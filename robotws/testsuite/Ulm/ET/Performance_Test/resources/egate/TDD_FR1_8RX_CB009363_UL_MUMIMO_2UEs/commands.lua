-- Functions for Common Scripts for AP9000
-- Note currently, only support one configuration, 


function configure()
    require "sansa.lua"
    run_configure()
end

function x2_link_up()
    exec('enb_x2_link_up enb=1 target=2')
end

function stop_max_dl_ul()
    require "multi_ue_sa_script_v3"
   
    stop_multiue_call_parallel(1,24,6,1,0.3)
end
function stop_max_dl()
    require "multi_ue_sa_script_v3"
   
    stop_multiue_call_parallel(1,24,6,1,0.3)
end

function stop_test_max_ul()
    require "multi_ue_sa_script_v3"
   
    stop_multiue_call_parallel(1,24,6,1,0.3)
end

function stop_max_ue()
    require "multi_ue_sa_script_v3"
    stop_multiue_call_parallel(1,4450,6,1,0.3)
end

function show_ue_nr_stats_24_ue_dl()
    exec("ue_stats_nr id=1-24 type=pdsch scell=0")
end
function show_ue_nr_stats_24_ue_ul()
    exec('ue_stats_nr id=1-24 type=pusch scell=0')
end
    

function start_max_dl_ul()
    require "multi_ue_sa_script_v3"
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
    require "multi_ue_sa_script_v3"
	set_amf_to_register_multiue(1,5,"311:489",24)
    register_multiue_with_traffic_parallel(1,24,6,1,1,1,"mbps",1,150,"dl",1.6,"internal",1350,"yes",60)
end
function start_max_ul()
    require "multi_ue_sa_script_v3"
	set_amf_to_register_multiue(1,5,"311:489",24)
    register_multiue_with_traffic_parallel(1,24,6,1,1,1,"kbps",46000,2,"both",1.6,"internal",1350,"yes",60)
end

function start_max_ue()
    require "multi_ue_sa_script_new"
    --- Max Ues case: 350 UEs * 6(cells/AP) = 2100 Ues with 74bps UL/DL
    --- Use 6Cell_6UEC_2100UEs_350UEs_PerCell.lua
exec('uec_l2_testmode_params fixed_csi_report=true')
    sleep(1)
    set_amf_to_register_multiue(1,5,"311:489",9000)
    sleep (3)
    register_multiue_with_pdu_check_traffic_parallel_retry(1,9000,6,1,1,1,"bps",74,74,"both",0.3,"internal",42,"yes",60)
end
function ue_stats_dl()
     print(" ############# PDSCH stats for Cell-1  Begins  ################### ")
     exec('ue_stats_nr id=1-4 type=pdsch scell=0')
     sleep(0.5)
     print(" ############ PDSCH stats for Cell-1  Ends  ##################### ")
     sleep(15)
     print("                                                                  ")
     print("                                                                  ")
     print(" ############ PDSCH stats for Cell-2  Start ##################### ")
     exec('ue_stats_nr id=5-8 type=pdsch scell=0')
     sleep(0.5)
     print(" ############ PDSCH stats for Cell-2  Ends  ##################### ")
     sleep(10)
     print("                                                                  ")
     print("                                                                  ")
     print(" ############ PDSCH stats for Cell-3  Begins #################### ")
     exec('ue_stats_nr id=9-12 type=pdsch scell=0')
     sleep (0.5)
     print(" ############# PDSCH stats for Cell-3  Ends  #################### ")
     sleep(8)
     print("                                                                  ")
     print("                                                                  ")
     print(" ############ PDSCH stats for Cell-4  Begins #################### ")
     exec('ue_stats_nr id=13-16 type=pdsch scell=0')
     sleep(0.5)
     print(" ############ PDSCH stats for Cell-4  Ends  ##################### ")
     sleep(7)
     print("                                                                  ")
     print("                                                                  ")
     print(" ############ PDSCH stats for Cell-5  Start ##################### ")
     exec('ue_stats_nr id=17-20 type=pdsch scell=0')
     sleep(0.5)
     print(" ############ PDSCH stats for Cell-5  Ends  ##################### ")
     sleep(6)
     print("                                                                  ")
     print("                                                                  ")
     print(" ############ PDSCH stats for Cell-6  Begins #################### ")
     exec('ue_stats_nr id=21-24 type=pdsch scell=0')
     sleep (1)
     print(" ############ PDSCH stats for Cell-6  Ends    ################### ")


end
function ue_stats_ul()
     print(" ############# PDSCH stats for Cell-1  Begins  ################### ")
     exec('ue_stats_nr id=1-4 type=pusch scell=0')
     sleep(0.5)
     print(" ############ PDSCH stats for Cell-1  Ends  ##################### ")
     sleep(10)
     print("                                                                  ")
     print("                                                                  ")
     print(" ############ PDSCH stats for Cell-2  Start ##################### ")
     exec('ue_stats_nr id=5-8 type=pusch scell=0')
     sleep(0.5)
     print(" ############ PDSCH stats for Cell-2  Ends  ##################### ")
     sleep(8)
     print("                                                                  ")
     print("                                                                  ")
     print(" ############ PDSCH stats for Cell-3  Begins #################### ")
     exec('ue_stats_nr id=9-12 type=pusch scell=0')
     sleep(0.5)
     print(" ############# PDSCH stats for Cell-3  Ends  #################### ")
     sleep(7)
     print("                                                                  ")
     print("                                                                  ")
     print(" ############ PDSCH stats for Cell-4  Begins #################### ")
     exec('ue_stats_nr id=13-16 type=pusch scell=0')
     sleep(0.5)
     print(" ############ PDSCH stats for Cell-4  Ends  ##################### ")
     sleep(6)
     print("                                                                  ")
     print("                                                                  ")
     print(" ############ PDSCH stats for Cell-5  Start ##################### ")
     exec('ue_stats_nr id=17-20 type=pusch scell=0')
     sleep(0.5)
     print(" ############ PDSCH stats for Cell-5  Ends  ##################### ")
     sleep(5)
     print("                                                                  ")
     print("                                                                  ")
     print(" ############ PDSCH stats for Cell-6  Begins #################### ")
     exec('ue_stats_nr id=21-24 type=pusch scell=0')
     sleep (0.5)
     print(" ############ PDSCH stats for Cell-6  Ends    ################### ")


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
   require "multi_ue_sa_script_v3"
    run_traffic_only_with_range(1,24,1,1,1,2,2,"both",64)
end
function  trf_rate_up()
   require "multi_ue_sa_script_v3"
    run_traffic_only_with_range(1,24,1,1,1,46000,151000,"both",1350)
end
function sib_check()
    require "multi_ue_sa_script_new"
    check_SIBs(1,6)
end
function start_72UE_DL_UL()
require "multi_ue_sa_script_new"
exec('uec_l2_testmode_params fixed_csi_report=true')
sleep (1)
set_amf_to_register_multiue(1,5,"311:489",432)
sleep (1)
--register_multiue_with_traffic_parallel(1,432,6,1,1,1,"mbps",3,22,"both",2,"internal",1350,"yes",60)
register_multiue_with_pdu_check_traffic_parallel_retry(1,432,6,1,1,1,"mbps",3,22,"both",0.6,"internal",1350,"yes",60)
end

----PET_Test_Cases_executione_commands----

function PET_1070FF_nonBF_24UE_UL()
require "multi_ue_sa_script_new"
exec('uec_l2_testmode_params fixed_csi_report=true')
sleep(1)
set_amf_to_register_multiue(1,5,"311:489",24)
sleep(1)
exec('seq_start rate=1 id=25-30 detailed_print=on duration=10  max_active_ues=4')
sleep(20)
exec('ue_summary')
sleep(1)
exec('ue_stats_nr id=1-24 scell=0 type=pusch')
print("PET_1070FF_nonBF_24UE_UL script completed")
end

function PET_1208FF_1070FF_nonBF_4500UE_DLUL()
require "multi_ue_sa_script_new"
exec('uec_l2_testmode_params fixed_csi_report=true')
sleep(1)
set_amf_to_register_multiue(1,5,"311:489",750)
sleep(5)
exec('seq_start rate=1 id=1-6 detailed_print=on duration=900  max_active_ues=750')
sleep(900)
exec('ue_summary')
print("PET_1208FF_1070FF_nonBF_4500UE_DLUL script completed")
end

function PET_1208FF_nonBF_24UE_DLUL()
require "multi_ue_sa_script_new"
exec('uec_l2_testmode_params fixed_csi_report=true')
sleep(1)
set_amf_to_register_multiue(1,5,"311:489",24)
sleep(1)
exec('seq_start rate=1 id=31-36 detailed_print=on duration=10  max_active_ues=4')
sleep(20)
exec('ue_summary')
sleep(1)
exec('ue_stats_nr id=1-24 scell=0 type=pusch')
sleep(1)
exec('ue_stats_nr id=1-24 scell=0 type=pdsch')
print("PET_1208FF_nonBF_24UE_DLUL script completed")
end

function PET_1208FF_nonBF_48UE_DLUL()
require "multi_ue_sa_script_new"
exec('uec_l2_testmode_params fixed_csi_report=true')
sleep(1)
set_amf_to_register_multiue(1,5,"311:489",48)
sleep(1)
exec('seq_start rate=1 id=7-12 detailed_print=on duration=15  max_active_ues=8')
sleep(40)
exec('ue_summary')
sleep(1)
exec('ue_stats_nr id=1-48 scell=0 type=pdsch')
sleep(1)
exec('ue_stats_nr id=1-48 scell=0 type=pusch')
print("PET_1208FF_nonBF_48UE_DLUL script completed")
end

function PET_1208FF_nonBF_40UE_DL_2CC()
require "multi_ue_sa_script_new"
exec('uec_l2_testmode_params fixed_csi_report=true')
sleep(1)
set_amf_to_register_multiue(1,5,"311:489",40)
sleep(1)
exec('seq_start rate=1 id=37 detailed_print=on duration=80  max_active_ues=40')
sleep(60)
exec('ue_summary')
sleep(1)
exec('ue_stats_nr id=1 scell=0-1 type=pdsch')
print("PET_1208FF_nonBF_40UE_DL_2CC script completed")
end

function PET_1208FF_nonBF_40UE_DL_3CC()
require "multi_ue_sa_script_new"
exec('uec_l2_testmode_params fixed_csi_report=true')
sleep(1)
set_amf_to_register_multiue(1,5,"311:489",40)
sleep(1)
exec('seq_start rate=1 id=38 detailed_print=on duration=60  max_active_ues=40')
sleep(60)
exec('ue_summary')
sleep(1)
exec('ue_stats_nr id=1,7,13,19,25,31,37,43,49,55,61,67,73,79,85,91,97,103,109,115,121,127,133,139,145,151,157,163,169,175,181,187,193,199,205,211,217,223,229,235 scell=0-2 type=pdsch')
exec('ue_stats_nr id=1 scell=0-2 type=pdsch')
print("PET_1208FF_nonBF_40UE_DL_3CC script completed")
end

function PET_1208FF_nonBF_432UE_DL()
require "multi_ue_sa_script_new"
exec('uec_l2_testmode_params fixed_csi_report=true')
sleep(2)
set_multi_amf_to_register_multiue(1,5,"311:489",1,432)
sleep(1)
exec('seq_start rate=1 id=13-18 detailed_print=on duration=80  max_active_ues=72')
end

function PET_1208FF_nonBF_432UE_UL()
require "multi_ue_sa_script_new"
exec('uec_l2_testmode_params fixed_csi_report=true')
sleep(1)
set_amf_to_register_multiue(1,5,"311:489",432)
sleep(1)
exec('seq_start rate=1 id=19-24 detailed_print=on duration=180  max_active_ues=72')
sleep(180)
--exec('ue_summary')
sleep(1)
exec('ue_stats_nr id=1-72 scell=0 type=pusch')
print("PET_1208FF_nonBF_432UE_UL script completed")
end

function PET_8406FF_nonBF_1UE_UL()
require "multi_ue_sa_script_new"
exec('uec_l2_testmode_params fixed_csi_report=true')
sleep(1)
set_amf_to_register_multiue(1,5,"311:489",1)
sleep(1)
exec('seq_start rate=1 id=39 detailed_print=on duration=4  max_active_ues=1')
sleep(2)
exec('ue_summary')
sleep(1)
exec('ue_stats_nr id=1 scell=0 type=pusch')
print("PET_8406FF_nonBF_1UE_UL script completed")
end

function PET_8406FF_nonBF_72UE_UL()
require "multi_ue_sa_script_new"
exec('uec_l2_testmode_params fixed_csi_report=true')
sleep(1)
set_amf_to_register_multiue(1,5,"311:489",72)
sleep(1)
exec('seq_start rate=1 id=40 detailed_print=on duration=120  max_active_ues=72')
sleep(120)
exec('ue_summary')
sleep(1)
exec('ue_stats_nr id=1-72 scell=0 type=pusch')
print("PET_8406FF_nonBF_72UE_UL script completed")
end

function PET_1070FF_nonBF_9000UE_DLUL_rate1()
require "multi_ue_sa_script_new"
exec('uec_l2_testmode_params fixed_csi_report=true')
sleep(1)
set_amf_to_register_multiue(1,5,"311:489",9000)
sleep(5)
exec('seq_start rate=1 id=1-6 detailed_print=on duration=1550  max_active_ues=1500')
sleep(1600)
exec('ue_summary')
print("PET_1070FF_nonBF_9000UE_DLUL_rate1 script completed")
end

function PET_1070FF_nonBF_9000UE_DLUL_rate1dot2()
require "multi_ue_sa_script_new"
exec('uec_l2_testmode_params fixed_csi_report=true')
sleep(1)
set_amf_to_register_multiue(1,5,"311:489",9000)
sleep(5)
exec('seq_start rate=1.2 id=1-6 detailed_print=on duration=1300  max_active_ues=1500')
sleep(1350)
exec('ue_summary')
print("PET_1070FF_nonBF_9000UE_DLUL_rate1dot2 script completed")
end

function PET_1070FF_nonBF_9000UE_DLUL_rate1dot5()
require "multi_ue_sa_script_new"
exec('uec_l2_testmode_params fixed_csi_report=true')
sleep(1)
set_amf_to_register_multiue(1,5,"311:489",9000)
sleep(5)
exec('seq_start rate=1.5 id=1-6 detailed_print=on duration=1050  max_active_ues=1500')
sleep(1100)
exec('ue_summary')
print("PET_1070FF_nonBF_9000UE_DLUL_rate1dot5 script completed")
end

function FR1_ScellAddition_Without_Traffic()
require "multi_ue_sa_script_new"
exec('uec_l2_testmode_params fixed_csi_report=true')
sleep(1)
exec('seq_start rate=1 id=41 detailed_print=on duration=420  max_active_ues=406')
sleep(430)
exec('ue_summary')
print("FR1_ScellAddition_Without_Traffic script completed")
end

function PET_NonBF_VoNR_CDRX_Enabled()
require "multi_ue_sa_script_new"
exec('uec_l2_testmode_params fixed_csi_report=true')
sleep(1)
set_amf_to_register_multiue(1,5,"311:489",828)
sleep(3)
exec('seq_start rate=1 id=1-6 detailed_print=on duration=150  max_active_ues=138')
sleep(160)
exec('ue_summary')
print("PET_NonBF_VoNR_CDRX_Enabled script completed")
end

function PET_NonBF_VoNR_CDRX_Disabled()
require "multi_ue_sa_script_new"
exec('uec_l2_testmode_params fixed_csi_report=true')
sleep(1)
set_amf_to_register_multiue(1,5,"311:489",1656)
sleep(5)
exec('seq_start rate=1 id=1-6 detailed_print=on duration=300  max_active_ues=276')
sleep(320)
exec('ue_summary')
print("PET_NonBF_VoNR_CDRX_Disabled script completed")
end

-----PET_Scenarios_with_Beamforming-----

function PET_1070FF_BF_9000UE_DLUL_rate1()
require "multi_ue_sa_script_new"
exec('uec_l2_testmode_params fixed_csi_report=true')
sleep(1)
set_amf_to_register_multiue(1,5,"311:489",9000)
sleep(5)
exec('beam_control_testmode_nr profile_id=1 ueBeamIndexInitial=0,1,2,3,4,5 ssbeam_bestbeam=0 ssbeam_rsrp_best=-44 ssbeam_rsrp_avg=-50')
exec('beam_control_testmode_nr profile_id=2 ueBeamIndexInitial=1,0,2,3,4,5 ssbeam_bestbeam=1 ssbeam_rsrp_best=-45 ssbeam_rsrp_avg=-120')
exec('beam_control_testmode_nr profile_id=3 ueBeamIndexInitial=2,0,1,3,4,5 ssbeam_bestbeam=2 ssbeam_rsrp_best=-50 ssbeam_rsrp_avg=-125')
exec('beam_control_testmode_nr profile_id=4 ueBeamIndexInitial=3,0,1,2,4,5 ssbeam_bestbeam=3 ssbeam_rsrp_best=-55 ssbeam_rsrp_avg=-120')
exec('beam_control_testmode_nr profile_id=5 ueBeamIndexInitial=4,0,1,2,3,5 ssbeam_bestbeam=4 ssbeam_rsrp_best=-60 ssbeam_rsrp_avg=-139')
exec('beam_control_testmode_nr profile_id=6 ueBeamIndexInitial=5,0,1,2,3,4 ssbeam_bestbeam=5 ssbeam_rsrp_best=-65 ssbeam_rsrp_avg=-70')
exec('ue_testmode_set_nr id=1-1500 testmode=beam_control action=activate profile_id=1 beamaction=attach scell=0')
exec('ue_testmode_set_nr id=1501-3000 testmode=beam_control action=activate profile_id=2 beamaction=attach scell=0')
exec('ue_testmode_set_nr id=3001-4500 testmode=beam_control action=activate profile_id=3 beamaction=attach scell=0')
exec('ue_testmode_set_nr id=4501-6000 testmode=beam_control action=activate profile_id=4 beamaction=attach scell=0')
exec('ue_testmode_set_nr id=6001-7500 testmode=beam_control action=activate profile_id=5 beamaction=attach scell=0')
exec('ue_testmode_set_nr id=7501-9000 testmode=beam_control action=activate profile_id=6 beamaction=attach scell=0')
sleep(2)
exec('seq_start rate=1 id=1-6 detailed_print=on duration=1550 max_active_ues=1500')
sleep(1600)
exec('ue_summary')
print("PET_1070FF_BF_9000UE_DLUL_rate1 script completed")
end

function PET_1070FF_nonBF_24UE_UL_BF()
require "multi_ue_sa_script_new"
exec('uec_l2_testmode_params fixed_csi_report=true')
sleep(2)
set_multi_amf_to_register_multiue(1,5,"311:489",1,24)
sleep(2)
exec('beam_control_testmode_nr profile_id=1 ueBeamIndexInitial=0,1,2,3,4,5 ssbeam_bestbeam=0 ssbeam_rsrp_best=-44 ssbeam_rsrp_avg=-50')
exec('beam_control_testmode_nr profile_id=2 ueBeamIndexInitial=1,0,2,3,4,5 ssbeam_bestbeam=1 ssbeam_rsrp_best=-45 ssbeam_rsrp_avg=-120')
exec('beam_control_testmode_nr profile_id=3 ueBeamIndexInitial=2,0,1,3,4,5 ssbeam_bestbeam=2 ssbeam_rsrp_best=-50 ssbeam_rsrp_avg=-125')
exec('beam_control_testmode_nr profile_id=4 ueBeamIndexInitial=3,0,1,2,4,5 ssbeam_bestbeam=3 ssbeam_rsrp_best=-55 ssbeam_rsrp_avg=-120')
exec('beam_control_testmode_nr profile_id=5 ueBeamIndexInitial=4,0,1,2,3,5 ssbeam_bestbeam=4 ssbeam_rsrp_best=-60 ssbeam_rsrp_avg=-139')
exec('beam_control_testmode_nr profile_id=6 ueBeamIndexInitial=5,0,1,2,3,4 ssbeam_bestbeam=5 ssbeam_rsrp_best=-65 ssbeam_rsrp_avg=-70')
exec('ue_testmode_set_nr id=1-4 testmode=beam_control action=activate profile_id=1 beamaction=attach scell=0')
exec('ue_testmode_set_nr id=5-8 testmode=beam_control action=activate profile_id=2 beamaction=attach scell=0')
exec('ue_testmode_set_nr id=9-12 testmode=beam_control action=activate profile_id=3 beamaction=attach scell=0')
exec('ue_testmode_set_nr id=13-16 testmode=beam_control action=activate profile_id=4 beamaction=attach scell=0')
exec('ue_testmode_set_nr id=17-20 testmode=beam_control action=activate profile_id=5 beamaction=attach scell=0')
exec('ue_testmode_set_nr id=21-24 testmode=beam_control action=activate profile_id=6 beamaction=attach scell=0')
sleep(1)
exec('seq_start rate=1 id=25-30 detailed_print=on duration=10  max_active_ues=4')
sleep(20)
exec('ue_summary')
sleep(1)
exec('ue_stats_nr id=1-24 scell=0 type=pusch')
print("PET_1070FF_nonBF_24UE_UL_BF script completed")
end

function PET_1208FF_BF_48UE_DLUL()
require "multi_ue_sa_script_new"
exec('uec_l2_testmode_params fixed_csi_report=true')
sleep(2)
set_multi_amf_to_register_multiue(1,5,"311:489",1,48)
sleep(2)
exec('beam_control_testmode_nr profile_id=1 ueBeamIndexInitial=0,1,2,3,4,5 ssbeam_bestbeam=0 ssbeam_rsrp_best=-44 ssbeam_rsrp_avg=-50')
exec('beam_control_testmode_nr profile_id=2 ueBeamIndexInitial=1,0,2,3,4,5 ssbeam_bestbeam=1 ssbeam_rsrp_best=-45 ssbeam_rsrp_avg=-120')
exec('beam_control_testmode_nr profile_id=3 ueBeamIndexInitial=2,0,1,3,4,5 ssbeam_bestbeam=2 ssbeam_rsrp_best=-50 ssbeam_rsrp_avg=-125')
exec('beam_control_testmode_nr profile_id=4 ueBeamIndexInitial=3,0,1,2,4,5 ssbeam_bestbeam=3 ssbeam_rsrp_best=-55 ssbeam_rsrp_avg=-120')
exec('beam_control_testmode_nr profile_id=5 ueBeamIndexInitial=4,0,1,2,3,5 ssbeam_bestbeam=4 ssbeam_rsrp_best=-60 ssbeam_rsrp_avg=-139')
exec('beam_control_testmode_nr profile_id=6 ueBeamIndexInitial=5,0,1,2,3,4 ssbeam_bestbeam=5 ssbeam_rsrp_best=-65 ssbeam_rsrp_avg=-70')
exec('ue_testmode_set_nr id=1-8 testmode=beam_control action=activate profile_id=1 beamaction=attach scell=0')
exec('ue_testmode_set_nr id=9-16 testmode=beam_control action=activate profile_id=2 beamaction=attach scell=0')
exec('ue_testmode_set_nr id=17-24 testmode=beam_control action=activate profile_id=3 beamaction=attach scell=0')
exec('ue_testmode_set_nr id=25-32 testmode=beam_control action=activate profile_id=4 beamaction=attach scell=0')
exec('ue_testmode_set_nr id=33-40 testmode=beam_control action=activate profile_id=5 beamaction=attach scell=0')
exec('ue_testmode_set_nr id=41-48 testmode=beam_control action=activate profile_id=6 beamaction=attach scell=0')
sleep(1)
set_amf_to_register_multiue(1,5,"311:489",48)
sleep(1)
exec('seq_start rate=1 id=7-12 detailed_print=on duration=12  max_active_ues=8')
sleep(20)
exec('ue_summary')
sleep(1)
exec('ue_stats_nr id=1-48 scell=0 type=pdsch')
sleep(1)
exec('ue_stats_nr id=1-48 scell=0 type=pusch')
print("PET_1208FF_BF_48UE_DLUL script completed")
end

function PET_1208FF_BF_432UE_DL()
require "multi_ue_sa_script_new"
exec('uec_l2_testmode_params fixed_csi_report=true')
sleep(2)
set_multi_amf_to_register_multiue(1,5,"311:489",1,432)
sleep(2)
exec('beam_control_testmode_nr profile_id=1 ueBeamIndexInitial=0,1,2,3,4,5 ssbeam_bestbeam=0 ssbeam_rsrp_best=-44 ssbeam_rsrp_avg=-50')
exec('beam_control_testmode_nr profile_id=2 ueBeamIndexInitial=1,0,2,3,4,5 ssbeam_bestbeam=1 ssbeam_rsrp_best=-45 ssbeam_rsrp_avg=-120')
exec('beam_control_testmode_nr profile_id=3 ueBeamIndexInitial=2,0,1,3,4,5 ssbeam_bestbeam=2 ssbeam_rsrp_best=-50 ssbeam_rsrp_avg=-125')
exec('beam_control_testmode_nr profile_id=4 ueBeamIndexInitial=3,0,1,2,4,5 ssbeam_bestbeam=3 ssbeam_rsrp_best=-55 ssbeam_rsrp_avg=-120')
exec('beam_control_testmode_nr profile_id=5 ueBeamIndexInitial=4,0,1,2,3,5 ssbeam_bestbeam=4 ssbeam_rsrp_best=-60 ssbeam_rsrp_avg=-139')
exec('beam_control_testmode_nr profile_id=6 ueBeamIndexInitial=5,0,1,2,3,4 ssbeam_bestbeam=5 ssbeam_rsrp_best=-65 ssbeam_rsrp_avg=-70')
exec('ue_testmode_set_nr id=1-72 testmode=beam_control action=activate profile_id=1 beamaction=attach scell=0')
exec('ue_testmode_set_nr id=73-144 testmode=beam_control action=activate profile_id=2 beamaction=attach scell=0')
exec('ue_testmode_set_nr id=145-216 testmode=beam_control action=activate profile_id=3 beamaction=attach scell=0')
exec('ue_testmode_set_nr id=217-288 testmode=beam_control action=activate profile_id=4 beamaction=attach scell=0')
exec('ue_testmode_set_nr id=289-360 testmode=beam_control action=activate profile_id=5 beamaction=attach scell=0')
exec('ue_testmode_set_nr id=361-432 testmode=beam_control action=activate profile_id=6 beamaction=attach scell=0')
sleep(1)
exec('seq_start rate=1 id=13-18 detailed_print=on duration=180  max_active_ues=72')
sleep(180)
exec('ue_summary')
sleep(1)
exec('ue_stats_nr id=1-72 scell=0 type=pdsch')
print("PET_1208FF_BF_432UE_DL script completed")
end

function PET_1208FF_BF_432UE_UL()
require "multi_ue_sa_script_new"
exec('uec_l2_testmode_params fixed_csi_report=true')
sleep(2)
set_multi_amf_to_register_multiue(1,5,"311:489",1,432)
sleep(2)
exec('beam_control_testmode_nr profile_id=1 ueBeamIndexInitial=0,1,2,3,4,5 ssbeam_bestbeam=0 ssbeam_rsrp_best=-44 ssbeam_rsrp_avg=-50')
exec('beam_control_testmode_nr profile_id=2 ueBeamIndexInitial=1,0,2,3,4,5 ssbeam_bestbeam=1 ssbeam_rsrp_best=-45 ssbeam_rsrp_avg=-120')
exec('beam_control_testmode_nr profile_id=3 ueBeamIndexInitial=2,0,1,3,4,5 ssbeam_bestbeam=2 ssbeam_rsrp_best=-50 ssbeam_rsrp_avg=-125')
exec('beam_control_testmode_nr profile_id=4 ueBeamIndexInitial=3,0,1,2,4,5 ssbeam_bestbeam=3 ssbeam_rsrp_best=-55 ssbeam_rsrp_avg=-120')
exec('beam_control_testmode_nr profile_id=5 ueBeamIndexInitial=4,0,1,2,3,5 ssbeam_bestbeam=4 ssbeam_rsrp_best=-60 ssbeam_rsrp_avg=-139')
exec('beam_control_testmode_nr profile_id=6 ueBeamIndexInitial=5,0,1,2,3,4 ssbeam_bestbeam=5 ssbeam_rsrp_best=-65 ssbeam_rsrp_avg=-70')
exec('ue_testmode_set_nr id=1-72 testmode=beam_control action=activate profile_id=1 beamaction=attach scell=0')
exec('ue_testmode_set_nr id=73-144 testmode=beam_control action=activate profile_id=2 beamaction=attach scell=0')
exec('ue_testmode_set_nr id=145-216 testmode=beam_control action=activate profile_id=3 beamaction=attach scell=0')
exec('ue_testmode_set_nr id=217-288 testmode=beam_control action=activate profile_id=4 beamaction=attach scell=0')
exec('ue_testmode_set_nr id=289-360 testmode=beam_control action=activate profile_id=5 beamaction=attach scell=0')
exec('ue_testmode_set_nr id=361-432 testmode=beam_control action=activate profile_id=6 beamaction=attach scell=0')
sleep(1)
exec('seq_start rate=1 id=19-24 detailed_print=on duration=80  max_active_ues=72')
sleep(90)
exec('ue_summary')
sleep(1)
exec('ue_stats_nr id=1-72 scell=0 type=pusch')
print("PET_1208FF_BF_432UE_UL script completed")
end

function PET_BF_VoNR_CDRX_Disabled()
require "multi_ue_sa_script_new"
exec('uec_l2_testmode_params fixed_csi_report=true')
sleep(1)
set_amf_to_register_multiue(1,5,"311:489",1656)
sleep(5)
exec('seq_start rate=1 id=1-6 detailed_print=on duration=350  max_active_ues=276')
sleep(320)
exec('ue_summary')
print("PET_BF_VoNR_CDRX_Disabled script completed")
end


function FDD_12Cell_9000UE_RRC_Connected()
require "multi_ue_sa_script_new"
exec('uec_l2_testmode_params fixed_csi_report=true')
sleep(1)
set_amf_to_register_multiue(1,5,"311:489",9000)
sleep(5)
exec('seq_start rate=1 id=1-6 detailed_print=on duration=900 max_active_ues=750')
sleep(900)
exec('seq_start rate=1 id=7-12 detailed_print=on duration=900 max_active_ues=750')
sleep(900)
exec('ue_summary')
print("FDD_12Cell_9000UE_RRC_Connected script completed")
end

function PET_1208FF_BF_48UE_DLUL()
require "multi_ue_sa_script_new"
exec('uec_l2_testmode_params fixed_csi_report=true')
sleep(2)
set_multi_amf_to_register_multiue(1,5,"311:489",1,48)
sleep(2)
exec('beam_control_testmode_nr profile_id=1 ueBeamIndexInitial=0,1,2,3,4,5 ssbeam_bestbeam=0 ssbeam_rsrp_best=-44 ssbeam_rsrp_avg=-50')
exec('beam_control_testmode_nr profile_id=2 ueBeamIndexInitial=1,0,2,3,4,5 ssbeam_bestbeam=1 ssbeam_rsrp_best=-45 ssbeam_rsrp_avg=-120')
exec('beam_control_testmode_nr profile_id=3 ueBeamIndexInitial=2,0,1,3,4,5 ssbeam_bestbeam=2 ssbeam_rsrp_best=-50 ssbeam_rsrp_avg=-125')
exec('beam_control_testmode_nr profile_id=4 ueBeamIndexInitial=3,0,1,2,4,5 ssbeam_bestbeam=3 ssbeam_rsrp_best=-55 ssbeam_rsrp_avg=-120')
exec('beam_control_testmode_nr profile_id=5 ueBeamIndexInitial=4,0,1,2,3,5 ssbeam_bestbeam=4 ssbeam_rsrp_best=-60 ssbeam_rsrp_avg=-139')
exec('beam_control_testmode_nr profile_id=6 ueBeamIndexInitial=5,0,1,2,3,4 ssbeam_bestbeam=5 ssbeam_rsrp_best=-65 ssbeam_rsrp_avg=-70')
exec('ue_testmode_set_nr id=1-8 testmode=beam_control action=activate profile_id=1 beamaction=attach scell=0')
exec('ue_testmode_set_nr id=9-16 testmode=beam_control action=activate profile_id=2 beamaction=attach scell=0')
exec('ue_testmode_set_nr id=17-24 testmode=beam_control action=activate profile_id=3 beamaction=attach scell=0')
exec('ue_testmode_set_nr id=25-32 testmode=beam_control action=activate profile_id=4 beamaction=attach scell=0')
exec('ue_testmode_set_nr id=33-40 testmode=beam_control action=activate profile_id=5 beamaction=attach scell=0')
exec('ue_testmode_set_nr id=41-48 testmode=beam_control action=activate profile_id=6 beamaction=attach scell=0')
sleep(1)
set_amf_to_register_multiue(1,5,"311:489",48)
sleep(1)
exec('seq_start rate=1 id=7-12 detailed_print=on duration=12  max_active_ues=8')
sleep(20)
exec('ue_summary')
sleep(1)
exec('ue_stats_nr id=1-48 scell=0 type=pdsch')
sleep(1)
exec('ue_stats_nr id=1-48 scell=0 type=pusch')
print("PET_1208FF_BF_48UE_DLUL script completed")
end

function PET_1208FF_BF_432UE_DL()
require "multi_ue_sa_script_new"
exec('uec_l2_testmode_params fixed_csi_report=true')
sleep(2)
set_multi_amf_to_register_multiue(1,5,"311:489",1,432)
sleep(2)
exec('beam_control_testmode_nr profile_id=1 ueBeamIndexInitial=0,1,2,3,4,5 ssbeam_bestbeam=0 ssbeam_rsrp_best=-44 ssbeam_rsrp_avg=-50')
exec('beam_control_testmode_nr profile_id=2 ueBeamIndexInitial=1,0,2,3,4,5 ssbeam_bestbeam=1 ssbeam_rsrp_best=-45 ssbeam_rsrp_avg=-120')
exec('beam_control_testmode_nr profile_id=3 ueBeamIndexInitial=2,0,1,3,4,5 ssbeam_bestbeam=2 ssbeam_rsrp_best=-50 ssbeam_rsrp_avg=-125')
exec('beam_control_testmode_nr profile_id=4 ueBeamIndexInitial=3,0,1,2,4,5 ssbeam_bestbeam=3 ssbeam_rsrp_best=-55 ssbeam_rsrp_avg=-120')
exec('beam_control_testmode_nr profile_id=5 ueBeamIndexInitial=4,0,1,2,3,5 ssbeam_bestbeam=4 ssbeam_rsrp_best=-60 ssbeam_rsrp_avg=-139')
exec('beam_control_testmode_nr profile_id=6 ueBeamIndexInitial=5,0,1,2,3,4 ssbeam_bestbeam=5 ssbeam_rsrp_best=-65 ssbeam_rsrp_avg=-70')
exec('ue_testmode_set_nr id=1-72 testmode=beam_control action=activate profile_id=1 beamaction=attach scell=0')
exec('ue_testmode_set_nr id=73-144 testmode=beam_control action=activate profile_id=2 beamaction=attach scell=0')
exec('ue_testmode_set_nr id=145-216 testmode=beam_control action=activate profile_id=3 beamaction=attach scell=0')
exec('ue_testmode_set_nr id=217-288 testmode=beam_control action=activate profile_id=4 beamaction=attach scell=0')
exec('ue_testmode_set_nr id=289-360 testmode=beam_control action=activate profile_id=5 beamaction=attach scell=0')
exec('ue_testmode_set_nr id=361-432 testmode=beam_control action=activate profile_id=6 beamaction=attach scell=0')
sleep(1)
exec('seq_start rate=1 id=13-18 detailed_print=on duration=80  max_active_ues=72')
sleep(90)
exec('ue_summary')
sleep(1)
exec('ue_stats_nr id=1-72 scell=0 type=pdsch')
print("PET_1208FF_BF_432UE_DL script completed")
end

function PET_1208FF_BF_432UE_UL()
require "multi_ue_sa_script_new"
exec('uec_l2_testmode_params fixed_csi_report=true')
sleep(2)
set_multi_amf_to_register_multiue(1,5,"311:489",1,432)
sleep(2)
exec('beam_control_testmode_nr profile_id=1 ueBeamIndexInitial=0,1,2,3,4,5 ssbeam_bestbeam=0 ssbeam_rsrp_best=-44 ssbeam_rsrp_avg=-50')
exec('beam_control_testmode_nr profile_id=2 ueBeamIndexInitial=1,0,2,3,4,5 ssbeam_bestbeam=1 ssbeam_rsrp_best=-45 ssbeam_rsrp_avg=-120')
exec('beam_control_testmode_nr profile_id=3 ueBeamIndexInitial=2,0,1,3,4,5 ssbeam_bestbeam=2 ssbeam_rsrp_best=-50 ssbeam_rsrp_avg=-125')
exec('beam_control_testmode_nr profile_id=4 ueBeamIndexInitial=3,0,1,2,4,5 ssbeam_bestbeam=3 ssbeam_rsrp_best=-55 ssbeam_rsrp_avg=-120')
exec('beam_control_testmode_nr profile_id=5 ueBeamIndexInitial=4,0,1,2,3,5 ssbeam_bestbeam=4 ssbeam_rsrp_best=-60 ssbeam_rsrp_avg=-139')
exec('beam_control_testmode_nr profile_id=6 ueBeamIndexInitial=5,0,1,2,3,4 ssbeam_bestbeam=5 ssbeam_rsrp_best=-65 ssbeam_rsrp_avg=-70')
exec('ue_testmode_set_nr id=1-72 testmode=beam_control action=activate profile_id=1 beamaction=attach scell=0')
exec('ue_testmode_set_nr id=73-144 testmode=beam_control action=activate profile_id=2 beamaction=attach scell=0')
exec('ue_testmode_set_nr id=145-216 testmode=beam_control action=activate profile_id=3 beamaction=attach scell=0')
exec('ue_testmode_set_nr id=217-288 testmode=beam_control action=activate profile_id=4 beamaction=attach scell=0')
exec('ue_testmode_set_nr id=289-360 testmode=beam_control action=activate profile_id=5 beamaction=attach scell=0')
exec('ue_testmode_set_nr id=361-432 testmode=beam_control action=activate profile_id=6 beamaction=attach scell=0')
sleep(1)
exec('seq_start rate=1 id=19-24 detailed_print=on duration=80  max_active_ues=72')
sleep(90)
exec('ue_summary')
sleep(1)
exec('ue_stats_nr id=1-72 scell=0 type=pusch')
print("PET_1208FF_BF_432UE_UL script completed")
end

function PET_BF_VoNR_CDRX_Disabled()
require "multi_ue_sa_script_new"
exec('uec_l2_testmode_params fixed_csi_report=true')
sleep(1)
set_amf_to_register_multiue(1,5,"311:489",1656)
sleep(5)
exec('seq_start rate=1 id=1-6 detailed_print=on duration=350  max_active_ues=276')
sleep(320)
exec('ue_summary')
print("PET_BF_VoNR_CDRX_Disabled script completed")
end


function FDD_12Cell_9000UE_RRC_Connected()
require "multi_ue_sa_script_new"
exec('uec_l2_testmode_params fixed_csi_report=true')
sleep(1)
set_amf_to_register_multiue(1,5,"311:489",9000)
sleep(5)
exec('seq_start rate=1 id=1-6 detailed_print=on duration=900 max_active_ues=750')
sleep(900)
exec('seq_start rate=1 id=7-12 detailed_print=on duration=900 max_active_ues=750')
sleep(900)
exec('ue_summary')
print("FDD_12Cell_9000UE_RRC_Connected script completed")
end

function FDD_12Cell_480UE_DL_Peak()
require "multi_ue_sa_script_new"
exec('uec_l2_testmode_params fixed_csi_report=true')
sleep(1)
set_amf_to_register_multiue(1,5,"311:489",480)
sleep(5)
exec('seq_start rate=1 id=13-18 detailed_print=on duration=50 max_active_ues=40')
sleep(60)
exec('seq_start rate=1 id=19-24 detailed_print=on duration=50 max_active_ues=40')
sleep(60)
exec('ue_summary')
print("FDD_12Cell_480UE_DL_Peak script completed")
end

function FDD_12Cell_480UE_UL_Peak()
require "multi_ue_sa_script_new"
exec('uec_l2_testmode_params fixed_csi_report=true')
sleep(1)
set_amf_to_register_multiue(1,5,"311:489",480)
sleep(5)
exec('seq_start rate=1 id=25-30 detailed_print=on duration=50 max_active_ues=40')
sleep(60)
exec('seq_start rate=1 id=31-36 detailed_print=on duration=50 max_active_ues=40')
sleep(60)
exec('ue_summary')
print("FDD_12Cell_480UE_UL_Peak script completed")
end

function PET_1208FF_BF_1182UE_DL_GBR_Bearers()
require "multi_ue_sa_script_new"
exec('uec_l2_testmode_params fixed_csi_report=true')
sleep(1)
set_amf_to_register_multiue(1,5,"311:489",1182)
sleep(1)
exec('beam_control_testmode_nr profile_id=1 ueBeamIndexInitial=0,1,2,3,4,5 ssbeam_bestbeam=0 ssbeam_rsrp_best=-44 ssbeam_rsrp_avg=-50')
exec('beam_control_testmode_nr profile_id=2 ueBeamIndexInitial=1,0,2,3,4,5 ssbeam_bestbeam=1 ssbeam_rsrp_best=-45 ssbeam_rsrp_avg=-120')
exec('beam_control_testmode_nr profile_id=3 ueBeamIndexInitial=2,0,1,3,4,5 ssbeam_bestbeam=2 ssbeam_rsrp_best=-50 ssbeam_rsrp_avg=-125')
exec('beam_control_testmode_nr profile_id=4 ueBeamIndexInitial=3,0,1,2,4,5 ssbeam_bestbeam=3 ssbeam_rsrp_best=-55 ssbeam_rsrp_avg=-120')
exec('beam_control_testmode_nr profile_id=5 ueBeamIndexInitial=4,0,1,2,3,5 ssbeam_bestbeam=4 ssbeam_rsrp_best=-60 ssbeam_rsrp_avg=-139')
exec('beam_control_testmode_nr profile_id=6 ueBeamIndexInitial=5,0,1,2,3,4 ssbeam_bestbeam=5 ssbeam_rsrp_best=-65 ssbeam_rsrp_avg=-70')
exec('ue_testmode_set_nr id=1-197 testmode=beam_control action=activate profile_id=1 beamaction=attach scell=0')
exec('ue_testmode_set_nr id=198-394 testmode=beam_control action=activate profile_id=2 beamaction=attach scell=0')
exec('ue_testmode_set_nr id=395-591 testmode=beam_control action=activate profile_id=3 beamaction=attach scell=0')
exec('ue_testmode_set_nr id=592-788 testmode=beam_control action=activate profile_id=4 beamaction=attach scell=0')
exec('ue_testmode_set_nr id=789-985 testmode=beam_control action=activate profile_id=5 beamaction=attach scell=0')
exec('ue_testmode_set_nr id=986-1182 testmode=beam_control action=activate profile_id=6 beamaction=attach scell=0')
sleep(1)
exec('seq_start rate=1 id=41-46 detailed_print=on duration=200  max_active_ues=197')
sleep(210)
exec('ue_summary')
sleep(1)
exec('ue_stats_nr id=1-1182 scell=0 type=pdsch')
print("PET_1208FF_BF_1182UE_DL_GBR_Bearers script completed")
end

function PET_1070FF_BF_50UEs_Mix_GBR_Bearers()
require "multi_ue_sa_script_new"
exec('uec_l2_testmode_params fixed_csi_report=true')
sleep(1)
set_amf_to_register_multiue(1,5,"311:489",300)
sleep(1)
exec('beam_control_testmode_nr profile_id=1 ueBeamIndexInitial=0,1,2,3,4,5 ssbeam_bestbeam=0 ssbeam_rsrp_best=-44 ssbeam_rsrp_avg=-50')
exec('beam_control_testmode_nr profile_id=2 ueBeamIndexInitial=1,0,2,3,4,5 ssbeam_bestbeam=1 ssbeam_rsrp_best=-45 ssbeam_rsrp_avg=-120')
exec('beam_control_testmode_nr profile_id=3 ueBeamIndexInitial=2,0,1,3,4,5 ssbeam_bestbeam=2 ssbeam_rsrp_best=-50 ssbeam_rsrp_avg=-125')
exec('beam_control_testmode_nr profile_id=4 ueBeamIndexInitial=3,0,1,2,4,5 ssbeam_bestbeam=3 ssbeam_rsrp_best=-55 ssbeam_rsrp_avg=-120')
exec('beam_control_testmode_nr profile_id=5 ueBeamIndexInitial=4,0,1,2,3,5 ssbeam_bestbeam=4 ssbeam_rsrp_best=-60 ssbeam_rsrp_avg=-139')
exec('beam_control_testmode_nr profile_id=6 ueBeamIndexInitial=5,0,1,2,3,4 ssbeam_bestbeam=5 ssbeam_rsrp_best=-65 ssbeam_rsrp_avg=-70')
exec('ue_testmode_set_nr id=1-50 testmode=beam_control action=activate profile_id=1 beamaction=attach scell=0')
exec('ue_testmode_set_nr id=51-100 testmode=beam_control action=activate profile_id=2 beamaction=attach scell=0')
exec('ue_testmode_set_nr id=101-150 testmode=beam_control action=activate profile_id=3 beamaction=attach scell=0')
exec('ue_testmode_set_nr id=151-200 testmode=beam_control action=activate profile_id=4 beamaction=attach scell=0')
exec('ue_testmode_set_nr id=201-250 testmode=beam_control action=activate profile_id=5 beamaction=attach scell=0')
exec('ue_testmode_set_nr id=251-300 testmode=beam_control action=activate profile_id=6 beamaction=attach scell=0')
sleep(1)
exec('seq_start rate=1 id=1-6 detailed_print=on duration=12  max_active_ues=9')
sleep(15)
exec('seq_start rate=1 id=7-12 detailed_print=on duration=3  max_active_ues=1')
sleep(3)
exec('seq_start rate=1 id=13-18 detailed_print=on duration=3  max_active_ues=1')
sleep(3)
exec('seq_start rate=1 id=19-24 detailed_print=on duration=3  max_active_ues=1')
sleep(3)
exec('seq_start rate=1 id=25-30 detailed_print=on duration=50  max_active_ues=38')
sleep(60)
exec('ue_summary')
print("PET_1070FF_BF_50UEs_Mix_GBR_Bearers script completed")
end

function PET_1070FF_BF_240UE_UL_GBR_Bearers()
require "multi_ue_sa_script_new"
exec('uec_l2_testmode_params fixed_csi_report=true')
sleep(1)
set_amf_to_register_multiue(1,5,"311:489",240)
sleep(1)
exec('beam_control_testmode_nr profile_id=1 ueBeamIndexInitial=0,1,2,3,4,5 ssbeam_bestbeam=0 ssbeam_rsrp_best=-44 ssbeam_rsrp_avg=-50')
exec('beam_control_testmode_nr profile_id=2 ueBeamIndexInitial=1,0,2,3,4,5 ssbeam_bestbeam=1 ssbeam_rsrp_best=-45 ssbeam_rsrp_avg=-120')
exec('beam_control_testmode_nr profile_id=3 ueBeamIndexInitial=2,0,1,3,4,5 ssbeam_bestbeam=2 ssbeam_rsrp_best=-50 ssbeam_rsrp_avg=-125')
exec('beam_control_testmode_nr profile_id=4 ueBeamIndexInitial=3,0,1,2,4,5 ssbeam_bestbeam=3 ssbeam_rsrp_best=-55 ssbeam_rsrp_avg=-120')
exec('beam_control_testmode_nr profile_id=5 ueBeamIndexInitial=4,0,1,2,3,5 ssbeam_bestbeam=4 ssbeam_rsrp_best=-60 ssbeam_rsrp_avg=-139')
exec('beam_control_testmode_nr profile_id=6 ueBeamIndexInitial=5,0,1,2,3,4 ssbeam_bestbeam=5 ssbeam_rsrp_best=-65 ssbeam_rsrp_avg=-70')
exec('ue_testmode_set_nr id=1-40 testmode=beam_control action=activate profile_id=1 beamaction=attach scell=0')
exec('ue_testmode_set_nr id=41-80 testmode=beam_control action=activate profile_id=2 beamaction=attach scell=0')
exec('ue_testmode_set_nr id=81-120 testmode=beam_control action=activate profile_id=3 beamaction=attach scell=0')
exec('ue_testmode_set_nr id=121-160 testmode=beam_control action=activate profile_id=4 beamaction=attach scell=0')
exec('ue_testmode_set_nr id=161-200 testmode=beam_control action=activate profile_id=5 beamaction=attach scell=0')
exec('ue_testmode_set_nr id=201-240 testmode=beam_control action=activate profile_id=6 beamaction=attach scell=0')
sleep(1)
exec('seq_start rate=1 id=47-52 detailed_print=on duration=60  max_active_ues=40')
sleep(65)
exec('ue_summary')
sleep(1)
exec('ue_stats_nr id=1-240 scell=0 type=pusch')
print("PET_1070FF_BF_240UE_UL_GBR_Bearers script completed")
end

----------------------------------------------------------------
--FDD PET RELEASE TEST CASES COMMANDS
----------------------------------------------------------------
function FDD_PET_REL_12CELL_START_TC1()
-- Start SA Max UEs Registration on 12cells
    require "multi_ue_sa_script_new"
    exec('uec_l2_testmode_params fixed_csi_report=true')
    sleep(1)
    exec('sim_debug_log level=1 gate=1')
	sleep(1)
    set_multi_amf_to_register_multiue(1,5,"311:489",1,18000)
    sleep(10)
    exec('seq_start rate=1 id=1-12 detailed_print=on duration=810 max_active_ues=750')
    sleep(820)
    sleep(10)
    print("FDD_PET_REL_12CELL_START_TC1 script completed")
    exec('ue_summary')
end

function FDD_PET_REL_12CELL_START_TC3()
-- Start SA Max UEs Registration on single cell
    require "multi_ue_sa_script_new"
    exec('uec_l2_testmode_params fixed_csi_report=true')
    sleep(1)
    exec('sim_debug_log level=1 gate=1')
	sleep(1)
    set_multi_amf_to_register_multiue(1,5,"311:489",1,18000)
    sleep(10)
    exec('seq_start rate=1 id=1 detailed_print=on duration=1900 max_active_ues=1500')
    sleep(1950)
    exec('ue_disp state=ACTIVE format=long')
    sleep(10)
    print("FDD_PET_REL_12CELL_START_TC3 script completed")
    exec('ue_summary')
end

function FDD_PET_REL_18CELL_START_TC5A()
-- Start SA SUE Registration with Peak DL Tput on 18cells
    require "multi_ue_sa_script_new"
    exec('uec_l2_testmode_params fixed_csi_report=true')
    sleep(1)
    exec('sim_debug_log level=1 gate=1')
	sleep(1)
	set_multi_amf_to_register_multiue(1,5,"311:489",1,18)
    sleep(10)
    exec('seq_start rate=1 id=19-36 detailed_print=on duration=100 max_active_ues=1')
    sleep(105)
    exec('ue_disp state=ACTIVE format=long')
    sleep(10)
    exec('ue_summary')
end

function FDD_PET_REL_18CELL_START_TC5B()
-- Start SA SUE Registration with Peak UL Tput on 18cells
    require "multi_ue_sa_script_new"
    exec('uec_l2_testmode_params fixed_csi_report=true')
    sleep(1)
    exec('sim_debug_log level=1 gate=1')
	sleep(1)
	set_multi_amf_to_register_multiue(1,5,"311:489",1,18)
    sleep(10)
    exec('seq_start rate=1 id=37-54 detailed_print=on duration=100 max_active_ues=1')
    sleep(105)
    exec('ue_disp state=ACTIVE format=long')
    sleep(10)
    exec('ue_summary')
end

function FDD_PET_REL_18CELL_START_TC8()
-- Start SA Multi-UEs Registration with Peak DL+UL Tput on (Half-ABIO) 9cells
    require "multi_ue_sa_script_new"
    exec('uec_l2_testmode_params fixed_csi_report=true')
    sleep(1)
    exec('sim_debug_log level=1 gate=1')
	sleep(1)
	set_multi_amf_to_register_multiue(1,5,"311:489",1,1296)
    sleep(10)
    exec('seq_start rate=1 id=55-57,61-66 detailed_print=on duration=100 max_active_ues=72')
    sleep(105)
    exec('ue_disp state=ACTIVE format=long')
    sleep(10)
    exec('ue_summary')
end

function FDD_PET_REL_12CELL_START_TC9()
-- Start SA MUE VoNR Registration on 12cells
    require "multi_ue_sa_script_new"
    exec('uec_l2_testmode_params fixed_csi_report=true')
    sleep(1)
    exec('sim_debug_log level=1 gate=1')
    sleep(1)
--    set_multi_amf_to_register_multiue(1,5,"311:489",1,9000)
    set_multi_amf_to_register_multiue(1,5,"311:489",1,2880)
    sleep(5)
--  for loop=1, 3 do
--      print("Iteration-"..loop.." Started")
--       exec('seq_start rate=1 id=1-12 detailed_print=on duration=300 max_active_ues=240')
       exec('seq_start rate=1 id=1-12 detailed_print=on duration=300 max_active_ues=200')
--     exec('ue_summary')
--     exec('sleep 14700')
       exec('sleep 310')
       exec('ue_summary')
--  end
    print("FDD_PET_REL_12CELL_START_TC9 script completed")
end

function FDD_PET_REL_12CELL_START_TC13()
-- Start SA MUE Registration with Peak DL+UL on 12cells
    require "multi_ue_sa_script_new"
    exec('uec_l2_testmode_params fixed_csi_report=true')
    sleep(1)
    exec('sim_debug_log level=1 gate=1')
	sleep(1)
    set_multi_amf_to_register_multiue(1,5,"311:489",1,18000)
    sleep(10)
    exec('seq_start rate=1 id=37-48 detailed_print=on duration=100 max_active_ues=4')
    sleep(105)
    exec('ue_disp state=ACTIVE format=long')
    sleep(10)
    print("FDD_PET_REL_12CELL_START_TC13 script completed")
    exec('ue_summary')
end

function FDD_PET_REL_24CELL_START_TC6()
-- Start SA SUE Peak DL+UL on 24cells
    require "multi_ue_sa_script_new"
    exec('uec_l2_testmode_params fixed_csi_report=true')
    sleep(1)
    exec('sim_debug_log level=1 gate=1')
    sleep(1)
    set_multi_amf_to_register_multiue(1,5,"311:489",1,9000)
    sleep(10)
    exec('seq_start rate=1 id=25-36 detailed_print=on duration=100 max_active_ues=1')
    sleep(110)
    exec('seq_start rate=1 id=37-48 detailed_print=on duration=100 max_active_ues=1')
    sleep(110)
    print("FDD_PET_REL_24CELL_START_TC6 script completed")
    exec('ue_summary')
end

function FDD_PET_REL_24CELL_START_TC2()
-- Start SA Max UEs Registration on 24cells
    require "multi_ue_sa_script_new"
    exec('uec_l2_testmode_params fixed_csi_report=true')
    sleep(1)
    exec('sim_debug_log level=1 gate=1')
    sleep(1)
    set_multi_amf_to_register_multiue(1,5,"311:489",1,9000)
    sleep(10)
    exec('seq_start rate=1 id=1,3,5,7,9,11,13,15,17,19,21,23 detailed_print=on duration=450 max_active_ues=375')
    sleep(460)
    exec('seq_start rate=1 id=2,4,6,8,10,12,14,16,18,20,22,24 detailed_print=on duration=450 max_active_ues=375')
    sleep(460)
    print("FDD_PET_REL_24CELL_START_TC2 script completed")
    exec('ue_summary')
end

function FDD_PET_REL_12CELL_START_TC7()
-- Start SA 72UEs Peak UL + DL Tput on LOKI-A & B cell
    require "multi_ue_sa_script_new"
    exec('uec_l2_testmode_params fixed_csi_report=true')
    sleep(1)
    exec('sim_debug_log level=1 gate=1')
    sleep(1)
    set_multi_amf_to_register_multiue(1,5,"311:489",1,18000)
--    set_multi_amf_to_register_multiue(1,5,"311:489",1,864)
    sleep(10)
--    exec('seq_start rate=1 id=1,7 detailed_print=on duration=100 max_active_ues=72')
    exec('seq_start rate=1 id=49,55 detailed_print=on duration=100 max_active_ues=72')
    sleep(130)
    exec('ue_disp state=IDLE format=long')
    sleep(5)
    print("FDD_PET_REL_12CELL_START_TC7 script completed")
    exec('ue_summary')
end

function PET_1070FF_nonBF_48UE_DLUL()
require "multi_ue_sa_script_new"
exec('uec_l2_testmode_params fixed_csi_report=true')
sleep(1)
set_amf_to_register_multiue(1,5,"311:489",48)
sleep(1)
exec('seq_start rate=1 id=51-56 detailed_print=on duration=15  max_active_ues=8')
sleep(40)
exec('ue_summary')
sleep(1)
exec('ue_stats_nr id=1-48 scell=0 type=pdsch')
sleep(1)
exec('ue_stats_nr id=1-48 scell=0 type=pusch')
print("PET_1070FF_nonBF_48UE_DLUL script completed")
end

function PET_1070FF_BF_48UE_DLUL()
require "multi_ue_sa_script_new"
exec('uec_l2_testmode_params fixed_csi_report=true')
sleep(2)
set_multi_amf_to_register_multiue(1,5,"311:489",1,48)
sleep(2)
exec('beam_control_testmode_nr profile_id=1 ueBeamIndexInitial=0,1,2,3,4,5 ssbeam_bestbeam=0 ssbeam_rsrp_best=-44 ssbeam_rsrp_avg=-50')
exec('beam_control_testmode_nr profile_id=2 ueBeamIndexInitial=1,0,2,3,4,5 ssbeam_bestbeam=1 ssbeam_rsrp_best=-45 ssbeam_rsrp_avg=-120')
exec('beam_control_testmode_nr profile_id=3 ueBeamIndexInitial=2,0,1,3,4,5 ssbeam_bestbeam=2 ssbeam_rsrp_best=-50 ssbeam_rsrp_avg=-125')
exec('beam_control_testmode_nr profile_id=4 ueBeamIndexInitial=3,0,1,2,4,5 ssbeam_bestbeam=3 ssbeam_rsrp_best=-55 ssbeam_rsrp_avg=-120')
exec('beam_control_testmode_nr profile_id=5 ueBeamIndexInitial=4,0,1,2,3,5 ssbeam_bestbeam=4 ssbeam_rsrp_best=-60 ssbeam_rsrp_avg=-139')
exec('beam_control_testmode_nr profile_id=6 ueBeamIndexInitial=5,0,1,2,3,4 ssbeam_bestbeam=5 ssbeam_rsrp_best=-65 ssbeam_rsrp_avg=-70')
exec('ue_testmode_set_nr id=1-8 testmode=beam_control action=activate profile_id=1 beamaction=attach scell=0')
exec('ue_testmode_set_nr id=9-16 testmode=beam_control action=activate profile_id=2 beamaction=attach scell=0')
exec('ue_testmode_set_nr id=17-24 testmode=beam_control action=activate profile_id=3 beamaction=attach scell=0')
exec('ue_testmode_set_nr id=25-32 testmode=beam_control action=activate profile_id=4 beamaction=attach scell=0')
exec('ue_testmode_set_nr id=33-40 testmode=beam_control action=activate profile_id=5 beamaction=attach scell=0')
exec('ue_testmode_set_nr id=41-48 testmode=beam_control action=activate profile_id=6 beamaction=attach scell=0')
sleep(1)
set_amf_to_register_multiue(1,5,"311:489",48)
sleep(1)
exec('seq_start rate=1 id=51-56 detailed_print=on duration=12  max_active_ues=8')
sleep(20)
exec('ue_summary')
sleep(1)
exec('ue_stats_nr id=1-48 scell=0 type=pdsch')
sleep(1)
exec('ue_stats_nr id=1-48 scell=0 type=pusch')
print("PET_1070FF_BF_48UE_DLUL script completed")
end

function PET_BF_VoNR_CDRX_Enabled()
require "multi_ue_sa_script_new"
exec('uec_l2_testmode_params fixed_csi_report=true')
sleep(1)
exec('beam_control_testmode_nr profile_id=1 ueBeamIndexInitial=0,1,2,3,4,5 ssbeam_bestbeam=0 ssbeam_rsrp_best=-44 ssbeam_rsrp_avg=-50')
exec('beam_control_testmode_nr profile_id=2 ueBeamIndexInitial=1,0,2,3,4,5 ssbeam_bestbeam=1 ssbeam_rsrp_best=-45 ssbeam_rsrp_avg=-120')
exec('beam_control_testmode_nr profile_id=3 ueBeamIndexInitial=2,0,1,3,4,5 ssbeam_bestbeam=2 ssbeam_rsrp_best=-50 ssbeam_rsrp_avg=-125')
exec('beam_control_testmode_nr profile_id=4 ueBeamIndexInitial=3,0,1,2,4,5 ssbeam_bestbeam=3 ssbeam_rsrp_best=-55 ssbeam_rsrp_avg=-120')
exec('beam_control_testmode_nr profile_id=5 ueBeamIndexInitial=4,0,1,2,3,5 ssbeam_bestbeam=4 ssbeam_rsrp_best=-60 ssbeam_rsrp_avg=-139')
exec('beam_control_testmode_nr profile_id=6 ueBeamIndexInitial=5,0,1,2,3,4 ssbeam_bestbeam=5 ssbeam_rsrp_best=-65 ssbeam_rsrp_avg=-70')
exec('ue_testmode_set_nr id=1-138 testmode=beam_control action=activate profile_id=1 beamaction=attach scell=0')
exec('ue_testmode_set_nr id=139-276 testmode=beam_control action=activate profile_id=2 beamaction=attach scell=0')
exec('ue_testmode_set_nr id=277-414 testmode=beam_control action=activate profile_id=3 beamaction=attach scell=0')
exec('ue_testmode_set_nr id=415-552 testmode=beam_control action=activate profile_id=4 beamaction=attach scell=0')
exec('ue_testmode_set_nr id=553-690 testmode=beam_control action=activate profile_id=5 beamaction=attach scell=0')
exec('ue_testmode_set_nr id=691-828 testmode=beam_control action=activate profile_id=6 beamaction=attach scell=0')
sleep(1)
set_amf_to_register_multiue(1,5,"311:489",828)
sleep(3)
exec('seq_start rate=1 id=1-6 detailed_print=on duration=200  max_active_ues=138')
sleep(160)
exec('ue_summary')
print("PET_BF_VoNR_CDRX_Enabled script completed")
end

function PET_1070FF_BF_9000UE_DLUL_rate1dot5()
require "multi_ue_sa_script_new"
exec('uec_l2_testmode_params fixed_csi_report=true')
sleep(1)
set_amf_to_register_multiue(1,5,"311:489",9000)
sleep(5)
exec('beam_control_testmode_nr profile_id=1 ueBeamIndexInitial=0,1,2,3,4,5 ssbeam_bestbeam=0 ssbeam_rsrp_best=-44 ssbeam_rsrp_avg=-50')
exec('beam_control_testmode_nr profile_id=2 ueBeamIndexInitial=1,0,2,3,4,5 ssbeam_bestbeam=1 ssbeam_rsrp_best=-45 ssbeam_rsrp_avg=-120')
exec('beam_control_testmode_nr profile_id=3 ueBeamIndexInitial=2,0,1,3,4,5 ssbeam_bestbeam=2 ssbeam_rsrp_best=-50 ssbeam_rsrp_avg=-125')
exec('beam_control_testmode_nr profile_id=4 ueBeamIndexInitial=3,0,1,2,4,5 ssbeam_bestbeam=3 ssbeam_rsrp_best=-55 ssbeam_rsrp_avg=-120')
exec('beam_control_testmode_nr profile_id=5 ueBeamIndexInitial=4,0,1,2,3,5 ssbeam_bestbeam=4 ssbeam_rsrp_best=-60 ssbeam_rsrp_avg=-139')
exec('beam_control_testmode_nr profile_id=6 ueBeamIndexInitial=5,0,1,2,3,4 ssbeam_bestbeam=5 ssbeam_rsrp_best=-65 ssbeam_rsrp_avg=-70')
exec('ue_testmode_set_nr id=1-1500 testmode=beam_control action=activate profile_id=1 beamaction=attach scell=0')
exec('ue_testmode_set_nr id=1501-3000 testmode=beam_control action=activate profile_id=2 beamaction=attach scell=0')
exec('ue_testmode_set_nr id=3001-4500 testmode=beam_control action=activate profile_id=3 beamaction=attach scell=0')
exec('ue_testmode_set_nr id=4501-6000 testmode=beam_control action=activate profile_id=4 beamaction=attach scell=0')
exec('ue_testmode_set_nr id=6001-7500 testmode=beam_control action=activate profile_id=5 beamaction=attach scell=0')
exec('ue_testmode_set_nr id=7501-9000 testmode=beam_control action=activate profile_id=6 beamaction=attach scell=0')
sleep(2)
exec('seq_start rate=1.5 id=1-6 detailed_print=on duration=1550 max_active_ues=1500')
sleep(1600)
exec('ue_summary')
print("PET_1070FF_BF_9000UE_DLUL_rate1dot5 script completed")
end

function FDD_PET_REL_24CELL_START_TC16()
-- Start SA 72UE Peak DL+UL on Loki-A & B 2cells with 24cells configuration
    require "multi_ue_sa_script_new"
    exec('uec_l2_testmode_params fixed_csi_report=true')
    sleep(1)
    exec('sim_debug_log level=1 gate=1')
    sleep(1)
    set_multi_amf_to_register_multiue(1,5,"311:489",1,9000)
    sleep(10)
    exec('seq_start rate=1 id=49,61 detailed_print=on duration=100 max_active_ues=72')
    sleep(110)
    print("FDD_PET_REL_24CELL_START_TC16 script completed")
    exec('ue_summary')
end

function PET_1116_0msFF_8701_9007_MUMIMO_SRSBF_4UE_DL()
    require "multi_ue_sa_script_new"
    exec('uec_l2_testmode_params fixed_csi_report=true')
    exec('ul_mimo_srs_beam_pos_nr profile_id=1 mode=fixed test_type=SRS init_quad_pos=0 init_sub_quad_pos=0') 
    exec('ul_mimo_srs_beam_pos_nr profile_id=2 mode=fixed test_type=SRS init_quad_pos=1 init_sub_quad_pos=3') 
    exec('ul_mimo_srs_beam_pos_nr profile_id=3 mode=fixed test_type=SRS init_quad_pos=2 init_sub_quad_pos=1') 
    exec('ul_mimo_srs_beam_pos_nr profile_id=4 mode=fixed test_type=SRS init_quad_pos=3 init_sub_quad_pos=2')
    exec('ue_testmode_set_nr id=1  testmode=ul_mimo_srs_beam_pos action=activate profile_id=1')
    exec('ue_testmode_set_nr id=2  testmode=ul_mimo_srs_beam_pos action=activate profile_id=2')
    exec('ue_testmode_set_nr id=3 testmode=ul_mimo_srs_beam_pos action=activate profile_id=3')
    exec('ue_testmode_set_nr id=4 testmode=ul_mimo_srs_beam_pos action=activate profile_id=4')
    sleep(1)
    set_amf_to_register_multiue(1,5,"311:489",4)
    sleep(5)
    exec('seq_start rate=1 id=41 detailed_print=on duration=6 max_active_ues=4')
    sleep(10)
    exec('ue_summary')
    exec('ue_stats_nr id=1-4 scell=0 type=pdsch')
    print("PET_1116_0msFF_8701_9007_MUMIMO_SRSBF_4UE_DL script completed")
end

function PET_1116_0msFF_8701_9007_MUMIMO_SRSBF_72UE_DL()
    require "multi_ue_sa_script_new"
    exec('uec_l2_testmode_params fixed_csi_report=true')
    exec('ul_mimo_srs_beam_pos_nr profile_id=1 mode=fixed test_type=SRS init_quad_pos=0 init_sub_quad_pos=0') 
    exec('ul_mimo_srs_beam_pos_nr profile_id=2 mode=fixed test_type=SRS init_quad_pos=1 init_sub_quad_pos=3') 
    exec('ul_mimo_srs_beam_pos_nr profile_id=3 mode=fixed test_type=SRS init_quad_pos=2 init_sub_quad_pos=1') 
    exec('ul_mimo_srs_beam_pos_nr profile_id=4 mode=fixed test_type=SRS init_quad_pos=3 init_sub_quad_pos=2')
    exec('ue_testmode_set_nr id=1-18  testmode=ul_mimo_srs_beam_pos action=activate profile_id=1')
    exec('ue_testmode_set_nr id=19-37  testmode=ul_mimo_srs_beam_pos action=activate profile_id=2')
    exec('ue_testmode_set_nr id=38-56 testmode=ul_mimo_srs_beam_pos action=activate profile_id=3')
    exec('ue_testmode_set_nr id=57-72 testmode=ul_mimo_srs_beam_pos action=activate profile_id=4')
    sleep(1)
    set_amf_to_register_multiue(1,5,"311:489",72)
    sleep(5)
    exec('seq_start rate=1 id=1 detailed_print=on duration=80 max_active_ues=72')
    sleep(90)
    exec('ue_summary')
    exec('ue_stats_nr id=1-72 scell=0 type=pdsch')
    print("PET_1116_0msFF_8701_9007_MUMIMO_SRSBF_72UE_DL script completed")
end

function PET_BF_VoNR_CDRX_Disabled()
    require "multi_ue_sa_script_new"
    exec('uec_l2_testmode_params fixed_csi_report=true')
    sleep(1)
    exec('beam_control_testmode_nr profile_id=1 ueBeamIndexInitial=0,1,2,3,4,5 ssbeam_bestbeam=0 ssbeam_rsrp_best=-44 ssbeam_rsrp_avg=-50')
    exec('beam_control_testmode_nr profile_id=2 ueBeamIndexInitial=1,0,2,3,4,5 ssbeam_bestbeam=1 ssbeam_rsrp_best=-45 ssbeam_rsrp_avg=-120')
    exec('beam_control_testmode_nr profile_id=3 ueBeamIndexInitial=2,0,1,3,4,5 ssbeam_bestbeam=2 ssbeam_rsrp_best=-50 ssbeam_rsrp_avg=-125')
    exec('beam_control_testmode_nr profile_id=4 ueBeamIndexInitial=3,0,1,2,4,5 ssbeam_bestbeam=3 ssbeam_rsrp_best=-55 ssbeam_rsrp_avg=-120')
    exec('beam_control_testmode_nr profile_id=5 ueBeamIndexInitial=4,0,1,2,3,5 ssbeam_bestbeam=4 ssbeam_rsrp_best=-60 ssbeam_rsrp_avg=-139')
    exec('beam_control_testmode_nr profile_id=6 ueBeamIndexInitial=5,0,1,2,3,4 ssbeam_bestbeam=5 ssbeam_rsrp_best=-65 ssbeam_rsrp_avg=-70')
    exec('ue_testmode_set_nr id=1-276 testmode=beam_control action=activate profile_id=1 beamaction=attach scell=0')
    exec('ue_testmode_set_nr id=277-552 testmode=beam_control action=activate profile_id=2 beamaction=attach scell=0')
    exec('ue_testmode_set_nr id=553-828 testmode=beam_control action=activate profile_id=3 beamaction=attach scell=0')
    exec('ue_testmode_set_nr id=829-1104 testmode=beam_control action=activate profile_id=4 beamaction=attach scell=0')
    exec('ue_testmode_set_nr id=1105-1380 testmode=beam_control action=activate profile_id=5 beamaction=attach scell=0')
    exec('ue_testmode_set_nr id=1381-1656 testmode=beam_control action=activate profile_id=6 beamaction=attach scell=0')
    sleep(1)
    set_amf_to_register_multiue(1,5,"311:489",1656)
    sleep(5)
    exec('seq_start rate=1 id=1-6 detailed_print=on duration=350  max_active_ues=276')
    sleep(320)
    exec('ue_summary')
    print("PET_BF_VoNR_CDRX_Disabled script completed")
end

function PET_8406FF_nonBF_432UE_UL()
    require "multi_ue_sa_script_new"
    exec('uec_l2_testmode_params fixed_csi_report=true')
    sleep(1)
    set_amf_to_register_multiue(1,5,"311:489",432)
    sleep(1)
    exec('seq_start rate=1 id=40-45 detailed_print=on duration=90  max_active_ues=72')
    sleep(100)
    exec('ue_summary')
    sleep(1)
    exec('ue_stats_nr id=1-72 scell=0 type=pusch')
    print("PET_8406FF_nonBF_432UE_UL script completed")
end

function PET_1070FF_MUMIMO_SRSBF_4UE_UL()
    require "multi_ue_sa_script_new"
    exec('uec_l2_testmode_params fixed_csi_report=true')
    sleep(1)
    set_amf_to_register_multiue(1,5,"311:489",4)
    sleep(5)
    exec('seq_start rate=1 id=3 detailed_print=on duration=6 max_active_ues=4')
    sleep(10)
    exec('ul_mimo_srs_beam_pos_nr profile_id=1 mode=fixed init_quad_pos=0 init_sub_quad_pos=0 test_type=UL_MIMO') 
    exec('ul_mimo_srs_beam_pos_nr profile_id=2 mode=fixed init_quad_pos=2 init_sub_quad_pos=3 test_type=UL_MIMO') 
    exec('ul_mimo_srs_beam_pos_nr profile_id=3 mode=fixed init_quad_pos=3 init_sub_quad_pos=1 test_type=UL_MIMO') 
    exec('ul_mimo_srs_beam_pos_nr profile_id=4 mode=fixed init_quad_pos=1 init_sub_quad_pos=1 test_type=UL_MIMO') 
    exec('ue_testmode_set_nr id=1 testmode=ul_mimo_srs_beam_pos action=activate profile_id=1') 
    exec('ue_testmode_set_nr id=2 testmode=ul_mimo_srs_beam_pos action=activate profile_id=2') 
    exec('ue_testmode_set_nr id=3 testmode=ul_mimo_srs_beam_pos action=activate profile_id=3') 
    exec('ue_testmode_set_nr id=4 testmode=ul_mimo_srs_beam_pos action=activate profile_id=4') 
    exec('ue_summary')
    exec('ue_stats_nr id=1-4 scell=0 type=pusch')
    print("PET_1070FF_MUMIMO_SRSBF_4UE_UL script completed")
end

function FDD_PET_REL_24CELL_START_TC6_DL()
-- Start SA SUE Peak DL+UL on 24cells
    require "multi_ue_sa_script_new"
    exec('uec_l2_testmode_params fixed_csi_report=true')
    sleep(1)
    exec('sim_debug_log level=1 gate=1')
    sleep(1)
    set_multi_amf_to_register_multiue(1,5,"311:489",1,9000)
    sleep(10)
    exec('seq_start rate=1 id=25-36 detailed_print=on duration=10 max_active_ues=1')
    sleep(11)
    exec('seq_start rate=1 id=37-48 detailed_print=on duration=10 max_active_ues=1')
    sleep(11)
    print("FDD_PET_REL_24CELL_START_TC6_DL script completed")
    exec('ue_summary')
end

function FDD_PET_REL_24CELL_START_TC6_UL()
-- Start SA SUE Peak DL+UL on 24cells
    require "multi_ue_sa_script_new"
    exec('uec_l2_testmode_params fixed_csi_report=true')
    sleep(1)
    exec('sim_debug_log level=1 gate=1')
    sleep(1)
    set_multi_amf_to_register_multiue(1,5,"311:489",1,9000)
    sleep(10)
    exec('seq_start rate=1 id=49-60 detailed_print=on duration=10 max_active_ues=1')
    sleep(11)
    exec('seq_start rate=1 id=61-72 detailed_print=on duration=10 max_active_ues=1')
    sleep(11)
    print("FDD_PET_REL_24CELL_START_TC6_UL script completed")
    exec('ue_summary')
end

function TDD_FDD_NONDSS_NONBF_6CELL_START_TC5()
-- Start T+F 25MHz SA 72UE Peak DL Tput [slowprbpooling=false]
    require "multi_ue_sa_script_new"
    exec('uec_l2_testmode_params fixed_csi_report=true')
    sleep(1)
    exec('sim_debug_log level=1 gate=1')
    sleep(1)
    set_multi_amf_to_register_multiue(1,5,"311:489",1,9000)
    sleep(5)
    exec('seq_start rate=1 id=7-12 detailed_print=on duration=100 max_active_ues=72')
    sleep(105)
    exec('ue_summary')
    print("TDD_FDD_NONDSS_NONBF_6CELL_START_TC5 script completed")
end

function TDD_FDD_NONDSS_NONBF_6CELL_START_TC7()
-- Start T+F 25MHz SA 72UE Peak UL Tput
    require "multi_ue_sa_script_new"
    exec('uec_l2_testmode_params fixed_csi_report=true')
    sleep(1)
    exec('sim_debug_log level=1 gate=1')
    sleep(1)
    set_multi_amf_to_register_multiue(1,5,"311:489",1,9000)
    sleep(5)
    exec('seq_start rate=1 id=13-18 detailed_print=on duration=100 max_active_ues=72')
    sleep(105)
    exec('ue_summary')
    print("TDD_FDD_NONDSS_NONBF_6CELL_START_TC7 script completed")
end

function FDD_TDD_NONDSS_UL_CA_2CELL_START_TC3()
-- Start F+T 20MHz+100MHz UL 2CC SA 40UE Peak UL Tput
            require "multi_ue_sa_script_new"
            exec('enb_x2_link_up enb=1 target=2')
            sleep(1)
            exec('uec_l2_testmode_params fixed_csi_report=true')
            sleep(1)
            exec('seq_start rate=1 id=83 detailed_print=on duration=50 max_active_ues=30')
            sleep(55)
            exec('ue_summary')
            print("FDD_TDD_NONDSS_UL_CA_2CELL_START_TC3 script completed")
end

function TDD_FDD_NONDSS_CA_4CELL_START_TC6()
    -- Start T+F 25MHz SA 72UE Peak UL Tput
        require "multi_ue_sa_script_new"
        exec('uec_l2_testmode_params fixed_csi_report=true')
        sleep(1)
        exec('sim_debug_log level=1 gate=1')
        sleep(1)
        set_multi_amf_to_register_multiue(1,5,"311:489",1,480)
        sleep(5)
        exec('seq_start rate=1 id=1 detailed_print=on duration=50 max_active_ues=40')
        sleep(55)
        exec('seq_start rate=1 id=7,15,20,28 detailed_print=on duration=40 max_active_ues=32')
        sleep(55)
        exec('ue_summary')
        print("TDD_FDD_NONDSS_CA_4CELL_START_TC6 script completed")
end

function TDD_FR1_FDD_9677_101_200UE_TC()
-- Start T+F CA 72 UE on CELL3, On 4 SCELLs 32UE
    require "multi_ue_sa_script_new"
    exec('uec_l2_testmode_params fixed_csi_report=true')
    sleep(1)
    exec('seq_start rate=1 id=3 detailed_print=on duration=80 max_active_ues=72')
    sleep(80)
    exec('seq_start rate=1 id=7 detailed_print=on duration=50 max_active_ues=32')
    sleep(40)
    exec('seq_start rate=1 id=14 detailed_print=on duration=50 max_active_ues=32')
    sleep(40)
    exec('seq_start rate=1 id=22 detailed_print=on duration=50 max_active_ues=32')
    sleep(40)
    exec('seq_start rate=1 id=29 detailed_print=on duration=50 max_active_ues=32')
    sleep(40)
    exec('ue_summary')
    sleep(600)
    exec('ue_summary')
    exec('ue_disp state=ACTIVE format=long')
    exec('ue_stats_nr id=1-400 type=pdsch,pusch scell=0-15')
    sleep(3600)
    exec('ue_summary')
    exec('ue_disp state=ACTIVE format=long')
    exec('ue_stats_nr id=1-400 type=pdsch,pusch scell=0-15')
    print("script completed")
end

function CB009855_DL_UL_MU_MIMO_TC()
        require "multi_ue_sa_script_new"
        exec('uec_l2_testmode_params fixed_csi_report=true')
        sleep(1)
        set_multi_amf_to_register_multiue(1,5,"311:489",1,400)
        sleep(5)
        exec('seq_start rate=1 id=3 detailed_print=on duration=80 max_active_ues=72')
        sleep(75)
        exec('ue_stats_nr id=1-400 type=pdsch,pusch scell=0-15')
        sleep(5)
        exec('ul_mimo_srs_beam_pos_nr profile_id=1 mode=fixed init_quad_pos=0 init_sub_quad_pos=0 test_type=UL_MIMO')
        exec('ul_mimo_srs_beam_pos_nr profile_id=2 mode=fixed init_quad_pos=2 init_sub_quad_pos=3 test_type=UL_MIMO')
        exec('ul_mimo_srs_beam_pos_nr profile_id=3 mode=fixed init_quad_pos=3 init_sub_quad_pos=1 test_type=UL_MIMO')
        exec('ul_mimo_srs_beam_pos_nr profile_id=4 mode=fixed init_quad_pos=1 init_sub_quad_pos=1 test_type=UL_MIMO')
        sleep(3)
        exec('ue_testmode_set_nr id=3,23,43,63,83,103,123,143,163,183,203,223,243,263,283,303,323,343 testmode=ul_mimo_srs_beam_pos action=activate profile_id=1')
        sleep(3)
        exec('ue_testmode_set_nr id=8,28,48,68,88,108,128,148,168,188,208,228,248,268,288,308,328,348 testmode=ul_mimo_srs_beam_pos action=activate profile_id=2')
        sleep(3)
        exec('ue_testmode_set_nr id=13,33,53,73,93,113,133,153,173,193,213,233,253,273,293,313,333,353 testmode=ul_mimo_srs_beam_pos action=activate profile_id=3')
        sleep(3)
        exec('ue_testmode_set_nr id=18,38,58,78,98,118,138,158,178,198,218,238,258,278,298,318,338,358,363 testmode=ul_mimo_srs_beam_pos action=activate profile_id=4')
        sleep(35)
        exec('ue_stats_nr id=1-400 type=pdsch,pusch scell=0-15')
        exec('seq_start rate=1 id=7 detailed_print=on duration=50 max_active_ues=32')
        sleep(40)
        exec('seq_start rate=1 id=14 detailed_print=on duration=50 max_active_ues=32')
        sleep(40)
        exec('seq_start rate=1 id=22 detailed_print=on duration=50 max_active_ues=32')
        sleep(40)
        exec('seq_start rate=1 id=29 detailed_print=on duration=50 max_active_ues=32')
        sleep(40)
        exec('ue_summary')
        sleep(5)
        exec('ue_stats_nr id=1-400 type=pdsch,pusch scell=0-15')
        exec('ue_summary')
        print("script completed")
end

function CB009363_UL_MU_MIMO_TC()
        require "multi_ue_sa_script_new"
        exec('uec_l2_testmode_params fixed_csi_report=true')
        sleep(1)
        set_multi_amf_to_register_multiue(1,5,"311:489",1,400)
        sleep(5)
        exec('seq_start rate=1 id=1,2,3 detailed_print=on duration=6 max_active_ues=4')
        sleep(75)
        exec('ue_stats_nr id=1-400 type=pdsch,pusch scell=0-15')
        sleep(5)
        exec('ul_mimo_srs_beam_pos_nr profile_id=1 mode=fixed init_quad_pos=0 init_sub_quad_pos=0 test_type=UL_MIMO')
        exec('ul_mimo_srs_beam_pos_nr profile_id=2 mode=fixed init_quad_pos=2 init_sub_quad_pos=3 test_type=UL_MIMO')
        exec('ul_mimo_srs_beam_pos_nr profile_id=3 mode=fixed init_quad_pos=3 init_sub_quad_pos=1 test_type=UL_MIMO')
        exec('ul_mimo_srs_beam_pos_nr profile_id=4 mode=fixed init_quad_pos=1 init_sub_quad_pos=1 test_type=UL_MIMO')
        sleep(3)
        exec('ue_testmode_set_nr id=3 testmode=ul_mimo_srs_beam_pos action=activate profile_id=1')
        sleep(3)
        exec('ue_testmode_set_nr id=6 testmode=ul_mimo_srs_beam_pos action=activate profile_id=2')
        sleep(3)
        exec('ue_testmode_set_nr id=9 testmode=ul_mimo_srs_beam_pos action=activate profile_id=3')
        sleep(3)
        exec('ue_testmode_set_nr id=12 testmode=ul_mimo_srs_beam_pos action=activate profile_id=4')
        sleep(35)
        exec('ue_stats_nr id=1-400 type=pdsch,pusch scell=0-15')
       -- exec('seq_start rate=1 id=3 detailed_print=on duration=5 max_active_ues=20')
        sleep(40)
        exec('ue_summary')
        sleep(5)
        exec('ue_stats_nr id=1-400 type=pdsch,pusch scell=0-15')
        exec('ue_summary')
        print("script completed")
end

function CB009363_UL_MU_MIMO_2UEs_TC()
        require "multi_ue_sa_script_new"
        exec('uec_l2_testmode_params fixed_csi_report=true')
        sleep(1)
        set_multi_amf_to_register_multiue(1,5,"311:489",1,400)
        sleep(5)
        exec('seq_start rate=1 id=1,2,3 detailed_print=on duration=80 max_active_ues=2')
        sleep(75)
        exec('ue_stats_nr id=1-400 type=pdsch,pusch scell=0-15')
        sleep(5)
        exec('ul_mimo_srs_beam_pos_nr profile_id=1 mode=fixed init_quad_pos=0 init_sub_quad_pos=0 test_type=UL_MIMO multi_path_config=true num_of_nlos_paths=1 azimuth=-45 zenith=0')
        exec('ul_mimo_srs_beam_pos_nr profile_id=2 mode=fixed init_quad_pos=2 init_sub_quad_pos=3 test_type=UL_MIMO multi_path_config=true num_of_nlos_paths=1 azimuth=-45 zenith=0')
        exec('ul_mimo_srs_beam_pos_nr profile_id=3 mode=fixed init_quad_pos=3 init_sub_quad_pos=1 test_type=UL_MIMO multi_path_config=true num_of_nlos_paths=1 azimuth=-45 zenith=0')
        exec('ul_mimo_srs_beam_pos_nr profile_id=4 mode=fixed init_quad_pos=1 init_sub_quad_pos=1 test_type=UL_MIMO multi_path_config=true num_of_nlos_paths=1 azimuth=-45 zenith=0')
        sleep(3)
        exec('ue_testmode_set_nr id=3,15,27,39,51,73,85,97,109,121,133,145,157,169,181,193,205,217 testmode=ul_mimo_srs_beam_pos action=activate profile_id=1')
        sleep(3)
        exec('ue_testmode_set_nr id=6,18,30,42,54,66,78,90,102,114,126,138,150,162,174,186,198,210 testmode=ul_mimo_srs_beam_pos action=activate profile_id=2')
        sleep(3)
        exec('ue_testmode_set_nr id=9,21,33,45,57,69,81,93,105,117,129,141,153,165,177,189,201,213 testmode=ul_mimo_srs_beam_pos action=activate profile_id=3')
        sleep(3)
        exec('ue_testmode_set_nr id=12,24,36,48,60,72,84,96,108,120,132,146,158,170,182,194,206,218,230 testmode=ul_mimo_srs_beam_pos action=activate profile_id=4')
        sleep(35)
        exec('ue_stats_nr id=1-400 type=pdsch,pusch scell=0-15')
    --    exec('seq_start rate=1 id=3 detailed_print=on duration=50 max_active_ues=32')
     --   sleep(40)
      --  exec('seq_start rate=1 id=6 detailed_print=on duration=50 max_active_ues=32')
   --     sleep(40)
     --   exec('seq_start rate=1 id=9 detailed_print=on duration=50 max_active_ues=32')
  --      sleep(40)
   --     exec('seq_start rate=1 id=12 detailed_print=on duration=50 max_active_ues=32')
    --    sleep(40)
        exec('ue_summary')
        sleep(5)
        exec('ue_stats_nr id=1-400 type=pdsch,pusch scell=0-15')
        exec('ue_summary')
        print("CB009363_UL_MU_MIMO_2UEs_TC script completed")
end

