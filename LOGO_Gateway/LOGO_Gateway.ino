#include <ArduinoJson.h>
#include <ESP8266WiFi.h>
#include <ESPAsyncTCP.h>
#include <ESPAsyncWebServer.h>
#include "ModbusLogo.h"

const char* WIFI_SSID     = "PosteMobile-90353337";
const char* WIFI_PASSWORD = "2022AleChrisMir#2022";

IPAddress localIP(192, 168, 1, 101);
IPAddress gateway(192, 168, 1,   1);
IPAddress subnet (255, 255, 255, 0);

AsyncWebServer server(81);
AsyncWebSocket ws("/ws");

// ---------------------------------------------------------
// BANDIERINE (FLAG) PER COMUNICARE COL LOOP
// ---------------------------------------------------------
bool requestStatus = false;

bool requestWriteMarker = false;
int pendingMarkerNumber = 0;
int pendingMarkerValue  = 0;

void initWiFi(){
  WiFi.mode(WIFI_STA);
  WiFi.config(localIP, gateway, subnet); 
  
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("Connecting to WiFi ..");
  while (WiFi.status() != WL_CONNECTED) {
    Serial.print('.');
    delay(1000);
  }
  Serial.println("");
  Serial.print("Connesso! IP: ");
  Serial.println(WiFi.localIP());
}

void notifyClients(const String& message) {
  ws.textAll(message);
}

// ---------------------------------------------------------
// GESTIONE MESSAGGI WEBSOCKET (Veloce e Non bloccante)
// ---------------------------------------------------------
void handleWebSocketMessage(void* arg, uint8_t* data, size_t len) {
  AwsFrameInfo* info = (AwsFrameInfo*)arg;

  if (!info->final || info->index != 0 || info->len != len) {
    return;
  }
  if (info->opcode != WS_TEXT) {
    return;
  }

  JsonDocument inDoc;
  DeserializationError err = deserializeJson(inDoc, data, len);
  if (err) {
    notifyClients("{\"type\":\"error\",\"message\":\"JSON non valido\"}");
    return;
  }

  const char* type = inDoc["type"] | "";

  // ── CASO 1: richiesta status ──────────────────
  if (strcmp(type, "status") == 0) {
    Serial.println("[WS] Ricevuta richiesta status. Delego al loop...");
    requestStatus = true; // Alzo la bandierina
  }

  // ── CASO 2: scrittura marker ──────────────────
  else if (strcmp(type, "writeMarker") == 0) {
    int markerNumber = inDoc["marker"] | 0;
    int value        = inDoc["value"]  | 0;

    if (markerNumber < 1 || markerNumber > 64) {
      notifyClients("{\"type\":\"writeMarker\",\"success\":false,\"message\":\"marker deve essere 1-64\"}");
      return;
    }
    if (value != 0 && value != 1) {
      notifyClients("{\"type\":\"writeMarker\",\"success\":false,\"message\":\"value deve essere 0 o 1\"}");
      return;
    }

    Serial.printf("[WS] Ricevuta richiesta scrittura M%d. Delego al loop...\n", markerNumber);
    // Salvo i dati e alzo la bandierina
    pendingMarkerNumber = markerNumber;
    pendingMarkerValue  = value;
    requestWriteMarker  = true; 
  }

  else {
    notifyClients("{\"type\":\"error\",\"message\":\"tipo non riconosciuto\"}");
  }
}

void onEvent(AsyncWebSocket *server, AsyncWebSocketClient *client, AwsEventType type, void *arg, uint8_t *data, size_t len) {
  switch (type) {
    case WS_EVT_CONNECT:
      Serial.printf("WebSocket client #%u connected from %s\n", client->id(), client->remoteIP().toString().c_str());
      break;
    case WS_EVT_DISCONNECT:
      Serial.printf("WebSocket client #%u disconnected\n", client->id());
      break;
    case WS_EVT_DATA:
      handleWebSocketMessage(arg, data, len);
      break;
    case WS_EVT_PONG:
    case WS_EVT_ERROR:
      break;
  }
}

void initWebSocket() {
  ws.onEvent(onEvent);
  server.addHandler(&ws);
}

// ---------------------------------------------------------
// FUNZIONI ESEGUITE DAL LOOP (Sicure e Bloccanti)
// ---------------------------------------------------------

void processStatus() {
  Serial.println("[MODBUS] Esecuzione lettura stato...");
  
  // alignas(4) forza l'allineamento a 32 bit per evitare crash (Exception 9) di memoria
  alignas(4) bool     inputs[COIL_I_COUNT]    = {};
  alignas(4) bool     outputs[COIL_Q_COUNT]   = {};
  alignas(4) uint16_t analogIn[IREG_AI_COUNT] = {};
  alignas(4) uint16_t analogOut[HREG_AQ_COUNT]= {};

  bool digitalOk = modbusReadAllDigital(inputs, COIL_I_COUNT, outputs, COIL_Q_COUNT);
  bool analogOk  = modbusReadAllAnalog(analogIn, IREG_AI_COUNT, analogOut, HREG_AQ_COUNT);

  JsonDocument outDoc;
  outDoc["action"]    = "status";
  outDoc["state"] = digitalOk && analogOk;

  JsonArray inArr  = outDoc["digital"]["inputs"].to<JsonArray>();
  JsonArray outArr = outDoc["digital"]["outputs"].to<JsonArray>();
  for (int i = 0; i < COIL_I_COUNT;  i++) inArr.add(inputs[i]);
  for (int i = 0; i < COIL_Q_COUNT;  i++) outArr.add(outputs[i]);

  JsonArray aiArr = outDoc["analog"]["inputs"].to<JsonArray>();
  JsonArray aqArr = outDoc["analog"]["outputs"].to<JsonArray>();
  for (int i = 0; i < IREG_AI_COUNT; i++) aiArr.add(analogIn[i]);
  for (int i = 0; i < HREG_AQ_COUNT; i++) aqArr.add(analogOut[i]);

  String response;
  serializeJson(outDoc, response);
  notifyClients(response);
  Serial.printf("[MODBUS] Status inviato — digital:%s analog:%s\n",
                digitalOk ? "OK" : "FAIL", analogOk ? "OK" : "FAIL");
}

void processWriteMarker() {
  Serial.println("[MODBUS] Esecuzione scrittura marker...");
  bool ok = modbusWriteMarker(pendingMarkerNumber, pendingMarkerValue == 1);

  JsonDocument outDoc;
  outDoc["type"]    = "writeMarker";
  outDoc["success"] = ok;
  outDoc["marker"]  = pendingMarkerNumber;
  outDoc["value"]   = pendingMarkerValue;

  String response;
  serializeJson(outDoc, response);
  notifyClients(response);
  Serial.printf("[MODBUS] WriteMarker M%d=%d — %s\n",
                pendingMarkerNumber, pendingMarkerValue, ok ? "OK" : "FAIL");
}

// ---------------------------------------------------------
// SETUP E LOOP
// ---------------------------------------------------------
void setup() {
  Serial.begin(115200);
  Serial.println("\nAvvio in corso...");
  
  initWiFi();
  initWebSocket();
  
  server.begin();
  Serial.println("Server Web e WebSocket avviati.");
}

void loop() {
  ws.cleanupClients();
  
  // Se il WebSocket ha richiesto lo stato, lo eseguiamo in modo sicuro qui
  if (requestStatus) {
    requestStatus = false; // Abbasso la bandierina
    processStatus();       // Leggo Modbus e rispondo
  }

  // Se il WebSocket ha richiesto la scrittura, la eseguiamo in modo sicuro qui
  if (requestWriteMarker) {
    requestWriteMarker = false; // Abbasso la bandierina
    processWriteMarker();       // Scrivo Modbus e rispondo
  }

  delay(20); 
}