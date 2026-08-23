extends Control

@onready var _money_label: Label = $TopBar/Money  # 金钱显示标签
@onready var _wood_label: Label = $TopBar/Wood  # 木材显示标签
@onready var _ore_label: Label = $TopBar/Ore  # 矿石显示标签
@onready var _wave_label: Label = $TopBar/Wave  # 波次显示标签
@onready var _status_label: Label = $StatusLabel  # 胜负状态提示
@onready var _next_wave_button: Button = $NextWaveButton  # 手动开始下一波按钮


# 初始化：连接 GameManager 信号、按钮事件并刷新 UI
func _ready() -> void:
	GameManager.money_changed.connect(_update_labels)
	GameManager.wood_changed.connect(_update_labels)
	GameManager.ore_changed.connect(_update_labels)
	GameManager.wave_changed.connect(_update_labels)
	GameManager.game_state_changed.connect(_on_state_changed)
	_next_wave_button.pressed.connect(_on_next_wave_pressed)
	_next_wave_button.mouse_entered.connect(_on_button_hover)
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
		GameManager.GameState.LOST:
			_status_label.text = "失败！"
			_next_wave_button.visible = false
		_:
			_status_label.text = ""
			_next_wave_button.visible = true


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
