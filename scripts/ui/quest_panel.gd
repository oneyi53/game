class_name QuestPanel
extends Control

# Quest panel: one card row per quest (reference: daily task screen).
# Row: reward on the left, name + progress bar in the middle,
# state button on the right. Quests complete automatically;
# the state button is display-only.
var quest_manager = null

@onready var header_label: Label = $HeaderLabel
@onready var quest_list: VBoxContainer = $QuestScroll/QuestList

func set_manager(p_quest_manager) -> void:
    quest_manager = p_quest_manager
    refresh()

func refresh() -> void:
    if header_label != null:
        header_label.text = "任务"
    if quest_list == null or quest_manager == null:
        return
    for child in quest_list.get_children():
        quest_list.remove_child(child)
        child.queue_free()
    for row_data in quest_manager.progress_rows():
        var row := HBoxContainer.new()
        row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        row.add_theme_constant_override("separation", 12)
        var reward := Label.new()
        reward.text = "金币\n+" + str(row_data.get("reward_gold", 0))
        reward.custom_minimum_size = Vector2(72, 96)
        reward.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
        reward.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        reward.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        row.add_child(reward)
        var middle := VBoxContainer.new()
        middle.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        var name_label := Label.new()
        name_label.text = str(row_data.get("name", ""))
        name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        middle.add_child(name_label)
        var bar := ProgressBar.new()
        bar.min_value = 0
        bar.max_value = maxi(1, int(row_data.get("target", 1)))
        bar.value = int(row_data.get("current", 0))
        bar.show_percentage = false
        bar.custom_minimum_size = Vector2(280, 24)
        middle.add_child(bar)
        var progress_label := Label.new()
        progress_label.text = str(int(row_data.get("current", 0))) + "/" + str(int(row_data.get("target", 1)))
        middle.add_child(progress_label)
        row.add_child(middle)
        var state_button := Button.new()
        state_button.custom_minimum_size = Vector2(120, 60)
        if bool(row_data.get("done", false)):
            state_button.text = "已完成"
        else:
            state_button.text = "进行中"
        state_button.disabled = true
        row.add_child(state_button)
        quest_list.add_child(row)
