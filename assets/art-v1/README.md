# Hero World 原创美术资源库

本目录是项目原创美术资源的统一归档入口。运行时代码应引用本目录下路径，不要把美术 PNG 放在仓库根目录。

## 目录结构

- `branding/icon.png`：Godot 应用图标，由 `project.godot` 引用。
- `effects/effect_atlas.png`：用户确认的原创技能特效图集，由 `scripts/core/main.gd` 预加载。
- `heroes-v1.png`、`monsters-v1.png`、`bosses-v1.png`、`scene-v1.png`、`equipment-v1.png`：五张原始分类图集。
- `sprites/heroes/`：6 名英雄单体 PNG。
- `sprites/monsters/`：10 类普通怪物单体 PNG。
- `sprites/bosses/`：2 个 Boss 单体 PNG。
- `sprites/scene/`：6 个独立场景素材。
- `sprites/equipment/`：6 件基础散件装备图标。
- `sprites/equipment_sets/`：3 套装备、共 18 张部件 PNG，含 manifest 与预览图。
- `sprites/previews/`：预览图，仅供核对，不作游戏背景。

## 已接入与未完成

- 原创技能特效图集已接入技能施放/命中表现；具体裁切区域与时长由代码配置。
- 英雄、怪物、Boss、场景与装备静态 PNG 已有单体资源；部分显示接入存在于历史功能分支，是否进入 main 以主线代码为准。
- 静态立绘不等于动画完成：行走、攻击、受击、死亡动画仍需单独制作和验收。
- 套装部件 PNG 已归档；不代表角色战斗立绘已完成装备外观叠加。
- 四个区域仍需独立地标/植被主题和实机画面验收。

## 使用约定

1. 优先复用已有原创 PNG，不重复生成同类资源。
2. 新增素材按用途放入 `branding/`、`effects/` 或 `sprites/<category>/`。
3. 移动素材必须同步更新所有 `res://` 引用和文档。
4. 不把整张 `scene-v1.png` 当地图背景；只使用切出的单体地标。
5. 图集颜色框、背景和 Boss 提示圈不是品质或战斗逻辑。
6. 目标编辑器为 Godot 4.7.2；导入、启动、运行和设备验收分开记录。

详细资源清单见 [ART_ASSET_CATALOG.md](ART_ASSET_CATALOG.md)，切图规格见 [SPRITE_SPEC.md](SPRITE_SPEC.md)。
