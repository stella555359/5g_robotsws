# *** Settings ***
# Suite Setup    Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup    Common Test Setup
# Test Teardown    Common Test Teardown
# Force Tags    CLOUD_5G_I_BOO_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD    owner_changyli   AP    CRT    SBTS00    RAN_5G_TDD    RAN_5G
# Resource    ../../resources/KISS/robot/common_resource.robot
# Resource    ../../resources/sg10/internal_resource/internal_resource.robot
# 
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}     SCFC_8701_case06.xml
# ${AIRPHONE_NAME}    IPHY_AQQL_2ABIL_1CELL.xml
# #${L1BYP_XML}      L1ByPTestModeConfiguration_case25_8ue.xml
# ${COMAVALUE}    ${CURDIR}/coma/8701_coma_dft.txt
# ${WTS_NAME}    wts_8701_case06.cfg
# ${UE_ID1}          1
# ${PDU_ID1}         1
# ${GW_ID1}          1
# ${SLICE_ID}       1
# ${UE_NUM_SA}         6
# ${UE_NUM_SA_VONR}         2
# ${UE_NUM_NSA}        2
# ${UE_NUM_NSA_ID}        11
# ${EGATE_TAG}      MUmimo
# ${TTI_TAG}      tti
# ${TTI_TAG_SWITCH}      tti_switch
# ${TTI_TAG_BLER}      tti_bler
# &{GNBMIRRORINGCONFIG}    BB_SLOT_2='true'    SYSCOM_MIRRORING='true'   L2HI_MIRRORING='true'   L2RT_MIRRORING='true'
# ...    CPRT_MIRRORING='false'    NUMBER_OF_FILES=30
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
# @{Rdparameter}    0x420062:1  0x800057:0
# 
# *** Test Cases ***
# CB008701_A_B301_case06_2SU_withGBR_6MU_with_nonGBR_and_dlMuMimoRankAdaption_Always_tapering_SA_NSA
#     Modify 8305 Swconfig
#     Modify l1bypass
#     Prepare gnb onair
#     Execute AP Command before attach
#     Start capture gnb and ap syslog in 'after_onair' file
#     Attach '${UE_NUM_SA}' SA UE
#     Attach '${UE_NUM_NSA}' NSA UE and data buffer sent
#     Send GBR data to SA UE
#     Send Non GBR data to SA UE
#     UE '3' fix RANK2
#     UE '4' fix RANK2
#     UE '5' fix RANK1
#     UE '6' fix RANK1
#     UE '11' fix RANK2
#     UE '12' fix RANK2
# #    Collect AP egate log    ${EGATE_TAG}
#     Wait '2s' for stable
# 
#     Start collect ttitrace
#     Wait for '3s' to stop ttitrace with name'${TTI_TAG}'
# 
#     run keyword and continue on failure    Check SA UE throughput
#     run keyword and continue on failure    Check NSA UE throughput
# 
#     run keyword and continue on failure    Check PM counters
# 
#     Release VONR    5
# 	Release VONR    6
# 
# 	Send NON GBR data to SA GBR UE
# 	Wait '5s' for stable
# 
#     Start collect ttitrace
#     Wait for '3s' to stop ttitrace with name'${TTI_TAG_SWITCH}'
#     run keyword and continue on failure    Check switch ue ttitrace
# 
# #	#add bler
#     airphone_bler_testmode_nr    4    dl_bler=\120,1,1,1,5
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 scell\=0 testmode\=bler action\=activate profile_id\=4
#     airphone_bler_testmode_nr    5    dl_bler=\150,1,1,1,5
#     airphone_execute_egate_command    ue_testmode_set_nr id\=2 scell\=0 testmode\=bler action\=activate profile_id\=5
# 
#     Wait '15s' for stable
# #    Start collect bip log
# #    Wait for '1s' to stop bip log with name'${BIP_TAG}'
# #
#     Start collect ttitrace
#     Wait for '3s' to stop ttitrace with name'${TTI_TAG_BLER}'
# 
#     run keyword and continue on failure    Check Srs Resource
# 
# 	Airphone SA Stop Data Traffic And Detach UE
# 	Airphone NSA Stop Data Traffic And Detach UE
# 
#     Stop capture gnb and ap syslog in 'after_onair' file
# 
# *** Keywords ***
# Check UE '${num}' rrc log aperidic
#     Airphone_collect_egate_log_files    ${TEST_LOG_DIRECTORY()}/All/egate_UE_${num}    unzip=TRUE
#     ${ret}     file match all       ${TEST_LOG_DIRECTORY()}/All/egate_UE_${num}/egate_console.log    .*crnti: (\\d+)
#     set suite variable     ${ue_rnti}    ${ret[0]}
#     run keyword and continue on failure    check_log_with_au2anlysis  ini_path=${CURDIR}/ini/RRC_AperidicSRS_SA.ini
#     ...    log_need_to_check=p    save_log_directory=${TEST_LOG_DIRECTORY()}/All/egate_UE_${num}
# 
# 
# #Modify l1bypass
# #    copy_file    ${COMAVALUE}    ${test_log_directory()}/coma.py
# #    Import Variables    ${test_log_directory()}/coma.py
# #    Modify airphone l1bypass coma value for eight ue
# #    ...    ${Hindex13}    ${Vindex7}    ${Hindex13}    ${Vindex7}
# #    ...    ${Hindex10}    ${Vindex8}    ${Hindex10}    ${Vindex8}
# #    ...    ${Hindex6}    ${Vindex7}    ${Hindex6}    ${Vindex7}
# #    ...    ${Hindex2}    ${Vindex8}    ${Hindex2}    ${Vindex8}
# #    ...    ${Hindex25}    ${Vindex7}    ${Hindex25}    ${Vindex7}
# #    ...    ${Hindex21}    ${Vindex8}     ${Hindex21}    ${Vindex8}
# #    ...    ${Hindex17}    ${Vindex7}     ${Hindex13}    ${Vindex7}
# #    ...    ${Hindex14}    ${Vindex8}     ${Hindex10}    ${Vindex8}
# 
# 
# Modify l1bypass
#     copy_file    ${COMAVALUE}    ${test_log_directory()}/coma.py
#     Import Variables    ${test_log_directory()}/coma.py
#     Modify airphone l1bypass coma value for four profile eight ue
#     ...    ${Hindex13}    ${Vindex7}    ${Hindex13}    ${Vindex7}    ${Hindex13}    ${Vindex7}    ${Hindex13}    ${Vindex7}
#     ...    ${Hindex10}    ${Vindex8}    ${Hindex10}    ${Vindex8}    ${Hindex10}    ${Vindex8}    ${Hindex10}    ${Vindex8}
#     ...    ${Hindex6}    ${Vindex7}    ${Hindex6}    ${Vindex7}    ${Hindex6}    ${Vindex7}    ${Hindex6}    ${Vindex7}
#     ...    ${Hindex2}    ${Vindex8}    ${Hindex2}    ${Vindex8}    ${Hindex2}    ${Vindex8}    ${Hindex2}    ${Vindex8}
#     ...    ${Hindex25}    ${Vindex7}    ${Hindex25}    ${Vindex7}   ${Hindex25}    ${Vindex7}    ${Hindex25}    ${Vindex7}
#     ...    ${Hindex21}    ${Vindex8}     ${Hindex21}    ${Vindex8}    ${Hindex21}    ${Vindex8}     ${Hindex21}    ${Vindex8}
#     ...    ${Hindex17}    ${Vindex7}     ${Hindex13}    ${Vindex7}    ${Hindex17}    ${Vindex7}     ${Hindex13}    ${Vindex7}
#     ...    ${Hindex14}    ${Vindex8}     ${Hindex10}    ${Vindex8}    ${Hindex14}    ${Vindex8}     ${Hindex10}    ${Vindex8}
#     ...    srsNumCountSwitchProfile1=78000
# 
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
# 
# Modify 8305 Swconfig
# 	Add GNB swconfig    0x420062:1  0x800057:0
# 
# Check NSA UE throughput
#     Wait until keyword succeeds    60s    5s    Verify multi NSA UEs throughput
# 
# 
# Verify multi NSA UEs throughput
#     : FOR    ${num}    IN RANGE    11    ${UE_NUM_NSA}+11
#     \    ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=8
#     \    ...    type=pdsch    tput_type=ave
#     \    should_be_true    ${dl_throughput_pcell}>150000
# 
# 
# Check SA UE throughput
#     Wait until keyword succeeds    60s    5s    Verify multi SA UEs throughput
# 
# Verify multi SA UEs throughput
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
#     \    ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=0
#     \    ...    type=pdsch    tput_type=ave
#     \    Run Keyword If    ${num}!=${5} and ${num}!=${6}    should_be_true    ${dl_throughput_pcell}>150000
# 
# 
# Attach '${UE_NUM_NSA}' NSA UE and data buffer sent
#     : FOR    ${num}    IN RANGE    ${UE_NUM_NSA_ID}     ${UE_NUM_NSA_ID} +2
#     \   airphone_cleanup_egate_console_log
#     \   Airphone Nsa Attach    ${num}    profile_id=None
#     \   Wait '3s' for stabible
#     \   NSA send ue '${num}' mutiple trf '3' for each '150M' DL data
# #    \   NSA send ue '${num}' mutiple trf '1' for each '5M' UL data
#     \   Collect AP egate log    ${EGATE_TAG}_${num}
# 
# 
# Airphone NSA Stop Data Traffic And Detach UE
#     : FOR    ${num}    IN RANGE    ${UE_NUM_NSA_ID}     ${UE_NUM_NSA_ID}+2
#     \    Airphone NSA Detach    ${num}
# 
# Airphone SA Stop Data Traffic And Detach UE
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
#     \    Airphone SA Detach    ue_id=${num}
# 
# 
# Attach '${UE_NUM_SA}' SA UE
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
#     \   airphone_cleanup_egate_console_log
#     \   Airphone SA Attach    ue_id=${num}
#     \   Wait '1s' for stabible
#     \   Airphone Set Traffic Type    ue_id=${num}    pdu_id= ${num}    type=internal
#     \   Wait '1s' for stabible
#     \   Airphone Pdu Session Setup    ue_id=${num}   pdu_id=${num}   nwslice_id=1   gw_id=${num}
#     \   Wait '1s' for stabible
#     \   Collect AP egate log    ${EGATE_TAG}_${num}
#     \   Wait '3s' for stabible
# 
# 
# Send Non GBR data to SA UE
#     : FOR    ${num}    IN RANGE    1    5
#     \    SA send mutiple trf dl data    ${num}    3   175M   ${num}
# #    \    SA send mutiple trf ul data    ${num}    1    20M   ${num}
# 
# Send GBR data to SA UE
#     : FOR    ${num}    IN RANGE    5    7
#     \    airphone_execute_egate_command    ue_pdu_session_modify ue\=${num} pdu\=${num} qosflows_to_add\=2 by\=amf
#     \    Wait '1s' for stabible
#     \    airphone_execute_egate_command    ue_pdu_session_modify ue\=${num} pdu\=${num} qosflows_to_add\=3 by\=amf
#     \    Wait '1s' for stabible
#     \    airphone_execute_egate_command    trf_data_start ue\=${num} pdu\=${num} qfi\=3 trf_id\=1 mbps\=10 dir\=dl
#     \    Wait '1s' for stabible
# 
# 
# Send NON GBR data to SA GBR UE
#     : FOR    ${num}    IN RANGE    5    7
#     \    SA send mutiple trf dl data    ${num}    3   175M   ${num}
# 
# Execute AP Command before attach
#     airphone_cleanup_egate_console_log
#     Airphone Setup X2 Connection
# 
# 
# Release VONR
#     [Arguments]    ${UE_ID}
#     Airphone Pdu Session Modify    ${UE_ID}    ${UE_ID}    qosflows_to_del=2
#     Airphone Pdu Session Modify    ${UE_ID}    ${UE_ID}    qosflows_to_del=3
# 	Wait '5s' for stabible
# 
# UE '${ue_id}' fix RANK1
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=1 cqi\=15 cqi_mode\=fixed ri\=0 ri_mode\=fixed
#     airphone_execute_egate_command    ue_testmode_set_nr id\=${ue_id} testmode\=csi_override action\=activate profile_id\=1 scell\=0
# 
# UE '${ue_id}' fix RANK2
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=2 cqi\=15 cqi_mode\=fixed ri\=1 ri_mode\=fixed
#     airphone_execute_egate_command    ue_testmode_set_nr id\=${ue_id} testmode\=csi_override action\=activate profile_id\=2 scell\=0
# 
# 
# UE '${ue_id}' fix RANK3
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=3 cqi\=15 cqi_mode\=fixed ri\=2 ri_mode\=fixed
#     airphone_execute_egate_command    ue_testmode_set_nr id\=${ue_id} testmode\=csi_override action\=activate profile_id\=3 scell\=0
# 
# Check Srs Resource
#     ${ret}     file match all       ${TEST_LOG_DIRECTORY()}/All/MUmimo_1_egate/egate_console.log         .*crnti: (\\d+)
#     set suite variable     ${ue_rnti}    ${ret[0]}
#     run keyword and continue on failure    check_log_with_au2anlysis  ini_path=${CURDIR}/ini/RRC_peridicSRS_SA_case06.ini    log_need_to_check=p
#    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/MUmimo_1_egate
#    ${ret}     file match all       ${TEST_LOG_DIRECTORY()}/All/MUmimo_5_egate/egate_console.log         .*crnti: (\\d+)
#     set suite variable     ${ue_rnti}    ${ret[0]}
#     run keyword and continue on failure    check_log_with_au2anlysis  ini_path=${CURDIR}/ini/RRC_peridicSRS_SA_case06.ini    log_need_to_check=p
#    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/MUmimo_5_egate
#     run keyword and continue on failure    check_log_with_au2anlysis    ${CURDIR}/ini/RRC_peridicSRS_NSA_case06.ini    log_need_to_check=p
#     ...   save_log_directory=${TEST_LOG_DIRECTORY()}/All/MUmimo_11_egate
# 
# Check ttitrace
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_case06.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/
# 
# 
# Check switch ue ttitrace
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_case06_switch.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/
# 
# 
# Check PM counters
#     ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
#     Wait Throughput Timer    ${remaining_time}
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}pmcounter${/}
# 	${M55308C34019_PRB_DL_MU_MIMO_12LAYER}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C34019    cell_id=1
#     ${M55308C34011_PRB_DL_MU_MIMO_8LAYER}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C34011    cell_id=1
#     ${M55308C34015_PRB_DL_MU_MIMO_6PAIR_UE}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C34025   cell_id=1
# 
#     log to console     ${M55308C34011_PRB_DL_MU_MIMO_8LAYER}
#     log to console     ${M55308C34015_PRB_DL_MU_MIMO_6PAIR_UE}
#     should_be_true    ${M55308C34011_PRB_DL_MU_MIMO_8LAYER}>0
#     should_be_true    ${M55308C34015_PRB_DL_MU_MIMO_6PAIR_UE}>0
# 
