*** Settings ***
Documentation
    ...  This test case was created to imitate LTE L3Pool VN crash recovery reset scenario. PID of L3Pool process will be found from ps -aux output.
    ...  Appropriate fields from VNU containter in IM will be checked during crash. Fault 4383 and recovery request apperance
    ...  will be checked in seperate threads. In meantime also resoningStatus from VNU will be checked.

Library  ute_async
Resource  ../../common_resources/ca_FM_general.robot


*** Variables ***
${RECOVERY_TIMEOUT}  300  # Timeout for SBTS to recover after L3Pool VN crash scenario
${STARTUP_TIMEOUT}  600  # Timeout for SBTS to recover after site reset
${NETACT_TIMEOUT}  180  # [in seconds] Timeout for alarm to be reported in Netact


*** Keywords ***
TC__FM___LTE_L3_crash_VN_recovery_reset
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-10142
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 14.05.2018 - https://jira3.int.net.nokia.com/browse/TAT-10142 - Initial TAT creation
    ...  - 07.03.2019 - https://jira3.int.net.nokia.com/browse/TAT-15102 - Support for 4+3 platform added
    ...  - 11.03.2019 - https://jira3.int.net.nokia.com/browse/TAT-15037 - Replacement of depracated KW "check_if_target_is_available"
    ...  - 14.03.2019 - https://jira3.int.net.nokia.com/browse/TAT-15267 - Removed additional space
    ...  - 18.03.2019 - https://jira3.int.net.nokia.com/browse/TAT-15307 - Allign all FM TCs with RobotFramework version 3.1.0
    ...  - 21.03.2019 - https://jira3.int.net.nokia.com/browse/TAT-15380 - Check primary core prefix KW changed
    ...  - 05.04.2019 - https://jira3.int.net.nokia.com/browse/TAT-15296 - Reset counter clearance moved at the TC beginning
    ...  - 28.06.2019 - https://jira3.int.net.nokia.com/browse/TAT-16740 - Change the way of historical alarms verification
    ...  - 28.08.2019 - https://jira3.int.net.nokia.com/browse/TAT-14208 - LTE L3pool VNUs are not accessible from FCT level (FSMF platform)
    ...  - 22.01.2020 - https://jira3.int.net.nokia.com/browse/TAT-18854 - Modify Get SM Variant function name in FM test cases
    ...  - 09.04.2020 - https://jira3.int.net.nokia.com/browse/TAT-19328 - Remove VNU_L and replace it with SW_NODE_L
    ...  - 19.06.2020 - https://jira3.int.net.nokia.com/browse/TAT-19746 - Move keywords to resource file
    ...  - 21.05.2021 - https://jira3.ext.net.nokia.com/browse/TAT-20125 - Process id was not optain correctly
    ...  - 11.10.2021 - https://jira3.ext.net.nokia.com/browse/TAT-21634 - Implement new method to crash SW_NODE_L when node is located on ABIO/ABIN
    ...  - 10.11.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22065 - Adapt FM TCs for CNI-61110
    ...  - 14.03.2022 - https://jira3.ext.net.nokia.com/browse/TAT-22777 - Fix for getting bbmod position
    ...  - 27.09.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23678 - Add time for getting output
    ...  - 26.10.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24003 - Resolve duplicate keywords
    ...  - 17.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24955 - FM files refactor to robotws standard
    ...  - 12.05.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25370 - Remove BTS_L_ID
    ...  - 05.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26813 - Refactor FM testcase for assert alarm active parameters
    ...  - 19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Use faults defined in py file
    ...  - 03.06.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27497 - Modify keyword in resource file
    ...  - 26.06.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27704 - Add option to skip RMOD power check
    ...  - 12.08.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27933 - Container not found
    ...  - 29.08.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28007 - Add keyword perform site reset
    ...  - 02.09.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28011 - Container not found in 24R2 release
    ...  - 25.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29190 - Enhancement of all test cases in regression to check fault signature
    ...  - 25.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29459 - Enhancement of all test cases in regression to check FS component field
    ...  *******************

    Set Tags  CA-FM  OWNER-laura.craciunel@nokia.com  AUTHOR-rafal.ozga@nokia.com  GROUP_IN_CHARGE-TIM_4_Vrf
    ...  PHASE-CRT  SW-SBTS17A  FEATURE-RP001534

    Step1: Check All Required States
    Step2: Trigged LTE L3Pool VN Crash
    Step3: Verify Success Of Recovery Action


Step1: Check All Required States
    [Documentation]  In this step specific states will be checked.

    Log  \nStep1: Check all required states.  console=true
    Perform Site Reset
    Check Which Core Is Primary
    Set Test Variable  ${INFO}  (CCS supervised command exited.*|Node communication failure)
    Set Test Variable  ${SCOPE}  Virtual Node
    Set Test Variable  ${CATEGORY}  (SW_FAILURE|TIMEOUT)
    Set Test Variable  ${RESET_COUNTER}  [0-9]+
    ${all_rmods_power_before_reco_reset}  Create Dictionary
    Set Test Variable  ${ALL_RMODS_POWER_BEFORE_RECO_RESET}
    ${all_rmods_power_after_reco_reset}  Create Dictionary
    Set Test Variable  ${ALL_RMODS_POWER_AFTER_RECO_RESET}
    Get All Tx Power From All RMs  ${ALL_RMODS_POWER_BEFORE_RECO_RESET}


Step2: Trigged LTE L3Pool VN Crash
    [Documentation]  In this step LTE L3Pool VN crash will be triggered.

    Log  \nStep2: Trigger LTE L3Pool VN crash.  console=true

    ${vnu_l}  Query Infomodel  get list /MRBTS-1/RAT-*//SOC_L-1/SW_NODE_L-* is [rat="LTE", applicationGroup="DistributedCPlane"]  timeout=60
    ${list_length}  Get Length  ${vnu_l}
    FOR  ${element}  IN  @{vnu_l}
        ${start_time}  Get Current Date  time_zone=UTC  result_format=datetime
        ${sm_variant}  Get SM Variant From Node  ${element.dist_name}
        ${is_node_on_bbmod}  Run Keyword And Return Status  Should Contain  ${element.dist_name}  BBMOD_L
        ${is_node_on_smod}  Run Keyword And Return Status  Should Contain  ${element.dist_name}  SMOD_L
        ${bbmod_type}  Run Keyword If  ${is_node_on_bbmod}  Get BBMOD Type  ${element.dist_name}
        ${smod_type}  Run Keyword If  ${is_node_on_smod}  Get SMOD Type  ${element.dist_name}
        ${node_id_fsmf}  Convert To Hex  ${element.nodeId}
        ${low_node_id_fsmf}  Convert To Lowercase  ${node_id_fsmf}
        ${minor}  Set Variable  .*(D_CPNODE)?.*0x${low_node_id_fsmf}
        ${is_ccu}  Run Keyword And Return Status  Should Contain  ${element.dist_name}  /CCU
        ${is_bbu}  Run Keyword And Return Status  Should Contain  ${element.dist_name}  /BBU
        ${is_board}  Run Keyword And Return Status  Should Contain  ${element.dist_name}  /BOARD
        IF  ${is_ccu}
          ${module_l_dn}  Fetch From Left  ${element}[dist_name]  /CCU_L
        ELSE IF  ${is_bbu}
          ${module_l_dn}  Fetch From Left  ${element}[dist_name]  /BBU_L
        ELSE IF  ${is_board}
          ${module_l_dn}  Fetch From Left  ${element}[dist_name]  /BOARD_L
        END
        ${module_l_parameters}  Query Infomodel  get object ${module_l_dn}
        ${product_name}  Set Variable  ${module_l_parameters}[productName]
        ${product_code}  Set Variable  ${module_l_parameters}[productCode]
        ${serial_number}  Set Variable  ${module_l_parameters}[serialNumber]
        ${string}  Set Variable If  ${is_node_on_smod}  SMOD  BBMOD
        ${module_r}  Query Infomodel  get object //${string}_R-* is [serialNumber=${module_l_parameters}[serialNumber]]
        Set Unit Position For Fault Signature  ${module_r}[dist_name]

        IF  '${sm_variant}'=='Flexi'  Crash VN On FSMF  ${element}  ${low_node_id_fsmf}
        IF  '${sm_variant}'=='AirScale'  Chose Crash Type  ${is_node_on_smod}  ${is_node_on_bbmod}  ${smod_type}  ${bbmod_type}  ${element}
        Setup Admin  bts_host=192.168.255.129  bts_port=443  use_ssl=True  alias=fault
        ${fault_4383_params}  Get String With Alarm Parameters  ${FAULT_4383_PROCESSES_AUTO_RST}
        ${fault_status}  Run Keyword In Background  Assert Alarm Active  parameters=${fault_4383_params}  timeout=660  alias=fault
        ${reset_recovery}  Start Async  ute_admin_infomodel  Query Infomodel  get list //RECOVERY_RESET_IND-*  timeout=660  alias=recovery
        ${vnu_status}  Run Keyword And Return Status
        ...  Query Infomodel  get list ${element.dist_name} is [stateInfo.reasoningStatus[0]="NodeStoppedUnexpectedly"]  timeout=300
        IF  ${vnu_status}
          Log  Reasoning status is NodeStoppedUnexpectedly. [OK]  console=true
        ELSE
          Set Test Restriction  Reasoning status is different than expected. [NOK]
        END
        ${status_fault}  Run Keyword And Return Status  Collect Keyword Result  ${fault_status}  timeout=660
        IF  ${status_fault}
          Log  Fault ${FAULT_4383_PROCESSES_AUTO_RST} is visible in WebEM. [OK]  console=true
        ELSE
          Set Test Restriction  Fault ${FAULT_4383_PROCESSES_AUTO_RST} was not visible in WebEM. [NOK]
        END
        ${status_reset_recovery}  ${async_result}  Run Keyword And Ignore Error  Wait For Async Result  alias=recovery
        IF  '${status_reset_recovery}'=='FAIL'
          Set Test Restriction  Recovery reset indication is not visible under FRI. [NOK]
        ELSE
          Log  Recovery reset indication is visible uder FRI. [OK]  console=true
        END
        Stop Async  alias=recovery
        Run Keyword And Continue On Failure  Teardown Admin  alias=fault
        Check WCDMA Cells  ${ACTIVE}  ${ENABLED}
        Check GSM Cells  ${ACTIVE}  ${ENABLED}
        Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT} sec  65 sec  Check All Cells
        Assert Alarm Inactive  parameters=${fault_4383_params}
        Log  Fault ${FAULT_4383_PROCESSES_AUTO_RST} is not visible after recovery action.  console=true

       Wait Until Keyword Succeeds  ${NETACT_TIMEOUT}  30
       ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_4383_PROCESSES_AUTO_RST}  time_from=${start_time}
       ...  additional_fault_id=${FAULT_4383_PROCESSES_AUTO_RST}[fault_id]
       Log  Fault ${FAULT_4383_PROCESSES_AUTO_RST} reported and cleared in Netact.  console=true

       Log  Checking fault signature.  console=true
       Check Fault Signature Of Alarm In WebEM  fault_id=${FAULT_4383_PROCESSES_AUTO_RST}[fault_id]  info=${INFO}  scope=${SCOPE}  minor=${minor}
       ...  category=${CATEGORY}  load_name=${SW_VERSION}  reset_counter=${RESET_COUNTER}  full_product_name=${product_name}
       ...  serial_number=${serial_number}  vendor_unit_number=${product_code}  unit_position=${UNIT_POSITION}
       ...  core_unit_position=${CORE_UNIT_POSITION}
       Check Fault Signature Of Alarm In Netact  fault_id=${FAULT_4383_PROCESSES_AUTO_RST}[fault_id]  time_from=${start_time}
       ...  info=INFO:${SPACE}${INFO}  scope=SCOPE:${SPACE}${SCOPE}  minor=MINOR:${SPACE}${minor}  category=CATEGORY:${SPACE}${CATEGORY}
       ...  load_name=LOAD_NAME:${SPACE}${SW_VERSION}  reset_counter=RESET_COUNTER:${SPACE}${RESET_COUNTER}  full_product_name=${product_name}
       ...  serial_number=${serial_number}  vendor_unit_number=${product_code}  unit_position=${UNIT_POSITION}
       ...  core_unit_position=${CORE_UNIT_POSITION}

    END


Step3: Verify Success Of Recovery Action
    [Documentation]  In this step verification of recovery action will be checked.

    Log  \nStep3: Verify success of recovery action after FHNET VN crash was triggered.  console=true
    Log  Checking Historical Alarms for presence of 7101 Internal BTS processes autonomous reset as recovery action  console=true
    ${historical_alarms}  Get_historic_alarms  severity=warning
    FOR  ${element}  IN  @{historical_alarms}
        ${status7101}  Run Keyword And Return Status  Should Be Equal As Integers  ${element}[alarmId]  7101
        IF  ${status7101}  BREAK
    END
    Should Be True  ${status7101}  Alarm 7101 "${FAULT_4383_PROCESSES_AUTO_RST}[alarm_name]" is not visible in historical alarms.
    Log  Alarm 7101 "${FAULT_4383_PROCESSES_AUTO_RST}[alarm_name]" is visible in historical alarms.  console=true
    Check All Cells
    Get All Tx Power From All RMs  ${ALL_RMODS_POWER_AFTER_RECO_RESET}
    Compare TXs  ${ALL_RMODS_POWER_AFTER_RECO_RESET}  ${ALL_RMODS_POWER_BEFORE_RECO_RESET}
    Admin Check Active Alarms TAF


Get BBMOD Type
    [Arguments]  ${dist_name}

    ${is_bbu}  Run Keyword And Return Status  Should Contain  ${dist_name}  BBU
    ${is_board}  Run Keyword And Return Status  Should Contain  ${dist_name}  BOARD
    IF  ${is_bbu}
      ${string}  Set Variable  /BBU_L
    ELSE IF  ${is_board}
      ${string}  Set Variable  /BOARD_L
    END
    ${bbmod_distname}  Fetch From Left  ${dist_name}  ${string}
    ${bbmod}  Query Infomodel  get object ${bbmod_distname}

    RETURN  ${bbmod.productName}


Get SMOD Type
    [Arguments]  ${dist_name}

    ${is_ccu}  Run Keyword And Return Status  Should Contain  ${dist_name}  CCU
    ${is_board}  Run Keyword And Return Status  Should Contain  ${dist_name}  BOARD
    IF  ${is_ccu}
      ${string}  Set Variable  /CCU_L
    ELSE IF  ${is_board}
      ${string}  Set Variable  /BOARD_L
    END
    ${smod_distname}  Fetch From Left  ${dist_name}  ${string}
    ${smod}  Query Infomodel  get object ${smod_distname}

    RETURN  ${smod.productName}


Chose Crash Type
    [Arguments]  ${is_node_on_smod}  ${is_node_on_bbmod}  ${smod_type}  ${bbmod_type}  ${sw_node_l}

    IF  '${is_node_on_smod}'=='True'  Chose Crash For System Module  ${smod_type}  ${sw_node_l}
    IF  '${is_node_on_bbmod}'=='True'  Chose Crash For Baseband Module  ${bbmod_type}  ${sw_node_l}


Chose Crash For System Module
    [Arguments]  ${type}  ${element}

    ${suported_system_modules}  Create List
    Append To List  ${suported_system_modules}  ASIA AirScale Common  ASIB AirScale Common  ASIL AirScale Common  ASIM AirScale Common

    ${node_id}  Convert To Hex  ${element.nodeId}  prefix=0x
    ${low_node_id}  Convert To Lowercase  ${node_id}
    IF  '${type}' in ${suported_system_modules}
      Crash VN On Airscale  ${element}  ${low_node_id}
    ELSE
      Fail  msg=Unsuported type for crash.
    END


Chose Crash For Baseband Module
    [Arguments]  ${type}  ${sw_node_l}

    IF  '${type}'=='ABIN AirScale Capacity' or '${type}'=='ABIO AirScale Capacity' or '${type}'=='ABIP AirScale Capacity'
      Crash VN On ABIO/ABIN/ABIP  ${sw_node_l}
    ELSE
      Fail  msg=Unsuported type for crash.
    END


Crash VN On ABIO/ABIN/ABIP
    [Documentation]  This KW is created to crash SW_NODE_L virtual nodes on ABIN|ABIO|ABIP AirScale Capacity baseband cards.
    [Arguments]  ${sw_node_l}

    Log  ${sw_node_l.dist_name}  console=true

    ${is_bbu}  Run Keyword And Return Status  Should Contain  ${sw_node_l.dist_name}  /BBU_L
    ${is_board}  Run Keyword And Return Status  Should Contain  ${sw_node_l.dist_name}  /BOARD_L
    IF  ${is_bbu}
      ${string}  Set Variable  /BBU_L
    ELSE IF  ${is_board}
      ${string}  Set Variable  /BOARD_L
    END
    ${bbmod_l_dn}  Fetch From Left  ${sw_node_l.dist_name}  ${string}
    ${stored_role}  Get StoredRole From MODULE_L  ${bbmod_l_dn}
    ${bbmod_r_dn}  Get Runtime Object Dist_name From Logical Object Dist_name  ${bbmod_l_dn}
    ${bbmod_position}  Get Module Vertical Position  ${bbmod_r_dn}
    Open Connection To Primary Core
    IF  '${stored_role}'=='Idle'  Open Connection To Secondary Core
    Open Connection To SoC  ${bbmod_position}  0
    Stop Container  ${sw_node_l.hostname}


Stop Container
    [Arguments]  ${hostname}

    Log  Container ${hostname} will be stopped.  console=true
    SSHLibrary.Write  ps aux | grep ${hostname}
    ${output_ps}  SSHLibrary.Read Until Prompt
    ${container_status}  Run Keyword And Return Status  Should Contain  ${output_ps}  hwr-container@${hostname}.service
    IF  ${container_status}
      SSHLibrary.Write  systemctl stop container hwr-container@${hostname}.service
    ELSE
      Kill node_D-CPNODE process  ${hostname}  ${output_ps}
    END


Kill node_D-CPNODE process
    [Arguments]  ${hostname}  ${output}

    ${matching_lines}  Get Lines Containing String  ${output}  node_${hostname}
    ${regex}  Get Regexp Matches  ${matching_lines}  root\\s+\\d+
    ${length_list}  Get Length  ${regex}
    ${random_regex}  Evaluate  random.randint(0, ${length_list}-1)  modules=random
    ${from_list}  Get From List  ${regex}  ${random_regex}
    ${words}  Split String  ${from_list}
    ${process_id}  Get From List  ${words}  1
    SSHLibrary.Write  kill -9 ${process_id}
    ${kill}  SSHLibrary.Read Until Prompt


TC Setup
    Common Test Setup  tc_name=FM__LTE_L3_crash_VN_recovery_reset
    Setup NetAct


TC Teardown
    Teardown NetAct
    Common Test Teardown
