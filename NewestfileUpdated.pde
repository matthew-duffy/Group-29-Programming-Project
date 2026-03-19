String lines[];
ArrayList<Flight> flights;

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
  size(600, 400);

  flights = new ArrayList<Flight>();


  lines = loadStrings("flights.csv");

  for (int i = 1; i < lines.length; i++) {

    String[] columns = split(lines[i], ',');
    if (columns.length < 17) continue;
    
    Flight f = new Flight(
    flightDate, airline,origin,destination);

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
  background(255);
  fill(0);

  for (int i = 0; i < flights.size() && i < 20; i++) {
    Flight f = flights.get(i);
    f.display(30 + i * 20);
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
    text(airlineCode + " | " + origin + " → " + destination, 20, y);
  }
}
