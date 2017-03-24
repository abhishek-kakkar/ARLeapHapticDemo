// Values will change from setup to setup.

PVector transformFingerCoordinates(PVector tip)
{
  PVector ret = new PVector();
  
  ret.x = 0.65*(260-tip.x);
  ret.y = 0.68*(-650+7*tip.z);
  ret.z = 1.03*(390-tip.y);
  
  return ret;
}