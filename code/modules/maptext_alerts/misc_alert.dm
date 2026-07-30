/atom/movable/screen/text/screen_text/picture
	maptext_height = 64
	maptext_width = 480
	maptext_x = 66
	maptext_y = 32
	letters_per_update = 1
	fade_out_delay = 5 SECONDS
	screen_loc = "WEST:6,1:5"
	style_open = "<span class='langchat' style=font-size:20pt;text-align:left valign='top'>"
	style_close = "</span>"
	layer = INTRO_LAYER
	plane = INTRO_PLANE
	icon = 'icons/ui_icons/screen_alert_images.dmi'
	///image that will display on the left of the screen alert
	var/image_to_play
	///Opacity of the displayed image
	var/image_to_play_alpha = 255
	///y offset of image
	var/image_to_play_offset_y = 32
	///x offset of image
	var/image_to_play_offset_x = 0

/atom/movable/screen/text/screen_text/picture/Initialize(mapload, datum/hud/hud_owner)
	. = ..()
	var/image/alertimage = image(icon, icon_state = image_to_play, pixel_y = image_to_play_offset_y, pixel_x = image_to_play_offset_x)
	alertimage.appearance_flags = APPEARANCE_UI
	alertimage.alpha = image_to_play_alpha
	overlays += alertimage

/atom/movable/screen/text/screen_text/picture/solar_devils
	image_to_play = "solar_devils"

/atom/movable/screen/text/screen_text/picture/red_dawn
	image_to_play = "red_dawn"

/atom/movable/screen/text/screen_text/picture/azure
	image_to_play = "azure_15"

/atom/movable/screen/text/screen_text/picture/snake_eater
	image_to_play = "snake_eater"

/atom/movable/screen/text/screen_text/directed_by
	layer = INTRO_LAYER
	plane = INTRO_PLANE
	screen_loc = "WEST:6,1:5"
	style_open = "<span class='langchat' style=font-size:20pt;text-align:left valign='top'>"
	style_close = "</span>"
	maptext_x = 32

/atom/movable/screen/text/screen_text/potrait
	screen_loc = "LEFT,TOP-3"
	maptext_height = 64
	maptext_width = 480
	maptext_x = 66
	maptext_y = 0
	letters_per_update = 2
	fade_out_delay = 10 SECONDS
	layer = INTRO_LAYER
	plane = INTRO_PLANE
	style_open = "<span class='langchat' style=font-size:20pt;text-align:left valign='top'>"
	style_close = "</span>"

/atom/movable/screen/text/screen_text/potrait/Initialize(mapload, datum/hud/hud_owner, name, icon_to_use, image_to_play)
	. = ..()
	var/image/alertimage = image(icon_to_use, icon_state = image_to_play)
	alertimage.appearance_flags = APPEARANCE_UI
	overlays += alertimage
	var/atom/movable/holding_movable = new
	holding_movable.appearance_flags = APPEARANCE_UI|KEEP_TOGETHER
	holding_movable.mouse_opacity = MOUSE_OPACITY_TRANSPARENT

	var/mutable_appearance/mugshot_name = mutable_appearance()
	mugshot_name.appearance_flags = APPEARANCE_UI
	mugshot_name.maptext_width = 66 // 64 (the icon) + 1 buffer each side
	mugshot_name.maptext_x = -1
	mugshot_name.maptext_y = -1
	mugshot_name.plane = plane
	mugshot_name.layer = layer+0.3

	if(!name)
		name = ""
	mugshot_name.maptext = "<span class='langchat' style=font-size:6px;text-align:center>[name]</span>"

	holding_movable.overlays += mugshot_name

	vis_contents += holding_movable

/atom/movable/screen/text/screen_text/picture/potrait_custom_mugshot
	image_to_play = "custom"
	image_to_play_alpha = 110
	screen_loc = "LEFT,TOP-3"
	maptext_width = 400
	image_to_play_offset_y = 0
	maptext_y = 0
	letters_per_update = 1
	play_delay = 1.5
	var/announcement_title

/mob/proc/play_portrait_announcement(text, title, mob/living/carbon/human/portrait_owner, override_color = "#FFFFFF")
	var/atom/movable/screen/text/screen_text/picture/potrait_custom_mugshot/portrait = new(null, null, portrait_owner)
	portrait.announcement_title = title
	play_screen_text(text, portrait, override_color)

#define PORTRAIT_VISIBLE_BODY_CHARACTERS 48
#define MAX_PORTRAIT_NAME_LEN 12

/atom/movable/screen/text/screen_text/picture/potrait_custom_mugshot/play_to_client()
	player?.add_to_screen(src)
	if(fade_in_time)
		animate(src, alpha = 255)

	for(var/letter = 2 to length(text_to_play) + letters_per_update step letters_per_update)
		var/window_start = max(1, letter - PORTRAIT_VISIBLE_BODY_CHARACTERS)
		var/visible_text = copytext_char(text_to_play, window_start, letter)
		maptext = "[style_open]<span class='langchat' style=font-size:24pt;text-align:left valign='top'><u>[uppertext(announcement_title)]:</u></span><br>[visible_text][style_close]"
		sleep(play_delay)

	addtimer(CALLBACK(src, PROC_REF(after_play)), fade_out_delay)

/atom/movable/screen/text/screen_text/picture/potrait_custom_mugshot/Initialize(mapload, datum/hud/hud_owner, mob/living/mugshottee)
	. = ..()
	var/atom/movable/holding_movable = new
	holding_movable.appearance_flags = APPEARANCE_UI|KEEP_TOGETHER
	holding_movable.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	var/mutable_appearance/mugshot = mutable_appearance()
	if(!mugshottee)
		debug_log("Mob based HUD portrait alert was called without a mob.")
		//return
		mugshot.appearance = image('icons/mob/mob.dmi', "spook")
	else
		mugshot.appearance = mugshottee.appearance
	mugshot.pixel_x = image_to_play_offset_x + 17
	mugshot.pixel_y = image_to_play_offset_y - 1 //scale shittery meant this didn't line up exactly without the -1
	mugshot.layer = layer+0.1
	mugshot.plane = plane
	mugshot.color = "#80D99A"
	mugshot.transform = matrix().Scale(3) //only need to scale once, although this can actually be after as well alpha filter stuff, makes no diff. we use a NEW matrix to also fix things like people lying down
	mugshot.dir = SOUTH
	var/mutable_appearance/alphafilter = mutable_appearance('icons/effects/alphacolors.dmi', "announcement")
	alphafilter.appearance_flags = APPEARANCE_UI
	alphafilter.render_target = "*mugshots"

	mugshot.overlays += alphafilter
	mugshot.filters += filter(arglist(alpha_mask_filter(0, 0, null, "*mugshots")))

	holding_movable.overlays += mugshot

	var/image/static_overlay = image('icons/UI_Icons/screen_alert_images.dmi', icon_state = image_to_play+"_static", pixel_y = image_to_play_offset_y, pixel_x = image_to_play_offset_x)
	static_overlay.appearance_flags = APPEARANCE_UI
	static_overlay.alpha = 45
	static_overlay.layer = layer+0.2
	static_overlay.plane = plane
	holding_movable.overlays += static_overlay



	var/mutable_appearance/mugshot_name = mutable_appearance()
	mugshot_name.appearance_flags = APPEARANCE_UI
	mugshot_name.maptext_width = 66 // 64 (the icon) + 1 buffer each side
	mugshot_name.maptext_x = -1
	mugshot_name.maptext_y = -1
	mugshot_name.plane = plane
	mugshot_name.layer = layer+0.3
	var/user_name = "UNKNOWN"
	if(mugshottee)
		var/mob/living/carbon/human/human_mugshottee = mugshottee
		var/rank_prefix = mugshottee.comm_title
		var/obj/item/card/id/id_card = human_mugshottee.get_idcard()
		if(id_card?.paygrade)
			var/datum/paygrade/paygrade = GLOB.paygrades[id_card.paygrade]
			if(paygrade?.prefix)
				rank_prefix = paygrade.prefix

		var/list/name_parts = splittext(trim(mugshottee.real_name), " ")
		var/last_name = length(name_parts) ? name_parts[length(name_parts)] : "UNKNOWN"
		last_name = copytext(last_name, 1, MAX_PORTRAIT_NAME_LEN + 1)
		user_name = trim("[rank_prefix] [last_name]")
	mugshot_name.maptext = "<span class='langchat' style=font-size:6px;text-align:center>[user_name]</span>"

	holding_movable.overlays += mugshot_name

	vis_contents += holding_movable

#undef MAX_PORTRAIT_NAME_LEN
#undef PORTRAIT_VISIBLE_BODY_CHARACTERS
