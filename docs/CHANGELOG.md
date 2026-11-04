# 开发变更日志

本文件记录可追溯的项目变更。Git commit 是代码事实来源；本日志解释每次变更的目的、范围和验证状态。

## 2026-11-04 — 本地代码与架构静态审查报告

- 分支：`docs/local-code-audit-2026-11-04`
- 基线：本地 `HeroWorld-clean`，main HEAD `e194898`。
- 新增文件：`docs/LOCAL_CODE_AUDIT_2026-11-04.md`。
- 更新文件：`README.md`、`docs/PROJECT_STATUS.md`、`docs/CHANGELOG.md`。
- 变更说明：记录本地批量只读审查的项目结构、主要系统实现盘点、美术资源引用现状、存档观察、潜在风险及下一轮交叉审查清单。
- 影响范围：仅文档；没有修改游戏代码、美术资源、Godot 配置或存档结构。
- 审查方式：Antigravity 批量读取脚本和数据文件，分析汇总输出；报告中的汇总输出行号不等同于源文件行号。
- 验证结果：文档整理；未执行 Godot headless、功能回归、Android/iOS 导出或真机测试。报告中的疑点仍需逐项核实。
- 下一步：复核怪物刷新容量、招募碎片扣除、英雄 HP 恢复和 SaveManager 调用链，再决定是否创建代码修复分支。

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
