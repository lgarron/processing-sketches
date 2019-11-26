
//////////////////////////////////////////////////////////////////////////////
// Common Settings

public void settings() {
  // Boilerplate-handled settings
  _numSec = 3;
  _recording = true;
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
float ls;

void _setup() {
  blendMode(EXCLUSION);
  fill(255);
  noStroke();

  l = width/8;
  ls = l * sqrt(0.5);
}

void arrow(float fwd) {
  push();
    translate(-l/2 - fwd * l, -l/2);
    beginShape();
    vertex(0, 0);
    vertex(l, 0);
    vertex(l/2, l/2);
    vertex(l, l);
    vertex(0, l);
    vertex(-l/2, l/2);
    endShape(CLOSE);
  pop();
}

void grid(float a, float b, float fwd) {
  for (float x = - l*2; x <= width + l*2; x = x + l*2) {
    for (float y = - l*2; y <= height + l*2; y = y + l*2) {
      push();
        translate(x, y);
        rotate(a*HALF_PI);
        arrow(fwd);
      pop();
      push();
        translate(x + l, y + l);
        rotate(b*HALF_PI);
        //color c = color(255, 204, 0);  // Define color 'c'
        //fill(c);  
        arrow(fwd);
      pop();
    }
  }
}

void rec(float sx, float sy, float rx, float ry, float r, float p) {
  background(0);
  for (float x = - l*2; x <= width + l*2; x = x + l*2) {
    for (float y = - l*2; y <= height + l*2; y = y + l*2) {
      
      push();
        translate(x, y);
        
        push();
          translate(sx * l/2, sy * l/2);
          square(0, 0, l);
        pop();
        
        push();
          translate(rx, ry);
          rotate((r - 0.5) * HALF_PI);
          translate(0, p*ls);
          beginShape();
          vertex(-ls, 0);
          vertex(ls, 0);
          vertex(ls, ls);
          vertex(-ls, ls);
          endShape(CLOSE);
        pop();
      
      pop();
    }
  }
}


void _draw() {
  float tt = ease((t * 4) % 1);
  int iter = floor(t * 8);

  background(255);
  push();
  translate(width/2, width/2);
  //rotate(t * HALF_PI * 2);
  translate(-width/2, -width/2);
  
  grid(3, 1, ease(t)*2 + 0.5); 
  
  //if (t < 1./4) { grid(3, 1, tt/2 + 0.5); }
  //else if (t < 2./4) { grid(3, 1, tt/2 + 1.0); }
  //else if (t < 3./4) { grid(3, 1, tt/2 + 1.5); }
  //else if (t < 4./4) { grid(3, 1, tt/2 + 2); }
  //else if (t < 2./4) { grid(3, 1, tt/2 + 2.5); }
  //else if (t < 3./4) { grid(3, 1, tt/2 + 3); }
  //else if (t < 4./4) { grid(3, 1, tt/2 + 3.5); }
  
  //if (t < 1.0/8) { grid(tt, 0, 0); }
  //else if (t < 2./8) { rec(1, -1, l * 3/2, l/2, 0, tt); }
  //else if (t < 3./8) { grid(3, 2-tt, 0); }
  
  //else if (t < 9./16) {  grid(3, 1, ease((t - 6./8)*16./3)); }
  //else if (t < 10./16) { grid(3, 1,0.5+1.5*ease((t * 16) % 1)); }
  ////else if (t < 5./8) { grid(3, 1, ease((t - 3./8) *4)* 2); }
  //else if (t < 6./8) { grid(3+tt, 1, 0); }
  //else if (t < 7./8) { rec(-1, 1, l*3/2, l/2, 2, 1-tt); }
  //else if (t < 8./8) { grid(2, 3-tt, 0);}
  pop();
}
