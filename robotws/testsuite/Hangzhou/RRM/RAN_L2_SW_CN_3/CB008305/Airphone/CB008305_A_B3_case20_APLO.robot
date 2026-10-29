# *** Settings ***
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags    owner_menzheng    AP    CRT    SBTS00    RAN_5G_TDD    RAN_5G    CLOUD_5G_I_MP_AP_LO
# Test Timeout      60 minutes
# Resource          ../../resources/KISS/robot/common_resource.robot
# Resource          ../../resources/sg10/internal_resource/internal_resource.robot
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}      SCFC_8305_case20_MPAPLO.xml
# ${COMAVALUE}    ${CURDIR}/coma/8305.txt
# ${AIRPHONE_NAME}    IPHY_AEQE_2CELL_APLO_8DL4UL.xml
# ${WTS_NAME}    WTS_SANSA_n78_8DL4UL_2CELL_MU_APLO.cfg
# ${COMAVALUE}    ${CURDIR}/coma/8305.txt
# ${UE_ID1}         1
# ${UE_ID2}         2
# ${GW_ID1}         1
# ${GW_ID2}         2
# ${PDU_ID}         1
# ${SLICE_ID}       1
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
# &{GNBMIRRORINGCONFIGS}    BB_SLOT_2='true'    SYSCOM_MIRRORING='true'   L2HI_MIRRORING='true'   L2RT_MIRRORING='true'   CPRT_MIRRORING='false'
# ...    NUMBER_OF_FILES=30
# 
# *** Test Cases ***
# CB008305_A_B3_case20_2UEs_rank2_with_heavy_and_littleData
#     Prepare gnb onair    
# 	run keyword and continue on failure    Start capture gnb and ap syslog in 'after_onair' file
#     airphone_cleanup_egate_console_log
#     Set UE1 and UE2 Pos
#     Airphone Set Traffic Type    ${UE_ID1}    ${PDU_ID}    internal
#     Airphone Set Traffic Type    ${UE_ID2}    ${PDU_ID}    internal
#     Airphone SA Attach    ue_id=${UE_ID1}
#     Airphone Pdu Session Setup    ${UE_ID1}    ${PDU_ID}    ${SLICE_ID}    ${GW_ID1}
#     Airphone SA Attach    ue_id=${UE_ID2}
#     Airphone Pdu Session Setup    ${UE_ID2}    ${PDU_ID}    ${SLICE_ID}    ${GW_ID2}
#     run keyword and continue on failure    Check rrc log
#     Airphone override to rank2
#     Send DL data to UE and check throughput
#     Start collect ttitrace
#     Wait for '2s' to stop ttitrace with name'tti'
#     Check mupair in ttitrace
#     Send DL data to UE and check throughput-2
#     Start collect ttitrace
#     Wait for '2s' to stop ttitrace with name'tti-2'
#     Check mupair in ttitrace-2
#     Detach SA UEs
#     Stop capture gnb and ap syslog in 'after_onair' file
# 
# *** Keywords **
# Set UE1 and UE2 Pos
#     airphone_execute_egate_command    ue_srs_beam_pos_nr profile_id\=1 init_pos\=0 srsMode\=fixed
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=ue_srs_beam_pos action\=activate profile_id\=1
#     airphone_execute_egate_command    ue_srs_beam_pos_nr profile_id\=2 init_pos\=2 srsMode\=fixed
#     airphone_execute_egate_command    ue_testmode_set_nr id\=2 testmode\=ue_srs_beam_pos action\=activate profile_id\=2
#     #airphone_execute_egate_command    ul_sinr_testmode_nr profile_id\=5 sinr_target_srs\=-50 noise_srs\=-1053
#     #airphone_execute_egate_command    ue_testmode_set_nr id\=1-2 testmode\=ul_sinr action\=activate profile_id\=5
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
#     SA send mutiple trf dl data    ${UE_ID1}    4    175M
#     SA send mutiple trf dl data    ${UE_ID2}    1    100M
#     Wait '20s ' to stable
#     Check throughput
# 
# Detach SA UEs
#     : FOR    ${num}    IN RANGE    1    3
#     \    airphone_sa_detach    ue_id=${num}
#     \    Wait '3s' for stabible
# 
# Check mupair in ttitrace
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_dl_case20-1.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# Check throughput
#     Wait until keyword succeeds    60s    5s    Verify throughput
# 
# Check rrc log
#     Airphone_collect_egate_log_files    ${TEST_LOG_DIRECTORY()}/All/egate    unzip=TRUE
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/rrc_8305.ini    log_need_to_check=p    save_log_directory=${TEST_LOG_DIRECTORY()}/All/egate
# 
# Verify throughput
#     ${dl_throughput_ue1}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID1}    scell_id=0    type=pdsch    tput_type=ave
#     ${dl_throughput_ue2}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID2}    scell_id=0    type=pdsch    tput_type=ave
#     should_be_true    ${dl_throughput_ue1}>550000
#     should_be_true    ${dl_throughput_ue2}>90000
# 
# Send DL data to UE and check throughput-2
#     SA send mutiple trf dl data    ${UE_ID1}    4    175M
#     SA send mutiple trf dl data    ${UE_ID2}    4    175M
#     Wait '20s ' to stable
#     Check throughput-2
# 
# Check throughput-2
#     Wait until keyword succeeds    60s    5s    Verify throughput-2
# 
# Verify throughput-2
#     ${dl_throughput_ue1}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID1}    scell_id=0    type=pdsch    tput_type=ave
#     ${dl_throughput_ue2}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID2}    scell_id=0    type=pdsch    tput_type=ave
#     should_be_true    ${dl_throughput_ue1}>550000
#     should_be_true    ${dl_throughput_ue2}>550000
# 
# Check mupair in ttitrace-2
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_dl_case20-2.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# Modify l1bypass
#     copy_file    ${COMAVALUE}    ${test_log_directory()}/coma.py
#     Import Variables    ${test_log_directory()}/coma.py
#     Modify airphone l1bypass coma value for eight ue    ${Hindex10}    ${Vindex10}    ${Hindex0}    ${Vindex0}    ${Hindex17}    ${Vindex5}
#     ...    ${Hindex8}    ${Vindex0}    ${Hindex17}    ${Vindex6}    ${Hindex0}    ${Vindex0}
#     ...    ${Hindex24}    ${Vindex9}    ${Hindex8}    ${Vindex0}    ${Hindex24}    ${Vindex9}
#     ...    ${Hindex0}    ${Vindex0}    ${Hindex24}    ${Vindex9}    ${Hindex0}    ${Vindex0}
#     ...    ${Hindex0}    ${Vindex0}    ${Hindex0}    ${Vindex0}    ${Hindex0}    ${Vindex0}
#     ...    ${Hindex8}    ${Vindex0}    
# 
# Airphone override to rank2
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=1 cqi\=15 ri\=1
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1-2 testmode\=csi_override action\=activate profile_id\=1
