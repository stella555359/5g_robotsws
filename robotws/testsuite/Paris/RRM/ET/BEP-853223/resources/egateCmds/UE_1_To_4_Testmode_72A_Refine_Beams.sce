
beam_control_testmode_nr profile_id=1 ueBeamIndexInitial=0 csirs_bestbeam=0 csirs_rsrp_best=-44 csirs_rsrp_avg=-50
sleep_script 1

beam_control_testmode_nr profile_id=2 ueBeamIndexInitial=0 csirs_bestbeam=1 csirs_rsrp_best=-45 csirs_rsrp_avg=-50
sleep_script 1

beam_control_testmode_nr profile_id=3 ueBeamIndexInitial=0 csirs_bestbeam=2 csirs_rsrp_best=-46 csirs_rsrp_avg=-50
sleep_script 1

beam_control_testmode_nr profile_id=4 ueBeamIndexInitial=0 csirs_bestbeam=3 csirs_rsrp_best=-47 csirs_rsrp_avg=-50
sleep_script 1

ue_testmode_set_nr id=1 testmode=beam_control action=activate profile_id=1 beamaction=attach scell=0
sleep_script 1

ue_testmode_set_nr id=2 testmode=beam_control action=activate profile_id=2 beamaction=attach scell=0
sleep_script 1

ue_testmode_set_nr id=3 testmode=beam_control action=activate profile_id=3 beamaction=attach scell=0
sleep_script 1

ue_testmode_set_nr id=4 testmode=beam_control action=activate profile_id=4 beamaction=attach scell=0
sleep_script 1

ul_mimo_srs_beam_pos_nr profile_id=200 mode=fixed init_quad_pos=0 init_sub_quad_pos=0 test_type=UL_MIMO srs_transmit_power_per_port=-849,-849,-849,-849
sleep_script 1

ue_testmode_set_nr id=1 testmode=ul_mimo_srs_beam_pos action=activate profile_id=200
sleep_script 1

ue_testmode_set_nr id=2 testmode=ul_mimo_srs_beam_pos action=activate profile_id=200
sleep_script 1

ue_testmode_set_nr id=3 testmode=ul_mimo_srs_beam_pos action=activate profile_id=200
sleep_script 1

ue_testmode_set_nr id=4 testmode=ul_mimo_srs_beam_pos action=activate profile_id=200
sleep_script 1