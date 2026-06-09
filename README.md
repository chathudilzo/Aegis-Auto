# Aegis-Auto: Automotive Infotainment Dashboard & Digital Twin HUD

A high-performance, landscape-oriented EV cockpit dashboard and media cluster built with Flutter. This project simulates a modern vehicle human-machine interface (HMI), processing real-time telemetry from an independent Python server while managing complex, asynchronous media streams.

---

## ⚡ Key Features

* **3D Rigged Vehicle Integration:** Renders a responsive, interactive 3D model of the car using hardware-accelerated vectors, allowing granular control over moving components.
* **Live Hardware Telemetry HUD:** Establishes a persistent network pipeline with an external Python vehicle simulator using WebSockets to drive responsive gauge readouts with zero layout lag.
* **Vector Path Navigation:** Integrates localized map caching and dedicated routing vectors capable of painting clean navigational paths over night-friendly obsidian map styles.
* **Intelligent Proxy Media Routing:** Decouples raw audio streams from video network endpoints using a secure proxy architecture to bypass content network IP-binding restrictions.
* **Tactile Waveform Scope:** Incorporates a customized visualizer that mirrors premium automotive diagnostic tools, automatically idling to save system resources when audio state alters.

---

## 📦 Core Dependencies

This project prioritizes direct API interaction over closed "black-box" wrappers:

* `flutter_riverpod` - State management core separating computational tasks from the user interface thread.
* `just_audio` & `audio_session` - Low-level player configurations handling network buffers and audio focus profiles.
* `web_socket_channel` - Low-latency I/O stream handler mapping inbound Python telemetry data.
* `o3d` - WebGL 3D asset controller managing rigged mesh elements.
* `flutter_osm_plugin` - Mapping controller selected for vector route plotting capabilities.
* `siri_wave` - Computational math canvas creating reactive physics waveforms.
* `http` - Basic network requests querying open source streaming directories.

---

## 🛠️ Local Environment & Hardware Verification

### Prerequisites
* Flutter SDK (v3.22.0 or higher)
* Python 3.10+ (with `websockets` installed via pip)

### Setting up the Hardware Emulator
Navigate to your mock engine directory and fire up the python script to begin broadcasting telemetry packets:
```bash
python server.py

Physical Device Network Bridging: If you deploy this project to a physical phone instead of a desktop emulator, connecting directly to localhost or 127.0.0.1 will block incoming telemetry. You must connect your development machine and your physical mobile phone to the same mobile hotspot to bridge them onto the identical network subnet, then change the connection string in your code to target your computer's local IP address.
