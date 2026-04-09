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



String lines[];

ArrayList<GlobalAirportData> airportData = new ArrayList<GlobalAirportData>();



//marker list(airoports)
ArrayList<SimplePointMarker> airportMarkers = new ArrayList<SimplePointMarker>();


//put new parts in original setup 
void setup() {
  size(800, 600);
  

  
  map = new UnfoldingMap(this, new Microsoft.AerialProvider());
  
  
  //makes it possible to interract
  MapUtils.createDefaultEventDispatcher(this, map);
  
  
  
  
  
  
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

  
/*
//!!!!!!!!!!
 //hand drawn markers
  for(int i = 0; i < airportData.size(); i++){
    GlobalAirportData airport = airportData.get(i);
    Location loc = new Location(airport.getLatitude(), airport.getLongitude());
    ScreenPosition pos = map.getScreenPosition(loc);

    // Only draw if position is on screen
    if (pos.x >= 0 && pos.x <= width && pos.y >= 0 && pos.y <= height) {
      ellipse(pos.x, pos.y, 8, 8);
    }
  }
  
  */
  
  map.draw();
  



}

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


///class GlobalAiroportData
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
  
    airportData.add(data);//Adds all this data into airoportData
  }
}
