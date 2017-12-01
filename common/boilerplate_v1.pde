//////////////////////////////////////////////////////////////////////////////
// Boilerplate by @beesandbombs, adapted by @lgarron

//////////////////////////////////////////////////////////////////////////////

// Settings
float _numSec = 4;
boolean _recording = false;
int _motionBlurSamples = 1;
float _coverArtTime = 0;

// Global variables
float t, c;

// File variables
int[][] _result;

// Constants
int _framesPerSec = 50;
float _shutterAngle = 0.6;

//////////////////////////////////////////////////////////////////////////////
// Convenience Functions

void push() {
  pushMatrix();
  pushStyle();
}

void pop() {
  popStyle();
  popMatrix();
}

float ease(float p) {
  float clipped = constrain(p, 0, 1);
  float clipped3 = clipped * clipped * clipped;
  return clipped3 * (10 - 15 * clipped + 6 * clipped * clipped);
}

//////////////////////////////////////////////////////////////////////////////
// Cover Art Freeze Frame Support

float _mousePrevX;
boolean _mouseHasMoved = false;

void _setupHasMouseMoved() {
  _mousePrevX = mouseX;
}

boolean _hasMouseMoved() {
  if (_mousePrevX != mouseX) {
    _mouseHasMoved = true;
  }
  _mousePrevX = mouseX;
  return _mouseHasMoved;
}

//////////////////////////////////////////////////////////////////////////////
// Setup

void setup() {
  _setupHasMouseMoved();
  _setup();

  _result = new int[width*height][3];
}

//////////////////////////////////////////////////////////////////////////////
// Draw

void _progressBar() {
  push();
  _draw();
  pop();
  push();
  fill(128);
  rect(0, 0, width * t, 4);
  pop();
}

void _motionBlur() {
  for (int i=0; i<width*height; i++) {
    for (int a=0; a<3; a++) {
      _result[i][a] = 0;
    }
  }

  c = 0;
  for (int sa=0; sa<_motionBlurSamples; sa++) {
    t = map(frameCount-1 + sa*_shutterAngle/_motionBlurSamples, 0, _numSec*_framesPerSec, 0, 1);
    _draw();
    loadPixels();
    for (int i=0; i<pixels.length; i++) {
      _result[i][0] += pixels[i] >> 16 & 0xff;
      _result[i][1] += pixels[i] >> 8 & 0xff;
      _result[i][2] += pixels[i] & 0xff;
    }
  }

  loadPixels();
  for (int i=0; i<pixels.length; i++)
    pixels[i] = 0xff << 24 | 
      int(_result[i][0]*1.0/_motionBlurSamples) << 16 | 
      int(_result[i][1]*1.0/_motionBlurSamples) << 8 | 
      int(_result[i][2]*1.0/_motionBlurSamples);
  updatePixels();
}

void draw() {
  if(!_recording){
    c = mouseY*1.0/height;
    if (!_hasMouseMoved()) {
      t = _coverArtTime;
    } else if(mousePressed) {
        t = (t + (ease(c))/10) % 1; // TODO: Match to _framesPerSec
    } else {
      t = (mouseX*2.0/width + 0.5) % 1;
    }
    _progressBar();
  }
  
  else {
    _motionBlur();

    saveFrame("frames/###.png");
    if (frameCount == _numSec*_framesPerSec)
      exit();
  }
}
