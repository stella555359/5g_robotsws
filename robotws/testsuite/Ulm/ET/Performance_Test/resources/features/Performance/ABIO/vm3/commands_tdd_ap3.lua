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

function PET_1208FF_nonBF_100UE_DL()
require "multi_ue_sa_script_new"
exec('uec_l2_testmode_params fixed_csi_report=true')
sleep(2)
set_multi_amf_to_register_multiue(1,5,"311:489",1,600)
sleep(1)
exec('seq_start rate=1 id=1-6 detailed_print=on duration=200  max_active_ues=100')
sleep(90)
exec('ue_summary')
sleep(1)
exec('ue_stats_nr id=1-100 scell=0 type=pdsch')
print("PET_1208FF_nonBF_100UE_DL script completed")
end

function PET_1208FF_nonBF_4UE_DLUL()
require "multi_ue_sa_script_new"
exec('uec_l2_testmode_params fixed_csi_report=true')
sleep(2)
set_multi_amf_to_register_multiue(1,5,"311:489",1,600)
sleep(1)
exec('seq_start rate=1 id=1-6 detailed_print=on duration=200  max_active_ues=4')
sleep(90)
exec('ue_summary')
sleep(1)
exec('ue_stats_nr id=1-4 scell=0 type=pdsch')
exec('ue_stats_nr id=1-4 scell=0 type=pusch')
print("PET_1208FF_nonBF_4UE_DLUL script completed")
end

function PET_1208FF_nonBF_100UE_UL()
require "multi_ue_sa_script_new"
exec('uec_l2_testmode_params fixed_csi_report=true')
sleep(1)
set_multi_amf_to_register_multiue(1,5,"311:489",1,600)
sleep(1)
exec('seq_start rate=1 id=1-6 detailed_print=on duration=200  max_active_ues=100')
sleep(90)
exec('ue_summary')
sleep(1)
exec('ue_stats_nr id=1-100 scell=0 type=pusch')
print("PET_1208FF_nonBF_100UE_UL script completed")
end

function PET_1208FF_nonBF_100UE_UL_100UE_DL()
require "multi_ue_sa_script_new"
exec('uec_l2_testmode_params fixed_csi_report=true')
sleep(2)
set_multi_amf_to_register_multiue(1,5,"311:489",1,600)
sleep(1)
exec('seq_start rate=1 id=1-6 detailed_print=on duration=200  max_active_ues=100')
sleep(200)
exec('ue_summary')
sleep(1)
exec('ue_stats_nr id=1-100 scell=0 type=pusch')
exec('ue_stats_nr id=200-300 scell=0 type=pdsch')
print("PET_1208FF_nonBF_100UE_UL_100UE_DL script completed")
end

function PET_1208FF_nonBF_100UE_DLUL()
require "multi_ue_sa_script_new"
exec('uec_l2_testmode_params fixed_csi_report=true')
sleep(2)
set_multi_amf_to_register_multiue(1,5,"311:489",1,100)
sleep(1)
exec('seq_start rate=1 id=7 detailed_print=on duration=400  max_active_ues=100')
sleep(200)

print("enable SRS")
exec('ul_mimo_srs_beam_pos_nr profile_id=1 mode=fixed init_quad_pos=0 init_sub_quad_pos=0 test_type=UL_MIMO')
exec('ue_testmode_set_nr id=1-100 testmode=ul_mimo_srs_beam_pos action=activate profile_id=1')

exec('ue_summary')
sleep(1)
exec('ue_stats_nr id=1-100 scell=0 type=pusch')
exec('ue_stats_nr id=1-100 scell=0 type=pdsch')
print("PET_1208FF_nonBF_100UE_DLUL script completed")
end


function PET_1208FF_nonBF_100UE_DLUL_orig()
require "multi_ue_sa_script_new"
exec('uec_l2_testmode_params fixed_csi_report=true')
sleep(2)
set_multi_amf_to_register_multiue(1,5,"311:489",1,600)
sleep(1)
exec('seq_start rate=1 id=7-12 detailed_print=on duration=200  max_active_ues=100')
sleep(200)
exec('ue_summary')
sleep(1)
exec('ue_stats_nr id=1-100 scell=0 type=pusch')
exec('ue_stats_nr id=1-100 scell=0 type=pdsch')
print("PET_1208FF_nonBF_100UE_DLUL_orig script completed")
end

function PET_1208FF_nonBF_100UEinCell1_4UEinOtherCell_DLUL()
require "multi_ue_sa_script_new"
exec('uec_l2_testmode_params fixed_csi_report=true')
sleep(2)
set_multi_amf_to_register_multiue(1,5,"311:489",1,600)
sleep(1)
exec('seq_start rate=1 id=13 detailed_print=on duration=200  max_active_ues=100')
sleep(1)
exec('seq_start rate=1 id=14-18 detailed_print=on duration=200  max_active_ues=4')
sleep(200)
exec('ue_summary')
sleep(1)
exec('ue_stats_nr id=1-100 scell=0 type=pusch')
exec('ue_stats_nr id=1-100 scell=0 type=pdsch')
print("PET_1208FF_nonBF_100UEinCell1_4UEinOtherCell_DLUL script completed")
end

function PET_1208FF_BF_100UE_DL()
require "multi_ue_sa_script_new"
exec('uec_l2_testmode_params fixed_csi_report=true')
sleep(2)
set_multi_amf_to_register_multiue(1,5,"311:489",1,100)
sleep(2)
exec('beam_control_testmode_nr profile_id=1 ueBeamIndexInitial=0,1,2,3,4,5 ssbeam_bestbeam=0 ssbeam_rsrp_best=-44 ssbeam_rsrp_avg=-50')
exec('ue_testmode_set_nr id=1-100 testmode=beam_control action=activate profile_id=1 beamaction=attach scell=0')
sleep(1)
exec('seq_start rate=1 id=13 detailed_print=on duration=150  max_active_ues=100')
print("PET_1208FF_BF_100UE_DL script completed")
end

function PET_1208FF_BF_100UE_UL()
require "multi_ue_sa_script_new"
exec('uec_l2_testmode_params fixed_csi_report=true')
sleep(2)
set_multi_amf_to_register_multiue(1,5,"311:489",1,100)
sleep(2)
exec('beam_control_testmode_nr profile_id=1 ueBeamIndexInitial=0,1,2,3,4,5 ssbeam_bestbeam=0 ssbeam_rsrp_best=-44 ssbeam_rsrp_avg=-50')
exec('ue_testmode_set_nr id=1-100 testmode=beam_control action=activate profile_id=1 beamaction=attach scell=0')
sleep(1)
exec('seq_start rate=1 id=19 detailed_print=on duration=150  max_active_ues=100')
print("PET_1208FF_BF_432UE_UL script completed")
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

function PET_1070FF_BF_9000UE_DLUL_rate1dot5(max_active_ues)
if tonumber(max_active_ues) == nil then
    max_active_ues = 1500
end
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
exec('seq_start rate=1.5 id=1-6 detailed_print=on duration=1050 max_active_ues='..max_active_ues)
sleep(1100)
exec('ue_summary')
print("PET_1070FF_BF_9000UE_DLUL_rate1dot5 script completed")
exec("set_log flush")
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

function PET_BF_VoNR_CDRX_Enabled()
require "multi_ue_sa_script_new"
exec('uec_l2_testmode_params fixed_csi_report=true')
sleep(1)
set_amf_to_register_multiue(1,5,"311:489",828)
sleep(3)
exec('seq_start rate=1 id=1-6 detailed_print=on duration=200  max_active_ues=138')
sleep(160)
exec('ue_summary')
print("PET_BF_VoNR_CDRX_Enabled script completed")
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

function PET_1070FF_MUMIMO_SRSBF_1200UE_DLUL()
    require "multi_ue_sa_script_new"
    exec('uec_l2_testmode_params fixed_csi_report=true')
    sleep(1)
    set_multi_amf_to_register_multiue(6,10,"311:489",601,1200)
    sleep(5)
    exec('filter_sim_rfm disable=all')
    sleep(1)
    exec('filter_sim_rfm enable=CSI,ACR,OERR,IERR,VIP')
    sleep(1)
    exec('seq_start rate=1 id=51,52,53 detailed_print=on duration=370 max_active_ues=200')
    sleep(365)
    exec('ul_mimo_srs_beam_pos_nr profile_id=3 mode=fixed init_quad_pos=3 init_sub_quad_pos=1 test_type=UL_MIMO')
    exec('ul_mimo_srs_beam_pos_nr profile_id=4 mode=fixed init_quad_pos=1 init_sub_quad_pos=1 test_type=UL_MIMO')
    exec('ue_testmode_set_nr id=601-900 testmode=ul_mimo_srs_beam_pos action=activate profile_id=3')
    exec('ue_testmode_set_nr id=901-1200 testmode=ul_mimo_srs_beam_pos action=activate profile_id=4')
    sleep(10)
    exec('ue_stats_nr id=601-1200 scell=0 type=pusch')
    exec('filter_sim_rfm enable=all')
    exec('ue_summary')
    print("PET_1070FF_MUMIMO_SRSBF_1200UE_DLUL script completed")
    exec("set_log flush")
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

function PET_1070FF_MUMIMO_SRSBF_2UE_UL()
    require "multi_ue_sa_script_new"
    exec('uec_l2_testmode_params fixed_csi_report=true')
    sleep(1)
    set_amf_to_register_multiue(1,5,"311:489",4)
    sleep(5)
    exec('seq_start rate=1 id=42 detailed_print=on duration=6 max_active_ues=2')
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
    print("PET_1070FF_MUMIMO_SRSBF_2UE_UL script completed")
end

function PET_1070FF_MUMIMO_SRSBF_36UE_UL()
    require "multi_ue_sa_script_new"
    exec('uec_l2_testmode_params fixed_csi_report=true')
    sleep(1)
    set_amf_to_register_multiue(1,5,"311:489",36)
    sleep(5)
    exec('seq_start rate=1 id=42 detailed_print=on duration=300 max_active_ues=36')
    sleep(10)
    exec('ul_mimo_srs_beam_pos_nr profile_id=1 mode=fixed init_quad_pos=0 init_sub_quad_pos=0 test_type=UL_MIMO')
    exec('ul_mimo_srs_beam_pos_nr profile_id=2 mode=fixed init_quad_pos=2 init_sub_quad_pos=3 test_type=UL_MIMO')
    exec('ul_mimo_srs_beam_pos_nr profile_id=3 mode=fixed init_quad_pos=3 init_sub_quad_pos=1 test_type=UL_MIMO')
    exec('ul_mimo_srs_beam_pos_nr profile_id=4 mode=fixed init_quad_pos=1 init_sub_quad_pos=1 test_type=UL_MIMO')
    exec('ul_mimo_srs_beam_pos_nr profile_id=5 mode=fixed init_quad_pos=0 init_sub_quad_pos=0 test_type=UL_MIMO')
    exec('ul_mimo_srs_beam_pos_nr profile_id=6 mode=fixed init_quad_pos=2 init_sub_quad_pos=2 test_type=UL_MIMO')
    exec('ue_testmode_set_nr id=1 testmode=ul_mimo_srs_beam_pos action=activate profile_id=1')
    exec('ue_testmode_set_nr id=2 testmode=ul_mimo_srs_beam_pos action=activate profile_id=2')
    exec('ue_testmode_set_nr id=3 testmode=ul_mimo_srs_beam_pos action=activate profile_id=3')
    exec('ue_testmode_set_nr id=4 testmode=ul_mimo_srs_beam_pos action=activate profile_id=4')
    exec('ue_testmode_set_nr id=3 testmode=ul_mimo_srs_beam_pos action=activate profile_id=5')
    exec('ue_testmode_set_nr id=4 testmode=ul_mimo_srs_beam_pos action=activate profile_id=6')
    exec('ue_summary')
    exec('ue_stats_nr id=1-36 scell=0 type=pusch')
    print("PET_1070FF_MUMIMO_SRSBF_36UE_UL script completed")
end

function TDD_FR2_2S_8CC_53UEsPerSector()
    require "multi_ue_sa_script_new"
    exec('uec_l2_testmode_params fixed_csi_report=true')
    sleep(1)
    set_multi_amf_to_register_multiue(6,10,"311:489",425,848)
    sleep(5)
    exec('seq_start rate=1 id=57 detailed_print=on duration=60 max_start=54 max_active_ues=53')
    sleep(60)
    exec('filter_sim_rfm enable=all')
    exec('ue_summary')
    sleep(5)
    exec('ue_stats_nr id=425-848 scell=0-7 type=pusch')
    print("TDD_FR2_2S_8CC_53UEsPerSector script completed")
    exec("set_log flush")
end

function TDD_FR2_1S_8CC_106UEsPerSector()
    require "multi_ue_sa_script_new"
    exec('uec_l2_testmode_params fixed_csi_report=true')
    sleep(1)
    set_multi_amf_to_register_multiue(1,3,"311:489",1,424)
    sleep(5)
    exec('seq_start rate=1 id=17 detailed_print=on duration=60 max_start=54 max_active_ues=53')
    sleep(60)
    exec('filter_sim_rfm enable=all')
    exec('ue_summary')
	sleep(5)
	exec('ue_stats_nr id=1-424 scell=0-7 type=pdsch')
    print("TDD_FR2_1S_8CC_106UEsPerSector script completed")
    exec("set_log flush")
end

------------------------------------------------------------------------------------------------------------------
---------------------------------------- performance team custom function ----------------------------------------
------------------------------------------------------------------------------------------------------------------
function performance_common_seq_active_cells_lua_tdd(argp)
    --[=====[  DOCUMENTATION
    Use this lua if you want a sequential attach with active cells
    --]=====]
    require "commands_common"
    local args = convert_str_to_table(argp)
    performance_common_seq_active_cells_lua(args)
    print("performance_common_seq_active_cells_lua_tdd script completed")
end

function performance_common_seq_lua_tdd(argp)
    --[=====[  DOCUMENTATION

        Use this lua if you want to attach sequentially
        (Does not support some functionalities: TBA )

    --]=====]
    require "commands_common"
    local args = convert_str_to_table(argp)
    performance_common_seq_lua(args)
    print("performance_common_seq_lua_tdd script completed")
end

function PERFORMANCE_COMMON_TDD_MUMIMO_SRSBF(argp)
    --[=====[  DOCUMENTATION
        flexible version of PET_1070FF_MUMIMO_SRSBF_1200UE_DLUL()

        required args: start_ue, end_ue, num_cells, active_cells, ul_datarate, dl_datarate, rate, trf_direction,
        optional args: ue_nr_cap, registration_type, period_ms, packetsize,
    --]=====]

    require "commands_common"
    local args = convert_str_to_table(argp)
    performance_common_lua_mumimo_srs(args)
    print("PERFORMANCE_COMMON_TDD_MUMIMO_SRSBF script completed")
end

function PERFORMANCE_COMMON_TDD_BF_6PROFILES(argp)
    --[=====[  DOCUMENTATION

        Use this lua if you want to use AIRPHONE created commands
            with Beamforming 5 profiles
        this functions wraps register_multiue_with_traffic_parallel to work with performance "Run Common Test"

        --- from 1208FF_6Cells_432UEs ---

    --]=====]

    require "commands_common"
    local args = convert_str_to_table(argp)
    enable_beamforming_with_6_profiles()
    local profile_id_count=6
    testmode_beam_control(profile_id_count, args.start_ue, args.end_ue, args.active_cells, args.num_cells)
    performance_common_lua(args)
    print("PERFORMANCE_COMMON_TDD_BF_6PROFILES script completed")
end

function PERFORMANCE_COMMON_TDD_PET_1070FF_BF(argp)
    --[=====[  DOCUMENTATION
        --- from PET_1070FF_BF_9000UE_DLUL_rate1dot5 ---
    --]=====]

    require "commands_common"
    local args = convert_str_to_table(argp)

    -- enable_beamforming_with_6_profiles()
    exec('beam_control_testmode_nr profile_id=1 ueBeamIndexInitial=0,1,2,3,4,5 ssbeam_bestbeam=0 ssbeam_rsrp_best=-44 ssbeam_rsrp_avg=-50')
    exec('beam_control_testmode_nr profile_id=2 ueBeamIndexInitial=1,0,2,3,4,5 ssbeam_bestbeam=1 ssbeam_rsrp_best=-45 ssbeam_rsrp_avg=-120')
    exec('beam_control_testmode_nr profile_id=3 ueBeamIndexInitial=2,0,1,3,4,5 ssbeam_bestbeam=2 ssbeam_rsrp_best=-50 ssbeam_rsrp_avg=-125')
    exec('beam_control_testmode_nr profile_id=4 ueBeamIndexInitial=3,0,1,2,4,5 ssbeam_bestbeam=3 ssbeam_rsrp_best=-55 ssbeam_rsrp_avg=-120')
    exec('beam_control_testmode_nr profile_id=5 ueBeamIndexInitial=4,0,1,2,3,5 ssbeam_bestbeam=4 ssbeam_rsrp_best=-60 ssbeam_rsrp_avg=-139')
    exec('beam_control_testmode_nr profile_id=6 ueBeamIndexInitial=5,0,1,2,3,4 ssbeam_bestbeam=5 ssbeam_rsrp_best=-65 ssbeam_rsrp_avg=-70')
    -- exec('ue_testmode_set_nr id=1-1500 testmode=beam_control action=activate profile_id=1 beamaction=attach scell=0')
    -- exec('ue_testmode_set_nr id=1501-3000 testmode=beam_control action=activate profile_id=2 beamaction=attach scell=0')
    -- exec('ue_testmode_set_nr id=3001-4500 testmode=beam_control action=activate profile_id=3 beamaction=attach scell=0')
    -- exec('ue_testmode_set_nr id=4501-6000 testmode=beam_control action=activate profile_id=4 beamaction=attach scell=0')
    -- exec('ue_testmode_set_nr id=6001-7500 testmode=beam_control action=activate profile_id=5 beamaction=attach scell=0')
    -- exec('ue_testmode_set_nr id=7501-9000 testmode=beam_control action=activate profile_id=6 beamaction=attach scell=0')

    local profile_id_count=6
    testmode_beam_control(profile_id_count, args.start_ue, args.end_ue, args.active_cells, args.num_cells)
    performance_common_lua_v2(args)
    print("PERFORMANCE_COMMON_TDD_BF_6PROFILES script completed")
end

function PERFORMANCE_COMMON_TDD_SEQ_BF_6PROFILES(argp)
    --[=====[  DOCUMENTATION

        Use this lua if you want to attach with Beamforming 6 profiles sequentially
        this functions wraps register_multiue_with_traffic_parallel to work with performance "Run Common Test"

        --- from 1208FF_6Cells_432UEs ---

    --]=====]
    require "commands_common"
    local args = convert_str_to_table(argp)
    enable_beamforming_with_6_profiles()
    local profile_id_count=6
    testmode_beam_control(profile_id_count, args.start_ue, args.end_ue, args.active_cells, args.num_cells)
    performance_common_lua_v2(args) -- performance_common_seq_active_cells_lua(args)
    print("PERFORMANCE_COMMON_TDD_SEQ_BF_6PROFILES script completed")
end

function PERFORMANCE_COMMON_TDD_SEQ_BF(argp)
    --[=====[  DOCUMENTATION

        Use this lua if you want to attach sequentially with beamforming 1 profile
        (Does not support some functionalities: TBA )

    --]=====]
    require "commands_common"
    local args = convert_str_to_table(argp)
    exec('beam_control_testmode_nr profile_id=1 ueBeamIndexInitial=0,1,2,3,4,5 ssbeam_bestbeam=0 ssbeam_rsrp_best=-44 ssbeam_rsrp_avg=-50')
    exec('ue_testmode_set_nr id=1-'..args.end_ue..' testmode=beam_control action=activate profile_id=1 beamaction=attach scell=0')
    performance_common_seq_lua(args)
    print("PERFORMANCE_COMMON_TDD_SEQ_BF script completed")
end

function PERFORMANCE_COMMON_TDD_SEQ_BF_ACTIVE_CELLS(argp)
    --[=====[  DOCUMENTATION

        Use this lua if you want to attach sequentially with beamforming 1 profile
        (Does not support some functionalities: TBA )

    --]=====]
    require "commands_common"
    local args = convert_str_to_table(argp)
    local profile_id_count=6
    enable_beamforming_with_6_profiles()
    testmode_beam_control_1_profile_per_cell(profile_id_count, args.start_ue, args.end_ue, args.num_cells)
    performance_common_seq_active_cells_lua(args)
    print("PERFORMANCE_COMMON_TDD_SEQ_BF_ACTIVE_CELLS script completed")
end

function PERFORMANCE_COMMON_TDD_SEQ_SRS_ACTIVE_CELLS(argp)
    --[=====[  DOCUMENTATION

        Use this lua if you want to attach sequentially with SRS
        (Does not support some functionalities: TBA )

    --]=====]
    require "commands_common"
    local args = convert_str_to_table(argp)
    local profile_id_count=4
    exec_ue_srs_beam_pos_nr_4_profiles()
    testmode_ue_srs_beam_pos(profile_id_count, args.start_ue, args.end_ue, args.active_cells, args.num_cells)
    performance_common_seq_active_cells_lua(args)
    print("PERFORMANCE_COMMON_TDD_SEQ_SRS_ACTIVE_CELLS script completed")
end

function PERFORMANCE_COMMON_TDD(argp)
    --[=====[  DOCUMENTATION
        Uses the original airphone script

        required args: start_ue, end_ue, num_cells, active_cells, ul_datarate, dl_datarate, rate, trf_direction,
        optional args: ue_nr_cap, registration_type, period_ms, packetsize,
    --]=====]
    require "commands_common"
    local args = convert_str_to_table(argp)
    performance_common_lua(args)
    print("PERFORMANCE_COMMON_TDD script completed")
end

function PERFORMANCE_COMMON_TDD_V2(argp)
    --[=====[  DOCUMENTATION
        similar to PERFORMANCE_COMMON_TDD, use this when the parameters inside the multi_ue_sa_script needs to be changed dynamically
        it supports,
            active cells,
            custom number of ue per cells, etc...

        required args: start_ue, end_ue, num_cells, active_cells, ul_datarate, dl_datarate, rate, trf_direction,
        optional args: ue_nr_cap, registration_type, period_ms, packetsize,
    --]=====]
    require "commands_common"
    local args = convert_str_to_table(argp)
    performance_common_lua_v2(args)
    print("PERFORMANCE_COMMON_TDD_V2 script completed")
end
