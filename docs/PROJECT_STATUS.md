# 项目状态与架构档案

> 本文是 Hero World 的长期项目上下文入口。更新代码或分支关系后，必须同步更新本文及 CHANGELOG.md。
> 最后核对：2026-11-04。核对范围：GitHub 当前主线、远程分支关系、递归 Git tree/blob SHA、关键 2.5D 与美术接入脚本。未在本机 Godot 4.7.2 运行验证。

## 当前交接状态（2026-11-04）

- 当前 main HEAD：97e23ed3d3fbc5e44d220d069c0daf6cad015ebe。
- 项目治理文档 PR #2、交接状态更新 PR #3 均已 squash 合并到 main。
- 本轮完成了 2.5D / 美术分支静态审查，详细发现见 BRANCH_AUDIT.md。
- 重要纠正：main 已经包含大部分基础美术资源（原始图集、英雄/怪物/Boss/散件/场景单体 PNG 和预览图）。此前“这些基础美术资源不在 main”的说法不正确。美术分支相对 main 真正新增的是 3 套装备的 18 张 PNG、manifest/preview、2.5D 地图/投影/地标代码和相关接入修改。
- 美术分支相对当前 main：ahead 113 / behind 13；相对 feat/hero-world-2.5d-boss-p0：ahead 56 / behind 0。不要整分支直接合并。
- 用户本地此前显示在 integration/art-2.5d，且有 project.godot 修改和 Godot 生成的未跟踪 .godot/、.import、.uid 文件。尚未确认这些状态在最新文档合并后是否变化；不得用 reset/clean/覆盖操作处理。
- 下一步：在最新 main 上继续逐文件整合设计，优先解决地图尺寸/移动边界不一致与旧存档位置迁移；在此之前不改游戏代码。

## 1. 项目定位

Hero World 是原创单机 RPG，目标平台为 Android，目标体验为竖屏移动端、卡通斜视伪 2.5D 世界。核心玩法方向包括英雄小队探索、自动战斗、装备成长、营地建设、地图/区域探索与离线本地存档。

**视觉方向已确定：A——卡通斜视伪 2.5D。** 这属于目标方向，不代表当前主线已经实现。

## 2. Git 仓库与主线规则

- 仓库：oneyi53/game
- 正式主线：main
- 当前 main HEAD：97e23ed3d3fbc5e44d220d069c0daf6cad015ebe（项目状态与变更日志同步提交）。
- 当前本地开发目录：~/GodotProjects/HeroWorld；此前终端显示用户曾切换到 integration/art-2.5d，本地工作区有未提交状态，必须先检查再操作。

### 主线与 2.5D 分支关系

| 分支 | 相对当前 main 的提交关系 | 定位 | 当前判断 |
|---|---:|---|---|
| main | 基准 | 唯一正式主线 | 当前唯一整合基线 |
| feat/hero-world-2.5d-boss-p0 | ahead 57 / behind 13 | 2.5D 投影、场景排序、Boss 与相关场景/角色逻辑 | 前置技术阶段；与 main 已分叉 |
| feat/hero-world-art-integration | ahead 113 / behind 13 | 在 2.5D 分支基础上继续扩展美术资源、地图管理、角色/怪物/场景接入和 UI | 2.5D 分支的严格后继；主要技术参考，但不能整分支合并 |

核对结果：
- feat/hero-world-art-integration 相对 feat/hero-world-2.5d-boss-p0：ahead 56 / behind 0。
- 两条开发线相对 main 的共同基点为 1add5582f092d9cc52752fb54e5bce5137fb4bfd；当前 main 已在其后新增 13 个提交，因此分支已分叉。
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

**第一优先级：完成坐标与存档迁移方案，随后才进入代码整合。**

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
