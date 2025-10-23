extends State

class_name ClimbWallState

var stateName : String = "ClimbWall"

var cR : CharacterBody3D

func enter(charRef : CharacterBody3D):
	cR = charRef
