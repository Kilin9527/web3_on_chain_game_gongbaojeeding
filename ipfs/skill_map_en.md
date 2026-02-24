# Skill Map Documentation

> **Version:** 1.0
> **Description:** Defines skill parameters and progression for Common skills and Class-specific skills (Warrior).

## 1. Legend
*   **Mode**: `0`=Active, `1`=Passive
*   **Type**: `0`=Support/None, `1`=Physical, `2`=Elemental
*   **Target**: `0`=Self, `1`=Single Enemy, `3`=All Enemies
*   **Cost**: `Type 1`=MP, `Type 2`=Special Resource/HP

---

## 2. Common Skills
Basic skills available to all character classes.

### ⚔️ Attack Skills

| Skill Name | Type | Target | Mode | Description & Progression |
| :--- | :---: | :---: | :---: | :--- |
| **Normal Attack** | Phy | Single | Active | **Basic attack.**<br>Unlock: Lv 1<br>Power: 1.0 (Fixed) |
| **Power Attack** | Phy | Single | Active | **Higher damage at a cost.**<br>Unlock: Lv 2 ~ 35<br>Power: 1.1 ➔ 1.5<br>Cost: 3 ➔ 35 |
| **Charged Attack** | Phy | Single | Active | **High burst damage with cooldown.**<br>Cooldown: 1 Turn<br>Unlock: Lv 15 ~ 55<br>Power: 1.5 ➔ 2.0<br>Cost: 15 ➔ 60 |

### 🛡️ Support Skills

| Skill Name | Type | Target | Mode | Description & Progression |
| :--- | :---: | :---: | :---: | :--- |
| **Heal** | Supp | Self | Active | **Restores HP.**<br>Unlock: Lv 1 ~ 30<br>Effect(100): Power 0.2 ➔ 0.45<br>Cost: 5 ➔ 40 |
| **Meditate** | Supp | Self | Active | **Consumes resource (Type 2) to restore MP (110).**<br>Cooldown: 3 ➔ 2 Turns<br>Unlock: Lv 5 ~ 30<br>Effect(110): Power 0.2 ➔ 0.4<br>Cost: 0.2 ➔ 0.1 |

### 🎁 Bonus Skills

| Skill Name | Type | Target | Mode | Description & Progression |
| :--- | :---: | :---: | :---: | :--- |
| **Exp increase** | - | Self | **Pass** | **Increases Exp gain (120).**<br>Unlock: Lv 10 ~ 55<br>Value: +5% ➔ +20% |
| **Gold increase** | - | Self | **Pass** | **Increases Gold gain (130).**<br>Unlock: Lv 10 ~ 55<br>Value: +5% ➔ +20% |

---

## 3. Warrior Skills

### ⚔️ Attack Skills

| Skill Name | Type | Target | Mode | Description & Progression |
| :--- | :---: | :---: | :---: | :--- |
| **Mortal Strike** | Phy | Single | Active | **High damage + Debuff.**<br>Cooldown: 2 Turns<br>Unlock: Lv 12 ~ 60<br>Power: 1.2 ➔ 1.8<br>Cost: 20 ➔ 100<br>Effect(101): Power 0.3 ➔ 0.7 (3 Turns) |
| **Sweeping Strike** | Phy | **AOE** | Active | **Area of Effect damage.**<br>Unlock: Lv 15 ~ 70<br>Power: 0.7 ➔ 1.1<br>Cost: 25 ➔ 70 |
| **Overpower** | Phy | Single | **Pass** | **Increases specific attack power.**<br>Unlock: Lv 20 ~ 40<br>Power: 1.1 ➔ 1.5 |
| **Attack increase** | - | Self | **Pass** | **Increases base Attack stats.**<br>Unlock: Lv 7 ~ 42<br>Value: 10% ➔ 30% |

### 🛡️ Defense Skills

| Skill Name | Type | Target | Mode | Description & Progression |
| :--- | :---: | :---: | :---: | :--- |
| **Thorns** | Phy | Self | Active | **Reflect damage.**<br>Unlock: Lv 9 ~ 60<br>Cost: 17 ➔ 100<br>Effect: <br>Lv1-2: Reflect(300) 0.3 ➔ 0.4<br>Lv3: Changes to Effect(101) 0.7 *(Note: Effect ID changes in data)* |
| **Toughness** | - | Self | **Pass** | **Increases Max HP & Defense.**<br>Unlock: Lv 16 ~ 60<br>HP Boost(210): +100 ➔ +500<br>Def Boost(203): +20 ➔ +80 |

### 🔮 Support Skills

| Skill Name | Type | Target | Mode | Description & Progression |
| :--- | :---: | :---: | :---: | :--- |
| **Elemental Strike** | **Elem** | Single | Active | **Deals elemental damage.**<br>Unlock: Lv 9 ~ 69<br>Power: 0.9 ➔ 1.1<br>Cost: 10 ➔ 40 |