*** Settings ***
Resource    ../../resources/common.robot
Resource    ../../resources/alarms.robot
Resource    ../../resources/ald.robot
Resource    ../../resources/selenium.robot
Resource    ../../resources/power_saving.robot

Documentation
...  TEST NAME:     ALD.18_ALD_Configure_RET_Antenna_from_runtime_view
...  AUTHORS:       tomasz.marchewka@nokia.com
...  MAINTAINER:    RAN_PZ_WRO_3_SG01
...  *****************
...  Basic information
...  *****************
...  The purpose of this test case is to check if RET can be detected and configured correclty and that tilt angles
...  can be set using WebEM (runtime view).
...  *****************
...  Pre-conditions
...  *****************
...  N/A
...  ******************
...  History of changes
...  *****************
...  18.03.2021 - https://jira3.ext.net.nokia.com/browse/TAT-21070 - adjust KW for Comba RET
...  23.03.2021 - https://jira3.ext.net.nokia.com/browse/TAT-21076 - adjust KW for dual core configurations
...  14.05.2021 - https://jira3.ext.net.nokia.com/browse/TAT-21293 - added Chrome driver validator
...  19.05.2021 - https://jira3.ext.net.nokia.com/browse/TAT-21336
...  19.10.2021 - https://jiradc.ext.net.nokia.com/browse/TAW-13 - Adaptation to CNI-61110
...  06.12.2021 - https://jiradc.ext.net.nokia.com/browse/TAW-36 - Switch to hran_frame_sbts_siso resource
...  01.04.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-124 - Change sleep from 10 to 20 in step1
...  20.04.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-154 - Adaptation to CNI-82119 and migration from hran_ta to robotlte repository
...  12.08.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-249 - Add Test Specific Teardown
...  *******************
...  RAN PZ3 WRO1 TEMPLATE


*** Keywords ***
ALD.18_ALD_Configure_RET_Antenna_from_runtime_view

	ALD.18_ALD_Configure_RET_Antenna_from_runtime_view.Test_Step.0 Check If ALDs Are In Configuration
    ALD.18_ALD_Configure_RET_Antenna_from_runtime_view.Test_Step.1 Change RET parameters
    ALD.18_ALD_Configure_RET_Antenna_from_runtime_view.Test_Step.2 Check ALDs State
    ALD.18_ALD_Configure_RET_Antenna_from_runtime_view.Test_Step.3 Calibrate RET
    ALD.18_ALD_Configure_RET_Antenna_from_runtime_view.Test_Step.4 Check ALDs State

ALD.18_ALD_Configure_RET_Antenna_from_runtime_view.Test_Step.0 Check If ALDs Are In Configuration
    [Documentation]  Check if at least one ALD of RET type is connected to BTS.
    Log to console    \n========================================
    Log  Step: 0 Test Preparation  console=${True}
    Log to console    ========================================
    ${ALD_R_RAEs}  ${ALD_R_MHAs}  ${ALD_R_RETs}
    ...  ${ALD_R_ALL}  ${num_of_RAEs}  ${num_of_MHAs}  ${num_of_RETs}  ${num_of_ALDs}  Sorting ALD_R by type
    Set Test Variable  ${num_of_RETs}
    Set Test Variable  ${ALD_R_RETs}
    IF  ${num_of_RETs}==${0}  Fail  msg=There is no at least one RET in configuration
    Log  You have ${num_of_RETs} RETs in configuration  console=${True}
    Check And Resolve Google Chrome And Webdriver Version Compatibility

ALD.18_ALD_Configure_RET_Antenna_from_runtime_view.Test_Step.1 Change RET parameters
   [Documentation]  Change RET parameters via runtime view: angle and mechanical angle.
    Log to console    \n========================================
    Log  Step: 1 Change RET parameters  console=${True}
    Log to console    ========================================
    Open Chrome Browser
    Login To WebEM
    Change RET Angle Via Runtime View  ${ALD_R_RETs}
    Change RET Mechanical Angle Via Runtime View  ${ALD_R_RETs}
    Sleep  60s
    [Teardown]  Selenium2Library.Close All Browsers

ALD.18_ALD_Configure_RET_Antenna_from_runtime_view.Test_Step.${n} Check ALDs State
    [Documentation]
    ...    1. Check if all ALDs achieve expected state: administrativeState=unlocked, operationalState=enabled.
    ...    2. Check if other unexpected faults are visible.
    Log to console    \n========================================
    Log  Step: ${n} Check ALDs State  console=${True}
    Log to console    ========================================
    Check ALDs State  ${ALD_expected_states}
    Check If Unexpected Alarms Are Raised  ${skip_fault}

ALD.18_ALD_Configure_RET_Antenna_from_runtime_view.Test_Step.3 Calibrate RET
    [Documentation]  Calibrate all RET devices.
    Log to console    \n========================================
    Log  Step: 3 Perform RET calibration  console=${True}
    Log to console    ========================================
    Open Chrome Browser
    Login To WebEM
    Calibrate RET Via Runtime View  ${ALD_R_RETs}
	Sleep  30
	[Teardown]  Selenium2Library.Close All Browsers

ALD.18_ALD_Configure_RET_Antenna_from_runtime_view.Test Specific Teardown
    [Documentation]  Recovery action for ALDs if fault 1874 or 1844 is visible.
    admin.setup admin  admin_api_log_dir=${RESULTS}/admin_api/  alias=${ute_admin_alias}
    ${if_exist_1874}=  Run Keyword And Return Status  admin.assert alarm active  faultId=1874
    ${if_exist_1842}=  Run Keyword And Return Status  admin.assert alarm active  faultId=1842
    ${if_exist_1844}=  Run Keyword And Return Status  admin.assert alarm active  faultId=1844
    ${faultId}=  Set Variable If
    ...  '${if_exist_1874}'=='${True}'  1874
    ...  '${if_exist_1842}'=='${True}'  1842
    ...  '${if_exist_1844}'=='${True}'  1844
    IF  ${if_exist_1874} or ${if_exist_1844} or ${if_exist_1842}  ALD Recovery Action  ${faultId}
    admin.teardown admin  alias=${ute_admin_alias}

ALD.18_ALD_Configure_RET_Antenna_from_runtime_view.Test Case Teardown
    [Arguments]  ${SEND_SNAPSHOT_FOR_SCRAMBLING}=${False}
    Run Keywords  common.Common Test Teardown  ${SEND_SNAPSHOT_FOR_SCRAMBLING}
    ...  AND  Kill All Instances Of Chrome
    Run Keyword If Test Failed  ALD.18_ALD_Configure_RET_Antenna_from_runtime_view.Test Specific Teardown
