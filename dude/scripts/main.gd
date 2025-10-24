extends Node2D

#
#func _ready() -> void:
	#slime_animation.play('appear_and_pulse')
	#slime_animation.animation_finished.connect(_on_appear_and_pulse)
	#
#func _on_appear_and_pulse(name) -> void:
	#if name == 'appear_and_pulse':
		#slime_1_animation.play('idle_texture')
		

@onready var staticbox_animation = get_node("Box/AnimationPlayer")
@onready var dude = get_node("PhysicsDude")
@onready var slime_1 = get_node("Slime_1")
@onready var slime_2 = get_node("Slime_2")
@onready var slime_1_animation = get_node("Slime_1/SlimeBody/AnimationPlayer")
@onready var slime_2_animation = get_node("Slime_2/SlimeBody/AnimationPlayer")

func _ready() -> void:
	dude.hit.connect(_on_hit_static_box)
	dude.slime_hit.connect(_on_hit_slime)
	
	slime_1_animation.play('idle')
	slime_2_animation.play('idle')
	
	slime_1_animation.animation_finished.connect(_on_slime_1_animation_finished)
	slime_2_animation.animation_finished.connect(_on_slime_2_animation_finished)

func _on_hit_static_box() -> void:
	staticbox_animation.play("hit")
	
func _on_hit_slime(collider: Node) -> void:
	var slime_animation = collider.get_node("AnimationPlayer")
	if slime_animation:
		slime_animation.play('idle_texture')

func _on_slime_1_animation_finished(name: String) -> void:
	if name == 'idle_texture':
		slime_1_animation.play('idle')

func _on_slime_2_animation_finished(name: String) -> void:
	if name == 'idle_texture':
		slime_2_animation.play('idle')
