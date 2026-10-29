*** Settings ***
Documentation
...   author: keli.weng
...   contact: keli.weng@nokia-sbell.com
...   this is a robot case about CNI132616
# Resource          ../Resources/common_resource.robot
# Suite Setup       Common MultiBTS Suite Setup For RRM
# Suite Teardown      Common MutliBTS Suite Teardown For RRM
# Test Setup    Run keywords    Common MultiBTS Test Setup For RRM    AND    Case Setup
# Test Teardown     Run keywords    Case Teardown    AND    Common MultiBTS Test Teardown For RRM
# Library           OperatingSystem
# Force Tags
# # ...                     CRT
# ...                     RAN_5G
# ...                     CLOUD_5G_CLASSICAL_ANDROID_ASIL_ABIO_ABIP_AZHL_AEHC_MCS
# ...                     SBTS00
# # ...                     STATE_SW_UPLOADED
# ...                     STATE_SKIP_AGENT
# ...                     CA_RAN_PZ_HAZ_1
# ...                     RAN_PZ_HAZ1_SG07_ST_RRM
# ...                     TA_LEVEL_22
# *** Variables ***
# ${DEBUGMODE}                        ${True}
# ${PA_MaxValue}           ${60}
# ${PA_NormalValue}        ${30}
# ${PA_HoValue}            ${50}
# ${PA_MinValue}           ${0}
# ${CA_MAX_Value}          ${60}
# ${CA_NormalValue}        ${8}
# ${CA_MIN_Value}          ${0}
# ${pci_of_cell1}          ${178}
# ${pci_of_cell2}          ${403}
# ${Cell1_ID}              187154473
# ${Cell2_ID}              187154836
# ${Pa_range_size}         ${18}
# ${Pa_interval}           60
# ${dist_name}            MRBTS-11423/NRBTS-11423
# ${bts0_web_ip}             10.106.201.195
# &{fault_4527}              faultId=${4527}
# &{fault_4602}              faultId=${4602}
# &{fault_4741}              faultId=${4741}
# &{fault_6327}              faultId=${6327}
# &{fault_6915}              faultId=${6915}
# &{fault_61618}             faultId=${61618}
# @{Ohter_Allow_Alarms}      &{fault_4527}    &{fault_4602}    &{fault_4741}    &{fault_61618}
# ...    &{fault_6327}    &{fault_6915}
# ${delta_filepath}       ${CURDIR}/delta_plan_nradjgnb_delete.json

# *** Test Cases ***
# CNI132616_01_lock_unlock
#     [Documentation]    author:keli
#     [Tags]    10_5_UTESRAN001T11423
#     Check Param Precondition
#     Start Multi Bts Log
#     Unlock NRADJGNB    NRADJGNB_id=26
#     Lock NRADJGNB    NRADJGNB_id=26
#     sleep    2s
#     Run Keyword And Ignore Error    Check Alarm 7311 Raised    bts_index=${1}
#     Wait until keyword succeeds    2 min    30 sec    Check 7311 in history alarm
#     Wait For XnlinkReestabTmr Timeout
#     Wait until keyword succeeds    2 min    30 sec    Check Alarm 7311 Canceled    bts_index=${1}
#     Unlock NRADJGNB    NRADJGNB_id=26
#     Wait For XnlinkReestabTmr Timeout
#     Sleep    4s
#     # Lock NRADJGNB    NRADJGNB_id=9
#     # Wait For XnlinkReestabTmr Timeout
#     # Check Alarm 7311 Raised    bts_index=${1}

# CNI132616_02_CP-IF XN resource cleanup after remove the available NRADJGNB on source NR site
#     [Documentation]    author:keli
#     [Tags]    10_5_UTESRAN001T11423
#     Check Param Precondition
#     Start Multi Bts Log
#     Deleted NRADJGNB    NRADJGNB_id=26
#     sleep    15s
#     Run Keyword And Ignore Error    Check Alarm 7311 Raised    bts_index=${1}
#     Wait until keyword succeeds    2 min    30 sec    Check 7311 in history alarm
#     sleep    5s
#     # Added NRADJGNB

# CNI132616_03_remove_xnlink_and_nradjgnb
#     [Documentation]    author:keli
#     [Tags]    10_5_UTESRAN001T11423
#     Check Param Precondition
#     Start Multi Bts Log
#     Remove Xnlink and NRADJGNB
#     Run Keyword And Ignore Error    Check Alarm 7311 Raised    bts_index=${1}
#     Wait until keyword succeeds    2 min    30 sec    Check 7311 in history alarm
#     # Lock NRADJGNB    NRADJGNB_id=9
#     # sleep    15s
#     # Wait until keyword succeeds    3 min    30 sec    Check Alarm 7311 Raised    bts_index=${1}
#     sleep    5s
#     # Unlock NRADJGNB    NRADJGNB_id=9
#     Wait For XnlinkReestabTmr Timeout
#     Sleep    4s
#     # Lock NRADJGNB    NRADJGNB_id=9
#     # Wait For XnlinkReestabTmr Timeout
#     # Check Alarm 7311 Raised    bts_index=${1}

# CNI132616_04 CP-IF XN resource cleanup after the NR neighbor automatic removal
#     [Documentation]    author:keli
#     [Tags]    10_5_UTESRAN001T11423
#     Check Param Precondition
#     Start Multi Bts Log
#     Abort xnlink establishment For BTS1
#     sleep    15s
#     Recover xnlink establishment For BTS1

# *** Keywords ***
# Case Setup
#     Log To Console    Case Setup

# Case Teardown
#     Log To Console    Case Teardown
#     # Run Keyword And Ignore Error    AT.UE Detach
#     Run Keyword And Ignore Error    Stop All Bts Log
#     # Run Keyword If Test Passed     Collect Coam Snapshot For All GNB
#     Run Keyword And Ignore Error    Disconnect All VM


# Param Precondition
#     Log To Console    ${\n}============= Param Precondition =============${\n}
#     @{para_list}      Create List    actIncXn    maxNumXnLinks
#     @{mo_list_vcu}    Create List    MRBTS-11423/NRBTS-11423    MRBTS-11423/NRBTS-11423
#     ${out}            Parameter Operation    operation=parameter_value_check   product_type=gnb
#     ...                                      para_list=@{para_list}    mo_list=@{mo_list_vcu}
#     ...                                      bts_index=0
#     Log To Console    Gnb0 Parameter Check Result: ${out}


# Param Precondition For BTS1
#     Log To Console    ${\n}============= Param Precondition =============${\n}
#     @{para_list}      Create List    actIncXn    maxNumXnLinks
#     @{mo_list_vcu}    Create List    MRBTS-301/NRBTS-301    MRBTS-301/NRBTS-301
#     ${out}            Parameter Operation    operation=parameter_value_check   product_type=gnb
#     ...                                      para_list=@{para_list}    mo_list=@{mo_list_vcu}
#     ...                                      bts_index=1
#     Log To Console    Gnb1 Parameter Check Result: ${out}


# Check cPlaneIpAddrCtrl
#     [Arguments]    ${NRADJGNB_id}=${9}
#     Log To Console    ${\n}============= Param Precondition2 =============${\n}
#     @{para_list}      Create List    gNodeBIdCtrl    cPlaneIpAddrCtrl
#     @{mo_list_vcu}    Create List    MRBTS-11423/NRBTS-11423/NRADJGNB-${NRADJGNB_id}    MRBTS-11423/NRBTS-11423/XNLINK-178
#     ${out}            Parameter Operation    operation=parameter_value_check   product_type=gnb
#     ...                                      para_list=@{para_list}    mo_list=@{mo_list_vcu}
#     ...                                      bts_index=0
#     Log To Console    Gnb0 Parameter Check Result: ${out}

# Check cPlaneIpAddrCtrl For BTS1
#     [Arguments]    ${NRADJGNB_id}=${9}
#     Log To Console    ${\n}============= Param Precondition2 =============${\n}
#     @{para_list}      Create List    gNodeBIdCtrl    cPlaneIpAddrCtrl
#     @{mo_list_vcu}    Create List    MRBTS-301/NRBTS-301/NRADJGNB-${NRADJGNB_id}    MRBTS-301/NRBTS-301/XNLINK-1
#     ${out}            Parameter Operation    operation=parameter_value_check   product_type=gnb
#     ...                                      para_list=@{para_list}    mo_list=@{mo_list_vcu}
#     ...                                      bts_index=1
#     Log To Console    Gnb0 Parameter Check Result: ${out}

# Check Param Precondition
#     Param Precondition
#     sleep    2s
#     Param Precondition For BTS1
#     sleep    2s
#     # Check cPlaneIpAddrCtrl
#     # sleep    2s
#     # Check cPlaneIpAddrCtrl For BTS1
#     # sleep    2s

# Lock XnLink
#     Log To Console      ${\n}============= lock Xn Link =============${\n}

# Remove Xnlink and NRADJGNB
#     Log To Console      ${\n}============= remove nradjgnb Xn Link =============${\n}
#     ${out}   Parameter Operation    operation=delta_plan_update   product_type=gnb
#     ...    delta_file_path=${CURDIR}/delta_plan_nradjgnb_xnlink_delete.json
#     Log To Console    Gnb0 Parameter Check Result: ${out}


# Lock NRADJGNB
#     [Arguments]    ${NRADJGNB_id}=${9}
#     Log To Console      ${\n}============= lock NRADJGNB =============${\n}
#     @{para_list}      Create List    administrativeState
#     @{value_list}     Create List    Locked
#     @{mo_list}    Create List    MRBTS-11423/NRBTS-11423/NRADJGNB-${NRADJGNB_id}
#     ${out}            Parameter Operation    operation=parameter_update   product_type=gnb
#     ...                                      para_list=@{para_list}    value_list=${value_list}    mo_list=@{mo_list}
#     ...                                      bts_index=0
#     Log To Console    Gnb0 Parameter Check Result: ${out}

# Unlock NRADJGNB
#     [Arguments]    ${NRADJGNB_id}=${9}
#     Log To Console      ${\n}============= unlock NRADJGNB =============${\n}
#     @{para_list}      Create List    administrativeState
#     @{value_list}     Create List    Unlocked
#     @{mo_list}    Create List    MRBTS-11423/NRBTS-11423/NRADJGNB-${NRADJGNB_id}
#     ${out}            Parameter Operation    operation=parameter_update   product_type=gnb
#     ...                                      para_list=@{para_list}    value_list=${value_list}    mo_list=@{mo_list}
#     ...                                      bts_index=0
#     Log To Console    Gnb0 Parameter Check Result: ${out}


# Deleted NRADJGNB
#     [Arguments]    ${NRADJGNB_id}=${9}
#     Modify NRADJGNB_ID in File    ${NRADJGNB_id}
#     Log To Console      ${\n}============= Deleted NRADJGNB =============${\n}
#     ${out}   Parameter Operation    operation=delta_plan_update   product_type=gnb
#     ...    delta_file_path=${CURDIR}/delta_plan_nradjgnb_delete.json
#     Log To Console    Gnb0 Parameter Check Result: ${out}


# Added NRADJGNB
#     Log To Console      ${\n}============= added NRADJGNB =============${\n}
#     ${out}   Parameter Operation    operation=delta_plan_update   product_type=gnb
#     ...    delta_file_path=${CURDIR}/delta_plan_nradjgnb_add.json
#     Log To Console    Gnb0 Parameter Check Result: ${out}


# Abort xnlink establishment For BTS1
#     Log To Console      ${\n}============= abort xnlink establishment =============${\n}
#     @{para_list}      Create List    ipSecEnabled
#     @{value_list}     Create List    true
#     @{mo_list}    Create List    MRBTS-301/TNLSVC-1/TNL-1/IPAPP-1/IPSECC-1
#     ${out}            Parameter Operation    operation=parameter_update   product_type=gnb
#     ...                                      para_list=@{para_list}    value_list=${value_list}    mo_list=@{mo_list}
#     ...                                      bts_index=1
#     Log To Console    Gnb1 Parameter Check Result: ${out}

# Recover xnlink establishment For BTS1
#     Log To Console      ${\n}============= abort xnlink establishment =============${\n}
#     @{para_list}      Create List    ipSecEnabled
#     @{value_list}     Create List    false
#     @{mo_list}    Create List    MRBTS-301/TNLSVC-1/TNL-1/IPAPP-1/IPSECC-1
#     ${out}            Parameter Operation    operation=parameter_update   product_type=gnb
#     ...                                      para_list=@{para_list}    value_list=${value_list}    mo_list=@{mo_list}
#     ...                                      bts_index=1
#     Log To Console    Gnb1 Parameter Check Result: ${out}


# Check Alarm 7306 and 7311 Raised
#     [Arguments]    ${bts_index}=${0}
# 	${fault_7306}    set variable    7306
#     ${fault_7311}    set variable    7311
#     &{expected_alarms1}    Create Dictionary    fault_id=${fault_7306}
#     &{expected_alarms2}    Create Dictionary    fault_id=${fault_7311}
#     @{expected_list}       Create List     ${expected_alarms1}    ${expected_alarms2}
#     ${res}    Alarm Operation    operation=analyze_active_alarms
#     ...                          product_type=gnb
#     ...                          bts_index=${bts_index}
#     ...                          expected_alarms=${expected_list}
#     Log To Console    ${res}
#     # ${orignal_active_alarm_list}    Get Current Active Faultid
# 	# ${active_alarm_list}=    Evaluate    [item['fault_id'] for item in ${orignal_active_alarm_list}]
#     # should contain any    ${Active_alarm_list}    ${fault_7306}    ${fault_7311}

# Check Alarm 7311 Raised
#     [Arguments]    ${bts_index}=${1}
#     Log To Console      ${\n}============= check alarm 7311 =============${\n}
#     &{expected_alarms1}    Create Dictionary    fault_id=7311
#     @{expected_list}       Create List     ${expected_alarms1}
#     ${res}    ${reason}    Alarm Operation    operation=analyze_active_alarms
#     ...                          product_type=gnb
#     ...                          bts_index=${bts_index}
#     ...                          expected_alarms=${expected_list}
#     Log To Console    result:${res}
#     Log To Console    reason:${reason}
#     # Should Be True    ${res}

# Check Alarm 7311 Not Raised
#     [Arguments]    ${bts_index}=${1}
#     Log To Console      ${\n}============= check alarm 7311 =============${\n}
#     &{expected_alarms1}    Create Dictionary    fault_id=7311
#     @{expected_list}       Create List     ${expected_alarms1}
#     ${res}    ${reason}    Alarm Operation    operation=analyze_active_alarms
#     ...                          product_type=gnb
#     ...                          bts_index=${bts_index}
#     ...                          expected_alarms=${expected_list}
#     Log To Console    result:${res}
#     Log To Console    reason:${reason}
#     Should Not Be True    ${res}

# Check Alarm 7311 Canceled
#     [Arguments]    ${bts_index}=${1}
#     Log To Console      ${\n}============= check alarm 7311 =============${\n}
#     &{expected_alarms1}    Create Dictionary    fault_id=7311
#     @{expected_list}       Create List     ${expected_alarms1}
#     ${res}    ${reason}    Alarm Operation    operation=analyze_active_alarms
#     ...                          product_type=gnb
#     ...                          bts_index=${bts_index}
#     ...                          expected_alarms=${expected_list}
#     Log To Console    result:${res}
#     Log To Console    reason:${reason}
#     Check 7311 in history alarm
#     Should Not Be True    ${res}

# Check 7311 in history alarm
#     [Arguments]    ${bts_index}=${1}
#     Log To Console      ${\n}============= check alarm 7311 =============${\n}
#     ${out}    Alarm Operation    operation=get_historical_alarms
#     ...                          product_type=gnb
#     ...                          bts_index=${bts_index}
#     ${out_content}    Convert To String   ${out}
#     Should Contain    ${out_content}    No Xn link available
#     Should Contain    ${out_content}    'fault_id': 7311

# Wait For XnlinkReestabTmr Timeout
#     [Arguments]   ${timeout}=60s
#     Log To Console    =Wait For XnlinkReestabTmr
#     sleep    ${timeout}    reason=Wait For XnlinkReestabTmr

# Check Xn Auto Recover And Check Alarm
#     Log    Check Xn Auto Recover And Check Alarm

# Counter Check throughput
#     ${value1}    Counter Operation    operation=collect_counter_and_check_rule
#     ...    product_type=gnb
#     Log To Console    ${value1}

# Stop All Bts Log
#     Stop All BTSLog And Download to Local

# Restart Bts log
#     Stop BTSLite For Btslog On VM0
#     Start BTSLite For Btslog On VM    btslog_name=restart.log

# Modify NRADJGNB_ID in File
#     [Arguments]    ${NRADJGNB_ID}
#     ${content}=    Get File    ${delta_filepath}
#     ${new_content}=    Replace NRADJGNB_ID    ${content}    ${NRADJGNB_ID}
#     Create File    ${delta_filepath}    ${new_content}
#     [Return]    ${delta_filepath}

# Replace NRADJGNB_ID
#     [Arguments]    ${content}    ${NRADJGNB_ID}
#     ${pattern}=    Set Variable    NRADJGNB-\\d+
#     ${replacement}=    Set Variable    NRADJGNB-${NRADJGNB_ID}
#     ${new_content}=    Replace String Using Regexp    ${content}    ${pattern}    ${replacement}
#     [Return]    ${new_content}