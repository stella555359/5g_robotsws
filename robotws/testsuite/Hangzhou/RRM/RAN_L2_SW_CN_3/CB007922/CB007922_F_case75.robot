# *** Settings ***
# Suite Setup    Common Suite Setup
# Suite Teardown  Common Suite Teardown
# Test Setup    Common Test Setup
# Test Teardown    Common Test Teardown
# Force Tags        CRT    SBTS00    SBTS23R1    SBTS22R2    SBTS22R4
# ...   CLOUD_5G_I_BLLL_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD
# ...    RAN_5G_TDD    RAN_5G
# Resource    ../resources/KISS/robot/common_resource.robot
# Resource    ../resources/sg10/internal_resource/internal_resource.robot
# 
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${UE_ID}         11
# ${CA_UE_NUM}    2
# ${NONCA_UE_NUM}    2
# ${SCFC_NAME}      SCFC_7922_CASE75.xml
# ${AIRPHONE_NAME}    IPHY_2AEHC_AEQA.xml
# ${WTS_NAME}       WTS_7922_F_case75.cfg
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
# ${BEAM_PROFILE}    beam_control_testmode_nr profile_id\=1 ueBeamIndexInitial\=5,0,1,2,3,4 ssbeam_bestbeam\=3 ssbeam_rsrp_best\=-44
#                    ...    ssbeam_rsrp_avg\=-50
# ${UE_TESTMODE}     ue_testmode_set_nr id\=1 testmode\=beam_control action\=activate profile_id\=1 beamaction\=attach scell\=8-9
# ${STABLETIME}    10s
# ${TTITRACE_TAG}    tti
# ${UE11_A1_EVENT}    ue_measurement_send_nr id\=11 meas_id\=2 event\=A1 rs_type\=ssb srsrp_nr\=50
# ${UE12_A1_EVENT}    ue_measurement_send_nr id\=12 meas_id\=2 event\=A1 rs_type\=ssb srsrp_nr\=50
# 
# *** Test Cases ***
# CB007922_case75_F_Multiple_UE_connection_setup_and_DLUL_data_scheduling_in_NSA_with_CPRI_ABIL_and_eCPRI_ABIL_CA
# 
#     Prepare gnb onair
#     Start capture gnb and ap syslog in 'after_onair' file
#     Execute AP Command before attach
#     Set UE Beamforming Profile
#     Attach LTE UE
#     UE send A1 Event
#     Send DL data to UE and check throughput
#     Start collect ttitrace
#     Wait for '5s' to stop ttitrace with name'${TTITRACE_TAG}'
#     Check ttitrace
#     UE DETACH
#     Stop capture gnb and ap syslog in 'after_onair' file
#     
# 
# *** Keywords ***
# Execute AP Command before attach
#     airphone_cleanup_egate_console_log
#     Airphone Setup X2 Connection
# 
# Set UE Beamforming Profile
#     airphone_execute_egate_command    ${BEAM_PROFILE}
#     airphone_execute_egate_command    ${UE_TESTMODE}
# Attach LTE UE
#     Airphone NSA Attach    11...14
#     Wait time to stable
# 
# UE send A1 Event
#     airphone_execute_egate_command    ${UE11_A1_EVENT}
#     Wait time to stable
#     airphone_execute_egate_command    ${UE12_A1_EVENT}
#     Wait time to stable
# 
# Send DL data to UE and check throughput
#      airphone_execute_egate_command    trf_data_start ue\=11-14 id\=2 dir\=dl mbps\=175 trf_id\=1
#      airphone_execute_egate_command    trf_data_start ue\=11-14 id\=2 dir\=dl mbps\=175 trf_id\=2
#      Wait time to stable
#       : FOR    ${ue}    IN RANGE    11    ${CA_UE_NUM}+11
#       \    ${pcell_tp}=    airphone_get_throughput_on_specific_scell    ${ue}    8    type=pdsch    tput_type=ave
#       \    ${scell_tp}=    airphone_get_throughput_on_specific_scell    ${ue}    9    type=pdsch    tput_type=ave
#       \    should be true    ${pcell_tp}>0
#       \    should be true    ${scell_tp}>0
#       : FOR    ${ue}   IN RANGE    13    ${NONCA_UE_NUM}+13
#       \    ${pcell_tp}=    airphone_get_throughput_on_specific_scell    ${ue}    8    type=pdsch    tput_type=ave
#       \    should be true    ${pcell_tp}>0
# 
# 
# Wait time to stable
#     sleep    ${STABLETIME}
# 
# Check ttitrace
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_dl.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# UE DETACH
#     :FOR    ${ue}    IN RANGE    11    ${CA_UE_NUM}+${NONCA_UE_NUM}+1
#     \    Airphone NSA Detach    ${ue}
