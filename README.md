# Guess My Drawing
Guess My Drawing classifies drawn images, currently supporting 345 different categories. It displays the top-5 confidence categories. I trained the model on [Google's Quick, Draw! dataset](https://quickdraw.withgoogle.com/data), and use iOS 11's CoreML framework to run the trained model.


### Device Installation
1. Download or clone this repository.
2. Open the project file in Xcode.
3. Build and install the application to your device.


### Screenshots
Here is a GIF of it classifying a few drawings correctly:
![App](images/app.gif?raw=true "App")


### Training the Model
I am currently not releasing the details on how I trained the model. The architecture of the model is:

```
convolution (3x3 window, 64 filters) w/ relu
convolution (3x3 window, 32 filters) w/ relu
convolution (5x5 window, 32 filters) w/ relu
fully connected (1024 neurons) w/ relu
fully connected (512 neurons) w/ relu
fully connected (512 neurons) w/ relu
fully connected (345 neurons) w/ softmax
```
