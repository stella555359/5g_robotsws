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

function FDD_CB010449_MAX_RRC_CASE()
    require "multi_ue_sa_script_new"
    exec('enb_x2_link_up enb=1 target=2')
    sleep(1)
    exec('uec_l2_testmode_params fixed_csi_report=true')
    sleep(1)
    set_multi_amf_to_register_multiue(1,5,"311:489",1,9000)
    sleep(5)
    print("Running 4500 RRC connetced UEs")
    sleep(1)
    exec('seq_start rate=1 id=1 detailed_print=on duration=2 max_start=1 max_active_ues=1')
    sleep(290)
    exec('seq_start rate=1 id=3-16 detailed_print=on duration=290 max_start=503 max_active_ues=281')
    sleep(290)
    exec('filter_sim_rfm enable=all')
    print("FDD_CB010449_MAX_RRC_CASE")
    exec("set_log flush")
    exec('ue_summary')
end

function FDD_CB010449_DL_TPUT()
    require "multi_ue_sa_script_new"
    exec('enb_x2_link_up enb=1 target=2')
    sleep(1)
    exec('uec_l2_testmode_params fixed_csi_report=true')
    sleep(1)
    set_multi_amf_to_register_multiue(1,5,"311:489",1,9000)
    sleep(5)
    print("Run FDD_CB010449_DL_TPUT")
    sleep(1)
    exec('seq_start rate=1 id=33 detailed_print=on duration=2 max_start=1 max_active_ues=1')
    sleep(75)
    exec('filter_sim_rfm enable=all')
    print("FDD_CB010449_DL")
    exec("set_log flush")
    exec('ue_summary')
end

function FDD_CB010449_UL_TPUT()
    require "multi_ue_sa_script_new"
    exec('enb_x2_link_up enb=1 target=2')
    sleep(1)
    exec('uec_l2_testmode_params fixed_csi_report=true')
    sleep(1)
    set_multi_amf_to_register_multiue(1,5,"311:489",1,9000)
    sleep(5)
    print("Run FDD_CB010449_UL_TPUT")
    sleep(1)
    exec('seq_start rate=1 id=289-304 detailed_print=on duration=75 max_start=72 max_active_ues=72')
    sleep(75)
    exec('filter_sim_rfm enable=all')
    print("FDD_CB010449_UL")
    exec("set_log flush")
    exec('ue_summary')
end

function FDD_CB010449_VoNr()
    require "multi_ue_sa_script_new"
    exec('enb_x2_link_up enb=1 target=2')
    sleep(1)
    exec('uec_l2_testmode_params fixed_csi_report=true')
    sleep(1)
    set_multi_amf_to_register_multiue(1,5,"311:489",1,9000)
    sleep(5)
    print("Running VoNr_1440_UE")
    sleep(1)
    exec('seq_start rate=1 id=65-80 detailed_print=on duration=92 max_start=91 max_active_ues=90')
    sleep(92)
    exec('filter_sim_rfm enable=all')
    print("FDD_CB010449_VoNr")
    exec("set_log flush")
    exec('ue_summary')
end

function FDD_CB010449_SINGLE_CELL_50UE()
    require "multi_ue_sa_script_new"
    exec('enb_x2_link_up enb=1 target=2')
    sleep(1)
    exec('uec_l2_testmode_params fixed_csi_report=true')
    sleep(1)
    set_multi_amf_to_register_multiue(1,5,"311:489",1,9000)
    sleep(5)
    print("FDD_CB010449_SINGLE_CELL_50UE")
    sleep(1)
    exec('seq_start rate=1 id=97 detailed_print=on duration=16 max_start=16 max_active_ues=16')
    sleep(16)
    exec('seq_start rate=1 id=129 detailed_print=on duration=16 max_start=16 max_active_ues=16')
    sleep(16)
    exec('seq_start rate=1 id=161 detailed_print=on duration=8 max_start=8 max_active_ues=8')
    sleep(8)
    exec('seq_start rate=1 id=193 detailed_print=on duration=10 max_start=10 max_active_ues=10')
    sleep(10)
    exec('filter_sim_rfm enable=all')
    print("FDD_CB010449_SINGLE_CELL_50UE")
    exec("set_log flush")
    exec('ue_summary')
end

function FDD_CB010449_L1POOL_50UE_PER_CELL()
    require "multi_ue_sa_script_new"
    exec('enb_x2_link_up enb=1 target=2')
    sleep(1)
    exec('uec_l2_testmode_params fixed_csi_report=true')
    sleep(1)
    set_multi_amf_to_register_multiue(1,5,"311:489",1,9000)
    sleep(5)
    print("FDD_CB010449_L1POOL_50UE_PER_CELL")
    sleep(1)
    exec('seq_start rate=1 id=225-240 detailed_print=on duration=16 max_start=16 max_active_ues=16')
    sleep(16)
    exec('seq_start rate=1 id=257-272 detailed_print=on duration=16 max_start=16 max_active_ues=16')
    sleep(16)
    exec('seq_start rate=1 id=161-176 detailed_print=on duration=8 max_start=8 max_active_ues=8')
    sleep(8)
    exec('seq_start rate=1 id=193-208 detailed_print=on duration=10 max_start=10 max_active_ues=10')
    sleep(10)
    exec('filter_sim_rfm enable=all')
    print("FDD_CB010449_L1POOL_50UE_PER_CELL")
    exec("set_log flush")
    exec('ue_summary')
end

