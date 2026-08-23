class_name WaveData
extends Resource

# 波次编号
@export var wave_number: int = 1
# 该波次敌人的数据资源
@export var enemy_data: EnemyData
# 该波次敌人总数
@export var enemy_count: int = 5
# 生成间隔（秒）
@export var spawn_interval: float = 1.5
# 该波次可能使用的出兵点名称列表
@export var spawn_points: PackedStringArray = ["top_left", "top_center", "top_right"]
