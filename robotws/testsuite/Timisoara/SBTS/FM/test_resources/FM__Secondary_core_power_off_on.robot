*** Settings ***
Documentation
    ...  This test is created to check that Fault Signature is correctly returned after secondary core power off/on.
    ...  Starting form 23R1 for all non-FSMF products, if actFaultSignature == 'true' the BTS shall send alarm
    ...  for fault 4590 EFaultId_CrashOrFailureSignatureAl enriched with fault signature after encountering an
    ...  unexpected reset due to power off and on of a system module.
    ...  Frozen in 22R4 for all products except FSMF, if actFaultSignature == 'true' the BTS shall send alarm
    ...  for fault 4589 EFaultID_UnitPowerResetAl enriched with fault signature when it detects that one of its units
    ...  (secondary system module or Radio Module) performed power reset.

Resource  ../../common_resources/ca_FM_general.robot


*** Variables ***
${ALARM_TIMEOUT}  600  # [in seconds] Timeout for alarm to appear in WebEM.
${NETACT_TIMEOUT}  120  # [in seconds] Timeout for alarm to appear in Netact.
${RECOVERY_TIMEOUT}  900  # [in seconds] Timeout for SBTS to recover after power off on.


*** Keywords ***
TC__FM__Secondary_core_power_off_on
    [Documentation]
    ...  [CASE LINk]: https://jira3.int.net.nokia.com/browse/TAT-19616
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  25.05.2020 - https://jira3.int.net.nokia.com/browse/TAT-19616 - Initial creation
    ...  24.11.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22065 - Adapt FM TCs for CNI-61110
    ...  28.10.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23842 - Remove Test Specific Teardown and Setup
    ...  17.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24955 - FM files refactor to robotws standard
    ...  21.04.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25200 - Component did not mached
    ...  31.05.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25478 - Update FM testcases for actFaultSignature
    ...  16.08.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25998 - Update test after requirements change
    ...  15.11.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25658 - Create new resources for NetAct and ONAP KWs
    ...  19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Use faults defined in py file
    ...  21.03.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27160 - Keyword enhancement in resource file
    ...  29.04.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27368 - Change test steps
    ...  17.07.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27606 - Multiple keywords for checking fault signature in FM testcases
    ...  13.08.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27938 - Resolve fault signature checks
    ...  31.10.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28025 - Enhancement for verifying additonalFaultID in NetAct
    ...  28.01.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-27427 - Fix category and info check
    ...  25.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29190 - Enhancement of all test cases in regression to check fault signature
    ...  25.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29459 - Enhancement of all test cases in regression to check FS component field
    ...  02.09.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29771 - Add fault 5489 in watchdog
    ...  19.09.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29766 - Added core variables for fault signature
    ...  ******************

    Set Tags  CA-FM  OWNER-laura.craciunel@nokia.com  AUTHOR-bogdan.boldurean@nokia.com
    ...  GROUP_IN_CHARGE-TIM_4_Vrf  PHASE-CRT  SW-SBTS20  FEATURE-RP001825

    Step0: Check All Required States
    Step1: Reset Site And Wait For BBPOOLs
    Step2: Power Off Secondary Core
    Step3: Power On Secondary Core
    Step4: Check Fault Signature


Step0: Check All Required States
    [Documentation]  In this step specific states will be checked.

    Log  \nStep0: Check all required states.  console=true
    ${date}  Get Current Date  time_zone=UTC  result_format=datetime
    Set Test Variable  ${START_TIME}  ${date}
    ${smods_list}  Get Fsm Info
    FOR  ${smod}  IN  @{smods_list}
         IF  '${smod}[activeRole]' == 'Secondary'  BREAK
         IF  '${smod}[activeRole]' == 'Primary'  CONTINUE
    END
    Set Test Variable  ${SECONDARY_SMOD}  ${smod}
    Set Test Variable  ${SERIAL_NUMBER}  ${smod}[serialNumber]
    Check Configuration And Release
    Set Variables For Fault Signature
    Set ActFaultSignature Value  true


Step1: Reset Site And Wait For BBPOOLs
    [Documentation]  In this step site reset will be performed and test will wait until BBPOOLs creation in runtime afterwards.

    Log  \nStep1: Reset site and wait for BBPOOLs.  console=true
    coam.Reset Site
    Log  Site reset finnished. Wait up to 10 min for BBPOOLs creation.  console=true
    Query Infomodel  check //BBPOOL_R-*  timeout=600
    Log  BBPOOL detected.  console=true


Step2: Power Off Secondary Core
    [Documentation]  Turn off Secondary core.

    Log  \nStep2: Power off secondary core.  console=true
    Set Test Variable  ${SMOD_IF}  SMOD_${SERIAL_NUMBER}
    Pdu BTS Interface Off  ${SMOD_IF}
    ${ping_loss_status}  Run Keyword And Return Status
    ...  Wait For Target To Be Not Reachable  hostname=192.168.255.119  timeout=300  remote_host=${PC_IP2}
    IF  ${ping_loss_status}==${FALSE}
        Set Test Restriction  Ping to secondary is not lost after power off.
    ELSE
        Log  Ping to secondary core is lost.  console=true
    END
    Sleep And Log Waiting Time  4  Wait 4 minutes and power on secondary core.


Step3: Power On Secondary Core
    [Documentation]  Turn on Primary Core while ping on secondary core is back.

    Log  \nStep3: Power on secondary core.  console=true
    Pdu BTS Interface On  ${SMOD_IF}
    ${fid_4352_params}  Get String With Alarm Parameters  ${FAULT_4352_CORES_NOT_CONN}
    Assert Alarm Active  parameters=${fid_4352_params}  timeout=${ALARM_TIMEOUT}
    Log  Fault 4352 "${FAULT_4352_CORES_NOT_CONN}[fault_name]" is visible in WebEM  console=true

    Log  Check states after power on secondary core.  console=true
    ${rmods}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}s  10s
    ...  Assert Every  RMOD  operationalState=${ENABLED}  timeout=60
    IF  ${rmods}
        Log  All rmods are operationalState=enabled availabilityStatus=online - recovery succedeed. [OK]  console=true
    ELSE
        Fail  Some rmods statuses are wrong - recovery filed. [NOK]
    END
    ${cells}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}s  10s
    ...  Check All Cells
    IF  ${cells}
        Log  All cells are Enabled Online. [OK]  console=true
    ELSE
        Fail  Some cells are NOT Enabled - recovery filed. [NOK]
    END

    ${fault}  Set Variable If  '${CHECK_FAULT}'=='True'  ${FAULT_4589_BTS_RST}  ${FAULT_4590}
    ${alarm_parameters}  Get String With Alarm Parameters  ${fault}
    Assert Alarm Inactive  parameters=${alarm_parameters}  timeout=${ALARM_TIMEOUT}
    Wait Until Keyword Succeeds  ${NETACT_TIMEOUT}  10
    ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{fault}  time_from=${START_TIME}
    ...  additional_fault_id=${fault}[fault_id]
    Log  Fault ${fault} was reported and cleared in Netact. [OK]  console=true


Step4: Check Fault Signature
    [Documentation]  In this step fault signature is check for the correct values.

    Log  \nStep4: Check fault signature from fault ${EXPECTED_FAULT_ID}.  console=true
    Check Fault Signature Of Alarm In WebEM  fault_id=${EXPECTED_FAULT_ID}  category=${CATEGORY}  info=${INFO}  load_name=${SW_VERSION}
    ...  reset_counter=${RESET_COUNTER}  scope=${SCOPE}  full_product_name=${PRODUCT_NAME}  serial_number=${SERIAL_NUMBER}
    ...  core_serial_number=${CORE_SERIAL_NUMBER}  unit_position=${UNIT_POSITION}  core_unit_position=${CORE_UNIT_POSITION}
    Check Fault Signature Of Alarm In Netact  fault_id=${EXPECTED_FAULT_ID}  time_from=${START_TIME}  category=CATEGORY:${SPACE}${CATEGORY}
    ...  info=INFO:${SPACE}${INFO}  load_name=LOAD_NAME:${SPACE}${SW_VERSION}  reset_counter=RESET_COUNTER:${SPACE}${RESET_COUNTER}
    ...  scope=SCOPE:${SPACE}${SCOPE}  full_product_name=${PRODUCT_NAME}  serial_number=${SERIAL_NUMBER}  core_serial_number=${CORE_SERIAL_NUMBER}
    ...  unit_position=${UNIT_POSITION}  core_unit_position=${CORE_UNIT_POSITION}
    Check Fault Signature If Fault 4589 Was Raised At Power Off/On For Radio Module


Set Variables For Fault Signature
    ${module_r_dn}  Get Module Dist Name By Serial Number And Class  ${SERIAL_NUMBER}  SMOD
    Set Test Variable  ${PRODUCT_NAME}  ${SECONDARY_SMOD}[productName]
    ${smod_parameters}  coam.Get Parameters  ${module_r_dn}
    Set Test Variable  ${CORE_SERIAL_NUMBER}  ${smod_parameters}[coreHwBoardSerialNumber]
    Set Unit Position For Fault Signature  ${module_r_dn}
    ${expected_fault_id}  Set Variable If  '${CHECK_FAULT}'=='True'  ${FAULT_4589_BTS_RST}[fault_id]  ${FAULT_4590}[fault_id]
    ${expected_scope}  Set Variable If  '${CHECK_FAULT}'=='True'  Site  ESM
    Set Test Variable  ${MINOR}  UNKNOWN
    Set Test Variable  ${INFO}  (Autonomous reset triggered by unknown|Unknown power reset.*)
    Set Test Variable  ${SCOPE}  ESM
    Set Test Variable  ${CATEGORY}  (UNKNOWN|POWER_OFF)
    Set Test Variable  ${RESET_COUNTER}  [0-9]+
    Set Test Variable  ${EXPECTED_FAULT_ID}


Check Configuration And Release
    ${smod_objects}  coam.Get Parameters For All  class_name=SMOD
    ${check_master}  Run Keyword And Return Status
    ...  Should Contain  ${smod_objects}[0][productName]  FSMF
    ${check_slave}  Run Keyword And Return Status
    ...  Should Contain  ${smod_objects}[1][productName]  FSMF
    ${check_fsmf}  Set Variable If  '${check_master}'=='True' and '${check_slave}'=='True'  True  False
    ${check_fault}  Set Variable If  '${check_fsmf}'=='True' or '${ENB_BRANCH}' < 'SBTS23R1'  True  False
    Set Test Variable  ${CHECK_FAULT}  ${check_fault}


TC Setup
    Common Test Setup  tc_name=FM__Secondary_core_power_off_on
    Setup NetAct


TC Teardown
    Run Keyword And Ignore Error
    ...  Pdu BTS Interface On  ${SMOD_IF}
    Teardown NetAct
    Common Test Teardown
