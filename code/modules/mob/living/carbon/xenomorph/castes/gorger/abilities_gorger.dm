/datum/action/xeno_action/activable/psydrain/free
	plasma_cost = 0

// ***************************************
// *********** Drain blood
// ***************************************
/datum/action/xeno_action/activable/drain
	name = "Drain"
	action_icon_state = "drain"
	desc = "Hold a marine for some time and drain their blood, while healing. You can't attack during this time and can be shot by the marine. When used on a dead human, you heal, or gain overheal, gradually and don't gain blood."
	use_state_flags = XACT_KEYBIND_USE_ABILITY
	cooldown_timer = 15 SECONDS
	plasma_cost = 0
	target_flags = XABB_MOB_TARGET
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_DRAIN,
	)

/datum/action/xeno_action/activable/drain/can_use_ability(atom/target, silent = FALSE, override_flags)
	. = ..()
	if(!ishuman(target) || issynth(target))
		if(!silent)
			to_chat(owner, span_xenowarning("We can't drain this!"))
		return FALSE

	var/mob/living/carbon/xenomorph/owner_xeno = owner
	var/mob/living/carbon/human/target_human = target
	if(!owner_xeno.Adjacent(target_human))
		if(!silent)
			to_chat(owner_xeno, span_notice("We need to be next to our meal."))
		return FALSE

	if(target_human.stat == DEAD)
		if(owner_xeno.do_actions)
			return FALSE
		return TRUE

	if(!.)
		return

	if(owner_xeno.plasma_stored >= owner_xeno.xeno_caste.plasma_max)
		if(!silent)
			to_chat(owner_xeno, span_xenowarning("No need, we feel sated for now..."))
		return FALSE

#define DO_DRAIN_ACTION(owner_xeno, target_human) \
	owner_xeno.do_attack_animation(target_human, ATTACK_EFFECT_REDSTAB);\
	owner_xeno.visible_message(target_human, span_danger("[owner_xeno] stabs its tail into [target_human]!"));\
	playsound(target_human, "alien_claw_flesh", 25, TRUE);\
	target_human.emote("scream");\
	target_human.apply_damage(damage = 4, damagetype = BRUTE, def_zone = BODY_ZONE_HEAD, blocked = 0, sharp = TRUE, edge = FALSE, updating_health = TRUE);\
\
	var/drain_healing = GORGER_DRAIN_HEAL;\
	HEAL_XENO_DAMAGE(owner_xeno, drain_healing, TRUE);\
	adjustOverheal(owner_xeno, drain_healing);\
	owner_xeno.gain_plasma(owner_xeno.xeno_caste.drain_plasma_gain)

/datum/action/xeno_action/activable/drain/use_ability(mob/living/carbon/human/target_human)
	var/mob/living/carbon/xenomorph/owner_xeno = owner
	if(target_human.stat == DEAD)
		var/overheal_gain = 0
		while((owner_xeno.health < owner_xeno.maxHealth || owner_xeno.overheal < owner_xeno.xeno_caste.overheal_max) &&do_after(owner_xeno, 2 SECONDS, TRUE, target_human, BUSY_ICON_HOSTILE))
			overheal_gain = owner_xeno.heal_wounds(2.2)
			adjustOverheal(owner_xeno, overheal_gain)
			owner_xeno.adjust_sunder(-2.5)
		to_chat(owner_xeno, span_notice("We feel fully restored."))
		return
	owner_xeno.face_atom(target_human)
	owner_xeno.emote("roar")
	ADD_TRAIT(owner_xeno, TRAIT_HANDS_BLOCKED, src)
	for(var/i = 0; i < GORGER_DRAIN_INSTANCES; i++)
		target_human.Immobilize(GORGER_DRAIN_DELAY)
		if(!do_after(owner_xeno, GORGER_DRAIN_DELAY, FALSE, target_human, ignore_turf_checks = FALSE))
			break
		DO_DRAIN_ACTION(owner_xeno, target_human)

	REMOVE_TRAIT(owner_xeno, TRAIT_HANDS_BLOCKED, src)
	target_human.blur_eyes(1)
	add_cooldown()

#undef DO_DRAIN_ACTION

/datum/action/xeno_action/activable/drain/ai_should_use(atom/target)
	return can_use_ability(target, TRUE)

// ***************************************
// *********** Transfusion
// ***************************************
/datum/action/xeno_action/activable/transfusion
	name = "Transfusion"
	action_icon_state = "transfusion"
	desc = "Restores some of the health of another xenomorph, or overheals, at the cost of blood."
	//When used on self, drains blood continuosly, slows you down and reduces damage taken, while restoring health over time.
	cooldown_timer = 2 SECONDS
	plasma_cost = 20
	target_flags = XABB_MOB_TARGET
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_TRANSFUSION,
	)

	///Used to keep track of the target's previous health for extra_health_check()
	var/target_health

/datum/action/xeno_action/activable/transfusion/can_use_ability(atom/target, silent = FALSE, override_flags) //it is set up to only return true on specific xeno or human targets
	. = ..()
	if(!.)
		return

	if(!isxeno(target))
		if(!silent)
			to_chat(owner, span_notice("We can only restore familiar biological lifeforms."))
		return FALSE

	var/mob/living/carbon/xenomorph/target_xeno = target

	if(owner.do_actions)
		return FALSE
	if(!line_of_sight(owner, target_xeno, 2) || get_dist(owner, target_xeno) > 2)
		if(!silent)
			to_chat(owner, span_notice("It is beyond our reach, we must be close and our way must be clear."))
		return FALSE
	if(target_xeno.stat == DEAD)
		if(!silent)
			to_chat(owner, span_notice("We can only help living sisters."))
		return FALSE
	target_health = target_xeno.health
	if(!do_mob(owner, target_xeno, 1 SECONDS, BUSY_ICON_FRIENDLY, BUSY_ICON_MEDICAL, ignore_flags = IGNORE_TARGET_LOC_CHANGE, extra_checks = CALLBACK(src, PROC_REF(extra_health_check), target_xeno)))
		return FALSE
	return TRUE

///An extra check for the do_mob in can_use_ability. If the target isn't immobile and has lost health, the ability is cancelled. The ability is also cancelled if the target is knocked into crit DURING the do_mob.
/datum/action/xeno_action/activable/transfusion/proc/extra_health_check(mob/living/target)
	if((target.health < target_health && !HAS_TRAIT(target, TRAIT_IMMOBILE)) || (target.InCritical() && target_health > target.get_crit_threshold()))
		return FALSE
	target_health = target.health
	return TRUE

/datum/action/xeno_action/activable/transfusion/use_ability(atom/target)
	var/mob/living/carbon/xenomorph/owner_xeno = owner
	var/mob/living/carbon/xenomorph/target_xeno = target
	var/heal_amount = target_xeno.maxHealth * GORGER_TRANSFUSION_HEAL
	HEAL_XENO_DAMAGE(target_xeno, heal_amount, FALSE)
	adjustOverheal(target_xeno, heal_amount)
	if(target_xeno.overheal)
		target_xeno.balloon_alert(owner_xeno, "Overheal: [target_xeno.overheal]/[target_xeno.xeno_caste.overheal_max]")
	add_cooldown()
	succeed_activate()

/datum/action/xeno_action/activable/transfusion/ai_should_use(atom/target)
	// no healing non-xeno
	if(!isxeno(target))
		return FALSE
	var/mob/living/carbon/xenomorph/target_xeno = target
	if(target_xeno.get_xeno_hivenumber() != owner.get_xeno_hivenumber())
		return FALSE
	// no overhealing
	if(target_xeno.health > target_xeno.maxHealth * (1 - GORGER_TRANSFUSION_HEAL))
		return FALSE
	return can_use_ability(target, TRUE)

// ***************************************
// *********** Rejuvenate
// ***************************************
#define REJUVENATE_MISCLICK_CD "rejuvenate_misclick"
/datum/action/xeno_action/activable/rejuvenate
	name = "Rejuvenate"
	action_icon_state = "rejuvenation"
	desc = "Drains blood continuosly, slows you down and reduces damage taken, while restoring some health over time. Cancel by activating again."
	cooldown_timer = 4 SECONDS
	plasma_cost = GORGER_REJUVENATE_COST
	target_flags = XABB_MOB_TARGET
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_REJUVENATE,
	)
	keybind_flags = XACT_KEYBIND_USE_ABILITY
	use_state_flags = XACT_USE_STAGGERED

/datum/action/xeno_action/activable/rejuvenate/can_use_ability(atom/A, silent, override_flags)
	. = ..()
	if(!.)
		return
	if(TIMER_COOLDOWN_CHECK(owner, REJUVENATE_MISCLICK_CD))
		return FALSE

/datum/action/xeno_action/activable/rejuvenate/use_ability(atom/A)
	. = ..()
	var/mob/living/carbon/xenomorph/owner_xeno = owner
	if(owner_xeno.has_status_effect(STATUS_EFFECT_XENO_REJUVENATE))
		owner_xeno.remove_status_effect(STATUS_EFFECT_XENO_REJUVENATE)
		add_cooldown()
		return
	owner_xeno.apply_status_effect(STATUS_EFFECT_XENO_REJUVENATE, GORGER_REJUVENATE_DURATION, owner_xeno.maxHealth * GORGER_REJUVENATE_THRESHOLD)
	to_chat(owner_xeno, span_notice("We tap into our reserves for nourishment, our carapace thickening."))
	succeed_activate()
	TIMER_COOLDOWN_START(owner_xeno, REJUVENATE_MISCLICK_CD, 1 SECONDS)

/datum/action/xeno_action/activable/rejuvenate/ai_should_use(atom/target)
	return FALSE

#undef REJUVENATE_MISCLICK_CD

// ***************************************
// *********** Psychic Link
// ***************************************
/datum/action/xeno_action/activable/psychic_link
	name = "Psychic Link"
	action_icon_state = "psychic_link"
	desc = "Link to a xenomorph and take some damage in their place. Unrest to cancel."
	cooldown_timer = 50 SECONDS
	plasma_cost = 0
	target_flags = XABB_MOB_TARGET
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_PSYCHIC_LINK,
	)
	///Timer for activating the link
	var/apply_psychic_link_timer
	///Overlay applied on the target xeno while linking
	var/datum/progressicon/target_overlay

/datum/action/xeno_action/activable/psychic_link/can_use_ability(atom/target, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return
	if(apply_psychic_link_timer)
		if(!silent)
			owner.balloon_alert(owner, "cancelled")
		link_cleanup()
		return FALSE
	if(owner.do_actions)
		return FALSE
	if(!isxeno(target))
		if(!silent)
			to_chat(owner, span_notice("We can only link to familiar biological lifeforms."))
		return FALSE
	var/mob/living/carbon/xenomorph/owner_xeno = owner
	if(owner_xeno.health <= owner_xeno.maxHealth * GORGER_PSYCHIC_LINK_MIN_HEALTH)
		if(!silent)
			to_chat(owner, span_notice("You are too hurt to link."))
		return FALSE
	if(!line_of_sight(owner, target, GORGER_PSYCHIC_LINK_RANGE))
		if(!silent)
			to_chat(owner, span_notice("It is beyond our reach, we must be close and our way must be clear."))
		return FALSE
	if(HAS_TRAIT(owner, TRAIT_PSY_LINKED))
		if(!silent)
			to_chat(owner, span_notice("You are already linked to a xenomorph."))
		return FALSE
	if(HAS_TRAIT(target, TRAIT_PSY_LINKED))
		if(!silent)
			to_chat(owner, span_notice("[target] is already linked to a xenomorph."))
		return FALSE
	return TRUE

/datum/action/xeno_action/activable/psychic_link/use_ability(atom/target)
	apply_psychic_link_timer = addtimer(CALLBACK(src, PROC_REF(apply_psychic_link), target), GORGER_PSYCHIC_LINK_CHANNEL, TIMER_UNIQUE|TIMER_STOPPABLE)
	target_overlay = new (target, BUSY_ICON_MEDICAL)
	owner.balloon_alert(owner, "linking...")

///Activates the link
/datum/action/xeno_action/activable/psychic_link/proc/apply_psychic_link(atom/target)
	link_cleanup()
	if(HAS_TRAIT(owner, TRAIT_PSY_LINKED) || HAS_TRAIT(target, TRAIT_PSY_LINKED))
		return fail_activate()

	var/mob/living/carbon/xenomorph/owner_xeno = owner
	var/psychic_link = owner_xeno.apply_status_effect(STATUS_EFFECT_XENO_PSYCHIC_LINK, -1, target, GORGER_PSYCHIC_LINK_RANGE, GORGER_PSYCHIC_LINK_REDIRECT, owner_xeno.maxHealth * GORGER_PSYCHIC_LINK_MIN_HEALTH, TRUE)
	RegisterSignal(psychic_link, COMSIG_XENO_PSYCHIC_LINK_REMOVED, PROC_REF(status_removed))
	target.balloon_alert(owner_xeno, "link successul")
	owner_xeno.balloon_alert(target, "linked to [owner_xeno]")
	if(!owner_xeno.resting)
		owner_xeno.set_resting(TRUE, TRUE)
	RegisterSignal(owner_xeno, COMSIG_XENOMORPH_UNREST, PROC_REF(cancel_psychic_link))
	succeed_activate()

///Removes the status effect on unrest
/datum/action/xeno_action/activable/psychic_link/proc/cancel_psychic_link(datum/source)
	SIGNAL_HANDLER
	var/mob/living/carbon/xenomorph/owner_xeno = owner
	owner_xeno.remove_status_effect(STATUS_EFFECT_XENO_PSYCHIC_LINK)

///Cancels the status effect
/datum/action/xeno_action/activable/psychic_link/proc/status_removed(datum/source)
	SIGNAL_HANDLER
	UnregisterSignal(source, COMSIG_XENO_PSYCHIC_LINK_REMOVED)
	UnregisterSignal(owner, COMSIG_XENOMORPH_UNREST)
	add_cooldown()

///Clears up things used for the linking
/datum/action/xeno_action/activable/psychic_link/proc/link_cleanup()
	QDEL_NULL(target_overlay)
	deltimer(apply_psychic_link_timer)
	apply_psychic_link_timer = null


/datum/action/xeno_action/activable/psychic_link/ai_should_use(atom/target)
	return FALSE

// ***************************************
// *********** Carnage
// ***************************************
/datum/action/xeno_action/activable/carnage
	name = "Carnage"
	action_icon_state = "carnage"
	desc = "Enter a state of thirst, gaining movement and healing on your next attack, scaling with missing blood. If your blood is below a certain %, you also knockdown your victim and drain some blood, during which you can't move."
	cooldown_timer = 15 SECONDS
	plasma_cost = 0
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_CARNAGE,
	)
	keybind_flags = XACT_KEYBIND_USE_ABILITY

/datum/action/xeno_action/activable/carnage/use_ability(atom/A)
	. = ..()
	var/mob/living/carbon/xenomorph/owner_xeno = owner
	owner_xeno.apply_status_effect(STATUS_EFFECT_XENO_CARNAGE, 10 SECONDS, owner_xeno.xeno_caste.carnage_plasma_gain, owner_xeno.maxHealth * GORGER_CARNAGE_HEAL, GORGER_CARNAGE_MOVEMENT)
	add_cooldown()

/datum/action/xeno_action/activable/carnage/ai_should_use(atom/target)
	if(!iscarbon(target))
		return FALSE
	var/mob/living/carbon/xenomorph/owner_xeno = owner
	if(owner_xeno.plasma_stored > owner_xeno.xeno_caste.plasma_max * 0.8 && owner_xeno.health > owner_xeno.maxHealth * 0.9)
		return FALSE
	// nothing gained by slashing allies
	if(target.get_xeno_hivenumber() == owner_xeno.get_xeno_hivenumber())
		return FALSE
	return can_use_ability(target, TRUE)

// ***************************************
// *********** Feast
// ***************************************
#define FEAST_MISCLICK_CD "feast_misclick"
/datum/action/xeno_action/activable/feast
	name = "Feast"
	action_icon_state = "feast"
	desc = "Enter a state of rejuvenation. During this time you use a small amount of blood and heal. You can cancel this early."
	cooldown_timer = 180 SECONDS
	plasma_cost = 0
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_FEAST,
	)
	keybind_flags = XACT_KEYBIND_USE_ABILITY
	use_state_flags = XACT_USE_STAGGERED

/datum/action/xeno_action/activable/feast/can_use_ability(atom/target, silent, override_flags)
	. = ..()
	var/mob/living/carbon/xenomorph/owner_xeno = owner
	if(TIMER_COOLDOWN_CHECK(owner_xeno, FEAST_MISCLICK_CD))
		return FALSE
	if(owner_xeno.has_status_effect(STATUS_EFFECT_XENO_FEAST))
		return TRUE
	if(owner_xeno.plasma_stored < owner_xeno.xeno_caste.feast_plasma_drain * 10)
		if(!silent)
			to_chat(owner_xeno, span_notice("Not enough to begin a feast. We need [owner_xeno.xeno_caste.feast_plasma_drain * 10] blood."))
		return FALSE

/datum/action/xeno_action/activable/feast/use_ability(atom/A)
	. = ..()
	var/mob/living/carbon/xenomorph/owner_xeno = owner
	if(owner_xeno.has_status_effect(STATUS_EFFECT_XENO_FEAST))
		to_chat(owner_xeno, span_notice("We decide to end our feast early..."))
		owner_xeno.remove_status_effect(STATUS_EFFECT_XENO_FEAST)
		return

	owner_xeno.emote("roar")
	owner_xeno.visible_message(owner_xeno, span_notice("[owner_xeno] begins to overflow with vitality!"))
	owner_xeno.apply_status_effect(STATUS_EFFECT_XENO_FEAST, GORGER_FEAST_DURATION, owner_xeno.xeno_caste.feast_plasma_drain)
	TIMER_COOLDOWN_START(src, FEAST_MISCLICK_CD, 2 SECONDS)
	add_cooldown()

/datum/action/xeno_action/activable/feast/ai_should_use(atom/target)
	var/mob/living/carbon/xenomorph/owner_xeno = owner
	// cancel the buff when at full health to conserve plasma, otherwise don't cancel
	if(owner_xeno.has_status_effect(STATUS_EFFECT_XENO_FEAST))
		return owner_xeno.health == owner_xeno.maxHealth
	// small damage has more efficient alternatives to be healed with
	if(owner_xeno.health > owner_xeno.maxHealth * 0.7)
		return FALSE
	// should use the ability when there is enough resource for the buff to tick a moderate amount of times
	if(owner_xeno.plasma_stored / owner_xeno.xeno_caste.feast_plasma_drain < 7)
		return FALSE
	return can_use_ability(target, TRUE)

#undef FEAST_MISCLICK_CD
