*** Settings ***
Documentation
    ...  This test is created to verify that, after software rollback, if enforcedRecovTimeWindow is active,
    ...  power resets on BBMOD are allowed when triggering FID 1904
    ...  The test should be performed on:
    ...  BBMOD: ABIA,ABIN and ABIO where OBSAI RMOD are connected: FRGY,FXDB, ...Fxxx.
    ...  First, RMOD details are set and software rollback is performed.
    ...  Parameters actForceAutoReset and enforcedRecovTimeWindow are set to required values.
    ...  Software rollback is performed for the second time.
    ...  When triggering FID 1904 first 3 times, autonomous recovery reset should be performed successfully.
    ...  Next two times, FSP warm reset should be performed successfully.
    ...  6th time, FSP power reset should be performed successfully.
    ...  After triggering fault 6th time, site reset is performed to clear all counters.
    ...  Fault is triggered 4 more times, autonomous recovery reset should be performed in the first 3 cases,
    ...  and FSP warm reset in the last case.

Resource  ../../common_resources/ca_FM_general.robot


*** Variables ***
${STARTUP_TIMEOUT}  15m  # [in minutes] Timeout for waiting until cells are onAir after site reset.
${RESTORE_TIMEOUT}  30m  # [in minutes] Timeout for waiting until cells are onAir after rollback.
${STEPS_TIMEOUT}  8m  # [in minutes] Timeout for waiting in between sending fault on RMOD.
${PING_LOSS_TIMEOUT}  10m  # [in minutes] Timeout for ping loss during reset
${PING_REGAIN_TIMEOUT}  10m  # [in minutes] Timeout for ping regain during reset
${ALARM_TIMEOUT}  180  # [in seconds] Timeout for alarms to appear or disappear.
@{BBMOD_LIST}  ABIA  ABIN  ABIO  # BBMOD type for test
@{ACCEPTED_CELLS_LIST}  NR  LTE  # cells type deployed on tested module
${RMOD_TYPE}  OBSAI  # RMOD type connected to BBMOD


*** Keywords ***
TC__FM__RMOD_reset_to_FSP_power_reset_counter_cleared_manual_site_reset_FID1904
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-26141
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  20.09.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26141 - Initial TAT creation
    ...  15.11.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25658 - Create new resources for NetAct and ONAP KWs
    ...  23.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26728 - Change rollback, recovery action and parameters
    ...  05.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26813 - Refactor FM testcase for assert alarm active parameters
    ...  19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Use faults defined in py file
    ...  26.06.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27703 - Tests fail due multiple keywords with the same name
    ...  31.10.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28025 - Enhancement for verifying additonalFaultID in NetAct
    ...  30.04.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29010 - Wrong runtime object checked after rollback
    ...  22.05.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29213 - Replace RMOD info search from /rom/config/FRIps.txt
    ...  24.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29523 - Add delay between sending faults
    ...  02.09.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29740 - Test fails due the fact that 4th FID 1904 sent into startup not in runtime
    ...  13.02.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30234 - Test should not fail if fault 1868 cleared in 2minutes after a BBMOD reset
    ...  ******************

    Set Tags  CA-FM  OWNER-mircea.vladulescu@nokia.com  AUTHOR-anna.benzar@nokia.com  GROUP_IN_CHARGE-TIM_4_Vrf
    ...  PHASE-CRT  SW-SBTS24  FEATURE-CB010884-A

    Step 0: Testcase Preconditions
    Step 1: Set ActForceAutoReset To Be False
    Step 2: Check And Set EnforcedRecovTimeWindow Value
    Step 3: Perform SW Rollback And Verify Netact Integration
    Step 4: Trigger FID 1904 On Obsai RMOD 3 Times
    Step 5: Trigger FID 1904 On Obsai Radio For The 4th Time
    Step 6: Trigger FID 1904 On Obsai Radio For The 5th Time
    Step 7: Trigger FID 1904 On Obsai Radio For The 6th Time
    Step 8: Trigger FID 1904 On Obsai Radio For The 7th, 8th and 9th Times
    Step 9: Trigger FID 1904 On Obsai Radio For The 10th Time


Step 0: Testcase Preconditions
    Log  \nStep 0: Testcase preconditions.  console=true
    IF  '${RMOD_TYPE}' == 'OBSAI'
        ${rmod_sn}  ${affected_bbmods_list}  Get Random RMOD Details By Given RMOD Type, BBMODs List And Accepted Cells List
        ...  ^F[A-Z]{3,4}  ${BBMOD_LIST}  ${ACCEPTED_CELLS_LIST}
    ELSE
        ${rmod_sn}  ${affected_bbmods_list}  Get Random RMOD Details By Given RMOD Type, BBMODs List And Accepted Cells List
        ...  ${RMOD_TYPE}  ${BBMOD_LIST}  ${ACCEPTED_CELLS_LIST}
    END
    ${rmod_dn}  Get Module Dist Name By Serial Number And Class  ${rmod_sn}  RMOD
    ${rmod_cells}  Get Cell Mapping By Module Id  ${rmod_dn}
    ${bbmods_cells}  Create List
    FOR  ${bbmod}  IN  @{affected_bbmods_list}
        ${cells}  Get Cell Mapping By Module Id  ${bbmod}
        Append To List  ${bbmods_cells}  @{cells}
    END
    ${bbmods_sn}  Create List
    FOR  ${bbmod}  IN  @{affected_bbmods_list}
        ${bbmod_parameters}  coam.Get Parameters  ${bbmod}
        Append To List  ${bbmods_sn}  ${bbmod_parameters}[serialNumber]
    END
    Set Test Variable  ${RMOD_SN}
    Set Test Variable  ${RMOD_CELLS}
    Set Test Variable  ${BBMODS_SN}
    Set Test Variable  ${BBMODS_CELLS}
    Log  Chosen rmod serial number is: ${RMOD_SN}.  console=true
    Log  Affected BBMODs have serial numbers: ${BBMODS_SN}.  console=true
    ${status_baseband}  Check If Test Runs Only On Baseband ABIA With LTE Cells
    Set Test Variable  ${STATUS_BASEBAND}


Step 1: Set ActForceAutoReset To Be False
    Log  \nStep 1: Set actForceAutoReset to be false.  console=true
    Change Parameter ActForce(Unit)AutoReset  false  actForceAutoReset


Step 2: Check And Set EnforcedRecovTimeWindow Value
    Log  \nStep 2: Check and set enforcedRecovTimeWindow value.  console=true
    Change Parameter EnforcedRecovTimeWindow  ${BTS_ID}  Enforced recovery enabled within 0 - 150 minutes


Step 3: Perform SW Rollback And Verify Netact Integration
    Log  \nStep 3: Perform SW rollback and verify netact integration.  console=true
    Log  First software rollback.  console=true
    Perform Software Rollback And Check BTS State  ${RESTORE_TIMEOUT}  ${PING_LOSS_TIMEOUT}  ${PING_REGAIN_TIMEOUT}
    Check Active And Pasive Software Versions To Be Set Correctly  ${PASSIVE_SW_VERSION}  ${ACTIVE_SW_VERSION}
    Log  Second software rollback.  console=true
    Perform Software Rollback And Check BTS State  ${RESTORE_TIMEOUT}  ${PING_LOSS_TIMEOUT}  ${PING_REGAIN_TIMEOUT}
    Check Active And Pasive Software Versions To Be Set Correctly  ${ACTIVE_SW_VERSION}  ${PASSIVE_SW_VERSION}

    Log  Verify if netact integration was lost during rollback.  console=true
    ${netact_info}  coam.Get Nms State
    ${netact_status}  Run Keyword And Return Status  Should Not Be Empty  ${netact_info}[0][managerInfo]
    IF  ${netact_status}
        Log  Integration to netact not lost. Reintegration not needed. Test will continue. [OK]  console=true
    ELSE
        Integrate SBTS To NetAct
    END


Step 4: Trigger FID 1904 On Obsai RMOD 3 Times
    Log  \nStep 4: Trigger FID 1904 on Obsai RMOD 3 times.  console=true
    Repeat Keyword  3 times  Trigger FID 1904 And Check Radio Autonomous Reset


Step ${index}: Trigger FID 1904 On Obsai Radio For The 4th Time
    Log  \nStep ${index}: Trigger FID 1904 on Obsai Radio for the 4th time.  console=true
    ${start_time_netact}  Get Current Date  time_zone=UTC  result_format=datetime
    ${start_time_webem}  Get BTS time in UTC format  %Y-%m-%d %H:%M:%S.%6N
    Trigger FID 1904
    ${fault_bb_auto_reset}  Get String With Alarm Parameters  ${FAULT_1904_BB_AUTO_RST}
    Set Test Variable  ${FAULT_BB_AUTO_RESET}
    Assert Alarm Active  parameters=${FAULT_BB_AUTO_RESET}  timeout=${ALARM_TIMEOUT}
    Log  Fault 1904 "${FAULT_1904_BB_AUTO_RST}[fault_name]" is active in WebEM. [OK]  console=true
    Wait Until Keyword Succeeds  ${ALARM_TIMEOUT}  10s
    ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_1904_BB_AUTO_RST}
    ...  time_from=${start_time_netact}  additional_fault_id=${FAULT_1904_BB_AUTO_RST}[fault_id]
    Log  Fault 1904 "${FAULT_1904_BB_AUTO_RST}[fault_name]" appeared & cleared from NetAct. [OK]  console=true
    Check Modules And Cells When Baseband Reset Is Performed - FID 1904  ${index}
    Check If Fault 1868 Was Raised Throughout Baseband Recovery  bbmod_reset_fault=${FAULT_1904_BB_AUTO_RST}  start_time_webem=${start_time_webem}
    ...  start_time_netact=${start_time_netact}


Step ${index}: Trigger FID 1904 On Obsai Radio For The 5th Time
    Log  \nStep ${index}: Trigger FID 1904 on Obsai Radio for the 5th time.  console=true
    ${start_time_netact}  Get Current Date  time_zone=UTC  result_format=datetime
    ${start_time_webem}  Get BTS time in UTC format  %Y-%m-%d %H:%M:%S.%6N
    Trigger FID 1904
    Assert Alarm Active  parameters=${FAULT_BB_AUTO_RESET}  timeout=${ALARM_TIMEOUT}
    Log  Fault 1904 "${FAULT_1904_BB_AUTO_RST}[fault_name]" is active in WebEM. [OK]  console=true
    Wait Until Keyword Succeeds  ${ALARM_TIMEOUT}  10s
    ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_1904_BB_AUTO_RST}
    ...  time_from=${start_time_netact}  additional_fault_id=${FAULT_1904_BB_AUTO_RST}[fault_id]
    Log  Fault 1904 "${FAULT_1904_BB_AUTO_RST}[fault_name]" appeared & cleared from NetAct. [OK]  console=true
    Check Modules And Cells When Baseband Reset Is Performed - FID 1904  ${index}
    Check If Fault 1868 Was Raised Throughout Baseband Recovery  bbmod_reset_fault=${FAULT_1904_BB_AUTO_RST}  start_time_webem=${start_time_webem}
    ...  start_time_netact=${start_time_netact}


Step ${index}: Trigger FID 1904 On Obsai Radio For The 6th Time
    Log  \nStep ${index}: Trigger FID 1904 on Obsai Radio for the 6th time.  console=true
    ${start_time_netact}  Get Current Date  time_zone=UTC  result_format=datetime
    Trigger FID 1904
    ${fault_bb_power_reset}  Get String With Alarm Parameters  ${FAULT_1904_BB_POWER_AUTO_RST}
    Assert Alarm Active  parameters=${fault_bb_power_reset}  timeout=${ALARM_TIMEOUT}
    Log  Fault 1904 "${FAULT_1904_BB_POWER_AUTO_RST}[fault_name]" is active in WebEM. [OK]  console=true
    Wait Until Keyword Succeeds  ${ALARM_TIMEOUT}  10s
    ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_1904_BB_POWER_AUTO_RST}
    ...  time_from=${start_time_netact}  additional_fault_id=${FAULT_1904_BB_POWER_AUTO_RST}[fault_id]
    Log  Fault 1904 "${FAULT_1904_BB_POWER_AUTO_RST}[fault_name]" appeared & cleared from NetAct. [OK]  console=true
    Check Modules And Cells When Baseband Reset Is Performed - FID 1904  ${index}
    Perform Site Reset
    coam.Reset Admin
    Sleep  5 minutes  This sleep is for SBTS to recover after reset admin.
    Change Parameter ActForce(Unit)AutoReset  true  actForceAutoReset
    Change Parameter ActForce(Unit)AutoReset  true  actForceUnitAutoReset


Step 8: Trigger FID 1904 On Obsai Radio For The 7th, 8th and 9th Times
    Log  \nStep 8: Trigger FID 1904 On Obsai Radio For The 7th, 8th and 9th Times.  console=true
    Repeat Keyword  3 times  Trigger FID 1904 And Check Radio Autonomous Reset


Step ${index}: Trigger FID 1904 On Obsai Radio For The 10th Time
    Log  \nStep ${index}: Trigger FID 1904 On Obsai Radio For The 10th Time.  console=true
    ${start_time_netact}  Get Current Date  time_zone=UTC  result_format=datetime
    ${start_time_webem}  Get BTS time in UTC format  %Y-%m-%d %H:%M:%S.%6N
    Trigger FID 1904
    Assert Alarm Active  parameters=${FAULT_BB_AUTO_RESET}  timeout=${ALARM_TIMEOUT}
    Log  Fault 1904 "${FAULT_1904_BB_AUTO_RST}[fault_name]" is active in WebEM. [OK]  console=true
    Wait Until Keyword Succeeds  ${ALARM_TIMEOUT}  10s
    ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_1904_BB_AUTO_RST}
    ...  time_from=${start_time_netact}  additional_fault_id=${FAULT_1904_BB_AUTO_RST}[fault_id]
    Log  Fault 1904 "${FAULT_1904_BB_AUTO_RST}[fault_name]" appeared & cleared from NetAct. [OK]  console=true
    Check Modules And Cells When Baseband Reset Is Performed - FID 1904  ${index}
    Check If Fault 1868 Was Raised Throughout Baseband Recovery  bbmod_reset_fault=${FAULT_1904_BB_AUTO_RST}  start_time_webem=${start_time_webem}
    ...  start_time_netact=${start_time_netact}


Trigger FID 1904
    ${smod_side}  ${rmod_ip}  ${stored_role}  Find RMOD Ip By Serial Number  ${RMOD_SN}
    Connect To RMOD Through Lxc-attach And Telnet Using Rmod Ip, Side And Port  ${rmod_ip}  ${smod_side}  2323  ${stored_role}
    SSHLibrary.Write  sendFault 1103 0 0 0 0 0 0
    SSHLibrary.Read Until Prompt
    Log  Fault sent.  console=true

    [Teardown]  SSHLibrary.Close All Connections


Trigger FID 1904 And Check Radio Autonomous Reset
    ${time_before_fault_sending}  Get Current Date  time_zone=UTC  result_format=datetime
    Trigger FID 1904
    Wait Until Keyword Succeeds  300s  10s  Check Cells On RMOD To Be Degraded Or Disabled  ${RMOD_CELLS}
    ${fault_radio_reset}  Get String With Alarm Parameters  ${FAULT_1904_RADIO_AUTO_RST}
    Assert Alarm Active  parameters=${fault_radio_reset}  timeout=${ALARM_TIMEOUT}
    Log  Fault 1904 "${FAULT_1904_RADIO_AUTO_RST}[fault_name]" is active in WebEM. [OK]  console=true
    Wait Until Keyword Succeeds  ${ALARM_TIMEOUT}  10s
    ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_1904_RADIO_AUTO_RST}
    ...  time_from=${time_before_fault_sending}  additional_fault_id=${FAULT_1904_RADIO_AUTO_RST}[fault_id]
    Log  Fault 1904 "${FAULT_1904_RADIO_AUTO_RST}[fault_name]" appeared & cleared from NetAct. [OK]  console=true
    Log  Wait for 6 minutes to send next trigger.  console=true
    Sleep  6 minutes  Wait to send next trigger.
    Wait Until Keyword Succeeds  300s  10s  Check Parameters Status For RMOD  ${RMOD_SN}  parameters=operationalState=${ENABLED}
    Wait Until Keyword Succeeds  300s  10s  Check Parameters Status For Cells  ${RMOD_CELLS}  operationalState=${ENABLED}
    Log  Autonomous recovery reset was performed successfully and all services are onAir. [OK]  console=true


Check Modules And Cells When Baseband Reset Is Performed - FID 1904
    [Arguments]  ${step}
    Wait Until Keyword Succeeds  300s  10s  Check Parameters Status For List Of BBMODs  ${BBMODS_SN}  operationalState=${DISABLED}
    Wait Until Keyword Succeeds  300s  10s  Check Parameters Status For Cells  ${BBMODS_CELLS}  operationalState=${DISABLED}
    Log  Affected BBMODs and cells mapped on them are in expected state: Disabled. [OK]  console=true
    IF  ${step} != 7 or ${step} != 9
        Log  Wait for ${STEPS_TIMEOUT} to send next trigger.  console=true
        Sleep  ${STEPS_TIMEOUT}  Wait to send next trigger.
    END
    Wait Until Keyword Succeeds  300s  10s  Check Parameters Status For List Of BBMODs  ${BBMODS_SN}  operationalState=${ENABLED}
    Wait Until Keyword Succeeds  300s  10s  Check Parameters Status For RMOD  ${RMOD_SN}  parameters=operationalState=${ENABLED}
    Wait Until Keyword Succeeds  300s  10s  Check Parameters Status For Cells  ${BBMODS_CELLS}  operationalState=${ENABLED}
    Log  BBMODs, RMOD and cells are up after recovery reset. [OK]  console=true


Perform Recovery Action
    ${rmod_status}  Run Keyword And Return Status  Check Parameters Status For RMOD  ${RMOD_SN}  parameters=operationalState=${ENABLED}
    ${cells_status}  Run Keyword And Return Status  Check Parameters Status For Cells  ${RMOD_CELLS}  operationalState=${ENABLED}
    IF  ${rmod_status} == ${FALSE} and ${cells_status} == ${FALSE}  Perform Site Reset
    ${software_status}  Run Keyword And Return Status
    ...  Check Active And Pasive Software Versions To Be Set Correctly  ${ACTIVE_SW_VERSION}  ${PASSIVE_SW_VERSION}
    IF  ${software_status}
        Log  Active software version is set correctly at the end of the test.  console=true
    ELSE
        Perform Software Rollback And Check BTS State  ${RESTORE_TIMEOUT}  ${PING_LOSS_TIMEOUT}  ${PING_REGAIN_TIMEOUT}
        Check Active And Pasive Software Versions To Be Set Correctly  ${ACTIVE_SW_VERSION}  ${PASSIVE_SW_VERSION}
    END


TC Setup
    Common Test Setup  tc_name=FM__RMOD_reset_counter_cleared_FID1904
    Setup NetAct


TC Teardown
    Run Keyword If Test Failed  FM__RMOD_reset_to_FSP_power_reset_counter_cleared_manual_site_reset_FID1904.Perform Recovery Action
    Change Parameter ActForce(Unit)AutoReset  false  actForceAutoReset
    Change Parameter ActForce(Unit)AutoReset  false  actForceUnitAutoReset
    Change Parameter EnforcedRecovTimeWindow  ${BTS_ID}  Enforced recovery enabled within 0 - 90 minutes
    Teardown NetAct
    Common Test Teardown