*** Settings ***
Documentation
    ...  This test case gets active alarms via ADMIN CLI.
    ...  Verify all cells on SBTS to be enabled.
    ...  actCli parameter is changed to be true.
    ...  Sending command for getting all alarms from SBTS via ADMIN CLI.
    ...  Verify for command to be sent with status completed.
    ...  Taking from every alarm the specific faultId via ADMIN CLI.
    ...  Taking from every alarm the specific faultId via WebEM.
    ...  Verify lists to be equal.
    ...  Test will fail if the lists are not equal.

Resource  ../../common_resources/ca_WebEM_general.robot


*** Keywords ***
TC__WebEM__Admin_CLI_getActiveAlarms
    [Documentation]
    ...  [CASE LINK]: https://jira3.ext.net.nokia.com/browse/TAT-21619
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 20.07.2021 - https://jira3.int.net.nokia.com/browse/TAT-21619 - Initial TAT creation
    ...  - 25.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24131 - Refactor TCs with best practice
    ...  - 15.12.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24316 - Refactor WebEM TCs and resources to use KWs from ca_SBTS_general
    ...  - 16.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26914 - Fix variable type
    ...  - 04.03.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26226 - Update TC for feature CB010545
    ...  - 10.04.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27315 - Resolve timing problem
    ...  - 06.06.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27612 - Verify current date instead of current time
    ...  - 17.12.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28559 - Modify bts name verification

    Set Tags  CA-WebEM  OWNER-nicolae-marcel.caragel@nokia.com  AUTHOR-andreea.burtic@nokia.com  MAINTAINER-andreea.burtic@nokia.com
    ...  GROUP_IN_CHARGE-TIM_3_Vrf  PHASE-CRT  SW-SBTS22

    Step1: Verify Cells On SBTS
    Step2: Change ActCli Parameter To Be true
    Step3: Get Active Alarms Via ADMIN CLI
    Step4: Change ActCli Parameter To Be false


Step1: Verify Cells On SBTS
    Log  Step1: Verify cells on SBTS  console=true
    ${status}  Run Keyword And Return Status
    ...  Check All Cells From WebEM
    Run Keyword If  ${status}
    ...  Log  SBTS is OnAir![OK]  console=true
    ...  ELSE
    ...  Fail  Not all cells are Enabled![NOK]


Step${id}: Change ActCli Parameter To Be ${value}
    Log  Step${id}: Change actCli parameter to be ${value}  console=true
    Change ActCli Parameter  ${value}


Step3: Get Active Alarms Via ADMIN CLI
    Log  Step3: Get active alarms via ADMIN CLI  console=true
    Get Active Alarms Via ADMIN CLI With EnhancedOutput On false
    Get Active Alarms Via ADMIN CLI With EnhancedOutput On true


Get Active Alarms Via ADMIN CLI With EnhancedOutput On ${value}
    ${fault_id_admin_cli_list}  Create List
    Setup Admin CLI  ${ACTIVE_SW_VERSION}  ${MPLANE_IP}
    ${request}  Set Variable  {"requestId":100,"parameters":{"name":"getActiveAlarms","parameters":{"enhancedOutput":${value}}}}
    Log  \nSending command via Admin CLI for getActiveAlarms with enhancedOutput on ${value}  console=true
    ${request_status}  ${error_code}  ${request_message}  Admin CLI Send Request  ${request}
    Run Keyword If  '${request_status}' == 'completed'
    ...  Log  Command sent with status: ${request_status}  console=true
    ...  ELSE
    ...  Fail  Command sent with status: ${request_status} and error code: ${error_code}
    ${command}  ${request_message_alarms}  Run Keyword If  '${value}'=='true'
    ...  Set Variable  Dictionary Should Contain Key  ${request_message}[alarms]
    ...  ELSE
    ...  Set Variable  List Should Not Contain Value  ${request_message}
    ${status_bts_id}  Run Keyword And Return Status
    ...  ${command}  ${request_message}  btsId
    ${status_bts_name}  Run Keyword And Return Status
    ...  ${command}  ${request_message}  btsName
    ${status_current_time}  Run Keyword And Return Status
    ...  ${command}  ${request_message}  currentTime
    ${status_parameters}  Run Keyword If  '${value}'=='true'
    ...  Check Value Of Parameters  ${request_message}
    Run Keyword If  '${value}'=='false' and ${status_bts_id} and ${status_bts_name} and ${status_current_time}
    ...  Log  In request message for getActiveAlarms with enhancedOutput on ${value} are no parameters btsId, btsName and currentTime.  console=true
    ...  ELSE IF  '${value}'=='true' and ${status_bts_id} and ${status_bts_name} and ${status_current_time} and ${status_parameters}
    ...  Log  In request message for getActiveAlarms with enhancedOutput on ${value} are parameters btsId, btsName and currentTime.  console=true
    ...  ELSE
    ...  Fail  Request message is unexpected for getActiveAlarms with enhancedOutput on ${value}.
    FOR  ${index}  IN  @{request_message_alarms}
        Run Keyword If  ${index}[faultId]
        ...  Append To List  ${fault_id_admin_cli_list}  ${index}[faultId]
        ...  ELSE
        ...  Continue For Loop
    END
    ${fault_id_webem_list}  Get All Active Alarms
    Sort List  ${fault_id_admin_cli_list}
    Sort List  ${fault_id_webem_list}
    Log  Verify if alarms are the same in Admin CLI and WebEM...  console=true
    ${status}  Run Keyword And Return Status
    ...  Lists Should Be Equal  ${fault_id_admin_cli_list}  ${fault_id_webem_list}
    Run Keyword If  ${status}
    ...  Log Alarms  ${fault_id_admin_cli_list}
    ...  ELSE
    ...  Fail  FaultIds from CLI are ${fault_id_admin_cli_list} whitch are not the same with faultIds from WebEM ${fault_id_webem_list}


Check Value Of Parameters
    [Arguments]  ${request_message}

    ${date_time}  Get Current Date  time_zone=UTC
    ${current_date_time}  Convert Date  ${date_time}  result_format=%Y-%m-%d
    ${bts_obj}  Get Parameters For All  BTS
    ${status_bts_id}  Run Keyword And Return Status
    ...  Should Be Equal As Strings  ${request_message}[btsId]  ${BTS_ID}
    ${status_bts_name}  Run Keyword And Return Status
    ...  Should Be Equal  ${request_message}[btsName]  ${bts_obj[0].btsName}
    ${status_current_time}  Run Keyword And Return Status
    ...  Should Start With  ${request_message}[currentTime]  ${current_date_time}
    Run Keyword If  ${status_bts_id} and ${status_bts_name} and ${status_current_time}
    ...  Return From Keyword  ${TRUE}
    ...  ELSE
    ...  Return From Keyword  ${FALSE}


Log Alarms
    [Arguments]  ${fault_id_admin_cli_list}

    FOR  ${fault_id}  IN  @{fault_id_admin_cli_list}
        Log  Alarm with faultId ${fault_id} is visible in Admin CLI and WebEM![OK]  console=true
    END


TC Setup
    Common Test Setup
    WebEM Setup


TC Teardown
    WebEM Teardown
    Common Test Teardown
