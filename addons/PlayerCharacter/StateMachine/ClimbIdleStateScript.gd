extends State

class_name ClimbIdleState

var stateName : String = "ClimbIdle"

var cR : CharacterBody3D

func enter(charRef : CharacterBody3D):
	cR = charRef
	
	verifications()
	
	cR.velocity = Vector3.ZERO

#func exit():
#	cR.reparent(get_tree().root)

func verifications():
	cR.moveSpeed = cR.climbSpeed
	cR.moveAccel = cR.climbAccel
	cR.moveDeccel = cR.climbDeccel
	
	if not cR.wallNormal:
		transitioned.emit(self, "IdleState")
		return
	
	var dot = cR.wallNormal.dot(Vector3.UP)
	
	if dot < -0.2 or dot > 0.2:
		transitioned.emit(self, "IdleState")
		return
	
	cR.wallDetector.look_at(cR.wallDetector.global_position - cR.wallNormal, Vector3.UP)
	
	_compute_wall_local_axes()

func _compute_wall_local_axes():
	var normalX :Vector2 = Vector2(cR.wallNormal.x, cR.wallNormal.z).normalized()
	var dir = Vector2(normalX.y, -normalX.x)
	cR.wallSideDir = Vector3(dir.x, 0.0, dir.y)
	var normalY :Vector2 = Vector2(cR.wallNormal.x, cR.wallNormal.y).normalized()
	dir = Vector2(normalY.y, -normalY.x)
	cR.wallUpDir = Vector3(dir.x, dir.y, 0.0)
	_try_update_detectors_orientation(cR.wallNormal)

func checkWallNormal():
	var dot = cR.wallNormal.dot(Vector3.UP)
	
	if dot < -cR.wallNormalOffsetDown or dot > cR.wallNormalOffsetUp:
		transitioned.emit(self, "IdleState")
		return

func physics_update(delta : float):
	checkWallNormal()
	
	update_normals()
	
	inputManagement()
	
	check_climbing_possible()
	
	move(delta)


func update_normals():
	if cR.wallCenterCheck.is_colliding():
		#cR.reparent(cR.wallCenterCheck.get_collider())
		cR.wallNormal = cR.wallCenterCheck.get_collision_normal()
		_compute_wall_local_axes()
	if cR.wallLeftCheck.is_colliding():
		cR.wallLeftNormal = cR.wallLeftCheck.get_collision_normal()
	if cR.wallRightCheck.is_colliding():
		cR.wallRightNormal = cR.wallRightCheck.get_collision_normal()
	

func _try_update_detectors_orientation(normal :Vector3):
	var dir = cR.wallDetector.global_position - normal
	cR.wallDetectorTmp.look_at(dir, Vector3.UP)
	if cR.wallCenterCheckTmp.is_colliding():
		if cR.wallCenterCheckTmp.get_collision_normal() == normal:
			cR.wallDetector.look_at(dir, Vector3.UP)
			cR.ledgeDetector.look_at(Vector3(dir.x, cR.ledgeDetector.global_position.y, dir.z), Vector3.UP)


func inputManagement():
	#if Input.is_action_just_pressed(cR.climbAction):
	#	transitioned.emit(self, "IdleState")
	if Input.is_action_just_pressed(cR.ropeAction):
		if cR.checkStamina(cR.ropeStaminaConsumption):
			if cR.ropeCheck.is_colliding():
				cR.wallNormal = cR.ropeCheck.get_collision_normal()
				transitioned.emit(self, "RopeState")
	
	if Input.is_action_just_pressed(cR.jumpAction):
		transitioned.emit(self, "JumpState")


func check_climbing_possible():
	if !cR.wallCenterCheck.is_colliding() or cR.currStamina <= 0:
		transitioned.emit(self, "IdleState")


func move(delta : float):
	#direction input
	cR.inputDirection = Input.get_vector(cR.moveLeftAction, cR.moveRightAction, cR.moveForwardAction, cR.moveBackwardAction)
	#get the move direction depending on the input
	cR.moveDirection = (cR.wallSideDir * cR.inputDirection.x).normalized()
	cR.moveDirection.y = -cR.inputDirection.y
	#cR.moveDirection += (cR.wallUpDir * cR.inputDirection.y).normalized()
	
	if cR.moveDirection.y < 0 and cR.is_on_floor():
		transitioned.emit(self, "IdleState")
	
	if (cR.moveDirection.y > 0 and cR.isOnLedge()):
		transitioned.emit(self, "ClimbLedgeState")
	
	if (cR.isMovingLeft() and cR.wallLeftCheck.is_colliding()):
		var normal = cR.wallLeftCheck.get_collision_normal()
		_try_update_detectors_orientation(normal)
	
	if (cR.isMovingRight() and cR.wallRightCheck.is_colliding()):
		var normal = cR.wallRightCheck.get_collision_normal()
		_try_update_detectors_orientation(normal)
	
	if cR.moveDirection:
		cR.currStamina -= cR.climbStaminaConsumption * delta
		#apply smooth move
		#apply force to stick to the wall
		cR.moveDirection += -cR.wallNormal * cR.wallPullForce
		cR.velocity = lerp(cR.velocity, cR.moveDirection * cR.moveSpeed, cR.moveAccel * delta)
	else:
		#apply smooth stop 
		cR.velocity = lerp(cR.velocity, Vector3.ZERO, cR.moveDeccel * delta)
		
		#cancel desired move speed accumulation if the timer has elapsed (is up)
		if cR.hitGroundCooldown <= 0: cR.desiredMoveSpeed = cR.velocity.length()
		
	#set to ensure the character don't exceed the max speed authorized
	if cR.desiredMoveSpeed >= cR.maxSpeed: cR.desiredMoveSpeed = cR.maxSpeed
