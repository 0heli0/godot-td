class_name Enemy
extends CharacterBody2D

# 敌人死亡信号，参数为敌人自身和是否被玩家击杀
signal died(enemy: Enemy, by_player: bool)

# 敌人数据资源
@export var data: EnemyData

# 当前战斗属性
var current_health: float
var current_speed: float
var current_attack: float
var current_defense: float
var current_magic_resist: float

# 内部路径相关
var _route: PackedVector2Array  # 当前行进的路线
var _waypoint_index: int = 0  # 当前目标路径点索引

# 敌人沿路线的进度比例（0.0 起点 ~ 1.0 终点），供塔选择最靠前的目标
var progress_ratio: float:
	get:
		if _route.size() < 2:
			return 0.0
		return float(_waypoint_index) / float(_route.size() - 1)


# 初始化时根据数据计算属性
func _ready() -> void:
	_reset_stats()


# 根据 EnemyData、难度和波次计算当前属性
func _reset_stats() -> void:
	if data == null:
		return
	current_health = _apply_buffs(data.base_health, BuffData.Type.HEALTH)
	current_speed = _apply_buffs(data.base_speed, BuffData.Type.MOVE_SPEED)
	# 攻击力随波次和难度增长
	current_attack = data.base_attack * (1.0 + 0.1 * (GameManager.difficulty - 1) + 0.05 * GameManager.wave)
	current_defense = _apply_buffs(data.base_defense, BuffData.Type.DEFENSE)
	current_magic_resist = _apply_buffs(data.base_magic_resist, BuffData.Type.MAGIC_RESIST)


# 应用指定类型的 buff 到基础数值
func _apply_buffs(base: float, type: BuffData.Type) -> float:
	var result := base
	if data == null:
		return result
	for buff in data.buffs:
		if buff.type == type:
			result = buff.apply_to(result)
	return result


# 设置敌人路线与数据，并定位到起点
func setup(spawn_route: PackedVector2Array, enemy_data: EnemyData) -> void:
	data = enemy_data
	_reset_stats()
	_route = spawn_route
	_waypoint_index = 0
	if _route.size() > 0:
		global_position = _route[0]


# 每帧物理更新：沿路线向目标点移动
func _physics_process(delta: float) -> void:
	if _route.is_empty() or _waypoint_index >= _route.size() - 1:
		return
	var target := _route[_waypoint_index + 1]
	var direction := global_position.direction_to(target)
	velocity = direction * current_speed
	move_and_slide()
	# 到达当前目标点后切换到下一路径点
	if global_position.distance_to(target) < 8.0:
		_waypoint_index += 1
		# 到达最后路径点即抵达基地
		if _waypoint_index >= _route.size() - 1:
			_reached_base()


# 抵达基地：对基地造成伤害并销毁自身
func _reached_base() -> void:
	var bases := get_tree().get_nodes_in_group("base_crystal")
	if not bases.is_empty():
		bases[0].take_damage(current_attack)
	queue_free()


# 受到伤害；is_magic 为 true 时按法抗减伤，否则按物防减伤
func take_damage(amount: float, is_magic: bool = false) -> void:
	var actual := amount
	if is_magic:
		actual = maxf(0.0, amount - current_magic_resist)
	else:
		actual = maxf(0.0, amount - current_defense)
	current_health -= actual
	if current_health <= 0.0:
		die(true)


# 敌人死亡：被玩家击杀时发放奖励、播放音效并生成烟雾特效，发出信号后销毁
func die(by_player: bool) -> void:
	if by_player and data != null:
		GameManager.earn({
			"money": data.reward_money,
			"wood": data.reward_wood,
			"ore": data.reward_ore,
		})
	AudioManager.play_explosion()
	_spawn_smoke()
	died.emit(self, by_player)
	queue_free()


# 在敌人位置生成烟雾爆炸特效
func _spawn_smoke() -> void:
	var smoke := preload("res://scenes/effects/smoke_explosion.tscn").instantiate()
	smoke.global_position = global_position
	get_tree().current_scene.add_child(smoke)
