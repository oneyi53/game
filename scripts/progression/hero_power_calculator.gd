class_name HeroPowerCalculator
extends RefCounted

# Original, display-only power estimate. It never changes combat stats.
# Keep this calculation in one place so active and reserve heroes use
# exactly the same level, equipment and camp inputs.

static func final_stats(hero_data: Dictionary, hero_level: int, attack_growth_pct: float, hp_growth_pct: float, equipment_bonus: Dictionary, camp_attack_pct: float, camp_hp_pct: float, loose_bonus: Dictionary) -> Dictionary:
    var growth_steps: int = maxi(0, hero_level - 1)
    var max_hp: int = int(round(float(hero_data.get("hp", 0)) * pow(1.0 + hp_growth_pct / 100.0, float(growth_steps))))
    var attack: int = int(round(float(hero_data.get("attack", 0)) * pow(1.0 + attack_growth_pct / 100.0, float(growth_steps))))
    var defense: int = int(hero_data.get("defense", 0))

    max_hp = int(round(float(max_hp) * (1.0 + float(equipment_bonus.get("hp_pct", 0)) / 100.0)))
    attack = int(round(float(attack) * (1.0 + float(equipment_bonus.get("attack_pct", 0)) / 100.0)))
    defense = int(round(float(defense) * (1.0 + float(equipment_bonus.get("defense_pct", 0)) / 100.0)))

    attack = int(round(float(attack) * (1.0 + camp_attack_pct / 100.0)))
    max_hp = int(round(float(max_hp) * (1.0 + camp_hp_pct / 100.0)))

    attack += int(loose_bonus.get("attack", 0))
    max_hp += int(loose_bonus.get("hp", 0))
    defense += int(loose_bonus.get("defense", 0))

    return {
        "attack": attack,
        "max_hp": max_hp,
        "defense": defense,
        "crit_chance": float(equipment_bonus.get("crit_pct", 0)) / 100.0,
        "crit_damage_pct": int(equipment_bonus.get("crit_damage_pct", 0)),
        "attack_speed_pct": int(equipment_bonus.get("attack_speed_pct", 0)),
        "move_speed": float(hero_data.get("move_speed", 0)),
        "attack_range": float(hero_data.get("attack_range", 0))
    }

static func power_from_stats(stats: Dictionary) -> int:
    var score: float = float(stats.get("attack", 0)) * 10.0
    score += float(stats.get("max_hp", 0))
    score += float(stats.get("defense", 0)) * 10.0
    score += float(stats.get("crit_chance", 0.0)) * 100.0
    score += float(stats.get("crit_damage_pct", 0)) * 2.0
    score += float(stats.get("attack_speed_pct", 0)) * 3.0
    score += float(stats.get("move_speed", 0)) * 0.5
    score += float(stats.get("attack_range", 0)) * 0.5
    return maxi(0, int(round(score)))

static func calculate(hero_data: Dictionary, hero_level: int, attack_growth_pct: float, hp_growth_pct: float, equipment_bonus: Dictionary, camp_attack_pct: float, camp_hp_pct: float, loose_bonus: Dictionary) -> int:
    return power_from_stats(final_stats(hero_data, hero_level, attack_growth_pct, hp_growth_pct, equipment_bonus, camp_attack_pct, camp_hp_pct, loose_bonus))
