
Serial hwser;

void serialOpen(String ser)
{
  try {
    hwser = new Serial(this, ser, 115200);
  } catch (Exception e) {
    hwser = null;
  }
}

void sendToFingers(int fingerMask)
{
  if (hwser == null) return;
  
  byte send[] = new byte[2];
  
  send[0] = 's';
  send[1] = (byte)(fingerMask & 255);
  
  hwser.write('s');
  hwser.write(fingerMask & 255);
}