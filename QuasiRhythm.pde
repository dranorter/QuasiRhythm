// QuasyRhythm by Daniel Demski
// Adapted from example code which came with the Beads library. 
import beads.*;
import java.util.Arrays; 

AudioContext ac;
// "arc" tracks our position on the straight line. "traj" points along the straight line. The melody uses nearby straight lines.
PVector arc = new PVector(random(0,1),random(0,1),random(0,1));
PVector drbeat_arc = arc.copy();
PVector melody_arc = new PVector(arc.x+random(0,0.5/sqrt(3)),arc.y+random(0,0.5/sqrt(3)),arc.z+random(0,0.5/sqrt(3)));
//PVector melody2_arc = new PVector(arc.x+random(0,1.0/sqrt(3)),arc.y+random(0,1.0/sqrt(3)),arc.z+random(0,1.0/sqrt(3)));
PVector melody2_arc = new PVector(arc.x+0.5,arc.y+0.5,arc.z+0.5);
PVector traj = new PVector(1.0/floor(random(1,2.3)),random(0.16,0.9),random(0.16,0.9));
//PVector traj = new PVector(1.61803398874989484820458683,1.0,0.61803398874989484820458683);

PVector drbeat_x = new PVector(1,0,0);
PVector drbeat_y = new PVector(0,1,0);
PVector drbeat_z = new PVector(0,0,1);

//PVector drbeat_traj = traj.add(new PVector(
// Random a,b,c
int temp = floor(random(3,9));//3,9
double b = ((double)temp)/(temp+ceil(random(0,2))*Math.pow(-1,floor(random(0,2))));
int temp2 = floor(random(3,9));
double c = ((double)temp2)/(temp2+ceil(random(0,2))*Math.pow(-1,floor(random(0,2))));

boolean tight_melody = true;

// New system: We choose thee ratios for a, b and c, then choose a trajectory which matches.
// New system commented out for version I'm sending to Santiago Beis. I like the sound of the old system better.
/*int temp3 = floor(random(3,9));//3,9
double a = ((double)temp3)/(temp3+ceil(random(0,2))*Math.pow(-1,floor(random(0,2))));
float traj_x = 1.0;
float traj_y = random(0,1);
PVector traj = new PVector(traj_x, traj_y, (float)(Math.log(Math.pow(a,-traj_x)*Math.pow(b,-traj_y))/Math.log(c)));*/

// Going to try and create a more Bead-centric version

//Glide arc_x = new Glide();

// Various lines below can be uncommented to use different rhythms I enjoyed. Sorry it's not organized.

//PVector traj = new PVector(1.61803398874989484820458683,1.0,0.61803398874989484820458683);
//PVector traj = new PVector(0.87331694,0.5367354,0.13195878);
//PVector traj = new PVector(2,3,1);

// Choose three intervals a, b, c such that traj.x*a+traj.y*b+traj.z*c = 0
// Equivalently, 3 frequency ratios a, b, c such that a = b^(-y/x)*c^(-z/x)
// And we want all 3 intervals to be close to nice rational intervals

// Solving by hand for traj = (0.87331694,0.5367354,0.13195878)

// Let's start with b = perfect fifth
//float b = 3.0/2;
// Just choosing c to be some otonal interval
//double c = 9.0/7;

//float a = 0.28043742307;//b^(-0.61459405562)*c^(-4.06744742563)
// That's a decent fit for 7/2. We can get it almost exact by
// tempering b just 2%.

//double b = 0.98*3.0/2;
//double a = 1.0/(Math.pow(b,traj.y/traj.x)*Math.pow(c,traj.z/traj.x));//0.5002948;//0.45002876386;

// Hand-calculating for (0.91652966,0.49367833,0.28992528)
//PVector traj = new PVector(2*0.91652966,2*0.49367833,2*0.28992528);
//PVector traj = new PVector(1.0,0.53863868409,0.3163294028);

//double b = 5.0/3;

//double c = 7.0/3;
// double a = 7/12*0.99582955//b^(-0.53863868409)*c^(-0.3163294028)
// We can temper 5/3 by 0.997287 and get a balanced compromise between the 5/3 and 7/12.
//double b = 0.997287*5.0/3;

// I had this formula wrong for a long time, but mostly for algebraic reasons.
// In comments above I have the wrong formula though. It's a^traj.x * b^traj.y * c^traj.z = 0
//double a = 1.0/(Math.pow(b,traj.y/traj.x)*Math.pow(c,traj.z/traj.x));
double a = Math.pow(b,-traj.y/traj.x)*Math.pow(c,-traj.z/traj.x);



// Start at 440. Start the nearby line's freq2 at a different spot. 
float freq = 440;
float freq2 = 440*(float)c;
float skip_prob = 1;// initially just drums
float extra_exponent = 1;

int intervalscale = round(random(1000,4000));

int notelength = 1000;

void setup() {
  println("Drift:");
  println(Math.pow(a,traj.x)*Math.pow(b,traj.y)*Math.pow(c,traj.z));
  size(300,300);
  ac = new AudioContext();
  
  if (tight_melody) {
    melody_arc = melody_arc.sub(arc.mult(melody_arc.sub(arc).dot(arc)).div(arc.mag()));
    melody2_arc = melody2_arc.sub(arc.mult(melody2_arc.sub(arc).dot(arc)).div(arc.mag()));
  }
  
  // Trying to find a good transform for drbeat subdivision
  // Just splitting up the largest interval for now
  //if (traj.x >= traj.y && traj.x >= traj.z) {
  //  drbeat_x = new PVector(1, -1, -1);
  //} else if (traj.y >= traj.x && traj.y >= traj.z) {
    
  //} else {
    
  //}

  Noise noise = new Noise(ac);
  
  WavePlayer freqModulator = new WavePlayer(ac, 35, Buffer.TRIANGLE);
  Function function = new Function(freqModulator) {
    public float calculate() {
      return x[0] * 10.0 + 80.0;
    }
  };
  WavePlayer bass = new WavePlayer(ac, function, Buffer.SINE);
  final Gain env = new Gain(ac, 1, new Envelope(ac, 0));
  env.addInput(bass);
  final Panner drum_line = new Panner(ac, -1);
  drum_line.addInput(env);
  ac.out.addInput(drum_line);
  
  
  //intervalscale = round(intervalscale / max(new float[]{traj.x,traj.y,traj.z}));
  float temp = (float)(intervalscale/(traj.x + traj.y + traj.z));
  intervalscale = round(temp);
  // Changed this line to remove some unfortunate clicking
  //notelength = round(intervalscale*1.25);
  notelength = round(intervalscale*min(new float[]{traj.x,traj.y,traj.z}))-2;
  
  println("Intervals (milliseconds):");
  println(intervalscale*traj.x);
  println(intervalscale*traj.y);
  println(intervalscale*traj.z);
  
  /*if ((a >= 1 && b >= 1 && c >= 1) || (a <= 1 && b <= 1 && c <= 1) || traj.z <= 0) {
    a = 1.0/a;
    traj = new PVector(traj_x, traj_y, (float)(Math.log(Math.pow(a,-traj_x)*Math.pow(b,-traj_y))/Math.log(c)));
  }
  if (traj.z <= 0) {
    b = 1.0/b;
    traj = new PVector(traj_x, traj_y, (float)(Math.log(Math.pow(a,-traj_x)*Math.pow(b,-traj_y))/Math.log(c)));
  }*/

  final Gain g = new Gain(ac, 1, new Envelope(ac, 0.0));
  final Gain m = new Gain(ac, 1, new Envelope(ac, 0.0));
  final Gain m2 = new Gain(ac, 1, new Envelope(ac, 0.0));
  final Gain drb = new Gain(ac, 1, new Envelope(ac, 0.0));
  
  final Bead melody_nextInterval = new Bead() {
    public void messageReceived(Bead message) {
      float melody_distx = (ceil(melody_arc.x) - melody_arc.x)/traj.x;
      if (melody_distx == 0) melody_distx = 1.0/traj.x;
      float melody_disty = (ceil(melody_arc.y) - melody_arc.y)/traj.y;
      if (melody_disty == 0) melody_disty = 1.0/traj.y;
      float melody_distz = (ceil(melody_arc.z) - melody_arc.z)/traj.z;
      if (melody_distz == 0) melody_distz = 1.0/traj.z;
      
      float melody_intervalLength = 1.0;
      //int pitch = Pitch.forceToScale((int)random(12), Pitch.minor);
      //float freq = Pitch.mtof(pitch + (int)random(5) * 12 + 32);
      float skip_probability = skip_prob;
          
                // Step arc up to the next transition,
      // and add interval which corresponds to
      // projected unit of that dimension
      if (melody_distx <= melody_disty && melody_distx <= melody_distz) {
        melody_arc.add(traj.copy().mult(melody_distx));
        melody_intervalLength = traj.x;
        freq *= a;
        skip_probability = 1-(1-skip_prob)*2;
      } else if (melody_disty <= melody_distx && melody_disty <= melody_distz) {
        melody_arc.add(traj.copy().mult(melody_disty));
        melody_intervalLength = traj.y;
        freq *= b;
      } else {
        melody_arc.add(traj.copy().mult(melody_distz));
        melody_intervalLength = traj.z;
        freq *= c;
      }
      
      // We get more complex intervals between successive notes by not
      // playing every freq we generate.
      if (random(0,1) > 0) {//skip_probability) {
        WavePlayer wp = new WavePlayer(ac, freq, Buffer.TRIANGLE);//Buffer.SINE);
        Gain h = new Gain(ac, 1, new Envelope(ac, 0));
        h.addInput(wp);
        Panner p = new Panner(ac, -1);
        p.addInput(h);
        m.addInput(p);
        ((Envelope)h.getGainUGen()).addSegment(0.08, 0.02*notelength);
        ((Envelope)h.getGainUGen()).addSegment(0.08, 0.8*notelength);
        ((Envelope)h.getGainUGen()).addSegment(0, 0.05*notelength, new KillTrigger(h));
      }
      
      // Only need arc's value mod integers
      while (melody_arc.x > 1) melody_arc.x -= 1;
      while (melody_arc.y > 1) melody_arc.y -= 1;
      while (melody_arc.z > 1) melody_arc.z -= 1;
      
      //println(intervalLength);
      //((Envelope)m.getGainUGen()).addSegment(0.05, 1);
      ((Envelope)m.getGainUGen()).addSegment(1, intervalscale*(melody_intervalLength), this);
      
    }
  };
  
  final Bead melody2_nextInterval = new Bead() {
    public void messageReceived(Bead message) {
        float melody2_distx = (ceil(melody2_arc.x) - melody2_arc.x)/traj.x;
      if (melody2_distx == 0) melody2_distx = 1.0/traj.x;
      float melody2_disty = (ceil(melody2_arc.y) - melody2_arc.y)/traj.y;
      if (melody2_disty == 0) melody2_disty = 1.0/traj.y;
      float melody2_distz = (ceil(melody2_arc.z) - melody2_arc.z)/traj.z;
      if (melody2_distz == 0) melody2_distz = 1.0/traj.z;
      
      float melody2_intervalLength = 1.0;
      //int pitch = Pitch.forceToScale((int)random(12), Pitch.minor);
      //float freq = Pitch.mtof(pitch + (int)random(5) * 12 + 32);
      float skip_probability = skip_prob;
          
                // Step arc up to the next transition,
      // and add interval which corresponds to
      // projected unit of that dimension
      if (melody2_distx <= melody2_disty && melody2_distx <= melody2_distz) {
        melody2_arc.add(traj.copy().mult(melody2_distx));
        melody2_intervalLength = traj.x;
        freq2 *= a;
        skip_probability = 1-(1-skip_prob)*2;
      } else if (melody2_disty <= melody2_distx && melody2_disty <= melody2_distz) {
        melody2_arc.add(traj.copy().mult(melody2_disty));
        melody2_intervalLength = traj.y;
        freq2 *= b;
      } else {
        melody2_arc.add(traj.copy().mult(melody2_distz));
        melody2_intervalLength = traj.z;
        freq2 *= c;
      }
      
      // We get more complex intervals between successive notes by not
      // playing every freq we generate.
      if (random(0,1) > 0) {//skip_probability) {
        WavePlayer wp = new WavePlayer(ac, freq2, Buffer.TRIANGLE);//Buffer.SINE);
        Gain h = new Gain(ac, 1, new Envelope(ac, 0));
        h.addInput(wp);
        Panner p = new Panner(ac, -1);
        p.addInput(h);
        m2.addInput(p);
        ((Envelope)h.getGainUGen()).addSegment(0.08, 0.02*notelength);
        ((Envelope)h.getGainUGen()).addSegment(0.08, 0.8*notelength);
        ((Envelope)h.getGainUGen()).addSegment(0, 0.05*notelength, new KillTrigger(h));
      }
      
      // Only need arc's value mod integers
      while (melody2_arc.x > 1) melody2_arc.x -= 1;
      while (melody2_arc.y > 1) melody2_arc.y -= 1;
      while (melody2_arc.z > 1) melody2_arc.z -= 1;
      
      //println(intervalLength);
      //((Envelope)m2.getGainUGen()).addSegment(0.05, 1);
      ((Envelope)m2.getGainUGen()).addSegment(1, intervalscale*(melody2_intervalLength), this);
      
    }
  };
  
  final Bead drbeat_play = new Bead() {
    public void messageReceived(Bead message) {
      WavePlayer drbwp = new WavePlayer(ac, 1000, Buffer.TRIANGLE);//Buffer.SINE);
      Gain drbh = new Gain(ac, 1, new Envelope(ac, 0));
      drbh.addInput(drbwp);
      Panner drbp = new Panner(ac, -1);
      drbp.addInput(drbh);
      drb.addInput(drbp);
      ((Envelope)drbh.getGainUGen()).addSegment(0.08, 0.02*notelength);
      //((Envelope)h.getGainUGen()).addSegment(0.08, 0.4*notelength);
      ((Envelope)drbh.getGainUGen()).addSegment(0, 0.05*notelength, new KillTrigger(drbh));
      
    }
  };
  
  final Bead nextInterval = new Bead() {
    public void messageReceived(Bead message) {
      float distx = (ceil(arc.x) - arc.x)/traj.x;
      if (distx == 0) distx = 1.0/traj.x;
      float disty = (ceil(arc.y) - arc.y)/traj.y;
      if (disty == 0) disty = 1.0/traj.y;
      float distz = (ceil(arc.z) - arc.z)/traj.z;
      if (distz == 0) distz = 1.0/traj.z;
      
      float intervalLength = 1.0;
      
      ((Envelope)drb.getGainUGen()).addSegment(1,1,drbeat_play);
      //((Envelope)drb.getGainUGen()).addSegment(1,100,drbeat_play);
      
      // Step arc up to the next transition,
      // and add interval which corresponds to
      // projected unit of that dimension
      if (distx <= disty && distx <= distz) {
        arc.add(traj.copy().mult(distx));
        intervalLength = traj.x;
        
        ((Envelope)env.getGainUGen()).addSegment(0.1, 0.02*notelength);
        ((Envelope)env.getGainUGen()).addSegment(0, 0.5*notelength);
        
      } else if (disty <= distx && disty <= distz) {
        arc.add(traj.copy().mult(disty));
        intervalLength = traj.y;
      } else {
        arc.add(traj.copy().mult(distz));
        intervalLength = traj.z;
      }
      
      // Only need arc's value mod integers
      while (arc.x > 1) arc.x -= 1;
      while (arc.y > 1) arc.y -= 1;
      while (arc.z > 1) arc.z -= 1;
      
      //println(intervalLength);
      ((Envelope)g.getGainUGen()).addSegment(0.05, 0.01*intervalscale*intervalLength);
      ((Envelope)g.getGainUGen()).addSegment(0, 0.99*intervalscale*intervalLength, this);
      
    }
  };
  
  
  ((Envelope)g.getGainUGen()).addSegment(0,100,nextInterval);
  ((Envelope)m.getGainUGen()).addSegment(0,100,melody_nextInterval);
  ((Envelope)m2.getGainUGen()).addSegment(0,100,melody2_nextInterval);
  g.addInput(noise);
  //ac.out.addInput(m);
  //ac.out.addInput(m2);
  ac.out.addInput(g);
  ac.out.addInput(drb);
  ac.start();
}

/*
 * Here's the code to draw a scatterplot waveform.
 * The code draws the current buffer of audio across the
 * width of the window. 
 * 
 * Start with some spunky colors.
 */
color fore = color(255, 102, 204);
color back = color(0,0,0);

/*
 * Just do the work straight into Processing's draw() method.
 */
void draw() {
  loadPixels();
  //set the background
  Arrays.fill(pixels, back);
  //scan across the pixels
  for(int i = 0; i < width; i++) {
    //for each pixel work out where in the current audio buffer we are
    int buffIndex = i * ac.getBufferSize() / width;
    //then work out the pixel height of the audio data at that point
    int vOffset = (int)((1 + ac.out.getValue(0, buffIndex)) * height / 2);
    //draw into Processing's convenient 1-D array of pixels
    vOffset = min(vOffset, height-10);
    pixels[vOffset * height + i] = fore;
  }
  updatePixels();
}
