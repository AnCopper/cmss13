//Independent Frontier Medics
/datum/emergency_call/ifm
	name = "Independent Frontier Medics (Team)"
	mob_max = 8
	probability = 12
	hostility = FALSE
	var/max_synths = 1
	var/synths = 0


/datum/emergency_call/ifm/New()
	. = ..()
	arrival_message = "'STSV Gentle Hands with the Independent Frontier Medics to USS [MAIN_SHIP_NAME]. We have received your distress signal but have not heard an answer to our hail. We are dispatching a medical team to render humanitarian aid."
	objectives = "Establish a triage point, treat the wounded regardless of affiliation, and evacuate your team if the situation becomes untenable."


/datum/emergency_call/ifm/print_backstory(mob/living/carbon/human/H)
	if(ishuman_strict(H))
		to_chat(H, SPAN_BOLD("You were born [pick(20;"in the outer colonies", 30;"on Earth", 15;"on a frontier station", 20;"in the UA core systems", 15;"on a space ship")] to a [pick(40;"poor", 20;"well-off", 40;"average")] family."))
		to_chat(H, SPAN_BOLD("You joined the Independent Frontier Medics because [pick(20;"you believe people deserve medical care regardless of who they are or what flag they fly", 20;"you lost someone in a conflict that had no medical response and swore it wouldn't happen again", 15;"you washed out of USCM service and found a better use for your skills out here", 20;"frontier medicine felt more honest than anything a corporate contract could offer", 15;"you grew up in a colony and saw firsthand what no access to medical care does to a community", 10;"after the Sutter's World incident, you decided someone had to fill the gap the USCM wouldn't")]."))
	else
		to_chat(H, SPAN_BOLD("You were assembled at Anchorpoint Station, where the IFM maintains its headquarters, and assigned to the STSV Gentle Hands as a medical support synthetic."))
	to_chat(H, SPAN_BOLD("Your core directives are surgical assistance, triage, and patient stabilisation. You have no combat protocols."))

	to_chat(H, SPAN_BOLD("The Independent Frontier Medics operate as a non-government organisation providing medical aid to whoever is in need, the IFM does not take sides. It never has."))
	to_chat(H, SPAN_BOLD("You carry a medical kit, not a weapon. Your security contractors are there so you do not have to."))
	to_chat(H, SPAN_BOLD("in 2176, A CLF cell hit an IFM field hospital over perceived corporate allegiances. Three of your colleagues did not come home. Ever since then the IFM brings security guards with their teams."))
	to_chat(H, SPAN_BOLD("You are currently aboard the STSV Gentle Hands, an Ami-Class hospital ship assigned to a routine resupply run through the Neroid Sector."))
	to_chat(H, SPAN_BOLD("Your ships comms officer intercepted a distress signal from the USCM vessel [MAIN_SHIP_NAME]. The signal had no information attached to it, and no details on the nature of the emergency. Almayer command is not responding to your hails."))
	to_chat(H, SPAN_BOLD("The CMO has made the call to board. You don't know what is on that ship. You don't know if whatever caused the distress is still active."))
	to_chat(H, SPAN_BOLD("What you know is that if there are wounded over there, they need someone who can treat them. That is what you are here for."))

	to_chat(H, SPAN_WARNING(FONT_SIZE_HUGE("YOU ARE NEUTRAL. Treat all wounded regardless of affiliation. Do NOT engage hostiles.")))




/datum/emergency_call/ifm/create_member(datum/mind/M, turf/override_spawn_loc)
	var/turf/spawn_loc = override_spawn_loc ? override_spawn_loc : get_spawn_point()

	if(!istype(spawn_loc))
		return

	var/mob/living/carbon/human/H = new(spawn_loc)
	M.transfer_to(H, TRUE)

	if(!leader && HAS_FLAG(H.client.prefs.toggles_ert, PLAY_LEADER) && check_timelock(H.client, JOB_SQUAD_LEADER, time_required_for_job))
		leader = H
		to_chat(H, SPAN_ROLE_HEADER("You are the Chief Medical Officer of the Independent Frontier Medics boarding team."))
		to_chat(H, SPAN_BOLD("Your team consists of field medics, at least one security contractor, and possibly a synthetic. They are your responsibility."))
		to_chat(H, SPAN_BOLD("You have final authority over your personnel and your triage point. Not over the marines. Not over the ship."))
		arm_equipment(H, /datum/equipment_preset/ifm/cmo, TRUE, TRUE)
	else if(synths < max_synths && HAS_FLAG(H.client.prefs.toggles_ert, PLAY_SYNTH) && H.client.check_whitelist_status(WHITELIST_SYNTHETIC))
		synths++
		to_chat(H, SPAN_ROLE_HEADER("You are a Medical Synthetic assigned to the Independent Frontier Medics boarding team."))
		to_chat(H, SPAN_BOLD("You answer to the CMO. Follow their directions. Assist the medics. Keep people alive."))
		to_chat(H, SPAN_BOLD("You have no combat protocols. You are not expected to fight."))
		arm_equipment(H, /datum/equipment_preset/synth/ifm, TRUE, TRUE)
	else if(medics < max_medics && HAS_FLAG(H.client.prefs.toggles_ert, PLAY_MEDIC) && check_timelock(H.client, JOB_SQUAD_MEDIC, time_required_for_job))
		medics++
		to_chat(H, SPAN_ROLE_HEADER("You are a Field Medic of the Independent Frontier Medics boarding team."))
		to_chat(H, SPAN_BOLD("Your job is to locate the wounded, stabilise them, and get them back to the triage point. Move fast and stay close to the team."))
		to_chat(H, SPAN_BOLD("You do not engage hostiles. If the fighting reaches you, fall back immediately to the triage point or the shuttle."))
		to_chat(H, SPAN_BOLD("Do not stay behind for a patient you cannot move. The CMO's retreat order is final."))
		arm_equipment(H, /datum/equipment_preset/ifm/medic, TRUE, TRUE)
	else if(heavies < max_heavies && HAS_FLAG(H.client.prefs.toggles_ert, PLAY_HEAVY) && check_timelock(H.client, JOB_SQUAD_SPECIALIST, time_required_for_job))
		heavies++
		to_chat(H, SPAN_ROLE_HEADER("You are a Security Contractor assigned to protect the Independent Frontier Medics boarding team."))
		to_chat(H, SPAN_BOLD("You are not a soldier. Your sole job is to protect the IFM doctors so they can do their job without getting killed."))
		to_chat(H, SPAN_BOLD("If something threatens the team, get your people behind you and get them moving. Break contact. Do not chase or hold a line you cannot hold."))
		to_chat(H, SPAN_BOLD("When the CMO calls a retreat, you are the last one through the door. Make sure everyone else got there first."))
		arm_equipment(H, /datum/equipment_preset/ifm/security, TRUE, TRUE)
	else
		to_chat(H, SPAN_ROLE_HEADER("You are a Field Medic of the Independent Frontier Medics boarding team."))
		to_chat(H, SPAN_BOLD("Your job is to locate the wounded, stabilise them, and get them back to the triage point. Move fast and stay close to the team."))
		to_chat(H, SPAN_BOLD("You do not engage hostiles. If the fighting reaches you, fall back immediately to the triage point or the shuttle."))
		to_chat(H, SPAN_BOLD("Do not stay behind for a patient you cannot move. The CMO's retreat order is final."))
		arm_equipment(H, /datum/equipment_preset/ifm/medic, TRUE, TRUE)
	print_backstory(H)

	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(to_chat), H, SPAN_BOLD("Objectives: [objectives]")), 1 SECONDS)



/datum/emergency_call/ifm/platoon
	name = "Independent Frontier Medics (Full Team)"
	mob_min = 6
	mob_max = 14
	probability = 0
	max_medics = 6
	max_heavies = 3
	max_synths = 1
