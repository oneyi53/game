# 开发变更日志

本文件记录可追溯的项目变更。Git commit 是代码事实来源；本日志解释每次变更的目的、范围和验证状态。

## 2026-11-04 — 项目治理文档合并至 main

- PR：[#2](https://github.com/oneyi53/game/pull/2)
- 来源分支：`docs/project-governance`
- 目标分支：`main`
- 合并方式：Squash merge
- 合并提交：`9e18e3f7065b0d19ab652a8c17840a08921b7d03`
- 变更文件：`README.md`、`docs/PROJECT_STATUS.md`、`docs/CHANGELOG.md`、`docs/DEVELOPMENT_WORKFLOW.md`
- 变更说明：建立项目长期状态档案、分支关系说明、逐次变更日志和开发/会话交接规范。
- 影响范围：仅文档；没有修改游戏代码、美术资源、Godot 项目配置或存档结构。
- 验证：审查 PR 四个文件；GitHub 显示 PR 可合并且状态 clean，已成功合并。Godot 导入/运行/设备验证未执行（文档变更不涉及运行时代码）。
- 下一步：只读审查 `feat/hero-world-art-integration` 与最新 `main` 的关键文件，建立逐文件整合清单；在审查完成前不做整分支合并。

## 2026-11-04 — 建立项目治理文档（初始提交）

- 分支：`docs/project-governance`
- 基础：从当时 GitHub `main` HEAD `afddb7028a327b9c22d1d13450b967e944f63548` 创建。
- 变更：
  - 更新 `README.md`，增加项目状态、主线规则、开发入口和文档导航。
  - 新增 `docs/PROJECT_STATUS.md`，记录远程分支关系、功能范围、风险和建议路线。
  - 新增 `docs/CHANGELOG.md`，建立变更记录规范。
  - 新增 `docs/DEVELOPMENT_WORKFLOW.md`，明确分支、提交、验证和交接流程。
- 目的：让后续开发者/会话能够从仓库文档恢复项目上下文，避免重复摸索或误合并旧分支。
- 验证：通过 GitHub API 核对分支名、提交关系及部分文件差异；当时尚未在本地运行 Godot。该文档 PR 后续已在上方记录并合并到 main。
- README 提交：`06cdd999508dbb4072aeca0ecf230dab6d13c7f1`。
- 项目档案提交：`af9d13c054a56ced72828df178fbb6e9e6c85854`。
- 本日志提交：`108c2d9958730a7fe8475c6796c3e68c23bce84a`。
- 工作流规范提交：`10f976fd1484f91c4114adcf75a8b4b99483ac1e`。

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
