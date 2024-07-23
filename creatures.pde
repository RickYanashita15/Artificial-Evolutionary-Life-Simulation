//creature class
class creature{
  float x,y; 
  float heading; 
  float[] genome; //array of floats of values (genes)
  
  //traits
  float baseSpeed, waterSpeed, landSpeed; 
  float energyFruit, energySeaweed, immunity; 
  color c; 
  float energy; //not a trait, but amount of energy that a creature has. 
  int reproduceTimer; 
  float append; 
  
  creature(){
    energy = 500; //starting energy
    x = random(width); 
    y = random(height); 
    heading = random(2*PI); 
    genome = new float[numGenes]; 
    reproduceTimer = millis(); 
    //set all gene values to a random number
    //need gene values to be varied, but trait values (what we observe) to be limited. using a sigmoid function allows gene to go crazy but trait to be consistent
    for(int i = 0; i < numGenes; i++){
      genome[i] = random(-5.0,5.0); 
    }
    calcValues(); 
  }
  
  //copy genome from source to offspring
  void copy(creature source){
    x = source.x; 
    y = source.y;
    for(int i = 0; i < genome.length; i++){
      genome[i] = source.genome[i]; 
    }
  }
  
  //mutation, randomize the gene value of just one genome to make offspring different from parent. 
  void mutate(){
    int gene = int(random(genome.length)); 
    genome[gene] += random(-0.5, -0.5); 
  }
  
  //function to calculate the base traits
  void calcValues(){
    append = sigmoid(genome[genes.get("appendage")]); 
    baseSpeed = 0.5 + sigmoid(genome[genes.get("speed")]); //getting gene at the integer that corresponds to specific string. 
    waterSpeed = baseSpeed*(1-(sigmoid(genome[genes.get("appendage")]))); //if appendage is negative, get a negative number from sigmoid, and water speed goes up. 
    landSpeed = baseSpeed*(1+(sigmoid(genome[genes.get("appendage")]))); //if appendage is positive, decreases water speed and increases land speed. 
    float sum = (1 + abs(sigmoid(genome[genes.get("fruitEnergy")])) + 
                     abs(sigmoid(genome[genes.get("seaweedEnergy")]))); //value of sum of energy from eating fruit and seaweed. 
                     //can evolve to many different types of food preferences
    energyFruit = 200*(abs(sigmoid(genome[genes.get("fruitEnergy")])))/sum; //get gene value, run it through sigmoid (abs value to always increase energy).
    energySeaweed = 200*(abs(sigmoid(genome[genes.get("seaweedEnergy")])))/sum; 
    immunity = 100*(abs(sigmoid(genome[genes.get("immunity")])))/sum; 
    
    //change the color of the creatures depending on the preference fruit vs. seaweed. 
    if(abs(genome[genes.get("fruitEnergy")]) > abs(genome[genes.get("seaweedEnergy")])){ //if more fruit energy than seaweed energy: 
      c = color(255*abs(sigmoid(genome[genes.get("fruitEnergy")])),0,0); //more red
    } else {
      c = color(0,255*abs(sigmoid(genome[genes.get("seaweedEnergy")])), 0); //more green
    }
  }
  
  void display(){
    fill(c); //color of the creature
    pushMatrix(); //display creatures
      translate(x,y); 
      rotate(heading); 
      pushMatrix(); 
        append = sigmoid(genome[genes.get("appendage")]); 
        scale(abs(append)); //psuh/pop so that the scale only applies to appendage
        if(append < 0){
          translate(-cellScale, 0); //putting tail at the back
          rotate(0.5*sin(0.5*frameCount));  //tail moves side to side for visual effects
          triangle(0,0, -cellScale, -0.5*cellScale, -cellScale, 0.5*cellScale); //tail is a triangle. 
        } else {
          stroke(c); 
          strokeWeight(3); 
          line(0,-2*cellScale, 0, 2*cellScale); //legs if the appendage is positive
        }
      popMatrix(); 
       noStroke(); 
      ellipse(0,0,cellScale,cellScale*(1+(sigmoid(genome[genes.get("shape")])))); //adjust the ellipse/body by the shape gene
    popMatrix();
  }
  
  //function to get the creatures to move (update position)
  void update(){
    //variables for location of left/right sensors
    float leftSensorX, leftSensorY;
    float rightSensorX, rightSensorY;
    float leftSensorR, leftSensorC; 
    float rightSensorR, rightSensorC; 
    
    float angle = sigmoid(genome[genes.get("angle")])*0.5*PI; //calculate the angle of the antenna
    float len = 3 + abs(sigmoid(genome[genes.get("distance")]))*cellScale; //calculate the length of the antenna
    float speed = 1; 
    
    leftSensorX = x + len*cos(heading+angle); //pos of the creature + len of the antenna * cos of angle and heading to figure out x value
    leftSensorY = y + len*sin(heading+angle); //same things as above
    rightSensorX = x + len*cos(heading-angle); //righ sensor we subtract the angle
    rightSensorY = y + len*sin(heading-angle); 
    leftSensorC = int(leftSensorX/cellScale); //column
    leftSensorR = int(leftSensorY/cellScale); //row
    rightSensorC = int(rightSensorX/cellScale);
    rightSensorR = int(rightSensorY/cellScale); 
    
    //draw the antennas + little eye-like dot at the end
    fill(0);
    stroke(c);
    strokeWeight(1);
    line(x,y,leftSensorX,leftSensorY);
    line(x,y,rightSensorX, rightSensorY); 
    noStroke(); 
    circle(leftSensorX, leftSensorY, 2);
    circle(rightSensorX, rightSensorY, 2); 
    
    //variables for scenting food/terrain on the left and right. 
    float leftFoodScent = 0; 
    float rightFoodScent = 0;
    int leftTerrain,rightTerrain; 
    
    //make sure the antennas are in the map and not off, so we don't get an out of bounds error. 
    if(leftSensorC >= 0 && leftSensorC < gridWidth && leftSensorR >= 0 && leftSensorR < gridHeight && rightSensorC >= 0 && rightSensorC < gridWidth && rightSensorR >= 0 && rightSensorR < gridHeight){
      leftFoodScent = theMap.map[int(leftSensorR)][int(leftSensorC)].fruitScent; //checking left food scent for fruit
      rightFoodScent = theMap.map[int(rightSensorR)][int(rightSensorC)].fruitScent;  
      heading += sigmoid(genome[genes.get("fruitTurnSpeed")])*0.25*PI*(leftFoodScent-rightFoodScent); //turn towwards or away from it
      
      //same deal for seaweed
      leftFoodScent = theMap.map[int(leftSensorR)][int(leftSensorC)].seaweedScent; 
      rightFoodScent = theMap.map[int(rightSensorR)][int(rightSensorC)].seaweedScent; 
      heading += sigmoid(genome[genes.get("seaweedTurnSpeed")])*0.25*PI*(leftFoodScent-rightFoodScent); 
      
      //turn towards or away from terrain
      if(theMap.map[int(leftSensorR)][int(leftSensorC)].altitude >= 0){ //land
        leftTerrain = 1;
      } else { //water
        leftTerrain = -1; 
      }
      
      if(theMap.map[int(rightSensorR)][int(rightSensorC)].altitude >= 0){
        rightTerrain = 1;
      } else {
        rightTerrain = -1; 
      }
      
      //change heading based on landTurnSpeed and waterTurnSpeed. 
      heading += sigmoid(genome[genes.get("landTurnSpeed")])*0.25*PI*(leftTerrain-rightTerrain); 
      heading += sigmoid(genome[genes.get("waterTurnSpeed")])*0.25*PI*(leftTerrain-rightTerrain); 
    }
    
    //to change movement speed of creature depending on the terrain
    if(theMap.map[int(y/cellScale)][int(x/cellScale)].altitude < 0){
      speed = waterSpeed; //in water, use the water speed
    } else {
      speed = landSpeed; //in land, use the land speed. 
    }
    x += speed*cos(heading); 
    y += speed*sin(heading); 
    
    //when they get to edge of the map, turn around. 
    if(x < 0 || x > width || y < 0 || y > height){
      heading += PI; //add PI to adjust where they are pointed. 
      x += speed*cos(heading); //adjust position, taking into account speed & heading
      y += speed*sin(heading); 
    }
    eat(); //eat function
    poisoned(); 
    energy -= abs(0.1 + baseSpeed); //they will lose energy no matter what, and more depending on how fast they move. 
  }
  
   void eat(){
     //figure out which cell the creature is in
     int cellX, cellY; 
     cellX = int(x/cellScale);
     cellY = int(y/cellScale); 
     
     //if the cell has food, add energy to creature depending on their genes for fruit/seaweed
     if(theMap.map[cellY][cellX].food == "fruit")
       {
         energy += energyFruit;   
         theMap.changeScent(cellY,cellX,-1); //remove scent and food from cell(s). 
         theMap.map[cellY][cellX].food = ""; 
       }
     if(theMap.map[cellY][cellX].food == "seaweed")
       {
         energy += energySeaweed;   
         theMap.changeScent(cellY,cellX,-1); 
         theMap.map[cellY][cellX].food = ""; 
       }
    }
    
    void poisoned(){
      //figure out which cell the creature is in
     int cellX, cellY; 
     cellX = int(x/cellScale);
     cellY = int(y/cellScale); 
     
     //if the cell has poison, remove energy to creature depending on their genes for immunity
     if(theMap.map[cellY][cellX].poison == true)
       {
         energy -= immunity;   
       }
    }
    
  
  
  
}
