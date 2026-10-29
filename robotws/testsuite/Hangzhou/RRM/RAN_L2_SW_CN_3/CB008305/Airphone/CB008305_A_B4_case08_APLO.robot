# *** Settings ***
# Suite Setup    Common Suite Setup
# #Suite Teardown    Common Suite Teardown
# Test Setup    Common Test Setup
# #Test Teardown    Common Test Teardown
# Force Tags    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
# ...    owner_l3gao   AP    CRT    SBTS00    RAN_5G_TDD    RAN_5G    SBTS23R1    DL_mumimo
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
# ${SCFC_NAME}     SCFC_8305_case08_APLO.xml
# ${AIRPHONE_NAME}    IPHY_AEQE_2CELL_APLO_8DL4UL.xml
# ${WTS_NAME}      WTS_SANSA_n78_8SA_32NSA_8DL4UL_2CELL_MU_APLO.cfg
# @{LOG_NAME_LIST}    gnb_snapshot
# @{Rdparameter}    0x340000:15    #0x580264:3
# ${UE_NUM}  2
# &{GNBMIRRORINGCONFIGS}    BB_SLOT_1='false'   BB_SLOT_2='false'    BB_SLOT_5='true'    SYSCOM_MIRRORING='true'
# ...    L2HI_MIRRORING='true'   L2RT_MIRRORING='true'   CPRT_MIRRORING='false'  NUMBER_OF_FILES=30
# ${EGATE_TAG}      MUmimo
# ${BIP_TAG}    mumumo_bip
# 
# *** Test Cases ***
# CB008305_A_B4_case08_two_rank4_Ues_paired_online_change_maxNumLayerPerMuRbg
#     Modify 8305 Swconfig
#     Prepare gnb onair
#     Set 2UE different DOA and enhence SRS power
#     Attach '${UE_NUM}' SA UEs
#     Data buffer send to '${UE_NUM}' SA UE
# 
#     Online change maxNumLayerPerMuRbg and check mu pair    maxNumLayer=8    time=1
#     Online change maxNumLayerPerMuRbg and check mu pair    maxNumLayer=4    time=2
#     Online change maxNumLayerPerMuRbg and check mu pair    maxNumLayer=8    time=3
#     DeRegister ‘${UE_NUM}’ SA UEs
# 
# 
# *** Keywords ***
# Modify 8305 Swconfig
#     Add GNB swconfig    @{Rdparameter}
# 
# Online change maxNumLayerPerMuRbg and check mu pair
#     [Arguments]    ${maxNumLayer}    ${time}
#     log to console    online change maxNumLayerPerMuRbg ${maxNumLayer} time ${time}
#     Start capture gnb and ap syslog in 'maxNumLayerPerMuRbg_${maxNumLayer}_time${time}' file
# #    online change dlMuMaxNumLayerPerMuRbg '${maxNumLayer}'
#     Online change parameters    dlMuMaxNumLayerPerMuRbg=${maxNumLayer}
# #    Start collect bip log
# #    Wait for '1s' to stop bip log with name'maxNumLayerPerMuRbg_${maxNumLayer}_time${time}_bip'
#     Start collect ttitrace
#     Wait for '2s' to stop ttitrace with name'maxNumLayerPerMuRbg_${maxNumLayer}_time${time}_mu_pair_check'
#     run keyword if  ${maxNumLayer}==8    Wait until keyword succeeds    50s    12s     Check ue mu pair and tput is correct
#     run keyword if  ${maxNumLayer}==4    Wait until keyword succeeds    50s    12s     Check ue mu no pair and tput is correct
#     run keyword if  ${maxNumLayer}==8     check TP and bler with ttitrace   900    1
#     ...    maxNumLayerPerMuRbg_${maxNumLayer}_time${time}_mu_pair_check   case08_pair    4
#     run keyword if  ${maxNumLayer}==4     check TP and bler with ttitrace   450    1
#     ...    maxNumLayerPerMuRbg_${maxNumLayer}_time${time}_mu_pair_check   case08_no_pair    4
#     Stop capture gnb and ap syslog in 'maxNumLayerPerMuRbg_${maxNumLayer}_time${time}' file
# 
# online change dlMuMaxNumLayerPerMuRbg '${maxNumLayer}'
#     TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
#     Perform online change value    MRBTS-1/NRBTS-2/NRCELL-1/NRDLMUMIMO-1    dlMuMaxNumLayerPerMuRbg    ${maxNumLayer}    online
# #    Wait until keyword succeeds    600s    30s    Verify BTS Is Onair
#     TAF_ADMIN.teardown admin    connection=online
#     Wait '30s' for stable
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
# Attach '${UE_NUM}' SA UEs
#     Start capture gnb and ap syslog in 'SA_${UE_NUM}_ue_rrc' file
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
#     \   airphone_cleanup_egate_console_log
#     \   Log To Console    ${\n}-----register UE ${num} ------
# #    \   Start collect 'attach_ue${num}' tcpdump
#     \   Airphone SA Attach    ue_id=${num}
#     \   Airphone Set Traffic Type    ue_id=${num}    pdu_id=${num}    type=internal
#     \   Airphone Pdu Session Setup   ue_id=${num}    pdu_id=${num}   nwslice_id=1    gw_id=${num}
#     \   Wait '3s' for stabible
# #    \   Stop collect 'attach_ue${num}' tcpdump
#     \   Collect AP egate log    UE_${num}_rrc
#     \   run keyword and continue on failure     Check_rrc   UE_${num}_rrc
#     Stop capture gnb and ap syslog in 'SA_${UE_NUM}_ue_rrc' file
# 
# DeRegister ‘${UE_NUM}’ SA UEs
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
#     \   airphone_sa_detach    ue_id=${num}    timeout=5
#     \   Wait '2s' for stabible
# 
# Data buffer send to '${UE_NUM}' SA UE
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
#     \   SA send mutiple trf dl data    ${num}    10   175M    ${num}
#     \   SA send mutiple trf ul data    ${num}    2   20M    ${num}
#     wait '2s' for stable
# 
# Check_rrc
#     [Arguments]    ${EGATE_TAG}
#     check_log_with_au2anlysis    ${CURDIR}/ini/8305_SA_RRC.ini    p
#     ...   save_log_directory=${TEST_LOG_DIRECTORY()}/All/${EGATE_TAG}_egate
# 
# Set 2UE different DOA and enhence SRS power
#     airphone_execute_egate_command    ue_srs_beam_pos_nr profile_id\=1 init_pos\=0 srsMode\=fixed
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=ue_srs_beam_pos action\=activate profile_id\=1
#     airphone_execute_egate_command    ue_srs_beam_pos_nr profile_id\=2 init_pos\=2 srsMode\=fixed
#     airphone_execute_egate_command    ue_testmode_set_nr id\=2 testmode\=ue_srs_beam_pos action\=activate profile_id\=2
#     airphone_execute_egate_command    ul_sinr_testmode_nr profile_id\=10 sinr_target_srs\=100 sinr_target_pucch\=-300 noise_srs\=-1053
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=ul_sinr action\=activate profile_id\=10
#     airphone_execute_egate_command    ue_testmode_set_nr id\=2 testmode\=ul_sinr action\=activate profile_id\=10
# 
# 
# Check rrc log
#     Airphone_collect_egate_log_files    ${TEST_LOG_DIRECTORY()}/All/egate    unzip=TRUE
#     run keyword and continue on failure    check_log_with_au2anlysis  ini_path=${CURDIR}/ini/rrc_8305.ini    log_need_to_check=p
#    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/egate
# 
# Check ue mu pair and tput is correct
#     ${dl_tput1}    airphone_get_throughput_on_specific_scell    ue_id=1   scell_id=0    type=pdsch    tput_type=ave
#     ${dl_tput2}    airphone_get_throughput_on_specific_scell    ue_id=2    scell_id=0    type=pdsch    tput_type=ave
#     should be true    ${dl_tput1}>1200000
#     should be true    ${dl_tput2}>1200000
#     log to console    result is UE1_${dl_tput1} UE2_${dl_tput2} both UE target 1200000
# 
# 
# Check ue mu no pair and tput is correct
#     ${dl_tput1}    airphone_get_throughput_on_specific_scell    ue_id=1   scell_id=0    type=pdsch    tput_type=ave
#     ${dl_tput2}    airphone_get_throughput_on_specific_scell    ue_id=2    scell_id=0    type=pdsch    tput_type=ave
#     should be true    ${dl_tput1}>600000
#     should be true    ${dl_tput2}>600000
#     log to console    result is UE1_${dl_tput1} UE2_${dl_tput2} both UE target 600000
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
# Wait for '${time}' to stop ttitrace with name'${tti_tag}'
#     sleep   ${time}
#     ${pcap_path}    Stop GNB Ttitrace With Streaming Mode
#     Decoder Tttirace From Pcap To Csv    ${pcap_path}      ${test_log_directory()}/All/${tti_tag}_tti/tti