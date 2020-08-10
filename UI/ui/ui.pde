import processing.serial.*;


GUI frame1;  //GUI container object for all the elements
Plot scope;  //Graph of the transfer characteristics
Plot voltageWaterfall;
Plot currentWaterfall;
Plot tran1, tran2; //Graphs of transient response
Button playButton;  //button to advance test
Button sweepButton;
Button refreshButt; //Button to refresh the
Button resetButton; //Clears the scope buffer and stops test
Button getTransients;
Dropdown portsDropdown;  //Dropdown to select COM port
TextEntry rSenseEntry;  //
TextEntry stepEntry;
TextEntry bufferEntry;
TextEntry sampleRateEntry;
TextEntry voltageEntry;
Slider voltageSlider;
//String portName;
Serial testerPort;  //The serial port object we yuse here
String in;
String[] portList;
char readin;
float dacVolts;
float adcVolts;
float stepVoltage;
float dir;
float rSense;
float sampleRate;
int bufferSize;
boolean go;
boolean mouseOverNothing;
boolean sweep;
public int previousMouseX, previousMouseY;
int timeOfLastClick;
int bufferMax;
PFont baseFont;
public PApplet papple;

void setup() {  //This method is called once at startup
  size(800, 1000);
  //String[] fontList = PFont.list();
  //printArray(fontList);
  
  //baseFont = createFont("Monospace.plain",18);
  //textFont(baseFont);
  
  papple = this;
  
  prepareExitHandler();
  
  //elements = new ArrayList<Element>();//Arraylist to contain gui elements
  frame1 = new GUI();
  
  //This button advances the test
  playButton = new Button(frame1, 10,10,70,26,"\u25ba",new Runnable(){public void run(){playButtonCallback();}});
  frame1.add(playButton);
  
  //This is the plot of the amplifier transfer characteristics
  scope = new Plot(frame1, 10,270,770,370,"Scope","Input Voltage (V)","Output Current (mA)");//,4.0,-0.1,4.0,-0.1);
  //scope.showTitle(true);
  frame1.add(scope);
  
  sweepButton = new Button(frame1, 10, 240, 70, 26, "Sweep", new Runnable(){public void run(){sweep = !sweep;}});
  frame1.add(sweepButton);
  
  resetButton = new Button(frame1, 90,10,50,26,"RST",new Runnable(){public void run(){reset();}});
  frame1.add(resetButton);
  
  rSenseEntry = new TextEntry(frame1, 220,10,46,26,"rSense",new Runnable(){public void run(){changerSense();}});
  frame1.add(rSenseEntry);
  rSense = 3.3/330*1000;
  rSenseEntry.setValue(str(rSense));
  rSenseEntry.setStep(0.01);
  
  bufferEntry = new TextEntry(frame1, 366,10,56,26,"buffer",new Runnable(){public void run(){changeBufferMax();}});
  frame1.add(bufferEntry);
  bufferMax = 1320;
  bufferEntry.setValue(str(bufferMax));
  bufferEntry.setStep(1.0);
  
  stepEntry = new TextEntry(frame1, 141,240,46,26,"step",new Runnable(){public void run(){changeStepVoltage();}});
  frame1.add(stepEntry);
  stepVoltage = 0.01;
  stepEntry.setValue(str(stepVoltage));
  stepEntry.setStep(0.01);
  
  voltageSlider = new Slider(frame1, 20, 75, 50, 140, "Voltage Slider",new Runnable(){public void run(){voltageSliderCallback();}});
  frame1.add(voltageSlider);
  
  voltageEntry = new TextEntry(frame1, 20,41,26, 26, "Voltage", new Runnable(){public void run(){voltageEntryCallback();}});
  voltageEntry.setValue("0.00");
  voltageEntry.setStep(0.01);
  frame1.add(voltageEntry);
  
  voltageWaterfall = new Plot(frame1, 60,45,700,100,"voltageWaterfall","Time (ms)","(V)");
  voltageWaterfall.showFit(false);
  frame1.add(voltageWaterfall);
  
  currentWaterfall = new Plot(frame1, 60,128,700,100,"currentWaterfall","Time (ms)","(mA)");
  currentWaterfall.showFit(false);
  frame1.add(currentWaterfall);
  
  getTransients = new Button(frame1, 10, 645, 70, 26, "\u21bb", new Runnable(){public void run(){getTransients();}});
  frame1.add(getTransients);
  
  sampleRateEntry = new TextEntry(frame1, 90, 645, 26, 26, "Sample Rate", new Runnable(){public void run(){changeSampleRate();}});
  sampleRateEntry.setStep(1);
  sampleRate = 1/0.0526;
  sampleRateEntry.setValue(nf(sampleRate,1,2));
  frame1.add(sampleRateEntry);
  
  tran1 = new Plot(frame1, 10,680,380,300,"Forced Response", "Time (ms)","Output Current (mA)");//,4.0,-0.1,4.0,-0.1);
  tran1.showTitle(true);
  tran1.setWindow(-2,-50,2,450);
  tran1.showFit(false);
  frame1.add(tran1);
  tran2 = new Plot(frame1, 400,680,380,300,"Natural Response"," ","Output Current (mA)");//,4.0,-0.1,4.0,-0.1);
  
  tran2.setWindow(-2,-50,2,450);
  tran2.showTitle(true);
  tran2.showFit(false);
  frame1.add(tran2);
  
  
  //This is a dropdown for selecting the serial port
  portsDropdown = new Dropdown(frame1, 570,10,200,26,"No UART detected", new Runnable(){public void run(){changeSerial();}});
  frame1.add(portsDropdown);
  
  //This button refreshes the serial port list
  refreshButt = new Button(frame1, 744,10,26,26,"\u21bb",new Runnable(){public void run(){refreshPorts();}});
  frame1.add(refreshButt);
  
  
  //Add the initially detected ports to the dropdown
  portList = Serial.list();
  for (String p : portList){
    portsDropdown.add(p);
  }
  
  if (portList.length > 0) portsDropdown.setSelected(0);
 
  //These parameters are used to scale the test input/output
  adcVolts = 0.0; dacVolts = 0.0; dir = stepVoltage;
  //Not used yet
  go = false;
  
  
  //////Colors used by gui elements
  //fg1 = color(0);  //black used for lines on buttons and dropdown
  //fg2 = color(220); //Grey used for some stuff?
  //fg3 = color(255,220,0);  // Yellow used for text and lines on scope
  //bg1 = color(220); //Grey used for button fill and background
  //bg2 = color(0);   //Black used for plot
  //bg3 = color(255); //White used for buttons when mouseover
}

void draw() {
  clear();//Erase the canvas
  background(frame1.bgfaded);//Set background to greyish green
  
  mouseOverNothing = true;
  for (Element e : frame1.getElements()){  //Draw all of the gui elements
    e.display();
    if (e.mouseOver()) mouseOverNothing = false;
  }
  if (mouseOverNothing) cursor(ARROW);
  
  fill(0);
  textAlign(RIGHT,TOP);
  text("Rsense:",220,12);
  textAlign(LEFT, TOP);
  text("\u03A9",220+rSenseEntry.getWidth(),12);
  
  textAlign(RIGHT,TOP);
  text("Step:",140,242);
  textAlign(LEFT, TOP);
  text("V",140+stepEntry.getWidth(),242);
  
  textAlign(RIGHT,TOP);
  text("Buffer:",365,12);
  
  textAlign(LEFT, TOP);
  text("kSa/s",96+textWidth(sampleRateEntry.getValue()),647);
  
  text("V",24+textWidth(voltageEntry.getValue()),43);
  
  doSerial();//Send serial message and wait for response
  
  //Write the transfer analytics at the top of scope
  textAlign(LEFT, TOP);
  fill(frame1.fglight);
  text("Gain: " + nf(scope.getSlope(),1,2) + "mS", 100, 55+220);
  text("Offset: " + nf(scope.getIntercept(),1,4) + "mA", 300, 55+220);
  text("RMS Noise: " + nf(scope.getRMS(),1,3) + "mA", 500, 55+220);
}

//Send serial message and wait for response
void doSerial(){
  if(go){
    try{
    if(dacVolts >= 3.3) {dacVolts=3.3; dir = -abs(stepVoltage);}
    if(dacVolts <= 0.0) {dacVolts=0.0; dir =  abs(stepVoltage);}
    testerPort.clear();  //Empty the buffer just in case it collects some miscellaneous garbage for no reason
    testerPort.write(nf(dacVolts,1,3)+"\n\r");  //Print the desired voltage as a float to the serial port.  I should have really converted this to a 12bit value
    
    voltageWaterfall.addPoint(millis(),dacVolts);
    
    //printArray(byte((str(j)+"\n\r").toCharArray()));
    //print(str(j)+"\n\r");
    //while(testerPort.available()<2);
    
    delay(5);//Give teensy a chance to reply, though it really shouldnt' take this long
    in = testerPort.readStringUntil('\n');
    //println(in);
    try{
    adcVolts = float(in);
    currentWaterfall.addPoint(millis(),adcVolts/rSense*1000.0);
    
    scope.addPoint(dacVolts,adcVolts/rSense*1000.0);///rsense*1000.0);
    if(sweep){
      dacVolts += dir;
      voltageSlider.setVal(100*dacVolts/3.3);
      voltageEntry.setValue(nf(dacVolts,1,2));
    }
    else
      dacVolts=voltageSlider.getVal()*3.3/100;
    }
    catch(Exception e){println("Dropped a packet!");} //If we can't parse a float out of the data, something went wrong
    
    //scope.addPoint(j,k);
    //j+=1;
    //k+=random(-1.0,1.0);
    }
    catch(Exception e){
      println("Error:  Select a valid Serial port");
    }
    while (scope.getSize() >= bufferMax) scope.dropPoint();
    while (voltageWaterfall.getSize()>=bufferMax) voltageWaterfall.dropPoint();
    while (currentWaterfall.getSize()>=bufferMax) currentWaterfall.dropPoint();
  }
  else {
    try{
      dacVolts=0.0;
      adcVolts=0.0;
      testerPort.write("0.00\n\r");
      voltageEntry.setValue("0.00");
      voltageSlider.setVal(0.0);
      //testerPort.write(str(voltageSlider.getVal()*3.3/100)+"\n\r");
      //voltageWaterfall.addPoint(millis(),dacVolts);
      //while (voltageWaterfall.getSize()>=bufferMax) voltageWaterfall.dropPoint();
    }
    catch(Exception e){
      //println("Error:  Select a valid Serial port");
    }
  }
}

//Called whenever left mouse button is pressed
void mouseClicked() {
  frame1.handleClick();
  if(millis()-timeOfLastClick < 500) mouseDoubleClicked();
  timeOfLastClick = millis();
}
void mouseDoubleClicked(){
  frame1.handleDoubleClick();
}
void mousePressed(){
  previousMouseX = mouseX;
  previousMouseY = mouseY;
  frame1.handlePress();
}
void mouseDragged(){
  frame1.handleDrag();
}
void mouseReleased(){
  frame1.handleRelease();
}

void keyPressed(){
  frame1.handleKeyPress();
  if(key == ' ') playButtonCallback();
}

void keyReleased(){
  frame1.handleKeyRelease();
}

void changeSampleRate(){
  if (float(sampleRateEntry.getValue()) > 0.0)
    sampleRate = float(sampleRateEntry.getValue());
  sampleRateEntry.setValue(nf(sampleRate,1,2));
}

//Called when refresh button pressed
void refreshPorts(){
  boolean selectedInPortList = false;
  portsDropdown.clear();
  portList = Serial.list();
  printArray(Serial.list());
  if (portList.length > 0 ){
    for (String p : portList){
      portsDropdown.add(p);
      if (portsDropdown.getSelected().equals(p))
        selectedInPortList = true;
    }
    if (!selectedInPortList)
      portsDropdown.setSelected(0);
  }
  else{
    portsDropdown.setSelected("No UART detected");
  }
}

void reset(){
  scope.clear();
  voltageWaterfall.clear();
  currentWaterfall.clear();
  scope.setAutoscale(true);
  voltageWaterfall.setAutoscale(true);
  currentWaterfall.setAutoscale(true);
  tran1.setWindow(-2,-50,2,450);
  tran1.update();
  tran2.setWindow(-2,-50,2,450);
  tran2.update();
  //dacVolts = 0;
  //dir = stepVoltage;
  //go = false;
  //playButton.setTitle("\u25ba");
}

void getTransients(){
  try{
  cursor(WAIT);
  testerPort.write("r\n");
  delay(3000);
  String tranString = testerPort.readStringUntil('r');
  String[] tranStrings = tranString.split("\n");
  float[] tranFloats = new float[2048];
  for (String s :tranStrings){
    try{
    tranFloats[int(s.split(",")[0])] = float(s.split(",")[1]);
    }
    catch(ArrayIndexOutOfBoundsException e){}
  }
  //float[] tranFloats = float(tranString.split("\n"));
  tran1.clear();
  tran2.clear();
  for(int i = 0; i < tranFloats.length-1;i++){
     if(i >= 384 && i<= 984)tran1.addPoint((i-684)/sampleRate/*.0526*/,tranFloats[i]/rSense*1000.0);
     else if(i >= 1066 && i <= 1666) tran2.addPoint((i-1366)/sampleRate/*.0526*/,tranFloats[i]/rSense*1000.0);
  }
  }catch(NullPointerException e){
    
  }
  
}

//Called when new port is selected on dropdown
void changeSerial(){
  try{
    testerPort = new Serial(this,portsDropdown.getSelected(),115200);
  }
  catch(Exception e){;}
}

//Called when play button is pressed.  The serial comms are still a little gross and unreliable.  need to fix
void playButtonCallback(){
  refreshPorts();
  if(go)playButton.setTitle("\u25ba");
  else playButton.setTitle("ll");//\u25a0");
  go = !go;
}

void voltageEntryCallback(){
  if(abs(float(voltageEntry.getValue()))<3.3 && float(voltageEntry.getValue())>0.0)
    voltageSlider.setVal(abs(float(voltageEntry.getValue()))*100/3.3);
}

void voltageSliderCallback(){
  voltageEntry.setValue(nf(voltageSlider.getVal()/100*3.3,1,2));
}

void changerSense(){
  if(abs(float(rSenseEntry.getValue()))>0.001)
    rSense = float(rSenseEntry.getValue());
  rSenseEntry.setValue(nf(rSense,1,2));
}

void changeBufferMax(){
  if(int(bufferEntry.getValue())<=9999 && int(bufferEntry.getValue())>0)
    bufferMax = abs(int(bufferEntry.getValue()));
  bufferEntry.setValue(nf(bufferMax));
}

void changeStepVoltage(){
  if(abs(float(stepEntry.getValue()))<3.3/2 && float(stepEntry.getValue())>0.0)
    stepVoltage = abs(float(stepEntry.getValue()));
  stepEntry.setValue(nf(stepVoltage,1,2));
}


private void prepareExitHandler() {

Runtime.getRuntime().addShutdownHook(new Thread(new Runnable() {

public void run () {

  System.out.println("SHUTDOWN HOOK");

   // application exit code here
   try{
      testerPort = new Serial(papple,portsDropdown.getSelected(),115200);//Reopen serial port because runtime has already closed it
      testerPort.write("0.00\n\r");
      testerPort.stop();  //Close the serial port for real
    }
    catch(Exception e){
      println("Error:  Failed to turn off output on close");
    }

}

}));

}
