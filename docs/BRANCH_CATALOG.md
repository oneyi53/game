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
