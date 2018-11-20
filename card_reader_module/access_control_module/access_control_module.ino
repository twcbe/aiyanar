#include <ESP8266WiFi.h>
#include <PubSubClient.h>
#include <ArduinoJson.h>
#include <Wiegand.h>
#include <TaskScheduler.h>
#include <EEPROM.h>
#include <ESP8266mDNS.h>
#include <WiFiUdp.h>
#include <ArduinoOTA.h>

extern "C" {
  #include <user_interface.h>
}

#define VERSION_STRING "1.7"
#define USE_STATIC_IP

// customizable options:
#define STATIC_IP_ADDRESS        10, 137,120,250
#define STATIC_IP_GATEWAY        10, 137,120,254
#define STATIC_IP_SUBNET         255,255,255,0
#define LOCK_NAME                "Main entrance"
#define CARD_READER_TOPIC        "access_control/card_readers"
#define SERVER_TOPIC             "access_control/server"
#define DOOR_UNLOCK_MIN_DURATION 1000
#define DOOR_UNLOCK_MAX_DURATION 30000
#define MAX_NUMBER_OF_BEEPS 5
#define MAX_BEEP_DURATION 1500
#define HEART_BEAT_DELAY 30000

const char* ssid = FILL_IN_SSID_STRING;
const char* password = FILL_IN_PASSWORD_STRING;
const char* mqttServer = "10.137.120.19";
// END customizable options

#define d0 16
#define d1 5
#define d2 4
#define d3 0
#define d4 2
#define d5 14
#define d6 12
#define d7 13
#define d8 15

#define ENTRY_CARD_READER_DATA0 d7
#define ENTRY_CARD_READER_DATA1 d6
#define ENTRY_CARD_READER_LED   d8
#define ENTRY_CARD_READER_BEEP  d5
#define EXIT_CARD_READER_DATA0  d3
#define EXIT_CARD_READER_DATA1  d4
#define EXIT_CARD_READER_LED    d2
#define EXIT_CARD_READER_BEEP   d1
#define LOCK_RELAY              d0

// new PCB layout
// #define ENTRY_CARD_READER_DATA0 d6
// #define ENTRY_CARD_READER_DATA1 d7
// #define ENTRY_CARD_READER_LED   d8
// #define ENTRY_CARD_READER_BEEP  d5
// #define EXIT_CARD_READER_DATA0  d3
// #define EXIT_CARD_READER_DATA1  d4
// #define EXIT_CARD_READER_LED    d2
// #define EXIT_CARD_READER_BEEP   d1
// #define LOCK_RELAY              d0

#define DOOR_UNLOCKED LOW
#define DOOR_LOCKED   HIGH
#define BEEP_OFF      HIGH
#define BEEP_ON       LOW
#define LED_RED       HIGH
#define LED_GREEN     LOW

#define clamp(value, min, max) ((value) > (max) ? (max) : ( (value) < (min) ? (min) : (value) ))

#define getOrDefault(object, key, defaultValue) (object.containsKey(key) ? object[key] : defaultValue)

#define stringEquals(str1, str2)    (strcmp(str1, str2)==0)
#define stringNotEquals(str1, str2) (strcmp(str1, str2)!=0)

enum class LockStates
{
  LOCKED,
  UNLOCKED_FOR_DURATION,
  EMERGENCY_UNLOCKED
};

void lockDoorCallback();
void beepOnCallback();
void beepOffCallback();
void heartBeatCallback();

Scheduler taskRunner;
Task lockDoorTask(0, 1, &lockDoorCallback);
Task beepTask(100, 4, &beepOnCallback);
Task heartBeatTask(HEART_BEAT_DELAY, TASK_FOREVER, &heartBeatCallback);

WIEGAND wg;
WiFiClient espClient;
PubSubClient client(espClient);

LockStates lockState = LockStates::LOCKED;

int asInteger(LockStates lockState)
{
  return static_cast<std::underlying_type<LockStates>::type>(lockState);
}

void heartBeatCallback() {
  uint32_t freeMemory = system_get_free_heap_size();

  Serial.print("free memory: ");
  Serial.println(freeMemory);

  char buffer[150];
  snprintf(buffer, sizeof(buffer), "[" LOCK_NAME "] (%s) free_memory: %u", WiFi.localIP().toString().c_str(), freeMemory);
  client.publish(CARD_READER_TOPIC, buffer);
}

void stateChangeTo(LockStates newLockState) {
  lockState = newLockState;
  Serial.print("Lock state changed to ");
  Serial.println(asInteger(newLockState));
}

void lockDoorCallback() {
  Serial.println("Locking door.");
  digitalWrite(LOCK_RELAY, DOOR_LOCKED);
  digitalWrite(ENTRY_CARD_READER_LED, LED_RED);
  digitalWrite(EXIT_CARD_READER_LED, LED_RED);
  stateChangeTo(LockStates::LOCKED);
}

void lockDoorAfter(unsigned long durationMillis) {
  lockDoorTask.restartDelayed(durationMillis);
}

void unlockDoor() {
  digitalWrite(LOCK_RELAY, DOOR_UNLOCKED);
  digitalWrite(ENTRY_CARD_READER_LED, LED_GREEN);
  digitalWrite(EXIT_CARD_READER_LED, LED_GREEN);
}

void beep(int number_of_beeps, int beep_duration) {
  number_of_beeps = clamp(number_of_beeps, 0, MAX_NUMBER_OF_BEEPS);
  beep_duration = clamp(beep_duration, 0, MAX_BEEP_DURATION);
  if(number_of_beeps != 0) {
    beepTask.setInterval(beep_duration);
    beepTask.setIterations(2 * number_of_beeps);
    beepTask.setCallback(&beepOnCallback);
    beepTask.restartDelayed(0);
  }
}

void unlockDoorFor(unsigned long durationMillis, int number_of_beeps, int beep_duration) {
  Serial.print("Unlocking door for ");
  Serial.print(durationMillis);
  Serial.println(" milliseconds");
  unlockDoor();
  beep(number_of_beeps, beep_duration);
  lockDoorAfter(durationMillis);
  stateChangeTo(LockStates::UNLOCKED_FOR_DURATION);
}

void beepOnCallback() {
  digitalWrite(ENTRY_CARD_READER_BEEP, BEEP_ON);
  digitalWrite(EXIT_CARD_READER_BEEP, BEEP_ON);
  beepTask.setCallback(&beepOffCallback);
}

void beepOffCallback() {
  digitalWrite(ENTRY_CARD_READER_BEEP, BEEP_OFF);
  digitalWrite(EXIT_CARD_READER_BEEP, BEEP_OFF);
  beepTask.setCallback(&beepOnCallback);
}

void beepForInvalidCard(int number_of_beeps, int beep_duration) {
  Serial.println("Beeping for invalid card.");
  digitalWrite(ENTRY_CARD_READER_LED, LED_RED);
  digitalWrite(EXIT_CARD_READER_LED, LED_RED);
  beep(number_of_beeps, beep_duration);
}

void enterEmergencyMode() {
  Serial.print("Entering emergency mode. Unlocking door.");
  unlockDoor();
  stateChangeTo(LockStates::EMERGENCY_UNLOCKED);
  lockDoorTask.disable();
  EEPROM.write(0, 1);
  EEPROM.commit();
}

void exitEmergencyMode(unsigned long durationMillis) {
  Serial.print("Exiting emergency mode. Locking door in ");
  Serial.print(durationMillis);

  Serial.println(" milliseconds");
  lockDoorAfter(durationMillis);
  stateChangeTo(LockStates::UNLOCKED_FOR_DURATION);
  EEPROM.write(0, 0);
  EEPROM.commit();
}

void loadStateFromStorage() {
  unsigned emergencyMode = EEPROM.read(0);
  if(emergencyMode) {
    enterEmergencyMode();
  } else {
    digitalWrite(LOCK_RELAY, DOOR_LOCKED);          // HIGH=door_locked LOW=door_unlocked
  }
}

void publishStartupMessage() {
  //MQTT
  if (!client.connected()) {
    Serial.println("MQTT not connected");
    reconnect();
  }
  char buffer[150];
  snprintf(buffer, sizeof(buffer), "[" LOCK_NAME "] (%s) startup complete. version " VERSION_STRING, WiFi.localIP().toString().c_str());
  client.publish(CARD_READER_TOPIC, buffer);
}

void setup() {

  EEPROM.begin(512);
  pinMode(ENTRY_CARD_READER_BEEP, OUTPUT);
  pinMode(ENTRY_CARD_READER_LED,  OUTPUT);
  pinMode(EXIT_CARD_READER_BEEP,  OUTPUT);
  pinMode(EXIT_CARD_READER_LED,   OUTPUT);

  pinMode(LOCK_RELAY, OUTPUT);

  digitalWrite(ENTRY_CARD_READER_BEEP, BEEP_OFF); // HIGH=beep_off    LOW=beep_on
  digitalWrite(ENTRY_CARD_READER_LED,  LED_RED);  // HIGH=red         LOW=green
  digitalWrite(EXIT_CARD_READER_BEEP,  BEEP_OFF); // HIGH=beep_off    LOW=beep_on
  digitalWrite(EXIT_CARD_READER_LED,   LED_RED);  // HIGH=red         LOW=green

  Serial.begin(115200);
  setupWifi();
  setupOTA();
  client.setServer(mqttServer, 1883);
  client.setCallback(callback);

  //Entry card reader (GateA in Wiegand library)
  wg.D0PinA = ENTRY_CARD_READER_DATA0;
  wg.D1PinA = ENTRY_CARD_READER_DATA1;
  //Exit card reader  (GateB in Wiegand library)
  wg.D0PinB = EXIT_CARD_READER_DATA0;
  wg.D1PinB = EXIT_CARD_READER_DATA1;
  // wg.begin(GateA , GateB, GateC)
  wg.begin(true, true, false);

  taskRunner.init();
  taskRunner.addTask(lockDoorTask);
  taskRunner.addTask(beepTask);
  taskRunner.addTask(heartBeatTask);
  heartBeatTask.enable();

  loadStateFromStorage();
  publishStartupMessage();
}

void setupOTA() {
  // Port defaults to 8266
  ArduinoOTA.setPort(8266);

  // Hostname defaults to esp8266-[ChipID]
  ArduinoOTA.setHostname("access_control_main_entrance_esp8266");

  // No authentication by default
  // ArduinoOTA.setPassword("admin");

  // Password can be set with it's md5 value as well
  // MD5(admin) = 21232f297a57a5a743894a0e4a801fc3
  // ArduinoOTA.setPasswordHash("21232f297a57a5a743894a0e4a801fc3");
  ArduinoOTA.onStart([]() {
    String type;
    if (ArduinoOTA.getCommand() == U_FLASH)
      type = "sketch";
    else // U_SPIFFS
      type = "filesystem";

    // NOTE: if updating SPIFFS this would be the place to unmount SPIFFS using SPIFFS.end()
    Serial.println("[OTA] Start updating " + type);
  });
  ArduinoOTA.onEnd([]() {
    Serial.println("\n[OTA] Ota successfully completed.");
  });
  ArduinoOTA.onProgress([](unsigned int progress, unsigned int total) {
    Serial.printf("[OTA] Progress: %u%% (%u/%u)\n", (100 * progress / total), progress, total);
  });
  ArduinoOTA.onError([](ota_error_t error) {
    Serial.printf("[OTA] Error[%u]: ", error);
    if (error == OTA_AUTH_ERROR) Serial.println("[OTA] Auth Failed");
    else if (error == OTA_BEGIN_ERROR) Serial.println("[OTA] Begin Failed");
    else if (error == OTA_CONNECT_ERROR) Serial.println("[OTA] Connect Failed");
    else if (error == OTA_RECEIVE_ERROR) Serial.println("[OTA] Receive Failed");
    else if (error == OTA_END_ERROR) Serial.println("[OTA] End Failed");
  });
  ArduinoOTA.begin();
}

void setupWifi() {

  delay(10);
  // We start by connecting to a WiFi network
  Serial.println();
  Serial.print("Connecting to ");
  Serial.println(ssid);

#ifdef USE_STATIC_IP
  IPAddress ip(STATIC_IP_ADDRESS);
  IPAddress gateway(STATIC_IP_GATEWAY);
  IPAddress subnet(STATIC_IP_SUBNET);
  WiFi.config(ip,gateway,subnet);
#endif
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

  Serial.println("");
  Serial.println("WiFi connected");
  Serial.println("IP address: ");
  Serial.println(WiFi.localIP());
}

void reconnect() {
  while (!client.connected()) {
    Serial.print("Attempting MQTT connection...");
    if (client.connect(LOCK_NAME " CARD READER")) {
      Serial.println("connected");
      client.publish(CARD_READER_TOPIC, "[" LOCK_NAME "] reconnected");
      client.subscribe(SERVER_TOPIC);
    } else {
      Serial.print("failed, rc=");
      Serial.print(client.state());
      Serial.println(" try again in 2 seconds");
      delay(2000);
    }
  }
}

void publishCardReadMessage(unsigned long cardNumber, const char* direction) {
  char cardNumberHex[100]="";
  snprintf(cardNumberHex, sizeof(cardNumberHex), "%lX", cardNumber);
  char payload[250]={};
  String strBuffer;
  DynamicJsonBuffer  jsonBuffer(200);
  JsonObject& root = jsonBuffer.createObject();

  root["message"] = "card_read";
  root["lock_name"] = LOCK_NAME;
  root["direction"] = direction;
  root["card_number"] = cardNumberHex;
  root.printTo(strBuffer);
  strBuffer.toCharArray(payload, sizeof(payload));

  client.publish(CARD_READER_TOPIC, payload);
}

void openDoorHandler(JsonObject &root) {
  float duration = getOrDefault(root, "duration", 5);
  int number_of_beeps = getOrDefault(root, "beeps", 0);
  int beep_duration = getOrDefault(root, "beep_duration", 200);
  duration = duration*1000;
  unsigned long unlockDuration = clamp(duration, DOOR_UNLOCK_MIN_DURATION, DOOR_UNLOCK_MAX_DURATION);
  unlockDoorFor(unlockDuration, number_of_beeps, beep_duration);
}

void callback(char* topic, byte* payload, unsigned int length) {
  //handle messages

  DynamicJsonBuffer  jsonBuffer(200);
  JsonObject& root = jsonBuffer.parseObject((const char*) payload);
  const char *lockName = root["lock_name"] | "";
  const char *command = root["command"] | "";

  if (strcmp(command, "start_emergency")==0) {
    enterEmergencyMode();
  }

  if (stringNotEquals(lockName, LOCK_NAME) && stringNotEquals(lockName, "all")) {
    //don't process messages not intended for this node
    return;
  }

  if (strcmp(command, "restart")==0) {
    ESP.reset();
  }

  //state machine
  switch(lockState) {
    case LockStates::LOCKED:
    if (strcmp(command, "open_door")==0) {
      openDoorHandler(root);
    }
    if (strcmp(command, "deny_access") == 0) {
      beepForInvalidCard(getOrDefault(root, "beeps", 2), getOrDefault(root, "beep_duration", 100));
    }
    break;

    case LockStates::UNLOCKED_FOR_DURATION:
    if (strcmp(command, "open_door")==0) {
      openDoorHandler(root);
    }
    if (strcmp(command, "deny_access") == 0) {
      beepForInvalidCard(getOrDefault(root, "beeps", 2), getOrDefault(root, "beep_duration", 100));
    }
    break;

    case LockStates::EMERGENCY_UNLOCKED:
    if (strcmp(command, "end_emergency")==0) {
      float duration = getOrDefault(root, "duration", 5);
      duration = duration*1000;
      unsigned long unlockDuration = clamp(duration, DOOR_UNLOCK_MIN_DURATION, DOOR_UNLOCK_MAX_DURATION);
      exitEmergencyMode(unlockDuration);
    }
    break;
  }
// ACS - Access Control System
//  - server to ACS {"command": "open_door", "duration": 5, "beeps": 0, "lock_name": "main_door" } - whenever valid card is swiped
//  - server to ACS {"command": "open_door", "duration": 5, "beeps": 1, "lock_name": "main_door" } - whenever valid face is recognized
//  - server to ACS {"command": "deny_access", "beeps": 2} - whenever person is not authorized
//
}

void loop() {
  //MQTT
  if (!client.connected()) {
    Serial.println("MQTT not connected");
    unlockDoor();
    reconnect();
    loadStateFromStorage();
  }
  client.loop();

  //card readers
  if (wg.available()) {
    unsigned long cardNumber = wg.getCode();
    publishCardReadMessage(cardNumber, (wg.getGateActive() == 1 ? "enter" : "exit"));
  }

  taskRunner.execute();
  ArduinoOTA.handle();
}
