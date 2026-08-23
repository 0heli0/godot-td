extends Control

@onready var _money_label: Label = $TopBar/Money  # 金钱显示标签
@onready var _wood_label: Label = $TopBar/Wood  # 木材显示标签
@onready var _ore_label: Label = $TopBar/Ore  # 矿石显示标签
@onready var _wave_label: Label = $TopBar/Wave  # 波次显示标签
@onready var _status_label: Label = $StatusLabel  # 胜负状态提示
@onready var _next_wave_button: Button = $NextWaveButton  # 手动开始下一波按钮
@onready var _countdown_label: Label = $CountdownLabel  # 下一波倒计时标签


# 初始化：连接 GameManager 信号、按钮事件并刷新 UI
func _ready() -> void:
	GameManager.money_changed.connect(_update_labels)
	GameManager.wood_changed.connect(_update_labels)
	GameManager.ore_changed.connect(_update_labels)
	GameManager.wave_changed.connect(_update_labels)
	GameManager.game_state_changed.connect(_on_state_changed)
	_next_wave_button.pressed.connect(_on_next_wave_pressed)
	_next_wave_button.mouse_entered.connect(_on_button_hover)
	_connect_wave_spawner()
	_update_labels()


# 更新资源与波次显示
func _update_labels(_value: int = 0) -> void:
	_money_label.text = "金钱: %d" % GameManager.money
	_wood_label.text = "木材: %d" % GameManager.wood
	_ore_label.text = "矿石: %d" % GameManager.ore
	_wave_label.text = "波次: %d / %d" % [GameManager.wave, GameManager.total_waves]


# 根据游戏状态显示胜负提示并控制按钮可见性
func _on_state_changed(state: GameManager.GameState) -> void:
	match state:
		GameManager.GameState.WON:
			_status_label.text = "胜利！"
			_next_wave_button.visible = false
			_countdown_label.visible = false
		GameManager.GameState.LOST:
			_status_label.text = "失败！"
			_next_wave_button.visible = false
			_countdown_label.visible = false
		_:
			_status_label.text = ""
			_next_wave_button.visible = true


# 连接波次生成器的倒计时信号
func _connect_wave_spawner() -> void:
	var spawner := get_tree().get_first_node_in_group("wave_spawner") as Node
	if spawner == null:
		return
	spawner.wave_started.connect(_on_wave_started)
	spawner.wave_finished.connect(_on_wave_finished)
	spawner.wave_countdown_tick.connect(_on_countdown_tick)


# 新波次开始时隐藏倒计时
func _on_wave_started(_wave: int) -> void:
	_countdown_label.visible = false


# 波次全部敌人出现后显示倒计时，并立即显示初始 30 秒
func _on_wave_finished(_wave: int) -> void:
	_countdown_label.visible = true
	_countdown_label.text = "下一波: 30s"


# 更新倒计时显示
func _on_countdown_tick(time_left: float) -> void:
	_countdown_label.text = "下一波: %.0fs" % time_left


# 鼠标悬停按钮时播放悬停音效
func _on_button_hover() -> void:
	AudioManager.play_ui_hover()


# 点击“下一波”按钮时播放点击音效并通知波次生成器
func _on_next_wave_pressed() -> void:
	AudioManager.play_ui_click()
	if GameManager.state == GameManager.GameState.PLAYING:
		var spawner := get_tree().get_first_node_in_group("wave_spawner") as Node
		if spawner:
			spawner.start_next_wave()
