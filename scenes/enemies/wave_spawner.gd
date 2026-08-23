extends Node

# 波次开始信号
signal wave_started(wave: int)
# 波次结束信号
signal wave_finished(wave: int)
# 倒计时刷新信号，参数为剩余秒数
signal wave_countdown_tick(time_left: float)

# 手动配置的波次数据列表；为空时自动生成
@export var waves: Array[WaveData] = []

var _is_spawning: bool = false  # 是否正在生成当前波次的敌人
var _spawned_count: int = 0  # 当前波次已生成敌人数量
var _current_wave: WaveData = null  # 当前波次配置

@onready var _timer: Timer = $Timer  # 控制敌人生成间隔的定时器
@onready var _advance_timer: Timer = $AdvanceTimer  # 波次间自动推进定时器


# 初始化定时器与状态监听
func _ready() -> void:
	_timer.timeout.connect(_spawn_next)
	_advance_timer.timeout.connect(start_next_wave)
	GameManager.game_state_changed.connect(_on_state_changed)


# 每帧刷新倒计时显示
func _process(delta: float) -> void:
	if not _advance_timer.is_stopped():
		wave_countdown_tick.emit(_advance_timer.time_left)


# 游戏状态回到 PLAYING 且未在生成时，自动开始下一波
func _on_state_changed(state: GameManager.GameState) -> void:
	if state == GameManager.GameState.PLAYING and not _is_spawning:
		start_next_wave()


# 开始下一波；若无配置则自动生成。手动点击按钮也会调用此方法。
func start_next_wave() -> void:
	# 取消自动推进，避免手动开始后重复触发
	_advance_timer.stop()
	# 超过总波次则判定胜利
	if GameManager.wave >= GameManager.total_waves:
		GameManager.state = GameManager.GameState.WON
		return
	GameManager.advance_wave()
	if waves.size() >= GameManager.wave:
		_current_wave = waves[GameManager.wave - 1]
	else:
		_current_wave = _generate_wave(GameManager.wave)
	_spawned_count = 0
	_is_spawning = true
	wave_started.emit(GameManager.wave)
	_spawn_next()


# 根据波次编号自动生成波次数据
func _generate_wave(wave_number: int) -> WaveData:
	var wave := WaveData.new()
	wave.wave_number = wave_number
	wave.enemy_count = 5 + wave_number * 2
	wave.spawn_interval = maxf(0.3, 1.5 - wave_number * 0.08)
	wave.enemy_data = _make_enemy_data(wave_number)
	return wave


# 生成单个敌人的数据配置
func _make_enemy_data(wave_number: int) -> EnemyData:
	var data := EnemyData.new()
	data.enemy_name = "Enemy Wave %d" % wave_number
	data.base_health = 50.0 + wave_number * 15.0
	data.base_attack = 5.0 + wave_number * 1.5 + GameManager.difficulty * 2.0
	data.base_speed = 80.0 + wave_number * 5.0
	data.reward_money = 10 + wave_number
	data.reward_xp = 10 + wave_number * 2
	return data


# 定时器回调：生成下一个敌人或结束当前波次
func _spawn_next() -> void:
	if _current_wave == null or GameManager.state != GameManager.GameState.PLAYING:
		return
	# 当前波次敌人已全部生成，结束本波并启动自动推进定时器
	if _spawned_count >= _current_wave.enemy_count:
		_is_spawning = false
		wave_finished.emit(GameManager.wave)
		_timer.stop()
		# 30 秒后自动开始下一波；玩家也可通过按钮提前开始
		_advance_timer.start(30.0)
		return
	_spawned_count += 1
	_spawn_enemy()
	_timer.start(_current_wave.spawn_interval)


# 从当前波次的出兵点中随机选择一个并生成敌人
func _spawn_enemy() -> void:
	var spawn_name := _current_wave.spawn_points[randi() % _current_wave.spawn_points.size()]
	var route := PathManager.get_route(spawn_name)
	if route.is_empty():
		return

	var enemy: Enemy = preload("res://scenes/enemies/enemy.tscn").instantiate()
	enemy.setup(route, _current_wave.enemy_data)
	add_child(enemy)
	enemy.died.connect(_on_enemy_died)


# 敌人死亡回调：若被玩家击杀，将经验平分给所有塔
func _on_enemy_died(enemy: Enemy, by_player: bool) -> void:
	if by_player:
		# 第一版简化处理：经验值由所有存活塔平分
		var towers := get_tree().get_nodes_in_group("towers")
		if not towers.is_empty():
			var xp_each: int = maxi(1, enemy.data.reward_xp / towers.size())
			for tower in towers:
				tower.gain_xp(xp_each)
