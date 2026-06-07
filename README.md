# SiMiProject

**Industrial IoT Retrofit Platform — Apple Developer Academy · Year 2 Application**
*Christian Ostoni · June 2026*

---

## What Is This

SiMiProject is an IIoT platform for retrofitting legacy PLC-controlled industrial machines with real-time remote monitoring and supervisory control — without modifying a single line of existing PLC logic. A Siemens LOGO! 8 PLC is made remotely controllable through a layered stack that terminates in a native iOS and visionOS application, connected via a TLS-encrypted MQTT broker.

---

## Contents of This Submission

The zip you received contains this repository plus three additional files that are excluded from version control (large binaries):

| File | Type | Description |
|---|---|---|
| `technical_documentations.pages` | Apple Pages document | Full technical documentation of the project. Covers system architecture, cybersecurity model, spatial computing rationale, demo hardware setup, and network topology. **Read this first.** |
| `demo_guide.pdf` | PDF | Step-by-step instructions for testing the live system. Covers both the iOS and visionOS apps, the recommended test sequence, and known limitations. |
| `final_video.mov` | Video | Demo recording showing the physical electrical panel, the iOS app, and a live pump on/off cycle controlled via the full stack (Vision Pro → MQTT → Raspberry Pi → ESP8266 → MODBUS → PLC). |

---

## Repository Structure

```
simiProject/
├── FactoryPanel/        # visionOS app (Apple Vision Pro)
├── FactoryPanelApp/     # iOS app (iPhone / iPad)
├── LogoLink/            # Swift Package — custom MQTT client library
├── backend/             # Raspberry Pi — Python async backend
├── LOGO_Gateway/        # ESP8266 — C++ firmware (Arduino)
└── .gitignore
```

---

### `FactoryPanel/`

Native **visionOS** application targeting Apple Vision Pro. Displays real-time PLC state as a spatial floating window with motor group cards, live output status (green = active), and an alarm banner for fault conditions. Imports `LogoLink` as a local Swift Package.

**Open with:** `FactoryPanel/FactoryPanel.xcodeproj` — requires Xcode 16+, visionOS SDK.

---

### `FactoryPanelApp/`

Native **iOS** application for iPhone and iPad. Functionally identical to the visionOS app but adapted for the standard UIKit/SwiftUI idioms (NavigationSplitView with inline title, system background materials). Shares the same `LogoLink` dependency.

**Open with:** `FactoryPanelApp/FactoryPanelApp.xcodeproj` — requires Xcode 16+, iOS 17+.

---

### `LogoLink/`

A first-party **Swift Package** that abstracts all MQTT communication for iOS 17+ and visionOS 1+. Wraps [CocoaMQTT](https://github.com/emqx/CocoaMQTT) behind a clean `@Observable` / `AsyncStream` API. Handles TLS negotiation, exponential-backoff reconnection, topic routing, and JSON decoding. Neither app references MQTT primitives directly.

**Build:** Swift Package, no Xcode project needed. Imported by both apps as a local dependency.

---

### `backend/`

Python 3 **async backend** running on the Raspberry Pi hub. Three concurrent `asyncio` coroutines share two queues:

- `MachinePoller` — periodic status requests (configurable interval, default 5 s)
- `WebSocketClient` — forwards commands to ESP8266 gateways, collects responses
- `mqttClientClass` — TLS connection to EMQX Cloud broker; bridges MQTT ↔ WebSocket

Entry point: `main.py`. Configuration: `config.json` (fleet roster, broker address, polling interval). Secrets: `.env` file (MQTT credentials, excluded from version control).

---

### `LOGO_Gateway/`

**C++ firmware** for the ESP8266 microcontroller (Arduino framework). Implements a non-blocking WebSocket server that proxies Modbus TCP reads/writes to the Siemens LOGO! 8 PLC. The Modbus register map covers 24 digital inputs, 20 digital outputs, 64 markers, 8 analog inputs, and 2 analog outputs.

**Flash with:** Arduino IDE or PlatformIO. Dependencies: `ESPAsyncWebServer`, `ESPAsyncTCP`, `ArduinoJson`, `ModbusIP_ESP8266` (header included in folder).

---

## How to Explore the Code

| Goal | Start here |
|---|---|
| Understand the full system | `technical_documentations.pages` |
| Test the live demo | `demo_guide.pdf` |
| iOS/visionOS client code | `FactoryPanelApp/` or `FactoryPanel/` |
| MQTT abstraction layer | `LogoLink/Sources/LogoLink/` |
| Cloud bridge (Raspberry Pi) | `backend/main.py` → `mqtt_client.py`, `websocketClient.py` |
| Edge firmware (ESP8266) | `LOGO_Gateway/LOGO_Gateway.ino` |

---

*Questions: christianostoni82@gmail.com*
