*** Settings ***
Documentation
    ...  This test case was created to imitate 5G RAT recovery reset scenario.
    ...  Virtual node will be found from querying SW_NODE_L related to NR RAT and crash will be performed with kill -9 command.
    ...  Appropriate fields from SW_NODE_L containter in IMS will be checked during crash. Fault 4383 and alarm 7101, recovery request apperance
    ...  and affected cells by recovery will be checked in seperate threads. Also resoningStatus from SW_NODE_L will be checked.

Library  ute_async
Resource  ../../common_resources/ca_FM_general.robot


*** Variables ***
${RECOVERY_TIMEOUT}  360  # [in seconds] Timeout for SBTS to recover after crash scenario
${STARTUP_TIMEOUT}  660  # [in seconds] Timeout for SBTS to recover after startup
${NETACT_TIMEOUT}  180  # [in seconds] Timeout for alarm to be reported in Netact


*** Keywords ***
TC__FM__5G_RAT_reset_executed_as_autonomous_recovery_action
    [Documentation]
    ...  [CASE LINK]: https://jira3.ext.net.nokia.com/browse/TAT-20271
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  30.09.2020 - https://jira3.ext.net.nokia.com/browse/TAT-20271 - Initial TAT creation
    ...  24.11.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22065 - Adapt FM TCs for CNI-61110
    ...  01.09.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23615 - actForce(Unit)AutoReset value changed
    ...  14.12.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23841 - Searching for 5G on both core sides
    ...  14.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24111 - Migrate from hran_ssh to taf.transport.ssh
    ...  17.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24955 - FM files refactor to robotws standard
    ...  29.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26797 - Update query
    ...  06.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26825 - Add support for ASIK
    ...  21.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26964 - Support for CB008880 check actRatResetEnhancement=FALSE
    ...  01.03.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27018 - Skip parameter change for older sw releases
    ...  19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Use faults defined in py file
    ...  31.07.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27864 - Update keyword
    ...  29.08.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28007 - Add keyword perform site reset
    ...  15.11.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27608 - Add check for fault signature
    ...  21.11.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28423 - Test fail because "faulty cells" are calculated after physicalId not lcrId
    ...  25.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29190 - Enhancement of all test cases in regression to check fault signature
    ...  25.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29459 - Enhancement of all test cases in regression to check FS component field
    ...  *******************

    Set Tags  CA-FM  OWNER-laura.craciunel@nokia.com  AUTHOR-laura.craciunel@nokia.com
    ...  GROUP_IN_CHARGE-TIM_4_Vrf  PHASE-CRT  SW-SBTS21  FEATURE-RP002956  FEATURE-CB008880

    Step 0: Check All Required States
    Step 1: Perform Site Reset
    Step 2: Trigger SW Node Crash
    Step 3: Check Recovery Action
    Step 4: Check Fault Signature


Step 0: Check All Required States
    [Documentation]  In this step specific states will be checked.

    Log  \nStep 0: Check all required states.  console=true
    IF  '${ENB_BRANCH}'>='SBTS24R2' or '${ENB_BRANCH}'=='SBTS00'  Change FEATCADM Parameter  actRatResetEnhancement  false
    Change FMCADM Parameter  actForceAutoReset  true
    Check Which Core Is Primary
    ${date}  Get Current Date  time_zone=UTC  result_format=datetime
    Set Test Variable  ${START_TIME}  ${date}


Step 1: Perform Site Reset
    [Documentation]  In this step site reset will be performed to clear recovery reset counters.

    Log  \nStep 1: Site reset will be performed to clear recovery reset counters.  console=true
    Perform Site Reset


Step 2: Trigger SW Node Crash
    [Documentation]  In this step SW Node crash will be performed to trigger 5G RAT reset recovery.

    Log  \nStep 2: Trigger SW node crash.  console=true
    ${status}  Run Keyword And Return Status
    ...  Query Infomodel  check /MRBTS-1/RAT-1/BTS_L-4//SW_NODE_L-* is [rat="NR", applicationGroup="CentralCPlane"]  timeout=60
    IF  ${status}
      ${sw_node_ccplane}  ${sw_node_lom}  Get SW Node  4
    ELSE
      ${sw_node_ccplane}  ${sw_node_lom}  Get SW Node  1
    END
    ${smods}  Get FSM Info
    FOR  ${smod}  IN  @{smods}
        ${is_asik}  Set Variable If  'ASIK' in '${smod}[productName]' and ${status}  ${TRUE}  ${FALSE}
        IF  ${is_asik}  BREAK
    END
    IF  ${is_asik}
      ${sw_node_list}  Get Node For ASIK  ${sw_node_lom}
    ELSE
       ${sw_node_list}  Combine Lists  ${sw_node_ccplane}  ${sw_node_lom}
    END
    ${random_element}  Evaluate  random.choice(${sw_node_list})  modules=random
    Set Test Variable  ${ELEMENT}  ${random_element}
    ${node_id}  Convert To Hex  ${ELEMENT}[nodeId]  prefix=0x
    ${low_node_id}  Convert To Lowercase  ${node_id}
    Log  random index from list is : ${random_element}.  console=true
    Log  dist.name of chosen SW_NODE_L is : ${ELEMENT}[dist_name].  console=true
    Log  virtual node type and variant is : ${ELEMENT}[applicationGroup] and ${ELEMENT}[variant].  console=true
    Set Test Variables For Fault Signature
    Setup Admin  bts_host=192.168.255.129  bts_port=443  use_ssl=True  alias=fault
    Crash SW_NODE_L  ${ELEMENT}  ${low_node_id}


Step 3: Check Recovery Action
    [Documentation]  In this step 5G RAT reset recovery will be checked.

    Log  \nStep 3: Check recovery action.  console=true

    ${alarm_parameters}  Get String With Alarm Parameters  ${FAULT_4383_RAT_AUTO_RST}
    ${fault_status}  Run Keyword In Background  Assert Alarm Active  parameters=${alarm_parameters}  timeout=660  alias=fault
    ${reset_recovery}  Start Async  ute_admin_infomodel  Query Infomodel  get list //RECOVERY_RESET_IND-*  timeout=660  alias=recovery

    ${vnu_status}  Run Keyword And Return Status
    ...  Query Infomodel  get list ${ELEMENT}[dist_name] is [stateInfo.reasoningStatus[0]="NodeStoppedUnexpectedly"]  timeout=300
    IF  ${vnu_status}
      Log  Reasoning status is NodeStoppedUnexpectedly. [OK]  console=true
    ELSE
      Set Test Restriction  Reasoning status is different than expected. [NOK]
    END

    ${status_fault}  Run Keyword And Return Status  Collect Keyword Result  ${fault_status}  timeout=660
    IF  ${status_fault}
      Log  Fault ${FAULT_4383_RAT_AUTO_RST} visible in WebEM. [OK]  console=true
    ELSE
      Fail  Fault ${FAULT_4383_RAT_AUTO_RST} visible in WebEM. [NOK]
    END

    ${status_reset_recovery}  ${async_result}  Run Keyword And Ignore Error  Wait For Async Result  alias=recovery
    IF  '${status_reset_recovery}'=='FAIL'
      Set Test Restriction  Recovery reset indication is not visible under FRI. [NOK]
    ELSE
      Log  RAT reset indication is visible uder FRI. [OK]  console=true
    END
    Stop Async  alias=recovery
    Run Keyword And Continue On Failure
    ...  Teardown Admin  alias=fault

    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT} sec  60 sec  Check All Cells
    Assert Alarm Inactive  parameters=${alarm_parameters}
    Log  Alarm ${FAULT_4383_RAT_AUTO_RST} is not visible after recovery action. [OK]  console=true
    Admin Check Active Alarms TAF

    Wait Until Keyword Succeeds  ${NETACT_TIMEOUT}  30
    ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_4383_RAT_AUTO_RST}  time_from=${START_TIME}
    ...  additional_fault_id=${FAULT_4383_RAT_AUTO_RST}[fault_id]
    Log  Fault ${FAULT_4383_RAT_AUTO_RST} reported and cleared in Netact.  console=true


Step 4: Check Fault Signature
    Log  \nStep 4: Check Fault Signature.  console=true
    Check Fault Signature Of Alarm In WebEM  fault_id=${EXPECTED_FAULT_ID}  category=${CATEGORY}  extra_info=${EXTRA_INFO}  info=${INFO}
    ...  load_name=${SW_VERSION}  minor=${MINOR}  reset_counter=${RESET_COUNTER}  scope=${SCOPE}  full_product_name=${PRODUCT_NAME}
    ...  serial_number=${SERIAL_NUMBER}  vendor_unit_number=${PRODUCT_CODE}  unit_position=${UNIT_POSITION}  core_unit_position=${CORE_UNIT_POSITION}
    Check Fault Signature Of Alarm In Netact  fault_id=${EXPECTED_FAULT_ID}  time_from=${START_TIME}  category=CATEGORY:${SPACE}${CATEGORY}
    ...  extra_info=EXTRA_INFO:${SPACE}${EXTRA_INFO}  info=INFO:${SPACE}${INFO}  load_name=LOAD_NAME:${SPACE}${SW_VERSION}
    ...  minor=MINOR:${SPACE}${MINOR}  reset_counter=RESET_COUNTER:${SPACE}${RESET_COUNTER}  scope=SCOPE:${SPACE}${SCOPE}
    ...  full_product_name=${PRODUCT_NAME}  serial_number=${SERIAL_NUMBER}  vendor_unit_number=${PRODUCT_CODE}  unit_position=${UNIT_POSITION}
    ...  core_unit_position=${CORE_UNIT_POSITION}


Crash SW_NODE_L
    [Documentation]  This KW is created to crash SW_NODE_L node using kill-9 <PID> command.
    [Arguments]  ${vnu_dist_name}  ${low_node_id}

    ${status}  Run Keyword And Return Status  Should Not Contain  ${vnu_dist_name}[dist_name]  ${PRIMARY_CORE_BTS_L}
    ${smod}  Set Variable If  ${status}  192.168.255.119  192.168.255.129
    Connect To SMOD  ${smod}
    ${result}  ssh.Execute  lxc-attach -n ${low_node_id} ps aux | grep swconfig
    Log  \n ${result} \n
    ${regex}  Get Regexp Matches  ${result}  root\\s+\\d+
    ${length_list}  Get Length  ${regex}
    ${random_regex}  Evaluate  random.randint(0, ${length_list}-1)  modules=random
    ${from_list}  Get From List  ${regex}  ${random_regex}
    ${words}  Split String  ${from_list}
    ${process_id}  Get From List  ${words}  1
    ${kill}  ssh.Execute  lxc-attach -n ${low_node_id} -- bash -c '{ sleep 1; } | kill -9 ${process_id}'


Get SW Node
    [Arguments]  ${core_side}

    ${sw_node_ccplane}  Query Infomodel  get list /MRBTS-1/RAT-1/BTS_L-${core_side}//SW_NODE_L-* is [rat="NR", applicationGroup="CentralCPlane"]
    ...  timeout=60
    ${sw_node_lom}  Query Infomodel
    ...  get list /MRBTS-1/RAT-1/BTS_L-${core_side}//SW_NODE_L-* is [rat="NR", applicationGroup="Lom", variant="MasterLomTraceController"]
    ...  timeout=60

    RETURN  ${sw_node_ccplane}  ${sw_node_lom}


Get Node For ASIK
    [Arguments]  ${node_list}

    Log  SMOD is ASIK, node must have hostname TRACECM00.  console=true
    FOR  ${node}  IN  @{node_list}
        ${list}  Create List  ${node}
        ${status}  Run Keyword And Return Status  Should Contain  ${node}[hostname]  TRACECM
        IF  ${status}  RETURN  ${list}
    END
    Fail  No available node with hostname TRACECM00 for ASIK.


Set Test Variables For Fault Signature
    ${cells_string}  Get Matching Lcr Ids String For All RAT Cells  NRCEL
    Set Test Variable  ${EXTRA_INFO}  faulty_cells=NR:${cells_string}
    ${node_id}  Convert To Hex  ${ELEMENT}[nodeId]  prefix=0x
    ${low_node_id}  Convert To Lowercase  ${node_id}
    ${status_CPCL}  Run Keyword And Return Status  Should Match Regexp  ${ELEMENT}[hostname]  CPCL[0-9]+
    ${status_CPNB}  Run Keyword And Return Status  Should Match Regexp  ${ELEMENT}[hostname]  CPNB[0-9]+
    ${status_CPRT}  Run Keyword And Return Status  Should Match Regexp  ${ELEMENT}[hostname]  CPRT[0-9]+
    ${status_CPNRT}  Run Keyword And Return Status  Should Match Regexp  ${ELEMENT}[hostname]  CPNRT[0-9]+
    ${status_CPIF}  Run Keyword And Return Status  Should Match Regexp  ${ELEMENT}[hostname]  CPIF[0-9]+
    ${status_TRACECC}  Run Keyword And Return Status  Should Match Regexp  ${ELEMENT}[hostname]  TRACECC[0-9]+
    ${status_TRACECM}  Run Keyword And Return Status  Should Match Regexp  ${ELEMENT}[hostname]  TRACECM[0-9]+
    ${hostname}  Set Variable If  ${status_CPCL}  CPCL
    ...  ${status_CPNB}  CPNB
    ...  ${status_CPRT}  CPRT
    ...  ${status_CPNRT}  CPNRT
    ...  ${status_CPIF}  CPIF
    ...  ${status_TRACECC}  TRACECC
    ...  ${status_TRACECM}  TRACECM
    Set Test Variable  ${MINOR}  ${low_node_id} ${hostname}
    ${smod_l_dn}  Fetch From Left  ${ELEMENT}[dist_name]  /SMOD_L-1
    ${smod_l_parameters}  Query Infomodel  get object ${smod_l_dn}/SMOD_L-1
    Set Test Variable  ${PRODUCT_NAME}  ${smod_l_parameters}[productName]
    Set Test Variable  ${PRODUCT_CODE}  ${smod_l_parameters}[productCode]
    Set Test Variable  ${SERIAL_NUMBER}  ${smod_l_parameters}[serialNumber]
    ${smod_r}  Query Infomodel  get object //SMOD_R-* is [serialNumber=${smod_l_parameters}[serialNumber]]
    Set Unit Position For Fault Signature  ${smod_r}[dist_name]
    Set Test Variable  ${EXPECTED_FAULT_ID}  ${FAULT_4383_RAT_AUTO_RST}[fault_id]
    Set Test Variable  ${CATEGORY}  TIMEOUT
    Set Test Variable  ${SCOPE}  NR RAT
    Set Test Variable  ${INFO}  Node communication failure
    Set Test Variable  ${RESET_COUNTER}  [0-9]+


TC Setup
    Common Test Setup  tc_name=FM__5G_RAT_reset_executed_as_autonomous_recovery_action
    Setup NetAct


TC Teardown
    Change FMCADM Parameter  actForceAutoReset  false
    Teardown NetAct
    Common Test Teardown
