
  public class Pthread implements Runnable {

    ArrayList<Particle>  PWlist;
    QuadTree pqt;
     Pthread(ArrayList<Particle>  PWlist,QuadTree pqt){
       
      this.pqt = pqt;
      this.PWlist = PWlist;
      
    }
    
    public void run(){
      
      //update all the partiles this thread was assigned to
      
       for(Particle p : this.PWlist)
         p.updateMov(pqt);
         
         
       for(Particle p : this.PWlist)
         p.moveAccToMov(pqt);
         
       incWorkingT();
       //  print("thread done/n");
    }
    
    
  }
  //i have no iead in the synchronized keyword is actualy working, i am not good at threads.
  static synchronized void incWorkingT(){
      
    threadsWorking--;
    
  }
