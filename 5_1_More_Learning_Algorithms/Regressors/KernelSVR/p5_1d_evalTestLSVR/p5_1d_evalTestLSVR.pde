//*********************************************
// Example Code for Interactive Intelligent Products
// Rong-Hao Liang: r.liang@tue.nl
//*********************************************

import Weka4P.*;
Weka4P wp;


void setup() {
  size(500, 500);             //set a canvas
  frameRate(60);
  wp = new Weka4P(this);
  wp.loadTrainARFF("mouseTrainNum.arff"); //load a ARFF dataset
  wp.loadTestARFF("mouseTestNum.arff");//load a ARFF dataset
  wp.loadModel("KSVR.model"); //load a pretrained model.
  wp.setModelDrawing(2);          //set the model visualization (for 2D features) with unit = 2
  wp.evaluateTestSet(true, true);  //5-fold cross validation (isRegression = true, showEvalDetails=true)
}

void draw() {
  wp.drawModel(0, 0); //draw the model visualization (for 2D features)
  wp.drawDataPoints(wp.test); //draw the datapoints
  float[] X = {mouseX, mouseY}; 
  double Y = wp.getPredictionIndex(X);
  wp.drawPrediction(X, Y); //draw the prediction
}
