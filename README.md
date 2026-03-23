# rpi-streaming-sensor-base

Docker base image for Raspberry Pi sensor streaming projects. Provides GStreamer, libcamera, MediaMTX RTSP server, Python/OpenCV, and serial tools on top of [rpi-firmware-base](https://github.com/DiegoSpinola/rpi-firmware-base).

## Quick Start

```bash
# Pull and run self-test
docker pull registry.hackeneering.com/hackeneering/rpi-streaming-sensor-base:bookworm-arm64-latest
docker run --rm --privileged \
    registry.hackeneering.com/hackeneering/rpi-streaming-sensor-base:bookworm-arm64-latest \
    self-test

# Interactive shell
docker run -it --privileged \
    registry.hackeneering.com/hackeneering/rpi-streaming-sensor-base:bookworm-arm64-latest \
    bash
```

## What's Inside

| Category | Details |
|----------|---------|
| **GStreamer 1.22** | core, base, good, bad, libav, rtsp, libcamera plugins |
| **libcamera** | Runtime + tools + V4L2 bridge (CSI cameras) |
| **V4L2** | v4l-utils (USB cameras) |
| **MediaMTX v1.16.3** | Standalone RTSP relay server |
| **Python 3.11** | numpy 1.24, OpenCV 4.6 |
| **Serial** | picocom, setserial (LiDARs, serial sensors) |

## Building Your App Image

```dockerfile
FROM registry.hackeneering.com/hackeneering/rpi-streaming-sensor-base:bookworm-arm64-latest

# Your sensor SDK
RUN apt-get update && apt-get install -y your-sensor-sdk

# Your GStreamer plugin
COPY libgstyourplugin.so /usr/lib/aarch64-linux-gnu/gstreamer-1.0/

# Your pipeline config
COPY start-stream.sh /app/
CMD ["bash", "/app/start-stream.sh"]
```

## Building & Deploying This Image

Requires the [Alloy framework](https://github.com/igma-company/alloy-template).

```bash
./alloy.sh           # Enter Alloy environment
bash xbuild.sh       # Cross-compile (x86 → arm64)
bash xdeploy.sh      # Push to registry.hackeneering.com
```

## Portainer Deployment

Use `docker-compose.selftest.yml` as a stack in Portainer:

```yaml
services:
  selftest:
    image: registry.hackeneering.com/hackeneering/rpi-streaming-sensor-base:bookworm-arm64-latest
    privileged: true
    command: self-test
    restart: "no"
```

## Image Hierarchy

```
debian:bookworm-slim
  └── rpi-firmware-base           (udev, i2c, GPIO, pinctrl, vcgencmd)
        └── rpi-streaming-sensor-base   (GStreamer, libcamera, MediaMTX, Python/OpenCV)
              └── your-app-image        (sensor SDK, custom plugins, pipeline config)
```

## Variant

**Bookworm arm64 only**. Trixie variant will be added when needed.
