import requests
import time

# Replace with your WSL IP
SERVER_URL = "http://172.29.151.248:8000/send"

PLAYER_ID = "windows_cheater"

def send_movement(position, velocity):
    payload = {
        "type": "movement",
        "player": PLAYER_ID,
        "position": position,
        "velocity": velocity
    }

    print("\nSending:", payload)

    try:
        r = requests.post(SERVER_URL, json=payload, timeout=2)
        print("Server Response:", r.json())
    except Exception as e:
        print("Error:", e)


def windows_speedhack():
    print("\n=== WINDOWS SUPER SPEEDHACK ACTIVATED ===")
    print("Cheat is running…")

    pos = [0, 0, 0]

    # EXTREME SPEEDHACK: teleport 500+ meters EVERY packet
    for step in range(1, 20):

        # TELEPORT + EXTREME SPEED
        jump_distance = step * 500     # 500m per packet = guaranteed ban
        pos = [0, 0, jump_distance]

        vel = [0, 0, 0]                # velocity spoof removed

        send_movement(pos, vel)

        time.sleep(0.05)               # send faster packets


if __name__ == "__main__":
    windows_speedhack()  # AUTORUNS SUPER SPEEDHACK
