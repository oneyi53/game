# 任务系统自动化测试说明

## 当前实现范围

`QuestManager` 从 `data/quests.json` 读取任务配置，追踪击杀计数、宝箱计数和完成标记；任务完成时发出 `quest_completed` 信号，携带任务 ID、名称、完成台词和配置金币。`Main` 监听该信号并自动增加金币，不存在单独的“领取任务奖励”API或领取状态。

任务进度通过 `save_progress()` 序列化为 `{counts, completed}`，由 `Main` 放入现有 `quests` 存档字段；启动时 `load_progress()` 恢复。缺少 `quests` 字段的旧存档按零进度初始化。此测试未调整数据格式或 schema 版本。

## 自动化测试

运行命令（Godot 4.7.2）：

```sh
godot --headless --path . --script res://tests/test_quest_manager.gd
```

测试覆盖实际 `data/quests.json` 配置加载、无任务进度的旧存档、负数和未知任务 ID 的进度输入、任务进度序列化/恢复、击杀目标匹配、击杀阈值、Boss ID 与 Boss 标记校验、宝箱目标、完成后重复事件抑制，以及已完成状态恢复后不重复发出完成信号。

`.github/workflows/godot-cloud-validation.yml` 将该脚本接入现有 Godot 4.7.2 headless 验证。

## 明确未覆盖及待评估问题

- 这组测试验证 `QuestManager` 的奖励信号只发一次，不实例化完整 `Main`，因此未验证信号处理后的实际金币 UI 更新或端到端存档写盘。
- 目前没有玩家主动领取任务奖励的接口；奖励在任务完成时由信号路径自动发放。
- `load_progress()` 对非负计数没有按任务目标上限裁剪；本 PR 仅记录此行为，不改存档恢复策略或玩法。
- `SaveManager` 的真实文件 I/O、备份恢复和故障注入不在本任务测试范围内，以免测试覆盖用户保存路径或扩展到通用存档管理器改造。
