class_name Tower
extends Area2D

# 角色/塔的数据配置
@export var data: TowerData
# 当前等级（最高 10 级）
@export var current_level: int = 1
# 当前经验值
@export var current_xp: int = 0
# 升到下一级所需经验值
@export var xp_to_next: int = 100

var _cooldown: float = 0.0  # 攻击冷却计时
var _enemies_in_range: Array[Enemy] = []  # 进入攻击范围的敌人
var _skills: Array[SkillData] = []  # 已解锁的技能

@onready var _range_shape: CollisionShape2D = $Range/CollisionShape2D  # 范围碰撞形状
@onready var _fire_point: Node2D = $FirePoint  # 发射弹道的位置


# 初始化：连接范围检测信号并设置攻击范围
func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	_update_range()


# 根据 data.attack_range 更新范围检测圆形半径
func _update_range() -> void:
	if data == null or _range_shape == null:
		return
	var circle := CircleShape2D.new()
	circle.radius = data.attack_range
	_range_shape.shape = circle


# 敌人进入攻击范围时加入列表
func _on_body_entered(body: Node) -> void:
	if body is Enemy:
		_enemies_in_range.append(body)


# 敌人离开攻击范围时从列表移除
func _on_body_exited(body: Node) -> void:
	if body is Enemy:
		_enemies_in_range.erase(body)


# 每帧减少冷却并尝试攻击
func _process(delta: float) -> void:
	if data == null:
		return
	_cooldown -= delta
	if _cooldown <= 0.0:
		_try_attack()


# 选择目标并发起一次攻击
func _try_attack() -> void:
	var target := _select_target()
	if target == null:
		return
	_fire(target)
	_cooldown = 1.0 / data.attack_speed


# 选择距离基地最近的敌人（progress_ratio 最大）
func _select_target() -> Enemy:
	# 过滤掉已经被销毁的敌人
	_enemies_in_range = _enemies_in_range.filter(func(e): return is_instance_valid(e))
	if _enemies_in_range.is_empty():
		return null
	# 选择行进最靠前（最靠近基地）的敌人
	var best: Enemy = _enemies_in_range[0]
	for e in _enemies_in_range:
		if e.progress_ratio > best.progress_ratio:
			best = e
	return best


# 向目标发射一枚弹道，并播放攻击音效
func _fire(target: Enemy) -> void:
	if not is_instance_valid(target):
		return
	var projectile: Projectile = preload("res://scenes/projectiles/projectile.tscn").instantiate()
	projectile.global_position = _fire_point.global_position
	projectile.setup(target, data)
	get_tree().current_scene.add_child(projectile)
	AudioManager.play_attack()


# 获得经验值；满足条件时升级
func gain_xp(amount: int) -> void:
	current_xp += amount
	while current_xp >= xp_to_next and current_level < 10:
		current_xp -= xp_to_next
		_level_up()


# 升级：提升等级、增加下一级所需经验，3/5/8 级解锁技能
func _level_up() -> void:
	current_level += 1
	xp_to_next = int(xp_to_next * 1.2)
	if current_level in [3, 5, 8]:
		_unlock_skill()


# 解锁一个技能（第一版使用固定占位技能）
func _unlock_skill() -> void:
	var skill := SkillData.new()
	skill.name = "Power Boost"
	skill.type = SkillData.Type.PHYSICAL_ATTACK_POWER
	skill.value = 5.0
	skill.unlocked_at_level = current_level
	_skills.append(skill)
	if data != null:
		# 第一版简单处理：直接增加基础攻击力
		data.base_attack_power += skill.value
