#!/bin/sh
set -e

# Start MediaMTX in the background
echo "Starting MediaMTX RTSP server..."
/usr/local/bin/mediamtx /config/mediamtx.yml &
MEDIAMTX_PID=$!

# Wait a moment for MediaMTX to start
sleep 2

# Check if MediaMTX is running
if ! kill -0 $MEDIAMTX_PID 2>/dev/null; then
    echo "ERROR: MediaMTX failed to start"
    exit 1
fi

echo "MediaMTX started successfully (PID: $MEDIAMTX_PID)"

# Trap SIGTERM and SIGINT to gracefully shutdown
cleanup() {
    echo "Shutting down..."
    kill -TERM $MEDIAMTX_PID 2>/dev/null || true
    wait $MEDIAMTX_PID 2>/dev/null || true
    exit 0
}

trap cleanup SIGTERM SIGINT

# Start blinkbridge
echo "Starting blinkbridge..."
exec python -m blinkbridge.main
