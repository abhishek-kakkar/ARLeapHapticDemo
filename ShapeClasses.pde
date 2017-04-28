class Cube {

  private PApplet app;
  
  public float px, py, pz;
  public float size;
  
  public Cube(PApplet parent)
  {
    app = parent;
  }

  public void draw()
  {
    app.pushMatrix();
    app.translate(px, py, pz);
    app.box(size);
    popMatrix();
  }
  
  public boolean liesWithin(float x, float y, float z)
  {
    if (( x >= px - (size / 2) && x <= px + (size / 2) ) &&
        ( y >= py - (size / 2) && y <= py + (size / 2) ) &&
        ( z >= pz - (size / 2) && z <= pz + (size / 2) )) {
      return true;
    } else {
      return false;
    }
  }
}