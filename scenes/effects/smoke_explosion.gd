extends CPUParticles2D

# 烟雾/爆炸特效：触发后自动销毁

func _ready() -> void:
	emitting = true
	$SelfDestruct.timeout.connect(queue_free)
