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

	------------TC1 : 1 SA UE SINGLE CELL TPUT DL1600Mbps UL220Mbps----------------------------------

	exec('seq_set id=1 name=SA-CELL_PEAK-UL-DL ue_group=1')	
	exec('ue_register ue_nr_capabilities=n25A_n66A_n71A_n773A capability_file=./capability.cfg registration_type=InitialRegistration')
	exec('ue_pdu_session_setup pdu=1  nwslice=1')
	exec('trf_data_start pdu=1 qfi=1 trf_id=1 dir=dl kbps=160000 size=1350')
	exec('trf_data_start pdu=1 qfi=1 trf_id=2 dir=dl kbps=160000 size=1350')
	exec('trf_data_start pdu=1 qfi=1 trf_id=3 dir=dl kbps=160000 size=1350')
	exec('trf_data_start pdu=1 qfi=1 trf_id=4 dir=dl kbps=160000 size=1350')
	exec('trf_data_start pdu=1 qfi=1 trf_id=5 dir=dl kbps=160000 size=1350')
	exec('trf_data_start pdu=1 qfi=1 trf_id=6 dir=dl kbps=160000 size=1350')
	exec('trf_data_start pdu=1 qfi=1 trf_id=7 dir=dl kbps=160000 size=1350')
	exec('trf_data_start pdu=1 qfi=1 trf_id=8 dir=dl kbps=160000 size=1350')
	exec('trf_data_start pdu=1 qfi=1 trf_id=9 dir=dl kbps=160000 size=1350')
	exec('trf_data_start pdu=1 qfi=1 trf_id=10 dir=dl kbps=160000 size=1350')
	exec('trf_data_start pdu=1 qfi=1 trf_id=1 dir=ul kbps=160000 size=1350')
	exec('trf_data_start pdu=1 qfi=1 trf_id=2 dir=ul kbps=60000 size=1350')			
	exec('seq_delay '..duration..'')
    exec('ue_deregister by=ue ue_deregister_type=switch_off')
	exec('seq_end')

	-----------TC1 : 1 NSA UE SINGLE CELL TPUT DL1600Mbps UL220Mbps------------------------

	exec('seq_set id=2 name=NSA_CELL_DL ue_group=4')
    exec('ue_attach ue_eutra_nr_capabilities=EUTRA_CAP_2CC ue_nr_capabilities=UE_CAP_2CC capability_file=./capability.cfg')
    exec('seq_delay 0.5')
    exec('enb_ue_dc_start target_gnb=2 target_cells=2 bearer=2 type=split_scg')
    exec('seq_delay 0.5')
    exec('trf_data_start id=2 dir=dl trf_id=1 kbps=160000 size=1350')
	exec('trf_data_start id=2 dir=dl trf_id=2 kbps=160000 size=1350')
	exec('trf_data_start id=2 dir=dl trf_id=3 kbps=160000 size=1350')
	exec('trf_data_start id=2 dir=dl trf_id=4 kbps=160000 size=1350')
	exec('trf_data_start id=2 dir=dl trf_id=5 kbps=160000 size=1350')
	exec('trf_data_start id=2 dir=dl trf_id=6 kbps=160000 size=1350')
	exec('trf_data_start id=2 dir=dl trf_id=7 kbps=160000 size=1350')
	exec('trf_data_start id=2 dir=dl trf_id=8 kbps=160000 size=1350')
	exec('trf_data_start id=2 dir=dl trf_id=9 kbps=160000 size=1350')
	exec('trf_data_start id=2 dir=dl trf_id=10 kbps=160000 size=1350')
	exec('trf_data_start id=2 dir=ul trf_id=1  kbps=160000 size=1350')
	exec('trf_data_start id=2 dir=ul trf_id=2  kbps=60000 size=1350')
    exec('sleep '..duration..'')
    exec('trf_data_stop id=2')
    exec('seq_delay 0.5')
    exec('enb_release_ue_dc bearer=2 by=enb cause=off')
    exec('seq_delay 0.5')
    exec('ue_detach')
    exec('seq_end')

	-----------TC2 : SA 40UEs MUMIMO CELL TPUT DL3200Mbps UL220Mbps------------------------

	exec('seq_set id=3 name=SA-MUMIMO_PEAK-UL-DL ue_group=1')	
	exec('ue_register ue_nr_capabilities=n25A_n66A_n71A_n773A capability_file=./capability.cfg registration_type=InitialRegistration')
	exec('ue_pdu_session_setup pdu=1  nwslice=1')
	exec('trf_data_start pdu=1 qfi=1 trf_id=1 dir=dl kbps=80000 size=1350')
	exec('trf_data_start pdu=1 qfi=1 trf_id=1 dir=ul kbps=5500 size=1350')
	exec('seq_delay '..duration..'')
    exec('ue_deregister by=ue ue_deregister_type=switch_off')
	exec('seq_end')

	------------TC3 : 500 SA UE CELL1 TPUT DL800Mbps UL110Mbps----------------------------------

	exec('seq_set id=4 name=SA-CELL_PEAK-UL-DL ue_group=1')	
	exec('ue_register ue_nr_capabilities=n25A_n66A_n71A_n773A capability_file=./capability.cfg registration_type=InitialRegistration')
	exec('ue_pdu_session_setup pdu=1 nwslice=1')
	exec('trf_data_start pdu=1 qfi=1 trf_id=1 dir=dl kbps=1600 size=1350')
	exec('trf_data_start pdu=1 qfi=1 trf_id=1 dir=ul kbps=220 size=1350')		
	exec('seq_delay '..duration..'')
    exec('ue_deregister by=ue ue_deregister_type=switch_off')
	exec('seq_end')

	-----------TC3 : 500 NSA UE CELL1 TPUT DL800Mbps UL110Mbps------------------------

	exec('seq_set id=5 name=NSA_CELL_DL ue_group=3')
    exec('ue_attach ue_eutra_nr_capabilities=EUTRA_CAP_2CC ue_nr_capabilities=UE_CAP_2CC capability_file=./capability.cfg')
    exec('seq_delay 0.5')
    exec('enb_ue_dc_start target_gnb=2 target_cells=1 bearer=2 type=split_scg')
    exec('seq_delay 0.5')
    exec('trf_data_start id=2 dir=dl trf_id=1 kbps=1600 size=1350')
	exec('trf_data_start id=2 dir=ul trf_id=1 kbps=220 size=1350')
    exec('sleep '..duration..'')
    exec('trf_data_stop id=2')
    exec('seq_delay 0.5')
    exec('enb_release_ue_dc bearer=2 by=enb cause=off')
    exec('seq_delay 0.5')
    exec('ue_detach')
    exec('seq_end')

	------------TC3 : 500 SA UE CELL2 TPUT DL800Mbps UL110Mbps----------------------------------

	exec('seq_set id=6 name=SA-CELL_PEAK-UL-DL ue_group=2')	
	exec('ue_register ue_nr_capabilities=n25A_n66A_n71A_n773A capability_file=./capability.cfg registration_type=InitialRegistration')
	exec('ue_pdu_session_setup pdu=1  nwslice=1')
	exec('trf_data_start pdu=1 qfi=1 trf_id=1 dir=dl kbps=1600 size=1350')
	exec('trf_data_start pdu=1 qfi=1 trf_id=1 dir=ul kbps=220 size=1350')		
	exec('seq_delay '..duration..'')
    exec('ue_deregister by=ue ue_deregister_type=switch_off')
	exec('seq_end')

	-----------TC3 : 500 NSA UE CELL2 TPUT DL800Mbps UL110Mbps------------------------

	exec('seq_set id=7 name=NSA_CELL_DL ue_group=4')
    exec('ue_attach ue_eutra_nr_capabilities=EUTRA_CAP_2CC ue_nr_capabilities=UE_CAP_2CC capability_file=./capability.cfg')
    exec('seq_delay 0.5')
    exec('enb_ue_dc_start target_gnb=2 target_cells=2 bearer=2 type=split_scg')
    exec('seq_delay 0.5')
    exec('trf_data_start id=2 dir=dl trf_id=1 kbps=1600 size=1350')
	exec('trf_data_start id=2 dir=ul trf_id=1 kbps=220 size=1350')
    exec('sleep '..duration..'')
    exec('trf_data_stop id=2')
    exec('seq_delay 0.5')
    exec('enb_release_ue_dc bearer=2 by=enb cause=off')
    exec('seq_delay 0.5')
    exec('ue_detach')
    exec('seq_end')

	------------TC4 : SA UE SINGLE CELL1 TPUT DL800Mbps ----------------------------------

	exec('seq_set id=8 name=SA-CELL_PEAK-UL-DL ue_group=1')	
	exec('ue_register ue_nr_capabilities=n25A_n66A_n71A_n773A capability_file=./capability.cfg registration_type=InitialRegistration')
	exec('ue_pdu_session_setup pdu=1  nwslice=1')
	exec('trf_data_start pdu=1 qfi=1 trf_id=1 dir=dl kbps=160000 size=1350')
	exec('trf_data_start pdu=1 qfi=1 trf_id=2 dir=dl kbps=160000 size=1350')
	exec('trf_data_start pdu=1 qfi=1 trf_id=3 dir=dl kbps=160000 size=1350')
	exec('trf_data_start pdu=1 qfi=1 trf_id=4 dir=dl kbps=160000 size=1350')
	exec('trf_data_start pdu=1 qfi=1 trf_id=5 dir=dl kbps=160000 size=1350')		
	exec('seq_delay '..duration..'')
    exec('ue_deregister by=ue ue_deregister_type=switch_off')
	exec('seq_end')

	------------TC4 : SA UE SINGLE CELL2 TPUT DL800Mbps ----------------------------------

	exec('seq_set id=9 name=SA-CELL_PEAK-UL-DL ue_group=2')	
	exec('ue_register ue_nr_capabilities=n25A_n66A_n71A_n773A capability_file=./capability.cfg registration_type=InitialRegistration')
	exec('ue_pdu_session_setup pdu=1  nwslice=1')
	exec('trf_data_start pdu=1 qfi=1 trf_id=1 dir=dl kbps=160000 size=1350')
	exec('trf_data_start pdu=1 qfi=1 trf_id=2 dir=dl kbps=160000 size=1350')
	exec('trf_data_start pdu=1 qfi=1 trf_id=3 dir=dl kbps=160000 size=1350')
	exec('trf_data_start pdu=1 qfi=1 trf_id=4 dir=dl kbps=160000 size=1350')
	exec('trf_data_start pdu=1 qfi=1 trf_id=5 dir=dl kbps=160000 size=1350')		
	exec('seq_delay '..duration..'')
    exec('ue_deregister by=ue ue_deregister_type=switch_off')
	exec('seq_end')

	-----------TC4 : NSA UE SINGLE CELL3 TPUT DL800Mbps ------------------------

	exec('seq_set id=10 name=NSA_CELL_DL ue_group=5')
    exec('ue_attach ue_eutra_nr_capabilities=EUTRA_CAP_2CC ue_nr_capabilities=UE_CAP_2CC capability_file=./capability.cfg')
    exec('seq_delay 0.5')
    exec('enb_ue_dc_start target_gnb=2 target_cells=3 bearer=2 type=split_scg')
    exec('seq_delay 0.5')
    exec('trf_data_start id=2 dir=dl trf_id=1 kbps=160000 size=1350')
	exec('trf_data_start id=2 dir=dl trf_id=2 kbps=160000 size=1350')
	exec('trf_data_start id=2 dir=dl trf_id=3 kbps=160000 size=1350')
	exec('trf_data_start id=2 dir=dl trf_id=4 kbps=160000 size=1350')
	exec('trf_data_start id=2 dir=dl trf_id=5 kbps=160000 size=1350')
    exec('sleep '..duration..'')
    exec('trf_data_stop id=2')
    exec('seq_delay 0.5')
    exec('enb_release_ue_dc bearer=2 by=enb cause=off')
    exec('seq_delay 0.5')
    exec('ue_detach')
    exec('seq_end')

	-----------TC4 : NSA UE SINGLE CELL4 TPUT DL800Mbps ------------------------

	exec('seq_set id=11 name=NSA_CELL_DL ue_group=6')
    exec('ue_attach ue_eutra_nr_capabilities=EUTRA_CAP_2CC ue_nr_capabilities=UE_CAP_2CC capability_file=./capability.cfg')
    exec('seq_delay 0.5')
    exec('enb_ue_dc_start target_gnb=2 target_cells=4 bearer=2 type=split_scg')
    exec('seq_delay 0.5')
    exec('trf_data_start id=2 dir=dl trf_id=1 kbps=160000 size=1350')
	exec('trf_data_start id=2 dir=dl trf_id=2 kbps=160000 size=1350')
	exec('trf_data_start id=2 dir=dl trf_id=3 kbps=160000 size=1350')
	exec('trf_data_start id=2 dir=dl trf_id=4 kbps=160000 size=1350')
	exec('trf_data_start id=2 dir=dl trf_id=5 kbps=160000 size=1350')
    exec('sleep '..duration..'')
    exec('trf_data_stop id=2')
    exec('seq_delay 0.5')
    exec('enb_release_ue_dc bearer=2 by=enb cause=off')
    exec('seq_delay 0.5')
    exec('ue_detach')
    exec('seq_end')

end

function TC1_SA_NSA_DL_UL()
	exec('uec_l2_testmode_params fixed_csi_report=true')
	enable_vip_logs()
	sleep(0.5)
    exec('seq_start id=1-2 rate=1 detailed_print=on max_start=1')
	sleep(3)
	vm0_print("TC1_SA_NSA_DL_UL script completed")
end

function TC2_SA_MUMIMO_DL_UL()
	exec('uec_l2_testmode_params fixed_csi_report=true')
	enable_vip_logs()
	sleep(0.5)
    exec('seq_start id=3 rate=1 detailed_print=on duration=50 max_start=40')
	sleep(80)
	vm0_print("TC2_SA_MUMIMO_DL_UL script completed")
end

function TC3_SANSA_500UEs_DL_UL()
	exec('uec_l2_testmode_params fixed_csi_report=true')
	enable_vip_logs()
	sleep(0.5)
    exec('seq_start id=4-7 rate=1 detailed_print=on duration=550 max_start=500')
	sleep(600)
	vm0_print("TC3_SANSA_500UEs_DL_UL script completed")
end

function TC4_SANSA_SUE_DL_50MHz()
	exec('uec_l2_testmode_params fixed_csi_report=true')
	enable_vip_logs()
	sleep(0.5)
    exec('seq_start id=8-9 rate=1 detailed_print=on duration=5 max_start=1')
	sleep(10)
    exec('seq_start id=10-11 rate=1 detailed_print=on duration=5 max_start=1')
	sleep(10)
	vm0_print("TC4_SANSA_SUE_DL_50MHz script completed")
end

--[[
commands to egate
  cfg file=sim_config.lua entry=run_configuration(SIM_FDD_12CELL_25MHz_CNI108638,5400) --To configure sim or egate
  script file=test_sequence.lua entry=x2_link()
  script file=test_sequence.lua entry=TC1_SA_NSA_DL_UL
  script file=test_sequence.lua entry=TC2_SA_MUMIMO_DL_UL
  script file=test_sequence.lua entry=TC3_SANSA_500UEs_DL_UL
  script file=test_sequence.lua entry=TC4_SANSA_SUE_DL_50MHz
--]]
