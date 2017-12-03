//////////////////////////////////////////////////////////////////////////////
// Common Settings
int numSec = 4;
boolean recording = true;

float spokeLen;

void setup() {
  size(512, 512, P3D);
  smooth(8);
  pixelDensity(recording ? 1 : 2);
  result = new int[width*height][3];
  blendMode(SUBTRACT);
  fill(255);
  noStroke();

  spokeLen = width/2;
}

//////////////////////////////////////////////////////////////////////////////
// Sketch

int kNumSpokes = 6;

void spoke(int iterations) {
  if (iterations == 0) {
    return;
  }

  strokeWeight(8);
  stroke(255);
  line(0, 0, spokeLen, 0);

  for (int dir = -1; dir <= 1; dir +=2) {
    for (int dist = 1; dist <= 4; dist++) {
      push();
      translate(dist * spokeLen/5, 0);
      scale(dist * 1.0 / 5);
      rotate(dir * PI / 3);
      spoke(iterations - 1);
      pop();
    }
  }
}

void spokes() {
  for (int i = 0; i < kNumSpokes; i++) {
    push();
    rotate(2 * PI * i /kNumSpokes);
    spoke(5);
    pop();
  }
}

void draw_() {
  background(255);

  push();
  translate(width/2, width/2);
  ellipse(0, 0, width/16, width/16);
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
