public class Slider extends Element{
  boolean vertical;
  float val;
  Runnable runnable;
  public Slider(GUI frame, int x, int y, int w, int h, String title, Runnable runnable){
    super(frame,x,y,w,h,title);
    vertical = true;
    this.runnable = runnable;
  }
  public Slider(GUI frame, int x, int y, int w, int h, String title, Runnable runnable, boolean vertical){
    super(frame,x,y,w,h,title);
    this.vertical = vertical;
    this.runnable = runnable;
  }
  void display(){
    if (vertical){
      noStroke();
      fill(frame.bgdark);
      rect(x+w/2-2,y,4,h,2);
      if(mouseOver())
        fill(frame.fglight);
      else
        fill(frame.fgfaded);
      rect(x,y+h-h*val/100-5,w,10,5);
    }
    
  }
  void onPress(){
    if (vertical){
      val = float(y+h-mouseY)/float(h)*100;
    }
    
    runnable.run();
  }
  void onDrag(){
    if (vertical){
      val = float(y+h-mouseY)/float(h)*100;
    }
    
    runnable.run();
  }
  
  void setVal(float val){
    this.val = val;
  }
  
  float getVal(){
    return val;
  }
  boolean mouseOver(){
    
    if (mousePressed)
      return mouseX>x && mouseX<x+w && mouseY>y-1 && mouseY<y+h+1;
    
    if((mouseX>x && mouseX<x+w && mouseY<y+h-h*val/100+5 && mouseY>y+h-h*val/100-5)||
    (mouseX>x+w/2-2 && mouseX<x+w/2+2 && mouseY<y+h && mouseY>y))
      return true;
      
    return false;
  }
}
