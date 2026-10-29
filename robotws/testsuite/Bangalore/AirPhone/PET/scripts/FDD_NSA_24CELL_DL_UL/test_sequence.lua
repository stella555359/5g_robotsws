require "sim_config"


function seq_configuration(duration)

-------------------------------------------
--NSA SEQUENCE
-------------------------------------------

local ping_period=9.5
local ping_loop=math.floor(duration/ping_period)

------------TC : DL 3067 Mbps 96 NSA UEs----------------------------------

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
    exec('ue_attach ue_eutra_nr_capabilities=UE_MRDC ue_nr_capabilities=UE_NSA_N71_20MHz capability_file=./capability.cfg')
    exec('seq_delay 0.5')
    exec('bearer_add by=ue id=3 filter=1 precedence=1 proto=17')
    exec('seq_delay 0.5')
    exec('enb_ue_dc_start target_gnb=2 target_cells='..cell_id..' bearer=2,3 type=split_scg')
    exec('seq_delay 0.5')
    exec('trf_data_start id=2 dir=dl trf_id=2 kbps=31947 size=1350') --7.68 Mbps
    exec('sleep '..duration..'') --For 1.5 Hrs
    exec('trf_data_stop id=2')
    exec('seq_delay 0.5')
    exec('enb_release_ue_dc bearer=2,3 by=enb cause=off')
    exec('seq_delay 0.5')
    exec('ue_detach')
    exec('seq_end')
    cell_id=cell_id+1
    ue_group_id=ue_group_id+1
end

------------TC : UL 1247 Mbps 96 NSA UEs ----------------------------------

ue_group_id=25
cell_id=1
for seq_id = 25, 48 do
    if ue_group_id > 48 then
        ue_group_id=25
    end
    if cell_id >24 then
        cell_id=1
    end
    exec('seq_set id='..seq_id..' name=NSA_CELL_DL  ue_group='..ue_group_id..'')
    exec('ue_attach ue_eutra_nr_capabilities=UE_MRDC ue_nr_capabilities=UE_NSA_N71_20MHz capability_file=./capability.cfg')
	exec('seq_delay 0.5')
	exec('bearer_add by=ue id=3 filter=1 precedence=1 proto=17')
	exec('seq_delay 0.5')
    exec('enb_ue_dc_start target_gnb=2 target_cells='..cell_id..' bearer=2,3 type=split_scg')
	exec('seq_delay 0.5')
    exec('trf_data_start id=2 dir=ul trf_id=2 kbps=12989 size=1350') --7.68 Mbps
    exec('sleep '..duration..'') --For 1.5 Hrs
	exec('trf_data_stop id=2,3')
	exec('seq_delay 0.5')
	exec('enb_release_ue_dc bearer=2,3 by=enb cause=off')
	exec('seq_delay 0.5')
    exec('ue_detach')
    exec('seq_end')
    cell_id=cell_id+1
    ue_group_id=ue_group_id+1
end

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
    exec('ue_attach ue_eutra_nr_capabilities=UE_MRDC ue_nr_capabilities=UE_NSA_N71_20MHz capability_file=./capability.cfg')
	exec('seq_delay 0.5')
	exec('bearer_add by=ue id=3 filter=1 precedence=1 proto=17')
	exec('seq_delay 0.5')
    exec('enb_ue_dc_start target_gnb=2 target_cells='..cell_id..' bearer=2,3 type=split_scg')
	exec('seq_delay 0.5')
    exec('trf_data_start id=2 dir=dl trf_id=2 kbps=4259 size=1350') --7.68 Mbps
    exec('sleep '..duration..'') --For 1.5 Hrs
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
    exec('ue_attach ue_eutra_nr_capabilities=UE_MRDC ue_nr_capabilities=UE_NSA_N71_20MHz capability_file=./capability.cfg')
	exec('seq_delay 0.5')
	exec('bearer_add by=ue id=3 filter=1 precedence=1 proto=17')
	exec('seq_delay 0.5')
    exec('enb_ue_dc_start target_gnb=2 target_cells='..cell_id..' bearer=2,3 type=split_scg')
	exec('seq_delay 0.5')
    exec('trf_data_start id=2 dir=ul trf_id=1 kbps=1731 size=1350') --7.68 Mbps
    exec('sleep '..duration..'') --For 1.5 Hrs
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

ue_group_id=25
cell_id=1
for seq_id = 97, 120 do
    if ue_group_id > 48 then
        ue_group_id=25
    end
    if cell_id > 24 then
        cell_id=1
    end
    
    exec('seq_set id='..seq_id..' name=NSA_PING_UE  ue_group='..ue_group_id..'')
    exec('ue_attach ue_eutra_nr_capabilities=UE_MRDC ue_nr_capabilities=UE_NSA_N71_20MHz capability_file=./capability.cfg')
    exec('seq_delay 0.5')
    exec('bearer_add by=ue id=3 filter=1 precedence=1 proto=17')
    exec('seq_delay 0.5')
    exec('enb_ue_dc_start target_gnb=2 target_cells='..cell_id..' bearer=2,3 type=split_scg')
    exec('seq_delay 0.5')
    exec('seq_loop_start loop='..ping_loop)
    exec('seq_delay 9.5')
    exec('trf_data_start id=2 dir=ul trf_id=1 bps=72 size=42 packets=1') --ping data
    exec('trf_data_start id=2 dir=dl trf_id=1 bps=72 size=42 packets=1' ) --ping data
    exec('seq_loop_end')
    exec('enb_release_ue_dc bearer=2,3 by=enb cause=off')
    exec('seq_delay 0.5')
    exec('ue_detach')
    exec('seq_end')

    cell_id=cell_id+1
    ue_group_id=ue_group_id+1
end	

end

function run_PET_NSA_24CELL_20MHz_4UE_DL3067()

    exec('uec_l2_testmode_params fixed_csi_report=true')
    sleep(0.5)
    enable_vip_logs()
    sleep(0.5)
    exec('seq_start id=1-24 rate=1 detailed_print=on max_active_ues=4 max_start=4')
end

function run_PET_NSA_24CELL_20MHz_4UE_UL1247()

    exec('uec_l2_testmode_params fixed_csi_report=true')
	sleep(0.5)
    
    sleep(0.5)
    exec('bearer_ue_param id=2 ue=26-4536 scg_ul_dist_percent=90')
    sleep(0.5)
    exec('bearer_ue_param id=3 ue=26-4536 scg_ul_dist_percent=90')
    sleep(0.5)
    exec('seq_start id=25-48 rate=1 detailed_print=on max_active_ues=4 max_start=4')
end

function run_PET_NSA_24CELL_20MHz_4500UE_DL3067()

    exec('uec_l2_testmode_params fixed_csi_report=true')
    sleep(0.5)
    enable_vip_logs()
    sleep(0.5)
    exec('seq_start id=49,61 rate=1 detailed_print=on max_active_ues=30 duration=40')
    sleep(0.1)  
    exec('seq_start id=50,62 rate=1 detailed_print=on max_active_ues=30 duration=40')
    sleep(0.1)
    exec('seq_start id=51,63 rate=1 detailed_print=on max_active_ues=30 duration=40')
    sleep(0.1)
    exec('seq_start id=52,64 rate=1 detailed_print=on max_active_ues=30 duration=40')
    sleep(0.1)
    exec('seq_start id=53,65 rate=1 detailed_print=on max_active_ues=30 duration=40')
    sleep(0.1)
    exec('seq_start id=54,66 rate=1 detailed_print=on max_active_ues=30 duration=40')
    sleep(0.1)
    exec('seq_start id=55,67 rate=1 detailed_print=on max_active_ues=30 duration=40')
    sleep(0.1)
    exec('seq_start id=56,68 rate=1 detailed_print=on max_active_ues=30 duration=40')
    sleep(0.1)
    exec('seq_start id=57,69 rate=1 detailed_print=on max_active_ues=30 duration=40')
    sleep(0.1)
    exec('seq_start id=58,70 rate=1 detailed_print=on max_active_ues=30 duration=40')
    sleep(0.1)
    exec('seq_start id=59,71 rate=1 detailed_print=on max_active_ues=30 duration=40')
    sleep(0.1)
    exec('seq_start id=60,72 rate=1 detailed_print=on max_active_ues=30 duration=40')
    sleep(0.1)
    exec('seq_start id=97,109 rate=1 detailed_print=on max_active_ues=158 duration=179')
    sleep(0.1)
    exec('seq_start id=98,110 rate=1 detailed_print=on max_active_ues=158 duration=179')
    sleep(0.1)
    exec('seq_start id=99,111 rate=1 detailed_print=on max_active_ues=158 duration=179')
    sleep(0.1)
    exec('seq_start id=100,112 rate=1 detailed_print=on max_active_ues=158 duration=179')
    sleep(0.1)
    exec('seq_start id=101,113 rate=1 detailed_print=on max_active_ues=158 duration=179')
    sleep(0.1)
    exec('seq_start id=102,114 rate=1 detailed_print=on max_active_ues=158 duration=179')
    sleep(0.1)
    exec('seq_start id=103,115 rate=1 detailed_print=on max_active_ues=157 duration=179')
    sleep(0.1)
    exec('seq_start id=104,116 rate=1 detailed_print=on max_active_ues=157 duration=179')
    sleep(0.1)
    exec('seq_start id=105,117 rate=1 detailed_print=on max_active_ues=157 duration=179')
    sleep(0.1)
    exec('seq_start id=106,118 rate=1 detailed_print=on max_active_ues=157 duration=179')
    sleep(0.1)
    exec('seq_start id=107,119 rate=1 detailed_print=on max_active_ues=157 duration=179')
    sleep(0.1)
    exec('seq_start id=108,120 rate=1 detailed_print=on max_active_ues=157 duration=179')
    sleep(200)
    vm0_print("run_PET_NSA_24CELL_20MHz_4500UE_DL3067 script completed")

end

function run_PET_NSA_24CELL_20MHz_4500UE_UL1247()

    exec('uec_l2_testmode_params fixed_csi_report=true')
    sleep(1)
    exec('bearer_ue_param id=2 ue=25-4536 scg_ul_dist_percent=90')
    sleep(0.5)
    exec('bearer_ue_param id=3 ue=25-4536 scg_ul_dist_percent=90')
    sleep(0.5)
    enable_vip_logs()
    sleep(0.5)
    exec('seq_start id=73-96 rate=1 detailed_print=on max_active_ues=30 max_start=40 duration=40')
    sleep(0.5)
    exec('seq_start id=97-102,109-114 rate=1 detailed_print=on max_active_ues=158 max_start=165 duration=165')
    sleep(0.5)
    exec('seq_start id=103-108,115-120 rate=1 detailed_print=on max_active_ues=157 max_start=162 duration=162')
    sleep(250)
    vm0_print("run_PET_NSA_24CELL_20MHz_4500UE_UL1247 script completed")

end 

function run_TC()
    run_PET_NSA_24CELL_20MHz_4500UE_DL3067()
    sleep(3700)
    run_PET_NSA_24CELL_20MHz_4500UE_UL1247()
end
--[[ 
commands to egate
  cfg file=sim_config.lua entry=run_configuration(sim_data,5400)
  script file=sim_config.lua entry=check_mib_sib(sim_data)
  script file=sim_config.lua entry=x2_connections(sim_data)
  script file=test_sequence.lua entry=run_PET_NSA_24CELL_20MHz_4UE_DL3067
  script file=test_sequence.lua entry=run_PET_NSA_24CELL_20MHz_4UE_UL1247
  script file=test_sequence.lua entry=run_PET_NSA_24CELL_20MHz_4500UE_DL3067
  script file=test_sequence.lua entry=run_PET_NSA_24CELL_20MHz_4500UE_UL1247
 
--]]
