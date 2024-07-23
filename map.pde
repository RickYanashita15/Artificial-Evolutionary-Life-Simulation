//map class
class map{
  cell map[][]; //2D array of cells
  
  String mapStats; 
  
  //constructor to construct maps. 
  map(){
    map = new cell[gridHeight][gridWidth]; //height comes first, width comes second. Row-column order. 
    float a; //altitude
    float noiseScale = 0.015*cellScale; //using processing noise function to fill in altitude, giving organic looking map. By changing scale, get more/less details on map
    float d, maxd, dx, dy; 
    maxd = sqrt(gridWidth*gridWidth*0.25+gridHeight*gridHeight*0.25); 
    //fill altitude for every cell on the map. 
    for (int r = 0; r < gridHeight; r++){
      for (int c = 0; c < gridWidth; c++){
        dx = gridWidth*0.5-r;
        dy = gridHeight*0.5-c; 
        d = sqrt(dx*dx+(800.0/1000.0)*dy*dy); 
        a = 0.75 - 2*d/maxd; 
        a += 2.0*noise(r*noiseScale,c*noiseScale) -1; 
        //a = noise(r*noiseScale, c*noiseScale); //noise returns a value between 0-1, focused around 0.5. Negative values = water, Positive values = land. 
        //a = map(a,0,1,-1,1); //map function remaps 0-1, to -1 to 1. 
        map[r][c] = new cell(a); //new cell with given altitude. 
      }
    }
    mapStats = getMapStat(); 
    //adds 50 food to start. 
    for(int i = 0; i < 50; i++){
      addFood(); 
    }
    //adds 20 poison to start
    for(int i = 0; i < 20; i++){
      addPoison(); 
    }
  }
  
  //code to display scent. Mainly for debugging, not necessary to display the scent (should be invisible in reality)
  void displayScent(){
    for(int r = 0; r < gridHeight; r++){
      for(int c = 0; c < gridWidth; c++){
        if(map[r][c].fruitScent > 0){
          fill(255,0,0,map[r][c].fruitScent*20); //fill cell with a color, with a transparency level determined by scent level
          rect(c*cellScale, r*cellScale, cellScale, cellScale); //redraw the rectangle to display scent. 
        }
        if(map[r][c].seaweedScent > 0){
          fill(125,218,88,map[r][c].seaweedScent*20);
          rect(c*cellScale, r*cellScale, cellScale, cellScale);
        }
      }
    }
  }
  
  //display map
  void display(){
    noStroke(); 
    for (int r = 0; r < gridHeight; r++){
      for (int c = 0; c < gridWidth; c++){
        
        //c = color(0,0,map(altitude,0,-0.5,255,0)); 

        //decide if the cell should be covered with land or water. 
        if (map[r][c].altitude < -0.5){
          fill(0,0,255-map[r][c].altitude*-200); //water 
        } 
        if (map[r][c].altitude >= -0.5 && map[r][c].altitude < 0){
          fill(100,150,255-map[r][c].altitude*-200); //shallow water
        } 
        if (map[r][c].altitude >= 0 && map[r][c].altitude < 0.3){
          fill(255,236,161-map[r][c].altitude*-200); //beach land
        } 
        if (map[r][c].altitude >= 0.3){
          fill(125,218-map[r][c].altitude*-200,88); //land
        } 
    
        rect(c*cellScale, r*cellScale, cellScale, cellScale); //multiply by cell scale because each cell is 4 pixels (cellscale). fill cellScale # of pixels both directions
        //adding food to the map
        if (map[r][c].food == "fruit"){
          fill(255,0,0); //fruit is red 
          circle(c*cellScale+cellScale*0.5, r*cellScale+cellScale*0.5, cellScale); //convert grid to pixels. c*cellScale+cellScale*0.5 = column x cell scale. want the food in the middle so have to add another half of the scale. Food is the size of the scale
        }
        if (map[r][c].food == "seaweed"){ //same thing for seaweed. 
          fill(0,255,0); 
          circle(c*cellScale+cellScale*0.5, r*cellScale+cellScale*0.5, cellScale); 
        }
        if (map[r][c].poison == true){ //color for poison is purple
          fill(214,97,232); 
          circle(c*cellScale+cellScale*0.5, r*cellScale+cellScale*0.5, cellScale); 
        }
      }
    }
    displayScent(); 
  }
  
   String getMapStat(){
    noStroke(); 
    float water = 0, land = 0; 
    float waterRatio, landRatio; 
     
    for (int r = 0; r < gridHeight; r++){
      for (int c = 0; c < gridWidth; c++){

        //decide if the cell should be covered with land or water. 
        if (map[r][c].altitude < -0.5){
           water += 1;//water 
        } 
        if (map[r][c].altitude >= -0.5 && map[r][c].altitude < 0){
          water += 1; //shallow water
        } 
        if (map[r][c].altitude >= 0 && map[r][c].altitude < 0.3){
          land += 1; //beach land
        } 
        if (map[r][c].altitude >= 0.3){
          land += 1; //land
        } 
      }
    }
    float sum = water + land; 
    waterRatio = water/sum;
    landRatio = land/sum; 
    String output = "Land Makeup: " + waterRatio*100 + "% water, " + landRatio*100 + "% land."; 
    return output; 
  }
  
  //function to add or remove scent from that location
  void changeScent(int row, int col, int flag){
    float scent; 
    int scentRange = 5; 
    
    //populating surrounding cells (that are in the scentRange) with differing levels of scent
    for(int r = row - scentRange; r <= row+scentRange; r++){
      for(int c = col-scentRange; c <= col+scentRange; c++){
        scent = scentRange/(1+pow(abs(r-row),2)+pow(abs(c-col),2)); //how much scent should be in the cell. calculate how far from the food this scent cell is to give the scent a value. add 1 to prevent zero division. 
        // check to make sure r & c values in within grid
        if((r >= 0) && (r < gridHeight) && (c >= 0) && (c < gridWidth)){
          if(map[row][col].food == "fruit"){ //check what type of food is located. in this case fruit
            map[r][c].fruitScent+=scent*flag; 
          }
          if(map[row][col].food == "seaweed"){
            map[r][c].seaweedScent+=scent*flag; 
          }
        }
      }
    }
    
  }
  //function to add food to the map. 
  void addFood(){
    //random location to place food. 
    int r,c; 
    r = int(random(gridHeight));  
    c = int(random(gridWidth)); 
    if (map[r][c].food != ""){
     return;     
    } 
    //add fruit to land, and seaweed to water. 
    if (map[r][c].altitude < 0){
      map[r][c].food = "seaweed"; 
    } else {
      map[r][c].food = "fruit"; 
    }
    changeScent(r,c,1); //change scent with a flag value of 1. 
  }
  
  //function to add poison to the map
  void addPoison(){
    //random location to place poison
    int r,c; 
    r = int(random(gridHeight));  
    c = int(random(gridWidth)); 
    if (map[r][c].poison == true){
     return;     
    } 
    map[r][c].poison = true; //add poison
    
  }

}
