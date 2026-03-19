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
    if (columns.length < 19) continue;
    

    flightDate = columns[0];
    airlineCode = columns[1];
    airline = columns[2];
    origin = columns[3];
    originState = columns[6];
    originWAC = columns[7];
    destination = columns[8];
    destinationCityName = columns[9];
    destinationState = columns[10];
    destinationWAC = columns[12];
    crsDepTime = columns[13];
    DepTime = columns[14];
    CRSArrTime = columns[15];
    ArrTime = columns[16];
    Cancelled = columns[17];
    Diverted = columns[18];
    Distance = columns[19];
    
    Flight f = new Flight(
    flightDate, airlineCode, airline,origin, originState, originWAC,destination,
    destinationCityName, destinationState, destinationWAC, crsDepTime, DepTime,
    CRSArrTime, ArrTime, Cancelled, Diverted, Distance);
    flights.add(f);
  }
  
  println("Flights loaded: "+flights.size());
  println("Date: " + flightDate);
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
  println("Distance Between Airports" + Distance);
}



void draw() {
  background(200);
  
  

  
  pushMatrix();
  translate(0, scrollY);  // Apply scroll offset
  
  fill(255);
  

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
  
  //Display header
  fill(200, 200, 200);
  noStroke();
  rect(0, 0, width, 20);
  
  fill(200, 200,0);
  textSize(12);
  text("AIRLINE", 20, 10);
  text("DATE", 120, 10);
  text("ORIGIN", 180, 10);
  text("STATE", 230, 10);
  text("DESTINATION", 280, 10);
  text("STATE", 370, 10);
  text("DEP TIME", 500, 10);
  text("ARR TIME", 560, 10);
  text("DISTANCE", 610, 10);
  text("DIVERTED", 670, 10);
  text("CANCELLED", 730, 10);
  

}

class Flight {

  String flightDate;     
  String airlineCode;        
  String airline;            
  String origin;          
  String originState;        
  String originWAC;          
  String destination;        
  String destinationCityName;
  String destinationState;   
  String destinationWAC;     
  String crsDepTime;         
  String depTime;            
  String CRSArrTime;         
  String arrTime;            
  String cancelled;          
  String diverted;           
  String distance;        
  

  Flight(String fDate, String aCode, String airl, String orig,
   String origState, String origWAC, String dest, String destC, String destS,
   String destWAC, String crsDep, String depT, String crsArr, String arrT,
   String cancel, String divert, String dist) {
    flightDate = fDate;
    airlineCode = aCode;
    airline = airl;
    origin = orig;
    originState = origState;
    originWAC = origWAC;
    destination = dest;
    destinationCityName = destC;
    destinationState = destS;
    destinationWAC = destWAC;
    crsDepTime = crsDep;
    depTime = depT;
    CRSArrTime = crsArr;
    arrTime = arrT;
    cancelled = cancel;
    diverted = divert;
    distance = dist;
  }

  void display(int y) {
    text(flightDate,100,y);
    text(airlineCode, 20,y);
    text(origin,200,y);
    text(originState, 230, y);
    text(destinationCityName,270,y);
    text(destinationState, 370, y);
    text(depTime, 520, y);
    text(arrTime, 570, y);
    text(distance, 620, y);
    
    //Diverted and canceled are 1 in the file
    if(diverted == "1"){text("yes", 690, y);}
    else{text("no", 690, y);}
    if(cancelled == "1"){text("yes", 750, y);}
    else{text("no", 750, y);}
  }
}

void mouseWheel(MouseEvent event) {
  // Controls scrolling
  float e = event.getCount();
  scrollY -= e * scrollSpeed;
  
  // Prevent scrolling beyond content bounds
  float maxScroll = -((flights.size() * itemHeight) - height + 50);
  scrollY = constrain(scrollY, maxScroll, 0);
}
