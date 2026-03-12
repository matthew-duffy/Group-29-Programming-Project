String lines[];
Flight flights[];

void setup() {
    String flightDate= "";
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

  lines = loadStrings("flights.csv");

  for (int i = 1; i < lines.length; i++) {

    String[] columns = split(lines[i], ',');

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

}

public class Flight{
  ArrayList<Flight> data;

    Flight(ArrayList<Flight> data){
        this.data = data;
    }

}

