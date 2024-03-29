//*********************************************
// Example Code for Interactive Intelligent Products
// Rong-Hao Liang: r.liang@tue.nl
//*********************************************

import weka.core.Attribute; //https://weka.sourceforge.io/doc.dev/weka/core/Attribute.html
import weka.classifiers.Classifier; //https://weka.sourceforge.io/doc.stable-3-8/weka/classifiers/Classifier.html
import weka.core.Instances; //https://weka.sourceforge.io/doc.dev/weka/core/Instances.html

import Weka4P.*;
Weka4P wp;

ArrayList<Attribute>[] attributes = new ArrayList[1];
Instances[] instances = new Instances[1];
Classifier[] classifiers = new Classifier[3];

void setup() {
  size(500, 500);             //set a canvas
  frameRate(60);
  wp = new Weka4P(this);
  instances[0] = wp.loadTrainARFFToInstances("mouseTrainNum.arff");
  attributes[0] = wp.loadAttributesFromInstances(instances[0]);
  classifiers[0] = wp.loadModelToClassifier("LinearReg.model"); //load a pretrained model.
  classifiers[1] = wp.loadModelToClassifier("LSVR.model"); //load a pretrained model.
  classifiers[2] = wp.loadModelToClassifier("KSVR.model"); //load a pretrained model.
  wp.loadTestARFF("mouseTrainNum.arff");//load a ARFF dataset
  wp.evaluateTestSet(classifiers[0],wp.test,true, true);  //5-fold cross validation (, , isRegression = true, showEvalDetails=true)
  wp.evaluateTestSet(classifiers[1],wp.test,true, true);  //5-fold cross validation (, , isRegression = true, showEvalDetails=true)
  wp.evaluateTestSet(classifiers[2],wp.test,true, true);  //5-fold cross validation (, , isRegression = true, showEvalDetails=true)
}
void draw() {
  background(255);
  float[] X = {mouseX, mouseY};
  double[] Y = new double[classifiers.length];
  for(int i = 0 ; i < classifiers.length ; i++){
    Y[i] = wp.getPredictionIndex(X, classifiers[i], attributes[0]);
    wp.drawPrediction(X, Y[i], wp.colors[i]); //draw the prediction
  }
}
