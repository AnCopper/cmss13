/datum/element/traitbound/thermal_cloak
	associated_trait = TRAIT_THERMAL_CLOAKED
	compatible_types = list(/mob/living)
	element_flags = ELEMENT_DETACH
	var/list/cloaked_mobs = list()
	var/list/thermal_viewers = list()

/datum/element/traitbound/thermal_cloak/Attach(datum/target)
	. = ..()
	if(. & ELEMENT_INCOMPATIBLE)
		return

	var/mob/living/cloaked_mob = target
	// A blank override keeps SEE_MOBS from drawing the mob through walls.
	var/image/cloak_image = image(loc = cloaked_mob)
	cloak_image.override = TRUE
	cloaked_mobs[cloaked_mob] = cloak_image
	if(!(cloaked_mob in thermal_viewers))
		RegisterSignal(cloaked_mob, COMSIG_MOVABLE_MOVED, PROC_REF(on_mob_moved))

	if(length(cloaked_mobs) == 1)
		START_PROCESSING(SSdcs, src)

	refresh_viewers()
	update_viewers()

/datum/element/traitbound/thermal_cloak/Detach(datum/target)
	var/mob/living/cloaked_mob = target
	var/image/cloak_image = cloaked_mobs[cloaked_mob]
	for(var/client/viewer_client as anything in GLOB.clients)
		viewer_client.images -= cloak_image
	qdel(cloak_image)

	cloaked_mobs -= cloaked_mob
	if(!(cloaked_mob in thermal_viewers))
		UnregisterSignal(cloaked_mob, COMSIG_MOVABLE_MOVED)

	if(!length(cloaked_mobs))
		STOP_PROCESSING(SSdcs, src)
		clear_viewers()
	else
		update_viewers()

	return ..()

/datum/element/traitbound/thermal_cloak/process()
	refresh_viewers()
	update_viewers()

/datum/element/traitbound/thermal_cloak/proc/refresh_viewers()
	var/list/current_viewers = list()
	for(var/mob/living/thermal_viewer as anything in GLOB.living_player_list)
		if(!thermal_viewer.client || !(thermal_viewer.sight & SEE_MOBS))
			continue
		current_viewers[thermal_viewer] = thermal_viewer.client

	var/list/old_viewers = thermal_viewers.Copy()
	for(var/mob/living/thermal_viewer as anything in old_viewers)
		if(current_viewers[thermal_viewer] == thermal_viewers[thermal_viewer])
			continue
		remove_viewer(thermal_viewer)

	for(var/mob/living/thermal_viewer as anything in current_viewers)
		if(thermal_viewers[thermal_viewer] == current_viewers[thermal_viewer])
			continue
		add_viewer(thermal_viewer, current_viewers[thermal_viewer])

/datum/element/traitbound/thermal_cloak/proc/add_viewer(mob/living/thermal_viewer, client/viewer_client)
	thermal_viewers[thermal_viewer] = viewer_client
	if(!(thermal_viewer in cloaked_mobs))
		RegisterSignal(thermal_viewer, COMSIG_MOVABLE_MOVED, PROC_REF(on_mob_moved))

/datum/element/traitbound/thermal_cloak/proc/remove_viewer(mob/living/thermal_viewer)
	var/client/viewer_client = thermal_viewers[thermal_viewer]
	thermal_viewers -= thermal_viewer
	if(viewer_client)
		for(var/mob/living/cloaked_mob as anything in cloaked_mobs)
			viewer_client.images -= cloaked_mobs[cloaked_mob]
	if(!(thermal_viewer in cloaked_mobs))
		UnregisterSignal(thermal_viewer, COMSIG_MOVABLE_MOVED)

/datum/element/traitbound/thermal_cloak/proc/clear_viewers()
	var/list/old_viewers = thermal_viewers.Copy()
	for(var/mob/living/thermal_viewer as anything in old_viewers)
		remove_viewer(thermal_viewer)

/datum/element/traitbound/thermal_cloak/proc/update_viewers()
	for(var/mob/living/thermal_viewer as anything in thermal_viewers)
		update_viewer(thermal_viewer)

/datum/element/traitbound/thermal_cloak/proc/update_viewer(mob/living/thermal_viewer)
	var/client/viewer_client = thermal_viewers[thermal_viewer]
	if(!viewer_client || thermal_viewer.client != viewer_client || !(thermal_viewer.sight & SEE_MOBS))
		return

	var/atom/viewer_eye = viewer_client.get_eye()
	if(!viewer_eye)
		viewer_eye = thermal_viewer
	var/turf/eye_turf = get_turf(viewer_eye)
	if(!eye_turf)
		return

	var/list/view_size = getviewsize(viewer_client.view)
	var/view_range = floor(max(view_size[1], view_size[2]) * 0.5)
	view_range += CEILING(max(abs(viewer_client.get_pixel_x()), abs(viewer_client.get_pixel_y())) / world.icon_size, 1)
	var/list/direct_view
	var/view_checked = FALSE
	for(var/mob/living/cloaked_mob as anything in cloaked_mobs)
		var/image/cloak_image = cloaked_mobs[cloaked_mob]
		var/turf/cloaked_turf = get_turf(cloaked_mob)
		if(!cloaked_turf || cloaked_turf.z != eye_turf.z)
			viewer_client.images -= cloak_image
			continue

		if(cloaked_turf == eye_turf)
			viewer_client.images -= cloak_image
			continue

		if(get_dist(eye_turf, cloaked_turf) > view_range)
			viewer_client.images |= cloak_image
			continue

		if(!view_checked)
			direct_view = dview(view_range, eye_turf, INVISIBILITY_MAXIMUM)
			view_checked = TRUE

		if(cloaked_mob in direct_view)
			viewer_client.images -= cloak_image
		else
			viewer_client.images |= cloak_image

/datum/element/traitbound/thermal_cloak/proc/on_mob_moved(mob/living/source)
	SIGNAL_HANDLER
	if(source in cloaked_mobs)
		update_viewers()
	else if(thermal_viewers[source])
		update_viewer(source)

