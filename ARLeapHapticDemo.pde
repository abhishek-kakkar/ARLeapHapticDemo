import de.voidplus.leapmotion.*;
import Jama.*;
import jp.nyatla.nyar4psg.*;
import processing.serial.*;
import processing.video.*;

Capture cam;
LeapMotion leap;
MultiMarker nya;

Cube cube1;

void setup() {
  size(640,480,P3D);
  colorMode(RGB, 100);
  println(MultiMarker.VERSION);

  cam=new Capture(this,640,480,"/dev/video1");
  nya=new MultiMarker(this,width,height,"../libraries/nyar4psg/data/camera_para.dat",NyAR4PsgConfig.CONFIG_PSG);
  
  //nya.addARMarker("../libraries/nyar4psg/data/patt.hiro",80);
  nya.addNyIdMarker(4, 80);
  cam.start();
  
  leap = new LeapMotion(this);
  
  serialOpen("/dev/ttyUSB0");
  
  cube1 = new Cube(this);
  cube1.px = 0; cube1.py = -160; cube1.pz = 80;
  cube1.size = 60;
  
  //delay(3000);
  
  //for (int i = 0; i < 5; i++)
  //{
  //  sendToFingers(1);
  //  delay(1000);
  //}
  
  //while (hwser.available() > 0) {
  //  String inBuffer = hwser.readString();   
  //  if (inBuffer != null) {
  //    println(inBuffer);
  //  }
  //}
}

int state = 0;
float offsetX = 0.0, offsetY = 0.0, offsetZ = 0.0;

long frameCount = 0;

void draw()
{
  if (!cam.available()) return;
  
  cam.read();
  nya.detect(cam);
  
  frameCount++;
  
  background(255, 255, 255);
  stroke(0);
  noFill();
  nya.drawBackground(cam);
  
  if(!nya.isExist(0)) return;
  
  //for (Hand hand : leap.getHands()) {
  //  String info = "";
  //  for (Finger finger : hand.getFingers()) {
  //    PVector tip = finger.getPositionOfJointTip();
      
  //    info += String.format("\n %.2f, %.2f, %.2f", tip.x, tip.y, tip.z);
  //  }
  //  text(info, 30, 300);
  //}
  
  nya.beginTransform(0);  
  
  color fColors[] = { #00FF00, #FF0000, #0000FF, #FFFF00, #FF00FF };  
  String info = "";
  
  // bitmask of collisions
  // bit 0 to bit 4
  int collided = 0x00;
  
  for (Hand hand : leap.getHands()) {
    info = "";
    for (Finger finger : hand.getFingers()) {
      PVector tip = finger.getPositionOfJointTip();
      PVector txp = transformFingerCoordinates(tip);
      
      pushMatrix();
      fill(fColors[finger.getType()]);
      
      translate(txp.x, txp.y, txp.z);
      
      if (cube1.liesWithin(txp.x, txp.y, txp.z)) {
        collided |= (1 << finger.getType());
      }
      
      if ((collided & 0x3) == 0x3 && state == 0) {
        state = 1;
        
        offsetX = cube1.px - txp.x;
        offsetY = cube1.py - txp.y;
        offsetZ = cube1.pz - txp.z;
      }
      
      if (state == 1 && finger.getType() == 1) {
        cube1.px = txp.x + offsetX;
        cube1.py = txp.y + offsetY;
        cube1.pz = txp.z + offsetZ;
        
        if ((collided & 0x3) != 0x3) {
          state = 0;
        }
      }
      
      info += String.format("\n %.2f, %.2f, %.2f", txp.x, txp.y, txp.z);
      
      ellipse(0, 0, 8, 8);
      popMatrix();
    }
  }
  
  info += "\n " + new StringBuffer(Integer.toBinaryString(collided)).reverse().toString();
  info += "\n " + state;
  
  if (collided != 0) {
    fill(255, 0, 0);
  } else {
    fill(0, 0, 255);
  }
  
  if (collided != 0 && frameCount % 5 == 0)
    sendToFingers(collided);

  cube1.draw();
  
  noFill();
  stroke(100,0,0);
  rect(-40,-40,80,80);

  nya.endTransform();
  
  fill(#00FFFF);
  text(info, 30, 300);
}