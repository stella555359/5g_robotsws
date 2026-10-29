-- Functions for Common Scripts for AP9000
-- Note currently, only support one configuration, 

function configure()
    require "tmo_cfg_singlecell.lua"
    run_configure()
end

function x2_link_up()
    exec('enb_x2_link_up enb=1 target=2')
end

function stop_max_dl_ul()
    require "multi_ue_sa_script_new"
   
    stop_multiue_call_parallel(1,24,6,1,0.3)
end
function stop_max_dl()
    require "multi_ue_sa_script_new"
   
    stop_multiue_call_parallel(1,24,6,1,0.3)
end

function stop_test_max_ul()
    require "multi_ue_sa_script_new"
   
    stop_multiue_call_parallel(1,24,6,1,0.3)
end

function stop_max_ue()
    require "multi_ue_sa_script_new"
    stop_multiue_call_parallel(1,4450,6,1,0.3)
end

function show_ue_nr_stats_24_ue_dl()
    exec("ue_stats_nr id=1-24 type=pdsch scell=0")
end
function show_ue_nr_stats_24_ue_ul()
    exec('ue_stats_nr id=1-24 type=pusch scell=0')
end
    

function start_max_dl_ul()
    require "multi_ue_sa_script_new"
    --- Max throughput case (4 UEs * 6(cells/AP) = 24) UL 46200 kbps/ 150000 kbps
    --- start_ue: integer)
    --- end_ue: integer
    --- num_cellsI: integer
    --- pdu_id: integer 
    --- qfi_id: integer
    --- trf_id: integer
    --- rate: bps, kbps, mbps
    --- ul_datarate: integer 
    --- dl_datarate: integer
    --- direction: dl,ul,both
    --- delay_bw_ue_attach: integer,fraction
    --- trf_type: internal
    --- packetsize: between 42 to 1350
    --- Retry_IDLE_OFF_UE (yes,no)
    --- srbInactivityTimerSA:  (integer)  It should be same as commission file. 
    set_amf_to_register_multiue(1,5,"310:260",24)
    register_multiue_with_traffic_parallel(1,24,6,1,1,1,"mbps",46,150,"both",2,"internal",1350,"yes",60)
end

function start_max_dl()
    require "multi_ue_sa_script_new"
	set_amf_to_register_multiue(1,5,"310:260",24)
    register_multiue_with_traffic_parallel(1,24,6,1,1,1,"mbps",1,150,"dl",1.6,"internal",1350,"yes",60)
end
function start_max_ul()
    require "multi_ue_sa_script_new"
	set_amf_to_register_multiue(1,5,"310:260",24)
    register_multiue_with_traffic_parallel(1,24,6,1,1,1,"kbps",46000,2,"both",1.6,"internal",1350,"yes",60)
end

function start_max_ue()
    require "multi_ue_sa_script_new"
exec('uec_l2_testmode_params fixed_csi_report=true')
    sleep(1)
    set_amf_to_register_multiue(1,5,"310:260",9000)
    sleep (3)
    register_multiue_with_pdu_check_traffic_parallel_retry(1,9000,6,1,1,1,"bps",74,74,"both",0.3,"internal",42,"yes",60)
end

function start_max_ues()
    require "multi_ue_sa_script_new"
    exec('uec_l2_testmode_params fixed_csi_report=true')
    sleep (1)
    set_amf_to_register_multiue(1,6,"310:260",3000)
    sleep (1)
    register_multiue_with_pdu_check_traffic_parallel_retry(1,3000,6,1,1,1,"bps",74,74,"both",0.4,"internal",42,"yes",60)
end

function  trf_rate_down()
   require "multi_ue_sa_script_new"
    run_traffic_only_with_range(1,24,1,1,1,2,2,"both",64)
end
function  trf_rate_up()
   require "multi_ue_sa_script_new"
    run_traffic_only_with_range(1,24,1,1,1,46000,151000,"both",1350)
end
function sib_check()
    require "multi_ue_sa_script_new"
    check_SIBs(1,6)
end

----Test_Cases_commands----

function Constant_Traffic_HO_Profile()
require "multi_ue_sa_script_new"
print("I am here again")
set_multi_amf_to_register_multiue3(1,6,"310:260",168,268)
sleep(1)
exec('seq_start rate=4 id=8-12 detailed_print=on duration=100  max_active_ues=10')
sleep(20)
set_multi_amf_to_register_multiue3(1,6,"310:260",1,92)
exec('seq_start rate=1 id=1-3 detailed_print=on duration=10100  max_active_ues=8')
sleep(20)
print("I am here")
set_multi_amf_to_register_multiue3(1,6,"310:260",300,389)
exec('seq_start rate=1 id=15-18 detailed_print=on duration=100  max_active_ues=6')
sleep(20)
set_multi_amf_to_register_multiue3(1,6,"310:260",390,500)
exec('seq_start rate=2 id=19-23 detailed_print=on duration=10100  max_active_ues=8')
sleep(5)
--set_multi_amf_to_register_multiue3(1,6,"310:260",93,113)
--exec('seq_start rate=1 id=4 detailed_print=on duration=10000  max_active_ues=8')
--exec('ue_summary')
sleep(1)
--[[
set_multi_amf_to_register_multiue3(1,6,"310:260",383,483)
exec('seq_start rate=1 id=21-23 detailed_print=on duration=100  max_active_ues=8')
]]--
print("Register Traffic script completed")
exec("set_log flush")
end

