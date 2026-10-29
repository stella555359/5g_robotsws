function x2_link()
    exec('enb_x2_link_up enb=3 target=2')
    sleep(0.5)
    exec('enb_x2_link_up enb=4 target=2')
    sleep(0.5)
    exec('enb_x2_link_up enb=5 target=2')
    sleep(0.5)
    exec('enb_x2_link_up enb=6 target=2')
    sleep(0.5)
    exec('enb_x2_link_up enb=7 target=2')
    sleep(0.5)
    exec('enb_x2_link_up enb=8 target=2')
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


function seq_configuration(duration)

	------------TC : UL CELL PEAK TUPT 553Mbps ----------------------------------

	exec('seq_set id=13 name=NSA_CELL_UL  ue_group=13')
    exec('ue_attach mode=ccsrt ue_nr_capabilities=MU_MIMO ue_eutra_nr_capabilities=EUTRA_MUMIMO capability_file=./capability.cfg ')
	exec('seq_delay 1.0')
    exec('ue_dc_enb_start target_gnb=2 target_cells=1 bearer=2 type=split_scg')  --sgnb add
    exec('seq_delay 1.0')
	exec('trf_data_start id=2 dir=ul trf_id=1 kbps=11945 size=1350 protocol=tcp')
	exec('sleep '..duration..'')
	exec('trf_data_stop id=2 dir=ul trf_id=1')
	exec('seq_delay 0.5')
    exec('enb_ue_dc_release bearer=2 by=enb cause=off')     --sgnb del
	exec('seq_delay 1.0')
	exec('ue_detach ')
	exec('seq_end')

	exec('seq_set id=14 name=NSA_CELL_UL  ue_group=14')
    exec('ue_attach mode=ccsrt ue_nr_capabilities=MU_MIMO ue_eutra_nr_capabilities=EUTRA_MUMIMO capability_file=./capability.cfg ')
	exec('seq_delay 1.0')
    exec('ue_dc_enb_start target_gnb=2 target_cells=1 bearer=2 type=split_scg')  --sgnb add
    exec('seq_delay 1.0')
	exec('trf_data_start id=2 dir=ul trf_id=1 kbps=11945 size=1350 protocol=tcp')
	exec('sleep '..duration..'')
	exec('trf_data_stop id=2 dir=ul trf_id=1')
	exec('seq_delay 0.5')
    exec('enb_ue_dc_release bearer=2 by=enb cause=off')     --sgnb del
	exec('seq_delay 1.0')
	exec('ue_detach ')
	exec('seq_end')

	exec('seq_set id=15 name=NSA_CELL_UL  ue_group=15')
    exec('ue_attach mode=ccsrt ue_nr_capabilities=MU_MIMO ue_eutra_nr_capabilities=EUTRA_MUMIMO capability_file=./capability.cfg ')
	exec('seq_delay 1.0')
    exec('ue_dc_enb_start target_gnb=2 target_cells=1 bearer=2 type=split_scg')  --sgnb add
    exec('seq_delay 1.0')
	exec('trf_data_start id=2 dir=ul trf_id=1 kbps=11945 size=1350 protocol=tcp')
	exec('sleep '..duration..'')
	exec('trf_data_stop id=2 dir=ul trf_id=1')
	exec('seq_delay 0.5')
    exec('enb_ue_dc_release bearer=2 by=enb cause=off')     --sgnb del
	exec('seq_delay 1.0')
	exec('ue_detach ')
	exec('seq_end')

	
 --[[
	------------TC : UL CELL PEAK TUPT 282Mbps ----------------------------------

	exec('seq_set id=2 name=NSA_CELL_UL  ue_group=13')
    exec('ue_attach  mode=ccsrt ue_eutra_nr_capabilities=UE_MRDC ue_nr_capabilities=UE_NSA_N71_25MHz capability_file=./capability.cfg')
    exec('seq_delay 0.5')
    exec('enb_ue_dc_start target_gnb=2 target_cells=1 bearer=2 type=split_scg')
    exec('seq_delay 0.5')
    exec('trf_data_start id=2 dir=ul trf_id=1 kbps=3916 size=1350 protocol=tcp')
    exec('sleep '..duration..'')
    exec('trf_data_stop id=2')
    exec('seq_delay 0.5')
    exec('enb_release_ue_dc bearer=2 by=enb cause=off')
    exec('seq_delay 0.5')
    exec('ue_detach')
    exec('seq_end')
	
	---------TC : DL L1 SUBPOOL 1519Mbps with 3 CELL----------------------------------
	
	exec('seq_set id=3 name=NSA_SUBPOOL_DL  ue_group=13')
    exec('ue_attach  mode=ccsrt ue_eutra_nr_capabilities=UE_MRDC ue_nr_capabilities=UE_NSA_N71_25MHz capability_file=./capability.cfg')
    exec('seq_delay 0.5')
    exec('enb_ue_dc_start target_gnb=2 target_cells=1 bearer=2 type=split_scg')
    exec('seq_delay 0.5')
    exec('trf_data_start id=2 dir=dl trf_id=1 kbps=160000 size=1350 protocol=tcp')
	exec('trf_data_start id=2 dir=dl trf_id=2 kbps=160000 size=1350 protocol=tcp')
	exec('trf_data_start id=2 dir=dl trf_id=3 kbps=160000 size=1350 protocol=tcp')
	exec('trf_data_start id=2 dir=dl trf_id=4 kbps=27000 size=1350 protocol=tcp')
    exec('sleep '..duration..'')
    exec('trf_data_stop id=2')
    exec('seq_delay 0.5')
    exec('enb_release_ue_dc bearer=2 by=enb cause=off')
    exec('seq_delay 0.5')
    exec('ue_detach')
    exec('seq_end')
	
	exec('seq_set id=4 name=NSA_SUBPOOL_DL  ue_group=14')
    exec('ue_attach  mode=ccsrt ue_eutra_nr_capabilities=UE_MRDC ue_nr_capabilities=UE_NSA_N71_25MHz capability_file=./capability.cfg')
    exec('seq_delay 0.5')
    exec('enb_ue_dc_start target_gnb=2 target_cells=2 bearer=2 type=split_scg')
    exec('seq_delay 0.5')
    exec('trf_data_start id=2 dir=dl trf_id=1 kbps=160000 size=1350 protocol=tcp')
	exec('trf_data_start id=2 dir=dl trf_id=2 kbps=160000 size=1350 protocol=tcp')
	exec('trf_data_start id=2 dir=dl trf_id=3 kbps=160000 size=1350 protocol=tcp')
	exec('trf_data_start id=2 dir=dl trf_id=4 kbps=27000 size=1350 protocol=tcp')
    exec('sleep '..duration..'')
    exec('trf_data_stop id=2')
    exec('seq_delay 0.5')
    exec('enb_release_ue_dc bearer=2 by=enb cause=off')
    exec('seq_delay 0.5')
    exec('ue_detach')
    exec('seq_end')
	
	exec('seq_set id=5 name=NSA_SUBPOOL_DL  ue_group=15')
    exec('ue_attach  mode=ccsrt ue_eutra_nr_capabilities=UE_MRDC ue_nr_capabilities=UE_NSA_N71_25MHz capability_file=./capability.cfg')
    exec('seq_delay 0.5')
    exec('enb_ue_dc_start target_gnb=2 target_cells=3 bearer=2 type=split_scg')
    exec('seq_delay 0.5')
    exec('trf_data_start id=2 dir=dl trf_id=1 kbps=160000 size=1350 protocol=tcp')
	exec('trf_data_start id=2 dir=dl trf_id=2 kbps=160000 size=1350 protocol=tcp')
	exec('trf_data_start id=2 dir=dl trf_id=3 kbps=160000 size=1350 protocol=tcp')
	exec('trf_data_start id=2 dir=dl trf_id=4 kbps=27000 size=1350 protocol=tcp')
    exec('sleep '..duration..'')
    exec('trf_data_stop id=2')
    exec('seq_delay 0.5')
    exec('enb_release_ue_dc bearer=2 by=enb cause=off')
    exec('seq_delay 0.5')
    exec('ue_detach')
    exec('seq_end')
	
	---------TC : UL L1 SUBPOOL 847Mbps with 3 CELL----------------------------------
	
	exec('seq_set id=6 name=NSA_SUBPOOL_UL  ue_group=13')
    exec('ue_attach  mode=ccsrt ue_eutra_nr_capabilities=UE_MRDC ue_nr_capabilities=UE_NSA_N71_25MHz capability_file=./capability.cfg')
    exec('seq_delay 0.5')
    exec('enb_ue_dc_start target_gnb=2 target_cells=1 bearer=2 type=split_scg')
    exec('seq_delay 0.5')
    exec('trf_data_start id=2 dir=ul trf_id=1 kbps=160000 size=1350 protocol=tcp')
	exec('trf_data_start id=2 dir=ul trf_id=2 kbps=122000 size=1350 protocol=tcp')
    exec('sleep '..duration..'')
    exec('trf_data_stop id=2')
    exec('seq_delay 0.5')
    exec('enb_release_ue_dc bearer=2 by=enb cause=off')
    exec('seq_delay 0.5')
    exec('ue_detach')
    exec('seq_end')
	
	exec('seq_set id=7 name=NSA_SUBPOOL_UL  ue_group=14')
    exec('ue_attach  mode=ccsrt ue_eutra_nr_capabilities=UE_MRDC ue_nr_capabilities=UE_NSA_N71_25MHz capability_file=./capability.cfg')
    exec('seq_delay 0.5')
    exec('enb_ue_dc_start target_gnb=2 target_cells=2 bearer=2 type=split_scg')
    exec('seq_delay 0.5')
    exec('trf_data_start id=2 dir=ul trf_id=1 kbps=160000 size=1350 protocol=tcp')
	exec('trf_data_start id=2 dir=ul trf_id=2 kbps=122000 size=1350 protocol=tcp')
    exec('sleep '..duration..'')
    exec('trf_data_stop id=2')
    exec('seq_delay 0.5')
    exec('enb_release_ue_dc bearer=2 by=enb cause=off')
    exec('seq_delay 0.5')
    exec('ue_detach')
    exec('seq_end')
	
	exec('seq_set id=8 name=NSA_SUBPOOL_UL  ue_group=15')
    exec('ue_attach  mode=ccsrt ue_eutra_nr_capabilities=UE_MRDC ue_nr_capabilities=UE_NSA_N71_25MHz capability_file=./capability.cfg')
    exec('seq_delay 0.5')
    exec('enb_ue_dc_start target_gnb=2 target_cells=3 bearer=2 type=split_scg')
    exec('seq_delay 0.5')
    exec('trf_data_start id=2 dir=ul trf_id=1 kbps=160000 size=1350 protocol=tcp')
	exec('trf_data_start id=2 dir=ul trf_id=2 kbps=122000 size=1350 protocol=tcp')
    exec('sleep '..duration..'')
    exec('trf_data_stop id=2')
    exec('seq_delay 0.5')
    exec('enb_release_ue_dc bearer=2 by=enb cause=off')
    exec('seq_delay 0.5')
    exec('ue_detach')
    exec('seq_end')
	
--]]
end


function run_NSA_72UE_DL()

	exec('uec_l2_testmode_params fixed_csi_report=true')
	enable_vip_logs()
	sleep(0.5)
    exec('seq_start id=1 rate=1 detailed_print=on max_active_ues=72 max_start=72')
	sleep(75)
	vm0_print("run_NSA_72UE_DL script completed")
end

function run_NSA_72UE_UL()

	exec('uec_l2_testmode_params fixed_csi_report=true')
	enable_vip_logs()
    sleep(0.5)
    exec('seq_start id=2 rate=1 detailed_print=on max_active_ues=72 max_start=72')
	sleep(75)
	vm0_print("run_NSA_72UE_UL script completed")
end

function run_NSA_3UE_SUBPOOL_DL()
	
	exec('uec_l2_testmode_params fixed_csi_report=true')
--	enable_vip_logs()
--    sleep(0.5)
--    exec('seq_start id=3,4,5 rate=1 detailed_print=on max_active_ues=1 max_start=1')
      exec('seq_start id=3 rate=1 detailed_print=on max_active_ues=1 max_start=1')
	sleep(75)
	vm0_print("run_NSA_3UE_SUBPOOL_DL script completed")

end

function run_NSA_3UE_SUBPOOL_UL()

    exec('uec_l2_testmode_params fixed_csi_report=true')
    enable_vip_logs()
    sleep(0.5)
    exec('seq_start id=6,7,8 rate=1 detailed_print=on max_active_ues=1 max_start=1')
    sleep(75)
    vm0_print("run_NSA_3UE_SUBPOOL_UL script completed")

end

function run_ALL()
    run_NSA_72UE_DL()
    sleep(5500)
    run_NSA_72UE_UL()
    sleep(5500)
    run_NSA_3UE_SUBPOOL_DL()
    sleep(5500)
    run_NSA_3UE_SUBPOOL_UL()
end

function TDD_NSA_UL_peak_tp_860Mbps_72UEs_percell_1cell_ABIP()
    require "multi_ue_sa_script_new"
 --   require "sansa"
	exec('enb_x2_link_up enb=3 target=2')
    exec('uec_l2_testmode_params fixed_csi_report=true')
    sleep(1)
	exec('bearer_ue_param id=2 ue=2-81 scg_ul_dist_percent=90')
    sleep(1)
    exec('ul_mimo_srs_beam_pos_nr profile_id=1 mode=fixed init_quad_pos=0 init_sub_quad_pos=0 test_type=UL_MIMO')
    exec('ul_mimo_srs_beam_pos_nr profile_id=2 mode=fixed init_quad_pos=2 init_sub_quad_pos=3 test_type=UL_MIMO')
    exec('ul_mimo_srs_beam_pos_nr profile_id=3 mode=fixed init_quad_pos=3 init_sub_quad_pos=1 test_type=UL_MIMO')
    exec('ul_mimo_srs_beam_pos_nr profile_id=4 mode=fixed init_quad_pos=1 init_sub_quad_pos=1 test_type=UL_MIMO')
--    exec('ue_testmode_set_nr id=1-20 testmode=ul_mimo_srs_beam_pos action=activate profile_id=1') 
--    exec('ue_testmode_set_nr id=21-40 testmode=ul_mimo_srs_beam_pos action=activate profile_id=2')
--    exec('ue_testmode_set_nr id=41-60 testmode=ul_mimo_srs_beam_pos action=activate profile_id=3')
--    exec('ue_testmode_set_nr id=61-81 testmode=ul_mimo_srs_beam_pos action=activate profile_id=4')
	sleep(1)
--    exec('filter_sim_rfm disable=all')
--    exec('filter_sim_rfm enable=CSI,ACR,OERR,IERR,VIP')
    sleep(5)
    exec('seq_start rate=2 id=13 detailed_print=on duration=20 max_active_ues=24')
    sleep(25)
    exec('seq_start rate=2 id=14 detailed_print=on duration=20 max_active_ues=24')
    sleep(25)
    exec('seq_start rate=2 id=15 detailed_print=on duration=20 max_active_ues=24')
    sleep(25)
	exec('ue_testmode_set_nr id=1-20 testmode=ul_mimo_srs_beam_pos scell=8 action=activate profile_id=1') 
	exec('ue_testmode_set_nr id=21-40 testmode=ul_mimo_srs_beam_pos scell=8 action=activate profile_id=2')
	exec('ue_testmode_set_nr id=41-60 testmode=ul_mimo_srs_beam_pos scell=8 action=activate profile_id=3')
	exec('ue_testmode_set_nr id=61-81 testmode=ul_mimo_srs_beam_pos scell=8 action=activate profile_id=4')
	sleep(1)                                                        
    exec('ue_summary')
    sleep(1)
    exec('disp_sgw')
    sleep(1)
    exec('disp_pgw')
    exec('filter_sim_rfm enable=all')
    exec('ue_summary')
    print('TDD_NSA_UL_peak_tp_860Mbps_72UEs_percell_1cell_ABIP script completed')
    exec('sim_log_set flush')
    sleep(1)
    exec('filter_sim_rfm disable=all')
    sleep(1)
    exec('sim_rfm enable=CSI,ACR,OERR,IERR,VIP')
    sleep(1)
    exec("set_log flush")
end 

--[[ 

commands to egate

  cfg file=sim_config.lua entry=run_configuration(5400)
  script file=test_sequence.lua entry=x2_link()
  script file=test_sequence.lua entry=run_NSA_72UE_DL
  script file=test_sequence.lua entry=run_NSA_72UE_UL
  script file=test_sequence.lua entry=run_NSA_3UE_SUBPOOL_UL
  script file=test_sequence.lua entry=run_NSA_3UE_SUBPOOL_DL
--]]
