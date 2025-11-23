<div align="center">

# 🎯 ZK-Sniper
### The First FPS with Non-Invasive ZK Anti-Cheat

![Starknet](https://img.shields.io/badge/Starknet-Powered-blue?logo=starknet)
![Godot](https://img.shields.io/badge/Godot-4.3-478cbf?logo=godot-engine&logoColor=white)
![Cairo](https://img.shields.io/badge/Cairo-1.0-orange)
![License](https://img.shields.io/badge/License-MIT-green)


<p align="center">
  <img src="path/to/your/screenshot_or_gif.gif" alt="Gameplay Demo" width="600">
  <br>
  <!-- <em>(Replace this line with a GIF of your gameplay!)</em> -->
</p>

</div>

---

## 🛑 The Problem
Current industry standards for anti-cheat (Vanguard, Ricochet, Easy Anti-Cheat) rely on an **invasive philosophy**:
1.  **Kernel Access (Ring 0):** They run at the highest privilege level of your OS.
2.  **Privacy Nightmare:** They scan your entire hard drive and memory.
3.  **Vulnerable:** Despite this, cheaters bypass them using hardware cheats (DMA).

## ✅ Our Solution: "Proof of Shot"
**ZK-Sniper** moves the anti-cheat logic from the Client's Kernel to the **Starknet Blockchain**. We don't scan your files; we verify the **Physics** of your actions.

* **Client Side:** The game generates a cryptographically secure proof that the shot followed the laws of physics (Recoil, Cooldown, Vector).
* **Chain Side:** The Starknet contract acts as the "Judge."
    * Valid Proof = Hit Registered + Score Updated.
    * Invalid Proof (Aimbot/No-Recoil) = **Transaction Reverted.**

> *"We verify the shot, not the user's operating system."*

---

## 🏗️ Architecture

We utilize the **Dojo Engine** to sync game state on-chain. Here is how the data flows:

```mermaid
sequenceDiagram
    participant P as Player (Godot)
    participant K as Katana (Sequencer)
    participant C as Cairo Contract (Judge)
    participant T as Torii (Indexer)

    P->>P: Player Shoots (Input: Angle, Recoil)
    P->>K: Send Transaction: shoot(input_data)
    K->>C: Execute System
    C->>C: Verify Physics (assert recoil > 0)
    alt Physics Valid
        C->>C: Update Kill Count
        C-->>K: State Change Accepted
    else Physics Invalid (Cheat)
        C-->>K: PANIC: REVERT TRANSACTION
    end
    K->>T: State Update
    T-->>P: Sync Scoreboard
