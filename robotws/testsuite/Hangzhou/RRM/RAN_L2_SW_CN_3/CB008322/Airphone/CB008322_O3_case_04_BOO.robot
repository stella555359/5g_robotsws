# *** Settings ***
# Suite Setup    Common Suite Setup
# #Suite Teardown    Common Suite Teardown
# Test Setup    Common Test Setup
# #Test Teardown    Common Test Teardown
# Force Tags    Author_lei.4.gao@nokia-sbell.com    AP    SBTS00    RAN_5G_TDD    RAN_5G
# ...   CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
# Resource    ../../resources/KISS/robot/common_resource.robot
# Resource    ../../resources/sg10/internal_resource/internal_resource.robot
# 
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}      SCFC_8322_O3_case04_BOO.xml
# ${AIRPHONE_NAME}    IPHY_2AQQL_2FDD_E3_GL.xml
# ${WTS_NAME}    wts_8322_4cell_SA_NSA_2TDD_2FDD_case36.lua
# @{LOG_NAME_LIST}    gnb_snapshot
# ${UE_NUM_SA}    1
# ${UE_NUM}    1
# 
# ${FILTER_f1ap_rrc_itf_l2PS}    itf_l2_ps_user_usersetupreq||itf_l2_ps_user_usersetupreq_t||itf_l2_ps_user_usermodifyreq
# ...    ||itf_l2_ps_user_usermodifyreq_t||itf_l2_ps_user_bearersetupresp||itf_l2_ps_user_usermodifyresp||itf_l2_ps_user_reconfigurationrequiredind
# ...    ||itf_l2_ps_user_reconfigurationrequiredind||itf_l2_ps_user_rrcconnectionreconfcompletedreq||f1ap||rrc||e1ap
# @{titles_tasSrsResourceInd}    3gpp.sfn    3gpp.slot    3gpp.rnti    itf_l2_ps_user_ReconfigurationRequiredInd_t.tasSrsResourceInd
# ...    itf_l2_ps_user_ReconfigurationRequiredInd_t.ueIdDu
# @{titles_duID_Crnti}    3gpp.sfn    3gpp.slot    3gpp.rnti    f1ap.GNB_DU_UE_F1AP_ID
# @{titles_ue_capability}    f1ap.GNB_DU_UE_F1AP_ID    nr-rrc.parallelTxSRS_PUCCH_PUSCH    nr-rrc.powerClass_v1530
# ...    nr-rrc.c1
# #((nr-rrc.parallelTxSRS_PUCCH_PUSCH == 0) && (nr-rrc.parallelTxSRS_PUCCH_PUSCH == 0)) && (nr-rrc.c1 == 9)
# 
# ${PROFILE2}    ul_mimo_srs_beam_pos_nr profile_id\=2 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=0 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=60 zenith\=40 srs_transmit_power_per_port\=-280,-280,-280,-280
# ${PROFILE3}    ul_mimo_srs_beam_pos_nr profile_id\=3 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=1 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-0 zenith\=-30 srs_transmit_power_per_port\=-300,-300,-280,-280
# ${PROFILE4}    ul_mimo_srs_beam_pos_nr profile_id\=4 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=2 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=30 zenith\=40 srs_transmit_power_per_port\=-300,-300,-280,-280
# ${PROFILE5}    ul_mimo_srs_beam_pos_nr profile_id\=5 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=3 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=15 zenith\=-30 srs_transmit_power_per_port\=-300,-300,-280,-280
# ${PROFILE6}    ul_mimo_srs_beam_pos_nr profile_id\=6 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=0 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=0 zenith\=40 srs_transmit_power_per_port\=-300,-300,-280,-280
# ${PROFILE7}    ul_mimo_srs_beam_pos_nr profile_id\=7 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=1 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-15 zenith\=-30 srs_transmit_power_per_port\=-280,-280,-280,-280
# ${PROFILE8}    ul_mimo_srs_beam_pos_nr profile_id\=8 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=2 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-35 zenith\=40 srs_transmit_power_per_port\=-300,-300,-280,-280
# ${PROFILE9}    ul_mimo_srs_beam_pos_nr profile_id\=9 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=3 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-50 zenith\=-30 srs_transmit_power_per_port\=-300,-300,-280,-280
# 
# ${TP_PEAK_DL}    1300000  #1.1gbps
# ${TP_PEAK_UL}    150000   #211mbps
# 
# *** Test Cases ***
# CB008322_E3_case37_subbandBeam_interwork_TDD_TDD_FDD_FDD_CA_8X4mimo_PUSCH_shorten_with_transition state
#     step1:get ready for gnb
#     step2:attach UE1 and check RRC
# #    step3:send full buffer for UEs and check logs
# #    step4:detach and reattach ue11_to_ue14 and check rrc
# #    step5:override UE1 to rank1 and check logs
# #    step6:detach and reattach ue1 and check rrc
# #    step7:online change bfSubbandSize and run case again
# #    Stop capture gnb and ap syslog in 'after_onair' file
# 
# *** Keywords ***
# step1:get ready for gnb
#     Log To Console   \n-------------step1:get ready for gnb---------------
# 	Add RD
# 	Get and Update BSR File		par_of_bsr_name=BSR_AQQL_6_H6_ALN60_ARP60_N01_COVERAGE_00392_00001
# 	creat syslog fail log tag
# 	Prepare gnb onair
# 	Start capture gnb and ap syslog in 'after_onair' file
# 	Airphone Cleanup Egate Console Log
# 
# step2:attach UE1 and check RRC
#     Log To Console   \n-------------step2:attach UE1 and check RRC---------------
#     Create SRS_pos profile
# 	Attach SA UEs with f1ap    ue_start=1    ue_end=${UE_NUM}
# 	set '${UE_NUM}' SA UEs Pos
# 
# step3:send full buffer for UEs and check logs
#     Log To Console   \n-------------step3:send full buffer for UEs and check logs---------------
#     SA send data for all 20UEs
# 	run keyword and continue on failure	   Check SA UE throughput    ue_start=1    ue_end=${UE_NUM}
#     Collect ttitrace and Check    tti_tag=tti_step3    ini_file=Case27_step3_tti
# 
# step4:detach and reattach ue11_to_ue14 and check rrc
#     Log To Console   \n-------------step4:detach and reattach ue11_to_ue14 and check rrc---------------
#     Airphone SA Detach UE    11    14
#     Attach SA UEs with f1ap    11    14
#     run keyword and continue on failure	   Check SA UE throughput    ue_start=1    ue_end=8
#     Collect ttitrace and Check    tti_tag=tti_step4    ini_file=Case27_step4_tti
# 
# step5:override UE1 to rank1 and check logs
#     Log To Console   \n-------------step5:override UE1 to rank1 and check logs---------------
#     Start collect UE f1ap    step5_ue1_aperisrs_ue5RTbeam
#     Airphone SA Stop Data    ue_start=6    ue_end=8
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=2 cqi\=15 cqi_mode\=fixed ri\=0 ri_mode\=fixed
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=csi_override action\=activate profile_id\=2 scell\=0  #rank1
#     Wait '5s' for stable
#     Stop collect UE f1ap    step5_ue1_aperisrs_ue5RTbeam
#     Check UE srs_switch from s1ap    step5_ue1_aperisrs_ue5RTbeam    Case27_step5_F1ap_1
#     SA send data for UEs    ue_start=6    ue_end=8
#     Wait '5s' for stable
#     run keyword and continue on failure	   Check SA UE throughput    ue_start=2    ue_end=8
#     Collect ttitrace and Check    tti_tag=tti_step5    ini_file=Case27_step5_tti
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=2 cqi\=15 cqi_mode\=fixed ri\=3 ri_mode\=fixed
#     Wait '5s' for stable
#     run keyword and continue on failure	   Check SA UE throughput    ue_start=1    ue_end=8
# 
# step6:detach and reattach ue1 and check rrc
#     Log To Console   \n-------------step6:detach and reattach ue1 and check rrc---------------
#     Airphone SA Detach UE    1    1
#     Attach SA UEs with f1ap    1    1
#     SA send data for UEs    ue_start=1    ue_end=1
#     run keyword and continue on failure	   Check SA UE throughput    ue_start=1    ue_end=8
#     Collect ttitrace and Check    tti_tag=tti_step6    ini_file=Case27_step6_tti
#     Airphone SA Detach UE
# 
# step7:online change bfSubbandSize and run case again
#     Log To Console   \n-------------step7:online change bfSubbandSize and run case again---------------
#     Online change bfSubbandSize enabled
#     Attach SA UEs with f1ap    ue_start=1    ue_end=18    tag=2
#     SA send data for all 20UEs
# 	run keyword and continue on failure	   Check SA UE throughput    ue_start=1    ue_end=8
#     Collect ttitrace and Check    tti_tag=tti_step3    ini_file=Case27_step7_tti    tag=2
# 
# Online change bfSubbandSize enabled
#     Online recommissioning with delta json file    ${CONFIG_DIR_PATH}/${SW_BRANCH}/JSON/delta_8322_case27_16PRB.json
#     Wait until keyword succeeds    600s    30s    Verify BTS Is Onair
#     Wait '15s' for stable
# 
# step5:set 4port high power for UEs and check logs
#     Log To Console   \n-------------step5:set 4port high power for UEs and check logs---------------
#     Set ports power and creat file    profile_id=3    port1_power=-500    port2_power=-500    port3_power=-500    port4_power=-500
#     : FOR    ${num}    IN RANGE    ${UE_NUM_SA}    0    -1
#     \    Start collect UE f1ap    step5_srsModify_${num}
#     \    airphone_execute_egate_command    ue_testmode_set_nr id\=${num} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=3
#     \    Wait '2s' for stable
#     \    Stop collect UE f1ap    step5_srsModify_${num}
#     Check UE srs_switch from s1ap    step5_srsModify_2    Case16_step5_F1ap_2
#     run keyword and continue on failure	   Check SA UE throughput    UE1_layer=4    UE2_layer=4
#     Collect ttitrace and Check    tti_tag=tti_step5    ini_file=Case16_step5_tti
# 
# 
# 
# step6:set 2port low power for UEs and check logs
#     Log To Console   \n-------------step6:set 2port low power for UEs and check logs---------------
#     Set ports power and creat file    profile_id=4    port1_power=-500    port2_power=-500    port3_power=-750    port4_power=-750
#     : FOR    ${num}    IN RANGE    ${UE_NUM_SA}    0    -1
#     \    airphone_execute_egate_command    ue_testmode_set_nr id\=${num} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=4
#     \    Wait '1s' for stable
#     Wait '4s' for stable
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
# creat syslog fail log tag
#     ${custom_error}    Create list    WRN/L2-PS
#     append to list    ${custom_error}    ERR RT
#     append to list    ${custom_error}    ERR/l1_application_rt
#     append to list    ${custom_error}    ERR/ctrlNrDlCsiRs
#     append to list    ${custom_error}    ERR/ctrlCommon
#     append to list    ${custom_error}    ERR/ctrlNrUlSrs
#     append to list    ${custom_error}    ERR/L2-PS
#     append to list    ${custom_error}    ERR/WRN/L2-PS
#     append to list    ${custom_error}    WRN/.uplane/L2-PS
#     Log To Console    custom_error are ${custom_error}
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
#     ...    ${TEST_LOG_DIRECTORY()}/All/${bip_file}/f1ap.csv    ${FILTER_f1ap_rrc_itf_l2PS}    ${titles_duID_Crnti}
#     ${gnb_du_id_list}    Get col_values from bip csv    ${TEST_LOG_DIRECTORY()}/All/${bip_file}/f1ap.csv    f1ap.GNB_DU_UE_F1AP_ID
#     Set Test Variable    ${ue${ue_id}_gnb_du_id}    ${gnb_du_id_list[0]}
#     ${ue_rnti}    Get col_values from bip csv    ${TEST_LOG_DIRECTORY()}/All/${bip_file}/f1ap.csv    3gpp.rnti
#     set suite variable     ${ue${ue_id}_rnti}    ${ue_rnti[0]}
#     Log To Console   \n------UE${ue_id} gnb_du_id is ${ue${ue_id}_gnb_du_id},crnti is ${ue${ue_id}_rnti}-----
# 
# check RRC logs from F1ap
#     [Arguments]     ${bip_file}    ${ini_path}
#     Log To Console   check RRC logs from F1ap
#     Run Keyword And ignore error    Convert BIP To CSV
#     ...    ${TEST_LOG_DIRECTORY()}/All/${bip_file}/${bip_file}.pcap
#     ...    ${TEST_LOG_DIRECTORY()}/All/${bip_file}/f1ap.csv    ${FILTER_f1ap_rrc_itf_l2PS}    ${titles_ue_capability}
#     run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/${ini_path}.ini     i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${bip_file}/
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
#     ...    ${TEST_LOG_DIRECTORY()}/All/${bip_file}/f1ap.csv    ${FILTER_f1ap_rrc_itf_l2PS}    @{titles_tasSrsResourceInd}
#     run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/${ini_path}.ini     i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${bip_file}/
# #get F1AP and UE id for test end
# 
# 
# Set ports power and creat file
#     [Arguments]     ${profile_id}    ${port1_power}    ${port2_power}    ${port3_power}=-750    ${port4_power}=-750
#     ${cmd}   Catenate    ul_mimo_srs_beam_pos_nr profile_id\=${profile_id} mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=2 test_type\=SRS
#     ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=15 zenith\=0
#     ...    srs_transmit_power_per_port\=${port1_power},${port2_power},${port3_power},${port4_power}
#     airphone_execute_egate_command    ${cmd}
# 
# Collect bip and Check
#     Start collect bip log
#     Wait for '1s' to stop bip log with name'${BIP_TAG1}'
# 
# Add RD
#     Add GNB swconfig    0x580717:0
# 
# Collect ttitrace and Check
#     [Arguments]     ${tti_tag}    ${ini_file}    ${tag}=1
# 	Start collect ttitrace
#     Wait for '1s' to stop ttitrace with name'${tti_tag}_${tag}'
#     run keyword and continue on failure	   Check ttitrace with ini    ${tti_tag}_${tag}    ${ini_file}
#     split_8322_tti    ${TEST_LOG_DIRECTORY()}/All/${tti_tag}_${tag}/tti_dl.csv
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
# SA send data for UEs
#     [Arguments]     ${ue_start}    ${ue_end}
#     : FOR    ${num}    IN RANGE    ${ue_start}    ${ue_end}+1
#     \    SA send mutiple trf dl data    ${num}    1   120M   1    tcp
#     \    SA send mutiple trf ul data    ${num}    1    10M   1
# 
# SA send data for all 20UEs
#     : FOR    ${num}    IN RANGE    1    5
#     \    SA send mutiple trf dl data    ${num}    1   120M   1    tcp
#     \    SA send mutiple trf ul data    ${num}    1    10M   1
#     Wait '3s' for stable
#     : FOR    ${num}    IN RANGE    5    9
#     \    SA send mutiple trf dl data    ${num}    1   120M   1    tcp
#     \    SA send mutiple trf ul data    ${num}    1    10M   1
#     Wait '3s' for stable
#     : FOR    ${num}    IN RANGE    9    19
#     \    SA send mutiple trf dl data    ${num}    1   10k   1    tcp
#     \    SA send mutiple trf ul data    ${num}    1   10k   1
# 
# Check SA UE throughput
#     [Arguments]     ${ue_start}    ${ue_end}
#     Wait until keyword succeeds    48s    8s    Verify multi SA UEs throughput    ${ue_start}    ${ue_end}
# 
# Verify multi SA UEs throughput
#     [Arguments]     ${ue_start}    ${ue_end}
#     ${UEs_TP_DL}   create list
#     ${UEs_TP_UL}   create list
#     : FOR    ${num}    IN RANGE    ${ue_start}    ${ue_end}+1
#     \    ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=0    type=pdsch    tput_type=ave
#     \    ${ul_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=0    type=pusch    tput_type=ave
#     \    run keyword and continue on failure    should_be_true    ${dl_throughput_pcell}>120000
#     \    run keyword and continue on failure    should_be_true    ${ul_throughput_pcell}>10000
#     \    append to list    ${UEs_TP_DL}    ${dl_throughput_pcell}
#     \    append to list    ${UEs_TP_UL}    ${ul_throughput_pcell}
#     log to console    UE${ue_start} to UE${UE_NUM_SA} DL_TP_result are ${UEs_TP_DL}
#     log to console    UE${ue_start} to UE${UE_NUM_SA} UL_TP_result are ${UEs_TP_UL}
# 
# 
# Get '${UE_NUM_SA}' UEs rnti
#    : FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
# 	\   ${ue_rnti}    file match all   ${TEST_LOG_DIRECTORY()}/All/attach_UE${num}_egate/egate_console.log.001   crnti: (\\d+)
# 	\   set suite variable     ${ue${num}_rnti}    ${ue_rnti[0]}
# 	\   Log To Console   UE_ID${num} Crnti is ${ue${num}_rnti}
# 
# Airphone SA Detach UE
#     [Arguments]     ${ue_start}=1    ${ue_end}=${UE_NUM_SA}
#     : FOR    ${num}    IN RANGE    ${ue_start}    ${ue_end}+1
#     \    Airphone SA Detach    ue_id=${num}
# 
# 
# Attach SA UEs with f1ap
#     [Arguments]     ${ue_start}=1    ${ue_end}=${UE_NUM_SA}    ${tag}=1
#     : FOR    ${num}    IN RANGE    ${ue_start}    ${ue_end}+1
#     \   Start collect UE f1ap    UE${num}_attach_f1ap_${tag}
#     \   Airphone SA Attach    ue_id=${num}
#     \   Airphone Set Traffic Type    ue_id=${num}    pdu_id=1    type=internal
#     \   Airphone Pdu Session Setup    ue_id=${num}   pdu_id=1   nwslice_id=1   gw_id=${num}
#     \   Wait '1s' for stable
#     \   Log To Console   attach UE${num} successfully
#     \   Stop collect UE f1ap    UE${num}_attach_f1ap_${tag}
#     \   Get Crnti and gnb_du_id from f1ap    UE${num}_attach_f1ap_${tag}    ${num}
#     \   check RRC logs from F1ap    UE${num}_attach_f1ap_${tag}    Case37_step2_F1ap_1
#     \   SA send mutiple trf ul data    ${num}    1   100k   1
# 
# Airphone SA Stop Data
#     [Arguments]     ${ue_start}=1    ${ue_end}=${UE_NUM_SA}
#     : FOR    ${num}    IN RANGE    ${ue_start}    ${ue_end}+1
#     \    Airphone SA Stop Data Traffic     ${num}     bi    1
# 
# Create SRS_pos profile
#     : FOR    ${num}    IN RANGE    2    ${UE_NUM}+2
#     \    airphone_execute_egate_command    ${PROFILE${num}}
# 
# set '${UE_NUM}' SA UEs Pos
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
#     \    ${num_r}    evaluate    ${num}+1
#     \    airphone_execute_egate_command    ue_testmode_set_nr id\=${num} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=${num_r}
# 
# 
# 
# 
# 
