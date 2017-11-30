//////////////////////////////////////////////////////////////////////////////
// Common Settings
int numSec = 5;
boolean recording = true;

//////////////////////////////////////////////////////////////////////////////
// Sketch

// Angle between spokes
float kGoldenAngle = PI * (3 - pow(5, 0.5));
// Offset to put the brightest spoke near the top.
float kOffset = PI;

// Spokes
int kNumSpokes = 64;
float kSpokeWidth = 32;
float kSpokeLen = 512;


void setup() {
  size(512, 512, P3D);
  smooth(8);
  pixelDensity(recording ? 1 : 2);
  result = new int[width*height][3];
  blendMode(SCREEN);
  fill(255);
  noStroke();
}

// 0 -> 1 -> 0
float brighten(float p) {
  float linear;
  if (p < 0.5) {
    linear = p*2;
  } else {
    linear = 2*(1-p);
  }
  return pow(linear, 3);
}

void spokes() {
  for (int i = 0; i < kNumSpokes; i = i+1) {
    push();
    fill(255 * brighten((i + t) / kNumSpokes));
    rotate(kOffset + kGoldenAngle * i);
    rect(0, -kSpokeWidth/2, kSpokeLen, kSpokeWidth);
    pop();
  }
}

void draw_() {
  background(0);

  push();
  translate(width/2, height/2);
  rotate(kGoldenAngle * t);
  spokes();
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
