# *** Settings ***
# Suite Setup    Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup    Common Test Setup
# Test Teardown    Common Test Teardown
# Force Tags    CLOUD_5G_I_BO_AP_KL_SANSA_L1B_ECPRI_CMWV_TDD    owner_menzheng   AP    CRT    SBTS00     SBTS22R4    RAN_5G_TDD    RAN_5G
# Resource    ../../resources/KISS/robot/common_resource.robot
# Resource    ../../resources/sg10/internal_resource/internal_resource.robot
# 
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}      SCFC_8305_case02_ap.xml
# ${AIRPHONE_NAME}    IPHY_AEQB_1CELL.xml
# ${L1BYP_XML}      L1ByPTestModeConfiguration_case25_8ue.xml
# ${COMAVALUE}    ${CURDIR}/coma/8305.txt
# ${WTS_NAME}    wts_8305.cfg
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
# 
# *** Test Cases ***
# CB008305_A_B1_case02_two_rank1_UEs_blindly_paired_mumimo_enable_pdsch_power_DMRS_check
#     Modify l1bypass
#     #Active GNB L2 feature debug traces
#     Prepare gnb onair
#     Start capture gnb and ap syslog in 'after_onair' file
#     Wait '20s' for stabible
#     airphone_cleanup_egate_console_log
#     Attach SA UE1
# 	Attach SA UE2
#     SA send dl and ul data    ${UE_ID1}    number=5    dl_data=175M    ul_data=20M    pdu_id=${PDU_ID1}
#     SA send dl and ul data    ${UE_ID2}    number=5    dl_data=175M    ul_data=20M    pdu_id=${PDU_ID2}
#     Wait '20s' for stabible
# 	Check 1st throughput 
#     Start collect ttitrace
#     Wait for '2s' to stop ttitrace with name'tti'
# 	DeRegister UE1
# 	Attach SA UE1
#     SA send dl and ul data    ${UE_ID1}    number=5    dl_data=175M    ul_data=20M    pdu_id=${PDU_ID1}
#     Wait '10s' for stabible
# 	Check 2nd throughput 
#     Start collect ttitrace
#     Wait for '2s' to stop ttitrace with name'tti_1'
#     DeRegister UE1
# 	Attach SA UE1
# 	UE send RANK2
#     SA send dl and ul data    ${UE_ID1}    number=5    dl_data=175M    ul_data=20M    pdu_id=${PDU_ID1}
#     Wait '10s' for stabible
# 	Check 3rd throughput 
#     Start collect ttitrace
#     Wait for '2s' to stop ttitrace with name'tti_2'
#     DeRegister SA 2 UEs
# 	Check ttitrace
#     Stop capture gnb and ap syslog in 'after_onair' file
# 
# *** Keywords ***
# Attach SA UE1
# 	airphone_cleanup_egate_console_log
#     Airphone Set Traffic Type    ${UE_ID1}    ${PDU_ID1}    internal
#     Airphone SA Attach    ue_id=${UE_ID1}
#     Airphone Pdu Session Setup    ${UE_ID1}    ${PDU_ID1}    ${SLICE_ID}    ${GW_ID1}
# 	UE send RANK1
#     Wait '10s' for stabible
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=2 cqi\=15 ri\=0
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=csi_override action\=activate profile_id\=2
#     Wait '5s' for stabible
# 	Check rrc log
# 
# Attach SA UE2
#     airphone_cleanup_egate_console_log
#     Airphone Set Traffic Type    ${UE_ID2}    ${PDU_ID2}    internal
#     Airphone SA Attach    ue_id=${UE_ID2}
#     Airphone Pdu Session Setup    ${UE_ID2}    ${PDU_ID2}    ${SLICE_ID}    ${GW_ID2}
# 	UE send RANK1
#     Wait '10s' for stabible
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=2 cqi\=15 ri\=0
#     airphone_execute_egate_command    ue_testmode_set_nr id\=2 testmode\=csi_override action\=activate profile_id\=2
#     Wait '5s' for stabible
# 	Check rrc log
# 	
# Check rrc log
#     Airphone_collect_egate_log_files    ${TEST_LOG_DIRECTORY()}/All/egate    unzip=TRUE
#     run keyword and continue on failure    check_log_with_au2anlysis  ini_path=${CURDIR}/ini/rrc_8305.ini    log_need_to_check=p
#    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/egate
# 
# Check ue tput is correct
#     ${dl_tput1}    ${ul_tput1}    Obtain one sa ue dl and ul throught    ${UE_ID1}    pdu_id=${PDU_ID1}
#     ${dl_tput2}    ${ul_tput2}    Obtain one sa ue dl and ul throught    ${UE_ID2}    pdu_id=${PDU_ID2}
#     should be true    ${dl_tput1}>300000
#     should be true    ${dl_tput2}>300000
# 
# Check ttitrace
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_case2.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# Modify l1bypass
#     copy_file    ${COMAVALUE}    ${test_log_directory()}/coma.py
#     Import Variables    ${test_log_directory()}/coma.py
#     Modify airphone l1bypass coma value for eight ue
#     ...    ${Hindex10}    ${Vindex10}    ${Hindex0}    ${Vindex0}
#     ...    ${Hindex17}    ${Vindex5}    ${Hindex0}    ${Vindex0}
#     ...    ${Hindex16}    ${Vindex5}    ${Hindex0}    ${Vindex0}
#     ...    ${Hindex16}    ${Vindex5}    ${Hindex0}    ${Vindex0}
#     ...    ${Hindex16}    ${Vindex5}    ${Hindex0}    ${Vindex0}
#     ...    ${Hindex16}    ${Vindex5}    ${Hindex0}    ${Vindex0}
#     ...    ${Hindex0}    ${Vindex0}    ${Hindex0}    ${Vindex0}
#     ...    ${Hindex0}    ${Vindex0}    ${Hindex0}    ${Vindex0}
# 
# Check 1st throughput 
#      Wait '10s' for stabible
#      ${ue1_tp}=    airphone_get_throughput_on_specific_scell    1    0    type=pdsch    tput_type=ave
#      ${ue2_tp}=    airphone_get_throughput_on_specific_scell    2    0    type=pdsch    tput_type=ave
#      should be true    ${ue1_tp}>320000
#      should be true    ${ue2_tp}>320000
# 
# Check 2nd throughput 
#      Wait '10s' for stabible
#      ${ue3_tp}=    airphone_get_throughput_on_specific_scell    1    0    type=pdsch    tput_type=ave
#      ${ue2_tp}=    airphone_get_throughput_on_specific_scell    2    0    type=pdsch    tput_type=ave
#      should be true    ${ue3_tp}>320000
#      should be true    ${ue2_tp}>320000
# 	 
# Check 3rd throughput 
#      Wait '10s' for stabible
#      ${ue3_tp}=    airphone_get_throughput_on_specific_scell    1    0    type=pdsch    tput_type=ave
#      ${ue2_tp}=    airphone_get_throughput_on_specific_scell    2    0    type=pdsch    tput_type=ave
#      should be true    ${ue3_tp}>640000
#      should be true    ${ue2_tp}>320000
# 
# Modify 8305 Swconfig
# 	Add GNB swconfig    0x340000:15  0x580542:0
# 
# DeRegister SA 2 UEs
#     : FOR    ${num}    IN RANGE    1    3
#     \   airphone_sa_detach    ue_id=${num}    timeout=5
#     \   Wait '2s' for stabible
# 	
# DeRegister UE1
#     airphone_sa_detach    ue_id=${UE_ID1}     timeout=5
#     Wait '2s' for stabible
# 	
# UE send RANK1
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=1 cqi\=15 cqi_mode\=fixed ri\=0 ri_mode\=fixed
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1-2 testmode\=csi_override action\=activate profile_id\=1 scell\=0
# 	
# UE send RANK2
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=2 cqi\=15 cqi_mode\=fixed ri\=1 ri_mode\=fixed	
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=csi_override action\=activate profile_id\=2 scell\=0	
