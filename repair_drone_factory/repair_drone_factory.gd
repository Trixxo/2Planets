extends Node2D

var additional_income = 1
var planet
var drone_index := 0
var activate_cost := 40
var building_info: String setget ,get_building_info
var animation_finished := true
var drones := []
var drone_spawner
const upgrade_1_type = 'healing_drone_factory'
const max_drones = 10

func init():
	building_info = ''
	drone_spawner = load('res://drone_spawner.gd').new()
	drone_spawner.max_drones = max_drones
	drone_spawner.base_building = get_parent()
	drone_spawner.factory = self
	drone_spawner.start_factory()

func buildup_finish():
	for drone in drones:
		drone.active = true

func new_drone():
	var repair_drone_rotation = \
		position.direction_to(Vector2(0, 0)).angle() - PI/2
	var direction_to_planet = \
		Vector2(0, 0).direction_to(get_parent().position).angle() - PI/2
	var repair_drone = \
		preload('res://repair_drone_factory/repair_drone.tscn').instance()
	repair_drone.name = '%s_drone_%d' % [name, drone_index]
	repair_drone.position = repair_drone.position.rotated(repair_drone_rotation)
	repair_drone.position += \
		get_parent().position + Vector2(0, 20).rotated(direction_to_planet)
	repair_drone.z_index = 3 if round(rand_range(1, 3)) == 1 else 1
	planet.add_child(repair_drone)
	repair_drone.init()
	drones.append(repair_drone)
	drone_spawner.drones = drones

func on_destroy():
	for drone in drones:
		drone.active = false

func get_building_info() -> String:
	return '%d/%d drones' % [len(drones), max_drones]

func on_animation_finished():
	animation_finished = true
	new_drone()
	get_parent().play('repair_drone_factory')
