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

-------------------------------------------
--NSA SEQUENCE
-------------------------------------------

local ping_period=9.5
local ping_loop=math.floor(duration/ping_period)

------------TC : DL 3067 Mbps 4500 NSA UEs ---------------------------------

ue_group_id=25
cell_id=1
for seq_id = 49, 72 do
    if ue_group_id > 48 then
        ue_group_id=25
    end
    if cell_id >24 then
        cell_id=1
    end
    exec('seq_set id='..seq_id..' name=NSA_CELL_DL  ue_group='..ue_group_id..'')
    exec('ue_attach mode=ccsrt ue_eutra_nr_capabilities=UE_MRDC ue_nr_capabilities=NSA_TCP_N71_20MHz capability_file=./capability.cfg')
	exec('seq_delay 0.5')
	exec('bearer_add by=ue id=3 filter=1 precedence=1 proto=17')
	exec('seq_delay 0.5')
    exec('enb_ue_dc_start target_gnb=2 target_cells='..cell_id..' bearer=2,3 type=split_scg')
	exec('seq_delay 0.5')
    exec('trf_data_start id=2 dir=dl trf_id=1 kbps=4259 size=1298 protocol=tcp')
    exec('sleep '..duration..'')
	exec('trf_data_stop id=2')
	exec('seq_delay 0.5')
	exec('enb_release_ue_dc bearer=2,3 by=enb cause=off')
	exec('seq_delay 0.5')
    exec('ue_detach')
    exec('seq_end')
    cell_id=cell_id+1
    ue_group_id=ue_group_id+1
end

------------TC : UL 1247 Mbps 4500 NSA UEs ----------------------------------

ue_group_id=25
cell_id=1
for seq_id = 73, 96 do
    if ue_group_id > 48 then
        ue_group_id=25
    end 
    if cell_id > 24 then
        cell_id=1
    end
	exec('seq_set id='..seq_id..' name=NSA_CELL_UL  ue_group='..ue_group_id..'')
    exec('ue_attach mode=ccsrt ue_eutra_nr_capabilities=UE_MRDC ue_nr_capabilities=NSA_TCP_N71_20MHz capability_file=./capability.cfg')
	exec('seq_delay 0.5')
	exec('bearer_add by=ue id=3 filter=1 precedence=1 proto=17')
	exec('seq_delay 0.5')
    exec('enb_ue_dc_start target_gnb=2 target_cells='..cell_id..' bearer=2,3 type=split_scg')
	exec('seq_delay 0.5')
    exec('trf_data_start id=2 dir=ul trf_id=1 kbps=1731 size=1298 protocol=tcp') --TCP TRF
    exec('sleep '..duration..'')
	exec('trf_data_stop id=2')
	exec('seq_delay 0.5')
	exec('enb_release_ue_dc bearer=2,3 by=enb cause=off')
	exec('seq_delay 0.5')
    exec('ue_detach')
    exec('seq_end')
    cell_id=cell_id+1
    ue_group_id=ue_group_id+1
end

------------TC : PING  NSA UEs ----------------------------------

ue_group_id=49
cell_id=1
for seq_id = 97, 120 do
    if ue_group_id > 72 then
        ue_group_id=49
    end
    if cell_id > 24 then
        cell_id=1
    end
    exec('seq_set id='..seq_id..' name=NSA_PING_UE  ue_group='..ue_group_id..'')
    exec('ue_attach mode=ccsrt ue_eutra_nr_capabilities=UE_MRDC ue_nr_capabilities=NSA_TCP_N71_20MHz capability_file=./capability.cfg')
    exec('seq_delay 0.5')
    exec('bearer_add by=ue id=3 filter=1 precedence=1 proto=17')
    exec('seq_delay 0.5')
    exec('enb_ue_dc_start target_gnb=2 target_cells='..cell_id..' bearer=2,3 type=split_scg')
    exec('seq_delay 0.5')
    exec('seq_loop_start loop='..ping_loop)
    exec('trf_data_start id=2,3  trf_id=1 packets=1 size=42 dir=ul')
    exec('trf_data_start id=2,3  trf_id=1 packets=1 size=42 dir=dl')
    exec('seq_delay 8.5')
    exec('seq_loop_end')
    exec('enb_release_ue_dc bearer=2,3 by=enb cause=off')
    exec('seq_delay 0.5')
    exec('ue_detach')
    exec('seq_end')
    cell_id=cell_id+1
    ue_group_id=ue_group_id+1
end

end

--------------------------------------------------Functions----------------------------------------

function run_PET_NSA_24CELL_20MHz_4500UE_DL3067()

    require "sim_config"
    exec('uec_l2_testmode_params fixed_csi_report=true')
    sleep(1)
    exec('sim_debug_log level=3 app_type=ueproxy')
    sleep(1)
    exec('sim_param_set disable_events_on_telnet_session=on')
    sleep(1)
    ue_amf_distribustion("sim_data")
    sleep(2)
    exec('seq_start id=49-72 rate=1 detailed_print=on duration=175 max_active_ues=30')
    sleep(5)
    exec('seq_start id=97,99,101,103,105,107,109,111,113,115,117,119 rate=1 detailed_print=on duration=175 max_active_ues=158')
    sleep(5)
    exec('seq_start id=98,100,102,104,106,108,110,112,114,116,118,120 rate=1 detailed_print=on duration=175 max_active_ues=157')
    sleep(5)
    exec('sim_param_set disable_events_on_telnet_session=on')
    sleep(140)
--    exec('sim_param_set disable_events_on_telnet_session=off')
--    sleep(0.5)
    exec('sim_rfm_filter enable=all')
    sleep(5)
    print("run_PET_NSA_24CELL_20MHz_4500UE_DL3067 script completed")
    exec("set_log flush")
    sleep(50)
    exec('ue_summary')
    sleep(5)
    enable_vip_logs()
    sleep(60)
    seq_stats_disp(49,72)
    sleep(30)
    seq_stats_disp(97,120)

end

function run_PET_NSA_24CELL_20MHz_4500UE_UL1247()

    require "sim_config"
    exec('uec_l2_testmode_params fixed_csi_report=true')
    sleep(1)
    exec('sim_debug_log level=3 app_type=ueproxy')
    sleep(1)
    exec('sim_param_set disable_events_on_telnet_session=on')
    sleep(1)
    ue_amf_distribustion("sim_data")
    sleep(2)
    exec('bearer_ue_param id=2 ue=1-4500 scg_ul_dist_percent=90')
    sleep(0.5)
    exec('bearer_ue_param id=3 ue=1-4500 scg_ul_dist_percent=90')
    sleep(0.5)
    enable_vip_logs()
    sleep(0.5)
    exec('seq_start id=73-96 rate=1 detailed_print=on duration=50 max_active_ues=30')
    sleep(5)
    exec('seq_start id=97,99,101,103,105,107,109,111,113,115,117,119 rate=1 detailed_print=on duration=165 max_active_ues=158')
    sleep(5)
    exec('seq_start id=98,100,102,104,106,108,110,112,114,116,118,120 rate=1 detailed_print=on duration=165 max_active_ues=157')
    sleep(5)
    exec('sim_param_set disable_events_on_telnet_session=on')
    sleep(165)
--    exec('sim_param_set disable_events_on_telnet_session=off')
--	sleep(0.5)
	exec('sim_rfm_filter enable=all')
	sleep(5)
    print("run_PET_NSA_24CELL_20MHz_4500UE_UL1247 script completed")
    exec("set_log flush")
	sleep(1)
	exec('ue_summary')
    sleep(5)
    enable_vip_logs()
    sleep(60)
	seq_stats_disp(73,120)
	sleep(50)
end

--[[ 
commands to egate
  cfg_sim file=sim_config.lua entry=run_configuration(sim_data,5400)
  script file=sim_config.lua entry=check_mib_sib(sim_data)
  script file=test_sequence.lua entry=x2_link
  uec_l2_testmode_params fixed_csi_report=true

  script file=test_sequence.lua entry=run_PET_NSA_24CELL_20MHz_4500UE_UL1247
  ue_disp state=ACTIVE format=long
  script file=sim_config.lua entry=seq_stats_disp(73,120)
or
  script file=test_sequence.lua entry=run_PET_NSA_24CELL_20MHz_4500UE_DL3067
  ue_disp state=ACTIVE format=long
  script file=sim_config.lua entry=seq_stats_disp(49,72)
  script file=sim_config.lua entry=seq_stats_disp(97,120)
--]]
