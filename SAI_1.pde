
import java.util.ArrayList;

ArrayList<Particle> Plist = new ArrayList<Particle>();

QuadTree qt;

// -63830
// 80093

// max particles in a single quad tree part
int qtcap = 20;

//mas threads (may not actualy work as intended)
int threadNum = 6;

// how many threads are curently active (may not actualy work as intended)
static int threadsWorking = 0;

//is thread working rn
boolean simulating = false; 

// i haave no idea what paused could be doing.
boolean paused = true;

// idk what this ones does...
int numberOfParticals = 2000;

//max speed
float max = 100;

// friction applied when moving 
float friction;

// min speed to apply colision friction
float minSpeedForColFriction;


// friction applied when colision and when speed is bigger than minSpeedForColFriction
float ColFriction;

// number of diferent particle types
int numberOfTypes = 3;


// holds the interaction streangth for each pair of particle types
float[][] interactions = new float[numberOfTypes][numberOfTypes];


// holds the color for every particle type
color[] Ctable = new color[numberOfTypes];

// holds the radius for every particle type
float Rtable[] = new float[numberOfTypes];

// holds the multiplier for the interaction distance of every particle type
float Dtable[] = new float[numberOfTypes];

//NOT IN USE old way of spaining particles, no longer in use (used to control the size of the single clump that contanied all the particles)
float spread = 800;

//number of clumps for every type of particle when starting sim, for example if this is set to 5 then upon starting the sim there will be 5 clumps of every particle type.
int numOfClumps = 10;

//min radius of particle clumps when starting sim
float Rmin= 50;

//max radius of particle clumps when starting sim
float Rmax = 500;


//the scale of the sim world, bigger value means bigger world
float viewScale = 1;

// current zoom of the camera
float zoom = 1;

//position of camera
PVector camera = new PVector(0,0);

//NOT IN USE old direction of gravity
PVector gravity = new PVector(0,1);

//how many frames to skip, if set to 1 then draw 1 out of every 1 frame, if set to 2 then draw 1 out of every 2 frames etc etc
int frameSkip = 1;

//particle type to spawn when clicking (can be changed at runtime with number keys)
int Ptype = 0;

// show brush
boolean showBrush = false;

// size of bruh (right clickng deletes everything in brush range)
float brushSize = 30;

//how many particles were rendered this frame
int particalsRenderedThisFrame = 0;

// NOT IN USE beta way of zooming so the zoom is towards the middle of the screen insted of top left
boolean useBetaZoom = false;

// makes it so if a particles detectes a colision it will applay force not only to itself but also to the other particle
boolean doubleColisionAction = true;

// show stats on screen, can be toggled by pressing s
boolean showStats = false;

//show the reaction distance for each particle (very laggy can cause crashes)
boolean showNdis = false;

boolean showBounds = false;

//decides whether to record every frame to output folder
boolean record = false;

//change view to a phase space where the middle of the screen represents no movment;
boolean velocityMapView = false;

// show the rules of the current sim
boolean ruleView = false;

//format to save frames if recording
String frameSaveFormat = "tiff";

//min and max radius sizes
int minS = 4,maxS = 10;

//min and max force difrences between particle sizes, if the maxS = 10 and the minS = 1 and the maxF =1 and maxF = 2 
//then a particle of size 10 would have a 2 times force multiplier apllied to its reactions, while a particle of size 1 would have a 1 times multiplier, all sizes in between are interpolated
float minF = 1, maxF = 2;
 
 // times stamp of last frame (in millisecends)
int lastFrameTime = 0;

// if fps is higher than this then the program will skip drawing the frame to avoid unacecary computations
float targetFpsFroDrawSkip = 60;
//random seed for sim
int seed = (int)random(-100000,100000);

int numberOfResets = 0;

 
void setup(){
  //print seed of current sim so you can save it for later if you want
  

// use that seed

    //randomSeed(-63830);
      randomSeed(seed);

  //randomSeed(-63830);

  size(1920,1080);
    //fullScreen(); //<>//
  
  //starts the sim

  
  initSim();
  

  
  noSmooth();
  noStroke();
  
  
  
frameRate(10000);


}



void draw(){
   colorMode(RGB,255);
   
  // checks if there is a reson not to render a frame
       background(0);
  if(!ruleView){
    if(frameCount % frameSkip == 0 || millis() - lastFrameTime > (0.001 / targetFpsFroDrawSkip)){
       
     ellipseMode(CENTER);
     push();
     translate(camera.x,camera.y);  
     
     //try to show all particles
     for(Particle p : Plist)
       p.show();
       
         pop();
    }
  }else{
   
    ellipseMode(CENTER);

    noStroke();
    
    textMode(CENTER);
    
    
    textSize(20);
    float sepSize = 100;
    for(int y = 0; y < numberOfTypes; y ++){
     
      
        fill(Ctable[y]);      
        ellipse(sepSize,(y+1) * sepSize + sepSize, 6 * Rtable[y], 6 * Rtable[y]);
        

        for(int x = 0; x < numberOfTypes; x ++){
          if(interactions[y][x] > 0)
          fill(0,255,0);
          else if(interactions[y][x] < 0)
          fill(255,0,0);
          text(nf(interactions[y][x],0 ,1), (x+2) * sepSize ,(y+2) * sepSize);
        }


    }

    for(int x = 0; x < numberOfTypes; x ++){
         fill(Ctable[x]);
         ellipse((x+1) * sepSize + sepSize, sepSize, 6 * Rtable[x], 6 * Rtable[x]);
            
    }
    
  }
  

    
    fill(255);
 //   ellipse(camera.x ,camera.y ,50,50);
 

        if(!paused && !simulating)
         simulateWithsThreads();
     
     //thread("remakeQuadTree");
     
     //remake the quadtree for this frame
         remakeQuadTree();
         


      noFill();
      if(showBrush)
      ellipse(mouseX,mouseY,brushSize*2,brushSize*2);
      
     // qt.show();
      
      PVector Rpos = new PVector(mouseX,mouseY);
      PVector Rsize = new PVector(100,100);
      
     rectMode(CENTER);
    
     stroke(0,255,0);
     strokeWeight(1);

    // rect(Rpos.x,Rpos.y,Rsize.x*2,Rsize.y*2);
      
     //ArrayList<Particle> Ps = qt.getPsInRect(Rpos,Rsize);
      
  //    for(Particle p : Ps)
    //    p.show();
      
      //qt.insertPs(Plist);
      
      
// render the stats to the screen if needed

          if(frameCount % frameSkip == 0 || millis() - lastFrameTime > (0.001 / targetFpsFroDrawSkip)){
            
                  if(showBounds){
                      noFill();
                      stroke(0,255,0);
                      rectMode(CORNERS);
                      rect(camera.x,camera.y,camera.x+width/zoom,camera.y+height/zoom);
                    }
            
            if(showStats){
              fill(255);
              textSize(13);
              textAlign(LEFT, TOP);
              text("fps: " + frameRate + "\nparticals: " + Plist.size() + "\ntypes: " + numberOfTypes + "\nrendered Particles: " +  particalsRenderedThisFrame + "\nzoom: " + zoom + "\nfriction: " + friction + "\nColFriction :" + ColFriction + "\nminSpeedForColFriction: " + minSpeedForColFriction,0,10);
            }
            
            if(record && !paused){
              
              saveFrame("frame_######." + frameSaveFormat);
              
            }
            
          }
 particalsRenderedThisFrame = 0;
 
 lastFrameTime = millis();
 
}


void exit() {
  
  print(seed + ", " + numberOfResets);
  super.exit();
  
} 

// simulate with threads, this basicly just creates and runs the threads, for more infor on the sim itself check the Pthread class
void simulateWithsThreads(){
  
  simulating = true;

        if(threadsWorking <= threadNum-threadsWorking){         
       
          int threadsToMake = threadNum-threadsWorking;
          Pthread[] threads = new Pthread[threadsToMake];     
         // print(threadsToMake + "\n");
        for(int i = 0 ; i < threadsToMake; i++)          
         threads[i] = new Pthread( splitList( i*(Plist.size()/threadsToMake),(i+1)*(Plist.size()/threadsToMake) , Plist ),qt );
           
        for(Pthread t : threads){
          //print(threads.length);
          threadsWorking++;
          new Thread(t).start();
        }
        }
       // for(Particle p : Plist)
       // p.updateMov(qt);
        simulating = false;     
      
      //    qt = new QuadTree(new PVector(width/2,height/2),new PVector(width/2,height/2), qtcap);

        //  qt.insertPs(Plist);
      
}

//NOT IN USE simulate on a single thread, was used beffor i knew how to work woth threads
void simulate(){
 
        simulating = true;
  

        for(Particle p : Plist)
        p.updateMov(qt);
        
       for(Particle p : Plist)
        p.moveAccToMov(qt);
        simulating = false;     
        
        //  qt = new QuadTree(new PVector(width/2,height/2),new PVector(width/2,height/2), qtcap);
    
        //  qt.insertPs(Plist);
      
}

//remake quad tree and re instert the particles in to it
void remakeQuadTree(){
   qt = new QuadTree(new PVector(width*viewScale/2,height*viewScale/2),new PVector(width*viewScale/2,height*viewScale/2), qtcap);

   qt.insertPs(Plist);
}

// sets up the simulation

void initSim(){
  // init of the main quad tree
     qt = new QuadTree(new PVector(width*viewScale/2,height*viewScale/2),new PVector(width*viewScale/2,height*viewScale/2), qtcap);
     Plist = new ArrayList<Particle>();
  //randomize the rules of the sim
  randomize();
  
  
  // randomize  the colors of the particles
  float CS = random(100);
  
    for(int y = 0 ; y < numberOfTypes; y ++){
    float t = CS +(100/numberOfTypes*y);
    if(t > 100)
      t -= 100;
    Ctable[y] = color(t,100,100);
    }
    

  
  
    //for(int t = 0 ; t < numberOfTypes; t ++){
    //  for(int i = 0 ; i < 3000 ; i ++)   
    //  Plist.add(new Particle(new PVector((int)random(width*viewScale/4*(t-1),width*viewScale/4*(t+2)),(int)random(height*viewScale/4*(t-1),height*viewScale/4*(t+2)) ),new PVector((int)random(-2,2),(int)random(-2,2) ), t ));
    //}
  
//this can be used to force certine rules in to the simulation

/*
    float[] FRtable = new float[]{
    5,5,5
  };
  
  float SR = -1;
  float OA = .5;
  
   float[][] Finteractions = new float [][]{
    {SR,OA,0},
    {0,SR,OA},
    {OA,0,SR}
  };

  float[] FDtable = new float[]{
    6,6,6
  };

  interactions = forceIntoArr2D(Finteractions,interactions);
  Rtable = forceIntoArr(FRtable,Rtable);
  Dtable = forceIntoArr(FDtable,Dtable);
  */
  
     //for(int i = 0 ; i < numberOfParticals ; i ++){
     // Plist.add(new Particle(new PVector((int)random(width*viewScale/spread,(width*viewScale/spread)*(spread-1)),(int)random(height*viewScale/spread,(height*viewScale/spread)*(spread-1)) ),new PVector((int)random(-2,2),(int)random(-2,2) ), (int)random(numberOfTypes)));
     //}
     
     //for(int t = 0 ; t < numberOfTypes; t ++){
     //  for(int i = 0 ; i < numberOfParticals/numberOfTypes ; i ++){
     //    float x = noise(i/100 + t*100 + random(-0.2,0.2));
     //    float y = noise(i/100 + t*100 + 100000 + random(-0.2,0.2));
         
     //    x = x*width*viewScale;      
     //    y = y*height*viewScale;
         
     //     Plist.add((new Particle(new PVector(x,y), new PVector((int)random(-2,2),(int)random(-2,2)), t )));
         
     //  }
     //}
     
          
          //spawns the random clumps of particles at the start
          
      for(int t = 0 ; t < numberOfTypes; t ++){
        for(int j = 0 ; j < numOfClumps ; j ++){
          
          float R = random(Rmin*viewScale, Rmax*viewScale);
          
        float x = random(R,width*viewScale-R);
        float y = random(R,height*viewScale-R);
        


        
       for(int i = 0 ; i < numberOfParticals/numberOfTypes/numOfClumps ; i ++){
        float T = random(TWO_PI);
        
          Plist.add((new Particle(new PVector(x + sin(T)*random(R) ,y + cos(T)*random(R)), new PVector((int)random(-2,2),(int)random(-2,2)), t )));
         
       }
      }
     }
  
//    for(int i = 0 ; i < numberOfParticals ; i++){
//    Particle p = new Particle(new PVector(random(0,width),random(0,height)),new PVector(random(-2,2),random(-2,2)) ,(int)random(0,numberOfTypes));
//    Plist.add(p);
////    qt.insertP(p);b 
//  }
        // inserts the particles in to the quad tree
        qt.insertPs(Plist);
  
}


//randomize everything that can be randomizd, if this explenation isnt sufficient then sucks to be you right now
void randomize(){
 
      colorMode(HSB,100);
  
  friction = random(0.9,1);
  ColFriction = random(0.9,1);
  minSpeedForColFriction = random(0,5);
  
  for(int y = 0 ; y < numberOfTypes; y ++){
    Rtable[y] = random(minS,maxS);
  }
  
    for(int y = 0 ; y < interactions.length; y++)
      for(int x = 0 ; x < interactions[y].length; x++)
        interactions[y][x] = random(-1,1);
  
  for(int y = 0 ; y < numberOfTypes; y ++){
    Dtable[y] = random(3,11);
  }
  
    float CS = random(0,100);
  
    for(int y = 0 ; y < numberOfTypes; y ++){
    float t = CS +(100/numberOfTypes*y);
    if(t > 100)
      t -= 100;
    Ctable[y] = color(t,100,100);
    }
  
}

//randomizes and applies the rules for a sim thats curently running (can be called but pressing the R key)
void randomizeLiveSim(){
  
  randomize();
  
  for(Particle p : Plist){
    p.r = Rtable[p.type];
    p.Ndis = p.r*Dtable[p.type];
  }
  
}

ArrayList<Particle>  splitList(int Fi, int Ti,ArrayList<Particle>  PWlist){
  
  ArrayList<Particle>  Slist = new ArrayList<Particle>();
  
  for(int i = Fi; i < Ti ; i ++)
    Slist.add(PWlist.get(i));
  return Slist;
  
}

// forces array a into array b
float[] forceIntoArr(float[] a, float[] b){
  
  for(int y = 0; y < a.length; y ++)
         b[y] = a[y];
  
  return b;
  
}
// forces 2d array a into 2d array b
float[][] forceIntoArr2D(float[][] a, float[][] b){
  
  for(int y = 0; y < a.length; y ++)
     for(int x = 0; x < a[y].length; x++)
         b[y][x] = a[y][x];
  
  return b;
  
}

//handle mouse input

void mouseDragged(){
  
  
        if((mouseButton == CENTER)){
  
        PVector dir = new PVector(mouseX,mouseY).sub(new PVector(pmouseX,pmouseY));
        dir.normalize();
        dir.mult((1/zoom)*2);
        camera .add(dir);
          
      } else if(mouseButton == RIGHT){
       
          ArrayList<Particle> P  =qt.getPsInRect(new PVector(map(mouseX-camera.x,0,width/viewScale/zoom,0,width),map(mouseY-camera.y,0,width/viewScale/zoom,0,width)),new PVector(brushSize*viewScale*zoom,brushSize*viewScale*zoom));
        for(Particle p : P)
        if(p.pos.dist(new PVector(map(mouseX-camera.x,0,width/viewScale/zoom,0,width),map(mouseY-camera.y,0,width/viewScale/zoom,0,width)))  < brushSize*viewScale*zoom)
          Plist.remove(p); 
        
      }else if(mouseButton == LEFT){
        Plist.add((new Particle(new PVector(map(mouseX-camera.x,0,width/viewScale/zoom,0,width),map(mouseY-camera.y,0,height/viewScale/zoom,0,height)),new PVector(), Ptype ))); 
      }
  
}

//handle keyboard input
void keyPressed() {
  //print("a");
   if (key == ' ') {
    paused = !paused; 
   }else if(key == 'r'){
     numberOfResets++;
     initSim();
     randomizeLiveSim();
   }else if( str(key).matches("-?[0-"+str(numberOfTypes-1)+"]+")){
     Ptype = Integer.valueOf(str(key));
   }else if(key == 'c'){
   // record = !record; 
   }else if(key == 's'){
     showStats  = !showStats;
   }else if(key == 'v'){
     velocityMapView = !velocityMapView;
   }else if(key == 'b'){
     showBounds = !showBounds;
   }else if(key == 'i'){
     ruleView = !ruleView;
   }
     

   
   
   
}

   //handle mouse wheel input
void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  if(e > 0)
  zoom -= (zoom*2)/(zoom+60);
  else
  zoom -= -(zoom*2)/(zoom+60);
  if(zoom < .1)
  zoom = .1;
  
  //camera.add(-viewScale,-viewScale);
  
}



  
