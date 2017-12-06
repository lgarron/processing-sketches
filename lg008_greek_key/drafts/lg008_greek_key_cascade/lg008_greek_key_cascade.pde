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

void l_rect(float a, float b, float c, float d) {
  rect(l * a, l * b, l * c, l * d);
}

void rotate_section() {
  translate(4.5*l, 4.5*l);
  rotate(PI);
  translate(-4.5*l, -4.5*l);
}

void section_1_mirrored(float p) {
  l_rect(1, 1 + p, 6, 1);
  l_rect(6, 2 + p, 1, 4 - 2*p);
  l_rect(5, 5 - p, 1, 1);
}

void section_1(float p) {
  l_rect(0, 1 + p, 1, 3 - p);
  l_rect(8, 4, 1, 4 - p);
  l_rect(4, 3+p, 1, 3 - 2*p);

  section_1_mirrored(p);

  push();
  rotate_section();
  section_1_mirrored(p);
  pop();
}

void section_2_mirrored(float p) {
  l_rect(1, 2, 6 - 2 * p, 1);
  l_rect(6 - 2*p, 3, 1, 1);
}

void section_2(float p) {
  l_rect(0, 2, 1, 5);
  l_rect(2 + 2*p, 4, 5 - 4 * p, 1);

  section_2_mirrored(p);

  push();
  rotate_section();
  section_2_mirrored(p);
  pop();
}

void flip() {
  translate(0, 4.5*l);
  scale(1, -1);
  translate(0, -4.5*l);
  translate(unit_width / 2, 0);
}

void section(int s, float p) {
  if (s == 1) {
    section_1(p);
  } else {
    section_2(p);
  }
}

void toggle(float p) {
  int i = floor(p * 4);
  float[] pp = {p * 4, p * 4 - 1, 3 - p*4, 4 - p*4, 0};

  int s = (i == 1 || i == 2) ? 2 : 1;
  push();
  if (i > 1) {
    flip();
  }
  section(s, ease(pp[i]));
  pop();
}

void row(float p) {
  for (float i = -1; i < 8; i++) {
    push();
    translate(unit_width * i, 0);

    toggle(there_and_back((p - i/128.0 % 1), 5));
    pop();
  }
  rect(0, 0, width, height/8 + l);
}

void _draw() {
  background(255);

  for (float i = 0; i < 4; i++) {
    push();
    translate(0, unit_width * (2 * i + 0.5));
    row((t + i * 3/8.0) % 1.0);
    pop();
  }
}
