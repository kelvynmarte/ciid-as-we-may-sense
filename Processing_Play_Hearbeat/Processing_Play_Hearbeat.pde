import ddf.minim.AudioPlayer;
import ddf.minim.Minim;
import processing.serial.*;
import processing.core.PApplet;
import processing.sound.*;
import java.nio.Buffer;
import java.util.*;
import oscP5.*;
import netP5.*;


public class LimitedQueue<E> extends LinkedList<E> {

    private int limit;

    public LimitedQueue(int limit) {
        this.limit = limit;
    }

    @Override
    public boolean add(E o) {
        boolean added = super.add(o);
        while (added && size() > limit) {
           super.remove();
        }
        return added;
    }
}

SoundFile soundfile;
Serial serialPort;
int LF = 10;
int pulse1timestamp = millis();
LinkedList<Integer> lastPulses = new LimitedQueue<Integer>(6);

void setup() {
    // size(640,360);
    fullScreen();
    background(255);
    String portName = Serial.list()[3];
    print(Serial.list());
    serialPort = new Serial(this, portName, 9600);
        
    //Load a soundfile
    soundfile = new SoundFile(this, "heartbeat.aif");
}      


void draw() {
  background(0);
  while ( serialPort.available() > 0) {  // If data is available,
      try{
          String stringValue = serialPort.readStringUntil(LF);
          if (stringValue != null) {
  
              Float value1 = Float.parseFloat(stringValue.trim());
  
              if(value1 > 525 && millis() - 400 > pulse1timestamp ){
                  println("pulse");
                  println(millis() - pulse1timestamp);
                  pulse1timestamp = millis();
                  lastPulses.add(pulse1timestamp);
                  soundfile.stop();
                  soundfile.play();
              }
          }
      }catch(Exception ex){
          println("error");
          System.out.println(ex);
      }
  }
  
  Iterator<Integer> latPulseIterator = lastPulses.iterator();
  while(latPulseIterator.hasNext()){
    int cPulseTime = latPulseIterator.next();
    
    
    float x = map(millis() - cPulseTime, 0 , 2000, 0, width);
    
    float opacity = map(Math.round((millis() - cPulseTime)/4), 0, width, 255, 100);
    float w = map(Math.round((millis() - cPulseTime)/4), 0, width, 20, width/20);

    fill(opacity);
    rect(x-w/2, 0, w, height);
  }
  

}