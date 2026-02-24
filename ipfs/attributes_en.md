# Role Attributes Documentation

> **Version:** 1.0  
> **Description:** Defines the attributes of roles.

## 1. Basic Attributes

Basic attributes are the core stats of a character. Specific basic attributes affect secondary stats (like attack power, defense, etc.) based on defined ratios.

### **Health & Mana**
*   **HP (hp)**
    *   **Name**: Health Points
    *   **Description**: Health Points. Once it drops to 0, the character dies and the game ends.
*   **MP (mp)**
    *   **Name**: Mana Points
    *   **Description**: Mana Points. Consumed when using spells.

### **Core Stats**

#### **1. Strength (Strength)**
*   **Type**: `str`
*   **Description**: Affects the character's physical attack power, physical defense power, physical penetration, physical hit rate, and HP.
*   **Affects (Per Point)**:
    *   Physical Attack Power: +5
    *   Physical Defense Power: +1
    *   Physical Penetration: +1
    *   Physical Hit Rate: +2
    *   HP: +2

#### **2. Agility (Agility)**
*   **Type**: `agi`
*   **Description**: Affects the character's physical attack power, physical hit rate, physical evasion rate, physical penetration and HP.
*   **Affects (Per Point)**:
    *   Physical Attack Power: +3
    *   Physical Evasion Rate: +3
    *   Physical Penetration: +3
    *   Physical Hit Rate: +3
    *   HP: +1

#### **3. Stamina (Stamina)**
*   **Type**: `sta`
*   **Description**: Affects the character's HP, physical defense power, physical evasion rate, magic defense power, and magic evasion rate.
*   **Affects (Per Point)**:
    *   Physical Defense Power: +3
    *   Physical Evasion Rate: +1
    *   Magic Defense Power: +1
    *   Magic Evasion Rate: +1
    *   HP: +5

#### **4. Intellect (Intellect)**
*   **Type**: `int`
*   **Description**: Affects the character's magic attack power, magic defense power, magic penetration, magic hit rate and MP.
*   **Affects (Per Point)**:
    *   Magic Attack Power: +5
    *   Magic Defense Power: +2
    *   Magic Penetration: +1
    *   Magic Hit Rate: +2
    *   MP: +2

#### **5. Spirit (Spirit)**
*   **Type**: `spi`
*   **Description**: Affects the character's magic attack power, magic defense power, magic hit rate, magic evasion rate and MP.
*   **Affects (Per Point)**:
    *   Magic Attack Power: +1
    *   Magic Defense Power: +3
    *   Magic Hit Rate: +2
    *   Magic Evasion Rate: +2
    *   MP: +4

---

## 2. General Attributes

| Type | Name | Description |
| :--- | :--- | :--- |
| **critical_hit_chance** | Critical Hit Chance | The probability of dealing critical damage to enemies. |
| **critical_damage** | Critical Damage | The base critical damage is 150% of normal damage. |
| **hp_recovery** | HP Recovery | The health automatically restored per turn. |
| **mp_recovery** | MP Recovery | The mana automatically restored per turn. |
| **hp_steal** | HP Steal | The health absorbed with each attack. |
| **mp_steal** | MP Steal | The mana absorbed with each attack. |

## 3. Physical Attributes

| Type | Name | Description |
| :--- | :--- | :--- |
| **physical_attack_power** | Physical Attack Power | Deals physical damage to enemies. |
| **physical_defense_power** | Physical Defense Power | Resists physical damage from enemies. |
| **physical_hit_rate** | Physical Hit Rate | The probability of hitting an enemy, default 90%. |
| **physical_evasion_rate** | Physical Evasion Rate | The probability of dodging an enemy's attack, default 0%. |
| **physical_penetration** | Physical Penetration | Ignores the enemy's defense. |

## 4. Magical Attributes

| Type | Name | Description |
| :--- | :--- | :--- |
| **magic_attack_power** | Magic Attack Power | Deals magical damage to enemies. |
| **magic_defense_power** | Magic Defense Power | Resists magical damage from enemies. |
| **magic_hit_rate** | Magic Hit Rate | The probability of a spell hitting an enemy, default 90%. |
| **magic_evasion_rate** | Magic Evasion Rate | The probability of dodging an enemy's magical attack, default 0%. |
| **magic_penetration** | Magic Penetration | Ignores the enemy's magic defense. |
| **fire_damage** | Fire Attribute Damage | Fire Attribute Damage. |
| **cold_damage** | Cold Attribute Damage | Cold Attribute Damage. |
| **wind_damage** | Wind Attribute Damage | Wind Attribute Damage. |
| **thunder_damage** | Thunder Attribute Damage | Thunder Attribute Damage. |
| **earth_damage** | Earth Attribute Damage | Earth Attribute Damage. |
| **light_damage** | Light Attribute Damage | Light Attribute Damage. |
| **dark_damage** | Dark Attribute Damage | Dark Attribute Damage. |
| **chaos_damage** | Chaos Damage | Chaos Damage. |
| **fire_resistance** | Fire Attribute Resistance | Fire Attribute Resistance. |
| **cold_resistance** | Cold Attribute Resistance | Cold Attribute Resistance. |
| **wind_resistance** | Wind Attribute Resistance | Wind Attribute Resistance. |
| **thunder_resistance** | Thunder Attribute Resistance | Thunder Attribute Resistance. |
| **earth_resistance** | Earth Attribute Resistance | Earth Attribute Resistance. |
| **light_resistance** | Light Attribute Resistance | Light Attribute Resistance. |
| **dark_resistance** | Dark Attribute Resistance | Dark Attribute Resistance. |
| **chaos_resistance** | Chaos Resistance | Chaos Resistance. |