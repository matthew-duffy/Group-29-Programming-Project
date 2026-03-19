String lines[];
ArrayList<Flight> flights;
float scrollY = 0;  // Current scroll position
float scrollSpeed = 20;  // How fast to scroll
float itemHeight = 20;  // Height of each flight entry

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
    
    Flight f = new Flight(
    flightDate, airline,origin,destination);
    flights.add(f);
  }
  
  println("Flights loaded: "+flights.size());
  /*println("Date: " + flightDate);
  println("Airline Code " + airlineCode);
  println("FL num: " + airline);
  println("Origin: " + origin);
  println("OriginState: " + originState);
  println("OriginWAC: " + originWAC);
  println("Destination: " + destination);
  println("Destination City: " + destinationCityName);
  println("Destination State: " + destinationState);
  println("Destination WAC: " + destinationWAC);
  println("CRSDepTime: " + crsDepTime);
  println("Actual Departure Time" + DepTime);
  println("Scheduled Arrival Time" + CRSArrTime);
  println("Actual Arrival Time" + ArrTime);
  println("Cancelled" + Cancelled);
  println("Diverted" + Diverted);
  println("Distance Between Airports" + Distance);*/
}



void draw() {
  background(0);
  
  fill(255,200,0);
  textSize(16);
  text("FLIGHT", 50, 40);
  text("TIME", 300, 40);
  text("DESTINATION", 400, 40);
  
  stroke(255);
  line(40, 50, 700, 50);
  
  fill(0,255,0);

  textSize(14);
  
  pushMatrix();
  translate(0, scrollY);  // Apply scroll offset
  
  fill(255);
  textSize(12);

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
    text(airlineCode, 50,y);
    text(flightDate,200,y);
    text(origin,350,y);
    text(destination,400,y);
  }
}

void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  scrollY -= e * scrollSpeed;
  
  // Prevent scrolling beyond content bounds
  float maxScroll = -((flights.size() * itemHeight) - height + 50);
  scrollY = constrain(scrollY, maxScroll, 0);
}

