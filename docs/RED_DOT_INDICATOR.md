# RedDotIndicator 通用红点组件

## 状态与边界

`RedDotIndicator` 是纯展示组件，位于 `scripts/ui/components/red_dot_indicator.gd`。它不读取任务、招募、装备、背包、存档或每日活跃度状态，也不决定红点何时显示。调用方负责提供业务判断并调用 `set_active()`。

本组件不等同于统一红点业务服务；父子入口聚合和业务状态派生仍由后续独立系统负责。

## API

- `set_active(active: bool) -> void`：显示或隐藏红点。重复传入相同状态是无操作，不创建/删除节点。
- `is_active() -> bool`：读取当前展示状态。
- `set_dot_size(diameter: float) -> void`：设置圆点直径，最小为 1 个逻辑 UI 像素。
- `attach_to(target: Control, anchor: Vector2 = Vector2(1, 0), anchor_offset: Vector2 = Vector2(-3, 3)) -> void`：将组件作为目标 Control 的子节点，并按归一化锚点与像素偏移定位。
- `dot_color`：可配置的圆点颜色。

组件默认隐藏，`mouse_filter` 固定为 `Control.MOUSE_FILTER_IGNORE`，不拦截父控件的鼠标/触屏输入；不参与键盘焦点。

## 用法示例

```gdscript
const RedDotIndicator = preload("res://scripts/ui/components/red_dot_indicator.gd")

func _ready() -> void:
    var marker := RedDotIndicator.new()
    marker.set_dot_size(12.0)
    marker.attach_to($RecruitButton, Vector2(1.0, 0.0), Vector2(-3.0, 3.0))
    marker.set_active(can_recruit_now)

func _refresh_recruit_state() -> void:
    $RecruitButton/RedDotIndicator.set_active(can_recruit_now)
```

如果业务状态变化，只更新已有组件；不要每次刷新都 new 一个红点。多个入口应各自持有独立组件实例。

## 自动化测试

`tests/test_red_dot_indicator.gd` 覆盖默认隐藏、运行时显隐、重复切换不增加子节点、多个组件状态互不影响、鼠标/触屏穿透配置，以及锚点/偏移/尺寸配置。

执行命令：

```sh
godot --headless --path . --script res://tests/test_red_dot_indicator.gd
```

当前测试为 headless Control 行为测试，不替代 Android/iOS 真机触控、分辨率、遮挡层级和视觉效果验收。
