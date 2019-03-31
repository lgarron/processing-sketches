
//////////////////////////////////////////////////////////////////////////////
// Common Settings

public void settings() {
  // Boilerplate-handled settings
  _numSec = 4;
  _recording = false;
  _motionBlurSamples = 4;
  _coverArtTime = 0;

  // These 3 must be defined in the main file.
  size(512, 512, P3D);
  pixelDensity(_recording ? 1 : 2);
  smooth(8);
}

//////////////////////////////////////////////////////////////////////////////
// Sketch

// Arrow stem width
float l;

void _setup() {
  blendMode(EXCLUSION);
  fill(255);
  noStroke();

  l = width/8;
}

void arrow() {
      push();
      translate(-l, -l);
  beginShape();
  vertex(0, 0);
  vertex(l*2, 0);
  vertex(l, l);
  vertex(l*2, l*2);
  vertex(0, l*2);
  vertex(-l, l*2);
  endShape(CLOSE);
      pop();
      
  //push();
  //translate(0, -l/2);
  //triangle(-l, 0, l, 0, 0, -l);
  //pop();
  //rect(-l/2, -l/2, l, l);
}

void grid(float p) {
  for (float x = 0; x <= width + l*2; x = x + l*2) {
    for (float y = 0; y <= height + l*2; y = y + l*2) {
      push();
      translate(x, y);
      rotate(clamp(p*4)*HALF_PI);
      arrow();
      pop();
      push();
      translate(x + l, y + l);
      //rotate(p*HALF_PI);
      arrow();
      pop();
    }
  }
}

void _draw() {
  float tt = (t * 4) % 1;
  int iter = floor(t * 4);

  background(255);
  //background(255 * (iter % 2));
  //translate(-l * floor(iter/2), -l * floor((iter + 1)/2));
  grid(ease(t));
}
