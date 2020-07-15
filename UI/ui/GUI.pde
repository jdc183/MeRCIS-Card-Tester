class GUI{
  ArrayList<Element> elements;  //Container for gui elements
  String focus;
  color fgdark,fglight,fgfaded,bgdark,bglight,bgfaded;
  
  
  public GUI(){
    elements = new ArrayList<Element>();
    
    //Use default color scheme
    fgdark = color(0,0,0);  //blaque
    fglight = color(255,220,0);  //deep jaundice highlight
    fgfaded = color(255,255,255);  //wight
    bgdark = color(10,40,20);  //Gooseturd dark green slate
    bglight = color(255,255,255);  //Pasty
    bgfaded = color(190,200,195);  //Birdpoop/mildew undersaturated light green
  }
  
  public void add(Element e){
    elements.add(e);
  }
  
  public ArrayList<Element> getElements(){
    return elements;
  }
  
  public void setFocus(String newFocus){
    focus = newFocus;
    focusElement(focus);
  }
  
  public String getFocus(){
    return focus;
  }
  
  public void focusElement(String focus){
    for (int i = 0; i < elements.size(); i++){
      if(elements.get(i).getTitle() == focus)
        elements.get(i).setFocus(true);
      else{
        if (elements.get(i).isFocused())
          elements.get(i).defocus();
        elements.get(i).setFocus(false);
      }
    }
    //println(focus);
  }
  public int getIndex(String element){
    for (int i = 0; i < elements.size(); i++){
      if(elements.get(i).getTitle() == element)
        return i;
    }
    return -1;
  }
  public Element getFocusElement(){
    for (int i = 0; i < elements.size(); i++){
      if(elements.get(i).getTitle() == focus)
        return elements.get(i);
    }
    return null;
  }
  
  public Element getMouseOverElement(){
    for (int i = elements.size()-1; i >= 0; i--){
      if(elements.get(i).mouseOver())
        return elements.get(i);
    }
    return null;
  }
  
  public void handleClick(){
    //println(getMouseOverElement().title);
    if(getMouseOverElement() != null){
      getMouseOverElement().onClick();  //If the mouse is on an element when pressed, call that elements runnable
      return;
    }
    setFocus(null);
  }
  
  public void handleDoubleClick(){
    if(getMouseOverElement() != null){
      getMouseOverElement().onDoubleClick();  //If the mouse is on an element when pressed, call that elements runnable
    }
  }
  public void handlePress(){
    if(getMouseOverElement() != null){
      this.getMouseOverElement().onPress();
      setFocus(getMouseOverElement().getTitle());
    }
  }
  public void handleDrag(){
    if(getMouseOverElement() != null)
    getMouseOverElement().onDrag();
  }
  public void handleRelease(){
    if(getMouseOverElement() != null)
    getMouseOverElement().onRelease();
  }
  
  public void handleKeyPress(){
    //if(key == TAB){
    //  try{
    //  println(getIndex(getFocusElement().getTitle()));
    //  if(getIndex(getFocusElement().getTitle())<elements.size()-1){
    //    focusElement(elements.get(getIndex(getFocusElement().getTitle())+1).getTitle());
    //    println();
    //  }catch(NullPointerException e){
        
    //    focusElement(elements.get(0).getTitle());
    //  }
    //  }else{
    //    focusElement(elements.get(0).getTitle());
    //  }
    //}
    if(getFocusElement() != null)
    getFocusElement().onKeyPress();
  }
  public void handleKeyRelease(){
    if(getFocusElement() != null)
      getFocusElement().onKeyRelease();
  }
}
