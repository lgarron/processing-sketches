//////////////////////////////////////////////////////////////////////////////
// Common Settings
float numSec = 1;
boolean recording = true;
int kSamplesPerFrame = 1;

float kDiam;
float kStretch;
float base_circle_scale;
int total_depth;
float line_width;

void setup_() {
  blendMode(SUBTRACT);
  fill(0);
  noStroke();

  kDiam = width/5;
  kStretch = 1;
  base_circle_scale = width/16;
  total_depth = 20;
  line_width = width/128;
}

//////////////////////////////////////////////////////////////////////////////
// Sketch


float scale_x(float p) {
  return 1 - p * 0.5;
}

float scale_y(float p) {
  return 1 - p * 0.25;
}

void scale_tree(int dir, float p) {
  translate(dir * kStretch * kDiam * p, kDiam * p);
  scale(scale_x(p), scale_y(p));
}

boolean printed = false;

void tree(int remaining, int depth) {
  if (remaining == 0) {
    return;
  }

  push();
  fill(255);
  // ellipse(0, 0, kDiam, kDiam / circle_aspect_ratio); // TODO: Handle circle scaling
  strokeWeight(base_circle_scale);
  point(0, 0);
  pop();

  for (int dir = -1; dir <=1; dir += 2) {
    strokeWeight(1);
    stroke(255);
    push();
    strokeWeight(line_width);
    line(0, 0, dir * kStretch * kDiam, kDiam);
    pop();
    push();
    scale_tree(dir, 1);
    tree(remaining - 1, depth + 1);
    pop();
  }
}

void main_tree() {
  float time = ease(t);

  strokeWeight(1 * line_width);
  stroke(255);

  push();
  strokeWeight(0.72 * line_width);
  strokeCap(ROUND);
  strokeJoin(ROUND);
  noFill();
  beginShape();
  vertex(-kStretch * kDiam, kDiam);
  vertex(0, 0);
  vertex(kStretch * kDiam, kDiam);
  endShape();
  pop();

  // alpha
  push();
  scale_tree(-1, 1);
  line(0, 0, -kStretch * kDiam * (1-time), kDiam * (1-time));
  pop();
  push();
  scale_tree(-1, 1);
  scale_tree(-1, 1 - time);
  tree(total_depth, 0);
  pop();

  // beta
  push();
  strokeWeight(line_width * 3/4.);
  line(
    kStretch * kDiam * (2 * time - 1), kDiam,
    (kStretch * kDiam - kStretch * 0.5 * kDiam) * (2 * time - 1), kDiam + kDiam * 0.75 
  ); // TODO: scale weight to compensate.
  pop();
  fill(255);
  float uhhhh = 0.3;
  // ellipse(kStretch * kDiam * (time-1), kDiam * (1-time), kDiam * uhhhh, kDiam * uhhhh);
  // ellipse(kStretch * kDiam * time, kDiam * time, kDiam * uhhhh, kDiam * uhhhh);
  push();
  strokeWeight(base_circle_scale*0.72);
  point(kStretch * kDiam * (time-1), kDiam * (1-time));
  point(kStretch * kDiam * time, kDiam * time);
  pop();

  push();
  translate(kDiam * time, 0);
  scale_tree(-1, 1);
  scale_tree(1, 1);
  tree(total_depth, 0);
  pop();

  // gamma
  push();
  scale_tree(1, 1);
  push();
  strokeWeight(line_width);
  line(0, 0, kStretch * kDiam * time, kDiam * time);
  pop();
  pop();
  push();
  scale_tree(1, 1);
  scale_tree(1, time);
  tree(total_depth, 0);
  pop();
}

void draw_() {
  background(255);

  push();
  translate(width/2, height/8);
  main_tree();
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
