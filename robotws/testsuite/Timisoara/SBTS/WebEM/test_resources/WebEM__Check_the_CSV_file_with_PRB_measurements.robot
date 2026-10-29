*** Settings ***
Documentation
    ...  This test case is transferred from BOAM_ET to ST_OAM_WebEM.
    ...  This test case check getPrbMeasurement command from ADMIN CLI.
    ...  actCli parameter is changed to be true.
    ...  Sending command for getPrbMeasurement from SBTS via ADMIN CLI and saving the results in a csv file.
    ...  Verify for command to be sent with status completed and error code 0.
    ...  File should not be empty.
    ...  Verify if bts id, eNB, Timestamp, Cell, every LTE cells and value -140 appeared in the csv file.
    ...  actCli parameter is changed to be false.

Resource  ../../common_resources/ca_WebEM_general.robot


*** Keywords ***
TC__WebEM__Check_the_CSV_file_with_PRB_measurements
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-24461
    ...
    ...  *****************
    ...  History of changes
    ...  ******************
    ...  - 15.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24461 - Initial TAT creation

    Set Tags  CA-WebEM  OWNER-cristina.antoci@nokia.com  AUTHOR-andreea.burtic@nokia.com  MAINTAINER-andreea.burtic@nokia.com
    ...  GROUP_IN_CHARGE-TIM_3_Vrf  PHASE-CRT  SW-SBTS23  FEATURE-CB007185

    Step1: Change ActCli Parameter To Be true
    Step2: Get GetPrbMeasurement Via ADMIN CLI
    Step3: Verify GetPrbMeasurement CSV
    Step4: Change ActCli Parameter To Be false


Step${id}: Change ActCli Parameter To Be ${value}
    Log  \nStep${id}: Change actCli parameter to be ${value}  console=true
    Change ActCli Parameter  ${value}


Step2: Get GetPrbMeasurement Via ADMIN CLI
    Log  Step2: Get getPrbMeasurement via ADMIN CLI  console=true
    Setup Admin CLI  ${ACTIVE_SW_VERSION}  ${MPLANE_IP}
    ${request}  Set Variable  {"requestId":1,"parameters":{"name":"getPrbMeasurement","parameters":{"duration":120,"operation":"Start"}}}
    Log  \nSending command via Admin CLI for getPrbMeasurement...  console=true
    ${request_status}  ${error_code}  ${request_message}  Admin CLI Send Request  ${request}  output_file=${BTS_FILES}/PRB_measurements.csv
    Run Keyword If  '${request_status}' == 'completed' and ${error_code} == 0
    ...  Log  Command sent with status: ${request_status} and error code: ${error_code}! [OK] console=true
    ...  ELSE
    ...  Fail  Command sent with status: ${request_status} and error code: ${error_code}! [NOK]
    File Should Not Be Empty  ${BTS_FILES}/PRB_measurements.csv  msg='${BTS_FILES}/PRB_measurements.csv' is empty![NOK]


Step3: Verify GetPrbMeasurement CSV
    Log  Step3: Verify getPrbMeasurement CSV  console=true
    ${lncels_param}  Get Parameters For All  LNCEL
    ${phycell_ids_list}  Create List
    FOR  ${index}  IN  @{lncels_param}
        Append To List  ${phycell_ids_list}  ${index}[phyCellId]
    END
    ${content_csv}  Run  command=cat ${BTS_FILES}/PRB_measurements.csv | sed -e 's/,/ ,/g' | column -t -s, | less -S
    ${bts_id}  Admin Get BTS Id
    Should Contain  ${content_csv}  ${bts_id}  msg=The file doesn't contain BTS id ${bts_id}![NOK]
    Log  The file contains BTS id ${bts_id}![OK]  console=true
    Should Contain  ${content_csv}  eNB  msg=The file doesn't contain eNB in header![NOK]
    Log  The file contains eNB in header![OK]  console=true
    Should Contain  ${content_csv}  Cell  msg=The file doesn't contain Cell in header![NOK]
    Log  The file contains Cell in header![OK]  console=true
    FOR  ${cell}  IN  @{phycell_ids_list}
        ${phycell}  Convert To String  ${cell}
        Should Contain  ${content_csv}  ${phycell}  msg=The file doesn't contain cell ${phycell}![NOK]
        Log  The file contains cell ${phycell}![OK]  console=true
    END
    Should Contain  ${content_csv}  Timestamp  msg=The file doesn't contain Timestamp in header![NOK]
    Log  The file contains Timestamp in header![OK]  console=true
    Should Contain  ${content_csv}  -140  msg=The file doesn't contain value -140![NOK]
    Log  The file contains value -140![OK]  console=true


TC Setup
    Common Test Setup


TC Teardown
    Common Test Teardown
