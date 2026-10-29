*** Settings ***
Documentation
    ...  This test case is created to perform software update in loop 3 times for 0 touch.
    ...  LOOP1_TARGET_SW_NAME, LOOP2_TARGET_SW_NAME, LOOP3_TARGET_SW_NAME must be given to set the SW versions for updates
    ...  After each SW update, the BTS is checked and the passive and active SW are compared

Resource  ../../common_resources/ca_CIT_general.robot


*** Variables ***
${LOOP1_TARGET_SW_NAME}  ${None}  # SW package name. If not given, TC will choose newest package in a directory.
${LOOP2_TARGET_SW_NAME}  ${None}  # SW package name. If not given, TC will choose newest package in a directory.
${LOOP3_TARGET_SW_NAME}  ${None}  # SW package name. If not given, TC will choose newest package in a directory.
${TARGET_SW_DIR}  /home/ute/TARGET_SW  # Directory in which TC should look for sw package.
# If not given, '/home/ute/btsauto/TARGET_SW' shall be used
${SW_UPDATE_TIMEOUT}  3600  # Given in seconds; That is a timeout for SW download and activation (without reset)
${PING_LOSS_TIMEOUT}  900  # Timeout for ping loss during reset
${PING_REGAIN_TIMEOUT}  1900  # Timeout for ping regain during reset
${PING_STABLE_TIMEOUT}  600  # Timeout for ping until target is stable
${RESET_ADMIN_AFTER_UPDATE}  ${TRUE}  # Flag for on-demand reset of admin after update
${BTS_ON_AIR_TIMEOUT}  15  # Timeout for BTS on Air (in minutes)


*** Keywords ***
TC__SWM__SW_Update_in_loop_x3
    [Documentation]
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 24.12.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28381 - Intial creation
    ...  **********************

    Set Tags  CA-COMPA  OWNER-mihail.steta@nokia.com  AUTHOR-iasmin.tomici@nokia.com  MAINTAINER-iasmin.tomici@nokia.com  PHASE-CRT  SW-SBTS  SW-FDSW
    ...  SW-FSM3

    Step1: Find Path To SW ${LOOP1_TARGET_SW_NAME}
    Step2: Check SW Versions Before Sw Download ${LOOP1_TARGET_SW_NAME}
    Step3: SW Update ${LOOP1_TARGET_SW_NAME}
    Step4: Check If BTS OnAir
    Step5: Check SW Versions After SW Activation And Verify Them
    Step6: Find Path To SW ${LOOP2_TARGET_SW_NAME}
    Step7: Check SW Versions Before Sw Download ${LOOP2_TARGET_SW_NAME}
    Step8: SW Update ${LOOP2_TARGET_SW_NAME}
    Step9: Check If BTS OnAir
    Step10: Check SW Versions After SW Activation And Verify Them
    Step11: Find Path To SW ${LOOP3_TARGET_SW_NAME}
    Step12: Check SW Versions Before Sw Download ${LOOP3_TARGET_SW_NAME}
    Step13: SW Update ${LOOP3_TARGET_SW_NAME}
    Step14: Check If BTS OnAir
    Step15: Check SW Versions After SW Activation And Verify Them
    Step16: Check Active Alarms


Step${index}: Find Path To SW ${target_sw_name}
    Log Step Header  step${index}: Find path to SW ${target_sw_name}
    ${target_sw_path}  Get SW File For SWDL  ${TARGET_SW_DIR}  ${target_sw_name}
    Run Keyword If  '${target_sw_path}'== ${None}
    ...  Fail  Target path could not be established
    Set Test Variable  ${TARGET_SW_PATH}  ${target_sw_path}
    Log  Chosen software package is: ${TARGET_SW_PATH}  console=true


Step${index}: Check SW Versions Before Sw Download ${target_sw_name}
    Log Step Header  step${index}: Check SW versions Before Sw Download ${target_sw_name}
    Check SW Versions Before Sw Download
    Run Keyword And Ignore Error
    ...  Log NIDD Change And Collect SCF


Step${index}: SW Update ${target_sw_name}
    Log Step Header  step${index}: Will now perform software update ${target_sw_name}
    ${start_time}  Get Current Date  time_zone=UTC  result_format=datetime
    Set Test Variable  ${START_TIME}  ${start_time}
    ${software_update_start}  Get Current Date
    ${sw_update_result}  ${sw_update_msg}  Run Keyword And Ignore Error
    ...  Update Software  ${TARGET_SW_PATH}  True  timeout=${SW_UPDATE_TIMEOUT}
    Set Test Variable  ${SW_UPDATE_RESULT}    ${sw_update_result}
    After SW update


Step${index}: Check If BTS OnAir
    Log Step Header  step${index}: Check if BTS onAir
    Check If BTS OnAir


Step${index}: Check SW Versions After SW Activation And Verify Them
    Log Step Header  step${index}: Check SW versions after SW activation and verify them
    Check SW Versions After SW Activation And Verify Them


Step16: Check Active Alarms
    Log Step Header  step16: Check active alarms
    ${critical_alarms1}  Create Dictionary  severity=Major
    ${critical_alarms2}  Create Dictionary  severity=Critical
    ${critical_patterns}  Create List  ${critical_alarms1}  ${critical_alarms2}
    ${alarms_status}  ${alarms_return}  Run Keyword And Ignore Error
    ...  Admin Check Active Alarms TAF  critical_patterns=${critical_patterns}
    Run Keyword If  '${alarms_status}'=='FAIL'
    ...  Fail  Major/Critical alarm found.
    Run Keyword If  ${alarms_return}
    ...  Set Test Restriction  Minor alarm found.
    Log  The verification of fault 4592 will start.  console=true
    ${date}  Get BTS time in UTC format  %Y-%m-%d %H
    Set Test Variable  ${DATE}  ${date}
    Sleep  20  TC waits 20s for fault to be loaded in history.
    ${historical_alarms}  Get Historic Alarms  60  load_history=True  severity=warning
    ${smods}  Get FSM Info
    FOR  ${smod}  IN  @{smods}
        ${length_product_name}  Get Length  ${smod}[productName]
        ${product_name}  Run Keyword If  ${length_product_name}>4
        ...  Fetch From Left  ${smod}[productName]  ${SPACE}
        ${outdoor_modules}  Set Variable If  '${product_name}' in ['ASOE','ASOF','ASOH','ASOG','ASIK']
        ...  ${TRUE}
        ...  ${FALSE}
        Exit For Loop If  ${outdoor_modules}
    END
    Run Keyword If  ${outdoor_modules}
    ...  Check The Appearance Of 4592 And Supplementary Alarm Info  ${historical_alarms}
    ...  ELSE
    ...  Check If Fault 4592 Is Not Visible In WebEM  ${historical_alarms}


Check SW Versions Before Sw Download
    ${software_info}  Get Software Info
    Set Test Variable  ${ACTIVE_SW_BEFORE}  ${software_info['Active SW version']}
    Set Test Variable  ${PASSIVE_SW_BEFORE}  ${software_info['Passive SW version']}
    Log  Active software package is: ${ACTIVE_SW_BEFORE}  console=true
    Log  Passive software package is: ${PASSIVE_SW_BEFORE}  console=true


After SW update
    ${software_update_end}  Get Current Date
    Run Keyword If  '${SW_UPDATE_RESULT}'=='FAIL'
    ...  Fail  Software update failed: ${sw_update_msg}
    ${ping_loss_status}  Run Keyword And Return Status
    ...  Wait For Target To Be Not Reachable  hostname=${SMOD1['TRS_IP']}  timeout=${PING_LOSS_TIMEOUT}
    Run Keyword If  ${ping_loss_status}==${FALSE}
    ...  Log  BTS RESET after successful sw update DID NOT OCCUR  console=true
    ...  ELSE
    ...  Log  BTS is resetting after successful sw update  console=true
    ${ping_loss}  Get Current Date
    ${ping_regain_status}  Run Keyword And Return Status
    ...  Wait For Target To Be Reachable  hostname=${SMOD1['TRS_IP']}  timeout=${PING_REGAIN_TIMEOUT}
    Run Keyword If  ${ping_regain_status}==${False}
    ...  Fail  Ping has not been regained within timeout
    ${ping_regain}  Get Current Date
    ${ping_stable_status}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  5x  20
    ...  Check If Target Is Stable  ${SMOD1['TRS_IP']}  min_uptime=360  max_downtime=0  timeout=${PING_STABLE_TIMEOUT}
    Run Keyword If  ${ping_stable_status}==${False}
    ...  Fail  Ping has not been available for ${PING_STABLE_TIMEOUT} seconds
    Wait Until Keyword Succeeds  5m  10s
    ...  sbts_admin.Admin And Infomodel Connections Reset  ${RESET_ADMIN_AFTER_UPDATE}


Check If BTS OnAir
    Log  Will now check if BTS is OnAir, timeout=${BTS_ON_AIR_TIMEOUT}min, interval=10sec  console=true
    Wait Until Keyword Succeeds  ${BTS_ON_AIR_TIMEOUT} min  10 sec
    ...  Admin Check All Required State
    Log Important Message  BTS is OnAir, all cells and modules are in expected states


Check SW Versions After SW Activation And Verify Them
    Checking MNL_R Status
    ${software_info}  Get Software Info
    Set Test Variable  ${ACTIVE_SW_AFTER}  ${software_info['Active SW version']}
    Set Test Variable  ${PASSIVE_SW_AFTER}  ${software_info['Passive SW version']}
    Set Tags  SW_AFTER_ACTIVATION_active-${ACTIVE_SW_AFTER}
    Set Tags  SW_AFTER_ACTIVATION_passive-${PASSIVE_SW_AFTER}
    Log  Passive software package is: ${PASSIVE_SW_AFTER}, expected: ${ACTIVE_SW_BEFORE}  console=true
    Should Contain  ${PASSIVE_SW_AFTER}  ${ACTIVE_SW_BEFORE}
    Log Important Message  SW builds on active and passive partition are as expected


Check If Fault 4592 Is Not Visible In WebEM
    [Arguments]  ${historical_alarms}
    ${status_list}  Run Keyword And Return Status  Should Not Be Empty  ${historical_alarms}
    Run Keyword If  ${status_list}
    ...  Check If Alarm 4592 Is Visible In History Alarms  ${historical_alarms}
    ...  ELSE
    ...  Log  Alarms with warning severity were not found in history alarms. [OK]  console=true


Check If Alarm 4592 Is Visible In History Alarms
    [Arguments]  ${historical_alarms}
    FOR  ${alarm}  IN  @{historical_alarms}
        ${status_alarm}  Run Keyword And Return Status
        ...  Should Be Equal As Strings  ${alarm}[faultId]  ${FAULT_4592}[fault_id]
        Run Keyword If  ${status_alarm}
        ...  Fail  Alarm 7115 "${FAULT_4592}[fault_name]" has appeared in historical alarms in WebEM. [NOK]
    END


Check The Appearance Of 4592 And Supplementary Alarm Info
    [Arguments]  ${historical_alarms}
    FOR  ${alarm}  IN  @{historical_alarms}
        ${status_alarm}  Run Keyword And Return Status
        ...  Should Be Equal As Strings  ${alarm}[faultId]  ${FAULT_4592}[fault_id]
        ${gmt_string}  Remove String  ${alarm}[btsObservationTimezone]  :
        ${gmt_time}  Fetch From Right  ${gmt_string}  +
        ${status_suppl_info}  Run Keyword And Return Status
        ...  Should Match Regexp  ${alarm}[alarmText][alarmAdditionalInfo][supplAlarmInfo]
        ...  BTS booted at ${DATE}:\\d{2}:\\d{2} GMT\\+${gmt_time} due to software reset
        Run Keyword If  ${status_alarm} and ${status_suppl_info}
        ...  Run Keywords
        ...  Log  Alarm 7115 "${FAULT_4592}[alarm_name]" has the correct supplementary info in historical alarms in WebEM. [OK]  console=true
        ...  AND
        ...  Set Test Variable  ${SUPPL_INFO}  BTS booted at ${DATE}:\\d{2}:\\d{2} GMT\\+${gmt_time} due to software reset
        ...  AND
        ...  Exit For Loop
    END
    Run Keyword If  ${status_suppl_info}==${FALSE}
    ...  Log  Alarm "${FAULT_4592}[fault_name]" is not visible correctly in WebEM. [OK]  ERROR  console=true
    Run Keyword If  ${STATUS_NETACT}
    ...  Checking Netact Integration State And Alarm in Cleared Alarms In Netact
    ...  &{FAULT_4592}  time_from=${START_TIME}  suppl_info=.*${SUPPL_INFO}.*


Log NIDD Change And Collect SCF
    Log  Log NIDD change, collect and validate SCF before download and activation  console=true
    ${active_package_name}  Get TargetBD Attribute Value From Active Partition  swReleaseVersionPackageName
    ${target_package_name}  hran_file_operations.Get TargetBD Node Attribute Value  swReleaseVersionPackageName  ${TARGET_SW_PATH}
    Log  active swReleaseVersionPackageName: ${active_package_name}\ntarget swReleaseVersionPackageName: ${target_package_name}  console=true
    ${active_sw}  Should Match Regexp  ${active_package_name}  SBTS.+_ENB_[0-9]{4}_[0-9]{6}_[0-9]{6}
    ${target_sw}  Should Match Regexp  ${target_package_name}  SBTS.+_ENB_[0-9]{4}_[0-9]{6}_[0-9]{6}
    Collect SCF  ${BTS_FILES}/SCF_${active_sw}_before_SW_Download.xml
    ${scf_valid}  ${msg}  Run Keyword And Ignore Error
    ...  Validate Scf  scf_file=${BTS_FILES}/SCF_${active_sw}_before_SW_Download.xml  timeout=240
    Run Keyword If  '${scf_valid}'=='FAIL'
    ...  Set Test Restriction  SCF Validation on BASE SW:${active_sw} failed:\n${msg}
    Log  SCF has been saved under ${BTS_FILES}/SCF_${active_sw}_before_SW_Download.xml  console=true


TC Setup
    Common Test Setup  tc_name=SWM__SW_Update_in_loop_x3
    ${status_netact}  Run Keyword And Return Status  Setup Netact
    Set Test Variable  ${STATUS_NETACT}  ${status_netact}
    Run Keyword If  ${status_netact}
    ...  Log  SBTS is integrated into Netact. Alarm check will follow.  console=true
    ...  ELSE
    ...  Log  SBTS is not integrated into Netact. Alarm check will be skipped.  console=true


TC Teardown
    Common Test Teardown