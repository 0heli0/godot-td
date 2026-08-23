extends Node

# 敌人预设路线集合，每条路线是全局路径点数组。
# 出兵点：左上、中上、右上；终点为正下方的基地。
var routes: Dictionary = {}

# 地图尺寸假设，单位像素
const MAP_WIDTH: float = 1280.0
const MAP_HEIGHT: float = 720.0
# 边距，用于确定左右出兵点位置
const MARGIN: float = 80.0
# 基地纵坐标
const BASE_Y: float = 640.0


# 场景加载时构建三条预设路线
func _ready() -> void:
	_build_routes()


# 构建左上、中上、右上到基地的三条固定路线
func _build_routes() -> void:
	var top_left := Vector2(MARGIN, MARGIN)
	var top_center := Vector2(MAP_WIDTH / 2.0, MARGIN)
	var top_right := Vector2(MAP_WIDTH - MARGIN, MARGIN)
	var base := Vector2(MAP_WIDTH / 2.0, BASE_Y)

	# 左上路线：先向右下，再汇入中路
	routes["top_left"] = PackedVector2Array([
		top_left,
		Vector2(MAP_WIDTH * 0.25, MAP_HEIGHT * 0.25),
		Vector2(MAP_WIDTH * 0.45, MAP_HEIGHT * 0.45),
		Vector2(MAP_WIDTH * 0.45, MAP_HEIGHT * 0.75),
		base,
	])

	# 中上路线：直线向下
	routes["top_center"] = PackedVector2Array([
		top_center,
		Vector2(MAP_WIDTH * 0.5, MAP_HEIGHT * 0.25),
		Vector2(MAP_WIDTH * 0.5, MAP_HEIGHT * 0.45),
		Vector2(MAP_WIDTH * 0.5, MAP_HEIGHT * 0.75),
		base,
	])

	# 右上路线：先向左下，再汇入中路
	routes["top_right"] = PackedVector2Array([
		top_right,
		Vector2(MAP_WIDTH * 0.75, MAP_HEIGHT * 0.25),
		Vector2(MAP_WIDTH * 0.55, MAP_HEIGHT * 0.45),
		Vector2(MAP_WIDTH * 0.55, MAP_HEIGHT * 0.75),
		base,
	])


# 根据名称获取路线；不存在时返回空数组
func get_route(name: String) -> PackedVector2Array:
	if routes.has(name):
		return routes[name]
	return PackedVector2Array()


# 获取所有出兵点名称
func get_spawn_names() -> PackedStringArray:
	var keys := routes.keys()
	var result := PackedStringArray()
	for key in keys:
		result.append(str(key))
	return result


# 随机选择一个出兵点名称
func get_random_spawn() -> String:
	var names := get_spawn_names()
	if names.is_empty():
		return ""
	return names[randi() % names.size()]
