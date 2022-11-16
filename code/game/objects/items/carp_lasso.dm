/obj/item/mob_lasso
	name = "space lasso"
	desc = "Comes standard with every space-cowboy.\nCan be used to tame space carp."
	icon = 'icons/obj/carp_lasso.dmi'
	icon_state = "lasso"
	///Ref to timer
	var/timer
	///Ref to lasso'd carp
	var/mob/living/simple_animal/mob_target
	///Range we can lasso things at
	var/range = 8
	///Whitelist of allowed animals
	var/list/whitelist_mobs

/obj/item/mob_lasso/Initialize(mapload)
	. = ..()
	whitelist_mobs = typecacheof(list(/mob/living/simple_animal/hostile/carp, /mob/living/simple_animal/cow, /mob/living/simple_animal/hostile/retaliate/dolphin), only_root_path = TRUE)

/obj/item/mob_lasso/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	var/failed = FALSE
	if(!isliving(target))
		failed = TRUE
	if(!check_allowed(target))
		failed = TRUE
	if(iscarbon(target) || issilicon(target))
		failed = TRUE
	if(!(locate(target) in oview(range, user)))
		failed = TRUE
	if(failed)
		if(ismob(target))
			to_chat(user, "<span class='notice'>[target] seems a bit big for this...</span>")
		return
	var/mob/living/simple_animal/C = target
	if(IS_DEAD_OR_INCAP(C))
		to_chat(user, "<span class='warning'>[target] is dead.</span>")
		return
	if(user.a_intent == INTENT_HELP && C == mob_target) //if trying to tie up previous target
		to_chat(user, "<span class='notice'>You begin to untie [C]</span>")
		if(proximity_flag && do_after(user, 2 SECONDS, FALSE, target))
			user.faction |= "carpboy_[user]"
			C.faction |= "carpboy_[user]"
			C.faction |= user.faction
			C.transform = transform.Turn(0)
			C.toggle_ai(AI_ON)
			var/datum/component/tamed_command/T = C.AddComponent(/datum/component/tamed_command)
			T.add_ally(user)
			to_chat(user, "<span class='notice'>[C] nuzzles you.</span>")
			UnregisterSignal(mob_target, COMSIG_PARENT_QDELETING)
			mob_target = null
			if(timer)
				deltimer(timer)
				timer = null
			return
	else if(timer) //if trying to add new target while old target is still flipped
		to_chat(user, "<span class='warning'>You can't do that right now!</span>")
		return
	//Do lasso/beam for style points
	var/datum/beam/B = new(loc, C, time=1 SECONDS, beam_icon='icons/effects/beam.dmi', beam_icon_state="carp_lasso", btype=/obj/effect/ebeam)
	INVOKE_ASYNC(B, /datum/beam/.proc/Start)
	C.unbuckle_all_mobs()
	mob_target = C
	C.throw_at(get_turf(src), 9, 2, user, FALSE, force = 0)
	C.transform = transform.Turn(180)
	C.toggle_ai(AI_OFF)
	RegisterSignal(C, COMSIG_PARENT_QDELETING, .proc/handle_hard_del)
	to_chat(user, "<span class='notice'>You lasso [C]!</span>")
	timer = addtimer(CALLBACK(src, .proc/fail_ally), 6 SECONDS, TIMER_STOPPABLE) //after 6 seconds set the carp back

/obj/item/mob_lasso/proc/check_allowed(atom/target)
	return is_type_in_typecache(target, whitelist_mobs)

/obj/item/mob_lasso/proc/fail_ally()
	visible_message("<span class='warning'>[mob_target] breaks free!</span>")
	mob_target?.transform = transform.Turn(0)
	mob_target.toggle_ai(AI_ON)
	UnregisterSignal(mob_target, COMSIG_PARENT_QDELETING)
	mob_target = null
	timer = null

/obj/item/mob_lasso/proc/handle_hard_del()
	mob_target = null

///Primal version, allows lavaland goobers to tame goliaths
/obj/item/mob_lasso/primal
	name = "primal lasso"
	desc = "A lasso fashioned out of goliath plating that is often found in the possession of Ash Walkers.\nCan be used to tame some lavaland animals."

/obj/item/mob_lasso/primal/Initialize(mapload)
	. = ..()
	whitelist_mobs = typecacheof(list(/mob/living/simple_animal/hostile/asteroid/goliath, /mob/living/simple_animal/hostile/asteroid/goldgrub,\
		/mob/living/simple_animal/hostile/asteroid/basilisk/watcher, /mob/living/simple_animal/hostile/asteroid/gutlunch))

/obj/item/mob_lasso/drake
	name = "drake lasso"
	desc = "A lasso fashioned out of the scaly hide of an ash drake.\nCan be used to tame one, if you can get close enough."
	range = 3

/obj/item/mob_lasso/drake/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	if(!user.mind?.has_antag_datum(/datum/antagonist/ashwalker))
		to_chat(user, "<span class='warning'>You don't know how to use this!</span>")
		return
	. = ..()

/obj/item/mob_lasso/drake/Initialize(mapload)
	. = ..()
	whitelist_mobs = typecacheof(list(/mob/living/simple_animal/hostile/megafauna/dragon), only_root_path = TRUE)

/obj/item/mob_lasso/antag
	name = "bluespace lasso"
	desc = "Comes standard with every evil space-cowboy!\nCan be used to tame almost anything."
	///blacklist of disallowed mobs
	var/list/blacklist_mobs

/obj/item/mob_lasso/antag/Initialize(mapload)
	. = ..()
	blacklist_mobs = typecacheof(list(/mob/living/simple_animal/hostile/megafauna, /mob/living/simple_animal/hostile/alien, /mob/living/simple_animal/hostile/syndicate))

/obj/item/mob_lasso/antag/check_allowed(atom/target)
	return !is_type_in_typecache(target, blacklist_mobs)

/obj/item/mob_lasso/antag/debug
	name = "debug lasso"
	desc = "Comes standard with every administrator space-cowboy!\nCan be used to tame anything."

/obj/item/mob_lasso/antag/debug/Initialize(mapload)
	. = ..()
	blacklist_mobs = list()

