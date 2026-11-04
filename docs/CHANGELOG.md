# 开发变更日志

## 2026-11-04 — 散件装备穿戴闭环（开发分支，待 CI 验证）

- 分支：`feat/loose-equipment-wearable-loop-2026-11-04`（基于 main `4dba3ea6947d8661f82f35199e8e0cf2c4d270a1`）。
- 修改文件：`scripts/progression/equipment_manager.gd`、`scripts/progression/backpack_manager.gd`、`scripts/ui/backpack_panel.gd`、`scripts/ui/equip_panel.gd`、`scripts/character/hero.gd`、`scripts/core/main.gd`，以及本文档。
- 变更：背包可选择队伍英雄穿戴散件；同槽替换时旧装备回到背包；装备面板显示当前散件槽并支持卸下；卸下后回到背包，背包满时进入原有邮箱溢出流程。散件平面攻击/生命/防御加成纳入统一属性重算。
- 槽位：武器（铁剑/短刀互斥）、胸甲、护腕、鞋子、副手盾牌。副手为独立槽，不侵占套装六槽。
- 套装兼容：散件覆盖武器/胸甲/护腕/鞋子时，对应底层套装件不计入套装数量；卸下散件后底层套装部件恢复计数。散件永不计入套装。
- 数据/存档兼容性：新增可选 `loose_equipment` 存档字段；原 `equipment` 字段保持原格式，旧存档无新字段时保持原套装状态；schema_version 不变。未修改散件掉落、背包上限、分解收益、强化/合成规则。
- 验证环境：GitHub Actions / Godot 4.7.2，等待本 PR 自动检查。
- 验证结果：提交前静态复核；CI 尚未完成，不能视为运行验证通过。移动端真机未验收。
- 已知限制：当前散件配置没有头盔和饰品类型；装备外观只在面板显示，不叠加到角色战斗立绘。
- 下一步：通过 CI 后检查 PR 差异与存档兼容，再合并；合并后补录最终 PR/commit 与 CI 结果。


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
