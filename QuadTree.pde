
class QuadTree{
  
  PVector pos;
  PVector size;
  int cap;
  ArrayList<Particle> particles = new ArrayList<Particle>();
  
  //subsections or child trees idc what you call it
  QuadTree[][] subSections;
  
  QuadTree(PVector pos, PVector size, int cap){
    this.pos = pos;
    this.size = size;
    this.cap = cap;
     particles = new ArrayList<Particle>();
     subSections = null;
  }
  
  
  //insert particles to quad tree and expand tree if needed
  void insertPs(ArrayList<Particle> Ps){
    
    for(Particle p : Ps)
      insertP(p);
    
  }
  //insert particle to quad tree and expand tree if needed
  boolean insertP(Particle p){
    
    if(!containsP(p))
      return false;
    
    if(particles.size() >= cap){
      if(this.subSections == null){
         this.subdevide(); 
      }
         
         // should never returb false;
      return insertToQuads(p);

    }else {
      
     particles.add(p); 
     return true;
     
    }

    
  }
  ////insert particles to quad and expand tree if needed
  boolean insertToQuads(Particle p){
    
      if(subSections[0][1].insertP(p))
        return true;
      if(subSections[0][0].insertP(p))
        return true;
      if(subSections[1][0].insertP(p))
        return true;
      if(subSections[1][1].insertP(p))
        return true;
        
      return false;
    
  }
  
  
  //subdivide tree, i know about the typo so basicly cope because i dont speak english.
  void subdevide(){
      
    /*
    
    [0,0]  [0,1]
    
    [1,0]  [1,1]
    
    
    */
    
    QuadTree[][] nsubSections = new QuadTree[2][2];
    
    nsubSections[0][1] = new QuadTree(new PVector(this.pos.x + this.size.x/2,this.pos.y + this.size.y/2), new PVector(this.size.x/2,this.size.y/2),cap);
    nsubSections[0][0] = new QuadTree(new PVector(this.pos.x - this.size.x/2,this.pos.y + this.size.y/2), new PVector(this.size.x/2,this.size.y/2),cap);
    nsubSections[1][0] = new QuadTree(new PVector(this.pos.x + this.size.x/2,this.pos.y - this.size.y/2), new PVector(this.size.x/2,this.size.y/2),cap);
    nsubSections[1][1] = new QuadTree(new PVector(this.pos.x - this.size.x/2,this.pos.y - this.size.y/2), new PVector(this.size.x/2,this.size.y/2),cap);
    
    subSections = nsubSections;
    
  }
  
  
  // get particles in an arbitrary rectangle
  ArrayList<Particle> getPsInRect(PVector Rpos, PVector Rsize){
    
    ArrayList<Particle> Ps = new ArrayList<Particle>();
    
    if(!intersectsRect(Rpos,Rsize)){
     return Ps; 
    }else{
     for(int i =0 ; i < particles.size(); i ++){
       Particle p = particles.get(i);
    //for(Particle p : particles)
      if(rectContainsP(p,Rpos,Rsize))
        Ps.add(p);
     }
        
      if(subSections != null){

       // print("\n");
        Ps.addAll(subSections[0][0].getPsInRect(Rpos,Rsize));
        Ps.addAll(subSections[0][1].getPsInRect(Rpos,Rsize));
        Ps.addAll(subSections[1][0].getPsInRect(Rpos,Rsize));
        Ps.addAll(subSections[1][1].getPsInRect(Rpos,Rsize));

        
      }

       return Ps; 
      
    }
    
  }
  
  //check if this quad tree contains a particle (does not include the child trees)
   boolean containsP(Particle p){
     return ( 
     (p.pos.x >= pos.x - this.size.x) && 
     (p.pos.x <= pos.x + this.size.x) && 
     (p.pos.y >= pos.y - this.size.y) && 
     (p.pos.y <= pos.y + this.size.y) );
   }
   
   //check if rectangle contains a particle,
   //Rpos rectangle position
   //Rsize is the size of the rectangle, (x is the width and y is the height)
   boolean rectContainsP(Particle p,PVector Rpos, PVector Rsize){
     
     
     if(p != null){
     return ( 
     (p.pos.x >= Rpos.x - Rsize.x) && 
     (p.pos.x <= Rpos.x + Rsize.x) && 
     (p.pos.y >= Rpos.y - Rsize.y) && 
     (p.pos.y <= Rpos.y + Rsize.y) );
     }else{
     return false;
     }
   }
   
   //does rectangle intersects this tree (does not include child trees)
   boolean intersectsRect(PVector Rpos, PVector Rsize){
     
     return !(
     
     Rpos.x - Rsize.x > pos.x + size.x ||
     Rpos.x + Rsize.x < pos.x - size.x  ||
     Rpos.y - Rsize.y > pos.y + size.y ||
     Rpos.y + Rsize.y < pos.y - size.y 
     
     );
     
   }
   
   //show this tree (includes child trees)
   void show(){
     rectMode(CENTER);
     
     noFill();
     stroke(255);
     strokeWeight(1);
       colorMode(RGB,255);
     fill(0,255,0,map(particles.size(),0,Plist.size(),0,255));
     rect(map(pos.x,0,width*viewScale,0,width),map(pos.y,0,height*viewScale,0,height),size.x*2,size.y*2);
     
    if(this.subSections != null){
      subSections[0][1].show();
      subSections[0][0].show(); 
      subSections[1][0].show();
      subSections[1][1].show();
    } //if(particles.size() != 0){
     
       //for(Particle p : particles)
       //   p.show(color(map(size.x,0,width/2,50,255)));
      
    
     
   }
    

  
}
