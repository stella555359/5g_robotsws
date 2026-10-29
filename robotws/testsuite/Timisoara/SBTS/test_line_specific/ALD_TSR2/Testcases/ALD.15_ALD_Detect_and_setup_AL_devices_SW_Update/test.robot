*** Settings ***
Resource    ../../../../../../Wroclaw/OAM/RAN_PZ_WRO3_SG01/resources/common.robot
Resource    ../../../../../../Wroclaw/OAM/RAN_PZ_WRO3_SG01/resources/alarms.robot
Resource    ../../../../../../Wroclaw/OAM/RAN_PZ_WRO3_SG01/resources/ald.robot
Resource    ../../../../../../Wroclaw/OAM/RAN_PZ_WRO3_SG01/resources/power_saving.robot

Documentation
...  TEST NAME:     ALD.15_ALD_Detect_and_setup_AL_devices_SW_Update
...  AUTHORS:       tomasz.marchewka@nokia.com
...  MAINTAINER:    RAN_PZ_WRO_3_SG01
...  *****************
...  Basic information
...  *****************
...  The purpose of this test case is to check if Antenna Line Devices (MHA/RET) are detected and set up properly after BTS SW update.
...  *****************
...  Pre-conditions
...  *****************
...  N/A
...  ******************
...  History of changes
...  *****************
...  - 19.04.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-148 - TC creation
...  *******************
...  RAN PZ3 WRO1 TEMPLATE

*** Variables ***


*** Keywords ***
ALD.15_ALD_Detect_and_setup_AL_devices_SW_Update

	ALD.15_ALD_Detect_and_setup_AL_devices_SW_Update.Test_Step.0 Check If ALDs Are In Configuration
    ALD.15_ALD_Detect_and_setup_AL_devices_SW_Update.Test_Step.1 BTS SW Update
    ALD.15_ALD_Detect_and_setup_AL_devices_SW_Update.Test_Step.2 Check states and alarms on BTS

ALD.15_ALD_Detect_and_setup_AL_devices_SW_Update.Test_Step.0 Check If ALDs Are In Configuration
    [Documentation]  Test step which checking if ALDs are in configuration.
    Log to console    \n========================================
    Log  Step: 0 Test Preparation  console=${True}
    Log to console    ========================================
    ${ALD_R_RAEs}  ${ALD_R_MHAs}  ${ALD_R_RETs}
    ...  ${ALD_R_ALL}  ${num_of_RAEs}  ${num_of_MHAs}  ${num_of_RETs}  ${num_of_ALDs}  Sorting ALD_R by type
    Set Test Variable  ${num_of_RETs}
    Set Test Variable  ${num_of_MHAs}
    Set Test Variable  ${num_of_ALDs}
    Run Keyword If  ${num_of_MHAs}==${0} and ${num_of_RETs}==${0}
    ...  Log  There is no ALD(s) in configuration  level=WARN  console=${True}
    ...  ELSE  Log  You have ${num_of_MHAs} MHAs and ${num_of_RETs} RETs in configuration  console=${True}

ALD.15_ALD_Detect_and_setup_AL_devices_SW_Update.Test_Step.1 BTS SW Update
    [Documentation]  BTS SW Update.
    Log to console    \n========================================
    Log  Step: 1 BTS SW Update  console=${True}
    Log to console    ========================================
    Allow Fault In Watchdog  faultID=6327  #fault_name: Setup of X2 connectivity to gNB failed
    Allow Fault In Watchdog  faultID=7300  #fault_name: No X2 link available
    Allow Fault In Watchdog  faultID=7319  #fault_name: No X2 link available for a specific LTEENB
    Download Expected SW Package  ${SW_PACKAGE}
    Log  SW update is ongoing...  console=${True}
    ${msg}=  admin.update software  ${SW_package_destination_path}/${SW_PACKAGE}_release_BTSSM_downloadable_A54.zip
    ...  ${SHOULD_ACTIVATE}  timeout=900
    Run Keyword If  '${msg}'=='Software update has been completed'
    ...  Log  ${msg}  console=${True}
    ...  ELSE  Fail  Software update has been failed
    Check If SMOD Is Not Pingable
    Log  BTS reset is ongoing...  console=${True}
    Check If SMOD Is Pingable

ALD.15_ALD_Detect_and_setup_AL_devices_SW_Update.Test_Step.2 Check states and alarms on BTS
    [Documentation]
    ...  1. Check if all SMODs achieve expected state: administrativeState=unlocked, operationalState=enabled.
    ...  2. Check if all RMODs achieve expected state: administrativeState=unlocked, operationalState=enabled.
    ...  3. Check if all ALDs achieve expected state: administrativeState=unlocked, operationalState=enabled.
    ...  4. Check if BTS have expected state: proceduralState=OnAir, blockingState=unblocked.
    ...  5. Check if all cells are on air.
    ...  6. Check active alarms on BTS.
    Log to console    \n========================================
    Log  Step: 2 Check states and alarms on BTS after SW update  console=${True}
    Log to console    ========================================
	Check SMODs State  ${SMOD_expected_states}
	Check RMODs State  ${RMOD_expected_states}
	Check ALDs State  ${ALD_expected_states}
    common.Check BTS State  ${BTS_expected_states}
    Check If NLWG Cells Are OnAir
    Disallow Fault In Watchdog  faultID=6327  #fault_name: Setup of X2 connectivity to gNB failed
    Disallow Fault In Watchdog  faultID=7300  #fault_name: No X2 link available
    Disallow Fault In Watchdog  faultID=7319  #fault_name: No X2 link available for a specific LTEENB
    Check If Unexpected Alarms Are Raised  ${skip_fault}
    SW Package Delete

ALD.15_ALD_Detect_and_setup_AL_devices_SW_Update.Test Case Teardown
    [Arguments]  ${SEND_SNAPSHOT_FOR_SCRAMBLING}=${False}
    Run Keyword  common.Common Test Teardown  ${SEND_SNAPSHOT_FOR_SCRAMBLING}
