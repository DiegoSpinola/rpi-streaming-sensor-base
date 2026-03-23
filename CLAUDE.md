# CLAUDE.md

## Project Overview

**rpi-streaming-sensor-base** is a Docker image that provides the common streaming and capture stack for Raspberry Pi sensor projects. It sits between `rpi-firmware-base` (generic Pi utilities) and application-specific images.

```
rpi-firmware-base          ← udev, i2c, GPIO, pinctrl
  └── rpi-streaming-sensor-base   ← THIS IMAGE
        └── app image        ← sensor SDK + custom plugins + config
```

## What's Included

| Category | Packages |
|----------|----------|
| GStreamer | tools, plugins-base/good/bad, libav, rtsp, libcamera |
| libcamera | runtime, tools, V4L2 bridge |
| V4L2 | v4l-utils (USB cameras) |
| Encoding | openh264 (via GStreamer) |
| RTSP | MediaMTX v1.16.3 (static binary) |
| Python | Python 3.11, numpy, OpenCV 4.6 |
| Serial | picocom, setserial (LiDARs) |

## Image Naming

```
registry.hackeneering.com/hackeneering/rpi-streaming-sensor-base:bookworm-arm64-<hash>
registry.hackeneering.com/hackeneering/rpi-streaming-sensor-base:bookworm-arm64-latest
```

Bookworm arm64 only for now. Trixie variant added when needed.

## Project Structure

```
rpi-streaming-sensor-base/
├── Dockerfile.bookworm           # Image definition (FROM rpi-firmware-base)
├── self-test.sh                  # Component verification script
├── docker-compose.yml            # Build orchestration
├── docker-compose.selftest.yml   # Portainer test stack
├── .config                       # Alloy config
├── alloy.sh                      # Alloy environment launcher
├── build.sh / xbuild.sh          # Build scripts (native / cross-compile)
├── deploy.sh / xdeploy.sh        # Deploy scripts (native / cross-compile)
├── run.sh                        # Run service locally
├── CLAUDE.md                     # This file
└── README.md
```

## Build & Deploy

```bash
./alloy.sh              # Enter Alloy container (if not already inside)
bash xbuild.sh           # Cross-compile build (x86 → arm64)
bash xdeploy.sh          # Build + push to registry.hackeneering.com
```

All scripts except `alloy.sh` require the Alloy environment (`$CUSTOM_HOSTNAME == "alloy"`).

## Downstream Usage

Application images build on top:

```dockerfile
FROM registry.hackeneering.com/hackeneering/rpi-streaming-sensor-base:bookworm-arm64-latest

# Add sensor-specific SDK
RUN apt-get update && apt-get install -y arducam-tof-sdk-dev ...

# Add custom GStreamer plugin
COPY libgsttofsrc.so /usr/lib/aarch64-linux-gnu/gstreamer-1.0/

# Add pipeline scripts
COPY start-mediamtx.sh /app/
```

## Design Principles

- **Start lean** — only include what's shared across 2+ projects
- **Promote up** — when a pattern repeats across apps, add it here
- **Transparent upgrades** — app images use `:latest` tag, base updates don't require app changes

## Self-test

Run `self-test` inside the container to verify all components:

```bash
docker run --rm --privileged \
    registry.hackeneering.com/hackeneering/rpi-streaming-sensor-base:bookworm-arm64-latest \
    self-test
```

## Known Downstream Applications

- Arducam T2 RGBD ToF camera streaming
- RGB-only camera streaming
- LiDAR streaming (USB/serial)
- Experimental ToF project
