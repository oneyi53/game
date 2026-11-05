extends SceneTree

const PanelScene = preload("res://scenes/ui/daily_activity_panel.tscn")

var claim_events: Array[String] = []
var close_events: int = 0

func _initialize() -> void:
    call_deferred("_run_tests")

func _run_tests() -> void:
    var panel: Control = PanelScene.instantiate()
    root.add_child(panel)
    await process_frame

    _test_empty_snapshot(panel)
    _test_task_rows_render(panel)
    _test_progress_text(panel)
    _test_reward_states_render(panel)
    _test_claim_signal(panel)
    _test_repeat_refresh_does_not_duplicate_rows(panel)
    _test_close_signal(panel)
    print("Daily activity panel tests: 7 passed")
    quit()

func _test_empty_snapshot(panel: Control) -> void:
    panel.set_snapshot({})
    assert(panel.get_node("ContentMargin/Content/ActivityPoints").text == "今日活跃度：0")
    assert(panel.get_node("ContentMargin/Content/TaskScroll/TaskList/EmptyTasks").visible)
    assert(panel.get_node("ContentMargin/Content/StageScroll/StageList").get_child_count() == 0)

func _sample_snapshot() -> Dictionary:
    return {
        "activity_points": 35,
        "tasks": [
            {"id": "kill_slimes", "name": "清理史莱姆", "description": "击败森林中的史莱姆", "progress": 3, "target": 5, "completed": false},
            {"id": "open_chest", "name": "开启宝箱", "description": "找到一个宝箱", "progress": 1, "target": 1, "completed": true}
        ],
        "stages": [
            {"id": "stage_1", "reward_id": "reward_1", "name": "初级奖励", "description": "金币", "threshold": 20, "state": "claimed"},
            {"id": "stage_2", "reward_id": "reward_2", "name": "进阶奖励", "description": "木材", "threshold": 50, "state": "claimable"},
            {"id": "stage_3", "reward_id": "reward_3", "name": "高级奖励", "description": "", "threshold": 100, "state": "locked"}
        ]
    }

func _test_task_rows_render(panel: Control) -> void:
    panel.set_snapshot(_sample_snapshot())
    var task_list: VBoxContainer = panel.get_node("ContentMargin/Content/TaskScroll/TaskList")
    assert(not task_list.get_node("EmptyTasks").visible)
    assert(task_list.has_node("Task_kill_slimes"))
    assert(task_list.has_node("Task_open_chest"))

func _test_progress_text(panel: Control) -> void:
    var task_list: VBoxContainer = panel.get_node("ContentMargin/Content/TaskScroll/TaskList")
    assert(task_list.get_node("Task_kill_slimes/Progress").text == "3 / 5")
    assert(task_list.get_node("Task_open_chest/Progress").text == "1 / 1 · 已完成")
    assert(panel.get_node("ContentMargin/Content/ActivityPoints").text == "今日活跃度：35")

func _test_reward_states_render(panel: Control) -> void:
    var stage_list: VBoxContainer = panel.get_node("ContentMargin/Content/StageScroll/StageList")
    assert(stage_list.get_child_count() == 3)
    assert(stage_list.get_node("Stage_stage_1/ClaimButton").disabled)
    assert(stage_list.get_node("Stage_stage_1/ClaimButton").text == "已领取")
    assert(not stage_list.get_node("Stage_stage_2/ClaimButton").disabled)
    assert(stage_list.get_node("Stage_stage_2/ClaimButton").text == "领取")
    assert(stage_list.get_node("Stage_stage_3/ClaimButton").disabled)
    assert(stage_list.get_node("Stage_stage_3/ClaimButton").text == "未解锁")

func _test_claim_signal(panel: Control) -> void:
    panel.reward_claim_requested.connect(_on_claim_requested)
    var button: Button = panel.get_node("ContentMargin/Content/StageScroll/StageList/Stage_stage_2/ClaimButton")
    button.pressed.emit()
    assert(claim_events.size() == 1)
    assert(claim_events[0] == "reward_2")

func _test_repeat_refresh_does_not_duplicate_rows(panel: Control) -> void:
    var snapshot := _sample_snapshot()
    panel.set_snapshot(snapshot)
    panel.set_snapshot(snapshot)
    panel.refresh()
    var task_list: VBoxContainer = panel.get_node("ContentMargin/Content/TaskScroll/TaskList")
    var stage_list: VBoxContainer = panel.get_node("ContentMargin/Content/StageScroll/StageList")
    assert(task_list.get_child_count() == 3)
    assert(stage_list.get_child_count() == 3)

func _test_close_signal(panel: Control) -> void:
    panel.close_requested.connect(_on_close_requested)
    panel.visible = true
    panel.get_node("ContentMargin/Content/Header/CloseButton").pressed.emit()
    assert(close_events == 1)
    assert(not panel.visible)

func _on_claim_requested(reward_id: String) -> void:
    claim_events.append(reward_id)

func _on_close_requested() -> void:
    close_events += 1
