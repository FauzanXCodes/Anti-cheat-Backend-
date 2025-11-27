from fastapi import FastAPI, Request
import uvicorn
import time
import math
import json
import os
from hashlib import sha256

app = FastAPI()

# ----------------------------------------
# Configuration
# ----------------------------------------
MAX_SPEED = 12.0                # legitimate max speed (m/s)
SPEED_TOLERANCE = 1.3           # 30% tolerance
MAX_TELEPORT_DIST = 8.0         # max allowed instant movement
MIN_DT = 0.001                  # avoid divide-by-zero

player_state = {}               # memory-only player states
EVIDENCE_DIR = "evidence"
os.makedirs(EVIDENCE_DIR, exist_ok=True)


# ----------------------------------------
# Helper functions
# ----------------------------------------

def save_evidence(player_id: str, payload: dict) -> str:
    raw = json.dumps(payload, sort_keys=True).encode()
    h = sha256(raw).hexdigest()

    path = os.path.join(EVIDENCE_DIR, f"{h}.json")
    with open(path, "wb") as f:
        f.write(raw)

    return h


def vec_len(vec):
    return math.sqrt(vec[0] ** 2 + vec[1] ** 2 + vec[2] ** 2)


# ----------------------------------------
# Anti-Cheat Detection Logic
# ----------------------------------------

def detect_speedhack(player_id: str, payload: dict):
    now = time.time()
    pos = payload.get("position")
    vel = payload.get("velocity")

    px, py, pz = float(pos[0]), float(pos[1]), float(pos[2])
    vx, vy, vz = float(vel[0]), float(vel[1]), float(vel[2])

    # Save evidence first
    evidence_hash = save_evidence(player_id, payload)

    # First ever packet from this player
    if player_id not in player_state:
        player_state[player_id] = {
            "pos": (px, py, pz),
            "timestamp": now,
            "velocity": (vx, vy, vz)
        }
        return {"status": "ok", "msg": "first packet", "evidence": evidence_hash}

    prev = player_state[player_id]
    old_pos = prev["pos"]
    old_time = prev["timestamp"]
    old_vel = prev.get("velocity", (0.0, 0.0, 0.0))

    dt = now - old_time
    if dt < MIN_DT:
        dt = MIN_DT

    # movement delta
    dx = px - old_pos[0]
    dy = py - old_pos[1]
    dz = pz - old_pos[2]

    dist = math.sqrt(dx*dx + dy*dy + dz*dz)
    inst_speed = dist / dt
    client_speed = vec_len((vx, vy, vz))
    old_speed = vec_len(old_vel)

    # ----------------------------------------
    # ZERO VELOCITY SPOOF — REMOVED PER REQUEST
    # ----------------------------------------

    # ----------------------------------------
    # TELEPORT HACK
    # ----------------------------------------
    if dist > MAX_TELEPORT_DIST and inst_speed > MAX_SPEED * 2:
        cheated_speed = inst_speed + 500
        print(f"⚠️ TELEPORT HACK DETECTED — Player {player_id} BANNED! Speed: {cheated_speed}")

        return {
            "status": "banned",
            "msg": "You have been banned",
            "type": "teleport",
            "speed": cheated_speed,
            "evidence": evidence_hash
        }

    # ----------------------------------------
    # SPEED HACK
    # ----------------------------------------
    if inst_speed > MAX_SPEED * SPEED_TOLERANCE:
        cheated_speed = inst_speed + 500
        print(f"⚠️ SPEEDHACK DETECTED — Player {player_id} BANNED! Speed: {cheated_speed}")

        return {
            "status": "banned",
            "msg": "You have been banned",
            "type": "speedhack",
            "speed": cheated_speed,
            "evidence": evidence_hash
        }

    # ----------------------------------------
    # Everything OK → Update state
    # ----------------------------------------
    player_state[player_id] = {
        "pos": (px, py, pz),
        "timestamp": now,
        "velocity": (vx, vy, vz)
    }

    return {
        "status": "ok",
        "inst_speed": inst_speed,
        "client_speed": client_speed,
        "evidence": evidence_hash
    }


# ----------------------------------------
# Main API Endpoint
# ----------------------------------------

@app.post("/send")
async def receive_data(request: Request):
    data = await request.json()

    print("\n--- Incoming Data From Godot ---")
    print(data)

    player = data.get("player")
    typ = data.get("type")

    if typ == "movement":
        return detect_speedhack(player, data)

    # fallback
    evidence_hash = save_evidence(player, data)
    return {"status": "ok", "received": data, "evidence": evidence_hash}


# ----------------------------------------
# Run server
# ----------------------------------------

if __name__ == "__main__":
    uvicorn.run("server:app", host="0.0.0.0", port=8000, reload=True)
