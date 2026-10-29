# *** Settings ***
# Test Timeout    60 minutes
# Suite Setup    Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup    Common Test Setup
# Test Teardown    Common Test Teardown
# Force Tags         AP    CRT    SBTS00    RAN_5G    owner_penny    CLOUD_5G_I_BLLL_AP_LOO
# Resource    ../../resources/KISS/robot/common_resource.robot
# Resource    ../../resources/sg10/internal_resource/internal_resource.robot
# 
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}      SCFC_10659_case05_TDD.xml
# ${AIRPHONE_NAME}    IPHY_1cell_AEQE_TDD.xml
# ${WTS_NAME}    wts_10659_ABIL_ASIL_TDD_1cell.cfg
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
# ${bler_testmode}    ul_cell_noise_testmode_nr profile_id\=1  noise_pusch\=-680
# ${bler_testmode_activate}    cell_testmode_set_nr cell_id\=1 gnb\=1 testmode\=ul_cell_noise profile_id\=1 action\=activate
# ${bler_sinr}    ul_sinr_testmode_nr profile_id\=1 sinr_target_pusch\=-400 
# ${bler_sinr_activate}    ue_testmode_set_nr id\=1 testmode\=ul_sinr profile_id=1 action\=activate
# @{Rdparameter}       0x9D0000:5    0x580010:0x200
# ${UE_ID}    1
# ${TTI_TAG}    tdd_case5
# 
# *** Test Cases ***
# CB010659_A_b1_101_case05_TDD_UL_HARQ_Retrans_With_MSC_Reserved_Min_50_Target_70
#     Prepare test
#     Prepare gnb onair
#     airphone_cleanup_egate_console_log
#     Start capture gnb and ap syslog in 'after_onair' file 
#     Attach SA ue to 5g cell    ${UE_ID}
#     SA send dl and ul data    1    number=2    dl_data=20M    ul_data=100M
#     Trigger ul retrans
#     Wait '20s' for stabible
#     Start collect ttitrace
#     Wait for '3s' to stop ttitrace with name'${TTI_TAG}'
#     Stop egate log and unzip with name'pair'
#     run keyword and continue on failure    Stop capture gnb and ap syslog in 'after_onair' file
#     Check ue throughput is correct
#     Check reserved mcs in ttitrace is correct    ${TTI_TAG} 
# 
# 
# 
# *** Keywords ***
# Attach SA ue to 5g cell
#     [Arguments]    ${UE_ID}    ${PDU_ID}=1    ${GW_ID}=1    ${SLICE_ID}=1
#     Airphone Set Traffic Type    ${UE_ID}    ${PDU_ID}    internal
#     Airphone SA Attach    ue_id=${UE_ID}    
#     Airphone Pdu Session Setup    ${UE_ID}    ${PDU_ID}    ${SLICE_ID}    ${GW_ID}
#     Wait '1s' for stabible
# 
# Prepare test
#     # Active GNB L2 feature debug traces
#     Add GNB swconfig    @{Rdparameter}
# 
# Trigger ul retrans
#     airphone_execute_egate_command    ${bler_sinr}
#     airphone_execute_egate_command    ${bler_sinr_activate}
# 
# Check ue throughput is correct
#     ${dl_tput1}    ${ul_tput1}    Obtain one sa ue dl and ul throught    ${UE_ID}
#     should be true    ${dl_tput1}>30
#     should be true    ${ul_tput1}>30
