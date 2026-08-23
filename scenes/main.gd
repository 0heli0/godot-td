extends Node2D

# 初始塔的屏幕位置
@export var initial_tower_position: Vector2 = Vector2(640, 400)

@onready var _map: Node2D = $Map  # 地图节点
@onready var _base_crystal: Area2D = $BaseCrystal  # 基地水晶
@onready var _wave_spawner: Node = $WaveSpawner  # 波次生成器
@onready var _ui: Control = $UIRoot  # UI 根节点


# 建造一座新塔所需的资源
const TOWER_COST := {"money": 50, "wood": 10, "ore": 0}


# 场景加载完成时：重置游戏、定位基地、放置初始塔
# 波次由 WaveSpawner 自动监听 GameManager 状态变化后启动
func _ready() -> void:
	GameManager.reset()
	_base_crystal.global_position = _map.get_base_position()
	_add_initial_tower()
	# 把波次生成器信号传给 UI，确保倒计时能正常刷新
	_ui.connect_wave_spawner(_wave_spawner)


# 处理鼠标左键点击：在地图空白处建造塔
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		# 避免点击 UI 时误建塔
		if not _is_ui_click(event.position):
			_try_place_tower(event.position)


# 判断点击位置是否在 UI 范围内
func _is_ui_click(position: Vector2) -> bool:
	var ui_rect := _ui.get_global_rect()
	return ui_rect.has_point(position)


# 尝试在指定位置建造一座基础塔
func _try_place_tower(position: Vector2) -> void:
	# 资源不足则直接返回
	if not GameManager.can_afford(TOWER_COST):
		return
	# 扣除资源失败则返回
	if not GameManager.spend(TOWER_COST):
		return
	var tower := preload("res://scenes/towers/tower.tscn").instantiate() as Tower
	tower.global_position = position
	tower.data = _create_basic_tower_data()
	add_child(tower)


# 在游戏开始时放置一座免费的初始塔
func _add_initial_tower() -> void:
	var tower := preload("res://scenes/towers/tower.tscn").instantiate() as Tower
	tower.global_position = initial_tower_position
	tower.data = _create_basic_tower_data()
	add_child(tower)


# 创建基础塔的数据配置
func _create_basic_tower_data() -> TowerData:
	var data := TowerData.new()
	data.tower_name = "Basic Tower"
	data.attack_type = TowerData.AttackType.PHYSICAL
	data.base_attack_power = 15.0
	data.attack_speed = 1.2
	data.attack_range = 220.0
	data.projectile_speed = 500.0
	data.cost = TOWER_COST
	return data
