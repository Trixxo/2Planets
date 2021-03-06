extends Node2D

var target
var velocity
var rotation_speed = 0.3
var start_velocity := 20
var min_acceleration := 0.05
var max_acceleration := 0.2
var target_player_number
var from_planet
#warning-ignore:unused_class_variable
remotesync var is_destroyed = false
var split_distance
var child_counter = 0
var color = Color(1, 0.3, 0.3)
var can_hit_planet
var type = 'normal_rocket'
remotesync var health = 10 setget set_health

func _ready():
	velocity = Vector2(start_velocity, 0).rotated(rotation)

func init(_target_player_number):
	target_player_number = _target_player_number
	var owning_player_number = 1 if target_player_number == 2 else 2
	add_to_group('rocket' + str(owning_player_number))

	if split_distance != null:
		self.texture = preload('res://split_rocket/split_missile.png')
		type = 'split_rocket'
	
	can_hit_planet = preload('res://can_hit_planet.gd').new()
	add_child(can_hit_planet)

func _process(delta):
	if is_destroyed: 
		queue_free()
		return

	if not is_instance_valid(target):
		target = find_new_target()

	if is_instance_valid(target):
		var target_angle = position.direction_to(target.global_position)
		var angle_diff = velocity.angle_to(target_angle)
		var rotation_direction = sign(angle_diff)
		velocity = velocity.rotated(rotation_direction * rotation_speed * delta)

		var acceleration = clamp(1 - abs(angle_diff), self.min_acceleration, self.max_acceleration) * delta
		velocity = velocity * (1 + acceleration)

		if can_hit_planet.did_hit_planet(target):
			can_hit_planet.rpc('hit_planet', type, target.get_path())

		if target.is_network_master():
			var distance_to_target = (
				global_position.distance_to(target.global_position) 
				- target.planetRadius
			)
			if (split_distance != null 
				and distance_to_target < split_distance):
				rpc('split')
			elif position.length_squared() > 4000000:
				queue_free()

	position += velocity * delta
	rotation = velocity.angle()

remotesync func split():
	var count = 5
	var spread = PI/8
	for i in range(count):
		child_counter += 1
		var rocket = load('res://attack/rocket.tscn').instance()
		rocket.name = name + '_' + str(child_counter)
		rocket.rotation = rotation - spread * floor(count/2) + i * spread
		rocket.position = position \
			+ velocity.rotated(rocket.rotation - rotation) * 0.2
		rocket.from_planet = from_planet
		rocket.target_player_number = target_player_number
		rocket.set_network_master(get_network_master())
		rocket.color = color
		rocket.texture = preload('res://split_rocket/split_missile.png')
		rocket.init(target_player_number)
		rocket.can_hit_planet.explosion_radius = 8
		rocket.can_hit_planet.damage = 1
		rocket.health = 5
		rocket.type = 'split_rocket'
		$'/root/main'.add_child(rocket)
		rocket.velocity = velocity.rotated(rocket.rotation - rotation) * 0.8
	print("destroying original split rocket: ", self.name)
	queue_free()


func find_new_target():
	if from_planet.player_number == 1:
		return get_node("/root/main/planet_2")
	else:
		return get_node("/root/main/planet_1")


func set_health(new_health):
	health = new_health
	if health <= 0:
		Helper.log(['rocket destroying itself: ', name])
		is_destroyed = true
