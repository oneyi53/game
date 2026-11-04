# Hero World 美术资源总目录

本目录汇总当前主线已收录的原创游戏美术资源。此提交只补齐装备套装 PNG 与资源目录，不覆盖游戏逻辑、场景、存档或数值。

## 当前资源分组

- `sprites/heroes/`：6 名英雄角色立绘/精灵资源。
- `sprites/monsters/`：10 类普通怪物资源（与 README 的切图清单一致）。
- `sprites/bosses/`：2 个 Boss 资源。
- `sprites/scene/`：6 张独立场景素材（营火、宝箱、喷泉、塔楼、绿树、黄树）。
- `sprites/equipment/`：6 件基础装备图标。
- `sprites/equipment_sets/`：3 套装备外观，每套 6 个部位，共 18 张独立装备 PNG，另有 1 张套装预览图。
- `sprites/previews/`：英雄、怪物、Boss、装备和场景预览图。
- `../heroes-v1.png`、`../monsters-v1.png`、`../bosses-v1.png`、`../equipment-v1.png`、`../scene-v1.png`：原始分类图集。
- 仓库根目录 `effect_atlas.png`：已保留的特效图集源图；目前不代表特效动画已完成接入。

## 装备套装

| 套装 | 武器 | 头盔 | 胸甲 | 护手 | 战靴 | 饰品 |
|---|---|---|---|---|---|---|
| 晨辉先锋 Dawn Vanguard | dawn_vanguard_weapon | dawn_vanguard_helmet | dawn_vanguard_chest | dawn_vanguard_gloves | dawn_vanguard_boots | dawn_vanguard_accessory |
| 森林壁垒 Forest Bulwark | forest_bulwark_weapon | forest_bulwark_helmet | forest_bulwark_chest | forest_bulwark_gloves | forest_bulwark_boots | forest_bulwark_accessory |
| 星羽猎手 Starfeather Hunt | starfeather_hunt_weapon | starfeather_hunt_helmet | starfeather_hunt_chest | starfeather_hunt_gloves | starfeather_hunt_boots | starfeather_hunt_accessory |

套装文件规格见同目录 `equipment_sets_manifest.md`。该批资源目前作为可用美术素材归档；不宣称已完成角色装备显示或战斗数值接入。

## 使用约定

优先复用现有 PNG 与预览，不重复生成同类素材。运行时接入时应通过统一资源路径/资源清单引用，并在 Godot 4.7.2 中执行导入和启动验证。
