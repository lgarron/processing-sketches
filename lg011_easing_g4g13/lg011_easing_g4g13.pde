//////////////////////////////////////////////////////////////////////////////
// Common Settings

public void settings() {
  // Boilerplate-handled settings
  _numSec = 1;
  _recording = false;
  _coverArtTime = 0;

  // Uncommon setting.
  _showProgressBar = false;

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


//////////////////////////////////////////////////////////////////////////////
// Sketch

// Unit width
float margin;
float radius;

void _setup() {
  blendMode(EXCLUSION);
  fill(255);
  noStroke();

  margin = width/8;
  radius = width/8;
}

void circle(float p) {
  ellipse(width/2, margin + (1-p) * (height - margin * 2), radius, radius);
}

void sheet(float p) {
  rect(0, 0, width, height * (1-p));
}

float easing(int i, int j, float p) {
  if (i == 0) {
    return 0;
  }
  if (j == 0) {
    return 1;
  }
  return easing(i-1, j, p) * (1-p) + easing(i, j-1, p) * p;
}

void _draw() {
  background(255);

  int i = 3;
  int j = 3;
  sheet(easing(i, j, clamp(t*3 - 0.5)));
  sheet(easing(i, j, clamp(t*3 - 2)));
}

