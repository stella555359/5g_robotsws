*** Settings ***
Documentation
    ...  This test case start rfDiagnosticTest and save the results via ADMIN CLI.
    ...  actCli parameter is changed to be true.
    ...  Check rfDiagnosticTest command via ADMIN CLI to be send with error code 0.
    ...  Verify btsId, btsName, cellId and cellType from cli response.
    ...  Check saveRfDiagnosticTestResults command with output file via ADMIN CLI to be send with error code 0.
    ...  Verify btsId, btsName, cellId and cellType from saved output file.
    ...  Check saveRfDiagnosticTestResults command without output file via ADMIN CLI to be send with error code 0.
    ...  Verify btsId, btsName, cellId and cellType from cli response.
    ...  actCli parameter is changed to be false.

Resource  ../../common_resources/ca_WebEM_general.robot


*** Variables ***
${CELL_TEHNOLOGY}  NR
${RFPOWERERRORHIGHTHRESHOLD}  8
${RFPOWERERRORLOWTHRESHOLD}  -8
${TXANTENNAVSWRHIGHTHRESHOLD}  3
${RXANTENNARTWPHIGHTHRESHOLD}  -30
${RXANTENNARTWPLOWTHRESHOLD}  -110


*** Keywords ***
TC__WebEM__Admin_CLI_rfDiagnosticTest_and_saveRfDiagnosticTestResults
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-26244
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 27.10.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26244 - Initial TAT creation

    Set Tags  CA-WebEM  OWNER-mihnea.spineanu@nokia.com  AUTHOR-andreea.burtic@nokia.com  MAINTAINER-andreea.burtic@nokia.com
    ...  GROUP_IN_CHARGE-TIM_3_Vrf  PHASE-CRT  SW-SBTS24  FEATURE-CB010545

    Step1: Sending RfDiagnosticTest Command Via ADMIN CLI
    Step2: Check Output From RfDiagnosticTest Command
    Step3: Sending SaveRfDiagnosticTestResults Command With Output File Via ADMIN CLI And Check Output
    Step4: Sending SaveRfDiagnosticTestResults Command Without Output File Via ADMIN CLI And Check Output


Step1: Sending RfDiagnosticTest Command Via ADMIN CLI
    Log  \nStep1: Sending rfDiagnosticTest command via ADMIN CLI  console=true
    Set A Random Cell Id For A Specific Tehnology
    Setup Admin CLI  ${ACTIVE_SW_VERSION}  ${MPLANE_IP}
    Log  \nSending command via Admin CLI for rfDiagnosticTest...  console=true
    ${request}  Catenate  SEPARATOR=  {"requestId":1,"parameters":{"name":"rfDiagnosticTest","parameters":{"forceActRemoteRfDiag":true,
    ...  "cells":[${CELL_ID}],"cellType":"${CELL_TEHNOLOGY}","thresholds":{"rFPowerErrorHighThreshold":${RFPOWERERRORHIGHTHRESHOLD},
    ...  "rFPowerErrorLowThreshold":${RFPOWERERRORLOWTHRESHOLD},"txAntennaVSWRHighThreshold":${TXANTENNAVSWRHIGHTHRESHOLD},
    ...  "rxAntennaRTWPHighThreshold":${RXANTENNARTWPHIGHTHRESHOLD},"rxAntennaRTWPLowThreshold":${RXANTENNARTWPLOWTHRESHOLD}}}}}
    ${request_status}  ${error_code}  ${request_message}  Admin CLI Send Request  ${request}
    Run Keyword If  '${request_status}' == 'completed' and ${error_code} == 0
    ...  Log  Command sent with status: ${request_status} and error code: ${error_code}![OK]  console=true
    ...  ELSE
    ...  Fail  Command sent with status: ${request_status} and error code: ${error_code}![NOK]
    ${request_message}  Get From List  ${request_message}  0
    ${bts_id_cli}  Get From Dictionary  ${request_message}  btsId
    Log  BTS id from cli response is ${bts_id_cli}!  console=true
    ${cell_id_cli}  Get From Dictionary  ${request_message}  cellId
    Log  Cell id from cli response is ${cell_id_cli}!  console=true
    ${cell_type_cli}  Get From Dictionary  ${request_message}  cellType
    Log  Cell type from cli response is ${cell_type_cli}!  console=true
    ${bts_name_cli}  Get From Dictionary  ${request_message}  btsName
    Log  BTS name from cli response is ${bts_name_cli}!  console=true
    Set Test Variable  ${BTS_ID_CLI}
    Set Test Variable  ${BTS_NAME_CLI}
    Set Test Variable  ${CELL_ID_CLI}
    Set Test Variable  ${CELL_TYPE_CLI}


Step2: Check Output From RfDiagnosticTest Command
    Log  \nStep2: Check output from rfDiagnosticTest command  console=true
    ${bts_id}  Admin Get BTS Id
    Set Test Variable  ${BTS_ID}
    ${bts_name}  Get Bts Name
    Set Test Variable  ${BTS_NAME}
    Run Keyword If  '${BTS_ID}' == '${BTS_ID_CLI}' and '${BTS_NAME}' == '${BTS_NAME_CLI}'
    ...  Log  BTS id and name from WebEM are the same as in cli response![OK]  console=true
    ...  ELSE
    ...  Fail  BTS id and name from WebEM are not the same as in cli response![NOK]
    Run Keyword If  '${CELL_ID}' == '${CELL_ID_CLI}' and '${CELL_TEHNOLOGY}' == '${CELL_TYPE_CLI}'
    ...  Log  Cell id and type from WebEM are the same as in cli response![OK]  console=true
    ...  ELSE
    ...  Fail  Cell id and type from WebEM are not the same as in cli response![NOK]


Step3: Sending SaveRfDiagnosticTestResults Command With Output File Via ADMIN CLI And Check Output
    Log  \nStep3: Sending saveRfDiagnosticTestResults command with output file via ADMIN CLI and check output  console=true
    Log  \nSending command via Admin CLI for saveRfDiagnosticTestResults with output file...  console=true
    ${request_status}  ${error_code}  ${request_message}  Admin CLI Send Request  {"requestId":1,"parameters":{"name":"saveRfDiagnosticTestResults"}}
    ...  output_file=${BTS_FILES}/testResult.txt
    Run Keyword If  '${request_status}' == 'completed' and ${error_code} == 0
    ...  Log  Command sent with status: ${request_status} and error code: ${error_code}![OK]  console=true
    ...  ELSE
    ...  Fail  Command sent with status: ${request_status} and error code: ${error_code}![NOK]
    Log  Verify testResult.txt to contain btsId, btsName, cellId and cellType...  console=true
    ${file_content}  OperatingSystem.Get File  ${BTS_FILES}/testResult.txt
    Should Contain  ${file_content}  "btsName": "${BTS_NAME}"  BTS name from WebEM are not the same as in cli response![NOK]
    Log  BTS id from WebEM are the same as in cli response![OK]  console=true
    Should Contain  ${file_content}  "btsId": ${BTS_ID}  BTS id from WebEM are not the same as in cli response![NOK]
    Log  BTS name from WebEM are the same as in cli response![OK]  console=true
    Should Contain  ${file_content}  "cellId": ${CELL_ID}  Cell id from WebEM are not the same as in cli response![NOK]
    Log  Cell id from WebEM are the same as in cli response![OK]  console=true
    Should Contain  ${file_content}  "cellType": "${CELL_TEHNOLOGY}"  Cell type from WebEM are not the same as in cli response![NOK]
    Log  Cell type from WebEM are the same as in cli response![OK]  console=true


Step4: Sending SaveRfDiagnosticTestResults Command Without Output File Via ADMIN CLI And Check Output
    Log  \nStep4: Sending saveRfDiagnosticTestResults command without output file via ADMIN CLI and check output  console=true
    Log  \nSending command via Admin CLI for saveRfDiagnosticTestResults with output file...  console=true
    ${request_status}  ${error_code}  ${request_message}  Admin CLI Send Request  {"requestId":1,"parameters":{"name":"saveRfDiagnosticTestResults"}}
    Run Keyword If  '${request_status}' == 'completed' and ${error_code} == 0
    ...  Log  Command sent with status: ${request_status} and error code: ${error_code}![OK]  console=true
    ...  ELSE
    ...  Fail  Command sent with status: ${request_status} and error code: ${error_code}![NOK]
    ${request_message}  Get From List  ${request_message}  0
    ${bts_id_cli}  Get From Dictionary  ${request_message}  btsId
    Log  BTS id from cli response is ${bts_id_cli}!  console=true
    ${cell_id_cli}  Get From Dictionary  ${request_message}  cellId
    Log  Cell id from cli response is ${cell_id_cli}!  console=true
    ${cell_type_cli}  Get From Dictionary  ${request_message}  cellType
    Log  Cell type from cli response is ${cell_type_cli}!  console=true
    ${bts_name_cli}  Get From Dictionary  ${request_message}  btsName
    Log  BTS name from cli response is ${bts_name_cli}!  console=true
    Run Keyword If  '${BTS_ID}' == '${bts_id_cli}' and '${BTS_NAME}' == '${bts_name_cli}'
    ...  Log  BTS id and name from WebEM are the same as in cli response![OK]  console=true
    ...  ELSE
    ...  Fail  BTS id and name from WebEM are not the same as in cli response![NOK]
    Run Keyword If  '${CELL_ID}' == '${cell_id_cli}' and '${CELL_TEHNOLOGY}' == '${cell_type_cli}'
    ...  Log  Cell id and type from WebEM are the same as in cli response![OK]  console=true
    ...  ELSE
    ...  Fail  Cell id and type from WebEM are not the same as in cli response![NOK]


Set A Random Cell Id For A Specific Tehnology
    Run Keyword If  '${CELL_TEHNOLOGY}' == 'NR'
    ...  Set A Random Cell Id  NRCEL
    ...  ELSE IF  '${CELL_TEHNOLOGY}' == 'LTE'
    ...  Set A Random Cell Id  LNCEL
    ...  ELSE
    ...  Fail  Only NR or LTE cells support RF Diagnostic Test![NOK]


Set A Random Cell Id
    [Arguments]  ${tehnology}
    ${cells_id}  Get Ids For All  ${tehnology}
    ${length}  Get Length  ${cells_id}
    ${cell}  Run Keyword If  ${length}>1
    ...  Evaluate  random.choice(${cells_id})  random
    ...  ELSE
    ...  Set Variable  ${cells_id}[0]
    ${cell_id}  Run Keyword If  '${tehnology}' == 'NRCEL'
    ...  Fetch From Right  ${cell}  CELL_R-
    ...  ELSE
    ...  Fetch From Right  ${cell}  CEL_R-
    Set Test Variable  ${CELL_ID}


TC Setup
    Common Test Setup
    Change ActCli Parameter  true


TC Teardown
    Change ActCli Parameter  false
    Common Test Teardown
