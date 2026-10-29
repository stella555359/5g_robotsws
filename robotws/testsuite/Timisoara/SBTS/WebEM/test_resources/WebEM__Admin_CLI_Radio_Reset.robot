*** Settings ***
Documentation
    ...  This test case performes RMODs reset via ADMIN CLI.
    ...  Verify all cells on SBTS to be enabled.
    ...  actCli parameter is changed to be true.
    ...  Taking ids from all RMODs.
    ...  Reset RMODs via ADMIN CLI.
    ...  Verify for command to be sent with status completed.
    ...  Verify all cells on SBTS to be enabled.

Resource  ../../common_resources/ca_WebEM_general.robot


*** Variables ***
${RECOVERY_TIMEOUT}  1200  # Time for SBTS to recovery.
${RESETTYPE}  Hard  # resetType parameter has two possible values: "Soft" and "Hard", by default is set to "Hard".


*** Keywords ***
TC__WebEM__Admin_CLI_Radio_Reset
    [Documentation]
    ...  [CASE LINK]: https://jira3.ext.net.nokia.com/browse/TAT-21620
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 20.07.2021 - https://jira3.int.net.nokia.com/browse/TAT-21620 - Initial TAT creation
    ...  - 25.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24131 - Refactor TCs with best practice
    ...  - 15.12.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24316 - Refactor WebEM TCs and resources to use KWs from ca_SBTS_general

    Set Tags  CA-WebEM  OWNER-nicolae-marcel.caragel@nokia.com  AUTHOR-andreea.burtic@nokia.com  MAINTAINER-andreea.burtic@nokia.com
    ...  GROUP_IN_CHARGE-TIM_3_Vrf  PHASE-CRT  SW-SBTS22

    Step1: Verify Cells On SBTS
    Step2: Change ActCli Parameter To Be true
    Step3: Reset All RMODs Via ADMIN CLI
    Step4: Change ActCli Parameter To Be false


Step1: Verify Cells On SBTS
    Log  Step1: Verify cells on SBTS  console=true
    ${status}  Run Keyword And Return Status
    ...  Check All Cells From WebEM
    Run Keyword If  ${status}
    ...  Log  SBTS is OnAir![OK]  console=true
    ...  ELSE
    ...  Fail  Not all cells are Enabled![NOK]


Step${id}: Change ActCli Parameter To Be ${value}
    Log  Step${id}: Change actCli parameter to be ${value}  console=true
    Change ActCli Parameter  ${value}


Step3: Reset All RMODs Via ADMIN CLI
    Log  Step3: Reset all RMODs via ADMIN CLI  console=true
    Setup Admin CLI  ${ACTIVE_SW_VERSION}  ${MPLANE_IP}
    ${rmods_id}  Get All RMODs Ids
    FOR  ${id}  IN  @{rmods_id}
        ${request}  Catenate  SEPARATOR=  {"requestId":100,"parameters":{"name":"unitReset","parameters":
        ...  {"id":"/MRBTS-${BTS_ID}/EQM_R-1/APEQM_R-1/RMOD_R-${id}","resetType":"${RESETTYPE}"}}}
        Log  \nSending command via Admin CLI for RMOD_R-${id}...  console=true
        ${request_status}  ${error_code}  ${request_message}  Admin CLI Send Request  ${request}
        Run Keyword If  '${request_status}' == 'completed'
        ...  Log  Command sent with status: ${request_status}  console=true
        ...  ELSE
        ...  Fail  Command sent with status: ${request_status} and error code: ${error_code}
        Log  Wait for all cells to be enabled...  console=true
        ${status}  Run Keyword And Return Status
        ...  Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10
        ...  Check All Cells
        Run Keyword If  ${status}
        ...  Log  All cells are Enabled![OK]  console=true
        ...  ELSE
        ...  Fail  Not all cells are Enabled![NOK]
    END


TC Setup
    Common Test Setup
    WebEM Setup


TC Teardown
    WebEM Teardown
    Common Test Teardown
