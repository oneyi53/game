class_name SaveManager
extends RefCounted

# Local save only. No network code anywhere in this project.
# save.json is the current save, save_backup.json is the previous one.
# Loading: main save first, then backup if the main save is broken.
# No files means "new_game"; existing but unusable files mean "corrupted".
# A valid backup is preserved when the main save is corrupt.

const SAVE_PATH: String = "user://save.json"
const BACKUP_PATH: String = "user://save_backup.json"
const SCHEMA_VERSION: int = 1

func default_data() -> Dictionary:
    return {
        "schema_version": SCHEMA_VERSION,
        "gold": 0,
        "chest_opened": false,
        "boss_defeated": false,
        "player_position": null,
        "heroes": [],
    }

func save_game(data: Dictionary) -> bool:
    var payload: Dictionary = data.duplicate(true)
    payload["schema_version"] = SCHEMA_VERSION
    if FileAccess.file_exists(SAVE_PATH):
        # Never replace a known-good backup with a corrupt main save.
        # This matters after load_game() has recovered from BACKUP_PATH:
        # the damaged main file remains until this next successful save.
        var current_main: Dictionary = _try_load(SAVE_PATH)
        if current_main["ok"]:
            var old_text: String = FileAccess.get_file_as_string(SAVE_PATH)
            if old_text != "":
                var backup = FileAccess.open(BACKUP_PATH, FileAccess.WRITE)
                if backup == null:
                    return false
                backup.store_string(old_text)
                backup.close()
    var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    if file == null:
        return false
    file.store_string(JSON.stringify(payload))
    file.close()
    return true

func load_game() -> Dictionary:
    var main_exists: bool = FileAccess.file_exists(SAVE_PATH)
    var backup_exists: bool = FileAccess.file_exists(BACKUP_PATH)
    if not main_exists and not backup_exists:
        return {"status": "new_game", "data": null}
    var main_result: Dictionary = _try_load(SAVE_PATH)
    if main_result["ok"]:
        return {"status": "ok", "data": main_result["data"]}
    var backup_result: Dictionary = _try_load(BACKUP_PATH)
    if backup_result["ok"]:
        return {"status": "restored_from_backup", "data": backup_result["data"]}
    return {"status": "corrupted", "data": null}

func _try_load(path: String) -> Dictionary:
    if not FileAccess.file_exists(path):
        return {"ok": false, "data": null}
    var text: String = FileAccess.get_file_as_string(path)
    if text == "":
        return {"ok": false, "data": null}
    var json = JSON.new()
    if json.parse(text) != OK:
        return {"ok": false, "data": null}
    var data = json.data
    if not (data is Dictionary):
        return {"ok": false, "data": null}
    if not data.has("schema_version") or int(data["schema_version"]) != SCHEMA_VERSION:
        return {"ok": false, "data": null}
    return {"ok": true, "data": data}
