# Hero World

原创单机 RPG，目标平台为 Android。项目目标是打造卡通斜视伪 2.5D 的英雄小队探索体验，包含自动战斗、装备成长、营地建设、区域探索和本地离线存档。

> 当前处于持续开发与架构整合阶段。目标视觉方向不代表主线已经具备完整美术表现或可发布版本。请以 docs/PROJECT_STATUS.md 中的分支和验证记录为准。

## 项目规则

- **唯一正式主线：main**。
- 功能分支和内容分支是开发成果/草稿来源，不自动等于主线已包含的功能。
- 不直接覆盖或重置 main；先审查差异，再通过独立分支和 PR 整合。
- 每次有意义的代码、资源或配置变更，都要记录在 docs/CHANGELOG.md。
- 只有实际完成的测试才能标记为通过；静态审查、Godot 导入、运行、功能回归和 Android 实机验证必须区分。

## 文档入口

| 文档 | 用途 |
|---|---|
| [项目状态与架构档案](docs/PROJECT_STATUS.md) | 项目定位、主线/分支关系、现有模块、风险、整合策略和下一步 |\n| [项目交接文档](docs/HANDOFF.md) | 项目目标、进度、完成度、痛点、验证快照和下一阶段顺序 |
| [《百炼英雄》竞品研究与设计参考](docs/BAILIAN_HERO_REFERENCE_STUDY.md) | 画面、竖屏操作、战斗、探索、资源成长循环、开发优先级与验收清单 |
| [2.5D / 美术分支静态审查](docs/BRANCH_AUDIT.md) | 文件净差异、坐标/存档风险、静态接入完成度和整合顺序 |
| [远程分支总目录](docs/BRANCH_CATALOG.md) | 当前远程分支、PR 状态、内容草稿和使用建议 |
| [世界坐标与旧存档迁移规范](docs/WORLD_COORDINATE_MIGRATION.md) | 四地图本地坐标、解锁门槛、旧存档迁移和验证方式 |
| [开发变更日志](docs/CHANGELOG.md) | 按日期、分支、Commit、文件和验证结果追踪每次修改 |
| [开发工作流与会话交接](docs/DEVELOPMENT_WORKFLOW.md) | 分支策略、提交规范、验证等级和会话交接要求 |

## 本地开发

- 当前项目使用 Godot 4.7.2 作为目标编辑器版本（实际打开前请确认本机版本）。
- 在 Godot Project Manager 中导入仓库根目录的 project.godot。
- 运行前先查看项目状态档案和当前分支状态。
- 不要把本地 .godot/ 缓存当作源码提交；.import 和 .uid 是否纳入版本控制应遵循仓库现有规则，不能批量添加或盲目删除。

## 当前主线

当前正式基线以 GitHub main 最新提交为准。详细状态见 docs/PROJECT_STATUS.md；远程分支盘点见 docs/BRANCH_CATALOG.md；原创 PNG 统一归档在 assets/art-v1/。
