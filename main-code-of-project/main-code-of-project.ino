#include <Wire.h>
#include <ESP8266WiFi.h>
#include <ESP8266WebServer.h>
#include <ESP8266WiFi.h>
#include <WiFiClient.h>
#include <ESP8266WiFi.h>
#include <OneWire.h>
#include <FirebaseESP8266.h>
#define FIREBASE_HOST "tankwater-78fb6-default-rtdb.asia-southeast1.firebasedatabase.app"
#define FIREBASE_AUTH "2hQyKxiXIEwsBCyVSmc4lav86t8pXtEymx5PO4U3"
const char* ssid = "NC_LINK_Wireless";
const char* password = "bikash54321";
FirebaseData firebaseData;

#define trigPin D0
#define echoPin D1
#define motor1Pin D2
#define motor2Pin D3
#define moisturePin A0

int heightOfTank;
int MaxLevel;
int MinLevel;

int Level0;
int Level1;
int Level2;
int Level3;
int Level4;
int Level5;
int moisturelevel;

long duration;
int distance;


void setup() {
  Serial.begin(9600);
  pinMode(trigPin, OUTPUT);
  pinMode(echoPin, INPUT);
  pinMode(motor1Pin, OUTPUT);
  pinMode(motor2Pin, OUTPUT);
  pinMode(moisturePin, INPUT);

  heightOfTank = getTankHeight();

  Serial.println(heightOfTank);

  MaxLevel = (int)(0.7 * heightOfTank);
  MinLevel = (int)(0.25 * heightOfTank);

  Level0 = 0;
  Level1 = MinLevel;
  Level2 = (int)(heightOfTank * 0.4);
  Level3 = (int)(heightOfTank * 0.6);
  Level4 = MaxLevel;
  Level5 = heightOfTank;

  WiFi.begin(ssid, password);

  while (WiFi.status() != WL_CONNECTED) {
    delay(1000);
    // Serial.println("Connecting to WiFi...");
  }

  Firebase.begin(FIREBASE_HOST, FIREBASE_AUTH);
  Firebase.setString(firebaseData, "SYSTEM/TANK_HEIGHT", String(heightOfTank));
}

void loop() {
  waterLevel();
  moistureLevel();


  delay(500);
}



int getTankHeight() {
  long d = pulseIn(echoPin, HIGH);
  pulseIn(echoPin, LOW);
  return (int)((d / 2) / 29.1);
}

void waterLevel() {
  digitalWrite(trigPin, LOW);
  delayMicroseconds(2);
  digitalWrite(trigPin, HIGH);
  delayMicroseconds(2);
  digitalWrite(trigPin, LOW);
  duration = pulseIn(echoPin, HIGH);
  distance = (duration / 2) / 29.1;
  Serial.print("sitance");
  Serial.println(distance);
  Serial.print("se");
Serial.println(heightOfTank);
  float waterLel = float (heightOfTank - distance) / float (heightOfTank) ;
  Serial.println(waterLel);
  Firebase.setString(firebaseData, "SYSTEM/WATER_LEVEL", String(waterLel));
  
  
  if (distance >= MaxLevel) {
    // Firebase.setString(firebaseData, "SYSTEM/WATER_LEVEL", String(distance));
    digitalWrite(motor1Pin, LOW);
    Firebase.setString(firebaseData, "SYSTEM/TANK_MOTOR", "1");
   Serial.println(distance);

  } else if (distance <= MinLevel) {
    
    // Firebase.setString(firebaseData, "SYSTEM/WATER_LEVEL", String();
    digitalWrite(motor1Pin, HIGH);
    Firebase.setString(firebaseData, "SYSTEM/TANK_MOTOR", "0");
   Serial.println(distance);
  } 

}


void moistureLevel() {
  moisturelevel = analogRead(moisturePin);
 Serial.println("moistureLevel =");

 Serial.println(moisturelevel);
  int mappedmoisturelevel=map(moisturelevel, 550, 1024, 0, 255);
  float m=float(mappedmoisturelevel)/255;
 Serial.println(m);
 Firebase.setString(firebaseData, "SYSTEM/MOISTURE_LEVEL", String(1-m));


  if (moisturelevel < 1000) {
    Serial.println("watering motor off");
    // Firebase.setString(firebaseData, "SYSTEM/MOISTURE_LEVEL", String(moisturelevel));
    Firebase.setString(firebaseData, "SYSTEM/WATERING_MOTOR", "0");
    digitalWrite(motor2Pin, HIGH);

  } else {
    Serial.println("watering motor on");
    // Firebase.setString(firebaseData, "SYSTEM/MOISTURE_LEVEL", String(moisturelevel));
    Firebase.setString(firebaseData, "SYSTEM/WATERING_MOTOR", "1");
    digitalWrite(motor2Pin, LOW);
  }
}
