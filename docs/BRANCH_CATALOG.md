# 远程分支总目录

> 核对时间：2026-11-04。仓库：oneyi53/game。初始快照共 42 条；后续 PR #31/#32 新增两条开发分支，盘点基数至少 44 条。
> 唯一正式主线：main；最近玩法整合提交 05ae26f4961a4d2f0b26cf243963b305dce61a60（后续文档同步可能更新 main HEAD）。
> 分支存在不代表已合并；PR 合并状态以 GitHub merged_at 为准。

## 使用规则
- 新工作一律从最新 main 建立主题分支；不在 main 直接做大功能。
- 已合并分支是历史来源，不作为新开发基线。
- 开放 PR 继续跟踪，不重复复制其改动。
- 关闭但未合并的 PR 不视为进入 main。
- 内容草稿逐文件审校后迁移，不整体 merge。
- 旧 2.5D/美术分支只作技术参考，先比对 tree/blob，再按模块迁移。

## 当前主线与开放 PR
| 分支 | 状态 | 用途 |
|---|---|---|
| main | 唯一正式主线 | 玩法基线 05ae26f4961a4d2f0b26cf243963b305dce61a60 |
| ci/godot-cloud-validation-2026-11-04 | PR #9 开放 | Godot 4.7.2 云端验证工作流 |
| docs/local-code-audit-2026-11-04 | PR #6 开放 | 本地代码审查文档 |
| feat/equipment-art-ui-2026-11-04 | PR #18 开放 | 装备美术 UI 接入候选 |

## 已合并 PR 来源
| PR | 分支 | 主题 |
|---:|---|---|
| #32 | feat/world-map-local-2-5d-integration-2026-11-04 | 四地图 2.5D 投影、map-local 坐标与旧存档运行时迁移 |
| #31 | feat/world-coordinate-save-migration-2026-11-04 | 旧共享地图坐标迁移纯函数与 8 项回归测试 |
| #30 | docs/verify-loose-equipment-merge-2026-11-04 | 分支盘点、原创 PNG 归档与 Godot 引用更新 |
| #29 | feat/loose-equipment-wearable-loop-2026-11-04 | 散件穿戴、属性、套装槽覆盖、存档兼容 |
| #28 | docs/update-development-records-2026-11-04 | 状态/日志同步 |
| #27 | feat/camp-building-party-bonuses | 营地建筑队伍增益 |
| #26 | feat/progression-fast-travel-destinations-2026-11-04 | 森林进度门槛传送点 |
| #24 | feat/campfire-fast-travel-v2-2026-11-04 | 营火传送 |
| #23 | feat/original-atlas-skill-vfx-2026-11-04 | 原创技能特效接入 |
| #22 | fix/mutually-exclusive-ui-panels-2026-11-04 | UI 面板互斥 |
| #20 | feat/backpack-equipment-icons-2026-11-04 | 背包散件图标 |
| #19 | feat/complete-art-asset-integration-2026-11-04 | 装备/场景素材接入 |
| #17、#16 | chore/consolidate-art-assets-2026-11-04 | 美术资源目录整理 |
| #15 | feat/consolidate-existing-art-2026-11-04 | 套装素材整理 |
| #14 | feat/forest-obstacle-collision-2026-11-04 | 森林障碍碰撞 |
| #12 | feat/forest-scene-art-2026-11-04 | 森林场景素材 |
| #11 | feat/sprite-art-pass-2026-11-04 | 英雄/怪物/Boss 精灵显示 |
| #10 | fix/fullscreen-floating-joystick-2026-11-04 | 全屏浮动摇杆 |
| #8 | docs/baillian-reference-study-2026-11-04 | 竞品研究与设计路线 |
| #7 | fix/core-save-recruitment-2026-11-04 | 核心存档与招募修复 |
| #5 | docs/audit-merge-sync | 分支审查记录同步 |
| #4 | docs/branch-audit | 2.5D/美术静态审查 |
| #3 | docs/handoff-sync | 项目交接记录 |
| #2 | docs/project-governance | 项目治理文档 |
| #1 | fix/android-apk-build | Android APK 构建工作流修复 |

## 已关闭但未合并的 PR
| PR | 分支 | 结论 |
|---:|---|---|
| #25 | feat/campfire-fast-travel-2026-11-04 | 未合并；后续实现以 #24 为准 |
| #21 | tools/effect-atlas-components-2026-11-04 | 未合并；工具拆图不是运行时依赖 |
| #13 | tools/inspect-effect-atlas-2026-11-04 | 未合并；仅云端检查/分析用途 |

## 无对应 PR 的远程分支
| 分支 | 处理建议 |
|---|---|
| content/area2-dialogues | 区域 2 对话草稿，逐文件审稿 |
| content/area3-dialogues | 区域 3 对话草稿，逐文件审稿 |
| content/area4-dialogues | 区域 4 对话草稿，逐文件审稿 |
| content/chat-art-apk-batch | 美术/APK 说明批次，只挑选仍有效内容 |
| content/m1-dialogues | M1 装备风味与任务对话草稿 |
| content/m1-text-draft | M1 装备、英雄、怪物、任务文案草稿 |
| content/next-chat-batch | 后续聊天批次素材与任务备忘 |
| content/system-draft | 系统设计草稿，需对照当前规则 |
| feat/backpack-item-art-2026-11-04 | 背包道具美术候选；先与 #19/#20 对照 |
| feat/floating-joystick-fullscreen-2026-11-04 | 摇杆历史候选；优先参考已合并 #10/#22 |
| feat/hero-world-2.5d-boss-p0 | 2.5D 前置技术分支，只作历史参考 |
| feat/hero-world-art-integration | 2.5D 后继美术整合分支，不可整分支 merge |
| feat/consolidate-existing-art-2026-11-04 | 与已合并套装/美术 PR 重叠 |
| fix/core-save-recruitment-2026-11-04 | 已合并 #7 的历史来源 |
| fix/android-apk-build | 已合并 #1 的历史来源 |
| fix/fullscreen-floating-joystick-2026-11-04 | 与已合并 #10 相关的历史候选 |

## 重要风险与优先级
1. 2.5D 分支存在 1200×900 地图/投影与旧 1600×1200 移动边界不一致、旧存档坐标未迁移等静态风险，见 BRANCH_AUDIT.md。
2. PR #29 虽已合并且 CI 通过，移动端触控、渲染、帧率与真实存档回归仍未验收。
3. 森林五个传送点目前仍是同一连续地图内快速移动，不等于独立场景切换。
4. 美术 PNG 已归档在 assets/art-v1/；避免从旧分支重复搬运已存在素材。

## 远程分支 HEAD SHA 快照

> 以下 SHA 是 2026-11-04 本次盘点时的固定快照；整理期间 PR #30 分支继续前进，因此该行记录的是本次整理前最后一个快照提交，不代表当前实时 HEAD。当前 PR 实时 head 请以 GitHub PR #30 页面为准。

| 分支 | HEAD SHA |
|---|---|
| chore/consolidate-art-assets-2026-11-04 | `fdb30a27130a44d5f1ce3d6ddb9b90b47b9a0dab` |
| ci/godot-cloud-validation-2026-11-04 | `4b1a3c358ee35208dea86551e963813846c4cf33` |
| content/area2-dialogues | `cb286b9548cf05f0b3ecdadbe402beecd1335fec` |
| content/area3-dialogues | `03a9c55da5631815362a5b247ee65a68968eb1ea` |
| content/area4-dialogues | `af95bab873d32b1c793567d3b4791a5ff270ac77` |
| content/chat-art-apk-batch | `dbe4e37224164ad790c294ffb595a0304460a779` |
| content/m1-dialogues | `30b32a422261332ea6bfa1fccb389e016404fc51` |
| content/m1-text-draft | `6b8241e09ae8137bb26c216eeee48bf34b1f6c05` |
| content/next-chat-batch | `1e79d4593c0b59f571fcc01163c901c0c60c2e19` |
| content/system-draft | `2be3b92d6706ac61b63bb9a3af2d59ea83c20049` |
| docs/audit-merge-sync | `a8da261a09ea36fdb20226b2f64389acf0d58dff` |
| docs/baillian-reference-study-2026-11-04 | `0527b99c06d512fd7c69b780c46c381e1e4ee07b` |
| docs/branch-audit | `50e3fdbccb44030b0c4b2b564f2884f20bf1de71` |
| docs/handoff-sync | `0a2b1a156595cb30f3de2fd5c7c40ae23a8b0e88` |
| docs/local-code-audit-2026-11-04 | `e19dff60a7759e20eb65cd0dbe19fc612dd3f5c5` |
| docs/project-governance | `81136b99a5bfc97b1a9f6a0343f70d050b5b03c0` |
| docs/update-development-records-2026-11-04 | `e477347115dde1a73203dc7438bcdeefadd0b253` |
| docs/verify-loose-equipment-merge-2026-11-04 | `396acf8f828d30286c7d988d4d6824dfe995daa6` |
| feat/backpack-equipment-icons-2026-11-04 | `a9848d14cfd5a262f64ce9526aafcbdccadef955` |
| feat/backpack-item-art-2026-11-04 | `68f6e399348cef4d110e0142f55347d48105a395` |
| feat/camp-building-party-bonuses | `33b829fbd202a5349d8df4f3385dd0abd83a79b7` |
| feat/campfire-fast-travel-2026-11-04 | `b2522ef36b0e9f7ab99a829b4e59149a1956d159` |
| feat/campfire-fast-travel-v2-2026-11-04 | `e17abf761e00b5ce1c051f62f95877f319ad06fb` |
| feat/complete-art-asset-integration-2026-11-04 | `5b2ede9040d8bbfeae85c41dbe0ef0e0521326dd` |
| feat/consolidate-existing-art-2026-11-04 | `64ab9b3feec0cd69b194b3da506edefb57cf83f2` |
| feat/equipment-art-ui-2026-11-04 | `d7b4aeda5b2590b31f961bf015f70ef2693c1de0` |
| feat/floating-joystick-fullscreen-2026-11-04 | `c197091777cb01b4de2d0938964f4fb7f0d0f4f8` |
| feat/forest-obstacle-collision-2026-11-04 | `d434069b2035ddd95e4ac2a86f9ec03b01f9e14e` |
| feat/forest-scene-art-2026-11-04 | `2bc4f151c65ebcb3b037a9a668103cad25e06842` |
| feat/hero-world-2.5d-boss-p0 | `bf01d75a3ab5fea5ab235de06351a75421c6cd91` |
| feat/hero-world-art-integration | `dd98b496750c4bbae0930a54c85b58bd27eaee07` |
| feat/loose-equipment-wearable-loop-2026-11-04 | `ea4d925af8de299276a97ac90d80e4bac3790d06` |
| feat/original-atlas-skill-vfx-2026-11-04 | `3b0e25d964b6653445d2efb4a98918816c7d4a68` |
| feat/progression-fast-travel-destinations-2026-11-04 | `6cac863f24dc21c586b5e39de7953b7bec3416d0` |
| feat/sprite-art-pass-2026-11-04 | `22e348500001c277ace54ad4fb4ea5f54b5518e8` |
| fix/android-apk-build | `b91d8ff8a7b13329f6cd056c5ce4c0581089ab7b` |
| fix/core-save-recruitment-2026-11-04 | `2cb9104068a62ae5f258656f43ca3db86c4f312b` |
| fix/fullscreen-floating-joystick-2026-11-04 | `5ae2eef6dbf494dd40891f56b660c46099ec37ad` |
| fix/mutually-exclusive-ui-panels-2026-11-04 | `1966912ee7a56edc264b73a5ceeb6563f5840da8` |
| main | `598216e6f67611b0f3db452718b4aa7cdf57ebb2` |
| tools/effect-atlas-components-2026-11-04 | `859cd5c2c579ce31fbecfb4297200eab4f68224d` |
| tools/inspect-effect-atlas-2026-11-04 | `f834d5c6d0900015c0702e4dbc580864ab15c5cb` |


## 盘点后新增 PR #31/#32 分支（2026-11-04）

| 分支 | 状态 | 用途 |
|---|---|---|
| feat/world-coordinate-save-migration-2026-11-04 | PR #31 已合并 | 旧共享地图坐标迁移纯函数与 8 项测试 |
| feat/world-map-local-2-5d-integration-2026-11-04 | PR #32 已合并 | 四地图 2.5D 投影、统一单位边界、map_id/map_positions 存档接入 |

PR #30、#31、#32 均已合并。当前远程 refs 请以 GitHub 实时分支列表为准；上文 SHA 表是原始盘点固定快照。


## 2026-11-05 新增分支

| 分支 | 状态 | 用途 |
|---|---|---|
| `feat/reference-grade-world-exploration-2026-11-05` | 新建，开发中 | 以《百炼英雄》为硬性体验基准，重做地图探索、镜头空间、角色动作、探索/战斗循环；从 main 创建，独立 PR，不与 #49/#50 混并 |


## 2026-11-05 对标统一治理：所有分支执行同一体验基准

用户要求：凡与“以《百炼英雄》为硬性体验基准”存在分歧的开发分支，全部调整。自本节起，以下规则适用于所有现存分支、开放 PR、新建分支和未来合并：

### 统一规则
- `main` 仍是唯一正式主线；不得为了追赶进度将多个过期分支直接整体合并，也不得未经核对强制改写/删除分支历史。
- 任何涉及地图、角色、战斗、探索、传送、成长、HUD、任务的功能分支，必须遵守 `BAILIAN_HERO_REFERENCE_STUDY.md` 第 13 节的验收维度。若实现与该基准冲突，先在原分支修正或从最新 main/cherry-pick 重建，再申请合并。
- UI/红点/每日活跃/装备图标/构建等子系统分支允许独立交付，但只能作为支撑模块；不得声称完成核心体验，也不得用面板或图标替代真实玩法闭环。
- 构建分支必须支持指定 feature SHA 的 APK 构建和产物校验；APK 只能代表对应 SHA，不得用旧包代表新功能。
- 对标是玩法体验与系统组织标准，不是复制其代码、美术、文案、角色或数值。

### 当前开放 PR 处理决定
| PR | 分支 | 处理 |
|---:|---|---|
| #50 | `feat/reference-hud-layout-2026-11-05` | 保留；摇杆/HUD 属于基础设施，补充最终必须服务地图、队伍、战斗、营地/传送，并完成设备验收的约束 |
| #49 | `feat/daily-activity-panel-ui` | 保留；仅作为面板组件，后续必须接真实探索/战斗/成长事件、奖励存档和红点，不作为完整日常系统 |
| #48 | `ci/optimize-android-apk-export-2026-11-05` | 保留；定位为指定 feature SHA 的 APK 交付基础设施，必须校验产物和安装启动 |
| #47 | `feat/daily-activity-core-2026-11-04` | 保留；成长子系统必须由真实玩法事件驱动，奖励与存档一致性验收后才可接入主流程 |
| #45 | `feat/red-dot-indicator-ui-2026-11-04` | 保留；红点只能由真实业务状态派生，不得作为装饰状态 |
| #18 | `feat/equipment-art-ui-2026-11-04` | 保留审查；图标展示必须与真实装备/属性/掉落/成长闭环一致，且先解决当前 mergeable=false 冲突 |
| #9 | `ci/godot-cloud-validation-2026-11-04` | 保留；CI 是质量门禁，不代表玩法、画面或真机验收 |
| #6 | `docs/local-code-audit-2026-11-04` | 保留；静态审查文档只记录证据，不把静态结论写成运行复现 |

### 历史分支处置
- 已合并到 main 的旧功能分支是历史来源，不反向回滚；若其功能与新标准不符，在新的统一体验分支中按模块重做。
- 旧 2.5D、地图、美术、障碍碰撞、传送等分支只作为代码/资源参考；先做 tree/blob 与提交差异审查，禁止整分支覆盖 main。
- 内容草稿分支只逐文件审校迁移；不得因对标要求而复制竞品文案或世界观。
- 构建、测试、工具、文档分支不属于玩法方向冲突，但必须服从上述质量与记录规则。

本轮已更新开放 PR #49/#50/#48/#47/#45/#18 的描述，明确其在全局对标中的边界；未关闭、删除或强制重写任何分支。分支目录仍需随每次 PR 合并/关闭更新。


## 2026-11-05 本次沟通交接补记

- 用户再次明确：所有与《百炼英雄》硬性体验基准存在分歧的开发方向必须统一调整；本次沟通与处理结论已同步到 `PROJECT_STATUS.md` 和 `CHANGELOG.md`。
- 当前分支 `feat/reference-grade-world-exploration-2026-11-05` 是统一体验实现分支；它尚未完成运行时代码重构，不能将分支治理文档更新等同于玩法实现完成。
- 开放 PR 的支撑模块边界已在 PR 描述中补充；PR #49 描述此前可能存在重复的治理段落，后续应清理重复文本。PR #18 当前 mergeable=false，须解决冲突后再审查。
- 未执行：历史分支逐个 rebase/代码改写、PR 合并/关闭、Android APK 生成与真机安装验证。
- 后续审查清单：重新获取实时远程分支和开放 PR；逐个 compare 最新 main 与分支 head；重点核对旧 2.5D/地图/障碍碰撞/角色移动/传送/美术分支；按 aligned、support-only、conflicts-with-benchmark、stale、needs-conflict-resolution 分类；只 cherry-pick 或逐文件迁移经过验证的模块。

## 2026-11-05 全仓分支一致性审计索引

- 本次最高开发方向与逐分支处理矩阵见 `docs/REFERENCE_ALIGNMENT_AUDIT_2026-11-05.md`。
- 已核对实时分支与开放 PR；PR #49 重复约束段已清理。
- 旧 2.5D/地图/美术分支作为历史候选，逐文件迁移，不整分支覆盖；支撑 PR 保留但必须服从完整玩法闭环验收。
- 审计不等于代码重构完成；main 运行时代码未改，旧分支尚未逐个重写，APK/真机验证未完成。

## 2026-11-05 统一体验分支执行记录
- 已提交首个运行时代码改造：Hero 平滑加速/制动、队员追赶、朝向与轻量程序化动作反馈（非帧动画）。
- 地图扩大暂缓，须先完成投影/相机/碰撞/存档坐标统一设计。
- 运行验证、Godot 导出及 APK 真机验收未完成；不得将此提交标记为可测试 APK。


## 2026-11-05 开源项目复用审查记录
- 新增 `docs/OPEN_SOURCE_CODE_REUSE_STUDY_2026-11-05.md`，记录三个参考项目的固定 commit、许可证、重点脚本、可迁移模块和采用边界。
- 两个 MIT 项目可按许可要求移植算法，但 Unity/Pygame 源码不兼容 Godot；Godot 参考项目无许可证，不复制其代码/资源。
- 本轮仅完成研究与复用决策，无上游代码直接合入；后续按地图/战斗/掉落优先级逐项实现并验证。

## 2026-11-05 战斗反馈实现记录
- 统一体验分支新增普通敌人攻击预警/前摇、出手前距离复核、受击打断、受击闪烁与击退；实现位于 `scripts/enemy/enemy.gd`。
- 这是基于通用战斗设计原则的独立 GDScript 实现，不复制无许可证项目的代码。
- 尚待 Godot 4.7.2 运行测试与数值调优；未产出 APK。

## 2026-11-05 英雄攻击反馈
- 开发分支新增英雄朝向目标的挥击弧光，队长技能使用更长反馈；仍非真正逐帧人物动画。
- 待原创 sprite sheet 接入后再完成待机/行走/攻击动画。尚未运行 Godot 或导出 APK。

## 2026-11-05 户外路径网络
- 三张户外地图新增分支式土路视觉层，提升主路、岔路和区域连接的可读性。
- 目前只是视觉路径，不代表已完成地形碰撞、资源采集或完整大地图；未运行 Godot 验证。

## 2026-11-05 地图边界扩展
- 地图逻辑边界与等距投影统一为 1600×1400，覆盖远端区域敌人出生点；幽谷和林地道路延伸至新区域。
- 仍需 Godot 实机验证相机边界、旧存档迁移和全区域移动。


## 2026-11-05 资源采集首版
- 在统一体验分支新增 `scripts/interactable/resource_node.gd`，并由 `scripts/core/main.gd` 动态生成 6 个户外木材点。
- 资源采集接入现有交互按钮、木材 HUD 与存档；旧存档兼容，采集状态跨地图/重启持久化。
- 未运行 Godot/未导出 APK；该功能尚未通过运行验收。


### 2026-11-05 操作对标记录
- 已补充公开资料支持的单摇杆移动、松手停止与自动攻击基准。
- 当前摇杆触点区域、按钮热区和布局参数仍待实机证据校准；未更改 main，未宣称真机验证。


## 2026-11-05 探索迷雾实现记录
- 统一体验分支新增 `scripts/core/exploration_fog.gd`，并在 `scripts/core/main.gd` 接入按地图持久化的探索网格。
- 户外地图队长周围持续揭开迷雾，城镇不使用迷雾；切图恢复已探索区域，移动探索触发节流自动保存。
- 该功能属于首版网格视野遮罩，尚无视线遮挡/探索度奖励；Godot 运行、存档回归与 APK 验证未完成。


## 2026-11-05 单机成长与离线收益参考落实
- 审核用户提供的全维度拆解：联机、公会、跨服内容不纳入项目；5V6卡牌站桩战斗与当前自由移动探索战斗冲突，不移植；720×1280 Godot 视口保持现有适配体系，不机械改成1080×2340；不引入Unity DOTween依赖。
- 现有单机离线收益系统已将封顶由8小时调整为12小时，保留原有金币/木材产出与10分钟阈值；具体小时收益仍为项目配置假设。
- 角色技能继续保留探索战斗中的队长手动释放，不套用未验证的能量100点/角色职业自动施法规则。
- 代码已提交，未运行Godot或导出APK。


## 2026-11-05 怒气主动技能首版
- 统一体验分支将队长主动技能改为手动消耗3/10怒气；队长普攻命中积攒1格，HUD显示怒气。
- 当前仅一个技能槽，未实现5格第二技能/怒气满额强化/队伍共享怒气/元素克制；未运行Godot验证、未导出APK。
