# *** Settings ***
# Test Timeout    60 minutes
# Suite Setup    Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup    Common Test Setup
# Test Teardown    Common Test Teardown
# Force Tags    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    owner_l10wang    AP    CRT    SBTS00    RAN_5G_TDD    RAN_5G    AP_REG
# ...    SBTS23R1
# Resource    ../../resources/KISS/robot/common_resource.robot
# Resource    ../../resources/sg10/internal_resource/internal_resource.robot
# 
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}      SCFC_8305_case3_aplo.xml
# ${COMAVALUE}    ${CURDIR}/coma/8305.txt
# ${AIRPHONE_NAME}    IPHY_AEQE_1CELL.xml
# ${WTS_NAME}    wts_1086_7_TAS_abio.cfg
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
# ${UE_ID1}          1
# ${UE_ID2}          2
# ${PDU_ID1}         1
# ${PDU_ID2}         2
# ${GW_ID1}          1
# ${GW_ID2}          1
# ${SLICE_ID}       1
# &{GNBMIRRORINGCONFIG}    BB_SLOT_2='true'    SYSCOM_MIRRORING='true'   L2HI_MIRRORING='true'   L2RT_MIRRORING='true'   CPRT_MIRRORING='false'
# ...    NUMBER_OF_FILES=30
# *** Test Cases ***
# CB008305_A_B2_case03_two_rank2_Ues_paired_with_correlation_checking
#     Prepare gnb onair
#     Start capture gnb and ap syslog in 'after_onair' file
#     airphone_cleanup_egate_console_log
# 	Set UE1 and UE2 Pos
#     Attach SA UE1 and UE2
#     SA send dl and ul data    ${UE_ID1}    number=4    dl_data=175M    ul_data=20M    pdu_id=${PDU_ID1}
#     SA send dl and ul data    ${UE_ID2}    number=4    dl_data=175M    ul_data=20M    pdu_id=${PDU_ID2}
#     Wait '60s' for stabible
#     run keyword and continue on failure    Check ue tput is correct
#     Start collect ttitrace
#     Wait for '3s' to stop ttitrace with name'tti1'
#     run keyword and continue on failure    Check rrc log
#     run keyword and continue on failure    Check mupair in ttitrace
#     Online change correlation to 0
#     Online change correlation to 0.5
#     Online change correlation to 1
#     Detach '2' UE
# *** Keywords ***
# Set UE1 and UE2 Pos
#     airphone_execute_egate_command    ue_srs_beam_pos_nr profile_id\=1 init_pos\=1 srsMode\=fixed
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=ue_srs_beam_pos action\=activate profile_id\=1
#     airphone_execute_egate_command    ue_srs_beam_pos_nr profile_id\=2 init_pos\=3 srsMode\=fixed
#     airphone_execute_egate_command    ue_testmode_set_nr id\=2 testmode\=ue_srs_beam_pos action\=activate profile_id\=2
#     airphone_execute_egate_command    ul_sinr_testmode_nr profile_id\=5 sinr_target_srs\=100 noise_srs\=-1053
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=ul_sinr action\=activate profile_id\=5
#     airphone_execute_egate_command    ue_testmode_set_nr id\=2 testmode\=ul_sinr action\=activate profile_id\=5
# 
# Attach SA UE1 and UE2
#     Airphone Set Traffic Type    ${UE_ID1}    ${PDU_ID1}    internal
#     Airphone Set Traffic Type    ${UE_ID2}    ${PDU_ID2}    internal
#     Airphone SA Attach    ue_id=${UE_ID1}
#     Airphone Pdu Session Setup    ${UE_ID1}    ${PDU_ID1}    ${SLICE_ID}    ${GW_ID1}
#     Wait '5s' for stabible
#     Airphone SA Attach    ue_id=${UE_ID2}
#     Airphone Pdu Session Setup    ${UE_ID2}    ${PDU_ID2}    ${SLICE_ID}    ${GW_ID2}
#     Wait '5s' for stabible
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=2 cqi\=15 ri\=1
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=csi_override action\=activate profile_id\=2
#     airphone_execute_egate_command    ue_testmode_set_nr id\=2 testmode\=csi_override action\=activate profile_id\=2
#     Wait '10s' for stabible
# 
# Check rrc log
#     Airphone_collect_egate_log_files    ${TEST_LOG_DIRECTORY()}/All/egate    unzip=TRUE
#     run keyword and continue on failure    check_log_with_au2anlysis  ini_path=${CURDIR}/ini/rrc_8305.ini    log_need_to_check=p
#    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/egate
# Check ue tput is correct
#     ${dl_tput1}    ${ul_tput1}    Obtain one sa ue dl and ul throught    ${UE_ID1}    pdu_id=${PDU_ID1}
#     ${dl_tput2}    ${ul_tput2}    Obtain one sa ue dl and ul throught    ${UE_ID2}    pdu_id=${PDU_ID2}
#     should be true    ${dl_tput1}>530000
#     should be true    ${dl_tput2}>530000
# Check ue tput is correct for nopair
#     ${dl_tput1}    ${ul_tput1}    Obtain one sa ue dl and ul throught    ${UE_ID1}    pdu_id=${PDU_ID1}
#     ${dl_tput2}    ${ul_tput2}    Obtain one sa ue dl and ul throught    ${UE_ID2}    pdu_id=${PDU_ID2}
#     should be true    ${dl_tput1}>270000
#     should be true    ${dl_tput2}>270000
# Online change correlation to 0
#     Log To Console    online change correlation to 0...
#     TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
#     TAF_ADMIN.perform_parameter_recommissioning    dist_name=MRBTS-1/NRBTS-1/NRCELL-1/NRDLMUMIMO-1    parameter=dlMuMimoCorrThd
#     ...    operation=update    value=0    skip_parameter_relation_errors=True    should_activate=True    connection=online
#     TAF_ADMIN.teardown admin    connection=online
#     Wait '30s' for stabible
#     Check ue tput is correct for nopair
#     Start collect ttitrace
#     Wait for '3s' to stop ttitrace with name'tti2'
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_dl_case3_1.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# Online change correlation to 0.5
#     Log To Console    online change correlation to 0...
#     TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
#     TAF_ADMIN.perform_parameter_recommissioning    dist_name=MRBTS-1/NRBTS-1/NRCELL-1/NRDLMUMIMO-1    parameter=dlMuMimoCorrThd
#     ...    operation=update    value=50    skip_parameter_relation_errors=True    should_activate=True    connection=online
#     TAF_ADMIN.teardown admin    connection=online
#     Wait '30s' for stabible
#     Check ue tput is correct
#     Start collect ttitrace
#     Wait for '3s' to stop ttitrace with name'tti3'
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_dl_case3_2.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# Online change correlation to 1
#     Log To Console    online change correlation to 0...
#     TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
#     TAF_ADMIN.perform_parameter_recommissioning    dist_name=MRBTS-1/NRBTS-1/NRCELL-1/NRDLMUMIMO-1    parameter=dlMuMimoCorrThd
#     ...    operation=update    value=100    skip_parameter_relation_errors=True    should_activate=True    connection=online
#     TAF_ADMIN.teardown admin    connection=online
#     Wait '30s' for stabible
#     Check ue tput is correct
#     Start collect ttitrace
#     Wait for '3s' to stop ttitrace with name'tti4'
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_dl_case3_3.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# Check mupair in ttitrace
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_dl_case3.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# Modify l1bypass
#     copy_file    ${COMAVALUE}    ${test_log_directory()}/coma.py
#     Import Variables    ${test_log_directory()}/coma.py
#     Modify airphone l1bypass coma value for eight ue
#     ...    ${Hindex10}    ${Vindex10}    ${Hindex0}    ${Vindex0}
#     ...    ${Hindex17}    ${Vindex5}    ${Hindex8}    ${Vindex0}
#     ...    ${Hindex10}    ${Vindex10}    ${Hindex0}    ${Vindex0}
#     ...    ${Hindex17}    ${Vindex5}    ${Hindex8}    ${Vindex0}
#     ...    ${Hindex10}    ${Vindex10}    ${Hindex0}    ${Vindex0}
#     ...    ${Hindex17}    ${Vindex5}    ${Hindex0}    ${Vindex0}
#     ...    ${Hindex10}    ${Vindex10}    ${Hindex0}    ${Vindex0}
#     ...    ${Hindex17}    ${Vindex5}    ${Hindex8}    ${Vindex0}
