/atom/movable/screen/text/screen_text/command_order
	maptext_height = 64
	maptext_width = 400
	maptext_x = 0
	maptext_y = 0
	screen_loc = "LEFT,TOP-3"

	letters_per_update = 2
	fade_out_delay = 10 SECONDS
	style_open = "<span class='langchat' style=font-size:24pt;text-align:center valign='top'>"
	style_close = "</span>"

/atom/movable/screen/text/screen_text/command_order/yautja
	play_delay = 0.3
	fade_out_delay = 10 SECONDS
	fade_out_time = 3 SECONDS

/atom/movable/screen/text/screen_text/command_order/automated
	fade_out_delay = 3 SECONDS
	style_open = "<span class='langchat' style=font-size:20pt;text-align:center valign='top'>"

/atom/movable/screen/text/screen_text/command_order/tutorial
	letters_per_update = 4 // overall, pretty fast while not immediately popping in
	play_delay = 0.1
	fade_out_delay = 2.5 SECONDS
	fade_out_time = 0.5 SECONDS

/atom/movable/screen/text/screen_text/command_order/tutorial/end_play()
	if(!player)
		qdel(src)
		return

	if(player.mob || HAS_TRAIT(player.mob, TRAIT_IN_TUTORIAL))
		return ..()

	for(var/atom/movable/screen/text/screen_text/command_order/tutorial/tutorial_message in player.screen_texts)
		LAZYREMOVE(player.screen_texts, tutorial_message)
		qdel(tutorial_message)

	return ..()
