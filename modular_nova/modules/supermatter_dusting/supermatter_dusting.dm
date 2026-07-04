/datum/component/supermatter_crystal/proc/create_consumed_anomaly(mob/living/carbon/human/consumed_human)
	var/datum/anomaly_placer/placer = new()
	var/area/new_area = placer.findValidArea()
	var/turf/new_turf = placer.findValidTurf(new_area)
	var/obj/effect/anomaly/consumed/anomaly = new(new_turf)
	anomaly.consumed = consumed_human
	consumed_human.forceMove(anomaly)
	anomaly.forceMove(new_turf)
	priority_announce("The supermatter has consumed a person, creating an anomaly at [new_area.name]. Neutralize the anomaly to retrieve their corpse.", "anomaly alert", has_important_message = TRUE)

/obj/effect/anomaly/consumed
	name = "warping anomaly"
	icon_state = "ectoplasm"
	immortal = TRUE
	var/mob/living/carbon/human/consumed
	var/atom/movable/warp_effect/warp
	var/timer = 30 SECONDS
	flags_1 = SUPERMATTER_IGNORES_1
	COOLDOWN_DECLARE(allow_neutralize)
	COOLDOWN_DECLARE(space_distort)

/obj/effect/anomaly/consumed/Initialize(mapload, new_lifespan = 250 SECONDS, drops_core = FALSE)
	. = ..()

	warp = new(src)
	vis_contents += warp
	animate(warp, time = 1, transform = matrix().Scale(1,1))
	animate(time = 9, transform = matrix())
	timer = rand(5 MINUTES, 10 MINUTES)
	COOLDOWN_START(src, allow_neutralize, timer)

/obj/effect/anomaly/consumed/process(seconds_per_tick)
	. = ..()
	var/datum/action/cooldown/spell/spacetime_dist/spell = new /datum/action/cooldown/spell/spacetime_dist()
	var/turf = get_turf(src)
	spell.duration = 20 SECONDS
	if(COOLDOWN_FINISHED(src, space_distort))
		spell.Activate(turf)
		COOLDOWN_START(src, space_distort, 1 MINUTES)

/obj/effect/anomaly/consumed/examine(mob/user)
	. = ..()

	if(consumed)
		. += span_info("The anomaly looks to contain [consumed.name]!")
	if(!COOLDOWN_FINISHED(src, allow_neutralize))
		. += span_info("The anomaly looks like it needs [DisplayTimeText(COOLDOWN_TIMELEFT(src, allow_neutralize))] to be neutralized.")

/obj/effect/anomaly/consumed/anomalyNeutralize()
	if(!COOLDOWN_FINISHED(src, allow_neutralize))
		balloon_alert_to_viewers("needs more time to stabilize!")
		return
	new /obj/effect/particle_effect/fluid/smoke/bad(loc)
	if(consumed)
		consumed.forceMove(get_turf(src))
	qdel(src)
