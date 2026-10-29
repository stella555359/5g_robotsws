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

    -----------TC1 : 1NSA UE FOUR CELL TPUT DL550Mbps UL110Mbps------------------------

    exec('seq_set id=1 name=TC1 ue_group=5')
    exec('ue_attach ue_eutra_nr_capabilities=FR2_8CC_NSA_EUTRACAPABILITY ue_nr_capabilities=FR2_8CC_NSA_UENRCAPABILITY capability_file=./capability.cfg')
    exec('seq_delay 0.5')
    exec('enb_ue_dc_start target_gnb=2 target_cells=1 bearer=2 type=split_scg')
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
    exec('trf_data_start id=2 dir=dl trf_id=11 mbps=160 size=1350')
    exec('trf_data_start id=2 dir=dl trf_id=12 mbps=160 size=1350')
    exec('trf_data_start id=2 dir=dl trf_id=13 mbps=160 size=1350')
    exec('trf_data_start id=2 dir=dl trf_id=14 mbps=160 size=1350')
    exec('trf_data_start id=2 dir=dl trf_id=15 mbps=160 size=1350')
    exec('trf_data_start id=2 dir=dl trf_id=16 mbps=160 size=1350')
    exec('trf_data_start id=2 dir=dl trf_id=17 mbps=160 size=1350')
    exec('trf_data_start id=2 dir=dl trf_id=18 mbps=160 size=1350')
    exec('trf_data_start id=2 dir=dl trf_id=19 mbps=160 size=1350')
    exec('trf_data_start id=2 dir=dl trf_id=20 mbps=160 size=1350')
    exec('trf_data_start id=2 dir=dl trf_id=21 mbps=160 size=1350')
    exec('trf_data_start id=2 dir=dl trf_id=22 mbps=160 size=1350')
    exec('trf_data_start id=2 dir=dl trf_id=23 mbps=160 size=1350')
    exec('trf_data_start id=2 dir=dl trf_id=24 mbps=160 size=1350')
    exec('trf_data_start id=2 dir=dl trf_id=25 mbps=160 size=1350')
    exec('trf_data_start id=2 dir=dl trf_id=26 mbps=160 size=1350')
    exec('trf_data_start id=2 dir=dl trf_id=27 mbps=140 size=1350')
	
    exec('trf_data_start id=2 dir=ul trf_id=1 mbps=160 size=1350')
    exec('trf_data_start id=2 dir=ul trf_id=2 mbps=160 size=1350')
    exec('trf_data_start id=2 dir=ul trf_id=3 mbps=160 size=1350')
    exec('trf_data_start id=2 dir=ul trf_id=4 mbps=80 size=1350')
	
    exec('sleep '..duration..'')
    exec('trf_data_stop id=1')
    exec('seq_delay 0.5')
    exec('enb_release_ue_dc bearer=2 by=enb cause=off')
    exec('seq_delay 0.5')
    exec('ue_detach')
    exec('seq_end')

    -----------TC2 : 10NSA UE 1S8CC TPUT DL4300Mbps UL560Mbps------------------------

    exec('seq_set id=2 name=TC2 ue_group=5')
    exec('ue_attach ue_eutra_nr_capabilities=FR2_8CC_NSA_EUTRACAPABILITY ue_nr_capabilities=FR2_8CC_NSA_UENRCAPABILITY capability_file=./capability.cfg')
    exec('seq_delay 0.5')
    exec('enb_ue_dc_start target_gnb=2 target_cells=1 bearer=2 type=split_scg')
    exec('seq_delay 0.5')
    exec('trf_data_start id=2 dir=dl trf_id=1 kbps=150000 size=1350')
    exec('trf_data_start id=2 dir=dl trf_id=2 kbps=150000 size=1350')
    exec('trf_data_start id=2 dir=dl trf_id=3 kbps=130000 size=1350')
    exec('trf_data_start id=2 dir=ul trf_id=1 kbps=56000 size=1350')
    exec('sleep '..duration..'')
    exec('trf_data_stop id=2')
    exec('seq_delay 0.5')
    exec('enb_release_ue_dc bearer=2 by=enb cause=off')
    exec('seq_delay 0.5')
    exec('ue_detach')
    exec('seq_end')

    -----------TC3 : 10NSA UE FOUR CELL TPUT DL550Mbps UL110Mbps------------------------

    exec('seq_set id=3 name=TC3 ue_group=5')
    exec('ue_attach ue_eutra_nr_capabilities=FR2_8CC_NSA_EUTRACAPABILITY ue_nr_capabilities=FR2_8CC_NSA_UENRCAPABILITY capability_file=./capability.cfg')
    exec('seq_delay 0.5')
    exec('enb_ue_dc_start target_gnb=2 target_cells=1 bearer=2 type=split_scg')
    exec('seq_delay 0.5')
    exec('trf_data_start id=2 dir=dl trf_id=1 kbps=55000 size=1350')
    exec('trf_data_start id=2 dir=ul trf_id=1 kbps=11000 size=1350')
    exec('sleep '..duration..'')
    exec('trf_data_stop id=3')
    exec('seq_delay 0.5')
    exec('enb_release_ue_dc bearer=2 by=enb cause=off')
    exec('seq_delay 0.5')
    exec('ue_detach')
    exec('seq_end')

    exec('seq_set id=4 name=TC3 ue_group=6')
    exec('ue_attach ue_eutra_nr_capabilities=FR2_8CC_NSA_EUTRACAPABILITY ue_nr_capabilities=FR2_8CC_NSA_UENRCAPABILITY capability_file=./capability.cfg')
    exec('seq_delay 0.5')
    exec('enb_ue_dc_start target_gnb=2 target_cells=2 bearer=2 type=split_scg')
    exec('seq_delay 0.5')
    exec('trf_data_start id=2 dir=dl trf_id=1 kbps=55000 size=1350')
    exec('trf_data_start id=2 dir=ul trf_id=1 kbps=11000 size=1350')
    exec('sleep '..duration..'')
    exec('trf_data_stop id=4')
    exec('seq_delay 0.5')
    exec('enb_release_ue_dc bearer=2 by=enb cause=off')
    exec('seq_delay 0.5')
    exec('ue_detach')
    exec('seq_end')

    exec('seq_set id=5 name=TC3 ue_group=7')
    exec('ue_attach ue_eutra_nr_capabilities=FR2_8CC_NSA_EUTRACAPABILITY ue_nr_capabilities=FR2_8CC_NSA_UENRCAPABILITY capability_file=./capability.cfg')
    exec('seq_delay 0.5')
    exec('enb_ue_dc_start target_gnb=2 target_cells=3 bearer=2 type=split_scg')
    exec('seq_delay 0.5')
    exec('trf_data_start id=2 dir=dl trf_id=1 kbps=55000 size=1350')
    exec('trf_data_start id=2 dir=ul trf_id=1 kbps=11000 size=1350')
    exec('sleep '..duration..'')
    exec('trf_data_stop id=5')
    exec('seq_delay 0.5')
    exec('enb_release_ue_dc bearer=2 by=enb cause=off')
    exec('seq_delay 0.5')
    exec('ue_detach')
    exec('seq_end')

    exec('seq_set id=6 name=TC3 ue_group=8')
    exec('ue_attach ue_eutra_nr_capabilities=FR2_8CC_NSA_EUTRACAPABILITY ue_nr_capabilities=FR2_8CC_NSA_UENRCAPABILITY capability_file=./capability.cfg')
    exec('seq_delay 0.5')
    exec('enb_ue_dc_start target_gnb=2 target_cells=4 bearer=2 type=split_scg')
    exec('seq_delay 0.5')
    exec('trf_data_start id=2 dir=dl trf_id=1 kbps=55000 size=1350')
    exec('trf_data_start id=2 dir=ul trf_id=1 kbps=11000 size=1350')
    exec('sleep '..duration..'')
    exec('trf_data_stop id=6')
    exec('seq_delay 0.5')
    exec('enb_release_ue_dc bearer=2 by=enb cause=off')
    exec('seq_delay 0.5')
    exec('ue_detach')
    exec('seq_end')

end

function TC1_1NSA_8CC_DL_UL()
	exec('uec_l2_testmode_params fixed_csi_report=true')
	exec('sim_param_set disable_events_on_telnet_session=on')
	enable_vip_logs()
	sleep(0.5)
    exec('enb_endc_param id=1 serving_cell_index_range_scg=8:16')
    exec('seq_start id=1 rate=1 detailed_print=on max_start=1')
	sleep(5)
	vm0_print("TC1_1NSA_8CC_DL_UL script completed")
end

function TC2_10NSA_8CC_DL_UL()
	exec('uec_l2_testmode_params fixed_csi_report=true')
	exec('sim_param_set disable_events_on_telnet_session=on')
	enable_vip_logs()
	sleep(0.5)
    exec('enb_endc_param id=1 serving_cell_index_range_scg=8:16')
    exec('seq_start id=2 rate=1 detailed_print=on max_start=10')
	sleep(15)
	vm0_print("TC2_10NSA_8CC_DL_UL script completed")
end

function TC3_NSA_nonCA_4CELL_DL_UL()
	exec('uec_l2_testmode_params fixed_csi_report=true')
	exec('sim_param_set disable_events_on_telnet_session=on')
	enable_vip_logs()
	sleep(0.5)
    exec('enb_endc_param id=1 serving_cell_index_range_scg=8:8')
    exec('seq_start id=3 rate=1 detailed_print=on max_start=10')
	sleep(15)

    exec('enb_endc_param id=1 serving_cell_index_range_scg=9:9')
    exec('seq_start id=4 rate=1 detailed_print=on max_start=10')
	sleep(15)

    exec('enb_endc_param id=1 serving_cell_index_range_scg=10:10')
    exec('seq_start id=5 rate=1 detailed_print=on max_start=10')
	sleep(15)

    exec('enb_endc_param id=1 serving_cell_index_range_scg=11:11')
    exec('seq_start id=6 rate=1 detailed_print=on max_start=10')
	sleep(15)
	vm0_print("TC3_NSA_nonCA_4CELL_DL_UL script completed")
end

--[[
commands to egate
  cfg file=sim_config.lua entry=run_configuration(sansa,84000) --To configure sim or egate
  script file=test_sequence.lua entry=x2_link()
  script file=test_sequence.lua entry=TC1_1NSA_8CC_DL_UL
  script file=test_sequence.lua entry=TC2_10NSA_8CC_DL_UL
  script file=test_sequence.lua entry=TC3_NSA_nonCA_4CELL_DL_UL

--]]


