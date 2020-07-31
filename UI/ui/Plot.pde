import garciadelcastillo.dashedlines.*;
class Plot extends Element{
  boolean autoscale, showFit, showTitle, dragging;
  float xmax, xmin, ymax, ymin, winymax, winymin, winxmax, winxmin;
  int yzero, xzero, padLeft, padBot;
  ArrayList<Float> xs,ys;
  ArrayList<Integer> xcoords, ycoords;
  String xlabel, ylabel;
  float xbar,x2bar,ybar,y2bar,intercept,slope,rms,mappedMouseX,mappedMouseY;
  DashedLines dash;
  
  public Plot(GUI frame, int x, int y, int w, int h){
    super(frame, x,y,w,h,str(random(1.0)));
    xs = new ArrayList<Float>();
    ys = new ArrayList<Float>();
    xcoords = new ArrayList<Integer>();
    ycoords = new ArrayList<Integer>();
    autoscale = true;
    padLeft = 80;
    padBot = 20;
    xlabel = "";
    ylabel = "";
    showFit=true;
    dash = new DashedLines(papple);
    dash.pattern(5, 5);
  }
  
  
  public Plot(GUI frame, int x, int y, int w, int h, String title, String xlabel, String ylabel){
    super(frame, x,y,w,h,title);
    xs = new ArrayList<Float>();
    ys = new ArrayList<Float>();
    xcoords = new ArrayList<Integer>();
    ycoords = new ArrayList<Integer>();
    autoscale = true;
    padLeft = 80;
    padBot = 20;
    this.xlabel = xlabel;
    this.ylabel = ylabel;
    showFit=true;
    dash = new DashedLines(papple);
    dash.pattern(5, 5);
  }
  
  public Plot(GUI frame, int x, int y, int w, int h, float winxmax, float winxmin, float winymax, float winymin){
    super(frame, x,y,w,h,str(random(1.0)));
    xs = new ArrayList<Float>();
    ys = new ArrayList<Float>();
    xcoords = new ArrayList<Integer>();
    ycoords = new ArrayList<Integer>();
    autoscale = false;
    this.winxmax = winxmax;
    this.winxmin = winxmin;
    this.winymax = winymax;
    this.winymin = winymin;
    padLeft = 100;
    padBot = 20;
    xlabel = "";
    ylabel = "";
    showFit=true;//Whether or not to draw the line of best fit
    dash = new DashedLines(papple);
    dash.pattern(5, 5);
  }
  public Plot(GUI frame, int x, int y, int w, int h, float winxmax, float winxmin, float winymax, float winymin, String title, String xlabel, String ylabel){
    super(frame, x,y,w,h,title);
    xs = new ArrayList<Float>();
    ys = new ArrayList<Float>();
    xcoords = new ArrayList<Integer>();
    ycoords = new ArrayList<Integer>();
    autoscale = false;
    this.winxmax = winxmax;
    this.winxmin = winxmin;
    this.winymax = winymax;
    this.winymin = winymin;
    padLeft = 100;
    padBot = 20;
    this.xlabel = xlabel;
    this.ylabel = ylabel;
    showFit=true;
    dash = new DashedLines(papple);
    dash.pattern(5, 5);
  }
  
  //Update the max, min and coords
  void update(){
    //Update global extrema
    xmax = max(xs);
    xmin = min(xs);
    ymax = max(ys);
    ymin = min(ys);
    
    if (autoscale){
      if(ymax > Float.MIN_VALUE && ymin < Float.MAX_VALUE){
        winymax = ymax + (ymax-ymin)*.01;
        winymin = ymin - (ymax-ymin)*.01;
      }
      if(xmax > Float.MIN_VALUE && xmin < Float.MAX_VALUE){
        winxmax = xmax + (xmax-xmin)*.01;
        winxmin = xmin - (xmax-xmin)*.01;
      }
    }
    
    //Adjust window for single point
    if (winymax <= winymin){
      winymax += 1.0;
      winymin -= 1.0;
    }
    if (winxmin >= winxmax){
      winxmax += 1.0;
      winxmin -= 1.0;
    }
    
    //Y coordinate of x-axis in pixels
    yzero = (int)map(0.0,winymin,winymax,y+h-padBot,y);
    xzero = (int)map(0.0,winxmin,winxmax,x+padLeft,x+w);
    
    //Update pixel coordinates of points
    for (int i = 0; i<xs.size(); i++){
      try{
        xcoords.set(i,int(map(xs.get(i),winxmin,winxmax,x+padLeft,x+w)));
      }
      catch(IndexOutOfBoundsException e){
        xcoords.add(int(map(xs.get(i),winxmin,winxmax,x+padLeft,x+w)));
      }
      try{
        ycoords.set(i,int(map(ys.get(i),winymin,winymax,y+h-padBot,y)));
      }
      catch(IndexOutOfBoundsException e){
        ycoords.add(int(map(ys.get(i),winymin,winymax,y+h-padBot,y)));
      }
    }
  }
  
  //Draw the frame, axis and points
  void display(){
    noStroke();
    fill(frame.bgdark);
    rect(x+padLeft,y,w-padLeft,h-padBot,5); // Draw slate background
    
    stroke(frame.bgfaded);
    if (winymax < 0.0) ;//line(x+padLeft,y,x+w,y);          // Draw the x-axis at the top
    else if (winymin > 0.0) ;//line(x+padLeft,y+h-padBot,x+w,y+h); // or the bottom 
    else line(x+padLeft, yzero, x+w, yzero);               // or somewhere in the middle of the screen

    if (winxmin <0.0 && winxmax>0.0) line(xzero,y,xzero,y+h-padBot);
    
    //label axes
    //textSize(18);
    fill(frame.fgdark);
    textAlign(RIGHT,TOP);
    text(nf(winymax,1,2),x+padLeft-5,y);
    textAlign(RIGHT,BOTTOM);
    text(nf(winymin,1,2),x+padLeft-5,y+h-padBot);
    textAlign(LEFT,TOP);
    text(nf(winxmin,1,2),x+padLeft,y+h-padBot);
    textAlign(RIGHT,TOP);
    text(nf(winxmax,1,2),x+w,y+h-padBot);
    
    textAlign(CENTER,TOP);
    text(xlabel,x+padLeft/2,y+h-padBot,x+w,y+h-padBot);
    
    textAlign(CENTER,BOTTOM);
    translate(x,y+h-padBot);
    rotate(-PI/2);
    text(ylabel,0,0,h,padLeft-5);
    rotate(PI/2);
    translate(-(x),-(y+h-padBot));
    
    
    //Draw points
    stroke(frame.fglight);
    for (int i = 1; i<xcoords.size(); i++){
      if(true)//xs.get(i)<winxmax && xs.get(i)>winxmin && ys.get(i)<winymax && ys.get(i)>winymin)
        line (xcoords.get(i-1),ycoords.get(i-1),xcoords.get(i),ycoords.get(i));
    }
    if (mouseOver()){
      cursor(CROSS);
      fill(frame.fglight);
      mappedMouseX=map(mouseX,x+padLeft,x+w,winxmin,winxmax);
      mappedMouseY=map(mouseY,y+h-padBot,y,winymin,winymax);
      textAlign(RIGHT,BOTTOM);
      text("("+nf(mappedMouseX,1,3)+", "+nf(mappedMouseY,1,3)+")",x+w-4,y+h-padBot-4);
      if(mouseY < y+h-padBot)
        dash.line(x+padLeft,mouseY,x+w,mouseY);
      if(mouseX > x+padLeft)
        dash.line(mouseX,y,mouseX,y+h-padBot);
    }
    
    if(showFit){
      getIntercept();
      stroke(frame.bgfaded);
      dash.line(x+padLeft,map(winxmin*slope+intercept,winymin,winymax,y+h-padBot,y),x+w,map(winxmax*slope+intercept,winymin,winymax,y+h-padBot,y));
    }
    if (showTitle){
      fill(frame.fglight);
      textAlign(CENTER,TOP);
      text(title,x+padLeft + (w-padLeft)/2,y+5);
    }
  }
  
  //Add a point (x,y)
  void addPoint(float x,float y){
    xs.add(new Float(x));
    ys.add(new Float(y));
    update();
  }
  
  //Drop the zero index point
  void dropPoint(){
    xs.remove(0);
    ys.remove(0);
    xcoords.remove(0);
    ycoords.remove(0);
    update();
  }
  void showTitle(boolean showTitle){
    this.showTitle = showTitle;
  }
  void showFit(boolean showFit){
    this.showFit = showFit;
  }
  void setAutoscale(boolean autoscale){
    this.autoscale = autoscale;
    update();
  }
  
  void setWindowFromCoords(int x1, int y1, int x2, int y2){
    autoscale=false;
    if(x1>x2){
      winxmax=map(x1,x+padLeft,x+w,winxmin,winxmax);
      winxmin=map(x2,x+padLeft,x+w,winxmin,winxmax);
    }
    else{
      winxmax=map(x2,x+padLeft,x+w,winxmin,winxmax);
      winxmin=map(x1,x+padLeft,x+w,winxmin,winxmax);
    }
    if(y1<y2){
      winymax=map(y1,y+h-padBot,y,winymin,winymax);
      winymin=map(y2,y+h-padBot,y,winymin,winymax);
    }
    else{
      winymax=map(y2,y+h-padBot,y,winymin,winymax);
      winymin=map(y1,y+h-padBot,y,winymin,winymax);
    }
    update();
  }
  
  void clear(){
    xs.clear();
    ys.clear();
    xcoords.clear();
    ycoords.clear();
  }
  
  int getSize(){
    return xs.size();
  }
  
  float getXbar(){
    int n = xs.size();
    xbar = 0.0;
    for (float x : xs) xbar+=x;
    xbar /= n;
    return xbar;
  }
  
  float getYbar(){
    int n = ys.size();
    ybar = 0.0;
    for(float y : ys) ybar+=y;
    ybar /= n;
    return ybar;
  }
  
  float getSlope(){
    getXbar();
    getYbar();
    int n = xs.size();
    
    float num=0.0, den=0.0;
    for (int i = 0; i < n; i++){
      num+=(xs.get(i)-xbar)*(ys.get(i)-ybar);
      den+=pow((xs.get(i)-xbar),2);
    }
    slope = num/den;
    return slope;
  }
  float getIntercept(){
    getSlope();
    //println("Slope: " + slope + " Ybar: " + ybar + " Xbar: " + xbar + " slope no intercept: " + ybar/xbar);
    intercept = ybar - xbar*slope;
    return intercept;
  }
  
  float getRMS(){
    getIntercept();
    int n = xs.size();
    rms = 0.0;
    for(int i = 0; i < n; i++){
      rms+=pow(slope*xs.get(i)+intercept - ys.get(i),2);
    }
    rms = sqrt(rms/n);
    return rms;
  }
  
  void onDrag(){
    if(mouseOver(previousMouseX,previousMouseY) && mouseOver()){
      noFill();
      stroke(frame.fglight);
      dash.line(x+padLeft,previousMouseY,x+w,previousMouseY);
      dash.line(previousMouseX,y,previousMouseX,y+h-padBot);
      noStroke();
      fill(255,220,0,10);
      rect(previousMouseX,previousMouseY,mouseX-previousMouseX, mouseY-previousMouseY);
      
    }
  }
  
  void onRelease(){
  if(mouseOver(previousMouseX,previousMouseY) && mouseOver() && abs(mouseX-previousMouseX) > 5 && abs(mouseY-previousMouseY) > 5)
    setWindowFromCoords(previousMouseX,previousMouseY,mouseX,mouseY);
  }
  
  void onDoubleClick(){
    setAutoscale(true);
  }
  
  //Calculate max value in float ArrayList
  private float max(ArrayList<Float> nums){
    float currentMax = Float.MIN_VALUE;
    for (float f : nums){
      if(f > currentMax) currentMax = f;
    }
    return currentMax;
  }
  private float min(ArrayList<Float> nums){
    float currentMax = Float.MAX_VALUE;
    for (float f : nums){
      if(f < currentMax) currentMax = f;
    }
    return currentMax;
  }
  
}
