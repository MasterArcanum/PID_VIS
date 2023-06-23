import controlP5.*;
import java.util.ArrayList;
import controlP5.Textfield;

// PID parameters
String Kp = "0.9";
String Ki = "0.1";
String Kd = "0.1";

float SP = 15;  // Set point
float PV = 5;  // Process value

// Error values
float integral = 0;
float prevError = 0;

// Time variables
float dt;
float prevTime;

// PID status
boolean pidEnabled = false;
float enableTime = 1;  // Enable PID at this time
float disableTime = 500;  // Disable PID at this time

// Lists to store the graph values
ArrayList<Float> spList = new ArrayList<Float>();
ArrayList<Float> pvList = new ArrayList<Float>();
ArrayList<Float> outList = new ArrayList<Float>();

class Button {
  int x, y, w, h;

  Button(int x, int y, int w, int h) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
  }

  boolean isPressed(int mouseX, int mouseY) {
    return mouseX > x && mouseX < x + w && mouseY > y && mouseY < y + h;
  }

  void draw() {
    fill(200);
    rect(x, y, w, h);
    fill(0);
    text("Change SP", x + 10, y + h / 2);
  }
}

Button button;
ControlP5 cp5;

void setup() {
  size(1400, 900);
  prevTime = millis() / 1000.0;
  button = new Button(width - 100, height - 50, 90, 40);

  cp5 = new ControlP5(this);
 
   cp5.addTextfield("Kp")
   .setPosition(10,10)
   .setSize(70,30)
   .setText((Kp))
   .onRelease(e -> Kp = e.getController().<Textfield>getStringValue().trim());


cp5.addTextfield("Ki")
   .setPosition(90,10)
   .setSize(70,30)
   .setText((Ki))
   .onRelease(e -> Ki = e.getController().<Textfield>getStringValue().trim());

  
cp5.addTextfield("Kd")
   .setPosition(170,10)
   .setSize(70,30)
   .setText((Kd))
   .onRelease(e -> Kd = e.getController().<Textfield>getStringValue().trim());

  // Добавление области для вывода значений параметров
  cp5.addTextlabel("labelKp")
     .setText("Kp: " + Kp)
     .setPosition(10, 50)
     .setFont(createFont("Arial", 14))
     .setColor(color(0));

  cp5.addTextlabel("labelKi")
     .setText("Ki: " + Ki)
     .setPosition(90, 50)
     .setFont(createFont("Arial", 14))
     .setColor(color(0));

  cp5.addTextlabel("labelKd")
     .setText("Kd: " + Kd)
     .setPosition(170, 50)
     .setFont(createFont("Arial", 14))
     .setColor(color(0));
}

void draw() {
  // Calculate elapsed time
  float currentTime = millis() / 1000.0;
  dt = currentTime - prevTime;
  prevTime = currentTime;

  // Enable/disable PID at specific times
  if (currentTime > enableTime && currentTime < disableTime) {
    pidEnabled = true;
  } else {
    pidEnabled = false;
  }

  // PID control
  float error = SP - PV;
  integral += error * dt;
  float derivative = (error - prevError) / dt;
  float output = pidEnabled ? Float.parseFloat(Kp) * error + Float.parseFloat(Ki) * integral + Float.parseFloat(Kd) * derivative : 0;

  prevError = error;

  // Update process value (with some artificial damping)
  PV += output * dt - 0.1 * PV * dt;

  // Store the values
  if (frameCount % 1 == 0) {  // Change the number for different speed
    spList.add(SP);
    pvList.add(PV);
    outList.add(output);

    if (spList.size() > width) {
      spList.remove(0);
      pvList.remove(0);
      outList.remove(0);
    }
  }

  // Clear the screen
  background(255);

  // Draw the graphs
  strokeWeight(2); // make the line thicker
  for (int i = 1; i < spList.size(); i++) {
    stroke(255, 0, 0);
    line(i - 1, map(spList.get(i - 1), -10, 20, height, 0), i, map(spList.get(i), -10, 20, height, 0));

    stroke(0, 0, 255);  // Set the stroke color to blue for PV
    line(i - 1, map(pvList.get(i - 1), -10, 20, height, 0), i, map(pvList.get(i), -10, 20, height, 0));

    stroke(0, 255, 0);
    line(i - 1, map(outList.get(i - 1), -10, 20, height, 0), i, map(outList.get(i), -10, 20, height, 0));
  }

  // Draw PID on/off lines
  stroke(0);
  line(enableTime * 100, 0, enableTime * 100, height);
  line(disableTime * 100, 0, disableTime * 100, height);

  // Draw the button
  button.draw();

  // Draw labels
  fill(0);
  text("Time (s)", width / 2, height - 20);
  if (spList.size() > 0) text("Задание (red): " + nf(spList.get(spList.size() - 1), 0, 2), 10, height - 30);
  if (pvList.size() > 0) text("Обратная связь (blue): " + nf(pvList.get(pvList.size() - 1), 0, 2), 10, height - 20);
  if (outList.size() > 0) text("Выход регулятора (green): " + nf(outList.get(outList.size() - 1), 0, 2), 10, height - 10);
  strokeWeight(1);

  // Обновление значений параметров на экране
  cp5.get(Textlabel.class, "labelKp").setText("Kp: " + Kp);
  cp5.get(Textlabel.class, "labelKi").setText("Ki: " + Ki);
  cp5.get(Textlabel.class, "labelKd").setText("Kd: " + Kd);
}

void mousePressed() {
  if (button.isPressed(mouseX, mouseY)) {
    if (mouseButton == LEFT) {
      SP++;
    } else if (mouseButton == RIGHT) {
      SP--;
    }
  }
}
