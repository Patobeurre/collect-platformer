extends CanvasLayer

class_name HUD

#label references variables
@onready var currentStateLT = $PlayCharInfos/VBoxContainer2/CurrentStateLabelText
@onready var desiredMoveSpeedLT = $PlayCharInfos/VBoxContainer2/DesiredMoveSpeedLabelText
@onready var velocityLT = $PlayCharInfos/VBoxContainer2/VelocityLabelText
@onready var nbJumpsInAirAllowedLT = $PlayCharInfos/VBoxContainer2/NbJumpsInAirAllowedLabelText
@onready var framesPerSecondLT = $PlayCharInfos2/VBoxContainer2/FramesPerSecondLabelText
@onready var staminaLT = $PlayCharInfos/VBoxContainer2/StaminaLabelText


func _process(_delta):
	displayCurrentFPS()

func displayStamina(stamina : float):
	$StaminaContainer/MarginContainer/ProgressBar.value = stamina
	staminaLT.set_text(str(stamina))

func displayCameraWallCheck(check : bool):
	$PlayCharInfos/VBoxContainer2/WallCheckLabelText.set_text(str(check))

func displayCurrentState(currentState : String):
	currentStateLT.set_text(str(currentState))
	
func displayDesiredMoveSpeed(desiredMoveSpeed : float):
	desiredMoveSpeedLT.set_text(str(desiredMoveSpeed))
	
func displayVelocity(velocity : float):
	velocityLT.set_text(str(velocity))
	
func displayNbJumpsInAirAllowed(nbJumpsInAirAllowed : int):
	nbJumpsInAirAllowedLT.set_text(str(nbJumpsInAirAllowed))
	
func displayCurrentFPS():
	framesPerSecondLT.set_text(str(Engine.get_frames_per_second()))
	
	
	
	
	
