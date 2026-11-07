extends RefCounted
class_name EffectPlayer

const WorldProjectionScript = preload("res://scripts/core/world_projection.gd")

# Draws a painted region from the original Hero World effect atlas.
# Atlas entries are individual illustrations, so animate them with
# a scale/fade tween instead of treating the atlas as a sprite sheet.

static func play(parent: Node, atlas: Texture2D, world_position: Vector2, atlas_region: Rect2, target_size: Vector2, duration: float = 0.42, start_rotation: float = 0.0) -> void:
    if parent == null or atlas == null or atlas_region.size.x <= 0.0 or atlas_region.size.y <= 0.0:
        return
    var sprite := Sprite2D.new()
    sprite.texture = atlas
    sprite.region_enabled = true
    sprite.region_rect = atlas_region
    sprite.centered = true
    sprite.rotation = start_rotation
    sprite.z_as_relative = false
    sprite.z_index = clampi(int(WorldProjectionScript.screen_depth(world_position) / 10.0) + 1, 1, 1024)
    parent.add_child(sprite)
    sprite.global_position = WorldProjectionScript.world_to_screen(world_position)
    var final_scale := Vector2(target_size.x / atlas_region.size.x, target_size.y / atlas_region.size.y)
    sprite.scale = final_scale * 0.52
    sprite.modulate.a = 1.0
    var tween := sprite.create_tween()
    tween.set_parallel(true)
    tween.tween_property(sprite, "scale", final_scale * 1.12, duration * 0.42).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
    tween.tween_property(sprite, "modulate:a", 0.0, duration).set_delay(duration * 0.16)
    tween.chain().tween_callback(sprite.queue_free)
