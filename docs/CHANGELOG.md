# 开发变更日志

## 2026-11-04 — 散件装备穿戴闭环（PR #29 已合并）

- PR：[#29](https://github.com/oneyi53/game/pull/29)，分支：`feat/loose-equipment-wearable-loop-2026-11-04`，合并提交：`598216e6f67611b0f3db452718b4aa7cdf57ebb2`。
- 修改文件：`scripts/progression/equipment_manager.gd`、`scripts/progression/backpack_manager.gd`、`scripts/ui/backpack_panel.gd`、`scripts/ui/equip_panel.gd`、`scripts/character/hero.gd`、`scripts/core/main.gd`，以及本文档。
- 变更：背包可选择队伍英雄穿戴散件；同槽替换时旧装备回到背包；装备面板显示当前散件槽并支持卸下；卸下后回到背包，背包满时进入原有邮箱溢出流程。散件平面攻击/生命/防御加成纳入统一属性重算。
- 槽位：武器（铁剑/短刀互斥）、胸甲、护腕、鞋子、副手盾牌。副手为独立槽，不侵占套装六槽。
- 套装兼容：散件覆盖武器/胸甲/护腕/鞋子时，对应底层套装件不计入套装数量；卸下散件后底层套装部件恢复计数。散件永不计入套装。
- 数据/存档兼容性：新增可选 `loose_equipment` 存档字段；原 `equipment` 字段保持原格式，旧存档无新字段时保持原套装状态；schema_version 不变。未修改散件掉落、背包上限、分解收益、强化/合成规则。
- 验证环境：GitHub Actions / Godot 4.7.2，GitHub Actions / Godot 4.7.2。
- 验证结果：Godot 4.7.2 云端资源导入、脚本解析、无头启动通过（Actions runs 41809736359、41809725550）。这不是完整玩法回归；移动端真机未验收。
- 已知限制：当前散件配置没有头盔和饰品类型；装备外观只在面板显示，不叠加到角色战斗立绘。
- 下一步：已合并。后续进行移动端穿戴交互、存档回归与视觉验收。


本文件记录可追溯的项目变更。Git commit 是代码事实来源；本日志解释每次变更的目的、范围和验证状态。

## 2026-11-04 — 2.5D 静态审查文档合并至 main

- PR：[#4](https://github.com/oneyi53/game/pull/4)
- 来源分支：docs/branch-audit
- 目标分支：main
- 合并方式：Squash merge
- 合并提交：ea1d4fd7c705fe3e527e3591cca42b851f2f27e6
- 变更文件：README.md、docs/PROJECT_STATUS.md、docs/CHANGELOG.md、docs/BRANCH_AUDIT.md
- 变更说明：记录 main 与 2.5D/美术分支的递归 tree/blob 净差异，纠正基础美术资源已在 main 的判断，并记录地图边界、旧存档迁移、镜头构图、地图装饰和动画等风险。
- 影响范围：仅文档；没有修改游戏代码、美术资源、Godot 项目配置或存档结构。
- 验证：审查四个文档文件；GitHub 显示 PR 可合并且状态 clean，已成功合并。Godot 导入/运行/设备验证未执行。
- 下一步：设计地图坐标契约与旧存档迁移，随后从最新 main 逐文件迁移 2.5D 代码。

## 2026-11-04 — 2.5D / 美术分支静态审查与资源归属纠错

- 基线：main 97e23ed3d3fbc5e44d220d069c0daf6cad015ebe。
- 审查分支：feat/hero-world-2.5d-boss-p0、feat/hero-world-art-integration。
- 方法：GitHub compare 核对提交关系；读取三个分支递归 Git tree，并按 blob SHA 比对实际文件归属；静态阅读投影、地图、主流程、英雄、敌人、Boss、交互物、UI 和 CI 文件。
- 重要纠错：基础图集、英雄/怪物/Boss/散件/场景单体 PNG 和预览图已经存在于 main，且与美术分支 blob SHA 相同。此前将这些基础资源判断为 main 缺失，是把三点比较文件列表误当成净差异造成的错误。
- 美术分支相对 main 真正新增：Godot 4.7.2 检查 workflow、WorldProjection/WorldMapManager/TreeVisual/LandmarkVisual 四个脚本、3 套装备 18 张 PNG 及 manifest/preview。
- 美术分支修改：main 场景、地图、主流程、英雄/敌人/Boss、营火/宝箱、背包/装备/英雄/HUD/离线/招募/摇杆 UI，以及 Android workflow 和 README。
- 静态发现：地图尺寸 1200×900 与 Hero/Enemy/Boss 1600×1200 clamp 不一致；旧版共享大地图存档位置没有迁移到新地图本地坐标；相机投影占屏比例、地图装饰分区、静态精灵动画等仍需验证/完善。
- 文档：新增 docs/BRANCH_AUDIT.md；更新 README.md、docs/PROJECT_STATUS.md。
- 验证：仅完成 GitHub 远程静态审查；未执行 Godot 导入、运行、Android 导出或真机验证。
- 下一步：先设计统一地图坐标契约与旧存档迁移，再从当前 main 逐文件迁移 2.5D 代码；不整分支 merge。

## 2026-11-04 — 项目治理文档合并至 main

- PR：[#2](https://github.com/oneyi53/game/pull/2)
- 来源分支：docs/project-governance
- 目标分支：main
- 合并方式：Squash merge
- 合并提交：9e18e3f7065b0d19ab652a8c17840a08921b7d03
- 变更文件：README.md、docs/PROJECT_STATUS.md、docs/CHANGELOG.md、docs/DEVELOPMENT_WORKFLOW.md
- 变更说明：建立项目长期状态档案、分支关系说明、逐次变更日志和开发/会话交接规范。
- 影响范围：仅文档；没有修改游戏代码、美术资源、Godot 项目配置或存档结构。
- 验证：审查 PR 四个文件；GitHub 显示 PR 可合并且状态 clean，已成功合并。Godot 导入/运行/设备验证未执行（文档变更不涉及运行时代码）。

## 2026-11-04 — 项目治理文档建立（初始提交）

- 分支：docs/project-governance
- 基础：从当时 GitHub main HEAD afddb7028a327b9c22d1d13450b967e944f63548 创建。
- 变更：更新 README.md；新增 docs/PROJECT_STATUS.md、docs/CHANGELOG.md、docs/DEVELOPMENT_WORKFLOW.md。
- 目的：让后续开发者/会话能够从仓库文档恢复项目上下文，避免重复摸索或误合并旧分支。
- 验证：通过 GitHub API 核对分支名、提交关系及部分文件差异；当时尚未在本地运行 Godot。该文档 PR 后续已合并到 main。
- README 提交：06cdd999508dbb4072aeca0ecf230dab6d13c7f1。
- 项目档案提交：af9d13c054a56ced72828df178fbb6e9e6c85854。
- 本日志提交：108c2d9958730a7fe8475c6796c3e68c23bce84a。
- 工作流规范提交：10f976fd1484f91c4114adcf75a8b4b99483ac1e。

## 记录规则

后续每次代码或资源变更追加一节，格式如下：

### YYYY-MM-DD — 简短主题

- 分支：
- Commit：
- 修改文件：
- 变更说明：
- 数据/存档兼容性：
- 验证环境：
- 验证结果：通过 / 失败 / 未验证
- 已知问题：
- 下一步：


## 2026-11-04 — 核心存档与招募问题修复（待验证）

- 分支：`fix/core-save-recruitment-2026-11-04`（从 main 建立）。
- 修改文件：`scripts/core/main.gd`、`scripts/core/save_manager.gd`、`scripts/progression/recruitment_manager.gd`、`docs/PROJECT_STATUS.md`、`docs/CHANGELOG.md`。
- 变更：恢复英雄已保存 HP；碎片英雄合成成功后消费配置数量的碎片；区分首次启动与双档损坏；备份前先验证主存档，避免损坏主档覆盖有效备份。
- 存档兼容：没有 heroes HP 记录的旧档仍以满血初始化；保存时 HP 为 0 的英雄重启后按普通复活规则恢复半血；schema_version 未改变。
- 验证环境：尚未在本地 Godot 4.7.2 执行。
- 验证结果：未验证。静态检查已复核修改后的代码片段，但没有运行时测试或故障注入。
- 下一步：测试首次启动、英雄 HP 保存恢复、碎片合成/不足/重复合成、损坏主档+有效备份恢复和保存失败场景。


### 2026-11-04 — 营地建筑队伍增益接入

- PR：[#27](https://github.com/oneyi53/game/pull/27)
- 分支：`feat/camp-building-party-bonuses`
- 合并提交：`6bd91e71165325f021adf33ee4284934a3902ec3`
- 修改文件：`scripts/character/hero.gd`、`scripts/core/main.gd`、`scripts/ui/camp_panel.gd`。
- 变更说明：铁匠铺建成后为全队提供攻击力 +5%；训练场建成后为全队提供最大生命 +8%。统一英雄属性重算路径，将等级成长、装备套装和营地加成按固定顺序重新应用，避免重复叠加；重算时保留当前生命比例。新招募英雄同样应用已建成建筑的增益；营地面板显示建筑效果。
- 数据/存档兼容性：复用现有营地建筑建成状态，不新增存档字段、不改变 schema；未建成建筑的旧存档属性不变。
- 验证环境：GitHub Actions，Godot 4.7.2。
- 验证结果：PR 分支资源导入、脚本解析、无头启动通过（run 41807763066）；合并后 main 验证 run 41807868225 在本记录更新时仍为 in_progress，待完成后补记。
- 已知问题：尚未完成 Android/iOS 真机数值与 UI 验收；建筑加成为固定数值，尚无升级等级系统。
- 下一步：完善散件装备从背包到六个装备槽的穿戴、属性应用与存档闭环，保留现有整套切换兼容。

### 2026-11-04 — 森林区域传送目的地与进度门槛

- PR：[#26](https://github.com/oneyi53/game/pull/26)
- 分支：`feat/progression-fast-travel-destinations-2026-11-04`
- 合并提交：`0f6ebd6dc0814d9f9b0b02356791ad5e7fcd20db`
- 修改文件：`scripts/core/main.gd`。
- 变更说明：传送面板按进度显示森林入口、营火据点、苔冠空地、落叶幽谷和朝露林地；锁定地点显示条件，选择时再次校验解锁状态。传送时同步移动队伍、清零移动速度、同步镜头并保存队长位置。
- 数据/存档兼容性：继续使用原有任务/Boss/营火进度标记与 `player_position`，没有新增存档字段。
- 验证环境：GitHub Actions，Godot 4.7.2。
- 验证结果：PR 分支验证通过（run 41806042140、41806054521）；合并后 main 验证通过（run 41806133682）。
- 已知问题：目前目的地仍位于同一张连续森林地图内，属于地图内快速移动，并非独立场景/地图加载；真实设备镜头与交互体验尚未验收。
- 下一步：结合后续独立区域地图规划，再决定场景切换和跨地图传送的数据结构。

### 2026-11-04 — 原创技能特效图集接入

- PR：[#23](https://github.com/oneyi53/game/pull/23)
- 变更文件：`scripts/fx/effect_player.gd` 及技能特效调用路径（以 PR 实际差异为准）。
- 变更说明：使用用户确认已替换为原创素材的 `effect_atlas.png`，为英雄技能接入施放/命中特效。
- 数据/存档兼容性：不改变存档结构。
- 验证环境：GitHub Actions，Godot 4.7.2。
- 验证结果：PR 合并后验证通过（run 41800701893）；尚未完成真机视觉效果验收。
- 已知问题：不同技能的特效裁切、帧序与移动端实际观感仍需运行时检查。
- 下一步：在完整战斗流程中检查技能特效触发时机与资源表现。


## 2026-11-04 — 主线/分支记录统一与原创 PNG 归档

- 工作分支：`docs/verify-loose-equipment-merge-2026-11-04`（PR #30）。
- 基线：main `598216e6f67611b0f3db452718b4aa7cdf57ebb2`。
- 修改：项目状态、分支审查、远程分支目录、美术资源说明、Godot 资源引用与 PNG 归档。
- 分支整理：记录本次快照中的 42 条远程分支，区分主线、开放 PR、已合并来源、已关闭未合并 PR、内容草稿和历史候选。
- PNG 归档：`effect_atlas.png` → `assets/art-v1/effects/effect_atlas.png`；`icon.png` → `assets/art-v1/branding/icon.png`。保留原 Git blob，不重绘、不压缩。
- 引用更新：同步更新特效 preload 与 `project.godot` 应用图标路径。
- 数据/存档兼容：未改数据 JSON、存档字段或 schema；只调整两个 PNG 的资源路径。
- 验证：GitHub 文件树/Blob 静态核对；素材路径变更后的 Godot 4.7.2 资源导入、脚本解析和 headless 启动通过（run 41816598943）；最新文档提交检查通过（run 41816687698）。移动端未验收。
- 下一步：完成 Godot 导入验证后，从 main 新建 2.5D 坐标/旧存档迁移分支。


## 2026-11-04 — 世界坐标与旧存档迁移第一阶段

- 从合并后的 main `78a92e8e7158260cf185388bac3ee6b24a6db1e5` 建立分支 `feat/world-coordinate-save-migration-2026-11-04`。
- 新增纯函数迁移层 `scripts/core/world_save_migration.gd`：旧 1600×1200 共享地图坐标转换到 1200×900 地图本地坐标；按旧地图区域和 Boss/任务解锁状态选择目标地图。
- 新格式合法 `map_id` 保存按地图本地坐标保留；未知/锁定地图安全回退到苔冠空地，不将新格式坐标误当旧共享地图坐标重新缩放。
- 新增 8 项 GDScript 回归测试，覆盖苔冠、落叶、朝露双门槛、锁定地图、旧区域外坐标、已有新格式坐标和缺失位置。
- 更新 Godot 4.7.2 CI，导入/解析/启动检查后执行迁移测试脚本。
- 新增 `docs/WORLD_COORDINATE_MIGRATION.md` 记录坐标契约和迁移规则。
- 本阶段尚未把迁移层接入主场景，也未改变现有存档写入；未改 schema_version、经济数值、背包、装备、任务或战斗规则。
- 验证状态：Godot 4.7.2 资源导入、脚本解析、8 项迁移测试与 headless 启动已在 run 41818333971 通过；后续文档提交的 CI 正在复核。移动端未验收。
- 下一步：根据 CI 结果修复测试/解析问题；之后接入加载迁移，并在保存新格式前保留原存档备份。


## 2026-11-04 — 2.5D 地图本地坐标与运行时接入（PR #32 已合并）

- 基线：main `f1cc665815c312106c8e2b46e59556c02f704618`；合并提交 `05ae26f4961a4d2f0b26cf243963b305dce61a60`；分支 `feat/world-map-local-2-5d-integration-2026-11-04`。
- 新增 `WorldMapManager` 与 `WorldProjection`：四张 1200×900 独立地图；逻辑坐标与屏幕投影分离。
- Hero、Enemy、Boss 统一使用 map-local 边界；敌我目标按 map_id 过滤；Boss 预警圈和技能特效投影至同一屏幕坐标系。
- MapDrawer 增加各地图独立地面主题、树木/地标与碰撞阻挡；地图切换通过 HUD 地图按钮和营火传送面板完成。
- Main 接入旧存档迁移，保存 `map_id`、`map_positions` 和当前玩家位置；切图时保存离开地图的位置并恢复目标地图位置。
- 旧存档迁移后在启动初始化完成时自动写入新格式；SaveManager 先将有效旧主存档复制为备份；损坏主档从备份恢复时不会覆盖有效备份。
- 纠正解锁规则：落叶幽谷由精英 Boss 解锁（不是普通主 Boss）；朝露林地由精英 Boss + `side_valley_puppet` 任务解锁。
- 存档 schema_version 仍为 1；保留散件装备 `loose_equipment`、套装、背包、任务、招募、营地、离线结算和英雄 HP 字段。
- 验证：Godot 4.7.2 导入/脚本解析、13 项地图/坐标回归测试、headless 启动通过（PR 分支 run 41820724625）；合并后 main 检查 run 41820854788 正在执行。
- 未验收：Android 真机触控、竖屏投影画面比例、帧率、长时间战斗、真实旧存档升级和备份恢复。
- 下一步：PR #32 合并后进行 Android 真机全流程验收，按设备画面调整镜头 zoom 与地图视觉尺寸。


### 2026-11-04 — 《百炼英雄》截图拆解补充与系统状态校准

- 分支：`docs/gameplay-ui-system-reference-2026-11-04`。
- 基线：main 已合并 PR #31（旧坐标迁移）与 PR #32（四地图 2.5D 运行时整合）；PR #32 合并提交 `05ae26f4961a4d2f0b26cf243963b305dce61a60`。
- 修改文件：`docs/BAILIAN_HERO_REFERENCE_STUDY.md`、`docs/PROJECT_STATUS.md`、`docs/CHANGELOG.md`。
- 变更说明：补充主城建筑入口、英雄收藏/编队、战力计算、任务活跃度、红点派生、弹窗视觉规范及 H5 技术线索到 Godot 模块的映射；按当前 main 代码区分已实现与待开发。
- 数据/存档兼容性：仅文档变更，不修改游戏数据、存档字段、schema_version 或运行时代码。
- 验证环境：GitHub 仓库 main 文件静态核对；检查 `WorldMapManager`、`WorldProjection`、`Main`、`Hero`、`SaveManager` 与现有竞品研究文档。
- 验证结果：文档静态核对；无 Godot 运行测试（本次未改运行时代码）。
- 已知问题：英雄编队编辑、统一战力评分、建筑实体入口、红点系统和日常活跃度奖励仍需独立实现；Android 真机验收仍未完成。
- 下一步：先完成 PR #32 的 Android 真机验收，再按编队/战力、建筑入口、任务红点顺序开发。


## 2026-11-04 — 英雄编队系统第一阶段：数据层

- 分支：`feat/hero-formation-data-layer-2026-11-04`。
- 修改文件：`scripts/core/formation_manager.gd`、`tests/test_formation_manager.gd`、`.github/workflows/godot-cloud-validation.yml`、`docs/HERO_FORMATION.md`、`docs/PROJECT_STATUS.md`、`docs/CHANGELOG.md`。
- 变更说明：新增已拥有英雄与出战编队分离的数据管理器，支持上阵、下阵、换位、队长固定首槽、队伍上限与存档序列化；默认上限 4。
- 数据/存档兼容性：本阶段未接入 SaveManager/Main，不修改现有存档，不改变当前队伍生成行为。
- 验证环境：GitHub Actions / Godot 4.7.2。
- 验证结果：等待 PR CI；包含 10 项编队规则测试、既有 13 项地图/坐标测试和 headless 启动。
- 已知问题：编队数据层尚未接入运行时与 UI；非上阵英雄的装备/等级管理将在下一阶段统一处理。
- 下一步：CI 通过后审查合并，再实现英雄收藏与编队编辑界面及队伍生成接入。


## 2026-11-04 — 英雄编队规则调整：队长可更换（PR #35 更新中）

- 分支：`feat/hero-formation-data-layer-2026-11-04`。
- 修改文件：`scripts/core/formation_manager.gd`、`tests/test_formation_manager.gd`、`docs/HERO_FORMATION.md`、`docs/PROJECT_STATUS.md`、`docs/CHANGELOG.md`、`.github/workflows/godot-cloud-validation.yml`。
- 变更：取消固定 `captain` ID 和首槽锁定；任意已拥有英雄均可成为队长。预备英雄提拔时，满编队伍会将原队长移入预备名单；下阵队长时下一位队员接任；任意槽位可交换；队伍至少保留一名出战英雄。
- 存档兼容：`formation.active_ids` 仍是有序 ID 数组，首位即队长；旧存档中 `captain` 若仍在队伍会按原顺序保留，但不再享有不可替换特权；不改 schema_version。
- 验证：原 PR CI run 41823230083 通过的是旧规则；本次新增 13 项测试，等待更新后 Godot 4.7.2 CI 复验。
- 下一步：检查新 CI 结果，通过后再合并 PR #35；随后进入 UI/运行时接入阶段。


## 2026-11-04 — 英雄编队第二阶段：运行时与 UI（PR #36，待验证）

- 分支：`feat/hero-formation-runtime-ui-2026-11-04`。
- 接入 FormationManager 到 Main：拥有英雄与出战英雄分离，存档新增 `formation.active_ids`；旧存档缺少字段时按原英雄顺序迁移，默认上限 4。
- 世界仅生成上阵英雄；首槽英雄作为可更换队长。支持在英雄面板中设置队长、上阵、下阵；满编时预备英雄可替换当前队长。
- 编队变化时重建活动英雄节点和跟随关系，更新装备/背包面板引用；按 hero_id 保存等级、经验、装备，HP 缓存跨编队切换保留。
- 新增 HeroPanel 滚动编队名单和动态操作按钮，调整主场景面板布局。
- 验证：PR #36 Godot 4.7.2 CI 通过，run 41824551382；资源导入、脚本解析、世界坐标/编队测试及 headless smoke test 全部成功。Android 真机尚未验收。
- 限制：预备英雄已保留等级/装备数据，但当前装备与背包操作面板仍只绑定世界中上阵英雄；后续补充收藏英雄详情/装备入口。


## 2026-11-04 — 英雄编队第三阶段：预备英雄装备管理（PR #37，待验证）

- 基线：PR #36 已合并，提交 `f4f9a28429caf6ee1cec2d6b4155a4d23f93ee7a`。
- 分支：`feat/reserve-hero-equipment-2026-11-04`。
- 装备面板新增全拥有英雄 roster，预备英雄可查看/切换套装、查看散件槽位并卸下装备。
- 背包穿戴目标列表扩展到所有已拥有英雄；Main 按 RecruitmentManager 校验拥有权，不再要求目标必须是当前运行时 Hero 节点。
- 预备英雄装备仍按 hero_id 写入原有存档字段，不新增或改变装备存档 schema；上阵后通过现有属性重算应用装备。
- 招募新英雄后刷新英雄装备和背包目标列表，背包选项标注出战/预备。
- 新增 4 项 EquipmentManager 回归测试，覆盖预备英雄套装、散件、存档往返和属性加成。
- 验证：等待 Godot 4.7.2 CI；Android 真机验收仍未完成。
