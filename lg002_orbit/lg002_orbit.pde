int samplesPerFrame = 4;
int numFrames = 200;
float shutterAngle = 0.6;

boolean recording = false;

float r;

void setup() {
  size(512, 512, P3D);
  smooth(8);
  pixelDensity(recording ? 1 : 2);
  result = new int[width*height][3];
  blendMode(EXCLUSION);
  fill(255);
  noStroke();

  r = width/8;
}

// k is the # of iterations over which the easing out happens.
float long_ease(int depth, float k) {
  return ease((t - depth + (k-1)) / k);
}

void planet(int iterations, int depth) {
  push();
  scale(pow(4, long_ease(depth, 1)));
  rotate(HALF_PI*long_ease(depth, 2));
  translate(-r*2*long_ease(depth, 2), 0);

  ellipse(0, 0, r, r);
  if (iterations > 0) {
    push();
    translate(r*2, 0);
    scale(0.25);
    rotate(-HALF_PI + t * PI * 4 * (1 - long_ease(depth, 1)));
    planet(iterations - 1, depth + 1);
    pop();
  }
  pop();
}

float loggy() {
  return pow(pow(2, 0.5), t*2);
}

void draw_() {
  background(255);
  translate(width/2, height/2);
  // scale(pow(4, t));
  planet(10, 0);
}

//////////////////////////////////////////////////////////////////////////////
// Boilerplate by @beesandbombs, adapted by @lgarron

int[][] result;
float t, c;

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
      t = mouseX*1.0/width;
    }
    draw_();
  }
  
  else {
    for (int i=0; i<width*height; i++)
      for (int a=0; a<3; a++)
        result[i][a] = 0;
  
    c = 0;
    for (int sa=0; sa<samplesPerFrame; sa++) {
      t = map(frameCount-1 + sa*shutterAngle/samplesPerFrame, 0, numFrames, 0, 1);
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
        int(result[i][0]*1.0/samplesPerFrame) << 16 | 
        int(result[i][1]*1.0/samplesPerFrame) << 8 | 
        int(result[i][2]*1.0/samplesPerFrame);
    updatePixels();
  
    saveFrame("frames/###.png");
    if (frameCount==numFrames)
      exit();
  }
}
