*** Settings ***
Documentation
    ...  TC for genereting fault23 on RMODS (turn off RMODs -> SW update -> turn ON RMODs) and updating RMOD software

Resource  ../../common_resources/ca_CIT_general.robot


*** Variables ***
${TARGET_SW_NAME}  ${None}  # SW package name. If not given, TC will choose newest package in a directory.
${TARGET_SW_DIR}  /home/ute/btsauto/TARGET_SW  # Directory in which TC should look for sw package. If not given,
# '/home/ute/btsauto/TARGET_SW' shall be used
${SW_UPDATE_TIMEOUT}  600  # Given in seconds; That is a timeout for SW download and activation
# (without reset)
${PING_LOSS_TIMEOUT}  240  # Timeout for ping loss during reset
${PING_REGAIN_TIMEOUT}  600  # Timeout for ping regain during reset
${TEST_TIMEOUT}  90  # Test timeout (in minutes)
${ON_AIR_CHECK_NUMBER}  60  # Number of checks for proceduralStatus: onAir after RMODs reset is complete;
${PING_STABLE_TIMEOUT}  600  # Timeout for ping to regain stable status
${RM_DETECTION_TIMEOUT}  15 min  # Timeout for all connected RMs detection (in minutes)
${HW_OFF_ID_LIST}  ${EMPTY}  # Module names as defined in interfaces.yaml. Modules shall be separated by comas
# (eg. SMOD_K11232234,RMOD_L11232234)
# Undefined names that are in interfaces.yaml will be turned ON
${NUMBER_OF_RMODS_TO_TURN_OFF}  1  # How many RMODs should be turned off (random choice)


*** Keywords ***
TC__SWM__SW_update_for_RMOD_with_fault_23
    [Documentation]
    ...
    ...  *********************
    ...  3. History of changes
    ...  *********************
    ...
    ...  - 08.11.2019 - initial creation
    ...  - 11.02.2020 - TAT-1900 Change values of 'max_downtime' and 'timeout' in Step6:KW:Check If Target Is Stable
    ...  - 16.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24946 - Replace hran_tools with taf.sw.ping
    ...  - 12.12.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26286 - Add Ping stable timeout variable for fixing ping timeout
    ...  - 19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Add watchdog alarm monitoring
    ...
    ...  **********************
    ...  4. Test case flowchart
    ...  **********************
    ...
    ...  https://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SBTS/SWM__SW_update_for_RMOD_with_fault_23.png
    [Timeout]  ${TEST_TIMEOUT} minutes

    Set Tags  OWNER-mariusz.bak@nokia.com  AUTHOR-wojciech.sikora@nokia.com  MAINTAINER-iasmin.tomici@nokia.com  GROUP_IN_CHARGE-TIM_2_Vrf  CA-SWM
    ...  PHASE-CIT  SW-SBTS17  SW-SBTS18  SW-SBTS19  FEATURE-RP001486_RP000912  FEATURE-RP001145_RP000912

    Step0: TC Precondition
    Step1: Check SW Versions
    Step2: Turn OFF RMODs On PDU
    Step3: SW Update
    Step4: Turn ON RMODs On PDU
    Step5: Check If Fault 23 Is Present
    Step6: Update SW On RMODs
    Step7: Check If BTS OnAir
    Step8: Check If Fault 23 Absent
    Step9: Check If All Cells OnAir


Step0: TC Precondition
    Log Step Header  step0: TC Precondition
    Set Test Variable  ${EXPECTED_BTS_STATUS}  ${ON_AIR}
    Log  Waiting for all RMODs will be detected  console=true
    ${status}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${RM_DETECTION_TIMEOUT}  20s
    ...  Check If All Radio Modules Are Available
    Run Keyword If  ${status}==${FALSE}
    ...  Set Test Blocked  Not all radio modules are available


Step1: Check SW Versions
    Log Step Header  step1: Check SW versions
    ${active_sw}  Infomodel Get Active SW Version
    Set Global Variable  ${ACTIVE_SW}
    ${passive_sw}  Infomodel Get Passive SW Version
    Log  Active software package is: ${ACTIVE_SW}  console=true
    Log  Passive software package is: ${passive_sw}  console=true
    Run Keyword If  '${ACTIVE_SW}'==''
    ...  Log  Active sw version was not readable  level=ERROR  console=true
    Run Keyword If  '${passive_sw}'==''
    ...  Log  Passive sw version was not readable  level=WARN  console=true
    Find Path To SW Package
    Run Keyword If  '${TARGET_SW_PATH}'== ${None}
    ...  Fail  No path to SW build provided


Step2: Turn OFF RMODs On PDU
    Log Step Header  step2: Turn OFF RMODs on PDU
    ${hw_off_id_list}  Split String  ${HW_OFF_ID_LIST}  ,
    Run Keyword If  '${hw_off_id_list[0]}'==''
    ...  Choose RMODs On Random
    ...  ELSE
    ...  Set Test Variable  ${hw_off_id_list}
    ${number_of_rmods_to_turn_off}  Get Length  ${hw_off_id_list}
    Log Important Message  List of RMODs to be turned OFF:${hw_off_id_list}${\n}How many:${number_of_rmods_to_turn_off} module/s
    State Change If Needed  ${hw_off_id_list}  Off
    Sleep  120s
    Log  Check if turned off RMODs are disabled in ADMIN  console=true
    Check If Right Amount RMODs Disabled
    Log  All turned off RMODs are disabled  console=true


Step3: SW Update
    Log Step Header  step3: SW update
    Log  Will now perform software update  console=true
    ${sw_update_result}  ${sw_update_msg}  Run Keyword And Ignore Error
    ...  Update Software  ${TARGET_SW_PATH}  True  timeout=${SW_UPDATE_TIMEOUT}
    Run Keyword If  '${sw_update_result}'=='FAIL'
    ...  Set Test Failed  Software update failed: ${sw_update_msg}
    ${ping_loss_status}  Run Keyword And Return Status
    ...  Wait For Target To Be Not Reachable  hostname=${SMOD1['TRS_IP']}  timeout=${PING_LOSS_TIMEOUT}
    Run Keyword If  ${ping_loss_status}==${FALSE}
    ...  Fail  BTS RESET after successful sw update DID NOT OCCUR
    ...  ELSE
    ...  Log To Console With Time  BTS is resetting after successful sw update
    ${ping_regain_status}  Run Keyword And Return Status
    ...  Wait For Target To Be Reachable  hostname=${SMOD1['TRS_IP']}  timeout=${PING_REGAIN_TIMEOUT}
    Run Keyword If  ${ping_regain_status}==${False}
    ...  Set Test Failed  Ping has not been regained within timeout
    ...  ELSE
    ...  Log To Console With Time  Ping regained
    Log  Will now check if BTS ping is stable for: 200 seconds - Please Wait...  console=true
    ${ping_stable_status}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  5x  20
    ...  Check If Target Is Stable  ${SMOD1['TRS_IP']}  min_uptime=360  max_downtime=0  timeout=${PING_STABLE_TIMEOUT}
    Run Keyword If  ${ping_stable_status}==${False}
    ...  Set Test Failed  Ping has not been available for ${PING_STABLE_TIMEOUT} seconds
    Wait Until Keyword Succeeds  5 min  10 sec
    ...  Fail If Connection With Admin Is Not Available


Step4: Turn ON RMODs On PDU
    Log Step Header  step4: Turn ON RMODs on PDU
    State Change If Needed  ${HW_OFF_ID_LIST}  On
    Log  Will now check if all radio modules are available...  console=true
    ${status}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${RM_DETECTION_TIMEOUT}  20s
    ...  Check If All Radio Modules Are Available
    Run Keyword If  ${status}
    ...  Log Important Message  All RMODs ON
    ...  ELSE
    ...  Set Test Blocked  Not all radio modules are available


Step5: Check If Fault 23 Is Present
    Log Step Header  step5: Check if fault 23 is present
    ${radios_with_fault_23_dn_list}  Create List
    Set Test Variable  ${RADIOS_WITH_FAULT_23_LIST}  ${radios_with_fault_23_dn_list}
    Log  Will now check if fault 23 if present on correct RMOD/s...  console=true
    ${fault_23_check}  Wait Until Keyword Succeeds  ${RM_DETECTION_TIMEOUT}  30 sec
    ...  Check Fault 23 For All Rmods
    Run Keyword If  ${fault_23_check}
    ...  Log  Fault 23 has been detected for following RMODs: ${RADIOS_WITH_FAULT_23_LIST}  console=true
    ...  ELSE
    ...  Set Test Norun  No fault 23 found!  fail_test=${FALSE}


Step6: Update SW On RMODs
    Log Step Header  step6: Update SW on RMODs
    Log  Will now perform software update  console=true
    ${sw_update_result}  ${sw_update_msg}  Run Keyword And Ignore Error
    ...  Update Software  ${TARGET_SW_PATH}  ${TRUE}  timeout=${SW_UPDATE_TIMEOUT}
    Run Keyword If  '${sw_update_result}'=='FAIL'
    ...  Set Test Failed  SW update failed. Reason: ${sw_update_msg}
    Log To Console With Time  SW update to RMOD/s done${\n}Result:${sw_update_result}${\n}Msg:${sw_update_msg}
    Log  Wait until rmods reset (operationalState Disabled)  console=true
    Wait Until Keyword Succeeds  3 min  15 sec
    ...  Check Rmods OperationalState Disabled  ${RADIOS_WITH_FAULT_23_LIST}
    Log To Console With Time  RMOD/s are resetting
    Log  Wait until rmods operationalState Enabled  console=true
    Wait Until Keyword Succeeds  10 min  30 sec
    ...  Assert Every  RMOD  operationalState=${ENABLED}
    Log To Console With Time  All RMOD/s operationalState=Enabled
    Log  Wait for SMOD ping stability results  console=true
    ${smod_ping_stable}  Check If Target Is Stable  ${SMOD1['TRS_IP']}  min_uptime=360  max_downtime=5  timeout=370
    Log To Console With Time  SMOD stability ping check result: ${smod_ping_stable}
    Run Keyword If  ${smod_ping_stable}
    ...  Log  SMOD is stable during RMODs update  console=true
    ...  ELSE
    ...  Set Test Failed  SMOD lost ping during RMODs update


Step7: Check If BTS OnAir
    Log Step Header  step7: Check if BTS onAir
    Log  Will now check if BTS is onAir maximum of ${ON_AIR_CHECK_NUMBER} times with 10s interval.  console=true
    FOR  ${run}  IN RANGE  1  ${ON_AIR_CHECK_NUMBER}
        ${bts_on_air}  Get Mrbts State
        ${matches}  Run Keyword And Return Status
        ...  Should Match Regexp  ${bts_on_air}  (?i)OnAir
        Run Keyword If  '${matches}' == '${True}'
        ...  Run Keywords
        ...  Log  BTS is onAir! Check attempt: ${run}  console=true
        ...  AND
        ...  Return From Keyword
        Sleep  10
    END
    Set Test Failed  BTS not onAir within timeout


Step8: Check If Fault 23 Absent
    Log Step Header  step8: Check if fault 23 absent
    ${active_alarms}  coam.Get Active Alarms
    ${radios_with_fault_23_after}  Create List
    FOR  ${alarm}  IN  @{active_alarms}
        Run Keyword If  ${alarm}[faultId] == ${FAULT_23}[fault_id]
        ...  Append To List  ${radios_with_fault_23_after}  ${alarm}[notifier]
    END
    ${verification_status}  Run Keyword And Return Status
    ...  Should Be Empty  ${radios_with_fault_23_after}
    Run Keyword If  ${verification_status}==${FALSE}
    ...  Set Test Failed  Fault 23 has been detected for following RMODS: ${radios_with_fault_23_after}. Test failed.
    Log  Fault 23 has not been detected.  console=true


Step9: Check If All Cells OnAir
    Log Step Header  step9: Check if all cells onAir
    Log  Will now wait for all cells to be online. Will check every 10 seconds untill success or TC timeout (30min).  console=true
    FOR  ${run}  IN RANGE  1  420
        ${all_cell_status}  Infomodel Check If All Objects From Path Are Online  ${DIST_CELLS}
        Run Keyword If  ${all_cell_status} == ${TRUE}
        ...  Run Keywords
        ...  Log  All cells online! Check attempt: ${run}  console=true
        ...  AND
        ...  Exit For Loop
        Sleep  10
    END


Check Rmods OperationalState Disabled
    [Arguments]  ${radios_with_fault_23_list}

    ${rmods_parameters}  Get Parameters For All  RMOD
    FOR  ${radio_with_fault_23}  IN ZIP  ${radios_with_fault_23_list}
        ${status}  Check If RMOD Is Disabled  ${radio_with_fault_23}  ${rmods_parameters}
        Run Keyword If  ${status}
        ...  Remove Values From List  ${radios_with_fault_23_list}  ${radio_with_fault_23}
    END
    ${all_rmods_reset}  Run Keyword And Return Status
    ...  Should Be Empty  ${radios_with_fault_23_list}
    Run Keyword If  ${all_rmods_reset}==${FALSE}
    ...  Fail  Radios: ${radios_with_fault_23_list} didn't reset


Check If RMOD Is Disabled
    [Arguments]  ${radio_with_fault_23}  ${rmods_parameters}

    FOR  ${rmod_parameters}  IN  @{rmods_parameters}
        ${radio_with_fault_23_cut}  Get Regexp Matches  ${radio_with_fault_23}  EQM_R-[0-9]+\/APEQM_R-[0-9]+\/RMOD_R-[0-9]+
        Run Keyword If  '${radio_with_fault_23_cut[0]}' in '${rmod_parameters['id']}'
        ...  Log  ${rmod_parameters['id']} : ${rmod_parameters['operationalState']}  console=true
        ${is_disabled}  Run Keyword And Return Status
        ...  Should Match Regexp  ${rmod_parameters['operationalState']}  (?i)Disabled
        Return From Keyword If  '${radio_with_fault_23_cut[0]}' in '${rmod_parameters['id']}' and $is_disabled  ${TRUE}
    END

    [Return]  ${FALSE}


State Change If Needed
    [Arguments]  ${hw_id_list}  ${pdu_target_state}

    FOR  ${hw_id}  IN  @{hw_id_list}
        ${hw_state}  Pdu BTS Interface Get Status  ${hw_id}
        ${hw_target_state}  Set Variable  ${pdu_target_state}
        Run Keyword If  '${hw_state}'!='${hw_target_state}'
        ...  Change Pdu State And Check Status  ${hw_id}  ${hw_target_state}
        ...  ELSE
        ...  Log  ${hw_id} status already correct: ${hw_state}  console=true
    END


Change Pdu State And Check Status
    [Arguments]  ${hw_id}  ${interface_state}  # state value should be: On/Off

    Log  Turn Pdu ${interface_state} And Check Status for: ${hw_id}  console=true
    Run Keyword If  '${interface_state}'=='Off'
    ...  Pdu BTS Interface Off  ${hw_id}
    ...  ELSE IF  '${interface_state}'=='On'
    ...  Pdu BTS Interface On  ${hw_id}
    Sleep  1
    ${hw_status}  Pdu BTS Interface Get Status  ${hw_id}
    Log  hw_status after ${interface_state} operation: ${hw_status}  console=true


Choose RMODs On Random
    ${interfaces_modules}  Get Turned ON RMODs
    Log  All RMODs from interface.yaml:${\n}${interfaces_modules}  console=true
    @{hw_off_id_list}  Evaluate  random.sample(${interfaces_modules},${NUMBER_OF_RMODS_TO_TURN_OFF})  random
    Set Test Variable  ${HW_OFF_ID_LIST}


Check Fault 23 For All Rmods
    Log  ...checking...  console=true
    ${active_alarms}  coam.Get Active Alarms
    FOR  ${alarm}  IN  @{active_alarms}
        Run Keyword If  ${alarm}[faultId] == ${FAULT_23}[fault_id]
        ...  Append To List  ${RADIOS_WITH_FAULT_23_LIST}  /${alarm}[notifier]
    END
    ${fault_23_presence_status}  Run Keyword And Return Status
    ...  Should Not Be Empty  ${RADIOS_WITH_FAULT_23_LIST}
    ${list_len_check}  Run Keyword And Return Status
    ...  Length Should Be  ${RADIOS_WITH_FAULT_23_LIST}  ${NUMBER_OF_RMODS_TO_TURN_OFF}
    Should Be True  ${fault_23_presence_status} and ${list_len_check}

    [Return]  ${TRUE}


Check If Right Amount RMODs Disabled
    Sleep  20
    ${turned_off_rmods_serial_numbers}  Create List
    FOR  ${rmods_id}  IN  @{HW_OFF_ID_LIST}
        ${serial_number}  Should Match Regexp  ${rmods_id}  [A-Z0-9]{6,20}
        Append To List  ${turned_off_rmods_serial_numbers}  ${serial_number}
    END
    ${rmods_parameters}  Get Parameters For All  RMOD
    FOR  ${module_parameters}  IN  @{rmods_parameters}
        Run Keyword If  '${module_parameters['serialNumber']}' in @{turned_off_rmods_serial_numbers}
        ...  Should Match Regexp  '${module_parameters['operationalState']}'  (?i)Disabled
        Log  RMOD:${module_parameters['serialNumber']}${\n}operationalState:${module_parameters['operationalState']}  console=true
    END


Fail If Connection With Admin Is Not Available
    ${status}  Run Keyword And Return Status
    ...  Get Mrbts State
    Run Keyword If  ${status}
    ...  Return From Keyword
    ${admin_reset_status}  Run Keyword And Return Status
    ...  Reset Admin
    ${status}  Run Keyword And Return Status
    ...  Get Mrbts State
    Run Keyword If  ${status}
    ...  Return From Keyword
    Fail  ${admin_reset_status}


Custom Test Teardown
    Common Test Teardown
    State Change If Needed  ${HW_OFF_ID_LIST}  On


TC Setup
    Common Test Setup  expected_bts_status=${EXPECTED_BTS_STATUS}  tc_name=SWM__SW_update_for_RMOD_with_fault_23


TC Teardown
    SWM__SW_update_for_RMOD_with_fault_23.Custom Test Teardown
