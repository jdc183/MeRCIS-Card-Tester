
class Button extends Element{
  //int x,y,w,h,r;
  int r;
  private Runnable runnable;
  public Button(GUI frame, int x, int y, int w, int h){
    super(frame, x,y,w,h,str(random(1.0)));
    r = 5;
    this.runnable = new Runnable(){public void run(){;}};
  }
  
  public Button(GUI frame, int x, int y, int w, int h, Runnable runnable){
    super(frame, x,y,w,h,str(random(1.0)));
    r = 5;
    this.runnable = runnable;
    title = "";
  }
  public Button(GUI frame, int x, int y, int w, int h, String title, Runnable runnable){
    super(frame, x,y,w,h,title);
    r = 5;
    this.runnable = runnable;
  }
  
  public void display(){
    noStroke();
    fill(frame.fgfaded);
    if (super.mouseOver()){
      fill(frame.fglight);
      rect(x-2,y-2,w+4,h+4,r);
      cursor(ARROW);
    }
    else rect(x,y,w,h,r);
    fill(frame.fgdark);
    textAlign(CENTER, CENTER);
    text(title,x+w/2,y+h/2-2);//,x+w,y+h+4);
  }
  void setTitle(String title){
    super.title = title;
  }
  void onClick(){
    runnable.run();
  }
}
