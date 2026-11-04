# 项目状态与架构档案

> 本文是 Hero World 的长期项目上下文入口。更新代码或分支关系后，必须同步更新本文及 `CHANGELOG.md`。
> 最后核对：2026-11-04。核对范围：GitHub 远程分支、提交关系、`main` README，以及美术整合分支与主线的文件差异。未在 Godot 4.7.2 本机运行验证。

## 1. 项目定位

Hero World 是原创单机 RPG，目标平台为 Android，目标体验为竖屏移动端、卡通斜视伪 2.5D 世界。核心玩法方向包括英雄小队探索、自动战斗、装备成长、营地建设、地图/区域探索与离线本地存档。

**视觉方向已确定：A——卡通斜视伪 2.5D。** 这属于目标方向，不代表当前主线已经实现。

## 2. Git 仓库与主线规则

- 仓库：`oneyi53/game`
- 正式主线：`main`
- 当前已核对的 main HEAD：`afddb7028a327b9c22d1d13450b967e944f63548`（短 SHA：`afddb70`，提交说明：`Add sprites: previews`）
- 本次文档工作分支：`docs/project-governance`，从上述 main HEAD 创建。
- 本地开发目录：`~/GodotProjects/HeroWorld`（用户此前提供的终端状态显示本地曾切换到该目录下的 `integration/art-2.5d`；本次文档分支是在 GitHub 远端创建，尚未确认用户本地是否获取该分支）。

### 主线与 2.5D 分支关系

| 分支 | 相对 main 的提交关系 | 定位 | 当前判断 |
|---|---:|---|---|
| `main` | 基准 | 唯一正式主线 | 稳定基线；不要被功能分支直接覆盖 |
| `feat/hero-world-2.5d-boss-p0` | ahead 57 / behind 11 | 2.5D 投影、场景排序、Boss 与相关场景/角色逻辑 | 有价值的技术开发线；与 main 已分叉 |
| `feat/hero-world-art-integration` | ahead 113 / behind 11 | 在 2.5D 分支基础上继续扩展美术资源、地图管理、角色/怪物/场景接入和 UI | 比 2.5D 分支多 56 个提交；与该分支关系为严格后继，但仍与 main 分叉 |

核对结果：
- `feat/hero-world-art-integration` 相对 `feat/hero-world-2.5d-boss-p0`：ahead 56 / behind 0。也就是说，美术整合分支包含 2.5D 分支的历史，并额外向前开发 56 个提交。
- 两条开发线相对 main 的共同基点为 `1add5582f092d9cc52752fb54e5bce5137fb4bfd`；main 后续又有 11 个提交，因此它们不能视作 main 的直接快进更新。
- 美术分支与 main 比较时，差异包括美术 PNG 资源、`world_projection.gd`、`world_map_manager.gd`、地图/主场景/英雄/敌人/Boss/交互物/UI 修改，以及 Godot 检查和 Android 构建 workflow 的变化。

**重要纠错：** 之前对话曾将美术资源描述为已经在 main 中。以本次 GitHub 分支比较结果为准：`assets/art-v1/` 下的美术图集和独立 PNG 在 `feat/hero-world-art-integration` 相对 main 的差异中被列为新增文件，因此不能据此认定它们已经进入 main。后续应以具体分支和文件路径核实资源归属。

## 3. 其他远程分支盘点

以下内容分支均以旧的共同基点为基础，相对当前 main 显示 behind 29，并只包含少量独立内容文件改动。它们是内容草稿来源，不应直接合并整个分支：

| 分支 | 相对 main | 主要独立文件/主题 |
|---|---:|---|
| `content/area2-dialogues` | ahead 1 / behind 29 | `content/area2-dialogues.md` |
| `content/area3-dialogues` | ahead 1 / behind 29 | `content/area3-dialogues.md` |
| `content/area4-dialogues` | ahead 1 / behind 29 | `content/area4-dialogues.md` |
| `content/chat-art-apk-batch` | ahead 3 / behind 29 | APK 说明、图片提示词、UI 文案 |
| `content/m1-dialogues` | ahead 2 / behind 29 | 装备风味文案、任务对话 |
| `content/m1-text-draft` | ahead 4 / behind 29 | 装备套装、英雄、怪物/Boss、任务文案 |
| `content/next-chat-batch` | ahead 3 / behind 29 | APK 文案、美术描述、后续任务 |
| `content/system-draft` | ahead 1 / behind 29 | 系统草案 |
| `fix/android-apk-build` | ahead 0 / behind 13 | 已落后于 main；比较结果没有独立差异文件 |

内容分支应逐文件挑选、审校和迁移到当前主线，不要把旧分支整体合并进来。

## 4. 已知代码与资源范围

根据远程分支文件差异，`feat/hero-world-art-integration` 已涉及：

- 美术资源目录：`assets/art-v1/`，包括英雄、怪物、Boss、装备、场景图及预览图；还包含三套装备套装素材和说明。
- 2.5D 基础：`scripts/core/world_projection.gd`、`scripts/core/world_map_manager.gd`。
- 地图与主场景：`scripts/core/map.gd`、`scripts/core/main.gd`、`scenes/main.tscn`。
- 视觉节点：`scripts/core/landmark_visual.gd`、`scripts/core/tree_visual.gd`。
- 角色与敌人：`scripts/character/hero.gd`、`scripts/enemy/enemy.gd`、`scripts/enemy/boss.gd`。
- 交互物：营火、宝箱。
- UI：背包、装备、英雄、HUD、离线奖励、招募等面板。
- CI：Godot 4.7.2 检查 workflow，以及 Android 构建 workflow 的修改。

注意：文件存在或提交存在，不等于功能已经在目标设备上验证通过。

## 5. 已知风险与待核查项

下列事项来自此前分支审查记录，当前应视为**待复核问题**，不是已经修复或已在本机复现的结论：

1. 地图尺寸与角色/敌人移动边界可能不一致：此前审查记录指出地图逻辑为 1200×900，但部分移动边界仍为 1600×1200。
2. 地图切换后玩家、敌人、营火、宝箱及重生点的位置/状态是否正确。
3. 旧存档在地图结构、区域解锁、对象位置变化后的兼容性。
4. 角色、怪物、Boss 的贴图锚点、缩放、朝向、动画和遮挡排序。
5. 行走/攻击动画是否完整；此前美术说明指出动画仍有未完成项，需再次核实。
6. Godot 4.7.2 导入、运行、主场景加载、脚本错误及 Android 导出。
7. `project.godot`、`.import`、`.uid` 与 `.godot/` 的版本控制规则，需结合仓库 `.gitignore` 和实际 Git 跟踪状态判断。

## 6. 建议的整合策略

1. 保持 `main` 为稳定基线，不直接 force-push、不重置、不用美术分支覆盖 main。
2. 以 `feat/hero-world-art-integration` 为主要技术参考，因为它包含 2.5D 分支的历史和额外美术整合工作。
3. 先逐文件审查 main 与美术分支差异，按依赖顺序迁移：投影/地图坐标 → 地图管理/场景 → 角色与敌人贴图 → 遮挡排序 → UI → 资源导入。
4. 对玩法逻辑、存档、任务、装备、招募、营地等系统做回归检查；必要时从 main 保留更新后的实现，而不是机械复制旧分支版本。
5. 每个逻辑模块单独提交；先在独立整合分支验证，再通过 PR 合入 main。
6. 内容分支只挑选具体文案文件，经过内容审校后纳入主线。
7. 未运行验证的改动必须标注“未验证”，不得写成“完成”。

## 7. 下一步从哪里开始

**第一优先级：建立可重复的基线和差异清单，不立即改游戏代码。**

建议顺序：
1. 确认用户本地工作区状态及当前分支，保护已有未提交改动。
2. 获取远程最新引用；确认本地 `main` 与 GitHub main 的 SHA。
3. 阅读美术分支的美术说明、Sprite 规范、投影/地图/主场景/英雄/敌人/Boss 脚本。
4. 对照 main 当前版本，建立“文件—功能—依赖—迁移策略—验证方式”清单。
5. 先处理坐标投影与地图边界，再接入角色/怪物/场景美术。
6. Godot 4.7.2 导入和运行验证通过后，再进入 Android 设备验证。

在上述清单完成前，不要求用户删除 `FantasyRPG`，不要求覆盖项目目录，也不执行未经审查的 merge/reset/checkout 覆盖操作。

## 8. 每次开发必须维护的记录

每个有意义的代码变更都应在 `CHANGELOG.md` 记录：
- 日期、分支、提交 SHA、提交标题；
- 修改文件和行为变化；
- 是否改变存档/资源格式；
- 测试命令、Godot 版本、运行环境和实际结果；
- 未解决问题及下一步。

每次会话结束前更新本文的“当前状态/下一步”，使下一次会话可以直接从仓库文档恢复上下文。
