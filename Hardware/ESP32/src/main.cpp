/*
#include <Arduino.h>
#include "BLEDevice.h"

class MyAdvertisedDeviceCallbacks: public BLEAdvertisedDeviceCallbacks {
    
    //    Called for each advertising BLE server.
    
    void onResult(BLEAdvertisedDevice advertisedDevice) {
      Serial.print("BLE Advertised Device found - ");
      Serial.println(advertisedDevice.toString().c_str());

      // We have found a device, check to see if it contains the Nordic UART service.
      if (advertisedDevice.haveServiceUUID() && advertisedDevice.getServiceUUID().equals(serviceUUID)) {

        Serial.println("Found a device with the desired ServiceUUID!");
        advertisedDevice.getScan()->stop();

        pServerAddress = new BLEAddress(advertisedDevice.getAddress());
        doConnect = true;

      } // Found our server
    } // onResult
}; // MyAdvertisedDeviceCallbacks


void setup() {
  Serial.begin(115200);
  Serial.println("Starting Arduino BLE Central Mode (Client) Nordic UART Service");

  BLEDevice::init("");

  // Retrieve a Scanner and set the callback we want to use to be informed when we
  // have detected a new device. Specify that we want active scanning and start the
  // scan to run for 30 seconds.
  BLEScan* pBLEScan = BLEDevice::getScan();
  pBLEScan->setAdvertisedDeviceCallbacks(new MyAdvertisedDeviceCallbacks());
  pBLEScan->setActiveScan(true);
  pBLEScan->start(30);
} // End of setup.


const uint8_t notificationOff[] = {0x0, 0x0};
const uint8_t notificationOn[] = {0x1, 0x0};
bool onoff = true;

void loop() {
  // Si le drapeau "doConnect" est vrai, on a trouvé le serveur BLE désiré et on tente de se connecter
  if (doConnect == true) {
    int maxAttempts = 3;
    int attempts = 0;

    while (attempts < maxAttempts && !connected) {
      Serial.print("Tentative de connexion numéro ");
      Serial.println(attempts + 1);
      
      if (connectToServer(*pServerAddress)) {
        Serial.println("Connexion réussie au serveur BLE.");
        connected = true;
      } else {
        Serial.println("Échec de connexion. Nouvelle tentative...");
        attempts++;
        delay(2000);  // Attendre 2 secondes avant de réessayer
      }
    }

    if (!connected) {
      Serial.println("Impossible de se connecter après plusieurs tentatives.");
    }

    doConnect = false;
  }
  
  // Si on est connecté, exécuter les actions toutes les cinq secondes
  if (connected) {
    if (onoff) {
      Serial.println("Notifications activées");
      pTXCharacteristic->getDescriptor(BLEUUID((uint16_t)0x2902))->writeValue((uint8_t*)notificationOn, 2, true);
    } else {
      Serial.println("Notifications désactivées");
      pTXCharacteristic->getDescriptor(BLEUUID((uint16_t)0x2902))->writeValue((uint8_t*)notificationOff, 2, true);
    }

    onoff = !onoff;

    String timeSinceBoot = "Temps depuis le démarrage : " + String(millis() / 1000);
    pRXCharacteristic->writeValue(timeSinceBoot.c_str(), timeSinceBoot.length());
  }

  delay(5000); // Délai de cinq secondes entre chaque boucle
}
*/

/*#include <Arduino.h>
#include <Wire.h>
#include <Adafruit_MPU6050.h>
#include <Adafruit_Sensor.h>

const int SDA_PIN = 8;
const int SCL_PIN = 9;

Adafruit_MPU6050 mpu;
const float TEMP_THRESHOLD = 50.0; // Threshold in °C for potential overheating

void setup() {
  Serial.begin(115200);
  delay(1000);

  Serial.println("Initialisation I2C...");
  // Begin I2C communication on specific pins for ESP32-C3 (Wokwi default: SDA=8, SCL=9)
  Wire.begin(SDA_PIN, SCL_PIN);  

  // Initialize MPU6050 and check if it's connected
  if (!mpu.begin()) {
    Serial.println("MPU6050 initialization failed. Please check connections.");
    while (1);
  }
  Serial.println("MPU6050 initialized successfully!");
}

void loop() {
  // Create event variables to store accelerometer, gyroscope, and temperature data
  sensors_event_t accel, gyro, temp;
  mpu.getEvent(&accel, &gyro, &temp);

  // Check for temperature alert
  if (temp.temperature > TEMP_THRESHOLD) {
    Serial.println("Warning: MPU6050 temperature exceeds threshold!");
  }

  // Display accelerometer values (in m/s²) for each axis
  Serial.print("Acceleration [m/s²] - X: ");
  Serial.print(accel.acceleration.x, 2); // Display with 2 decimal
  Serial.print("\tY: ");
  Serial.print(accel.acceleration.y, 2);
  Serial.print("\tZ: ");
  Serial.print(accel.acceleration.z, 2);
  Serial.println();

  // Display gyroscope (rotation) values (in rad/s) for each axis
  Serial.print("Rotation [rad/s] - X: ");
  Serial.print(gyro.gyro.x, 2); // Display with 2 decimal
  Serial.print("\tY: ");
  Serial.print(gyro.gyro.y, 2);
  Serial.print("\tZ: ");
  Serial.print(gyro.gyro.z, 2);
  Serial.println();

  delay(200);
}*/

#include <Arduino.h>
#include <Wire.h>

// Adresse I2C du MPU-9250 (dépend de la connexion de la broche AD0, ici nous supposons qu'elle est connectée à GND)
const int MPU9250_ADDRESS = 0x68;

// Registres du MPU-9250
const int ACCEL_XOUT_H = 0x3B;
const int GYRO_XOUT_H = 0x43;

// Déclarations des fonctions
void setupMPU9250();
void readSensorData();
void writeMPU9250(byte address, byte reg, byte data);

void setup() {
  Wire.begin(21, 22); // Initialiser I2C avec les broches SDA et SCL correctes
  Serial.begin(115200); // Démarrer la communication série à 115200 bauds
  setupMPU9250(); // Configurer les registres du MPU-9250
}

void loop() {
  // Lire les données du capteur et les afficher
  readSensorData();
  delay(1000); // Délai pour la lisibilité
}

void setupMPU9250() {
  // Réveiller le MPU-9250
  writeMPU9250(MPU9250_ADDRESS, 0x6B, 0x00);
  // Configurer le gyroscope et l'accéléromètre
  // Ceci est une configuration de base et doit être ajustée pour votre application
  writeMPU9250(MPU9250_ADDRESS, 0x1B, 0x00); // Régler le gyroscope à ±250 degrés/sec
  writeMPU9250(MPU9250_ADDRESS, 0x1C, 0x00); // Régler l'accéléromètre à ±2g
}

void readSensorData() {
  int16_t accelX, accelY, accelZ, gyroX, gyroY, gyroZ;

  // Lire les données de l'accéléromètre
  Wire.beginTransmission(MPU9250_ADDRESS);
  Wire.write(ACCEL_XOUT_H);
  Wire.endTransmission(false);
  Wire.requestFrom((uint8_t)MPU9250_ADDRESS, (uint8_t)6, (uint8_t)true);
  accelX = (Wire.read() << 8 | Wire.read());
  accelY = (Wire.read() << 8 | Wire.read());
  accelZ = (Wire.read() << 8 | Wire.read());

  // Lire les données du gyroscope
  Wire.beginTransmission(MPU9250_ADDRESS);
  Wire.write(GYRO_XOUT_H);
  Wire.endTransmission(false);
  Wire.requestFrom((uint8_t)MPU9250_ADDRESS, (uint8_t)6, (uint8_t)true);
  gyroX = (Wire.read() << 8 | Wire.read());
  gyroY = (Wire.read() << 8 | Wire.read());
  gyroZ = (Wire.read() << 8 | Wire.read());

  // Afficher les données dans le moniteur série
  Serial.print("Accel X: "); Serial.print(accelX);
  Serial.print(" | Y: "); Serial.print(accelY);
  Serial.print(" | Z: "); Serial.println(accelZ);

  Serial.print("Gyro X: "); Serial.print(gyroX);
  Serial.print(" | Y: "); Serial.print(gyroY);
  Serial.print(" | Z: "); Serial.println(gyroZ);
}

void writeMPU9250(byte address, byte reg, byte data) {
  Wire.beginTransmission(address);
  Wire.write(reg);
  Wire.write(data);
  Wire.endTransmission();
}