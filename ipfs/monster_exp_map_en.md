# Monster XP & Scaling Map

> **Version:** 1.0  
> **Description:** Defines the experience points granted by monsters and their attribute scaling relative to the player.

## 📊 Data Table

| Rarity | Base XP | Base Scaling | Offset | Effective Strength Range |
| :---: | :---: | :---: | :---: | :--- |
| **1** | 10 | 0.6x | ± 0.1 | **0.5x ~ 0.7x** |
| **2** | 20 | 0.8x | ± 0.1 | **0.7x ~ 0.9x** |
| **3** | 30 | 1.0x | ± 0.15 | **0.85x ~ 1.15x** |
| **4** | 50 | 1.2x | ± 0.2 | **1.0x ~ 1.4x** |

## 💡 Mechanics

*   **Base XP**: The fixed amount of experience points gained upon defeating a monster of this rarity.
*   **Attribute Scaling**: Monster stats are calculated dynamically based on the player's current stats.
    *   **Scaling**: The multiplier applied to the player's stats (e.g., `1.0` equals player stats).
    *   **Offset**: An absolute range of deviation. The final multiplier is randomized between `Scaling - Offset` and `Scaling + Offset`.
*   **Formula**:
    $$ MonsterStats = PlayerStats \times (Scaling \pm Random(0, Offset)) $$