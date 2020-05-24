extends AnimatedSprite

var planet
var is_destroyed = false
var type
var child

const textures = {
	attack = preload('res://building/rocket.png'),
	defense = preload('res://building/satellite.png'),
	income = preload('res://building/mine.png')
}

func init():
	child.planet = planet
	add_child(child)
	child.connect('income', self, 'add_money')
	child.connect('change_type', self, 'change_child_type')
	child.init()

	animation = type

remotesync func destroy(cost):
	planet.money += cost / 4
	is_destroyed = true
	queue_free()
	planet.update()

func add_money(value):
	var income_animation = preload('res://Income_animation.tscn').instance()
	income_animation.position = Vector2(-10, 8)
	add_child(income_animation)
	income_animation.label.text = str(value)

func upgrade():
	if planet.money < 40:
		return

	planet.money -= 40
	child.upgrade()

func change_child_type(path):
	child.set_script(load(path))
	child.planet = planet
	child.init()

func try_fire_rocket(name):
	if type == 'attack':
		child.try_fire_rocket(name)
