


void setup() {
  size(800, 600);
  ellipseMode(CENTER);

  
}

void draw() {
  background(255);
  drawPieChart();
}




void drawPieChart() {
 background(255);

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
