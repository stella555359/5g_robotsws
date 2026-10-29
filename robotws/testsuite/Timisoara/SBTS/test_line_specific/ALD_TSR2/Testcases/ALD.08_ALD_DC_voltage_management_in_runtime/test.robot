*** Settings ***
Resource    ../../../../../../Wroclaw/OAM/RAN_PZ_WRO3_SG01/resources/common.robot
Resource    ../../../../../../Wroclaw/OAM/RAN_PZ_WRO3_SG01/resources/alarms.robot
Resource    ../../../../../../Wroclaw/OAM/RAN_PZ_WRO3_SG01/resources/ald.robot
Resource    ../../../../../../Wroclaw/OAM/RAN_PZ_WRO3_SG01/resources/power_saving.robot

Documentation
...  TEST NAME:     ALD.08_ALD_DC_voltage_management_in_runtime
...  AUTHORS:       tomasz.marchewka@nokia.com
...  MAINTAINER:    RAN_PZ_WRO_3_SG01
...  *****************
...  Basic information
...  *****************
...  The purpose of this test case is to check DC voltage managment procedure.
...  *****************
...  Pre-conditions
...  *****************
...  N/A
...  ******************
...  History of changes
...  ******************
...  17.07.2018 - Test creation
...  24.08.2018 - update
...  4.09.2018  - review
...  10.09.2108 - Test update after review
...  30.10.2018 - TAT-12901 - Changed FEG calculation mechanism after correction of pronto PR379694, which changed OAM procedure when DC voltage OFF
...  16.11.2018 - https://jira3.int.net.nokia.com/browse/TAT-13192
...  12.03.2019 - https://jira3.int.net.nokia.com/browse/TAT-14560
...  30.04.2019 - https://jira3.int.net.nokia.com/browse/TAT-13910
...  03.06.2019 - https://jira3.int.net.nokia.com/browse/TAT-15283
...  01.07.2019 - https://jira3.int.net.nokia.com/browse/TAT-16745
...  12.08.2021 - https://jira3.int.net.nokia.com/browse/TAT-21666
...  10.09.2021 - https://jira3.int.net.nokia.com/browse/TAT-21872
...  06.12.2021 - https://jiradc.ext.net.nokia.com/browse/TAW-36 - Switch to hran_frame_sbts_siso resource
...  21.04.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-155 - Adaptation to CNI-82119 and migration from hran_ta to robotlte repository
...  28.07.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-231 - Add recovery action as BTS Reset Site in Test Specific Teardown
...  *******************
...  RAN PZ3 WRO1 TEMPLATE

*** Variables ***


*** Keywords ***
ALD.08_ALD_DC_voltage_management_in_runtime

	ALD.08_ALD_DC_voltage_management_in_runtime.Test_Step.0 Check If ALDs Are In Configuration
    ALD.08_ALD_DC_voltage_management_in_runtime.Test_Step.1 DC voltage switching OFF
    ALD.08_ALD_DC_voltage_management_in_runtime.Test_Step.2 FEG calculation
    ALD.08_ALD_DC_voltage_management_in_runtime.Test_Step.3 Checking alarms
    ALD.08_ALD_DC_voltage_management_in_runtime.Test_Step.4 DC voltage switching ON
    ALD.08_ALD_DC_voltage_management_in_runtime.Test_Step.5 FEG calculation
    ALD.08_ALD_DC_voltage_management_in_runtime.Test_Step.6 Alarm Check after DC ON
    ALD.08_ALD_DC_voltage_management_in_runtime.Test_Step.7 Checking ALDs State

ALD.08_ALD_DC_voltage_management_in_runtime.Test_Step.0 Check If ALDs Are In Configuration
    [Documentation]  Test step which checking if ALDs are in configuration.
    Log to console    \n========================================
    Log  Step: 0 Test Preparation  console=${True}
    Log to console    ========================================
    Set Test Variable  ${COMMISSIONING_PATH}  /home/ute/testline_configuration/${TESTLINE_NAME}/node1/SCF_01_${RELEASE}.xml
    ${ALD_R_RAEs}  ${ALD_R_MHAs}  ${ALD_R_RETs}
    ...  ${ALD_R_ALL}  ${num_of_RAEs}  ${num_of_MHAs}  ${num_of_RETs}  ${num_of_ALDs}  Sorting ALD_R by type
    Run Keyword If  ${num_of_MHAs}==${0} and ${num_of_RETs}==${0}
    ...  Fail  msg=There is no at least one ALD in configuration
    Log  You have ${num_of_MHAs} MHAs and ${num_of_RETs} RETs in configuration  console=${True}
    Make DC Settings Backup

ALD.08_ALD_DC_voltage_management_in_runtime.Test_Step.1 DC voltage switching OFF
    [Documentation]  Test step which switching off DC voltage on selected ANTL and RSL.
    Log to console    \n========================================
    Log  Step: 1 DC voltage switching Off  console=${True}
    Log to console    ========================================
    Allow Fault In Watchdog  faultID=4141  #fault_name: DC voltage administratively disabled
    DC Voltage Switching OFF
    Sleep  120s
    Run Keyword If  '${MRBTS_ID}'=='5046' or '${MRBTS_ID}'=='9040'  Run Keywords
    ...  Log To Console  It's Testline with shared multiret with second TestLine.
    ...  AND  Run Keyword    Shared ALDs check    ALL    ${MRBTS_ID}
    ...  ELSE
    ...  Check ALDs State  ${ALD_expected_state_powerOff}

ALD.08_ALD_DC_voltage_management_in_runtime.Test_Step.2 FEG calculation
    [Documentation]  This keyword check if FEG is correctly calculated when DC is off and there is recalculation as recovery action.
    Log to console    \n========================================
    Log  Step: 2 FEG calculation  console=${True}
    Log to console    ========================================
    Check FEG On ANTL Where Is Loglink With Recovery

ALD.08_ALD_DC_voltage_management_in_runtime.Test_Step.3 Checking alarms
    [Documentation]  Check active alarms on BTS.
    Log to console    \n========================================
    Log  Step: 3 Checking alarms  console=${True}
    Log to console    ========================================
    Find Source of Reported 4141 Faults
    Get Alarm Source 4141
    Check Alarm 4141

ALD.08_ALD_DC_voltage_management_in_runtime.Test_Step.4 DC voltage switching ON
    [Documentation]  Test step which switching on DC voltage on selected ANTL and RSL.
    Log to console    \n========================================
    Log  Step: 4 DC voltage switching ON  console=${True}
    Log to console    ========================================
    DC Voltage Switching ON
    Sleep  120s

ALD.08_ALD_DC_voltage_management_in_runtime.Test_Step.5 FEG calculation
    [Documentation]  This keyword is checking if front end gain is calculated properly.
    Log to console    \n========================================
    Log  Step: 5 FEG calculation  console=${True}
    Log to console    ========================================
    Check FEG On Antl Without MHA
    Check FEG On Antl With MHA

ALD.08_ALD_DC_voltage_management_in_runtime.Test_Step.6 Alarm Check after DC ON
    [Documentation]  Check active alarms on BTS.
    Log to console    \n========================================
    Log  Step: 6 Alarm Check after DC ON  console=${True}
    Log to console    ========================================
    Disallow Fault In Watchdog  faultID=4141  #fault_name: DC voltage administratively disabled
    ${status_4141}=  Run Keyword And Return Status  admin.assert alarm active  faultId=4141
    Run Keyword If  ${status_4141}  Fail  msg=Fault 4141 was not cleared
    ...  ELSE  Log  Fault 4141 is not reported  console=${True}
    ${status_10}=  Run Keyword And Return Status  admin.assert alarm active  faultId=10
    Run Keyword If  ${status_10}  Fail  msg=Fault 10 was not cleared
    ...  ELSE  Log  Fault 10 is not reported  console=${True}

ALD.08_ALD_DC_voltage_management_in_runtime.Test_Step.7 Checking ALDs State
    [Documentation]  Check if all ALDs achieve expected state: administrativeState=unlocked, operationalState=enabled.
    Log to console    \n========================================
    Log  Step: 7 Checking ALDs State   console=${True}
    Log to console    ========================================
	Check ALDs State  ${ALD_expected_states}
    Check If Unexpected Alarms Are Raised  ${skip_fault}

ALD.08_ALD_DC_voltage_management_in_runtime.Test Specific Teardown
    [Documentation]  Test teardown which restores DC Voltage and executes reset site if needed.
    admin.setup admin  admin_api_log_dir=${RESULTS}/admin_api/  alias=${ute_admin_alias}
    Log  \nRestoring DC Voltage  console=${True}
    Restore DC Settings
    ${ALD_status}=  Run Keyword And Return Status  Check ALDs State  ${ALD_expected_states}
    Run Keyword If  not ${ALD_status}  Run Keywords  Log To Console  BTS Reset site...
    ...  AND  Allow Fault In Watchdog  faultID=6327  #fault_name: Setup of X2 connectivity to gNB failed
    ...  AND  Allow Fault In Watchdog  faultID=7300  #fault_name: No X2 link available
    ...  AND  Allow Fault In Watchdog  faultID=7319  #fault_name: No X2 link available for a specific LTEENB	    ...
	...  AND  admin.reset site  timeout=700
    ...  AND  Check SMODs State  ${SMOD_expected_states}
	...  AND  Check RMODs State  ${RMOD_expected_states}
	...  AND  Check ALDs State  ${ALD_expected_states}
    ...  AND  common.Check BTS State  ${BTS_expected_states}
    ...  AND  Check If NLWG Cells Are OnAir
    ...  AND  Disallow Fault In Watchdog  faultID=6327  #fault_name: Setup of X2 connectivity to gNB failed
    ...  AND  Disallow Fault In Watchdog  faultID=7300  #fault_name: No X2 link available
    ...  AND  Disallow Fault In Watchdog  faultID=7319  #fault_name: No X2 link available for a specific LTEENB
    ...  ELSE IF  ${ALD_status}  Run Keyword  Check If NLWG Cells Are OnAir
    admin.teardown admin  alias=${ute_admin_alias}

ALD.08_ALD_DC_voltage_management_in_runtime.Test Case Teardown
    [Arguments]  ${SEND_SNAPSHOT_FOR_SCRAMBLING}=${False}
    Run Keyword  common.Common Test Teardown  ${SEND_SNAPSHOT_FOR_SCRAMBLING}
    Run Keyword If Test Failed  ALD.08_ALD_DC_voltage_management_in_runtime.Test Specific Teardown
