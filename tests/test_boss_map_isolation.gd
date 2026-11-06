extends SceneTree

const BossScript = preload("res://scripts/enemy/boss.gd")

class FakeHero:
    extends Node2D
    var world_map_id: String = "town"
    var dead: bool = false

func _initialize() -> void:
    var boss = BossScript.new()
    boss.set_meta("world_map_id", "moss_crown")
    root.add_child(boss)
    var remote_hero = FakeHero.new()
    remote_hero.world_map_id = "town"
    remote_hero.position = Vector2(20.0, 0.0)
    remote_hero.add_to_group("heroes")
    root.add_child(remote_hero)
    boss.telegraph_timer = 0.01
    boss._update_telegraph(0.02)
    assert(not boss.telegraph_active, "heroes on another map must not trigger this boss telegraph")
    remote_hero.world_map_id = "moss_crown"
    boss.telegraph_timer = 0.01
    boss._update_telegraph(0.02)
    assert(boss.telegraph_active, "a nearby hero on the boss map should trigger the telegraph")
    print("Boss map isolation tests: 2 passed")
    quit()
