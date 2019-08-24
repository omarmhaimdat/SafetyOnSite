import turicreate as tc
import os

IMAGES_DIR = 'SafetyOnSite'
csv_path = 'out.csv'
csv_sf = tc.SFrame.read_csv(csv_path)

def row_to_bbox_coordinates(row):
    """
    Takes a row and returns a dictionary representing bounding
    box coordinates:  (center_x, center_y, width, height)  e.g. {'x': 100, 'y': 120, 'width': 80, 'height': 120}
    """
    return {'x': row['xMin'] + (row['xMax'] - row['xMin'])/2,
            'width': (row['xMax'] - row['xMin']),
            'y': row['yMin'] + (row['yMax'] - row['yMin'])/2,
            'height': (row['yMax'] - row['yMin'])}

csv_sf['coordinates'] = csv_sf.apply(row_to_bbox_coordinates)
del csv_sf['id'], csv_sf['xMin'], csv_sf['xMax'], csv_sf['yMin'], csv_sf['yMax']
csv_sf = csv_sf.rename({'name': 'label', 'image': 'name'})

# Load all images in random order
sf_images = tc.image_analysis.load_images(IMAGES_DIR, recursive=True,
    random_order=True)

# Split path to get filename
info = sf_images['path'].apply(lambda path: os.path.basename(path).split('/')[:1])

# Rename columns to 'name'
info = info.unpack().rename({'X.0': 'name'})

# Add to our main SFrame
sf_images = sf_images.add_columns(info)

# Original path no longer needed
del sf_images['path']

# Combine label and coordinates into a bounding box dictionary
csv_sf = csv_sf.pack_columns(['label', 'coordinates'], new_column_name='bbox', dtype=dict)

# Combine bounding boxes of the same 'name' into lists
sf_annotations = csv_sf.groupby('name',
    {'annotations': tc.aggregate.CONCAT('bbox')})

sf = sf_images.join(sf_annotations, on='name', how='left')

sf['annotations'] = sf['annotations'].fillna([])

# Save SFrame
sf.save('SafetyOnSite.sframe')