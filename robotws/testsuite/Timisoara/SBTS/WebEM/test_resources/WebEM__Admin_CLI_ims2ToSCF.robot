*** Settings ***
Documentation
    ...  This test case gets SCF from IMS2 via ADMIN CLI R&D.
    ...  actCli parameter is changed to be true.
    ...  actDccSupport parameter is changed to be true.
    ...  Check ims2ToSCF command with input and output files and export type configurationAndRuntimeObjects
    ...  via ADMIN CLI R&D to be send completed with error code 0.
    ...  Check if scf file is not empty.
    ...  Check ims2ToSCF command with input and output files and export type runtimeObjects
    ...  via ADMIN CLI R&D to be send completed with error code 0.
    ...  Check if scf file is not empty.
    ...  Check ims2ToSCF command with input and output files and export type configuration
    ...  via ADMIN CLI R&D to be send completed with error code 0.
    ...  Check if scf file is not empty.
    ...  Check ims2ToSCF command with wrong input and output files via ADMIN CLI R&D to be send failed with error code 3.
    ...  Check ims2ToSCF command without input file via ADMIN CLI R&D to be send failed with error code 3.
    ...  Check ims2ToSCF command without output file via ADMIN CLI R&D to be send failed with error code 3.
    ...  Check ims2ToSCF command without input and output files via ADMIN CLI R&D to be send failed with error code 3.
    ...  Check ims2ToSCF command with a wrong ims2 via ADMIN CLI R&D to be send failed with error code 7.
    ...  actCli parameter is changed to be false.
    ...  actDccSupport parameter is changed to be false.

Resource  ../../common_resources/ca_WebEM_general.robot


*** Variables ***
${PASSWORD_DDC_USER}  nE&e3Q*ptK8  # Password for dcc user used in admin cli setup


*** Keywords ***
TC__WebEM__Admin_CLI_ims2ToSCF
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-26589
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 12.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26589 - Initial TAT creation

    Set Tags  CA-WebEM  OWNER-mihnea.spineanu@nokia.com  AUTHOR-andreea.burtic@nokia.com  MAINTAINER-andreea.burtic@nokia.com
    ...  GROUP_IN_CHARGE-TIM_3_Vrf  PHASE-CRT  SW-SBTS24  FEATURE-CB010545

    Step1: Change ActCli And ActDccSupport Parameters To Be true
    Step2: Save Ims2
    Step3: Sending Command Ims2ToSCF With Input And Output Files And Export Type configurationAndRuntimeObjects Via ADMIN CLI R&D
    Step4: Sending Command Ims2ToSCF With Input And Output Files And Export Type runtimeObjects Via ADMIN CLI R&D
    Step5: Sending Command Ims2ToSCF With Input And Output Files And Export Type configuration Via ADMIN CLI R&D
    Step6: Sending Command Ims2ToSCF With Wrong Input And Output Files Via ADMIN CLI R&D
    Step7: Sending Command Ims2ToSCF Without Input File Via ADMIN CLI R&D
    Step8: Sending Command Ims2ToSCF Without Output File Via ADMIN CLI R&D
    Step9: Sending Command Ims2ToSCF Without Input And Output Files Via ADMIN CLI R&D
    Step10: Sending Command Ims2ToSCF With A Wrong Ims2 Via ADMIN CLI R&D
    Step11: Change ActCli And ActDccSupport Parameters To Be false


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


Step${index}: Sending Command Ims2ToSCF With Input And Output Files And Export Type ${export_type} Via ADMIN CLI R&D
    Log  \nStep${index}: Sending command ims2ToSCF with input and output files and export type ${export_type} via ADMIN CLI R&D  console=true
    Setup Admin CLI RAD  ${ACTIVE_SW_VERSION}  ${MPLANE_IP}  dcuser  ${PASSWORD_DDC_USER}  9020
    Log  Sending command via Admin CLI R&D for ims2ToSCF with input and output files and export type ${export_type}...  console=true
    Set Test Variable  ${REQUEST}  {"requestId":1,"parameters":{"name":"ims2ToSCF","parameters":{"exportType":"${export_type}"}}}
    ${response}  Send Admin CLI Request RAD  ${REQUEST}  output_file=${BTS_FILES}/scf_from_step${index}.xml  input_file=${IMS_PATH}
    ${request_status}  Get From Dictionary  ${response}  requestStatus
    ${error_code}  Get From Dictionary  ${response}  errorCode
    ${output_file_name}  Get From Dictionary  ${response}  outputFileName
    Run Keyword If  '${request_status}' == 'completed' and ${error_code} == 0 and '${output_file_name}'=='${BTS_FILES}/scf_from_step${index}.xml'
    ...  Log  Command sent with status: ${request_status} and error code: ${error_code}! [OK]  console=true
    ...  ELSE
    ...  Fail  Command sent with status: ${request_status} and error code: ${error_code}! [NOK]
    Log  The scf was saved in location: ${BTS_FILES}/scf_from_step${index}.xml!  console=true
    ${scf_content}  OperatingSystem.Get File  ${BTS_FILES}/scf_from_step${index}.xml
    Should Not Be Empty  ${scf_content}  SCF file is empty![NOK]
    Log  SCF file is not empty![OK]  console=true


Step6: Sending Command Ims2ToSCF With Wrong Input And Output Files Via ADMIN CLI R&D
    Log  \nStep6: Sending command ims2ToSCF with wrong input and output files via ADMIN CLI R&D  console=true
    Setup Admin CLI RAD  ${ACTIVE_SW_VERSION}  ${MPLANE_IP}  dcuser  ${PASSWORD_DDC_USER}  9020
    Log  Sending command via Admin CLI R&D for getHistoricalAndActiveAlarmsFromIMS2 without input file...  console=true
    ${response}  Send Admin CLI Request RAD  ${REQUEST}  output_file=${BTS_FILES}/scf.txt  input_file=${COMMISSIONING_PATH}
    ${request_status}  Get From Dictionary  ${response}  requestStatus
    ${error_code}  Get From Dictionary  ${response}  errorCode
    ${request_message}  Get From Dictionary  ${response}  requestMessage
    ${message}  Set Variable  The output file shall be a xml file
    Run Keyword If  '${request_status}' == 'failed' and ${error_code} == 3 and '${request_message}' == '${message}'
    ...  Log  Command sent with status: ${request_status}, error code: ${error_code} and request message :${request_message}! [OK]  console=true
    ...  ELSE
    ...  Fail  Command sent with status: ${request_status}, error code: ${error_code} and request message :${request_message}! [NOK]


Step7: Sending Command Ims2ToSCF Without Input File Via ADMIN CLI R&D
    Log  \nStep7: Sending command ims2ToSCF without input file via ADMIN CLI R&D  console=true
    Setup Admin CLI RAD  ${ACTIVE_SW_VERSION}  ${MPLANE_IP}  dcuser  ${PASSWORD_DDC_USER}  9020
    Log  Sending command via Admin CLI R&D for ims2ToSCF without input file...  console=true
    ${response}  Send Admin CLI Request RAD  ${REQUEST}  output_file=${BTS_FILES}/scf.xml
    ${request_status}  Get From Dictionary  ${response}  requestStatus
    ${error_code}  Get From Dictionary  ${response}  errorCode
    ${request_message}  Get From Dictionary  ${response}  requestMessage
    ${message}  Set Variable  Invalid schema: Missing required property: inputFileContent
    Run Keyword If  '${request_status}' == 'failed' and ${error_code} == 3 and '${request_message}' == '${message}'
    ...  Log  Command sent with status: ${request_status}, error code: ${error_code} and request message :${request_message}! [OK]  console=true
    ...  ELSE
    ...  Fail  Command sent with status: ${request_status}, error code: ${error_code} and request message :${request_message}! [NOK]


Step8: Sending Command Ims2ToSCF Without Output File Via ADMIN CLI R&D
    Log  \nStep8: Sending command ims2ToSCF without output file via ADMIN CLI R&D  console=true
    Setup Admin CLI RAD  ${ACTIVE_SW_VERSION}  ${MPLANE_IP}  dcuser  ${PASSWORD_DDC_USER}  9020
    Log  Sending command via Admin CLI R&D for ims2ToSCF without output file...  console=true
    ${response}  Send Admin CLI Request RAD  ${REQUEST}  input_file=${IMS_PATH}
    ${request_status}  Get From Dictionary  ${response}  requestStatus
    ${error_code}  Get From Dictionary  ${response}  errorCode
    ${request_message}  Get From Dictionary  ${response}  requestMessage
    ${req}  Set Variable  Invalid schema: /outputFileContent, Format validation failed (This procedure does not support base64 encoded file content)
    Run Keyword If  '${request_status}' == 'failed' and ${error_code} == 3 and '${request_message}' == '${req}'
    ...  Log  Command sent with status: ${request_status}, error code: ${error_code} and request message :${request_message}! [OK]  console=true
    ...  ELSE
    ...  Fail  Command sent with status: ${request_status}, error code: ${error_code} and request message :${request_message}! [NOK]


Step9: Sending Command Ims2ToSCF Without Input And Output Files Via ADMIN CLI R&D
    Log  \nStep9: Sending command ims2ToSCF without input and output files via ADMIN CLI R&D  console=true
    Setup Admin CLI RAD  ${ACTIVE_SW_VERSION}  ${MPLANE_IP}  dcuser  ${PASSWORD_DDC_USER}  9020
    Log  Sending command via Admin CLI R&D for ims2ToSCF without input and output files...  console=true
    ${response}  Send Admin CLI Request RAD  ${REQUEST}
    ${request_status}  Get From Dictionary  ${response}  requestStatus
    ${error_code}  Get From Dictionary  ${response}  errorCode
    ${request_message}  Get From Dictionary  ${response}  requestMessage
    ${message}  Set Variable  Invalid schema: Missing required property: inputFileContent
    Run Keyword If  '${request_status}' == 'failed' and ${error_code} == 3 and '${request_message}' == '${message}'
    ...  Log  Command sent with status: ${request_status}, error code: ${error_code} and request message :${request_message}! [OK]  console=true
    ...  ELSE
    ...  Fail  Command sent with status: ${request_status}, error code: ${error_code} and request message :${request_message}! [NOK]


Step10: Sending Command Ims2ToSCF With A Wrong Ims2 Via ADMIN CLI R&D
    Log  \nStep10: Sending command ims2ToSCF with a wrong ims2 via ADMIN CLI R&D  console=true
    Create File  ${BTS_FILES}/wrong_ims.ims2  Wrong ims for WebEM__Admin_CLI_ims2ToSCF TC!
    Setup Admin CLI RAD  ${ACTIVE_SW_VERSION}  ${MPLANE_IP}  dcuser  ${PASSWORD_DDC_USER}  9020
    Log  Sending command via Admin CLI R&D for ims2ToSCF with a wrong ims2...  console=true
    ${response}  Send Admin CLI Request RAD  ${REQUEST}  output_file=${BTS_FILES}/scf.xml  input_file=${BTS_FILES}/wrong_ims.ims2
    ${request_status}  Get From Dictionary  ${response}  requestStatus
    ${error_code}  Get From Dictionary  ${response}  errorCode
    ${request_message}  Get From Dictionary  ${response}  requestMessage
    ${message}  Set Variable  Parsing ims2 file failed
    Run Keyword If  '${request_status}' == 'failed' and ${error_code} == 7 and '${request_message}' == '${message}'
    ...  Log  Command sent with status: ${request_status}, error code: ${error_code} and request message :${request_message}! [OK]  console=true
    ...  ELSE
    ...  Fail  Command sent with status: ${request_status}, error code: ${error_code} and request message :${request_message}! [NOK]


TC Setup
    Common Test Setup


TC Teardown
    Common Test Teardown
