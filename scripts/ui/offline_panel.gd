class_name OfflinePanel
extends Control

# Offline settlement panel (self-designed, v5 spec: no reference
# screenshot exists, so this layout is Hero World's own design in
# the same panel language as the v4 panels). A centered modal with
# a title, the offline duration, one structured row per reward
# (colour swatch + name + amount), an optional wood-cap note, and
# a single confirm button. The earnings are already credited by
# Main before this panel is shown, so confirming only closes the
# panel; it never credits twice. show_empty() covers the HUD
# offline button when there is nothing to settle this session.

signal confirmed

@onready var panel_label: RichTextLabel = $PanelLabel

var scroll: ScrollContainer = null
var list_box: VBoxContainer = null

const GOLD_COLOR := Color(1.0, 0.827, 0.302)
const WOOD_COLOR := Color(0.545, 0.353, 0.169)

func show_settlement(data: Dictionary) -> void:
	if panel_label != null:
		panel_label.visible = false
	_ensure_dynamic()
	_clear_list()
	var billed: int = int(data.get("billed_seconds", 0))
	var elapsed: int = int(data.get("elapsed_seconds", 0))
	var cap_hours: int = int(data.get("cap_hours", 8))
	_add_title("离线结算")
	var duration_text: String = "离线 " + str(billed / 3600) + " 小时 " + str((billed % 3600) / 60) + " 分钟"
	if elapsed > billed:
		duration_text += "（已按 " + str(cap_hours) + " 小时封顶计算）"
	_add_centered_label(duration_text)
	var gold: int = int(data.get("gold", 0))
	var wood: int = int(data.get("wood", 0))
	if gold > 0:
		_add_reward_row("金币", gold, GOLD_COLOR)
	if wood > 0:
		_add_reward_row("木材", wood, WOOD_COLOR)
	if bool(data.get("wood_capped", false)):
		_add_centered_label("木材已达上限，多余部分不计入")
	_add_confirm_button()
	visible = true

func show_empty(gold_per_hour: int, wood_per_hour: int, cap_hours: int, min_minutes: int) -> void:
	if panel_label != null:
		panel_label.visible = false
	_ensure_dynamic()
	_clear_list()
	_add_title("离线收益")
	_add_centered_label("暂无可结算的离线收益")
	_add_centered_label("离线 " + str(min_minutes) + " 分钟以上即可结算")
	_add_centered_label("每小时金币 +" + str(gold_per_hour) + "、木材 +" + str(wood_per_hour))
	_add_centered_label("最多按 " + str(cap_hours) + " 小时计算")
	_add_confirm_button()
	visible = true

func _ensure_dynamic() -> void:
	if scroll != null:
		scroll.visible = true
		return
	scroll = ScrollContainer.new()
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(scroll)
	list_box = VBoxContainer.new()
	list_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list_box.alignment = BoxContainer.ALIGNMENT_CENTER
	# Fill the panel height so the centered group sits mid-panel instead
	# of packing at the top (panel is 600x560 from main.tscn; content
	# is only ~350px tall). ScrollContainer never scrolls: the box
	# minimum height equals the viewport height.
	list_box.custom_minimum_size = Vector2(0, size.y)
	list_box.add_theme_constant_override("separation", 16)
	scroll.add_child(list_box)

func _clear_list() -> void:
	for child in list_box.get_children():
		list_box.remove_child(child)
		child.queue_free()

func _add_title(text: String) -> void:
	var title := Label.new()
	title.text = text
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 40)
	list_box.add_child(title)

func _add_centered_label(text: String) -> void:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	list_box.add_child(label)

func _add_reward_row(resource_name: String, amount: int, swatch_color: Color) -> void:
	var row := HBoxContainer.new()
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_theme_constant_override("separation", 16)
	var swatch := ColorRect.new()
	swatch.color = swatch_color
	swatch.custom_minimum_size = Vector2(64, 64)
	row.add_child(swatch)
	var name_label := Label.new()
	name_label.text = resource_name
	name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", 28)
	row.add_child(name_label)
	var amount_label := Label.new()
	amount_label.text = "+" + str(amount)
	amount_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	amount_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	amount_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	amount_label.add_theme_font_size_override("font_size", 28)
	row.add_child(amount_label)
	list_box.add_child(row)

func _add_confirm_button() -> void:
	var button := Button.new()
	button.text = "确认"
	button.custom_minimum_size = Vector2(240, 72)
	button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	button.pressed.connect(_on_confirm_pressed)
	list_box.add_child(button)

func _on_confirm_pressed() -> void:
	visible = false
	confirmed.emit()
