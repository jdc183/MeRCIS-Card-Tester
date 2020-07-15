//A basic gui element with constructor, display(), mouseOver(), and onClick() methods
abstract class Element{
  int x,y,w,h;//,id;
  String title;
  boolean isFocus;
  GUI frame;
  public Element(GUI frame, int x, int y, int w, int h, String title){//, int id){
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.title = title;
    this.frame = frame;
    isFocus = false;
    //this.id = id;
  }
  
  public String getTitle(){
    return title;
  }
  
  //execute this if element is focus of gui
  public void onKeyPress(){
    
  }
  public boolean isFocused(){
    return isFocus;
  };
  public void defocus(){
    
  }
  public void onKeyRelease(){
    
  }
  
  //Called in mousePressed() if mouseOver() 
  public void onClick(){
    
  }
  public void onDoubleClick(){
    
  }
  
  public void onPress(){
    
  }
  
  public void onDrag(){
    
  }
  
  public void onRelease(){
    
  }
  
  public void setFocus(boolean tf){
    isFocus = tf;
  }
  //Draw the gui element
  abstract void display();
  
  //Checks if the mouse is in the rectangular bounds of the gui element
  public boolean mouseOver(){
    return mouseX > x && mouseY > y && mouseX < x + w && mouseY < y + h;
  }
  public boolean mouseOver(int x1, int y1){
    return x1 > x && y1 > y && x1 < x + w && y1 < y + h;
  }
}
