class_name SkillData
extends Resource

# 技能类型：物理攻速、物理攻击力、法术攻击力、法术冷却缩减、法术技能激活
enum Type {
	PHYSICAL_ATTACK_SPEED,
	PHYSICAL_ATTACK_POWER,
	MAGIC_ATTACK_POWER,
	MAGIC_COOLDOWN_REDUCTION,
	MAGIC_SKILL_ACTIVATION,
}

# 技能名称
@export var name: String = ""
# 技能类型
@export var type: Type = Type.PHYSICAL_ATTACK_SPEED
# 技能数值
@export var value: float = 0.0
# 解锁该技能的等级（3/5/8）
@export var unlocked_at_level: int = 3
