//////////////////////////////////////////////////////////////////////////////
// Common Settings

public void settings() {
  // Boilerplate-handled settings
  _numSec = 6;
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

// Bouncy dot radius
float unit_width;
float l; // line width

void _setup() {
  blendMode(EXCLUSION);
  fill(255);
  noStroke();

  unit_width = width/8;
  l = unit_width/8;
}

void l_rect(float x, float y, float w, float h) {
  rect(l * x, l * y, l * w, l * h);
}

void lin(float x1, float y1, float x2, float y2) {
  l_rect(x1, y1, x2 - x1, y2 - y1);
}

void rotate_half_around(float x, float y) {
  translate(x * l, y * l);
  rotate(PI);
  translate(-x * l, -y * l);
}

void section(int s, float p) {
  lin(4, 4, 5, 5);
  lin(8, 4, 9, 5);

  for (float i = 0; i < 2; i++) {
    push();
    if (i == 1) {
      rotate_half_around(8.5, 4.5);
    }
    switch (s) {
      case 0:
        lin( 4,      3+p,    5,      4);
        lin( 2,      3+p,    4,      4+p);
        lin( 2,      4+p,    3,      8);
        lin( 3,      7,      8,      8);
        lin( 8,      5,      9,      8);
        break;
      case 1:
        lin( 2+2*p,  4,      4,      5);
        lin( 2+2*p,  5,      3+2*p,  8);
        lin( 3+2*p,  7,      8,      8);
        lin( 8,      5,      9,      8);
        break;
      case 2:
        lin( 4,      5,      5,      8);
        lin( 5,      7,      8+2*p,  8);
        lin( 8+2*p,  5,      9+2*p,  8);
        lin( 9,      4,      9+p*2,  5);
        break;
      case 3:
        lin( 4,      5,      5,      8);
        lin( 5,      7,     10,      8);
        lin(10,      5-p,   11,      8);
        lin( 9,      4-p,   11,      5-p);
        lin( 8,      4-p,    9,      5);
        break;
      case 4:
        lin( 4,      5,      5,      8);
        lin( 5,      7,     10,      8);
        lin(10,      4,     11,      8);
        lin( 9,      3,     11,      4);
        lin( 8,      3,      9,      5);
        break;
    }
    pop();
  }
}

void toggle(float p) {
  push();
  section(floor(p * 4), ease(loop(p * 4)));
  pop();
}

void row(int row_num, float p) {
  for (float i = -1; i < 8; i++) {
    push();
    translate(unit_width * i, 0);

    float offset = (row_num % 2 == 0) ? i/64.0 : (6 - i)/64.0;
    toggle(there_and_back((p - offset) % 1.0, 8));
    pop();
  }
  rect(0, 0, width, height/8 + l);
}

void _draw() {
  background(255);

  for (int i = 0; i < 4; i++) {
    push();
    translate(0, unit_width * (2 * i + 0.5));
    row(i, loop(t + i * 3/8.0));
    pop();
  }
}
