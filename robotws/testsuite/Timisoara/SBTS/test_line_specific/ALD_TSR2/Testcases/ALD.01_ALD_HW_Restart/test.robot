*** Settings ***
Resource    ../../../../../../Wroclaw/OAM/RAN_PZ_WRO3_SG01/resources/common.robot
Resource    ../../../../../../Wroclaw/OAM/RAN_PZ_WRO3_SG01/resources/alarms.robot
Resource    ../../../../../../Wroclaw/OAM/RAN_PZ_WRO3_SG01/resources/ald.robot
Resource    ../../../../../../Wroclaw/OAM/RAN_PZ_WRO3_SG01/resources/power_saving.robot
Resource    ../../../../../../Wroclaw/OAM/RAN_PZ_WRO3_SG01/resources/selenium.robot

Documentation
...  TEST NAME:     ALD.01_ALD_HW_Restart
...  AUTHORS:       tomasz.marchewka@nokia.com
...  MAINTAINER:    RAN_PZ_WRO_3_SG01
...  *****************
...  Basic information
...  *****************
...  The purpose of this test case is to check if ALD HW reset procedure works correctly according to operator
...  request - via WebEM interface.
...  *****************
...  Pre-conditions
...  *****************
...  N/A
...  ******************
...  History of changes
...  ******************
...  08.01.2020 - https://jira3.int.net.nokia.com/browse/TAT-18718
...  19.03.2020 - Test creation
...  05.11.2020 - https://jira3.ext.net.nokia.com/browse/TAT-20401
...  16.12.2020 - https://jira3.ext.net.nokia.com/browse/TAT-20640
...  19.05.2021 - https://jira3.ext.net.nokia.com/browse/TAT-21336
...  17.06.2021 - https://jira3.ext.net.nokia.com/browse/TAT-21476
...  11.10.2021 - https://jiradc.ext.net.nokia.com/browse/TAW-5 - migration to TAF
...  18.10.2021 - https://jiradc.ext.net.nokia.com/browse/TAW-10 - Adaptation to CNI-61110
...  06.12.2021 - https://jiradc.ext.net.nokia.com/browse/TAW-36 - Switch to hran_frame_sbts_siso resource
...  04.04.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-140 - Adaptation to CNI-82119 and migration from hran_ta to robotlte repository
...  *******************
...  RAN PZ3 WRO1 TEMPLATE

*** Variables ***


*** Keywords ***
ALD.01_ALD_HW_Restart

	ALD.01_ALD_HW_Restart.Test_Step.0 Check If ALDs Are In Configuration
    ALD.01_ALD_HW_Restart.Test_Step.1 ALD Hardware Reset Via WebEM
    ALD.01_ALD_HW_Restart.Test_Step.2 Checking ALD State After HW Reset

ALD.01_ALD_HW_Restart.Test_Step.0 Check If ALDs Are In Configuration
    [Documentation]  Test step which checking if ALDs are in configuration.
    Log to console    \n========================================
    Log  Step: 0 Test Preparation  console=${True}
    Log to console    ========================================
    ${ALD_R_RAEs}  ${ALD_R_MHAs}  ${ALD_R_RETs}
    ...  ${ALD_R_ALL}  ${num_of_RAEs}  ${num_of_MHAs}  ${num_of_RETs}  ${num_of_ALDs}  Sorting ALD_R by type
    Set Test Variable  ${ALD_R_ALL}
    Run Keyword If  ${num_of_MHAs}==${0} and ${num_of_RETs}==${0}
    ...  Fail  msg=There is no at least one ALD in configuration
    Log  You have ${num_of_MHAs} MHAs and ${num_of_RETs} RETs in configuration  console=${True}
    Check And Resolve Google Chrome And Webdriver Version Compatibility

ALD.01_ALD_HW_Restart.Test_Step.1 ALD ${type} Reset Via WebEM
    [Documentation]  ${type} reset for all ALDs via WebEM.
    Log to console    \n========================================
    Log  Step: 1 ALD ${type} reset via WebEM  console=${True}
    Log to console    ========================================
    Open Chrome Browser
    Login To WebEM
    ALD Hardware Reset Via WebEM  ${ALD_R_ALL}  ${ALD_expected_state_offline}
	Sleep  60
	[Teardown]  Selenium2Library.Close All Browsers

ALD.01_ALD_HW_Restart.Test_Step.2 Checking ALD State After HW Reset
    [Documentation]  Check if all ALDs achieve expected state: administrativeState=unlocked, operationalState=enabled.
    Log to console    \n========================================
    Log  Step: 2 Checking ALD State After HW Reset  console=${True}
    Log to console    ========================================
	Check ALDs State  ${ALD_expected_states}
	Check If Unexpected Alarms Are Raised  ${skip_fault}

ALD.01_ALD_HW_Restart.Test Case Teardown
    [Arguments]  ${SEND_SNAPSHOT_FOR_SCRAMBLING}=${False}
    Run Keywords  common.Common Test Teardown  ${SEND_SNAPSHOT_FOR_SCRAMBLING}
    ...  AND  Kill All Instances Of Chrome
