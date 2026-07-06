/datum/component/supermatter_crystal/proc/create_consumed_anomaly(mob/living/carbon/human/consumed_human)
	var/datum/anomaly_placer/placer = new()
	var/area/new_area = placer.findValidArea()
	var/turf/new_turf = placer.findValidTurf(new_area)
	var/obj/effect/anomaly/consumed/anomaly = new(new_turf)
	anomaly.consumed = consumed_human
	consumed_human.forceMove(anomaly)
	anomaly.forceMove(new_turf)
	priority_announce("The supermatter has consumed a person, creating an anomaly at [new_area.name]. Neutralize the anomaly to retrieve their corpse.", "anomaly alert", has_important_message = TRUE)


/obj/effect/anomaly/consumed // Give better name
	name = "warping anomaly"
	icon_state = "ectoplasm" // Get sprite made
	immortal = TRUE
	var/mob/living/carbon/human/consumed
	var/atom/movable/warp_effect/warp
	flags_1 = SUPERMATTER_IGNORES_1
	COOLDOWN_DECLARE(space_distort)

/obj/effect/anomaly/consumed/Initialize(mapload, new_lifespan = 250 SECONDS, drops_core = FALSE)
	. = ..()

	warp = new(src)
	vis_contents += warp
	animate(warp, time = 1, transform = matrix().Scale(1,1))
	animate(time = 9, transform = matrix()) // Add mob head to overlays

/obj/effect/anomaly/consumed/process(seconds_per_tick)
	. = ..()
	var/datum/action/cooldown/spell/spacetime_dist/spell = new /datum/action/cooldown/spell/spacetime_dist()
	var/turf = get_turf(src)
	spell.duration = 20 SECONDS
	if(COOLDOWN_FINISHED(src, space_distort))
		spell.Activate(turf)
		COOLDOWN_START(src, space_distort, 35 SECONDS)

/obj/effect/anomaly/consumed/examine(mob/user)
	. = ..()

	if(consumed)
		. += span_info("The anomaly looks to contain [consumed.name]!")

/obj/effect/anomaly/consumed/anomalyNeutralize()
	new /obj/effect/particle_effect/fluid/smoke/bad(loc)
	if(consumed)
		consumed.apply_damage(600, BURN, spread_damage = TRUE)
		consumed.become_husk(BURN)
		consumed.forceMove(get_turf(src))
	qdel(src)
