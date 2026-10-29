# *** Settings ***
# Test Timeout    60 minutes
# Suite Setup    Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup    Common Test Setup
# Test Teardown    Common Test Teardown
# Force Tags    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    owner_l10wang    AP    CRT    SBTS00    RAN_5G_TDD    RAN_5G   SBTS23R1
# Resource    ../../resources/KISS/robot/common_resource.robot
# Resource    ../../resources/sg10/internal_resource/internal_resource.robot
# 
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${COMAVALUE}    ${CURDIR}/coma/8305.txt
# ${SCFC_NAME}      CB008305_SCFC_case25_aplo.xml
# ${AIRPHONE_NAME}    IPHY_AEQE_1CELL.xml
# ${WTS_NAME}    wts_1086_7_TAS_abio.cfg
# ${UE_ID1}    1
# ${UE_ID2}    2
# ${GW_ID1}    1
# ${GW_ID2}    2
# ${PDU_ID}    1
# ${SLICE_ID}    1
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
# 
# *** Test Cases ***
# CB008305_C_B5_case25_2UE_rank3_rank4_pair_Eirp_PMcounter_check_basedon2200
#     Prepare gnb onair
#     run keyword and continue on failure    Start capture gnb and ap syslog in 'after_onair' file
#     airphone_cleanup_egate_console_log
#     Set UE1 and UE2 Pos
#     Airphone Set Traffic Type    ${UE_ID1}    ${PDU_ID}    internal
#     Airphone Set Traffic Type    ${UE_ID2}    ${PDU_ID}    internal
#     Airphone SA Attach    ue_id=${UE_ID1}
#     Airphone Pdu Session Setup    ${UE_ID1}    ${PDU_ID}    ${SLICE_ID}    ${GW_ID1}
#     Airphone SA Attach    ue_id=${UE_ID2}
#     Airphone Pdu Session Setup    ${UE_ID2}    ${PDU_ID}    ${SLICE_ID}    ${GW_ID2}
#     Check rrc log
#     Send DL data to UE and check throughput
#     Check mupair in ttitrace
#     Check EIRP counters
#     Detach SA UEs
# 
# 
# *** Keywords ***
# Set UE1 and UE2 Pos
#     airphone_execute_egate_command    ue_srs_beam_pos_nr profile_id\=1 init_pos\=0 srsMode\=fixed
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=ue_srs_beam_pos action\=activate profile_id\=1
#     airphone_execute_egate_command    ue_srs_beam_pos_nr profile_id\=2 init_pos\=3 srsMode\=fixed
#     airphone_execute_egate_command    ue_testmode_set_nr id\=2 testmode\=ue_srs_beam_pos action\=activate profile_id\=2
# 
#     airphone_execute_egate_command    ul_sinr_testmode_nr profile_id\=5 sinr_target_srs\=100 noise_srs\=-1053
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=ul_sinr action\=activate profile_id\=5
#     airphone_execute_egate_command    ue_testmode_set_nr id\=2 testmode\=ul_sinr action\=activate profile_id\=5
# 
# Internal send DL data
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
#     \    Airphone SA Start Data Traffic    ${num}    DL    100M    pdu_id=1    duration=6000s
#     \    ...    trf_id=${num}
#     \    Wait '3s ' to stable
# 
# Wait '${time} ' to stable
#     sleep    ${time}
# 
# Send DL data to UE and check throughput
#      SA send mutiple trf dl data   ${UE_ID1}    4    175M
#      SA send mutiple trf dl data   ${UE_ID2}    4    175M
#      Wait '5s ' to stable
#      Start collect ttitrace
#      Wait for '2s' to stop ttitrace with name'tti'
#      Wait '50s ' to stable
#     : FOR    ${num}    IN RANGE    1    3
#     \   ${pcell_tp}=    airphone_get_throughput_on_specific_scell    ${num}    0    type=pdsch    tput_type=ave
#     \   Log To Console    UE ${num} dl throughput: ${pcell_tp}
#     \   should be true    ${pcell_tp}<270000
# 
# 
# Detach SA UEs
#     : FOR    ${num}    IN RANGE    1    3
#     \   airphone_sa_detach    ue_id=${num}
#     \   Wait '3s' for stabible
# 
# Check mupair in ttitrace
#     run keyword and continue on failure     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_dl_case25.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# Check EIRP counters
#      Wait '60s' for stabible
#     ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=5min
#     Wait Throughput Timer    ${remaining_time}
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}pmcounter${/}
# 	${PM_counter_value_M55324C00101}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55324C00101    cell_id=1
# 	${PM_counter_value_M55324C00464}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55324C00464    cell_id=1
#     ${PM_counter_value_M55324C00334}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55324C00334    cell_id=1
#     ${PM_counter_value_M55324C00337}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55324C00337    cell_id=1
# 	should be true     ${PM_counter_value_M55324C00334} > 0
#   should be true     ${PM_counter_value_M55324C00337} > 0
# 
# 
# 
# Check rrc log
#     Airphone_collect_egate_log_files    ${TEST_LOG_DIRECTORY()}/All/egate    unzip=TRUE
#     run keyword and continue on failure    check_log_with_au2anlysis  ini_path=${CURDIR}/ini/rrc_8305.ini    log_need_to_check=p
#    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/egate
# 
# 
# Modify l1bypass
#     copy_file    ${COMAVALUE}    ${test_log_directory()}/coma.py
#     Import Variables    ${test_log_directory()}/coma.py
#     Modify airphone l1bypass coma value for eight ue
#     ...    ${Hindex10}    ${Vindex10}    ${Hindex0}    ${Vindex0}
#     ...    ${Hindex17}    ${Vindex5}    ${Hindex8}    ${Vindex0}
#     ...    ${Hindex17}    ${Vindex6}    ${Hindex0}    ${Vindex0}
#     ...    ${Hindex24}    ${Vindex9}    ${Hindex8}    ${Vindex0}
#     ...    ${Hindex24}    ${Vindex9}    ${Hindex0}    ${Vindex0}
#     ...    ${Hindex24}    ${Vindex9}    ${Hindex0}    ${Vindex0}
#     ...    ${Hindex0}    ${Vindex0}    ${Hindex0}    ${Vindex0}
#     ...    ${Hindex0}    ${Vindex0}    ${Hindex8}    ${Vindex0}
# 
