extends CharacterBody3D
class_name Player


@export_subgroup("Properties")
@export var movement_speed = 5
@export var jump_strength = 8
@export var dash_speed = 60
@export var zoom_value = 10
@export var ladder_climb_speed = 4
@export var ladder_gravity = 2

@export var STEP_HEIGHT: float = 0.2

@export var push_force :float = 80.0


var mouse_sensitivity = 500
var gamepad_sensitivity := 0.075

var movement_velocity: Vector3
var rotation_target: Vector3
var direction: Vector3 = Vector3.ZERO
var direction_dash: Vector3 = Vector3.ZERO

var input_mouse: Vector2

var health:int = 100
var gravity := 0.0

var previously_floored := false

var jump_single := true
var jump_double := true


@onready var body = $Body
@onready var camera = $Head/Camera
@onready var dash_cooldown = $DashCD
@onready var dash_duration = $DashDuration

@onready var raycast_head = $Head/RayCastHead


var is_jumping :bool = false
var is_in_air :bool = false
var is_dashing :bool = false
var is_dash_enabled :bool = true
var is_climbing_step :bool = false
var is_interacting :bool = false
var is_on_ladder :bool = false

var is_movement_enabled :bool = true
var is_camera_enabled :bool = true
var is_fishing_enabled :bool = true



func _ready():
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	rotation_target = camera.global_rotation


func _physics_process(delta):
	
	# Handle functions
	
	if is_on_floor():
		is_jumping = false
		is_in_air = false
	else:
		is_in_air = true
	
	handle_controls(delta)
	
	# Movement
	
	if is_dashing:
		movement_velocity = movement_velocity.lerp(dash_speed * direction_dash, delta * 10)
	elif is_on_ladder:
		movement_velocity = movement_velocity.lerp(movement_speed * direction * 0.5, delta * 10)
		if Input.is_action_pressed("move_forward"):
			movement_velocity.y = ladder_climb_speed
		else:
			movement_velocity.y = -ladder_gravity
	else:
		handle_gravity(delta)
		movement_velocity = movement_velocity.lerp(movement_speed * direction, delta * 10)
		movement_velocity.y = -gravity
	
	
	print(movement_velocity)
	
	set_velocity(movement_velocity)
	set_max_slides(6)
	move_and_slide()
	
	# Push RigidBody3D
	
	for i in get_slide_collision_count():
		var c = get_slide_collision(i)
		if c.get_collider() is RigidBody3D:
			c.get_collider().apply_central_impulse(-c.get_normal() * push_force)
	
	# Rotation Camera
	
	camera.rotation.z = lerp_angle(camera.rotation.z, -input_mouse.x * 6 * delta, 0)
	
	camera.rotation.x = lerp_angle(camera.rotation.x, rotation_target.x, delta * 25)
	rotation.y = lerp_angle(rotation.y, rotation_target.y, delta * 25)
	
	# Landing after jump or falling
	
	camera.position.y = lerp(camera.position.y, 0.0, delta * 5)
	
	if is_on_floor() and gravity > 1 and !previously_floored:
		camera.position.y = -0.1
	
	previously_floored = is_on_floor()
	
	# Falling/respawning
	
	if is_jumping:
		is_jumping = false
		is_in_air = true
	


# Mouse movement

func _input(event):
	if event is InputEventMouseMotion and is_camera_enabled:
		
		input_mouse = event.relative / mouse_sensitivity
		
		rotation_target.y -= event.relative.x / mouse_sensitivity
		rotation_target.x -= event.relative.y / mouse_sensitivity




func handle_controls(_delta):
	
	if not is_movement_enabled:
		return
	
	# Movement
	
	var input := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	direction = (body.global_transform.basis * Vector3(input.x, 0, input.y)).normalized()

	#movement_velocity = Vector3(input.x, 0, input.y).normalized() * movement_speed
	
	#action_zoom()
	
	action_dash()
	action_pickaxe()
	
	# Rotation
	
	#var rotation_input := Input.get_vector("camera_right", "camera_left", "camera_down", "camera_up")
	
	#rotation_target -= Vector3(-rotation_input.y, -rotation_input.x, 0).limit_length(1.0) * gamepad_sensitivity
	#rotation_target.x = clamp(rotation_target.x, deg_to_rad(-90), deg_to_rad(90))
	
	# Jumping
	
	if Input.is_action_just_pressed("jump"):
		
		if is_on_floor():
			is_jumping = true
			is_in_air = false
		
		if(jump_single): action_jump()
	

# Handle gravity

func handle_gravity(delta):
	
	gravity += 20 * delta
	
	if gravity > 0 and is_on_floor():
		jump_single = true
		gravity = 0


# Jumping

func action_jump():
	
	gravity = -jump_strength
	
	jump_single = false
	jump_double = true


func action_pickaxe():
	
	if Input.is_action_just_pressed("pickaxe"):
		
		if raycast_head.is_colliding():
			print("collide")


func action_dash():
	
	if Input.is_action_pressed("dash"):
		
		if not is_dash_enabled:
			return
		
		is_dash_enabled = false
		is_dashing = true
		gravity = 0
		
		if direction != Vector3.ZERO:
			direction_dash = direction
		else:
			direction_dash = (body.global_transform.basis * Vector3.FORWARD).normalized()
		
		dash_duration.start()
		dash_cooldown.start()


func enable_movements_controls(enabled :bool):
	is_movement_enabled = enabled
	direction = Vector3.ZERO
	movement_velocity = Vector3.ZERO

func enable_camera_controls(enabled :bool):
	is_camera_enabled = enabled


func _on_dash_cd_timeout():
	is_dash_enabled = true


func _on_dash_duration_timeout():
	is_dashing = false
