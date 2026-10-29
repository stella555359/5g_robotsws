*** Settings ***
Documentation  LOGS__Event_Log_Creation_For_WebEM_Operation
Resource    ../resources/pm_logs_frame.robot
Resource    ../resources/pm_logs_general.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot
Resource    ../resources/bts_states.robot
Library     taf.sbts.oam.coam.admin  WITH NAME  coam
Library     DateTime

*** Keywords ***
TC__LOGS__Event_Log_Creation_For_WebEM_Operation.robot
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-12131
    ...  ******************
    ...  Author: Lukasz Targonski
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 2018-09-10 - https://jira3.int.net.nokia.com/browse/TAT-12131 - Initial Creation
    ...  - 2018-10-16 - https://jira3.int.net.nokia.com/browse/TAT-12422
    ...  - 2018-11-20 - https://jira3.int.net.nokia.com/browse/TAT-13182
    ...  - 2019-02-05 - https://jira3.int.net.nokia.com/browse/TAT-14316
    ...  - 2019-03-18 - https://jira3.int.net.nokia.com/browse/TAT-15155
    ...  - 2019-04-04 - https://jira3.int.net.nokia.com/browse/TAT-15641
    ...  - 2019-08-19 - https://jira3.int.net.nokia.com/browse/TAT-17192
    ...  - 2021-08-06 - https://jira3.ext.net.nokia.com/browse/TAT-21707
    ...  - 2021-12-22 - TAT-22173 - Changes done due to CNI-61110 - move to hran_frame_sbts_siso
    ...  - 2022-07-19 - https://jiradc.ext.net.nokia.com/browse/TAT-23414 - KW(placeholder) Common step trigger for
    ...                 checking sleeping cells added in TC Teardown due to BIT CS4.3 Enable Sleeping Cell
    ...  - 10.03.2023 - TAT-24917 - Hran_frame resource name change to ca_pm_logs_frame
    ...  ******************
    ...  Basic information
    ...  *****************
    ...  This test to check if Event logs are successfully created in Info Model to log WebEM user activities on BTS.
    ...  In first steps 1 - 3 three WebEM operations are performed
    ...  Step 1: connection to WebEM is opened, Step 2: btsName parameter is updated, Step 3: connection to WebEM is closed.
    ...  In steps 4 - 6 it is checked if appropriate Event logs for such operations
    ...  are created under /MRBTS-1/RAT-1/EVENT_LOG-1/ path in Info Model. It is also checked if all mandatory parameters in
    ...  Event log are correctly filled.
    ...  *******************
    ...  Test case flowchart: https://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SBTS/LOGS__Event_Log_Creation_For_WebEM_Operation.png
    ...  *******************


    Set Tags    CA-LOGS    OWNER-lukasz.targonski@nokia.com    AUTHOR-lukasz.targonski@nokia.com
    ...    MAINTAINER-iuliia.taupeka@nokia.com    PHASE-CRT    SW-SBTS17

    Step 1: Open WebEM Connection
    Step 2: Perform Parameter Update Via WebEM
    Step 3: Close WebEM Connection
    Step 4: Verify Event Log For Open WebEM Connection Operation
    Step 5: Verify Event Log For Perform Parameter Update Via WebEM Operation
    Step 6: Verify Event Log For Close WebEM Connection Operation


Step 1: Open WebEM Connection
    Log  \nStep 1: Open connection to WebEM  console=${TRUE}
    ${current_date}           DateTime.Get Current Date  time_zone=UTC  exclude_millis=True  result_format=%Y-%m-%d %H:%M:
    pm_logs_frame.Setup Admin Connection  bts_host=${SMOD1['TRS_IP']}
    ${current_date_plus_1m}   DateTime.Add Time To Date  ${current_date}  1 minute  result_format=%Y-%m-%d %H:%M:

    ${current_date}           Replace String  ${current_date}  ${SPACE}  T
    ${current_date_plus_1m}   Replace String  ${current_date_plus_1m}  ${SPACE}  T

    Set Test Variable  ${current_date}
    Set Test Variable  ${current_date_plus_1m}

Step 2: Perform Parameter Update Via WebEM
    Log  \nStep 2: Perform parameter update via WebEM  console=${TRUE}
    ${bts_id}      bts_states.Get BTS ID
    ${btsName}     bts_states.Get BTS Name

    Log  btsName parameter will be changed to 'xxxxx'  console=${TRUE}
    coam.Perform Parameter Recommissioning  MRBTS-${bts_id}  btsName  update  xxxxx  skip_parameter_relation_errors=${TRUE}
    Log  btsName parameter will be changed back to '${btsName}'  console=${TRUE}
    coam.Perform Parameter Recommissioning  MRBTS-${bts_id}  btsName  update  ${btsName}  skip_parameter_relation_errors=${TRUE}

Step 3: Close WebEM Connection
    Log  \nStep 3: Close connection to WebEM  console=${TRUE}
    coam.Teardown All Aliases For Admin
    Set Test Variable  ${admin_started}  ${FALSE}

Step 4: Verify Event Log For Open WebEM Connection Operation
    [Documentation]
    ...  In Step 4 it is checked if correct Event log with 'operation' parameter 'http session establishment'
    ...  is successfully created under /MRBTS-1/RAT-1/EVENT_LOG-1/ object in Info Model. Additiona parameters including additionalText,
    ...  clientIpAddress, procedureResult, sessionId, sessionTime, userName are also checked

    Log  \nStep 4: Verify Event Log for 'open WebEM connection' operation  console=${TRUE}
    Sleep  1m
    Start Infomodel
    ${operation}  Set Variable  Login
    ${parameter_update_operation}  Set Variable  ${FALSE}
    ${match_found}  Set Variable  ${FALSE}

    ${event_logs_list}  Query Infomodel  get list //EVENT_LOG-1/EVENT-*

    FOR  ${event}  IN  @{event_logs_list}
      ${match_date}  Run Keyword And Ignore Error  Should Contain Any  ${event.sessionTime}  ${current_date}  ${current_date_plus_1m}
      Run keyword if  '${match_date[0]}'=='PASS'  run keywords
      ...  Log  \nEvent-${event.dist_name} with correct sessionTime parameter value: ${event.sessionTime} found  console=${TRUE}
      ...  AND  Log  Event parameters values will be analyzed  console=${TRUE}
      ...  AND  Validate Event Log Parameters  ${event}  ${operation}  ${parameter_update_operation}
      Run keyword if  ${match_found}  Run Keywords
      ...  Set Test Variable  ${session_time}  ${event.sessionTime}
      ...  AND  Set Test Variable  ${session_id}  ${event.sessionId}
      ...  AND  Exit For Loop
    END

    Run Keyword Unless  ${match_found}  Fail  ${operation} Event log not found in Info Model

Step 5: Verify Event Log For Perform Parameter Update Via WebEM Operation
    [Documentation]
    ...  In Step 5 it is checked if correct Event logs with 'operation' parameter 'PLAN_VALIDATE_IND' and 'PLAN_ACTIVATE_IND'
    ...  is successfully created under /MRBTS-1/RAT-1/EVENT_LOG-1/ object in Info Model. Additiona parameters including additionalText,
    ...  clientIpAddress, procedureResult, sessionId, sessionTime, userName, changedObjectDetails are also checked

    Log  \nStep 5: Verify Event Log for 'parameter update via WebEM' Operation  console=${TRUE}
    ${operation}  Set Variable  PLAN_VALIDATE_IND
    ${parameter_update_operation}  Set Variable  ${FALSE}
    Find Event Log In Info Model  ${operation}  ${parameter_update_operation}
    ${operation}  Set Variable  PLAN_ACTIVATE_IND
    ${parameter_update_operation}  Set Variable  ${TRUE}
    Find Event Log In Info Model  ${operation}  ${parameter_update_operation}

Step 6: Verify Event Log For Close WebEM Connection Operation
    [Documentation]
    ...  In Step 6 it is checked if correct Event logs with 'operation' parameter 'http session closing'
    ...  is successfully created under /MRBTS-1/RAT-1/EVENT_LOG-1/ object in Info Model. Additiona parameters including additionalText,
    ...  clientIpAddress, procedureResult, sessionId, sessionTime, userName are also checked

    Log  \nStep 6: Verify Event Log for 'close WebEM connection' operation  console=${TRUE}
    ${operation}  Set Variable  Logout
    ${parameter_update_operation}  Set Variable  ${FALSE}
    ${match_found}  Set Variable  ${FALSE}
    Find Event Log In Info Model  ${operation}  ${parameter_update_operation}

Find Event Log In Info Model
    [Arguments]  ${operation}  ${parameter_update_operation}
    ${event_logs_list}  Query Infomodel  get list //EVENT_LOG-1/EVENT-*
    ${match_found}  Set Variable  ${FALSE}
    FOR  ${event}  IN  @{event_logs_list}
      Run Keyword If  '${event.sessionTime}'=='${session_time}' and '${event.sessionId}'=='${session_id}'  run keywords
      ...  Log  \nEvent-${event.dist_name} with correct sessionTime parameter value: ${session_time} found  console=${TRUE}
      ...  AND  Log  Event parameters values will be analyzed  console=yes
      ...  AND  Validate Event Log Parameters  ${event}  ${operation}  ${parameter_update_operation}
      Run Keyword If  ${match_found}  Exit For Loop
    END

    Run Keyword Unless  ${match_found}  Fail  ${operation} Event log not found in Info Model

Validate Event Log Parameters
    [Documentation]
    ...  m_oper i.e. match_operation
    ...  m_addit_txt i.e match_additional_text
    ...  m_cl_ip i.e. match_client_ip
    ...  m_proc_res  i.e. match_procedure_result
    ...  m_uname i.e. match_username

    [Arguments]  ${Event_log}  ${operation}  ${parameter_update_operation}

    ${additional_text}  Set Variable If  ${SMOD2_exists}  SM-1011-Pri${SPACE}*  SM-1011${SPACE}*

    ${m_oper}         Run Keyword And Ignore Error  Should Match  ${Event_log.operation}  ${operation}
    ${m_addit_txt}   Run Keyword And Ignore Error  Should Match  ${Event_log.additionalText}  ${additional_text}
    ${m_cl_ip}         Run Keyword And Ignore Error  Should Match  ${Event_log.clientIpAddress}  192.168.255.126
    ${m_proc_res}  Run Keyword And Ignore Error  Should Match  ${Event_log.procedureResult}  Succeeded
    ${m_uname}          Run Keyword And Ignore Error  Should Match  ${Event_log.userName}  Nemuadmin

    ${match_changed_object_details}  Run Keyword If  ${parameter_update_operation} and ${Event_log.changedObjectDetails}
    ...  Validate changedObjectDetails Parameter  ${Event_log}
    ${match_changed_object_details}  Set Variable If  ${parameter_update_operation}==${FALSE}  ${TRUE}  ${match_changed_object_details}

    Run Keyword If  '${m_oper[0]}'=='PASS'
    ...  Log  Correct value of parameter 'operation': ${Event_log.operation}  console=${TRUE}
    ...  ELSE  Log  Incorrect value of parameter 'operation': ${Event_log.operation}  console=${TRUE}
    Run Keyword If  '${m_addit_txt[0]}'=='PASS'
    ...  Log  Correct value of parameter 'additionalText': ${Event_log.additionalText}  console=${TRUE}
    ...  ELSE  Log  Incorrect value of parameter 'additionalText': ${Event_log.additionalText}  console=${TRUE}
    Run Keyword If  '${m_cl_ip[0]}'=='PASS'
    ...  Log  Correct value of parameter 'clientIp': ${Event_log.clientIpAddress}  console=${TRUE}
    ...  ELSE  Log  Incorrect value of parameter 'clientIp': ${Event_log.clientIpAddress}  console=${TRUE}
    Run Keyword If  '${m_proc_res[0]}'=='PASS'
    ...  Log  Correct value of parameter 'procedureResult': ${Event_log.procedureResult}  console=${TRUE}
    ...  ELSE  Log  Incorrect value of parameter 'procedureResult': ${Event_log.procedureResult}  console=${TRUE}
    Run Keyword If  '${m_uname[0]}'=='PASS'
    ...  Log  Correct value of parameter 'username': ${Event_log.userName}  console=${TRUE}
    ...  ELSE  Log  Incorrect value of parameter 'username': ${Event_log.userName}  console=${TRUE}
    Run Keyword If  ${parameter_update_operation}
    ...  Run Keyword Unless  ${Event_log.changedObjectDetails}  Log  changedObjectDetails parameter is missing  console=${TRUE}

    Run Keyword If
    ...  '${m_oper[0]}'=='PASS' and '${m_addit_txt[0]}'=='PASS' and '${m_cl_ip[0]}'=='PASS' and '${m_proc_res[0]}'=='PASS' and '${m_uname[0]}'=='PASS'
    ...  Run Keywords
    ...  Log  Correct WebEM Event log for ${operation} operation found under ${Event_log.dist_name}  console=${TRUE}
    ...  AND  Set Test Variable  ${match_found}  ${TRUE}
    ...  ELSE  Set Test Variable  ${match_found}  ${FALSE}

Validate changedObjectDetails Parameter
    [Arguments]  ${Event_log}

    ${changed_object_details}  Get From List  ${Event_log.changedObjectDetails}  0
    ${changed_object_details_parameter_name}   Get from Dictionary  ${changed_object_details}  parameterName
    ${changed_object_details_parameter_value}  Get from Dictionary  ${changed_object_details}  parameterValue

    ${match_changed_object_details_parameter_name}   Run Keyword And Ignore Error  Should Match  ${changed_object_details_parameter_name}  btsName
    ${match_changed_object_details_parameter_value}  Run Keyword And Ignore Error  Should Match  ${changed_object_details_parameter_value}  xxxxx

    Run Keyword If  '${match_changed_object_details_parameter_name[0]}'=='PASS'
    ...  Log  Correct value of changedObjectDetails parameter 'parameterName': ${changed_object_details_parameter_name}  console=${TRUE}
    ...  ELSE  Log  Incorrect value of changedObjectDetails parameter 'parameterName': ${changed_object_details_parameter_name}  console=${TRUE}
    Run Keyword If  '${match_changed_object_details_parameter_value[0]}'=='PASS'
    ...  Log  Correct value of changedObjectDetails parameter 'parameterValue': ${changed_object_details_parameter_value}  console=${TRUE}
    ...  ELSE  Log  Incorrect value of changedObjectDetails parameter 'parameterValue': ${changed_object_details_parameter_value}  console=${TRUE}

    ${match_changed_object_details}  Set Variable If
    ...  '${match_changed_object_details_parameter_name[0]}'=='PASS' and '${match_changed_object_details_parameter_value[0]}'=='PASS'
    ...  ${TRUE}  ${FALSE}

    [Return]  ${match_changed_object_details}

TC Setup
    Common Test Setup
    ...  infomodel_launch=${FALSE}    alarms_check=${FALSE}    cells_check=${FALSE}    admin_launch=${FALSE}
    ...  modules_check=${FALSE}    expected_BTS_status=${FALSE}

TC Teardown
    Run Keywords
    ...    interface.Common step trigger
    ...    AND    coam.Connect To
    ...    AND    Setup Scout And Send Configuration
    ...    AND    Common Test Teardown
