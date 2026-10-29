# *** Settings ***
# Suite Setup    Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup    Common Test Setup
# Test Teardown    Common Test Teardown
# Force Tags    CLOUD_5G_I_BLLL_AP_LOO     AP    CRT
# ...    SBTS00    RAN_5G_TDD
# Resource    ../../resources/KISS/robot/common_resource.robot
# Resource    ../../resources/sg10/internal_resource/internal_resource.robot
# Documentation     maxDlHarqTx=8
# ...               0x340000=15      # as PM counter period update to 15/15=1min
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}     SCFC_CB009198_CASE05.xml
# ${AIRPHONE_NAME}    IPHY_AEQE_ASIL_1CELL.xml
# ${WTS_NAME}    wts_AEQE_aplo_sa.cfg
# @{LOG_NAME_LIST}    gnb_snapshot
# ${UE_NUM}         1
# ${UE_ID1}          1
# ${PDU_ID1}         1
# ${GW_ID1}          1
# ${UE_ID2}          2
# ${PDU_ID2}         2
# ${GW_ID2}          2
# ${SLICE_ID}       1
# ${EGATE_TAG}      CB009198
# ${BIP_TAG}    9198_bip
# &{GNBMIRRORINGCONFIGS}    BB_SLOT_2='false'   BB_SLOT_1='false'    BB_SLOT_5='true'    SYSCOM_MIRRORING='true'
# ...    L2HI_MIRRORING='true'   L2RT_MIRRORING='true'   CPRT_MIRRORING='false'  NUMBER_OF_FILES=30
# 
# 
# *** Test Cases ***
# CB009198_B_B3_case05_SA_FR1_Transition_From_Single_Tx_To_Rank2_On_PUSCH
# #    Active GNB L2 feature debug traces
#     Prepare gnb onair
#     Start capture gnb and ap syslog in 'after_onair' file
#     airphone_cleanup_egate_console_log
#     Attach 1 NonCoherent UE and Check SRS Port change
#     Attach 1 fullCOherent UE and Check SRS Port Change
#     Stop capture gnb and ap syslog in 'after_onair' file
# 
# *** Keywords ***
# Attach 1 NonCoherent UE and Check SRS Port change
#     Airphone Set Traffic Type    ${UE_ID1}    ${PDU_ID1}    internal
#     Airphone SA Attach    ${UE_ID1}
#     Wait '5s' for stabible
#     Airphone Pdu Session Setup    ${UE_ID1}    ${PDU_ID1}    ${SLICE_ID}    ${GW_ID1}
#     Wait '5s' for stabible
#     SA send mutiple trf ul data    ${UE_ID1}    1   140M   ${UE_ID1}
#     Start collect ttitrace
#     airphone_execute_egate_command    ul_sinr_testmode_nr profile_id\=1 pathloss\=110
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=ul_sinr action\=activate profile_id\=1 scell\=0
#     Wait '3s' for stabible
#     Wait for '1s' to stop ttitrace with name'SA_UE_pathloss_110'
#     Start collect ttitrace
#     airphone_execute_egate_command    ul_sinr_testmode_nr profile_id\=1 pathloss\=120
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=ul_sinr action\=activate profile_id\=1 scell\=0
#     Wait '3s' for stabible
#     Wait for '1s' to stop ttitrace with name'SA_UE_pathloss_120'
#     Check RRC log for SRS port change to port1
#     cb009198_check_mcs_sinr    ${TEST_LOG_DIRECTORY()}/All/SA_UE_pathloss_120_ul.csv    19
#     Start collect ttitrace
#     airphone_execute_egate_command    ul_sinr_testmode_nr profile_id\=1 pathloss\=130
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=ul_sinr action\=activate profile_id\=1 scell\=0
#     Wait '3s' for stabible
#     Wait for '1s' to stop ttitrace with name'SA_UE_pathloss_130'
#     #cb009198_check_mcs_sinr    ${TEST_LOG_DIRECTORY()}/All/SA_UE_pathloss_130_ul.csv    19
#     airphone_execute_egate_command    ul_sinr_testmode_nr profile_id\=1 pathloss\=60
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=ul_sinr action\=activate profile_id\=1 scell\=0
#     Wait '3s' for stabible
#     Start collect ttitrace
#     Wait for '1s' to stop ttitrace with name'SA_UE_pathloss_60'
#     Check tti for dft-ofdm to cp-ofdm
#     Check RRC log for SRS port change to port2
#     Start collect ttitrace
#     airphone_execute_egate_command    ul_sinr_testmode_nr profile_id\=1 pathloss\=110
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=ul_sinr action\=activate profile_id\=1 scell\=0
#     Wait '3s' for stabible
#     Wait for '1s' to stop ttitrace with name'SA_UE_pathloss_110_again'
#     Start collect ttitrace
#     airphone_execute_egate_command    ul_sinr_testmode_nr profile_id\=1 pathloss\=120
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=ul_sinr action\=activate profile_id\=1 scell\=0
#     Wait '3s' for stabible
#     Wait for '1s' to stop ttitrace with name'SA_UE_pathloss_120_again'
#     #cb009198_check_mcs_sinr    ${TEST_LOG_DIRECTORY()}/All/SA_UE_pathloss_120_again_ul.csv    19
#     Detach UE '1'
# 
# 
# Attach 1 fullCOherent UE and Check SRS Port Change
#     Airphone Set Traffic Type    ${UE_ID2}    ${PDU_ID2}    internal
#     Airphone SA Attach    ${UE_ID2}
#     Wait '5s' for stabible
#     Airphone Pdu Session Setup    ${UE_ID2}    ${PDU_ID2}    ${SLICE_ID}    ${GW_ID2}
#     Wait '5s' for stabible
#     SA send mutiple trf ul data    ${UE_ID2}    1   140M   ${UE_ID2}
#     airphone_execute_egate_command    ul_sinr_testmode_nr profile_id\=2 pathloss\=110
#     airphone_execute_egate_command    ue_testmode_set_nr id\=2 testmode\=ul_sinr action\=activate profile_id\=2 scell\=0
#     Wait '3s' for stabible
#     Start collect ttitrace
#     airphone_execute_egate_command    ul_sinr_testmode_nr profile_id\=2 pathloss\=120
#     Wait '2s' for stabible
#     Wait for '1s' to stop ttitrace with name'SA_UE_pathloss_120_nonco'
#    # cb009198_check_mcs_sinr    ${TEST_LOG_DIRECTORY()}/All/SA_UE_pathloss_120_nonco_ul.csv    19
#     Check RRC log for SRS port not change to port1
#     airphone_execute_egate_command    ul_sinr_testmode_nr profile_id\=2 pathloss\=30
#     airphone_execute_egate_command    ue_testmode_set_nr id\=2 testmode\=ul_sinr action\=activate profile_id\=2 scell\=0
#     Wait '3s' for stabible
#     Start collect ttitrace
#     Wait for '3s' to stop ttitrace with name'SA_UE_pathloss_30_nonco'
#     Check tti for dft-ofdm to cp-ofdm_again
# 
# 
# Attach 2 UE
#     Airphone Set Traffic Type    ${UE_ID1}    ${PDU_ID1}    internal
#     Airphone Set Traffic Type    ${UE_ID2}    ${PDU_ID2}    internal
#     Airphone SA Attach    ${UE_ID1}
#     Wait '5s' for stabible
#     Airphone Pdu Session Setup    ${UE_ID1}    ${PDU_ID1}    ${SLICE_ID}    ${GW_ID1}
#     Wait '5s' for stabible
#     Airphone SA Attach    ${UE_ID2}
#     Wait '5s' for stabible
#     Airphone Pdu Session Setup    ${UE_ID2}    ${PDU_ID2}    ${SLICE_ID}    ${GW_ID2}
#     Wait '5s' for stabible
#     SA send mutiple trf ul data    ${UE_ID1}    1   140M   ${UE_ID1}
#     SA send mutiple trf ul data    ${UE_ID2}    1   140M   ${UE_ID2}
#     Wait '5s' for stabible
#     Start collect ttitrace
#     airphone_execute_egate_command    ul_sinr_testmode_nr profile_id\=1 pathloss\=113
#     airphone_execute_egate_command    ul_sinr_testmode_nr profile_id\=2 pathloss\=113
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=ul_sinr action\=activate profile_id\=1 scell\=0
#     airphone_execute_egate_command    ue_testmode_set_nr id\=2 testmode\=ul_sinr action\=activate profile_id\=2 scell\=0
# 
#     Wait '5s' for stabible
#     Wait for '1s' to stop ttitrace with name'SA_UE_pathloss_110'
# 
#     Start collect ttitrace
#     airphone_execute_egate_command    ul_sinr_testmode_nr profile_id\=1 pathloss\=120
#     airphone_execute_egate_command    ul_sinr_testmode_nr profile_id\=2 pathloss\=120
#     Wait '3s' for stabible
#     Wait for '1s' to stop ttitrace with name'SA_UE_pathloss_120'
# 
#     Start collect ttitrace
#     airphone_execute_egate_command    ul_sinr_testmode_nr profile_id\=1 pathloss\=130
#     airphone_execute_egate_command    ul_sinr_testmode_nr profile_id\=2 pathloss\=130
#     Wait '3s' for stabible
#     Wait for '1s' to stop ttitrace with name'SA_UE_pathloss_130'
# 
#     Start collect ttitrace
#     airphone_execute_egate_command    ul_sinr_testmode_nr profile_id\=1 pathloss\=30
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=ul_sinr action\=activate profile_id\=1 scell\=0
#     Wait '3s' for stabible
#     Wait for '1s' to stop ttitrace with name'SA_UE_pathloss_30'
#     Start collect ttitrace
#     airphone_execute_egate_command    ul_sinr_testmode_nr profile_id\=1 pathloss\=113
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=ul_sinr action\=activate profile_id\=1 scell\=0
#     Wait '3s' for stabible
#     Wait for '1s' to stop ttitrace with name'SA_UE_pathloss_113_again'
# 
#     Start collect ttitrace
#     airphone_execute_egate_command    ul_sinr_testmode_nr profile_id\=1 pathloss\=120
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=ul_sinr action\=activate profile_id\=1 scell\=0
#     Wait '3s' for stabible
#     Wait for '1s' to stop ttitrace with name'SA_UE_pathloss_120_again'
# 
# Check RRC log for SRS port change to port1
#     Airphone_collect_egate_log_files    ${TEST_LOG_DIRECTORY()}/All/egate_precoderenable    unzip=TRUE
#     check_log_with_au2anlysis  ini_path=${CURDIR}/ini/rrc_9198_precoder_enable_srsport1.ini
#     ...    log_need_to_check=p    save_log_directory=${TEST_LOG_DIRECTORY()}/All/egate_precoderenable
# 
# Check RRC log for SRS port change to port2
#     Airphone_collect_egate_log_files    ${TEST_LOG_DIRECTORY()}/All/egate_precoderdisable    unzip=TRUE
#     check_log_with_au2anlysis  ini_path=${CURDIR}/ini/rrc_9198_precoder_disable_srsport2.ini
#     ...    log_need_to_check=p    save_log_directory=${TEST_LOG_DIRECTORY()}/All/egate_precoderdisable
# 
# Check RRC log for SRS port not change to port1
#     Airphone_collect_egate_log_files    ${TEST_LOG_DIRECTORY()}/All/egate_precoderenable_fullcore    unzip=TRUE
#     check_log_with_au2anlysis  ini_path=${CURDIR}/ini/rrc_9198_precoder_enable_srsport1.ini
#     ...    log_need_to_check=p    save_log_directory=${TEST_LOG_DIRECTORY()}/All/egate_precoderenable_fullcore
# 
# Check tti for dft-ofdm to cp-ofdm
#     Check Log With Au2anlysis    ${CURDIR}/ini/cp-ofdm.ini   i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# Check tti for dft-ofdm to cp-ofdm_again
#     Check Log With Au2anlysis    ${CURDIR}/ini/cp-ofdm_1.ini   i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
