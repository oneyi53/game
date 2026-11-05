# 开源项目代码学习与复用评估（2026-11-05）

> 本文是项目《百炼英雄》对标开发的代码复用决策记录。审查对象固定到下列仓库当前检查的 commit；后续上游变化需重新审查许可证与代码。
> 目标项目：Godot 4.7.2、竖屏单机 RPG；核心体验是主城整备、连续地图探索、队伍跟随、自动战斗与手动走位、资源/宝箱/事件、英雄成长和 Boss 区域解锁。

## 1. 总结结论

| 上游项目 | 技术栈 | 许可证检查 | 可取部分 | 本项目处理 |
|---|---|---|---|---|
| [survivors-roguelike-kit](https://github.com/Roo-Roo-Roo/survivors-roguelike-kit) | Unity 6 / C# | MIT（仓库声明；需保留版权与许可声明） | 敌人基类职责拆分、对象池、分段刷怪、掉落接口、事件通道、数据驱动配置、状态机 | 可合法复用其 MIT 代码或移植其算法，但 Unity API/ScriptableObject/MonoBehaviour 不能直接放进 Godot。优先移植对象池和刷怪配置思路；本轮未将 C# 源文件原样拷入项目。 |
| [The_Last_Survivor](https://github.com/LeoLeman555/The_Last_Survivor) | Python / Pygame | MIT（仓库声明；需保留版权与许可声明） | 敌人动画帧管理、目标追踪、武器瞄准、拾取物吸附、地图物件更新/寿命、资源数据拆分 | 可参考并移植纯算法；Pygame Surface/Sprite/Rect 与项目 Godot 场景/节点不兼容。本轮未原样复制 Python 文件。 |
| [Capybara-Survivor-GodotGame](https://github.com/SebastianGranadosJ/Capybara-Survivor-GodotGame) | Godot / GDScript | GitHub 仓库 API 未声明许可证，仓库根目录未找到 LICENSE 文件 | Godot CharacterBody2D 移动、敌人追击/击退、武器自动选敌、经验掉落、刷怪位置碰撞查询、动画节点组织 | 技术上最接近，但**没有可确认的开源许可证**。只做功能/架构观察，不复制、改写或移植其代码和资源；如需代码级复用，先取得作者明确书面授权并补齐许可文件。 |

**重要：本轮没有任何上游代码被直接复制进本项目。** 原因是前两个仓库虽为 MIT，但实现框架分别是 Unity 与 Pygame，无法直接编译进 Godot；第三个虽为 Godot，却没有可确认许可证。为避免误用，先记录可迁移算法与边界，再按本项目架构实现。后续如实际移植 MIT 代码，会在文件头和 `THIRD_PARTY_NOTICES.md` 中保留来源、作者、commit 与 MIT 声明。

## 2. 上游版本与许可证证据

- Roo-Roo-Roo/survivors-roguelike-kit：检查 commit `3f905381d73a34b516030528b8ef6743868b9e52`；仓库元数据声明 MIT，根目录 `LICENSE` 为 MIT License，版权主体 Roo-Roo-Roo（2026）。
- LeoLeman555/The_Last_Survivor：检查 commit `dfc29c8b7f9ee2460ae76ec4b40f2c5832cacdcf`；仓库元数据声明 MIT，根目录 `LICENSE` 为 MIT License，版权主体 Léo Leman（2024）。
- SebastianGranadosJ/Capybara-Survivor-GodotGame：检查 commit `66450c74d555546314349927cb7bc6daa69dd035`；仓库元数据 `license=null`，未发现根目录 LICENSE。默认公开可浏览不等于允许复制、修改或再分发。

## 3. 逐项目技术拆解

### 3.1 Survivors Roguelike Kit（Unity / MIT）

已检查的重点文件：
- `Player/Movement/PlayerMovement.cs`：把输入采集与物理移动分开，在固定物理帧更新速度，并单独维护移动朝向。其直接速度赋值较简单；我们此前在 `scripts/character/hero.gd` 已采用 Godot 原生 `CharacterBody2D` 方式加入加速/制动和朝向反馈，不应再照搬 Unity Rigidbody2D。
- `Game/Enemy/BaseEnemy.cs`：敌人基类集中处理属性初始化、目标缓存、移动生命周期、死亡、掉落和复用回收；具体移动交给子类。这种职责边界值得采用，未来应拆成敌人数据/状态、感知与移动、战斗/死亡掉落，不把所有行为塞进一个脚本。
- `RSOFramework/Pool/PoolRuntimeSO.cs`：按 key 管理预热队列、活动对象集合、回收和批量回收。Godot 可移植其池生命周期，但需处理 `PackedScene`、`Node.reparent`、`_enter_tree/_ready` 和重置状态，不可直接移植 Unity API。
- `System/Stage/StageManager.cs`：按时间段和 SpawnSet 生成敌人，支持随机/环形/密集模式，使用累计预算控制每秒生成数量，并对段落排序。对我们的野外 RPG，不能直接照搬“生存时间越久怪越多”；更适合转成区域 encounter 配置：地图区域、触发半径、怪物组、精英概率、冷却、重生规则。
- 项目 README 还列出事件通道、技能/状态效果、经验与掉落、对象池、存档和数据驱动配置。我们已有 JSON 数据加载与 manager 结构，优先复用思想而不是引入 Unity 式 SO 架构。

**采用优先级：高（对象池/遭遇配置/敌人职责拆分）；低（幸存者式连续刷怪、局内随机技能升级 UI）。**

### 3.2 The Last Survivor（Pygame / MIT）

已检查的重点文件：
- `src/game/enemies/enemy.py`：敌人从数据表读取生命、速度、尺寸与动画规格，动画帧与实体逻辑分离；可借鉴数据驱动敌人配置和帧动画状态机。
- `src/game/controllers/shooter.py` 与 `src/game/weapons/weapon.py`：武器行为独立于玩家控制器，包含瞄准/朝向和射击节奏。我们的自动战斗应采用“目标选择→攻击冷却→攻击执行→命中结算”分层，不应把攻击硬编码到英雄移动脚本。
- `src/game/maps/ground_objects.py`：掉落物具有寿命、拾取范围、靠近玩家时吸附、碰撞拾取；适合改造成经验/金币/木材掉落物的统一行为。
- `src/game/controllers/update.py`、`manager.py` 等控制器按更新/绘制/管理拆分；Godot 已有场景树生命周期，不应机械照搬 Pygame 主循环。
- Pygame 的 `Sprite`、`Surface`、`Rect` 和手工 draw/update 不可直接用于 Godot。坐标、delta、碰撞查询应由 Godot 节点与物理服务器承担。

**采用优先级：高（动画数据驱动、掉落吸附、武器模块化）；中（敌人数据表与更新职责拆分）。**

### 3.3 Capybara Survivor（Godot / 无许可证）

已检查的重点文件：
- `entitys/player/player.gd`：CharacterBody2D 输入移动、待机/行走动画切换、自动武器挂载、经验与升级选择。
- `entitys/enemys/slime/mob.gd`：敌人追踪玩家、受击硬直/击退、死亡生成经验与特效。
- `entitys/weapons/arrowWeapon/arrowWeapon.gd`：检测攻击范围内敌人并转向目标，按冷却生成投射物。
- `utils/object_randomizer/object_randomizer.gd`：将候选升级项复制、洗牌后抽取不重复选项。
- `survivors_game.gd`：刷怪点碰撞查询、波次刷怪、Boss 计时和基于分数线性回归的动态难度。
- 观察到的实现问题：玩家通过绝对节点路径查找依赖，部分变量/函数命名不统一，刷怪/难度数值大量硬编码，敌人死亡直接 queue_free，缺少对象池；其“生存时长驱动难度”也不适合开放地图 RPG 的探索节奏。

**采用优先级：只借鉴功能设计，不做代码级复用。** 特别是其击退、自动选敌、经验掉落和碰撞安全刷怪值得我们独立实现，但不得从该仓库复制 GDScript、场景或素材，除非取得授权。

## 4. 对本项目的落地决策

| 模块 | 目标体验 | 参考来源 | 本项目落地方式 | 当前状态 |
|---|---|---|---|---|
| 英雄移动/朝向 | 走停自然、朝向明确、队伍跟随 | Survivors Kit、Capybara（仅观察） | Godot CharacterBody2D；加速度/制动、队员追赶；接入真实 spritesheet 状态机 | 已有首轮平滑移动提交；真实帧动画待原创素材 |
| 敌人 AI | 感知、追击、攻击、受击、死亡 | 三项目的设计观察；MIT 源码可迁移模式 | 按状态/职责拆分，加入攻击距离、碰撞阻挡、受击反馈 | 待实现 |
| 自动战斗 | 目标选择、攻击间隔、伤害结算、技能反馈 | The Last Survivor（MIT）、Capybara（仅观察） | 独立 Combat/Targeting 层；按仇恨/距离/威胁排序，避免依赖 Area 返回顺序 | 待实现 |
| 掉落与拾取 | 金币/木材/经验掉落、吸附、拾取反馈 | The Last Survivor（MIT）、Survivors Kit（MIT） | 统一掉落实体接口；近距离吸附、拾取半径、寿命和对象池 | 待实现 |
| 区域遭遇 | 地图探索中的怪群/精英/Boss | Survivors Kit（MIT） | 将时间刷怪改为区域触发 encounter 数据；探索与任务状态驱动，不做无限刷屏 | 待实现 |
| 对象池 | 降低重复实例化开销 | Survivors Kit（MIT） | 先在投射物、掉落、短效特效等高频对象接入；普通地图单位数量较少，不为“用了池”而过度设计 | 待评估 |
| 难度曲线 | 随区域/进度逐步提高挑战 | Capybara（仅观察） | 使用区域等级、玩家战力、任务进度、Boss 阶段的受控配置；不复制分数回归公式 | 待设计 |
| 动画 | 待机/行走/攻击/受击与方向反馈 | The Last Survivor（MIT）、Capybara（仅观察） | 原创 spritesheet + AnimatedSprite2D/AnimationPlayer；静态 PNG 不冒充帧动画 | 待接入素材 |

## 5. 不采用的做法

1. 不把我们的探索 RPG 改造成无尽生存刷怪游戏；“百炼英雄”对标优先级仍是地图探索、队伍、区域推进和成长。
2. 不引入 Unity、Pygame 运行时或跨引擎依赖。
3. 不复制 Capybara 仓库任何代码、场景、贴图、音频或资源；无许可证时不能因其是 Godot 项目就默认可复用。
4. 不直接照搬竞品/样例的数值、角色、美术或 UI。
5. 不在没有 Godot 4.7.2 运行测试前宣称移植完成。

## 6. 后续工程执行顺序

1. 先完成地图坐标/投影/相机/碰撞一致性与一张可玩的野外地图。
2. 以原创素材接入英雄和敌人的真实动画状态机。
3. 抽离敌人战斗状态、目标选择、攻击冷却和伤害结算。
4. 落地区域遭遇配置（触发式怪群/精英/Boss），避免时间无限刷怪。
5. 再引入统一掉落与吸附拾取、对象池和性能测量。
6. 为移植自 MIT 项目的代码建立 `THIRD_PARTY_NOTICES.md`，保留版权声明、许可证全文、上游 URL、commit SHA、修改说明。
7. 每个模块配 Godot headless 检查/场景运行测试；通过后再走 Android APK 构建。

## 7. 来源链接

- https://github.com/Roo-Roo-Roo/survivors-roguelike-kit
- https://github.com/Roo-Roo-Roo/survivors-roguelike-kit/blob/main/LICENSE
- https://github.com/LeoLeman555/The_Last_Survivor
- https://github.com/LeoLeman555/The_Last_Survivor/blob/main/LICENSE
- https://github.com/SebastianGranadosJ/Capybara-Survivor-GodotGame
- https://github.com/SebastianGranadosJ/Capybara-Survivor-GodotGame/blob/main/entitys/player/player.gd
- https://github.com/SebastianGranadosJ/Capybara-Survivor-GodotGame/blob/main/entitys/enemys/slime/mob.gd
