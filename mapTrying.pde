import processing.core.PApplet;
import de.fhpotsdam.unfolding.mapdisplay.*;
import de.fhpotsdam.unfolding.utils.*;
import de.fhpotsdam.unfolding.marker.*;
import de.fhpotsdam.unfolding.interactions.*;
import de.fhpotsdam.unfolding.*;
import de.fhpotsdam.unfolding.geo.*;
import de.fhpotsdam.utils.*;
import de.fhpotsdam.unfolding.providers.*;
import controlP5.*;
import java.util.*;

//input search bar prep
UnfoldingMap map;

ControlP5 cp5;
String inputCode = "";

String lines[];

//WHEN CONNECTED TO REAL CODE THIS WILL BE AMMENDED!!(FLIGHTS)
ArrayList<Flight> flights = new ArrayList<Flight>();
ArrayList<GlobalAirportData> airportData = new ArrayList<GlobalAirportData>();

ArrayList<String> codes = new ArrayList<String>(); // Maybe temp thing

//marker list(airoports)
ArrayList<SimplePointMarker> airportMarkers = new ArrayList<SimplePointMarker>();


String flightDate = "";         
String airlineCode = "";        
String airline = "";            
String origin = "";             
String originState = "";        
String originWAC = "";          
String destination = "";        
String destCity = "";
String destinationState = "";   
String destinationWAC = "";     
String crsDepTime = "";         
String DepTime = "";            
String CRSArrTime = "";         
String ArrTime = "";            
String Cancelled = "";          
String Diverted = "";           
String Distance = "";           


//put new parts in original setup 
void setup() {
  size(800, 600);
  
  //search bar set up
  //cp5 = new ControlP5(this);

  //cp5.addTextfield("countryInput")
  //   .setPosition(20, 20)
  //   .setSize(150, 30)
  //   .setAutoClear(false);
   ///
  
  map = new UnfoldingMap(this, new Microsoft.AerialProvider());
  
  MapUtils.createDefaultEventDispatcher(this, map);
  
  
  
  
  flights = new ArrayList<Flight>();

  lines = loadStrings("flights2k.csv");
  for (int i = 1; i <= lines.length - 1; i++) {
    String[] quoteSplit = split(lines[i], '"');  // Removing quotes from the data, so we can keep comma in originCity and destCity.
    String originCity = quoteSplit[1];
    destCity   = quoteSplit[3];

    String[] commaSplit = split(lines[i], ",");  // Than removing commas. Note that we're ignoring 4,5, 9 and 10 because of the manipulations above.
  ///Flight(String fDate, String aCode, 
  ///String orig, String dest, String oState, String dCity, 
  ///String dState, String crsDep, String dTime, String aTime, 
  ///String dist, String div, String canc)
    flightDate = commaSplit[0];
    airlineCode = commaSplit[1];
    airline = commaSplit[2];
    origin = commaSplit[3];
    // columns[4] is Origin City Name
    originState = commaSplit[6];
    // columns[6] is Origin WAC
    destination = commaSplit[8];
    destinationState = commaSplit[11];
    // columns[10] is Destination WAC
    crsDepTime = commaSplit[13];
    DepTime = commaSplit[14];
    // columns[13] is CRS Arr Time
    ArrTime = commaSplit[16];
    Cancelled = commaSplit[17];
    Diverted = commaSplit[18];
    Distance = commaSplit[19];
    
    // Pass ALL needed variables into the Flight object
    Flight f = new Flight(flightDate, airlineCode, origin, destination, 
    originState, destCity, destinationState, crsDepTime, 
    DepTime, ArrTime, Distance, Diverted, Cancelled);
    flights.add(f);
    
  }
  
  // Load Global Airport Data from txt
  GlobalAirportData();
  // MARKERS (all)
  for(int i = 0; i < airportData.size() - 1; i++){
        Location loc = new Location(
        airportData.get(i).getLatitude(),
        airportData.get(i).getLongitude()
        );
        // Create point markers for locations
        println(airportData.get(i).getLatitude(), airportData.get(i).getLongitude());

        SimplePointMarker marker = new SimplePointMarker(loc);
        //Making the marker smaller
        marker.setRadius(3.0f);
        // Add markers to the map
        airportMarkers.add(marker);
        map.addMarker(marker);
        println("Markers added: " + airportMarkers.size());
  }
  /*
  ///Filtered markers based on data set
  for(int i = 1; i < airportData.size() - 1; i++){
    //for(int j = 0; j < airportData.size(); j++) {
      //if(codes.get(i).equals(airportData.get(j).getOrigin())){
        println(airportData.get(i).getLatitude(), airportData.get(i).getLongitude());
        Location airportsLocations = new Location(airportData.get(i).getLatitude(), airportData.get(i).getLongitude());
        // Create point markers for locations
        SimplePointMarker airportMarker = new SimplePointMarker(airportsLocations);
        //Making the marker smaller
        airportMarker.setRadius(3.0f);
        // Add markers to the map
        map.addMarkers(airportMarker);
        
      }
    //}
 // }
    //flights.get(3).printFlights();
  */
  
}



///Put new parts in main draw!!
void draw() {
  
  background(230);
  
  //map.zoomLevelOut();
  //map.zoomLevelIn();
  //map.zoomIn();
  //map.zoomOut();
  
  

  //clip(190, 0, width - 190 - 300, height);
  map.draw();
 
  
  //noClip();

  //noStroke();
  //fill(230);
  /*
  rect(0, 0, 190, height);
  rect(width - 300, 0, 300, height);
*/

}

///function for detecting when user types
/*void countryInput(String text){
 inputCode = text.toUpperCase();*/
 //filterAirports();
  

/*
//filtering
void filterAirports(){
  map.getMarkers().clear();
  
  for(int i=0;i<airportData.size(); i++){
    GlobalAirportData airport = airportData.get(i);
    
    //check if airportcode matches input
    if(airport.getCountry().toUpperCase().contains(inputCode)){
    
    Location loc = new Location(
    airport.getLatitude(),
    airport.getLongitude());
    
    SimplePointMarker marker = new SimplePointMarker(loc);
    marker.setRadius(3.0f);
    map.addMarker(marker);
  }
  
}
}*/


///class GlobalAiroportData,  2ND SECTION
class GlobalAirportData{
    private String Origin;
    private String AirportName;
    private float TotalSeats;
    private String Country;
    private float Latitude;
    private float Longitude;
    
    GlobalAirportData(String Origin, String AirportName, float TotalSeats, String Country, float Latitude, float Longitude){
      this.Origin = Origin;
      this.AirportName = AirportName;
      this.TotalSeats = TotalSeats;
      this.Country = Country;
      this.Latitude = Latitude;
      this.Longitude = Longitude;
    }
    
    //GETERS
    String  getOrigin()        {  return this.Origin;        }
    String  getAirportName()   {  return this.AirportName;   }
    float   getTotalSeats()    {  return this.TotalSeats;    }
    String  getCountry()       {  return this.Country;       }
    float   getLatitude()      {  return this.Latitude;      }
    float   getLongitude()     {  return this.Longitude;     }
    
    //We dont need to write setters because we're setting those data from the file.
}

void GlobalAirportData() {
  String[] lines = loadStrings("airport_volume_airport_locations.csv");
  if (lines == null || lines.length <= 1) return;
  
  for (int i = 1; i <= lines.length - 1; i++) {
    String[] commmaSplit = split(lines[i], ',');  // Removing quotes from the data, so we can keep comma in originCity and destCity.
    
    String Origin = commmaSplit[0];
    String AirportName = commmaSplit[1];
    float TotalSeats = Float.parseFloat(commmaSplit[2]);
    String Country = commmaSplit[3];
    float Latitude = Float.parseFloat(commmaSplit[4]);
    float Longitude = Float.parseFloat(commmaSplit[5]);
    
    GlobalAirportData data = new GlobalAirportData(Origin, AirportName, TotalSeats, Country, Latitude, Longitude);
  
    airportData.add(data);
  }
}

//flights info delete after


// Flight class, represents a singular flight
// Class was written by Andrew
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
  
  void printFlights() {
       println("flightDate: " + this.flightDate);
       println("airlineCode: " + this.airlineCode);
       println("origin: " + this.origin);
       println("destination: " + this.destination);
       println("originState: " + this.originState);
       println("destinationCityName: " + this.destinationCityName);
       println("destinationState: " + this.destinationState);
       println("crsDepTime: " + this.crsDepTime);
       println("DepTime: " + this.DepTime);
       println("ArrTime: " + this.ArrTime);
       println("Distance: " + this.Distance);
       println("Diverted: " + this.Diverted);
       println("Cancelled: " + this.Cancelled);
    }
}
