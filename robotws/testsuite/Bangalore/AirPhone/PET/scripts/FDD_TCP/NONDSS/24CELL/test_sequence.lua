require "sim_config"

function seq_configuration(duration)

-------------------------------------------
--NSA SEQUENCE
-------------------------------------------

------------TC : 24UE 24 CELL DL 5640 Mbps---------------------------------

ue_group_id=25
cell_id=1
for seq_id = 1, 24 do
    if ue_group_id > 48 then
        ue_group_id=25
    end
    if cell_id >24 then
        cell_id=1
    end
    exec('seq_set id='..seq_id..' name=NSA_CELL_DL  ue_group='..ue_group_id..'')
    exec('ue_attach mode=ccsrt ue_eutra_nr_capabilities=TCP_MRDC ue_nr_capabilities=NSA_TCP_N71_20MHz capability_file=./capability.cfg')
	exec('seq_delay 0.5')
    exec('enb_ue_dc_start target_gnb=2 target_cells='..cell_id..' bearer=2 type=split_scg')
	exec('seq_delay 0.5')
    exec('trf_data_start id=2 dir=dl trf_id=1 kbps=117500 size=1298 protocol=tcp')
    exec('trf_data_start id=2 dir=dl trf_id=2 kbps=117500 size=1298 protocol=tcp')
    exec('sleep '..duration..'') --For 1.5 Hrs
	exec('trf_data_stop id=2')
	exec('seq_delay 0.5')
	exec('enb_release_ue_dc bearer=2 by=enb cause=off')
	exec('seq_delay 0.5')
    exec('ue_detach')
    exec('seq_end')
    cell_id=cell_id+1
    ue_group_id=ue_group_id+1
end

------------TC : TC : 24UE 24 CELL UL 5640 Mbps----------------------------------

ue_group_id=25
cell_id=1
for seq_id = 25,48 do
    if ue_group_id > 48 then
        ue_group_id=25
    end
    if cell_id >24 then
        cell_id=1
    end
    exec('seq_set id='..seq_id..' name=NSA_CELL_DL  ue_group='..ue_group_id..'')
    exec('ue_attach mode=ccsrt ue_eutra_nr_capabilities=TCP_MRDC ue_nr_capabilities=NSA_TCP_N71_20MHz capability_file=./capability.cfg')
	exec('seq_delay 0.5')
    exec('enb_ue_dc_start target_gnb=2 target_cells='..cell_id..' bearer=2 type=split_scg')
	exec('seq_delay 0.5')
    exec('trf_data_start id=2 dir=ul trf_id=1 kbps=121000 size=1298 protocol=tcp')
    exec('sleep '..duration..'') --For 1.5 Hrs
	exec('trf_data_stop id=2')
	exec('seq_delay 0.5')
	exec('enb_release_ue_dc bearer=2 by=enb cause=off')
	exec('seq_delay 0.5')
    exec('ue_detach')
    exec('seq_end')
    cell_id=cell_id+1
    ue_group_id=ue_group_id+1
end

end

function run_PET_NSA_24CELL_24UE_DL5640()

    exec('uec_l2_testmode_params fixed_csi_report=true')
    sleep(0.5)
    enable_vip_logs()
    sleep(0.5)
--    exec('seq_start id=1-24 rate=1 detailed_print=on duration=1 max_active_ues=1 max_start=1')
    exec('seq_start id=1,13 rate=1 detailed_print=on duration=2 max_active_ues=1 max_start=1')
    sleep(0.1)
    exec('seq_start id=5,17 rate=1 detailed_print=on duration=2 max_active_ues=1 max_start=1')
    sleep(0.1)
    exec('seq_start id=9,21 rate=1 detailed_print=on duration=2 max_active_ues=1 max_start=1')
    sleep(0.1)
    exec('seq_start id=2,14 rate=1 detailed_print=on duration=2 max_active_ues=1 max_start=1')
    sleep(0.1)
    exec('seq_start id=6,18 rate=1 detailed_print=on duration=2 max_active_ues=1 max_start=1')
    sleep(0.1)
    exec('seq_start id=10,22 rate=1 detailed_print=on duration=2 max_active_ues=1 max_start=1')
    sleep(0.1)
    exec('seq_start id=3,15 rate=1 detailed_print=on duration=2 max_active_ues=1 max_start=1')
    sleep(0.1)
    exec('seq_start id=7,19 rate=1 detailed_print=on duration=2 max_active_ues=1 max_start=1')
    sleep(0.1)
    exec('seq_start id=11,23 rate=1 detailed_print=on duration=2 max_active_ues=1 max_start=1')
    sleep(0.1)
    exec('seq_start id=4,16 rate=1 detailed_print=on duration=2 max_active_ues=1 max_start=1')
    sleep(0.1)
    exec('seq_start id=8,20 rate=1 detailed_print=on duration=2 max_active_ues=1 max_start=1')
    sleep(0.1)
    exec('seq_start id=12,24 rate=1 detailed_print=on duration=2 max_active_ues=1 max_start=1')
    sleep(35)
    exec('sim_rfm_filter enable=all')
    sleep(1)
    exec("ue_disp state=ACTIVE format=long")
    vm0_print("run_PET_NSA_24CELL_24UE_DL5640 script completed")
    exec('set_log flush')
    sleep(1)
    exec("ue_summary")
end

--[[ 
commands to egate
  cfg file=sim_config.lua entry=run_configuration(sim_data,5400)
  script file=sim_config.lua entry=mib_sib_check(sim_data)
  script file=sim_config.lua entry=x2_connections(sim_data)
  script file=test_sequence.lua entry=run_PET_NSA_24CELL_24UE_DL5640
  script file=test_sequence.lua entry=run_PET_NSA_24CELL_24UE_UL2904

--]]
