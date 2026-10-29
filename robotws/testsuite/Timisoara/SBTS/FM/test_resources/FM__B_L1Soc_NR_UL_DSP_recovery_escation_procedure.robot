*** Settings ***
Documentation
    ...  This test is created to trigger DSP crash on Loki with NR
    ...  At first, parameters faultSnapshotTriggers, actL1FastAutoHealing and diagSnapDestination must be set
    ...  Core to crash is chosen by hardware variant, rat type and BBMOD type, which should be ABIO, ABIN or ABIP
    ...  Site reset is performed to clear all counters
    ...  SSH connection to DSP is opened via primary/secondary core
    ...  devmem commmand is used to trigger the crash
    ...  The crash must be triggered 4 times
    ...  Alarm with given fault is verified in RawAlarmHistory file and NUM_L1_AUTO_HEALING_BTS counter must be incremented
    ...  At the end, SBTS must be on air.

Resource  ../../common_resources/ca_FM_general.robot


*** Variables ***
${STARTUP_TIMEOUT}  600  # Timeout for SBTS to recover after site reset
${FAULT_NUMBER}  9100  # Fault that must be set in faultSnapshotTriggers
${TRIGGER_TYPE}  onFaultDetection  # Trigger type that must be set in faultSnapshotTriggers
${RAT_TYPE}  NR  # SOC's cells type
${UNIT_TYPE}  ${EMPTY}  # Mandatory. BBMOD type can be ABIO, ABIN, aSOE, ABIP
${CRASH_COMMAND}  devmem 0x87E044241600 64 1  # Command to trigger the crash
${CRASH_COMMAND_ABIP}  devmem 0x87E044201600 64 1  # Command for ABIP to trigger the crash


*** Keywords ***
TC__FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-23770
    ...
    ...  History of changes
    ...  ******************
    ...  27.09.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23770 - Initial TAT creation
    ...  29.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24134 - PMMNL object is missing under /MNL-1/MNLENT-1
    ...  17.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24955 - FM files refactor to robotws standard
    ...  24.04.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25226 - Change keyword arguments
    ...  25.05.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25235 - Updated execution of test on ABIP
    ...  07.11.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26246 - Adapt for SoC from ASOE and ASOF
    ...  19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Use faults defined in py file
    ...  03.06.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27497 - Modify keyword in resource file
    ...  16.04.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29060 - Test fails at recommissioning
    ...  19.05.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28979 - Alarm filtering and counter check updates
    ...  04.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29522 - Add different counter verification from 25R3 onwards
    ...  25.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29190 - Enhancement of all test cases in regression to check fault signature
    ...  25.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29459 - Enhancement of all test cases in regression to check FS component field
    ...  09.12.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30310 - Fix timezone
    ...  06.02.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30470 - Take date and time right after DSP crash
    ...  ******************

    Set Tags  CA-FM  OWNER-ioan.marta@nokia.com  AUTHOR-anna.benzar@nokia.com  GROUP_IN_CHARGE-TIM_4_Vrf  PHASE-CRT
    ...  SW-SBTS22  FEATURE-CB0008397

    Step0: Set Parameters
    Step1: Perform Site Reset
    Step2: Trigger DSP Crash
    Step3: Trigger DSP Crash
    Step4: Trigger DSP Crash
    Step5: Trigger DSP Crash Fourth Time


Step0: Set Parameters
    Log  \nStep0: Setting necessary parameters.  console=true

    ${parameter_value}  Set Variable If  '${ENB_BRANCH}' < 'SBTS25R3'  netact  nms
    Check Presence Of PMMNL Object
    IF  '${ENB_BRANCH}' >= 'SBTS25R3'
        Log  Changing parameter ActL1FastAutoHealing/diagSnapDestination value will not be performed, it is active by default.  console=true
        Verify And Change FaultSnapshotTriggers Values  2087  ${TRIGGER_TYPE}
    ELSE
        Verify And Change FaultSnapshotTriggers Values  ${FAULT_NUMBER}  ${TRIGGER_TYPE}
        Change Parameter ActL1FastAutoHealing/diagSnapDestination Value  true  actL1FastAutoHealing  FEATCADM-1  FEATCADM_A-1
    END
    Change Parameter ActL1FastAutoHealing/diagSnapDestination Value  ${parameter_value}  diagSnapDestination  TRBLCADM-1  TRBLCADM_A-1
    ${hw_variant}  Set Variable If  '${UNIT_TYPE}' == 'ABIP'  Thor  Loki
    ${soc_dn}  Get Random SOC Dist_name  ${hw_variant}  ${RAT_TYPE}  ${UNIT_TYPE}
    IF  '${hw_variant}' == 'Loki' and '${UNIT_TYPE}' != 'ASOE' and '${UNIT_TYPE}' != 'ASOF'
        ${unit_l_dn}  Fetch From Left  ${soc_dn}  /BBU_L
    ELSE
        ${unit_l_dn}  Fetch From Left  ${soc_dn}  /BOARD_L
    END
    IF  '${UNIT_TYPE}' == 'ASOF' or '${UNIT_TYPE}' == 'ASOE'
        ${unit_l_parameters}  Get Parameters For  SMOD  ${unit_l_dn}
    ELSE
        ${unit_l_parameters}  Get Parameters For  BBMOD  ${unit_l_dn}
    END
    ${unit_product_name}  Set Variable  ${unit_l_parameters}[productName]
    ${unit_r_dn}  Get Runtime Object Dist_name From Logical Object Dist_name  ${unit_l_dn}
    ${soc_vertical_position}  Get Module Vertical Position  ${unit_r_dn}
    ${soc_position}  IF  '${UNIT_TYPE}' == 'ABIP'  Set Variable  1  ELSE  Get SOC Position  ${soc_dn}  ${unit_product_name}
    ${stored_role}  Get StoredRole From MODULE_L  ${unit_l_dn}
    Set Test Variable  ${SOC_DN}  ${soc_dn}
    Set Test Variable  ${SOC_VERTICAL_POSITION}  ${soc_vertical_position}
    Set Test Variable  ${SOC_HORIZONTAL_POSITION}  ${soc_position}
    Set Test Variable  ${STORED_ROLE}  ${stored_role}
    Set Test Variable  ${SCOPE}  SoC
    Set Test Variable  ${EXTRA_INFO}  faulty_cells=.*NR:[0-9]+.*
    ${start_time}  Get Current Date  time_zone=UTC  result_format=datetime
    Set Test Variable  ${START_TIME}


Step1: Perform Site Reset
    Log  \nStep1: Performing site reset.  console=true

    Run Keyword And Ignore Error  coam.Snapshot Cancel
    Perform Site Reset
    Sleep Until New 15 Minutes Cycle


Step${index}: Trigger DSP Crash
    Log  \nStep${index}: Triggering DSP crash.  console=true

    ${current_date_time}  Get Current Date  time_zone=UTC  result_format=%Y-%b-%d %H:%M:%S
    Open SSH Connection And Trigger DSP Crash
    Verify Alarm In RawAlarmHistory File  9101  ${current_date_time}  ${None}  inactive
    ${minutes_to_sleep}  Sleep Until New 15 Minutes Cycle
    IF  '${ENB_BRANCH}' >= 'SBTS25R3'
        Collect Snapshot And Verify Counter Value By Date And Time Criteria  counter_name=DSP_L1_AUTO_HEALING_BTS
        ...                                                                  counter_value=1
        ...                                                                  snapshot_file_name=Snapshot_${index}
        ...                                                                  pattern=.*RD\.BTS.*\.xml\.gz
        ...                                                                  date=${DATE_SNAPSHOT}
        ...                                                                  time=${TIME_SNAPSHOT}
    ELSE
        Verify NUM_L1_AUTO_HEALING_BTS Counter To Be Incremented  1
    END
    Sleep Until Next Trigger  ${minutes_to_sleep}


Step5: Trigger DSP Crash Fourth Time
    Log  \nStep5: Triggering DSP crash fourth time.  console=true

    Open SSH Connection And Trigger DSP Crash
    ${fault_1900_params}  Get String With Alarm Parameters  ${FAULT_9100_SOC_AUTO_RST}
    ${fault_2087_params}  Get String With Alarm Parameters  ${FAULT_2087_SOC_AUTO_RST}
    IF  '${ENB_BRANCH}' >= 'SBTS25R3'
        Assert Alarm Active  parameters=${fault_2087_params}  timeout=300
        Log  Alarm with fault 2087 is reported in WebEM.  console=true
        Sleep Until New 15 Minutes Cycle
        Collect Snapshot And Verify Counter Value By Date And Time Criteria  counter_name=DSP_L1_AUTO_HEALING_BTS
        ...                                                                  counter_value=1
        ...                                                                  snapshot_file_name=Snapshot_5
        ...                                                                  pattern=.*RD\.BTS.*\.xml\.gz
        ...                                                                  date=${DATE_SNAPSHOT}
        ...                                                                  time=${TIME_SNAPSHOT}
        Check Fault Signature Of Alarm In WebEM  fault_id=${FAULT_2087_SOC_AUTO_RST}[fault_id]  scope=${SCOPE}  extra_info=${EXTRA_INFO}
        Check Fault Signature Of Alarm In Netact  fault_id=${FAULT_2087_SOC_AUTO_RST}[fault_id]
        ...                                       time_from=${START_TIME}
        ...                                       scope=SCOPE:${SPACE}${SCOPE}
        ...                                       extra_info=EXTRA_INFO:${SPACE}${EXTRA_INFO}
    ELSE
        Assert Alarm Active  parameters=${fault_1900_params}  timeout=300
        Log  Alarm with fault 9100 is reported in WebEM.  console=true
        Sleep Until New 15 Minutes Cycle
        Verify NUM_L1_AUTO_HEALING_BTS Counter To Be Incremented  1
    END
    Wait Until Keyword Succeeds  ${STARTUP_TIMEOUT}  10  Check All Cells


Open SSH Connection And Trigger DSP Crash
    Open Connection To Primary Core
    IF  '${STORED_ROLE}' == 'Idle'  Open Connection To Secondary Core
    Open Connection To SOC  ${SOC_VERTICAL_POSITION}  ${SOC_HORIZONTAL_POSITION}
    IF  '${UNIT_TYPE}' == 'ABIP'
        SSHLibrary.Write  ${CRASH_COMMAND_ABIP}
    ELSE
        SSHLibrary.Write  ${CRASH_COMMAND}
    END
    ${current_date_time_snapshot}  Get Current Date  time_zone=UTC  result_format=%Y%m%d %H%M%S
    ${date_snapshot}  Fetch From Left  ${current_date_time_snapshot}  ${SPACE}
    ${time_snapshot}  Fetch From Right  ${current_date_time_snapshot}  ${SPACE}
    Set Test Variable  ${DATE_SNAPSHOT}
    Set Test Variable  ${TIME_SNAPSHOT}
    SSHLibrary.Read Until Prompt
    Log  DSP crashed successfuly.  console=true

    [Teardown]  SSHLibrary.Close All Connections


Sleep Until Next Trigger
    [Arguments]  ${minutes_to_sleep}

    ${minutes_until_next_trigger}  IF  '${minutes_to_sleep}' < '00:10:00'  Subtract Time From Time  00:10:00
    ...                                                                                             ${minutes_to_sleep}
    ...                                                                                             timer
    ...                                                                                             exclude_millis=yes
    IF  '${minutes_until_next_trigger}' != 'None'
        Sleep  ${minutes_until_next_trigger}
        Log  ${minutes_until_next_trigger} more minutes to sleep until next trigger.  console=true
    ELSE
        Log  No need to sleep until next trigger.  console=true
    END


TC Setup
    Common Test Setup  tc_name=FM__B_L1Soc_NR_UL_DSP_recovery_escalation_procedure
    Setup Netact


TC Teardown
    IF  '${ENB_BRANCH}' >= 'SBTS25R3'
        Log  Changing parameter ActL1FastAutoHealing/diagSnapDestination value will not be performed, it is active by default.  console=true
    ELSE
        Change Parameter ActL1FastAutoHealing/diagSnapDestination Value  false  actL1FastAutoHealing  FEATCADM-1  FEATCADM_A-1
    END
    Teardown Netact
    Common Test Teardown