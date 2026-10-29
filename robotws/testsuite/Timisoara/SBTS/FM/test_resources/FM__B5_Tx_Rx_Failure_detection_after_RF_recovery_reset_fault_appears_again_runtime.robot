*** Settings ***
Documentation
    ...  This test case was created to trigger fault 1911 two times on CPRI RMOD.
    ...  RMOD is chosen and all variables are set.
    ...  First fault is triggered in runtime, RMOD recovery is performed.
    ...  Second fault is in runtime, RMOD recovery is performed.
    ...  At the end, site reset is performed to clear all recovery reset counters.


Resource  ../../common_resources/ca_FM_general.robot


*** Variables ***
${RMOD_TYPE}  ${EMPTY}  # Type of RMOD that will be used to send the fault. Should be CPRI.
${ALARM_TIMEOUT}  300s  # [in seconds] Timeout for alarm to be reported in WebEM and Netact


*** Keywords ***
TC__FM__B5_Tx_Rx_Failure_detection_after_RF_recovery_reset_fault_appears_again_runtime
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-29754
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  27.08.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29754 - Initial TAT creation
    ...  *******************

    Set Tags  CA-FM  OWNER-vincentiu.nacov@nokia.com  AUTHOR-anna.beke@nokia.com  GROUP_IN_CHARGE-TIM_4_Vrf  PHASE-CRT  FEATURE-CB009504-SR-BA


    Step 0: TC Preconditions
    Step 1: Trigger Fault 1911 On RMOD
    Step 2: Trigger Fault 1911 On RMOD


Step 0: TC Preconditions
    Log  \nStep 0: TC Preconditions.  console=true

    ${start_time}  Get Current Date  time_zone=UTC  result_format=datetime
    Change Parameter ActForce(Unit)AutoReset  true  actForceUnitAutoReset
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
    ${sw_line}  Get SW Line For Specific RMOD  ${RMOD_DN}
    ${rmod_user}  ${rmod_password}  Get User And Password For RMOD  ${sw_line}  ${RMOD_TYPE}
    ${smod_side}  ${rmod_ip}  ${stored_role}  Find RMOD Ip By Serial Number  ${rmod_sn}
    Set Test Variable  ${RMOD_SN}
    Set Test Variable  ${RMOD_IP}
    Set Test Variable  ${SMOD_SIDE}
    Set Test Variable  ${STORED_ROLE}
    Set Test Variable  ${RMOD_USER}
    Set Test Variable  ${RMOD_PASSWORD}
    Set Test Variable  ${START_TIME}

    Log  Perform RMOD reset...  console=true
    coam.Reset Unit  ${RMOD_DN}  timeout=300
    Assert  RMOD  ${RMOD_DN}  operationalState=${DISABLED}  timeout=180s
    Assert  RMOD  ${RMOD_DN}  operationalState=${ENABLED}  timeout=180s


Step ${index}: Trigger Fault 1911 On RMOD
    Log  \nStep ${index}: Trigger Fault 1911 On RMOD.  console=true

    Log  Trigger Alarm in Runtime - wait more than 4 minutes after radio detection...  console=true
    Sleep  242s  Wait at least 4 minutes to send fault.
    Open Connection To Radio Module  ${SMOD_SIDE}  ${STORED_ROLE}  ${RMOD_IP}  ${RMOD_USER}  ${RMOD_PASSWORD}
    SSHLibrary.Write  devmem 0xFF988114 32 0x0
    SSHLibrary.Read Until Prompt
    SSHLibrary.Write  devmem 0xFF990114 32 0x0
    SSHLibrary.Read Until Prompt

    Log  Verify fault 1911 Warning - presence.  console=true
    ${fid_1911_params}  Get String With Alarm Parameters  ${FAULT_1911_RADIO_AUTO_RST}
    Assert Alarm Active  parameters=${fid_1911_params}  timeout=${ALARM_TIMEOUT}
    Log  Fault ${FAULT_1911_RADIO_AUTO_RST} is active in WebEM.  console=true
    Wait Until Keyword Succeeds  ${ALARM_TIMEOUT}  10s
    ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_1911_RADIO_AUTO_RST}  time_from=${START_TIME}
    Log  Fault ${FAULT_1911_RADIO_AUTO_RST} reported & cleared from Netact.  console=true
    Assert  RMOD  ${RMOD_DN}  operationalState=${ENABLED}  timeout=300s
    Wait Until Keyword Succeeds  180s  10s  Check Parameters Status For Cells  ${RMOD_CELLS}  operationalState=${ENABLED}

    [Teardown]  SSHLibrary.Close Connection


TC Setup
    Common Test Setup  tc_name=FM__B5_Tx_Rx_Failure_RF_recovery
    Setup NetAct


TC Teardown
    Perform Site Reset
    Teardown NetAct
    Common Test Teardown
