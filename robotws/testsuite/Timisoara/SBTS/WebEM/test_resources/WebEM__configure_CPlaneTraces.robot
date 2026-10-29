*** Settings ***
Documentation
    ...  This test case is transferred from BOAM_ET to ST_OAM_WebEM.
    ...  This test case configure CPlane Traces via ADMIN CLI.
    ...  actCli parameter is changed to be true.
    ...  actInternalTrace parameter is changed to be true.
    ...  Configure CPlane Traces command via ADMIN CLI is performed.
    ...  Verify for command to be sent with status completed, request message succeeded and error code 0.
    ...  actCli parameter is changed to be false.

Resource  ../../common_resources/ca_WebEM_general.robot


*** Keywords ***
TC__WebEM__configure_CPlaneTraces
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-24242
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 12.12.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24242 - Initial TAT creation
    ...  - 15.12.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24316 - Refactor WebEM TCs and resources to use KWs from ca_SBTS_general

    Set Tags  CA-WebEM  OWNER-cristina.antoci@nokia.com  AUTHOR-andreea.burtic@nokia.com  MAINTAINER-andreea.burtic@nokia.com
    ...  GROUP_IN_CHARGE-TIM_3_Vrf  PHASE-CRT  SW-SBTS23

    Step1: Change ActCli Parameter To Be true
    Step2: Configure CPlace Traces Via ADMIN CLI
    Step3: Change ActCli Parameter To Be false


Step${id}: Change ActCli Parameter To Be ${value}
    Log  \nStep${id}: Change actCli parameter to be ${value}  console=true
    Change ActCli Parameter  ${value}


Step2: Configure CPlace Traces Via ADMIN CLI
    Log  \nStep2: Configure CPlace Traces via ADMIN CLI  console=true
    ${status}  Run Keyword And Return Status
    ...  Perform Parameter Recommissioning  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
    ...  actInternalTrace
    ...  update
    ...  true
    ...  skip_parameter_relation_errors=true
    Run Keyword If  ${status}
    ...  Log  Parameter actInternalTrace is set to true![OK]  console=true
    ...  ELSE
    ...  Fail  Parameter actInternalTrace is not set to true![NOK]
    Setup Admin CLI  ${ACTIVE_SW_VERSION}  ${MPLANE_IP}
    ${request}  Set Variable  {"requestId":1,"parameters":{"name":"configureCPlaneTraces","parameters":{"configurationParameters":{"dscp":0}}}}
    Log  Sending command via Admin CLI for configureCPlaneTraces...  console=true
    ${request_status}  ${error_code}  ${request_message}  Admin CLI Send Request  ${request}
    Run Keyword If  '${request_status}' == 'completed' and '${request_message}' == 'Succeeded' and ${error_code} == 0
    ...  Log  Command sent with status: ${request_status}, message: ${request_message} and error code: ${error_code}  console=true
    ...  ELSE
    ...  Fail  Command sent with status: ${request_status}, message: ${request_message} and error code: ${error_code}
    ${status}  Run Keyword And Return Status
    ...  Check All Cells
    Run Keyword If  ${status}
    ...  Log  SBTS is OnAir![OK]  console=true
    ...  ELSE
    ...  Fail  Not all cells are Enabled![NOK]


TC Setup
    Common Test Setup
    WebEM Setup


TC Teardown
    WebEM Teardown
    Common Test Teardown
