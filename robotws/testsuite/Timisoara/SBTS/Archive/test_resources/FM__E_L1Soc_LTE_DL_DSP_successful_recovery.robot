*** Settings ***
Resource    ../../common_resources/ca_FM_general.robot

*** Variables ***
${STARTUP_TIMEOUT}   600                                            # Timeout for SBTS to recover after site reset
${FAULT_NUMBER}      9101                                           # Fault that must be set in faultSnapshotTriggers
${TRIGGER_TYPE}      onFaultDetection                               # Trigger type that must be set in faultSnapshotTriggers
${HW_VARIANT}        Loki                                           # SOC's hardware variant
${RAT_TYPE}          LTE                                            # SOC's cells type
${BBMOD_TYPE}        ABIO                                           # BBMOD type
${CRASH_COMMAND}     devmem 0x87E044041600 64 1                     # Command to trigger the crash

*** Keywords ***
FM__E_L1Soc_LTE_DL_DSP_successful_recovery
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-23787
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  This test is created to trigger DSP crash on Loki with LTE
    ...  At first, parameters faultSnapshotTriggers, actL1FastAutoHealing and diagSnapDestination must be set
    ...  Core to crash is chosen by hardware variant, rat type and BBMOD type, which should be ABIO or ABIN
    ...  Site reset is performed to clear all counters
    ...  SSH connection to DSP is opened via primary/secondary core
    ...  devmem commmand is used to trigger the crash
    ...  Alarm with given fault is verified in RawAlarmHistory file and NUM_L1_AUTO_HEALING_BTS counter must be incremented
    ...  At the end, SBTS must be on air.
    ...
    ...  History of changes
    ...  ******************
    ...  30.09.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23787 - Initial TAT creation
    ...  26.10.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24003 - Resolve duplicate keywords
    ...  29.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24134 - PMMNL object it is missing under /MNL-1/MNLENT-1
    ...  17.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24955 - FM files refactor to robotws standard
    ...  10.05.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25325 - Change keyword arguments
    ...  12.05.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25370 - Remove BTS_L_ID
    ...  03.06.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27497 - Modify keyword in resource file
    ...  ******************

    Set Tags        CA-FM  OWNER-catalin.botezatu@nokia.com  AUTHOR-anna.benzar@nokia.com
    ...             MAINTAINER-anna.benzar@nokia.com    GROUP_IN_CHARGE-TIM_4_Vrf    PHASE-CRT  SW-SBTS22  FEATURE-CB0008397

    Step0: Set parameters
    Step1: Perform Site Reset
    Step2: Trigger DSP crash
    Step3: Check services after L1 Soc auto-healing

Step0: Set parameters
    Log  \nStep0: Setting necessary parameters...  console=true
    ${bts_id}  Admin Get BTS ID
    Set test variable  ${BTS_ID}  ${bts_id}
    Check presence of PMMNL object
    Verify and change faultSnapshotTriggers values  ${FAULT_NUMBER}  ${TRIGGER_TYPE}
    Change parameter actL1FastAutoHealing/diagSnapDestination value  true    actL1FastAutoHealing    FEATCADM-1  FEATCADM_A-1
    Change parameter actL1FastAutoHealing/diagSnapDestination value  netact  diagSnapDestination     TRBLCADM-1  TRBLCADM_A-1
    ${soc_dn}  Get random SOC dist_name  ${HW_VARIANT}  ${RAT_TYPE}  ${BBMOD_TYPE}
    ${bbmod_l_dn}  Fetch from left  ${soc_dn}  /BBU_L
    ${bbmod_l_parameters}  Get parameters for  BBMOD  ${bbmod_l_dn}
    ${bbmod_product_name}  Set variable  ${bbmod_l_parameters}[productName]
    ${bbmod_r_dn}  Get runtime object dist_name from logical object dist_name  ${bbmod_l_dn}
    ${bbmod_position}  Get module vertical position  ${bbmod_r_dn}
    ${soc_position}   Get SOC position  ${soc_dn}  ${bbmod_product_name}
    ${stored_role}  Get storedRole from MODULE_L  ${bbmod_l_dn}
    Set test variable  ${SOC_DN}  ${soc_dn}
    Set test variable  ${BBMOD_POSITION}  ${bbmod_position}
    Set test variable  ${SOC_POSITION}    ${soc_position}
    Set test variable  ${STORED_ROLE}  ${stored_role}

Step1: Perform Site Reset
    Log  \nStep1: Performing Site Reset...  console=true
    coam.Reset site  ${STARTUP_TIMEOUT}
    ${status}  Run keyword and return status  Wait until keyword succeeds  ${STARTUP_TIMEOUT}  20  Check modules and cells
    Run keyword if  ${status}
    ...  Log  Site reached on air state after performing site reset  console=true
    ...  ELSE
    ...  Fail  Site didn't manage to reach on air state after site reset.

Step2: Trigger DSP crash
    Log  \nStep2: Triggering DSP crash...  console=true
    ${date_time}  Get current date
    ${current_date_time}  Convert date  ${date_time}  result_format=%Y-%b-%d %H:%M:%S
    Open SSH connection and trigger DSP crash
    Verify alarm in RawAlarmHistory file  ${FAULT_NUMBER}  ${current_date_time}  ${None}  inactive
    Sleep Until New 15 Minutes Cycle
    Verify NUM_L1_AUTO_HEALING_BTS counter to be incremented  1

Step3: Check services after L1 Soc auto-healing
    Log  \nStep3: Check services after L1 Soc auto-healing...  console=true
    ${status}  Run keyword and return status  Wait until keyword succeeds  ${STARTUP_TIMEOUT}  20  Check modules and cells
    Run keyword if  ${status}
    ...  Log  SBTS is on air  console=true
    ...  ELSE
    ...  Fail  Site didn't manage to reach on air state.

Open SSH connection and trigger DSP crash
    Open connection to primary core
    Run keyword if  '${STORED_ROLE}'=='Idle'  Open connection to secondary core
    Open connection to SOC  ${BBMOD_POSITION}  ${SOC_POSITION}
    Send command to trigger DSP crash

Send command to trigger DSP crash
    SSHLibrary.write  ${CRASH_COMMAND}
    SSHLibrary.read until prompt
    SSHLibrary.close connection
    Log   DSP crashed successfuly.  console=true

TC Setup
    Common Test Setup

TC Teardown
    Change parameter actL1FastAutoHealing/diagSnapDestination value  false    actL1FastAutoHealing    FEATCADM-1  FEATCADM_A-1
    Common Test Teardown
