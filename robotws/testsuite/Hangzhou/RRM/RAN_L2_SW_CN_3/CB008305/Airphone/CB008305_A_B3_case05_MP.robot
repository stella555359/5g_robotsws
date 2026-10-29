# *** Settings ***
# Suite Setup    Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup    Common Test Setup
# Test Teardown    Common Test Teardown
# 
# Force Tags        CRT    SBTS00   RAN_5G_TDD    RAN_5G   owner_l3gao    CLOUD_5G_I_MP_AP_LO
# Resource    ../../resources/KISS/robot/common_resource.robot
# Resource    ../../resources/sg10/internal_resource/internal_resource.robot
# Documentation
# ...     check 0 5 10 15 20 five SE
# ...     owner_l3gao
# ...     check DMRS enable
# ...     check bler and retransmission
# ...     ptrs off /srs power reduced
# ...     tapering enable dueo default
# ...     PR674081
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${UE_ID1}          1
# ${UE_ID2}          2
# ${SCFC_NAME}     SCFC_8305_case05_MP.xml
# ${AIRPHONE_NAME}    IPHY_AQQL_2CELL_APLO_8x4_GL.xml
# ${WTS_NAME}      WTS_2cell_SA_NSA.lua
# @{LOG_NAME_LIST}    gnb_snapshot
# ${UE_NUM}  2
# 
# ${TP_PEAK_DL}    1300000
# ${TP_PEAK_DL_MU}  5200000
# ${TP_PEAK_UL}    150000
# 
# &{GNBMIRRORINGCONFIGS}    BB_SLOT_2='false'   BB_SLOT_1='false'    BB_SLOT_5='true'    SYSCOM_MIRRORING='false'
# ...    L2HI_MIRRORING='false'   L2RT_MIRRORING='false'   CPRT_MIRRORING='false'  NUMBER_OF_FILES=30
# ${SE_threshold}   20    #20 default   0 for ivan case
# ${par_of_bsr_name}       BSR_AQQL_6_H6_ALN60_ARP60_N01_COVERAGE_00392_00001
# 
# ${FILTER_f1ap_srsModify}    itf_l2_ps_user_reconfigurationrequiredind||rrc||f1ap||itf_l2_ps_user_usermodifyreq
# @{titles_tasSrsResourceInd}    3gpp.sfn    3gpp.slot    3gpp.rnti    itf_l2_ps_user_ReconfigurationRequiredInd_t.tasSrsResourceInd
# ...    itf_l2_ps_user_ReconfigurationRequiredInd_t.ueIdDu
# ${FILTER_f1ap_rrc_itl_l2ps}    f1ap||e1ap||rrc
# ...    ||itf_l2_ps_user_reconfigurationrequiredind||itf_l2_ps_user_usermodifyreq||itf_l2_ps_user_usersetupreq
# @{titles_duID_Crnti}    3gpp.sfn    3gpp.slot    3gpp.rnti    f1ap.GNB_DU_UE_F1AP_ID
# 
# ${PROFILE2}    ul_mimo_srs_beam_pos_nr profile_id\=2 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=0 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=51 zenith\=-30 srs_transmit_power_per_port\=-300,-300,-250,-250
# ${PROFILE3}    ul_mimo_srs_beam_pos_nr profile_id\=3 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=1 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=24 zenith\=-10 srs_transmit_power_per_port\=-300,-300,-250,-250
# ${PROFILE4}    ul_mimo_srs_beam_pos_nr profile_id\=4 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=1 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-15 zenith\=-30 srs_transmit_power_per_port\=-300,-300,-280,-280
# ${PROFILE5}    ul_mimo_srs_beam_pos_nr profile_id\=5 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=3 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-45 zenith\=-30 srs_transmit_power_per_port\=-300,-300,-280,-280
# 
# 
# *** Test Cases ***
# CB008305_A_B3_case05_two_rank2_Ues_paired_with_SE checking_based2200
#     step1:get ready for gnb
#     step2:attach UEs with Pos and get rnti
#     step3:Online change SE and check with rank2
#     step4:online change modulation 256qam and check
# 
# *** Keywords ***
# step1:get ready for gnb
# 	Add RD
# 	Get and Update BSR File		par_of_bsr_name=BSR_AQQL_6_H6_ALN60_ARP60_N01_COVERAGE_00392_00001
# 	Prepare gnb onair
# 	Airphone Cleanup Egate Console Log
# 
# step2:attach UEs with Pos and get rnti
#     Log To Console   \n-------------step2:attach UEs with Pos and get rnti---------------
#     Start capture only gnb syslog in 'step2_attach' file
#     Create SRS_pos profile
# 	Attach '${UE_NUM}' SA UEs with f1ap
# 	set '${UE_NUM}' SA UEs Pos
# 	SA send data '${UE_NUM}' UEs
# 	Wait '10s' for stable
# 	run keyword and continue on failure    Stop capture only gnb syslog in 'step2_attach' file
# 
# step3:Online change SE and check with rank2
#     Log To Console   \n-------------step3:Online change SE and check with rank2---------------
#     run keyword and continue on failure    Fix 2UE to rank2
#     run keyword and continue on failure    Online change SE and check    throughput=315    #330
#     run keyword and continue on failure    DeRegister ‘${UE_NUM}’ SA UEs
# 
# step4:online change modulation 256qam and check
#     Log To Console   \n-------------step4:online change modulation 256qam and check---------------
#     Start capture only gnb syslog in 'step4' file
#     run keyword and continue on failure    online change modulation and check    256qam
#     DeRegister ‘${UE_NUM}’ SA UEs
# 	run keyword and continue on failure    Stop capture only gnb syslog in 'step4' file
# 
# Attach '${UE_NUM_SA}' SA UEs with f1ap
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
#     \   ${gw_pdu_r}    evaluate    ${num}%10+1
#     \   Start collect UE f1ap    UE${num}_attach_f1ap
#     \   Airphone SA Attach    ue_id=${num}
#     \   Airphone Set Traffic Type    ue_id=${num}    pdu_id=${gw_pdu_r}    type=internal
#     \   Airphone Pdu Session Setup    ue_id=${num}   pdu_id=${gw_pdu_r}  nwslice_id=1   gw_id=${gw_pdu_r}
#     \   Wait '1s' for stable
#     \   Log To Console   attach UE${num} successfully
#     \   Stop collect UE f1ap    UE${num}_attach_f1ap
#     \   Get Crnti and gnb_du_id from f1ap    UE${num}_attach_f1ap    ${num}
# 
# SA send data '${UE_NUM_SA}' UEs
#     log to console    push data for UEs
#     ${ue_peak}    evaluate   int(${TP_PEAK_DL_MU}/1000/${UE_NUM})
#     ${data_num}    evaluate   int(${ue_peak}/175)
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
#     \   ${gw_pdu_r}    evaluate    ${num}%10+1
#     \    SA send mutiple trf dl data    ${num}    5   150M   ${gw_pdu_r}    tcp
#     \    SA send mutiple trf ul data    ${num}    1    170M   ${gw_pdu_r}
# 
# Online change parameters
#     [Arguments]    ${delta_9235_case10}    ${actMuAwareTdSch}    ${dlMuAwareCorrThd}    ${dlMuAwarePrbRatio}
#     ${template}    OperatingSystem.Get File    ${CONFIG_DIR_PATH}/${SW_BRANCH}/JSON/${delta_9235_case10}.json
#     log to console    ${template}
#     ${message} =    Replace Variables    ${template}
#     Create File    ${CONFIG_DIR_PATH}/${SW_BRANCH}/JSON/${delta_9235_case10}_modified.json    ${message}
#     Online recommissioning with delta json file
#     ...   ${CONFIG_DIR_PATH}/${SW_BRANCH}/JSON/${delta_9235_case10}_modified.json
#     Wait until keyword succeeds    1500s    60s    Verify BTS Is Onair
# 
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
# online change modulation and check
#     [Arguments]    ${DMRS_tag}
#     Online recommissioning with delta json file   ${CONFIG_DIR_PATH}/${SW_BRANCH}/JSON/delta_8305_${DMRS_tag}.json
#     Create SRS_pos profile
# 	Attach '${UE_NUM}' SA UEs with f1ap
# 	set '${UE_NUM}' SA UEs Pos
# 	SA send data '${UE_NUM}' UEs
#     run keyword and continue on failure    Fix 2UE to rank2
#     Wait until keyword succeeds    48s    8s     Check ue tput is correct    410
#     Start collect ttitrace
#     Wait for '1s' to stop ttitrace with name'tti_${DMRS_tag}_enable'
#     run keyword and continue on failure    check TP and bler with ttitrace   410    1
#     ...    tti_${DMRS_tag}_enable   8305_case05_ttitrace_TP
#     airphone_execute_egate_command    bler_testmode_nr profile_id\=2 dl_bler\=10,2,3,4,5   #add bler
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 scell\=0 testmode\=bler profile_id\=2 action\=activate
#     airphone_execute_egate_command    ue_testmode_set_nr id\=2 scell\=0 testmode\=bler profile_id\=2 action\=activate
#     Wait '5s' for stable
#     Start collect ttitrace
#     Wait for '1s' to stop ttitrace with name'tti_${DMRS_tag}_enable_addBler'
#     run keyword and continue on failure    check TP and bler with ttitrace   370    1
#     ...    tti_${DMRS_tag}_enable_addBler   8305_case05_ttitrace_TP_Bler
#     Wait '5s' for stable
#     Wait until keyword succeeds    48s    8s     Check ue tput is correct    370
# 
# Online change SE and check
#     [Arguments]    ${throughput}
#     Start capture gnb and ap syslog in 'online_change_se' file
#     : FOR    ${se_ret}    IN RANGE    ${SE_threshold}    -5    -5     #check 0 5 10 15 20 five SE
#     \    log to console  check SE_${se_ret}
#     \    set global variable    ${se_ret}
#     \    ${se}    Convert To Integer   ${se_ret}
#     \    Online recommissioning with delta json file   ${CONFIG_DIR_PATH}/${SW_BRANCH}/JSON/delta_8305_case05_SE_${se}_APLO.json
#     \    Wait '15s' for stable
#     \    Start collect ttitrace
#     \    Wait for '1s' to stop ttitrace with name'tti_se${se}'
# #    \    Start collect bip log
# #    \    Wait for '1s' to stop bip log with name'bip_se${se}'
#     \    run keyword if  ${se}>16   check TP and bler with ttitrace   ${throughput}/2    1    tti_se${se}   8305_case05_ttitrace_TP_SE2
#     \    run keyword if  ${se}<16    check TP and bler with ttitrace   ${throughput}    1    tti_se${se}   8305_case05_ttitrace_TP
#     \    Wait '10s' for stable
#     \    run keyword if  ${se}>16    Wait until keyword succeeds    48s    8s     Check ue tput is correct    ${throughput}/2
#     \    run keyword if  ${se}<16    Wait until keyword succeeds    48s    8s     Check ue tput is correct    ${throughput}
#     Stop capture gnb and ap syslog in 'online_change_se' file
# 
# DeRegister ‘${UE_NUM}’ SA UEs
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
#     \   airphone_sa_detach    ue_id=${num}    timeout=5
# 
# Check_rrc
#     [Arguments]    ${EGATE_TAG}
#     check_log_with_au2anlysis    ${CURDIR}/ini/8305_SA_RRC_2200.ini    p
#     ...   save_log_directory=${TEST_LOG_DIRECTORY()}/All/${EGATE_TAG}_egate
# 
# Fix 2UE to rank2
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=1 cqi\=15 ri\=1
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=csi_override action\=activate profile_id\=1
#     airphone_execute_egate_command    ue_testmode_set_nr id\=2 testmode\=csi_override action\=activate profile_id\=1
# 
# 
# Check ue tput is correct
#     [Arguments]    ${throughput}
#     ${dl_tput1}    airphone_get_throughput_on_specific_scell    ue_id=1   scell_id=0    type=pdsch    tput_type=ave
#     ${dl_tput2}    airphone_get_throughput_on_specific_scell    ue_id=2    scell_id=0    type=pdsch    tput_type=ave
#     should be true    (${dl_tput1}/1000)>${throughput}
#     should be true    (${dl_tput2}/1000)>${throughput}
#     log to console  UE TP result ${dl_tput1} and ${dl_tput2}
# 
# check TP and bler with ttitrace
#     [Arguments]    ${throughput}    ${time_avg}    ${tti_file}    ${ini_file}
#     ${a}  get_ues_tbsize_by_sfn   ${test_log_directory()}/All/${tti_file}/tti_dl.csv
#     ...        ${test_log_directory()}/All/${tti_file}/tti_dl_new.csv   ${time_avg}   filter=dlFdSchedData.ackNack\=ACK
#     @{keys}  Get Dictionary Keys   ${a}
#     : FOR      ${key}     IN     @{keys}
#     \    ${result}   evaluate  ${a[${key}]}/${time_avg}/1024/1000
#     \    log to console   actually TP is ${result}
#     \    log to console   target result TP is ${throughput}
#     \    should be true  ${result}>${throughput}
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/${ini_file}.ini    log_need_to_check=i
#     ...   save_log_directory=${TEST_LOG_DIRECTORY()}/All/${tti_file}/
# 
# Wait for '${time}' to stop ttitrace with name'${tti_tag}'
#     sleep   ${time}
#     ${pcap_path}    Stop GNB Ttitrace With Streaming Mode
#     Decoder Tttirace From Pcap To Csv    ${pcap_path}      ${test_log_directory()}/All/${tti_tag}/tti
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
#     Log To Console   Check '${bip_file}' srs_switch
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
#     [Arguments]     ${bip_file}    ${ini_paht}
#     Log To Console   Check '${bip_file}' srs_switch
#     Run Keyword And ignore error    Convert BIP To CSV
#     ...    ${TEST_LOG_DIRECTORY()}/All/${bip_file}/${bip_file}.pcap
#     ...    ${TEST_LOG_DIRECTORY()}/All/${bip_file}/f1ap.csv    ${FILTER_f1ap_srsModify}    ${titles_tasSrsResourceInd}
#     run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/${ini_paht}.ini     i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${bip_file}/
# 
# Add RD
#     Add GNB swconfig    0x340000:15
#     Add GNB swconfig    0x580542:0   #SE check
#     Add GNB swconfig    0x9D0000:15