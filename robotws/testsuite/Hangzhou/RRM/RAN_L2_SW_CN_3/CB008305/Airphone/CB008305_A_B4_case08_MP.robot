# *** Settings ***
# Suite Setup    Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup    Common Test Setup
# Test Teardown    Common Test Teardown
# Force Tags        CRT    SBTS00   RAN_5G_TDD    RAN_5G   owner_l3gao    CLOUD_5G_I_MP_AP_LO
# Resource    ../../resources/KISS/robot/common_resource.robot
# Resource    ../../resources/sg10/internal_resource/internal_resource.robot
# Documentation     chbw change from 100mhz
# ...   256qam enable
# ...   dmrs_fdm enable
# ...   1208 frame  4X4 mimo
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${UE_ID1}          1
# ${UE_ID2}          2
# ${SCFC_NAME}     SCFC_8305_case08_MP.xml
# ${AIRPHONE_NAME}    IPHY_AQQL_2CELL_APLO.xml
# ${WTS_NAME}      WTS_2cell_SA_NSA.lua
# @{LOG_NAME_LIST}    gnb_snapshot
# ${UE_NUM}  2
# &{GNBMIRRORINGCONFIGS}    BB_SLOT_1='false'   BB_SLOT_2='false'    BB_SLOT_5='true'    SYSCOM_MIRRORING='true'
# ...    L2HI_MIRRORING='true'   L2RT_MIRRORING='true'   CPRT_MIRRORING='false'  NUMBER_OF_FILES=30
# ${EGATE_TAG}      MUmimo
# ${BIP_TAG}    mumumo_bip
# 
# ${TP_PEAK_DL}    1300000
# ${TP_PEAK_DL_MU}  5200000
# ${TP_PEAK_UL}    150000
# 
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
# ${PROFILE4}    ul_mimo_srs_beam_pos_nr profile_id\=4 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=1 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=24 zenith\=-10 srs_transmit_power_per_port\=-300,-300,-250,-250
# ${PROFILE3}    ul_mimo_srs_beam_pos_nr profile_id\=3 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=1 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-15 zenith\=-30 srs_transmit_power_per_port\=-300,-300,-280,-280
# ${PROFILE5}    ul_mimo_srs_beam_pos_nr profile_id\=5 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=3 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-45 zenith\=-30 srs_transmit_power_per_port\=-300,-300,-280,-280
# 
# *** Test Cases ***
# CB008305_A_B4_case08_two_rank4_Ues_paired_online_change_maxNumLayerPerMuRbg
#     step1:get ready for gnb
#     step2:attach UEs with Pos and get rnti
#     step3:online change maxNumLayer and check pairing
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
# step3:online change maxNumLayer and check pairing
#     Online change maxNumLayerPerMuRbg and check mu pair    maxNumLayer=8    time=1
#     Online change maxNumLayerPerMuRbg and check mu pair    maxNumLayer=4    time=2
#     Online change maxNumLayerPerMuRbg and check mu pair    maxNumLayer=8    time=3
#     DeRegister ‘${UE_NUM}’ SA UEs
# 
# Online change maxNumLayerPerMuRbg and check mu pair
#     [Arguments]    ${maxNumLayer}    ${time}
#     log to console    online change maxNumLayerPerMuRbg ${maxNumLayer} time ${time}
#     Start capture gnb and ap syslog in 'maxNumLayerPerMuRbg_${maxNumLayer}_time${time}' file
#     Online change parameters    dlMuMaxNumLayerPerMuRbg=${maxNumLayer}
# #    Start collect bip log
# #    Wait for '1s' to stop bip log with name'maxNumLayerPerMuRbg_${maxNumLayer}_time${time}_bip'
#     Wait '15s' for stable
#     Start collect ttitrace
#     Wait for '1s' to stop ttitrace with name'maxNumLayerPerMuRbg_${maxNumLayer}_time${time}_mu_pair_check'
#     run keyword if  ${maxNumLayer}==8    Wait until keyword succeeds    50s    12s     Check ue mu pair and tput is correct
#     run keyword if  ${maxNumLayer}==4    Wait until keyword succeeds    50s    12s     Check ue mu no pair and tput is correct
#     run keyword if  ${maxNumLayer}==8     check TP and bler with ttitrace   900    1
#     ...    maxNumLayerPerMuRbg_${maxNumLayer}_time${time}_mu_pair_check   case08_pair    4
#     run keyword if  ${maxNumLayer}==4     check TP and bler with ttitrace   450    1
#     ...    maxNumLayerPerMuRbg_${maxNumLayer}_time${time}_mu_pair_check   case08_no_pair    4
#     Stop capture gnb and ap syslog in 'maxNumLayerPerMuRbg_${maxNumLayer}_time${time}' file
# 
# Online change parameters
#     [Arguments]    ${dlMuMaxNumLayerPerMuRbg}
#     ${template}    OperatingSystem.Get File    ${CONFIG_DIR_PATH}/${SW_BRANCH}/JSON/delta_8305_case08.json
#     log to console    ${template}
#     ${message} =    Replace Variables    ${template}
#     Create File    ${CONFIG_DIR_PATH}/${SW_BRANCH}/JSON/delta_8305_case08_modified.json    ${message}
#     Online recommissioning with delta json file
#     ...   ${CONFIG_DIR_PATH}/${SW_BRANCH}/JSON/delta_8305_case08_modified.json
#     Wait until keyword succeeds    1500s    60s    Verify BTS Is Onair
# 
# Check ue mu pair and tput is correct
#     ${dl_tput1}    airphone_get_throughput_on_specific_scell    ue_id=1   scell_id=0    type=pdsch    tput_type=ave
#     ${dl_tput2}    airphone_get_throughput_on_specific_scell    ue_id=2    scell_id=0    type=pdsch    tput_type=ave
#     run keyword and continue on failure    should be true    ${dl_tput1}>1200000
#     run keyword and continue on failure    should be true    ${dl_tput2}>1200000
#     log to console    result is UE1_${dl_tput1} UE2_${dl_tput2} both UE target 1200000
#     log to console   egate UE1 tp is ${dl_tput1}
#     log to console   egate UE2 tp is ${dl_tput2}
# 
# Check ue mu no pair and tput is correct
#     ${dl_tput1}    airphone_get_throughput_on_specific_scell    ue_id=1   scell_id=0    type=pdsch    tput_type=ave
#     ${dl_tput2}    airphone_get_throughput_on_specific_scell    ue_id=2    scell_id=0    type=pdsch    tput_type=ave
#     run keyword and continue on failure    should be true    ${dl_tput1}>600000
#     run keyword and continue on failure    should be true    ${dl_tput2}>600000
#     log to console    result is UE1_${dl_tput1} UE2_${dl_tput2} both UE target 600000
#     log to console   egate UE1 tp is ${dl_tput1}
#     log to console   egate UE2 tp is ${dl_tput2}
# 
# Wait for '${time}' to stop ttitrace with name'${tti_tag}'
#     sleep   ${time}
#     ${pcap_path}    Stop GNB Ttitrace With Streaming Mode
#     Decoder Tttirace From Pcap To Csv    ${pcap_path}      ${test_log_directory()}/All/${tti_tag}_tti/tti
# 
# Add RD
#     Add GNB swconfig    0x340000:15
#     Add GNB swconfig    0x9D0000:15
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
#     \    SA send mutiple trf dl data    ${num}    8   175M   ${gw_pdu_r}    tcp
#     \    SA send mutiple trf ul data    ${num}    1    170M   ${gw_pdu_r}
# 
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
# check TP and bler with ttitrace
#     [Arguments]    ${throughput}    ${time_avg}    ${tti_file}    ${ini_file}    ${ue_rank}
# #    ${a}  get_ues_tbsize_by_sfn   ${test_log_directory()}/All/${tti_file}_tti/tti_dl.csv
# #    ...        ${test_log_directory()}/All/${tti_file}_tti/tti_dl_new.csv   ${time_avg}   filter=dlFdSchedData.ackNack\=ACK
# #    @{keys}  Get Dictionary Keys   ${a}
# #    : FOR      ${key}     IN     @{keys}
# #    \    ${result}   evaluate  ${a[${key}]}/${time_avg}/1024/1000
# #    \    log to console   result is ${result}
# #    \    ${throughput_target}    evaluate  (${throughput}*${ue_rank})/4
# #    \    should be true  ${result}>${throughput_target}
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/${ini_file}.ini    log_need_to_check=i
#     ...   save_log_directory=${TEST_LOG_DIRECTORY()}/All/${tti_file}_tti/
# 
# DeRegister ‘${UE_NUM}’ SA UEs
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
#     \   airphone_sa_detach    ue_id=${num}    timeout=5
#     \   Wait '2s' for stabible