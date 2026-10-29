from random import randint

beam1 = "beam_control_testmode_nr profile_id=1 ueBeamIndexInitial=0,1,2,3,4,5 " \
         " ssbeam_bestbeam=0 ssbeam_rsrp_best=-44 ssbeam_rsrp_avg=-50"
beam2 = "beam_control_testmode_nr profile_id=2 ueBeamIndexInitial=1,0,2,3,4,5 " \
         " ssbeam_bestbeam=1 ssbeam_rsrp_best=-45 ssbeam_rsrp_avg=-120"
beam3 = "beam_control_testmode_nr profile_id=3 ueBeamIndexInitial=2,0,1,3,4,5 " \
         " ssbeam_bestbeam=2 ssbeam_rsrp_best=-50 ssbeam_rsrp_avg=-125"
beam4 = "beam_control_testmode_nr profile_id=4 ueBeamIndexInitial=3,0,1,2,4,5 " \
         " ssbeam_bestbeam=3 ssbeam_rsrp_best=-55 ssbeam_rsrp_avg=-120"
beam5 = "beam_control_testmode_nr profile_id=5 ueBeamIndexInitial=4,0,1,2,3,5 " \
         " ssbeam_bestbeam=4 ssbeam_rsrp_best=-60 ssbeam_rsrp_avg=-139"
beam6 = "beam_control_testmode_nr profile_id=6 ueBeamIndexInitial=5,0,1,2,3,4 " \
         " ssbeam_bestbeam=5 ssbeam_rsrp_best=-65 ssbeam_rsrp_avg=-70"
# beam7 = "beam_control_testmode_nr profile_id=7 ueBeamIndexInitial=6,0,1,2,3,4,5,7 " \
#          " ssbeam_bestbeam=6 ssbeam_rsrp_best=-46 ssbeam_rsrp_avg=-100"
# beam8 = "beam_control_testmode_nr profile_id=8 ueBeamIndexInitial=7,0,1,2,3,4,5,6 " \
#          " ssbeam_bestbeam=7 ssbeam_rsrp_best=-48 ssbeam_rsrp_avg=-100"

fdd_cells = [1, 2, 21, 22]
tdd_cells = [201, 202, 211, 212]


async def prepare_testmode_near_cell_rf_condition(watcher=None):
    await watcher.send_command(f"ul_sinr_testmode_nr profile_id=3"
                               f" pcmax=26"
                               f" pathloss=50"
                               f" alpha=100")
    # Near FDD profile=3
    await watcher.send_command(f"csi_override_testmode_nr profile_id=3 cqi_mode=oscillating cqi=12 cqi_min=10"
                               f" cqi_max=15 cqi_step=1 cqi_period=3"
                               f" ri_mode=varying ri=2,3 ri_period=20")
    # Near TDD profile=6
    await watcher.send_command(f"csi_override_testmode_nr profile_id=6 cqi_mode=oscillating cqi=12 cqi_min=10"
                               f" cqi_max=15 cqi_step=1 cqi_period=3"
                               f" ri_mode=varying ri=2,3 ri_period=20")
    # NearCell FDD profile=3
    await watcher.send_command(f"adv_bler_testmode_nr profile_id=3 target_bler_profile_id=1"
                               f" target_bler=40,30,20,15,10,5,2,1,1,0,0,0,0,0,0"
                               f" retx_target_bler1=20,15,10,8,5,3,1,1,1,0,0,0,0,0,0"
                               f" retx_target_bler2=10,8,5,4,3,1,1,0,0,0,0,0,0,0,0"
                               f" retx_target_bler3=5,4,3,2,1,1,0,0,0,0,0,0,0,0,0"
                               f" retx_target_bler4=3,2,1,1,1,0,0,0,0,0,0,0,0,0,0"
                               f" retx_target_bler5=1,1,1,0,0,0,0,0,0,0,0,0,0,0,0"
                               f" retx_target_bler6=1,0,0,0,0,0,0,0,0,0,0,0,0,0,0"
                               f" retx_target_bler7=0,0,0,0,0,0,0,0,0,0,0,0,0,0,0"
                               f" target_mcs=25 mcs_table=all rank=0 p_target_bler_profile_id=1")
    # NearCell TDD profile=6
    await watcher.send_command(f"adv_bler_testmode_nr profile_id=6 target_bler_profile_id=1"
                               f" target_bler=40,30,20,15,10,5,2,1,1,0,0,0,0,0,0"
                               f" retx_target_bler1=20,15,10,8,5,3,1,1,1,0,0,0,0,0,0"
                               f" retx_target_bler2=10,8,5,4,3,1,1,0,0,0,0,0,0,0,0"
                               f" retx_target_bler3=5,4,3,2,1,1,0,0,0,0,0,0,0,0,0"
                               f" retx_target_bler4=3,2,1,1,1,0,0,0,0,0,0,0,0,0,0"
                               f" retx_target_bler5=1,1,1,0,0,0,0,0,0,0,0,0,0,0,0"
                               f" retx_target_bler6=1,0,0,0,0,0,0,0,0,0,0,0,0,0,0"
                               f" retx_target_bler7=0,0,0,0,0,0,0,0,0,0,0,0,0,0,0"
                               f" target_mcs=25 mcs_table=all rank=0 p_target_bler_profile_id=1")


async def prepare_testmode_mid_cell_rf_condition(watcher=None):
    await watcher.send_command(f"ul_sinr_testmode_nr profile_id=2"
                               f" pcmax=26"
                               f" pathloss=80"
                               f" alpha=90")
    # FDD MID profile=2
    await watcher.send_command(f"csi_override_testmode_nr profile_id=2 cqi_mode=oscillating cqi=7 cqi_min=5"
                               f" cqi_max=10 cqi_step=1 cqi_period=4"
                               f" ri_mode=fixed ri=1")
    # TDD MID profile=5
    await watcher.send_command(f"csi_override_testmode_nr profile_id=5 cqi_mode=oscillating cqi=7 cqi_min=5"
                               f" cqi_max=10 cqi_step=1 cqi_period=4"
                               f" ri_mode=fixed ri=1")
    # FDD MID profile=2
    await watcher.send_command(f"adv_bler_testmode_nr profile_id=2 target_bler_profile_id=1"
                               f" target_bler=40,30,20,15,10,8,6,5,2,1,1,0,0,0,0"
                               f" retx_target_bler1=20,15,10,8,5,4,3,3,1,1,1,0,0,0,0"
                               f" retx_target_bler2=10,8,5,4,3,2,2,1,1,0,0,0,0,0,0"
                               f" retx_target_bler3=5,4,3,2,1,1,1,1,0,0,0,0,0,0,0"
                               f" retx_target_bler4=3,2,1,1,1,1,0,0,0,0,0,0,0,0,0"
                               f" retx_target_bler5=1,1,1,0,0,0,0,0,0,0,0,0,0,0,0"
                               f" retx_target_bler6=1,0,0,0,0,0,0,0,0,0,0,0,0,0,0"
                               f" retx_target_bler7=0,0,0,0,0,0,0,0,0,0,0,0,0,0,0"
                               f" target_mcs=18 mcs_table=all rank=0 p_target_bler_profile_id=1")
    # TDD MID profile=5
    await watcher.send_command(f"adv_bler_testmode_nr profile_id=5 target_bler_profile_id=1"
                               f" target_bler=40,30,20,15,10,7,6,5,2,1,1,0,0,0,0"
                               f" retx_target_bler1=20,15,10,8,5,4,3,3,1,1,1,0,0,0,0"
                               f" retx_target_bler2=10,8,5,4,3,2,2,1,1,0,0,0,0,0,0"
                               f" retx_target_bler3=5,4,3,2,1,1,1,1,0,0,0,0,0,0,0"
                               f" retx_target_bler4=3,2,1,1,1,0,0,0,0,0,0,0,0,0,0"
                               f" retx_target_bler5=1,1,1,0,0,0,0,0,0,0,0,0,0,0,0"
                               f" retx_target_bler6=1,0,0,0,0,0,0,0,0,0,0,0,0,0,0"
                               f" retx_target_bler7=0,0,0,0,0,0,0,0,0,0,0,0,0,0,0"
                               f" target_mcs=18 mcs_table=all rank=0 p_target_bler_profile_id=1")


async def prepare_testmode_far_cell_rf_condition(watcher=None):
    # FDD
    await watcher.send_command(f"ul_sinr_testmode_nr profile_id=1"
                               f" pcmax=26"
                               f" pathloss=90"
                               f" alpha=90")
    # TDD
    await watcher.send_command(f"ul_sinr_testmode_nr profile_id=4"
                               f" pcmax=26"
                               f" pathloss=90"
                               f" alpha=90")
    # FarCell FDD profile=1
    await watcher.send_command(f"csi_override_testmode_nr profile_id=1 cqi_mode=oscillating cqi=3 cqi_min=1"
                               f" cqi_max=5 cqi_step=1 cqi_period=4"
                               f" ri_mode=fixed ri=0")
    # FarCell TDD profile=4
    await watcher.send_command(f"csi_override_testmode_nr profile_id=4 cqi_mode=oscillating cqi=3 cqi_min=1"
                               f" cqi_max=5 cqi_step=1 cqi_period=4"
                               f" ri_mode=fixed ri=0")
    # FarCell FDD profile=1
    await watcher.send_command(f"adv_bler_testmode_nr profile_id=1 target_bler_profile_id=1"
                               f" target_bler=40,30,25,20,18,15,12,10,5,2,1,1,0,0,0"
                               f" retx_target_bler1=20,15,13,10,9,8,6,5,3,1,1,0,0,0,0"
                               f" retx_target_bler2=10,8,6,5,5,4,3,3,1,1,0,0,0,0,0"
                               f" retx_target_bler3=5,4,3,3,2,2,2,1,1,0,0,0,0,0,0"
                               f" retx_target_bler4=3,2,2,1,1,1,1,1,0,0,0,0,0,0,0"
                               f" retx_target_bler5=1,1,1,1,1,0,0,0,0,0,0,0,0,0,0"
                               f" retx_target_bler6=1,0,0,0,0,0,0,0,0,0,0,0,0,0,0"
                               f" retx_target_bler7=0,0,0,0,0,0,0,0,0,0,0,0,0,0,0"
                               f" target_mcs=5 mcs_table=all rank=0 p_target_bler_profile_id=1")
    # FarCell TDD profile=4
    await watcher.send_command(f"adv_bler_testmode_nr profile_id=4 target_bler_profile_id=1"
                               f" target_bler=40,30,20,19,18,17,16,15,10,5,2,1,1,0,0"
                               f" retx_target_bler1=20,15,10,10,9,9,8,8,5,3,1,1,0,0,0"
                               f" retx_target_bler2=10,8,5,5,5,4,4,4,3,1,1,0,0,0,0"
                               f" retx_target_bler3=5,4,3,2,2,2,2,2,1,1,0,0,0,0,0"
                               f" retx_target_bler4=3,2,1,1,1,1,1,1,1,0,0,0,0,0,0"
                               f" retx_target_bler5=1,1,1,1,1,1,1,0,0,0,0,0,0,0,0"
                               f" retx_target_bler6=1,0,0,0,0,0,0,0,0,0,0,0,0,0,0"
                               f" retx_target_bler7=0,0,0,0,0,0,0,0,0,0,0,0,0,0,0"
                               f" target_mcs=5 mcs_table=all rank=0 p_target_bler_profile_id=1")


async def activate_nsa_far_cell_testmod(ue_id, target_cell, watcher=None):
    # bler_profile_id = None
    await watcher.send_command(f"ue_testmode_set_nr id={ue_id} testmode=ul_sinr profile_id=1"
                               f" action=activate scell=8-9")
    if target_cell in fdd_cells:
        await watcher.send_command(f"ue_testmode_set_nr id={ue_id} testmode=csi_override profile_id=1"
                                   f" action=activate scell=8-9")
        await watcher.send_command(f"ue_testmode_set_nr id={ue_id} testmode=adv_bler profile_id=1"
                                   f" action=activate scell=8-9")
        # bler_profile_id = 1
    elif target_cell in tdd_cells:
        await watcher.send_command(f"ue_testmode_set_nr id={ue_id} testmode=csi_override profile_id=4"
                                   f" action=activate scell=8-9")
        await watcher.send_command(f"ue_testmode_set_nr id={ue_id} testmode=adv_bler profile_id=4"
                                   f" action=activate scell=8-9")
        # bler_profile_id = 1
    # return bler_profile_id


async def activate_nsa_mid_cell_testmod(ue_id, target_cell, watcher=None):
    # bler_profile_id = None
    await watcher.send_command(f"ue_testmode_set_nr id={ue_id} testmode=ul_sinr profile_id=2"
                               f" action=activate scell=8-9")
    if target_cell in fdd_cells:
        await watcher.send_command(f"ue_testmode_set_nr id={ue_id} testmode=csi_override profile_id=2"
                                   f" action=activate scell=8-9")
        await watcher.send_command(f"ue_testmode_set_nr id={ue_id} testmode=adv_bler profile_id=2"
                                   f" action=activate scell=8-9")
        # bler_profile_id = 2
    elif target_cell in tdd_cells:
        await watcher.send_command(f"ue_testmode_set_nr id={ue_id} testmode=csi_override profile_id=5"
                                   f" action=activate scell=8-9")
        await watcher.send_command(f"ue_testmode_set_nr id={ue_id} testmode=adv_bler profile_id=5"
                                   f" action=activate scell=8-9")
    #     bler_profile_id = 2
    # return bler_profile_id


async def activate_nsa_near_cell_testmod(ue_id, target_cell, watcher=None):
    # bler_profile_id = None
    await watcher.send_command(f"ue_testmode_set_nr id={ue_id} testmode=ul_sinr profile_id=3"
                               f" action=activate scell=8-9")
    if target_cell in fdd_cells:
        await watcher.send_command(f"ue_testmode_set_nr id={ue_id} testmode=csi_override profile_id=3"
                                   f" action=activate scell=8-9")
        await watcher.send_command(f"ue_testmode_set_nr id={ue_id} testmode=adv_bler profile_id=3"
                                   f" action=activate scell=8-9")
        # bler_profile_id = 3
    elif target_cell in tdd_cells:
        await watcher.send_command(f"ue_testmode_set_nr id={ue_id} testmode=csi_override profile_id=6"
                                   f" action=activate scell=8-9")
        await watcher.send_command(f"ue_testmode_set_nr id={ue_id} testmode=adv_bler profile_id=6"
                                   f" action=activate scell=8-9")
        # bler_profile_id = 3
    # return bler_profile_id


async def activate_sa_far_cell_testmod(ue_id, target_cell, watcher=None):
    if target_cell in fdd_cells:
        await watcher.send_command(f"ue_testmode_set_nr id={ue_id} testmode=ul_sinr profile_id=1"
                                   f" action=activate scell=0,1,2,3")
        await watcher.send_command(f"ue_testmode_set_nr id={ue_id} testmode=csi_override profile_id=1"
                                   f" action=activate scell=0,1,2,3")
        # await watcher.send_command(f"ue_testmode_set_nr id={ue_id} testmode=ta"
        #                            f" profile_id=3 action=activate")
        await watcher.send_command(f"ue_testmode_set_nr id={ue_id} testmode=adv_bler profile_id=1"
                                   f" action=activate scell=0,1,2,3")
    elif target_cell in tdd_cells:
        await watcher.send_command(f"ue_testmode_set_nr id={ue_id} testmode=ul_sinr profile_id=4"
                                   f" action=activate scell=0,1,2,3")
        await watcher.send_command(f"ue_testmode_set_nr id={ue_id} testmode=ta"
                                   f" profile_id=3 action=activate")
        await watcher.send_command(f"ue_testmode_set_nr id={ue_id} testmode=csi_override profile_id=4"
                                   f" action=activate scell=0,1,2,3")
        await watcher.send_command(f"ue_testmode_set_nr id={ue_id} testmode=adv_bler profile_id=4"
                                   f" action=activate scell=0,1,2,3")


async def activate_sa_mid_cell_testmod(ue_id, target_cell, watcher=None):
    await watcher.send_command(f"ue_testmode_set_nr id={ue_id} testmode=ul_sinr profile_id=2"
                               f" action=activate scell=0,1,2,3")
    if target_cell in fdd_cells:
        await watcher.send_command(f"ue_testmode_set_nr id={ue_id} testmode=csi_override profile_id=2"
                                   f" action=activate scell=0,1,2,3")
        # await watcher.send_command(f"ue_testmode_set_nr id={ue_id} testmode=ta"
        #                            f" profile_id=2 action=activate")
        await watcher.send_command(f"ue_testmode_set_nr id={ue_id} testmode=adv_bler profile_id=2"
                                   f" action=activate scell=0,1,2,3")
    elif target_cell in tdd_cells:
        await watcher.send_command(f"ue_testmode_set_nr id={ue_id} testmode=csi_override profile_id=5"
                                   f" action=activate scell=0,1,2,3")
        await watcher.send_command(f"ue_testmode_set_nr id={ue_id} testmode=ta"
                                   f" profile_id=2 action=activate")
        await watcher.send_command(f"ue_testmode_set_nr id={ue_id} testmode=adv_bler profile_id=5"
                                   f" action=activate scell=0,1,2,3")


async def activate_sa_near_cell_testmod(ue_id, target_cell, watcher=None):
    await watcher.send_command(f"ue_testmode_set_nr id={ue_id} testmode=ul_sinr profile_id=3"
                               f" action=activate scell=0,1,2,3")
    if target_cell in fdd_cells:
        await watcher.send_command(f"ue_testmode_set_nr id={ue_id} testmode=csi_override profile_id=3"
                                   f" action=activate scell=0,1,2,3")
        # await watcher.send_command(f"ue_testmode_set_nr id={ue_id} testmode=ta"
        #                            f" profile_id=1 action=activate")
        await watcher.send_command(f"ue_testmode_set_nr id={ue_id} testmode=adv_bler profile_id=3"
                                   f" action=activate scell=0,1,2,3")
    elif target_cell in tdd_cells:
        await watcher.send_command(f"ue_testmode_set_nr id={ue_id} testmode=csi_override profile_id=6"
                                   f" action=activate scell=0,1,2,3")
        await watcher.send_command(f"ue_testmode_set_nr id={ue_id} testmode=ta"
                                   f" profile_id=1 action=activate")
        await watcher.send_command(f"ue_testmode_set_nr id={ue_id} testmode=adv_bler profile_id=6"
                                   f" action=activate scell=0,1,2,3")


async def prepare_beam_profiles(watcher=None):
    await watcher.send_command(beam1)
    await watcher.send_command(beam2)
    await watcher.send_command(beam3)
    await watcher.send_command(beam4)
    await watcher.send_command(beam5)
    await watcher.send_command(beam6)


async def prepare_timing_advance_profiles(watcher=None):
    await watcher.send_command(f"ue_ta_nr profile_id=1 ue_p_delay_initial=167")
    await watcher.send_command(f"ue_ta_nr profile_id=2 ue_p_delay_initial=415")
    await watcher.send_command(f"ue_ta_nr profile_id=3 ue_p_delay_initial=663")


async def activate_beam_profile(ue_id, profile_id, watcher=None):
    if profile_id == "random":
        profile_id = randint(1, 6)
    await watcher.send_command(f"ue_testmode_set_nr id={ue_id} testmode=beam_control action=activate"
                               f" profile_id={profile_id} beamaction=attach")


async def create_cqi_profile(watcher=None):
    await watcher.send_command('csi_override_testmode_nr profile_id=1 cqi_mode=oscillating cqi=1\
                               cqi_min=1 cqi_max=7 cqi_step=1 cqi_period=3')


async def activate_cqi_profile(ue_id, profile_id, watcher=None):
    await watcher.send_command('ue_testmode_set_nr id={} testmode=csi_override profile_id={}\
                               action=activate'.format(ue_id, profile_id))


async def create_bler_profile(watcher=None):
    await watcher.send_command('bler_testmode_nr profile_id=1 dl_bler=150,50,20,10,10,10,10,10\
                               ul_bler=150,50,20,10,10,10,10,10')


async def activate_bler_profile(ue_id, profile_id, watcher=None):
    await watcher.send_command(f"ue_testmode_set_nr id={ue_id} testmode=bler profile_id={profile_id}"
                               f" action=activate")


async def deactivate_bler_profile(ue_id, profile_id, watcher=None):
    await watcher.send_command(f"ue_testmode_set_nr id={ue_id} testmode=bler profile_id={profile_id}"
                               f" action=deactivate")


async def prepare_amf_for_inactive_state(amf_id=1, plmn_id='310:260', tac_id=200, watcher=None):
    await watcher.send_command(f"amf_ue_ics_param id={amf_id} core_network_assistance_info=on ue_identity_index_value=1"
                               f" ue_specific_drx=64 periodic_registration_update_timer=1:10min"
                               f" plmn_id={plmn_id} tac_id={tac_id}")
    await watcher.send_command(f"amf_ue_ng_handover_request_param id={amf_id} core_network_assistance_info=on"
                               f" ue_identity_index_value=1 ue_specific_drx=64 "
                               f"periodic_registration_update_timer=1:10min plmn_id={plmn_id} tac_id={tac_id}")
    await watcher.send_command(f"amf_ue_path_switch_param id={amf_id} core_network_assistance_info=on"
                               f" ue_identity_index_value=1 ue_specific_drx=64 "
                               f"periodic_registration_update_timer=1:10min plmn_id={plmn_id} tac_id={tac_id}")


async def activate_timing_advance_profile(ue_id, profile_id, watcher=None):
    await watcher.send_command(f"ue_testmode_set_nr id={ue_id} scell=0 testmode=ta"
                               f" profile_id={profile_id} action=activate")


async def create_no_rrc_setup_req_profile(watcher=None):
    """Function creates profile for no sending MSG3"""
    await watcher.send_command(f"cont_res_testmode_nr profile_id=1 missed_ra_resp=20 msg5_dtx=0")


async def create_no_rrc_setup_complete_profile(watcher=None):
    """Function creates profile for no sending MSG5"""
    await watcher.send_command(f"cont_res_testmode_nr profile_id=2 missed_ra_resp=0 msg5_dtx=255")


async def deactivate_beam_control_profile(ue_id, beam_id, watcher=None):
    await watcher.send_command(f"ue_testmode_set_nr id={ue_id} testmode=beam_control action=deactivate "
                               f"profile_id={beam_id}")


async def activate_beam_control_profile(ue_id, beam_id, watcher=None):
    await watcher.send_command(f"ue_testmode_set_nr id={ue_id} testmode=beam_control action=activate "
                               f"profile_id={beam_id} beamaction=attach")
