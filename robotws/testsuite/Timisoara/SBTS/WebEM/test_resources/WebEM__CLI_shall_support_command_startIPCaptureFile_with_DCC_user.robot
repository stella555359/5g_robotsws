*** Settings ***
Documentation
    ...  This TC execute command with DCC account.
    ...  Change parameter actCli to be true.
    ...  Change parameter actDccSupport to be true.
    ...  Check startIPCaptureFile command via ADMIN CLI to be send with error code 0.
    ...  Check stopIPCaptureFile command via ADMIN CLI to be send with error code 0.
    ...  Change parameter actCli to be false.
    ...  Change parameter actDccSupport to be false.

Resource  ../../common_resources/ca_WebEM_general.robot


*** Keywords ***
TC__WebEM__CLI_shall_support_command_startIPCaptureFile_with_DCC_user
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-24479
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 30.05.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24479 - Initial TAT creation
    ...  - 24.10.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26235 - Update due to PR730089

    Set Tags  CA-WebEM  OWNER-cristina.antoci@nokia.com  AUTHOR-andreea.burtic@nokia.com  MAINTAINER-andreea.burtic@nokia.com
    ...  GROUP_IN_CHARGE-TIM_3_Vrf  PHASE-CRT  SW-SBTS23  FEATURE-CB006577

    Step1: Change ActCli And ActDccSupport To Be true
    Step2: Sending StartIPCaptureFile Command Via ADMIN CLI
    Step3: Change ActCli And ActDccSupport To Be false


Step${index}: Change ActCli And ActDccSupport To Be ${value}
    Log  \nStep${index}: Change actCli and actDccSupport to be ${value}  console=true
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


Step2: Sending StartIPCaptureFile Command Via ADMIN CLI
    Log  \nStep2: Sending startIPCaptureFile command via ADMIN CLI  console=true
    Setup Admin CLI  ${ACTIVE_SW_VERSION}  ${MPLANE_IP}  dcuser  nE&e3Q*ptK8  9020
    ${new_request}  Catenate  SEPARATOR=  {"requestId":1,"parameters":{"name":"startIPCaptureFile","parameters":
    ...  {"measurementPoint":"NE_Terminated","uplaneCapturing":true}}}
    ${old_request}  Catenate  SEPARATOR=  {"requestId":1,"parameters":{"name":"startIPCaptureFile","parameters":
    ...  {"measurementPoint":"NE_Terminated","password":"12345678","uplaneCapturing":true}}}
    Log  \nSending command via Admin CLI for startIPCaptureFile in data collection user...  console=true
    ${release}  Fetch From Left  ${ACTIVE_SW_VERSION}  _
    ${request_status}  ${error_code}  ${request_message}  Run Keyword If  '${release}'>='SBTS24R1'
    ...  Admin CLI Send Request  ${new_request}
    ...  ELSE
    ...  Admin CLI Send Request  ${old_request}
    Run Keyword If  '${request_status}' == 'completed' and ${error_code} == 0
    ...  Log  Command startIPCaptureFile sent with status: ${request_status} and error code: ${error_code}  console=true
    ...  ELSE
    ...  Fail  Command startIPCaptureFile sent with status: ${request_status} and error code: ${error_code}
    Sleep  30s  This sleep is for the connection to end.
    Log  \nSending command via Admin CLI for stopIPCaptureFile in data collection user...  console=true
    ${request_status}  ${error_code}  ${request_message}  Admin CLI Send Request  {"requestId":1,"parameters":{"name":"stopIPCaptureFile"}}
    Run Keyword If  '${request_status}' == 'completed' and ${error_code} == 0
    ...  Log  Command stopIPCaptureFile sent with status: ${request_status} and error code: ${error_code}  console=true
    ...  ELSE
    ...  Fail  Command stopIPCaptureFile sent with status: ${request_status} and error code: ${error_code}
    Check All Cells


TC Setup
    Common Test Setup  tc_name=WebEM__CLI_shall_support_command_startIPCaptureFile


TC Teardown
    Common Test Teardown
