//////////////////////////////////////////////////////////////////////////////
// Common Settings

public void settings() {
  // Boilerplate-handled settings
  _numSec = 2;
  _recording = true;
  _coverArtTime = 0;

  // These 3 must be defined in the main file.
  size(512, 512, P3D);
  pixelDensity(_recording ? 1 : 2);
  smooth(8);
}

//////////////////////////////////////////////////////////////////////////////
// Convenience Functions

float loop(float p) {
  return p % 1.0;
}

float clamp(float p) {
  return constrain(p, 0, 1);
}

// /•••\...
float there_and_back(float p, float speed) {
  if (p < 1/2.0) {
    return clamp(p * speed);
  } else {
    return clamp(1 - ((p-0.5) * speed));
  }
}

//////////////////////////////////////////////////////////////////////////////
// Sketch

// Stroke width
float s1; // Small
float s2; // Big

void _setup() {
  blendMode(EXCLUSION);
  fill(255);
  noStroke();

  s1 = width/4;
  s2 = width/2;
}

void arc(float p, boolean has_cap) {
  push();
  translate(0, s2/2);
  blendMode(SUBTRACT);

  // Big Arc
  push();
  blendMode(EXCLUSION);
  rotate(-PI/2);
  arc(0, 0, s2, s2, 0, PI*p);
  arc(0, 0, s2-s1*2, s2-s1*2, 0, PI*p);
  pop();

  // End Cap
  push();
  rotate(PI*p);
  translate(0, -s2/2+s1/2);
  scale(1-p, 1); // Squish cap
  arc(0, 0, s1, s1, 0, PI*2);
  pop();

  pop();
}


void line(float p) {
  push();
  translate(0, s2-s1);
  rect(-p * s2, 0, p * s2, s1);
  pop();
}

void right_half(float p) {
  arc(constrain(p*2, 0, 1), true);
  line(constrain(p*2-1, 0, 1));
}

void both_halves(float p) {

  push();
  rotate(PI/2);
  scale(-1, 1);
  right_half(p);
  pop();

  right_half(p);
}

void _draw() {
  background(255);

  translate(width/2, height/3);
  scale(pow(0.5, t), pow(0.5, t));
  rotate(-PI/4);

  push();
  blendMode(SUBTRACT);
  rect(-s1, 0, s1, s1);
  both_halves(ease(t));
  pop();
}

