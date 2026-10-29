-- Functions for Common Scripts for AP9000
-- Note currently, only support one configuration, 

function configure()
      require "3Cell_1UEC_1AMF_1UPF_PerAP_updated.lua"
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
	set_amf_to_register_multiue(1,5,"311:489",24)
    register_multiue_with_traffic_parallel(1,24,6,1,1,1,"mbps",1,150,"dl",1.6,"internal",1350,"yes",60)
end
function start_max_ul()
    require "multi_ue_sa_script_v5"
	set_amf_to_register_multiue(1,5,"311:489",24)
    register_multiue_with_traffic_parallel(1,24,6,1,1,1,"kbps",46000,2,"both",1.6,"internal",1350,"yes",60)
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
	require "6Cell_6UEC_5AMF_5UPF_PerAP_updated"
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
    exec('seq_stop id=all')
end

function pet_seq_start_for_odd_even_seq_grp()
    require "multi_ue_sa_script_v5"
    require "6Cell_6UEC_5AMF_5UPF_PerAP_updated"
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
    require "6Cell_6UEC_5AMF_5UPF_PerAP_updated"

	seq_id_set1 = FIRST_CELL_ID	--Seq_group start id '1'
	seq_id_set_diff = 3 --If user want to run seq_start id=1-3, then set value as diff as '3',
    seq_id_set2 = seq_id_set_diff	--If user wants to run for each or single seq_group, set same value as 'seq_id_set1' in 'seq_id_set_diff'
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

	seq_id_set1 = FIRST_CELL_ID	--Seq_group start id '1'
	seq_id_set_diff = 3 --If user want to run seq_start id=1-3, then set value as diff as '3',
	seq_id_set2 = seq_id_set_diff	--If user wants to run for each or single seq_group, set same value as 'seq_id_set1' in 'seq_id_set_diff'
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

function TDD_FR1_SA_500UE_Register ()
    exec('seq_start rate=1 id=1,3 detailed_print=on duration=580  max_active_ues=500')
    sleep(580)
    exec('ue_summary')
    sleep(1)
    print("TDD_FR1_SA_500UE_Register script completed")
end

function DSS_xp_connections()
exec('enb_xp_param id=1 ignore_xp=off xp_listening_socket=on')
sleep(1)
exec('enb_xp_param id=1 xp_peers=2')
sleep(1)
exec('enb_xp_link_up enb=1 target=2')
sleep(1)
exec('enb_x2_link_up enb=1 target=2')
sleep(1)
exec('enb_dss_param id=1 feature_flag=on message_sets=DMS3')
end

function DSS_cell_setup() 
    local cell = 1
    local dss_peer_cell_start = 1
    local tgt_cell = 1
    local new_id = 1
    for i=1, 5 do
          print(" ############ cell"..cell.." commands begins #################### ")
          exec("enb_cell_param enb=1 id="..new_id.." lte_nr_dss_mode=DSS_PHASE_3 antenna_ports_num=2")
          sleep(2)
          exec("enb_cell_dss_feature enb=1 id="..new_id.." nr_dl_peak_rate_increase=on")
          sleep(2)
          exec("enb_cell_dss_feature enb=1 id="..new_id.." superfast_allocation=off")
          sleep(2)
          exec("enb_dss_cell_param enb=1 id="..new_id.." dl_resource_sharing_algo=dl_prb_load_based")
          sleep(2)
          exec("enb_dss_configure_partnership enb=1 cell="..cell.." dss_peer=2:"..dss_peer_cell_start.."")
          sleep(2)
          exec("enb_crm_cell_resource_reservation enb=1 cell="..cell.." tgt_enb=2 tgt_cell="..tgt_cell.." assigned_dl_minimum_share_to_nr=30 assigned_dl_maximum_share_to_nr=100 assigned_dl_minimum_share_to_lte=15 assigned_dl_maximum_share_to_lte=70 assigned_ul_minimum_share_to_nr=20 assigned_ul_maximum_share_to_nr=70")
          sleep(2)
          exec("enb_crm_param id=1 ul_qos_load_meas_timer=200 dl_qos_load_meas_timer=200")
          sleep(2)
          exec("sim_trace enb=1 protocol=xp on")
          sleep(2)
          exec("enb_dss_establish_partnership enb=1 cell="..cell.." tgt_enb=2 tgt_cell="..tgt_cell.."")
          sleep(2)
          exec("enb_dss_cell_resource_reservation_dl enb=1 cell="..cell.." reset")
          sleep(2)
          exec("enb_dss_cell_resource_reservation_ul enb=1 cell="..cell.." reset")
          sleep(2)
          exec("enb_dss_dl_resource_cell_reservation cell="..cell.." enb=1 prb_area_reservation_list=0,0,0-10-none+0,0,5-10-none+0,0,9-10-none")
          sleep(2)
          exec("enb_dss_dl_resource_cell_reservation cell="..cell.." enb=1 reserved_fixed_normal_subframes=0000000000-0000000000-0000000000-0000000000-0000000000-0000000000-0000000000-0000000000")
          sleep(2)
          exec("enb_dss_dl_resource_cell_reservation cell="..cell.." enb=1 min_lte_nr_dss_ratio=30 max_lte_nr_dss_ratio=100")
          sleep(2)
          exec("enb_dss_cell_resource_coordination enb=1 cell="..cell.." tgt_enb=2 tgt_cell="..tgt_cell.." dir=DL")
          sleep(2)
          exec("enb_dss_ul_resource_cell_reservation cell="..cell.." enb=1 minimum_prb_share=30 maximum_prb_share=70")
          sleep(2)
          exec("enb_dss_cell_resource_coordination enb=1 cell="..cell.." tgt_enb=2 tgt_cell="..tgt_cell.." dir=UL")
          sleep(2)
          exec("enb_crm_status enb=1 cell="..cell.."")
          sleep(2)
          exec("enb_dss_resource_allocation enb=1 cell="..cell.." tgt_enb=2 tgt_cell="..tgt_cell.." dir=DL allocation_start_time=immediate dl_allocated_normal_subframes=1011111001-1111111111-1011111001-1111111111-1011111001-1111111111-1011111001-1111111111 dl_prb_area_allocation_list=0:0,106+1:0,106+2:0,106+3:0,106+4:0,106+5:0,106+6:0,106+7:0,106+8:0,106+9:0,106+10:0,106+11:0,106+12:0,106+13:0,106+14:0,106+15:0,106+16:0,106+17:0,106+18:0,106+19:0,106+20:0,106+21:0,106+22:0,106+23:0,106+24:0,106+25:0,106+26:0,106+27:0,106+28:0,106+29:0,106+30:0,106+31:0,106+32:0,106+33:0,106+34:0,106+35:0,106+36:0,106+37:0,106+38:0,106+39:0,106+40:0,106+41:0,106+42:0,106+43:0,106+44:0,106+45:0,106+46:0,106+47:0,106+48:0,106+49:0,106+50:0,106+51:0,106+52:0,106+53:0,106+54:0,106+55:0,106+56:0,106+57:0,106+58:0,106+59:0,106+60:0,106+61:0,106+62:0,106+63:0,106+64:0,106+65:0,106+66:0,106+67:0,106+68:0,106+69:0,106+70:0,106+71:0,106+72:0,106+73:0,106+74:0,106+75:0,106+76:0,106+77:0,106+78:0,106+79:0,106")
          sleep(2)
          exec("enb_dss_resource_allocation enb=1 cell="..cell.." tgt_enb=2 tgt_cell="..tgt_cell.." dir=UL allocation_start_time=immediate ul_allocated_prb_list=0,3|5,70|103,3")
          sleep(2)
          cell= cell + 1
          dss_peer_cell_start= dss_peer_cell_start + 1
          tgt_cell= tgt_cell + 1
          new_id= new_id + 1
   end     
end

function FDD_SA_152UE_8CELL_RRCCONNECTED ()
    exec('uec_l2_testmode_params fixed_csi_report=true')
    sleep(1)
    exec('seq_start rate=1 id=9-16 detailed_print=on duration=170 max_active_ues=152')
    sleep(170)
    exec('ue_summary')
    sleep(1)
    print("TDD_FR1_SA_1216UE_Register script completed")
end

function FDD_SA_SUE_8CELL_DL_UL ()
    exec('uec_l2_testmode_params fixed_csi_report=true')
	sleep(1)
    exec('seq_start rate=1 id=1-8 detailed_print=on duration=10  max_active_ues=1')
    sleep(10)
    exec('ue_summary')
    sleep(1)
    print("TDD_FR1_SA_8UE_Register script completed")
end

function FDD_SA_20UE_8CELL_DL_UL ()
    exec('uec_l2_testmode_params fixed_csi_report=true')
    sleep(1)
    exec('seq_start rate=1 id=17-24 detailed_print=on duration=30  max_active_ues=20')
    sleep(30)
    exec('ue_summary')
    sleep(1)
    print("TDD_FR1_SA_160UE_Register script completed")
end

function FDD_SA_20UE_4CC_4F_DL ()
    exec('uec_l2_testmode_params fixed_csi_report=true')
    sleep(1)
    exec('seq_start rate=1 id=6 detailed_print=on duration=30  max_active_ues=20')
    sleep(30)
    exec('ue_summary')
    sleep(1)
    print("FDD_SA_20UE_4CC_4F_DL script completed")
end

function FDD_SA_80UE_MIX_BAND_DL_UL ()
    exec('uec_l2_testmode_params fixed_csi_report=true')
    sleep(1)
    exec('seq_start rate=1 id=1,3 detailed_print=on duration=30 max_active_ues=20')
    sleep(30)
    exec('seq_start rate=1 id=6,8 detailed_print=on duration=30 max_active_ues=20')
    sleep(30)
    exec('ue_summary')
    sleep(1)
    print("FDD_SA_80UE_MIX_BAND_DL_UL script completed")
end

function l2_testmode_param()
    exec('uec_l2_testmode_params fixed_csi_report=true')
end
