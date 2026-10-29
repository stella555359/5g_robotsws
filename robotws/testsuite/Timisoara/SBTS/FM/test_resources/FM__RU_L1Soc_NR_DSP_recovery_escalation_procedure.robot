*** Settings ***
Documentation
    ...  This test is created to trigger RMOD recovery and appearance of fault 2941 and 1981.
    ...  RMOD information is retrieved.
    ...  Site reset is performed to clear all recovery reset counters.
    ...  RMOD recovery is triggered four times.
    ...  First, fault 2941 is reported in rawAlarmHistoryFile.
    ...  After every trigger, TC must wait 10 minutes to send the next one.
    ...  At the final trigger, fault 1981 is reported in WebEM and Netact.
    ...  All services must be operational at the end of the TC.


Resource  ../../common_resources/ca_FM_general.robot


*** Variables ***
${RMOD_TYPE}  ${EMPTY}   #RMOD type.Can be from 7.1 generation(e.g. AVQL, AVHA, AVQE, AVQC)
${ALARM_TIMEOUT}  300  # Timeout for fault to appear.


*** Keywords ***
TC__FM__RU_L1Soc_NR_DSP_recovery_escalation_procedure
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-29556
    ...
    ...  History of changes
    ...  ******************
    ...  04.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29556 - Initial TAT creation
    ...  25.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29190 - Enhancement of all test cases in regression to check fault signature
    ...  25.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29459 - Enhancement of all test cases in regression to check FS component field
    ...  29.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29612 - Created radio modules data file and new RMOD connection method
    ...  21.08.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29737 - Update retrieval method of RMOD credentials.
    ...  16.10.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30020 - Test fails beacuse fault signature can not be retrieved
    ...  ******************

    Set Tags  CA-FM  OWNER-ioan.marta@nokia.com  AUTHOR-anna.beke@nokia.com  GROUP_IN_CHARGE-TIM_4_Vrf  PHASE-CRT  FEATURE-CB009514-KB

    Step 0: TC Preconditions
    Step 1: Trigger Fault 2941 On RMOD
    Step 2: Trigger Fault 2941 On RMOD
    Step 3: Trigger Fault 2941 On RMOD
    Step 4: Trigger Fault 2941 On RMOD


Step 0: TC Preconditions
    Log  \nStep 0: TC preconditions.  console=true

    ${rmod_sn}  Get Random RMOD Serial Number By Given RMOD Type  ${RMOD_TYPE}
    ${rmods_info}  Get Frm
    FOR  ${rmod}  IN  @{rmods_info}
        ${status}  Run Keyword And Return Status  Should Be Equal As Strings  ${rmod}[serialNumber]  ${rmod_sn}
        IF  not ${status}  CONTINUE
        ${rmod_cells}  Get Cell Mapping By Module Id  ${rmod}[id][internal]
        Set Test Variable  ${RMOD_DN}  ${rmod}[id][internal]
        Set Test Variable  ${RMOD_CELLS}
        BREAK
    END
    Variable Should Exist  ${RMOD_DN}  message=RMOD DN not found for RMOD with serial number: ${rmod_sn}.
    ${smod_side}  ${rmod_ip}  ${stored_role}  Find RMOD Ip By Serial Number  ${rmod_sn}
    ${sw_line}  Get SW Line For Specific RMOD  ${RMOD_DN}
    ${rmod_user}  ${rmod_password}  Get User And Password For RMOD  ${sw_line}  ${RMOD_TYPE}
    Set Test Variable  ${RMOD_SN}
    Set Test Variable  ${RMOD_IP}
    Set Test Variable  ${SMOD_SIDE}
    Set Test Variable  ${STORED_ROLE}
    Set Test Variable  ${CATEGORY}  SW_FAILURE
    Set Test Variable  ${SCOPE}  RFM
    Set Test Variable  ${EXTRA_INFO}  faulty_cells=.*NR:[0-9]+.*
    Set Test Variable  ${RESET_COUNTER}  [0-9]+
    Set Test Variable  ${RMOD_USER}
    Set Test Variable  ${RMOD_PASSWORD}
    Perform Site Reset


Step ${index}: Trigger Fault 2941 On RMOD
    Log  \nStep ${index}: Trigger fault 2941 on RMOD.  console=true

    ${start_time}  Get Current Date  time_zone=UTC  result_format=datetime
    ${current_date_time}  Get Current Date  result_format=%Y-%b-%d %H:%M:%S
    Open Connection To Radio Module  ${SMOD_SIDE}  ${STORED_ROLE}  ${RMOD_IP}  ${RMOD_USER}  ${RMOD_PASSWORD}
    SSHLibrary.Write  ssh 192.168.100.17
    SSHLibrary.Read Until Prompt
    SSHLibrary.Write  sudo su
    SSHLibrary.Read Until Prompt
    Sleep  2s  Wait to send the first command.
    SSHLibrary.Write  devmem 0x87E044E01600 64 1
    SSHLibrary.Read Until Prompt

    IF  ${index} == 1
        Wait Until Keyword Succeeds  180s  10s  Verify Alarm In RawAlarmHistory File  2941  ${current_date_time}  ${None}  inactive
        Log  Wait 10 minutes before sending next trigger.  console=true
        Sleep  10min  Wait 10 minutes before triggering next fault.
    ELSE IF  ${index} == 2 or ${index} == 3
        Log  Wait 10 minutes before sending next trigger.  console=true
        Sleep  10min  Wait 10 minutes before triggering next fault.
    ELSE
        Log  Verify fault 1981 Warning - presence.  console=true
        ${fid_1981_params}  Get String With Alarm Parameters  ${FAULT_1981_RADIO_AUTO_RST}
        Assert Alarm Active  parameters=${fid_1981_params}  timeout=${ALARM_TIMEOUT}
        Log  Fault ${FAULT_1981_RADIO_AUTO_RST} is active in WebEM.  console=true
        Wait Until Keyword Succeeds  180s  10s  Check Parameters Status For Cells  ${RMOD_CELLS}  operationalState=${DISABLED}
        Log  Cells mapped on RMOD are disabled.  console=true
        Wait Until Keyword Succeeds  60s  10s
        ...  Check Fault Signature Of Alarm In WebEM  fault_id=${FAULT_1981_RADIO_AUTO_RST}[fault_id]  category=${CATEGORY}  scope=${SCOPE}
        ...  component=${RMOD_SN}  extra_info=${EXTRA_INFO}  reset_counter=${RESET_COUNTER}  load_name=${SW_VERSION}
        Wait Until Keyword Succeeds  60s  10s
        ...  Check Fault Signature Of Alarm In Netact  fault_id=${FAULT_1981_RADIO_AUTO_RST}[fault_id]  time_from=${START_TIME}
        ...  category=CATEGORY:${SPACE}${CATEGORY}  scope=SCOPE:${SPACE}${SCOPE}  component=COMPONENT:${SPACE}${RMOD_SN}
        ...  extra_info=EXTRA_INFO:${SPACE}${EXTRA_INFO}  reset_counter=RESET_COUNTER:${SPACE}${RESET_COUNTER}
        ...  load_name=LOAD_NAME:${SPACE}${SW_VERSION}
        Wait Until Keyword Succeeds  ${ALARM_TIMEOUT}  10s
        ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_1981_RADIO_AUTO_RST}  time_from=${start_time}
        Log  Fault ${FAULT_1981_RADIO_AUTO_RST} reported & cleared from Netact.  console=true
    END
    Log  Verify RMOD and cells mapped on it are enabled.  console=true
    Assert  RMOD  ${RMOD_DN}  operationalState=${ENABLED}  timeout=300s
    Wait Until Keyword Succeeds  180s  10s  Check Parameters Status For Cells  ${RMOD_CELLS}  operationalState=${ENABLED}
    Log  All services are operational after triggering fault on RMOD.  console=true

    [Teardown]  SSHLibrary.Close Connection


TC Setup
    Common Test Setup  tc_name=FM__RU_L1Soc_NR_DSP_recovery_escalation_procedure
    Setup Netact


TC Teardown
    Teardown Netact
    Common Test Teardown
