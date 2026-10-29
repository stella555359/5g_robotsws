*** Settings ***
Resource    ../resources/pm_logs_frame.robot
Resource    ../resources/pm_logs_general.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot
Library     taf.sbts.oam.coam.admin  WITH NAME  coam
Library     DateTime

*** Variables ***


*** Keywords ***
TC__LOGS__Event_Log_Creation_For_SSH_Operation
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-12083
    ...  ******************
    ...  Author: Lukasz Targonski
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 2018-09-06 - https://jira3.int.net.nokia.com/browse/TAT-12083 - Initial Creation
    ...  - 2018-10-16 - https://jira3.int.net.nokia.com/browse/TAT-12422
    ...  - 2019-02-05 - https://jira3.int.net.nokia.com/browse/TAT-14316
    ...  - 2019-04-30 - https://jira3.int.net.nokia.com/browse/TAT-15751
    ...  - 2019-06-28 - https://jira3.int.net.nokia.com/browse/TAT-16347
    ...  - 2021-08-06 - https://jira3.ext.net.nokia.com/browse/TAT-21707
    ...  - 2021-12-22 - TAT-22173 - Changes done due to CNI-61110 - move to hran_frame_sbts_siso
    ...  - 2022-07-19 - https://jiradc.ext.net.nokia.com/browse/TAT-23414 - KW(placeholder) Common step trigger for
    ...                 checking sleeping cells added in TC Teardown due to BIT CS4.3 Enable Sleeping Cell
    ...  - 10.03.2023 - TAT-24917 - Hran_frame resource name change to ca_pm_logs_frame
    ...  ******************
    ...  Basic information
    ...  *****************
    ...  This test to check if Event logs are successfully created in Info Model to log SSH user activities on BTS. In 3 Steps it is checked if
    ...  seperate Event logs are created to log: Step 1 SSH login operation, Step 2 Executed SSH session commands and Step 3 SSH logout operation.
    ...  Event logs for such operations are created under /MRBTS-1/RAT-1/SYSTEM_LOG-1/ path in Info Model.
    ...  It is also checked if all mandatory parameters in Event log are correctly filled.
    ...  *******************
    ...  Test case flowchart: https://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SBTS/LOGS__Event_Log_Creation_For_SSH_Operation.png
    ...  *******************


    Set Tags    CA-LOGS    OWNER-lukasz.targonski@nokia.com    AUTHOR-lukasz.targonski@nokia.com
    ...    MAINTAINER-iuliia.taupeka@nokia.com    PHASE-CR2    SW-SBTS17

    Step 1: Open SSH Connection
    Step 2: Execute SSH commands
    Step 3: Close SSH Connection


Step 1: Open SSH Connection
    [Documentation]
    ...  In Step 1 Connection to BTS via SSH is established. It is checked if correct Event log with 'operation' parameter 'SSH Login operation'
    ...  is successfully created under /MRBTS-1/RAT-1/SYSTEM_LOG-1/ object in Info Model. Additiona parameters including additionalText,
    ...  clientIpAddress, procedureResult, sessionId, sessionTime, userName are also checked

    Log  \nStep 1: Open SSH Connection and find appropriate Event log in Info Model  console=${TRUE}
    Sleep  3m
    SSHLibrary.Open Connection  ${SMOD1['IP']}
    SSHLibrary.Login  ${SMOD1['USERNAME']}  ${SMOD1['PASSWORD']}
    ${current_date}  DateTime.get current date  time_zone=UTC  exclude_millis=True  result_format=%Y-%m-%d %H:%M:
    ${current_date_minus_1m}  DateTime.Subtract Time From Date  ${current_date}  1 minute  result_format=%Y-%m-%d %H:%M:

    ${current_date}  Replace String  ${current_date}  ${SPACE}  T
    ${current_date_minus_1m}  Replace String  ${current_date_minus_1m}  ${SPACE}  T

    ${additional_text}  Set Variable If  ${SMOD2_exists}  SM-1011-Pri${SPACE}  SM-1011${SPACE}
    ${operation}  Set Variable  SSH Login operation
    Find SSH Login Event Log In Info Model  ${current_date}  ${current_date_minus_1m}  ${additional_text}  ${operation}

Step 2: Execute SSH commands
    [Documentation]
    ...  In Step 2 SSH session commands ('echo') are executed. BTS should log commands executed during SSH session in a group of 10 commands into
    ...  one Event log
    ...  It is checked if correct Event log with 'operation' parameter 'SSH session commands'
    ...  is successfully created under /MRBTS-1/RAT-1/SYSTEM_LOG-1/ object in Info Model. Additiona parameters including additionalText,
    ...  clientIpAddress, procedureResult, sessionId, sessionTime, userName are also checked

    Log  \nStep 2: Execute SSH Commands and find appropriate Event log in Info Model  console=${TRUE}
    FOR  ${index}  IN RANGE  1  11
      SSHLibrary.Write  echo ${index}
    END
    ${additional_text}  Set Variable If  ${SMOD2_exists}
    ...  SM-1011-Pri echo 1;echo 2;echo 3;echo 4;echo 5;echo 6;echo 7;echo 8;echo 9;echo 10;
    ...  SM-1011 echo 1;echo 2;echo 3;echo 4;echo 5;echo 6;echo 7;echo 8;echo 9;echo 10;
    ${operation}  Set Variable  SSH session commands
    Find Event Log In Info Model  ${additional_text}  ${operation}

Step 3: Close SSH Connection
    [Documentation]
    ...  In Step 3 SSH logout operation is performed. It is checked if correct Event log with 'operation' parameter 'SSH Logout Operation'
    ...  is successfully created under /MRBTS-1/RAT-1/SYSTEM_LOG-1/ object in Info Model. Additiona parameters including additionalText,
    ...  clientIpAddress, procedureResult, sessionId, sessionTime, userName are also checked

    Log  \nStep 3: Close SSH connection and find appropriate Event log in Info Model  console=${TRUE}
    SSHLibrary.Close Connection
    ${additional_text}  Set Variable If  ${SMOD2_exists}  SM-1011-Pri${SPACE}  SM-1011${SPACE}
    ${operation}  Set Variable  SSH Logout Operation
    Find Event Log In Info Model  ${additional_text}  ${operation}

Find SSH Login Event Log In Info Model
    [Arguments]  ${current_date}  ${current_date_minus_1m}  ${additional_text}  ${operation}
    ${match_found}  Set Variable  ${FALSE}
    Sleep  30s
    ${event_logs_list}  Query Infomodel  get list //SYSTEM_LOG-1/EVENT-*

    FOR  ${event}  IN  @{event_logs_list}
      ${match_date}  Run Keyword And Ignore Error  Should Contain Any  ${event.sessionTime}  ${current_date}  ${current_date_minus_1m}
      Run keyword if  '${match_date[0]}'=='PASS'  run keywords
      ...  Log  \nEvent-${event.dist_name} with correct sessionTime parameter value: ${event.sessionTime} found  console=${TRUE}
      ...  AND  Log  Event parameters values will be analyzed  console=${TRUE}
      ...  AND  Validate Event Log Parameters  ${event}  ${additional_text}  ${operation}
      Run keyword if  ${match_found}  Run Keywords
      ...  Set Test Variable  ${session_time}  ${event.sessionTime}
      ...  AND  Exit For Loop
    END

    Run Keyword Unless  ${match_found}  Fail  ${operation} Event log not found in Info Model

Find Event Log In Info Model
    [Arguments]  ${additional_text}  ${operation}
    Sleep  30s
    ${event_logs_list}  Query Infomodel  get list //SYSTEM_LOG-1/EVENT-*
    ${match_found}  Set Variable  ${FALSE}
    FOR  ${event}  IN  @{event_logs_list}
      Run Keyword If  '${event.sessionTime}'=='${session_time}'  run keywords
      ...  Log  \nEvent-${event.dist_name} with correct sessionTime parameter value: ${session_time} found  console=${TRUE}
      ...  AND  Log  Event parameters values will be analyzed  console=yes
      ...  AND  Validate Event Log Parameters  ${event}  ${additional_text}  ${operation}
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

    [Arguments]  ${Event_log}  ${additional_text}  ${operation}
    ${m_oper}         Run Keyword And Ignore Error  Should Match  ${Event_log.operation}  ${operation}
    ${m_addit_txt}   Run Keyword And Ignore Error  Should Match  ${Event_log.additionalText}  ${additional_text}
    ${m_cl_ip}         Run Keyword And Ignore Error  Should Match  ${Event_log.clientIpAddress}  192.168.255.126
    ${m_proc_res}  Run Keyword And Ignore Error  Should Match  ${Event_log.procedureResult}  Succeeded
    ${m_uname}          Run Keyword And Ignore Error  Should Match  ${Event_log.userName}  toor4nsn
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

    Run Keyword If
    ...  '${m_oper[0]}'=='PASS' and '${m_addit_txt[0]}'=='PASS' and '${m_cl_ip[0]}'=='PASS' and '${m_proc_res[0]}'=='PASS' and '${m_uname[0]}'=='PASS'
    ...  Run Keywords
    ...  Log  Correct SSH Event log for ${operation} operation found under ${Event_log.dist_name}  console=${TRUE}
    ...  AND  Set Test Variable  ${match_found}  ${TRUE}
    ...  ELSE  Set Test Variable  ${match_found}  ${FALSE}

TC Setup
    Common Test Setup    alarms_check=${FALSE}    cells_check=${FALSE}

TC Teardown
    Run Keywords
    ...    interface.Common step trigger
    ...    AND    Setup Scout And Send Configuration
    ...    AND    Common Test Teardown
