extends Node

# UI 音效
@onready var _ui_click: AudioStreamPlayer = $UIClick
@onready var _ui_hover: AudioStreamPlayer = $UIHover

# 游戏音效
@onready var _attack: AudioStreamPlayer = $Attack
@onready var _explosion: AudioStreamPlayer = $Explosion


# 播放 UI 点击音效
func play_ui_click() -> void:
	_ui_click.play()


# 播放 UI 悬停音效
func play_ui_hover() -> void:
	_ui_hover.play()


# 播放攻击音效
func play_attack() -> void:
	_attack.play()


# 播放爆炸/死亡音效
func play_explosion() -> void:
	_explosion.play()
