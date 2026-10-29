require "sim_config"

function seq_configuration(duration)

	------------TC : DL CELL PEAK TUPT 553Mbps ----------------------------------

	exec('seq_set id=1 name=NSA_CELL_DL  ue_group=13')
    exec('ue_attach mode=ccsrt ue_eutra_nr_capabilities=UE_MRDC ue_nr_capabilities=UE_NSA_N71_25MHz capability_file=./capability.cfg')
    exec('seq_delay 0.5')
    exec('enb_ue_dc_start target_gnb=2 target_cells=1 bearer=2 type=split_scg')
    exec('seq_delay 0.5')
    exec('trf_data_start id=2 dir=dl trf_id=1 kbps=7695 size=1298 protocol=tcp')
    exec('sleep '..duration..'')
    exec('trf_data_stop id=2')
    exec('seq_delay 0.5')
    exec('enb_release_ue_dc bearer=2 by=enb cause=off')
    exec('seq_delay 0.5')
    exec('ue_detach')
    exec('seq_end')
 
	------------TC : UL CELL PEAK TUPT 282Mbps ----------------------------------

	exec('seq_set id=2 name=NSA_CELL_UL  ue_group=13')
    exec('ue_attach mode=ccsrt ue_eutra_nr_capabilities=UE_MRDC ue_nr_capabilities=UE_NSA_N71_25MHz capability_file=./capability.cfg')
    exec('seq_delay 0.5')
    exec('enb_ue_dc_start target_gnb=2 target_cells=1 bearer=2 type=split_scg')
    exec('seq_delay 0.5')
    exec('trf_data_start id=2 dir=ul trf_id=1 kbps=3916 size=1298 protocol=tcp')
    exec('sleep '..duration..'')
    exec('trf_data_stop id=2')
    exec('seq_delay 0.5')
    exec('enb_release_ue_dc bearer=2 by=enb cause=off')
    exec('seq_delay 0.5')
    exec('ue_detach')
    exec('seq_end')
	
	---------TC : DL L1 SUBPOOL 1519Mbps with 3 CELL----------------------------------
	
	exec('seq_set id=3 name=NSA_SUBPOOL_DL  ue_group=13')
    exec('ue_attach mode=ccsrt ue_eutra_nr_capabilities=UE_MRDC ue_nr_capabilities=UE_NSA_N71_25MHz capability_file=./capability.cfg')
    exec('seq_delay 0.5')
    exec('enb_ue_dc_start target_gnb=2 target_cells=1 bearer=2 type=split_scg')
    exec('seq_delay 0.5')
    exec('trf_data_start id=2 dir=dl trf_id=1 kbps=160000 size=1298 protocol=tcp')
	exec('trf_data_start id=2 dir=dl trf_id=2 kbps=160000 size=1298 protocol=tcp')
	exec('trf_data_start id=2 dir=dl trf_id=3 kbps=160000 size=1298 protocol=tcp')
	exec('trf_data_start id=2 dir=dl trf_id=4 kbps=27000 size=1298 protocol=tcp')
    exec('sleep '..duration..'')
    exec('trf_data_stop id=2')
    exec('seq_delay 0.5')
    exec('enb_release_ue_dc bearer=2 by=enb cause=off')
    exec('seq_delay 0.5')
    exec('ue_detach')
    exec('seq_end')
	
	exec('seq_set id=4 name=NSA_SUBPOOL_DL  ue_group=14')
    exec('ue_attach mode=ccsrt ue_eutra_nr_capabilities=UE_MRDC ue_nr_capabilities=UE_NSA_N71_25MHz capability_file=./capability.cfg')
    exec('seq_delay 0.5')
    exec('enb_ue_dc_start target_gnb=2 target_cells=2 bearer=2 type=split_scg')
    exec('seq_delay 0.5')
    exec('trf_data_start id=2 dir=dl trf_id=1 kbps=160000 size=1298 protocol=tcp')
	exec('trf_data_start id=2 dir=dl trf_id=2 kbps=160000 size=1298 protocol=tcp')
	exec('trf_data_start id=2 dir=dl trf_id=3 kbps=160000 size=1298 protocol=tcp')
	exec('trf_data_start id=2 dir=dl trf_id=4 kbps=27000 size=1298 protocol=tcp')
    exec('sleep '..duration..'')
    exec('trf_data_stop id=2')
    exec('seq_delay 0.5')
    exec('enb_release_ue_dc bearer=2 by=enb cause=off')
    exec('seq_delay 0.5')
    exec('ue_detach')
    exec('seq_end')
	
	exec('seq_set id=5 name=NSA_SUBPOOL_DL  ue_group=15')
    exec('ue_attach mode=ccsrt ue_eutra_nr_capabilities=UE_MRDC ue_nr_capabilities=UE_NSA_N71_25MHz capability_file=./capability.cfg')
    exec('seq_delay 0.5')
    exec('enb_ue_dc_start target_gnb=2 target_cells=3 bearer=2 type=split_scg')
    exec('seq_delay 0.5')
    exec('trf_data_start id=2 dir=dl trf_id=1 kbps=160000 size=1298 protocol=tcp')
	exec('trf_data_start id=2 dir=dl trf_id=2 kbps=160000 size=1298 protocol=tcp')
	exec('trf_data_start id=2 dir=dl trf_id=3 kbps=160000 size=1298 protocol=tcp')
	exec('trf_data_start id=2 dir=dl trf_id=4 kbps=27000 size=1298 protocol=tcp')
    exec('sleep '..duration..'')
    exec('trf_data_stop id=2')
    exec('seq_delay 0.5')
    exec('enb_release_ue_dc bearer=2 by=enb cause=off')
    exec('seq_delay 0.5')
    exec('ue_detach')
    exec('seq_end')
	
	---------TC : UL L1 SUBPOOL 847Mbps with 3 CELL----------------------------------
	
	exec('seq_set id=6 name=NSA_SUBPOOL_UL  ue_group=13')
    exec('ue_attach mode=ccsrt ue_eutra_nr_capabilities=UE_MRDC ue_nr_capabilities=UE_NSA_N71_25MHz capability_file=./capability.cfg')
    exec('seq_delay 0.5')
    exec('enb_ue_dc_start target_gnb=2 target_cells=1 bearer=2 type=split_scg')
    exec('seq_delay 0.5')
    exec('trf_data_start id=2 dir=ul trf_id=1 kbps=160000 size=1298 protocol=tcp')
	exec('trf_data_start id=2 dir=ul trf_id=2 kbps=122000 size=1298 protocol=tcp')
    exec('sleep '..duration..'')
    exec('trf_data_stop id=2')
    exec('seq_delay 0.5')
    exec('enb_release_ue_dc bearer=2 by=enb cause=off')
    exec('seq_delay 0.5')
    exec('ue_detach')
    exec('seq_end')
	
	exec('seq_set id=7 name=NSA_SUBPOOL_UL  ue_group=14')
    exec('ue_attach mode=ccsrt ue_eutra_nr_capabilities=UE_MRDC ue_nr_capabilities=UE_NSA_N71_25MHz capability_file=./capability.cfg')
    exec('seq_delay 0.5')
    exec('enb_ue_dc_start target_gnb=2 target_cells=2 bearer=2 type=split_scg')
    exec('seq_delay 0.5')
    exec('trf_data_start id=2 dir=ul trf_id=1 kbps=160000 size=1298 protocol=tcp')
	exec('trf_data_start id=2 dir=ul trf_id=2 kbps=122000 size=1298 protocol=tcp')
    exec('sleep '..duration..'')
    exec('trf_data_stop id=2')
    exec('seq_delay 0.5')
    exec('enb_release_ue_dc bearer=2 by=enb cause=off')
    exec('seq_delay 0.5')
    exec('ue_detach')
    exec('seq_end')
	
	exec('seq_set id=8 name=NSA_SUBPOOL_UL  ue_group=15')
    exec('ue_attach mode=ccsrt ue_eutra_nr_capabilities=UE_MRDC ue_nr_capabilities=UE_NSA_N71_25MHz capability_file=./capability.cfg')
    exec('seq_delay 0.5')
    exec('enb_ue_dc_start target_gnb=2 target_cells=3 bearer=2 type=split_scg')
    exec('seq_delay 0.5')
    exec('trf_data_start id=2 dir=ul trf_id=1 kbps=160000 size=1298 protocol=tcp')
	exec('trf_data_start id=2 dir=ul trf_id=2 kbps=122000 size=1298 protocol=tcp')
    exec('sleep '..duration..'')
    exec('trf_data_stop id=2')
    exec('seq_delay 0.5')
    exec('enb_release_ue_dc bearer=2 by=enb cause=off')
    exec('seq_delay 0.5')
    exec('ue_detach')
    exec('seq_end')
	

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
    exec('bearer_ue_param id=2 ue=865-1728 scg_ul_dist_percent=90')
    sleep(0.5)
    exec('seq_start id=2 rate=1 detailed_print=on max_active_ues=72 max_start=72')
	sleep(75)
	vm0_print("run_NSA_72UE_UL script completed")
end

function run_NSA_3UE_SUBPOOL_DL()
	
	exec('uec_l2_testmode_params fixed_csi_report=true')
	enable_vip_logs()
    sleep(0.5)
    exec('seq_start id=3,4,5 rate=1 detailed_print=on max_active_ues=1 max_start=1')
	sleep(75)
	vm0_print("run_NSA_3UE_SUBPOOL_DL script completed")
    exec('set_log flush')
    sleep(1)

end

function run_NSA_3UE_SUBPOOL_UL()

    exec('uec_l2_testmode_params fixed_csi_report=true')
    enable_vip_logs()
    sleep(0.5)
    exec('bearer_ue_param id=2 ue=865-1728 scg_ul_dist_percent=90')
    sleep(0.5)
    exec('seq_start id=6,7,8 rate=1 detailed_print=on max_active_ues=1 max_start=1')
    sleep(75)
    vm0_print("run_NSA_3UE_SUBPOOL_UL script completed")
    exec('set_log flush')
    sleep(1)

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

--[[ 

commands to egate
  cfg file=sim_config.lua entry=run_configuration(SIM_FDD_12CELL_25MHz_CNI108638,5400)
  script file=sim_config.lua entry=mib_sib_check(SIM_FDD_12CELL_25MHz_CNI108638)
  script file=sim_config.lua entry=x2_connections(SIM_FDD_12CELL_25MHz_CNI108638)
  script file=test_sequence.lua entry=run_NSA_72UE_DL
  script file=test_sequence.lua entry=run_NSA_72UE_UL
  script file=test_sequence.lua entry=run_NSA_3UE_SUBPOOL_UL
  script file=test_sequence.lua entry=run_NSA_3UE_SUBPOOL_DL
--]]
