# Evaluate Construction Site Safety on iOS using Machine Learning
> Building an iOS application for safety on site with Swift, Turi Create, and Core ML

We'll create an iOS application that predicts whether someone is wearing a helmet or not using a simple classifier. But I also added an object detection script if you want to go further.

I'll mainly go through `object detection` part.

### Final result - Classifier
![Final Results - classifier](classifier.png)

### Final result - Object Detection (w/out bounding boxes)
![Final Results - object detection](object-detection.png)

## Data preparation

MacOS, Linux & Windows:

```sh
./data_preparation > data_preparation.py
```

Download a large dataset of images with:

* helmet and no jacket
* helmet and jacket
* no helmet and no jacket
* no helmet and jacket

Try to balance out the dataset to improve your results.

I've used an open source repo on GitHub where you can annotate and generate a `.csv` file with the 7 columns formatted in a way that can easily be used with turicreate.

[Simple Image Annotator by Sebastian G. Perez ](https://github.com/sgp715/simple_image_annotator)

You should at this point have a `.csv` file with the necessary information to train an object detection model.

The simple Image Annotator will output a file at the end of the annotation process called `out.csv`.


## Train the model

MacOS, Linux & Windows:

```sh
./training_script > main.py
```

## About me

**Omar MHAIMDAT** – [Linkedin](https://www.linkedin.com/in/omarmhaimdat/) – omarmhaimdat@gmail.com

Distributed under the MIT license. See ``LICENSE`` for more information.

###[Look at the rest of my repos](https://github.com/omarmhaimdat/)
