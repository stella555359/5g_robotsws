*** Settings ***
Documentation
    ...  Test will get the SMOD or BBMOD with feature activated. To check the activation status test will query infomodel object OAMMA_A.
    ...  eCPRI RMOD port will be extracted also from infomodel and a connection to specific SOC will be made.
    ...  After connection to SOC is established command: ip netns exec radions tcpdump -i ${rfoeX_id}[0] -XX -c 5000 -e -nn | grep CFM
    ...  will be executed to check Loopback Message and Loopback Reply.
    ...  Process l1_application_rt will be killed and 2087 SoC Autonomous Reset as Recovery action should be visible.
    ...  Also 61009 Fronthaul loopback connectivity check failure may be raised, Loopback Message and Loopback Reply should be visible again.
    ...  After recovery action l1_application_nrt process will be killed and same steps will be checked again.
    ...  actForceUnitAutoReset parameter will be set to false.
    ...  Testcase will trigger 3 x crashes of L1 on secondary SoC resulting in fault 2087 SoC autonomous reset as recovery action.
    ...  Fourth L1 crash on secondary SoC will cause fault 2087 critical Critical SW Component failure.
    ...  supplAlarmInfo field will be checked in following cases:
    ...  - Secondary SoC_x autonomous reset for SoC reset.
    ...  - Secondary SoC_x reset loop detected for critical fault.

Resource  ../../common_resources/ca_FM_general.robot


*** Variables ***
${ALARM_TIMEOUT}  300  # [in seconds] Timeout for alarm to be reported
${ALARM_CLEARED_TIMEOUT}  900  # [in seconds] Timeout for alarm to be cleared


*** Keywords ***
TC__FM__L1_SoC_reset_CB005832_CB007442_interaction
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-26214
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  20.11.2017 - https://jiradc.ext.net.nokia.com/browse/TAT-26214 - Initial TAT creation
    ...  15.11.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25658 - Create new resources for NetAct and ONAP KWs
    ...  22.12.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26668 - Fix variable type
    ...  08.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26672 - Fix prompt check
    ...  19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Use faults defined in py file
    ...  03.06.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27497 - Modify keyword in resource file
    ...  17.07.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27606 - Multiple keywords for checking fault signature in FM testcases
    ...  10.09.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28073 - Add site reset in test precondition
    ...  31.10.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28025 - Enhancement for verifying additonalFaultID in NetAct
    ...  11.03.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28704 - Test fails because tmp_content is not received
    ...  25.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29190 - Enhancement of all test cases in regression to check fault signature
    ...  25.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29459 - Enhancement of all test cases in regression to check FS component field
    ...  30.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29603 - Enhancement: adding enough time for fid 2087 to be cleared in Netact
    ...  31.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29665 - Test fails at fault signature check
    ...  01.09.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29781 - Fix broken pipe
    ...  22.09.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29901 - Enhancement for CB010565-SR-A
    ...  *******************

    Set Tags  CA-FM  OWNER-lucian.ciurel@nokia.com  AUTHOR-bogdan.boldurean@nokia.com
    ...  GROUP_IN_CHARGE-TIM_4_Vrf  PHASE-CRT  FEATURE-CB005832  FEATURE-CB007442  FEATURE-CB010565

    Step 0: Test Precondition
    Step 1: Connect To SoC And Check L2Ping
    Step 2: Provoke L1_rt Fault
    Step 3: Check Fault
    Step 4: Check Recovery
    Step 5: Provoke L1_nrt Fault
    Step 6: Check Fault
    Step 7: Check Recovery
    Step 8: Provoke L1_rt Fault
    Step 9: Check Fault
    Step 10: Check Recovery
    Step 11: Provoke L1_nrt Fault
    Step 12: Check Critical Fault
    Step 13: Perform Site Reset To Recover Services


Step 0: Test Precondition
    Log  Step 0: Test precondition.  console=true
    Perform Site Reset
    ${unit}  ${port}  Get Unit To Test
    Set Test Variable  ${PRODUCT_NAME}  ${unit}[productName]
    Set Test Variable  ${SERIAL_NUMBER}  ${unit}[serialNumber]
    Set Test Variable  ${PRODUCT_CODE}  ${unit}[productCode]
    Set Unit Position For Fault Signature  ${unit}[dist_name]
    ${loki_id}  Get Loki For Given Port  ${unit}[productName]  ${port}
    Set Test Variable  ${LOKI_ID}
    ${soc_vertical_position}  Get Module Vertical Position  ${unit}[dist_name]
    Set Test Variable  ${SOC_VERTICAL_POSITION}
    Log  Chosen SOC is ${SOC_VERTICAL_POSITION}:${LOKI_ID}  console=true
    Set Unit Connection Parameters  ${unit}
    Set Test Variable  ${INFO}  failed process:.*l1_application_(n)?rt.*
    Set Test Variable  ${CATEGORY}  SW_FAILURE
    Set Test Variable  ${SCOPE_SOC}  SoC
    Set Test Variable  ${SCOPE_BOARD}  Board
    Set Test Variable  ${EXTRA_INFO}  faulty_cells=.*NR:[0-9]+.*
    Set Test Variable  ${RESET_COUNTER}  [0-9]+
    Setup Admin  ${SMOD1}[IP]  name=alarm
    Change FMCADM Parameter  actForceUnitAutoReset  false
    ${soc_string}  Set Variable If  '${LOKI_ID}' == '1'  SoC_B  SoC_C
    Set Test Variable  ${SOC_STRING}


Step 1: Connect To SoC And Check L2Ping
    Log  Step 1: Connect to SoC.  console=true
    Open Connection To Primary Core
    IF  '${SMOD_CONNECTION}' == 'Secondary'  Open Connection To Secondary Core
    Open Connection To SOC  ${SOC_VERTICAL_POSITION}  ${LOKI_ID}
    Check L2Ping


Step ${step_nr}: Provoke L1_rt Fault
    Log  Step ${step_nr}: Provoke l1_rt fault.  console=true
    SSHLibrary.Write  ps aux | grep l1_application_rt
    ${command_output}  SSHLibrary.Read Until Prompt  strip_prompt=True
    ${command_output}  Split To Lines  ${command_output}
    @{words}  Split String  ${command_output}[0]
    ${process_id}  Set Variable  ${words}[1]
    SSHLibrary.Write  kill -11 ${process_id}
    SSHLibrary.Read Until Prompt


Step ${step_nr}: Check Fault
    Log  Step ${step_nr}: Check Fault.  console=true
    ${time_alarm}  Get Current Date  time_zone=UTC  result_format=datetime
    ${fault_61009_params}  Get String With Alarm Parameters  ${FAULT_61009}
    ${additional_alarm_check}  Run Keyword In Background  Assert Alarm Active  parameters=${fault_61009_params}  connection=alarm
    ...  timeout=${ALARM_TIMEOUT}
    ${fault_2087_params}  Get String With Alarm Parameters  ${FAULT_2087_SOC_AUTO_RST}
    ${fault_2087_params}  Catenate  ${fault_2087_params},  supplAlarmInfo="Secondary ${SOC_STRING} autonomous reset"
    Assert Alarm Active  parameters=${fault_2087_params}  timeout=${ALARM_TIMEOUT}
    Log  Fault ${fault_2087_params} appeared in WebEM.  console=true
    Wait Until Keyword Succeeds  ${ALARM_CLEARED_TIMEOUT}  10s
    ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_2087_SOC_AUTO_RST}  time_from=${time_alarm}
    ...  additional_fault_id=${FAULT_2087_SOC_AUTO_RST}[fault_id]  suppl_info=Secondary ${SOC_STRING} autonomous reset
    Log  Fault ${fault_2087_params} appeared in Netact.  console=true
    ${status}  Run Keyword And Return Status
    ...  Collect Keyword Result  ${additional_alarm_check}  timeout=${ALARM_TIMEOUT}
    Set Test Variable  ${FAULT_61009_ACTIVE_STATUS}  ${status}
    IF  ${status}
      Log  Fault ${FAULT_61009} appeared.  console=true
    ELSE
      Log  Fault ${FAULT_61009} didn't appeared.  console=true
    END
    Log  Check fault signature in alarm.  console=true
    Check Fault Signature Of Alarm In WebEM  fault_id=${FAULT_2087_SOC_AUTO_RST}[fault_id]  category=${CATEGORY}  extra_info=${EXTRA_INFO}
    ...  info=${INFO}  load_name=${SW_VERSION}  reset_counter=${RESET_COUNTER}  scope=${SCOPE_SOC}  full_product_name=${PRODUCT_NAME}
    ...  serial_number=${SERIAL_NUMBER}  vendor_unit_number=${PRODUCT_CODE}  unit_position=${UNIT_POSITION}  core_unit_position=${CORE_UNIT_POSITION}
    Check Fault Signature Of Alarm In Netact  fault_id=${FAULT_2087_SOC_AUTO_RST}[fault_id]  time_from=${time_alarm}
    ...  category=CATEGORY:${SPACE}${CATEGORY}  extra_info=EXTRA_INFO:${SPACE}${EXTRA_INFO}  info=INFO:${SPACE}${INFO}
    ...  load_name=LOAD_NAME:${SPACE}${SW_VERSION}  reset_counter=RESET_COUNTER:${SPACE}${RESET_COUNTER}  scope=SCOPE:${SPACE}${SCOPE_SOC}
    ...  full_product_name=${PRODUCT_NAME}  serial_number=${SERIAL_NUMBER}  vendor_unit_number=${PRODUCT_CODE}  unit_position=${UNIT_POSITION}
    ...  core_unit_position=${CORE_UNIT_POSITION}


Step ${step_nr}: Check Recovery
    Log  Step ${step_nr}: Check recovery.  console=true
    Wait Until Keyword Succeeds  10m  1m
    ...  Check All Cells
    ${fault_61009_params}  Get String With Alarm Parameters  ${FAULT_61009}
    ${61009_inactive}  IF  ${FAULT_61009_ACTIVE_STATUS}  Run Keyword And Return Status  Assert Alarm Inactive  parameters=${fault_61009_params}
    IF  ${FAULT_61009_ACTIVE_STATUS} and ${61009_inactive}
      Log  Fault ${FAULT_61009} cleared.  console=true
    ELSE IF  ${FAULT_61009_ACTIVE_STATUS} and not ${61009_inactive}
      Fail  Fault ${FAULT_61009} not found in inactive alarms.
    ELSE
      Log  Fault ${FAULT_61009} was not checked to be cleared.  console=true
    END
    Log  Reconect to SoC afet reset.  console=true
    Run Keyword And Ignore Error  SSHLibrary.Read Until  >
    Open Connection To SOC  ${SOC_VERTICAL_POSITION}  ${LOKI_ID}
    Check L2Ping


Step ${step_nr}: Provoke L1_nrt Fault
    Log  Step ${step_nr}: Provoke l1_nrt fault.  console=true
    SSHLibrary.Write  ps aux | grep l1_application_nrt
    ${command_output}  SSHLibrary.Read Until Prompt  strip_prompt=True
    ${command_output}  Split To Lines  ${command_output}
    @{words}  Split String  ${command_output}[0]
    ${process_id}  Set Variable  ${words}[1]
    SSHLibrary.Write  kill -11 ${process_id}
    SSHLibrary.Read Until Prompt


Step 12: Check Critical Fault
    Log  Step 12: Check critical fault.  console=true
    ${time_alarm}  Get Current Date  time_zone=UTC  result_format=datetime
    ${fault_61009_params}  Get String With Alarm Parameters  ${FAULT_61009}
    ${additional_alarm_check}  Run Keyword In Background  Assert Alarm Active  parameters=${fault_61009_params}  connection=alarm
    ...  timeout=${ALARM_TIMEOUT}
    ${suppl_info_string}  Catenate  SEPARATOR=
    ...  FSP autonomous recovery reset is not allowed because it would disable any working cell or due to internal BTS limitation.
    ...  ${SPACE}FSP reset is needed;
    ...  Secondary ${SOC_STRING} reset loop detected
    ${fault_2087_params}  Get String With Alarm Parameters  ${FAULT_2087_SW_COMP_FAILURE}
    ${fault_2087_params}  Catenate  ${fault_2087_params},  supplAlarmInfo="${suppl_info_string}"
    Assert Alarm Active  parameters=${fault_2087_params}  timeout=${ALARM_TIMEOUT}
    Log  Fault ${fault_2087_params} appeared in WebEM.  console=true
    Wait Until Keyword Succeeds  300  10s
    ...  Check Additional Information For Given Alarm And Fault  &{FAULT_2087_SW_COMP_FAILURE}
    ...  additional_fault_id=${FAULT_2087_SW_COMP_FAILURE}[fault_id]  suppl_info=${suppl_info_string}
    Log  Fault ${fault_2087_params} appeared in Netact.  console=true
    ${status}  Run Keyword And Return Status
    ...  Collect Keyword Result  ${additional_alarm_check}  timeout=${ALARM_TIMEOUT}
    Set Test Variable  ${FAULT_61009_ACTIVE_STATUS}  ${status}
    IF  ${status}
      Log  Fault ${FAULT_61009} was seen.  console=true
    ELSE
      Log  Fault ${FAULT_61009} was not seen.  console=true
    END


Step 13: Perform Site Reset To Recover Services
    Log  Step 13: Perform site reset to recover services.  console=true
    Perform Site Reset


Check L2Ping
    Log  Check L2Ping.  console=true
    # This is here to clear output after SOC reset
    Run Keyword And Ignore Error
    ...  SSHLibrary.Read Until Prompt
    Set Client Configuration  timeout=5m  prompt=#
    SSHLibrary.Write  cd /tmp
    SSHLibrary.Read Until Prompt
    SSHLibrary.Write  ls -l
    ${tmp_content}  SSHLibrary.Read Until Prompt
    ${rfoe_x_id}  Get Regexp Matches  ${tmp_content}  rfoe\\d
    SSHLibrary.Write  ip netns exec radions tcpdump -i ${rfoe_x_id}[0] -XX -c 5000 -e -nn | grep CFM
    ${command_output}  SSHLibrary.Read Until Prompt
    Should Contain  ${command_output}  Loopback Message  Loopback Message was not found in command output.
    Log  Loopback Message was seen in command output.  console=true
    Should Contain  ${command_output}  Loopback Reply  Loopback Reply was not found in command output.
    Log  Loopback Reply was seen in command output.  console=true


Get Unit To Test
    ${ethapp_object}  Query Infomodel  get object //OAMMA_A-1
    ${eth_if_dn_object}  Query Infomodel  get object ${ethapp_object}[ethIfDN]
    ${link_selector_dn_object}  Query Infomodel  get object ${eth_if_dn_object}[linkSelectorDN]
    ${port}  Get Regexp Matches  ${link_selector_dn_object}[connectorLabel]  \\d+
    ${unit_object}  Query Infomodel  get object ${link_selector_dn_object}[modDN]
    ${unit_a}  Set Variable  ${unit_object}[dist_name]
    ${verdict}  ${result}  Run Keyword And Ignore Error
    ...  Query Infomodel  get object //BBMOD_R-* is [configDN=${unit_a}]
    IF  '${verdict}'=='PASS'  RETURN  ${result}  ${port}[0]
    ${verdict}  ${result}  Run Keyword And Ignore Error
    ...  Query Infomodel  get object //SMOD_R-* is [configDN=${unit_a}]
    IF  '${verdict}'=='PASS'  RETURN  ${result}  ${port}[0]


Get Loki For Given Port
    [Arguments]  ${unit_type}  ${port}

    IF  'ABIO' in '${unit_type}' and ${port}<=6
      RETURN  1
    ELSE IF  'ABIO' in '${unit_type}' and ${port}>=7
      RETURN  2
    ELSE IF  'ASOE' in '${unit_type}' and ${port}<=6
      RETURN  1
    ELSE IF  'ASOE' in '${unit_type}' and ${port}>=7
      RETURN  2
    ELSE IF  'ASOF' in '${unit_type}' and ${port}<=3
      RETURN  1
    ELSE IF  'ASOF' in '${unit_type}' and ${port}>=4
      RETURN  2
    ELSE
      RETURN  1
    END


Set Unit Connection Parameters
    [Arguments]  ${unit}

    IF  ('ASOE' or 'ASOF') in '${unit}[productName]'
      Set Test Variable  ${SMOD_CONNECTION}  Primary
      RETURN
    END
    ${bbmod_horizontal_position}  IF  'Capacity' in '${unit}[productName]'  Get Module Horizontal Position  ${unit}[dist_name]
    ${smods}  Get Fsm Info
    FOR  ${smod}  IN  @{smods}
        ${smod_param}  coam.Get Parameters  ${smod}[id][internal]
        Exit For Loop If  '${smod_param}[horizontalPosition]' == '${bbmod_horizontal_position}'
    END
    Set Test Variable  ${SMOD_CONNECTION}  ${smod_param}[activeRole]


TC Setup
    Common Test Setup  tc_name=FM__L1_SoC_reset_CB005832_CB007442_interaction
    Setup NetAct


TC Teardown
    Teardown NetAct
    Run Keyword If Test Failed  Perform Site Reset
    Change FMCADM Parameter  actForceUnitAutoReset  true
    Common Test Teardown
