import processing.serial.*;


GUI frame1;  //GUI container object for all the elements
Plot scope;  //Graph of the transfer characteristics
Plot tran1, tran2; //Graphs of transient response
Button playButton;  //button to advance test
Button refreshButt; //Button to refresh the
Button resetButton; //Clears the scope buffer and stops test
Button getTransients;
Dropdown portsDropdown;  //Dropdown to select COM port
TextEntry rSenseEntry;  //
TextEntry stepEntry;
TextEntry bufferEntry;
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
int bufferSize;
boolean go;
boolean mouseOverNothing;
public int previousMouseX, previousMouseY;
int timeOfLastClick;
int bufferMax;
PFont baseFont;
public PApplet papple;

void setup() {  //This method is called once at startup
  size(800, 800);  //Nice resolution for small screens, could easily be changed
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
  scope = new Plot(frame1, 10,45,760,390,"Scope","Input Voltage (V)","Output Current (mA)");//,4.0,-0.1,4.0,-0.1);
  //scope.showTitle(true);
  frame1.add(scope);
  
  resetButton = new Button(frame1, 90,10,50,26,"RST",new Runnable(){public void run(){reset();}});
  frame1.add(resetButton);
  
  //This is a dropdown for selecting the serial port
  portsDropdown = new Dropdown(frame1, 570,10,200,26,"No UART detected", new Runnable(){public void run(){changeSerial();}});
  frame1.add(portsDropdown);
  
  //This button refreshes the serial port list
  refreshButt = new Button(frame1, 744,10,26,26,"\u21bb",new Runnable(){public void run(){refreshPorts();}});
  frame1.add(refreshButt);
  
  rSenseEntry = new TextEntry(frame1, 220,10,46,26,"rSense",new Runnable(){public void run(){changerSense();}});
  frame1.add(rSenseEntry);
  rSense = 3.3/400*1000;
  rSenseEntry.setValue(str(rSense));
  rSenseEntry.setStep(0.01);
  
  bufferEntry = new TextEntry(frame1, 500,10,56,26,"buffer",new Runnable(){public void run(){changeBufferMax();}});
  frame1.add(bufferEntry);
  bufferMax = 1320;
  bufferEntry.setValue(str(bufferMax));
  bufferEntry.setStep(1.0);
  
  stepEntry = new TextEntry(frame1, 356,10,46,26,"step",new Runnable(){public void run(){changeStepVoltage();}});
  frame1.add(stepEntry);
  stepVoltage = 0.01;
  stepEntry.setValue(str(stepVoltage));
  stepEntry.setStep(0.01);
  
  getTransients = new Button(frame1, 10, 445, 70, 26, "\u21bb", new Runnable(){public void run(){getTransients();}});
  frame1.add(getTransients);
  
  tran1 = new Plot(frame1, 10,480,380,300,"Forced Response","Time (us)","Output Current (mA)");//,4.0,-0.1,4.0,-0.1);
  //tran1.showTitle(true);
  tran1.showFit(false);
  frame1.add(tran1);
  tran2 = new Plot(frame1, 400,480,380,300,"Natural Response"," ","Output Current (mA)");//,4.0,-0.1,4.0,-0.1);
  //tran2.showTitle(true);
  tran2.showFit(false);
  frame1.add(tran2);
  
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
  text("Step:",355,12);
  textAlign(LEFT, TOP);
  text("V",355+stepEntry.getWidth(),12);
  
  textAlign(RIGHT,TOP);
  text("Buffer:",500,12);
  
  doSerial();//Send serial message and wait for response
  
  //Write the transfer analytics at the top of scope
  textAlign(LEFT, TOP);
  fill(frame1.fglight);
  text("Gain: " + nf(scope.getSlope(),1,2) + "mS", 100, 55);
  text("Offset: " + nf(scope.getIntercept(),1,4) + "mA", 300, 55);
  text("RMS Noise: " + nf(scope.getRMS(),1,3) + "mA", 500, 55);
}

//Send serial message and wait for response
void doSerial(){
  if(go){
    try{
    
    if(dacVolts >= 3.3) {dacVolts=3.3; dir = -abs(stepVoltage);}
    if(dacVolts <= 0.0) {dacVolts=0.0; dir =  abs(stepVoltage);}
    testerPort.clear();  //Empty the buffer just in case it collects some miscellaneous garbage for no reason
    testerPort.write(nf(dacVolts,1,3)+"\n\r");  //Print the desired voltage as a float to the serial port.  I should really convert this to a 12bit value
    
    
    //printArray(byte((str(j)+"\n\r").toCharArray()));
    //print(str(j)+"\n\r");
    //while(testerPort.available()<2);
    
    delay(5);//Give teensy a chance to reply
    
    //while(readin != '\n'){
    //  readin = char(testerPort.read());
    //  in += readin;
    //}
    in = testerPort.readStringUntil('\n');
    //println(in);
    try{
    adcVolts = float(in);
    
    scope.addPoint(dacVolts,adcVolts/rSense*1000.0);///rsense*1000.0);
    dacVolts += dir;
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
  }
  else {
    try{
      dacVolts=0.0;
      adcVolts=0.0;
      testerPort.write("0.00\n\r");
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
  dacVolts = 0;
  dir = stepVoltage;
  //go = false;
  //playButton.setTitle("\u25ba");
}

void getTransients(){
  try{
  testerPort.write("r\n");
  cursor(WAIT);
  delay(2000);
  String tranString = testerPort.readStringUntil('r');
  float[] tranFloats = float(tranString.split("\n"));
  tran1.clear();
  tran2.clear();
  for(int i = 0; i < tranFloats.length-1;i++){
     if(i >= 500 && i<= 1000)tran1.addPoint((i-684)*52.6,tranFloats[i]);
     else if(i >= 1300 && i <= 1800) tran2.addPoint((i-1366)*52.6,tranFloats[i]);
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

//Called when button one is pressed.  The serial comms are still gross and unreliable.  need to fix
void playButtonCallback(){
  refreshPorts();
  if(go)playButton.setTitle("\u25ba");
  else playButton.setTitle("\u25a0");
  go = !go;
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
