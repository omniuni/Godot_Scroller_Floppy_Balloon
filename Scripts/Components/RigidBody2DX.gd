class_name RigidBody2DX
extends RigidBody2D

var _last_known_state: PhysicsDirectBodyState2D

func get_last_known_physics_state() -> PhysicsDirectBodyState2D:
	return _last_known_state

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	_last_known_state = state
	pass
