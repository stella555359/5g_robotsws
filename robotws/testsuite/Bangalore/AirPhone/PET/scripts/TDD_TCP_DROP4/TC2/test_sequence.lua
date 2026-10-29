require "sim_config"

function seq_configuration(duration)
--TC4-TDD_NSA_4DL4UL_12Cells_nonBF_1208FF_375UE_percell_total_DL_peak_tp_3244.3Mbps_ABIP--60UEs/cell will have -high thrp

cell_id=1
ue_group_id=13
for seq_id = 1, 12 do
    if ue_group_id > 24 then
        ue_group_id=13
    end
    if cell_id >12 then
        cell_id=1
    end
    exec('seq_set id='..seq_id..' name=NSA_CELL_DL  ue_group='..ue_group_id..'')
    exec('ue_attach mode=ccsrt ue_nr_capabilities=NSA_FR1 ue_eutra_nr_capabilities=EUTRA_NSA capability_file=./capability.cfg ')
	exec('seq_delay 0.1')
    exec('bearer_add by=ue id=3 filter=1 precedence=1 proto=17')  --2nd DRB
    exec('seq_delay 1.0')
    exec('ue_dc_enb_start target_gnb=2 target_cells='..cell_id..' bearer=2,3 type=split_scg')  --sgnb add
    exec('seq_delay 0.1')
	exec('trf_data_start id=2 dir=ul trf_id=1 kbps=2015 size=1298 protocol=tcp')
	exec('sleep '..duration..'')
	exec('trf_data_stop id=2 dir=ul trf_id=1')
	exec('seq_delay 0.1')
    exec('enb_ue_dc_release bearer=2,3 by=enb cause=off')     --sgnb del
	exec('seq_delay 0.1')
	exec('ue_detach ')
	exec('seq_end')
    cell_id=cell_id+1
    ue_group_id=ue_group_id+1
end

--TC4-TDD_NSA_4DL4UL_12Cells_nonBF_1208FF_375UE_percell_total_DL_peak_tp_3244.3Mbps_ABIP--315Ue/cell will have pingdata

cell_id=1
ue_group_id=25
for seq_id = 13, 24 do
    if ue_group_id > 36 then
        ue_group_id=25
    end
    if cell_id >12 then
        cell_id=1
    end
    exec('seq_set id='..seq_id..' name=NSA_CELL_DL  ue_group='..ue_group_id..'')
    exec('ue_attach ue_nr_capabilities=NSA_FR1 ue_eutra_nr_capabilities=EUTRA_NSA capability_file=./capability.cfg ')
	exec('seq_delay 0.1')
    exec('bearer_add by=ue id=3 filter=1 precedence=1 proto=17')  --2nd DRB
    exec('seq_delay 1.0')
    exec('ue_dc_enb_start target_gnb=2 target_cells='..cell_id..' bearer=2,3 type=split_scg')  --sgnb add
    exec('seq_delay 0.1')
    exec("seq_loop_start loop=570")     
	exec('trf_data_start id=2 dir=dl trf_id=1 packets=1 size=42')
	exec('trf_data_start id=2 dir=ul trf_id=1 packets=1 size=42')
	exec('seq_delay 9.5')
    exec("seq_loop_end")
	exec('seq_delay 0.1')
    exec('enb_ue_dc_release bearer=2,3 by=enb cause=off')     --sgnb del
	exec('seq_delay 0.1')
	exec('ue_detach ')
	exec('seq_end')
    cell_id=cell_id+1
    ue_group_id=ue_group_id+1
end

end

function run_NSA_TCP_TC4_UL()
	exec('uec_l2_testmode_params fixed_csi_report=true')
    exec('bearer_ue_param id=2 ue=1-4500 scg_ul_dist_percent=90')
	sleep(1)
    exec('filter_sim_rfm disable=all')
    sleep(1)
    exec('filter_sim_rfm enable=CSI,ACR,OERR,IERR,VIP')
    sleep(1)
    exec('sim_param_set disable_events_on_telnet_session=on')
    sleep(1)
    exec('seq_start rate=1 id=1-6 detailed_print=on duration=70 max_active_ues=60')
	sleep(70)
    exec('ue_summary')
    exec('seq_start rate=1 id=7-12 detailed_print=on duration=70 max_active_ues=60')
    sleep(70)
    exec('ue_summary')
    exec('seq_start rate=1 id=13-18 detailed_print=on duration=350 max_active_ues=315')
    sleep(350)
    exec('ue_summary')
    exec('seq_start rate=1 id=19-24 detailed_print=on duration=350 max_active_ues=315')
    sleep(350)
    exec('filter_sim_rfm enable=all')
    exec('ue_summary')
    exec('sim_param_set disable_events_on_telnet_session=yes')
	print("run_NSA_TCP_TC4_UL script completed")
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
