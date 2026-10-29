*** Settings ***
Resource    ../../common_resources/ca_WebEM_general.robot

*** Variables ***
${RESTORE_TIMEOUT}    20    #Time needed to restore SBTS after power reset, default value 20 min.

*** Keywords ***
TC__WebEM__Admin_CLI_Power_reset_with_additional_timeout
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-24581
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  This test case is transferred from BOAM_ET to ST_OAM_KPI.
    ...  This test case is performing power reset operation.
    ...
    ...  actCli parameter is changed to be true.
    ...  TC is sending power reset command via ADMIN CLI.
    ...  This command has additional timeout and its status should be failed with error code 8.
    ...  TC is waiting for SBTS to reach onAir state after power reset procedure.
    ...  actCli parameter is changed to be false.
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 26.01.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24581 - Initial TAT creation
    ...  - 19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Add watchdog alarm monitoring

    Set Tags    CA-KPI    OWNER-oana.badea@nokia.com     AUTHOR-andrada-lavinia.baleti@nokia.com
    ...    MAINTAINER-andrada-lavinia.baleti@nokia.com    GROUP_IN_CHARGE-TIM_1_Vrf    PHASE-CRT    SW-SBTS23
    ...    FEATURE-CB007040

    Step1: Change actCli parameter to be true
    Step2: Send power reset command via ADMIN CLI
    Step3: Change actCli parameter to be false


Step${id}: Change actCli parameter to be ${value}
    Log  \nStep${id}: Change actCli parameter to be ${value}  console=true
    Change actCli parameter  ${value}

Step2: Send power reset command via ADMIN CLI
    Log  \nStep2: Send power reset command via ADMIN CLI  console=true
    Setup Admin CLI  ${active SW version}  ${MPLANE_IP}  ${ADMIN_CLI_KEY}
    ${request}  Set Variable  {"requestId":1,"parameters":{"name":"powerReset","parameters":{"resetWithSnapshot ":false, "timeout":120000}}}
    Log  Sending command via Admin CLI...  console=true
    ${requestStatus}  ${errorCode}  ${requestMessage}  Admin CLI Send Request  ${request}
    Run Keyword If  '${requestStatus}' == 'failed' and ${errorCode} == 8
    ...  Log  Command sent with status: ${requestStatus} and error code: ${errorCode}. [OK]  console=true
    ...  ELSE
    ...  Fail  Command sent with status: ${requestStatus} and error code: ${errorCode}. [NOK]
    Log  Request message from ADMIN CLI: ${requestMessage}.  console=true
    Log  TC will wait until SBTS is reaching onAir state.  console=true
    ${status}  Run keyword and return status  Wait Until Keyword Succeeds  ${RESTORE_TIMEOUT} min  15s  Admin Check All Required State
    Run keyword if  ${status}
    ...  Log  All cells are onAir. [OK]  console=true
    ...  ELSE
    ...  Fail  Not all cells are onAir. [NOK]


TC Setup
    Common test setup  tc_name=WebEM__Admin_CLI_Power_reset_with_additional_timeout

TC Teardown
    Common test teardown
