//------------ CC CLOTHING VENDOR---------------

GLOBAL_LIST_INIT(cm_vending_clothing_combat_correspondent, list(
	list("STANDARD EQUIPMENT (TAKE ALL)", 0, null, null, null),
	list("Essential Reporter's Set", 0, /obj/effect/essentials_set/cc, MARINE_CAN_BUY_ESSENTIALS, VENDOR_ITEM_MANDATORY),
	list("Press Broadcasting Camera", 0, /obj/item/device/broadcasting, MARINE_CAN_BUY_SECONDARY, VENDOR_ITEM_RECOMMENDED),
	list("Spare Broadcasting Camera", 0, /obj/item/device/broadcasting, CORRESPONDENT_CAN_BUY_CAMERA, VENDOR_ITEM_RECOMMENDED),
))

GLOBAL_LIST_INIT(cm_vending_clothing_combat_correspondent_refills, list(
	list("REFILLS", 0, null, null, null),
	list("Camera", 10, /obj/item/device/camera, null, VENDOR_ITEM_REGULAR),
	list("Camera Film", 5, /obj/item/device/camera_film, null, VENDOR_ITEM_REGULAR),
	list("Toner", 5, /obj/item/device/toner, null, VENDOR_ITEM_REGULAR),
	list("Regulation Tapes", 15, /obj/item/storage/box/tapes, null, VENDOR_ITEM_REGULAR),
	list("Paper Bin", 10, /obj/item/paper_bin/uscm, null, VENDOR_ITEM_REGULAR),
))

GLOBAL_LIST_INIT(cm_vending_clothing_civilian_correspondent, list(
	list("CIVILIAN PRESS EQUIPMENT", 0, null, null, null),
	list("Portable Press Fax Machine", 0, /obj/item/device/fax_backpack, CIVILIAN_CAN_BUY_BACKPACK, VENDOR_ITEM_RECOMMENDED),
	list("Leather Satchel", 0, /obj/item/storage/backpack/satchel, CIVILIAN_CAN_BUY_BACKPACK, VENDOR_ITEM_REGULAR),
	list("CIVILIAN OUTFIT (CHOOSE 5)", 0, null, null, null),
	list("Black Uniform", 0, /obj/item/clothing/under/marine/reporter/black, CIVILIAN_CAN_BUY_UNIFORM, VENDOR_ITEM_RECOMMENDED),
	list("Orange Uniform", 0, /obj/item/clothing/under/marine/reporter/orange, CIVILIAN_CAN_BUY_UNIFORM, VENDOR_ITEM_REGULAR),
	list("Red Uniform", 0, /obj/item/clothing/under/marine/reporter/red, CIVILIAN_CAN_BUY_UNIFORM, VENDOR_ITEM_REGULAR),
	list("Worn Suit", 0, /obj/item/clothing/under/detective/neutral, CIVILIAN_CAN_BUY_UNIFORM, VENDOR_ITEM_REGULAR),
	list("Grey Suit", 0, /obj/item/clothing/under/detective/grey, CIVILIAN_CAN_BUY_UNIFORM, VENDOR_ITEM_REGULAR),
	list("Black Tailored Suit", 0, /obj/item/clothing/under/suit_jacket, CIVILIAN_CAN_BUY_UNIFORM, VENDOR_ITEM_REGULAR),
	list("Navy Tailored Suit", 0, /obj/item/clothing/under/suit_jacket/navy, CIVILIAN_CAN_BUY_UNIFORM, VENDOR_ITEM_REGULAR),
	list("Black Skirt", 0, /obj/item/clothing/under/blackskirt, CIVILIAN_CAN_BUY_UNIFORM, VENDOR_ITEM_REGULAR),
	list("Black Suitskirt", 0, /obj/item/clothing/under/liaison_suit/black/skirt, CIVILIAN_CAN_BUY_UNIFORM, VENDOR_ITEM_REGULAR),
	list("Corporate Casual", 0, /obj/item/clothing/under/liaison_suit/field, CIVILIAN_CAN_BUY_UNIFORM, VENDOR_ITEM_REGULAR),
	list("Corporate Casual Skirt", 0, /obj/item/clothing/under/liaison_suit/field/skirt, CIVILIAN_CAN_BUY_UNIFORM, VENDOR_ITEM_REGULAR),
	list("Simple White Shirt and Black Pants", 0, /obj/item/clothing/under/sl_suit, CIVILIAN_CAN_BUY_UNIFORM, VENDOR_ITEM_REGULAR),
	list("Grey Workwear", 0, /obj/item/clothing/under/colonist/workwear, CIVILIAN_CAN_BUY_UNIFORM, VENDOR_ITEM_REGULAR),
	list("Khaki Workwear", 0, /obj/item/clothing/under/colonist/workwear/khaki, CIVILIAN_CAN_BUY_UNIFORM, VENDOR_ITEM_REGULAR),
	list("Pink Workwear", 0, /obj/item/clothing/under/colonist/workwear/pink, CIVILIAN_CAN_BUY_UNIFORM, VENDOR_ITEM_REGULAR),
	list("Green Workwear", 0, /obj/item/clothing/under/colonist/workwear/green, CIVILIAN_CAN_BUY_UNIFORM, VENDOR_ITEM_REGULAR),
	list("Blue Workwear", 0, /obj/item/clothing/under/colonist/workwear/blue, CIVILIAN_CAN_BUY_UNIFORM, VENDOR_ITEM_REGULAR),
	list("CIVILIAN OUTERWEAR (CHOOSE 5)", 0, null, null, null),
	list("Combat Correspondent's Armor", 0, /obj/item/clothing/suit/storage/marine/light/reporter, CIVILIAN_CAN_BUY_SUIT, VENDOR_ITEM_RECOMMENDED),
	list("Blue Press Vest", 0, /obj/item/clothing/suit/storage/jacket/marine/reporter/blue, CIVILIAN_CAN_BUY_SUIT, VENDOR_ITEM_RECOMMENDED),
	list("Black Press Coat", 0, /obj/item/clothing/suit/storage/jacket/marine/reporter/black, CIVILIAN_CAN_BUY_SUIT, VENDOR_ITEM_REGULAR),
	list("Green Press Coat", 0, /obj/item/clothing/suit/storage/jacket/marine/reporter/green, CIVILIAN_CAN_BUY_SUIT, VENDOR_ITEM_REGULAR),
	list("Green Correspondent Jacket", 0, /obj/item/clothing/suit/storage/jacket/marine/correspondent, CIVILIAN_CAN_BUY_SUIT, VENDOR_ITEM_REGULAR),
	list("Blue Correspondent Jacket", 0, /obj/item/clothing/suit/storage/jacket/marine/correspondent/blue, CIVILIAN_CAN_BUY_SUIT, VENDOR_ITEM_REGULAR),
	list("Tan Correspondent Jacket", 0, /obj/item/clothing/suit/storage/jacket/marine/correspondent/tan, CIVILIAN_CAN_BUY_SUIT, VENDOR_ITEM_REGULAR),
	list("Brown Correspondent Jacket", 0, /obj/item/clothing/suit/storage/jacket/marine/correspondent/brown, CIVILIAN_CAN_BUY_SUIT, VENDOR_ITEM_REGULAR),
	list("Grey Bomber Jacket", 0, /obj/item/clothing/suit/storage/jacket/marine/bomber/grey, CIVILIAN_CAN_BUY_SUIT, VENDOR_ITEM_REGULAR),
	list("Red Bomber Jacket", 0, /obj/item/clothing/suit/storage/jacket/marine/bomber/red, CIVILIAN_CAN_BUY_SUIT, VENDOR_ITEM_REGULAR),
	list("Khaki Bomber Jacket", 0, /obj/item/clothing/suit/storage/jacket/marine/bomber, CIVILIAN_CAN_BUY_SUIT, VENDOR_ITEM_REGULAR),
	list("Brown Windbreaker", 0, /obj/item/clothing/suit/storage/windbreaker/windbreaker_brown, CIVILIAN_CAN_BUY_SUIT, VENDOR_ITEM_REGULAR),
	list("Grey Windbreaker", 0, /obj/item/clothing/suit/storage/windbreaker/windbreaker_gray, CIVILIAN_CAN_BUY_SUIT, VENDOR_ITEM_REGULAR),
	list("Green Windbreaker", 0, /obj/item/clothing/suit/storage/windbreaker/windbreaker_green, CIVILIAN_CAN_BUY_SUIT, VENDOR_ITEM_REGULAR),
	list("Beige Trench Coat", 0, /obj/item/clothing/suit/storage/CMB/trenchcoat, CIVILIAN_CAN_BUY_SUIT, VENDOR_ITEM_REGULAR),
	list("Brown Trench Coat", 0, /obj/item/clothing/suit/storage/CMB/trenchcoat/brown, CIVILIAN_CAN_BUY_SUIT, VENDOR_ITEM_REGULAR),
	list("Grey Trench Coat", 0, /obj/item/clothing/suit/storage/CMB/trenchcoat/grey, CIVILIAN_CAN_BUY_SUIT, VENDOR_ITEM_REGULAR),
	list("CIVILIAN HEADWEAR (CHOOSE 5)", 0, null, null, null),
	list("Combat Correspondent's Helmet", 0, /obj/item/clothing/head/helmet/marine/reporter, CIVILIAN_CAN_BUY_HAT, VENDOR_ITEM_RECOMMENDED),
	list("Combat Correspondent's Cap", 0, /obj/item/clothing/head/cmcap/reporter, CIVILIAN_CAN_BUY_HAT, VENDOR_ITEM_RECOMMENDED),
	list("Tan Beret", 0, /obj/item/clothing/head/beret/civilian, CIVILIAN_CAN_BUY_HAT, VENDOR_ITEM_REGULAR),
	list("Brown Beret", 0, /obj/item/clothing/head/beret/civilian/brown, CIVILIAN_CAN_BUY_HAT, VENDOR_ITEM_REGULAR),
	list("Black Beret", 0, /obj/item/clothing/head/beret/civilian/black, CIVILIAN_CAN_BUY_HAT, VENDOR_ITEM_REGULAR),
	list("White Beret", 0, /obj/item/clothing/head/beret/civilian/white, CIVILIAN_CAN_BUY_HAT, VENDOR_ITEM_REGULAR),
	list("Tan Fedora", 0, /obj/item/clothing/head/fedora, CIVILIAN_CAN_BUY_HAT, VENDOR_ITEM_REGULAR),
	list("Grey Fedora", 0, /obj/item/clothing/head/fedora/grey, CIVILIAN_CAN_BUY_HAT, VENDOR_ITEM_REGULAR),
	list("Brown Fedora", 0, /obj/item/clothing/head/fedora/brown, CIVILIAN_CAN_BUY_HAT, VENDOR_ITEM_REGULAR),
	list("Brown Cowboy Hat", 0, /obj/item/clothing/head/cowboy, CIVILIAN_CAN_BUY_HAT, VENDOR_ITEM_REGULAR),
	list("Light-Brown Cowboy Hat", 0, /obj/item/clothing/head/cowboy/light, CIVILIAN_CAN_BUY_HAT, VENDOR_ITEM_REGULAR),
	list("CIVILIAN ACCESSORIES", 0, null, null, null),
	list("Bronze Aviator Shades", 0, /obj/item/clothing/glasses/sunglasses/aviator, CIVILIAN_CAN_BUY_GLASSES, VENDOR_ITEM_REGULAR),
	list("Silver Aviator Shades", 0, /obj/item/clothing/glasses/sunglasses/aviator/silver, CIVILIAN_CAN_BUY_GLASSES, VENDOR_ITEM_REGULAR),
	list("Sunglasses", 0, /obj/item/clothing/glasses/sunglasses, CIVILIAN_CAN_BUY_GLASSES, VENDOR_ITEM_REGULAR),
	list("Prescription Sunglasses", 0, /obj/item/clothing/glasses/sunglasses/prescription, CIVILIAN_CAN_BUY_GLASSES, VENDOR_ITEM_REGULAR),
	list("Prescription Glasses", 0, /obj/item/clothing/glasses/regular/hipster, CIVILIAN_CAN_BUY_GLASSES, VENDOR_ITEM_REGULAR),
	list("Black Laceup Shoes", 0, /obj/item/clothing/shoes/laceup, CIVILIAN_CAN_BUY_SHOES, VENDOR_ITEM_REGULAR),
	list("Brown Laceup Shoes", 0, /obj/item/clothing/shoes/laceup/brown, CIVILIAN_CAN_BUY_SHOES, VENDOR_ITEM_REGULAR),
	list("Fancy Leather Shoes", 0, /obj/item/clothing/shoes/leather/fancy, CIVILIAN_CAN_BUY_SHOES, VENDOR_ITEM_REGULAR),
	list("Black Sneakers", 0, /obj/item/clothing/shoes/black, CIVILIAN_CAN_BUY_SHOES, VENDOR_ITEM_REGULAR),
	list("Black Gloves", 0, /obj/item/clothing/gloves/black, CIVILIAN_CAN_BUY_GLOVES, VENDOR_ITEM_REGULAR),
	list("Brown Gloves", 0, /obj/item/clothing/gloves/brown, CIVILIAN_CAN_BUY_GLOVES, VENDOR_ITEM_REGULAR),
	list("Black Leather Gloves", 0, /obj/item/clothing/gloves/black_leather, CIVILIAN_CAN_BUY_GLOVES, VENDOR_ITEM_REGULAR),
	list("Black Tie", 0, /obj/item/clothing/accessory/tie/black, CIVILIAN_CAN_BUY_ACCESSORY, VENDOR_ITEM_REGULAR),
	list("Red Tie", 0, /obj/item/clothing/accessory/tie/red, CIVILIAN_CAN_BUY_ACCESSORY, VENDOR_ITEM_REGULAR),
	list("Blue Tie", 0, /obj/item/clothing/accessory/tie, CIVILIAN_CAN_BUY_ACCESSORY, VENDOR_ITEM_REGULAR),
	list("Green Tie", 0, /obj/item/clothing/accessory/tie/green, CIVILIAN_CAN_BUY_ACCESSORY, VENDOR_ITEM_REGULAR),
	list("Gold Tie", 0, /obj/item/clothing/accessory/tie/gold, CIVILIAN_CAN_BUY_ACCESSORY, VENDOR_ITEM_REGULAR),
))

GLOBAL_LIST_INIT(cm_vending_clothing_military_correspondent, list(
	list("USCM FIELD EQUIPMENT", 0, null, null, null),
	list("MRE", 0, /obj/item/storage/box/mre, MARINE_CAN_BUY_MRE, VENDOR_ITEM_RECOMMENDED),
	list("USCM Backpack", 0, /obj/item/storage/backpack/marine, MARINE_CAN_BUY_BACKPACK, VENDOR_ITEM_REGULAR),
	list("USCM Satchel", 0, /obj/item/storage/backpack/marine/satchel, MARINE_CAN_BUY_BACKPACK, VENDOR_ITEM_RECOMMENDED),
	list("USCM UNIFORM (CHOOSE 1)", 0, null, null, null),
	list("USCM Uniform", 0, /obj/item/clothing/under/marine, MARINE_CAN_BUY_UNIFORM, VENDOR_ITEM_RECOMMENDED),
	list("Black Reporter Uniform", 0, /obj/item/clothing/under/marine/reporter/black, MARINE_CAN_BUY_UNIFORM, VENDOR_ITEM_REGULAR),
	list("Orange Reporter Uniform", 0, /obj/item/clothing/under/marine/reporter/orange, MARINE_CAN_BUY_UNIFORM, VENDOR_ITEM_REGULAR),
	list("Red Reporter Uniform", 0, /obj/item/clothing/under/marine/reporter/red, MARINE_CAN_BUY_UNIFORM, VENDOR_ITEM_REGULAR),
	list("USCM ARMOR (CHOOSE 1)", 0, null, null, null),
	list("Combat Correspondent's Armor", 0, /obj/item/clothing/suit/storage/marine/light/reporter, MARINE_CAN_BUY_ARMOR, VENDOR_ITEM_RECOMMENDED),
	list("M3 Pattern Light Armor", 0, /obj/item/clothing/suit/storage/marine/light, MARINE_CAN_BUY_ARMOR, VENDOR_ITEM_REGULAR),
	list("USCM Webbing", 0, /obj/item/clothing/suit/storage/webbing, MARINE_CAN_BUY_ARMOR, VENDOR_ITEM_REGULAR),
	list("USCM Service Jacket", 0, /obj/item/clothing/suit/storage/jacket/marine/service, MARINE_CAN_BUY_ARMOR, VENDOR_ITEM_REGULAR),
	list("Black Hazard Vest", 0, /obj/item/clothing/suit/storage/hazardvest/black, MARINE_CAN_BUY_ARMOR, VENDOR_ITEM_REGULAR),
	list("USCM HEADGEAR (CHOOSE 1)", 0, null, null, null),
	list("Combat Correspondent's Helmet", 0, /obj/item/clothing/head/helmet/marine/reporter, MARINE_CAN_BUY_HELMET, VENDOR_ITEM_RECOMMENDED),
	list("M10 Pattern Marine Helmet", 0, /obj/item/clothing/head/helmet/marine, MARINE_CAN_BUY_HELMET, VENDOR_ITEM_REGULAR),
	list("USCM Cap", 0, /obj/item/clothing/head/cmcap, MARINE_CAN_BUY_HELMET, VENDOR_ITEM_REGULAR),
	list("USCM Boonie Hat", 0, /obj/item/clothing/head/cmcap/boonie, MARINE_CAN_BUY_HELMET, VENDOR_ITEM_REGULAR),
	list("USCM Beret", 0, /obj/item/clothing/head/beret/cm, MARINE_CAN_BUY_HELMET, VENDOR_ITEM_REGULAR),
	list("Tan USCM Beret", 0, /obj/item/clothing/head/beret/cm/tan, MARINE_CAN_BUY_HELMET, VENDOR_ITEM_REGULAR),
	list("USCM POUCHES (CHOOSE 2)", 0, null, null, null),
	list("First-Aid Pouch", 0, /obj/item/storage/pouch/firstaid/full, MARINE_CAN_BUY_POUCH, VENDOR_ITEM_REGULAR),
	list("Flare Pouch", 0, /obj/item/storage/pouch/flare/full, MARINE_CAN_BUY_POUCH, VENDOR_ITEM_REGULAR),
	list("Large General Pouch", 0, /obj/item/storage/pouch/general/large, MARINE_CAN_BUY_POUCH, VENDOR_ITEM_REGULAR),
	list("USCM ACCESSORIES", 0, null, null, null),
	list("Marine Combat Boots", 0, /obj/item/clothing/shoes/marine/knife, MARINE_CAN_BUY_SHOES, VENDOR_ITEM_REGULAR),
	list("Marine Combat Gloves", 0, /obj/item/clothing/gloves/marine, MARINE_CAN_BUY_GLOVES, VENDOR_ITEM_REGULAR),
	list("Brown Webbing Vest", 0, /obj/item/clothing/accessory/storage/black_vest/brown_vest, MARINE_CAN_BUY_ACCESSORY, VENDOR_ITEM_REGULAR),
	list("Black Webbing Vest", 0, /obj/item/clothing/accessory/storage/black_vest, MARINE_CAN_BUY_ACCESSORY, VENDOR_ITEM_REGULAR),
	list("Webbing", 0, /obj/item/clothing/accessory/storage/webbing, MARINE_CAN_BUY_ACCESSORY, VENDOR_ITEM_REGULAR),
	list("Black Webbing", 0, /obj/item/clothing/accessory/storage/webbing/black, MARINE_CAN_BUY_ACCESSORY, VENDOR_ITEM_REGULAR),
	list("Drop Pouch", 0, /obj/item/clothing/accessory/storage/droppouch, MARINE_CAN_BUY_ACCESSORY, VENDOR_ITEM_REGULAR),
	list("Black Drop Pouch", 0, /obj/item/clothing/accessory/storage/droppouch/black, MARINE_CAN_BUY_ACCESSORY, VENDOR_ITEM_REGULAR),
	list("USCM MASK (CHOOSE 1)", 0, null, null, null),
	list("Gas Mask", 0, /obj/item/clothing/mask/gas, MARINE_CAN_BUY_MASK, VENDOR_ITEM_REGULAR),
	list("Heat Absorbent Coif", 0, /obj/item/clothing/mask/rebreather/scarf, MARINE_CAN_BUY_MASK, VENDOR_ITEM_REGULAR),
	list("Rebreather", 0, /obj/item/clothing/mask/rebreather, MARINE_CAN_BUY_MASK, VENDOR_ITEM_REGULAR),
))

/obj/structure/machinery/cm_vending/clothing/combat_correspondent
	name = "\improper ColMarTech Combat Correspondent Equipment Rack"
	desc = "An automated rack hooked up to a colossal storage of reporter standard-issue equipment."
	req_access = list(ACCESS_PRESS)
	vendor_role = list(JOB_COMBAT_REPORTER)

/obj/structure/machinery/cm_vending/clothing/combat_correspondent/get_listed_products(mob/user)
	var/mob/living/carbon/human/human_user = user
	if(istype(human_user?.assigned_equipment_preset, /datum/equipment_preset/uscm_ship/reporter_uscm))
		return GLOB.cm_vending_clothing_combat_correspondent + GLOB.cm_vending_clothing_military_correspondent + GLOB.cm_vending_clothing_combat_correspondent_refills
	return GLOB.cm_vending_clothing_combat_correspondent + GLOB.cm_vending_clothing_civilian_correspondent + GLOB.cm_vending_clothing_combat_correspondent_refills


/obj/effect/essentials_set/cc
	spawned_gear_list = list(
		/obj/item/device/flashlight,
		/obj/item/tool/pen,
		/obj/item/device/binoculars,
		/obj/item/notepad,
		/obj/item/device/taperecorder,
	)
