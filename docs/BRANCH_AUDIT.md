# 2.5D / 美术分支静态审查记录

> 审查日期：2026-11-04（历史静态审查；最新基线见第 9 节）
> 审查方式：GitHub 远程文件读取、递归 Git tree 与 blob SHA 对照、关键脚本静态阅读。
> 未执行：本机 Godot 导入、运行、Android 导出、设备实测。因此以下属于静态审查结论，不代表运行验证。

## 1. 本次使用的准确基线

- 仓库：oneyi53/game
- 当前正式主线：main，HEAD 97e23ed3d3fbc5e44d220d069c0daf6cad015ebe
- 2.5D 前置分支：feat/hero-world-2.5d-boss-p0
- 后续美术整合分支：feat/hero-world-art-integration

提交关系（GitHub compare）：

| 比较 | 结果 | 含义 |
|---|---:|---|
| 2.5D 分支相对当前 main | ahead 57 / behind 13 | 已分叉，不可快进 |
| 美术分支相对当前 main | ahead 113 / behind 13 | 已分叉，不可整分支直接覆盖 |
| 美术分支相对 2.5D 分支 | ahead 56 / behind 0 | 美术分支是 2.5D 分支的后继，包含其历史 |

因此，后续以 feat/hero-world-art-integration 作为主要技术参考，不要再把两条功能分支分别合并。2.5D 分支是它的前一阶段。

### 文件差异的核对方法

GitHub 的三点比较（base...head）会以 merge-base 为比较起点，文件列表不能直接当作“当前 main 缺少哪些文件”的净差异清单。此次另外读取了 main、2.5D、art 三个分支的递归 Git tree，并按每个文件的 blob SHA 逐项比对。下面的文件归属结论以 tree/blob 对照为准。

## 2. 美术资源：主线已经有大部分，不要重复复制

此前曾误判为主线没有美术资源。这个判断不正确，已在本次审查中纠正。

当前 main 已经包含并且与美术分支 blob SHA 相同的基础资源：

- 5 张原始图集：英雄、怪物、Boss、装备、场景。
- 6 个英雄单体 PNG。
- 10 个普通怪物单体 PNG。
- 2 个 Boss 单体 PNG。
- 6 个散件装备图标。
- 6 个场景地标 PNG。
- 5 张精灵预览图。
- assets/art-v1/README.md、SPRITE_SPEC.md、art-generated-notes.md。

这解释了为什么本地会出现大量由 Godot 生成的 .import 文件：资源源文件本身已经在主线仓库里；但 main 的角色、敌人和地图脚本还没有把它们完整显示出来。

美术分支相对当前 main 真正新增的美术资源主要是：

- 3 套装备共 18 张独立装备 PNG；
- equipment_sets_manifest.md；
- equipment_sets_preview.png。

因此后续不需要再次搬运基础英雄/怪物/Boss/场景 PNG；只需审查并接入新增套装资源。

## 3. 美术分支相对当前 main 的净文件变化

以递归 tree/blob SHA 对照，分类如下。

### 新增

- .github/workflows/godot-4-7-2-check.yml
- scripts/core/world_projection.gd
- scripts/core/world_map_manager.gd
- scripts/core/tree_visual.gd
- scripts/core/landmark_visual.gd
- 3 套装备的 18 张 PNG、manifest 和预览图。

### 修改

- .github/workflows/android.yml
- README.md
- scenes/main.tscn
- scripts/core/main.gd
- scripts/core/map.gd
- scripts/character/hero.gd
- scripts/enemy/enemy.gd
- scripts/enemy/boss.gd
- scripts/interactable/campfire.gd
- scripts/interactable/chest.gd
- scripts/ui/backpack_panel.gd
- scripts/ui/equip_panel.gd
- scripts/ui/hero_panel.gd
- scripts/ui/hud.gd
- scripts/ui/offline_panel.gd
- scripts/ui/recruit_panel.gd
- scripts/ui/virtual_joystick.gd

### 当前 main 有、art 分支快照没有的文档

- docs/PROJECT_STATUS.md
- docs/CHANGELOG.md
- docs/DEVELOPMENT_WORKFLOW.md

这些文档是在两条开发分支分叉后新增到 main 的。整合时必须以当前 main 为基底保留它们；也必须保留当前 README 中的文档导航，而不能用 art 分支的旧 README 覆盖。

### 没有被 art 分支修改的关键文件

tree/blob 对照显示，art 分支没有修改：

- project.godot
- .gitignore
- scripts/core/save_manager.gd
- data/*.json

这意味着地图切换与存档位置语义的变化主要发生在 main.gd，但没有配套的 SaveManager/schema 迁移实现。

## 4. 2.5D 实现结构

### 坐标与绘制

- WorldProjection.world_to_screen()：将逻辑坐标投影为菱形地面坐标。
- screen_depth()：按逻辑坐标 x+y 计算绘制深度。
- 角色、敌人、Boss、营火、宝箱和地标在 _draw() 中应用投影偏移。
- main.gd 每帧更新动态单位的 z-index。
- map.gd 用投影后的多边形绘制菱形地砖；树和地标拆成独立节点，以便和角色进行遮挡排序。
- 摇杆输入通过投影逆变换转换为逻辑移动方向。

这是正确的总体方向：逻辑坐标用于移动、碰撞和战斗；投影只影响渲染，不应把投影结果写回 CharacterBody2D 的逻辑位置。

### 地图管理

world_map_manager.gd 定义四个独立地图：

- town：王朝营地，安全区。
- moss_crown：苔冠空地。
- fallen_leaf：落叶幽谷。
- morning_dew：朝露林地。

每张地图的逻辑边界是 1200×900，怪物通过 map id 分配到地图，地图切换时切换地面并隐藏/暂停其他地图的敌人。地图解锁继续依赖现有 Boss 与任务进度。

## 5. 已发现的高优先级问题

### P1：地图尺寸、投影尺寸和角色移动边界不一致

相关文件：

- scripts/core/world_projection.gd
- scripts/core/world_map_manager.gd
- scripts/core/map.gd
- scripts/core/main.gd
- scripts/character/hero.gd
- scripts/enemy/enemy.gd
- scripts/enemy/boss.gd

当前静态代码中的数值：

| 模块 | 当前尺寸/边界 |
|---|---:|
| WorldProjection | 1200×900 |
| WorldMapManager 每张地图 | 1200×900 |
| MapDrawer 绘制范围 | 1200×900 |
| Main 中遗留常量 | 1600×1200 |
| Hero / Enemy / Boss clamp | x=20..1580，y=20..1180 |

结果：角色或敌人可以走出 1200×900 地面，而地图投影边界和摄像机边界只按 1200×900 计算，可能出现走到地面外、摄像机跟随异常或单位不可见的情况。

另外，world_projection.gd 和 map.gd 的注释仍称逻辑坐标是 1600×1200，但实际投影/地图常量是 1200×900。必须先确定唯一地图坐标契约，再统一移动 clamp、出生点、敌人位置和投影边界。WorldMapManager 已有 clamp_to_map()，但当前 Hero/Enemy/Boss 没有使用它。

### P1：旧存档坐标没有完成地图迁移

相关文件：

- scripts/core/main.gd
- scripts/core/world_map_manager.gd
- scripts/core/save_manager.gd（未被 art 分支修改）

现状：

- 新代码增加了 map_id 保存字段。
- 读取没有 map_id 的旧存档时，默认地图为 moss_crown。
- 旧存档的 player_position 会直接作为新地图的逻辑位置使用，没有按旧地图区域转换为新地图的本地坐标，也没有按 1200×900 边界校验。
- map_from_legacy_position() 目前只是无条件返回 MOSS_CROWN，而且没有被调用。
- SaveManager 的 schema 仍为 1，且没有迁移步骤。

旧主线允许玩家在 1600×1200 的共享大地图中移动；新分支改成每张地图独立的 1200×900 坐标空间。老存档如果记录了 x>1200 或 y>900 的位置，可能被载入到新地图地面以外；旧玩家如果原来处于其他区域，也可能被放到错误地图。

合并前必须设计旧存档迁移：根据旧坐标/任务与 Boss 解锁状态识别原区域，转换为新地图本地坐标，并对边界做安全处理。需要用旧版样本存档做回归，不可直接覆盖用户存档。

### P2：竖屏摄像机下的地图占屏比例需要实机/编辑器确认

- 投影将 1200×900 地图变为约 1050×525 的屏幕包围范围。
- 项目视口为 720×1280。
- scenes/main.tscn 的 Camera2D 没有设置 zoom，代码按默认 zoom 计算。

因此地图菱形在竖屏画面中可能只占中间约 525px 高度，画面上下留白较大。这个问题需在 Godot 4.7.2 中看实际画面，再决定相机 zoom、地图尺寸或构图；不能只靠静态推测定最终数值。

### P2：四张地图的地标没有按地图区分

map.gd 在 _ready() 时一次性创建同一批树和三个地标；set_active_map() 只改变 active_map_id 并重绘地面，没有按地图隐藏/替换树和地标。当前四张地图会复用同一组装饰，城镇也会显示相同的森林树木/地标。需要按 map id 配置各地图的地标和装饰集合。

### P2：新游戏默认进入 Moss Crown，而不是 Town

main.gd 默认 active_map_id 和无 map_id 存档的回退值都是 MOSS_CROWN。如果产品流程要求“主城 → 传送 → 探索”，新档起点应确认是否改为 TOWN；旧档迁移则需单独处理，不能混在同一个默认值里。

### P3：若干未完成的重构痕迹

- _spawn_enemy_at(enemy_id, pos) 没有使用传入的 pos，而是始终从 WorldMapManager 重新取位置；_spawn_enemies() 的 placements 位置参数因此没有实际作用。
- map_positions 在切图时写入，但没有读取或写入存档；目前切回地图总是使用固定 spawn。
- WorldMapManager.is_safe_map()、is_region_unlocked() 等接口需要核实调用情况，避免保留未接入的伪功能。

## 6. 美术接入完成度

### 已有静态接入

美术分支中的代码已经实际引用了不少主线已有资源：

- Hero：6 个英雄静态 PNG。
- Enemy：10 个普通怪物静态 PNG。
- Boss：2 个 Boss 静态 PNG，红色攻击预警圈仍由代码绘制。
- Scene：树、塔、喷泉、营火、宝箱使用单体 PNG。
- UI：英雄/招募头像、背包 6 个散件图标、装备面板 3 套装备图标。

因此，资源包说明中“游戏内接入未做”的描述已经过时；代码已有静态接入，但仍需在 Godot 中验证。

### 尚未完成

- 英雄、普通怪物、Boss 只有静态立绘；行走、攻击、受击、死亡动画未完成。
- 装备面板能展示套装部件图标，但角色战斗立绘没有装备外观叠加。
- 四个区域尚未形成各自独立的完整地标/植被主题。
- assets/art-v1/README.md 与 SPRITE_SPEC.md 中“游戏内接入未做/套装外观未做”等描述，和当前代码、equipment_sets 目录内容不一致。
- art-generated-notes.md 仍保留“单体切图未做”和 Godot 4.3 等旧说明，需整理为历史说明或更新状态。

## 7. CI 与导出工作流

- main 当前 Android workflow 是手动触发。
- art 分支将 Android workflow 改为：向指定美术分支 push 时执行测试 APK 构建；正式签名 APK 仍通过手动输入和仓库 Secrets 控制。
- art 分支新增 Godot 4.7.2 headless import/startup 检查 workflow。
- 这些 workflow 的验证不是完整游戏回归，也不等于 Android 真机验收。后续应单独审查 workflow 差异和运行记录，不随游戏脚本一并盲目复制。

## 8. 整合建议顺序

不要把 feat/hero-world-art-integration 整条分支 merge 到 main。建议从最新 main 建立整合分支，按模块迁移：

1. 先定坐标契约和旧存档迁移：统一 1200×900 或重新确定尺寸；修复 Hero/Enemy/Boss 边界；写旧存档坐标转换与测试。
2. 接入 2.5D 地图层：WorldProjection、MapDrawer、TreeVisual、LandmarkVisual、WorldMapManager；确保逻辑坐标不被投影污染。
3. 接入单位渲染：Hero、Enemy、Boss 静态贴图与深度排序；验证攻击范围、碰撞、Boss 预警圈仍使用逻辑坐标。
4. 接入地图切换：验证 Town/Moss/Fallen/Morning 的出生点、敌人归属、暂停/恢复、重生队列和地图解锁。
5. 接入 UI 美术：背包散件、装备套装、英雄/招募头像和传送按钮。
6. 单独审查 CI/Android workflow，不要把工作流配置变化当作游戏代码的一部分自动合入。
7. 在 Godot 4.7.2 完成导入、主场景运行、移动/战斗/传送/存档回归，再做 Android 导出和真机测试。

当前最先要解决的是坐标契约 + 旧存档迁移，不是先把所有 PNG 复制进项目。基础 PNG 已经在 main。


## 9. 最新主线与分支快照补充（2026-11-04）

- 当前 main 基线为 `598216e6f67611b0f3db452718b4aa7cdf57ebb2`；PR #29 散件装备已合并，Godot 4.7.2 headless 检查有成功记录。
- 本文前文记录的旧 main SHA 与 ahead/behind 数字属于当时审查快照，不可作为当前分支提交数；完整远程分支和 PR 状态见 `docs/BRANCH_CATALOG.md`。
- 2.5D / 美术历史分支仍不得整体 merge。先解决 1200×900 与 1600×1200 边界不一致、旧存档坐标迁移，再按模块迁移。
- 根目录原创 PNG 归档到 `assets/art-v1/effects/effect_atlas.png` 与 `assets/art-v1/branding/icon.png`；运行时引用同步更新。Godot 新路径导入尚待本次 PR 检查。
