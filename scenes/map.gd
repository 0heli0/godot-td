extends Node2D

# 道路绘制宽度
const ROAD_WIDTH: float = 40.0
# 道路颜色
const ROAD_COLOR := Color("5a4d41")

@onready var spawns: Node2D = $Spawns  # 出兵点标记节点
@onready var base: Node2D = $Base  # 基地标记节点


# 场景准备好后触发重绘，画出道路
func _ready() -> void:
	queue_redraw()


# 绘制所有预设路线作为道路
func _draw() -> void:
	for route_name in PathManager.routes:
		_draw_route(PathManager.routes[route_name])


# 根据路径点绘制一段道路：线段 + 圆角端点
func _draw_route(waypoints: PackedVector2Array) -> void:
	if waypoints.size() < 2:
		return
	for i in range(waypoints.size() - 1):
		draw_line(waypoints[i], waypoints[i + 1], ROAD_COLOR, ROAD_WIDTH)
		draw_circle(waypoints[i], ROAD_WIDTH / 2.0, ROAD_COLOR)
	draw_circle(waypoints[-1], ROAD_WIDTH / 2.0, ROAD_COLOR)


# 返回基地的世界坐标
func get_base_position() -> Vector2:
	return Vector2(get_viewport_rect().size.x / 2.0, 640.0)
