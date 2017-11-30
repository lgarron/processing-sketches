//////////////////////////////////////////////////////////////////////////////
// Common Settings
float numSec = 4;
boolean recording = false;
int kSamplesPerFrame = 1;

public void settings() {
  size(512, 512, P3D);
  pixelDensity(recording ? 1 : 2);
  smooth(8);
}

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

void setup() {
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
