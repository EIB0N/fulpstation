/datum/action/bloodsucker/cloak
	name = "Cloak of Darkness"
	desc = "Blend into the shadows and become invisible to the untrained and Artificial eye. Slows you down and you cannot dissapear while mortals watch you."
	button_icon_state = "power_cloak"
	bloodcost = 5
	constant_bloodcost = 0.2
	conscious_constant_bloodcost = TRUE
	cooldown = 50
	bloodsucker_can_buy = TRUE
	amToggle = TRUE
	var/was_running

/// Must have nobody around to see the cloak
/datum/action/bloodsucker/cloak/CheckCanUse(display_error)
	if(!..())
		return FALSE
	for(var/mob/living/M in viewers(9, owner) - owner)
		owner.balloon_alert(owner, "you can only vanish unseen.")
		return FALSE
	return TRUE

/datum/action/bloodsucker/cloak/ActivatePower(mob/living/user = owner)
	was_running = (user.m_intent == MOVE_INTENT_RUN)
	if(was_running)
		user.toggle_move_intent()
	user.AddElement(/datum/element/digitalcamo)
	user.balloon_alert(user, "cloak turned on.")
	. = ..()

/datum/action/bloodsucker/cloak/UsePower(mob/living/user)
	// Checks that we can keep using this.
	if(!..())
		return
	animate(user, alpha = max(25, owner.alpha - min(75, 10 + 5 * level_current)), time = 1.5 SECONDS)
	// Prevents running while on Cloak of Darkness
	if(user.m_intent != MOVE_INTENT_WALK)
		owner.balloon_alert(owner, "you attempt to run, crushing yourself.")
		user.toggle_move_intent()
		user.adjustBruteLoss(rand(5,15))

/datum/action/bloodsucker/cloak/ContinueActive(mob/living/user, mob/living/target)
	if(!..())
		return FALSE
	/// Must be CONSCIOUS
	if(user.stat != CONSCIOUS)
		to_chat(owner, span_warning("Your cloak failed due to you falling unconcious!"))
		return FALSE
	return TRUE

/datum/action/bloodsucker/cloak/DeactivatePower(mob/living/user = owner, mob/living/target)
	. = ..()
	animate(user, alpha = 255, time = 1 SECONDS)
	user.RemoveElement(/datum/element/digitalcamo)
	if(was_running && user.m_intent == MOVE_INTENT_WALK)
		user.toggle_move_intent()
	user.balloon_alert(user, "cloak turned off.")
