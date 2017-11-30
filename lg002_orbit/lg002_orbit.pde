//////////////////////////////////////////////////////////////////////////////
// Common Settings
int numSec = 4;
boolean recording = true;

//////////////////////////////////////////////////////////////////////////////
// Sketch

// Planet radius; set in setup().
float kRadius;
// Planet : moon scale
int kMoonScale = 4;
// Moon distance : planet radius
int kMoonDist = kMoonScale/2;
// # of orbits performed by small moons around their planets per animation
// iteration. Note that the outside orbits of the outermost moons are slowed
// down in order to synchronize with the reference frame.
int kOrbitRate = 2;

void setup() {
  size(512, 512, P3D);
  smooth(8);
  pixelDensity(recording ? 1 : 2);
  result = new int[width*height][3];
  blendMode(EXCLUSION);
  fill(255);
  noStroke();

  kRadius = width/8;
}

// Starts with position + speed of 0, reaches given speed at given time.
float approach_rate(float cur_time, float speed, float by_time) {
  if (cur_time < 0) {
    return 0;
  }
  if (cur_time < by_time) {
    return (cur_time * cur_time) / (2 * by_time) * speed;
  }
  return ((2 *cur_time - by_time) * by_time) / (2 * by_time) * speed;
}

void planet(int iterations, int depth) {
  ellipse(0, 0, kRadius, kRadius);
  if (iterations > 0) {
    push();
    translate(kRadius*kMoonDist, 0);
    scale(1.0/kMoonScale);
    rotate(-2 * PI * approach_rate(1-(t - depth), kOrbitRate, 2));
    rotate(-HALF_PI);
    planet(iterations - 1, depth + 1);
    pop();
  }
}

// Zooms smoothly around the focus of the spiral formed by the moons.
void log_zoom() {
  float denom = kMoonScale*kMoonScale + 1;
  float base = kRadius*kMoonDist*(kMoonScale/denom);

  translate(base*kMoonScale, -base);
  scale(pow(kMoonScale, t));
  rotate(HALF_PI*t);
  translate(-base*kMoonScale, base);
}

void draw_() {
  background(255);

  push();
  translate(width/2, height/2);
  log_zoom();
  planet(10, 0);
  pop();
}

//////////////////////////////////////////////////////////////////////////////
// Boilerplate by @beesandbombs, adapted by @lgarron

// Constants
int kFramesPerSec = 50;
int kSamplesPerFrame = 4;
float kShutterAngle = 0.6;

// Global variables
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
      t = (mouseX*2.0/width) % 1; // TODO: Match to kFramesPerSec
    }
    push();
    draw_();
    pop();
    push();
    fill(128);
    rect(0, 0, width * t, 4);
    pop();
  }
  
  else {
    for (int i=0; i<width*height; i++)
      for (int a=0; a<3; a++)
        result[i][a] = 0;
  
    c = 0;
    for (int sa=0; sa<kSamplesPerFrame; sa++) {
      t = map(frameCount-1 + sa*kShutterAngle/kSamplesPerFrame, 0, numSec*kFramesPerSec, 0, 1);
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
        int(result[i][0]*1.0/kSamplesPerFrame) << 16 | 
        int(result[i][1]*1.0/kSamplesPerFrame) << 8 | 
        int(result[i][2]*1.0/kSamplesPerFrame);
    updatePixels();
  
    saveFrame("frames/###.png");
    if (frameCount == numSec*kFramesPerSec)
      exit();
  }
}
