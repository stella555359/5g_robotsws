# *** Settings ***
# Suite Setup    Common Suite Setup
# #Suite Teardown    Common Suite Teardown
# Test Setup    Common Test Setup
# Test Teardown    Common Test Teardown
# Force Tags    CLOUD_5G_I_BOO_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD    owner_menzheng   AP    CRT    SBTS00    RAN_5G_TDD    RAN_5G
# Resource    ../../resources/KISS/robot/common_resource.robot
# Resource    ../../resources/sg10/internal_resource/internal_resource.robot
# 
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}     SCFC_8701_case10.xml
# ${AIRPHONE_NAME}    IPHY_AQQL_2ABIL_1CELL.xml
# ${COMAVALUE}    ${CURDIR}/coma/8701_coma_dft.txt
# ${WTS_NAME}    wts_8701_case10.cfg
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
# ${UE_NUM_SA}         6
# ${UE_NUM_NSA}         2
# ${EGATE_TAG}      MUmimo
# ${BIP_TAG}    mumumo_bip
# &{GNBMIRRORINGCONFIG}    BB_SLOT_2='true'    SYSCOM_MIRRORING='true'   L2HI_MIRRORING='true'   L2RT_MIRRORING='true'   CPRT_MIRRORING='false'
# ...    NUMBER_OF_FILES=30
# @{Rdparameter}    0x420062:1  0x800057:0
# 
# *** Test Cases ***
# CB008701_A_B302_case10_2SU_withAperidicSRS_only_6MU_dlMuMimoRankAdaption_Disabled_tapering
#     Modify 8701 Swconfig
#     Modify l1bypass
#     #Active GNB L2 feature debug traces
#     Prepare gnb onair
#     Execute AP Command before attach
#     Start capture gnb and ap syslog in 'SA_NSA_ue' file
#     Attach '${UE_NUM_SA}' SA UE and data buffer sent
#     Attach '${UE_NUM_NSA}' NSA UE and data buffer sent
#     UE send RANK2
#     Wait '20s' for stable
#     #Start collect bip log
#     #Wait for '3s' to stop bip log with name'${BIP_TAG}'
#     Start collect ttitrace
#     Wait for '3s' to stop ttitrace with name'tti'
#     run keyword and continue on failure    Check SA UE throughput
#     run keyword and continue on failure    Check NSA UE throughput
#     run keyword and continue on failure    Check Srs Resource
#     run keyword and continue on failure    Check ttitrace
#     Airphone SA Stop Data Traffic And Detach UE
#     Airphone NSA Stop Data Traffic And Detach UE
#     Stop capture gnb and ap syslog in 'SA_NSA_ue' file
# 
# *** Keywords ***
# Check UE '${num}' rrc log peridic
#     Airphone_collect_egate_log_files    ${TEST_LOG_DIRECTORY()}/All/egate_UE_${num}    unzip=TRUE
#     ${ret}     file match all       ${TEST_LOG_DIRECTORY()}/All/egate_UE_${num}/egate_console.log         .*crnti: (\\d+)
#     set suite variable     ${ue_rnti}    ${ret[0]}
#     run keyword and continue on failure    check_log_with_au2anlysis  ini_path=${CURDIR}/ini/RRC_peridicSRS_SA.ini    log_need_to_check=p
#    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/egate_UE_${num}
#    
# Check UE '${num}' rrc log AperidicSRS
#     Airphone_collect_egate_log_files    ${TEST_LOG_DIRECTORY()}/All/egate_UE_${num}    unzip=TRUE
#     run keyword and continue on failure    check_log_with_au2anlysis  ini_path=${CURDIR}/ini/RRC_AperidicSRS.ini    log_need_to_check=p
#    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/egate_UE_${num}
# 
# Check mupair in ttitrace
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_dl_case13_1.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# Modify l1bypass
#     copy_file    ${COMAVALUE}    ${test_log_directory()}/coma.py
#     Import Variables    ${test_log_directory()}/coma.py
#     Modify airphone l1bypass coma value for eight ue
#     ...    ${Hindex13}    ${Vindex7}    ${Hindex13}    ${Vindex7}
#     ...    ${Hindex10}    ${Vindex8}    ${Hindex10}    ${Vindex8}
#     ...    ${Hindex6}    ${Vindex7}    ${Hindex6}    ${Vindex7}
#     ...    ${Hindex2}    ${Vindex8}    ${Hindex2}    ${Vindex8}
#     ...    ${Hindex25}    ${Vindex7}    ${Hindex25}    ${Vindex7}
#     ...    ${Hindex21}    ${Vindex8}     ${Hindex21}    ${Vindex8}
#     ...    ${Hindex17}    ${Vindex7}     ${Hindex17}    ${Vindex7}
#     ...    ${Hindex14}    ${Vindex8}     ${Hindex14}    ${Vindex8}
# 
# check TP and bler with ttitrace
#     [Arguments]    ${throughput}    ${time_avg}    ${tti_file}    ${ini_file}
#     ${a}  get_ues_tbsize_by_sfn   ${test_log_directory()}/All/${tti_file}/tti_dl.csv
#     ...        ${test_log_directory()}/All/${tti_file}/tti_dl_new.csv   ${time_avg}   filter=dlFdSchedData.ackNack\=ACK
#     @{keys}  Get Dictionary Keys   ${a}
#     : FOR      ${key}     IN     @{keys}
#     \    ${result}   evaluate  ${a[${key}]}/${time_avg}/1024/1000
#     \    log to console   result is ${result}
#     \    log to console   TP is ${throughput}
#     \    should be true  ${result}>${throughput}
# #    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/${ini_file}.ini    log_need_to_check=i
# #    ...   save_log_directory=${TEST_LOG_DIRECTORY()}/All/${tti_file}/
# 
# Check ttitrace
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_case10.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# Modify 8701 Swconfig
#     Add GNB swconfig    0x420062:1  0x800057:0
#     Add GNB swconfig     0x10040:1
#     Add GNB swconfig     0x10041:1
#     Add GNB swconfig     0x1003F:1
#     Add GNB swconfig     0x1007C:1
#     Modify GNB swconfig    0x1002A:1
# 
# Attach NSA 8 UEs
#     : FOR    ${num}    IN RANGE    11    ${UE_NUM}+1
#     \   Airphone Nsa Attach    ${num}    profile_id=None
#     \   Wait '10s' for stable
# 
# NSA send data 8 UEs
#     : FOR    ${num}    IN RANGE    11    ${UE_NUM}+1
#     \   NSA send ue '${num}' mutiple trf '1' for each '150M' DL data
#     \   NSA send ue '${num}' mutiple trf '2' for each '150M' DL data
#     \   NSA send ue '${num}' mutiple trf '1' for each '30M' UL data
# 
# Check NSA UE throughput
#     Wait until keyword succeeds    60s    5s    Verify multi NSA UEs throughput
# 
# Verify multi NSA UEs throughput
#     : FOR    ${num}    IN RANGE    11    12+1
#     \    ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=8    type=pdsch    tput_type=ave
#     \    should_be_true    ${dl_throughput_pcell}>50000
# 
# Check SA UE throughput
#     Wait until keyword succeeds    60s    5s    Verify multi SA UEs throughput
# 
# Verify multi SA UEs throughput
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
#     \    ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=0    type=pdsch    tput_type=ave
#     \    should_be_true    ${dl_throughput_pcell}>100000
# 
# Attach '${UE_NUM_NSA}' NSA UE and data buffer sent
#     : FOR    ${num}    IN RANGE    11    12+1
#     \   airphone_cleanup_egate_console_log
#     \   Airphone Nsa Attach    ${num}    profile_id=None
#     \   Wait '3s' for stabible
#     \   Collect AP egate log    ${EGATE_TAG}_${num}
#     \   #Check UE '${num}' rrc log AperidicSRS
#     \   NSA send ue '${num}' mutiple trf '1' for each '175M' DL data
# 
# Airphone NSA Stop Data Traffic And Detach UE
#     : FOR    ${num}    IN RANGE    11    12+1
#     \    Airphone NSA Stop Data Traffic   ${num}    DL
#     \    Airphone NSA Detach    ${num}
# 
# Airphone SA Stop Data Traffic And Detach UE
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
#     \    Airphone SA Stop Data Traffic     ${num}     DL    ${num}
#     \    Airphone SA Detach    ue_id=${num}
# 
# 
# Attach '${UE_NUM_SA}' SA UE and data buffer sent
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
#     \   airphone_cleanup_egate_console_log
#     \   Airphone SA Attach    ue_id=${num}
#     \   Wait '2s' for stabible
#     \   Airphone Set Traffic Type    ue_id=${num}    pdu_id= ${num}    type=internal
#     \   Airphone Pdu Session Setup    ue_id=${num}   pdu_id=${num}   nwslice_id=1   gw_id=${num}
#     \   Wait '3s' for stabible
#     \   Collect AP egate log    ${EGATE_TAG}_${num}
#     \   #Check UE '${num}' rrc log peridic
#     \   SA send mutiple trf dl data    ${num}    3    175M   ${num}
# 
# Execute AP Command before attach
#     airphone_cleanup_egate_console_log
#     Airphone Setup X2 Connection
# 
# UE send RANK2
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=1 cqi\=15 cqi_mode\=fixed ri\=1 ri_mode\=fixed
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1-6 testmode\=csi_override action\=activate profile_id\=1 scell\=0
#     airphone_execute_egate_command    ue_testmode_set_nr id\=11-12 testmode\=csi_override action\=activate profile_id\=1 scell\=0
# 	
# Check Srs Resource
#     ${ret}     file match all       ${TEST_LOG_DIRECTORY()}/All/MUmimo_1_egate/egate_console.log         .*crnti: (\\d+)
#     set suite variable     ${ue_rnti}    ${ret[0]}
#     run keyword and continue on failure    check_log_with_au2anlysis  ini_path=${CURDIR}/ini/RRC_peridicSRS_case11.ini    log_need_to_check=p
#    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/MUmimo_1_egate
#     ${ret}     file match all       ${TEST_LOG_DIRECTORY()}/All/MUmimo_6_egate/egate_console.log         .*crnti: (\\d+)
#     set suite variable     ${ue_rnti}    ${ret[0]}
#     run keyword and continue on failure    check_log_with_au2anlysis  ini_path=${CURDIR}/ini/RRC_peridicSRS_case11.ini    log_need_to_check=p
#    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/MUmimo_6_egate
#     run keyword and continue on failure    check_log_with_au2anlysis  ini_path=${CURDIR}/ini/RRC_AperidicSRS.ini    log_need_to_check=p
#    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/MUmimo_11_egate
