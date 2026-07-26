#!/bin/bash
echo "Starting NetSentinel..."

# Start bridge
cd /app/bridge
python3 -m venv venv
source venv/bin/activate
uvicorn main:app --host 0.0.0.0 --port 8000 &
echo "Bridge started on :8000"

# Wait for bridge
sleep 3

# Start engine in demo mode by default
IFACE=${IFACE:-""}
if [ -n "$IFACE" ]; then
    echo "Starting live capture on $IFACE"
    /app/engine/build/netsentinel --iface $IFACE --bridge http://localhost:8000 &
else
    echo "Starting demo mode"
    /app/engine/build/netsentinel --demo /app/demo/normal_traffic.pcap --bridge http://localhost:8000 &
fi

# Serve dashboard
echo "Dashboard on http://localhost:5173"
serve -s /app/dashboard/dist -l 5173
