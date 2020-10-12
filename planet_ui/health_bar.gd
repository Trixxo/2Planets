#warning-ignore-all:return_value_discarded

tool
extends Control

var planet
var health = 100
var animated_health = health
var background = health
var tween: Tween
var tween_target = health
var tween_start_value = health
var width_factor = rect_size.x / 100

const tween_duration = 0.4
const default_tween_delay_duration = 0.5 
var tween_delay_duration = default_tween_delay_duration

func _ready():
	tween = $'Tween'

func _draw():
	draw_line(Vector2(0, 0), Vector2(background * width_factor, 0), Color('#3a3756'), 8)
	draw_line(Vector2(1, 0), Vector2((animated_health) * width_factor -1, 0), Color(1, 1, 1), 6)
	draw_line(Vector2(1, 0), Vector2(health * width_factor - 1, 0), Color('#51647d'), 6)

func _process(_delta: float):
	var delay_in_effect = tween.is_active() and round(animated_health) == round(tween_start_value)
	var should_animate = health < tween_target
	if should_animate and (not tween.is_active() or delay_in_effect):
		start_tween()
		tween_delay_duration = default_tween_delay_duration
	elif should_animate and not delay_in_effect:
		tween_delay_duration = 0
		
	update()

func start_tween():
	tween.remove_all()
	tween_start_value = animated_health
	tween_target = health
	tween.interpolate_property(self, 'animated_health',
		animated_health, health, tween_duration,
		Tween.TRANS_QUINT, Tween.EASE_IN, tween_delay_duration)
	tween.start()
