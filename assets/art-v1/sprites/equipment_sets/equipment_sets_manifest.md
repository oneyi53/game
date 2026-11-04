# Hero World 装备套装清单（已确认，已提交到 feat/hero-world-art-integration）

验证环境：Godot 4.7.2（仅美术资源，不改代码、数据、数值、存档、逻辑）。
规格：全部 PNG、256x256、透明背景、主体居中（128,128）、最长边 210px（占画布 82%）、无文字、无水印、无品质边框、无属性信息。
目标目录（确认后提交）：assets/art-v1/sprites/equipment_sets/
预览：equipment_sets_preview.png（本目录，棋盘格底仅用于检查透明区）

## Dawn Vanguard（晨辉先锋套装）

| 文件名 | 中文名称 | 部位 |
|---|---|---|
| dawn_vanguard_weapon.png | 晨辉长剑 | 武器 |
| dawn_vanguard_helmet.png | 曦光战盔 | 头盔 |
| dawn_vanguard_chest.png | 金耀胸甲 | 胸甲 |
| dawn_vanguard_gloves.png | 烈阳护手 | 护手 |
| dawn_vanguard_boots.png | 逐光战靴 | 战靴 |
| dawn_vanguard_accessory.png | 朝阳徽章 | 饰品 |

## Forest Bulwark（森林壁垒套装）

| 文件名 | 中文名称 | 部位 |
|---|---|---|
| forest_bulwark_weapon.png | 古藤重锤 | 武器 |
| forest_bulwark_helmet.png | 林卫头盔 | 头盔 |
| forest_bulwark_chest.png | 苍木胸甲 | 胸甲 |
| forest_bulwark_gloves.png | 荆叶护手 | 护手 |
| forest_bulwark_boots.png | 岩根战靴 | 战靴 |
| forest_bulwark_accessory.png | 森林守护徽记 | 饰品 |

## Starfeather Hunt（星羽猎手套装）

| 文件名 | 中文名称 | 部位 |
|---|---|---|
| starfeather_hunt_weapon.png | 星羽长弓 | 武器 |
| starfeather_hunt_helmet.png | 轻羽猎盔 | 头盔 |
| starfeather_hunt_chest.png | 流星轻甲 | 胸甲 |
| starfeather_hunt_gloves.png | 疾风护手 | 护手 |
| starfeather_hunt_boots.png | 飞羽短靴 | 战靴 |
| starfeather_hunt_accessory.png | 星芒吊坠 | 饰品 |

## 自检结果

- 恰好 18 张独立 PNG，文件名与任务清单完全一致。
- 全部 256x256、RGBA、四角 alpha 均为 0，无背景残留。
- 未覆盖现有 6 件散件图标，未动任何代码、数据、分支。
- 64x64 缩小图已检查：18 件均可辨认，星羽长弓的细弓弦在抠图后大部分丢失，但弓身、羽翼、星饰仍在，不影响辨认；晨辉长剑在 64px 下较细，仍可认出是剑。
- 已知说明：本批为美术资源包，游戏内接入、套装效果、数值均不在本次范围内。
