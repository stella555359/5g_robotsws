*** Settings ***
Resource    ../../../../../../Wroclaw/OAM/RAN_PZ_WRO3_SG01/resources/common.robot
Resource    ../../../../../../Wroclaw/OAM/RAN_PZ_WRO3_SG01/resources/alarms.robot
Resource    ../../../../../../Wroclaw/OAM/RAN_PZ_WRO3_SG01/resources/ald.robot
Resource    ../../../../../../Wroclaw/OAM/RAN_PZ_WRO3_SG01/resources/cli.robot
Resource    ../../../../../../Wroclaw/OAM/RAN_PZ_WRO3_SG01/resources/power_saving.robot

Documentation
...  TEST NAME:     CLI.04_Admin_CLI_getRETById
...  AUTHORS:       tomasz.marchewka@nokia.com
...  MAINTAINER:    RAN_PZ_WRO_3_SG01
...  *****************
...  Basic information
...  *****************
...  The purpose of this test case is check if getRETById command via Admin command line is working.
...  The getRETById request returns the remote electrical tilt (RET) information.
...  *****************
...  Pre-conditions
...  *****************
...  N/A
...  ******************
...  History of changes
...  *****************
...  09.08.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-239 - Test case creation
...  *******************
...  RAN PZ3 WRO1 TEMPLATE

*** Variables ***


*** Keywords ***
CLI.04_Admin_CLI_getRETById

    CLI.04_Admin_CLI_getRETById.Test_Step.0 Check If RETs Are In Configuration
    CLI.04_Admin_CLI_getRETById.Test_Step.1 Enable CLI Feature
    CLI.04_Admin_CLI_getRETById.Test_Step.2 Sending RET Unit Information Request For Selected RET Via CLI
    CLI.04_Admin_CLI_getRETById.Test_Step.3 Check ALDs State

CLI.04_Admin_CLI_getRETById.Test_Step.0 Check If RETs Are In Configuration
    [Documentation]  Test step which checking if RETs are in configuration.
    Log to console    \n========================================
    Log  Step: 0 Test Preparation  console=${True}
    Log to console    ========================================
    ${ALD_R_RAEs}  ${ALD_R_MHAs}  ${ALD_R_RETs}
    ...  ${ALD_R_ALL}  ${num_of_RAEs}  ${num_of_MHAs}  ${num_of_RETs}  ${num_of_ALDs}  Sorting ALD_R by type
    Set Test Variable  ${ALD_R_RETs}
    Set Test Variable  ${num_of_RETs}
    Run Keyword If  ${num_of_RETs}==${0}
    ...  Fail  msg=There is no at least one expected RET in configuration
    Log  You have ${num_of_RETs} RETs in configuration  console=${True}

CLI.04_Admin_CLI_getRETById.Test_Step.1 Enable CLI Feature
    [Documentation]
    ...    1.Check if parameter actCli is set as "true", if not then change it to "true".
    ...    2.Select random RET.
    Log to console    \n========================================
    Log  Step: 1 Enable CLI Feature And Select New Angle  console=${True}
    Log to console    ========================================
    Set Feature On Expected Value  parameter=actCli  value=true
    ${chosen_RET}=  Select Random RET  ${ALD_R_RETs}
    ${ALD_R_to_ALD_A}=  Mapping ALD_R To ALD_A
    ${ALD_A}=  Get From Dictionary  ${ALD_R_to_ALD_A}  ${chosen_RET}
    ${ignore}  ${ALD_A}=  Split String From Right  ${ALD_A}  separator=SCF-1/
    ${ALD_A}=  Replace String  ${ALD_A}  search_for=_A  replace_with=
    Log  Ongoing calibration on ${ALD_A}/RETU-1...  console=${True}
    Set Test Variable  ${ALD_A}

CLI.04_Admin_CLI_getRETById.Test_Step.2 Sending RET Unit Information Request For Selected RET Via CLI
    [Documentation]  This keyword send getRETById command for selected RET unit.
    Log to console    \n========================================
    Log  Step: 2 Sending RET Unit Information Request For Selected RET Via CLI  console=${True}
    Log to console    ========================================
    Collect And Setup ADMIN CLI
    ${command_cli}=  Set Variable  {"requestId":321,"parameters":{"name":"getRETById","parameters":{"id":"${ALD_A}/RETU-1"}}}
    ${requestStatus}  ${requestMessage}  CLI Send Request And Return Status And Request Message  ${command_cli}
    Run Keyword If  '${requestStatus}' != 'completed'
    ...  Fail  msg=Command sent with status: ${requestStatus}
    ...  ELSE   Log   Command sent with status: ${requestStatus}  console=${True}

CLI.04_Admin_CLI_getRETById.Test_Step.3 Check ALDs State
    [Documentation]  Check if all ALDs achieve expected state: administrativeState=unlocked, operationalState=enabled.
    Log to console    \n========================================
    Log  Step: 3 Check ALDs State  console=${True}
    Log to console    ========================================
    Check ALDs State  ${ALD_expected_states}

CLI.04_Admin_CLI_getRETById.Test Case Teardown
    [Arguments]  ${SEND_SNAPSHOT_FOR_SCRAMBLING}=${False}
    Run Keyword  common.Common Test Teardown  ${SEND_SNAPSHOT_FOR_SCRAMBLING}
