extends CharacterBody3D

class_name PlayerCharacter 

@export_group("Movement variables")
var moveSpeed : float
var moveAccel : float
var moveDeccel : float
var desiredMoveSpeed : float 
@export var desiredMoveSpeedCurve : Curve
@export var maxSpeed : float
@export var inAirMoveSpeedCurve : Curve
var inputDirection : Vector2 
var moveDirection : Vector3 
@export var hitGroundCooldown : float #amount of time the character keep his accumulated speed before losing it (while being on ground)
var hitGroundCooldownRef : float 
@export var bunnyHopDmsIncre : float #bunny hopping desired move speed incrementer
@export var autoBunnyHop : bool = false
var lastFramePosition : Vector3 
var lastFrameVelocity : Vector3
var wasOnFloor : bool
var walkOrRun : String = "WalkState" #keep in memory if play char was walking or running before being in the air
#for crouch visible changes
@export var baseHitboxHeight : float
@export var baseModelHeight : float
@export var heightChangeSpeed : float

@export_group("In Air variables")
@export var inAirMoveAccel : float
@export var inAirMoveDeccel : float

@export_group("Crouch variables")
@export var crouchSpeed : float
@export var crouchAccel : float
@export var crouchDeccel : float
@export var continiousCrouch : bool = false #if true, doesn't need to keep crouch button on to crouch
@export var crouchHitboxHeight : float
@export var crouchModelHeight : float

@export_group("Walk variables")
@export var walkSpeed : float
@export var walkAccel : float
@export var walkDeccel : float

@export_group("Run variables")
@export var runSpeed : float
@export var runAccel : float 
@export var runDeccel : float 
@export var continiousRun : bool = false #if true, doesn't need to keep run button on to run

@export_group("Climb variables")
@export var climbSpeed : float
@export var climbAccel : float
@export var climbDeccel : float
@export var wallPullForce : float
@export var wallNormalOffsetDown : float
@export var wallNormalOffsetUp : float
var wallNormal : Vector3
var wallLeftNormal : Vector3
var wallRightNormal : Vector3
var wallSideDir : Vector3
var wallUpDir : Vector3

@export_group("Jump variables")
@export var jumpHeight : float
@export var jumpTimeToPeak : float
@export var jumpTimeToFall : float
@onready var jumpVelocity : float = (2.0 * jumpHeight) / jumpTimeToPeak
@export var jumpCooldown : float
var jumpCooldownRef : float 
@export var nbJumpsInAirAllowed : int 
var nbJumpsInAirAllowedRef : int 
var jumpBuffOn : bool = false
var bufferedJump : bool = false
@export var coyoteJumpCooldown : float
var coyoteJumpCooldownRef : float
var coyoteJumpOn : bool = false

@export_group("Grapling variables")
@export var ropeSpeed : float
@export var ropeAccel : float
@export var ropeDeccel : float
@export var ropeMinDistance : float

@export_group("Gravity variables")
@onready var jumpGravity : float = (-2.0 * jumpHeight) / (jumpTimeToPeak * jumpTimeToPeak)
@onready var fallGravity : float = (-2.0 * jumpHeight) / (jumpTimeToFall * jumpTimeToFall)

@export_group("Keybind variables")
@export var moveForwardAction : String = ""
@export var moveBackwardAction : String = ""
@export var moveLeftAction : String = ""
@export var moveRightAction : String = ""
@export var runAction : String = ""
@export var crouchAction : String = ""
@export var jumpAction : String = ""
@export var climbAction : String = ""
@export var ropeAction : String = ""

@export_group("Stamina variables")
@export var maxStamina : float
@export var jumpStaminaConsumption : float
@export var climbStaminaConsumption : float
@export var ropeStaminaConsumption : float
@export var staminaBaseRecovery : float
var currStamina : float

#references variables
@onready var camHolder : Node3D = $CameraHolder
@onready var model : MeshInstance3D = $Model
@onready var hitbox : CollisionShape3D = $Hitbox
@onready var stateMachine : Node = $StateMachine
@onready var hud : CanvasLayer = $HUD
@onready var ceilingCheck : RayCast3D = $Raycasts/CeilingCheck
@onready var floorCheck : RayCast3D = $Raycasts/FloorCheck
@onready var wallCheck : RayCast3D = $CameraHolder/Camera/CameraWallCheck
@onready var wallDetector : Node3D = $WallDetector
@onready var wallCenterCheck : RayCast3D = $WallDetector/WallCenterCheck
@onready var wallLeftCheck : RayCast3D = $WallDetector/WallLeftCheck
@onready var wallRightCheck : RayCast3D = $WallDetector/WallRightCheck
@onready var wallDetectorTmp : Node3D = $WallDetectorTmp
@onready var wallCenterCheckTmp : RayCast3D = $WallDetectorTmp/WallCenterCheckTmp
@onready var rope_node : Node3D = $Rope
@onready var ropeCheck : RayCast3D = $CameraHolder/Camera/RopeCheck
@onready var rope_path : Path3D = $Rope/RopePath3D
@onready var ledgeDetector : Node3D = $LedgeDetector
@onready var ledgeCheckHigh : RayCast3D = $LedgeDetector/LedgeCheckHigh
@onready var ledgeCheckLow : RayCast3D = $LedgeDetector/LedgeCheckLow


func _ready():
	#set move variables, and value references
	moveSpeed = walkSpeed
	moveAccel = walkAccel
	moveDeccel = walkDeccel
	
	hitGroundCooldownRef = hitGroundCooldown
	jumpCooldownRef = jumpCooldown
	nbJumpsInAirAllowedRef = nbJumpsInAirAllowed
	coyoteJumpCooldownRef = coyoteJumpCooldown
	
	currStamina = maxStamina
	
func _process(_delta: float):
	displayProperties()
	
func _physics_process(_delta : float):
	modifyPhysicsProperties()
	
	updateDetectorsOrientation()
	
	move_and_slide()
	
	updateStamina(_delta)
	
	Global.player_global_pos = camHolder.global_position


func isOnLedge() -> bool:
	return (ledgeCheckLow.is_colliding() and !ledgeCheckHigh.is_colliding())


func updateStamina(delta):
	if is_on_floor():
		if currStamina > maxStamina:
			currStamina = maxStamina
		elif currStamina < maxStamina:
			currStamina += staminaBaseRecovery * delta

func checkStamina(staminaToConsume):
	return currStamina - staminaToConsume > 0

func updateDetectorsOrientation():
	if (stateMachine.currStateName != "ClimbIdle") and (stateMachine.currStateName != "Rope") :
		var look_dir : Vector3 = Vector3(global_position.x, 0, global_position.z) - camHolder.get_global_transform_interpolated().basis.z
		look_dir.y = wallDetector.global_position.y
		wallDetector.look_at(look_dir, Vector3.UP)
		wallDetectorTmp.look_at(look_dir, Vector3.UP)
		look_dir.y = ledgeDetector.global_position.y
		ledgeDetector.look_at(look_dir, Vector3.UP)

func displayProperties():
	#display properties on the hud
	if hud != null:
		hud.displayCurrentState(stateMachine.currStateName)
		hud.displayDesiredMoveSpeed(desiredMoveSpeed)
		hud.displayVelocity(velocity.length())
		hud.displayNbJumpsInAirAllowed(nbJumpsInAirAllowed)
		hud.displayStamina(currStamina)
		hud.displayCameraWallCheck(wallCheck.is_colliding())
		
func modifyPhysicsProperties():
	lastFramePosition = position #get play char position every frame
	lastFrameVelocity = velocity #get play char velocity every frame
	wasOnFloor = !is_on_floor() #check if play char was on floor every frame
	
func gravityApply(delta : float):
	#if play char goes up, apply jump gravity
	#otherwise, apply fall gravity
	if velocity.y >= 0.0: velocity.y += jumpGravity * delta
	elif velocity.y < 0.0: velocity.y += fallGravity * delta

func isMovingLeft() -> bool:
	return inputDirection.x < 0
	
func isMovingRight() -> bool:
	return inputDirection.x > 0 
