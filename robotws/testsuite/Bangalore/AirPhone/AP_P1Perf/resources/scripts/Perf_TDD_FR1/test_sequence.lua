function x2_link()
    exec('enb_x2_link_up enb=1 target=2')
end

function enable_vip_logs()
    exec('sim_rfm_filter disable=all')
    exec('sim_rfm enable=CSI,ACR,OERR,IERR,VIP')
end

function vm0_print(text)
    exec('sim_rfm_filter enable=all')
	print(text)
	exec('sim_rfm_filter disable=all')
    exec('sim_rfm enable=CSI,ACR,OERR,IERR,VIP')
end

function ue_proxy_loglevel()
    exec('sim_debug_log level=3 app_type=ueproxy')
end

function seq_configuration(duration)

    -----------TC1 : 1SA UE 3CC TPUT DL4800Mbps------------------------

    exec('seq_set id=1 name=TC1 ue_group=1')
    exec('ue_register ue_nr_capabilities=UE_CAP_3CC_CA capability_file=./capability.cfg registration_type=InitialRegistration')
    exec('ue_pdu_session_setup pdu=1 nwslice=1')
    exec('trf_data_start pdu=1 qfi=1 trf_id=1 dir=dl mbps=160 size=1350')
	exec('trf_data_start pdu=1 qfi=1 trf_id=2 dir=dl mbps=160 size=1350')
	exec('trf_data_start pdu=1 qfi=1 trf_id=3 dir=dl mbps=160 size=1350')
	exec('trf_data_start pdu=1 qfi=1 trf_id=4 dir=dl mbps=160 size=1350')
	exec('trf_data_start pdu=1 qfi=1 trf_id=5 dir=dl mbps=160 size=1350')
	exec('trf_data_start pdu=1 qfi=1 trf_id=6 dir=dl mbps=160 size=1350')
	exec('trf_data_start pdu=1 qfi=1 trf_id=7 dir=dl mbps=160 size=1350')
	exec('trf_data_start pdu=1 qfi=1 trf_id=8 dir=dl mbps=160 size=1350')
	exec('trf_data_start pdu=1 qfi=1 trf_id=9 dir=dl mbps=160 size=1350')
	exec('trf_data_start pdu=1 qfi=1 trf_id=10 dir=dl mbps=160 size=1350')
	exec('trf_data_start pdu=1 qfi=1 trf_id=11 dir=dl mbps=160 size=1350')
	exec('trf_data_start pdu=1 qfi=1 trf_id=12 dir=dl mbps=160 size=1350')
	exec('trf_data_start pdu=1 qfi=1 trf_id=13 dir=dl mbps=160 size=1350')
	exec('trf_data_start pdu=1 qfi=1 trf_id=14 dir=dl mbps=160 size=1350')
	exec('trf_data_start pdu=1 qfi=1 trf_id=15 dir=dl mbps=160 size=1350')
	exec('trf_data_start pdu=1 qfi=1 trf_id=16 dir=dl mbps=160 size=1350')
	exec('trf_data_start pdu=1 qfi=1 trf_id=17 dir=dl mbps=160 size=1350')
	exec('trf_data_start pdu=1 qfi=1 trf_id=18 dir=dl mbps=160 size=1350')
	exec('trf_data_start pdu=1 qfi=1 trf_id=19 dir=dl mbps=160 size=1350')
	exec('trf_data_start pdu=1 qfi=1 trf_id=20 dir=dl mbps=160 size=1350')
	exec('trf_data_start pdu=1 qfi=1 trf_id=21 dir=dl mbps=160 size=1350')
	exec('trf_data_start pdu=1 qfi=1 trf_id=22 dir=dl mbps=160 size=1350')
	exec('trf_data_start pdu=1 qfi=1 trf_id=23 dir=dl mbps=160 size=1350')
	exec('trf_data_start pdu=1 qfi=1 trf_id=24 dir=dl mbps=160 size=1350')
	exec('trf_data_start pdu=1 qfi=1 trf_id=25 dir=dl mbps=160 size=1350')
	exec('trf_data_start pdu=1 qfi=1 trf_id=26 dir=dl mbps=160 size=1350')
	exec('trf_data_start pdu=1 qfi=1 trf_id=27 dir=dl mbps=160 size=1350')
	exec('trf_data_start pdu=1 qfi=1 trf_id=28 dir=dl mbps=160 size=1350')
	exec('trf_data_start pdu=1 qfi=1 trf_id=29 dir=dl mbps=160 size=1350')
	exec('trf_data_start pdu=1 qfi=1 trf_id=30 dir=dl mbps=160 size=1350')
    exec('seq_delay '..duration..'')
    exec('ue_deregister by=ue ue_deregister_type=switch_off')
    exec('seq_end')

    -----------TC2 : 40SA UE 3CC TPUT DL4800Mbps UL200Mbps------------------------

    exec('seq_set id=2 name=TC2 ue_group=1')
    exec('ue_register ue_nr_capabilities=UE_CAP_3CC_CA capability_file=./capability.cfg registration_type=InitialRegistration')
    exec('ue_pdu_session_setup pdu=1 nwslice=1')
    exec('trf_data_start pdu=1 qfi=1 trf_id=1 dir=dl mbps=120 size=1350')
	exec('trf_data_start pdu=1 qfi=1 trf_id=1 dir=ul mbps=5 size=1350')
    exec('seq_delay '..duration..'')
    exec('ue_deregister by=ue ue_deregister_type=switch_off')
    exec('seq_end')

    -----------TC3 : 40SA UE MU-MIMO TPUT DL3200Mbps UL200Mbps------------------------

    exec('seq_set id=3 name=TC3 ue_group=2')
    exec('ue_register ue_nr_capabilities=UE_CAP_MU_MIMO capability_file=./capability.cfg registration_type=InitialRegistration')
    exec('ue_pdu_session_setup pdu=1 nwslice=1')
	exec('trf_data_start pdu=1 qfi=1 trf_id=1 dir=dl mbps=80 size=1350')
	exec('trf_data_start pdu=1 qfi=1 trf_id=2 dir=ul mbps=5 size=1350')
    exec('seq_delay '..duration..'')
    exec('ue_deregister by=ue ue_deregister_type=switch_off')
    exec('seq_end')

    -----------TC4 : 1000SA 1000NSA UE RRC CONNECTED------------------------

    exec('seq_set id=4 name=TC4_CELL1_SA ue_group=1')
    exec('ue_register ue_nr_capabilities=UE_CAP capability_file=./capability.cfg registration_type=InitialRegistration')
    exec('ue_pdu_session_setup pdu=1 nwslice=1')
    exec('trf_data_start pdu=1 qfi=1 trf_id=1 dir=dl bps=74')
    exec('trf_data_start pdu=1 qfi=1 trf_id=1 dir=ul bps=74')
    exec('seq_delay '..duration..'')
    exec('ue_deregister by=ue ue_deregister_type=switch_off')
    exec('seq_end')

    exec('seq_set id=5 name=TC4_CELL2_NSA ue_group=5')
    exec('ue_attach ue_eutra_nr_capabilities=UE_EUTRA_CAP ue_nr_capabilities=NSA_UE_CAP capability_file=./capability.cfg')
    exec('seq_delay 0.5')
    exec('enb_ue_dc_start target_gnb=2 target_cells=2 bearer=2 type=split_scg')
    exec('seq_delay 0.5')
    exec('trf_data_start id=2 dir=dl trf_id=1 bps=74')
    exec('trf_data_start id=2 dir=ul trf_id=1 bps=74')
    exec('sleep '..duration..'')
    exec('trf_data_stop id=2')
    exec('seq_delay 0.5')
    exec('enb_release_ue_dc bearer=2 by=enb cause=off')
    exec('seq_delay 0.5')
    exec('ue_detach')
    exec('seq_end')

    -----------TC5 : 1SA 1NSA UE DL1600Mbps UL200Mbps------------------------

    exec('seq_set id=6 name=TC5_CELL1_SA ue_group=1')
    exec('ue_register ue_nr_capabilities=UE_CAP capability_file=./capability.cfg registration_type=InitialRegistration')
    exec('ue_pdu_session_setup pdu=1 nwslice=1')
    exec('trf_data_start pdu=1 qfi=1 trf_id=1 dir=dl mbps=160 size=1350')
	exec('trf_data_start pdu=1 qfi=1 trf_id=2 dir=dl mbps=160 size=1350')
	exec('trf_data_start pdu=1 qfi=1 trf_id=3 dir=dl mbps=160 size=1350')
	exec('trf_data_start pdu=1 qfi=1 trf_id=4 dir=dl mbps=160 size=1350')
	exec('trf_data_start pdu=1 qfi=1 trf_id=5 dir=dl mbps=160 size=1350')
	exec('trf_data_start pdu=1 qfi=1 trf_id=6 dir=dl mbps=160 size=1350')
	exec('trf_data_start pdu=1 qfi=1 trf_id=7 dir=dl mbps=160 size=1350')
	exec('trf_data_start pdu=1 qfi=1 trf_id=8 dir=dl mbps=160 size=1350')
	exec('trf_data_start pdu=1 qfi=1 trf_id=9 dir=dl mbps=160 size=1350')
	exec('trf_data_start pdu=1 qfi=1 trf_id=10 dir=dl mbps=160 size=1350')
	exec('trf_data_start pdu=1 qfi=1 trf_id=1 dir=ul mbps=160 size=1350')
	exec('trf_data_start pdu=1 qfi=1 trf_id=2 dir=ul mbps=40 size=1350')
    exec('seq_delay '..duration..'')
    exec('ue_deregister by=ue ue_deregister_type=switch_off')
    exec('seq_end')

    exec('seq_set id=7 name=TC5_CELL2_NSA ue_group=6')
    exec('ue_attach ue_eutra_nr_capabilities=UE_EUTRA_CAP ue_nr_capabilities=NSA_UE_CAP capability_file=./capability.cfg')
    exec('seq_delay 0.5')
    exec('enb_ue_dc_start target_gnb=2 target_cells=3 bearer=2 type=split_scg')
    exec('seq_delay 0.5')
    exec('trf_data_start id=2 dir=dl trf_id=1 mbps=160 size=1350')
    exec('trf_data_start id=2 dir=dl trf_id=2 mbps=160 size=1350')
    exec('trf_data_start id=2 dir=dl trf_id=3 mbps=160 size=1350')
    exec('trf_data_start id=2 dir=dl trf_id=4 mbps=160 size=1350')
    exec('trf_data_start id=2 dir=dl trf_id=5 mbps=160 size=1350')
    exec('trf_data_start id=2 dir=dl trf_id=6 mbps=160 size=1350')
    exec('trf_data_start id=2 dir=dl trf_id=7 mbps=160 size=1350')
    exec('trf_data_start id=2 dir=dl trf_id=8 mbps=160 size=1350')
    exec('trf_data_start id=2 dir=dl trf_id=9 mbps=160 size=1350')
    exec('trf_data_start id=2 dir=dl trf_id=10 mbps=160 size=1350')
    exec('trf_data_start id=2 dir=ul trf_id=1 mbps=160 size=1350')
    exec('trf_data_start id=2 dir=ul trf_id=2 mbps=40 size=1350')
    exec('sleep '..duration..'')
    exec('trf_data_stop id=2')
    exec('seq_delay 0.5')
    exec('enb_release_ue_dc bearer=2 by=enb cause=off')
    exec('seq_delay 0.5')
    exec('ue_detach')
    exec('seq_end')

end

function TC1_SUE_3CC_DL()
	exec('uec_l2_testmode_params fixed_csi_report=true')
	exec('sim_param_set disable_events_on_telnet_session=on')
	enable_vip_logs()
	sleep(0.5)
    exec('seq_start id=1 rate=1 detailed_print=on max_start=1')
	sleep(5)
	vm0_print("TC1_SUE_3CC_DL script completed")
end

function TC2_40SA_3CC_DL_UL()
	exec('uec_l2_testmode_params fixed_csi_report=true')
	exec('sim_param_set disable_events_on_telnet_session=on')
	enable_vip_logs()
	sleep(0.5)
    exec('seq_start id=2 rate=1 detailed_print=on max_start=40')
	sleep(50)
	vm0_print("TC2_40SA_3CC_DL_UL script completed")
end

function TC3_40SA_MUMIMO_DL_UL()
	exec('uec_l2_testmode_params fixed_csi_report=true')
	exec('sim_param_set disable_events_on_telnet_session=on')
	enable_vip_logs()
	sleep(0.5)
	exec('ul_sinr_testmode_nr profile_id=7 sinr_target_srs=100 noise_srs=-1053')
	exec('ue_testmode_set_nr id=1-40 testmode=ul_sinr action=activate profile_id=7')
	exec('ue_srs_beam_pos_nr profile_id=1 srsMode=fixed init_pos=0')
	exec('ue_srs_beam_pos_nr profile_id=2 srsMode=fixed init_pos=1')
	exec('ue_srs_beam_pos_nr profile_id=3 srsMode=fixed init_pos=2')
	exec('ue_srs_beam_pos_nr profile_id=4 srsMode=fixed init_pos=3')
	exec('ue_testmode_set_nr id=751-760 testmode=ue_srs_beam_pos action=activate profile_id=1')
	exec('ue_testmode_set_nr id=761-770 testmode=ue_srs_beam_pos action=activate profile_id=2')
	exec('ue_testmode_set_nr id=771-780 testmode=ue_srs_beam_pos action=activate profile_id=3')
	exec('ue_testmode_set_nr id=781-790 testmode=ue_srs_beam_pos action=activate profile_id=4')
    exec('seq_start id=3 rate=1 detailed_print=on max_start=40')
	sleep(50)
	vm0_print("TC3_40SA_MUMIMO_DL_UL script completed")
end

function TC4_1000SA_1000NSA_RRC()
	exec('uec_l2_testmode_params fixed_csi_report=true')
	exec('sim_param_set disable_events_on_telnet_session=on')
	enable_vip_logs()
	sleep(0.5)
    exec('seq_start id=4 rate=2 detailed_print=on max_start=1000')
    sleep(520)
    exec('enb_endc_param id=1 serving_cell_index_range_scg=9:9')
    exec('seq_start id=5 rate=2 detailed_print=on max_start=1000')
	sleep(520)
	vm0_print("TC4_1000SA_1000NSA_RRC script completed")
end

function TC5_1SA_1SA_PEAK_DL_UL()
	exec('uec_l2_testmode_params fixed_csi_report=true')
	exec('sim_param_set disable_events_on_telnet_session=on')
	enable_vip_logs()
	sleep(0.5)
    exec('seq_start id=6 rate=1 detailed_print=on max_start=1')
    sleep(5)
    exec('enb_endc_param id=1 serving_cell_index_range_scg=10:10')
    exec('seq_start id=7 rate=1 detailed_print=on max_start=1')
	sleep(5)
	vm0_print("TC5_1SA_1SA_PEAK_DL_UL script completed")
end

--[[
commands to egate
  cfg file=sim_config.lua entry=run_configuration(sansa,84000) --To configure sim or egate
  script file=test_sequence.lua entry=x2_link()
  script file=test_sequence.lua entry=TC1_SUE_3CC_DL
  script file=test_sequence.lua entry=TC2_40SA_3CC_DL_UL
  script file=test_sequence.lua entry=TC3_40SA_MUMIMO_DL_UL
  script file=test_sequence.lua entry=TC4_1000SA_1000NSA_RRC
  script file=test_sequence.lua entry=TC5_1SA_1SA_PEAK_DL_UL

--]]
