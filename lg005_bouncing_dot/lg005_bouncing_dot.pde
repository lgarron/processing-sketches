//////////////////////////////////////////////////////////////////////////////
// Common Settings
float numSec = 4;
boolean recording = true;
int kSamplesPerFrame = 1;

//////////////////////////////////////////////////////////////////////////////
// Sketch

// Bouncy dot radius
float kR; // TODO: squish
float bounceHeight;
int kNumBounces = 8;

float kRectWidth;
float kRectHeight;
float kDotTravelHeight;

int kNumBeamSpokes = 8;
float kBeamSpeed;
float kBeamLength;
float kBeamWidth;

void setup_() {
  blendMode(EXCLUSION);
  fill(255);
  noStroke();

  kR = height / 8;
  bounceHeight = kR * 1.5;

  kRectWidth = width / 4;
  kRectHeight = kRectWidth / 8;
  kDotTravelHeight = height;

  kBeamSpeed = kR * 4;
  kBeamLength = kR*5/8;
  kBeamWidth = kR/4;
}

void beam(float p) {
  for (int i = 0; i < kNumBeamSpokes; i++) {
    float unconstrainted_end = (p) * kBeamSpeed;

    float end = constrain(unconstrainted_end, 0, kBeamLength);
    float start = constrain(unconstrainted_end - kBeamLength * 2, 0, kBeamLength);
    push();

    stroke(0, 128, 255);
    strokeWeight(kBeamWidth);
    rotate(2 * PI * i / kNumBeamSpokes);
    translate(kR/2, 0);
    line(start, 0, end, 0);
    pop();
  }
}

float bounce_t() {
  return abs(sin(t * PI * kNumBounces));
}

void dot() {
  push();
  ellipse(0, 0, kR, kR);
  beam((t * kNumBounces) % 1);
  pop();
}

// Includes "current" as well as "next" and "previous" dots.
void bouncy_dots() {
  push();
  translate(0, -bounce_t() * bounceHeight + t*kDotTravelHeight);
  dot();

  push();
  translate(0, -kDotTravelHeight);
  dot();
  pop();

  push();
  translate(0, kDotTravelHeight);
  dot();
  pop();

  pop();
}

void bars() {
  for (int i = 0; i < kNumBounces; i++) {

    push();
    translate((t * kNumBounces - i) * kRectWidth, 0);
    translate(0, i*1.0/kNumBounces * kDotTravelHeight + kR/2);
    rect(-kRectWidth/2, 0, kRectWidth, kRectHeight, kRectHeight/2);

    push();
    translate((kNumBounces) * kRectWidth, 0);
    rect(-kRectWidth/2, 0, kRectWidth, kRectHeight, kRectHeight/2);
    pop();

    push();
    translate(-(kNumBounces) * kRectWidth, 0);
    rect(-kRectWidth/2, 0, kRectWidth, kRectHeight, kRectHeight/2);
    pop();

    pop();
  }
}

void draw_() {
  background(255);

  push();
  translate(width/2, 0);
  bouncy_dots();
  bars();

  pop();
}

//////////////////////////////////////////////////////////////////////////////
// Boilerplate by @beesandbombs, adapted by @lgarron

// Constants
int kFramesPerSec = 50;
float kShutterAngle = 0.6;

// Global variables
int[][] result;
float t, c;

void setup() {
  size(512, 512, P3D);
  smooth(8);
  pixelDensity(recording ? 1 : 2);
  result = new int[width*height][3];

  setup_();
}

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
      t = (mouseX*2.0/width + 0.5) % 1; // TODO: Match to kFramesPerSec
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
