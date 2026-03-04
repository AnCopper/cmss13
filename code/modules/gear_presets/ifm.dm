/datum/equipment_preset/ifm
	name = "Independent Frontier Medics"
	faction = FACTION_IFM
	job_title = JOB_CMB
	languages = list(LANGUAGE_ENGLISH, LANGUAGE_JAPANESE)
	origin_override = ORIGIN_CIVILIAN
	minimap_background = "background_cmb"
	var/human_versus_human = FALSE
	var/headset_type = /obj/item/device/radio/headset/distress/ifm

/datum/equipment_preset/ifm/New()
	. = ..()
	access = get_access(ACCESS_LIST_UA)

/datum/equipment_preset/cmb/load_name(mob/living/carbon/human/new_human)
	new_human.gender = pick(MALE, FEMALE)
	var/datum/preferences/A = new()
	A.randomize_appearance(new_human)
	var/random_name = random_name(new_human.gender)
	new_human.change_real_name(new_human, random_name)
	new_human.name = new_human.real_name
	new_human.age = rand(20,45)

	var/static/list/colors = list("BLACK" = list(15, 15, 25), "BROWN" = list(102, 51, 0), "AUBURN" = list(139, 62, 19))
	var/static/list/hair_colors = colors.Copy() + list("BLONDE" = list(197, 164, 30), "CARROT" = list(174, 69, 42))
	var/hair_color = pick(hair_colors)
	new_human.r_hair = hair_colors[hair_color][1]
	new_human.g_hair = hair_colors[hair_color][2]
	new_human.b_hair = hair_colors[hair_color][3]
	new_human.r_facial = hair_colors[hair_color][1]
	new_human.g_facial = hair_colors[hair_color][2]
	new_human.b_facial = hair_colors[hair_color][3]
	var/eye_color = pick(colors)
	new_human.r_eyes = colors[eye_color][1]
	new_human.g_eyes = colors[eye_color][2]
	new_human.b_eyes = colors[eye_color][3]
	if(new_human.gender == MALE)
		new_human.h_style = pick("Crewcut", "Shaved Head", "Buzzcut", "Undercut", "Side Undercut", "Pvt. Joker", "Marine Fade", "Low Fade", "Medium Fade", "High Fade", "No Fade", "Coffee House Cut", "Flat Top",)
		new_human.f_style = pick("5 O'clock Shadow", "Shaved", "Full Beard", "3 O'clock Moustache", "5 O'clock Shadow", "5 O'clock Moustache", "7 O'clock Shadow", "7 O'clock Moustache",)
	else
		new_human.h_style = pick("Ponytail 1", "Ponytail 2", "Ponytail 3", "Ponytail 4", "Pvt. Redding", "Pvt. Clarison", "Cpl. Dietrich", "Pvt. Vasquez", "Marine Bun", "Marine Bun 2", "Marine Flat Top",)

/datum/equipment_preset/cmb/load_id(mob/living/carbon/human/new_human, client/mob_client)
	if(human_versus_human)
		var/obj/item/clothing/under/uniform = new_human.w_uniform
		if(istype(uniform))
			uniform.has_sensor = UNIFORM_HAS_SENSORS
	return ..()

//*****************************************************************************************************/

/datum/equipment_preset/cmb/standard
	name = "IFM - Field Doctor"
	paygrades = list(PAY_SHORT_CMBD = JOB_PLAYTIME_TIER_0)
	role_comm_title = "IFM DOC"
	flags = EQUIPMENT_PRESET_EXTRA
	assignment = "CMB Deputy"
	job_title = JOB_CMB

	minimap_icon = "deputy"

	skills = /datum/skills/cmb

/datum/equipment_preset/cmb/standard/load_gear(mob/living/carbon/human/new_human)

	var/choice = rand(1,10)
	new_human.equip_to_slot_or_del(new headset_type, WEAR_L_EAR)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/under/CM_uniform, WEAR_BODY)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/accessory/holobadge/cord, WEAR_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/mask/cigarette, WEAR_FACE)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/CMB, WEAR_JACKET)
	new_human.equip_to_slot_or_del(new /obj/item/device/binoculars, WEAR_IN_JACKET)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/telebaton, WEAR_IN_JACKET)
	new_human.equip_to_slot_or_del(new /obj/item/storage/belt/security/MP/CMB/full, WEAR_WAIST)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/veteran, WEAR_HANDS)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/head/CMB, WEAR_HEAD)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/veteran/pmc/knife, WEAR_FEET)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/glasses/sunglasses/sechud, WEAR_EYES)
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/firstaid/ert, WEAR_L_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/storage/backpack/satchel/sec, WEAR_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/action, WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/device/radio, WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/device/flashlight, WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/device/camera, WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/device/taperecorder, WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/tool/crowbar, WEAR_IN_BACK)

	switch(choice)
		if(1 to 6)
			new_human.equip_to_slot_or_del(new /obj/item/clothing/accessory/storage/holster, WEAR_ACCESSORY)
			new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/revolver/cmb, WEAR_IN_ACCESSORY)
			new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/revolver/cmb/normalpoint, WEAR_IN_ACCESSORY)
			new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/revolver/cmb/normalpoint, WEAR_IN_ACCESSORY)
			new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/shotgun/pump/dual_tube/cmb, WEAR_J_STORE)
			new_human.equip_to_slot_or_del(new /obj/item/restraint/handcuffs/zip, WEAR_IN_BACK)
			new_human.equip_to_slot_or_del(new /obj/item/explosive/grenade/flashbang, WEAR_IN_BACK)
			new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/shotgun/large, WEAR_R_STORE)
			new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/shotgun/buckshot, WEAR_IN_R_STORE)
			new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/shotgun/buckshot, WEAR_IN_R_STORE)
			new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/shotgun/buckshot, WEAR_IN_R_STORE)
			new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/shotgun/buckshot, WEAR_IN_R_STORE)
			new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/shotgun, WEAR_IN_R_STORE)
			new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/shotgun, WEAR_IN_R_STORE)
			new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/shotgun/beanbag, WEAR_IN_R_STORE)
		if(7 to 8)
			new_human.equip_to_slot_or_del(new /obj/item/clothing/accessory/storage/holster, WEAR_ACCESSORY)
			new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/highpower, WEAR_IN_ACCESSORY)
			new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/highpower, WEAR_IN_ACCESSORY)
			new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/highpower, WEAR_IN_ACCESSORY)
			new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/shotgun/pump/dual_tube/cmb, WEAR_J_STORE)
			new_human.equip_to_slot_or_del(new /obj/item/restraint/handcuffs/zip, WEAR_IN_BACK)
			new_human.equip_to_slot_or_del(new /obj/item/explosive/plastic/breaching_charge/rubber, WEAR_IN_BACK)
			new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/shotgun/large, WEAR_R_STORE)
			new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/shotgun/buckshot, WEAR_IN_R_STORE)
			new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/shotgun/buckshot, WEAR_IN_R_STORE)
			new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/shotgun/buckshot, WEAR_IN_R_STORE)
			new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/shotgun/buckshot, WEAR_IN_R_STORE)
			new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/shotgun, WEAR_IN_R_STORE)
			new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/shotgun, WEAR_IN_R_STORE)
			new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/shotgun/beanbag, WEAR_IN_R_STORE)
		if(9 to 10)
			new_human.equip_to_slot_or_del(new /obj/item/clothing/accessory/storage/holster, WEAR_ACCESSORY)
			new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/revolver/cmb, WEAR_IN_ACCESSORY)
			new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/revolver/cmb/normalpoint, WEAR_IN_ACCESSORY)
			new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/revolver/cmb/normalpoint, WEAR_IN_ACCESSORY)
			new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/smg/mp5/mp5a5, WEAR_J_STORE)
			new_human.equip_to_slot_or_del(new /obj/item/restraint/handcuffs/zip, WEAR_IN_BACK)
			new_human.equip_to_slot_or_del(new /obj/item/device/motiondetector, WEAR_L_HAND)
			new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/magazine/large, WEAR_R_STORE)
			new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/mp5, WEAR_IN_R_STORE)
			new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/mp5, WEAR_IN_R_STORE)
			new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/mp5, WEAR_IN_R_STORE)
			new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/mp5, WEAR_IN_R_STORE)


//*****************************************************************************************************/

/datum/equipment_preset/ifm/cmo
	name = "CMB - The Colonial Marshal"
	paygrades = list(PAY_SHORT_CMBM = JOB_PLAYTIME_TIER_0)
	idtype = /obj/item/card/id/marshal
	role_comm_title = "CMB MAR"
	flags = EQUIPMENT_PRESET_EXTRA

	minimap_icon = "xo"

	assignment = "CMB Marshal"
	job_title = JOB_CMB_TL
	skills = /datum/skills/cmb/leader
	minimum_age = 30
	languages = ALL_HUMAN_LANGUAGES

/datum/equipment_preset/ifm/cmo/load_gear(mob/living/carbon/human/new_human)
	//clothes
	new_human.equip_to_slot_or_del(new headset_type, WEAR_L_EAR)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/under/CM_uniform, WEAR_BODY)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/accessory/storage/holster, WEAR_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/revolver/cmb/custom, WEAR_IN_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/revolver/cmb/normalpoint, WEAR_IN_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/revolver/cmb/normalpoint, WEAR_IN_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/accessory/holobadge/cord, WEAR_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/mask/cigarette/cigar, WEAR_FACE)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/CMB/marshal, WEAR_JACKET)
	new_human.equip_to_slot_or_del(new /obj/item/device/binoculars/range, WEAR_IN_JACKET)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/telebaton, WEAR_IN_JACKET)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/shotgun/pump/dual_tube/cmb/m3717, WEAR_J_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/storage/belt/security/MP/CMB/full, WEAR_WAIST)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/veteran, WEAR_HANDS)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/head/CMB, WEAR_HEAD)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/veteran/pmc/knife, WEAR_FEET)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/glasses/sunglasses/sechud, WEAR_EYES)
	//pouches
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/firstaid/ert, WEAR_L_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/shotgun/large, WEAR_R_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/shotgun/buckshot, WEAR_IN_R_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/shotgun/buckshot, WEAR_IN_R_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/shotgun/buckshot, WEAR_IN_R_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/shotgun/buckshot/incendiary, WEAR_IN_R_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/shotgun/incendiary, WEAR_IN_R_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/shotgun, WEAR_IN_R_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/shotgun/beanbag, WEAR_IN_R_STORE)
	//backpack
	new_human.equip_to_slot_or_del(new /obj/item/storage/backpack/satchel/sec, WEAR_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/action, WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/explosive/grenade/high_explosive/m15/rubber, WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/handheld_distress_beacon/cmb, WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/device/radio, WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/device/flashlight, WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/device/camera, WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/device/taperecorder, WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/tool/crowbar, WEAR_IN_BACK)

/datum/equipment_preset/synth/ifm
	name = "CMB - Medical Technician"
	paygrades = list(PAY_SHORT_CMBMT = JOB_PLAYTIME_TIER_0)
	idtype = /obj/item/card/id/deputy/riot
	role_comm_title = "CMB MDT"
	flags = EQUIPMENT_PRESET_EXTRA

	minimap_icon = "medic"

	assignment = "CMB Medical Technician"
	job_title = JOB_CMB_MED
	skills = /datum/skills/cmb/medic

/datum/equipment_preset/synth/ifm/load_gear(mob/living/carbon/human/new_human)
	//clothes
	new_human.equip_to_slot_or_del(new /obj/item/device/radio/headset/distress/ifm(new_human), WEAR_L_EAR)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/under/marine/veteran/cmb, WEAR_BODY)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/accessory/storage/surg_vest/equipped, WEAR_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/accessory/armband/medgreen, WEAR_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/accessory/holobadge/cord, WEAR_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/marine/veteran/cmb/light, WEAR_JACKET)
	new_human.equip_to_slot_or_del(new /obj/item/storage/box/mre, WEAR_IN_JACKET)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/mp5, WEAR_IN_JACKET)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/mp5, WEAR_IN_JACKET)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/smg/mp5/mp5a5/tactical, WEAR_J_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/veteran, WEAR_HANDS)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/mask/rebreather/scarf, WEAR_FACE)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/head/CMB/beret, WEAR_HEAD)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/veteran/pmc/knife, WEAR_FEET)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/glasses/hud/health, WEAR_EYES)
	//belt
	new_human.equip_to_slot_or_del(new /obj/item/storage/belt/medical/full, WEAR_WAIST)
	new_human.equip_to_slot_or_del(new /obj/item/device/defibrillator, WEAR_IN_BELT)
	new_human.equip_to_slot_or_del(new /obj/item/roller, WEAR_IN_BELT)
	//pouches
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/medical/socmed/not_op, WEAR_L_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/magazine/large, WEAR_R_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/mp5, WEAR_IN_R_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/mp5, WEAR_IN_R_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/mp5, WEAR_IN_R_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/mp5, WEAR_IN_R_STORE)
	//backpack
	new_human.equip_to_slot_or_del(new /obj/item/storage/backpack/molle, WEAR_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/explosive/grenade/high_explosive/m15/rubber, WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/device/radio, WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/baton, WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/storage/firstaid/adv, WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/restraint/handcuffs/zip, WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/restraint/handcuffs/zip, WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/tool/crowbar/tactical, WEAR_IN_BACK)

/datum/equipment_preset/ifm/medic
	name = "CMB - Breaching Technician"
	paygrades = list(PAY_SHORT_CMBBT = JOB_PLAYTIME_TIER_0)
	idtype = /obj/item/card/id/deputy/riot
	role_comm_title = "CMB BT"
	flags = EQUIPMENT_PRESET_EXTRA

	minimap_icon = "engi"

	assignment = "CMB Breaching Technician"
	job_title = JOB_CMB_ENG
	skills = /datum/skills/cmb/engi

/datum/equipment_preset/ifm/medic/load_gear(mob/living/carbon/human/new_human)
	//clothes
	new_human.equip_to_slot_or_del(new headset_type, WEAR_L_EAR)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/under/marine/veteran/cmb, WEAR_BODY)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/accessory/storage/tool_webbing/equipped, WEAR_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/accessory/holobadge/cord, WEAR_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/marine/veteran/cmb, WEAR_JACKET)
	new_human.equip_to_slot_or_del(new /obj/item/storage/box/mre, WEAR_IN_JACKET)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/m16/ext, WEAR_IN_JACKET)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/m16/ext, WEAR_IN_JACKET)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/veteran, WEAR_HANDS)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/mask/rebreather/scarf, WEAR_FACE)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/m16/m16a5/tactical, WEAR_J_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine/veteran/cmb/engi, WEAR_HEAD)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/veteran/pmc/knife, WEAR_FEET)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/glasses/sunglasses/sechud/tactical, WEAR_EYES)
	//belt
	new_human.equip_to_slot_or_del(new /obj/item/storage/belt/gun/xm51/black/cmb, WEAR_WAIST)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/xm51/cmb, WEAR_IN_BELT)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/xm51/cmb, WEAR_IN_BELT)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/xm51/cmb/rubber, WEAR_IN_BELT)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/shotgun/light/breaching, WEAR_IN_BELT)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/shotgun/light/breaching, WEAR_IN_BELT)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/shotgun/light/breaching, WEAR_IN_BELT)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/shotgun/light/breaching/rubber, WEAR_IN_BELT)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/shotgun/light/breaching/rubber, WEAR_IN_BELT)
	//pouches
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/firstaid/ert, WEAR_L_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/magazine/large/m16, WEAR_R_STORE)
	//backpack
	new_human.equip_to_slot_or_del(new /obj/item/storage/backpack/marine/engineerpack/ert, WEAR_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/storage/toolkit/tactical, WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/explosive/grenade/high_explosive/m15/rubber, WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/device/radio, WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/baton, WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/restraint/handcuffs/zip, WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/restraint/handcuffs/zip, WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/stack/sheet/metal/large_stack, WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/stack/sheet/plasteel/large_stack, WEAR_IN_BACK)
//*****************************************************************************************************/

/datum/equipment_preset/ifm/security
	name = "CMB - SWAT Specialist"
	paygrades = list(PAY_SHORT_CMBSWS = JOB_PLAYTIME_TIER_0)
	idtype = /obj/item/card/id/deputy/riot
	role_comm_title = "CMB Spec"
	flags = EQUIPMENT_PRESET_EXTRA

	minimap_icon = "cmb_spc"

	assignment = "CMB SWAT Specialist"
	job_title = JOB_CMB_SWAT
	skills = /datum/skills/cmb/spec

/datum/equipment_preset/ifm/security/load_gear(mob/living/carbon/human/new_human)
	//clothes
	new_human.equip_to_slot_or_del(new headset_type, WEAR_L_EAR)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/under/marine/veteran/cmb, WEAR_BODY)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/accessory/storage/webbing/five_slots, WEAR_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/m16, WEAR_IN_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/m16, WEAR_IN_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/m16, WEAR_IN_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/m16, WEAR_IN_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/m16, WEAR_IN_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/accessory/holobadge/cord, WEAR_ACCESSORY)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/marine/veteran/cmb/spec, WEAR_JACKET)
	new_human.equip_to_slot_or_del(new /obj/item/storage/box/mre, WEAR_IN_JACKET)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/m16/ext, WEAR_IN_JACKET)
	new_human.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/m16/ext, WEAR_IN_JACKET)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/veteran, WEAR_HANDS)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/mask/rebreather/scarf, WEAR_FACE)
	new_human.equip_to_slot_or_del(new /obj/item/weapon/gun/rifle/xm177/car15a3/tactical, WEAR_J_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine/veteran/cmb/spec, WEAR_HEAD)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/veteran/pmc/knife, WEAR_FEET)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/glasses/sunglasses/sechud/tactical, WEAR_EYES)
	//belt
	new_human.equip_to_slot_or_del(new /obj/item/storage/belt/gun/m4a3/m1911/socom/black, WEAR_WAIST)
	//pouches
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/firstaid/ert, WEAR_L_STORE)
	new_human.equip_to_slot_or_del(new /obj/item/storage/pouch/tools/tactical/sec/full, WEAR_R_STORE)
	//backpack
	new_human.equip_to_slot_or_del(new /obj/item/storage/backpack/molle, WEAR_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/explosive/grenade/high_explosive/m15/rubber, WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/device/radio, WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/device/binoculars, WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/device/motiondetector/m717, WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/tool/crowbar/tactical, WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/explosive/plastic/breaching_charge/rubber, WEAR_IN_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/storage/box/packet/smoke, WEAR_IN_BACK)
