import de.voidplus.leapmotion.*;
import Jama.*;
import jp.nyatla.nyar4psg.*;
import processing.serial.*;
import processing.video.*;

Capture cam;
LeapMotion leap;
MultiMarker nya;

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
}

float cubeX = 0 , cubeY = -160, cubeZ = 40;
float cubeSize = 40;

boolean liesWithinCube(float x, float y, float z) {
  
  if (( x >= cubeX - (cubeSize / 2) && x <= cubeX + (cubeSize / 2) ) &&
      ( y >= cubeY - (cubeSize / 2) && y <= cubeY + (cubeSize / 2) ) &&
      ( z >= cubeZ - (cubeSize / 2) && z <= cubeZ + (cubeSize / 2) )) {
    return true;
  } else {
    return false;
  }
}

int state = 0;
float offsetX = 0.0, offsetY = 0.0, offsetZ = 0.0;

void draw()
{
  if (!cam.available()) return;
  
  cam.read();
  nya.detect(cam);
  
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
      PVector txp = new PVector();
      
      pushMatrix();
      fill(fColors[finger.getType()]);
      
      txp.x = 0.76*(170-tip.x);
      txp.y = 0.68*(-530+7*tip.z);
      txp.z = 1.03*(408-tip.y);
      
      translate(txp.x, txp.y, txp.z);
      
      if (liesWithinCube(txp.x, txp.y, txp.z)) {
        collided |= (1 << finger.getType());
      }
      
      if ((collided & 0x3) == 0x3 && state == 0) {
        state = 1;
        
        offsetX = cubeX - txp.x;
        offsetY = cubeY - txp.y;
        offsetZ = cubeZ - txp.z;
      }
      
      if (state == 1 && finger.getType() == 1) {
        cubeX = txp.x + offsetX;
        cubeY = txp.y + offsetY;
        cubeZ = txp.z + offsetZ;
        
        if ((collided & 0x3) != 0x3) {
          state = 0;
        }
      }
      
      info += String.format("\n %.2f, %.2f, %.2f", txp.x, txp.y, txp.z);
      
      ellipse(0, 0, 12, 12);
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
  
  pushMatrix();
  translate(cubeX, cubeY, cubeZ);
  box(cubeSize);
  popMatrix();
  
  noFill();
  stroke(100,0,0);
  rect(-40,-40,80,80);

  nya.endTransform();
  
  fill(#00FFFF);
  text(info, 30, 300);
}