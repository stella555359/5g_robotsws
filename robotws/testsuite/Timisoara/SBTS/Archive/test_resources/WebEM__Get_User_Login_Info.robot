*** Settings ***
Resource    ../../common_resources/ca_WebEM_general.robot


*** Keywords ***
TC__WebEM__Get_User_Login_Info
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-24239
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  This test case is transferred from BOAM_ET to ST_OAM_WebEM.
    ...  This test case gets user login info via ADMIN CLI.
    ...  actCli parameter is changed to be true.
    ...  Get user login info command via ADMIN CLI is performed.
    ...  Verify for command to be sent with status completed and error code 0.
    ...  actCli parameter is changed to be false.
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 09.12.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24239 - Initial TAT creation
    ...  - 15.12.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24316 - Refactor WebEM TCs and resources to use KWs from ca_SBTS_general

    Set Tags    CA-WebEM    OWNER-cristina.antoci@nokia.com     AUTHOR-andreea.burtic@nokia.com
    ...    MAINTAINER-andreea.burtic@nokia.com    GROUP_IN_CHARGE-TIM_3_Vrf    PHASE-CRT    SW-SBTS23

    Step1: Change actCli parameter to be true
    Step2: Get user login info via ADMIN CLI
    Step3: Change actCli parameter to be false


Step${id}: Change actCli parameter to be ${value}
    Log  \nStep${id}: Change actCli parameter to be ${value}  console=true
    Change actCli parameter  ${value}

Step2: Get user login info via ADMIN CLI
    Log  \nStep2: Get user login info via ADMIN CLI  console=true
    Setup Admin CLI  ${active SW version}  ${MPLANE_IP}  ${ADMIN_CLI_KEY}
    ${request}  Set Variable  {"requestId":1,"parameters":{"name":"getUserLoginInfo"}}
    Log  Sending command via Admin CLI for getUserLoginInfo...  console=true
    ${requestStatus}  ${errorCode}  ${requestMessage}  Admin CLI Send Request  ${request}
    Run Keyword If  '${requestStatus}' == 'completed' and ${errorCode} == 0
    ...  Log  Command sent with status: ${requestStatus} and error code: ${errorCode}  console=true
    ...  ELSE
    ...  Fail  Command sent with status: ${requestStatus} and error code: ${errorCode}
    Log  User login info from ADMIN CLI: ${requestMessage}  console=true
    ${status}  Run keyword and return status  Check all cells from WebEM
    Run keyword if  ${status}
    ...  Log  SBTS is OnAir![OK]  console=true
    ...  ELSE
    ...  Fail  Not all cells are Enabled![NOK]


TC Setup
    Common test setup
    WebEM Setup

TC Teardown
    WebEM Teardown
    Common test teardown


