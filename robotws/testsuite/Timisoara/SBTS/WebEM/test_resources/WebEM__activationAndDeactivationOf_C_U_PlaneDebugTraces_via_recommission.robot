*** Settings ***
Documentation
    ...  This test case is transferred from BOAM_ET to ST_OAM_WebEM.
    ...  This test activating and deactivating actInternalTrace parameter via ADMIN CLI.
    ...  actCli parameter is changed to be true.
    ...  Command for activating actInternalTrace parameter via ADMIN CLI is performed.
    ...  Verify for command to be sent with status completed.
    ...  Command for deactivating actInternalTrace parameter via ADMIN CLI is performed.
    ...  Verify for command to be sent with status completed.
    ...  Command for activating actInternalTrace parameter using json file via ADMIN CLI is performed.
    ...  Verify for command to be sent with status completed and error code 0.

Resource  ../../common_resources/ca_WebEM_general.robot


*** Variables ***
${JSON_WITH_PARAMETER_true}  ${EMPTY}  # Mandatory path to JSON file with actInternalTrace parameter on true.


*** Keywords ***
TC__WebEM__activationAndDeactivationOf_C_U_PlaneDebugTraces_via_recommission
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-24244
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 16.12.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24244 - Initial TAT creation
    ...  - 10.05.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25214 - JSON path was changed

    Set Tags  CA-WebEM  OWNER-cristina.antoci@nokia.com  AUTHOR-andreea.burtic@nokia.com  MAINTAINER-andreea.burtic@nokia.com
    ...  GROUP_IN_CHARGE-TIM_3_Vrf  PHASE-CRT  SW-SBTS23

    Step1: Change ActCli Parameter To Be true
    Step2: Activation Recommission Parameter To Be True Via ADMIN CLI
    Step3: Activation Recommission Parameter To Be False Via ADMIN CLI
    Step4: Activation Recommission File Via ADMIN CLI
    Step5: Change ActCli Parameter To Be false


Step${id}: Change ActCli Parameter To Be ${value}
    Log  \nStep${id}: Change actCli parameter to be ${value}  console=true
    Change ActCli Parameter  ${value}


Step2: Activation Recommission Parameter To Be True Via ADMIN CLI
    Log  \nStep2: Activation Recommission Parameter to be true via ADMIN CLI  console=true
    Setup Admin CLI  ${ACTIVE_SW_VERSION}  ${MPLANE_IP}
    ${request}  Catenate  SEPARATOR=  {"requestId":1,"parameters":{"name":"recommission","parameters":{"planObjects":
    ...  [{"distName":"MRBTS-${BTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1","operation":"update","parameters":[{"parameterName"
    ...  :"actInternalTrace","value":"true","operation":"update"}]}],"skipParameterRelationErrors":true,  "shouldBeActivated":true}}}
    Log  Sending command via Admin CLI for activation actInternalTrace parameter...  console=true
    ${request_status}  ${error_code}  ${request_message}  Admin CLI Send Request  ${request}
    Run Keyword If  '${request_status}' == 'completed'
    ...  Log  Command sent with status: ${request_status} and error code: ${error_code}  console=true
    ...  ELSE
    ...  Fail  Command sent with status: ${request_status} and error code: ${error_code}


Step3: Activation Recommission Parameter To Be False Via ADMIN CLI
    Log  \nStep3: Activation Recommission Parameter to be false via ADMIN CLI  console=true
    ${request}  Catenate  SEPARATOR=  {"requestId":1,"parameters":{"name":"recommission","parameters":{"planObjects":
    ...  [{"distName":"MRBTS-${BTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1","operation":"update","parameters":[{"parameterName"
    ...  :"actInternalTrace","value":"false","operation":"update"}]}],"skipParameterRelationErrors":true,  "shouldBeActivated":true}}}
    Log  Sending command via Admin CLI for deactivation actInternalTrace parameter...  console=true
    ${request_status}  ${error_code}  ${request_message}  Admin CLI Send Request  ${request}
    Run Keyword If  '${request_status}' == 'completed'
    ...  Log  Command sent with status: ${request_status} and error code: ${error_code}  console=true
    ...  ELSE
    ...  Fail  Command sent with status: ${request_status} and error code: ${error_code}


Step4: Activation Recommission File Via ADMIN CLI
    Log  \nStep4: Activation Recommission File via ADMIN CLI  console=true
    ${status_json}  Run Keyword And Return Status
    ...  Should Not Be Empty  ${JSON_WITH_PARAMETER_true}
    Run Keyword If  ${status_json}
    ...  Log  Path to JSON is provided, test should continue![OK]  console=true
    ...  ELSE
    ...  Fail  Please provide path to JSON![NOK]
    ${request}  Catenate  SEPARATOR=  {"requestId":1,"parameters":{"name":"recommission", "parameters": {"
    ...  skipParameterRelationErrors":true,"shouldBeActivated": false}}}
    Log  Sending command via Admin CLI for activation actInternalTrace parameter via json file...  console=true
    ${request_status}  ${error_code}  ${request_message}  Admin CLI Send Request  ${request}  input_file=${JSON_WITH_PARAMETER_true}
    Run Keyword If  '${request_status}' == 'completed' and ${error_code} == 0
    ...  Log  Command sent with status: ${request_status} and error code: ${error_code}  console=true
    ...  ELSE
    ...  Fail  Command sent with status: ${request_status} and error code: ${error_code}


TC Setup
    Common Test Setup


TC Teardown
    Common Test Teardown
