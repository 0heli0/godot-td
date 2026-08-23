class_name Projectile
extends Area2D

var _target: Enemy  # 追踪的目标敌人
var _speed: float = 400.0  # 弹道速度
var _damage: float = 10.0  # 造成伤害
var _is_magic: bool = false  # 是否为法术伤害


# 初始化：绑定击中事件
func _ready() -> void:
	body_entered.connect(_on_body_entered)


# 设置弹道的目标与伤害数据
func setup(target: Enemy, tower_data: TowerData) -> void:
	_target = target
	_speed = tower_data.projectile_speed
	_damage = tower_data.base_attack_power
	_is_magic = tower_data.attack_type == TowerData.AttackType.MAGIC


# 每帧朝目标移动，到达目标附近时触发命中
func _physics_process(delta: float) -> void:
	if not is_instance_valid(_target):
		queue_free()
		return
	var direction := global_position.direction_to(_target.global_position)
	global_position += direction * _speed * delta
	# 距离足够近即判定命中
	if global_position.distance_to(_target.global_position) < 8.0:
		_hit()


# 与目标敌人发生碰撞时触发命中
func _on_body_entered(body: Node) -> void:
	if body == _target:
		_hit()


# 命中目标造成伤害并销毁弹道
func _hit() -> void:
	if is_instance_valid(_target):
		_target.take_damage(_damage, _is_magic)
	queue_free()
