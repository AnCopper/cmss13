SUBSYSTEM_DEF(hijack)
	name   = "Hijack"
	wait   = 2 SECONDS
	flags  = SS_KEEP_TIMING
	priority   = SS_PRIORITY_HIJACK
	init_order = SS_INIT_HIJACK

	///Required progress to safely arrive at our destination
	var/required_progress = 100

	/// The progress at which the ship will enter FTL
	var/ftl_required_progress = 50

	///Current progress towards the FTL jump
	var/current_progress = 0

	/// How much progress is required to early launch
	var/early_launch_required_progress = 25

	///The estimated time left to get to the safe evacuation point
	var/estimated_time_left = 0

	///Areas that are marked as having progress, assoc list that is progress_area = boolean, the boolean indicating if it was progressing or not on the last fire()
	var/list/area/progress_areas = list()

	///The areas that need to be cycled through currently
	var/list/area/current_run = list()

	///The living human mobs that need to be cycled through currently
	var/list/mob/living/carbon/human/current_run_mobs = list()

	///The progress of the current run that needs to be added at the end of the current run
	var/current_run_progress_additive = 0

	///Holds what the current_run_progress_additive should be multiplied by at the end of the current run
	var/current_run_progress_multiplicative = 1

	///Holds the progress change from last run
	var/last_run_progress_change = 0

	///Holds the next % point progress should be announced, increments on itself
	var/announce_checkpoint = 25

	///What stage of evacuation we are currently on
	var/evac_status = EVACUATION_STATUS_NOT_INITIATED

	///What stage of hijack are we currently on
	var/hijack_status = HIJACK_OBJECTIVES_NOT_STARTED

	///Whether command has permanently diverted the emergency fuel supply from FTL to self destruct
	var/sd_route_selected = FALSE

	///Whether the ship has reached a stable orbit through the self destruct fuel route
	var/stable_orbit = FALSE

	///Whether or not evacuation has been disabled by admins
	var/evac_admin_denied = FALSE

	/// If TRUE, self destruct has been unlocked and is possible with a hold of reactor
	var/sd_unlocked = FALSE

	/// Admin var to manually prevent self destruct from occurring
	var/admin_sd_blocked = FALSE

	/// Maximum amount of fusion generators that can be overloaded at once for a time benefit
	var/maximum_overload_generators = 18

	/// How many generators are currently overloaded
	var/overloaded_generators = 0

	/// How long the manual self destruct will take on the high end
	var/sd_max_time = 15 MINUTES

	/// How long the manual self destruct will take on the low end and the fully fueled command sequence will take
	var/sd_min_time = 5 MINUTES

	/// How much time left until SD detonates
	var/sd_time_remaining = 0

	/// Whether command has started the pump-fueled self destruct sequence
	var/command_sd_active = FALSE

	/// Roughly what % of the SD countdown remains
	var/percent_completion_remaining = 100

	/// If the engine room has been heated, occurs at 33% SD completion
	var/engine_room_heated = FALSE

	/// If the engine room has been superheated, occurs at 66% SD completion
	var/engine_room_superheated = FALSE

	/// If the self destruct has/is detonating
	var/sd_detonated = FALSE

	/// When the irreversible self destruct grace period will end
	var/sd_detonation_time = 0

	/// If a generator has ever been overloaded in the past this round
	var/generator_ever_overloaded = FALSE

	/// If ARES has announced the 50% point yet for SD
	var/ares_sd_announced = FALSE

	/// At what world.time the ship is currently entered FTL
	var/in_ftl_time = INFINITY

	/// If the ship is currently transiting in FTL
	var/in_ftl = FALSE

	/// If the ship has crashed onto a ground map and space turfs have been replaced with turf/open_space
	var/crashed = FALSE

	/// The x offset for open_space turfs to ground when crashed
	var/crashed_offset_x = 0

	/// The y offset for open_space turfs to ground when crashed
	var/crashed_offset_y = 0

	/// The min ground z for open_space turfs when crashed
	var/crashed_ground_z_min = 0

	/// The bottom left origin point where the shipmap crashes to the ground map
	var/turf/ground_origin

	/// Whether or not lifeboats are still allowed to depart or not
	var/escape_possible = TRUE

	/// The x origin for the mainship map
	var/ship_origin_x = 0

	/// The y origin for the mainship map
	var/ship_origin_y = 0

	/**
	 * A list of bounds in the form of OPEN_SPACE_BOUNDS_MINX, OPEN_SPACE_BOUNDS_MAXX, OPEN_SPACE_BOUNDS_MINY, OPEN_SPACE_BOUNDS_MAXY
	 * of space that will convert to open space. Should not be modified because it will just be referencing the config list.
	 */
	var/list/open_space_bounds

	/// Where the ship is currently transiting to
	var/datum/spaceport/spaceport

	/// An alist of area -> machinery (fuelpumps) for lookup
	var/alist/area_machinery_lookup = alist()

	/// A list of all APCs on the main ship
	var/list/obj/structure/machinery/power/apc/almayer/apcs = list()

	/// A list of all powernets on the main ship
	var/list/datum/powernet/powernets = list()

/datum/controller/subsystem/hijack/Initialize(timeofday)
	RegisterSignal(SSdcs, COMSIG_GLOB_GENERATOR_SET_OVERLOADING, PROC_REF(on_generator_overload))

	var/spaceport_to_use = pick(subtypesof(/datum/spaceport))
	spaceport = new spaceport_to_use

	return SS_INIT_SUCCESS

/datum/controller/subsystem/hijack/stat_entry(msg)
	if(!SSticker?.mode?.is_in_endgame)
		msg = " Not Hijack"
		return ..()

	var/progress_goal = sd_route_selected ? ftl_required_progress : required_progress
	if(current_progress >= progress_goal)
		msg = " Complete"
		return ..()

	msg = " Progress: [round(current_progress / progress_goal * 100, 0.1)]% | Last run: [last_run_progress_change]"
	return ..()

/datum/controller/subsystem/hijack/fire(resumed = FALSE)
	if(!SSticker?.mode?.is_in_endgame)
		return

	if(hijack_status < HIJACK_OBJECTIVES_STARTED)
		// First fire
		hijack_status = HIJACK_OBJECTIVES_STARTED
		SEND_GLOBAL_SIGNAL(COMSIG_GLOB_FUEL_PUMP_UPDATE)
		return

	if(hijack_status == HIJACK_OBJECTIVES_DOCKED)
		// Post FTL dock to repeatedly spawn ERTs
		if(TIMER_COOLDOWN_CHECK(src, COOLDOWN_POSTHIJACK_ERT))
			return

		var/to_spawn = pick(spaceport.allies)
		if(!ispath(to_spawn))
			stack_trace("Failed to instantiate emergency call ally '[to_spawn]' for spaceport [spaceport]!")
			TIMER_COOLDOWN_START(src, COOLDOWN_POSTHIJACK_ERT, 30 SECONDS)
			return

		var/datum/emergency_call/emergency_call = new to_spawn
		emergency_call.name_of_spawn = /obj/effect/landmark/ert_spawns/umbilical
		emergency_call.shuttle_id = null
		emergency_call.activate(TRUE, FALSE)

		TIMER_COOLDOWN_START(src, COOLDOWN_POSTHIJACK_ERT, 5 MINUTES)
		return

	if(stable_orbit || hijack_status == HIJACK_OBJECTIVES_FTL_CRASH || hijack_status == HIJACK_OBJECTIVES_GROUND_CRASH)
		// Stable orbit and crashed states can handle SD without further fuel pump processing
		if(!sd_detonated && (command_sd_active || (sd_unlocked && overloaded_generators)))
			process_self_destruct()

		if(stable_orbit)
			return

		// Handle power shortage by ship being cracked in half
		if(crashed && hijack_status == HIJACK_OBJECTIVES_GROUND_CRASH)
			for(var/obj/structure/machinery/power/apc/almayer/apc as anything in apcs)
				if(prob(5))
					apc.shorted = TRUE
					playsound(apc.loc, 'sound/effects/sparks2.ogg', 25, 1)
					var/datum/effect_system/spark_spread/spark = new /datum/effect_system/spark_spread
					spark.set_up(2, 1, apc)
					spark.start()
		return

	if(!SSticker.mode.count_marines(SSmapping.levels_by_trait(ZTRAIT_MARINE_MAIN_SHIP)))
		// All marines dead, stop objective progression
		if(in_ftl || hijack_status == HIJACK_OBJECTIVES_STARTED)
			shipwide_ai_announcement("No USCM life signs detected on board. [in_ftl ? "Maintaining course to [spaceport.name]." : "Deactivating hyperdrive charge cycle."]")
		can_fire = FALSE
		return

	if(!resumed)
		current_run = progress_areas.Copy()
		if(in_ftl && world.time - in_ftl_time >= 30 SECONDS)
			current_run_mobs = GLOB.alive_human_list.Copy()

	if(in_ftl)
		// Scalar between 30s and 15min for ~0-12.5% chance of a hallucination when in FTL outside a pod
		var/duration_clamped = clamp(world.time - in_ftl_time, 30 SECONDS, 5 MINUTES)
		var/chance_haullucinate = SCALE(duration_clamped, 30 SECONDS, 40 MINUTES) * 100 // max actually seems to be a little less because byond floats
		for(var/mob/living/carbon/human/current_mob as anything in current_run_mobs)
			current_run_mobs -= current_mob

			if(!current_mob || current_mob.stat == DEAD)
				continue
			var/turf/mob_turf = get_turf(current_mob)
			if(!mob_turf || !is_mainship_level(mob_turf.z))
				continue
			if(istype(current_mob.loc, /obj/structure/machinery/cryopod))
				continue
			if(!ishuman_strict(current_mob))
				continue

			if(prob(chance_haullucinate))
				current_mob.process_hallucination()

			if(MC_TICK_CHECK)
				return

	if(hijack_status == HIJACK_OBJECTIVES_STARTED)
		if(sd_route_selected && current_progress >= ftl_required_progress)
			stabilize_orbit()
			return

		if(!sd_route_selected && current_progress >= required_progress)
			// Progress is now complete to leave FTL
			if(hijack_status <= HIJACK_OBJECTIVES_STARTED)
				hijack_status = HIJACK_OBJECTIVES_COMPLETE
				leave_ftl()
				addtimer(CALLBACK(src, PROC_REF(initiate_docking_procedures)), 10 SECONDS)
			return

		if(!sd_route_selected && current_progress >= ftl_required_progress && !in_ftl)
			// Progress is now able to enter FTL
			initiate_ftl_charge()

		// Calculate new progression
		for(var/area/almayer/cycled_area as anything in current_run)
			current_run -= cycled_area

			var/new_area_state = cycled_area.power_equip

			var/obj/structure/machinery/machine = SShijack.area_machinery_lookup[cycled_area]
			if(machine)
				// Pumps don't care about area power but health
				new_area_state = machine.operable()

			if(progress_areas[cycled_area] != new_area_state)
				progress_areas[cycled_area] = new_area_state
				announce_area_state_change(cycled_area, new_area_state)

			if(progress_areas[cycled_area])
				switch(cycled_area.hijack_evacuation_type)
					if(EVACUATION_TYPE_ADDITIVE)
						current_run_progress_additive += cycled_area.hijack_evacuation_weight
					if(EVACUATION_TYPE_MULTIPLICATIVE)
						current_run_progress_multiplicative *= cycled_area.hijack_evacuation_weight

			if(MC_TICK_CHECK)
				return

		last_run_progress_change = current_run_progress_additive * current_run_progress_multiplicative
		current_progress += last_run_progress_change

		if(last_run_progress_change)
			// There was progress, update time left
			var/progress_goal = sd_route_selected ? ftl_required_progress : required_progress
			estimated_time_left = max(((progress_goal - current_progress) / last_run_progress_change) * wait, 0)
		else
			// Failure!
			estimated_time_left = INFINITY
			if(in_ftl)
				initiate_ftl_crash()
			else
				initiate_ground_crash()
			return

		if(current_progress >= announce_checkpoint)
			// Announce the progress checkpoint
			announce_progress()
			announce_checkpoint += initial(announce_checkpoint)
			SEND_GLOBAL_SIGNAL(COMSIG_GLOB_FUEL_PUMP_UPDATE)

		current_run_progress_additive = 0
		current_run_progress_multiplicative = 1

///Called when the dropship has been called by the xenos
/datum/controller/subsystem/hijack/proc/on_call_shuttle()
	hijack_status = HIJACK_OBJECTIVES_SHIP_INBOUND
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_HIJACK_INBOUND)

	if(istype(SSticker.mode, /datum/game_mode/colonialmarines))
		var/datum/game_mode/colonialmarines/colonial_marines = SSticker.mode
		colonial_marines.add_current_round_status_to_end_results("Hijack")
	GLOB.round_statistics?.track_hijack()

/// Called usually after some delay after the dropship has been called by the xenos (or immediately on queen sneak)
/datum/controller/subsystem/hijack/proc/hijack_general_quarters()
	var/datum/ares_datacore/datacore = GLOB.ares_datacore
	if(GLOB.security_level < SEC_LEVEL_RED)
		set_security_level(SEC_LEVEL_RED, no_sound = TRUE, announce = FALSE)
	if(!COOLDOWN_FINISHED(datacore, ares_quarters_cooldown))
		return FALSE
	COOLDOWN_START(datacore, ares_quarters_cooldown, 10 MINUTES)
	shipwide_ai_announcement("ATTENTION! GENERAL QUARTERS. ALL HANDS, MAN YOUR BATTLESTATIONS.", MAIN_AI_SYSTEM, 'sound/effects/GQfullcall.ogg')
	return TRUE

///Called when the xeno dropship crashes into the Almayer and announces the current status of various objectives to marines
/datum/controller/subsystem/hijack/proc/announce_status_on_crash()
	var/message = ""

	for(var/area/cycled_area as anything in progress_areas)
		var/new_area_state = cycled_area.power_equip
		var/obj/structure/machinery/machine = SShijack.area_machinery_lookup[cycled_area]
		if(machine)
			// Pumps don't care about area power but health
			new_area_state = machine.operable()
		message += "[cycled_area] - [new_area_state ? "Online" : "Offline"]\n"
		progress_areas[cycled_area] = new_area_state

	message += "\nCritical damage sustained to ship systems. Altitude rapidly decreasing. Initiating sublight burn to exit AO.\nMaintain fueling functionality to initiate quantum jump to [spaceport.name]. Command may permanently divert emergency fuel to orbital stabilization and the emergency destruct reserve from a communications console."

	marine_announcement(message, HIJACK_ANNOUNCE)

///Called when an area's operable status is changed to announce that it has been changed
/datum/controller/subsystem/hijack/proc/announce_area_state_change(area/changed_area, new_state)
	var/message = "[changed_area] - [new_state ? "Online" : "Offline"]"
	shipwide_ai_announcement(message, HIJACK_ANNOUNCE, sound('sound/misc/notice2.ogg'))

///Called to announce to xenos the state of evacuation progression
/datum/controller/subsystem/hijack/proc/announce_progress()
	var/announce = announce_checkpoint / initial(announce_checkpoint)

	var/marine_warning_areas = ""
	var/xeno_warning_areas = ""
	var/marine_no_repairable = " All fueling areas operational."
	var/broken_unrepairable = 0

	for(var/area/cycled_area as anything in progress_areas)
		var/new_area_state = cycled_area.power_equip
		var/repairable = TRUE
		var/obj/structure/machinery/machine = SShijack.area_machinery_lookup[cycled_area]
		if(machine)
			// Pumps don't care about area power but health
			repairable = FALSE
			new_area_state = machine.operable()
		progress_areas[cycled_area] = new_area_state
		if(new_area_state)
			// Powered: xenos interested to know this
			xeno_warning_areas += "[cycled_area], "
			continue
		if(repairable)
			// Not powered, but can be powered: marines interested to know this
			marine_warning_areas += "[cycled_area], "
		else
			broken_unrepairable++

	// Remove ending commas and whitespace
	if(xeno_warning_areas)
		xeno_warning_areas = copytext(xeno_warning_areas, 1, -2)
	if(marine_warning_areas)
		marine_warning_areas = copytext(marine_warning_areas, 1, -2)
	if(broken_unrepairable > 0)
		var/total_machines = length(SShijack.area_machinery_lookup)
		var/working_machines = total_machines - broken_unrepairable
		marine_no_repairable = " [working_machines]/[total_machines] fueling areas remain operational."

	var/datum/hive_status/hive
	for(var/hivenumber in GLOB.hive_datum)
		hive = GLOB.hive_datum[hivenumber]
		if(!length(hive.totalXenos))
			continue

		switch(announce)
			if(1)
				if(sd_route_selected)
					xeno_announcement(SPAN_XENOANNOUNCE("The talls are halfway towards stabilizing their metal hive and fueling its hive killer. Disable the following areas: [xeno_warning_areas]"), hive.hivenumber, XENO_HIJACK_ANNOUNCE)
				else
					xeno_announcement(SPAN_XENOANNOUNCE("The talls are a quarter of the way towards their goals. Disable the following areas: [xeno_warning_areas]"), hive.hivenumber, XENO_HIJACK_ANNOUNCE)
			if(2)
				if(sd_route_selected)
					xeno_announcement(SPAN_XENOANNOUNCE("The talls have fueled their hive killer and are completing their final orbital stabilization!"), hive.hivenumber, XENO_HIJACK_ANNOUNCE)
				else
					xeno_announcement(SPAN_XENOANNOUNCE("The talls are half way towards their goals. Disable the following areas: [xeno_warning_areas]"), hive.hivenumber, XENO_HIJACK_ANNOUNCE)
			if(3)
				xeno_announcement(SPAN_XENOANNOUNCE("The talls are three quarters of the way towards their goals. Disable the following areas: [xeno_warning_areas]"), hive.hivenumber, XENO_HIJACK_ANNOUNCE)
			if(4)
				xeno_announcement(SPAN_XENOANNOUNCE("The talls have completed their goals!"), hive.hivenumber, XENO_HIJACK_ANNOUNCE)

	switch(announce)
		if(1)
			if(sd_route_selected)
				marine_announcement("Orbital stabilization and self-destruct fuel transfer at 50 percent.[marine_warning_areas ? "\nTo increase speed, restore power to the following areas: [marine_warning_areas]" : marine_no_repairable]", HIJACK_ANNOUNCE)
			else
				marine_announcement("Emergency fuel replenishment is at 50%. Tachyon field accelerators currently charging.[marine_warning_areas ? "\nTo increase speed, restore power to the following areas: [marine_warning_areas]" : marine_no_repairable]", HIJACK_ANNOUNCE)
		if(2)
			if(sd_route_selected)
				marine_announcement("Self-destruct fuel reserve fully charged. Final orbital stabilization underway.", HIJACK_ANNOUNCE)
			else
				marine_announcement("Emergency fuel replenishment is at 100%. Tachyon field accelerators fully charged, quantum jump initiating. Ensure constant supply of fuel to the tachyon field accelerators.[marine_warning_areas ? "\nTo increase speed, restore power to the following areas: [marine_warning_areas]" : marine_no_repairable]", HIJACK_ANNOUNCE)
		if(3)
			shipwide_ai_announcement("Tachyon quantum jump progress at 50 percent. Ensure constant supply of fuel to the tachyon field accelerators.[marine_warning_areas ? "\nTo increase speed, restore power to the following areas: [marine_warning_areas]" : marine_no_repairable]", HIJACK_ANNOUNCE, sound('sound/misc/notice2.ogg'))
		if(4)
			shipwide_ai_announcement("Tachyon quantum jump complete. Initiating docking procedures with [spaceport.name]. Lifeboats and pods re-enabled.", HIJACK_ANNOUNCE, sound('sound/misc/notice2.ogg'))

/// Passes the ETA for status panels
/datum/controller/subsystem/hijack/proc/get_evac_eta()
	if(stable_orbit)
		return "Stable Orbit"

	switch(hijack_status)
		if(HIJACK_OBJECTIVES_STARTED)
			if(estimated_time_left == INFINITY)
				return "Never"
			return "[duration2text_sec(estimated_time_left)]"

		if(HIJACK_OBJECTIVES_COMPLETE)
			return "Complete"

/// Passes the SD ETA for status panels
/datum/controller/subsystem/hijack/proc/get_sd_eta()
	if(sd_detonated)
		if(world.time < sd_detonation_time)
			return "[duration2text_sec(sd_detonation_time - world.time)]"
		return "Complete"

	if(!command_sd_active && overloaded_generators <= 0)
		return "Never"

	return "[duration2text_sec(sd_time_remaining)]"

/// Plays the passed sfx for any xenos shipside
/datum/controller/subsystem/hijack/proc/play_sfx_for_shipside_xenos(sound/soundin, vol=45)
	for(var/mob/living/carbon/xenomorph as anything in GLOB.xeno_mob_list)
		var/turf/xeno_turf = get_turf(xenomorph)
		if(!xeno_turf || !is_mainship_level(xeno_turf.z))
			continue
		playsound_client(xenomorph.client, soundin, vol=vol)


//~~~~~~~~~~~~~~~~~~~~~~~~ EVAC STUFF ~~~~~~~~~~~~~~~~~~~~~~~~//

/// Initiates evacuation by announcing and then prepping all lifepods/lifeboats
/datum/controller/subsystem/hijack/proc/initiate_evacuation(force = FALSE)
	if(evac_status == EVACUATION_STATUS_INITIATED || (!force && (evac_admin_denied & FLAGS_EVACUATION_DENY)))
		return FALSE
	if(in_ftl)
		return FALSE
	if(!crashed && (hijack_status == HIJACK_OBJECTIVES_GROUND_CRASH))
		return FALSE

	evac_status = EVACUATION_STATUS_INITIATED
	ai_announcement("Attention. Emergency. All personnel must evacuate immediately.", 'sound/AI/evacuate.ogg')

	for(var/obj/structure/machinery/status_display/cycled_status_display in GLOB.machines)
		if(is_mainship_level(cycled_status_display.z))
			cycled_status_display.set_picture("evac")
	for(var/obj/docking_port/mobile/crashable/escape_shuttle/shuttle in SSshuttle.mobile)
		shuttle.prepare_evac()
	activate_lifeboats()
	return TRUE

/// Cancels evacuation, tells lifepods/lifeboats and status_displays
/datum/controller/subsystem/hijack/proc/cancel_evacuation(silent = FALSE)
	if(sd_detonated || evac_status == EVACUATION_STATUS_NOT_INITIATED)
		return FALSE

	evac_status = EVACUATION_STATUS_NOT_INITIATED
	deactivate_lifeboats()
	if(!silent)
		ai_announcement("Evacuation has been cancelled.", 'sound/AI/evacuate_cancelled.ogg')

	for(var/obj/structure/machinery/status_display/cycled_status_display in GLOB.machines)
		if(is_mainship_level(cycled_status_display.z))
			cycled_status_display.set_sec_level_picture()

	for(var/obj/docking_port/mobile/crashable/escape_shuttle/shuttle in SSshuttle.mobile)
		shuttle.cancel_evac()
	return TRUE

/// Opens the lifeboat doors and gets them ready to launch
/datum/controller/subsystem/hijack/proc/activate_lifeboats()
	for(var/obj/docking_port/stationary/lifeboat_dock/lifeboat_dock in GLOB.lifeboat_almayer_docks)
		var/obj/docking_port/mobile/crashable/lifeboat/lifeboat = lifeboat_dock.get_docked()
		if(lifeboat && lifeboat.available)
			lifeboat.status = LIFEBOAT_ACTIVE
			lifeboat_dock.open_dock()

/// Turns off ability to manually take off lifeboats
/datum/controller/subsystem/hijack/proc/deactivate_lifeboats()
	for(var/obj/docking_port/stationary/lifeboat_dock/lifeboat_dock in GLOB.lifeboat_almayer_docks)
		var/obj/docking_port/mobile/crashable/lifeboat/lifeboat = lifeboat_dock.get_docked()
		if(lifeboat && lifeboat.available)
			lifeboat.status = LIFEBOAT_INACTIVE

/// Forces every remaining escape pod and lifeboat docked on the Almayer to launch
/datum/controller/subsystem/hijack/proc/launch_escape_craft()
	for(var/obj/docking_port/mobile/crashable/escape_shuttle/shuttle in SSshuttle.mobile)
		var/obj/docking_port/stationary/escape_pod_dock = shuttle.get_docked()
		if(!escape_pod_dock || !is_mainship_level(escape_pod_dock.z) || shuttle.launched || shuttle.mode == SHUTTLE_CRASHED)
			continue

		INVOKE_ASYNC(shuttle, TYPE_PROC_REF(/obj/docking_port/mobile/crashable/escape_shuttle, evac_launch), TRUE)

	for(var/obj/docking_port/mobile/crashable/lifeboat/lifeboat in SSshuttle.mobile)
		var/obj/docking_port/stationary/lifeboat_dock = lifeboat.get_docked()
		if(!lifeboat_dock || !is_mainship_level(lifeboat_dock.z))
			continue

		INVOKE_ASYNC(lifeboat, TYPE_PROC_REF(/obj/docking_port/mobile/crashable/lifeboat, evac_launch), TRUE)

/// Unlocks all marine dropship and optionally ert dropship doors on the mainship
/datum/controller/subsystem/hijack/proc/unlock_all_dropship_doors(include_ert=TRUE)
	for(var/obj/docking_port/mobile/shuttle as anything in SSshuttle.mobile)
		var/turf/location = get_turf(shuttle)
		if(!location || !is_mainship_level(location.z))
			continue

		if(istype(shuttle, /obj/docking_port/mobile/marine_dropship))
			var/obj/docking_port/mobile/marine_dropship/dropship = shuttle
			dropship.control_doors("unlock", "all")
			continue
		if(include_ert && istype(shuttle, /obj/docking_port/mobile/emergency_response))
			var/obj/docking_port/mobile/emergency_response/dropship = shuttle
			dropship.control_doors("unlock")
			continue

/// Changes whether the mobile docking_ports on the mainship are operating (launchable)
/datum/controller/subsystem/hijack/proc/allow_dropship_launching(include_marine_dropship=FALSE)
	for(var/obj/docking_port/mobile/shuttle as anything in SSshuttle.mobile)
		var/turf/location = get_turf(shuttle)
		if(!location || !is_mainship_level(location.z))
			continue
		// ASSUMPTION: Only a hijacked marine_dropship would possibly be something permanently disabled
		if(istype(shuttle, /obj/docking_port/mobile/marine_dropship))
			if(!include_marine_dropship)
				continue
			var/obj/docking_port/mobile/marine_dropship/dropship = shuttle
			if(dropship.is_hijacked)
				continue
		else if(istype(shuttle, /obj/docking_port/mobile/crashable))
			continue
		else if(istype(shuttle, /obj/docking_port/mobile/vehicle_elevator))
			continue
		shuttle.set_mode(SHUTTLE_IDLE)

/// Changes whether the mobile docking_ports on the mainship are not operating (launchable)
/datum/controller/subsystem/hijack/proc/disallow_dropship_launching(include_marine_dropship=TRUE)
	for(var/obj/docking_port/mobile/shuttle as anything in SSshuttle.mobile)
		var/turf/location = get_turf(shuttle)
		if(!location || !is_mainship_level(location.z))
			continue

		if(istype(shuttle, /obj/docking_port/mobile/marine_dropship))
			if(!include_marine_dropship)
				continue
		else if(istype(shuttle, /obj/docking_port/mobile/crashable))
			continue
		else if(istype(shuttle, /obj/docking_port/mobile/vehicle_elevator))
			continue
		shuttle.set_mode(SHUTTLE_CRASHED)

/// Changes whether the stationary docking_ports on the mainship are operating (dockable)
/datum/controller/subsystem/hijack/proc/allow_dropship_pad_landing(include_marine_dropship=FALSE)
	for(var/obj/docking_port/stationary/pad as anything in SSshuttle.stationary)
		var/turf/location = get_turf(pad)
		if(!location || !is_mainship_level(location.z))
			continue
		if(!include_marine_dropship && istype(pad, /obj/docking_port/stationary/marine_dropship))
			continue
		if(istype(pad, /obj/docking_port/stationary/vehicle_elevator))
			continue
		pad.disabled = initial(pad.disabled)

/// Changes whether the stationary docking_ports on the mainship are operating (dockable)
/datum/controller/subsystem/hijack/proc/disallow_dropship_pad_landing(include_marine_dropship=TRUE)
	for(var/obj/docking_port/stationary/pad as anything in SSshuttle.stationary)
		var/turf/location = get_turf(pad)
		if(!location || !is_mainship_level(location.z))
			continue
		if(!include_marine_dropship && istype(pad, /obj/docking_port/stationary/marine_dropship))
			continue
		if(istype(pad, /obj/docking_port/stationary/vehicle_elevator))
			continue
		pad.disabled = TRUE


//~~~~~~~~~~~~~~~~~~~~~~~~ SD STUFF ~~~~~~~~~~~~~~~~~~~~~~~~//

/// Permanently diverts the active hijack fuel route from FTL to stable orbit and self destruct
/datum/controller/subsystem/hijack/proc/select_self_destruct_route()
	if(!SSticker?.mode?.is_in_endgame || hijack_status != HIJACK_OBJECTIVES_STARTED || in_ftl || sd_route_selected || sd_unlocked || command_sd_active || sd_detonated || admin_sd_blocked)
		return FALSE

	sd_route_selected = TRUE
	if(last_run_progress_change)
		estimated_time_left = max(((ftl_required_progress - current_progress) / last_run_progress_change) * wait, 0)
	else
		estimated_time_left = INFINITY

	shipwide_ai_announcement("Command override accepted. Emergency fuel routing diverted to orbital stabilizers and self-destruct reserves. Quantum jump capability permanently disabled.", HIJACK_ANNOUNCE, sound('sound/misc/notice2.ogg'))
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_FUEL_PUMP_UPDATE)
	return TRUE

/// Marks the ship as safe from crashing after the self destruct fuel objective is completed
/datum/controller/subsystem/hijack/proc/stabilize_orbit()
	if(stable_orbit || !sd_route_selected || in_ftl || hijack_status != HIJACK_OBJECTIVES_STARTED)
		return FALSE

	stable_orbit = TRUE
	current_progress = ftl_required_progress
	estimated_time_left = 0
	last_run_progress_change = 0
	current_run.Cut()
	current_run_progress_additive = 0
	current_run_progress_multiplicative = 1
	shipwide_ai_announcement("Stable orbit achieved. Self-destruct fuel reserve fully charged. Fuel pumps are no longer required. Command authorization is required to initiate the destruct sequence.", HIJACK_ANNOUNCE, sound('sound/misc/notice2.ogg'))
	xeno_announcement(SPAN_XENOANNOUNCE("The tallhosts have stabilized their metal hive and fueled its hive killer. Destroying the fueling structures will no longer bring it down. Prevent them from reaching their command center!"), "everything", XENO_HIJACK_ANNOUNCE)
	return TRUE

/// Starts a fully fueled self destruct from the command console after stable orbit is achieved
/datum/controller/subsystem/hijack/proc/start_command_self_destruct()
	if(!SSticker?.mode?.is_in_endgame || hijack_status != HIJACK_OBJECTIVES_STARTED || in_ftl || !stable_orbit || !sd_route_selected || sd_unlocked || command_sd_active || sd_detonated || admin_sd_blocked)
		return FALSE

	command_sd_active = TRUE
	sd_time_remaining = sd_min_time
	percent_completion_remaining = 1
	set_security_level(SEC_LEVEL_DELTA, no_sound = TRUE, announce = FALSE)
	shipwide_ai_announcement("DANGER: Emergency destruct system activated by Command. Fusion reactor meltdown in five minutes. Evacuate the ship.", "SELF-DESTRUCT SYSTEMS ACTIVE", sound('sound/AI/selfdestruct_short.ogg'))
	return TRUE

/// Advances either the manual generator overload or command-initiated self destruct countdown
/datum/controller/subsystem/hijack/proc/process_self_destruct()
	var/sd_required_time = sd_min_time
	if(!command_sd_active)
		sd_required_time = max((1 - round(overloaded_generators / maximum_overload_generators, 0.01)) * sd_max_time, sd_min_time)

	sd_time_remaining -= wait
	if(!engine_room_heated && sd_time_remaining <= sd_required_time * 0.66)
		heat_engine_room()

	if(!ares_sd_announced && sd_time_remaining <= sd_required_time * 0.5)
		announce_sd_halfway()

	if(!engine_room_superheated && sd_time_remaining <= sd_required_time * 0.33)
		superheat_engine_room()

	if(sd_time_remaining <= 0)
		detonate_sd()

/// After a crash, marines can optionally hold SD for a time for a stalemate instead of a xeno minor
/datum/controller/subsystem/hijack/proc/unlock_self_destruct(from_ftl = FALSE)
	sd_time_remaining = sd_max_time
	sd_unlocked = TRUE
	shipwide_ai_announcement("[from_ftl ? "Hyperdrive tachyon shunt no longer operable. Lifeboats and pods re-enabled. " : ""]Remaining fuel transferred to on board fusion generators to permit scuttling.", HIJACK_ANNOUNCE, sound('sound/misc/notice2.ogg'))

/// Signal handler for COMSIG_GLOB_GENERATOR_SET_OVERLOADING
/datum/controller/subsystem/hijack/proc/on_generator_overload(obj/structure/machinery/power/power_generator/reactor/source, new_overloading)
	SIGNAL_HANDLER

	if(new_overloading && !generator_ever_overloaded)
		generator_ever_overloaded = TRUE
		set_security_level(SEC_LEVEL_DELTA)
		var/datum/hive_status/hive
		for(var/hivenumber in GLOB.hive_datum)
			hive = GLOB.hive_datum[hivenumber]
			if(!length(hive.totalXenos))
				continue

			xeno_announcement(SPAN_XENOANNOUNCE("The talls may be attempting to take their ship down with them in Engineering, stop them!"), hive.hivenumber, XENO_HIJACK_ANNOUNCE)

	adjust_generator_overload_count(new_overloading ? 1 : -1)

/datum/controller/subsystem/hijack/proc/adjust_generator_overload_count(amount = 1)
	var/generator_overload_percent = round(overloaded_generators / maximum_overload_generators, 0.01)
	var/old_required_time = sd_min_time + ((1 - generator_overload_percent) * (sd_max_time - sd_min_time))
	percent_completion_remaining = sd_time_remaining / old_required_time
	overloaded_generators = clamp(overloaded_generators + amount, 0, maximum_overload_generators)
	generator_overload_percent = round(overloaded_generators / maximum_overload_generators, 0.01)
	var/new_required_time = sd_min_time + ((1 - generator_overload_percent) * (sd_max_time - sd_min_time))
	sd_time_remaining = percent_completion_remaining * new_required_time

/datum/controller/subsystem/hijack/proc/heat_engine_room()
	engine_room_heated = TRUE
	var/area/engine_room = GLOB.areas_by_type[/area/almayer/engineering/lower/engine_core]
	engine_room.firealert()
	engine_room.temperature = T90C
	for(var/mob/current_mob as anything in GLOB.living_player_list)
		if(current_mob?.stat != CONSCIOUS)
			continue
		var/area/mob_area = get_area(current_mob)
		if(istype(mob_area, /area/almayer/engineering/lower/engine_core))
			to_chat(current_mob, SPAN_BOLDWARNING("You feel the heat of the room increase as the fusion engines whirr louder."))

/datum/controller/subsystem/hijack/proc/superheat_engine_room()
	engine_room_superheated = TRUE
	var/area/engine_room = GLOB.areas_by_type[/area/almayer/engineering/lower/engine_core]
	engine_room.firealert()
	engine_room.temperature = T120C //slowly deals burn at this temp
	for(var/mob/current_mob as anything in GLOB.living_player_list)
		if(current_mob?.stat != CONSCIOUS)
			continue
		var/area/mob_area = get_area(current_mob)
		if(istype(mob_area, /area/almayer/engineering/lower/engine_core))
			to_chat(current_mob, SPAN_BOLDWARNING("The room feels incredibly hot, you can't take much more of this!"))

/datum/controller/subsystem/hijack/proc/critically_heat_engine_room()
	var/area/engine_room = GLOB.areas_by_type[/area/almayer/engineering/lower/engine_core]
	engine_room.firealert()
	engine_room.temperature = T0C + 200
	for(var/mob/current_mob as anything in GLOB.living_player_list)
		if(current_mob?.stat != CONSCIOUS)
			continue
		var/area/mob_area = get_area(current_mob)
		if(istype(mob_area, /area/almayer/engineering/lower/engine_core))
			to_chat(current_mob, SPAN_BOLDWARNING("The air sears your flesh as the fusion engines enter runaway meltdown!"))

/// Sends the timed evacuation and xeno announcements during the self destruct grace period
/datum/controller/subsystem/hijack/proc/announce_sd_grace_period()
	sleep(10 SECONDS)
	xeno_announcement(SPAN_XENOANNOUNCE("You have failed me, and your failure condemns your sisters to burn with this metal hive. The tallhosts flee from their own hive killer. Hunt them. Tear them from their escape vessels. If the hive must die, let no tallhost escape it."), "everything", "Queen Mother Psychic Directive")
	sleep(60 SECONDS)
	if(evac_status == EVACUATION_STATUS_NOT_INITIATED && initiate_evacuation(TRUE))
		shipwide_ai_announcement("ALERT: Emergency evacuation procedures automatically initiated. Self-destruct detonation in fifty seconds.", HIJACK_ANNOUNCE, quiet = TRUE)
	sleep(35 SECONDS)
	shipwide_ai_announcement("WARNING: Evacuation order confirmed. Launching all escape pods and lifeboats. Self-destruct detonation in fifteen seconds.", HIJACK_ANNOUNCE, sound('sound/AI/evacuation_confirmed.ogg'))
	launch_escape_craft()
	sleep(5 SECONDS)
	xeno_announcement(SPAN_XENOANNOUNCE("DO NOT LET THEM ESCAPE."), "everything", "Queen Mother Psychic Directive")
	sleep(5 SECONDS)
	xeno_announcement(SPAN_XENOANNOUNCE("KILL THEM."), "everything", "Queen Mother Psychic Directive")

/datum/controller/subsystem/hijack/proc/announce_sd_halfway()
	ares_sd_announced = TRUE
	shipwide_ai_announcement("ALERT: Fusion reactor meltdown has reached fifty percent.", HIJACK_ANNOUNCE, sound('sound/misc/notice2.ogg'))

/// Shakes the ship with increasing intensity throughout the final self destruct countdown
/datum/controller/subsystem/hijack/proc/shake_sd_grace_period(detonation_time)
	while(world.time < detonation_time)
		var/shake_delay = rand(15 SECONDS, 20 SECONDS)
		if(world.time + shake_delay >= detonation_time)
			return
		sleep(shake_delay)
		if(world.time >= detonation_time)
			return

		var/time_remaining = detonation_time - world.time
		var/shake_strength = rand(3, 4)
		var/shake_time = rand(5, 7)
		if(time_remaining <= 90 SECONDS)
			shake_strength = rand(4, 5)
			shake_time = rand(6, 8)
		if(time_remaining <= 60 SECONDS)
			shake_strength = rand(5, 6)
			shake_time = rand(7, 9)
		if(time_remaining <= 30 SECONDS)
			shake_strength = rand(6, 7)
			shake_time = rand(8, 10)

		shakeship(shake_strength, shake_time, time_remaining <= 30 SECONDS)

/datum/controller/subsystem/hijack/proc/detonate_sd()
	set waitfor = FALSE

	SSticker?.roundend_check_paused = TRUE
	sd_detonated = TRUE
	sd_detonation_time = world.time + 2 MINUTES
	critically_heat_engine_room()
	shipwide_ai_announcement("ALERT: Fusion reactor meltdown is irreversible. Emergency detonation in two minutes. Evacuate immediately.", HIJACK_ANNOUNCE, sound('sound/AI/selfdestruct_2m.ogg'))
	INVOKE_ASYNC(src, PROC_REF(shake_sd_grace_period), sd_detonation_time)
	INVOKE_ASYNC(src, PROC_REF(announce_sd_grace_period))
	// The existing detonation sequence lasts 27 seconds, so begin it within the two minute grace period.
	sleep(93 SECONDS)

	var/creak_picked = pick('sound/effects/creak1.ogg', 'sound/effects/creak2.ogg', 'sound/effects/creak3.ogg')
	for(var/mob/current_mob as anything in GLOB.mob_list)
		var/turf/current_turf = get_turf(current_mob)
		if(!current_turf || !current_mob.client || !is_mainship_level(current_turf.z))
			continue

		to_chat(current_mob, SPAN_BOLDWARNING("The ship's deck worryingly creaks underneath you."))
		playsound_client(current_mob.client, creak_picked, vol=50)

	sleep(7 SECONDS)
	shipwide_ai_announcement("ALERT: Fusion reactors dangerously overloaded. Runaway meltdown in reactor core imminent.", HIJACK_ANNOUNCE, sound('sound/misc/notice2.ogg'))
	sleep(5 SECONDS)

	var/sound_picked = pick('sound/theme/nuclear_detonation1.ogg','sound/theme/nuclear_detonation2.ogg')
	for(var/client/player as anything in GLOB.clients)
		playsound_client(player, sound_picked, vol=90)

	var/list/alive_mobs = list() //Everyone who will be destroyed on the zlevel(s).
	var/list/dead_mobs = list() //Everyone who only needs to see the cinematic.
	for(var/mob/current_mob as anything in GLOB.mob_list) //This only does something cool for the people about to die, but should prove pretty interesting.
		var/turf/current_turf = get_turf(current_mob)
		if(!current_turf)
			continue

		if(current_mob.stat == DEAD)
			dead_mobs |= current_mob
			continue

		if(is_mainship_level(current_turf.z) || (hijack_status == HIJACK_OBJECTIVES_GROUND_CRASH && is_ground_level(current_turf.z)))
			alive_mobs |= current_mob
			shake_camera(current_mob, 110, 4)

	sleep(10 SECONDS)
	/*Hardcoded for now, since this was never really used for anything else.
	Would ideally use a better system for showing cutscenes.*/
	var/atom/movable/screen/cinematic/explosion/explosive_cinematic = new()

	for(var/mob/current_mob as anything in (alive_mobs + dead_mobs))
		if(current_mob?.loc && current_mob.client)
			current_mob.client.add_to_screen(explosive_cinematic)  //They may have disconnected in the mean time.

	sleep(1.5 SECONDS) //Extra 1.5 seconds to look at the ship.
	flick("intro_nuke", explosive_cinematic)

	sleep(3.5 SECONDS)
	for(var/mob/current_mob as anything in alive_mobs)
		var/turf/current_mob_turf = get_turf(current_mob)
		if(!current_mob_turf) //Who knows, maybe they escaped, or don't exist anymore.
			continue

		if(is_mainship_level(current_mob_turf.z) || (hijack_status == HIJACK_OBJECTIVES_GROUND_CRASH && is_ground_level(current_mob_turf.z)))
			if(istype(current_mob.loc, /obj/structure/closet/secure_closet/freezer/fridge))
				continue
			current_mob.death(create_cause_data("nuclear explosion"))
		else
			current_mob.client.remove_from_screen(explosive_cinematic) //those who managed to escape the z level at last second shouldn't have their view obstructed.

	flick("ship_destroyed", explosive_cinematic)
	explosive_cinematic.icon_state = "summary_destroyed"

	for(var/client/player as anything in GLOB.clients)
		playsound_client(player, 'sound/effects/explosionfar.ogg', vol=90)


	sleep(0.5 SECONDS)

	SSticker?.roundend_check_paused = FALSE
	if(SSticker?.mode)
		SSticker.mode.check_win()
	else //Just a safety, just in case a mode isn't running, somehow.
		to_world(SPAN_ROUNDBODY("Resetting in 30 seconds!"))
		sleep(30 SECONDS)
		log_game("Rebooting due to nuclear detonation.")
		world.Reboot()


//~~~~~~~~~~~~~~~~~~~~~~~~ GROUND CRASH STUFF ~~~~~~~~~~~~~~~~~~~~~~~~//

/// Called when pumps failed before FTL initiated to crash onto the ground map
/datum/controller/subsystem/hijack/proc/initiate_ground_crash()
	hijack_status = HIJACK_OBJECTIVES_GROUND_CRASH
	marine_announcement("Tachyon quantum jump drive deactivated due to insufficient fueling. Entry into atmosphere imminent.", HIJACK_ANNOUNCE, sound('sound/mecha/internaldmgalarm.ogg'))
	play_sfx_for_shipside_xenos('sound/mecha/internaldmgalarm.ogg')

	// Figure out the main Z by assuming the LZs are on that Z
	var/obj/lz = locate(/obj/structure/machinery/computer/shuttle/dropship/flight/lz1)
	if(!lz)
		lz = locate(/obj/structure/machinery/computer/shuttle/dropship/flight/lz2)
	var/ground_z = lz.z

	// Figure out the bottom left of playable space with 1 extra border
	var/obj/effect/landmark/mainship_crashsite/origin_landmark = locate() in GLOB.landmarks_list
	ground_origin = get_turf(origin_landmark)
	var/border_type = /turf/closed/wall/strata_ice/jungle
	var/cordon_type = FALSE
	if(ground_origin)
		if(istype(ground_origin, /turf/closed))
			if(istype(ground_origin, /turf/closed/cordon))
				cordon_type = /turf/closed/cordon
				var/turf/border_turf = locate(ground_origin.x + 1, ground_origin.y + 1, ground_origin.z)
				if(istype(border_turf, /turf/closed))
					border_type = border_turf.type
				ground_origin = locate(ground_origin.x + 2, ground_origin.y + 2, ground_origin.z)
			border_type = ground_origin.type
			ground_origin = locate(ground_origin.x + 1, ground_origin.y + 1, ground_origin.z)
	else
		for(var/turf/closed/current_turf in block(1, 1, ground_z, 50, 50, ground_z))
			if(istype(current_turf, /turf/closed/cordon))
				cordon_type = /turf/closed/cordon
				var/turf/border_turf = locate(current_turf.x + 1, current_turf.y + 1, current_turf.z)
				if(istype(border_turf, /turf/closed))
					border_type = border_turf.type
				ground_origin = locate(current_turf.x + 2, current_turf.y + 2, current_turf.z)
				break
			border_type = current_turf.type
			ground_origin = locate(current_turf.x + 1, current_turf.y + 1, current_turf.z)
			break

	// Explosive reentry
	if(ground_origin)
		INVOKE_ASYNC(src, PROC_REF(ground_reentry_hazard), locate(ground_origin.x + 50, ground_origin.y + 50, ground_origin.z))
		INVOKE_ASYNC(src, PROC_REF(ground_reentry_hazard), locate(ground_origin.x + 100, ground_origin.y + 50, ground_origin.z))
		INVOKE_ASYNC(src, PROC_REF(ground_reentry_hazard), locate(ground_origin.x + 150, ground_origin.y + 50, ground_origin.z))
		INVOKE_ASYNC(src, PROC_REF(ground_reentry_hazard), locate(ground_origin.x + 200, ground_origin.y + 50, ground_origin.z))
	addtimer(CALLBACK(src, PROC_REF(crash_onto_ground), ground_origin, border_type, cordon_type), 20 SECONDS)

/// Creates a warhead at the provided location for mainship reentry
/datum/controller/subsystem/hijack/proc/ground_reentry_hazard(turf/target)
	if(!target)
		return
	var/obj/structure/ob_ammo/warhead/explosive/warhead = new
	warhead.name = "mainship reentry explosion"
	warhead.clear_power = 0
	warhead.clear_falloff = 30
	warhead.standard_power = 1200
	warhead.standard_falloff = 30
	warhead.clear_delay = 0
	warhead.double_explosion_delay = 0 // No third explosion please
	warhead.warhead_impact(target) // This is a blocking call

/// Actually places the crash template onto the ground map, updates space turfs, and performs some effects
/datum/controller/subsystem/hijack/proc/crash_onto_ground(turf/ground_origin, border_type, cordon_type)
	if(!ground_origin)
		CRASH("Unable to determine origin location on groundmap for hijack ground crash! Origin can be manually specified with a /obj/effect/landmark/mainship_crashsite")

	msg_admin_niche("Crashing mainship to [ADMIN_COORDJMP(ground_origin)]")

	shakeship(
		sstrength = 1,
		stime = 3,
		drop = FALSE,
	)

	// Break all shipside ships and disable all non-pod/elevator pads
	unlock_all_dropship_doors() // Unlock doors because they'll be uninteractable
	disallow_dropship_launching()
	disallow_dropship_pad_landing()

	escape_possible = FALSE
	shipwide_ai_announcement("ALERT: Lifeboat telemetry equipment destroyed. Cause: Atmospheric reentry.\n\nEvacuation via port and starboard lifeboats is no longer possible.", HIJACK_ANNOUNCE, sound('sound/effects/creak1.ogg'))

	// Place the crash template
	var/datum/map_config/ship_map_config = SSmapping.configs[SHIP_MAP]
	var/datum/map_template/template = SSmapping.map_templates[ship_map_config?.ground_crash_template_name]
	var/time = world.timeofday
	if(!template?.load(ground_origin, centered=FALSE, delete=TRUE, allow_cropping=TRUE, crop_within_type=cordon_type, crop_within_border=1, expand_type=border_type, keep_within_ztrait=TRUE))
		stack_trace("Hijack crash template '[ship_map_config?.ground_crash_template_name]' failed to load!")
	else
		log_debug("Crash template '[ship_map_config?.ground_crash_template_name]' load took [(world.timeofday - time) / 10]s")

	// Determine difference between the templates to offset
	var/list/ship_map_bounds = SSmapping.load_group_bounds[ship_map_config?.map_name]
	if(!ship_map_bounds)
		stack_trace("Ship map bounds for '[ship_map_config?.map_name]' could not be found!")
	var/horizontal_difference = template?.width - ship_map_bounds?[MAP_MAXX]
	var/vertical_difference = template?.height - ship_map_bounds?[MAP_MAXY]

	// Figure out the offset for open_space turfs to peer down to ground aligned to the wreck
	var/shipmap_z = SSmapping.levels_by_trait(ZTRAIT_MARINE_MAIN_SHIP)[1]
	var/list/ship_bounds = SSmapping.z_list[shipmap_z].bounds
	ship_origin_x = ship_bounds[MAP_MINX]
	ship_origin_y = ship_bounds[MAP_MINY]
	crashed_offset_x = -ship_origin_x + 1 + horizontal_difference // Horizontal difference between shipmap and template
	crashed_offset_y = -ship_origin_y + 1 + vertical_difference // Vertical difference between shipmap and template
	crashed_offset_x += ground_origin.x - 1
	crashed_offset_y += ground_origin.y - 1
	crashed_ground_z_min = ground_origin.z
	open_space_bounds = ship_map_config?.open_space_bounds

	shakeship(
		sstrength = 3,
		stime = 3,
		drop = FALSE,
	)
	shipwide_ai_announcement("ALERT: Altitude rapidly decreasing. Brace for impact.", HIJACK_ANNOUNCE, sound('sound/effects/GQfullcall.ogg'))
	play_sfx_for_shipside_xenos('sound/effects/GQfullcall.ogg')
	if(GLOB.security_level < SEC_LEVEL_RED)
		set_security_level(SEC_LEVEL_RED, no_sound = TRUE, announce = FALSE)

	// Update shipside space turfs to open_space
	time = world.timeofday
	var/list/ship_zs = SSmapping.levels_by_trait(ZTRAIT_MARINE_MAIN_SHIP)
	for(var/z_level in ship_zs)
		for(var/turf/open/space/space_turf in Z_TURFS(z_level))
			set_ftl_turf_open(space_turf)
			CHECK_TICK
	log_debug("set_ftl_turf_open took [(world.timeofday - time) / 10]s")
	crashed = TRUE

	shakeship(
		sstrength = 8,
		stime = 5,
		drop = TRUE,
	)
	explode_pumps()
	time = world.timeofday
	crack_open_ship(SAFEPICK(ship_map_config?.crack_open_horizontal_positions))
	log_debug("crack_open_ship took [(world.timeofday - time) / 10]s")
	explode_apcs(50)

	if(!admin_sd_blocked && MODE_HAS_MODIFIER(/datum/gamemode_modifier/continue_on_ground_crash))
		addtimer(CALLBACK(src, PROC_REF(unlock_self_destruct), FALSE), 15 SECONDS)

/// Called to explode the apcs with probability (so more shipwide damage)
/datum/controller/subsystem/hijack/proc/explode_apcs(chance=50)
	var/cause_data = create_cause_data("ship explosion")
	for(var/obj/structure/machinery/power/apc/apc as anything in apcs)
		var/turf/apc_turf = get_turf(apc)
		if(apc_turf && apc.crash_break_probability && prob(chance))
			cell_explosion(apc_turf, 30, 5, explosion_cause_data=cause_data, enviro=TRUE)
			CHECK_TICK

/// Called to crack open turfs (including hull) on the mainship level at a particular x to open_space
/datum/controller/subsystem/hijack/proc/crack_open_ship(x)
	// Figure out bottom of the ship
	var/current_z = SSmapping.levels_by_trait(ZTRAIT_MARINE_MAIN_SHIP)[1]
	var/offset = SSmapping.level_trait(current_z, ZTRAIT_DOWN)
	while(offset)
		current_z += offset
		offset = SSmapping.level_trait(current_z, ZTRAIT_DOWN)

	// Go up one and iterate (first floor may open up bottom floor)
	var/first_floor = /turf/open/floor/almayer/fake_outerhull
	var/second_floor = null
	offset = SSmapping.level_trait(current_z, ZTRAIT_UP)
	while(offset)
		current_z += offset
		offset = SSmapping.level_trait(current_z, ZTRAIT_UP)

		// For every turf in the line:
		for(var/turf/current in block(x, 1, current_z, x, world.maxy, current_z))
			if(istype(current, /turf/open_space))
				continue
			if(istype(current, /turf/open/space))
				continue
			if(locate(/obj/structure/machinery/door/airlock/evacuation) in current)
				continue
			if(locate(/obj/structure/ladder/multiz) in current)
				continue

			// Creak if its a wall (but abort this iteration if its a shuttle)
			if(istype(current, /turf/closed))
				if(istype(current, /turf/closed/shuttle))
					continue
				var/creak_picked = pick('sound/effects/creak1.ogg', 'sound/effects/creak2.ogg', 'sound/effects/creak3.ogg')
				playsound(current, creak_picked)

			// Crack open turfs
			var/leak = prob(5)
			current = crack_open_turf(current, first_floor, second_floor)
			crack_open_side(current, WEST, leak, first_floor, second_floor)
			crack_open_side(current, EAST, leak, first_floor, second_floor)
			CHECK_TICK

		second_floor = null
		if(first_floor)
			// second floor might be walkable
			second_floor = /turf/open/walkable_lattice
		first_floor = null

/// Helper proc for crack_open_ship to handle a particular side to spread a crack
/datum/controller/subsystem/hijack/proc/crack_open_side(turf/target, direction, leak, first_floor, second_floor)
	// Check and then spread crack if possible
	var/turf/current_turf = target
	do
		var/previous_turf = current_turf
		current_turf = get_step(current_turf, direction)
		if(istype(current_turf, /turf/open_space))
			current_turf = previous_turf
			break
		if(istype(current_turf, /turf/open/space))
			current_turf = previous_turf
			break
		if(istype(current_turf, /turf/closed/shuttle))
			current_turf = previous_turf
			break
		if(locate(/obj/structure/machinery/door/airlock/evacuation) in current_turf)
			current_turf = previous_turf
			break
		if(locate(/obj/structure/ladder/multiz) in current_turf)
			current_turf = previous_turf
			break
		current_turf = crack_open_turf(current_turf, first_floor, second_floor)
		var/turf/below_previous = SSmapping.get_turf_below(previous_turf)
		if(istype(below_previous, /turf/closed))
			below_previous.ScrapeAway() // Try not to trap people that fall on walls
	while(prob(25))

	// Optionally leak water
	if(leak)
		var/opposite_dir = GLOB.reverse_dir[direction]
		var/x_adjust = 0
		var/y_adjust = 0
		switch(opposite_dir)
			if(NORTH)
				y_adjust = 5
			if(SOUTH)
				y_adjust = -5
			if(WEST)
				x_adjust = 5
			if(EAST)
				x_adjust = -5
		var/obj/structure/prop/invuln/pipe_water/water = new(current_turf)
		water.dir = opposite_dir
		water.pixel_x += x_adjust
		water.pixel_y += y_adjust
		var/turf/below = SSmapping.get_turf_below(current_turf)
		var/transparent = TRUE
		while(below && transparent)
			water = new(below)
			water.pixel_x += x_adjust
			water.pixel_y += y_adjust
			transparent = istransparentturf(below)
			below = SSmapping.get_turf_below(below)

	return current_turf

/// Helper proc for crack_open_ship to handle a particular turf
/datum/controller/subsystem/hijack/proc/crack_open_turf(turf/target, make_below_walkable_type, make_current_walkable_type)
	// Delete stuff that would be weird to fall
	var/metal_junk = 0
	var/glass_junk = 0
	for(var/obj/structure/machinery/machine in target)
		qdel(machine)
		metal_junk++
		glass_junk++
	for(var/obj/structure/platform/platform in target)
		qdel(platform)
		metal_junk++
	for(var/obj/structure/platform_decoration/deco in target)
		qdel(deco)
		metal_junk++
	for(var/obj/structure/window/window in target)
		qdel(window)
		glass_junk++
	for(var/obj/structure/mineral_door/door in target)
		qdel(door)
	for(var/obj/structure/bed/bed in target)
		if(prob(75))
			qdel(bed)
			metal_junk++
		else if(istype(bed, /obj/structure/bed/nest))
			qdel(bed)
	for(var/obj/effect/alien/alien_stuff in target)
		qdel(alien_stuff)
	for(var/obj/structure/pipes/pipe in target)
		qdel(pipe)
		metal_junk++
	for(var/obj/structure/sign/sign in target)
		qdel(sign)
	for(var/obj/structure/sink/sink in target)
		qdel(sink)
		metal_junk++
	for(var/obj/structure/toilet/toilet in target)
		qdel(toilet)
	for(var/obj/structure/prop/almayer/computers/prop_computer in target)
		qdel(prop_computer)
		metal_junk++

	// Spawn some junk
	if(metal_junk)
		var/obj/metal = new /obj/item/stack/sheet/metal(target)
		metal.pixel_x = rand(-8, 8)
		metal.pixel_y = rand(-8, 8)
	if(glass_junk || prob(15))
		new /obj/item/shard(target)

	// Spawn some effects
	if(prob(15))
		new /obj/effect/particle_effect/smoke(target)
	if(prob(15))
		new /obj/flamer_fire(target)

	// Optionally make closed turfs below target walkable
	if(make_below_walkable_type)
		var/turf/below = SSmapping.get_turf_below(target)
		if(istype(below, /turf/closed))
			below.ChangeTurf(make_below_walkable_type)

	// Optionally make target walkable instead of open_space
	if(make_current_walkable_type && prob(90) && istype(target, /turf/open))
		target = target.ChangeTurf(make_current_walkable_type)
		return target

	// Make target open_space (which will chuck stuff down)
	var/turf/open_space/space = target.ChangeTurf(/turf/open_space)

	return space

//~~~~~~~~~~~~~~~~~~~~~~~~ FTL STUFF ~~~~~~~~~~~~~~~~~~~~~~~~//

/// Delayed call to enter_ftl with announcement
/datum/controller/subsystem/hijack/proc/initiate_ftl_charge()
	if(sd_route_selected)
		return FALSE

	in_ftl = TRUE
	in_ftl_time = world.time

	// Return to sender any shuttles already in transit to the ship
	for(var/obj/docking_port/mobile/marine_dropship/shuttle as anything in SSshuttle.mobile)
		if(shuttle.destination && is_mainship_level(shuttle.destination.z))
			shuttle.destination = shuttle.previous

	// Disable all non-pod/elevator pads
	unlock_all_dropship_doors() // Unlock doors because they'll be uninteractable
	disallow_dropship_pad_landing()

	marine_announcement("Initiating quantum jump. Opening virtual mass field. Lifeboats and pods disabled until arrival.", HIJACK_ANNOUNCE, sound('sound/mecha/powerup.ogg'))
	play_sfx_for_shipside_xenos('sound/mecha/powerup.ogg')

	addtimer(CALLBACK(src, PROC_REF(enter_ftl)), 5 SECONDS)

/// Updates a specific space turf to have the speedspace animation
/datum/controller/subsystem/hijack/proc/set_ftl_turf(turf/open/space/space_turf)
	var/which_turf = ((space_turf.x - 9 * space_turf.y) % 15) + 1
	if(which_turf < 1)
		which_turf += 15
	space_turf.icon_state = "speedspace_ew_[which_turf]"

/// Updates a specific space turf to return back to regular space
/datum/controller/subsystem/hijack/proc/unset_ftl_turf(turf/open/space/space_turf)
	space_turf.icon_state = "[((space_turf.x + space_turf.y) ^ ~(space_turf.x * space_turf.y) + space_turf.z) % 25]"

/// Updates a specific space turf to either become black or an open_space turf depending on distance to the main ship
/datum/controller/subsystem/hijack/proc/set_ftl_turf_open(turf/open/space/space_turf)
	var/adjusted_x = space_turf.x - ship_origin_x
	var/adjusted_y = space_turf.y - ship_origin_y
	// Attempt to keep approx 15 each direction of open_space
	if(!open_space_bounds || adjusted_x < open_space_bounds[OPEN_SPACE_BOUNDS_MINX] || adjusted_x > open_space_bounds[OPEN_SPACE_BOUNDS_MAXX] || adjusted_y < open_space_bounds[OPEN_SPACE_BOUNDS_MINY] || adjusted_y > open_space_bounds[OPEN_SPACE_BOUNDS_MAXY])
		// Don't bother with open_space further out
		space_turf.icon_state = "black"
		return
	space_turf.ChangeTurf(/turf/open_space/ground_level)

/// Called to enter FTP warp
/datum/controller/subsystem/hijack/proc/enter_ftl()
	shakeship(
		sstrength = 2,
		stime = 1,
		drop = FALSE,
		osound = FALSE
	)

	var/list/ship_zs = SSmapping.levels_by_trait(ZTRAIT_MARINE_MAIN_SHIP)
	for(var/z_level in ship_zs)
		for(var/turf/open/space/space_turf in Z_TURFS(z_level))
			set_ftl_turf(space_turf)
			CHECK_TICK

	shipwide_ai_announcement("ALERT: Prolonged exposure outside hypersleep chambers during a tachyon quantum jump can be fatal. Seek hypersleep chambers if possible.", HIJACK_ANNOUNCE)

/// Called when FTL has failed
/datum/controller/subsystem/hijack/proc/initiate_ftl_crash()
	hijack_status = HIJACK_OBJECTIVES_FTL_CRASH
	shipwide_ai_announcement("Tachyon quantum jump drive deactivated due to insufficient fueling. Brace for destabilization of hyperdrive field.", HIJACK_ANNOUNCE, sound('sound/mecha/internaldmgalarm.ogg'))
	play_sfx_for_shipside_xenos('sound/mecha/internaldmgalarm.ogg')

	addtimer(CALLBACK(src, PROC_REF(leave_ftl), TRUE), 5 SECONDS)
	if(GLOB.security_level < SEC_LEVEL_RED)
		set_security_level(SEC_LEVEL_RED, no_sound = TRUE, announce = FALSE)

	if(!admin_sd_blocked)
		addtimer(CALLBACK(src, PROC_REF(unlock_self_destruct), TRUE), 30 SECONDS)

/// Called to leave FTL warp potentionally unintentionally with more destructive effects
/datum/controller/subsystem/hijack/proc/leave_ftl(unintentionally = FALSE)
	in_ftl = FALSE
	current_run_mobs.Cut()

	var/list/ship_zs = SSmapping.levels_by_trait(ZTRAIT_MARINE_MAIN_SHIP)
	for(var/z_level in ship_zs)
		for(var/turf/open/space/space_turf in Z_TURFS(z_level))
			unset_ftl_turf(space_turf)
			CHECK_TICK

	// Allow pads to work again except marine_dropship pads
	allow_dropship_pad_landing()

	if(!unintentionally)
		shakeship(
			sstrength = 2,
			stime = 1,
			drop = FALSE,
			osound = FALSE
		)
		for(var/mob/mob as anything in GLOB.player_list)
			if(is_mainship_level(mob.z))
				playsound_client(mob.client, sound('sound/effects/supercapacitors_uncharging.ogg'))
		return

	shakeship(
		sstrength = 5,
		stime = 3,
		drop = TRUE,
	)

	for(var/mob/mob as anything in GLOB.player_list)
		if(is_mainship_level(mob.z))
			playsound_client(mob.client, sound('sound/effects/supercapacitors_uncharging.ogg'))

	explode_pumps_with_warning(10 SECONDS)

/// Warn exploding pumps
/datum/controller/subsystem/hijack/proc/explode_pumps_with_warning(time_till = 10 SECONDS)
	shipwide_ai_announcement("ALERT: Build up detected within pumping systems. Overload in [DisplayTimeText(time_till)].", HIJACK_ANNOUNCE, sound('sound/effects/double_klaxon.ogg'))
	play_sfx_for_shipside_xenos('sound/effects/double_klaxon.ogg')
	addtimer(CALLBACK(src, PROC_REF(explode_pumps)), time_till)
	for(var/key,value in SShijack.area_machinery_lookup)
		var/obj/structure/machinery/machine = value
		playsound(machine, 'sound/effects/pipe_hissing.ogg', vol = 40)
		machine.visible_message(SPAN_HIGHDANGER("[machine] begins hissing violently!"))
		for(var/turf/position in machine.locs)
			new /obj/effect/warning/explosive(position, time_till)

/// Called to explode the fuel pumps
/datum/controller/subsystem/hijack/proc/explode_pumps()
	var/datum/space_weapon_ammo/rocket_launcher/swing_rockets/rockets = new
	rockets.name = "ship explosion"
	for(var/key,machine in SShijack.area_machinery_lookup)
		rockets.hit_target(get_turf(machine), shake=FALSE)
	qdel(rockets)

/// Called when FTL is completed successfully to load in shuttles
/datum/controller/subsystem/hijack/proc/initiate_docking_procedures()
	var/list/options = list(/obj/docking_port/stationary/emergency_response/external/hangar_port, /obj/docking_port/stationary/emergency_response/external/hangar_starboard)
	var/obj/docking_port/stationary/stationary
	var/datum/map_template/shuttle
	while(length(options) && (!shuttle || !stationary))
		var/obj/docking_port/stationary/dock_at = pick_n_take(options)
		stationary = SSshuttle.getDock(dock_at::id)
		if(!stationary || stationary.get_docked())
			stationary = null
			continue

		switch(dock_at)
			if(/obj/docking_port/stationary/emergency_response/external/hangar_port)
				shuttle = SSmapping.shuttle_templates[/datum/map_template/shuttle/port_umbilical_cord::shuttle_id]
			if(/obj/docking_port/stationary/emergency_response/external/hangar_starboard)
				shuttle = SSmapping.shuttle_templates[/datum/map_template/shuttle/starboard_umbilical_cord::shuttle_id]

	if(!shuttle || !stationary)
		message_admins("initiate_docking_procedures failed to create an umbilical cord dock!")
		return

	hijack_status = HIJACK_OBJECTIVES_DOCKED
	shipwide_ai_announcement(spaceport.docking_message, spaceport.name, sound('sound/misc/notice2.ogg'))
	SSshuttle.action_load(shuttle, stationary)
