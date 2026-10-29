require "sim_config"

function seq_configuration(duration)
--TC9-T+F_NSA_2CC_8406FF_SRSBF_Pcell_1100Mbps_nonBF_Scell_446Mbps_72UE_percell
    exec('seq_set id=1 name=NSA_L1POOL_DL  ue_group=13')
    exec('ue_attach mode=ccsrt ue_eutra_nr_capabilities=NR_FT_NSA_ENDC_UE_CAP ue_nr_capabilities=UE_Capa_NSA_NR_FT capability_file=./capability.cfg ')
    exec('seq_delay 0.1')
    exec('ue_dc_enb_start target_gnb=2 target_cells=1 bearer=2 type=split_scg')  --sgnb add
    exec('seq_delay 0.1')
    exec('trf_data_start id=2 dir=dl trf_id=1 kbps=21460 size=1298 protocol=tcp')
    exec('sleep '..duration..'')
    exec('trf_data_stop id=2 dir=dl trf_id=1')
    exec('seq_delay 0.1')
    exec('enb_ue_dc_release bearer=2 by=enb cause=off')     --sgnb del
    exec('seq_delay 0.1')
    exec('ue_detach ')
    exec('seq_end')
    exec('seq_set id=2 name=NSA_L1POOL_DL  ue_group=14')
    exec('ue_attach mode=ccsrt ue_eutra_nr_capabilities=NR_FT_NSA_ENDC_UE_CAP ue_nr_capabilities=UE_Capa_NSA_NR_FT capability_file=./capability.cfg ')
    exec('seq_delay 0.1')
    exec('ue_dc_enb_start target_gnb=2 target_cells=1 bearer=2 type=split_scg')  --sgnb add
    exec('seq_delay 0.1')
    exec('trf_data_start id=2 dir=dl trf_id=1 kbps=21460 size=1298 protocol=tcp')
    exec('sleep '..duration..'')
    exec('trf_data_stop id=2 dir=dl trf_id=1')
    exec('seq_delay 0.1')
    exec('enb_ue_dc_release bearer=2 by=enb cause=off')     --sgnb del
    exec('seq_delay 0.1')
    exec('ue_detach ')
    exec('seq_end')
    exec('seq_set id=3 name=NSA_L1POOL_DL  ue_group=15')
    exec('ue_attach mode=ccsrt ue_eutra_nr_capabilities=NR_FT_NSA_ENDC_UE_CAP ue_nr_capabilities=UE_Capa_NSA_NR_FT capability_file=./capability.cfg ')
    exec('seq_delay 0.1')
    exec('ue_dc_enb_start target_gnb=2 target_cells=1 bearer=2 type=split_scg')  --sgnb add
    exec('seq_delay 0.1')
    exec('trf_data_start id=2 dir=dl trf_id=1 kbps=15270 size=1298 protocol=tcp')
    exec('sleep '..duration..'')
    exec('trf_data_stop id=2 dir=dl trf_id=1')
    exec('seq_delay 0.1')
    exec('enb_ue_dc_release bearer=2 by=enb cause=off')     --sgnb del
    exec('seq_delay 0.1')
    exec('ue_detach ')
    exec('seq_end')
    exec('seq_set id=4 name=NSA_L1POOL_DL  ue_group=16')
    exec('ue_attach mode=ccsrt ue_eutra_nr_capabilities=MRDC_NSA_CAP_UE ue_nr_capabilities=NSA_UE_NR_CAP capability_file=./capability.cfg ')
    exec('seq_delay 0.1')
    exec('ue_dc_enb_start target_gnb=2 target_cells=2 bearer=2 type=split_scg')  --sgnb add
    exec('seq_delay 0.1')
    exec('trf_data_start id=2 dir=dl trf_id=1 kbps=6194 size=1298 protocol=tcp')
    exec('sleep '..duration..'')
    exec('trf_data_stop id=2 dir=dl trf_id=1')
    exec('seq_delay 0.1')
    exec('enb_ue_dc_release bearer=2 by=enb cause=off')     --sgnb del
    exec('seq_delay 0.1')
    exec('ue_detach ')
    exec('seq_end')
end

function NSA_TD_FR1_TCP_TC9_DL()
    exec('uec_l2_testmode_params fixed_csi_report=true')
    sleep(1)
    exec('filter_sim_rfm disable=all')
	sleep(1)
	exec('filter_sim_rfm enable=CSI,ACR,OERR,IERR,VIP')
	sleep(1)
    exec('seq_start rate=1 id=1 detailed_print=on duration=25 max_active_ues=20')
    sleep(25)
    exec('seq_start rate=1 id=2 detailed_print=on duration=25 max_active_ues=20')
    sleep(25)
    exec('seq_start rate=1 id=3 detailed_print=on duration=35 max_active_ues=32')
    sleep(35)
    exec('seq_start rate=1 id=4 detailed_print=on duration=35 max_active_ues=32')
    sleep(35)
    exec('filter_sim_rfm enable=all')
    exec('ue_summary')
    print("NSA_TD_FR1_TCP_TC9_DL script completed")
    exec("set_log flush")
    sleep(1)
    exec('filter_sim_rfm enable=CSI,ACR,OERR,IERR,VIP')
    sleep(1)
    exec('filter_sim_rfm disable=all')
    exec("set_log flush")
end


--[[ 

commands to egate
  cfg file=sim_config.lua entry=run_configuration(SIM_FDD_12CELL_25MHz_CNI108638,5400)
  script file=sim_config.lua entry=check_mib_sib(SIM_FDD_12CELL_25MHz_CNI108638)
  script file=sim_config.lua entry=x2_connections(SIM_FDD_12CELL_25MHz_CNI108638)
  script file=test_sequence.lua entry=run_NSA_72UE_DL
  script file=test_sequence.lua entry=run_NSA_72UE_UL
  script file=test_sequence.lua entry=run_NSA_3UE_SUBPOOL_UL
  script file=test_sequence.lua entry=run_NSA_3UE_SUBPOOL_DL
--]]
