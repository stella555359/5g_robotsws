*** Settings ***
Documentation
    ...  This test was designed to test CNI-132903 BTS autonomous fallback to previous BTS SW or DnR is broken during BTS start-up failure when FPGA
    ...  re-configuration reset is triggered.
    ...  With this feature RLC value is taken from FPGA BlackBox when FPGA BlackBox identifies that HW WD Phase 3 was triggered.
    ...  This proves that previous RLC value is not lost and RLC is correctly incremented in next startup and BTS does not enter to reset loop
    ...  without fallback.


Resource  ../../common_resources/ca_FM_general.robot


*** Variables ***
${PING_TIMEOUT}  300  # [in seconds] Timeout for ping lost/regain.
${ALARM_TIMEOUT}  300  # [in seconds] Timeout for alarm to be reported in WebEM.
${NETACT_TIMEOUT}  120  # [in seconds] Timeout for alarm to be reported in Netact.
${RECOVERY_TIMEOUT}  900  # [in seconds] Timeout for SBTS to reach onAir state.


*** Keywords ***
FM__ASOF_SBTS_autonomous_fallback_to_previous_SW
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-29939
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  23.09.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29939 - Initial TAT creation
    ...  *******************

    Set Tags  CA-FM  OWNER-corneliu.marcu@nokia.com  AUTHOR-laura.craciunel@nokia.com
    ...  GROUP_IN_CHARGE-TIM_4_Vrf  PHASE-CRT  SW-SBTS26R1  CNI-132903

    Step 0: Testcase Preconditions
    Step 1: Trigger T3 Watchdog Recovery
    Step 2: Trigger T3 Watchdog Recovery
    Step 3: Trigger T3 Watchdog Recovery


Step 0: Testcase Preconditions
    Log  \nStep 0: Testcase preconditions.  console=true
    IF  '${ENB_BRANCH}' >= 'SBTS26R1'
        Log  Release SBTS26R1 or higher on active partition. Test will continue.  console=true
    ELSE
        Fail  Release SBTS26R1 or higher is not active on current.
    END
    Check NetBoot Variable
    ${active_partition_id}  ${passive_partition_id}  Get Active And Passive Partitions Ids
    Set Test Variable  ${ACTIVE_PARTITION_ID}  ${active_partition_id}


Step ${index}: Trigger T3 Watchdog Recovery
    Log  \nStep ${index}: Trigger T3 watchdog recovery.  console=true
    Trigger T3 Watchdog Recovery
    Wait For Target To Be Not Reachable  hostname=${OAM_BTS_IP}  timeout=${PING_TIMEOUT}
    Log  Ping has been lost.  console=true
    Wait For Target To Be Reachable  hostname=${OAM_BTS_IP}  timeout=${PING_TIMEOUT}
    Log  Ping has been regained.  console=true
    Sleep  10s  Wait until HWAPI is initialized.
    IF  ${index}==3
        Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10  Check Modules And Cells  check_cells=${FALSE}
        Log  Check cell status degraded.  console=true
        Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10  Check That All Cells Are Degraded
        Log  Cells are degraded.  console=true
        Check Fault Active After Fallback
    ELSE
        Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10  Check Modules And Cells
    END


Check That All Cells Are Degraded
    IF  ${SCF_COUNT_GSM}  coam.Assert Every  GNCEL  operationalState=${ENABLED}, availabilityStatus=${DEGRADED}  timeout=60
    IF  ${SCF_COUNT_WCDMA}  coam.Assert Every  WNCEL  operationalState=${ENABLED}, availabilityStatus=${DEGRADED}  timeout=60
    IF  ${SCF_COUNT_LTE}  coam.Assert Every  LNCEL  operationalState=${ENABLED}, availabilityStatus=${DEGRADED}  timeout=60
    IF  ${SCF_COUNT_NR}  coam.Assert Every  NRCEL  operationalState=${ENABLED}, availabilityStatus=${DEGRADED}  timeout=60


Check Fault Active After Fallback
    coam.Reset Admin
    ${fault_4082_params}  Get String With Alarm Parameters  ${FAULT_4082}
    Assert Alarm Active  parameters=${fault_4082_params}  timeout=${ALARM_TIMEOUT}
    Log  Fault ${FAULT_4082} is active in WebEM.  console=true
    Setup NetAct
    Wait Until Keyword Succeeds  ${NETACT_TIMEOUT}  30
    ...  Check Additional Information For Given Alarm And Fault  &{FAULT_4082}  additional_fault_id=${FAULT_4082}[fault_id]
    Log  Fault ${FAULT_4082} is active in Netact.  console=true

    [Teardown]  Teardown Netact


TC Setup
    Common Test Setup  tc_name=FM__ASOF_SBTS_autonomous_fallback_to_previous_SW


TC Teardown
    Recover SBTS If Passive SW Is Active
    Save Reset Data Output
    Common Test Teardown