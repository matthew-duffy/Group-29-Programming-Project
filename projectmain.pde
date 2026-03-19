String lines[];
ArrayList<Flight> flights;
float scrollY = 0;  // Current scroll position
float scrollSpeed = 20;  // How fast to scroll
float itemHeight = 20;  // Height of each flight entry

// SCREEN NAVIGATION VARIABLES
// 0 = Flight List (Default)
// 1 = Pie Chart Screen
// 2 = Hourly Bar Chart Screen
// To add more screens, just plan for 3, 4, 5, etc.
int currentScreen = 0; 

// array list to store number of flights each hour
int[] hourlyCounts = new int[24];

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
  ellipseMode(CENTER);

  flights = new ArrayList<Flight>();

  lines = loadStrings("flights.csv");

  for (int i = 1; i < lines.length; i++) {
    // Advanced split: splits on commas but ignores commas inside quotation marks
    String[] columns = lines[i].split(",(?=(?:[^\"]*\"[^\"]*\")*[^\"]*$)");
    if (columns.length < 18) continue; // Ensure we have all 18 columns
    
    flightDate = columns[0];
    airlineCode = columns[1];
    airline = columns[2];
    origin = columns[3];
    // columns[4] is Origin City Name
    originState = columns[5];
    // columns[6] is Origin WAC
    destination = columns[7];
    destinationCityName = columns[8];
    destinationState = columns[9];
    // columns[10] is Destination WAC
    crsDepTime = columns[11];
    DepTime = columns[12];
    // columns[13] is CRS Arr Time
    ArrTime = columns[14];
    Cancelled = columns[15];
    Diverted = columns[16];
    Distance = columns[17];
    
    // Pass ALL needed variables into the Flight object
    Flight f = new Flight(flightDate, airlineCode, origin, destination, originState, destinationCityName, destinationState, crsDepTime, DepTime, ArrTime, Distance, Diverted, Cancelled);
    flights.add(f);
  }
  
  println("Flights loaded: " + flights.size());
  
  // Call function to process flight data and count departures
  countFlightsByHour();
}

void draw() {
  background(0);

  // SCREEN ROUTER
  if (currentScreen == 0) {
    drawFlightListScreen();
  } 
  else if (currentScreen == 1) {
    drawChartScreen();
  }
  else if (currentScreen == 2) {
    drawHourlyChart();
  }
  // HOW TO ADD MORE SCREENS:
  // 1. Add another else if statement here:
  // else if (currentScreen == 3) {
  //   drawMyNewScreen();
  // }
  
  // Draw universal navigation instructions on top of whatever screen is showing
  drawNavigationOverlay();
}


// SCREEN 0: FLIGHT LIST 
void drawFlightListScreen() {
  // Reset text alignment because other screens change it!
  textAlign(LEFT, BASELINE);
  
  // 1. DRAW THE SCROLLING LIST FIRST
  pushMatrix();
  translate(0, scrollY);  // Apply scroll offset
  
  textSize(12);
  for (int i = 0; i < flights.size(); i++) {
    Flight f = flights.get(i);
    
    // Shifted the starting Y down to 80 so it starts below the header
    float y = 80 + (i * itemHeight); 
    
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
  
  // 2. DRAW A SOLID BACKGROUND FOR THE HEADER
  fill(0); 
  noStroke();
  rect(0, 0, width, 60); 
  
  fill(255, 200, 0);
  textSize(14);
  
  // Match the display() column X-coordinates
  text("AIRLINE", 10, 40);
  text("DATE", 70, 40);
  text("ORIGIN", 150, 40);
  text("O.ST", 210, 40);
  text("DEST CITY", 260, 40);
  text("D.ST", 420, 40);
  text("DEP", 470, 40);
  text("ARR", 520, 40);
  text("DIST", 570, 40);
  text("DIV", 620, 40);
  text("CANC", 680, 40);
  
  stroke(255);
  line(10, 50, 750, 50); // Underline for the header
}

// SCREEN 1: CHARTS
void drawChartScreen() {
  background(255);
  drawPieChart();
}

void drawPieChart() {
  HashMap<String, Integer> stateCount = new HashMap<String, Integer>();

  for (Flight f : flights) {
    String state = f.destination;
    if (stateCount.containsKey(state)) {
      stateCount.put(state, stateCount.get(state) + 1);
    } else {
      stateCount.put(state, 1);
    }
  }

  float total = flights.size();
  float angleStart = 0;

  noStroke();
  textAlign(CENTER, CENTER); 
  textSize(20);

  int i = 0;
  for (String state : stateCount.keySet()) {
    float count = stateCount.get(state);
    float angle = (count / total) * TWO_PI;
    
    //colour
    fill((i * 50) % 255, (i * 80) % 255, (i * 110) % 255);
    
    //slice
    arc(400, 300, 300, 300, angleStart, angleStart + angle, PIE);
    
    //label;
    float midAngle = angleStart + angle / 2;
    float x = 400 + cos(midAngle) * 150;
    float y = 300 + sin(midAngle) * 150;

    fill(0,200,100); // green
    text(state, x, y);

    angleStart += angle;
    i++;
  }
}

// SCREEN 2: HOURLY DEPARTURES
void countFlightsByHour() {
  for (int i = 0; i < 24; i++) {
    hourlyCounts[i] = 0;
  }

  for (Flight f : flights) {
    int hour = f.getDepartureHour();

    if (hour != -1) {
      hourlyCounts[hour]++;
    }
  }
}

void drawHourlyChart() {
  int chartX = 60;
  int chartY = 520; // Shifted up slightly to avoid overlapping the nav bar
  int chartHeight = 300;
  int barWidth = 20;
  int gap = 5;
  
  int maxCount = 0;
  
  for (int i = 0; i < 24; i++) {
    if (hourlyCounts[i] > maxCount) {
      maxCount = hourlyCounts[i];
    }
  }

  if (maxCount == 0) maxCount = 1;

  stroke(255);
  line(chartX, chartY, chartX, chartY - chartHeight);
  line(chartX, chartY, chartX + 24 * (barWidth + gap), chartY);
  
  for (int i = 0; i < 24; i++) {
    float barHeight = map(hourlyCounts[i], 0, maxCount, 0, chartHeight);
    int x = chartX + i * (barWidth + gap);

    fill(0, 200, 255);
    rect(x, chartY - barHeight, barWidth, barHeight);

    fill(255);
    textAlign(CENTER);
    text(i, x + barWidth/2, chartY + 15);
  }
    
  fill(255);
  textSize(16);
  textAlign(LEFT);
  text("Flights by Departure Hour", chartX, chartY - chartHeight - 20);
}


// HOW TO ADD MORE SCREENS:
// 2. Create the function that draws your new screen
// void drawMyNewScreen() {
//   fill(255);
//   text("Welcome to screen 4!", 50, 50); etc
// }

// Draws instructions to tell the user how to switch screens
void drawNavigationOverlay() {
  // Always reset alignment just in case
  textAlign(LEFT, BASELINE);
  fill(0, 200); 
  noStroke();
  rect(0, height - 30, width, 30);
  
  fill(255);
  textSize(14);
  text("1: Flight List | 2: Destination Chart | 3: Hourly Chart", 10, height - 10);
  // can update these instructions to tell users to press '4'
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
  else if (key == '3') {
    currentScreen = 2;
  }
  // 3. Add a key trigger to switch to your new screen state
  // else if (key == '4') {
  //   currentScreen = 3;
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
  
  String originState;
  String destinationCityName;
  String destinationState;
  String crsDepTime;
  String DepTime;
  String ArrTime;
  String Distance;
  String Diverted;
  String Cancelled;

  Flight(String fDate, String aCode, String orig, String dest, String oState, String dCity, String dState, String crsDep, String dTime, String aTime, String dist, String div, String canc) {
    flightDate = fDate;
    airlineCode = aCode;
    origin = orig;
    destination = dest;
    originState = oState;
    destinationCityName = dCity;
    destinationState = dState;
    crsDepTime = crsDep;
    DepTime = dTime;
    ArrTime = aTime;
    Distance = dist;
    Diverted = div;
    Cancelled = canc;
  }

  int getDepartureHour() {
    if (crsDepTime == null || crsDepTime.equals("")) {
      return -1;
    }

    try {
      int time = Integer.parseInt(crsDepTime);
      int hour = time / 100;

      if (hour >= 0 && hour < 24) {
        return hour;
      }
    } catch(Exception e) {
      return -1;
    }

    return -1;
  }

  void display(int y) {
    text(airlineCode, 10, y);
    // Grab just the date portion so it fits nicely
    text(flightDate.split(" ")[0], 70, y);
    text(origin, 150, y);
    text(originState, 210, y);
    
    // Clean quotes off the City Name text
    text(destinationCityName.replace("\"", ""), 260, y);
    text(destinationState, 420, y);
    text(DepTime, 470, y);
    text(ArrTime, 520, y);
    text(Distance, 570, y);
    
    if(Diverted.equals("1")) {
      text("yes", 620, y);
    } else {
      text("no", 620, y);
    }
    
    if(Cancelled.equals("1")) {
      text("yes", 680, y);
    } else {
      text("no", 680, y);
    }
  }
}
