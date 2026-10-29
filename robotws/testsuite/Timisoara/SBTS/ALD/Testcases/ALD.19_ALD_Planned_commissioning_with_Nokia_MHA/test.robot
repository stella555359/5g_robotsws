*** Settings ***
Resource    ../../resources/common.robot
Resource    ../../resources/alarms.robot
Resource    ../../resources/ald.robot
Resource    ../../resources/power_saving.robot

Documentation
...  TEST NAME:     ALD.19_ALD_Planned_commissioning_with_Nokia_MHA
...  AUTHORS:       damian.sliwinski@nokia.com
...  MAINTAINER:    RAN_PZ_WRO_3_SG01
...  *****************
...  Basic information
...  *****************
...  The purpose of this test case is to test commissioning with Nokia MHA.
...  *****************
...  Pre-conditions
...  *****************
...  N/A
...  ******************
...  History of changes
...  *****************
...  12.06.2017 - https://jira3.int.net.nokia.com/browse/TAT-6279 - New TC available
...  06.09.2017 - https://jira3.int.net.nokia.com/browse/TAT-7502 - Changes in commissioning and decommissioning procedures.
...  13.09.2017 - https://jira3.int.net.nokia.com/browse/TAT-7594 - Changes in Infomodel queries to use ADMIN Abstract Layer
...  03.10.2017 - https://jira3.int.net.nokia.com/browse/TAT-7813 - Replace references to LNBTS with MRBTS
...  06.10.2017 - https://jira3.int.net.nokia.com/browse/TAT-7897 - Use hran_ald.robot resource
...  25.05.2018 - https://jira3.int.net.nokia.com/browse/TAT-10157 - Add checking cells after reboot, add CELLS_ONAIR_TIMEOUT
...  04.03.2018 - https://jira3.int.net.nokia.com/browse/TAT-12485 - Filtered alarms elated with SSH and R&D port services
...  25.20.2018 - https://jira3.int.net.nokia.com/browse/TAT-12591 - Added FHEB and FHDB as exception in Check FEG keyword
...  12.03.2019 - https://jira3.int.net.nokia.com/browse/TAT-14560
...  19.07.2019 - https://jira3.int.net.nokia.com/browse/TAT-14249
...  14.09.2020 - https://jira3.int.net.nokia.com/browse/TAT-20209
...  15.07.2021 - https://jira3.int.net.nokia.com/browse/TAT-21469 - Added NRCEL verification after BTS start-up
...  25.08.2021 - https://jira3.int.net.nokia.com/browse/TAT-21780
...  22.10.2021 - https://jiradc.ext.net.nokia.com/browse/TAW-19 - Adaptation to CNI-61110
...  06.12.2021 - https://jiradc.ext.net.nokia.com/browse/TAW-36 - Switch to hran_frame_sbts_siso resource
...  20.12.2021 - https://jiradc.ext.net.nokia.com/browse/TAW-42 - Adding timeouts / sleep
...  22.04.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-159 - Adaptation to CNI-82119 and migration from hran_ta to robotlte repository
...  10.08.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-245 - Add Test Specific Teardown
...  08.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-335 - Adaptation to CB007500 (workaraound solution for configuration reset via admin)
...  21.06.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-352 - Newton Add FID1811 to allowed fault list
...  *******************
...  RAN PZ3 WRO1 TEMPLATE


*** Keywords ***
ALD.19_ALD_Planned_commissioning_with_Nokia_MHA

	ALD.19_ALD_Planned_commissioning_with_Nokia_MHA.Test_Step.0 Check If ALDs Are In Configuration
    ALD.19_ALD_Planned_commissioning_with_Nokia_MHA.Test_Step.1 BTS decommissioning
    ALD.19_ALD_Planned_commissioning_with_Nokia_MHA.Test_Step.2 BTS commissioning
    ALD.19_ALD_Planned_commissioning_with_Nokia_MHA.Test_Step.3 Comparing quantity of MHAs in SCFC file and Infomodel
    ALD.19_ALD_Planned_commissioning_with_Nokia_MHA.Test_Step.4 Checking ALDs State

ALD.19_ALD_Planned_commissioning_with_Nokia_MHA.Test_Step.0 Check If ALDs Are In Configuration
    [Documentation]  Test step which checking if ALDs are in configuration.
    Log to console    \n========================================
    Log  Step: 0 Test Preparation  console=${True}
    Log to console    ========================================
    Set Test Variable  ${COMMISSIONING_PATH}  /home/ute/testline_configuration/${TESTLINE_NAME}/node1/SCF_01_${RELEASE}.xml
    ${ALD_R_RAEs}  ${ALD_R_MHAs}  ${ALD_R_RETs}
    ...  ${ALD_R_ALL}  ${num_of_RAEs}  ${num_of_MHAs}  ${num_of_RETs}  ${num_of_ALDs}  Sorting ALD_R by type
    Set Test Variable  ${num_of_MHAs}
    IF  ${num_of_MHAs}==${0}  Fail  msg=There is no at least one MHA in configuration
    Log  You have ${num_of_MHAs} MHAs in configuration  console=${True}

ALD.19_ALD_Planned_commissioning_with_Nokia_MHA.Test_Step.1 BTS decommissioning
    [Documentation]
    ...    1. Reset configuration.
    ...    2. Check if BTS achieve expected state: proceduralState=NotCommissioned.
    Log to console    \n========================================
    Log  Step: 1 BTS decommissioning  console=${True}
    Log to console    ========================================
#   unavailable due to CB007500-SR BTS Configuration Reset by D&RSW
#	Log  Resetting configuration via ADMIN  console=${True}
#	admin.reset configuration  remove_operator_certificates=${False}  remove_user_account_credentials=${False}  timeout=800
    Configuration Reset With HWF
	Check SMODs State  ${SMOD_expected_states}
	Sleep  100s
    common.Check BTS State  ${BTS_expected_state_notCommissioned}
    IF  '${MRBTS_ID}'=='5020'
        Log To Console  Waiting for secondary core visible
        sleep  900s
    END

ALD.19_ALD_Planned_commissioning_with_Nokia_MHA.Test_Step.2 BTS commissioning
    [Documentation]
    ...    1. Perform commissioning.
    ...    2. Check BTS statuses and alarms.
    Log to console    \n========================================
    Log  Step: 2 BTS commissioning  console=${True}
    Log to console    ========================================
    Allow Fault In Watchdog  faultID=6327  #fault_name: Setup of X2 connectivity to gNB failed
    Allow Fault In Watchdog  faultID=7300  #fault_name: No X2 link available
    Allow Fault In Watchdog  faultID=7319  #fault_name: No X2 link available for a specific LTEENB
    IF  '${MRBTS_ID}'=='5019'  Allow Fault In Watchdog  faultID=1811  #fault_name: Radio autonomous reset as recovery action
    Log  Restoring BTS configuration using ${COMMISSIONING_PATH}    console=${True}
    admin.perform commissioning  ${MRBTS_ID}  ${COMMISSIONING_PATH}  ${SKIP_PARAMETER_RELATION_ERRORS}  ${SHOULD_ACTIVATE}  timeout=600
	Check SMODs State  ${SMOD_expected_states}
	Check RMODs State  ${RMOD_expected_states}
	Check ALDs State  ${ALD_expected_states}
    common.Check BTS State  ${BTS_expected_states}
    Check If NLWG Cells Are OnAir
    Disallow Fault In Watchdog  faultID=6327  #fault_name: Setup of X2 connectivity to gNB failed
    Disallow Fault In Watchdog  faultID=7300  #fault_name: No X2 link available
    Disallow Fault In Watchdog  faultID=7319  #fault_name: No X2 link available for a specific LTEENB
    IF  '${MRBTS_ID}'=='5019'  Disallow Fault In Watchdog  faultID=1811  #fault_name: Radio autonomous reset as recovery action
    Check If Unexpected Alarms Are Raised  ${skip_fault}

ALD.19_ALD_Planned_commissioning_with_Nokia_MHA.Test_Step.3 Comparing quantity of MHAs in SCFC file and Infomodel
    [Documentation]
    ...    The number of MHAs in SCFC file is not obtained directly. It is determined by the number of
    ...    ALD_A objects in Infomodel. This method was suggested by the test owner.
    Log to console    \n========================================
    Log  Step: 3 Comparing quantity of MHAs in SCFC file and Infomodel   console=${True}
    Log to console    ========================================
    ${ALD_L_dn_list}  ${ALD_R_dn_list}  ${ALD_A_dn_list}  ${parameters_to_check}  Get defined ALDs Connected To BTS  MHA
    ${num_of_MHA_in_IM}=  Get Length  ${ALD_L_dn_list}
    Log  Number of MHA ALD objects in Infomodel: ${num_of_MHA_in_IM}  console=${True}
    ${num_of_MHA_in_SCF}=  Get Length  ${ALD_A_dn_list}
    Log  Number of respective MHA ALD_A objects in Infomodel: ${num_of_MHA_in_SCF}  console=${True}
    Should Be Equal As Numbers  ${num_of_MHA_in_IM}  ${num_of_MHA_in_SCF}  msg=NOT all MHAs are commissioned
    Log  All MHAs are commissioned    console=${True}

ALD.19_ALD_Planned_commissioning_with_Nokia_MHA.Test_Step.4 Checking ALDs State
    [Documentation]
    ...    1. Check if all ALDs achieve expected state: administrativeState=unlocked, operationalState=enabled.
    ...    2. Check if other unexpected faults are visible.
    Log to console    \n========================================
    Log  Step: 4 Checking ALDs State   console=${True}
    Log to console    ========================================
	Check ALDs State  ${ALD_expected_states}
    Check If Unexpected Alarms Are Raised  ${skip_fault}

ALD.19_ALD_Planned_commissioning_with_Nokia_MHA.Test Specific Teardown
    [Documentation]  Test teardown which restores original configuration settings.
    admin.setup admin  admin_api_log_dir=${RESULTS}/admin_api/  alias=${ute_admin_alias}
    Allow Fault In Watchdog  faultID=6327  #fault_name: Setup of X2 connectivity to gNB failed
    Allow Fault In Watchdog  faultID=7300  #fault_name: No X2 link available
    Allow Fault In Watchdog  faultID=7319  #fault_name: No X2 link available for a specific LTEENB
    IF  '${MRBTS_ID}'=='5019'  Allow Fault In Watchdog  faultID=1811  #fault_name: Radio autonomous reset as recovery action
    Log  \nRestoring original configuration settings  console=${True}
    admin.perform commissioning  ${MRBTS_ID}  ${COMMISSIONING_PATH}  ${SKIP_PARAMETER_RELATION_ERRORS}  ${SHOULD_ACTIVATE}  timeout=600
	Check SMODs State  ${SMOD_expected_states}
	Check RMODs State  ${RMOD_expected_states}
	Check ALDs State  ${ALD_expected_states}
    common.Check BTS State  ${BTS_expected_states}
    Check If NLWG Cells Are OnAir
    Disallow Fault In Watchdog  faultID=6327  #fault_name: Setup of X2 connectivity to gNB failed
    Disallow Fault In Watchdog  faultID=7300  #fault_name: No X2 link available
    Disallow Fault In Watchdog  faultID=7319  #fault_name: No X2 link available for a specific LTEENB
    IF  '${MRBTS_ID}'=='5019'  Disallow Fault In Watchdog  faultID=1811  #fault_name: Radio autonomous reset as recovery action
    admin.teardown admin  alias=${ute_admin_alias}

ALD.19_ALD_Planned_commissioning_with_Nokia_MHA.Test Case Teardown
    [Arguments]  ${SEND_SNAPSHOT_FOR_SCRAMBLING}=${False}
    Run Keyword  common.Common Test Teardown  ${SEND_SNAPSHOT_FOR_SCRAMBLING}
    Run Keyword If Test Failed  ALD.19_ALD_Planned_commissioning_with_Nokia_MHA.Test Specific Teardown
