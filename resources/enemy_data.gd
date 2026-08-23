class_name EnemyData
extends Resource

# 敌人名称
@export var enemy_name: String = ""
# 基础生命值
@export var base_health: float = 50.0
# 基础攻击力
@export var base_attack: float = 5.0
# 基础移动速度（像素/秒）
@export var base_speed: float = 100.0
# 基础物理防御
@export var base_defense: float = 0.0
# 基础法术抗性
@export var base_magic_resist: float = 0.0
# 被击败后奖励的金钱
@export var reward_money: int = 10
# 被击败后奖励的木材
@export var reward_wood: int = 0
# 被击败后奖励的矿石
@export var reward_ore: int = 0
# 被击败后奖励的经验值
@export var reward_xp: int = 10
# 敌人携带的 buff 列表
@export var buffs: Array[BuffData] = []
