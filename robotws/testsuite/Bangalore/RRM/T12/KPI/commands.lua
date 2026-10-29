-- Functions for Common Scripts for AP9000
-- Note currently, only support one configuration, 

function configure()
    require "rjio_latestmod_singlecell.lua"
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
    set_amf_to_register_multiue(1,5,"311:489",24)
    register_multiue_with_traffic_parallel(1,24,6,1,1,1,"mbps",46,150,"both",2,"internal",1350,"yes",60)
end

function start_max_dl()
    require "multi_ue_sa_script_new"
	set_amf_to_register_multiue(1,5,"311:489",24)
    register_multiue_with_traffic_parallel(1,24,6,1,1,1,"mbps",1,150,"dl",1.6,"internal",1350,"yes",60)
end
function start_max_ul()
    require "multi_ue_sa_script_new"
	set_amf_to_register_multiue(1,5,"311:489",24)
    register_multiue_with_traffic_parallel(1,24,6,1,1,1,"kbps",46000,2,"both",1.6,"internal",1350,"yes",60)
end

function start_max_ue()
    require "multi_ue_sa_script_new"
exec('uec_l2_testmode_params fixed_csi_report=true')
    sleep(1)
    set_amf_to_register_multiue(1,5,"311:489",9000)
    sleep (3)
    register_multiue_with_pdu_check_traffic_parallel_retry(1,9000,6,1,1,1,"bps",74,74,"both",0.3,"internal",42,"yes",60)
end

function start_max_ues()
    require "multi_ue_sa_script_new"
    exec('uec_l2_testmode_params fixed_csi_report=true')
    sleep (1)
    set_amf_to_register_multiue(1,6,"311:489",3000)
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

function error_imp()
    require "multi_ue_sa_script_new"
        
    
end


----Test_Cases_commands----


function Constant_Traffic_HO_Profile()
require "multi_ue_sa_script_new"
exec('uec_l2_testmode_params fixed_csi_report=true')
sleep(1)
print("I am here again")
set_amf_to_register_multiue(1,3,"311:489",24)
sleep(1)
exec('seq_start rate=1 id=7-9 detailed_print=on duration=100  max_active_ues=10')
sleep(20)

exec('seq_start rate=1 id=10-12 detailed_print=on duration=100  max_active_ues=8')
sleep(20)
print("I am here")
exec('seq_start rate=1 id=13-15 detailed_print=on duration=100  max_active_ues=10')
sleep(20)
exec('seq_start rate=1 id=16-18 detailed_print=on duration=100  max_active_ues=8')
sleep(5)
--exec('seq_start rate=1 id=4 detailed_print=on duration=100  max_active_ues=8')
--exec('ue_summary')
print("Here again FOOL")
sleep(1)
--exec('seq_start rate=1 id=21-23 detailed_print=on duration=100  max_active_ues=8')
print("Register Traffic script completed")
exec("set_log flush")
end


function test()
require "multi_ue_sa_script_new"
--exec('uec_l2_testmode_params fixed_csi_report=true')
sleep(1)
print("I am here again")
--set_amf_to_register_multiue(1,1,"311:489",100)

set_multi_amf_to_register_multiue3(1,3,"311:489",1,93)
sleep(1)
exec('seq_start rate=1 id=1 detailed_print=on duration=10000  max_active_ues=2')
sleep(20)

print("Register Traffic script completed")
exec("set_log flush")
end

function test1()
require "multi_ue_sa_script_new"
--exec('uec_l2_testmode_params fixed_csi_report=true')
sleep(1)
print("I am here again")
--set_amf_to_register_multiue(1,1,"311:489",100)

set_multi_amf_to_register_multiue3(1,3,"311:489",510,600)
sleep(1)
--exec('ul_sinr_testmode_nr profile_id=3 sinr_target_srs=-100 sinr_target_pusch=-450 sinr_target_pucch=-100 sinr_target_preamble=-100')
--exec('ue_testmode_set_nr id=187-200 testmode=ul_sinr action=activate profile_id=3')

exec('seq_start rate=3 id=28 detailed_print=on duration=60  max_active_ues=15')
sleep(20)

print("Register Traffic script completed")
exec("set_log flush")
end



function RJIO()
require "multi_ue_sa_script_new"
sleep(1)
print("I am here again")

set_multi_amf_to_register_multiue3(1,3,"311:489",187,286)
sleep(1)


---bkp----exec('ul_sinr_testmode_nr profile_id=3 sinr_target_srs=-200 sinr_target_pusch=-475 sinr_target_pucch=-425 sinr_target_preamble=-100')

exec('ul_sinr_testmode_nr profile_id=3 sinr_target_srs=-200 sinr_target_pusch=-350 sinr_target_pucch=-350 sinr_target_preamble=-100')
exec('ue_testmode_set_nr id=187-286 testmode=ul_sinr action=activate profile_id=3')

exec('seq_start rate=2 id=12-18 detailed_print=on duration=300  max_active_ues=10')
sleep(60)
--vonr
set_multi_amf_to_register_multiue3(1,3,"311:489",318,408)
sleep(1)


exec('ul_sinr_testmode_nr profile_id=3 sinr_target_srs=-200 sinr_target_pusch=-350 sinr_target_pucch=-350 sinr_target_preamble=-100')
exec('ue_testmode_set_nr id=318-408 testmode=ul_sinr action=activate profile_id=3')

exec('seq_start rate=2 id=22-24 detailed_print=on duration=300  max_active_ues=8')
sleep(60)
--[[
exec('ue_change_location id=1-92 enb=2 cell=1')
set_multi_amf_to_register_multiue3(1,3,"311:489",1,92)
sleep(1)
exec('seq_start rate=1 id=1-2 detailed_print=on duration=13000  max_active_ues=10')
sleep(60)
]]--
--Transition

set_multi_amf_to_register_multiue3(1,3,"311:489",409,509)
print("I am here")
--exec('ul_sinr_testmode_nr profile_id=3 sinr_target_srs=-200 sinr_target_pusch=-350 sinr_target_pucch=-350 sinr_target_preamble=-100')
--exec('ue_testmode_set_nr id=409-509 testmode=ul_sinr action=activate profile_id=3')
exec('seq_start rate=3 id=25-27 detailed_print=on duration=21600  max_active_ues=8')
sleep(60)


set_multi_amf_to_register_multiue3(1,3,"311:489",510,610)
sleep(1)
exec('seq_start rate=5 id=28-30 detailed_print=on duration=21600  max_active_ues=10')
sleep(60)

set_multi_amf_to_register_multiue3(1,3,"311:489",611,810)
sleep(1)
exec('seq_start rate=5 id=31-35 detailed_print=on duration=21600  max_active_ues=10')
sleep(60)

print("Here again FOOL")
sleep(300)
print("SCRIPT completed")
exec("set_log flush")
end




function RJIO1()
require "multi_ue_sa_script_new"
require "rjio_latestmod_singlecell_tm.lua"
sleep(1)
print("I am here again")
set_multi_amf_to_register_multiue3(1,3,"311:489",188,286)
sleep(1)
exec('ul_sinr_testmode_nr profile_id=3 sinr_target_srs=-200 sinr_target_pusch=-320 sinr_target_pucch=-320 sinr_target_preamble=-100')
exec('ue_testmode_set_nr id=187-286 testmode=ul_sinr action=activate profile_id=3')
exec('seq_start rate=2 id=12-18 detailed_print=on duration=300  max_active_ues=10')
sleep(60)


--vonr
set_multi_amf_to_register_multiue3(1,3,"311:489",318,408)
sleep(1)

exec('ul_sinr_testmode_nr profile_id=3 sinr_target_srs=-200 sinr_target_pusch=-320 sinr_target_pucch=-320 sinr_target_preamble=-100')
exec('ue_testmode_set_nr id=318-408 testmode=ul_sinr action=activate profile_id=3')

exec('seq_start rate=1 id=22-24 detailed_print=on duration=300  max_active_ues=6')
sleep(60)

--[[
exec('ue_change_location id=1-92 enb=2 cell=1')
set_multi_amf_to_register_multiue3(1,3,"311:489",1,92)
sleep(1)
exec('seq_start rate=1 id=1-2 detailed_print=on duration=13000  max_active_ues=10')
sleep(60)
]]--

--Transition
set_multi_amf_to_register_multiue3(1,3,"311:489",409,509)
print("I am here")
--exec('ul_sinr_testmode_nr profile_id=3 sinr_target_srs=-200 sinr_target_pusch=-350 sinr_target_pucch=-350 sinr_target_preamble=-100')
--exec('ue_testmode_set_nr id=409-509 testmode=ul_sinr action=activate profile_id=3')
exec('seq_start rate=1 id=25-27 detailed_print=on duration=10600  max_active_ues=6')
sleep(60)


set_multi_amf_to_register_multiue3(1,3,"311:489",510,610)
sleep(1)
exec('seq_start rate=1 id=28-29 detailed_print=on duration=10600  max_active_ues=8')
sleep(100)


print("Here again FOOL")
sleep(300)
print("SCRIPT completed")
exec("set_log flush")
end



function RJIO2()
require "multi_ue_sa_script_new"
sleep(1)
print("I am here again")
--set_multi_amf_to_register_multiue3(1,3,"311:489",114,154)
--sleep(1)
--addition_of_uehistory_info_sa_handover(114,154,'311:489',4)
--exec('seq_start rate=1 id=7 detailed_print=on duration=10  max_active_ues=1')
--sleep(100)

--set_multi_amf_to_register_multiue3(1,3,"311:489",155,185)
--sleep(1)
--addition_of_uehistory_info_sa_handover(155,185,'311:489',5)
--exec('seq_start rate=1 id=10 detailed_print=on duration=100  max_active_ues=6')
--sleep(100)

--set_multi_amf_to_register_multiue3(1,3,"311:489",510,610)
--sleep(1)
--exec('seq_start rate=2 id=28 detailed_print=on duration=100  max_active_ues=10')
--sleep(100)

set_multi_amf_to_register_multiue3(1,3,"311:489",611,810)
sleep(1)
exec('seq_start rate=2 id=31-33 detailed_print=on duration=100  max_active_ues=10')
sleep(30)

--vonr
--[[set_multi_amf_to_register_multiue3(1,3,"311:489",318,408)
sleep(1)

exec('ul_sinr_testmode_nr profile_id=3 sinr_target_srs=-200 sinr_target_pusch=-320 sinr_target_pucch=-320 sinr_target_preamble=-100')
exec('ue_testmode_set_nr id=318-408 testmode=ul_sinr action=activate profile_id=3')

exec('seq_start rate=1 id=22-24 detailed_print=on duration=300  max_active_ues=6')
sleep(60)

]]--

print("Here again FOOL")
sleep(100)
print("SCRIPT completed")
exec("set_log flush")
end


function RJIO3()
require "multi_ue_sa_script_new"
sleep(1)
print("I am here again")
set_multi_amf_to_register_multiue3(1,3,"311:489",186,286)
sleep(1)
exec('ul_sinr_testmode_nr profile_id=3 sinr_target_srs=-200 sinr_target_pusch=-350 sinr_target_pucch=-350 sinr_target_preamble=-100')
exec('ul_sinr_testmode_nr profile_id=3 sinr_target_srs=-200 sinr_target_pusch=-475 sinr_target_pucch=-425 sinr_target_preamble=-100')
exec('bler_testmode_nr profile_id=2 ul_bler=100,100,100,100,100,100,100,100')
exec('ue_testmode_set_nr id=187-286 testmode=ul_sinr action=activate profile_id=3')
exec('ue_testmode_set_nr id=187-286 testmode=bler action=activate profile_id=2')
exec('seq_start rate=2 id=12-18 detailed_print=on duration=300  max_active_ues=14')
sleep(60)

print("Here again FOOL")
sleep(100)
print("SCRIPT completed")
exec("set_log flush")
end

function RJIO4()
require "multi_ue_sa_script_new"
sleep(1)
print("I am here again")
--- Basic call
set_multi_amf_to_register_multiue3(1,3,"311:489",188,286)
sleep(1)
exec('ul_sinr_testmode_nr profile_id=3 sinr_target_srs=-200 sinr_target_pusch=-320 sinr_target_pucch=-320 sinr_target_preamble=-100')
exec('ue_testmode_set_nr id=187-286 testmode=ul_sinr action=activate profile_id=3')
exec('seq_start rate=2 id=12-18 detailed_print=on duration=300  max_active_ues=14')
sleep(60)
--Vonr Calls
set_multi_amf_to_register_multiue3(1,3,"311:489",318,408)
sleep(1)
exec('ul_sinr_testmode_nr profile_id=3 sinr_target_srs=-200 sinr_target_pusch=-320 sinr_target_pucch=-320 sinr_target_preamble=-100')
exec('ue_testmode_set_nr id=318-408 testmode=ul_sinr action=activate profile_id=3')
exec('seq_start rate=1 id=22-24 detailed_print=on duration=300  max_active_ues=8')
sleep(60)
---Intra gNB Intra freq HO
--[[
exec('ue_change_location id=1-92 enb=2 cell=1')
set_multi_amf_to_register_multiue3(1,3,"311:489",1,92)
sleep(1)
exec('seq_start rate=1 id=1-2 detailed_print=on duration=13000  max_active_ues=10')
sleep(60)
]]--
--Transition
set_multi_amf_to_register_multiue3(1,3,"311:489",409,509)
exec('ul_sinr_testmode_nr profile_id=3 sinr_target_srs=-200 sinr_target_pusch=-350 sinr_target_pucch=-350 sinr_target_preamble=-100')
exec('ue_testmode_set_nr id=409-509 testmode=ul_sinr action=activate profile_id=3')
exec('seq_start rate=1 id=25-27 detailed_print=on duration=10800  max_active_ues=6')
sleep(60)
--RRE
set_multi_amf_to_register_multiue3(1,3,"311:489",510,610)
sleep(1)
exec('seq_start rate=1 id=28-29 detailed_print=on duration=10800  max_active_ues=8')
sleep(100)
--Second DRB
set_multi_amf_to_register_multiue3(1,3,"311:489",287,317)
sleep(1)
exec('ul_sinr_testmode_nr profile_id=3 sinr_target_srs=-200 sinr_target_pusch=-320 sinr_target_pucch=-320 sinr_target_preamble=-100')
exec('ue_testmode_set_nr id=287-317 testmode=ul_sinr action=activate profile_id=3')
exec('seq_start rate=2 id=19-21 detailed_print=on duration=10800  max_active_ues=10')
sleep(60)
--Paging
set_multi_amf_to_register_multiue3(1,3,"311:489",611,810)
sleep(1)
exec('ul_sinr_testmode_nr profile_id=3 sinr_target_srs=-200 sinr_target_pusch=-320 sinr_target_pucch=-320 sinr_target_preamble=-100')
exec('ue_testmode_set_nr id=611-810 testmode=ul_sinr action=activate profile_id=3')
exec('seq_start rate=6 id=31-36 detailed_print=on duration=10800  max_active_ues=10')
sleep(60)

print("Here again FOOL")
sleep(300)
print("SCRIPT completed")
exec("set_log flush")
end

function RJIO5()
require "multi_ue_sa_script_new"
require "rjio_latestmod_singlecell_error.lua"
sleep(1)
print("I am here again")
loop_counter = 1
set_multi_amf_to_register_multiue3(1,3,"311:489",186,286)
sleep(1)
--for loop_counter = 1,100 do

    for ue_id = 186,286 do
        exec('ue_nr_rrc_reconf_param id='..ue_id..' if_contains=any action=drop')     
    end
        exec('seq_start rate=2 id=12 detailed_print=on duration=300  max_active_ues=14')
        sleep(60)
--end
    

sleep(60)

print("Here again FOOL")
sleep(100)
print("SCRIPT completed")
exec("set_log flush")
end

function RJIO6()
require "multi_ue_sa_script_new"
sleep(1)
print("I am here again")
--- Basic call
--set_multi_amf_to_register_multiue3(1,3,"311:489",188,286)
sleep(1)
exec('ul_sinr_testmode_nr profile_id=3 sinr_target_srs=-200 sinr_target_pusch=-320 sinr_target_pucch=-320 sinr_target_preamble=-100')
exec('ue_testmode_set_nr id=187-286 testmode=ul_sinr action=activate profile_id=3')
exec('seq_start rate=2 id=13 detailed_print=on duration=300  max_active_ues=14')
sleep(60)
end

