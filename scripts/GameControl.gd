extends CanvasLayer
var HiddenCursorEnabled: bool = false
var isApproving: bool = false
var isDenying: bool = false
var PassingPolicyAnimationExit: bool = false
var PassingPolicyAnimationEnter: bool = false
var current_policy: Dictionary
const MAX_POLICIES_TO_REVIEW: int = 2
var PoliciesReviewed = 0
var isFinishingUpFiscalYear = false
var CompiledPassedBills: Array
func _ready():
	SignalBus.connect("displayBill", _on_paperstack_toggle)
	SignalBus.connect("StampSelected_Deny", _on_StampSelectedDeny_toggle)
	SignalBus.connect("StampSelected_Approve",_on_StampSelectedApprove_toggle)
	SignalBus.connect("policyPressed", _on_PolicyPressed)
	SignalBus.connect("broadcastCurrentPolicy", _on_GetCurrentPolicy)
func _on_GetCurrentPolicy(policy):
	current_policy = policy

func transition():
	$BlackScreen.visible = true	
	$AnimationPlayer.play("fade_to_black")
func _on_paperstack_toggle(value):
	$PassingPolicies.visible = value
	
func _on_StampSelectedDeny_toggle(value):
	isDenying = value
	isApproving = !value
	switchMouseCursor(value,  load('res://assets/Art/stampDeny_hover.png'))
func _on_StampSelectedApprove_toggle(value):
	isApproving = value
	isDenying = !value
	switchMouseCursor(value,  load('res://assets/Art/stampApprove_hover.png'))
func switchMouseCursor(value, texture):
	if value:
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		HiddenCursorEnabled = true
		$"HiddenCursor".visible = true
		$"HiddenCursor".texture = texture
	else: 
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		HiddenCursorEnabled = false
		$"HiddenCursor".visible = false
		isApproving = false
		isDenying = false

func _on_PolicyPressed():
	if isApproving:
		$PassingPolicies/Paper/Stamp.texture = load('res://assets/Art/Approved.png')
		SignalBus.emit_signal('policyPassed', current_policy)
		CompiledPassedBills.append(current_policy)
	if isDenying:
		$PassingPolicies/Paper/Stamp.texture = load('res://assets/Art/Denied.png')
	if isApproving or isDenying:
		PoliciesReviewed += 1
		$RemainingBills.text = "Bills Remaining: " + str(MAX_POLICIES_TO_REVIEW - PoliciesReviewed)
		$PassingPolicies/Paper/Stamp.visible = true
		$PassingPolicies/Paper.disabled = true
		await get_tree().create_timer(.5).timeout
		PassingPolicyAnimationExit = true
		
func resetPolicy():
	$PassingPolicies.position.y = 1000
	PassingPolicyAnimationEnter = true
	$PassingPolicies/Paper/Stamp.visible = false
	SignalBus.emit_signal("newPolicy")

	if !(PoliciesReviewed >= MAX_POLICIES_TO_REVIEW):
		print("reset")
		$PassingPolicies.position.y = 1500
		PassingPolicyAnimationEnter = true
		$PassingPolicies/Paper/Stamp.visible = false
		
func moveOnToNextFiscalYear():
	await get_tree().create_timer(1).timeout
	transition()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	HiddenCursorEnabled = false
	$"HiddenCursor".visible = false
	isApproving = false
	isDenying = false
	SignalBus.emit_signal("fiscalYearEnd", CompiledPassedBills)
func _process(delta):
	if HiddenCursorEnabled == true:
		$HiddenCursor.position = get_viewport().get_mouse_position()

	if PassingPolicyAnimationExit == true:
		$PassingPolicies.position.y -= 10
		if $PassingPolicies.position.y <= -1000:
			resetPolicy()
			PassingPolicyAnimationExit = false
	if PoliciesReviewed >= MAX_POLICIES_TO_REVIEW and isFinishingUpFiscalYear == false:
		isFinishingUpFiscalYear = true
		moveOnToNextFiscalYear()

	if PassingPolicyAnimationEnter == true and isFinishingUpFiscalYear == false:
		$PassingPolicies.position.y -= 10
		if $PassingPolicies.position.y <= 324:
			$PassingPolicies.position.y = 324
			PassingPolicyAnimationEnter = false
			$PassingPolicies/Paper.disabled = false
