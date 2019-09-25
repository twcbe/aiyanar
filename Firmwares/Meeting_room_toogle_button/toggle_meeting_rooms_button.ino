
#include <ESP8266WiFi.h>
#include <PubSubClient.h>

const char* ssid = "iot";
const char* password = "trip MIND part BASE port";
const char* mqttServer = "10.137.140.10";
const char* payload = "pressed";

WiFiClient espClient;
PubSubClient client(espClient);

int BUTTON_PIN = 5;
int buttonState=HIGH;
int lastButtonState=HIGH;

unsigned long lastDebounceTime = 0;
unsigned long debounceDelay = 50;

void setupWifi() {
  Serial.println();
  Serial.print("Connecting to ");
  Serial.println(ssid);
  WiFi.begin(ssid, password);

  int tries = 0;
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
    tries++;
    if (tries>20) {
      Serial.print("Connection failed. Rebooting...");
      ESP.restart();
    }
  }

  Serial.println();
  Serial.println("WiFi connected");
  Serial.println("IP address: ");
  Serial.println(WiFi.localIP());
}

void reconnect()
{
  while(!client.connected()){
    Serial.println("Attempting MQTT connection");
    if(client.connect("MeetingRoomButton")){
      client.subscribe("button/1");
      Serial.println("MQTT connected");         
    }
    else {
       Serial.print("failed, rc=");
      Serial.print(client.state());
      Serial.println(" trying again in 2 seconds");
      delay(2000);
    }
  }
}

void setup() {
     Serial.begin(115200);
     pinMode(BUTTON_PIN,INPUT_PULLUP);
     setupWifi();
     client.setServer(mqttServer, 1883);
}

void loop() {
  if (!client.connected()) {
    Serial.println("MQTT not connected");
    reconnect();
  }
  client.loop();
   int reading = digitalRead(BUTTON_PIN);
   if (reading != lastButtonState) {
    lastDebounceTime = millis();
  }
  
  if ((millis() - lastDebounceTime) > debounceDelay) {
    if (reading != buttonState) {
      buttonState = reading;
       if (buttonState == HIGH) {
         Serial.println(payload);
         client.publish("button/1",payload);
      }
    }
  }
   lastButtonState = reading;
}
