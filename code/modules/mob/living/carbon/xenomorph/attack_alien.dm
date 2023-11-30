/*
* Important note about attack_alien : In our code, attack_ procs are received by src, not dealt by src
* For example, attack_alien defined for humans means what will happen to THEM when attacked by an alien
* In that case, the first argument is always the attacker. For attack_alien, it should always be Xenomorph sub-types
*/

//#define DEBUG_ATTACK_ALIEN

/mob/living/proc/attack_alien_grab(mob/living/carbon/xenomorph/X)
	if(X == src || anchored || buckled || X.buckled)
		return FALSE

	if(!Adjacent(X))
		return FALSE

	X.start_pulling(src)
	return TRUE

/mob/living/carbon/human/attack_alien_grab(mob/living/carbon/xenomorph/X)
	if(check_shields(COMBAT_TOUCH_ATTACK, X.xeno_caste.melee_damage, "melee"))
		return ..()
	X.visible_message(span_danger("\The [X]'s grab is blocked by [src]'s shield!"),
		span_danger("Our grab was blocked by [src]'s shield!"), null, 5)
	playsound(loc, 'sound/weapons/alien_claw_block.ogg', 25, TRUE) //Feedback
	return FALSE


/mob/living/proc/attack_alien_disarm(mob/living/carbon/xenomorph/X, dam_bonus)

	SEND_SIGNAL(src, COMSIG_LIVING_MELEE_ALIEN_DISARMED, X)
	X.do_attack_animation(src, ATTACK_EFFECT_DISARM2)
	playsound(loc, 'sound/weapons/alien_knockdown.ogg', 25, TRUE)
	X.visible_message(span_warning("\The [X] shoves [src]!"),
	span_warning("We shove [src]!"), null, 5)
	return TRUE

/mob/living/carbon/human/attack_alien_disarm(mob/living/carbon/xenomorph/X, dam_bonus)
	var/randn = rand(1, 100)
	var/stamina_loss = getStaminaLoss()
	var/disarmdamage = X.xeno_caste.melee_damage * X.xeno_melee_damage_modifier + 20
	var/damage_to_deal = clamp(disarmdamage, 0, maxHealth - stamina_loss)
	var/sound = 'sound/weapons/alien_knockdown.ogg'

	if ishumanbasic(src)
		if(IsParalyzed())
			X.do_attack_animation(src, ATTACK_EFFECT_DISARM2)
			X.visible_message(null, "<span class='info'>We could not do much to [src], they are already down.</span>", null)
			sound = 'sound/weapons/punchmiss.ogg'
		else
			X.do_attack_animation(src, ATTACK_EFFECT_DISARM2)
			if(pulling)
				X.visible_message("<span class='danger'>[X] has broken [src]'s grip on [pulling]!</span>",
				"<span class='danger'>We break [src]'s grip on [pulling]!</span>", null, 5)
				sound = 'sound/weapons/thudswoosh.ogg'
				stop_pulling()
			else if(prob(60) && drop_held_item())
				X.visible_message("<span class='danger'>[X] has disarmed [src]!</span>",
				"<span class='danger'>We disarm [src]!</span>", null, 5)
				sound = 'sound/weapons/thudswoosh.ogg'
				return
			apply_damage(damage_to_deal, STAMINA)
			X.visible_message("<span class='danger'>[X] shoves and presses [src] down!</span>",
			"<span class='danger'>We shove and press [src] down!</span>", null, 5)
			Stagger(2 SECONDS)
			if(stamina_loss >= maxHealth)
				if(!IsParalyzed())
					apply_damage(90, STAMINA)
					visible_message(null, "<span class='danger'>You are too weakened to keep resisting [X], you slump to the ground!</span>")
					X.visible_message("<span class='danger'>[X] slams [src] to the ground!</span>",
					"<span class='danger'>We slam [src] to the ground!</span>", null, 5)
					Paralyze(20 SECONDS)
	else if(!ishumanbasic(src))
		if(randn <= 40)
			if(!IsParalyzed())
				X.do_attack_animation(src, ATTACK_EFFECT_DISARM2)
				X.visible_message("<span class='danger'>[X] shoves and presses [src] down!</span>",
				"<span class='danger'>We shove and press [src] down!</span>", null, 5)
				visible_message(null, "<span class='danger'>You are too weakened to keep resisting [X], you slump to the ground!</span>")
				X.visible_message("<span class='danger'>[X] slams [src] to the ground!</span>",
				"<span class='danger'>We slam [src] to the ground!</span>", null, 5)
				Paralyze(5 SECONDS)
			else if(IsParalyzed())
				X.do_attack_animation(src, ATTACK_EFFECT_DISARM2)
				X.visible_message(null, "<span class='info'>We could not do much to [src], they are already down.</span>", null)
				sound = 'sound/weapons/punchmiss.ogg'
		else if(randn > 40)
			X.do_attack_animation(src, ATTACK_EFFECT_DISARM2)
			sound = 'sound/weapons/punchmiss.ogg'
			X.visible_message("<span class='danger'>[X] attempted to disarm [src] but they resist!</span>",
			"<span class='danger'>We attempt to disarm [src] but it resisted!</span>", null, 5)
			Stagger(2 SECONDS)


	log_combat(X, src, "disarmed")
	playsound(loc, sound, 25, TRUE, 7)
//	else;
//		playsound(loc, 'sound/weapons/punchmiss.ogg', 25, TRUE, 7)
//		X.visible_message("<span class='danger'>[X] attempted to disarm [src]!</span>",
//		"<span class='danger'>We attempt to disarm [src]!</span>", null, 5)
//		return


/mob/living/proc/can_xeno_slash(mob/living/carbon/xenomorph/X)
	return !(status_flags & INCORPOREAL)

/mob/living/proc/get_xeno_slash_zone(mob/living/carbon/xenomorph/X, set_location = FALSE, random_location = FALSE, no_head = FALSE)
	return

/mob/living/carbon/get_xeno_slash_zone(mob/living/carbon/xenomorph/X, set_location = FALSE, random_location = FALSE, no_head = FALSE, ignore_destroyed = TRUE)
	var/datum/limb/affecting
	if(set_location)
		affecting = get_limb(set_location)
	else if(SEND_SIGNAL(X, COMSIG_XENOMORPH_ZONE_SELECT) & COMSIG_ACCURATE_ZONE)
		affecting = get_limb(X.zone_selected)
	else
		affecting = get_limb(ran_zone(X.zone_selected, 70))
	if(!affecting || (random_location && !set_location) || (ignore_destroyed && !affecting.is_usable())) //No organ or it's destroyed, just get a random one
		affecting = get_limb(ran_zone(null, 0))
	if(!affecting || (no_head && affecting == get_limb("head")) || (ignore_destroyed && !affecting.is_usable()))
		affecting = get_limb("chest")
	return affecting

/mob/living/proc/attack_alien_harm(mob/living/carbon/xenomorph/X, dam_bonus, set_location = FALSE, random_location = FALSE, no_head = FALSE, no_crit = FALSE, force_intent = null)

	if(!can_xeno_slash(X))
		return FALSE

	var/damage = X.xeno_caste.melee_damage * X.xeno_melee_damage_modifier
	if(!damage)
		return FALSE

	var/datum/limb/affecting = get_xeno_slash_zone(X, set_location, random_location, no_head)
	var/armor_block = 0

	var/list/damage_mod = list()
	var/list/armor_mod = list()

	var/signal_return = SEND_SIGNAL(X, COMSIG_XENOMORPH_ATTACK_LIVING, src, damage, damage_mod, armor_mod)

	// if we don't get any non-stacking bonuses dont apply dam_bonus
	if(!(signal_return & COMSIG_XENOMORPH_BONUS_APPLIED))
		damage_mod += dam_bonus

	if(!(signal_return & COMPONENT_BYPASS_ARMOR))
		armor_block = MELEE

	for(var/i in damage_mod)
		damage += i

	var/armor_pen
	for(var/i in armor_mod)
		armor_pen += i

	if(!(signal_return & COMPONENT_BYPASS_SHIELDS))
		damage = check_shields(COMBAT_MELEE_ATTACK, damage, "melee")

	if(!damage)
		X.visible_message(span_danger("\The [X]'s slash is blocked by [src]'s shield!"),
			span_danger("Our slash is blocked by [src]'s shield!"), null, COMBAT_MESSAGE_RANGE)
		return FALSE

	var/attack_sound = "alien_claw_flesh"
	var/attack_message1 = span_danger("\The [X] slashes [src]!")
	var/attack_message2 = span_danger("We slash [src]!")
	var/log = "slashed"

	//Somehow we will deal no damage on this attack
	if(!damage)
		playsound(X.loc, 'sound/weapons/alien_claw_swipe.ogg', 25, 1)
		X.do_attack_animation(src)
		X.visible_message(span_danger("\The [X] lunges at [src]!"), \
		span_danger("We lunge at [src]!"), null, 5)
		return FALSE

	X.do_attack_animation(src, ATTACK_EFFECT_REDSLASH)

	//The normal attack proceeds
	playsound(loc, attack_sound, 25, 1)
	X.visible_message("[attack_message1]", \
	"[attack_message2]")

	if(status_flags & XENO_HOST && stat != DEAD)
		log_combat(X, src, log, addition = "while they were infected")
	else //Normal xenomorph friendship with benefits
		log_combat(X, src, log)

	record_melee_damage(X, damage)
	var/damage_done = apply_damage(damage, BRUTE, affecting, armor_block, TRUE, TRUE, TRUE, armor_pen) //This should slicey dicey
	SEND_SIGNAL(X, COMSIG_XENOMORPH_POSTATTACK_LIVING, src, damage_done, damage_mod)

	return TRUE

/mob/living/silicon/attack_alien_disarm(mob/living/carbon/xenomorph/X, dam_bonus, set_location = FALSE, random_location = FALSE, no_head = FALSE, no_crit = FALSE, force_intent = null)

	if(stat == DEAD) //A bit of visual flavor for attacking Cyborgs. Sparks!
		return FALSE
	. = ..()
	if(!.)
		return
	var/datum/effect_system/spark_spread/spark_system
	spark_system = new /datum/effect_system/spark_spread()
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)
	spark_system.start(src)
	playsound(loc, "alien_claw_metal", 25, TRUE)

/mob/living/silicon/attack_alien_harm(mob/living/carbon/xenomorph/X, dam_bonus, set_location = FALSE, random_location = FALSE, no_head = FALSE, no_crit = FALSE, force_intent = null)

	if(stat == DEAD) //A bit of visual flavor for attacking Cyborgs. Sparks!
		return FALSE
	. = ..()
	if(!.)
		return
	var/datum/effect_system/spark_spread/spark_system
	spark_system = new /datum/effect_system/spark_spread()
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)
	spark_system.start(src)
	playsound(loc, "alien_claw_metal", 25, TRUE)


/mob/living/carbon/xenomorph/attack_alien_harm(mob/living/carbon/xenomorph/X, dam_bonus, set_location = FALSE, random_location = FALSE, no_head = FALSE, no_crit = FALSE, force_intent = null)
	if(issamexenohive(X))
		X.visible_message(span_warning("\The [X] nibbles [src]."),
		span_warning("We nibble [src]."), null, 5)
		return FALSE
	return ..()


/mob/living/carbon/human/attack_alien_harm(mob/living/carbon/xenomorph/X, dam_bonus, set_location = FALSE, random_location = FALSE, no_head = FALSE, no_crit = FALSE, force_intent = null)

	if(stat == DEAD)
		if(istype(wear_ear, /obj/item/radio/headset/mainship))
			var/obj/item/radio/headset/mainship/cam_headset = wear_ear
			if(cam_headset.camera.status)
				cam_headset.camera.toggle_cam(null, FALSE)
				playsound(loc, "alien_claw_metal", 25, 1)
				X.do_attack_animation(src, ATTACK_EFFECT_CLAW)
				to_chat(X, span_warning("We disable the creatures hivemind sight apparatus."))
				return FALSE

		if(length(static_light_sources) || length(hybrid_light_sources) || length(affected_movable_lights))
			playsound(loc, "alien_claw_metal", 25, 1)
			X.do_attack_animation(src, ATTACK_EFFECT_CLAW)
			disable_lights(sparks = TRUE)
			to_chat(X, span_warning("We disable whatever annoying lights the dead creature possesses."))
		else
			to_chat(X, span_warning("[src] is dead, why would we want to touch it?"))
		return FALSE

	SEND_SIGNAL(X, COMSIG_XENOMORPH_ATTACK_HUMAN, src)

	. = ..()
	if(!.)
		return FALSE

//Every other type of nonhuman mob //MARKER OVERRIDE
/mob/living/attack_alien(mob/living/carbon/xenomorph/X, damage_amount = X.xeno_caste.melee_damage, damage_type = BRUTE, damage_flag = "", effects = TRUE, armor_penetration = 0, isrightclick = FALSE)
	if(X.status_flags & INCORPOREAL)
		return FALSE

	if (X.fortify || X.behemoth_charging)
		return FALSE

	SEND_SIGNAL(X, COMSIG_XENOMORPH_ATTACK_LIVING, src, damage_amount, X.xeno_caste.melee_damage * X.xeno_melee_damage_modifier)

	switch(X.a_intent)
		if(INTENT_HELP)
			if(on_fire)
				fire_stacks = max(fire_stacks - 1, 0)
				playsound(loc, 'sound/weapons/thudswoosh.ogg', 25, 1, 7)
				X.visible_message(span_danger("[X] tries to put out the fire on [src]!"), \
					span_warning("We try to put out the fire on [src]!"), null, 5)
				if(fire_stacks <= 0)
					X.visible_message(span_danger("[X] has successfully extinguished the fire on [src]!"), \
						span_notice("We extinguished the fire on [src]."), null, 5)
					ExtinguishMob()
				return TRUE
			X.visible_message(span_notice("\The [X] caresses \the [src] with its scythe-like arm."), \
			span_notice("We caress \the [src] with our scythe-like arm."), null, 5)

		if(INTENT_GRAB)
			return attack_alien_grab(X)

		if(INTENT_HARM)
			return attack_alien_harm(X)

		if(INTENT_DISARM)
			return attack_alien_disarm(X)
	return FALSE

/mob/living/attack_larva(mob/living/carbon/xenomorph/larva/M)
	M.visible_message(span_danger("[M] nudges its head against [src]."), \
	span_danger("We nudge our head against [src]."), null, 5)
