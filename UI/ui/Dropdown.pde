class Dropdown extends Element{
  int temph;
  ArrayList<String> stuff;
  String selected;
  private Runnable runnable;
  public Dropdown(GUI frame, int x, int y, int w, int h, String title){
    super(frame, x,y,w,h,title);
    temph = h;
    stuff = new ArrayList<String>();
    selected = title;
    runnable = new Runnable(){public void run(){;}};
  }
  public Dropdown(GUI frame, int x, int y, int w, int h, String title, Runnable runnable){
    super(frame,x,y,w,h,title);
    temph = h;
    stuff = new ArrayList<String>();
    selected = title;
    this.runnable = runnable;
  }
  public String getSelected(){
    return selected;
  }
  public void setSelected(int n){
    selected = stuff.get(n);
    runnable.run();
    
  }
  public void setSelected(String s){
    selected = s;
    runnable.run();
  }
  public void add(String thing){
    stuff.add(thing);
  }
  public void clear(){
    stuff.clear();
  }
  public ArrayList<String> getStuff(){
    return stuff;
  }
  public void display(){
    if(!this.isFocus)
      temph = h;
    noStroke();
    fill(frame.fgfaded);
    if(this.isFocus || mouseOver()){
      rect(x,y,w,temph,5);
    }
    textAlign(LEFT,CENTER);
    textSize(18);
    if(temph > h){
      for(int i = 0; i < stuff.size(); i++){
        fill(frame.fgfaded);
          if(stuff.get(i).equals(mouseOverWhat())){
            fill(frame.fglight);
            rect(x,y+h*(i+1),w,h,5);
          }
        fill(frame.fgdark);
        text(stuff.get(i),x+10,y+10+h*(i+1));
      }
    
    }
    fill(frame.fgdark);
    textAlign(RIGHT,CENTER);
    text(selected,x+w-36,y+10);
    //if(mouseOver()){
    //  cursor(ARROW);
    //}
    
  }
  public void onClick(){
    if (!(temph>h+2))  temph = h+h*stuff.size();
    else{
      if (!selected.equals(mouseOverWhat())){
        selected = mouseOverWhat();
        runnable.run();
      }
      temph = h; 
    }
  }
  public void defocus(){
    temph = h;
  }
  boolean mouseOver(){
    return mouseX > x && mouseY > y && mouseX < x + w && mouseY < y + temph;
  }
  String mouseOverWhat(){
    if (!mouseOver()) return "";
    if (mouseX > x && mouseY > y && mouseX < x + w && mouseY < y + h) return selected;
    return stuff.get(int(map(mouseY,y+temph,y+h,stuff.size(),0)));
  } 
}
