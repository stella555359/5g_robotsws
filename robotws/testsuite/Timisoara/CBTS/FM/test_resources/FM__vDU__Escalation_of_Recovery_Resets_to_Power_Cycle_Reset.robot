*** Settings ***
Documentation
    ...  This TC is created to verify if POOR Reset counter is incremented during process kill.
    ...  RMOD from 5.1, 6.2 or 7.1 families is chosen.
    ...  Initial POOR Reset Counter value is saved.
    ...  UOAM process is killed twice, and only after the second kill, the counter must be incremented.
    ...  FIDs 10, 4590, 4527 are reported during both process kill operations.
    ...  Also, the list of operations must be correct: Reset Reason And Reset Cause fields values
    ...  must be "hard_reset" and "RecoveryReset".

Resource  ../../common_resources/vdu_frame.robot
Resource  ../../common_resources/vdu_general.robot


*** Variables ***
@{SUPPORTED_HW}  5.1  6.2  7.1  #Supported HW generation
${DC}  ${TRUE}  #Configuration type
${ALARM_TIMEOUT}  300s     # Timeout for alarm to appear in WebEM
${RECOVERY_TIMEOUT}  900s  # Timeout for CBTS to be onAir


*** Keywords ***
TC__FM__vDU__Escalation_of_Recovery_Resets_to_Power_Cycle_Reset
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-29936
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  23.09.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29936 - Initial TAT creation
    ...  ******************

    Set Tags  CA-FM  OWNER-denis.gruia@nokia.com  AUTHOR-anna.beke@nokia.com  GROUP_IN_CHARGE-TIM_4_Vrf  PHASE-CRT  FEATURE-CB013988-CR-A

    Step 0: TC Preconditions
    Step 1: Kill UOAM Process, Wait For RMOD To Recover and Check Counter And Operations
    Step 2: Kill UOAM Process, Wait For RMOD To Recover and Check Counter And Operations


Step 0: TC Preconditions
    Log  \nStep 0: TC Preconditions  console=true

    Change specific parameter for vDU  actAlarmsSuppression  allowAlarms  MRBTS-${VDU_MRBTS_ID}/MNL-1/MNLENT-1/FMCADM-1/ALARMSUPP-1
    Set Alarms Dictionaries
    ${rmods}  vdu.Get Rmods Status
    ${all_rmods_ips}  Get All RMODs IPs from vDU
    FOR  ${current_rmod}  IN  @{rmods}
        ${status}  ${hw_generation}  Run Keyword And Ignore Error  Get Hw Generation For RMOD  ${current_rmod}[product_name]
        IF  '${status}' == 'FAIL'  CONTINUE
        ${status}  Run Keyword And Return Status  List Should Contain Value  ${SUPPORTED_HW}  ${hw_generation}
        IF  not ${status}  CONTINUE
        ${active_sw_build}  Split String  ${current_rmod}[active_sw_build]  .
        ${rmod_user}  ${rmod_password}  Get User And Password For RMOD  ${active_sw_build}[1]  ${current_rmod}[product_name]
        IF  '${hw_generation}' == '5.1'
            ${rmod_user}  Set Variable  root
        END
        ${rmod_ip}  Get Ip For RMOD  ${current_rmod}[serial_number]  ${rmod_user}  ${rmod_password}  ${all_rmods_ips}  dc=${DC}
        ${rmod}  Create Dictionary   serial_number=${current_rmod}[serial_number]
        ...                          id=${current_rmod}[id]
        ...                          ip=${rmod_ip}
        ...                          user=${rmod_user}
        ...                          password=${rmod_password}
        ...                          hw_generation=${hw_generation}
        Set Test Variable  ${RMOD}
        BREAK
    END
    Should Not Be Empty  ${RMOD}  msg=No RMOD found from given generations: ${SUPPORTED_HW}.
    Log  Chosen RMOD information: ${RMOD}

    Open SSH Connection To Specific RMOD  ${RMOD}[ip]  ${RMOD}[user]  ${RMOD}[password]  ${RMOD}[serial_number]  dc=${DC}
    ${initial_counter_value}  Get POOR Reset Counter From RMOD /var/log/BBOX5 File  ${RMOD}[serial_number]
    Set Test Variable  ${INITIAL_COUNTER_VALUE}
    Log  Initial POOR Reset Counter value: ${initial_counter_value}  console=true

    [Teardown]  SSHLibrary.Close All Connections


Step ${index}: Kill UOAM Process, Wait For RMOD To Recover and Check Counter And Operations
    Log  \nStep ${index}: Kill UOAM Process, Wait For RMOD To Recover and Check Counter And Operations  console=true

    Open SSH Connection To Specific RMOD  ${RMOD}[ip]  ${RMOD}[user]  ${RMOD}[password]  ${RMOD}[serial_number]  dc=${DC}
    IF  '${RMOD}[hw_generation]' == '5.1'
        SSHLibrary.Write  ps | grep uoam
        ${output_ps}  SSHLibrary.Read Until Prompt
        ${lines}  Get Lines Containing String  ${output_ps}  uoamapp
        ${split}  Split String  ${lines}
        ${pid}  Set Variable  ${split}[0]
        SSHLibrary.Write  kill -11 ${pid}
    ELSE
        SSHLibrary.Write  ps aux | grep uoam
        ${output_ps}  SSHLibrary.Read Until Prompt
        ${lines}  Get Lines Containing String  ${output_ps}  uoamapp
        ${split}  Split String  ${lines}
        ${pid}  Set Variable  ${split}[1]
        SSHLibrary.Write  kill -11 ${pid}
    END
    SSHLibrary.Close All Connections

    Wait Until Keyword Succeeds  ${ALARM_TIMEOUT}  5s
    ...  Check If Fault Is Visible In VDU WebEM  ${FAULT_10_Critical}[alarm_id]
    ...                                          ${FAULT_10_Critical}[alarm_name]
    ...                                          ${FAULT_10_Critical}[fault_id]
    ...                                          ${FAULT_10_Critical}[fault_name]
    ...                                          ${FAULT_10_Critical}[severity]
    Log  Fault ${FAULT_10_Critical} is active in WebEM  console=true
    Wait Until Keyword Succeeds  ${ALARM_TIMEOUT}  5s
    ...  Check If Fault Is Visible In VDU WebEM  ${FAULT_4590}[alarm_id]
    ...                                          ${FAULT_4590}[alarm_name]
    ...                                          ${FAULT_4590}[fault_id]
    ...                                          ${FAULT_4590}[fault_name]
    ...                                          ${FAULT_4590}[severity]
    Log  Fault ${FAULT_4590} is active in WebEM  console=true
    Wait Until Keyword Succeeds  ${ALARM_TIMEOUT}  5s
    ...  Check If Fault Is Visible In VDU WebEM  ${FAULT_4527}[alarm_id]
    ...                                          ${FAULT_4527}[alarm_name]
    ...                                          ${FAULT_4527}[fault_id]
    ...                                          ${FAULT_4527}[fault_name]
    ...                                          ${FAULT_4527}[severity]
    Log  Fault ${FAULT_4527} is active in WebEM  console=true

    Log  Checking RMOD and cells to be on air.  console=true
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  5s  Verify RMOD Parameter By RMOD Id  ${RMOD}[id]  availability_status  ${ONLINE}
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  5s  Check All Cells From VDU  operational_state=${ENABLED}
    ...                                                                             availability_status=${ONLINE}
    ...                                                                             administrative_state=${UNLOCKED}
    Log  All services are operational after fault triggering and RMOD reset.[OK]  console=true

    Open SSH Connection To Specific RMOD  ${RMOD}[ip]  ${RMOD}[user]  ${RMOD}[password]  ${RMOD}[serial_number]  dc=${DC}
    ${poor_reset_couter}  Get POOR Reset Counter From RMOD /var/log/BBOX5 File  ${RMOD}[serial_number]
    SSHLibrary.Close All Connections
    IF  '${index}' == '1'
        Should Be Equal As Strings  ${INITIAL_COUNTER_VALUE}  ${poor_reset_couter}
        Log  POOR Reset Counter not incremented: ${poor_reset_couter}. [OK]  console=true
    ELSE
        IF  '${poor_reset_couter}' <= '${INITIAL_COUNTER_VALUE}'  Fail  POOR Counter was not incremented.
        Log  POOR Counter correctly incremented: ${poor_reset_couter}. [OK]  console=true
    END
    Open SSH Connection To Specific RMOD  ${RMOD}[ip]  ${RMOD}[user]  ${RMOD}[password]  ${RMOD}[serial_number]  dc=${DC}
    Verify The List Of Operations From RMOD /var/volatile/log/BBOX5 File  ${RMOD}[serial_number]  .*hard_reset  RecoveryReset

    [Teardown]  SSHLibrary.Close All Connections


Set Alarms Dictionaries
    ${FAULT_10_Critical}  Create Dictionary  alarm_id=7116
    ...                                      alarm_name=BASE STATION SERVICE PROBLEM
    ...                                      fault_id=10
    ...                                      fault_name=No connection to unit
    ...                                      severity=regex"Critical|critical"
    ${FAULT_4590}  Create Dictionary  alarm_id=7115
    ...                               alarm_name=BASE STATION INFORMATION
    ...                               fault_id=4590
    ...                               fault_name=Fault signature for crash or failure
    ...                               severity=regex"Warning|warning"
    ${FAULT_4527}  Create Dictionary  alarm_id=7115
    ...                               alarm_name=BASE STATION INFORMATION
    ...                               fault_id=4527
    ...                               fault_name=Radio Diagnostic Files collected
    ...                               severity=regex"Minor|minor"
    Set Test Variable  ${FAULT_10_Critical}
    Set Test Variable  ${FAULT_4590}
    Set Test Variable  ${FAULT_4527}


TC Setup
    Common VDU Setup
    Modify Resource Search Order  FM__Escalation_of_Recovery_Resets_to_Power_Cycle_Reset


TC Teardown
    Perform VDU Reset
    Common VDU Teardown
