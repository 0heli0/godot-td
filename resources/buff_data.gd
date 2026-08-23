class_name BuffData
extends Resource

# buff 类型：防御、法抗、移速、血量
enum Type {
	DEFENSE,
	MAGIC_RESIST,
	MOVE_SPEED,
	HEALTH,
}

# buff 类型
@export var type: Type = Type.DEFENSE
# buff 数值
@export var value: float = 0.0
# 是否为百分比加成（true：乘法；false：加法）
@export var is_percentage: bool = false


# 将 buff 应用到基础数值上，返回最终数值
func apply_to(base_value: float) -> float:
	if is_percentage:
		return base_value * (1.0 + value)
	return base_value + value
