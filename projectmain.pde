String lines[];
ArrayList<Flight> flights;
ArrayList<Flight> displayedFlights; // NEW: The subset of data currently being viewed

float scrollY = 0;  // Current scroll position
float scrollSpeed = 20;  // How fast to scroll
float itemHeight = 20;  // Height of each flight entry

// SCREEN NAVIGATION VARIABLES
int currentScreen = 0; 

// array list to store number of flights each hour
int[] hourlyCounts = new int[24];

// SEARCH VARIABLES
String searchQuery = ""; // NEW: Stores what the user types

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
  displayedFlights = new ArrayList<Flight>(); // Initialize the display list

  lines = loadStrings("flights.csv");

  for (int i = 1; i < lines.length; i++) {
    String[] columns = lines[i].split(",(?=(?:[^\"]*\"[^\"]*\")*[^\"]*$)");
    if (columns.length < 18) continue; 
    
    flightDate = columns[0];
    airlineCode = columns[1];
    airline = columns[2];
    origin = columns[3];
    originState = columns[5];
    destination = columns[7];
    destinationCityName = columns[8];
    destinationState = columns[9];
    crsDepTime = columns[11];
    DepTime = columns[12];
    ArrTime = columns[14];
    Cancelled = columns[15];
    Diverted = columns[16];
    Distance = columns[17];
    
    Flight f = new Flight(flightDate, airlineCode, origin, destination, originState, destinationCityName, destinationState, crsDepTime, DepTime, ArrTime, Distance, Diverted, Cancelled);
    flights.add(f);
  }
  
  // Initially, displayed flights is equal to all flights
  displayedFlights.addAll(flights);
  
  println("Flights loaded: " + flights.size());
  countFlightsByHour();
}

void draw() {
  background(0);

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
  drawNavigationOverlay();
}

// NEW: Function to filter the data based on user input
void filterFlights() {
  displayedFlights.clear(); // Empty the current view
  scrollY = 0; // Reset scroll position so we don't get lost at the bottom
  
  if (searchQuery.length() == 0) {
    // If search is empty, show everything
    displayedFlights.addAll(flights);
  } else {
    String q = searchQuery.toLowerCase();
    for (Flight f : flights) {
      // Check if the query matches airline, origin, destination, or city
      if (f.airlineCode.toLowerCase().contains(q) || 
          f.origin.toLowerCase().contains(q) || 
          f.destination.toLowerCase().contains(q) || 
          f.destinationCityName.toLowerCase().contains(q) ||
          f.originState.toLowerCase().contains(q)) {
        
        displayedFlights.add(f);
      }
      else if(q.contains("dep") && f.Cancelled.equals("0") && f.Diverted.equals("0") && q.equals("dep" + f.DepTime)){
      
            if(q.contains(f.DepTime.toLowerCase())){
                displayedFlights.add(f);
              }
    }
    else if(q.contains("arr") && f.Cancelled.equals("0") && f.Diverted.equals("0") && q.equals("arr" + f.ArrTime)){
          if(q.contains(f.ArrTime.toLowerCase())){
              displayedFlights.add(f);
          }
    }
    }
  }
  
  // Re-calculate the hourly chart based on the new subset!
  countFlightsByHour();
}


// SCREEN 0: FLIGHT LIST 
void drawFlightListScreen() {
  textAlign(LEFT, BASELINE);
  
  // 1. DRAW THE SCROLLING LIST FIRST
  pushMatrix();
  translate(0, scrollY);  // Apply scroll offset
  
  textSize(12);
  for (int i = 0; i < displayedFlights.size(); i++) {
    Flight f = displayedFlights.get(i);
    
    // Shifted Y down to 100 to make room for search bar + header
    float y = 100 + (i * itemHeight); 
    
    // Only draw if visible
    if (y + scrollY > -itemHeight && y + scrollY < height) {
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
  
  // 2. DRAW A SOLID BACKGROUND FOR THE HEADER (Expanded for search bar)
  fill(0); 
  noStroke();
  rect(0, 0, width, 80); 
  
  // 3. DRAW SEARCH BAR
  fill(255);
  textSize(16);
  // Blinking cursor effect
  String cursor = (frameCount / 30 % 2 == 0) ? "_" : "";
  text("Search (Airline, Origin, Dest, City, DepTime(put \"dep\" before), ArrTime(put \"arr\" before): " + searchQuery + cursor, 10, 25);
  stroke(100);
  line(10, 35, 750, 35);
  
  // 4. DRAW COLUMN HEADERS
  fill(255, 200, 0);
  textSize(14);
  text("AIRLINE", 10, 60);
  text("DATE", 70, 60);
  text("ORIGIN", 150, 60);
  text("O.ST", 210, 60);
  text("DEST CITY", 260, 60);
  text("D.ST", 420, 60);
  text("DEP", 470, 60);
  text("ARR", 520, 60);
  text("DIST", 570, 60);
  text("DIV", 620, 60);
  text("CANC", 680, 60);
  
  stroke(255);
  line(10, 70, 750, 70); 
}

// SCREEN 1: CHARTS
void drawChartScreen() {
  background(255);
  drawPieChart();
  
  // Show search bar context on the chart screen too
  fill(0);
  textSize(16);
  textAlign(LEFT);
  text("Filtering by: " + (searchQuery.equals("") ? "All Flights" : searchQuery), 10, 25);
}

void drawPieChart() {
  HashMap<String, Integer> stateCount = new HashMap<String, Integer>();

  // CHANGED: Iterate over displayedFlights to make chart dynamic
  for (Flight f : displayedFlights) {
    String state = f.destination;
    if (stateCount.containsKey(state)) {
      stateCount.put(state, stateCount.get(state) + 1);
    } else {
      stateCount.put(state, 1);
    }
  }

  float total = displayedFlights.size();
  if (total == 0) return; // Prevent divide by zero if search has no results

  float angleStart = 0;

  noStroke();
  textAlign(CENTER, CENTER); 
  textSize(20);

  int i = 0;
  for (String state : stateCount.keySet()) {
    float count = stateCount.get(state);
    float angle = (count / total) * TWO_PI;
    
    fill((i * 50) % 255, (i * 80) % 255, (i * 110) % 255);
    arc(400, 320, 300, 300, angleStart, angleStart + angle, PIE);
    
    float midAngle = angleStart + angle / 2;
    float x = 400 + cos(midAngle) * 150;
    float y = 320 + sin(midAngle) * 150;

    fill(0,200,100); 
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

  // CHANGED: Iterate over displayedFlights to make chart dynamic
  for (Flight f : displayedFlights) {
    int hour = f.getDepartureHour();
    if (hour != -1) {
      hourlyCounts[hour]++;
    }
  }
}

void drawHourlyChart() {
  int chartX = 60;
  int chartY = 520; 
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

  // Show search bar context
  fill(255);
  textSize(16);
  textAlign(LEFT);
  text("Filtering by: " + (searchQuery.equals("") ? "All Flights" : searchQuery), 10, 25);

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

void drawNavigationOverlay() {
  textAlign(LEFT, BASELINE);
  fill(0, 200); 
  noStroke();
  rect(0, height - 30, width, 30);
  
  fill(255);
  textSize(14);
  text(",: Flight List | .: Destination Chart | /: Hourly Chart | Type to Search!", 10, height - 10);
}

// INPUT HANDLING
void keyPressed() {
  // Switch screens based on number keys
  if (key == ',') {
    currentScreen = 0;
  } 
  else if (key == '.') {
    currentScreen = 1;
  }
  else if (key == '/') {
    currentScreen = 2;
  }
  // NEW: Search Input Handling
  else if (key == BACKSPACE) {
    if (searchQuery.length() > 0) {
      searchQuery = searchQuery.substring(0, searchQuery.length() - 1);
      filterFlights(); // Re-filter when user deletes a letter
    }
  }
  else if (key != CODED && key != ENTER && key != RETURN && key != ESC && key != TAB) {
    // Only accept letters, numbers, and spaces
    if (String.valueOf(key).matches("[a-zA-Z0-9 ]")) {
      searchQuery += key;
      filterFlights(); // Re-filter when a user types a new letter
    }
  }
}

void mouseWheel(MouseEvent event) {
  if (currentScreen == 0) {
    float e = event.getCount();
    scrollY -= e * scrollSpeed;
    
    //  Use displayedFlights size to dynamically calculate the scrolling bounds
    float maxScroll = -((displayedFlights.size() * itemHeight) - height + 120);
    if (maxScroll > 0) maxScroll = 0; // Prevent jumping if list is shorter than screen
    
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
    if (DepTime == null || DepTime.equals("")) {
      return -1;
    }

    try {
      int time = Integer.parseInt(DepTime);
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
    text(flightDate.split(" ")[0], 70, y);
    text(origin, 150, y);
    text(originState, 210, y);
    
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
