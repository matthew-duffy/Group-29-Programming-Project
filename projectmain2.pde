String lines[];
ArrayList<Flight> flights;
float scrollY = 0;  // Current scroll position
float scrollSpeed = 20;  // How fast to scroll
float itemHeight = 20;  // Height of each flight entry

// SCREEN NAVIGATION VARIABLES
// 0 = Flight List (Default)
// 1 = Charts Screen
// To add more screens, just plan for 2, 3, 4, etc.
int currentScreen = 0; 

// Moved these out of void setup() so that they can be used for the Flight class
String flightDate = "";         
String airlineCode = "";        
String airline = "";            
String origin = "";             
String originState = "";        
String originWAC = "";          
String destination = "";        
String destinationCityName = "";
String destinationState = "";   
String destinationWAC = "";     
String crsDepTime = "";         
String DepTime = "";            
String CRSArrTime = "";         
String ArrTime = "";            
String Cancelled = "";          
String Diverted = "";           
String Distance = "";           

void setup() {
  size(800, 600);

  flights = new ArrayList<Flight>();

  lines = loadStrings("flights.csv");

  for (int i = 1; i < lines.length; i++) {
    String[] columns = split(lines[i], ',');
    if (columns.length < 17) continue;
    
    flightDate = columns[0];
    airlineCode = columns[1];
    airline = columns[2];
    origin = columns[3];
    originState = columns[4];
    originWAC = columns[5];
    destination = columns[6];
    destinationCityName = columns[7];
    destinationState = columns[8];
    destinationWAC = columns[9];
    crsDepTime = columns[10];
    DepTime = columns[11];
    CRSArrTime = columns[12];
    ArrTime = columns[13];
    Cancelled = columns[14];
    Diverted = columns[15];
    Distance = columns[16];
    
    Flight f = new Flight(flightDate, airlineCode, origin, destination);
    flights.add(f);
  }
  
  println("Flights loaded: " + flights.size());
}

void draw() {
  background(0);
  

  // SCREEN ROUTER
  // This checks which screen we should be looking at and calls the right function
  if (currentScreen == 0) {
    drawFlightListScreen();
  } 
  else if (currentScreen == 1) {
    drawChartScreen();
  }
  // HOW TO ADD MORE SCREENS:
  // 1. Add another else if statement here:
  // else if (currentScreen == 2) {
  //   drawMyNewScreen();
  // }
  
  // Draw universal navigation instructions on top of whatever screen is showing
  drawNavigationOverlay();
}


// SCREEN 0: FLIGHT LIST 
void drawFlightListScreen() {
  fill(255,200,0);
  textSize(16);
  text("FLIGHT", 50, 40);
  text("TIME", 300, 40);
  text("DESTINATION", 400, 40);
  
  stroke(255);
  line(40, 50, 700, 50);
  
  pushMatrix();
  translate(0, scrollY);  // Apply scroll offset
  
  textSize(12);
  for (int i = 0; i < flights.size(); i++) {
    Flight f = flights.get(i);
    float y = 30 + (i * itemHeight);
    
    // Only draw if visible
    if (y + scrollY > -itemHeight && y + scrollY < height) {
      // Alternate row colors for better readability
      if (i % 2 == 0) {
        fill(240);
      } else {
        fill(220);
      }
      rect(0, y - 15, width, itemHeight);
      
      fill(0);
      f.display(int(y));
    }
  }
  popMatrix();
}


// SCREEN 1: CHARTS (New placeholder screen)
void drawChartScreen() {
  fill(255);
  textSize(24);
  text("Flight Data Charts", 50, 50);
  
  textSize(14);
  text("This could be for charts", 50, 100);
  
}

// HOW TO ADD MORE SCREENS:
// 2. Create the function that draws your new screen
// void drawMyNewScreen() {
//   fill(255);
//   text("Welcome to screen 3!", 50, 50); etc
// }

// Draws instructions to tell the user how to switch screens
void drawNavigationOverlay() {
  fill(0, 200); 
  noStroke();
  rect(0, height - 30, width, 30);
  
  fill(255);
  textSize(14);
  text("Press '1' for Flight List | Press '2' for Charts", 10, height - 10);
  //  can update these instructions to tell users to press '3'
}

// INPUT HANDLING
void keyPressed() {
  // Switch screens based on number keys
  if (key == '1') {
    currentScreen = 0;
  } 
  else if (key == '2') {
    currentScreen = 1;
  }

  // 3. Add a key trigger to switch to your new screen state
  // else if (key == '3') {
  //   currentScreen = 2;
  // }
}

void mouseWheel(MouseEvent event) {
  // Only allow scrolling if we are on the flight list screen (Screen 0)
  if (currentScreen == 0) {
    float e = event.getCount();
    scrollY -= e * scrollSpeed;
    
    // Prevent scrolling beyond content bounds
    float maxScroll = -((flights.size() * itemHeight) - height + 50);
    scrollY = constrain(scrollY, maxScroll, 0);
  }
}
class Flight {
  String flightDate;
  String airlineCode;
  String origin;
  String destination;

  Flight(String fDate, String aCode, String orig, String dest) {
    flightDate = fDate;
    airlineCode = aCode;
    origin = orig;
    destination = dest;
  }

  void display(int y) {
    text(airlineCode, 50, y);
    text(flightDate, 200, y);
    text(origin, 350, y);
    text(destination, 400, y);
  }
}
