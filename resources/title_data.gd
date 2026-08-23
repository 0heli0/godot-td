class_name TitleData
extends Resource

# 称号名称
@export var title_name: String = ""
# 该称号可用的技能池
@export var skill_pool: Array[SkillData] = []
# 额外属性加成，例如 {"attack_power": 10.0}
@export var bonus_stats: Dictionary = {}
