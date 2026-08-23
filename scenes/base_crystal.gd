extends Area2D

# 生命值变化信号，参数为当前值和最大值
signal health_changed(current: int, maximum: int)
# 基地被摧毁信号
signal destroyed()

# 基地最大生命值
@export var max_health: int = 100

# 当前生命值，设置时自动限制在 [0, max_health] 并发出信号
var health: int:
	set(value):
		health = clampi(value, 0, max_health)
		health_changed.emit(health, max_health)
		# 生命值为 0 时触发失败
		if health == 0:
			destroyed.emit()
			GameManager.lose()


# 初始化生命值
func _ready() -> void:
	health = max_health


# 受到伤害，扣除对应生命值
func take_damage(amount: float) -> void:
	health -= int(amount)
