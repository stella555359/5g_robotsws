*** Settings ***
Resource    ../../../../../../Wroclaw/OAM/RAN_PZ_WRO3_SG01/resources/common.robot
Resource    ../../../../../../Wroclaw/OAM/RAN_PZ_WRO3_SG01/resources/alarms.robot
Resource    ../../../../../../Wroclaw/OAM/RAN_PZ_WRO3_SG01/resources/ald.robot
Resource    ../../../../../../Wroclaw/OAM/RAN_PZ_WRO3_SG01/resources/power_saving.robot

Documentation
...  TEST NAME:     ALD.17_ALD_Configure_Commissioned_RET_Antenna
...  AUTHORS:       tomasz.marchewka@nokia.com
...  MAINTAINER:    RAN_PZ_WRO_3_SG01
...  *****************
...  Basic information
...  *****************
...  The purpose of this test case is to test change parameters for RET ALDs.
...  *****************
...  Pre-conditions
...  *****************
...  N/A
...  ******************
...  History of changes
...  *****************
...  31.10.2017 - Start implementation.
...  12.03.2018 - TAT-9076 - use delta recommissioning to set new tilt angle
...  03.10.2018 - TAT-12486 - use keyword Admin Check Active Alarms instead  Check alarms (because new fault have to be filtered)
...  12.03.2019 - https://jira3.int.net.nokia.com/browse/TAT-14560
...  04.10.2019 - https://jira3.int.net.nokia.com/browse/TAT-17510
...  28.07.2021 - https://jira3.int.net.nokia.com/browse/TAT-21672
...  19.10.2021 - https://jiradc.ext.net.nokia.com/browse/TAW-12 - Adaptation to CNI-61110
...  06.12.2021 - https://jiradc.ext.net.nokia.com/browse/TAW-36 - Switch to hran_frame_sbts_siso resource
...  07.02.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-78 - Adaptation to CNI-64298
...  20.04.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-153 - Adaptation to CNI-82119 and migration from hran_ta to robotlte repository
...  12.08.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-249 - Add Test Specific Teardown
...  *******************
...  RAN PZ3 WRO1 TEMPLATE

*** Variables ***


*** Keywords ***
ALD.17_ALD_Configure_Commissioned_RET_Antenna

	ALD.17_ALD_Configure_Commissioned_RET_Antenna.Test_Step.0 Check If ALDs Are In Configuration
    ALD.17_ALD_Configure_Commissioned_RET_Antenna.Test_Step.1 Change RET parameters
    ALD.17_ALD_Configure_Commissioned_RET_Antenna.Test_Step.2 Check ALDs State

ALD.17_ALD_Configure_Commissioned_RET_Antenna.Test_Step.0 Check If ALDs Are In Configuration
    [Documentation]  Check if at least one ALD of RET type is connected to BTS.
    Log to console    \n========================================
    Log  Step: 0 Test Preparation  console=${True}
    Log to console    ========================================
    ${ALD_R_RAEs}  ${ALD_R_MHAs}  ${ALD_R_RETs}
    ...  ${ALD_R_ALL}  ${num_of_RAEs}  ${num_of_MHAs}  ${num_of_RETs}  ${num_of_ALDs}  Sorting ALD_R by type
    Set Test Variable  ${num_of_RETs}
    Set Test Variable  ${ALD_R_RETs}
    Run Keyword If  ${num_of_RETs}==${0}
    ...  Fail  msg=There is no at least one RET in configuration
    Log  You have ${num_of_RETs} RETs in configuration  console=${True}

ALD.17_ALD_Configure_Commissioned_RET_Antenna.Test_Step.1 Change RET parameters
   [Documentation]
    ...  This test steps:
    ...  1. Change Tile Angle.
    ...  2. Change Mechanical Angle.
    ...  3. Calibrate Tilt.
    ...  4. Check parameters after change.
    Log to console    \n========================================
    Log  Step: 1 Change RET parameters  console=${True}
    Log to console    ========================================
    Change RETU Parameters  ${ALD_R_RETs}

ALD.17_ALD_Configure_Commissioned_RET_Antenna.Test_Step.2 Check ALDs State
    [Documentation]
    ...    1. Check if all ALDs achieve expected state: administrativeState=unlocked, operationalState=enabled.
    ...    2. Check if other unexpected faults are visible.
    Log to console    \n========================================
    Log  Step: 2 Check ALDs State  console=${True}
    Log to console    ========================================
    Check ALDs State  ${ALD_expected_states}
    Check If Unexpected Alarms Are Raised  ${skip_fault}

ALD.17_ALD_Configure_Commissioned_RET_Antenna.Test Specific Teardown
    [Documentation]  Recovery action for ALDs if fault 1874 or 1844 is visible.
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

ALD.17_ALD_Configure_Commissioned_RET_Antenna.Test Case Teardown
    [Arguments]  ${SEND_SNAPSHOT_FOR_SCRAMBLING}=${False}
    Run Keyword  common.Common Test Teardown  ${SEND_SNAPSHOT_FOR_SCRAMBLING}
    Run Keyword If Test Failed  ALD.17_ALD_Configure_Commissioned_RET_Antenna.Test Specific Teardown
