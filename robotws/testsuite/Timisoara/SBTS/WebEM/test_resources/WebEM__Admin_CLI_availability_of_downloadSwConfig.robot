*** Settings ***
Documentation
    ...  This test case downloads swconfig via ADMIN CLI R&D.
    ...  actCli parameter is changed to be true.
    ...  actDccSupport parameter is changed to be true.
    ...  Check downloadSwConfig command with output file via ADMIN CLI R&D to be send completed with error code 0.
    ...  Check if swconfig was donwnloaded and not empty.
    ...  Check downloadSwConfig command without output file via ADMIN CLI R&D to be send failed with error code 3.
    ...  actCli parameter is changed to be false.
    ...  actDccSupport parameter is changed to be false.

Resource  ../../common_resources/ca_WebEM_general.robot


*** Variables ***
${PASSWORD_DDC_USER}  nE&e3Q*ptK8  # Password for dcc user used in admin cli setup


*** Keywords ***
TC__WebEM__Admin_CLI_availability_of_downloadSwConfig
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-26592
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 31.10.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26592 - Initial TAT creation

    Set Tags  CA-WebEM  OWNER-mihnea.spineanu@nokia.com  AUTHOR-andreea.burtic@nokia.com  MAINTAINER-andreea.burtic@nokia.com
    ...  GROUP_IN_CHARGE-TIM_3_Vrf  PHASE-CRT  SW-SBTS24  FEATURE-CB010545

    Step1: Change ActCli And ActDccSupport Parameters To Be true
    Step2: Sending Command DownloadSwConfig With Output File Via ADMIN CLI R&D
    Step3: Sending Command DownloadSwConfig Without Output File Via ADMIN CLI R&D
    Step4: Change ActCli And ActDccSupport Parameters To Be false


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


Step2: Sending Command DownloadSwConfig With Output File Via ADMIN CLI R&D
    Log  \nStep2: Sending command downloadSwConfig with output file via ADMIN CLI R&D  console=true
    Setup Admin CLI RAD  ${ACTIVE_SW_VERSION}  ${MPLANE_IP}  dcuser  ${PASSWORD_DDC_USER}  9020
    Log  \nSending command via Admin CLI R&D for downloadSwConfig with output file...  console=true
    ${request}  Set Variable  {"requestId":1,"parameters":{"name":"downloadSwConfig"}}
    ${response}  Send Admin CLI Request RAD  ${request}  output_file=${BTS_FILES}/swconfig.txt
    ${request_status}  Get From Dictionary  ${response}  requestStatus
    ${error_code}  Get From Dictionary  ${response}  errorCode
    ${request_message}  Get From Dictionary  ${response}  requestMessage
    Run Keyword If  '${request_status}' == 'completed' and ${error_code} == 0
    ...  Log  Command sent with status: ${request_status} and error code: ${error_code}! [OK]  console=true
    ...  ELSE
    ...  Fail  Command sent with status: ${request_status} and error code: ${error_code}! [NOK]
    Log  The swconfig was saved in location: ${BTS_FILES}/swconfig.txt!  console=true
    ${swconfig_content}  OperatingSystem.Get File  ${BTS_FILES}/swconfig.txt
    Should Contain  ${swconfig_content}  OBLIGATORY FLAGS  The saved swconfig doesn't contain obligatory flags![NOK]
    Log  The saved swconfig contain obligatory flags![OK]  console=true
    Should Contain  ${swconfig_content}  RECOMMENDED DEBUGS - startup related
    ...  The saved swconfig doesn't contain RECOMMENDED DEBUGS - startup related![NOK]
    Log  The saved swconfig contain RECOMMENDED DEBUGS - startup related![OK]  console=true


Step3: Sending Command DownloadSwConfig Without Output File Via ADMIN CLI R&D
    Log  \nStep3: Sending command downloadSwConfig without output file via ADMIN CLI R&D  console=true
    Setup Admin CLI RAD  ${ACTIVE_SW_VERSION}  ${MPLANE_IP}  dcuser  ${PASSWORD_DDC_USER}  9020
    Log  \nSending command via Admin CLI R&D for downloadSwConfig without output file...  console=true
    ${response}  Send Admin CLI Request RAD  {"requestId":1,"parameters":{"name":"downloadSwConfig"}}
    ${request_status}  Get From Dictionary  ${response}  requestStatus
    ${error_code}  Get From Dictionary  ${response}  errorCode
    ${request_message}  Get From Dictionary  ${response}  requestMessage
    Run Keyword If  '${request_status}' == 'failed' and ${error_code} == 3
    ...  Log  Command sent with status: ${request_status} and error code: ${error_code}! [OK]  console=true
    ...  ELSE
    ...  Fail  Command sent with status: ${request_status} and error code: ${error_code}! [NOK]


TC Setup
    Common Test Setup


TC Teardown
    Common Test Teardown
