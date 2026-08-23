class_name TowerData
extends Resource

# 攻击类型：物理 / 法术
enum AttackType { PHYSICAL, MAGIC }

# 角色/塔名称
@export var tower_name: String = ""
# 攻击类型
@export var attack_type: AttackType = AttackType.PHYSICAL
# 基础攻击力
@export var base_attack_power: float = 10.0
# 攻击速度（每秒攻击次数）
@export var attack_speed: float = 1.0
# 攻击范围（像素）
@export var attack_range: float = 200.0
# 弹道速度（像素/秒）
@export var projectile_speed: float = 400.0
# 建造消耗：金钱、木材、矿石
@export var cost: Dictionary = {"money": 50, "wood": 0, "ore": 0}
