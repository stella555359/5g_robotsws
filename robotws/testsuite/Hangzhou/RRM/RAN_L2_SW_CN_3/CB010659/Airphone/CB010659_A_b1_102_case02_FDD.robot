# *** Settings ***
# Suite Setup    Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup    Common Test Setup
# Test Teardown    Common Test Teardown
# Force Tags        CLOUD_5G_I_BL_AP_KL_SANSA_FS_CPRI_CMWV_FDD    AP    CRT    SBTS00    RAN_5G    owner_penny
# Resource    ../../resources/KISS/robot/common_resource.robot
# Resource    ../../resources/sg10/internal_resource/internal_resource.robot
# 
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}      SCFC_10659_case02_FDD.xml
# ${AIRPHONE_NAME}    IPHY_AHLOA_ASIB_ABIL_FDD.xml 
# ${WTS_NAME}       WTS_ASIB_ABIL_FDD_CPRI_SANSA_FS.cfg
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
# ${bler_testmode_nr_profile_1}    bler_testmode_nr profile_id\=1 ul_bler_bit_error\=100,80,80,80,0,0,0,0 ul_bler_bit_error_periodicity\=3 
# ...        ul_bler_bit_error_duration\=0
# @{Rdparameter}       0x340000:5    0x580010:0x4000
# ${UE_ID}    1
# ${TTI_TAG}    fdd_case2
# 
# 
# *** Test Cases ***
# CB010659_A_b1_102_case02_FDD_UL_HARQ_Retrans_With_Regular_MSC_In_slot_with_same_REs
#     Prepare test
#     Prepare gnb onair
#     Establish enb x2 link
#     airphone_cleanup_egate_console_log
#     Start capture gnb and ap syslog in 'after_onair' file 
#     Attach SA ue to 5g cell    ${UE_ID}
#     SA send dl and ul data    1    number=1    dl_data=100M    ul_data=100M
#     Trigger ul retrans
#     Start collect ttitrace   
#     Wait for '3s' to stop ttitrace with name'${TTI_TAG}'
#     Stop egate log and unzip with name'pair'
#     Run keyword and continue on failure    Stop capture gnb and ap syslog in 'after_onair' file
#     Check reserved mcs in ttitrace is correct    ${TTI_TAG}    
#     
# 
# 
# 
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
#     airphone_execute_egate_command	${bler_testmode_nr_profile_1}
#     airphone_execute_egate_command	ue_testmode_set_nr id\=1 testmode\=bler profile_id\=1 action\=activate
# 
# 
# 
# 
# 
