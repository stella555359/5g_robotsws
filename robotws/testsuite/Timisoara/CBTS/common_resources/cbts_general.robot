*** Settings ***
Documentation  This suite contains KWs used by vDU and vCU TCs

Library  DateTime
Library  taf.sw.ping  WITH NAME  ping
Library  taf.transport.ssh  WITH NAME  ssh
Library  SSHLibrary
Library  ../../resources/python_resources/radio_modules.py
Resource  netact_resource.robot
Resource  ../../resources/ca_FM_common.robot


*** Keywords ***
Change M2M Output To List Of Alarm Dicts
    [Documentation]  This keyword is used to transform the output received from the m2m interface query for active or
    ...  historical alarms into a list of alarm dictionaries, by removing the output noise characters as well as removing
    ...  the outer dictionary, finally evaluating it as a json.
    ...  ${m2m_output} - represents the variable which holds the raw m2m query output from the get_active_alarms or
    ...  get_historical_alarms query
    ...  ${alarms_list} - represents the return value - a list of dictionaries composed of the alarms
    [Arguments]  ${m2m_output}

    ${output}  Remove M2M Output Noise  ${m2m_output}
    ${output}  Fetch From Right  ${output}  {\n\t"alarms" :
    ${output}  Fetch From Left  ${output}  ,\n\t"total" :
    ${alarms_list}  Evaluate  json.loads('''${output}''')  json

    [Return]  ${alarms_list}


Check If Alarm Was Raised After Timestamp
    [Documentation]  This keyword is used to check if a specific alarm is found in the historical alarms
    ...  output, checking from a given timestamp until the present time.
    ...  ${timestamp} - represents the date and time after which we want to find the alarm; should have the same format
    ...  as the 'Get current date' keyword, excluding the milliseconds.
    ...  ${alarms_history} - represents the output from get_historical_alarms for either vcu or vdu
    ...  &{parameters} - represents a dictionary containing all fields of the alarm output we want to check,
    ...  for example: alarm_id=7115  alarm_name=text  fault_id=4592  fault_name=text
    ...  The keyword fails if the latest alarm found in the historical alarms output, matching the search criteria,
    ...  appeared before ${timestamp}
    ...  An example for using this keyword:
    ...  Check if alarm was raised after timestamp  ${timestamp}  alarm_id=7115  alarm_name=BASE STATION INFORMATION
    ...  ...  fault_id=4592  fault_name=BTS reset cause
    ...  *AUTHOR*: victor.banicioiu@nokia.com
    ...  *MAINTAINER*: victor.banicioiu@nokia.com
    [Arguments]  ${timestamp}  ${alarms_history}  &{parameters}

    Run Keyword If  ${alarms_history}[total]==0
    ...  Fail  Error: "No alarm ${parameters}[alarm_id] was found in alarm history" [NOK].
    ${alarm_entry}  Set Variable  ${alarms_history}[alarms][0]
    ${last_alarm}  Set Variable  ${alarm_entry}[appear_time]
    Set Test Variable  ${APPEAR_TIMESTAMP}  ${last_alarm}
    ${last_alarm}  Replace String  ${last_alarm}  T  ${SPACE}
    ${last_alarm}  Fetch From Left  ${last_alarm}  +
    Run Keyword If  '${last_alarm}' > '${timestamp}'
    ...  Log  Alarm ${parameters}[alarm_id] was raised after the selected timestamp.  console=true
    ...  ELSE
    ...  Fail  Error: "The alarm ${parameters}[alarm_id] entry was raised before the selected timestamp" [NOK].
    Verify Alarm Output Parameters  ${alarm_entry}  ${parameters}


Check Fault Signature Fields For OM_GEN_SFS_FM_3055
    [Documentation]  This keyword is used to evaluate the fault signature fields of an alarm output obtained
    ...  from the alarm history. The keyword checks that the mandatory fields are present and they adhere
    ...  to OM_GEN_SFS_FM.3055 convention.
    ...  Arguments are:
    ...  ${alarm} - represents the fault signature field from one of the alarms obtained from alarm history,
    ...  in the form of a dictionary.
    ...  ${active_sw_version} - represents the test variable ${VXU_ACTIVE_SW_VERSION} (X = D | C)
    ...  depending on which unit we are checking the alarm.
    ...  The keyword will fail if any of the mandatory fields is non-existent or if its value do not adhere
    ...  to the OM_GEN_SFS_FM.3055 convention.
    ...  *AUTHOR*: victor.banicioiu@nokia.com
    ...  *MAINTAINER*: victor.banicioiu@nokia.com
    [Arguments]  ${alarm}  ${active_sw_version}

    @{category}  Create List  OAM_RESET  PLATFORM_RESET  ASSERT  EXCEPTION  TIMEOUT  POWER_OFF  SW_FAILURE  HW_FAILURE  UNKNOWN
    @{scope}  Create List  Site  Board  Partial  DSP group  BBPOOL  RFM  ESM  GSM RAT  WCDMA RAT  LTE RAT  NR RAT  SoC  vCU  vDU  Virtual Node
    List Should Contain Value  ${category}  ${alarm}[category]  Error: "Category field in fault signature is not displayed correctly" [NOK].
    Log  'Category' field in fault signature is correctly displayed.  console=true
    Should Be Equal  ${alarm}[loadName]  ${active_sw_version}  Error: "loadName field in fault signature is not displayed correctly" [NOK].
    Log  'loadName' field in fault signature is correctly displayed.  console=true
    ${key_exists}  Run Keyword And Return Status
    ...  Get From Dictionary  ${alarm}  component
    Run Keyword If  ${key_exists}
    ...  Should Match Regexp  ${alarm}[component]  [A-Za-z0-9]*  Error: "Component field not displayed correctly" [NOK].
    ...  ELSE
    ...  Log  Component field is not present in the output. Might not be applicable.  WARN  console=true
    List Should Contain Value  ${scope}  ${alarm}[scope]  Error: "Scope field in fault signature is not displayed correctly" [NOK].
    Log  'Scope' field in fault signature is correctly displayed.  console=true


Verify Alarm Output Parameters
    [Documentation]  This keyword checks that the provided parameters in the dictionary &{parameters}
    ...  can be found in the alarm entry ${alarm} provided from the active or historical alarms output.
    ...  *AUTHOR*: victor.banicioiu@nokia.com
    ...  *MAINTAINER*: victor.banicioiu@nokia.com
    [Arguments]  ${alarm}  ${parameters}

    FOR  ${parameter}  IN  @{parameters}
        ${alarm_parameter}  Convert To String  ${alarm}[${parameter}]
        Should Contain  ${parameters}[${parameter}]  ${alarm_parameter}
    END


Remove M2M Rad Debug Parameters Output Noise
    [Documentation]  This kw is removing additional noise from Rad debug parameters M2M output.
    [Arguments]  ${output}

    ${output}  Remove M2M Output Noise  ${output}
    ${output}  Remove String  ${output}  \\n
    ${output}  Remove String Using Regexp  ${output}  \\n.*\\n
    ${output}  Remove String Using Regexp  ${output}  (\\s*\\d*)*:00:
    ${output}  Remove String Using Regexp  ${output}  (\\n\\s\\s|curl):\\s\\(6\\).*
    ${output}  Remove String  ${output}  \n
    ${output}  Remove String Using Regexp  ${output}  \\.\\d+M\\s+\\.\\d+M

    RETURN  ${output}


Refactor M2M Rad Debug Parameters Output
    [Documentation]  This kw is removing unnecessary characters from M2M output and returns the list with
    ...  dictionaries corresponding to all R&D debug parameters.
    ...  *AUTHOR*: andrada-lavinia.baleti@nokia.com
    ...  *MAINTAINER*: andrada-lavinia.baleti@nokia.com
    [Arguments]  ${output}

    ${output}  Remove M2M Output Noise  ${output}
    ${output}  Remove String  ${output}  \\n
    ${output}  Fetch From Right  ${output}  "radParams":
    ${output}  Fetch From Left  ${output}  ,"status":
    ${list_of_dict}  Evaluate  json.loads('''${output}''')  json

    [Return]  ${list_of_dict}


Save M2M Output To Json File
    [Documentation]  This kw is transforming string response to M2M command into a dictionary which contains
    ...  the operation id, R&D debug domains or parameters and the status of the command. This dictionary
    ...  is written in json file in ${TEST_RESULTS_DIR} directory.
    ...  *AUTHOR*: andrada-lavinia.baleti@nokia.com
    ...  *MAINTAINER*: andrada-lavinia.baleti@nokia.com
    [Arguments]  ${output}  ${file_path}

    ${dict}  Evaluate  json.loads('''${output}''')  json
    ${json_string}  Evaluate  json.dumps(${dict}, indent=4)  json
    Create File  ${TEST_RESULTS_DIR}/${file_path}  ${json_string}


Verify First Row In DiagnosticReport.Csv File
    [Documentation]
    ...  This keyword verifies first row in DiagnosticReport.csv
    ...  ${csv_content} must be obtained with "Return csv file content" from csv.resource.py
    ...  DiagnosticReport.csv is usually located in ${TEST_RESULTS_DIR}.
    ...  *AUTHOR*: anna.benzar@nokia.com
    [Arguments]  ${csv_content}

    Verify Entry In Csv File  ${csv_content}  Check point Id  0  0
    Verify Entry In Csv File  ${csv_content}  Check point name  0  1
    Verify Entry In Csv File  ${csv_content}  Distname  0  2
    Verify Entry In Csv File  ${csv_content}  last definitive result timestamp  0  3
    Verify Entry In Csv File  ${csv_content}  last definitive result  0  4
    Verify Entry In Csv File  ${csv_content}  trigger type  0  5
    Verify Entry In Csv File  ${csv_content}  timestamp  0  6
    Verify Entry In Csv File  ${csv_content}  last result  0  7


Verify Second Row In DiagnosticReport.Csv File
    [Documentation]
    ...  This keyword verifies second row in DiagnosticReport.csv
    ...  ${csv_content} must be obtained with "Return csv file content" from csv.resource.py
    ...  DiagnosticReport.csv is usually located in ${TEST_RESULTS_DIR}.
    ...  *AUTHOR*: anna.benzar@nokia.com
    [Arguments]  ${csv_content}  ${bts_id}  ${type}  ${status}  ${test_time}

    Verify Entry In Csv File  ${csv_content}  38  1  0
    Verify Entry In Csv File  ${csv_content}  Configuration file presence on running software  1  1
    Verify Entry In Csv File  ${csv_content}  MRBTS-${bts_id}  1  2
    Verify Entry In Csv File  ${csv_content}  ${type}  1  5
    Verify Entry In Csv File  ${csv_content}  ${status}  1  7
    ${date_time_csv}  Fetch From Left  ${csv_content}[1][3]  +
    ${date_time_csv}  Replace String Using Regexp  ${date_time_csv}  T  ${SPACE}
    Run Keyword If  '${date_time_csv}' < '${test_time}'
    ...  Fail  CSV time is not correct. [NOK]


Verify Third Row In DiagnosticReport.Csv File
    [Documentation]
    ...  This keyword verifies third row in DiagnosticReport.csv
    ...  ${csv_content} must be obtained with "Return csv file content" from csv.resource.py
    ...  DiagnosticReport.csv is usually located in ${TEST_RESULTS_DIR}.
    ...  *AUTHOR*: anna.benzar@nokia.com
    [Arguments]  ${csv_content}  ${bts_id}  ${type}  ${status}  ${test_time}

    Verify Entry In Csv File  ${csv_content}  39  2  0
    Verify Entry In Csv File  ${csv_content}  Configuration data validity on running software  2  1
    Verify Entry In Csv File  ${csv_content}  MRBTS-${bts_id}  2  2
    Verify Entry In Csv File  ${csv_content}  ${type}  2  5
    Verify Entry In Csv File  ${csv_content}  ${status}  2  7
    ${date_time_csv}  Fetch From Left  ${csv_content}[2][3]  +
    ${date_time_csv}  Replace String Using Regexp  ${date_time_csv}  T  ${SPACE}
    Run Keyword If  '${date_time_csv}' < '${test_time}'
    ...  Fail  Csv time is not correct. [NOK]


Verify Entry In Csv File
    [Documentation]
    ...  This keyword verifies csv entry at the given row and column.
    ...  ${file_content} must be obtained with "Return csv file content" from csv.resource.py
    ...  *AUTHOR*: anna.benzar@nokia.com
    [Arguments]  ${file_content}  ${entry_value}  ${row}  ${column}

    Should Be Equal As Strings  ${file_content}[${row}][${column}]  ${entry_value}  ${entry_value} not correct is csv file. [NOK]


Get Full Name For Pod
    [Documentation]
    ...  This keyword retrieves pod name on vDU or vCU by given pod type.
    ...  SSH connection must be opened beforehand.
    [Arguments]  ${cran}  ${pod_type}

    SSHLibrary.Write  kubectl get pods -n ${cran}
    ${pods_output}  SSHLibrary.Read Until Prompt
    ${pod_line}  Get Lines Containing String  ${pods_output}  ${pod_type}
    ${pod_name}  Fetch From Left  ${pod_line}  ${SPACE}
    Should Not Be Empty  ${pod_name}  Pod type: ${pod_type} not found on current opened connection.

    RETURN  ${pod_name}


Get Full Name For Container
    [Documentation]
    ...  This keyword returns container name on vDU or vCU based on pods name output and container type.
    ...  SSH connection must be opened beforehand.
    [Arguments]  ${cran}  ${container_type}

    SSHLibrary.Write  kubectl get pods -n ${cran}
    ${pods_output}  SSHLibrary.Read Until Prompt
    ${pods_lines}  Split To Lines  ${pods_output}
    ${pod_name}  Fetch From Left  ${pods_lines}[1]  ${SPACE}

    IF  '${cran}' in '${pod_name}'
        ${container_name}  Catenate  SEPARATOR=-  ctr  ${cran}  ${container_type}
    ELSE
        ${container_name}  Catenate  SEPARATOR=-  ctr  ${container_type}
    END

    RETURN  ${container_name}


Get Current Time For Diagnostic Check
    [Documentation]
    ...  This kewyord returns current date and time with format: %Y-%m-%d %H:%M:%S
    ...  Current time is incremented with 3 hours
    ...  to compare it with current time returned by Diagnostic Check.

    ${current_date_time}  Get Current Date  time_zone=UTC  increment= + 3 hours  result_format=%Y-%m-%d %H:%M:%S  exclude_millis=True

    [Return]  ${current_date_time}


Clear File Form Server
    [Documentation]  This will remove the given file form an open SSH connection.
    ...  Connection must be made with taf.transport.ssh.
    [Arguments]  ${path}  ${connection}=${None}

    Log  Removing ${path} from server.  console=true
    ssh.Send Command  sudo rm ${path}  connection=${connection}
    Sleep  2  Wait for file to be removed.
    ${status}  File Exists  ${path}  connection=${connection}
    Run Keyword If  ${status}
    ...  Fail  Could not remove ${path}. Test will be failed.

    [Teardown]  Reset Rsyslog Service On Server  ${connection}


Reset Rsyslog Service On Server
    [Documentation]  Rsyslog service must be restarted after deleting the log file because
    ...  oncoming syslogs will not be saved.
    [Arguments]  ${connection}=${None}

    Log  Reseting rsyslog service on server.  console=true
    ssh.Send Command  sudo service rsyslog restart  connection=${connection}


Check Syslog Collection Is Ongoing
    [Documentation]  Check Syslog Collection Is Ongoing
    [Arguments]  ${ip}

    ${syslog_status}  Get Syslog Collection Status  ${ip}
    Run Keyword If  '${syslog_status}'!='on'
    ...  Fail  Syslog collection is not triggerd.


Check Syslog Collection Is Finnished
    [Documentation]  Check Syslog Collection Is Finnished
    [Arguments]  ${ip}

    ${syslog_status}  Get Syslog Collection Status  ${ip}
    Run Keyword If  '${syslog_status}'=='on'
    ...  Fail  Syslog collection is not triggerd.


Get Syslog Collection Status
    [Documentation]  Get Syslog Collection Status
    [Arguments]  ${ip}

    ${m2m_output}  Run M2M Command  GET  https://${ip}/api/licensed/v1/syslog-streaming  Bearer  ${TOKEN}
    ${m2m_output}  Remove M2M Output Noise  ${m2m_output}
    ${m2m_output}  Evaluate  ${m2m_output}
    ${keys}  Get Dictionary Keys  ${m2m_output}
    ${key}  Run Keyword If  'status' in ${keys}
    ...  Set Variable  status
    ...  ELSE
    ...  Set Variable  content

    [Return]  ${m2m_output}[${key}]


Wait Syslog Collection To Be Finnished
    [Documentation]  Wait Syslog Collection To Be Finnished
    [Arguments]  ${ip}  ${timeout}

    Log  Wait up to ${timeout} for syslog collection to be finnished.  console=true
    Wait Until Keyword Succeeds  ${timeout}  10
    ...  Check Syslog Collection Is Finnished  ${ip}


Modify Resource Search Order
    [Documentation]  Adjust Robot's library search order for the Robot-based (as opposed to JSON-based)
    ...  test sets. To be used in TC Setup section as follows (presented here in a convenient tabular form):
    ...  Modify Resource Search Order | res_name
    [Tags]  robot:no-dry-run
    [Arguments]  ${resource_name}

    ${search_order}  Set Library Search Order
    Set Library Search Order  ${resource_name}  @{search_order}


Check If OAMPM Pod Is Not Running
    [Documentation]  This keyword is checking if status for given pod is not Running.
    [Arguments]  ${pod_name}  ${cran}

    SSHLibrary.Write  oc get pods -n ${cran}
    ${pods_output}  SSHLibrary.Read Until Prompt
    ${pod_line}  Get Lines Containing String  ${pods_output}  ${pod_name}
    Should Not Contain  ${pod_line}  Running