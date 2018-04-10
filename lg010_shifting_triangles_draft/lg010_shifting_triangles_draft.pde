//////////////////////////////////////////////////////////////////////////////
// Common Settings

public void settings() {
  // Boilerplate-handled settings
  _numSec = 1;
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


//////////////////////////////////////////////////////////////////////////////
// Sketch

// Unit width
float w;

void _setup() {
  blendMode(EXCLUSION);
  fill(255);
  noStroke();

  w = width/4;
}

void tri(float x1, float y1, float x2, float y2, float x3, float y3, float e1, float e2) {
  push();
  scale(w/2);
  translate(e1, e2);
  triangle(x1, y1, x2, y2, x3, y3);
  pop();
}

void unit1(float p) {
  tri(0, 0, 0, 1, 1, 1, p, p);
  tri(0, 0, 1, 0, 1, 1, -p, -p);
  tri(0, 0, 0, 1, 1, 1, p + 1, p + 1);
  tri(0, 0, 1, 0, 1, 1, -p + 1, -p + 1);
}

void unit2(float p) {
  tri(0, 0, 0, 1, 1, 0, p, -p + 1);
  tri(1, 1, 0, 1, 1, 0, -p, p + 1);
  tri(0, 0, 0, 1, 1, 0, p + 1, -p);
  tri(1, 1, 0, 1, 1, 0, -p + 1, p);
}

void flip() {
  translate(0, height);
  scale(1, -1);
}

void _draw() {
  background(255);

  for (float i = -w; i <= height; i += w) {
    for (float j = -w; j <= width; j += w) {
      push();
      flip();
      translate(i, j);
      float tt = t; //t + (i - w/2) / w / 8;
      if (tt < 0.5) {
        float e = ease(tt*2)/2;
        translate(w/2, w/2 * (e));
        unit1(e);
      } else {
        float e = (ease(tt*2 - 1) + 1)/2;
        translate(w/2, w/2 * (e));
        unit2(e);
      }
      pop();
    }
  }
}

