//*********************************************
// Example Code for Interactive Intelligent Products
// Rong-Hao Liang: r.liang@tue.nl
//*********************************************

import papaya.*;
import processing.serial.*;
Serial port; 

int sensorNum = 1; 
int streamSize = 500;
int[] rawData = new int[sensorNum];
float[][] sensorHist = new float[sensorNum][streamSize]; //history data to show

float[][] diffArray = new float[sensorNum][streamSize]; //diff calculation: substract

float[] modeArray = new float[streamSize]; //To show activated or not
float[][] thldArray = new float[sensorNum][streamSize]; //diff calculation: substract
int activationThld = 20; //The diff threshold of activiation

int windowSize = 20; //The size of data window
float[][] windowArray = new float[sensorNum][windowSize]; //data window collection
boolean b_sampling = false; //flag to keep data collection non-preemptive
int sampleCnt = 0; //counter of samples

//Statistical Features
float[] windowM = new float[sensorNum]; //mean
float[] windowSD = new float[sensorNum]; //standard deviation

//Save
Table csvData;
boolean b_saveCSV = false;
String dataSetName = "A0GestTest"; 
String[] attrNames = new String[]{"m_x", "sd_x", "label"};
boolean[] attrIsNominal = new boolean[]{false, false, true};
int labelIndex = 0;

void setup() {
  size(500, 500, P2D);
  frameRate(60);
  initSerial();
  initCSV();
}

void draw() {
  background(255);
  lineGraph(sensorHist[0], 0, 500, 0, 0, width, height/3, 0); //draw sensor stream
  lineGraph(diffArray[0], 0, 500, 0, height/3, width, height/3, 1); //history of signal
  lineGraph(thldArray[0], 0, 500, 0, height/3, width, height/3, 2); //history of signal
  barGraph (modeArray, 0, height/3, width, height/3);
  showInfo("Thld: "+activationThld, 20, 2*height/3-20);
  showInfo("([A]:+/[Z]:-)", 20, 2*height/3);
  lineGraph(windowArray[0], 0, 1023, 0, 2*height/3, width, height/3, 3); //history of window
  showInfo("M: "+nf(windowM[0], 0, 2), 20, 2*height/3-60);
  showInfo("SD: "+nf(windowSD[0], 0, 2), 20, 2*height/3-40);
  showInfo("Current Label: "+getCharFromInteger(labelIndex), 20, 20);
  showInfo("Num of Data: "+csvData.getRowCount(), 20, 40);
  showInfo("[X]:del/[C]:clear/[S]:save", 20, 60);
  showInfo("[/]:label+", 20, 80);
  if (b_saveCSV) {
    saveCSV(dataSetName, csvData);
    saveARFF(dataSetName, csvData);
    b_saveCSV = false;
  }
}

void keyPressed() {
  if (key == 'A' || key == 'a') {
    activationThld = min(activationThld+5, 100);
  }
  if (key == 'Z' || key == 'z') {
    activationThld = max(activationThld-5, 10);
  }
  if (key == 'C' || key == 'c') {
    csvData.clearRows();
    println(csvData.getRowCount());
  }
  if (key == 'X' || key == 'x') {
    csvData.removeRow(csvData.getRowCount()-1);
  }
  if (key == 'S' || key == 's') {
    b_saveCSV = true;
  }
  if (key == '/') {
    ++labelIndex;
    labelIndex %= 10;
  }
  if (key == '0') {
    labelIndex = 0;
  }
}

void serialEvent(Serial port) {   
  String inData = port.readStringUntil('\n');  // read the serial string until seeing a carriage return
  if (inData.charAt(0) == 'A') {
    rawData[0] = int(trim(inData.substring(1)));
    appendArray( (sensorHist[0]), map(rawData[0], 0, 1023, 0, height)); //store the data to history (for visualization)
    //calculating diff
    float diff = abs( (sensorHist[0])[0] - (sensorHist[0])[1]); //absolute diff
    appendArray(diffArray[0], diff);
    appendArray(thldArray[0], activationThld);
    //test activation threshold
    if (diff>activationThld) { 
      appendArray(modeArray, 2); //activate when the absolute diff is beyond the activationThld
      if (b_sampling == false) { //if not sampling
        b_sampling = true; //do sampling
        sampleCnt = 0; //reset the counter
        for (int i = 0; i < sensorNum; i++) {
          for (int j = 0; j < windowSize; j++) {
            (windowArray[i])[j] = 0; //reset the window
          }
        }
      }
    } else { 
      if (b_sampling == true) appendArray(modeArray, 3); //otherwise, deactivate.
      else appendArray(modeArray, -1); //otherwise, deactivate.
    }

    if (b_sampling == true) {
      appendArray(windowArray[0], rawData[0]); //store the windowed data to history (for visualization)
      ++sampleCnt;
      if (sampleCnt == windowSize) {
        windowM[0] = Descriptive.mean(windowArray[0]); //mean
        windowSD[0] = Descriptive.std(windowArray[0], true); //standard deviation
        TableRow newRow = csvData.addRow();
        newRow.setFloat("m_x", windowM[0]);
        newRow.setFloat("sd_x", windowSD[0]);
        newRow.setString("label", getCharFromInteger(labelIndex));
        println(csvData.getRowCount());
        b_sampling = false; //stop sampling if the counter is equal to the window size
      }
    }
  }
  return;
}

//Append a value to a float[] array.
float[] appendArray (float[] _array, float _val) {
  float[] array = _array;
  float[] tempArray = new float[_array.length-1];
  arrayCopy(array, tempArray, tempArray.length);
  array[0] = _val;
  arrayCopy(tempArray, 0, array, 1, tempArray.length);
  return array;
}

void initSerial() {
  //Initiate the serial port
  for (int i = 0; i < Serial.list().length; i++) println("[", i, "]:", Serial.list()[i]);
  String portName = Serial.list()[Serial.list().length-1];//MAC: check the printed list
  //String portName = Serial.list()[9];//WINDOWS: check the printed list
  port = new Serial(this, portName, 115200);
  port.bufferUntil('\n'); // arduino ends each data packet with a carriage return 
  port.clear();           // flush the Serial buffer
}
