#!/bin/bash
# Self-test for rpi-streaming-sensor-base image
# Verifies all key components are installed and functional

PASS=0
WARN=0
FAIL=0

ok()   { echo "  [OK]   $1"; ((PASS++)); }
warn() { echo "  [WARN] $1"; ((WARN++)); }
fail() { echo "  [FAIL] $1"; ((FAIL++)); }

echo "=== Streaming Sensor Base — Self Test ==="
echo ""

# Run firmware-base self-test first (renamed during image build)
if command -v self-test-firmware &>/dev/null; then
    self-test-firmware
    echo ""
fi

echo "--- GStreamer ---"
if command -v gst-launch-1.0 &>/dev/null; then
    VER=$(gst-launch-1.0 --version 2>&1 | head -1)
    ok "gst-launch-1.0: $VER"
else
    fail "gst-launch-1.0 not found"
fi

if command -v gst-inspect-1.0 &>/dev/null; then
    ok "gst-inspect-1.0 available"
else
    fail "gst-inspect-1.0 not found"
fi

# Check key GStreamer plugins
for plugin in videotestsrc videoconvert openh264enc rtspclientsink; do
    if gst-inspect-1.0 $plugin &>/dev/null; then
        ok "GStreamer plugin: $plugin"
    else
        fail "GStreamer plugin missing: $plugin"
    fi
done

# Check libcamerasrc (may fail without hardware, but plugin should be loadable)
if gst-inspect-1.0 libcamerasrc &>/dev/null; then
    ok "GStreamer plugin: libcamerasrc"
else
    warn "GStreamer plugin: libcamerasrc (not loadable — may need camera hardware)"
fi

# Quick pipeline test
if gst-launch-1.0 videotestsrc num-buffers=1 ! fakesink &>/dev/null; then
    ok "GStreamer pipeline: videotestsrc ! fakesink"
else
    fail "GStreamer pipeline test failed"
fi

echo ""
echo "--- libcamera ---"
if command -v cam &>/dev/null; then
    ok "libcamera-tools (cam) available"
else
    warn "libcamera-tools (cam) not found"
fi

echo ""
echo "--- V4L2 ---"
if command -v v4l2-ctl &>/dev/null; then
    ok "v4l2-ctl available"
else
    fail "v4l2-ctl not found"
fi

echo ""
echo "--- MediaMTX ---"
if command -v mediamtx &>/dev/null; then
    VER=$(mediamtx --version 2>&1 || echo "unknown")
    ok "MediaMTX: $VER"
else
    fail "MediaMTX not found"
fi

echo ""
echo "--- Python & OpenCV ---"
if command -v python3 &>/dev/null; then
    PYVER=$(python3 --version 2>&1)
    ok "Python: $PYVER"
else
    fail "Python3 not found"
fi

if NPVER=$(python3 -c "import numpy; print(numpy.__version__)" 2>/dev/null); then
    ok "numpy: $NPVER"
else
    fail "numpy not importable"
fi

if CVVER=$(python3 -c "import cv2; print(cv2.__version__)" 2>/dev/null); then
    ok "OpenCV: $CVVER"
else
    fail "OpenCV not importable"
fi

echo ""
echo "--- Serial Tools ---"
if command -v picocom &>/dev/null; then
    ok "picocom available"
else
    warn "picocom not found"
fi

if command -v setserial &>/dev/null; then
    ok "setserial available"
else
    warn "setserial not found"
fi

echo ""
echo "=== Summary ==="
echo "  Passed: $PASS"
echo "  Warnings: $WARN"
echo "  Failed: $FAIL"

[ $FAIL -eq 0 ] && exit 0 || exit 1
