*** Settings ***
Documentation
    ...  This test case is created to trigger SC reset as recovery action multiple times
    ...  to verify the counter increment and reset after manual site reset.
    ...  It will be done by triggerring fault 2080 using Fault Generator method. Recovery action will be checked against faultID 2080 with
    ...  alarmId=7101 and faultName = "BTS secondary core autonomous reset as recovery action".

Resource  ../../common_resources/ca_FM_general.robot


*** Variables ***
${RECOVERY_TIMEOUT}  1200  # Recovery timeout after triggering Fault 2080
${ALARM_TIMEOUT}  300  # [in seconds] Timeout for alarm to appear in WebEM
${NETACT_TIMEOUT}  120  # [in seconds] Timeout for alarm to appear in Netact


*** Keywords ***
TC__FM__SC_reset_counter_cleared_manual_site_reset
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-14619
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  24.02.2020 - https://jira3.int.net.nokia.com/browse/TAT-14619 - Initial TAT creation
    ...  28.07.2021 - https://jira3.int.net.nokia.com/browse/TAT-21653 - TC updated according with test description
    ...  24.11.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22065 - Adapt FM TCs for CNI-61110
    ...  17.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24955 - FM files refactor to robotws standard
    ...  05.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26813 - Refactor FM testcase for assert alarm active parameters
    ...  12.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26904 - Test must have actForceAutoReset on true
    ...  26.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27001 - Test fails with message BTS_L-4 not found
    ...  19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Use faults defined in py file
    ...  26.03.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27122 - Query fails with matching object not found
    ...  29.08.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28007 - Add keyword perform site reset
    ...  01.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29190 - Enhancement of all test cases in regression to check fault signature
    ...  05.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29459 - Enhancement of all test cases in regression to check FS component field
    ...  05.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29097 - Enhancement replace the FaultGenerator for FID 2080 by cmd line command
    ...  19.09.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29766 - Added core variables for fault signature
    ...  23.09.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29934 - Ignore fault in case of eCpri radios
    ...  ******************

    Set Tags  CA-FM  OWNER-laura.craciunel@nokia.com  AUTHOR-bogdan.boldurean@nokia.com
    ...  GROUP_IN_CHARGE-TIM_4_Vrf  PHASE-CRT  SW-SBTS20  FEATURE-RP001534

    Step0: Check All Required States
    Step1: Perform Site Reset To Clear Counters
    Step2: Trigger Fault 2080 And Verify SBTS After Recovery
    Step3: Trigger Fault 2080 And Verify SBTS After Recovery
    Step5: Perform Site Reset To Clear Counters
    Step6: Trigger Fault 2080 And Verify SBTS After Recovery


Step0: Check All Required States
    Log  \nStep0: Check all required states.  console=true
    Change FMCADM Parameter  actForceAutoReset  true
    Set Variables For Fault Signature Check
    ${ecpri_links}  Get Cablinks Available By Provided Protocol  ecpri
    IF  ${ecpri_links}
        Log  Test line has eCpri radios, fault "Unit synchronization failed" will be added to allow alarms in watchdog.  console=true
        watchdog.Allow Alarm  fault_id=16  fault_name=Unit synchronization failed
    END

Step${index}: Trigger Fault 2080 And Verify SBTS After Recovery
    [Documentation]  This step triggers fault 2080 on the secondary core.

    Log  \nStep${index}: Trigger fault 2080 and verify SBTS after recovery.  console=true
    ${start_time}  Get Current Date  time_zone=UTC  result_format=datetime

    Open Connection To Primary Core
    Open Connection To Secondary Core
    SSHLibrary.Write  rio hpdalm send hld
    SSHLibrary.Read Until Prompt
    ${fault_2080_params}  Get String With Alarm Parameters  ${FAULT_2080_2_ND_CORE_AUTO_RST}
    Assert Alarm Active  parameters=${fault_2080_params}  timeout=${ALARM_TIMEOUT}
    Log  Fault ${FAULT_2080_2_ND_CORE_AUTO_RST} is active in WebEM.  console=true

    ${secondary_dn}  Query Infomodel  get object /MRBTS-1/RAT-1/BTS_L-* is [storedRole=Idle]
    ${cells_on_secondary}  Infomodel Get Cells Deployed On Module  ${secondary_dn}
    Check Secondary Core Status
    FOR  ${im_cell}  IN  @{cells_on_secondary}
        Infomodel Cell Should Be Failed  ${im_cell}
    END

    Log  Verify SBTS after recovery.  console=true
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10  Query Infomodel  check /MRBTS-1/RAT-1/BTS_L-* is [storedRole=Idle]
    ${smod_object}  Query Infomodel  get object //SMOD_L-1 is [serialNumber=${SMOD}[serialNumber]]
    ${reset_counter_after_recovery}  Set Variable  ${smod_object.coreRestartCounter}
    Log  Reset counter value after recovery: ${reset_counter_after_recovery}  console=true
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10  Check All Cells
    Check Links Status  Available
    Admin Check Active Alarms Taf
    Checking The Value Of Reset Counter

    Wait Until Keyword Succeeds  ${NETACT_TIMEOUT}  30
    ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_2080_2_ND_CORE_AUTO_RST}  time_from=${start_time}
    ...  additional_fault_id=${FAULT_2080_2_ND_CORE_AUTO_RST}[fault_id]
    Log  Fault ${FAULT_2080_2_ND_CORE_AUTO_RST} reported and cleared in Netact.  console=true

    Log  Checking fault signature.  console=true
    Check Fault Signature Of Alarm In WebEM
    ...  fault_id=${FAULT_2080_2_ND_CORE_AUTO_RST}[fault_id]
    ...  info=${INFO}
    ...  scope=${SCOPE}
    ...  minor=${MINOR}
    ...  category=${CATEGORY}
    ...  load_name=${SW_VERSION}
    ...  reset_counter=${COUNTER}
    ...  full_product_name=${PRODUCT_NAME}
    ...  serial_number=${SERIAL_NUMBER}
    ...  core_serial_number=${CORE_SERIAL_NUMBER}
    ...  vendor_unit_number=${PRODUCT_CODE}
    ...  core_vendor_unit_number=${CORE_PRODUCT_CODE}
    ...  unit_position=${UNIT_POSITION}
    ...  core_unit_position=${CORE_UNIT_POSITION}
    Check Fault Signature Of Alarm In Netact
    ...  fault_id=${FAULT_2080_2_ND_CORE_AUTO_RST}[fault_id]
    ...  time_from=${start_time}
    ...  info=INFO:${SPACE}${INFO}
    ...  scope=SCOPE:${SPACE}${SCOPE}
    ...  minor=MINOR:${SPACE}${MINOR}
    ...  category=CATEGORY:${SPACE}${CATEGORY}
    ...  load_name=LOAD_NAME:${SPACE}${SW_VERSION}
    ...  reset_counter=RESET_COUNTER:${SPACE}${COUNTER}
    ...  full_product_name=${PRODUCT_NAME}
    ...  serial_number=${SERIAL_NUMBER}
    ...  core_serial_number=${CORE_SERIAL_NUMBER}
    ...  vendor_unit_number=${PRODUCT_CODE}
    ...  core_vendor_unit_number=${CORE_PRODUCT_CODE}
    ...  unit_position=${UNIT_POSITION}
    ...  core_unit_position=${CORE_UNIT_POSITION}


Step${index}: Perform Site Reset To Clear Counters
    Log  \nStep${index}: Site reset will be performed to clear all counters.  console=true
    Perform Site Reset
    Checking The Value Of Reset Counter


Check Secondary Core Status
    [Documentation]  This KW was created to check secondary SMOD status after it was hot removed.

    ${smod_state}  Run Keyword And Return Status  Assert Any  SMOD  operationalState=${DISABLED},availabilityStatus=${NOT_INSTALLED}
    IF  '${smod_state}'=='${FALSE}'
        Set Test Restriction  Secondary core status is different than expected operationalState=disabled and/or availabilityStatus=not installed.[NOK]
    ELSE
        Log  Secondary core reached expected states operationalState=disabled and availabilityStatus=not installed. [OK]  console=true
    END


Checking The Value Of Reset Counter
    ${smod_object}  Query Infomodel  get object //SMOD_L-1 is [serialNumber=${SMOD}[serialNumber]]
    Set Test Variable  ${RESET_COUNTER}  ${smod_object.coreRestartCounter}
    Log  Current value of reset counter: ${RESET_COUNTER}.  console=true


Set Variables For Fault Signature Check
    ${smods_list}  coam.Get Fsm Info
    FOR  ${smod}  IN  @{smods_list}
        IF  '${smod}[activeRole]' == 'Secondary'  BREAK
        IF  '${smod}[activeRole]' == 'Primary'  CONTINUE
    END
    Set Test Variable  ${SMOD}  ${smod}
    Set Test Variable  ${PRODUCT_CODE}  ${SMOD}[productCode]
    Set Test Variable  ${PRODUCT_NAME}  ${SMOD}[productName]
    Set Test Variable  ${SERIAL_NUMBER}  ${SMOD}[serialNumber]
    Set Test Variable  ${INFO}  .*RapidIO host link down.*
    Set Test Variable  ${MINOR}  FCT SRIO
    Set Test Variable  ${SCOPE}  ESM
    Set Test Variable  ${CATEGORY}  SW_FAILURE
    Set Test Variable  ${COUNTER}  [0-9]+
    ${extra_info}  Catenate  SEPARATOR=${SPACE}
    ...  faulty_cells=(.*GSM:[0-9]+.*,)?(.*WCDMA:[0-9]+.*,)?(.*LTE:[0-9]+.*,)?(.*NR:[0-9]+.*,)?[0-9]+;
    ...  gracefully_shutdown_cells=(.*GSM:[0-9]+.*,)?(.*WCDMA:[0-9]+.*,)?(.*LTE:[0-9]+.*,)?(.*NR:[0-9]+.*,)?[0-9]+
    Set Test Variable  ${EXTRA_INFO}  ${extra_info}
    Set Unit Position For Fault Signature  ${SMOD}[id][internal]
    ${smod_parameters}  coam.Get Parameters  ${SMOD}[id][internal]
    Set Test Variable  ${CORE_SERIAL_NUMBER}  ${smod_parameters}[coreHwBoardSerialNumber]
    Set Test Variable  ${CORE_PRODUCT_CODE}  ${smod_parameters}[coreHwBoardProductCode]


TC Setup
    Common Test Setup  tc_name=FM__SC_reset_counter_cleared_manual_site_reset
    Setup NetAct


TC Teardown
    Change FMCADM Parameter  actForceAutoReset  false
    Teardown NetAct
    Common Test Teardown
