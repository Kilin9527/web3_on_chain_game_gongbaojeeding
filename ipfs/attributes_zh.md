# 角色属性文档 (Role Attributes)

> **版本:** 1.0  
> **描述:** 定义角色的各项属性体系。

## 1. 基础属性 (Basic Attributes)

基础属性是角色的核心数值，特定的基础属性会按比例影响角色的二级属性（如攻击力、防御力等）。

### **生命与法力**
*   **HP (hp)**
    *   **名称**: 生命值 (Health Points)
    *   **描述**: 生命值。一旦降为0，角色死亡，游戏结束。
*   **MP (mp)**
    *   **名称**: 法力值 (Mana Points)
    *   **描述**: 法力值。使用法术时消耗。

### **核心五维**

#### **1. 力量 (Strength)**
*   **标识**: `str`
*   **描述**: 影响角色的物理攻击力、物理防御力、物理穿透、物理命中率和生命值。
*   **属性加成 (每点力量)**:
    *   物理攻击力 (physical_attack_power): +5
    *   物理防御力 (physical_defense_power): +1
    *   物理穿透 (physical_penetration): +1
    *   物理命中率 (physical_hit_rate): +2
    *   生命值 (HP): +2

#### **2. 敏捷 (Agility)**
*   **标识**: `agi`
*   **描述**: 影响角色的物理攻击力、物理命中率、物理闪避率、物理穿透和生命值。
*   **属性加成 (每点敏捷)**:
    *   物理攻击力 (physical_attack_power): +3
    *   物理闪避率 (physical_evasion_rate): +3
    *   物理穿透 (physical_penetration): +3
    *   物理命中率 (physical_hit_rate): +3
    *   生命值 (hp): +1

#### **3. 耐力 (Stamina)**
*   **标识**: `sta`
*   **描述**: 影响角色的生命值、物理防御力、物理闪避率、魔法防御力和魔法闪避率。
*   **属性加成 (每点耐力)**:
    *   物理防御力 (physical_defense_power): +3
    *   物理闪避率 (physical_evasion_rate): +1
    *   魔法防御力 (magic_defense_power): +1
    *   魔法闪避率 (magic_evasion_rate): +1
    *   生命值 (hp): +5

#### **4. 智力 (Intellect)**
*   **标识**: `int`
*   **描述**: 影响角色的魔法攻击力、魔法防御力、魔法穿透、魔法命中率和法力值。
*   **属性加成 (每点智力)**:
    *   魔法攻击力 (magic_attack_power): +5
    *   魔法防御力 (magic_defense_power): +2
    *   魔法穿透 (magic_penetration): +1
    *   魔法命中率 (magic_hit_rate): +2
    *   法力值 (mp): +2

#### **5. 精神 (Spirit)**
*   **标识**: `spi`
*   **描述**: 影响角色的魔法攻击力、魔法防御力、魔法命中率、魔法闪避率和法力值。
*   **属性加成 (每点精神)**:
    *   魔法攻击力 (magic_attack_power): +1
    *   魔法防御力 (magic_defense_power): +3
    *   魔法命中率 (magic_hit_rate): +2
    *   魔法闪避率 (magic_evasion_rate): +2
    *   法力值 (mp): +4

---

## 2. 通用属性 (General Attributes)

| 标识 (Type) | 名称 | 描述 |
| :--- | :--- | :--- |
| **critical_hit_chance** | 暴击率 | 对敌人造成暴击伤害的概率。 |
| **critical_damage** | 暴击伤害 | 暴击伤害倍率。基础暴击伤害为正常伤害的 150%。 |
| **hp_recovery** | 生命恢复 | 每回合自动恢复的生命值。 |
| **mp_recovery** | 法力恢复 | 每回合自动恢复的法力值。 |
| **hp_steal** | 生命吸取 | 每次攻击吸收的生命值。 |
| **mp_steal** | 法力吸取 | 每次攻击吸收的法力值。 |

## 3. 物理属性 (Physical Attributes)

| 标识 (Type) | 名称 | 描述 |
| :--- | :--- | :--- |
| **physical_attack_power** | 物理攻击力 | 对敌人造成物理伤害。 |
| **physical_defense_power** | 物理防御力 | 抵抗来自敌人的物理伤害。 |
| **physical_hit_rate** | 物理命中率 | 命中敌人的概率，默认为 90%。 |
| **physical_evasion_rate** | 物理闪避率 | 躲避敌人攻击的概率，默认为 0%。 |
| **physical_penetration** | 物理穿透 | 无视敌人的物理防御力。 |

## 4. 魔法属性 (Magical Attributes)

| 标识 (Type) | 名称 | 描述 |
| :--- | :--- | :--- |
| **magic_attack_power** | 魔法攻击力 | 对敌人造成魔法伤害。 |
| **magic_defense_power** | 魔法防御力 | 抵抗来自敌人的魔法伤害。 |
| **magic_hit_rate** | 魔法命中率 | 法术命中敌人的概率，默认为 90%。 |
| **magic_evasion_rate** | 魔法闪避率 | 躲避敌人魔法攻击的概率，默认为 0%。 |
| **magic_penetration** | 魔法穿透 | 无视敌人的魔法防御力。 |
| **fire_damage** | 火属性伤害 | 火属性造成的伤害。 |
| **cold_damage** | 冰属性伤害 | 冰属性造成的伤害。 |
| **wind_damage** | 风属性伤害 | 风属性造成的伤害。 |
| **thunder_damage** | 雷属性伤害 | 雷属性造成的伤害。 |
| **earth_damage** | 地属性伤害 | 地属性造成的伤害。 |
| **light_damage** | 光属性伤害 | 光属性造成的伤害。 |
| **dark_damage** | 暗属性伤害 | 暗属性造成的伤害。 |
| **chaos_damage** | 混沌伤害 | 混沌属性造成的伤害。 |
| **fire_resistance** | 火属性抗性 | 对火属性伤害的抗性。 |
| **cold_resistance** | 冰属性抗性 | 对冰属性伤害的抗性。 |
| **wind_resistance** | 风属性抗性 | 对风属性伤害的抗性。 |
| **thunder_resistance** | 雷属性抗性 | 对雷属性伤害的抗性。 |
| **earth_resistance** | 地属性抗性 | 对地属性伤害的抗性。 |
| **light_resistance** | 光属性抗性 | 对光属性伤害的抗性。 |
| **dark_resistance** | 暗属性抗性 | 对暗属性伤害的抗性。 |
| **chaos_resistance** | 混沌抗性 | 对混沌属性伤害的抗性。 |