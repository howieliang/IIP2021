//*********************************************
// Example Code for Interactive Intelligent Products
// Rong-Hao Liang: r.liang@tue.nl
//*********************************************

import Weka4P.*;
Weka4P wp;

void setup() {
  size(500, 500);             //set a canvas
  wp = new Weka4P(this);
  
  wp.loadTrainARFF("mouseTrain.arff");//load a ARFF dataset
  wp.loadModel("LinearSVC.model"); //load a pretrained model.
  wp.setModelDrawing(2);          //set the model visualization (for 2D features) with unit = 2
}
void draw() {
  wp.drawModel(0, 0);  //draw the model visualization (for 2D features)
  float[] X = {mouseX, mouseY}; 
  String Y = wp.getPrediction(X);
  wp.drawPrediction(X, Y); //draw the prediction
}
