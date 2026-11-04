# 远程分支总目录

> 核对时间：2026-11-04。仓库：oneyi53/game。快照共 42 条远程分支。
> 唯一正式主线：main，基线 598216e6f67611b0f3db452718b4aa7cdf57ebb2。
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
| main | 唯一正式主线 | HEAD 598216e6f67611b0f3db452718b4aa7cdf57ebb2 |
| docs/verify-loose-equipment-merge-2026-11-04 | PR #30 开放 | 合并/CI 记录与本次项目文档整理 |
| ci/godot-cloud-validation-2026-11-04 | PR #9 开放 | Godot 4.7.2 云端验证工作流 |
| docs/local-code-audit-2026-11-04 | PR #6 开放 | 本地代码审查文档 |
| feat/equipment-art-ui-2026-11-04 | PR #18 开放 | 装备美术 UI 接入候选 |

## 已合并 PR 来源
| PR | 分支 | 主题 |
|---:|---|---|
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
