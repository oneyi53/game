# Hero World

原创单机 RPG，目标平台为 Android。项目目标是打造卡通斜视伪 2.5D 的英雄小队探索体验，包含自动战斗、装备成长、营地建设、区域探索和本地离线存档。

> 当前处于持续开发与架构整合阶段。目标视觉方向不代表主线已经具备完整美术表现或可发布版本。请以 `docs/PROJECT_STATUS.md` 中的分支和验证记录为准。

## 项目规则

- **唯一正式主线：`main`**。
- 功能分支和内容分支是开发成果/草稿来源，不自动等于主线已包含的功能。
- 不直接覆盖或重置 main；先审查差异，再通过独立分支和 PR 整合。
- 每次有意义的代码、资源或配置变更，都要记录在 `docs/CHANGELOG.md`。
- 只有实际完成的测试才能标记为通过；静态审查、Godot 导入、运行、功能回归和 Android 实机验证必须区分。

## 文档入口

| 文档 | 用途 |
|---|---|
| [项目状态与架构档案](docs/PROJECT_STATUS.md) | 项目定位、主线/分支关系、现有模块、风险、整合策略和下一步 |
| [开发变更日志](docs/CHANGELOG.md) | 按日期、分支、Commit、文件和验证结果追踪每次修改 |
| [开发工作流与会话交接](docs/DEVELOPMENT_WORKFLOW.md) | 分支策略、提交规范、验证等级和会话交接要求 |

## 本地开发

- 当前项目使用 Godot 4.7.2 作为目标编辑器版本（实际打开前请确认本机版本）。
- 在 Godot Project Manager 中导入仓库根目录的 `project.godot`。
- 运行前先查看 [项目状态档案](docs/PROJECT_STATUS.md) 和当前分支状态。
- 不要把本地 `.godot/` 缓存当作源码提交；`.import` 和 `.uid` 是否纳入版本控制应遵循仓库现有规则，不能批量删除或盲目添加。

## 当前主线

当前档案核对的 main 基线：`afddb70`（`Add sprites: previews`）。详细分支提交关系和待验证事项见 [PROJECT_STATUS.md](docs/PROJECT_STATUS.md)。
