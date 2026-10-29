*** Settings ***
Resource    ../../../../../../Wroclaw/OAM/RAN_PZ_WRO3_SG01/resources/common.robot
Resource    ../../../../../../Wroclaw/OAM/RAN_PZ_WRO3_SG01/resources/alarms.robot
Resource    ../../../../../../Wroclaw/OAM/RAN_PZ_WRO3_SG01/resources/ald.robot
Resource    ../../../../../../Wroclaw/OAM/RAN_PZ_WRO3_SG01/resources/cli.robot
Resource    ../../../../../../Wroclaw/OAM/RAN_PZ_WRO3_SG01/resources/power_saving.robot

Documentation
...  TEST NAME:     CLI.02_Admin_CLI_setTiltAngle
...  AUTHORS:       tomasz.marchewka@nokia.com
...  MAINTAINER:    RAN_PZ_WRO_3_SG01
...  *****************
...  Basic information
...  *****************
...  The purpose of this test case is check if setTiltAngle command via Admin command line is working.
...  The setTiltAngle request allows you to adjust the tilt of the antenna using remote electrical tilt (RET).
...  *****************
...  Pre-conditions
...  *****************
...  N/A
...  ******************
...  History of changes
...  *****************
...  03.08.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-235 - Test case creation
...  15.08.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-252 - Add angle verification
...  06.09.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-261 - Add recovery action
...  *******************
...  RAN PZ3 WRO1 TEMPLATE

*** Variables ***


*** Keywords ***
CLI.02_Admin_CLI_setTiltAngle

    CLI.02_Admin_CLI_setTiltAngle.Test_Step.0 Check If RETs Are In Configuration
    CLI.02_Admin_CLI_setTiltAngle.Test_Step.1 Enable CLI Feature And Select New Angle
    CLI.02_Admin_CLI_setTiltAngle.Test_Step.2 Sending Tilt Angle For Selected RET Via CLI
    CLI.02_Admin_CLI_setTiltAngle.Test_Step.3 Check ALDs State
    CLI.02_Admin_CLI_setTiltAngle.Test_Step.4 Verifying Tilt Angle

CLI.02_Admin_CLI_setTiltAngle.Test_Step.0 Check If RETs Are In Configuration
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

CLI.02_Admin_CLI_setTiltAngle.Test_Step.1 Enable CLI Feature And Select New Angle
    [Documentation]
    ...    1.Check if parameter actCli is set as "true", if not then change it to "true".
    ...    2.Select random RET.
    ...    3.Select new angle.
    Log to console    \n========================================
    Log  Step: 1 Enable CLI Feature And Select New Angle  console=${True}
    Log to console    ========================================
    Set Feature On Expected Value  parameter=actCli  value=true
    ${chosen_RET}=  Select Random RET  ${ALD_R_RETs}
    ${my_ret_param}=  Get RETU Parameters  ${chosen_RET}
    ${ret_angle}  ${ret_maxAngle}  ${ret_minAngle}  ${ret_mechAngle}  Get RETU Angles  ${my_ret_param}
    ${new_angle}  ${new_mechAngle}  Generate New Valid Angle And MechanicalAngle  ${ret_angle}  ${ret_maxAngle}  ${ret_minAngle}  ${ret_mechAngle}
    ${ALD_R_to_ALD_A}=  Mapping ALD_R To ALD_A
    ${ALD_A}=  Get From Dictionary  ${ALD_R_to_ALD_A}  ${chosen_RET}
    ${ignore}  ${ALD_A}=  Split String From Right  ${ALD_A}  separator=SCF-1/
    ${ALD_A}=  Replace String  ${ALD_A}  search_for=_A  replace_with=
    Log  For ${ALD_A}: \nCurrent angle: ${ret_angle}°, \nNew angle: ${new_angle}°.  console=${True}
    Set Test Variable  ${new_angle}
    Set Test Variable  ${ALD_A}
    Set Test Variable  ${chosen_RET}

CLI.02_Admin_CLI_setTiltAngle.Test_Step.2 Sending Tilt Angle For Selected RET Via CLI
    [Documentation]  This keyword send setTiltAngle command for selected RET unit.
    Log to console    \n========================================
    Log  Step: 2 Sending Tilt Angle For Selected RET Via CLI  console=${True}
    Log to console    ========================================
    Collect And Setup ADMIN CLI
    ${command_cli}=  Set Variable  {"requestId":321,"parameters":{"name":"setTiltAngle","parameters":{"id":"${ALD_A}/RETU-1","angle":${new_angle}}}}
    ${requestStatus}  ${error_code}  CLI Send Request And Return Status And Error Code  ${command_cli}
    Run Keyword If  '${requestStatus}' != 'completed'
    ...  Fail  msg=Command sent with status: ${requestStatus}
    ...  ELSE   Log   Command sent with status: ${requestStatus}  console=${True}
    Sleep  10s

CLI.02_Admin_CLI_setTiltAngle.Test_Step.3 Check ALDs State
    [Documentation]  Check if all ALDs achieve expected state: administrativeState=unlocked, operationalState=enabled.
    Log to console    \n========================================
    Log  Step: 3 Check ALDs State  console=${True}
    Log to console    ========================================
    Check ALDs State  ${ALD_expected_states}

CLI.02_Admin_CLI_setTiltAngle.Test_Step.4 Verifying Tilt Angle
    [Documentation]  Check if RETU angle is properly changed.
    Log to console    \n========================================
    Log  Step: 3 Verifying Tilt Angle  console=${True}
    Log to console    ========================================
    ${ret_param}=  Get RETU Parameters  ${chosen_RET}
    ${read_ret_angle}  ${read_ret_maxAngle}  ${read_ret_minAngle}  ${read_ret_mechanicalAngle}  Get RETU Angles  ${ret_param}
    ${new_angle}=  Convert To Number  ${new_angle}
    ${read_ret_angle}=  Convert To Number  ${read_ret_angle}
    ${status}=  Run Keyword And Return Status  Should Be Equal As Numbers  ${read_ret_angle}  ${new_angle}
    Run Keyword If  ${status}  Log  RETU angle is correctly changed  console=${True}
    ...  ELSE  Fail  msg=RETU angle is not changed ${read_ret_angle}!=${new_angle}

CLI.02_Admin_CLI_setTiltAngle.Test Specific Teardown
    [Documentation]  Recovery action for ALDs if fault 1806, 1842, 1844, 1871 or 1874 is visible.
    admin.setup admin  admin_api_log_dir=${RESULTS}/admin_api/  alias=${ute_admin_alias}
    ${if_exist_1806}=  Run Keyword And Return Status  admin.assert alarm active  faultId=1806
    ${if_exist_1842}=  Run Keyword And Return Status  admin.assert alarm active  faultId=1842
    ${if_exist_1844}=  Run Keyword And Return Status  admin.assert alarm active  faultId=1844
    ${if_exist_1871}=  Run Keyword And Return Status  admin.assert alarm active  faultId=1871
    ${if_exist_1874}=  Run Keyword And Return Status  admin.assert alarm active  faultId=1874
    ${faultId}=  Set Variable If
    ...  '${if_exist_1806}'=='${True}'  1806
    ...  '${if_exist_1842}'=='${True}'  1842
    ...  '${if_exist_1844}'=='${True}'  1844
    ...  '${if_exist_1871}'=='${True}'  1871
    ...  '${if_exist_1874}'=='${True}'  1874
    Run Keyword If  ${if_exist_1806} or ${if_exist_1842} or ${if_exist_1844} or ${if_exist_1871} or ${if_exist_1874}  ALD Recovery Action  ${faultId}
    admin.teardown admin  alias=${ute_admin_alias}

CLI.02_Admin_CLI_setTiltAngle.Test Case Teardown
    [Arguments]  ${SEND_SNAPSHOT_FOR_SCRAMBLING}=${False}
    Run Keyword  common.Common Test Teardown  ${SEND_SNAPSHOT_FOR_SCRAMBLING}
    Run Keyword If Test Failed  CLI.02_Admin_CLI_setTiltAngle.Test Specific Teardown
