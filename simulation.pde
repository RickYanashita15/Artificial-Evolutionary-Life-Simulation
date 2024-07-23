int cellScale = 4; //each cell in the map is 4pixels x 4pixels
int mapWidth, mapHeight; //width and height of map in pixels
int gridWidth, gridHeight; //width and height of the grid in pixels
map theMap; 
float zoom, cameraX, cameraY; //location of the camera
String popString; 
String mapString; 
boolean run = true; 


int minPop = 50; //minimum population. If population drops below 50, spawn new creatures
ArrayList<creature> pop; //population, an arraylist of creature objects. ArrayList: size of population will change. 
int waitReproduceTime; 

int numGenes; 
HashMap<String,Integer> genes = new HashMap<String,Integer>(); //map names of genes to integer values. 

void setup(){
  size(800,1000,P3D); //2D simulation with a 3D camera
  
  //adding a bunch of genomes into genes hashmap
  genes.put("angle",0); //angle of two sensing organs
  genes.put("distance",1); //length of sensing organs
  genes.put("appendage",2); //tail for swimming or legs for moving 
  genes.put("fruitTurnSpeed",3); //if sense fruit, turns toward it at a speed
  genes.put("seaweedTurnSpeed",4); //if sense seaweed, turns towards it at a speed
  genes.put("landTurnSpeed",5); //if sense land, turns towards it at a speed
  genes.put("waterTurnSpeed",6); //if sense water, turns towards it at a speed. 
  genes.put("shape",7); //body shape
  genes.put("fruitEnergy",8);  //amount of energy they get from fruit
  genes.put("seaweedEnergy",9); //amount of energy they get from seaweed
  genes.put("speed",10); //speed they they move at, which can be affected by appendage. 
  genes.put("immunity", 11); //immunity to poison
  numGenes = genes.size(); 
   
  pop = new ArrayList<creature>(); //add 100 creatures 
  for(int i = 0; i < minPop*2; i++){
    pop.add(new creature()); 
  }

  waitReproduceTime = 60000;
  
  mapWidth = 1*width; //map is width of window
  mapHeight = 1*height; //map is height of window
  gridWidth = mapWidth/cellScale; //creating the grid. map size / cell size. should be even divisor. 
  gridHeight = mapHeight/cellScale; 
  theMap = new map(); //creating a new map object
  cameraX = width/2.0; //camera starts at middle of window. 
  cameraY = height/2.0; 
  zoom = (height/2.0) / tan(PI*30.0/180.0); //right distance to just be looking at window
  
  mapString = theMap.mapStats; 
  popString = "Population Size: " + pop.size() ; 
}

void draw(){
  playPauseInput(); 
  if (run){
    background(0); 
    theMap.addFood(); 
    theMap.display(); 
    for(creature c: pop){ //draw each creature on the map. 
      c.update(); //update creature position
      c.display(); //display creature position
    }
    keyInput(); 
    reproduce(); 
    checkPop(); //remove creatures with energy below 0, 
    popString = "Population Size:" + pop.size(); 
    fill(255, 255, 255);
    textSize(15);
    text(popString, 0, 40);
    text(mapString, 0, 60); 
  }
}

//removing from arraylist, go through the list backwards. 
void checkPop(){
  for (int i = pop.size()-1; i >=0; i--){
    creature c = pop.get(i); 
    if(c.energy <=0){
      pop.remove(i); 
    }
  }
}

//asexual reproduction
void reproduce(){
  //get each creature and if energy above 1500, reproduce
  for(int i = 0; i < pop.size(); i++){
    creature c = pop.get(i);
    if(c.energy > 1500 && millis() - c.reproduceTimer >= waitReproduceTime){
      c.reproduceTimer = millis(); 
      creature offspring = new creature(); 
      offspring.copy(c); //copy genome of the old creature
      offspring.mutate(); //new creature should be mutated 
      c.energy -= 1000; //reproduction costs 1000 energy
      offspring.heading = random(0,2*PI); //change movement direction of the offspring heading
      offspring.calcValues(); 
      pop.add(offspring); //add offspring to the population
    }
  }
  //if the population is too small, spawn more creatures
  if(pop.size() < minPop){
    creature c = new creature(); 
    pop.add(c); 
  }
}

//see if a key is being currently held down, and move camera accordingly. 
void keyInput(){
  if(keyPressed){
    if (keyCode == LEFT){
      cameraX-=5; 
    }
    if (keyCode == RIGHT){
      cameraX+=5; 
    }
    if (keyCode == UP){
      cameraY-=5; 
    }
    if (keyCode == DOWN){
      cameraY+=5; 
    }
    camera(cameraX,cameraY,zoom, cameraX, cameraY, 0, 0, 1, 0); //reset the camera to the new location as the user presses buttons to move around. 
  }
}

void playPauseInput(){
  if(keyPressed){
    if(key == ' '){
      run = !run; 
      key = 's'; 
    }
  }
}

//function for zooming in. built in function for processing. Takes a MouseEvent object. 
void mouseWheel(MouseEvent event){
  float e = event.getCount();
  
  if (run && (e > 0 || zoom >= 101.02539)){ //checks to make sure zoom does not clip into the background/ flip the scene
    zoom += 5*e; 
  }
  
  camera(cameraX, cameraY, zoom, cameraX, cameraY, 0, 0, 1, 0); //reset camera to use new zoom value. 
  
  
}

//sigmoid function, used everywhere in the code. 
float sigmoid(float x){
  float r = 0.5; 
  return(2.0/(1+exp(-r*x)) - 1); 
}
