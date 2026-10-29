*** Settings ***
Documentation
    ...  This test case is transferred from BOAM_ET to ST_OAM_WebEM.
    ...  This test case check if SBTS reject the second getPrbMeasurement command from ADMIN CLI.
    ...  actCli parameter is changed to be true.
    ...  Sending in background the first command for getPrbMeasurement from SBTS via ADMIN CLI and saving the results in a csv file.
    ...  Sending the second command for getPrbMeasurement from SBTS via ADMIN CLI and saving the results in a csv file.
    ...  Verify the second command to be sent with status failed and error code 69.
    ...  File from the first command should not be empty.
    ...  Verify if bts id, eNB, Timestamp, Cell, every LTE cells and value -140 appeared in the csv file.
    ...  actCli parameter is changed to be false.

Resource  ../../common_resources/ca_WebEM_general.robot


*** Keywords ***
TC__WebEM__BTS_reject_the_second_getPrbMeasurement_CLI_command
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-24460
    ...
    ...  *****************
    ...  History of changes
    ...  ******************
    ...  - 16.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24460 - Initial TAT creation

    Set Tags  CA-WebEM  OWNER-cristina.antoci@nokia.com  AUTHOR-andreea.burtic@nokia.com  MAINTAINER-andreea.burtic@nokia.com
    ...  GROUP_IN_CHARGE-TIM_3_Vrf  PHASE-CRT  SW-SBTS23  FEATURE-CB007185

    Step1: Change ActCli Parameter To Be true
    Step2: Verify If The BTS Reject The Second GetPrbMeasurement Via ADMIN CLI
    Step3: Verify PRBmeasurements CSV
    Step4: Change ActCli Parameter To Be false


Step${id}: Change ActCli Parameter To Be ${value}
    Log  \nStep${id}: Change actCli parameter to be ${value}  console=true
    Change ActCli Parameter  ${value}


Step2: Verify If The BTS Reject The Second GetPrbMeasurement Via ADMIN CLI
    Log  Step2: Verify if the BTS reject the second getPrbMeasurement via ADMIN CLI  console=true
    ${admin_cli_path}  Setup Admin CLI  ${ACTIVE_SW_VERSION}  ${MPLANE_IP}
    ${command}  Catenate  SEPARATOR=  ${admin_cli_path}/admin-cli.sh --bts-username\=Nemuadmin --bts-password\=nemuuser --bts-host\=
    ...  ${MPLANE_IP} --bts-port\=443 --data\='{"requestId":1,"parameters":{"name":"getPrbMeasurement","parameters":{"operation
    ...  ":"Start","duration":60}}}' --output-file\=${BTS_FILES}/PRBmeasurements.csv
    Log  \nSending the first command via Admin CLI for getPrbMeasurement...  console=true
    Process.Start Process  ${command}  shell=yes
    Sleep  5s  Time for the first command to run.
    Log  The first command is running in background...  console=true
    Log  \nSending the second command via Admin CLI for getPrbMeasurement...  console=true
    ${output}  Run  ${command}
    Should Contain  ${output}  "errorCode":69  msg=The output doesn't contain errorCode:69![NOK]
    Should Contain  ${output}  "requestStatus":"failed"  msg=The output doesn't contain requestStatus:failed![NOK]
    Should Contain  ${output}  "requestMessage":"Operation failed"  msg=The output doesn't contain requestMessage:Operation failed![NOK]
    Log  The output contains requestStatus:failed, errorCode:69 and requestMessage:Operation failed![OK]  console=true
    Wait Until Keyword Succeeds  90  10
    ...  File Should Not Be Empty  ${BTS_FILES}/PRBmeasurements.csv  msg='${BTS_FILES}/PRBmeasurements.csv' is empty![NOK]


Step3: Verify PRBmeasurements CSV
    Log  Step3: Verify PRBmeasurements CSV  console=true
    ${lncels_param}  Get Parameters For All  LNCEL
    ${phycell_ids_list}  Create List
    FOR  ${index}  IN  @{lncels_param}
        Append To List  ${phycell_ids_list}  ${index}[phyCellId]
    END
    ${content_csv}  Run  command=cat ${BTS_FILES}/PRBmeasurements.csv | sed -e 's/,/ ,/g' | column -t -s, | less -S
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
