/datum/faction/ifm
	name = "Independent Frontier Medics"
	faction_tag = FACTION_IFM

/datum/faction/ifm/modify_hud_holder(image/holder, mob/living/carbon/human/human)
	var/icon/override_icon_file
	var/hud_icon_state
	var/_role = human.job
	if(!_role)
		var/obj/item/card/id/id_card = human.get_idcard()
		if(id_card)
			_role = id_card.rank
	switch(_role)
		if(JOB_IFM_FIELD_DOCTOR)
			hud_icon_state = "ifm_field_doctor"
		if(JOB_IFM_CHIEF_MEDICAL_OFFICER)
			hud_icon_state = "ifm_cmo"
		if(JOB_IFM_SECURITY_CONTRACTOR)
			hud_icon_state = "ifm_security"
		if(JOB_IFM_SYNTHETIC)
			hud_icon_state = "ifm_synth"
	if(hud_icon_state)
		holder.overlays += image(override_icon_file ? override_icon_file : base_icon_file, human, "hc_[hud_icon_state]")
