
class TextEntry extends Element{
  String value;
  int cursorIndex;
  int holdIndex;
  boolean shift;
  Runnable runnable;
  float step;
  public TextEntry(GUI frame, int x, int y, int w, int h, String title, Runnable runnable){
    super(frame, x,y,w,h,title);
    this.runnable = runnable;
    value = "";
    step = 1;
  }
  public void display(){
    if(textWidth(value)>20) w=int(textWidth(value))+8;
    if (cursorIndex >= value.length()) cursorIndex = value.length();
    if (holdIndex >= value.length()) holdIndex = value.length();
    fill(frame.fgfaded);
    noStroke();
    if(this.isFocus || mouseOver())
      rect(x,y,w,h,5);
    fill(frame.fgdark);
    textAlign(LEFT,TOP);
    if(mouseOver()){
      cursor(TEXT);
    }
    if(isFocus){
      if(millis()%1000>400){
        stroke(frame.fgdark);
        line(x+4+textWidth(value.substring(0,cursorIndex)),y+4,x+4+textWidth(value.substring(0,cursorIndex)),y+2+18+2);
      }
      fill(frame.fglight);
      noStroke();
      
      if(cursorIndex > holdIndex){
        if (cursorIndex == value.length() && holdIndex == 0) rect(x,y,w,h,5);
        //else if (cursorIndex == value.length())
        //  rect(x+4+textWidth(value.substring(0,holdIndex)),y,w,h,5);
        //else if (holdIndex == 0)
        //  rect(x,y,textWidth(value.substring(holdIndex,cursorIndex)),h,5);
        else
          rect(x+4+textWidth(value.substring(0,holdIndex)),y+3,textWidth(value.substring(holdIndex,cursorIndex)), h-5);
      }
      else if (holdIndex > cursorIndex)
        if (holdIndex == value.length() && cursorIndex == 0) rect(x,y,w,h,5);
        //else if (holdIndex == value.length())
        //  rect(x+4+textWidth(value.substring(0,cursorIndex)),y,w,h,5);
        //else if (cursorIndex == 0)
        //  rect(x,y,textWidth(value.substring(cursorIndex,holdIndex)),h,5);
        else
          rect(x+4+textWidth(value.substring(0,cursorIndex)),y+3,textWidth(value.substring(cursorIndex,holdIndex)), h-5);
      
    }
    fill(frame.fgdark);
    text(value,x+4,y+2);
  }
  public int getWidth(){
    return w;
  }
  void setValue(String newText){
    value = newText;
  }
  void defocus(){
    runnable.run();
  }
  String getValue(){
    return value;
  }
  
  void onPress(){
    cursorIndex = indexOf(mouseX);
    holdIndex = cursorIndex;
  }
  void onDrag(){
    cursorIndex = indexOf(mouseX);
  }
  int indexOf(int xcoord){
    for(int i = value.length();i>=0;i--){
      if (xcoord >= x-3+textWidth(value.substring(0,i))){
        return i;
      }
    }
    return 0;
  }
  void onDoubleClick(){
    holdIndex = 0;
    cursorIndex = value.length();
  }
  void setStep(float step){
    this.step=step;
  }
  
  void onKeyPress(){
    if (key == DELETE){
      if (cursorIndex > holdIndex){
        value = value.substring(0,holdIndex)+value.substring(cursorIndex);
      }
      
      else if (cursorIndex < holdIndex){
        value = value.substring(0,cursorIndex)+value.substring(holdIndex);
      }
      else if (cursorIndex < value.length()){
        value = value.substring(0,cursorIndex)+value.substring(cursorIndex+1);
      }
      cursorIndex = min(cursorIndex,holdIndex);
      holdIndex = cursorIndex;
    }
    else if ((key > 31) && (key != CODED)){
      if (cursorIndex > holdIndex){
        value = value.substring(0,holdIndex)+key+value.substring(cursorIndex);
      }
      
      else if (cursorIndex < holdIndex){
        value = value.substring(0,cursorIndex)+key+value.substring(holdIndex);
      }
      else{
        value = value.substring(0,cursorIndex) + key + value.substring(cursorIndex);
      }
      cursorIndex = min(cursorIndex,holdIndex)+1;
      holdIndex = cursorIndex;
    }
    else if (key == ENTER || key == RETURN){
      runnable.run();
    }
    else if (key == BACKSPACE){
      if (cursorIndex > holdIndex){
        value = value.substring(0,holdIndex)+value.substring(cursorIndex);
      }
      
      else if (cursorIndex < holdIndex){
        value = value.substring(0,cursorIndex)+value.substring(holdIndex);
      }
      
      else if(cursorIndex > 0){
        value = value.substring(0,cursorIndex-1)+value.substring(cursorIndex);
        cursorIndex--;
      }
      cursorIndex = min(holdIndex,cursorIndex);
      holdIndex = cursorIndex;
      
    }
    else if (key == CODED) {
      if (keyCode == LEFT) {
        if(cursorIndex>0)
          cursorIndex--;
        if(!shift){
          cursorIndex = min(cursorIndex,holdIndex);
          holdIndex=cursorIndex;
        }
       
      }
      else if (keyCode == RIGHT){
        if(cursorIndex < value.length())
          cursorIndex++;
        if(!shift){
          cursorIndex = max(cursorIndex,holdIndex);
          holdIndex=cursorIndex;
        }
      }
      else if (keyCode == UP){
        try{
          if (value.indexOf('.')!=-1)
            value = nf(float(value)+step,1,value.length()-1-value.indexOf('.'));
          else
            value = str(int(value)+int(step));
            
          runnable.run();
        }
        catch(Exception e){
        }
      }
      else if (keyCode == DOWN){
        try{
          if (value.indexOf('.')!=-1)
            value = nf(float(value)-step,1,value.length()-1-value.indexOf('.'));
          else
            value = str(int(value)-int(step));
          
          runnable.run();
        }
        catch(Exception e){
        }
      }
      else if (keyCode == SHIFT){
        shift = true;
      }
    }
  }
  void onKeyRelease(){
    if (key == CODED){
      if(keyCode == SHIFT){
        shift = false;
      }
    }
  }
}
