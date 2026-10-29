*** Settings ***
Resource    ../../resources/common.robot
Resource    ../../resources/alarms.robot
Resource    ../../resources/ald.robot
Resource    ../../resources/power_saving.robot

Documentation
...  TEST NAME:     ALD.12_ALD_Detect_and_setup_AL_devices_Lock_Unlock
...  AUTHORS:       tomasz.marchewka@nokia.com
...  MAINTAINER:    RAN_PZ_WRO_3_SG01
...  *****************
...  Basic information
...  *****************
...  The purpose of this test case is to check if Antenna Line Devices (MHA/RET) are detected and work properly
...  after radio modules Lock/Unlock procedure.
...  *****************
...  Pre-conditions
...  *****************
...  N/A
...  ******************
...  History of changes
...  *****************
...  03.12.2020 - https://jira3.int.net.nokia.com/browse/TAT-20582 - test creation
...  10.12.2020 - https://jira3.int.net.nokia.com/browse/TAT-20637
...  28.07.2021 - https://jira3.int.net.nokia.com/browse/TAT-21673
...  18.10.2021 - https://jiradc.ext.net.nokia.com/browse/TAW-13 - Adaptation to CNI-61110
...  06.12.2021 - https://jiradc.ext.net.nokia.com/browse/TAW-36 - Switch to hran_frame_sbts_siso resource
...  20.04.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-150 - Adaptation to CNI-82119 and migration from hran_ta to robotlte repository
...  *******************
...  RAN PZ3 WRO1 TEMPLATE


*** Keywords ***
ALD.12_ALD_Detect_and_setup_AL_devices_Lock_Unlock

	ALD.12_ALD_Detect_and_setup_AL_devices_Lock_Unlock.Test_Step.0 Check If ALDs Are In Configuration
    ALD.12_ALD_Detect_and_setup_AL_devices_Lock_Unlock.Test_Step.1 RF lock/unlock procedure with state checking
    ALD.12_ALD_Detect_and_setup_AL_devices_Lock_Unlock.Test_Step.2 FEG calculation

ALD.12_ALD_Detect_and_setup_AL_devices_Lock_Unlock.Test_Step.0 Check If ALDs Are In Configuration
    [Documentation]  Test step which checking if ALDs are in configuration.
    Log to console    \n========================================
    Log  Step: 0 Test Preparation  console=${True}
    Log to console    ========================================
    ${ALD_R_RAEs}  ${ALD_R_MHAs}  ${ALD_R_RETs}
    ...  ${ALD_R_ALL}  ${num_of_RAEs}  ${num_of_MHAs}  ${num_of_RETs}  ${num_of_ALDs}  Sorting ALD_R by type
    Set Test Variable  ${num_of_RETs}
    Set Test Variable  ${num_of_MHAs}
    Set Test Variable  ${ALD_R_RETs}
    Set Test Variable  ${ALD_R_MHAs}
    IF  ${num_of_MHAs}==${0} and ${num_of_RETs}==${0}  Fail  msg=There is no at least one ALD in configuration
    Log  You have ${num_of_MHAs} MHAs and ${num_of_RETs} RETs in configuration  console=${True}

ALD.12_ALD_Detect_and_setup_AL_devices_Lock_Unlock.Test_Step.1 RF lock/unlock procedure with state checking
   [Documentation]
   ...    1. Lock RM module.
   ...    2. Check connection ALD to RM modules.
   ...    3. Check ALD state after RM lock.
   ...    4. Unlock RM module.
    Log to console    \n========================================
    Log  Step: 1 RF lock/unlock procedure with state checking  console=${True}
    Log to console    ========================================
    ${rmod_dist_r}=   admin.get ids for all  RMOD
    FOR  ${rmod_dist}  IN  @{rmod_dist_r}
        ${rmod}=  Should Match Regexp  ${rmod_dist}  RMOD_R-\\d+
        Log  Locking ${rmod}  console=${true}
        admin.lock  ${rmod_dist}  timeout=240
        Sleep  30s
        ${ALD_DC}  ${ALD_conf}  Check ALD With Rmod Connection  ${rmod}
        Log  Checking ALD state after ${rmod} lock:  console=${True}
        Check ALD State After RM Lock  ${ALD_DC}  ${ALD_conf}
        Log  Unlocking ${rmod}  console=${true}
        admin.unlock  ${rmod_dist}  timeout=240
        Sleep  60s
        Log  Checking ALD state after ${rmod} unlock:
        Check ALDs State  ${ALD_expected_states}
    END
    Check If Unexpected Alarms Are Raised  ${skip_fault}

ALD.12_ALD_Detect_and_setup_AL_devices_Lock_Unlock.Test_Step.2 FEG calculation
    [Documentation]  This keyword is checking if front end gain is calculated properly.
    Log to console    \n========================================
    Log  Step: 2 FEG calculation  console=${True}
    Log to console    ========================================
    Check FEG On Antl Without MHA
    Check FEG On Antl With MHA

ALD.12_ALD_Detect_and_setup_AL_devices_Lock_Unlock.Test Specific Teardown
    [Documentation]  Test teardown which unlock all RMODs.
    Log  \nUnlock All RMODs  console=${True}
    ${rmod_list}=  admin.get ids for all  RMOD
    FOR  ${i}  IN  @{rmod_list}
        Run Keyword And Ignore Error  admin.unlock  ${i}  timeout=240
        Sleep  60s
    END

ALD.12_ALD_Detect_and_setup_AL_devices_Lock_Unlock.Test Case Teardown
    [Arguments]  ${SEND_SNAPSHOT_FOR_SCRAMBLING}=${False}
    Run Keyword If Test Failed  ALD.12_ALD_Detect_and_setup_AL_devices_Lock_Unlock.Test Specific Teardown
    Run Keyword  common.Common Test Teardown  ${SEND_SNAPSHOT_FOR_SCRAMBLING}
