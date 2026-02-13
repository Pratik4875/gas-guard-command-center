#include <ESP8266WiFi.h>
#include <Firebase_ESP_Client.h>

// Provide the token generation process info.
#include <addons/TokenHelper.h>
// Provide the RTDB payload printing info and other helper functions.
#include <addons/RTDBHelper.h>

// Wi-Fi Credentials
#define WIFI_SSID "group5"
#define WIFI_PASSWORD "12345678"

// Firebase Credentials
#define API_KEY "AIzaSyDCuB98rUGo785Y6iQ68p2LXzoIJXjBLK4"
#define DATABASE_URL "https://gasguard-bdcd2-default-rtdb.asia-southeast1.firebasedatabase.app" 

// Hardware Pins
#define SENSOR_PIN A0     // MQ Sensor
#define RED_LED_PIN D1    // Danger LED (Red)
#define BUZZER_PIN D2     // Buzzer
#define GREEN_LED_PIN D5  // Safe LED (Green) - Connect to D5

// Firebase Objects
FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig config;

unsigned long sendDataPrevMillis = 0;
bool signupOK = false;
int gasThreshold = 600; // Updated to 600 as per user request

void setup() {
  Serial.begin(115200);
  
  pinMode(RED_LED_PIN, OUTPUT);
  pinMode(GREEN_LED_PIN, OUTPUT);
  pinMode(BUZZER_PIN, OUTPUT);
  pinMode(SENSOR_PIN, INPUT);
  
  // Test LEDs on startup
  digitalWrite(RED_LED_PIN, HIGH);
  digitalWrite(GREEN_LED_PIN, HIGH);
  delay(500);
  digitalWrite(RED_LED_PIN, LOW);
  digitalWrite(GREEN_LED_PIN, LOW);

  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("Connecting to Wi-Fi");
  while (WiFi.status() != WL_CONNECTED) {
    Serial.print(".");
    delay(300);
  }
  Serial.println();
  Serial.print("Connected with IP: ");
  Serial.println(WiFi.localIP());

  /* Assign the api key (required) */
  config.api_key = API_KEY;
  /* Assign the RTDB URL (required) */
  config.database_url = DATABASE_URL;

  /* Sign up */
  if (Firebase.signUp(&config, &auth, "", "")) {
    Serial.println("Firebase Auth Successful");
    signupOK = true;
  } else {
    Serial.printf("%s\n", config.signer.signupError.message.c_str());
  }

  /* Assign the callback function for the long running token generation task */
  config.token_status_callback = tokenStatusCallback; // see addons/TokenHelper.h
  
  Firebase.begin(&config, &auth);
  Firebase.reconnectWiFi(true);
}

void loop() {
  // Read Sensor
  int gasValue = analogRead(SENSOR_PIN);
  Serial.print("Gas Level: ");
  Serial.println(gasValue);

  // Local Alert Logic
  if (gasValue > gasThreshold) {
    // DANGER STATE
    digitalWrite(RED_LED_PIN, HIGH);   // Red ON
    digitalWrite(GREEN_LED_PIN, LOW);  // Green OFF
    tone(BUZZER_PIN, 1000);            // Buzzer ON
  } else {
    // SAFE STATE
    digitalWrite(RED_LED_PIN, LOW);    // Red OFF
    digitalWrite(GREEN_LED_PIN, HIGH); // Green ON
    noTone(BUZZER_PIN);                // Buzzer OFF
  }

  // Send to Firebase (every 2 seconds)
  if (Firebase.ready() && signupOK && (millis() - sendDataPrevMillis > 2000 || sendDataPrevMillis == 0)) {
    sendDataPrevMillis = millis();
    
    // Upload current gas level
    if (Firebase.RTDB.setInt(&fbdo, "sensor/gas_level", gasValue)) {
      Serial.println("Data sent to Firebase!");
    } else {
      Serial.println("Failed to send data");
      Serial.println(fbdo.errorReason());
    }
  }
  
  delay(100);
}
