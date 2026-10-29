-- Functions for Common Scripts for AP9000
-- Note currently, only support one configuration,

function configure()
    require "6Cell_6UEC_5AMF_5UPF_PerAP_updated.lua"
    run_configuration()
end

function x2_link_up()
    exec('enb_x2_link_up enb=1 target=2')
end

function stop_max_dl_ul()
    require "multi_ue_sa_script_v5"

    stop_multiue_call_parallel(1,24,6,1,0.3)
end
function stop_max_dl()
    require "multi_ue_sa_script_v5"

    stop_multiue_call_parallel(1,24,6,1,0.3)
end

function stop_test_max_ul()
    require "multi_ue_sa_script_v5"

    stop_multiue_call_parallel(1,24,6,1,0.3)
end

function stop_max_ue()
    require "multi_ue_sa_script_v5"
    stop_multiue_call_parallel(1,4450,6,1,0.3)
end

function show_ue_nr_stats_24_ue_dl()
    exec('ue_stats_nr id=1-24 type=pdsch scell=0')
end

function show_ue_nr_stats_24_ue_ul()
    exec('ue_stats_nr id=1-24 type=pusch scell=0')
end

function start_max_dl_ul()
    require "multi_ue_sa_script_v5"
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
    require "multi_ue_sa_script_v5"
    set_amf_to_register_multiue(1,5,"311:489",100)
    register_multiue_with_traffic_parallel(1,100,1,1,1,1,"mbps",1,150,"dl",1.6,"internal",1350,"yes",60)
end
function start_max_ul()
    require "multi_ue_sa_script_v5"
    set_amf_to_register_multiue(1,5,"311:489",100)
    register_multiue_with_traffic_parallel(1,100,1,1,1,1,"kbps",46000,2,"both",1.6,"internal",1350,"yes",60)
end

function start_max_ue()
    require "multi_ue_sa_script_v5"
    --- Max Ues case: 350 UEs * 6(cells/AP) = 2100 Ues with 74bps UL/DL
    --- Use 6Cell_6UEC_2100UEs_350UEs_PerCell.lua
    exec('uec_l2_testmode_params fixed_csi_report=true')
    sleep(1)
    set_amf_to_register_multiue(1,5,"311:489",3000)
    --register_multiue_with_traffic_parallel(1,2250,6,1,1,1,"bps",74,74,"both",1.3,"internal",42,"yes",60)
    register_multiue_with_pdu_check_traffic_parallel_retry(1,3000,6,1,1,1,"bps",74,74,"both",0.6,"internal",42,"yes",10)
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

function start_max_dl_mu_mimo()
    require "multi_ue_sa_script_v5"

    set_amf_to_register_multiue(1,5,"311:489",24)
    attach_start_traffic_multiue(1,24,1,1,1,"mbps",1,150,"dl",1,"internal",1350,"yes",10)
    run_traffic_only_with_range(1,4,1,1,1,"mbps",0,800,"dl",1350)
    sleep(0.3)
    run_traffic_only_with_range(5,16,1,1,1,"mbps",0,400,"dl",1350)
    sleep(0.3)
    run_traffic_only_with_range(17,20,1,1,1,"mbps",0,800,"dl",1350)
    sleep(0.3)
    run_traffic_only_with_range(21,24,1,1,1,"mbps",0,400,"dl",1350)
    sleep(0.3)

    print("###############################################################################")
    print("#  Cell-1  #  UE-01 to UE-04  #  MU-MIMO  #  Downlink traffic 800Mbps per UE  #")
    print("#  Cell-2  #  UE-05 to UE-08  #  SU-MIMO  #  Downlink traffic 400Mbps per UE  #")
    print("#  Cell-3  #  UE-09 to UE-12  #  SU-MIMO  #  Downlink traffic 800Mbps per UE  #")
    print("#  Cell-4  #  UE-13 to UE-16  #  SU-MIMO  #  Downlink traffic 400Mbps per UE  #")
    print("#  Cell-5  #  UE-17 to UE-20  #  MU-MIMO  #  Downlink traffic 800Mbps per UE  #")
    print("#  Cell-6  #  UE-21 to UE-24  #  SU-MIMO  #  Downlink traffic 400Mbps per UE  #")
    print("###############################################################################")
end

function tput_loki_a()
     print("########################################################################")
     print("#  Cell-1  #  UE-1 to UE-4   #  MU-MIMO  #  Downlink Throughput per UE  #")
     exec('ue_stats_nr id=1-4 type=pdsch scell=0')
     sleep(1)
     print("########################################################################")
     sleep(15)
     print("#  Cell-2  #  UE-5 to UE-8   #  SU-MIMO  #  Downlink Throughput per UE  #")
     exec('ue_stats_nr id=5-8 type=pdsch scell=0')
     sleep(1)
     print("########################################################################")
     sleep(15)
     print("#  Cell-3  #  UE-9 to UE-12  #  SU-MIMO  #  Downlink Throughput per UE  #")
     exec('ue_stats_nr id=9-12 type=pdsch scell=0')
     sleep(1)
     print("#########################################################################")
end

function tput_loki_b()
     print("########################################################################")
     print("#  Cell-5  #  UE-17 to UE-20   #  MU-MIMO  #  Downlink Throughput per UE  #")
     exec('ue_stats_nr id=17-20 type=pdsch scell=0')
     sleep(1)
     print("########################################################################")
     sleep(15)
     print("#  Cell-4  #  UE-13 to UE-16   #  SU-MIMO  #  Downlink Throughput per UE  #")
     exec('ue_stats_nr id=13-16 type=pdsch scell=0')
     sleep(1)
     print("########################################################################")
     sleep(15)
     print("#  Cell-6  #  UE-21 to UE-24   #  SU-MIMO  #  Downlink Throughput per UE  #")
     exec('ue_stats_nr id=21-24 type=pdsch scell=0')
     sleep(1)
     print("#########################################################################")
end

function beam_profile_config()
--2.    Beam Forming steps for 24 UEs
exec('beam_control_testmode_nr profile_id=1 ueBeamIndexInitial=1,2,3,4,5,0 ssbeam_bestbeam=1 ssbeam_rsrp_best=-44 ssbeam_rsrp_avg=-50')
exec('csi_override_testmode_nr profile_id=1 cqi_mode=fixed cqi=15 ri_mode=fixed cqi_min=0 cqi_max=15 ri=3 pmi_mode=fixed pmi=852 cri_mode=fixed cri=2 li_mode=fixed li=0')

exec('beam_control_testmode_nr profile_id=2 ueBeamIndexInitial=5,0,1,2,3,4 ssbeam_bestbeam=5 ssbeam_rsrp_best=-44 ssbeam_rsrp_avg=-50')
exec('csi_override_testmode_nr profile_id=2 cqi_mode=fixed cqi=15 ri_mode=fixed cqi_min=0 cqi_max=15 ri=3 pmi_mode=fixed pmi=852 cri_mode=fixed cri=2 li_mode=fixed li=0')

exec('beam_control_testmode_nr profile_id=3 ueBeamIndexInitial=2,3,4,5,0,1 ssbeam_bestbeam=2 ssbeam_rsrp_best=-44 ssbeam_rsrp_avg=-50')
exec('csi_override_testmode_nr profile_id=3 cqi_mode=fixed cqi=15 ri_mode=fixed cqi_min=0 cqi_max=15 ri=3 pmi_mode=fixed pmi=852 cri_mode=fixed cri=2 li_mode=fixed li=0')

exec('beam_control_testmode_nr profile_id=4 ueBeamIndexInitial=4,5,0,1,2,3 ssbeam_bestbeam=4 ssbeam_rsrp_best=-44 ssbeam_rsrp_avg=-50')
exec('csi_override_testmode_nr profile_id=4 cqi_mode=fixed cqi=15 ri_mode=fixed cqi_min=0 cqi_max=15 ri=3 pmi_mode=fixed pmi=852 cri_mode=fixed cri=2 li_mode=fixed li=0')

exec('beam_control_testmode_nr profile_id=5 ueBeamIndexInitial=3,4,5,0,1,2 ssbeam_bestbeam=3 ssbeam_rsrp_best=-44 ssbeam_rsrp_avg=-50')
exec('csi_override_testmode_nr profile_id=5 cqi_mode=fixed cqi=15 ri_mode=fixed cqi_min=0 cqi_max=15 ri=3 pmi_mode=fixed pmi=341 cri_mode=fixed cri=3 li_mode=fixed li=0')

exec('beam_control_testmode_nr profile_id=6 ueBeamIndexInitial=0,1,2,3,4,5 ssbeam_bestbeam=0 ssbeam_rsrp_best=-44 ssbeam_rsrp_avg=-50')
exec('csi_override_testmode_nr profile_id=6 cqi_mode=fixed cqi=15 ri_mode=fixed cqi_min=0 cqi_max=15 ri=3 pmi_mode=fixed pmi=341 cri_mode=fixed cri=3 li_mode=fixed li=0')

exec('beam_control_testmode_nr profile_id=7 ueBeamIndexInitial=1,2,3,4,5,0 ssbeam_bestbeam=1 ssbeam_rsrp_best=-44 ssbeam_rsrp_avg=-50')
exec('csi_override_testmode_nr profile_id=7 cqi_mode=fixed cqi=15 ri_mode=fixed cqi_min=0 cqi_max=15 ri=3 pmi_mode=fixed pmi=341 cri_mode=fixed cri=3 li_mode=fixed li=0')

exec('beam_control_testmode_nr profile_id=8 ueBeamIndexInitial=5,0,1,2,3,4 ssbeam_bestbeam=5 ssbeam_rsrp_best=-44 ssbeam_rsrp_avg=-50')
exec('csi_override_testmode_nr profile_id=8 cqi_mode=fixed cqi=15 ri_mode=fixed cqi_min=0 cqi_max=15 ri=3 pmi_mode=fixed pmi=341 cri_mode=fixed cri=3 li_mode=fixed li=0')

exec('ue_testmode_set_nr id=1-2 testmode=beam_control action=activate profile_id=1 beamaction=attach')
exec('ue_testmode_set_nr id=1-2 testmode=csi_override action=activate profile_id=1 scell=8')

exec('ue_testmode_set_nr id=3-4 testmode=beam_control action=activate profile_id=5 beamaction=attach')
exec('ue_testmode_set_nr id=3-4 testmode=csi_override action=activate profile_id=5 scell=8')

exec('ue_testmode_set_nr id=17-18 testmode=beam_control action=activate profile_id=2 beamaction=attach')
exec('ue_testmode_set_nr id=17-18 testmode=csi_override action=activate profile_id=2 scell=8')

exec('ue_testmode_set_nr id=19-20 testmode=beam_control action=activate profile_id=6 beamaction=attach')
exec('ue_testmode_set_nr id=19-20 testmode=csi_override action=activate profile_id=6 scell=8')

exec('ue_testmode_set_nr id=5-12 testmode=beam_control action=activate profile_id=3 beamaction=attach')
exec('ue_testmode_set_nr id=5-12 testmode=csi_override action=activate profile_id=3 scell=8')

exec('ue_testmode_set_nr id=13-16 testmode=beam_control action=activate profile_id=4 beamaction=attach')
exec('ue_testmode_set_nr id=13-16 testmode=csi_override action=activate profile_id=4 scell=8')

exec('ue_testmode_set_nr id=21-24 testmode=beam_control action=activate profile_id=4 beamaction=attach')
exec('ue_testmode_set_nr id=21-24 testmode=csi_override action=activate profile_id=4 scell=8')

--3.    PUCCH SINR power control if it is required

exec('ul_sinr_testmode_nr profile_id=1 sinr_target_srs=300 sinr_target_pusch=-300 sinr_target_pucch=-300 sinr_target_preamble=100')
exec('ue_testmode_set_nr id=1-24 testmode=ul_sinr action=activate profile_id=1')
end

function start_max_ues()
    require "multi_ue_sa_script_v5"
    exec('uec_l2_testmode_params fixed_csi_report=true')
    sleep (1)
    set_amf_to_register_multiue(1,6,"311:489",3000)
    sleep (1)
    register_multiue_with_pdu_check_traffic_parallel_retry(1,3000,6,1,1,1,"bps",74,74,"both",0.4,"internal",42,"yes",60)
end

function  trf_rate_down()
   require "multi_ue_sa_script_v5"
    run_traffic_only_with_range(1,24,1,1,1,2,2,"both",64)
end

function  trf_rate_up()
   require "multi_ue_sa_script_v5"
    run_traffic_only_with_range(1,24,1,1,1,46000,151000,"both",1350)
end

function sib_check()
    require "multi_ue_sa_script_v5"
    require "12Cell_6UEC_5AMF_5UPF_FDD_SANSA"
    check_SIBs(FIRST_CELL_ID, END_CELL_ID)
end

function start_72UE_DL_UL()
    require "multi_ue_sa_script_v5"
    set_amf_to_register_multiue(1,5,"311:489",432)
    --attach_start_traffic_multiue(1,432,1,1,1,"mbps",3,22,"both",0.7,"internal",1350,"yes",60)
    register_multiue_with_traffic_parallel(1,432,6,1,1,1,"mbps",3,22,"both",2,"internal",1350,"yes",60)
end

function pet_uc1_start()
    require "multi_ue_sa_script_v5"
    exec('uec_l2_testmode_params fixed_csi_report=true')
    sleep(1)
    set_multi_amf_to_register_multiue(1,5,"311:489",1,3000)
    sleep(1)
    exec('seq_start rate=1 id=1-6 detailed_print=on duration=600 max_active_ues=500')
    --sleep(0.1)
    --exec('seq_start rate=1 id=4-6 detailed_print=on duration=600 max_active_ues=500')
    --sleep(600)
    --exec('ue_summary')
end

function pet_uc1_stop()
    exec('seq_stop id=1-3')
    sleep (30)
    exec('seq_stop id=4-6')
end

function pet_uc2_start()
    require "multi_ue_sa_script_v5"
    exec('uec_l2_testmode_params fixed_csi_report=true')
    sleep(1)
    set_multi_amf_to_register_multiue(5,12,"311:489",1,24)
    exec('seq_start rate=1 id=7-12 detailed_print=on duration=43200  max_active_ues=4')
    --sleep(0.1)
    --exec('seq_start rate=1 id=10-12 detailed_print=on duration=43200  max_active_ues=4')
    --sleep(30)
    exec('ue_summary')
end

function pet_uc2_stop()
    exec('seq_stop id=7-12')
end

function pet_seq_start()
    require "multi_ue_sa_script_v5"
    require "6Cell_6UEC_5AMF_5UPF_PerAP_updated"
    duration = 86400
--    duration = 1200
    timer = round (duration / 2)

    exec('uec_l2_testmode_params fixed_csi_report=true')
    sleep(1)
    set_multi_amf_to_register_multiue(FIRST_AMF_ID, END_AMF_ID, PLMN, FIRST_UE_SA_CELL, END_UE_SA_CELL)
--    set_amf_to_register_multiue(1,5,"311:489",3000)
    sleep(1)
    exec('seq_start rate=1 id='..FIRST_CELL_ID..'-'..END_CELL_ID..' detailed_print=on duration='..duration..' max_active_ues='..UE_COUNT_ON_CELL)
--    exec('seq_start rate=1 id=1-3 detailed_print=on duration=900 max_active_ues=500')
--    exec('seq_start id=1-3 detailed_print=on rate=1 duration=900 max_start=500 max_active_ues=500')
--    sleep(0.1)
--    exec('seq_start rate=1 id=4-6 detailed_print=on duration=900 max_active_ues=500')
--    exec('seq_start id=4-6 detailed_print=on rate=1 duration=900 max_start=500 max_active_ues=500')
--    sleep(800)
    sleep(timer)
    exec('ue_summary')
end

function pet_seq_stop_all()
--    exec('seq_stop id=all')
    exec('seq_stop id=all rate=15')
end

function pet_seq_start_for_odd_even_seq_grp()
    require "multi_ue_sa_script_v5"
--    require "6Cell_6UEC_5AMF_5UPF_PerAP_updated"
    require "18Cell_9UEC_5AMF_5UPF_FDD_SANSA"
--[[
    NUMBER_OF_CELLS = 6
    AMF_COUNT = 5
    UEC_COUNT = 6
    UE_COUNT_ON_CELL = 500
    PLMN="311:489"
    FIRST_CELL_ID = 1
    FIRST_AMF_ID = 1
    FIRST_UE_SA_CELL = 1
    END_UE_SA_CELL = NUMBER_OF_CELLS * UE_COUNT_ON_CELL
    END_CELL_ID = FIRST_CELL_ID + NUMBER_OF_CELLS - 1
    END_AMF_ID = FIRST_AMF_ID + AMF_COUNT - 1
--]]

    duration = 86400
    timer = round (duration / 2)

    exec('uec_l2_testmode_params fixed_csi_report=true')
    sleep(1.0)
    set_multi_amf_to_register_multiue(FIRST_AMF_ID, END_AMF_ID, PLMN, FIRST_UE_SA_CELL, END_UE_SA_CELL)
    sleep(0.1)
    i = 1
    for cellid = FIRST_CELL_ID, END_CELL_ID do
        if i > NUMBER_OF_CELLS then
            i = 2
        end
        exec('seq_start rate=1 id='..i..' detailed_print=on duration='..duration..' max_active_ues='..UE_COUNT_ON_CELL)
        sleep(UE_COUNT_ON_CELL)
        i = i + 2
        exec('ue_summary')
    end
    sleep(timer)
    exec('ue_summary')
end

function pet_seq_start_overnight_run()
    require "multi_ue_sa_script_v5"
--    require "6Cell_6UEC_5AMF_5UPF_PerAP_updated"
    require "12Cell_6UEC_5AMF_5UPF_FDD_SANSA"

    seq_id_set1 = FIRST_CELL_ID    --Seq_group start id '1'
    seq_id_set_diff = 3 --If user want to run seq_start id=1-3, then set value as diff as '3',
    seq_id_set2 = seq_id_set_diff    --If user wants to run for each or single seq_group, set same value as 'seq_id_set1' in 'seq_id_set_diff'
    rate = 1  --Seq_start rate value
    duration = 86400
    timer = round (duration / 2)
    i = round (NUMBER_OF_CELLS / seq_id_set_diff)

    exec('uec_l2_testmode_params fixed_csi_report=true')
    sleep(1)
    set_multi_amf_to_register_multiue(FIRST_AMF_ID, END_AMF_ID, PLMN, FIRST_UE_SA_CELL, END_UE_SA_CELL)
    sleep(1)

    if seq_id_set2 < END_CELL_ID then
        for j = 1, i do
            exec('seq_start rate='..rate..' id='..seq_id_set1..'-'..seq_id_set2..' detailed_print=on duration='..duration..' max_active_ues='..UE_COUNT_ON_CELL)
            sleep(0.01)
            seq_id_set1 = seq_id_set2 + 1
            seq_id_set2 = seq_id_set2 + seq_id_set_diff
        end
    else
        exec('seq_start rate='..rate..' id='..seq_id_set1..'-'..seq_id_set2..' detailed_print=on duration='..duration..' max_active_ues='..UE_COUNT_ON_CELL)
        seq_id_set1 = seq_id_set2 + 1
        seq_id_set2 = seq_id_set2 + seq_id_set_diff
    end
    sleep(timer)
    exec('ue_summary')
----    exec('seq_stop id=1-6')
end

function pet_seq_loop_start()
    require "multi_ue_sa_script_v5"
    require "6Cell_6UEC_5AMF_5UPF_PerAP_updated"

    seq_id_set1 = FIRST_CELL_ID    --Seq_group start id '1'
    seq_id_set_diff = 3 --If user want to run seq_start id=1-3, then set value as diff as '3',
    seq_id_set2 = seq_id_set_diff    --If user wants to run for each or single seq_group, set same value as 'seq_id_set1' in 'seq_id_set_diff'
    num_of_iterations = 2  --Number of Iterations
    rate = 1  --Seq_start rate value
    duration = 86400
    timer = round (duration / 2)

    exec('uec_l2_testmode_params fixed_csi_report=true')
    sleep(1)
    set_multi_amf_to_register_multiue(FIRST_AMF_ID, END_AMF_ID, PLMN, FIRST_UE_SA_CELL, END_UE_SA_CELL)
    sleep(0.1)

    for iteration=1, num_of_iterations do
        print("Iteration-"..iteration.." Started")
        if seq_id_set2 < NUMBER_OF_CELLS then
            local i = round (NUMBER_OF_CELLS / seq_id_set_diff)
            for j = 1, i do
                exec('seq_start rate='..rate..' id='..seq_id_set1..'-'..seq_id_set2..' detailed_print=on duration='..duration..' max_active_ues='..UE_COUNT_ON_CELL)
                sleep(0.01)
                seq_id_set1 = seq_id_set2 + 1
                seq_id_set2 = seq_id_set2 + seq_id_set_diff
            end
        else
            exec('seq_start rate='..rate..' id='..seq_id_set1..'-'..seq_id_set2..' detailed_print=on duration='..duration..' max_active_ues='..UE_COUNT_ON_CELL)
            seq_id_set1 = seq_id_set2 + 1
            seq_id_set2 = seq_id_set2 + seq_id_set_diff
        end
        sleep(timer)
        exec('ue_summary')
        exec('seq_stop id=all')
        sleep(10)
    end
end

function pet_seq12_start_UC1()
-- Start SA Max UEs Registration
    require "multi_ue_sa_script_v5"
    exec('uec_l2_testmode_params fixed_csi_report=true')
    sleep(1)
    exec('sim_debug_log level=0 gate=1')
--    set_multi_amf_to_register_multiue(1,5,"311:489",1,1824)
    set_multi_amf_to_register_multiue(1,5,"311:489",1,4500)
    sleep(1)
--    exec('seq_start rate=1 id=1-6 detailed_print=on duration=200 max_active_ues=152')
    exec('seq_start rate=1 id=1-12 detailed_print=on duration=500 max_active_ues=375')
--    sleep(205)
    sleep(505)
--    exec('ue_summary')
--    sleep(1)
--    exec('seq_start rate=1 id=7-12 detailed_print=on duration=200 max_active_ues=152')
--    exec('seq_start rate=1 id=7-12 detailed_print=on duration=400 max_active_ues=300')
--    sleep(205)
--    sleep(405)
    exec('ue_summary')
    sleep(5)
    exec('ue_disp state=ACTIVATING format=long')
    sleep(5)
    exec('ue_disp state=IDLE format=long')
    sleep(5)
    exec('ue_disp state=ACTIVE format=long')
    sleep(10)
    exec('ue_summary')
end

function pet_seql2_start_100UE_DL()
-- Start SA Multi-UEs Peak Tput
    require "multi_ue_sa_script_v5"
    exec('uec_l2_testmode_params fixed_csi_report=true')
    sleep(1)
    exec('sim_debug_log level=0 gate=1')
--    set_multi_amf_to_register_multiue(1,5,"311:489",1,480)
    set_multi_amf_to_register_multiue(6,10,"311:489",601,1500)
    sleep(1)
    exec('seq_start rate=1 id=13-21 detailed_print=on duration=200 max_active_ues=100')
--    exec('seq_start rate=1 id=13-18 detailed_print=on duration=100 max_active_ues=40')
--    sleep(105)
--    exec('ue_summary')
--    sleep(1)
--    exec('seq_start rate=1 id=19-24 detailed_print=on duration=100 max_active_ues=40')
    sleep(105)
    exec('ue_summary')
    sleep(5)
    exec('ue_disp state=ACTIVATING format=long')
    sleep(5)
    exec('ue_disp state=IDLE format=long')
    sleep(5)
    exec('ue_disp state=ACTIVE format=long')
    sleep(10)
    exec('ue_summary')
    print('pet_seql2_start_100UE_DL script completed')
end

function pet_seql2_start_4UE_DLUL()
-- Start SA Multi-UEs Peak Tput
    require "multi_ue_sa_script_v5"
    exec('uec_l2_testmode_params fixed_csi_report=true')
    sleep(1)
    exec('sim_debug_log level=0 gate=1')
--    set_multi_amf_to_register_multiue(1,5,"311:489",1,480)
    set_multi_amf_to_register_multiue(6,10,"311:489",601,1500)
    sleep(1)
    exec('seq_start rate=1 id=13-21 detailed_print=on duration=200 max_active_ues=4')
    sleep(105)
    exec('ue_summary')
    sleep(5)
    exec('ue_disp state=ACTIVATING format=long')
    sleep(5)
    exec('ue_disp state=IDLE format=long')
    sleep(5)
    exec('ue_disp state=ACTIVE format=long')
    sleep(10)
    exec('ue_summary')
    print('pet_seql2_start_4UE_DLUL script completed')
end

function pet_seql2_start_100UE_DLUL()
-- Start SA Multi-UEs Peak Tput
    require "multi_ue_sa_script_v5"
    exec('uec_l2_testmode_params fixed_csi_report=true')
    sleep(1)
    exec('sim_debug_log level=0 gate=1')
--    set_multi_amf_to_register_multiue(1,5,"311:489",1,480)
    set_multi_amf_to_register_multiue(6,10,"311:489",601,1500)
    sleep(1)
    exec('seq_start rate=1 id=50-58 detailed_print=on duration=200 max_active_ues=100')
    sleep(105)
    exec('ue_summary')
    sleep(5)
    exec('ue_disp state=ACTIVATING format=long')
    sleep(5)
    exec('ue_disp state=IDLE format=long')
    sleep(5)
    exec('ue_disp state=ACTIVE format=long')
    sleep(10)
    exec('ue_summary')
    print('pet_seql2_start_100UE_DLUL script completed')
end

function pet_seql2_start_100UEinCell1_4UEinOtherCell_DLUL()
-- Start SA Multi-UEs Peak Tput
    require "multi_ue_sa_script_v5"
    exec('uec_l2_testmode_params fixed_csi_report=true')
    sleep(1)
    exec('sim_debug_log level=0 gate=1')
--    set_multi_amf_to_register_multiue(1,5,"311:489",1,480)
    set_multi_amf_to_register_multiue(6,10,"311:489",601,1500)
    sleep(1)
    exec('seq_start rate=1 id=25 detailed_print=on duration=200 max_active_ues=100')
	sleep(1)
	exec('seq_start rate=1 id=26-33 detailed_print=on duration=200 max_active_ues=4')
    sleep(105)
    exec('ue_summary')
    sleep(5)
    exec('ue_disp state=ACTIVATING format=long')
    sleep(5)
    exec('ue_disp state=IDLE format=long')
    sleep(5)
    exec('ue_disp state=ACTIVE format=long')
    sleep(10)
    exec('ue_summary')
    print('pet_seql2_start_100UEinCell1_4UEinOtherCell_DLUL script completed')
end

function pet_seql2_start_100UE_UL()
-- Start SA Multi-UEs Peak Tput
    require "multi_ue_sa_script_v5"
    exec('uec_l2_testmode_params fixed_csi_report=true')
    sleep(1)
    exec('sim_debug_log level=0 gate=1')
--    set_multi_amf_to_register_multiue(1,5,"311:489",1,480)
    set_multi_amf_to_register_multiue(1,5,"311:489",1,100)
    sleep(1)
    exec('seq_start rate=1 id=25 detailed_print=on duration=200 max_active_ues=100')
--    exec('seq_start rate=1 id=13-18 detailed_print=on duration=100 max_active_ues=40')
--    sleep(105)
--    exec('ue_summary')
--    sleep(1)
--    exec('seq_start rate=1 id=19-24 detailed_print=on duration=100 max_active_ues=40')
    sleep(105)
    exec('ue_summary')
    sleep(5)
    exec('ue_disp state=ACTIVATING format=long')
    sleep(5)
    exec('ue_disp state=IDLE format=long')
    sleep(5)
    exec('ue_disp state=ACTIVE format=long')
    sleep(10)
    exec('ue_summary')
    print('pet_seql2_start_100UE_UL script completed')
end

function pet_seq12_start_UC2()
-- Start SA Multi-UEs Peak Tput
    require "multi_ue_sa_script_v5"
    exec('uec_l2_testmode_params fixed_csi_report=true')
    sleep(1)
    exec('sim_debug_log level=0 gate=1')
--    set_multi_amf_to_register_multiue(1,5,"311:489",1,480)
    set_multi_amf_to_register_multiue(1,5,"311:489",1,864)
    sleep(1)
    exec('seq_start rate=1 id=37,40 detailed_print=on duration=100 max_active_ues=72')
--    exec('seq_start rate=1 id=13-18 detailed_print=on duration=100 max_active_ues=40')
--    sleep(105)
--    exec('ue_summary')
--    sleep(1)
--    exec('seq_start rate=1 id=19-24 detailed_print=on duration=100 max_active_ues=40')
    sleep(105)
    exec('ue_summary')
    sleep(5)
    exec('ue_disp state=ACTIVATING format=long')
    sleep(5)
    exec('ue_disp state=IDLE format=long')
    sleep(5)
    exec('ue_disp state=ACTIVE format=long')
    sleep(10)
    exec('ue_summary')
end

function pet_seq18_start()
    require "multi_ue_sa_script_v5"
    exec('uec_l2_testmode_params fixed_csi_report=true')
    sleep(1)
    set_multi_amf_to_register_multiue(1,5,"311:489",1,9060)
--    set_multi_amf_to_register_multiue(1,5,"311:489",1,72)
    sleep(2)
--    exec('seq_start rate=1 id=1-6 detailed_print=on duration=6400 max_active_ues=4')
    exec('seq_start rate=1 id=1-6 detailed_print=on duration=600 max_active_ues=500')
    sleep(605)
    exec('ue_summary')
--    exec('seq_start rate=1 id=7-12 detailed_print=on duration=6400 max_active_ues=4')
    exec('seq_start rate=1 id=7-12 detailed_print=on duration=600 max_active_ues=500')
    sleep(605)
    exec('ue_summary')
--    exec('seq_start rate=1 id=13-18 detailed_print=on duration=6400 max_active_ues=4')
    exec('seq_start rate=1 id=13-18 detailed_print=on duration=600 max_active_ues=500')
    sleep(605)
    exec('ue_summary')
    sleep(5)
    exec('ue_disp state=ACTIVATING format=long')
    sleep(5)
    exec('ue_disp state=IDLE format=long')
    sleep(5)
    exec('ue_disp state=ACTIVE format=long')
    sleep(10)
    exec('ue_summary')
end

function pet_overnight_start_stop()
    require "multi_ue_sa_script_v5"
    num_of_iterations = 8

    exec('uec_l2_testmode_params fixed_csi_report=true')
    sleep(1)
    exec('sim_debug_log level=0 gate=1')
    set_multi_amf_to_register_multiue(1,5,"311:489",1,9060)
    sleep(1)
    for iteration=1, num_of_iterations do
        print("Iteration-"..iteration.." Started")
        if (iteration % 2) == 0 then
            exec('seq_start rate=1.5 id=1-6 detailed_print=on duration=900 max_active_ues=750')
            sleep(900)
            exec('seq_start rate=1.5 id=7-12 detailed_print=on duration=900 max_active_ues=750')
        else
            exec('seq_start rate=1.2 id=1-6 detailed_print=on duration=900 max_active_ues=750')
            sleep(900)
            exec('seq_start rate=1.2 id=7-12 detailed_print=on duration=900 max_active_ues=750')
        end
        sleep(4600) --Overall sleep for 2hrs incld below sleep
        exec('ue_disp state=IDLE format=long')
        sleep(1)
        exec('ue_disp state=ACTIVATING format=long')
        sleep(1)
        exec('ue_summary')
--        sleep(5)
--        os.execute("python3 WTS_Summary -u no -c sa -p egate_console.log*")
        sleep(100)
        exec('seq_stop id=all rate=15')
        sleep(600)
        exec('seq_stop id=all rate=15')
        sleep(600)
    end
end

function pet_overnight_start_stop_new()
    require "multi_ue_sa_script_v5"
    num_of_iterations = 10 --4

    exec('uec_l2_testmode_params fixed_csi_report=true')
    sleep(1)
    exec('sim_debug_log level=0 gate=1')
    set_multi_amf_to_register_multiue(1,5,"311:489",1,9000)
    sleep(1)
    for iteration=1, num_of_iterations do
        print("Iteration-"..iteration.." Started")

        exec('seq_start rate=1 id=1-12 detailed_print=on duration=900 max_active_ues=750')
        sleep(910)

--[[        if (iteration % 2) == 0 then
            exec('seq_start rate=1.5 id=1-6 detailed_print=on duration=900 max_active_ues=750')
            sleep(900)
            exec('seq_start rate=1.5 id=7-12 detailed_print=on duration=900 max_active_ues=750')
        else
            exec('seq_start rate=1.2 id=1-6 detailed_print=on duration=900 max_active_ues=750')
            sleep(900)
            exec('seq_start rate=1.2 id=7-12 detailed_print=on duration=900 max_active_ues=750')
        end
--]]
        for loop=1, 3 do
--            sleep(2400) --Sleep for 40mins
            exec('ue_disp state=IDLE format=long')
            sleep(5)
            exec('ue_disp state=OFF format=long')
            sleep(5)
            exec('ue_disp state=ACTIVE format=long')
            sleep(5)
            exec('ue_summary')
            sleep(5)
            sleep(5100) --Sleep for 1hr 25mins
        end
--        exec("set_log flush")
--        sleep(1)
--        os.execute("python3 WTS_Summary -u no -c sa -p egate_console.log*")
--        sleep(1200)  --Sleep for 20mins
        exec('seq_stop id=all rate=10')
        sleep(600)
--        exec('seq_stop id=all rate=15')
--        sleep(600)
    end
end

function pet_overnight_18cell_start_stop_new()
    require "multi_ue_sa_script_v5"
    num_of_iterations = 4
    exec('uec_l2_testmode_params fixed_csi_report=true')
    sleep(1)
    exec('sim_debug_log level=0 gate=1')
--    set_multi_amf_to_register_multiue(1,5,"311:489",1,13500)
    set_multi_amf_to_register_multiue(1,5,"311:489",1,9000)
    sleep(1)
    for iteration=1, num_of_iterations do
        print("Iteration-"..iteration.." Started")

        exec('seq_start rate=1 id=4-6,13-15 detailed_print=on duration=790 max_active_ues=750')
        sleep(800)
            exec('ue_summary')
        exec('seq_start rate=1 id=1-3,7-9 detailed_print=on duration=395 max_active_ues=375')
        sleep(400)
            exec('ue_summary')
        exec('seq_start rate=1 id=10-12,16-18 detailed_print=on duration=395 max_active_ues=375')
        sleep(400)
            exec('ue_summary')

--[[
        if (iteration % 2) == 0 then
            exec('seq_start rate=1.5 id=1-3 detailed_print=on duration=395 max_active_ues=375')
            sleep(400)
            exec('seq_start rate=1.5 id=4-6 detailed_print=on duration=790 max_active_ues=750')
            sleep(800)
            exec('seq_start rate=1.5 id=7-9 detailed_print=on duration=395 max_active_ues=375')
            sleep(400)
            exec('seq_start rate=1.5 id=10-12 detailed_print=on duration=395 max_active_ues=375')
            sleep(400)
            exec('seq_start rate=1.5 id=13-15 detailed_print=on duration=790 max_active_ues=750')
            sleep(800)
            exec('seq_start rate=1.5 id=16-18 detailed_print=on duration=395 max_active_ues=375')
        else
            exec('seq_start rate=1.2 id=1-3 detailed_print=on duration=395 max_active_ues=375')
            sleep(400)
            exec('seq_start rate=1.2 id=4-6 detailed_print=on duration=790 max_active_ues=750')
            sleep(800)
            exec('seq_start rate=1.2 id=7-9 detailed_print=on duration=395 max_active_ues=375')
            sleep(400)
            exec('seq_start rate=1.2 id=10-12 detailed_print=on duration=395 max_active_ues=375')
            sleep(400)
            exec('seq_start rate=1.2 id=13-15 detailed_print=on duration=790 max_active_ues=750')
            sleep(800)
            exec('seq_start rate=1.2 id=16-18 detailed_print=on duration=395 max_active_ues=375')
        end
--]]
        for loop=1, 3 do
--[[            sleep(1200) --Sleep for 20mins
            exec('ue_disp state=IDLE format=long')
            sleep(5)
            exec('ue_disp state=ACTIVATING format=long')
--]]
            sleep(5)
            exec('ue_disp state=OFF format=long')
            sleep(5)
            exec('ue_summary')
--            sleep(5)
            sleep(5400) --Sleep for 1hr 30mins
        end
--[[
        exec('seq_stop id=all rate=10')
        sleep(600)
        exec('seq_stop id=all rate=15')
        sleep(200)
--]]
    end
end

function pet_seq12_start_w18cells()
    require "multi_ue_sa_script_v5"
    num_of_iterations = 8
    exec('uec_l2_testmode_params fixed_csi_report=true')
    sleep(1)
    exec('sim_debug_log level=0 gate=1')
    set_multi_amf_to_register_multiue(1,5,"311:489",1,13590)
    sleep(1)
    for iteration=1, num_of_iterations do
        print("Iteration-"..iteration.." Started")
        if (iteration % 2) == 0 then
            exec('seq_start rate=1.5 id=1-6 detailed_print=on duration=850 max_active_ues=750')
            sleep(900)
            exec('seq_start rate=1.5 id=10-15 detailed_print=on duration=850 max_active_ues=750')
        else
            exec('seq_start rate=1.2 id=1-6 detailed_print=on duration=850 max_active_ues=750')
            sleep(900)
            exec('seq_start rate=1.2 id=10-15 detailed_print=on duration=850 max_active_ues=750')
        end
        for loop=1, 3 do
            sleep(1800) --Sleep for 30mins
            exec('ue_disp state=IDLE format=long')
            sleep(5)
            exec('ue_disp state=ACTIVATING format=long')
            sleep(5)
            exec('ue_summary')
            sleep(5)
        end
        exec('seq_stop id=all rate=10')
        sleep(600)
        exec('seq_stop id=all rate=15')
        sleep(300)
    end
end

function petse_maxRRC_w12cells()
    require "multi_ue_sa_script_v5"
    exec('uec_l2_testmode_params fixed_csi_report=true')
    sleep(1)
    --exec('sim_debug_log level=0 gate=1')
    set_multi_amf_to_register_multiue(1,5,"311:489",1,9000)
    sleep(2)
    num_of_iterations = 8
    for iteration=1, num_of_iterations do
        print("Iteration-"..iteration.." Started")
        exec('seq_start rate=1 id=1-12 detailed_print=on duration=825 max_active_ues=750')
        sleep(21600)
        exec('seq_stop id=all rate=10')
        sleep(300)
    end

    for loop=1, 3 do
            sleep(1800) --Sleep for 30mins
            exec('ue_disp state=IDLE format=long')
            sleep(5)
            exec('ue_disp state=ACTIVATING format=long')
            sleep(5)
            exec('ue_summary')
            sleep(5)
        end

end

function pet_seq24_start_UC2()
-- Start SA Multi-UEs Peak Tput
    require "multi_ue_sa_script_v5"
    exec('uec_l2_testmode_params fixed_csi_report=true')
    sleep(1)
    exec('sim_debug_log level=0 gate=1')
    sleep(1)
    set_multi_amf_to_register_multiue(1,5,"311:489",1,48)
    sleep(1)
    exec('seq_start rate=1 id=25-48 detailed_print=on duration=100 max_active_ues=2')
    sleep(105)
    exec('ue_disp state=ACTIVE format=long')
    sleep(10)
    exec('ue_summary')
end


------------------------------------------------------------------------------------------------------------------
---------------------------------------- performance team custom function ----------------------------------------
------------------------------------------------------------------------------------------------------------------
function performance_common_lua_fdd(argp)
    --[=====[  DOCUMENTATION

        Use this lua if you want to use AIRPHONE created commands
        this functions wraps register_multiue_with_traffic_parallel to work with performance "Run Common Test"

    --]=====]
    require "commands_common"
    local args = convert_str_to_table(argp)
    performance_common_lua(args)
    print("performance_common_lua_fdd script completed")
end

function performance_common_lua_fdd_v2(argp)
    --[=====[  DOCUMENTATION

        Use this lua if you want to use all the new performance functionalities
            - max ue per cell
            - active cells ( inactive cells will not attach any UEs )
        this functions wraps register_multiue_with_traffic_parallel_v2 to work with performance "Run Common Test"

    --]=====]
    require "commands_common"
    local args = convert_str_to_table(argp)
    performance_common_lua_v2(args)
    print("performance_common_lua_fdd_v2 script completed")
end

function performance_common_seq_lua_fdd(argp)
    --[=====[  DOCUMENTATION

        Use this lua if you want to attach sequentially
        (Does not support some functionalities: TBA )

    --]=====]
    require "commands_common"
    local args = convert_str_to_table(argp)
    performance_common_seq_lua(args)
    print("performance_common_seq_lua_fdd script completed")
end

function performance_common_seq_active_cells_lua_fdd(argp)
    require "commands_common"
    local args = convert_str_to_table(argp)
    performance_common_seq_active_cells_lua(args)
    print("performance_common_seq_active_cells_lua_fdd script completed")
end

function ASOE_FDD_6Cells_72UEsPerCell_UL_DL()
    --[=====[  DOCUMENTATION

        OBSOLETE

    --]=====]
    require "multi_ue_sa_script_v5"
    exec('uec_l2_testmode_params fixed_csi_report=true')
    sleep(1)
    exec('sim_debug_log level=0 gate=1')
    sleep(1)
    set_multi_amf_to_register_multiue(1,5,"311:489",1,432)
    sleep(10)
    exec('seq_start rate=1 id=1000-1005 detailed_print=on duration=120 max_active_ues=72')
    sleep(120)
    print("ASOE_FDD_6Cells_72UEsPerCell_UL_DL script completed")
    exec('ue_summary')
end
