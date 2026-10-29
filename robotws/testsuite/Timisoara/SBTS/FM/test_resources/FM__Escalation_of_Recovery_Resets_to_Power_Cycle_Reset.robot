*** Settings ***
Documentation
    ...  This TC is created to verify if POOR Reset counter is incremented during process kill.
    ...  RMOD from 6.2 or 7.1 families is chosen.
    ...  Initial POOR Reset Counter value is saved.
    ...  UOAM process is killed twice, and only after the second kill, the counter must be incremented.
    ...  FIDs 10, 4590, 4527 are reported during both operations.
    ...  Also, the list of operations must be correct: Reset Reason And Reset Cause fields values
    ...  must be "hard_reset" and "RecoveryReset".

Resource  ../../common_resources/ca_FM_general.robot


*** Variables ***
@{SUPPORTED_HW}  6.2  7.1  #Supported HW generation
${ALARM_TIMEOUT}  300s  # Timeout for alarm to appear in WebEM


*** Keywords ***
TC__FM__Escalation_of_Recovery_Resets_to_Power_Cycle_Reset
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-29930
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  22.09.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29930 - Initial TAT creation
    ...  26.03.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-29931 - Multiple enhancements: Verification of 4590 + fault signature +
    ...  changes in ca_FM_common keywords
    ...  ******************

    Set Tags  CA-FM  OWNER-denis.gruia@nokia.com  AUTHOR-anna.beke@nokia.com  GROUP_IN_CHARGE-TIM_4_Vrf  PHASE-CRT  FEATURE-CB013988-SR-A

    Step 0: TC Preconditions
    Step 1: Kill UOAM Process, Check POOR Reset Counter And Wait For RMOD To Recover
    Step 2: Kill UOAM Process, Check POOR Reset Counter And Wait For RMOD To Recover


Step 0: TC Preconditions
    Log  \nStep 0: TC Preconditions  console=true

    Change FMCADM Parameter  actForceUnitAutoReset  true
    Set actAlarmsSuppression to disabled
    Perform Site Reset
    ${rmods_info}  Get Frm
    FOR  ${rmod}  IN  @{rmods_info}
        ${status}  ${hw_generation}  Run Keyword And Ignore Error  Get Hw Generation For RMOD  ${rmod}[productName]
        IF  '${status}' == 'FAIL'  CONTINUE
        ${status}  Run Keyword And Return Status  List Should Contain Value  ${SUPPORTED_HW}  ${hw_generation}
        IF  not ${status}  CONTINUE
        ${rmod_cells}  Get Cell Mapping By Module Id  ${rmod}[id][internal]
        Set Test Variable  ${RMOD_DN}  ${rmod}[id][internal]
        Set Test Variable  ${RMOD_TYPE}  ${rmod}[productName]
        Set Test Variable  ${RMOD_SN}  ${rmod}[serialNumber]
        Set Test Variable  ${RMOD_CELLS}
        BREAK
    END
    ${sw_line}  Get SW Line For Specific RMOD  ${RMOD_DN}
    ${rmod_user}  ${rmod_password}  Get User And Password For RMOD  ${sw_line}  ${RMOD_TYPE}
    ${rmod_side}  ${rmod_ip}  ${stored_role}  Find RMOD Ip By Serial Number  ${RMOD_SN}
    Set Test Variable  ${RMOD_IP}
    Set Test Variable  ${RMOD_SIDE}
    Set Test Variable  ${STORED_ROLE}
    Set Test Variable  ${RMOD_USER}
    Set Test Variable  ${RMOD_PASSWORD}
    Set Test Variables For Fault Signature 4590

    Open Connection To Radio Module  ${RMOD_SIDE}  ${STORED_ROLE}  ${RMOD_IP}  ${RMOD_USER}  ${RMOD_PASSWORD}
    SSHLibrary.Write  sudo su
    SSHLibrary.Read Until Prompt
    ${initial_counter_value}  Get POOR Reset Counter From RMOD /var/log/BBOX5 File  ${RMOD_SN}
    Set Test Variable  ${INITIAL_COUNTER_VALUE}
    Log  Initial POOR Reset Counter value: ${initial_counter_value}  console=true

    [Teardown]  SSHLibrary.Close All Connections


Step ${index}: Kill UOAM Process, Check POOR Reset Counter And Wait For RMOD To Recover
    Log  \nStep ${index}: Kill UOAM Process, Check POOR Reset Counter And Wait For RMOD To Recover  console=true

    ${start_time}  Get Current Date  time_zone=UTC  result_format=datetime
    Open Connection To Radio Module  ${RMOD_SIDE}  ${STORED_ROLE}  ${RMOD_IP}  ${RMOD_USER}  ${RMOD_PASSWORD}
    SSHLibrary.Write  sudo su
    SSHLibrary.Read Until Prompt
    SSHLibrary.Write  ps | grep uoam
    ${output_ps}  SSHLibrary.Read Until Prompt
    ${lines}  Get Lines Containing String  ${output_ps}  uoamapp
    ${lines_are_empty}  Run Keyword And Return Status  Should Be Empty  ${lines}
    IF  ${lines_are_empty}
        SSHLibrary.Write  ps -aux | grep uoam
        ${output_ps}  SSHLibrary.Read Until Prompt
        ${lines}  Get Lines Containing String  ${output_ps}  uoamapp
    END
    ${split}  Split String  ${lines}
    ${pid}  Set Variable  ${split}[0]
    SSHLibrary.Write  kill -11 ${pid}
    SSHLibrary.Read Until Prompt
    SSHLibrary.Close All Connections

    ${fid_10_params}  Get String With Alarm Parameters  ${FAULT_10_Critical}
    Assert Alarm Active  parameters=${fid_10_params}  timeout=${ALARM_TIMEOUT}
    Log  Fault ${FAULT_10_Critical} is active in WebEM.  console=true
    ${fid_4590_params}  Get String With Alarm Parameters  ${FAULT_4590}
    Assert Alarm Active  parameters=${fid_4590_params}  timeout=${ALARM_TIMEOUT}
    Log  Fault ${FAULT_4590} is active in WebEM.  console=true
    ${fid_4527_params}  Get String With Alarm Parameters  ${FAULT_4527}
    Assert Alarm Active  parameters=${fid_4527_params}  timeout=${ALARM_TIMEOUT}
    Log  Fault ${FAULT_4527} is active in WebEM.  console=true

    Wait Until Keyword Succeeds  ${ALARM_TIMEOUT}  10s
    ...  Check Additional Information For Given Alarm And Fault  &{FAULT_4527}
    Log  Fault ${FAULT_4527} is active in Mantaray.  console=true
    Wait Until Keyword Succeeds  ${ALARM_TIMEOUT}  10s
    ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_10_Critical}  time_from=${start_time}
    Log  Fault ${FAULT_10_Critical} reported & cleared from Mantaray.  console=true
    Wait Until Keyword Succeeds  ${ALARM_TIMEOUT}  10s
    ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_4590}  time_from=${start_time}
    Log  Fault ${FAULT_4590} reported & cleared from Mantaray.  console=true

    Assert  RMOD  ${RMOD_DN}  operationalState=${ENABLED}  timeout=600s
    Wait Until Keyword Succeeds  180s  10s  Check Parameters Status For Cells  ${RMOD_CELLS}  operationalState=${ENABLED}

    Log  Check fault signature.  console=true
    Wait Until Keyword Succeeds  180s  10s   Check Fault Signature Of Alarm In WebEM  fault_id=${FAULT_4590}[fault_id]  category=${CATEGORY}
    ...  component=${RMOD_SN}  load_name=${SW_VERSION}  minor=${MINOR}  reset_counter=${RESET_COUNTER}
    ...  scope=${SCOPE}  info=${INFO}  rfm_gpp=${RFM_GPP}
    Check Fault Signature Of Alarm In Netact  fault_id=${FAULT_4590}[fault_id]  time_from=${start_time}  category=CATEGORY:${SPACE}${CATEGORY}
    ...  component=COMPONENT:${SPACE}${RMOD_SN}  load_name=LOAD_NAME:${SPACE}${SW_VERSION}  minor=MINOR:${SPACE}${MINOR}
    ...  reset_counter=RESET_COUNTER:${SPACE}${RESET_COUNTER}  scope=SCOPE:${SPACE}${SCOPE}
    ...  info=INFO:${SPACE}${INFO}  rfm_gpp=RFM_GPP:${SPACE}${RFM_GPP}

    Open Connection To Radio Module  ${RMOD_SIDE}  ${STORED_ROLE}  ${RMOD_IP}  ${RMOD_USER}  ${RMOD_PASSWORD}
    SSHLibrary.Write  sudo su
    SSHLibrary.Read Until Prompt
    ${poor_reset_counter}  Get POOR Reset Counter From RMOD /var/log/BBOX5 File  ${RMOD_SN}
    SSHLibrary.Close All Connections

    IF  '${index}' == '1'
        Should Be Equal As Integers  ${INITIAL_COUNTER_VALUE}
        ...                          ${poor_reset_counter}
        ...                          msg=POOR Reset Counter value: ${poor_reset_counter} is not equal to initial value: ${INITIAL_COUNTER_VALUE}.
        Log  POOR Reset Counter not incremented: ${poor_reset_counter}. [OK]  console=true
        Open Connection To Radio Module  ${RMOD_SIDE}  ${STORED_ROLE}  ${RMOD_IP}  ${RMOD_USER}  ${RMOD_PASSWORD}
        SSHLibrary.Write  sudo su
        SSHLibrary.Read Until Prompt
        Verify The List Of Operations From RMOD /var/volatile/log/BBOX5 File  ${RMOD_SN}  SOFT_RESET_SW_RESET_N_REQ  RecoveryReset  uoamapp
    ELSE
        IF  '${poor_reset_counter}' <= '${INITIAL_COUNTER_VALUE}'  Fail  POOR Counter was not incremented.
        Log  POOR Counter correctly incremented: ${poor_reset_counter}. [OK]  console=true
        Open Connection To Radio Module  ${RMOD_SIDE}  ${STORED_ROLE}  ${RMOD_IP}  ${RMOD_USER}  ${RMOD_PASSWORD}
        SSHLibrary.Write  sudo su
        SSHLibrary.Read Until Prompt
        Verify The List Of Operations From RMOD /var/volatile/log/BBOX5 File  ${RMOD_SN}  POR  RecoveryReset_POR  uoamapp
    END


    [Teardown]  SSHLibrary.Close All Connections


Set Test Variables For Fault Signature 4590
    Set Test Variable  ${CATEGORY}  SW_FAILURE
    Set Test Variable  ${RESET_COUNTER}  [0-9]+
    Set Test Variable  ${SCOPE}  RFM
    Set Test Variable  ${INFO}  resetCause=RecoveryReset.*resetSignal=(SOFT_RESET_SW_REQ|POR).*
    Set Test Variable  ${MINOR}  RFM_GPP
    Set Test Variable  ${RFM_GPP}  .*uoamapp.*


TC Setup
    Common Test Setup  tc_name=FM__Escalation_of_Recovery_Resets_to_Power_Cycle_Reset
    Setup NetAct


TC Teardown
    Perform Site Reset
    Teardown NetAct
    Common Test Teardown
