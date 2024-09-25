#include <WiFi.h>
#define LIGHT_SENSOR_PIN 34// ESP32 pin GIOP36 (ADC0)

const char* ssid = "yale wireless";

const char* host = "...";
const uint16_t port = 10000;

WiFiClient client;

void setup() {
  // initialize serial communication at 9600 bits per second:
  Serial.begin(9600);

  WiFi.begin(ssid);

  while(WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }

  Serial.println(WiFi.localIP());


  // set the ADC attenuation to 11 dB (up to ~3.3V input)
  analogSetAttenuation(ADC_11db);
}

void loop() {
  // reads the input on analog pin (value between 0 and 4095)
  // int analogValue = analogRead(LIGHT_SENSOR_PIN);
  if(client.connect(IPAddress(host), port)) {
    Serial.println("Connected!");
  } else {
    Serial.println("FAILED.");
    return;
  }

  if (client.connected()) {
    // Send data
    String message = "Hello from ESP32!";
    client.println(message);
    Serial.println("Message sent: " + message);
  } else {
    Serial.println("Disconnected from server");
  }

  delay(5000); // Send message every 5 seconds

  // Serial.print("Analog Value = ");
  // Serial.println(analogValue);   // the raw analog reading



  delay(500);
}
