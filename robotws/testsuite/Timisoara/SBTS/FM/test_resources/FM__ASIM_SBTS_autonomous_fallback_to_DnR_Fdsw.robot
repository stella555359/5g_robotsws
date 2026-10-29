*** Settings ***
Documentation
    ...  This test was designed to test CNI-132903 BTS autonomous fallback to previous BTS SW or DnR is broken during BTS start-up failure when FPGA
    ...  re-configuration reset is triggered.
    ...  With this feature RLC value is taken from FPGA BlackBox when FPGA BlackBox identifies that HW WD Phase 3 was triggered.
    ...  This proves that previous RLC value is not lost and RLC is correctly incremented in next startup and BTS does not enter to reset loop
    ...  without fallback.


Library  taf.fdsw.rc  WITH NAME  fdsw
Resource  ../../common_resources/ca_FM_general.robot


*** Variables ***
${STEP_WAIT}  12  # [in seconds] Time in between crashes.
${PING_TIMEOUT}  300  # [in seconds] Timeout for ping lost/regain.
${ALARM_TIMEOUT}  600  # [in seconds] Timeout for alarm to be reported in WebEM.
${RECOVERY_TIMEOUT}  900  # [in seconds] Time for SBTS to reach onAir state.


*** Keywords ***
TC__FM__ASIM_SBTS_autonomous_fallback_to_DnR_Fdsw
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-29937
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  23.09.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29937 - Initial TAT creation
    ...  *******************

    Set Tags  CA-FM  OWNER-corneliu.marcu@nokia.com  AUTHOR-laura.craciunel@nokia.com
    ...  GROUP_IN_CHARGE-TIM_4_Vrf  PHASE-CRT  SW-SBTS26R1  CNI-132903

    Step 0: Testcase Preconditions
    Step 1: Trigger T3 Watchdog Recovery In Loop


Step 0: Testcase Preconditions
    Log  \nStep 0: Testcase preconditions.  console=true
    ${passive_branch}  Get Substring  ${PASSIVE_SW_VERSION}  0  8
    IF  '${ENB_BRANCH}' >= 'SBTS26R1' and '${passive_branch}' >= 'SBTS26R1'
        Log  Release SBTS26R1 or higher on active and passive. Test will continue.  console=true
    ELSE
        Fail  Release SBTS26R1 or higher is not active on current and passive.
    END
    Check NetBoot Variable
    ${active_partition_id}  ${passive_partition_id}  Get Active And Passive Partitions Ids
    Set Test Variable  ${ACTIVE_PARTITION_ID}  ${active_partition_id}


Step 1: Trigger T3 Watchdog Recovery In Loop
    Log  \nStep 1: Trigger T3 watchdog recovery in loop.  console=true
    FOR  ${loop}  IN RANGE  1  7
        Log  \nLoop ${loop}.  console=true
        Trigger T3 Watchdog Recovery
        Wait For Target To Be Not Reachable  hostname=${OAM_BTS_IP}  timeout=${PING_TIMEOUT}
        Log  Ping has been lost.  console=true
        Wait For Target To Be Reachable  hostname=${OAM_BTS_IP}  timeout=${PING_TIMEOUT}
        Log  Ping has been regained.  console=true
        Sleep  ${STEP_WAIT}s   Wait until HWAPI is initialized.
    END
    ${status_4082}  Run Keyword And Return Status  Wait Until Keyword Succeeds  ${ALARM_TIMEOUT}s  30s
    ...  Check Active Alarm In Fdsw  fault_id=${FAULT_4082_ALARM_7651}[fault_id]  fault_name=${FAULT_4082_ALARM_7651}[fault_name]
    ...  alarm_id=${FAULT_4082_ALARM_7651}[alarm_id]  severity=${FAULT_4082_ALARM_7651}[severity]
    IF  ${status_4082}
        Log  Fault id 4082 "SW fallback" active in FDSW.  console=true
    ELSE
        Fail  SBTS did not reach FDSW.
    END
    Return To The Software That Was Active Before FDSW


Check Active Alarm In Fdsw
    [Arguments]  ${fault_id}  ${fault_name}  ${alarm_id}  ${severity}

    fdsw.Connect To  ip_address=${OAM_BTS_IP}  port=443  username=Nemuadmin  password=nemuuser
    ${active_alarms}  fdsw.Get Alarms
    FOR  ${alarm}  IN  @{active_alarms}
        ${match_condition}  Catenate  '${alarm}[fault_id]'=='${fault_id}' and '${alarm}[name]'=='${fault_name}'
        ...  and '${alarm}[number]'=='${alarm_id}' and '${alarm}[severity]'=='${severity}'
        ${match}  Set Variable If  ${match_condition}  True  False
        IF  ${match}  BREAK
    END
    Should Be Equal As Strings  ${match}  True  Fault ${fault_id} "${fault_name}" not active in FDSW.

    [Teardown]  Run Keyword And Ignore Error  fdsw.Teardown


Return To The Software That Was Active Before FDSW
    Log  Return to the software that was active before FDSW.  console=true
    fdsw.Connect To  ip_address=${OAM_BTS_IP}  port=443  username=Nemuadmin  password=nemuuser
    fdsw.Software Rollback  ${ACTIVE_PARTITION_ID}
    Log  Software rollback from FDSW performed.  console=true
    Wait For Target To Be Reachable  hostname=${OAM_BTS_IP}  timeout=${PING_TIMEOUT}
    coam.Reset Admin
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}s  30s  Check modules and cells
    Log  Modules and cells enabled. SBTS onAir.  console=true

    [Teardown]  Run Keyword And Ignore Error  fdsw.Teardown


TC Setup
    Common Test Setup  tc_name=FM__ASIM_SBTS_autonomous_fallback_to_DnR_Fdsw


TC Teardown
    Recover SBTS If Passive SW Is Active
    Save Reset Data Output
    Common Test Teardown