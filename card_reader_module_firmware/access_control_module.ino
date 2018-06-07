#include <ESP8266WiFi.h>
#include <PubSubClient.h>
#include <ArduinoJson.h>
#include <Wiegand.h>

// Update these with values suitable for your network.

#define d0 16
#define d1 5
#define d2 4
#define d3 0
#define d4 2
#define d5 14
#define d6 12
#define d7 13
#define d8 15

const char* ssid = "twguest";
const char* password = "crimson trout rewrite trustable ivy";
const char* mqtt_server = "10.137.120.19";

#define CARD_READER_TOPIC "access_control/card_readers"
#define SERVER_TOPIC "access_control/server"

WIEGAND wg1;
WiFiClient espClient;
PubSubClient client(espClient);
long lastMsg = 0;
char msg[250];

void setup() {
  pinMode(BUILTIN_LED, OUTPUT);     // Initialize the BUILTIN_LED pin as an output
  Serial.begin(115200);
  setup_wifi();
  client.setServer(mqtt_server, 1883);
  client.setCallback(callback);
  wg1.begin(d7, d8);
}

void setup_wifi() {

  delay(10);
  // We start by connecting to a WiFi network
  Serial.println();
  Serial.print("Connecting to ");
  Serial.println(ssid);

  WiFi.begin(ssid, password);

  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }

  Serial.println("");
  Serial.println("WiFi connected");
  Serial.println("IP address: ");
  Serial.println(WiFi.localIP());
}

void callback(char* topic, byte* payload, unsigned int length) {
  Serial.print("Message arrived [");
  Serial.print(topic);
  Serial.print("] ");
  for (int i = 0; i < length; i++) {
    Serial.print((char)payload[i]);
  }
  Serial.println();
}

void reconnect() {
  // Loop until we're reconnected
  while (!client.connected()) {
    Serial.print("Attempting MQTT connection...");
    // Attempt to connect
    if (client.connect("ESP8266Client")) {
      Serial.println("connected");
      // Once connected, publish an announcement...
      client.publish(CARD_READER_TOPIC, "[Main entrance] reconnected");
      // ... and resubscribe
      client.subscribe(SERVER_TOPIC);
    } else {
      Serial.print("failed, rc=");
      Serial.print(client.state());
      Serial.println(" try again in 2 seconds");
      // Wait 2 seconds before retrying
      delay(2000);
    }
  }
}

void publish_message(char *card_number) {
  char payload[250]={};
  String str_buffer;
  DynamicJsonBuffer  jsonBuffer(200);
  JsonObject& root = jsonBuffer.createObject();

  root["message"] = "card_read";
  root["lock_name"] = "Main entrance";
  root["card_number"] = card_number;
  root.printTo(str_buffer);
  str_buffer.toCharArray(payload, sizeof(payload));

  client.publish(CARD_READER_TOPIC, payload);
}

void loop() {
  if (!client.connected()) {
    Serial.println("MQTT not connected");
    reconnect();
  }
  client.loop();
  if (wg1.available()) {
    unsigned long card_number = wg1.getCode();
    char card_number_hex[100]="";
    snprintf(card_number_hex, sizeof(card_number_hex), "%lX", card_number);
    publish_message(card_number_hex);
  }
  delay(100);
}



