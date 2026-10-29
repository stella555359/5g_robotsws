*** Settings ***
Documentation
    ...  This test is created to verify that, after software rollback, if enforcedRecovTimeWindow is active,
    ...  power resets on BBMOD are allowed when triggering the following faults on RMOD:
    ...  fault 1904 - should perform RMOD recovery
    ...  fault 1905 - should perform RMOD recovery
    ...  fault 1956 - should perform RMOD recovery
    ...  fault 1955 - should not perform RMOD recovery and reset counter doesn`t increment his value.
    ...  The test should be performed on:
    ...  BBMOD: ABIA,ABIN and ABIO where OBSAI RMOD are connected: FRGY,FXDB, ...Fxxx.
    ...  First, RMOD details are set and software rollback is performed.
    ...  Parameters actForceAutoReset and enforcedRecovTimeWindow are set to required values.
    ...  Software rollback is performed for the second time.
    ...  Faults are sent one by one and RMOD, cells and alarms checks are done.
    ...  At the end, if alarm 4001 is raised, site reset is performed and all services must be operational.

Resource  ../../common_resources/ca_FM_general.robot


*** Variables ***
${RESTORE_TIMEOUT}  30m  # [in minutes] Timeout for waiting until cells are onAir after rollback.
${PING_LOSS_TIMEOUT}  10m  # [in minutes] Timeout for ping loss during reset
${PING_REGAIN_TIMEOUT}  10m  # [in minutes] Timeout for ping regain during reset
${ALARM_TIMEOUT}  300  # [in seconds] Timeout for alarms to appear or disappear.


*** Keywords ***
TC__FM__Robustness_trigger_different_faults_RMOD
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-26139
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  20.09.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26139 - Initial TAT creation
    ...  15.11.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25658 - Create new resources for NetAct and ONAP KWs
    ...  19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Use faults defined in py file
    ...  25.06.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27703 - Tests fail due multiple keywords with the same name
    ...  30.08.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28027 - Add check for 4241-4247 faults in Raw Alarm History
    ...  31.10.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28025 - Enhancement for verifying additonalFaultID in NetAct
    ...  07.11.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28341 - Test fails when checking fault in rawAlarmHistory
    ...  22.05.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29213 - Replace RMOD info search from /rom/config/FRIps.txt
    ...  ******************

    Set Tags  CA-FM  OWNER-mircea.vladulescu@nokia.com  AUTHOR-anna.benzar@nokia.com  MAINTAINER-anna.benzar@nokia.com  GROUP_IN_CHARGE-TIM_4_Vrf
    ...  PHASE-CRT  SW-SBTS24  FEATURE-CB010884-A

    Step 0: Testcase Preconditions
    Step 1: Set ActForceAutoReset To Be False
    Step 2: Check And Set EnforcedRecovTimeWindow Value
    Step 3: Perform SW Rollback
    Step 4: Trigger FID 1904 On Obsai RMOD
    Step 5: Trigger FID 1905 On Obsai RMOD
    Step 6: Trigger FID 1956 On Obsai RMOD
    Step 7: Trigger FID 1955 On Obsai RMOD
    Step 8: Trigger FID 1956 On Obsai RMOD
    Step 9: Verify Faults Presence In RawAlarmHistory File


Step 0: Testcase Preconditions
    Log  \nStep 0: Testcase preconditions.  console=true
    ${test_start_time}  Get Current Date  time_zone=UTC  result_format=datetime
    ${rmod_sn}  Get Random RMOD Serial Number By Given RMOD Type  ^F[A-Z]{3,4}
    ${rmod_dn}  Get Module Dist Name By Serial Number And Class  ${rmod_sn}  RMOD
    ${rmod_cells}  Get Cell Mapping By Module Id  ${rmod_dn}
    ${rmod_bbmods}  Get Baseband Modules On Which Radio Module Is Mapped  ${rmod_dn}
    Set Variables For Site Reset Or SC Reset  ${rmod_bbmods}
    ${current_date_time_raw}  Get BTS time in UTC format  %Y-%b-%d %H:%M:%S
    ${expected_faults_raw}  Create List  4241  4242  4243  4244  4246  4247
    Set Test Variable  ${TEST_START_TIME}
    Set Test Variable  ${RMOD_SN}
    Set Test Variable  ${RMOD_DN}
    Set Test Variable  ${RMOD_CELLS}
    Set Test Variable  ${CURRENT_DATE_TIME_RAW}
    Set Test Variable  ${EXPECTED_FAULTS_RAW}
    Log  Chosen rmod serial number is: ${RMOD_SN}.  console=true
    Log  Perform software rollback at the beginning of the test.  console=true
    Perform Software Rollback And Check BTS State  ${RESTORE_TIMEOUT}  ${PING_LOSS_TIMEOUT}  ${PING_REGAIN_TIMEOUT}
    Check Active And Pasive Software Versions To Be Set Correctly  ${PASSIVE_SW_VERSION}  ${ACTIVE_SW_VERSION}


Step 1: Set ActForceAutoReset To Be False
    Log  \nStep 1: Set actForceAutoReset to be false.  console=true
    Change Parameter ActForce(Unit)AutoReset  false  actForceAutoReset


Step 2: Check And Set EnforcedRecovTimeWindow Value
    Log  \nStep 2: Check and set enforcedRecovTimeWindow value.  console=true
    ${message}  Change Parameter EnforcedRecovTimeWindow  ${BTS_ID}  Enforced recovery enabled within 0 - 90 minutes
    Log  ${message}  console=true


Step 3: Perform SW Rollback
    Log  \nStep 3: Perform SW rollback.  console=true
    Perform Software Rollback And Check BTS State  ${RESTORE_TIMEOUT}  ${PING_LOSS_TIMEOUT}  ${PING_REGAIN_TIMEOUT}
    Check Active And Pasive Software Versions To Be Set Correctly  ${ACTIVE_SW_VERSION}  ${PASSIVE_SW_VERSION}
    Sleep  260s  Wait at least 4 minutes to send fault.


Step 4: Trigger FID 1904 On Obsai RMOD
    Log  \nStep 4: Trigger FID 1904 on Obsai RMOD.  console=true
    ${smod_side}  ${rmod_ip}  ${stored_role}  Find RMOD Ip By Serial Number  ${RMOD_SN}
    Connect To RMOD Through Lxc-attach And Telnet Using Rmod Ip, Side And Port  ${rmod_ip}  ${smod_side}  2323  ${stored_role}
    SSHLibrary.Write  sendFault 1103 0 0 0 0 0 0
    SSHLibrary.Read Until Prompt
    SSHLibrary.Close All Connections
    Log  Fault sent.  console=true
    Wait Until Keyword Succeeds  300s  10s
    ...  Check Cells On RMOD To Be Degraded Or Disabled  ${RMOD_CELLS}
    ${fault_1904_params}  Get String With Alarm Parameters  ${FAULT_1904_RADIO_AUTO_RST}
    Assert Alarm Active  parameters=${fault_1904_params}  timeout=${ALARM_TIMEOUT}
    Log  Fault 1904 "${FAULT_1904_RADIO_AUTO_RST}[fault_name]" is active in WebEM. [OK]  console=true
    Wait Until Keyword Succeeds  ${ALARM_TIMEOUT}  10s
    ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_1904_RADIO_AUTO_RST}  time_from=${TEST_START_TIME}
    ...  additional_fault_id=${FAULT_1904_RADIO_AUTO_RST}[fault_id]
    Log  Fault 1904 "${FAULT_1904_RADIO_AUTO_RST}[fault_name]" appeared & cleared from NetAct. [OK]  console=true
    Wait Until Keyword Succeeds  300s  10s
    ...  Assert  RMOD  ${RMOD_DN}  parameters=operationalState=${ENABLED}
    Wait Until Keyword Succeeds  300s  10s
    ...  Check Parameters Status For Cells  ${RMOD_CELLS}  operationalState=${ENABLED}
    Log  RMOD and cells are up after recovery reset. [OK]  console=true
    Sleep  120s  Wait 2 minutes before sending next fault.


Step 5: Trigger FID 1905 On Obsai RMOD
    Log  \nStep 5: Trigger FID 1905 on Obsai RMOD.  console=true
    ${smod_side}  ${rmod_ip}  ${stored_role}  Find RMOD Ip By Serial Number  ${RMOD_SN}
    Connect To RMOD Through Lxc-attach And Telnet Using Rmod Ip, Side And Port  ${rmod_ip}  ${smod_side}  2323  ${stored_role}
    SSHLibrary.Write  sendFault 1102 0 0 0 0 0 0
    SSHLibrary.Read Until Prompt
    SSHLibrary.Close All Connections
    Log  Fault sent.  console=true
    Wait Until Keyword Succeeds  300s  10s
    ...  Check Cells On RMOD To Be Degraded Or Disabled  ${RMOD_CELLS}
    ${fault_1905_params}  Get String With Alarm Parameters  ${FAULT_1905_RADIO_AUTO_RST}
    Assert Alarm Active  parameters=${fault_1905_params}  timeout=${ALARM_TIMEOUT}
    Log  Fault 1905 "${FAULT_1905_RADIO_AUTO_RST}[fault_name]" is active in WebEM. [OK]  console=true
    Wait Until Keyword Succeeds  ${ALARM_TIMEOUT}  10s
    ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_1905_RADIO_AUTO_RST}  time_from=${TEST_START_TIME}
    ...  additional_fault_id=${FAULT_1905_RADIO_AUTO_RST}[fault_id]
    Log  Fault 1905 "${FAULT_1905_RADIO_AUTO_RST}[fault_name]" appeared & cleared from NetAct. [OK]  console=true
    Wait Until Keyword Succeeds  300s  10s
    ...  Assert  RMOD  ${RMOD_DN}  parameters=operationalState=${ENABLED}
    Wait Until Keyword Succeeds  300s  10s
    ...  Check Parameters Status For Cells  ${RMOD_CELLS}  operationalState=${ENABLED}
    Log  RMOD and cells are up after recovery reset. [OK]  console=true
    Sleep  120s  Wait 2 minutes before sending next fault.


Step 6: Trigger FID 1956 On Obsai RMOD
    Log  \nStep 6: Trigger FID 1956 on Obsai RMOD.  console=true
    ${smod_side}  ${rmod_ip}  ${stored_role}  Find RMOD Ip By Serial Number  ${RMOD_SN}
    Connect To RMOD Through Lxc-attach And Telnet Using Rmod Ip, Side And Port  ${rmod_ip}  ${smod_side}  2323  ${stored_role}
    SSHLibrary.Write  sendFault 1229 1 0 0 0 0 0
    SSHLibrary.Read Until Prompt
    SSHLibrary.Close All Connections
    Log  Fault sent.  console=true
    Wait Until Keyword Succeeds  300s  10s
    ...  Check Cells On RMOD To Be Degraded Or Disabled  ${RMOD_CELLS}
    ${fault_1956_params}  Get String With Alarm Parameters  ${FAULT_1956_RADIO_AUTO_RST}
    Assert Alarm Active  parameters=${fault_1956_params}  timeout=${ALARM_TIMEOUT}
    Log  Fault 1956 "${FAULT_1956_RADIO_AUTO_RST}[fault_name]" is active in WebEM. [OK]  console=true
    Wait Until Keyword Succeeds  ${ALARM_TIMEOUT}  10s
    ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_1956_RADIO_AUTO_RST}  time_from=${TEST_START_TIME}
    ...  additional_fault_id=${FAULT_1956_RADIO_AUTO_RST}[fault_id]
    Log  Fault 1956 "${FAULT_1956_RADIO_AUTO_RST}[fault_name]" appeared & cleared from NetAct. [OK]  console=true
    Wait Until Keyword Succeeds  300s  10s
    ...  Assert  RMOD  ${RMOD_DN}  parameters=operationalState=${ENABLED}
    Sleep  120s  Wait 2 minutes before sending next fault.


Step 7: Trigger FID 1955 On Obsai RMOD
    Log  \nStep 7: Trigger FID 1955 on Obsai RMOD.  console=true
    ${smod_side}  ${rmod_ip}  ${stored_role}  Find RMOD Ip By Serial Number  ${RMOD_SN}
    Connect To RMOD Through Lxc-attach And Telnet Using Rmod Ip, Side And Port  ${rmod_ip}  ${smod_side}  2323  ${stored_role}
    SSHLibrary.Write  sendFault 1228 1 0 0 0 0 0
    SSHLibrary.Read Until Prompt
    SSHLibrary.Close All Connections
    Log  Fault sent.  console=true
    Wait Until Keyword Succeeds  300s  10s
    ...  Assert  RMOD  ${RMOD_DN}  parameters=availabilityStatus=${DEGRADED}
    Wait Until Keyword Succeeds  300s  10s
    ...  Check Cells On RMOD To Be Degraded Or Disabled  ${RMOD_CELLS}
    ${fault_1955_params}  Get String With Alarm Parameters  ${FAULT_1955_BER_DETECTED_ON_OPT_CONN}
    Assert Alarm Active  parameters=${fault_1955_params}  timeout=${ALARM_TIMEOUT}
    Log  Fault 1955 "${FAULT_1955_BER_DETECTED_ON_OPT_CONN}[fault_name]" is active in WebEM. [OK]  console=true
    Wait Until Keyword Succeeds  300s  10s
    ...  Check Additional Information For Given Alarm And Fault  &{FAULT_1955_BER_DETECTED_ON_OPT_CONN}
    ...  additional_fault_id=${FAULT_1955_BER_DETECTED_ON_OPT_CONN}[fault_id]
    Log  Fault 1955 "${FAULT_1955_BER_DETECTED_ON_OPT_CONN}[fault_name]" is active in NetAct. [OK]  console=true
    Sleep  120s  Wait 2 minutes before sending next fault.


Step 8: Trigger FID 1956 On Obsai RMOD
    Log  \nStep 8: Trigger FID 1956 on Obsai RMOD.  console=true
    FOR  ${cell}  IN  @{RMOD_CELLS}
         ${cell_parameters}  coam.Get Parameters  ${cell}
         ${degraded_status}  Run Keyword And Return Status
         ...  Should Contain  ${DEGRADED}  ${cell_parameters}[availabilityStatus]
         Exit For Loop If  ${degraded_status}
    END
    IF  ${degraded_status} == ${TRUE}  Block all cells mapped on RMOD
    ${smod_side}  ${rmod_ip}  ${stored_role}  Find RMOD Ip By Serial Number  ${RMOD_SN}
    Connect To RMOD Through Lxc-attach And Telnet Using Rmod Ip, Side And Port  ${rmod_ip}  ${smod_side}  2323  ${stored_role}
    SSHLibrary.Write  sendFault 1229 1 0 0 0 0 0
    SSHLibrary.Read Until Prompt
    SSHLibrary.Close All Connections
    Log  Fault sent.  console=true

    IF  ${SITE_RESET}
        Verify Site Autonomous Reset Scenario
    ELSE IF  ${SC_RESET}
        Verify Secondary Core Reset Scenario
    ELSE
        Verify FSP Recovery Scenario
    END


Step 9: Verify Faults Presence In RawAlarmHistory File
    Log  \nStep 9: Verify Faults Presence In RawAlarmHistory File.  console=true
    FOR  ${fault_id}  IN  @{EXPECTED_FAULTS_RAW}
       ${fault_status}  Run Keyword And Return Status  Verify Alarm In RawAlarmHistory File  ${fault_id}  ${CURRENT_DATE_TIME_RAW}
       Return From Keyword If  ${fault_status}
    END
    Fail  No fault from ${EXPECTED_FAULTS_RAW} list reported in "RawAlarmHistory" file on current date, after ${CURRENT_DATE_TIME_RAW}. [NOK]


Get Baseband Modules On Which Radio Module Is Mapped
    [Arguments]  ${rmod_r_dn}

    ${cables}  Get Parameters For All  CABLINK
    ${rmod_bbmods}  Create List
    FOR  ${cable}  IN  @{cables}
         ${rmod_status}  Run Keyword And Return Status  Should Be Equal  ${cable}[secondEndpointDN]  ${rmod_r_dn}
         IF  ${rmod_status}  Append To List  ${rmod_bbmods}  ${cable}[firstEndpointDN]
    END
    Should Not Be Empty  ${rmod_bbmods}  Didn't found the BBMOD/s on which RMOD with dist name: ${rmod_r_dn} is mapped. [NOK]
    Log  BBMODs on which RMOD is mapped, are: ${rmod_bbmods}.  console=true

    [Return]  ${rmod_bbmods}


Set Variables For Site Reset Or SC Reset
    [Arguments]  ${rmod_bbmods}
    ${bbmods_on_sc}  Set variable  0
    Set Test Variable  ${SITE_RESET}  ${FALSE}
    Set Test Variable  ${SC_RESET}  ${FALSE}
    FOR  ${bbmod_dn}  IN  @{rmod_bbmods}
         ${2g_3g_status}  Verify GSM Or WCDMA Cells Existence On Baseband Module  ${bbmod_dn}
         Exit For Loop If  ${2g_3g_status}
    END
    FOR  ${bbmod_dn}  IN  @{rmod_bbmods}
         ${bbmod_position}  Get Module Horizontal Position  ${bbmod_dn}
         IF  ${bbmod_position} == 2
             ${bbmods_on_sc}  Evaluate  ${bbmods_on_sc} + 1
         ELSE
             ${bbmods_on_sc}  Set Variable  ${bbmods_on_sc}
         END
    END
    IF  ${2g_3g_status} == ${TRUE} and ${bbmods_on_sc} == 1
        Set Test Variable  ${SITE_RESET}  ${TRUE}
    ELSE IF  ${2g_3g_status} == ${TRUE} and ${bbmods_on_sc} == 2
        Set Test Variable  ${SC_RESET}  ${TRUE}
    ELSE
        Log  There are no GSM or WCDMA cells mapped on RMOD BBMODs.  console=true
    END


Verify GSM Or WCDMA Cells Existence On Baseband Module
    [Arguments]  ${bbmod_dn}

    ${bbmod_cells}  Get Cell Mapping By Module Id  ${bbmod_dn}
    FOR  ${cell}  IN  @{bbmod_cells}
         ${2g_status}  Run Keyword And Return Status  Should Contain  ${cell}  GNCEL
         ${3g_status}  Run Keyword And Return Status  Should Contain  ${cell}  WNCEL
         IF  ${2g_status} or ${3g_status}  Return From Keyword  ${TRUE}
    END

    [Return]  ${FALSE}


Block all cells mapped on RMOD
    FOR  ${cell}  IN  @{RMOD_CELLS}
        Block Cell  dist_name=${cell}  timeout=180
    END


Verify Site Autonomous Reset Scenario
    Log  Verify Site Autonomus Reset Alarm.  console=true
    ${fault_1956_params}  Get String With Alarm Parameters  ${FAULT_1956_SITE_AUTO_RST}
    Assert Alarm Active  parameters=${fault_1956_params}  timeout=${ALARM_TIMEOUT}
    Log  Fault 1956 "${FAULT_1956_SITE_AUTO_RST}[fault_name]" is active in WebEM. [OK]  console=true
    Wait Until Keyword Succeeds  ${ALARM_TIMEOUT}  10s
    ...  Check Additional Information For Given Alarm And Fault in NA cleared alarms  &{FAULT_1956_SITE_AUTO_RST}  time_from=${TEST_START_TIME}
    ...  additional_fault_id=${FAULT_1956_SITE_AUTO_RST}[fault_id]
    Log  Fault 1956 "${FAULT_1956_SITE_AUTO_RST}[fault_name]" appeared & cleared from Netact. [OK]  console=true
    Wait Until Keyword Succeeds  ${STARTUP_TIMEOUT}  30  Check Modules And Cells


Verify Secondary Core Reset Scenario
    Log  Verify Secondary Core Reset Alarm.  console=true
    Change Parameter ActForce(Unit)AutoReset  true  actForceAutoReset
    ${fault_1956_params}  Get String With Alarm Parameters  ${FAULT_1956_SC_AUTO_RST}
    Assert Alarm Active  parameters=${fault_1956_params}  timeout=${ALARM_TIMEOUT}
    Log  Fault 1956 "${FAULT_1956_SC_AUTO_RST}[fault_name]" is active in WebEM. [OK]  console=true
    Wait Until Keyword Succeeds  ${ALARM_TIMEOUT}  10s
    ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_1956_SC_AUTO_RST}  time_from=${TEST_START_TIME}
    ...  additional_fault_id=${FAULT_1956_SC_AUTO_RST}[fault_id]
    Log  Fault 1956 "${FAULT_1956_SC_AUTO_RST}[fault_name]" appeared & cleared from NetAct. [OK]  console=true
    ${fault_4001_params}  Get String With Alarm Parameters  ${FAULT_4001_RAT_AUTO_RST}
    Assert Alarm Active  parameters=${fault_4001_params}  timeout=${ALARM_TIMEOUT}
    Log  Fault 4001 "${FAULT_4001_RAT_AUTO_RST}[fault_name]" is active in WebEM. [OK]  console=true
    Wait Until Keyword Succeeds  ${ALARM_TIMEOUT}  10s
    ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_4001_RAT_AUTO_RST}  time_from=${TEST_START_TIME}
    ...  additional_fault_id=${FAULT_4001_RAT_AUTO_RST}[fault_id]
    Log  Fault 1956 "${FAULT_4001_RAT_AUTO_RST}[fault_name]" appeared & cleared from NetAct. [OK]  console=true
    FOR  ${cell}  IN  @{RMOD_CELLS}
        ${cell_parameters}  coam.Get Parameters  ${cell}
        ${blocked_status}  Run Keyword And Return Status
        ...  Should Contain  ${BLOCKED}  ${cell_parameters}[blockingState]
        IF  ${blocked_status}  Unblock Cell  dist_name=${cell}  timeout=180
    END
    Wait Until Keyword Succeeds  ${STARTUP_TIMEOUT}  30  Check Modules And Cells


Verify FSP Recovery Scenario
    Log  Verify FSP Recovery Alarm.  console=true
    ${fault_1956_params}  Get String With Alarm Parameters  ${FAULT_1956_BB_AUTO_RST}
    Assert Alarm Active  parameters=${fault_1956_params}  timeout=${ALARM_TIMEOUT}
    Log  Fault 1956 "${FAULT_1956_BB_AUTO_RST}[fault_name]" is active in WebEM. [OK]  console=true
    Wait Until Keyword Succeeds  ${ALARM_TIMEOUT}  10s
    ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_1956_BB_AUTO_RST}  time_from=${TEST_START_TIME}
    ...  additional_fault_id=${FAULT_1956_BB_AUTO_RST}[fault_id]
    Log  Fault 1956 "${FAULT_1956_BB_AUTO_RST}[fault_name]" appeared & cleared from NetAct. [OK]  console=true
    FOR  ${cell}  IN  @{RMOD_CELLS}
        ${cell_parameters}  coam.Get Parameters  ${cell}
        ${blocked_status}  Run Keyword And Return Status
        ...  Should Contain  ${BLOCKED}  ${cell_parameters}[blockingState]
        IF  ${blocked_status}  Unblock Cell  dist_name=${cell}  timeout=180
    END
    Wait Until Keyword Succeeds  ${STARTUP_TIMEOUT}  30  Check Modules And Cells


Perform Recovery Action
    ${rmod_status}  Run Keyword And Return Status
    ...  Assert  RMOD  ${RMOD_DN}  parameters=operationalState=${ENABLED}
    ${cells_status}  Run Keyword And Return Status
    ...  Check Parameters Status For Cells  ${RMOD_CELLS}  operationalState=${ENABLED}
    IF  ${rmod_status} == ${FALSE} or ${cells_status} == ${FALSE}
        Perform Site Reset
    END


TC Setup
    Common Test Setup  tc_name=FM__Robustness_trigger_different_faults_RMOD
    Setup NetAct


TC Teardown
    Run Keyword If Test Failed
    ...  FM__Robustness_trigger_different_faults_RMOD.Perform Recovery Action
    Teardown NetAct
    Common Test Teardown
