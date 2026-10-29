*** Settings ***
Resource    ../../common_resources/ca_WebEM_general.robot


*** Keywords ***
TC__WebEM__Remote_Tool_checkClock_Linux_remote
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-24454
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  This test case is transferred from BOAM_ET to ST_OAM_WebEM.
    ...  This test case is checking clock via ADMIN CLI.
    ...  actCli parameter is changed to be true.
    ...  Check clock command is sending via ADMIN CLI.
    ...  Verify command to be sent with status completed and error code 0.
    ...  actCli parameter is changed to be false.
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 11.01.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24454 - Initial TAT creation

    Set Tags    CA-WebEM    OWNER-cristina.antoci@nokia.com     AUTHOR-andrada-lavinia.baleti@nokia.com
    ...    MAINTAINER-andrada-lavinia.baleti@nokia.com    GROUP_IN_CHARGE-TIM_3_Vrf    PHASE-CRT    SW-SBTS23

    Step1: Change actCli parameter to be true
    Step2: Check clock via ADMIN CLI
    Step3: Change actCli parameter to be false


Step${id}: Change actCli parameter to be ${value}
    Log  \nStep${id}: Change actCli parameter to be ${value}  console=true
    Change actCli parameter  ${value}

Step2: Check clock via ADMIN CLI
    Log  \nStep2: Check clock via ADMIN CLI  console=true
    Setup Admin CLI  ${active SW version}  ${MPLANE_IP}  ${ADMIN_CLI_KEY}
    ${request}  Set Variable  {"requestId":1,"parameters":{"name":"checkClock"}}
    Log  Sending command via Admin CLI...  console=true
    ${requestStatus}  ${errorCode}  ${requestMessage}  Admin CLI Send Request  ${request}
    Run Keyword If  '${requestStatus}' == 'completed' and ${errorCode} == 0
    ...  Log  Command sent with status: ${requestStatus} and error code: ${errorCode}  console=true
    ...  ELSE
    ...  Fail  Command sent with status: ${requestStatus} and error code: ${errorCode}
    ${status}  Run keyword and return status  Admin Check All Required State
    Run keyword if  ${status}
    ...  Log  SBTS is OnAir![OK]  console=true
    ...  ELSE
    ...  Fail  Not all cells are Enabled![NOK]


TC Setup
    Common test setup

TC Teardown
    Common test teardown
