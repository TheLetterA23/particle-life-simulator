
class Particle{
  
  //the possition of the Particle
  PVector pos;
  
  // the movment vector of the Particle
  PVector mov;
  
  //the radius of the Particle
  float r;
  
  //the range in whice the particle with react to other particles
  float Ndis;
  
  // the type of the Particle
  int type;
  
  //the acuracy of the collision and movment calculations, 1 means no acuracy increes, 2 means divide the times step in to 2 partsm 3 means 3 parts etc etc, gets changes dynamicly to acomodate difficolt moments in sim
  int acc = 1;
  
  //holds all the neighbor particles this frame (usefull because multiples fumctions need this info)
  ArrayList<Particle> Ns = new ArrayList<Particle>();
  
  //parent quad tree.
  QuadTree pqt;

  float realwidth = width * viewScale;
  float realheight = height * viewScale;
  
  Particle(PVector pos,PVector mov, int type){
    
    this.pos = pos;
    this.mov = mov;
    this.r = Rtable[type];
    this.type = type;
    Ndis = r*Dtable[type];
    pqt = qt;
    
  }
  
  //updates the movment direction based on the neighbors, this is where the reactions come into place
  void updateMov(QuadTree npqt){
    pqt = npqt;
    //get neighbors in a cube the with side length r
    Ns = pqt.getPsInRect(new PVector(pos.x,pos.y),new PVector(Ndis,Ndis));
    PVector movChange = new PVector();
    
    //get aceleration multiplier based radius
    float am = map(r,minS,maxS,minF,maxF);
    
    //react to each neighbor
    for(Particle n : Ns){
      
      PVector np = new PVector(n.pos.x,n.pos.y);
      if(isNan(np.x) || isNan(np.y))
      continue;
      
      //because the neighbor list contanies neighbors in a cube and not a circile we still need to filter for things outsid the reaction distance
      if(pos.dist(np) > Ndis)
      continue;
      
      //sanity check to make sure there are no 2 particles with the same location
      if(np.x == pos.x && np.y == pos.y)
        continue;
      
      PVector t = new PVector(np.x,np.y);
      t.sub(pos);
      t.normalize();
      
      
      //reacte based on distance and interaction coefficient
      t.mult( ((1)/( pos.dist(np))) * interactions[this.type][n.type] * am);
      
      movChange.add(t);
      
    }
    
    movChange.mult(1);
    //sanity check because these keep coming back as NaN
    if( isNan(movChange.x) || isNan(movChange.y) )
      return;
      
      
     
    mov.add(movChange);
    
  }
  
  //checks if number is NaN
  boolean isNan(float f){
    
    Float F = f;
    
    return F.isNaN();
    
  }
  
  // move particle and check for collisions woth the boundries and other particles
  void moveAccToMov(QuadTree npqt){
    pqt = npqt;
    Ns = pqt.getPsInRect(new PVector(pos.x,pos.y),new PVector(Ndis,Ndis));
    mov.mult(friction); //<>// //<>// //<>// //<>//
    
    mov.limit(max);
    
    if(pos.x - r < 0 || pos.x + r > realwidth)
    mov.x =- mov.x;
    
    if(pos.y - r < 0 || pos.y + r > realheight)
    mov.y =- mov.y;

    if(pos.x - r < 0 )
    pos.x = r;
    
    if(pos.x + r > realwidth)
    pos.x = realwidth-r;
    
    if(pos.y - r < 0 )
    pos.y = r;
    
    if(pos.y + r > realheight)
    pos.y = realheight-r;
    
    
    //if there are too many particles near eachother its probbly a good idea to up the simulation accuracy in order for everything to remain stable
    //btw these numbers are arbitrary and were acquired with trial and error
   if(Ns.size() > 70){
   acc = 10;
   for(Particle n : Ns)
   n.acc = 10;
   }else
   acc = 1;
    
    for(int i = 0 ; i < acc ; i ++){
         
    pos.add(new PVector(mov.x,mov.y).div(acc));
   // pos.add(new PVector(gravity.x,gravity.y).div(acc));
    
   // ArrayList<Particle> Ns = pqt.getPsInRect(new PVector(pos.x,pos.y),new PVector(r*2,r*2));
    
    for(Particle n : Ns){
      
      //grossest code in the world!!!!!!!!!!!!!!!!!!!
      
      PVector p = new PVector(n.pos.x,n.pos.y);
      if(isNan(p.x) || isNan(p.y))
      continue;
      
      
      if(pos.dist(p) <= this.r + n.r)
        handleCollision(n);
    }
    
   }
    
    
    
  }
  
  //show particle on screen if its visible
  void show(){

    float x;
    float y;
    
    if(useBetaZoom){
    
     x = map((pos.x),0,realwidth,0,width );
     y = map((pos.y),0,realheight,0,height);
    
    PVector screenPos = new PVector(x,y);
    PVector cameraCenter = new PVector(width/2 - camera.x,height/2 - camera.y);
    
    PVector dir = new PVector(screenPos.x,screenPos.y).sub(cameraCenter);
    dir.normalize();
    
  //  print(dir);
    
    float dist = screenPos.dist(cameraCenter);
    
    dir.mult(1+1/(zoom/dist));
    
    print(dir);
    
    screenPos.add(dir);
    
  //  print(screenPos+"\n");
    
    x = screenPos.x;
    y = screenPos.y;
    }else if(!velocityMapView){
     
     x = map((pos.x),0,realwidth*zoom,0,width );
     y = map((pos.y),0,realheight*zoom,0,height);

      
    }else{
      
      x =  map(mov.x,-max,max,0,width);
      y =  map(mov.y,-max,max,0,height);
      
    }
    
    
    if(x + camera.x < width+this.r && y + camera.y < height+this.r && x + camera.x > 0-this.r && y + camera.y > 0-this.r){
    fill(Ctable[type]);
    //fill(map(acc,0,30,100,255));
    noStroke();
    if(useBetaZoom)
    ellipse(x,y,r*2/(viewScale)/zoom,r*2/(viewScale)/zoom ); 
    else
    ellipse(x,y,r*2/(viewScale)/zoom,r*2/(viewScale)/zoom ); 
    particalsRenderedThisFrame++;
    }
    
    //if needed show Ndis
    if(showNdis){
    noFill();
    stroke(255);
    ellipse(x,y,Ndis*2/(viewScale)/zoom,Ndis*2/(viewScale)/zoom );
    }
    
  }
    void show(color c){
    fill(c);
    noStroke();
    ellipse(pos.x,pos.y,r*2,r*2); 
  }
  
  
  // handles particles to particle colissions, i have no iead how this works i stole it from a friend who stole it from the internet. i just played woth the finctions and names untill it worked.
  void handleCollision(Particle other) {
   // Get distances between the balls components
    PVector distanceVect = PVector.sub(other.pos, pos);

    // Calculate magnitude of the vector separating the balls
    float distanceVectMag = distanceVect.mag();

    // Minimum distance before they are touching
    float minDistance = r + other.r;

  
      float distanceCorrection = (minDistance-distanceVectMag)/2.0;
      PVector d = distanceVect.copy();
      PVector correctionVector = d.normalize().mult(distanceCorrection);
      other.pos.add(correctionVector);
      pos.sub(correctionVector);

      // get angle of distanceVect
      float theta  = distanceVect.heading();
      // precalculate trig values
      float sine = sin(theta);
      float cosine = cos(theta);

      /* bTemp will hold rotated ball poss. You 
       just need to worry about bTemp[1] pos*/
      PVector[] bTemp = {
        new PVector(), new PVector()
      };

      /* this ball's pos is relative to the other
       so you can use the vector between them (bVect) as the 
       reference point in the rotation expressions.
       bTemp[0].pos.x and bTemp[0].pos.y will initialize
       automatically to 0.0, which is what you want
       since b[1] will rotate around b[0] */
      bTemp[1].x  = cosine * distanceVect.x + sine * distanceVect.y;
      bTemp[1].y  = cosine * distanceVect.y - sine * distanceVect.x;

      // rotate Temporary velocities
      PVector[] vTemp = {
        new PVector(), new PVector()
      };

      vTemp[0].x  = cosine * mov.x + sine * mov.y;
      vTemp[0].y  = cosine * mov.y - sine * mov.x;
      vTemp[1].x  = cosine * other.mov.x + sine * other.mov.y;
      vTemp[1].y  = cosine * other.mov.y - sine * other.mov.x;

      /* Now that velocities are rotated, you can use 1D
       conservation of momentum equations to calculate 
       the final mov along the x-axis. */
      PVector[] vFinal = {  
        new PVector(), new PVector()
      };

      // final rotated mov for b[0]
      vFinal[0].x = ((r - other.r) * vTemp[0].x + 2 * other.r * vTemp[1].x) / (r + other.r);
      vFinal[0].y = vTemp[0].y;

      // final rotated mov for b[0]
      vFinal[1].x = ((other.r - r) * vTemp[1].x + 2 * r * vTemp[0].x) / (r + other.r);
      vFinal[1].y = vTemp[1].y;

      // hack to avoid clumping
      bTemp[0].x += vFinal[0].x;
      bTemp[1].x += vFinal[1].x;

      /* Rotate ball poss and velocities back
       Reverse signs in trig expressions to rotate 
       in the opposite direction */
      // rotate balls
      PVector[] bFinal = { 
        new PVector(), new PVector()
      };

      bFinal[0].x = cosine * bTemp[0].x - sine * bTemp[0].y;
      bFinal[0].y = cosine * bTemp[0].y + sine * bTemp[0].x;
      bFinal[1].x = cosine * bTemp[1].x - sine * bTemp[1].y;
      bFinal[1].y = cosine * bTemp[1].y + sine * bTemp[1].x;

      // update balls to screen pos
      //other.pos.x = pos.x + bFinal[1].x;
     // other.pos.y = pos.y + bFinal[1].y;

      //pos.add(bFinal[0]);

      // update velocities
      mov.x = cosine * vFinal[0].x - sine * vFinal[0].y;
      mov.y = cosine * vFinal[0].y + sine * vFinal[0].x;
      
      //of this part is actualy mine
      
      if(doubleColisionAction){
      other.mov.x = cosine * vFinal[1].x - sine * vFinal[1].y;
      other.mov.y = cosine * vFinal[1].y + sine * vFinal[1].x;
      }
     if(mov.mag() > minSpeedForColFriction/viewScale) 
     mov.mult(ColFriction); 
     if(other.mov.mag() > minSpeedForColFriction/viewScale && doubleColisionAction) 
     other.mov.mult(ColFriction); 
      
    
  }
  
}
