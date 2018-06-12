#include <ESP8266WiFi.h>
#include <PubSubClient.h>
#include <ArduinoJson.h>
#include <Wiegand.h>

#define d0 16
#define d1 5
#define d2 4
#define d3 0
#define d4 2
#define d5 14
#define d6 12
#define d7 13
#define d8 15

#define card1Data0 d7
#define card1Data1 d8
#define card1Led   d6
#define card1Beep  d5
#define card2Data0 d3
#define card2Data1 d4
#define card2Led   d2
#define card2Beep  d1
#define lockRelay  d0

#define LOCK_RELAY_DOOR_UNLOCKED LOW
#define LOCK_RELAY_DOOR_LOCKED   HIGH
#define CARD_1_BEEP_OFF          HIGH
#define CARD_1_BEEP_ON           LOW
#define CARD_1_LED_RED           HIGH
#define CARD_1_LED_GREEN         LOW
#define CARD_2_BEEP_OFF          HIGH
#define CARD_2_BEEP_ON           LOW
#define CARD_2_LED_RED           HIGH
#define CARD_2_LED_GREEN         LOW

const char* ssid = "twguest";
const char* password = "crimson trout rewrite trustable ivy";
const char* mqttServer = "10.137.120.19";

#define CARD_READER_TOPIC "access_control/card_readers"
#define SERVER_TOPIC "access_control/server"

WIEGAND wg1;
WIEGAND wg2;

WiFiClient espClient;
PubSubClient client(espClient);
long lastMsg = 0;
char msg[250];

void setup() {

  pinMode(card1Beep, OUTPUT);
  pinMode(card1Led,  OUTPUT);
  pinMode(card2Beep, OUTPUT);
  pinMode(card2Led,  OUTPUT);

  digitalWrite(card1Beep, CARD_1_BEEP_OFF); // HIGH=beep_off    LOW=beep_on
  digitalWrite(card1Led,  CARD_1_LED_RED);  // HIGH=red         LOW=green
  digitalWrite(card2Beep, CARD_2_BEEP_OFF); // HIGH=beep_off    LOW=beep_on
  digitalWrite(card2Led,  CARD_2_LED_RED);  // HIGH=red         LOW=green

  digitalWrite(lockRelay, LOCK_RELAY_DOOR_LOCKED); // HIGH=door_locked LOW=door_unlocked

  Serial.begin(115200);
  setupWifi();
  client.setServer(mqttServer, 1883);
  client.setCallback(callback);
  wg1.begin(card1Data0, card1Data1);
  wg2.begin(card2Data0, card2Data1);
}

void setupWifi() {

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

void reconnect() {
  while (!client.connected()) {
    Serial.print("Attempting MQTT connection...");
    if (client.connect("ESP8266Client")) {
      Serial.println("connected");
      client.publish(CARD_READER_TOPIC, "[Main entrance] reconnected");
      client.subscribe(SERVER_TOPIC);
    } else {
      Serial.print("failed, rc=");
      Serial.print(client.state());
      Serial.println(" try again in 2 seconds");
      delay(2000);
    }
  }
}

void publishCardReadMessage(unsigned long cardNumber, char* direction) {
  char cardNumberHex[100]="";
  snprintf(cardNumberHex, sizeof(cardNumberHex), "%lX", cardNumber);
  char payload[250]={};
  String strBuffer;
  DynamicJsonBuffer  jsonBuffer(200);
  JsonObject& root = jsonBuffer.createObject();

  root["message"] = "card_read";
  root["lock_name"] = "Main entrance";
  root["direction"] = direction;
  root["card_number"] = cardNumberHex;
  root.printTo(strBuffer);
  strBuffer.toCharArray(payload, sizeof(payload));

  client.publish(CARD_READER_TOPIC, payload);
}

void callback(char* topic, byte* payload, unsigned int length) {
  //handle messages

  DynamicJsonBuffer  jsonBuffer(200);
  JsonObject& root = jsonBuffer.parseObject((char*) payload);
  char *message = root["message"];
  char *lockName = root["lock_name"];
  char *command = root["command"];

  // if (strcmp(command, "open_door")==0) {
  //   digitalWrite(lockRelay, LOCK_RELAY_DOOR_UNLOCKED);
  //   // todo: lock after 15 seconds
  // }

  // - server to CR {"command": "open_door", "duration": 5, "beep_tone": "twice", "lock_name": "main_door" } - whenever card is swiped
  // - server to CR {"command": "deny_access", "beep_tone": "something", "feedback_led": "toggle_twice"}
  // - server to CR {"command": "close_door", "lock_name": "main_door" } - whenever card is swiped



  // Serial.print("Message arrived [");
  // Serial.print(topic);
  // Serial.print("] ");
  // for (int i = 0; i < length; i++) {
  //   Serial.print((char)payload[i]);
  // }
  // Serial.println();
}

void loop() {
  //MQTT
  if (!client.connected()) {
    Serial.println("MQTT not connected");
    reconnect();
  }
  client.loop();

  //card reader 1
  if (wg1.available()) {
    unsigned long cardNumber = wg1.getCode();
    publishCardReadMessage(cardNumber, "enter");
  }

  //card reader 2
  if (wg2.available()) {
    unsigned long cardNumber = wg2.getCode();
    publishCardReadMessage(cardNumber, "exit");
  }

  delay(100);
}
