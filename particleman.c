// attempts to create a simple particle system
// TODO: alpha channel 'a' is currently ignored/unused
// TODO: size is currently ignored
// TODO: many errors exist

// "gcc -lglut particleman.c -o particleman" should compile me

// TODO: MORE AMBITIOUS FAILED GOAL:
// attempt to replicate Second Life's particle system function
// http://wiki.secondlife.com/wiki/LlParticleSystem 

#include <GL/glut.h>
#include <stdlib.h>

// max number of particles
#define MAXPARTICLES 65535

// set to 1 for 3-D particles, not just points (very slow on my machine)
#define SLOW 0

// a particle has 3D position, velocity, RGBA color, birth time, and size
// size=0 -> don't render this particle
// TODO: should 'life' be a property of each particle?
// TODO: add concept of acceleration? (d2x, d2y, d2z natch)
struct particle {float x,y,z,dx,dy,dz,r,g,b,a,birth,size;};
typedef struct particle PARTICLE;

// vector (useful for color, position, velocity)
struct vector {float x,y,z;};
typedef struct vector VECTOR;

// array of particles
PARTICLE particles[MAXPARTICLES];

// the interval for each redraw
float dt = .1;

// current "high water" particle (loops after hitting max)
int highwater = 0;

// defining the particle system
float num = 1.; // particles generated per time interval
float life = 800.; // life of each particle, in time units
float size_start = 0.001; // starting size of each particle
float size_end = 0.01; // ending size of each particle
VECTOR color_start = {1.,1.,0.}; // starting color of each particle
VECTOR color_end = {1.,0.,0.}; // ending color of each particle
VECTOR dir = {0.,.02,0.}; // direction in which particles are emitted
VECTOR turb_dir = {0.01,0.,0.}; // randomness of direction
VECTOR emitter = {0.,-1.,0}; // location of particle emitter
VECTOR gravity = {0.,-.0001,0.}; // the force of gravity (or whatever)

// the start time
float t = 0.0;

// Spits out vector info w/ tag
void debugVector (VECTOR vec, char *tag) {
  printf("%s: <%f,%f,%f>\n",tag,vec.x,vec.y,vec.z);
}

// Spits out a bunch of information on a particle w/ tag string
void debugParticle (PARTICLE part, char *tag) {
  printf("%s: POS=<%f,%f,%f>, DIR=<%f,%f,%f>\n",tag,part.x,part.y,part.z,part.dx,part.dy,part.dz);
}

// update the particles
void updateParticles (void) {
  int i;

  // random vector
  VECTOR rand = {1.*random()/RAND_MAX-0.5,1.*random()/RAND_MAX-0.5,1.*random()/RAND_MAX-0.5};

  // handle existing particles
  for (i=0; i<MAXPARTICLES; i++) {
    // convenience variable
    float age = t-particles[i].birth;

    // if particle has exceeded lifetime, kill it (set size to 0)
    // ignore particles that already dead
    // TODO: should -1 be the "dead value" instead?
    if (age>life || particles[i].size==0) {particles[i].size=0; continue;}

    // tweak particle velocity
    particles[i].dx += gravity.x*dt;
    particles[i].dy += gravity.y*dt;
    particles[i].dz += gravity.z*dt;

    // tweak particle position
    particles[i].x += particles[i].dx*dt;
    particles[i].y += particles[i].dy*dt;
    particles[i].z += particles[i].dz*dt;

    // tweak particle size
    particles[i].size = size_start + (age/life)*(size_end-size_start);

    // tweak particle color
    particles[i].r = color_start.x + (age/life)*(color_end.x-color_start.x);
    particles[i].g = color_start.y + (age/life)*(color_end.y-color_start.y);
    particles[i].b = color_start.z + (age/life)*(color_end.z-color_start.z);

    // silliness: if particle hits top/bottom/sides, bounce?
    // bounce < -1 = flubber
    float bounce = -.20;
    if (particles[i].y<-1.) {particles[i].dy *= bounce;}
    if (particles[i].y>1.) {particles[i].dy *= bounce;}
    // could use abs() below, but not working? (#include math.h? && -lm?)
    if (particles[i].x>1.) {particles[i].dx *= bounce;}
    if (particles[i].x<-1.) {particles[i].dx *= bounce;}
  }

  // generate new particles (starting at highwater)
  // TODO: this is wrong -- it generate num particles each time, not num*dt
  for (i=0; i<num; i++) {
    if (++highwater > MAXPARTICLES) {highwater=0;}

    // particles start at emitter location w/ direction dir
    // size/color determined by size_start and color_start
    // TODO: better way of doing this?
    // "PARTICLE part = particles[highwater];" does not work (creates a copy)

    particles[highwater].x = emitter.x;
    particles[highwater].y = emitter.y;
    particles[highwater].z = emitter.z;
    particles[highwater].dx = dir.x+rand.x*turb_dir.x;
    particles[highwater].dy = dir.y+rand.y*turb_dir.y;
    particles[highwater].dz = dir.z+rand.z*turb_dir.z;
    particles[highwater].r = color_start.x;
    particles[highwater].g = color_start.y;
    particles[highwater].b = color_start.z;
    particles[highwater].a = 0.0; // TODO: actually use alpha value
    particles[highwater].birth = t;
    particles[highwater].size = size_start; // TODO: allow 3-D size values?

  }

  // increment the time
  t += dt;
}

void display (void) {
  int i;

  // update the particles
  updateParticles();

  // clear the buffer
  glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

  // forces all translations to be local?
  glPushMatrix();

  // render the particles
  for (i=0; i<MAXPARTICLES; i++) {
    PARTICLE part = particles[i]; // convenience
   
    // skip "dead" or uncreated particles
    if (part.size == 0) {continue;}

    // render particle (reset coordinate system to 0,0,0 each time)

    if (SLOW) {
      // method 1 for rendering particles (slow)
      glPushMatrix();
      glTranslatef(part.x,part.y,part.z);
      glColor3f(part.r,part.g,part.b);
      glutSolidSphere(part.size,10,10);
      glPopMatrix();
    } else {
      glBegin(GL_POINTS);
      glColor3f(part.r,part.g,part.b);
      glVertex2f(part.x,part.y);
      // failed experiment w/ GL_POLYGON below (too slow)
      // glVertex2f(part.x+part.size,part.y);
      // glVertex2f(part.x+part.size,part.y+part.size);
      // glVertex2f(part.x,part.y+part.size);
      glEnd();
    }

  }

  glPopMatrix();
  glutSwapBuffers();
}

int main(int argc, char **argv)
{

  glutInit(&argc, argv);

 // use double buffering + depth buffering
 glutInitDisplayMode(GLUT_DEPTH | GLUT_DOUBLE | GLUT_RGBA);

 // optional: window size
 glutInitWindowSize(800,600);

 // create the window
 glutCreateWindow("Particle Man");

 // glutDisplayFunc(): what to do when display is damaged
 glutDisplayFunc(display);

 // glutIdleFunc(): what to do when application is idle
 // often same as glutDisplayFunc()
 glutIdleFunc(display);

 glutMainLoop();
}

