//stores data about each cell in the map. 
class cell{
  float altitude; //to differentiate between land, high altitude, water, deep ocean. 
  float fruitScent; //scent from fruit or seaweed
  float seaweedScent; 
  String food; //if there is food stored in the cell. 
  boolean poison; 
  
  //constructor sets everything to null values. 
  cell(float a){
    altitude = a; 
    fruitScent = seaweedScent = 0; //no scent bc no food. 
    food = ""; //no food to start
    poison = false; //no poison to start
  }
}
