*** Settings ***
Documentation
    ...  This test case gets historical and active alarms from IMS2 via ADMIN CLI R&D.
    ...  actCli parameter is changed to be true.
    ...  actDccSupport parameter is changed to be true.
    ...  Check getHistoricalAndActiveAlarmsFromIMS2 command with input and output files via ADMIN CLI R&D to be send completed with error code 0.
    ...  Check if active and historical alarms from SBTS are visible in saved csv.
    ...  Check getHistoricalAndActiveAlarmsFromIMS2 command without input file via ADMIN CLI R&D to be send failed with error code 3.
    ...  Check getHistoricalAndActiveAlarmsFromIMS2 command without output file via ADMIN CLI R&D to be send failed with error code 3.
    ...  Check getHistoricalAndActiveAlarmsFromIMS2 command without input and output files via ADMIN CLI R&D to be send failed with error code 3.
    ...  actCli parameter is changed to be false.
    ...  actDccSupport parameter is changed to be false.

Resource  ../../common_resources/ca_WebEM_general.robot


*** Variables ***
${PASSWORD_DDC_USER}  nE&e3Q*ptK8  # Password for dcc user used in admin cli setup


*** Keywords ***
TC__WebEM__Admin_CLI_getHistoricalAndActiveAlarmsFromIMS2
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-26591
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 01.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26591 - Initial TAT creation

    Set Tags  CA-WebEM  OWNER-mihnea.spineanu@nokia.com  AUTHOR-andreea.burtic@nokia.com  MAINTAINER-andreea.burtic@nokia.com
    ...  GROUP_IN_CHARGE-TIM_3_Vrf  PHASE-CRT  SW-SBTS24  FEATURE-CB010545

    Step1: Change ActCli And ActDccSupport Parameters To Be true
    Step2: Save Ims2
    Step3: Sending Command GetHistoricalAndActiveAlarmsFromIMS2 With Input And Output Files Via ADMIN CLI R&D
    Step4: Sending Command GetHistoricalAndActiveAlarmsFromIMS2 Without Input File Via ADMIN CLI R&D
    Step5: Sending Command GetHistoricalAndActiveAlarmsFromIMS2 Without Output File Via ADMIN CLI R&D
    Step6: Sending Command GetHistoricalAndActiveAlarmsFromIMS2 Without Input And Output Files Via ADMIN CLI R&D
    Step7: Change ActCli And ActDccSupport Parameters To Be false


Step${index}: Change ActCli And ActDccSupport Parameters To Be ${value}
    Log  \nStep${index}: Change actCli and actDccSupport parameters to be ${value}  console=true
    Change ActCli Parameter  ${value}
    ${status}  Run Keyword And Return Status
    ...  Perform Parameter Recommissioning  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
    ...  actDccSupport
    ...  update
    ...  ${value}
    ...  skip_parameter_relation_errors=true
    Run Keyword If  ${status}
    ...  Log  Parameter actDccSupport is set to ${value}![OK]  console=true
    ...  ELSE
    ...  Fail  Parameter actDccSupport is not set to ${value}![NOK]


Step2: Save Ims2
    Log  \nStep2: Save ims2  console=true
    Collect Infomodel Log From Current Session  ${BTS_FILES}/first_infomodel.ims2  timeout=300
    Set Test Variable  ${IMS_PATH}  ${BTS_FILES}/first_infomodel.ims2
    Log  Infomodel log saved under: ${IMS_PATH}  console=true


Step3: Sending Command GetHistoricalAndActiveAlarmsFromIMS2 With Input And Output Files Via ADMIN CLI R&D
    Log  \nStep3: Sending command getHistoricalAndActiveAlarmsFromIMS2 with input and output files via ADMIN CLI R&D  console=true
    Setup Admin CLI RAD  ${ACTIVE_SW_VERSION}  ${MPLANE_IP}  dcuser  ${PASSWORD_DDC_USER}  9020
    Log  \nSending command via Admin CLI R&D for getHistoricalAndActiveAlarmsFromIMS2 with input and output files...  console=true
    Set Test Variable  ${REQUEST}  {"requestId":1,"parameters":{"name":"getHistoricalAndActiveAlarmsFromIMS2"}}
    ${response}  Send Admin CLI Request RAD  ${REQUEST}  output_file=${BTS_FILES}/alarms.csv  input_file=${IMS_PATH}
    ${request_status}  Get From Dictionary  ${response}  requestStatus
    ${error_code}  Get From Dictionary  ${response}  errorCode
    ${output_file_name}  Get From Dictionary  ${response}  outputFileName
    Run Keyword If  '${request_status}' == 'completed' and ${error_code} == 0 and '${output_file_name}'=='${BTS_FILES}/alarms.csv'
    ...  Log  Command sent with status: ${request_status} and error code: ${error_code}! [OK]  console=true
    ...  ELSE
    ...  Fail  Command sent with status: ${request_status} and error code: ${error_code}! [NOK]
    Log  The alarms csv was saved in location: ${BTS_FILES}/alarms.csv!  console=true
    ${alarms_content}  OperatingSystem.Get File  ${BTS_FILES}/alarms.csv
    ${active_alarms}  coam.Get Active Alarms
    FOR  ${alarm}  IN  @{active_alarms}
        Should Contain  ${alarms_content}  ${alarm}[faultName]
        ...  Active alarm with fault name: ${alarm}[faultName] is not visible in alarms.csv content![NOK]
        Log  Active alarm with fault name: ${alarm}[faultName] is visible in alarms.csv content![OK]  console=true
    END
    Should Contain  ${alarms_content}  Historical alarm list
    ${historic_alarms}  coam.Get Historic Alarms
    ${historic_alarms_len}  Get Length  ${historic_alarms}
    Run Keyword If  ${historic_alarms_len} == 0
    ...  Run Keywords
    ...  Should Contain  ${alarms_content}  No historical alarm exist  No historical alarm exist text is not visible![NOK]
    ...  AND
    ...  Log  No historical alarm exist text is visible![OK]  console=true
    ...  ELSE
    ...  Verify If Historic Alarms From SBTS Appears In Saved File From Cli Output  ${historic_alarms}  ${alarms_content}


Step4: Sending Command GetHistoricalAndActiveAlarmsFromIMS2 Without Input File Via ADMIN CLI R&D
    Log  \nStep4: Sending command getHistoricalAndActiveAlarmsFromIMS2 without input file via ADMIN CLI R&D  console=true
    Setup Admin CLI RAD  ${ACTIVE_SW_VERSION}  ${MPLANE_IP}  dcuser  ${PASSWORD_DDC_USER}  9020
    Log  \nSending command via Admin CLI R&D for getHistoricalAndActiveAlarmsFromIMS2 without input file...  console=true
    ${response}  Send Admin CLI Request RAD  ${REQUEST}  output_file=${BTS_FILES}/alarms.csv
    ${request_status}  Get From Dictionary  ${response}  requestStatus
    ${error_code}  Get From Dictionary  ${response}  errorCode
    ${request_message}  Get From Dictionary  ${response}  requestMessage
    ${message}  Set Variable  Invalid schema: Missing required property: inputFileContent
    Run Keyword If  '${request_status}' == 'failed' and ${error_code} == 3 and '${request_message}' == '${message}'
    ...  Log  Command sent with status: ${request_status}, error code: ${error_code} and request message :${request_message}! [OK]  console=true
    ...  ELSE
    ...  Fail  Command sent with status: ${request_status}, error code: ${error_code} and request message :${request_message}! [NOK]


Step5: Sending Command GetHistoricalAndActiveAlarmsFromIMS2 Without Output File Via ADMIN CLI R&D
    Log  \nStep5: Sending command getHistoricalAndActiveAlarmsFromIMS2 without output file via ADMIN CLI R&D  console=true
    Setup Admin CLI RAD  ${ACTIVE_SW_VERSION}  ${MPLANE_IP}  dcuser  ${PASSWORD_DDC_USER}  9020
    Log  \nSending command via Admin CLI R&D for getHistoricalAndActiveAlarmsFromIMS2 without output file...  console=true
    ${response}  Send Admin CLI Request RAD  ${REQUEST}  input_file=${IMS_PATH}
    ${request_status}  Get From Dictionary  ${response}  requestStatus
    ${error_code}  Get From Dictionary  ${response}  errorCode
    ${request_message}  Get From Dictionary  ${response}  requestMessage
    ${req}  Set Variable  Invalid schema: /outputFileContent, Format validation failed (This procedure does not support base64 encoded file content)
    Run Keyword If  '${request_status}' == 'failed' and ${error_code} == 3 and '${request_message}' == '${req}'
    ...  Log  Command sent with status: ${request_status}, error code: ${error_code} and request message :${request_message}! [OK]  console=true
    ...  ELSE
    ...  Fail  Command sent with status: ${request_status}, error code: ${error_code} and request message :${request_message}! [NOK]


Step6: Sending Command GetHistoricalAndActiveAlarmsFromIMS2 Without Input And Output Files Via ADMIN CLI R&D
    Log  \nStep6: Sending command getHistoricalAndActiveAlarmsFromIMS2 without input and output files via ADMIN CLI R&D  console=true
    Setup Admin CLI RAD  ${ACTIVE_SW_VERSION}  ${MPLANE_IP}  dcuser  ${PASSWORD_DDC_USER}  9020
    Log  \nSending command via Admin CLI R&D for getHistoricalAndActiveAlarmsFromIMS2 without input and output files...  console=true
    ${response}  Send Admin CLI Request RAD  ${REQUEST}
    ${request_status}  Get From Dictionary  ${response}  requestStatus
    ${error_code}  Get From Dictionary  ${response}  errorCode
    ${request_message}  Get From Dictionary  ${response}  requestMessage
    ${message}  Set Variable  Invalid schema: Missing required property: inputFileContent
    Run Keyword If  '${request_status}' == 'failed' and ${error_code} == 3 and '${request_message}' == '${message}'
    ...  Log  Command sent with status: ${request_status}, error code: ${error_code} and request message :${request_message}! [OK]  console=true
    ...  ELSE
    ...  Fail  Command sent with status: ${request_status}, error code: ${error_code} and request message :${request_message}! [NOK]


Verify If Historic Alarms From SBTS Appears In Saved File From Cli Output
    [Arguments]  ${historic_alarms}  ${alarms_content}

    FOR  ${hist_alarm}  IN  @{historic_alarms}
        Should Contain  ${alarms_content}  ${hist_alarm}[faultName]
        ...  Historic alarm with fault name: ${hist_alarm}[faultName] is not visible in alarms.csv content![NOK]
        Log  Historic alarm with fault name: ${hist_alarm}[faultName] is visible in alarms.csv content![OK]  console=true
    END


TC Setup
    Common Test Setup


TC Teardown
    Common Test Teardown
