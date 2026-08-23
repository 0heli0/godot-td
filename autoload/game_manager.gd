extends Node

# 游戏全局状态枚举：进行中、胜利、失败
enum GameState { PLAYING, WON, LOST }

# 资源变化信号，供 UI 监听
signal money_changed(amount: int)
signal wood_changed(amount: int)
signal ore_changed(amount: int)
signal wave_changed(wave: int)
signal game_state_changed(state: GameState)

# 玩家拥有的金钱，修改时自动发出信号并限制为不小于 0
var money: int = 200:
	set(value):
		money = maxi(0, value)
		money_changed.emit(money)

# 玩家拥有的木材，修改时自动发出信号并限制为不小于 0
var wood: int = 100:
	set(value):
		wood = maxi(0, value)
		wood_changed.emit(wood)

# 玩家拥有的矿石，修改时自动发出信号并限制为不小于 0
var ore: int = 50:
	set(value):
		ore = maxi(0, value)
		ore_changed.emit(ore)

# 当前波次，修改时自动发出信号并限制为不小于 0
var wave: int = 0:
	set(value):
		wave = maxi(0, value)
		wave_changed.emit(wave)

# 当前难度等级，影响敌人攻击力
var difficulty: int = 1

# 当前游戏状态，修改时自动发出信号
var state: GameState = GameState.PLAYING:
	set(value):
		state = value
		game_state_changed.emit(state)

# 总波次数，击败所有波次即获胜
var total_waves: int = 10


# 初始化：重置所有全局状态
func _ready() -> void:
	reset()


# 重置游戏状态为初始值
func reset() -> void:
	money = 200
	wood = 100
	ore = 50
	wave = 0
	difficulty = 1
	state = GameState.PLAYING


# 检查是否支付得起指定的资源消耗
func can_afford(cost: Dictionary) -> bool:
	return (
		money >= cost.get("money", 0)
		and wood >= cost.get("wood", 0)
		and ore >= cost.get("ore", 0)
	)


# 支付资源消耗，成功返回 true，失败返回 false
func spend(cost: Dictionary) -> bool:
	if not can_afford(cost):
		return false
	money -= cost.get("money", 0)
	wood -= cost.get("wood", 0)
	ore -= cost.get("ore", 0)
	return true


# 获得资源奖励
func earn(cost: Dictionary) -> void:
	money += cost.get("money", 0)
	wood += cost.get("wood", 0)
	ore += cost.get("ore", 0)


# 进入下一波；超过总波次则判定胜利
func advance_wave() -> void:
	wave += 1
	if wave > total_waves:
		state = GameState.WON


# 触发失败状态
func lose() -> void:
	state = GameState.LOST
