import java.util.Collections;
import java.util.Comparator;
import java.util.Map;
import java.util.HashMap;


// GLOBAL VARIABLES

String lines[];                           // Stores raw lines from the CSV
ArrayList<Flight> flights;                // Stores all parsed Flight objects
ArrayList<Flight> displayedFlights;       // The active subset of flights currently being viewed

// Scrolling variables for the Flight List screen
float scrollY = 0;                        // Current vertical scroll position
float scrollSpeed = 20;                   // Pixels to move per scroll wheel tick
float itemHeight = 20;                    // The visual height of each flight entry row

// Screen navigation
// 0 = Flight List, 1 = Destination Pie Chart, 2 = Hourly Bar Chart
int currentScreen = 0;

// Array to store the number of flights departing at each hour (0-23)
int[] hourlyCounts = new int[24];

// Search and Filter variables
String searchQuery = "";                  // Stores the text typed by the user

// Filter toggles (controlled via UI buttons)
boolean showOnlyCancelled = false;
boolean showOnlyDiverted = false;

// Sorting state trackers (true = ascending, false = descending)
boolean airlineAsc = true;
boolean originAsc = true;
boolean depAsc = true;
boolean distAsc = true;
boolean lateDesc = true;                  // Lateness defaults to descending (most late first)


String flightDate = "";
String airlineCode = "";
String origin = "";
String originState = "";
String destination = "";
String destinationCityName = "";
String destinationState = "";
String crsDepTime = "";
String depTime = "";
String arrTime = "";
String cancelled = "";
String diverted = "";
String distance = "";

// SETUP & INITIALIZATION

void setup() {
  size(1000, 650);
  ellipseMode(CENTER);

  flights = new ArrayList<Flight>();
  displayedFlights = new ArrayList<Flight>();

  // Load the full dataset
  lines = loadStrings("flights_full.csv");

  // Parse the CSV starting from index 1 to skip the header row
  for (int i = 1; i < lines.length; i++) {
    // Regex splits on commas but ignores commas inside quotation marks
    String[] columns = lines[i].split(",(?=(?:[^\"]*\"[^\"]*\")*[^\"]*$)");
    if (columns.length < 18) continue; // Skip malformed rows

    // Extract necessary columns and trim whitespace
    flightDate = columns[0].trim();
    airlineCode = columns[1].trim();
    origin = columns[3].trim();
    originState = columns[5].trim();
    destination = columns[7].trim();
    destinationCityName = columns[8].trim();
    destinationState = columns[9].trim();
    crsDepTime = columns[11].trim();
    depTime = columns[12].trim();
    arrTime = columns[14].trim();
    cancelled = columns[15].trim();
    diverted = columns[16].trim();
    distance = columns[17].trim();

    // add the flight to our master list
    Flight f = new Flight(
      flightDate, airlineCode, origin, destination,
      originState, destinationCityName, destinationState,
      crsDepTime, depTime, arrTime, distance, diverted, cancelled
    );
    flights.add(f);
  }

  // Initially, all flights are displayed
  displayedFlights.addAll(flights);
  println("Flights loaded: " + flights.size());
  
  // Initialize the hourly distribution for the default view
  countFlightsByHour();
}

// MAIN DRAW LOOP

void draw() {
  background(0);

  // Route to the correct screen rendering function based on state
  if (currentScreen == 0) {
    drawFlightListScreen();
  } else if (currentScreen == 1) {
    drawChartScreen();
  } else if (currentScreen == 2) {
    drawHourlyChart();
  }

  // Draw the fixed top and bottom navigation overlays
  drawNavigationOverlay();
}

// FAST FILTERING (Optimized for 500k+ rows)

void filterFlights() {
  displayedFlights.clear();
  scrollY = 0; // Reset scroll position to top when data changes

  String q = searchQuery.toLowerCase().trim();

  // Date-range variables
  boolean hasDateRange = false;
  int minDay = 1;
  int maxDay = 31;

  // Look for the "d:" to handle date range queries (e.g., "d:1-5")
  int dIdx = q.indexOf("d:");
  String textQuery = q;

  if (dIdx != -1) {
    // Find the end of the date range input (next space or end of string)
    int endIdx = q.indexOf(' ', dIdx);
    if (endIdx == -1) endIdx = q.length();

    // Extract the range part (e.g., "1-5")
    String token = q.substring(dIdx + 2, endIdx).trim(); 
    int dash = token.indexOf('-');

    if (dash > 0 && dash < token.length() - 1) {
      try {
        // Parse the bounds
        int a = Integer.parseInt(token.substring(0, dash).trim());
        int b = Integer.parseInt(token.substring(dash + 1).trim());

        // Sort them just in case user types "d:5-1"
        minDay = min(a, b);
        maxDay = max(a, b);

        // make it do only the valid days in a month
        minDay = constrain(minDay, 1, 31);
        maxDay = constrain(maxDay, 1, 31);

        hasDateRange = true;
      } catch (Exception e) {
        // Ignore invalid formats
      }
    }

    // Remove the "d:" token from the text query so it doesn't break string matching
    textQuery = (q.substring(0, dIdx) + " " + q.substring(endIdx)).trim();
  }

  boolean hasTextQuery = textQuery.length() > 0;
  boolean depMode = hasTextQuery && textQuery.startsWith("dep");
  boolean arrMode = hasTextQuery && textQuery.startsWith("arr");

  // Iterate over the master flight list
  for (int i = 0; i < flights.size(); i++) {
    Flight f = flights.get(i);

    // 1. Check UI Button Filters
    if (showOnlyCancelled && !f.Cancelled.startsWith("1")) continue;
    if (showOnlyDiverted && !f.Diverted.startsWith("1")) continue;

    // 2. Check Date Range Filter
    if (hasDateRange) {
      int d = f.dayOfMonth; // Uses the safely pre-computed day in the Flight object
      if (d < minDay || d > maxDay) continue;
    }

    // 3. Check Text Match Filters
    if (!hasTextQuery) {
      displayedFlights.add(f);
      continue;
    }

    // Departure Time exact search (e.g., "dep800")
    if (depMode) {
      if (!f.Cancelled.startsWith("1") && !f.Diverted.startsWith("1")) {
        if (textQuery.equals("dep" + f.DepTime.toLowerCase())) {
          displayedFlights.add(f);
        }
      }
      continue;
    }

    // Arrival Time exact search (e.g., "arr1105")
    if (arrMode) {
      if (!f.Cancelled.startsWith("1") && !f.Diverted.startsWith("1")) {
        if (textQuery.equals("arr" + f.ArrTime.toLowerCase())) {
          displayedFlights.add(f);
        }
      }
      continue;
    }

    // General text search (Updated to match projectmain.pde - removed destination checks)
    if (f.airlineCodeLower.contains(textQuery) ||
      f.originLower.contains(textQuery) ||
      f.originStateLower.contains(textQuery)) {
      displayedFlights.add(f);
    }
  }

  // Update chart data to reflect the newly filtered list
  countFlightsByHour();
}

// SORTING LOGIC

void sortFlights(String sortBy) {
  if (sortBy.equals("AIRLINE")) {
    Collections.sort(displayedFlights, new Comparator<Flight>() {
      public int compare(Flight a, Flight b) {
        return airlineAsc ? a.airlineCode.compareTo(b.airlineCode) : b.airlineCode.compareTo(a.airlineCode);
      }
    });
    airlineAsc = !airlineAsc; // Toggle direction for next click
    
  } else if (sortBy.equals("ORIGIN")) {
    Collections.sort(displayedFlights, new Comparator<Flight>() {
      public int compare(Flight a, Flight b) {
        return originAsc ? a.origin.compareTo(b.origin) : b.origin.compareTo(a.origin);
      }
    });
    originAsc = !originAsc;
    
  } else if (sortBy.equals("DEP")) {
    Collections.sort(displayedFlights, new Comparator<Flight>() {
      public int compare(Flight a, Flight b) {
        return depAsc ? Integer.compare(a.depInt, b.depInt) : Integer.compare(b.depInt, a.depInt);
      }
    });
    depAsc = !depAsc;
    
  } else if (sortBy.equals("DIST")) {
    Collections.sort(displayedFlights, new Comparator<Flight>() {
      public int compare(Flight a, Flight b) {
        return distAsc ? Float.compare(a.distFloat, b.distFloat) : Float.compare(b.distFloat, a.distFloat);
      }
    });
    distAsc = !distAsc;
    
  } else if (sortBy.equals("LATENESS")) {
    Collections.sort(displayedFlights, new Comparator<Flight>() {
      public int compare(Flight a, Flight b) {
        return lateDesc ? Integer.compare(b.getLateness(), a.getLateness()) : Integer.compare(a.getLateness(), b.getLateness());
      }
    });
    lateDesc = !lateDesc;
  }
}

// SCREEN 0: FLIGHT LIST

void drawFlightListScreen() {
  textAlign(LEFT, BASELINE);

  // Use a matrix to shift the coordinate system based on user scroll
  pushMatrix();
  translate(0, scrollY);

  textSize(12);
  for (int i = 0; i < displayedFlights.size(); i++) {
    Flight f = displayedFlights.get(i);
    float y = 130 + (i * itemHeight);

//  Only draw rows that are visible on the screen
    if (y + scrollY > -itemHeight && y + scrollY < height) {
      
      // Row color logic
      if (f.Cancelled.startsWith("1")) fill(255, 80, 80);        // Red for cancelled
      else if (f.Diverted.startsWith("1")) fill(255, 180, 80);   // Orange for diverted
      else if (i % 2 == 0) fill(240);                            // Alternating gray
      else fill(220);                                            // Alternating light gray

      rect(0, y - 15, width, itemHeight);

      // Draw the text
      fill(0);
      f.display(int(y));
    }
  }
  popMatrix();

  // Draw header background to hide scrolling rows underneath
  fill(0);
  noStroke();
  rect(0, 0, width, 110);

  // Draw Column Headers
  fill(255, 200, 0);
  textSize(14);
  text("AIRLINE ⇕", 10, 100);
  text("DATE", 95, 100);
  text("ORIGIN ⇕", 170, 100);
  text("O.ST", 255, 100);
  text("DEST CITY", 300, 100);
  text("D.ST", 470, 100);
  text("DEP ⇕", 520, 100);
  text("ARR", 580, 100);
  text("DIST ⇕", 635, 100);
  text("DIV", 710, 100);
  text("CANC", 760, 100);
  text("LATE ⇕", 840, 100);

  // Header separator line
  stroke(255);
  line(10, 110, width - 10, 110);
}

//   SCREEN 1: DESTINATION PIE CHART

void drawChartScreen() {
  background(255);
  drawPieChart();

  // Display what is currently being filtered
  fill(0);
  textSize(16);
  textAlign(LEFT);
  text("Filtering by: " + (searchQuery.equals("") ? "All Flights" : searchQuery), 10, 95);
}

void drawPieChart() {
  // Aggregate flight counts by destination state
  HashMap<String, Integer> stateCount = new HashMap<String, Integer>();

  for (int i = 0; i < displayedFlights.size(); i++) {
    Flight f = displayedFlights.get(i);
    String state = f.destination;
    if (stateCount.containsKey(state)) {
      stateCount.put(state, stateCount.get(state) + 1);
    } else {
      stateCount.put(state, 1);
    }
  }

  // Move map entries to a list for sorting
  ArrayList<Map.Entry<String, Integer>> sortedList =
    new ArrayList<Map.Entry<String, Integer>>(stateCount.entrySet());

  // Sort descending by value (flight count)
  Collections.sort(sortedList, new Comparator<Map.Entry<String, Integer>>() {
    public int compare(Map.Entry<String, Integer> a, Map.Entry<String, Integer> b) {
      return b.getValue() - a.getValue();
    }
  });

  // Only graph the top 20 to prevent overcrowding
  int limit = min(20, sortedList.size());
  float total = 0;
  for (int i = 0; i < limit; i++) {
    total += sortedList.get(i).getValue();
  }
  
  if (total == 0) return;

  float angleStart = 0;
  noStroke();
  textAlign(CENTER, CENTER);
  textSize(14);

  // Draw the slices
  for (int i = 0; i < limit; i++) {
    String state = sortedList.get(i).getKey();
    float count = sortedList.get(i).getValue();
    float angle = (count / total) * TWO_PI;

    // Procedural color generation
    fill((i * 50) % 255, (i * 80) % 255, (i * 110) % 255);
    arc(width/2, 360, 320, 320, angleStart, angleStart + angle, PIE);

    // Calculate midpoint of the slice to place text labels
    float mid = angleStart + angle/2;
    float x = width/2 + cos(mid) * 165;
    float y = 360 + sin(mid) * 165;

    fill(20);
    text(state, x, y);

    angleStart += angle;
  }
}

//   SCREEN 2: HOURLY DEPARTURE BAR CHART

void countFlightsByHour() {
  // Reset array
  for (int i = 0; i < 24; i++) hourlyCounts[i] = 0;

  // Aggregate current view counts
  for (int i = 0; i < displayedFlights.size(); i++) {
    int hour = displayedFlights.get(i).getDepartureHour();
    if (hour != -1) hourlyCounts[hour]++;
  }
}

void drawHourlyChart() {
  int chartX = 60;
  int chartY = 560;
  int chartHeight = 320;
  int barWidth = 26;
  int gap = 8;

  // Find peak hour to scale chart properly
  int maxCount = 0;
  for (int i = 0; i < 24; i++) {
    if (hourlyCounts[i] > maxCount) maxCount = hourlyCounts[i];
  }
  if (maxCount == 0) maxCount = 1; // Prevent div by zero

  fill(255);
  textSize(16);
  textAlign(LEFT);
  text("Filtering by: " + (searchQuery.equals("") ? "All Flights" : searchQuery), 10, 95);

  // Draw chart axes
  stroke(255);
  line(chartX, chartY, chartX, chartY - chartHeight);
  line(chartX, chartY, chartX + 24 * (barWidth + gap), chartY);

  for (int i = 0; i < 24; i++) {
    // Map count to a pixel height
    float barHeight = map(hourlyCounts[i], 0, maxCount, 0, chartHeight);
    int x = chartX + i * (barWidth + gap);
    float y = chartY - barHeight;

    // Detect if mouse is over this specific bar
    boolean hovering = mouseX >= x && mouseX <= x + barWidth && mouseY >= y && mouseY <= chartY;

    if (hovering) fill(255, 180, 0); // Highlight color
    else fill(0, 200, 255);          // Normal bar color

    rect(x, y, barWidth, barHeight);

    // X-axis label (Hour 0-23)
    fill(255);
    textAlign(CENTER);
    text(i, x + barWidth/2, chartY + 16);

    // Show the actual count value above the bar if hovered
    if (hovering) {
      fill(255);
      textSize(13);
      text(hourlyCounts[i], x + barWidth/2, y - 10);
      textSize(16); // Reset text size for next elements
    }
  }

  fill(255);
  textSize(18);
  textAlign(LEFT);
  text("Flights by Departure Hour", chartX, chartY - chartHeight - 20);
}

//   UI CONTROLS & OVERLAYS

void drawNavigationOverlay() {
  // Top controls background
  fill(0);
  noStroke();
  rect(0, 0, width, 80);

  // Search Bar
  fill(255);
  textSize(16);
  textAlign(LEFT, BASELINE);
  String cursor = (frameCount / 30 % 2 == 0) ? "_" : ""; // Blinking cursor
  text("Search (airline/origin/etc, dep1234, arr1234, date range d:1-5): " + searchQuery + cursor, 10, 25);
  stroke(100);
  line(10, 35, width - 10, 35);

  // Filter Buttons
  noStroke();
  
  if (showOnlyCancelled) fill(255, 100, 100); else fill(100);
  rect(10, 45, 140, 25, 5);
  fill(255); textSize(12); text("Only Cancelled", 22, 62);

  if (showOnlyDiverted) fill(100, 100, 255); else fill(100);
  rect(160, 45, 140, 25, 5);
  fill(255); text("Only Diverted", 175, 62);

  fill(90, 170, 90);
  rect(310, 45, 140, 25, 5);
  fill(255); text("Sort by Lateness", 323, 62);

  // Bottom Navigation Bar
  fill(0, 200);
  noStroke();
  rect(0, height - 30, width, 30);
  fill(255);
  textSize(14);
  text(",: Flight List | .: Destination Chart | /: Hourly Chart", 10, height - 10);
}

//   INPUT HANDLING (Mouse & Keyboard)

void mousePressed() {
  // 1. Global top buttons (Available on all screens)
  if (mouseY > 45 && mouseY < 70) {
    if (mouseX > 10 && mouseX < 150) {
      showOnlyCancelled = !showOnlyCancelled;
      filterFlights();
      return;
    } else if (mouseX > 160 && mouseX < 300) {
      showOnlyDiverted = !showOnlyDiverted;
      filterFlights();
      return;
    } else if (mouseX > 310 && mouseX < 450) {
      sortFlights("LATENESS");
      return;
    }
  }

  // 2. List header sorting 
  if (currentScreen == 0 && mouseY > 85 && mouseY < 110) {
    if (mouseX > 10 && mouseX < 90) sortFlights("AIRLINE");
    else if (mouseX > 170 && mouseX < 250) sortFlights("ORIGIN");
    else if (mouseX > 520 && mouseX < 575) sortFlights("DEP");
    else if (mouseX > 635 && mouseX < 700) sortFlights("DIST");
    else if (mouseX > 840 && mouseX < 920) sortFlights("LATENESS");
  }
}

void keyPressed() {
  // Screen switching
  if (key == ',') currentScreen = 0;
  else if (key == '.') currentScreen = 1;
  else if (key == '/') currentScreen = 2;
  
  // Search text logic
  else if (key == BACKSPACE) {
    if (searchQuery.length() > 0) {
      searchQuery = searchQuery.substring(0, searchQuery.length() - 1);
      filterFlights();
    }
  } 
  // Add allowed characters to search query (letters, numbers, space, colon, hyphen)
  else if (key != CODED && key != ENTER && key != RETURN && key != ESC && key != TAB) {
    if (String.valueOf(key).matches("[a-zA-Z0-9 :\\-]")) {
      searchQuery += key;
      filterFlights();
    }
  }
}

void mouseWheel(MouseEvent event) {
  // Only scroll on the list screen
  if (currentScreen == 0) {
    float e = event.getCount();
    scrollY -= e * scrollSpeed;

    // Prevent scrolling past the bottom of the list
    float maxScroll = -((displayedFlights.size() * itemHeight) - height + 150);
    if (maxScroll > 0) maxScroll = 0;

    scrollY = constrain(scrollY, maxScroll, 0);
  }
}

//   FLIGHT DATA CLASS

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

  // Cached lowercase strings dramatically speed up the text search
  String airlineCodeLower;
  String originLower;
  String destinationLower;
  String destinationCityLower;
  String originStateLower;

  // Cached numeric values speed up sorting and date filtering
  int dayOfMonth = 1;
  int depInt = 9999;
  float distFloat = 0;

  Flight(
    String fDate, String aCode, String orig, String dest,
    String oState, String dCity, String dState,
    String crsDep, String dTime, String aTime, String dist,
    String div, String canc
    ) {
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

    airlineCodeLower = airlineCode.toLowerCase();
    originLower = origin.toLowerCase();
    destinationLower = destination.toLowerCase();
    destinationCityLower = destinationCityName.toLowerCase();
    originStateLower = originState.toLowerCase();

    // Handles various formats like MM/DD/YYYY
    try {
      String datePart = flightDate.split(" ")[0]; // Get the "MM/DD/YYYY" part
      String[] dParts = datePart.split("/");      // Split by slashes
      if (dParts.length >= 2) {
        dayOfMonth = Integer.parseInt(dParts[1]); // Grab the DD part regardless of format length
      }
    } catch(Exception e) {
      dayOfMonth = 1;
    }

    // Pre-parse integers/floats for sorting
    try {
      if (DepTime != null && DepTime.length() > 0) depInt = Integer.parseInt(DepTime);
    } catch(Exception e) {
      depInt = 9999; // Fallback for invalid/empty
    }

    try {
      if (Distance != null && Distance.length() > 0) distFloat = Float.parseFloat(Distance);
    } catch(Exception e) {
      distFloat = 0;
    }
  }

  // Returns hour block for the hourly chart (e.g., 1405 returns 14)
  int getDepartureHour() {
    if (depInt == 9999) return -1;
    int hour = depInt / 100;
    if (hour >= 0 && hour < 24) return hour;
    return -1;
  }

  // Determines how many minutes late the flight left compared to scheduled
  int getLateness() {
    // If it lacks times or was cancelled, it has no meaningful lateness
    if (DepTime.equals("") || crsDepTime.equals("") || Cancelled.startsWith("1")) return -9999;
    
    try {
      int dep = Integer.parseInt(DepTime);
      int crs = Integer.parseInt(crsDepTime);

      // Convert HHMM format into total minutes since start of day
      int depMin = (dep / 100) * 60 + (dep % 100);
      int crsMin = (crs / 100) * 60 + (crs % 100);

      int diff = depMin - crsMin;

      // Handle flights crossing midnight (e.g., Scheduled 23:50, Leaves 00:20)
      if (diff < -720) diff += 1440;
      if (diff > 720) diff -= 1440;

      return diff;
    } catch (Exception e) {
      return -9999;
    }
  }

  // Renders the single row for this flight in the List Screen
  void display(int y) {
    fill(0);
    text(airlineCode, 10, y);
    text(flightDate.split(" ")[0], 95, y);
    text(origin, 170, y);
    text(originState, 255, y);

    text(destinationCityName.replace("\"", ""), 300, y);
    text(destinationState, 470, y);
    text(DepTime, 520, y);
    text(ArrTime, 580, y);
    text(Distance, 635, y);

    if (Diverted.startsWith("1")) text("DIV", 710, y);
    else text("", 710, y);

    if (Cancelled.startsWith("1")) text("CANC", 760, y);
    else text("", 760, y);

    // Calculate and display lateness with color coding
    int late = getLateness();
    if (late != -9999) {
      if (late > 0) fill(200, 40, 40); // Red if late
      else fill(40, 140, 40);          // Green if early/on-time
      text(late + "m", 840, y);
    }
  }
}
