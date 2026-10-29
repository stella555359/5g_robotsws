*** Settings ***
Documentation
    ...  This test is created to perform failure on ASIB and verify that the recovery mechanism works properly.
    ...  First, actFaultSignature parameter is set to true.
    ...  SMOD type is checked and must be ASIB.
    ...  Connection to master is opened and ps aux and kill commands are used to perform the failure.
    ...  After the failure is triggered, site recovery reset is performed and two types of alarms are reported in WebEm and NetAct.
    ...  After recovery, alarms are cleared and all services hosted by tested unit must be restored.

Resource  ../../common_resources/ca_FM_general.robot


*** Variables ***
${RECOVERY_TIMEOUT}  900  # [in seconds] Timeout for SBTS to recover after site reset
${FIRST_ALARM_TIMEOUT}  600  # [in seconds] Timeout for WebEm and NetAct alarms
${SECOND_ALARM_TIMEOUT}  720  # [in seconds] Timeout for WebEm and NetAct alarms (alarm may appear later than the first)
${SMOD_TYPE}  ASIL  # SMOD type


*** Keywords ***
FM__OAM_binary_recovery
    [Documentation]
    ...  [CASE LINK]: https://jira3.ext.net.nokia.com/browse/TAT-22427
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  22.12.2021 - https://jira3.int.net.nokia.com/browse/TAT-22427 - Initial TAT creation
    ...  03.03.2022 - https://jira3.ext.net.nokia.com/browse/TAT-22731 - Single core check fixed
    ...  08.03.2022 - https://jira3.ext.net.nokia.com/browse/TAT-22768 - Ignoring FID 4590 for SMOD type ASIL
    ...  28.10.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23931 - Move keywords to resource file
    ...  17.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24955 - FM files refactor to robotws standard
    ...  31.05.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25478 - Update FM testcases for actFaultSignature
    ...  15.11.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25658 - Create new resources for NetAct and ONAP KWs
    ...  05.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26813 - Refactor FM testcase for assert alarm active parameters
    ...  19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Use faults defined in py file
    ...  26.06.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27703 - Tests fail due multiple keywords with the same name
    ...  29.08.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28007 - Add keyword perform site reset
    ...  31.10.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28025 - Enhancement for verifying additonalFaultID in NetAct
    ...  25.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29190 - Enhancement of all test cases in regression to check fault signature
    ...  25.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29459 - Enhancement of all test cases in regression to check FS component field
    ...  ******************

    Set Tags  CA-FM  OWNER-lucian.ciurel@nokia.com  AUTHOR-anna.benzar@nokia.com  GROUP_IN_CHARGE-TIM_4_Vrf
    ...  PHASE-CRT  SW-SBTS22

    Step 0: Set Variables And Open Connection To Master
    Step 1: Kill OAM Binary Process


Step 0: Set Variables And Open Connection To Master
    Log  \nStep 0:Commissioning actFaultSignature to true and verifying SMOD type.  console=true
    Set ActFaultSignature Value  true
    ${status_active}  Query Infomodel  check /MRBTS-1/RAT-1/BTS_L-* is [storedRole=Active]  allow_negative_result=True
    IF  ${status_active}
      ${bts_l_obj}  Query Infomodel  get object /MRBTS-1/RAT-1/BTS_L-* is [storedRole=Active]
    ELSE
      ${bts_l_obj}  Query Infomodel  get object /MRBTS-1/RAT-1/BTS_L-* is [storedRole=Single]
    END
    ${bts_l_dn}  Set Variable  ${bts_l_obj}[dist_name]
    ${smod_obj}  Query Infomodel  get object ${bts_l_dn}/EQM_L-1/CABINET_L-1/SMOD_L-1
    ${status_smod}  Run Keyword And Return Status  Should Contain  ${smod_obj}[productName]  ${SMOD_TYPE}
    IF  ${status_smod}
      Open Connection To Master
    ELSE
      Fail  SMOD type on master is not ${SMOD_TYPE}.
    END
    Set Variables For Fault Signature Check
    ${start_time}  Get Current Date  time_zone=UTC  result_format=datetime
    Set Test Variable  ${START_TIME}


Step 1: Kill OAM Binary Process
    Log  \nStep 1: Performing kill command on ${SMOD_TYPE}.  console=true
    ${start_time}  Get Current Date  time_zone=UTC  result_format=datetime
    Perform Kill Command

    ${fault_4590_params}  Get String With Alarm Parameters  ${FAULT_4590}
    IF  '${SMOD_TYPE}' != 'ASIL'
      Assert Alarm Active  parameters=${fault_4590_params}  timeout=${FIRST_ALARM_TIMEOUT}
      Log  Fault 4590 "${FAULT_4590}[fault_name]" is reported in WebEm.  console=true
      Sleep  120
      Wait Until Keyword Succeeds  ${FIRST_ALARM_TIMEOUT}  10s
      ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_4590}  time_from=${start_time}
      ...  additional_fault_id=${FAULT_4590}[fault_id]
      Log  Fault 4590 "${FAULT_4590}[fault_name]" is reported & cleared from NetAct.  console=true
      Log  Check fault signature.  console=true
      Check Fault Signature Of Alarm In WebEM  fault_id=${FAULT_4590}[fault_id]  info=${INFO}  scope=${SCOPE}  minor=${MINOR}
      ...  category=${CATEGORY}  load_name=${SW_VERSION}  reset_counter=${COUNTER}  full_product_name=${PRODUCT_NAME}  serial_number=${SERIAL_NUMBER}
      ...  vendor_unit_number=${PRODUCT_CODE}  unit_position=${UNIT_POSITION}  core_unit_position=${CORE_UNIT_POSITION}
      Check Fault Signature Of Alarm In Netact  fault_id=${FAULT_4590}[fault_id]  time_from=${START_TIME}  info=INFO:${SPACE}${INFO}
      ...  scope=SCOPE:${SPACE}${SCOPE}  minor=MINOR:${SPACE}${MINOR}  category=CATEGORY:${SPACE}${CATEGORY}
      ...  load_name=LOAD_NAME:${SPACE}${SW_VERSION}  reset_counter=RESET_COUNTER:${SPACE}${COUNTER}  full_product_name=${PRODUCT_NAME}
      ...  serial_number=${SERIAL_NUMBER}  vendor_unit_number=${PRODUCT_CODE}  unit_position=${UNIT_POSITION}
      ...  core_unit_position=${CORE_UNIT_POSITION}
    END

    ${fault_4592_params}  Get String With Alarm Parameters  ${FAULT_4592}
    Assert Alarm Active  parameters=${fault_4592_params}  timeout=${SECOND_ALARM_TIMEOUT}
    Log  Fault 4592 "${FAULT_4592}[fault_name]" is reported in WebEm.  console=true
    Wait Until Keyword Succeeds  ${SECOND_ALARM_TIMEOUT}  10s
    ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_4592}  time_from=${start_time}
    ...  additional_fault_id=${FAULT_4592}[fault_id]
    Log  Fault 4592 "${FAULT_4592}[fault_name]" is reported & cleared from NetAct.  console=true

    ${status}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  20
    ...  Verify SBTS Is On Air
    IF  ${status}
      Log  Site reached on air state after fault triggering.  console=true
    ELSE
      Fail  Site didn't manage to reach on air state.
    END


Set Variables For Fault Signature Check
    ${smods_list}  coam.Get Fsm Info
    FOR  ${smod}  IN  @{smods_list}
      ${status_active_role}  Run Keyword And Return Status  Should Not Be Empty  ${smod}[activeRole]
      IF  ${status_active_role}==${FALSE}  BREAK
      IF  '${smod}[activeRole]' == 'Primary'  BREAK
    END
    Set Test Variable  ${PRODUCT_CODE}  ${smod}[productCode]
    Set Test Variable  ${PRODUCT_NAME}  ${smod}[productName]
    Set Test Variable  ${SERIAL_NUMBER}  ${smod}[serialNumber]
    Set Test Variable  ${INFO}  soam-dem
    Set Test Variable  ${MINOR}  .*(CPUA)?.*(NRT)?.*
    Set Test Variable  ${SCOPE}  Site
    Set Test Variable  ${CATEGORY}  SW_FAILURE
    Set Test Variable  ${COUNTER}  [0-9]+
    Set Unit Position For Fault Signature  ${smod}[id][internal]


Open Connection To Master
    Log  Opening connection to master  console=true
    SSHLibrary.Open Connection  ${SMOD1}[IP]  prompt=REGEXP:(#|>)
    SSHLibrary.Login  ${SMOD1}[USERNAME]  ${SMOD1}[PASSWORD]


Perform Kill Command
    SSHLibrary.Write  ps aux | grep DEM
    ${output_ps}  SSHLibrary.Read Until Prompt
    ${lines}  Get Lines Containing String  ${output_ps}  /opt/DEM/DEM
    ${split}  Split String  ${lines}
    ${pid}  Set Variable  ${split}[1]
    SSHLibrary.Write  kill -11 ${pid}
    SSHLibrary.Close All Connections


Verify SBTS Is On Air
    ${list_modules}  Create List  SMOD  BBMOD  RMOD
    FOR  ${module}  IN  @{list_modules}
        Assert Every  ${module}  operationalState=${ENABLED}
    END
    Check All Cells
    Admin Check Active Alarms TAF


TC Setup
    Common Test Setup  tc_name=FM__OAM_binary_recovery
    Setup NetAct


TC Teardown
    Run Keyword If Test Failed  Perform Site Reset
    Teardown NetAct
    Common Test Teardown
