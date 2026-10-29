# from common import *
from random import randint
from common import execute_wts_command

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


async def prepare_testmode_far_cell_rf_condition(watcher=None):
    if watcher:
        await watcher.send_command(f"bler_testmode_nr profile_id=1 "
                                   f"dl_bler=100,50,20,10,10,10,10,10 ul_bler=100,50,20,10,10,10,10,10")
        await watcher.send_command(f"csi_override_testmode_nr profile_id=1 "
                                   f"cqi_mode=oscillating cqi=1 cqi_min=1 cqi_max=7 cqi_step=1 cqi_period=3")
        await watcher.send_command(f"ul_sinr_testmode_nr profile_id=1"
                                   f" sinr_target_srs=-500 sinr_target_pusch=-500 "
                                   f"sinr_target_pucch=-500 sinr_target_preamble=-500")
    else:
        execute_wts_command(cmd=f"bler_testmode_nr profile_id=1 "
                                f"dl_bler=100,50,20,10,10,10,10,10 ul_bler=100,50,20,10,10,10,10,10")
        execute_wts_command(cmd=f"csi_override_testmode_nr profile_id=1 "
                                f"cqi_mode=oscillating cqi=1 cqi_min=1 cqi_max=7 cqi_step=1 cqi_period=3")
        execute_wts_command(cmd=f"ul_sinr_testmode_nr profile_id=1"
                                f" sinr_target_srs=-500 sinr_target_pusch=-500 "
                                f"sinr_target_pucch=-500 sinr_target_preamble=-500")


async def prepare_testmode_mid_cell_rf_condition(watcher=None):
    if watcher:
        await watcher.send_command(f"bler_testmode_nr profile_id=2 "
                                   f"dl_bler=25,12,5,2,2,2,2,2 ul_bler=25,12,5,2,2,2,2,2")
        await watcher.send_command(f"csi_override_testmode_nr profile_id=2 "
                                   f"cqi_mode=oscillating cqi=8 cqi_min=8 cqi_max=12 cqi_step=1 cqi_period=3")
        await watcher.send_command(f"ul_sinr_testmode_nr profile_id=2"
                                   f" sinr_target_srs=-240 sinr_target_pusch=-240 "
                                   f"sinr_target_pucch=-240 sinr_target_preamble=-240")
    else:
        execute_wts_command(cmd=f"bler_testmode_nr profile_id=2 "
                                f"dl_bler=25,12,5,2,2,2,2,2 ul_bler=25,12,5,2,2,2,2,2")
        execute_wts_command(cmd=f"csi_override_testmode_nr profile_id=2 "
                                f"cqi_mode=oscillating cqi=8 cqi_min=8 cqi_max=12 cqi_step=1 cqi_period=3")
        execute_wts_command(cmd=f"ul_sinr_testmode_nr profile_id=2"
                                f" sinr_target_srs=-240 sinr_target_pusch=-240 "
                                f"sinr_target_pucch=-240 sinr_target_preamble=-240")


def activate_nsa_far_cell_testmod(ue_id):
    execute_wts_command(cmd=f"ue_testmode_set_nr id={ue_id} testmode=bler profile_id=1"
                            f" action=activate scell=8-9")
    execute_wts_command(cmd=f"ue_testmode_set_nr id={ue_id} testmode=csi_override profile_id=1"
                            f" action=activate scell=8-9")
    execute_wts_command(cmd=f"ue_testmode_set_nr id={ue_id} testmode=ul_sinr profile_id=1"
                            f" action=activate scell=8-9")


def activate_nsa_mid_cell_testmod(ue_id):
    execute_wts_command(cmd=f"ue_testmode_set_nr id={ue_id} testmode=bler profile_id=2"
                            f" action=activate scell=8-9")
    execute_wts_command(cmd=f"ue_testmode_set_nr id={ue_id} testmode=csi_override profile_id=2"
                            f" action=activate scell=8-9")
    execute_wts_command(cmd=f"ue_testmode_set_nr id={ue_id} testmode=ul_sinr profile_id=2"
                            f" action=activate scell=8-9")


async def activate_sa_far_cell_testmod(ue_id, watcher=None):
    if watcher:
        await watcher.send_command(f"ue_testmode_set_nr id={ue_id} testmode=bler profile_id=1"
                                   f" action=activate scell=0,1,2,3")
        await watcher.send_command(f"ue_testmode_set_nr id={ue_id} testmode=csi_override profile_id=1"
                                   f" action=activate scell=0,1,2,3")
        await watcher.send_command(f"ue_testmode_set_nr id={ue_id} testmode=ul_sinr profile_id=1"
                                   f" action=activate scell=0,1,2,3")
    else:
        execute_wts_command(cmd=f"ue_testmode_set_nr id={ue_id} testmode=bler profile_id=1"
                                f" action=activate scell=0,1,2,3")
        execute_wts_command(cmd=f"ue_testmode_set_nr id={ue_id} testmode=csi_override profile_id=1"
                                f" action=activate scell=0,1,2,3")
        execute_wts_command(cmd=f"ue_testmode_set_nr id={ue_id} testmode=ul_sinr profile_id=1"
                                f" action=activate scell=0,1,2,3")


async def activate_sa_mid_cell_testmod(ue_id, watcher=None):
    if watcher:
        # await watcher.send_command(f"ue_testmode_set_nr id={ue_id} testmode=bler profile_id=1"
        #                            f" action=activate scell=0,1,2,3")
        await watcher.send_command(f"ue_testmode_set_nr id={ue_id} testmode=csi_override profile_id=2"
                                   f" action=activate scell=0,1,2,3")
        await watcher.send_command(f"ue_testmode_set_nr id={ue_id} testmode=ul_sinr profile_id=2"
                                   f" action=activate scell=0,1,2,3")
    else:
        # execute_wts_command(cmd=f"ue_testmode_set_nr id={ue_id} testmode=bler profile_id=2"
        #                         f" action=activate scell=0,1,2,3")
        execute_wts_command(cmd=f"ue_testmode_set_nr id={ue_id} testmode=csi_override profile_id=2"
                                f" action=activate scell=0,1,2,3")
        execute_wts_command(cmd=f"ue_testmode_set_nr id={ue_id} testmode=ul_sinr profile_id=2"
                                f" action=activate scell=0,1,2,3")


async def prepare_beam_profiles(watcher=None):
    if watcher:
        await watcher.send_command(beam1)
        await watcher.send_command(beam2)
        await watcher.send_command(beam3)
        await watcher.send_command(beam4)
        await watcher.send_command(beam5)
        await watcher.send_command(beam6)
    else:
        execute_wts_command(cmd=beam1)
        execute_wts_command(cmd=beam2)
        execute_wts_command(cmd=beam3)
        execute_wts_command(cmd=beam4)
        execute_wts_command(cmd=beam5)
        execute_wts_command(cmd=beam6)


async def activate_beam_profile(ue_id, profile_id, watcher=None):
    if watcher:
        if profile_id == "random":
            profile_id = randint(1, 6)
        await watcher.send_command(f"ue_testmode_set_nr id={ue_id} testmode=beam_control action=activate"
                                   f" profile_id={profile_id} beamaction=attach")
    else:
        if profile_id == "random":
            profile_id = randint(1, 6)
        execute_wts_command(cmd='ue_testmode_set_nr id={} testmode=beam_control action=activate\
                                 profile_id={} beamaction=attach'.format(ue_id, profile_id))


def create_cqi_profile():
    execute_wts_command(cmd='csi_override_testmode_nr profile_id=1 cqi_mode=oscillating cqi=1\
                             cqi_min=1 cqi_max=7 cqi_step=1 cqi_period=3')


def activate_cqi_profile(ue_id, profile_id):
    execute_wts_command(cmd='ue_testmode_set_nr id={} testmode=csi_override profile_id={}\
                             action=activate'.format(ue_id, profile_id))


def create_bler_profile():
    execute_wts_command(cmd='bler_testmode_nr profile_id=1 dl_bler=150,50,20,10,10,10,10,10\
                             ul_bler=150,50,20,10,10,10,10,10')


async def activate_bler_profile(ue_id, profile_id, watcher=None):
    if watcher:
        await watcher.send_command(f"ue_testmode_set_nr id={ue_id} testmode=bler profile_id={profile_id}"
                                   f" action=activate")
    else:
        execute_wts_command(cmd='ue_testmode_set_nr id={} testmode=bler profile_id={}\
                                action=activate'.format(ue_id, profile_id))


async def deactivate_bler_profile(ue_id, profile_id, watcher=None):
    if watcher:
        await watcher.send_command(f"ue_testmode_set_nr id={ue_id} testmode=bler profile_id={profile_id}"
                                   f" action=deactivate")
    else:
        execute_wts_command(cmd='ue_testmode_set_nr id={} testmode=bler profile_id={}\
                                action=deactivate'.format(ue_id, profile_id))


async def prepare_amf_for_inactive_state(amf_id=1, plmn_id='310:260', tac_id=200, watcher=None):
    if watcher:
        await watcher.send_command(f"amf_ue_ics_param id={amf_id} core_network_assistance_info=on"
                                   f" ue_identity_index_value=1 ue_specific_drx=64"
                                   f" periodic_registration_update_timer=1:10min plmn_id={plmn_id} tac_id={tac_id}")
    else:
        execute_wts_command(cmd='amf_ue_ics_param id={} core_network_assistance_info=on ue_identity_index_value=1\
                                 ue_specific_drx=64 periodic_registration_update_timer=1:10min\
                                 plmn_id={} tac_id={}'.format(amf_id, plmn_id, tac_id))


def create_timing_advance_profiles():
    """Function creates usable TA profiles for AirPhone
    profile 1: N41 TDD 32-63 TA"""

    execute_wts_command(cmd=f"ue_ta_nr profile_id=1 ue_p_delay_initial=256 ue_p_delay_min=256"
                            f" ue_p_delay_max=504 ue_speed=5 nb_reps_ta_sim=1")


def activate_timing_advance_profile(ue_id, profile_id):
    execute_wts_command(cmd=f"ue_testmode_set_nr id={ue_id} scell=0 testmode=ta"
                            f" profile_id={profile_id} action=activate")


def create_no_rrc_setup_req_profile():
    """Function creates profile for no sending MSG3"""
    execute_wts_command(cmd=f"cont_res_testmode_nr profile_id=1 missed_ra_resp=20 msg5_dtx=0")


def create_no_rrc_setup_complete_profile():
    """Function creates profile for no sending MSG5"""
    execute_wts_command(cmd=f"cont_res_testmode_nr profile_id=2 missed_ra_resp=0 msg5_dtx=255")
