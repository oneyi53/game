class_name DailyActivityPanel
extends Control

signal reward_claim_requested(reward_id: String)
signal close_requested

var _points_label: Label
var _task_list: VBoxContainer
var _stage_list: VBoxContainer
var _empty_tasks_label: Label
var _snapshot: Dictionary = {}

func _ready() -> void:
    _build_ui()
    refresh()

# Snapshot contract: activity_points (int), tasks (Array[Dictionary]),
# stages (Array[Dictionary]). Each task supplies id/name/description/progress/target/completed.
# Each stage supplies id/reward_id/name/description/threshold/state ("locked",
# "claimable", or "claimed"). All values are display-only; this panel derives no rules.
func set_snapshot(snapshot: Dictionary) -> void:
    _snapshot = snapshot.duplicate(true)
    refresh()

func refresh() -> void:
    if not is_inside_tree() or _task_list == null:
        return
    _points_label.text = "今日活跃度：%d" % int(_snapshot.get("activity_points", 0))
    _rebuild_tasks()
    _rebuild_stages()

func _build_ui() -> void:
    var background := ColorRect.new()
    background.name = "PanelBackground"
    background.color = Color(0.035, 0.055, 0.075, 0.94)
    background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    background.mouse_filter = Control.MOUSE_FILTER_STOP
    add_child(background)

    var margin := MarginContainer.new()
    margin.name = "ContentMargin"
    margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    margin.add_theme_constant_override("margin_left", 18)
    margin.add_theme_constant_override("margin_top", 14)
    margin.add_theme_constant_override("margin_right", 18)
    margin.add_theme_constant_override("margin_bottom", 14)
    add_child(margin)

    var content := VBoxContainer.new()
    content.name = "Content"
    content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    content.size_flags_vertical = Control.SIZE_EXPAND_FILL
    content.add_theme_constant_override("separation", 10)
    margin.add_child(content)

    var header := HBoxContainer.new()
    header.name = "Header"
    content.add_child(header)

    var title := Label.new()
    title.text = "每日活跃"
    title.add_theme_font_size_override("font_size", 24)
    title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    header.add_child(title)

    var close_button := Button.new()
    close_button.name = "CloseButton"
    close_button.text = "关闭"
    close_button.pressed.connect(_on_close_pressed)
    header.add_child(close_button)

    _points_label = Label.new()
    _points_label.name = "ActivityPoints"
    _points_label.text = "今日活跃度：0"
    _points_label.add_theme_font_size_override("font_size", 20)
    content.add_child(_points_label)

    var task_title := Label.new()
    task_title.text = "每日任务"
    task_title.add_theme_font_size_override("font_size", 18)
    content.add_child(task_title)

    var task_scroll := ScrollContainer.new()
    task_scroll.name = "TaskScroll"
    task_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    task_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
    task_scroll.custom_minimum_size = Vector2(0, 170)
    task_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    content.add_child(task_scroll)

    _task_list = VBoxContainer.new()
    _task_list.name = "TaskList"
    _task_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    _task_list.add_theme_constant_override("separation", 8)
    task_scroll.add_child(_task_list)

    _empty_tasks_label = Label.new()
    _empty_tasks_label.name = "EmptyTasks"
    _empty_tasks_label.text = "暂无每日任务"
    _empty_tasks_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    _task_list.add_child(_empty_tasks_label)

    var stage_title := Label.new()
    stage_title.text = "活跃度奖励"
    stage_title.add_theme_font_size_override("font_size", 18)
    content.add_child(stage_title)

    var stage_scroll := ScrollContainer.new()
    stage_scroll.name = "StageScroll"
    stage_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    stage_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
    stage_scroll.custom_minimum_size = Vector2(0, 120)
    stage_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    content.add_child(stage_scroll)

    _stage_list = VBoxContainer.new()
    _stage_list.name = "StageList"
    _stage_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    _stage_list.add_theme_constant_override("separation", 8)
    stage_scroll.add_child(_stage_list)

func _rebuild_tasks() -> void:
    _clear_rows(_task_list)
    var tasks: Array = _snapshot.get("tasks", [])
    _empty_tasks_label.visible = tasks.is_empty()
    for task_variant in tasks:
        if not task_variant is Dictionary:
            continue
        var task: Dictionary = task_variant
        var row := VBoxContainer.new()
        row.name = "Task_%s" % str(task.get("id", "unknown"))
        var title := Label.new()
        title.text = str(task.get("name", "未命名任务"))
        title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        row.add_child(title)

        var description := Label.new()
        description.text = str(task.get("description", ""))
        description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        description.modulate = Color(0.78, 0.82, 0.86)
        row.add_child(description)

        var progress := Label.new()
        progress.name = "Progress"
        progress.text = "%d / %d%s" % [
            int(task.get("progress", 0)),
            int(task.get("target", 0)),
            " · 已完成" if bool(task.get("completed", false)) else ""
        ]
        row.add_child(progress)
        _task_list.add_child(row)

func _rebuild_stages() -> void:
    _clear_rows(_stage_list)
    var stages: Array = _snapshot.get("stages", [])
    for stage_variant in stages:
        if not stage_variant is Dictionary:
            continue
        var stage: Dictionary = stage_variant
        var row := HBoxContainer.new()
        row.name = "Stage_%s" % str(stage.get("id", "unknown"))
        row.size_flags_horizontal = Control.SIZE_EXPAND_FILL

        var description := Label.new()
        description.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        description.text = str(stage.get("name", "阶段奖励"))
        var detail := str(stage.get("description", ""))
        if not detail.is_empty():
            description.text += " — " + detail
        description.text += "（%d）" % int(stage.get("threshold", 0))
        row.add_child(description)

        var state := str(stage.get("state", "locked"))
        var button := Button.new()
        button.name = "ClaimButton"
        match state:
            "claimable":
                button.text = "领取"
                button.pressed.connect(_on_claim_pressed.bind(str(stage.get("reward_id", stage.get("id", "")))))
            "claimed":
                button.text = "已领取"
                button.disabled = true
            _:
                button.text = "未解锁"
                button.disabled = true
        row.add_child(button)
        _stage_list.add_child(row)

func _clear_rows(container: VBoxContainer) -> void:
    for child in container.get_children():
        if child == _empty_tasks_label:
            continue
        container.remove_child(child)
        child.queue_free()

func _on_claim_pressed(reward_id: String) -> void:
    if not reward_id.is_empty():
        reward_claim_requested.emit(reward_id)

func _on_close_pressed() -> void:
    close_requested.emit()
    visible = false
