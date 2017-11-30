//////////////////////////////////////////////////////////////////////////////
// Common Settings
int numSec = 4;
boolean recording = false;

//////////////////////////////////////////////////////////////////////////////
// Sketch

// Arrow stem width
float l;

void setup() {
  size(512, 512, P3D);
  smooth(8);
  pixelDensity(recording ? 1 : 2);
  result = new int[width*height][3];
  blendMode(EXCLUSION);
  fill(255);
  noStroke();

  l = width/8;
}

void arrow() {
  push();
  translate(0, -l/2);
  triangle(-l, 0, l, 0, 0, -l);
  pop();
  rect(-l/2, -l/2, l, l);
}

void grid(float p) {
  for (float x = 0; x <= width + l*2; x = x + l*2) {
    for (float y = 0; y <= height + l*2; y = y + l*2) {
      push();
      translate(x, y);
      rotate(p*HALF_PI);
      arrow();
      pop();
    }
  }
}

void draw_() {
  background(0);

  float tt = (t * 4) % 1;
  int iter = floor(t * 4);
  int dir = (iter % 2 == 0) ? 1 : -1;

  if (dir == 1) {
    rect(0, 0, width, height);
  }

  push();
  translate(-l * floor(iter/2), -l * floor((iter + 1)/2));
  grid(ease(tt) - iter);
  pop();
}

//////////////////////////////////////////////////////////////////////////////
// Boilerplate by @beesandbombs, adapted by @lgarron

// Constants
int kFramesPerSec = 50;
int kSamplesPerFrame = 4;
float kShutterAngle = 0.6;

// Global variables
int[][] result;
float t, c;

float ease(float p) {
  float clipped = constrain(p, 0, 1);
  float clipped3 = clipped * clipped * clipped;
  return clipped3 * (10 - 15 * clipped + 6 * clipped * clipped);
}

void push() { pushMatrix(); pushStyle(); }
void pop()  { popStyle();   popMatrix(); }

void draw() {
  
  if(!recording){
    c = mouseY*1.0/height;
    if(mousePressed) {
        t = (t + (ease(c))/10) % 1;
    } else {
      t = (mouseX*2.0/width) % 1; // TODO: Match to kFramesPerSec
    }
    push();
    draw_();
    pop();
    push();
    fill(128);
    rect(0, 0, width * t, 4);
    pop();
  }
  
  else {
    for (int i=0; i<width*height; i++)
      for (int a=0; a<3; a++)
        result[i][a] = 0;
  
    c = 0;
    for (int sa=0; sa<kSamplesPerFrame; sa++) {
      t = map(frameCount-1 + sa*kShutterAngle/kSamplesPerFrame, 0, numSec*kFramesPerSec, 0, 1);
      draw_();
      loadPixels();
      for (int i=0; i<pixels.length; i++) {
        result[i][0] += pixels[i] >> 16 & 0xff;
        result[i][1] += pixels[i] >> 8 & 0xff;
        result[i][2] += pixels[i] & 0xff;
      }
    }

    loadPixels();
    for (int i=0; i<pixels.length; i++)
      pixels[i] = 0xff << 24 | 
        int(result[i][0]*1.0/kSamplesPerFrame) << 16 | 
        int(result[i][1]*1.0/kSamplesPerFrame) << 8 | 
        int(result[i][2]*1.0/kSamplesPerFrame);
    updatePixels();
  
    saveFrame("frames/###.png");
    if (frameCount == numSec*kFramesPerSec)
      exit();
  }
}
