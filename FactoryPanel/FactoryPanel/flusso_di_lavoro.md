# LogoLink — Flusso di Lavoro

## Architettura

```
Consumer App (SwiftUI)
        │
        ▼
    LogoLink          ← unica classe pubblica (entry point)
        │
        ├── MQTTClientWrapper    ← adattatore interno CocoaMQTT
        │        │
        │        └── CocoaMQTT  ← libreria esterna
        │
        └── TopicRouter         ← mappa topic → macchina → consumer
```

---

## Flusso Completo

### SETUP (una volta all'avvio app)

1. Consumer crea `LogoLinkConfiguration` (host, porta, TLS sì/no, credenziali)
2. Consumer crea istanza `LogoLink`
3. Consumer registra macchine: `logoLink.register(Machine(id: "macchina1"))`
4. Consumer imposta delegate o ascolta `AsyncStream`
5. Consumer chiama `logoLink.connect(config:)`

---

### CONNESSIONE

1. `LogoLink` passa config a `MQTTClientWrapper`
2. Wrapper apre socket TCP verso broker (con TLS se configurato)
3. Broker accetta → CocoaMQTT callback "connected"
4. Wrapper notifica `LogoLink` → `LogoLink` notifica delegate: `didConnect()`
5. `LogoLink` fa subscribe a tutti i topic delle macchine registrate:
   - `macchina1/response`
   - `macchina1/status`
   - `macchina2/response`
   - `macchina2/status`
   - ...

---

### RICEZIONE STATUS (ogni ~1 secondo, passivo)

1. PLC → ESP8266 → Raspberry → Broker pubblica su `macchina1/status`
2. Broker invia messaggio al client (già sottoscritto)
3. CocoaMQTT riceve → callback a `MQTTClientWrapper`
4. Wrapper chiama closure → `TopicRouter` riceve `(topic, payload)`
5. `TopicRouter`: topic contiene `/status` → decode `MachineStatusResponse`
6. `TopicRouter` trova `Machine "macchina1"` nel registro
7. `LogoLink` notifica consumer:
   - `delegate.logoLink(didReceiveStatus:for:)`
   - oppure pubblica su `AsyncStream<MachineStatusResponse>`

---

### INVIO COMANDO (su azione utente)

1. Consumer chiama: `logoLink.sendCommand(command, to: macchina1)`
2. `LogoLink` serializza `MachineCommand` → JSON Data
3. `LogoLink` chiede a Wrapper: publish su `macchina1/command`
4. Wrapper pubblica via CocoaMQTT
5. Broker recapita al Raspberry → ESP8266 → PLC esegue scrittura coil

---

### RICEZIONE RISPOSTA COMANDO

1. PLC esegue → ESP8266 → Raspberry → Broker pubblica su `macchina1/response`
2. Flusso identico a STATUS ma decode `MachineCommandResponse`
3. `delegate.logoLink(didReceiveCommandResponse:for:)`

---

### DISCONNESSIONE

1. Consumer chiama `logoLink.disconnect()` ← intenzionale  
   oppure rete cade ← non intenzionale
2. Wrapper tenta reconnect con backoff esponenziale se non intenzionale
3. Se reconnect fallisce → `delegate.logoLinkDidDisconnect(error:)`
4. Al reconnect riuscito: tutti i subscribe vengono riattivati automaticamente

---

## Topic per macchina

| Topic | Direzione | Tipo messaggio |
|---|---|---|
| `{id}/command` | publish → broker | `MachineCommand` |
| `{id}/response` | broker → subscribe | `MachineCommandResponse` |
| `{id}/status` | broker → subscribe | `MachineStatusResponse` |

---

## Struttura JSON

### MachineCommand (publish su `{id}/command`)
```json
{
  "machine": "macchina1",
  "topic_risposta": "macchina1/response",
  "payload": {
    "action": "writeCoil",
    "markerNumber": 3,
    "value": 1,
    "state": true
  }
}
```

### MachineCommandResponse (subscribe su `{id}/response`)
```json
{
  "machine": "macchina1",
  "payload": {
    "action": "writeCoil",
    "markerNumber": 3,
    "value": 1,
    "state": true
  }
}
```

### MachineStatusResponse (subscribe su `{id}/status`)
```json
{
  "machine": "macchina1",
  "action": "status",
  "state": true,
  "digitalIO": {
    "inputs": [true, false, ...],
    "outputs": [false, true, ...]
  },
  "analogIO": {
    "inputs": [0, 512, ...],
    "outputs": [255, 0]
  }
}
```

---

## Connessione SSL/TLS

- `useTLS: false` → porta 1883, connessione plain
- `useTLS: true` → porta 8883, socket cifrato
- `allowSelfSignedCerts: true` → disabilita verifica catena certificati (utile per broker LAN)
