# *** Settings ***
# Suite Setup    Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup    Common Test Setup
# Test Teardown    Common Test Teardown
# Force Tags    owner_l3gao    AP    SBTS00    RAN_5G_TDD    RAN_5G    CLOUD_5G_I_MP_AP_LO
# Resource    ../../resources/KISS/robot/common_resource.robot
# Resource    ../../resources/sg10/internal_resource/internal_resource.robot
# 
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# #${SCFC_NAME}      SCFC_8322_B32_CASE16.xml
# ${SCFC_NAME}      SCFC_8322_B32_CASE16_MP.xml
# ${AIRPHONE_NAME}    IPHY_AQQL_1CELL_APLO_One_link.xml
# ${WTS_NAME}    wts_8322_B32_SA_NSA_32UEs.cfg
# @{LOG_NAME_LIST}    gnb_snapshot
# ${UE_NUM_SA}    2
# 
# &{GNBMIRRORINGCONFIGS}    BB_SLOT_5='true'    SYSCOM_MIRRORING='true'   L2HI_MIRRORING='true'
# ...   L2RT_MIRRORING='true'   CPRT_MIRRORING='true'    NUMBER_OF_FILES=10
# ${TP_PEAK_DL}    1100000  #1.1gbps
# ${TP_PEAK_UL}    210000   #211mbps
# 
# ${PROFILE2}    ul_mimo_srs_beam_pos_nr profile_id\=2 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=0 step\=5 
#    ...    trigger_puxch_update\=0 test_type\=SRS
# ...   multi_path_config\=true num_of_nlos_paths\=1 azimuth\=0 zenith\=0 srs_transmit_power_per_port\=-350,-350,-350,-350
# ${PROFILE3}    ul_mimo_srs_beam_pos_nr profile_id\=3 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=0 step\=5 
#    ...    trigger_puxch_update\=0 test_type\=SRS
# ...   multi_path_config\=true num_of_nlos_paths\=1 azimuth\=0 zenith\=0 srs_transmit_power_per_port\=-750,-750,-750,-750
# ${PROFILE4}    ul_mimo_srs_beam_pos_nr profile_id\=4 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=0 step\=5 
#    ...    trigger_puxch_update\=0 test_type\=SRS
# ...   multi_path_config\=true num_of_nlos_paths\=1 azimuth\=0 zenith\=0 srs_transmit_power_per_port\=-300,-300,-700,-700
# 
# ${FILTER_f1ap_srsModify}    itf_l2_ps_user_reconfigurationrequiredind||rrc||f1ap||itf_l2_ps_user_usermodifyreq
# @{titles_tasSrsResourceInd}    3gpp.sfn    3gpp.slot    3gpp.rnti    itf_l2_ps_user_ReconfigurationRequiredInd_t.tasSrsResourceInd
# ...    itf_l2_ps_user_ReconfigurationRequiredInd_t.ueIdDu
# ${FILTER_f1ap_rrc_itl_l2ps}    f1ap||e1ap||rrc
# ...    ||itf_l2_ps_user_reconfigurationrequiredind||itf_l2_ps_user_usermodifyreq||itf_l2_ps_user_usersetupreq
# @{titles_duID_Crnti}    3gpp.sfn    3gpp.slot    3gpp.rnti    f1ap.GNB_DU_UE_F1AP_ID
# 
# 
# *** Test Cases ***
# CB008322_B32_case016_2UE_T2R4_100Mhz_SubBandSize0_RANK_mixed_SRSperiod20_CLoseLoopMimo_frame1070
#     step1:get ready for gnb
#     step2:attach UEs and get rnti
#     step3:send full buffer for UEs and check logs
#     step4:set 4port low power for UEs and check logs
#     step5:set 4port high power for UEs and check logs
#     step6:set 2port low power for UEs and check logs
#     step7:override multi_rank and check logs
#     Airphone SA Detach UE
# 
# *** Keywords ***
# step1:get ready for gnb
#     Log To Console   \n-------------step1:get ready for gnb---------------
# 	Add RD
# 	Get and Update BSR File		par_of_bsr_name=BSR_AQQL_6_H6_ALN60_ARP60_N01_COVERAGE_00392_00001
# 	Prepare gnb onair
# 	Start capture gnb and ap syslog in 'after_onair' file
# 	Airphone Cleanup Egate Console Log
# 
# step2:attach UEs and get rnti
#     Log To Console   \n-------------step2:attach UEs and get rnti---------------
#     Create SRS_pos profile
# 	Attach '${UE_NUM_SA}' SA UEs with f1ap
# 	set '${UE_NUM_SA}' SA UEs Pos file '2'
# 
# step3:send full buffer for UEs and check logs
#     Log To Console   \n-------------step3:send full buffer for UEs and check logs---------------
#     SA send data '${UE_NUM_SA}' UEs
# 	run keyword and continue on failure	   Check SA UE throughput    UE1_layer=4    UE2_layer=4
#     Collect ttitrace and Check    tti_tag=tti_step3    ini_file=Case16_step3_tti
#     Collect bip and Check    step3
# 
# step4:set 4port low power for UEs and check logs
#     Log To Console   \n-------------step4:set 4port low power for UEs and check logs---------------
# #    Set ports power and creat file    profile_id=2    port1_power=-750    port2_power=-750    port3_power=-750    port4_power=-750
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
#     \    Start collect UE f1ap    step4_srsModify_${num}
#     \    airphone_execute_egate_command    ue_testmode_set_nr id\=${num} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=3
#     \    Wait '2s' for stable
#     \    Stop collect UE f1ap    step4_srsModify_${num}
#     \    run keyword and continue on failure	   Check UE srs_switch from s1ap    step4_srsModify_${num}    Case16_step4_F1ap_${num}
#     Collect bip and Check    step4
#     run keyword and continue on failure	   Check SA UE throughput    UE1_layer=4    UE2_layer=4
#     Collect ttitrace and Check    tti_tag=tti_step4    ini_file=Case16_step4_tti
# 
# step5:set 4port high power for UEs and check logs
#     Log To Console   \n-------------step5:set 4port high power for UEs and check logs---------------
# #    Set ports power and creat file    profile_id=3    port1_power=-300    port2_power=-300    port3_power=-300    port4_power=-300
#     : FOR    ${num}    IN RANGE    ${UE_NUM_SA}    0    -1
#     \    Start collect UE f1ap    step5_srsModify_${num}
#     \    airphone_execute_egate_command    ue_testmode_set_nr id\=${num} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2
#     \    Wait '2s' for stable
#     \    Stop collect UE f1ap    step5_srsModify_${num}
#     Collect bip and Check    step5
#     Check UE srs_switch from s1ap    step5_srsModify_2    Case16_step5_F1ap_2
#     run keyword and continue on failure	   Check SA UE throughput    UE1_layer=4    UE2_layer=4
#     Collect ttitrace and Check    tti_tag=tti_step5    ini_file=Case16_step5_tti
# #
# step6:set 2port low power for UEs and check logs
#     Log To Console   \n-------------step6:set 2port low power for UEs and check logs---------------
# #    Set ports power and creat file    profile_id=4    port1_power=-300    port2_power=-300    port3_power=-750    port4_power=-750
#     : FOR    ${num}    IN RANGE    ${UE_NUM_SA}    0    -1
#     \    airphone_execute_egate_command    ue_testmode_set_nr id\=${num} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=4
#     \    Wait '2s' for stable
#     Wait '4s' for stable
#     Collect bip and Check    step6
#     run keyword and continue on failure	   Check SA UE throughput    UE1_layer=4    UE2_layer=2
#     Collect ttitrace and Check    tti_tag=tti_step6    ini_file=Case16_step6_tti
# 
# step7:override multi_rank and check logs
#     Log To Console   \n-------------step7:override multi_rank and check logs---------------
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=2 cqi\=15 cqi_mode\=fixed ri\=2 ri_mode\=fixed
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=3 cqi\=15 cqi_mode\=fixed ri\=1 ri_mode\=fixed
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=4 cqi\=15 cqi_mode\=fixed ri\=0 ri_mode\=fixed
#     Log To Console   \n-------------step7:override rank3 and check logs---------------
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
#     \    airphone_execute_egate_command    ue_testmode_set_nr id\=${num} testmode\=csi_override action\=activate profile_id\=2 scell\=0  #rank3
#     \    Wait '1s' for stable
#     Wait '5s' for stable
#     run keyword and continue on failure	   Check SA UE throughput    UE1_layer=3    UE2_layer=2
#     Collect ttitrace and Check    tti_tag=tti_step7_1    ini_file=Case16_step7_tti_1
#     Log To Console   \n-------------step7:override rank2 and check logs---------------
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
#     \    airphone_execute_egate_command    ue_testmode_set_nr id\=${num} testmode\=csi_override action\=activate profile_id\=3 scell\=0  #rank2
#     \    Wait '1s' for stable
#     Wait '5s' for stable
#     run keyword and continue on failure	   Check SA UE throughput    UE1_layer=2    UE2_layer=2
#     Collect ttitrace and Check    tti_tag=tti_step7_2    ini_file=Case16_step7_tti_2
#     Log To Console   \n-------------step7:override rank1 and check logs---------------
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
#     \    airphone_execute_egate_command    ue_testmode_set_nr id\=${num} testmode\=csi_override action\=activate profile_id\=4 scell\=0  #rank1
#     \    Wait '1s' for stable
#     Wait '5s' for stable
#     run keyword and continue on failure	   Check SA UE throughput    UE1_layer=1    UE2_layer=1
#     Collect ttitrace and Check    tti_tag=tti_step7_3    ini_file=Case16_step7_tti_3
# 
# Attach '${UE_NUM}' RANK3 SA UE
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
#     \   airphone_cleanup_egate_console_log
#     \   Airphone SA Attach    ue_id=${num}
#     \   Wait '2s' for stabible
#     \   Airphone Set Traffic Type    ue_id=${num}    pdu_id= ${num}    type=internal
#     \   Airphone Pdu Session Setup    ue_id=${num}   pdu_id=${num}   nwslice_id=1   gw_id=${num}
#     \   Wait '3s' for stabible
#     \   UE '${num}' send RANK3
# #    \   Collect AP egate log    ${EGATE_TAG}_${num}
# 
# 
# UE '${num}' send RANK3
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=1 cqi\=15 cqi_mode\=fixed ri\=2 ri_mode\=fixed
#     airphone_execute_egate_command    ue_testmode_set_nr id\=${num} testmode\=csi_override action\=activate profile_id\=1 scell\=0
# 
# 
# 
# #get F1AP and UE id for test start
# Start collect UE f1ap
#     [Arguments]     ${bip_file}
#     Log To Console    Start collect '${bip_file}' tcpdump
#     ${executor_oam_vm}    Create Dictionary    host=192.168.255.1    user=toor4nsn    password=oZPS0POrRieRtu
#     Start Tcpdump    name=${bip_file}    options= -i any -C 300    remote_info=${executor_oam_vm}
# 
# Stop collect UE f1ap
#     [Arguments]     ${bip_file}
#     Log To Console    Stop collect '${bip_file}' tcpdump
#     Stop Tcpdump    ${bip_file}    ${TEST_LOG_DIRECTORY()}/All/${bip_file}
# 
# Get Crnti and gnb_du_id from f1ap
#     [Arguments]     ${bip_file}    ${ue_id}
#     Log To Console   Check '${bip_file}' Crnti and gnb_du_id
#     Run Keyword And ignore error    Convert BIP To CSV
#     ...    ${TEST_LOG_DIRECTORY()}/All/${bip_file}/${bip_file}.pcap
#     ...    ${TEST_LOG_DIRECTORY()}/All/${bip_file}/f1ap.csv    ${FILTER_f1ap_rrc_itl_l2ps}    ${titles_duID_Crnti}
#     ${gnb_du_id_list}    Get col_values from bip csv    ${TEST_LOG_DIRECTORY()}/All/${bip_file}/f1ap.csv    f1ap.GNB_DU_UE_F1AP_ID
#     Set Test Variable    ${ue${ue_id}_gnb_du_id}    ${gnb_du_id_list[0]}
#     ${ue_rnti}    Get col_values from bip csv    ${TEST_LOG_DIRECTORY()}/All/${bip_file}/f1ap.csv    3gpp.rnti
#     set suite variable     ${ue${ue_id}_rnti}    ${ue_rnti[0]}
#     Log To Console   \n------UE${ue_id} gnb_du_id is ${ue${ue_id}_gnb_du_id},crnti is ${ue${ue_id}_rnti}-----
# 
# Get col_values from bip csv
#     [Arguments]    ${csv_file}    ${col_name}
#     ${col_values}    read_csv_columns    ${csv_file}    ${col_name}
#     ${col_value_list}    Remove Duplicates    ${col_values}
#     [return]     ${col_value_list}
# 
# Check UE srs_switch from s1ap
#     [Arguments]     ${bip_file}    ${ini_path}
#     Log To Console   Check '${bip_file}' srs_switch
#     Run Keyword And ignore error    Convert BIP To CSV
#     ...    ${TEST_LOG_DIRECTORY()}/All/${bip_file}/${bip_file}.pcap
#     ...    ${TEST_LOG_DIRECTORY()}/All/${bip_file}/f1ap.csv    ${FILTER_f1ap_srsModify}    ${titles_tasSrsResourceInd}
#     run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/${ini_path}.ini     i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${bip_file}/
# #get F1AP and UE id for test end
# 
# Analyse odftbeam in rrclog
#     [Arguments]     ${tag}    ${ini_file}
# 	check_log_with_au2anlysis    ${CURDIR}/ini/${ini_file}.ini    p    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${tag}_egate
# 
# Set ports power and creat file
#     [Arguments]     ${profile_id}    ${port1_power}    ${port2_power}    ${port3_power}=-750    ${port4_power}=-750
#     ${cmd}   Catenate    ul_mimo_srs_beam_pos_nr profile_id\=${profile_id} mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=2 test_type\=SRS
#     ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=15 zenith\=0
#     ...    srs_transmit_power_per_port\=${port1_power},${port2_power},${port3_power},${port4_power}
#     airphone_execute_egate_command    ${cmd}
# 
# Collect bip and Check
#     [Arguments]     ${bip_tag}
#     Start collect bip log
#     Wait for '1s' to stop bip log with name'${bip_tag}'
# 
# Set UE '${UE_ID}' position1
#     airphone_execute_egate_command    ul_mimo_srs_beam_pos_nr profile_id\=2 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=2 test_type\=SRS
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2
# 
# Set UE '${UE_ID}' low power
#     ${cmd}   Catenate    ul_mimo_srs_beam_pos_nr profile_id\=2 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=2 test_type\=SRS
#     ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=15 zenith\=0 srs_transmit_power_per_port\=-750,-750,-750,-750
# 
# Add RD
#     Add GNB swconfig    0x800070:0  	#rdRtBwvDowngradeMethod
#     Add GNB swconfig	0x580717:0		# rdPdcchApplyToSeparateStreams, default=true
# 
# Collect ttitrace and Check
#     [Arguments]     ${tti_tag}    ${ini_file}
# 	Start collect ttitrace
#     Wait for '1s' to stop ttitrace with name'${tti_tag}'
#     run keyword and continue on failure	   Check ttitrace with ini    ${tti_tag}    ${ini_file}
#     split_8322_tti    ${TEST_LOG_DIRECTORY()}/All/${tti_tag}/tti_dl.csv
# 
# Wait for '${time}' to stop ttitrace with name'${tti_tag}'
#     sleep   ${time}
#     ${pcap_path}    Stop GNB Ttitrace With Streaming Mode
#     log to console  ${\n}---decode tti start---
#     Decoder Tttirace From Pcap To Csv    ${pcap_path}    ${test_log_directory()}/All/${tti_tag}/tti
# 
# Check ttitrace with ini
#     [Arguments]     ${tti_tag}    ${ini_file}
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/${ini_file}.ini   log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${tti_tag}/
# 
# SA send data '${UE_NUM_SA}' UEs
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
#     \    SA send mutiple trf dl data    ${num}    4   175M   ${num}    tcp
#     \    SA send mutiple trf ul data    ${num}    1    175M   ${num}
# 
# Check SA UE throughput
#     [Arguments]     ${UE1_layer}    ${UE2_layer}
#     Wait until keyword succeeds    48s    8s    Verify multi SA UEs throughput    ${UE1_layer}    ${UE2_layer}
# 
# Verify multi SA UEs throughput
#     [Arguments]     ${UE1_layer}    ${UE2_layer}
#     ${UEs_TP_DL}   create list
#     ${UEs_TP_UL}   create list
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
#     \    ${TP_DL_perUE_target}   evaluate  ${TP_PEAK_DL}/${UE_NUM_SA}*${UE${num}_layer}/4   #downlin cellpeak/UE number*rank4/ue_layer
#     \    ${TP_UL_perUE_target}   evaluate  ${TP_PEAK_UL}/${UE_NUM_SA}   #uplink cellpeak/UE number*rank4/ue_layer
#     \    ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=0    type=pdsch    tput_type=ave
#     \    ${ul_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=0    type=pusch    tput_type=ave
#     \    run keyword and continue on failure    should_be_true    ${dl_throughput_pcell}>${TP_DL_perUE_target}
#     \    run keyword and continue on failure    should_be_true    ${ul_throughput_pcell}>${TP_UL_perUE_target}
#     \    append to list    ${UEs_TP_DL}    ${dl_throughput_pcell}
#     \    append to list    ${UEs_TP_UL}    ${ul_throughput_pcell}
#     log to console    cell_DL_TP_target is ${TP_PEAK_DL},UE_DL_TP_target is ${TP_DL_perUE_target}
#     log to console    cell_UL_TP_target is ${TP_PEAK_UL},UE_DL_TP_target is ${TP_UL_perUE_target}
#     log to console    UE1 to UE${UE_NUM_SA} DL_TP_result are ${UEs_TP_DL}
#     log to console    UE1 to UE${UE_NUM_SA} UL_TP_result are ${UEs_TP_UL}
# 
# 
# Get '${UE_NUM_SA}' UEs rnti
#    : FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
# 	\   ${ue_rnti}    file match all   ${TEST_LOG_DIRECTORY()}/All/attach_UE${num}_egate/egate_console.log.001   crnti: (\\d+)
# 	\   set suite variable     ${ue${num}_rnti}    ${ue_rnti[0]}
# 	\   Log To Console   UE_ID${num} Crnti is ${ue${num}_rnti}
# 
# Airphone SA Detach UE
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
#     \    Airphone SA Detach    ue_id=${num}
#     Stop capture gnb and ap syslog in 'after_onair' file
# 
# Attach '${UE_NUM_SA}' SA UEs with f1ap
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
#     \   Start collect UE f1ap    UE${num}_attach_f1ap
#     \   Airphone SA Attach    ue_id=${num}
#     \   Airphone Set Traffic Type    ue_id=${num}    pdu_id=${num}    type=internal
#     \   Airphone Pdu Session Setup    ue_id=${num}   pdu_id=${num}   nwslice_id=1   gw_id=${num}
#     \   Wait '1s' for stable
#     \   Log To Console   attach UE${num} successfully
#     \   Stop collect UE f1ap    UE${num}_attach_f1ap
#     \   Get Crnti and gnb_du_id from f1ap    UE${num}_attach_f1ap    ${num}
# 
# Create SRS_pos profile
#     : FOR    ${num}    IN RANGE    2    5
#     \    airphone_execute_egate_command    ${PROFILE${num}}
# 
# set '${UE_NUM_SA}' SA UEs Pos file '${file_id}'
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
#     \    airphone_execute_egate_command    ue_testmode_set_nr id\=${num} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=${file_id}
