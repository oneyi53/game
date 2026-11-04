# RedDotService — 派生红点状态服务

## 职责边界

`RedDotService` 是纯逻辑聚合层，只接收调用方提供的业务状态，并根据 target 层级计算父入口显隐。它不拥有招募、装备、背包、任务或每日活跃度的业务规则，也不发奖励、不改存档、不创建 UI 节点。

依赖方向：

`业务 Manager / 状态适配器 → RedDotService → HUD / 面板 / 主城入口显示`

UI 只读取快照；不能自行从文字、按钮状态或面板内容推断业务红点。

## API

- `set_hierarchy({ "hud": ["daily", "quest"], "town": ["recruit", "backpack"] })`：配置父 target 与子 target 的关系。拒绝空 ID、重复子项、自引用和循环；失败时保留旧层级。
- `set_source_state(target_id, active)`：更新一个业务状态源。
- `replace_source_states(states)`：原子替换整份状态源；输入必须是 Boolean 字典。
- `clear_source_state(target_id)`：移除状态源。
- `is_visible(target_id)`：查询目标是否应显示红点。
- `get_snapshot()`：返回 target ID 到 Boolean 的派生快照。
- `state_changed(snapshot)`：状态或层级发生实际变化时发出。

一个 target 可以同时有直接状态和子 target；其最终可见状态是直接状态与任意子 target 的逻辑 OR。子 target 也可以是更深层的聚合 target。

## 使用约束

1. 业务层只提交“当前可执行/待处理”的权威状态，不要把“有未完成内容”一概当红点。
2. 红点不写入玩家存档；加载后从各业务 manager 重新计算。
3. 打开面板本身不清除红点；只有业务状态成功变化后才更新源状态。
4. 业务 source 的稳定 ID 和 parent-child 映射应由单一适配层维护。
5. 每日活跃度奖励只有在日规则、时区、领奖原子性确认后才能接入。

## 验证范围

`tests/test_red_dot_service.gd` 覆盖空状态、单源更新、父子 OR、嵌套聚合、父节点直接状态、互相独立的 target、无效层级、循环拒绝、状态批量原子替换及快照隔离。Godot 4.7.2 CI 负责脚本导入、测试和 headless 启动；真实 HUD/建筑视觉和触屏仍需设备验收。
