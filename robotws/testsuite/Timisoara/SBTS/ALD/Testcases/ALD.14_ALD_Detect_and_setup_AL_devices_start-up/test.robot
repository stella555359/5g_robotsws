*** Settings ***
Resource    ../../resources/common.robot
Resource    ../../resources/alarms.robot
Resource    ../../resources/ald.robot
Resource    ../../resources/power_saving.robot

Documentation
...  TEST NAME:     ALD.14_ALD_Detect_and_setup_AL_devices_start-up
...  AUTHORS:       tomasz.marchewka@nokia.com
...  MAINTAINER:    RAN_PZ_WRO_3_SG01
...  *****************
...  Basic information
...  *****************
...  The purpose of this test case is to check if Antenna Line Devices (MHA/RET) are detected and set up properly
...  during BTS startup.
...  *****************
...  Pre-conditions
...  *****************
...  N/A
...  ******************
...  History of changes
...  *****************
...  31.03.2017 - https://jira3.int.net.nokia.com/browse/TAT-5971 - New TC available
...  13.09.2017 - https://jira3.int.net.nokia.com/browse/TAT-7594 - Changes in Infomodel queries to use ADMIN Abstract Layer
...  03.10.2017 - https://jira3.int.net.nokia.com/browse/TAT-7813 - Replace references to LNBTS with MRBTS
...  10.10.2017 - https://jira3.int.net.nokia.com/browse/TAT-7934 - General enhancements resulting form BTS software changes
...  10.10.2017 - https://jira3.int.net.nokia.com/browse/TAT-7897 - Use hran_ald.robot resource
...  16.10.2017 - https://jira3.int.net.nokia.com/browse/TAT-8025
...  07.11.2017 - https://jira3.int.net.nokia.com/browse/TAT-8071 - check BTS proceduralState in common.Common Test Setup
...  22.02.2018 - https://jira3.int.net.nokia.com/browse/TAT-9172 - add TC Variable for commissioning timeout
...  25.05.2018 - https://jira3.int.net.nokia.com/browse/TAT-10155 - Add checking cells after reboot in test teardown, add CELLS_ONAIR_TIMEOUT
...  29.05.2019 - https://jira3.int.net.nokia.com/browse/TAT-16253 - TC handover, changed GROUP_IN_CHARGE
...  05.05.2020 - https://jira3.int.net.nokia.com/browse/TAT-19502 - Change variable ${RECOMMISSIONING_FILE} and Pre-test Actions
...  23.08.2021 - https://jira3.int.net.nokia.com/browse/TAT-21763 - Migration to TAF
...  26.10.2021 - https://jiradc.ext.net.nokia.com/browse/TAW-23 - adaptation to CNI-61110
...  28.10.2021 - https://jiradc.ext.net.nokia.com/browse/TAW-26 - addition of sleep time in step 3
...  06.12.2021 - https://jiradc.ext.net.nokia.com/browse/TAW-36 - Switch to hran_frame_sbts_siso resource
...  07.02.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-79 - Adaptation to CNI-64298
...  19.04.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-146 - Adaptation to CNI-82119 and migration from hran_ta to robotlte repository
...  19.12.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-289 - different ALD comparison method. Step1 and step3 modified
...  *******************
...  RAN PZ3 WRO1 TEMPLATE


*** Keywords ***
ALD.14_ALD_Detect_and_setup_AL_devices_start-up

	ALD.14_ALD_Detect_and_setup_AL_devices_start-up.Test_Step.0 Check If ALDs Are In Configuration
    ALD.14_ALD_Detect_and_setup_AL_devices_start-up.Test_Step.1 Get Basic Parameters For Each ALD
    ALD.14_ALD_Detect_and_setup_AL_devices_start-up.Test_Step.2 Remove All ALDs From Configuration
    ALD.14_ALD_Detect_and_setup_AL_devices_start-up.Test_Step.3 Autodetect Information And Properties Of Each ALD
    ALD.14_ALD_Detect_and_setup_AL_devices_start-up.Test_Step.4 Checking ALDs State

ALD.14_ALD_Detect_and_setup_AL_devices_start-up.Test_Step.0 Check If ALDs Are In Configuration
    [Documentation]  Test step which checking if ALDs are in configuration.
    Log to console    \n========================================
    Log  Step: 0 Test Preparation  console=${True}
    Log to console    ========================================
    Set Test Variable  ${COMMISSIONING_PATH}  /home/ute/testline_configuration/${TESTLINE_NAME}/node1/SCF_01_${RELEASE}.xml
    ${ALD_R_RAEs}  ${ALD_R_MHAs}  ${ALD_R_RETs}
    ...  ${ALD_R_ALL}  ${num_of_RAEs}  ${num_of_MHAs}  ${num_of_RETs}  ${num_of_ALDs}  Sorting ALD_R by type
    Set Test Variable  ${ALD_R_ALL}
    IF  ${num_of_MHAs}==${0} and ${num_of_RETs}==${0}  Fail  msg=There is no at least one ALD in configuration
    Log  You have ${num_of_MHAs} MHAs and ${num_of_RETs} RETs in configuration  console=${True}

ALD.14_ALD_Detect_and_setup_AL_devices_start-up.Test_Step.1 Get Basic Parameters For Each ALD
   [Documentation]
    Log to console    \n========================================
    Log  Step: 1 Get basic parameters for each ALD  console=${True}
    Log to console    ========================================
    ${ALD_L_dn_list}  ${ALD_R_dn_list}  ${ALD_A_dn_list}  ${parameters_before}=  Get defined ALDs Connected To BTS  ALL
    ${num_of_ALD_L_before}=  Get Length  ${ALD_L_dn_list}
    ${num_of_ALD_A_before}=  Get Length  ${ALD_A_dn_list}
    ${num_of_ALD_R_before}=  Get Length  ${ALD_R_dn_list}
    Set Test Variable  ${num_of_ALD_L_before}
    Set Test Variable  ${num_of_ALD_A_before}
    Set Test Variable  ${num_of_ALD_R_before}
    Set Test Variable  ${parameters_before}
    ${SN_list_before}=  Create List
    FOR  ${item}  IN  @{parameters_before}
        ${ignore}  ${right_side}=  Split String From Right  ${item}  separator=_  max_split=1
        ${dict_value}=  Evaluate  $parameters_before.get("${item}")
        IF  '${right_side}'=='serialNumber'  Append To List  ${SN_list_before}  ${dict_value}
    END
    Sort List  ${SN_list_before}
    Set Test Variable  ${SN_list_before}

ALD.14_ALD_Detect_and_setup_AL_devices_start-up.Test_Step.2 Remove All ALDs From Configuration
    [Documentation]
   ...    1. Remove all commissioned ALDs.
   ...    2. BTS reset.
   ...    3. Check ALD state after BTS start-up.
   ...    4. Check if cells are on air.
   ...    5. Check alarms on BTS.
    Log to console    \n========================================
    Log  Step: 2 Remove All ALDs From Configuration  console=${True}
    Log to console    ========================================
    Create Delta Remove For ALD  ${ALD_R_ALL}  deviceType=ALL
    Allow Fault In Watchdog  faultID=6327  #fault_name: Setup of X2 connectivity to gNB failed
    Allow Fault In Watchdog  faultID=7300  #fault_name: No X2 link available
    Allow Fault In Watchdog  faultID=7319  #fault_name: No X2 link available for a specific LTEENB
    Log  BTS Reset site...  console=${true}
    admin.reset site  timeout=700
	Check SMODs State  ${SMOD_expected_states}
	Check RMODs State  ${RMOD_expected_states}
	Log  Waiting for ALD detection...  console=${true}
	Sleep  120s
	Check ALDs State  ${ALD_expected_states}
	common.Check BTS State  ${BTS_expected_states}
	Check If NLWG Cells Are OnAir
	Disallow Fault In Watchdog  faultID=6327  #fault_name: Setup of X2 connectivity to gNB failed
    Disallow Fault In Watchdog  faultID=7300  #fault_name: No X2 link available
    Disallow Fault In Watchdog  faultID=7319  #fault_name: No X2 link available for a specific LTEENB
	Check If Unexpected Alarms Are Raised  ${skip_fault}

ALD.14_ALD_Detect_and_setup_AL_devices_start-up.Test_Step.3 Autodetect Information And Properties Of Each ALD
    [Documentation]
    Log to console    \n========================================
    Log  Step: 3 Autodetect information and properties of each ALD are checked  console=${True}
    Log to console    ========================================
    ${ALD_L_dn_list}  ${ALD_R_dn_list}  ${ALD_A_dn_list}  ${parameters_after}=  Get defined ALDs Connected To BTS  ALL
    ${num_of_ALD_L_after}=  Get Length  ${ALD_L_dn_list}
    ${num_of_ALD_A_after}=  Get Length  ${ALD_A_dn_list}
    ${num_of_ALD_R_after}=  Get Length  ${ALD_R_dn_list}
    Set Test Variable  ${num_of_ALD_L_after}
    Set Test Variable  ${num_of_ALD_A_after}
    Set Test Variable  ${num_of_ALD_R_after}
    ${ald_not_assigned}=  Count Values In List  ${ALD_A_dn_list}  ${None}
    ${status}=  Run Keyword And Return Status  Should Be True  '${num_of_ALD_A_before}'=='${ald_not_assigned}'
    IF  ${status}
        Log  All ALD(s) are "not assigned" after BTS start-up  console=${true}
    ELSE
        Fail  At least one ALD is "assigned" (configDN parameter should be empty)
    END
    ${SN_list_after}=  Create List
    FOR  ${item}  IN  @{parameters_after}
        ${ignore}  ${right_side}=  Split String From Right  ${item}  separator=_  max_split=1
        ${dict_value}=  Evaluate  $parameters_after.get("${item}")
        IF  '${right_side}'=='serialNumber'  Append To List  ${SN_list_after}  ${dict_value}
    END
    Sort List  ${SN_list_after}
    ${status}=  Run Keyword And Return Status  Lists Should Be Equal  ${SN_list_before}  ${SN_list_after}
    IF  ${status}
        Log  All ALD(s) parameters before and after start-up are equal  console=${true}
    ELSE
        Fail  ALD parameters are not equal
    END


ALD.14_ALD_Detect_and_setup_AL_devices_start-up.Test_Step.4 Checking ALDs State
    [Documentation]  Check if all ALDs have expected state: administrativeState=Unlocked, operationalState=Enabled.
    Log to console    \n========================================
    Log  Step: 4 Checking ALDs State   console=${True}
    Log to console    ========================================
	Check ALDs State  ${ALD_expected_states}
    Check If Unexpected Alarms Are Raised  ${skip_fault}

ALD.14_ALD_Detect_and_setup_AL_devices_start-up.Test Specific Teardown
    [Documentation]  Test teardown which restores original configuration settings.
    Allow Fault In Watchdog  faultID=6327  #fault_name: Setup of X2 connectivity to gNB failed
    Allow Fault In Watchdog  faultID=7300  #fault_name: No X2 link available
    Allow Fault In Watchdog  faultID=7319  #fault_name: No X2 link available for a specific LTEENB
    Log  Restoring original configuration settings  console=${True}
    admin.perform commissioning  ${MRBTS_ID}  ${COMMISSIONING_PATH}  ${SKIP_PARAMETER_RELATION_ERRORS}  ${SHOULD_ACTIVATE}  timeout=600
	Check SMODs State  ${SMOD_expected_states}
	Check RMODs State  ${RMOD_expected_states}
	Check ALDs State  ${ALD_expected_states}
    common.Check BTS State  ${BTS_expected_states}
    Check If NLWG Cells Are OnAir
	Disallow Fault In Watchdog  faultID=6327  #fault_name: Setup of X2 connectivity to gNB failed
    Disallow Fault In Watchdog  faultID=7300  #fault_name: No X2 link available
    Disallow Fault In Watchdog  faultID=7319  #fault_name: No X2 link available for a specific LTEENB

ALD.14_ALD_Detect_and_setup_AL_devices_start-up.Test Case Teardown
    [Arguments]  ${SEND_SNAPSHOT_FOR_SCRAMBLING}=${False}
    Run Keywords
    ...  ALD.14_ALD_Detect_and_setup_AL_devices_start-up.Test Specific Teardown
    ...  AND  common.Common Test Teardown  ${SEND_SNAPSHOT_FOR_SCRAMBLING}
