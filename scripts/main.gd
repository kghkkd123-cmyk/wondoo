extends Node2D

# Prototype-only visuals: replace these shapes with authorized game sprites later.
const WORLD_SIZE := Vector2(1152.0, 648.0)
const WALK_SPEED := 125.0
const RUN_SPEED := 220.0
const MAX_STAMINA := 100.0
const RUN_ST_COST := 24.0
const ST_RECOVERY := 14.0

var player_position := Vector2(260.0, 340.0)
var destination := Vector2(260.0, 340.0)
var running := false
var stamina := MAX_STAMINA
var inventory_open := false
var monsters: Array[Vector2] = [
	Vector2(570.0, 210.0),
	Vector2(760.0, 420.0),
	Vector2(960.0, 270.0)
]

func _process(delta: float) -> void:
	var distance := player_position.distance_to(destination)
	var moving := distance > 1.0
	if moving:
		var speed := RUN_SPEED if running and stamina > 0.0 else WALK_SPEED
		player_position = player_position.move_toward(destination, speed * delta)
		if running and stamina > 0.0:
			stamina = maxf(0.0, stamina - RUN_ST_COST * delta)
			if stamina <= 0.0:
				running = false
	else:
		player_position = destination

	if not (moving and running):
		stamina = minf(MAX_STAMINA, stamina + ST_RECOVERY * delta)
	queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_W:
			running = not running if stamina > 0.0 else false
		elif event.keycode == KEY_I:
			inventory_open = not inventory_open
		elif event.keycode == KEY_ESCAPE:
			inventory_open = false
	elif event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT and not inventory_open:
			destination = event.position.clamp(Vector2(24.0, 80.0), WORLD_SIZE - Vector2(24.0, 24.0))

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, WORLD_SIZE), Color("#213f33"))
	# Sparse map grid: no textures or animations needed to test movement.
	for x in range(0, 1152, 64):
		draw_line(Vector2(x, 0), Vector2(x, 648), Color("#315243"), 1.0)
	for y in range(0, 648, 64):
		draw_line(Vector2(0, y), Vector2(1152, y), Color("#315243"), 1.0)

	for index in monsters.size():
		var monster: Vector2 = monsters[index]
		draw_circle(monster + Vector2(0, 12), 24.0, Color(0, 0, 0, 0.25))
		draw_circle(monster, 19.0, Color("#b85e4a"))
		draw_circle(monster + Vector2(-6, -5), 3.0, Color("#fff2d8"))
		draw_circle(monster + Vector2(6, -5), 3.0, Color("#fff2d8"))
		_print_text("Monster %d" % (index + 1), monster + Vector2(-42, -27), 14)

	draw_circle(destination, 7.0, Color("#dcd78e"))
	draw_circle(destination, 3.0, Color("#435d45"))
	draw_circle(player_position + Vector2(0, 15), 23.0, Color(0, 0, 0, 0.3))
	draw_circle(player_position, 18.0, Color("#65b8f1"))
	draw_circle(player_position + Vector2(0, -5), 8.0, Color("#d6f2ff"))

	draw_rect(Rect2(0, 0, WORLD_SIZE.x, 67), Color("#122721"))
	_print_text("WONDOO   |   LEFT CLICK: MOVE   |   W: RUN TOGGLE   |   I: INVENTORY", Vector2(24, 28), 18)
	draw_rect(Rect2(24, 45, 214, 12), Color("#101d19"))
	draw_rect(Rect2(26, 47, 210.0 * stamina / MAX_STAMINA, 8), Color("#f3c45c"))
	_print_text("ST %d / %d" % [ceili(stamina), int(MAX_STAMINA)], Vector2(248, 56), 14)
	_print_text("MODE: %s" % ("RUN" if running else "WALK"), Vector2(400, 56), 14)
	_print_text("Prototype: combat and loot coming later", Vector2(24, 624), 16)

	if inventory_open:
		_draw_inventory()

func _draw_inventory() -> void:
	var panel := Rect2(748, 92, 367, 488)
	draw_rect(panel, Color("#172821"))
	draw_rect(panel, Color("#9cb494"), false, 2.0)
	_print_text("INVENTORY  (I / ESC to close)", Vector2(770, 123), 18)
	for row in 5:
		for col in 4:
			var slot := Rect2(774 + col * 82, 154 + row * 76, 68, 64)
			draw_rect(slot, Color("#2b4036"))
			draw_rect(slot, Color("#526a55"), false, 1.0)
	_print_text("Item icons will be added later.", Vector2(771, 558), 15)

func _print_text(message: String, position: Vector2, font_size: int) -> void:
	draw_string(ThemeDB.fallback_font, position, message, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color("#f3f0dc"))
