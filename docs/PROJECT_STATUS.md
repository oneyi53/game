# 项目状态与架构档案

> Hero World 长期上下文入口。分支清单见 [BRANCH_CATALOG.md](BRANCH_CATALOG.md)，静态技术审查见 [BRANCH_AUDIT.md](BRANCH_AUDIT.md)。
> 最后核对：2026-11-04。仓库 `oneyi53/game`；唯一正式主线 `main`。

## 最新交接状态（2026-11-04）

- **PR #30 的 main 基线：** `598216e6f67611b0f3db452718b4aa7cdf57ebb2`（本次整理开始时的主线提交；合并后的新主线以 GitHub 为准）。
- **PR #29 已合并：** 散件穿戴闭环；合并提交即当前 main HEAD。
- **Godot 4.7.2 CI：** PR #29 分支及合并后 main 的资源导入、脚本解析、headless 启动均有成功记录（PR #30 记录原功能验证 run 41809736359、41809725550；本次素材新路径与最终文档提交的 Godot 检查 run 41816687698 通过）；不代表移动端验收。
- **本次整理：** 通过 PR #30 提交；合并后，分支目录、开发记录与原创 PNG 归档路径一并进入 main。
- **营地增益：** 铁匠铺全队攻击 +5%；训练场全队最大生命 +8%。
- **森林传送：** 森林入口、营火据点、苔冠空地、落叶幽谷、朝露林地五个进度门槛目的地已接入；仍是同一连续地图内快速移动，不是独立场景切换。
- **原创特效：** 用户确认的原创图集已接入技能施放/命中表现，归档路径为 `assets/art-v1/effects/effect_atlas.png`。
- **散件装备：** 每名英雄按槽位保存；支持穿戴、同槽替换、卸下和邮箱溢出；平面属性参与属性重算；散件覆盖套装槽时暂停对应套装计件，卸下后恢复；副手盾独立于六件套装槽。
- **存档兼容：** 新增可选 `loose_equipment` 字段；旧存档缺少字段时默认为空；schema_version 不变。未改掉落率、背包容量、分解奖励、制作或升级。
- **美术现状：** 主线已有英雄、怪物、Boss、装备、场景和套装 PNG；目录说明以 `assets/art-v1/README.md`、`ART_ASSET_CATALOG.md` 为准。素材已存在不代表动画和所有显示效果完成。
- **下一项技术主线：** 2.5D 地图接入前先统一地图坐标契约、修复移动边界并设计旧存档坐标迁移；禁止整条合并旧美术分支。
- **验证边界：** 云端 headless CI 仅代表资源导入、脚本解析和无头启动；移动端触控、渲染、帧率、完整战斗与存档回归仍待设备验证。

## 记录基线说明

下文部分内容是早期审查快照，保留作历史背景。旧 main SHA、旧 ahead/behind 数量及“待 CI”状态不代表当前；最新分支状态以 [BRANCH_CATALOG.md](BRANCH_CATALOG.md) 为准。

## 1. 项目定位

Hero World 是原创单机 RPG，目标平台为 Android，目标体验为竖屏移动端、卡通斜视伪 2.5D 世界。核心玩法方向包括英雄小队探索、自动战斗、装备成长、营地建设、地图/区域探索与离线本地存档。

**视觉方向已确定：A——卡通斜视伪 2.5D。** 这属于目标方向，不代表当前主线已经实现。

## 2. Git 仓库与主线规则

- 仓库：oneyi53/game
- 正式主线：main
- 当前 main HEAD 请以 GitHub main 最新提交为准；最近一次完整分支比较基线为 ea1d4fd7c705fe3e527e3591cca42b851f2f27e6。
- 当前本地开发目录：~/GodotProjects/HeroWorld；此前终端显示用户曾切换到 integration/art-2.5d，本地工作区有未提交状态，必须先检查再操作。

### 主线与 2.5D 分支关系

| 分支 | 最近核对的提交关系 | 定位 | 当前判断 |
|---|---:|---|---|
| main | 基准 | 唯一正式主线 | 当前唯一整合基线 |
| feat/hero-world-2.5d-boss-p0 | ahead 57 / behind 14 | 2.5D 投影、场景排序、Boss 与相关场景/角色逻辑 | 前置技术阶段；与 main 已分叉 |
| feat/hero-world-art-integration | ahead 113 / behind 14 | 在 2.5D 分支基础上继续扩展美术资源、地图管理、角色/怪物/场景接入和 UI | 2.5D 分支的严格后继；主要技术参考，但不能整分支合并 |

核对结果：
- feat/hero-world-art-integration 相对 feat/hero-world-2.5d-boss-p0：ahead 56 / behind 0。
- 两条开发线相对 main 的共同基点为 1add5582f092d9cc52752fb54e5bce5137fb4bfd；main 已在其后新增提交，因此分支已分叉。
- 不要把 GitHub 三点比较的文件列表直接当作当前 main 缺少的文件清单。资源归属以递归 Git tree/blob SHA 对照为准，详细记录见 BRANCH_AUDIT.md。

## 3. 其他远程分支盘点

以下内容分支均以旧的共同基点为基础，相对当时 main 显示 behind 29，并只包含少量独立内容文件改动。它们是内容草稿来源，不应直接合并整个分支：

| 分支 | 相对当时 main | 主要独立文件/主题 |
|---|---:|---|
| content/area2-dialogues | ahead 1 / behind 29 | content/area2-dialogues.md |
| content/area3-dialogues | ahead 1 / behind 29 | content/area3-dialogues.md |
| content/area4-dialogues | ahead 1 / behind 29 | content/area4-dialogues.md |
| content/chat-art-apk-batch | ahead 3 / behind 29 | APK 说明、图片提示词、UI 文案 |
| content/m1-dialogues | ahead 2 / behind 29 | 装备风味文案、任务对话 |
| content/m1-text-draft | ahead 4 / behind 29 | 装备套装、英雄、怪物/Boss、任务文案 |
| content/next-chat-batch | ahead 3 / behind 29 | APK 文案、美术描述、后续任务 |
| content/system-draft | ahead 1 / behind 29 | 系统草案 |
| fix/android-apk-build | ahead 0 / behind 13（此前核对） | 已落后于当时 main；比较结果没有独立差异文件 |

内容分支应逐文件挑选、审校和迁移到当前主线，不要把旧分支整体合并进来。具体提交关系需要在真正使用前重新核对。

## 4. 当前主线已有的模块与资源

### 项目结构

- project.godot、export_presets.cfg：Godot 项目和 Android 导出配置。
- scenes/：主场景、英雄、普通敌人、Boss、营火、宝箱场景。
- scripts/core/：主流程、地图绘制、数据加载、本地存档。
- scripts/character/、scripts/enemy/、scripts/interactable/：英雄、敌人/Boss、交互物。
- scripts/progression/：背包、营地、装备、等级、离线收益、任务、招募管理。
- scripts/ui/：HUD、摇杆、英雄/装备/背包/营地/离线/招募面板。
- data/：英雄、敌人、任务、装备、掉落、等级、招募、营地等 JSON 数据。
- assets/art-v1/：基础英雄、怪物、Boss、装备、场景图集与单体 PNG。

### 资源接入现状

main 已经包含基础美术资源文件，但 main 的角色、敌人、地图绘制脚本尚未完整引用这些 PNG，因此“资源存在”不等于“运行画面已经显示”。基础资源归属与美术分支新增资源见 BRANCH_AUDIT.md。

## 5. 已知风险与待核查项

当前最重要的风险来自 art 分支尚未整合的 2.5D 代码，均为静态审查发现，尚未本机复现：

1. 地图尺寸不一致：WorldProjection、WorldMapManager、MapDrawer 使用 1200×900，但 Hero/Enemy/Boss 仍 clamp 到 1600×1200，可能走出可绘制地图。
2. 旧存档位置迁移未完成：旧版 1600×1200 共享地图坐标可能被直接载入新 1200×900 独立地图；map_from_legacy_position() 是未使用的 stub。
3. 竖屏视口 720×1280 下，投影地图约 1050×525，Camera2D 默认 zoom；地图占屏比例需要 Godot 实际画面验证。
4. 四张地图目前复用同一批树与地标，缺少按地图切换的独立装饰集合。
5. art 分支的静态角色/怪物/Boss 贴图已接入，但行走/攻击等动画未做；套装图标未叠加到角色战斗立绘。
6. 美术说明文档存在过期/相互矛盾的状态描述。
7. main 的 .gitignore 未忽略 .godot/；本地导入生成文件策略（.import、.uid）需另行确认，不能批量添加或删除。

具体代码路径、优先级和整合顺序见 BRANCH_AUDIT.md。

## 6. 建议的整合策略

1. 保持 main 为唯一稳定基线，不直接 force-push、不 reset、不用美术分支覆盖 main。
2. 以 feat/hero-world-art-integration 为主要技术参考；不重复合并其前置 2.5D 分支。
3. 从最新 main 建立整合分支，逐文件迁移投影/地图管理/地图绘制，再迁移单位渲染、UI 和资源。
4. 先修复坐标边界与旧存档迁移，再做角色/敌人贴图接入和地图切换。
5. 对玩法逻辑、存档、任务、装备、招募、营地等系统做回归检查；必要时保留 main 的更新实现，不机械复制旧分支。
6. Android 与 Godot CI workflow 单独审查后再决定是否接入。
7. 未运行验证的改动必须标注“未验证”，不得写成“完成”。

## 7. 下一步从哪里开始

**当前优先级：实现散件装备穿戴闭环，同时保护现有套装切换和旧存档。**

1. 为六个装备槽建立明确的散件装备状态与英雄归属。
2. 从背包穿戴/替换/卸下散件，正确应用攻击、生命、防御属性。
3. 明确散件与整套切换的互斥/恢复规则，避免套装加成重复计算。
4. 保存并恢复装备槽状态；旧存档没有散件穿戴字段时保持现有预设套装。
5. Godot 4.7.2 CI通过后，再安排移动端真机验收。

历史 2.5D 坐标迁移审查仍保留在下文，作为后续整合风险参考，不再覆盖当前最近开发优先级。

<!-- 历史计划原文保留如下，供追溯： -->

**历史第一优先级：完成坐标与存档迁移方案，随后才进入代码整合。**

1. 再确认用户本地工作区状态，保护 project.godot 和 Godot 生成文件。
2. 以当前 main HEAD 为整合基线。
3. 先定地图坐标唯一契约（1200×900 或其他明确尺寸）。
4. 设计旧版共享大地图坐标到新独立地图的存档迁移。
5. 迁移 WorldProjection、WorldMapManager、MapDrawer，并统一 Hero/Enemy/Boss clamp。
6. Godot 4.7.2 导入和运行验证通过后，再接入静态精灵、地图地标和 UI。

在上述清单完成前，不要求用户删除 FantasyRPG，不要求覆盖项目目录，也不执行未经审查的 merge/reset/checkout 覆盖操作。

## 8. 每次开发必须维护的记录

每个有意义的代码变更都应在 CHANGELOG.md 记录：
- 日期、分支、提交 SHA、提交标题；
- 修改文件和行为变化；
- 是否改变存档/资源格式；
- 测试命令、Godot 版本、运行环境和实际结果；
- 未解决问题及下一步。

每次会话结束前更新本文的“当前状态/下一步”，使下一次会话可以直接从仓库文档恢复上下文。


## 核心存档与招募修复分支（2026-11-04）

- 开发分支：`fix/core-save-recruitment-2026-11-04`，从当前 main 建立；不直接修改 main。
- 已实施但尚未运行验证的修复：
  1. 英雄生成时，在等级和装备重算最大生命后，按 hero id 恢复存档 HP；旧存档缺少英雄 HP 时保留满血默认。若存档时 HP 为 0（死亡延迟窗口），重新进入时按正常复活规则恢复半血。
  2. 新增碎片合成原子状态方法：成功招募时同时扣除配置要求的碎片。
  3. SaveManager 区分无存档的新游戏与现存档损坏；只有有效主档才会被复制覆盖备份，避免损坏主档覆盖最后有效备份。
- 注意：目前仍未做 Godot 4.7.2 headless/运行时验证、存档故障注入或移动设备回归。不得将本分支视为已验收。
- 下一步：本地拉取此分支，在 Godot 4.7.2 做脚本解析、首次启动、英雄受伤保存/重启、10 碎片合成和损坏主档+有效备份恢复测试；通过后再合并 PR。


## 世界坐标与存档迁移（2026-11-04，进行中）

- 当前正式 main 基线：`78a92e8e7158260cf185388bac3ee6b24a6db1e5`（已包含 PR #30 的分支/美术归档整理）。
- 当前工作分支：`feat/world-coordinate-save-migration-2026-11-04`。
- 新增纯函数迁移模块：`scripts/core/world_save_migration.gd`；将旧共享地图 1600×1200 的区域坐标转换为新地图 1200×900 的本地坐标。
- 区域识别依据旧 MapDrawer 的三个真实区域矩形；落叶幽谷要求精英 Boss 已击败；朝露林地要求精英 Boss 已击败且 `quests.completed.side_valley_puppet` 为 true。
- 已有新格式 `map_id` 坐标按本地坐标解释；未知或未解锁地图安全回退到苔冠空地，不再误按旧共享坐标缩放。
- 新增 8 项 GDScript 回归测试，并将测试命令加入 Godot 4.7.2 CI。
- 迁移模块目前尚未接入主场景加载/保存；本分支没有改变现有玩家存档、schema_version、经济、装备或战斗数据。
- 当前验证：Godot 4.7.2 资源导入、脚本解析、8 项迁移测试和 headless 启动已通过 run 41818333971；文档更新后的最终提交正在复核。当前运行环境没有 Godot 可执行文件，因此测试由 GitHub Actions 执行。
- 后续：CI 通过后，将迁移模块接入存档加载流程；迁移后的首次保存必须保留原始存档备份，再继续地图坐标与单位边界接入。
