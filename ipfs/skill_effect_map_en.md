# Skill Effect Map

> **Version:** 1.0
> **Description:** Defines the base enums for the skill system and the index registry for specific effects.

## 1. Base Enums

Constants that define the fundamental framework of skills.

| Category | Key | Value | Note |
| :--- | :--- | :---: | :--- |
| **Damage Type** | `none` | **0** | Utility / Heal |
| | `physical` | **1** | Physical Damage |
| | `magic` | **2** | Magic / Elemental Damage |
| | `true` | **99** | True Damage (Ignores Def) |
| **Activation Mode** | `active` | **0** | Active Skill |
| | `passive` | **1** | Passive Skill |
| **Cost Type** | `none` | **0** | No Cost |
| | `mp` | **1** | Costs Mana Points |
| | `hp` | **2** | Costs Health Points |
| **Target Scope** | `self` | **0** | Self |
| | `enemy_1` | **1** | Single Enemy |
| | `enemy_2` | **2** | 2 Enemies |
| | `enemy_3` | **3** | 3 Enemies |
| | `enemy_4` | **4** | 4 Enemies |
| | `enemy_all` | **99** | All Enemies (AOE) |

## 2. Effect Registry

Specific Buffs, Debuffs, and special mechanics linked via `Index`.

### ❤️ Recovery & Survival
| Index | Attribute | Description |
| :---: | :---: | :--- |
| **100** | hp | Heals HP by **X%**. |
| **110** | mp | Recovers MP by **X%**. |
| **2** | hp | **(Debuff)** Reduces healing received by **X%**. |

### ⚔️ Stat Buffs
*Note: Distinguishes between Flat values and Percentage (%) boosts.*

| Index | Attribute | Type | Description |
| :---: | :---: | :---: | :--- |
| **200** | ap (Attack) | **%** | Increases Attack Power by **X%**. |
| **201** | ap (Attack) | **Flat** | Increases Attack Power by **X**. |
| **202** | dp (Defense) | **%** | Increases Defense Power by **X%**. |
| **203** | dp (Defense) | **Flat** | Increases Defense Power by **X**. |
| **210** | hp (Max) | **Flat** | Increases Max HP by **X**. |
| **211** | hp (Max) | **%** | Increases Max HP by **X%**. |
| **212** | mp (Max) | **Flat** | Increases Max MP by **X**. |
| **213** | mp (Max) | **%** | Increases Max MP by **X%**. |

### 💰 Resources
| Index | Attribute | Description |
| :---: | :---: | :--- |
| **120** | exp | Increases EXP gained by **X%**. |
| **130** | gold | Increases Gold gained by **X%**. |

### 🛡️ Special Mechanics
| Index | Attribute | Description |
| :---: | :---: | :--- |
| **300** | reflect | **Reflect**: Reflects **X%** of damage taken back to the attacker. |