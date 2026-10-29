*** Settings ***
Resource    ../../../resources_mem/common.robot
Resource    ../../../resources_mem/alarms.robot
Resource    ../../../resources_mem/ald.robot
Resource    ../../../resources_mem/netact.robot
Resource    ../../../resources_mem/power_saving.robot
Resource    ../../../resources_mem/L3_call.robot

Documentation
...  TEST NAME:     SM.21_FHS_Reset_via_NA
...  AUTHORS:       jakub.hirny@nokia.com
...  MAINTAINER:    RAN_PZ_WRO_3_SG01
...  *****************
...  Basic information
...  *****************
...  The purpose of this test case is to check if FHS reset procedure works correctly from NetAct by using Open API.
...  *****************
...  Pre-conditions
...  *****************
...  - BTS-NetAct M-Plane connection is working
...  - ACTIONS NIDD adaptation is supported by SW releases on both NetAct and BTS
...  - SRNCLAB with "pure trunk base"
...  - NetActTrunk - NetAct - 99.23.04.0.96 (or higher)
...  ******************
...  History of changes
...  ******************
...  10.05.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-357 - TC creation
...  31.07.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-381 - tests adaptation for CB006830 (graceful cell shutdown)
...  05.03.2024 - https://jiradc.ext.net.nokia.com/browse/TAW-556 - Extend Reset NE command timeout
...  *******************
...  RAN PZ3 WRO1 TEMPLATE




*** Keywords ***
SM.21_FHS_Reset_via_NA
    SM.21_FHS_Reset_via_NA.Test_Step:0 Test Preparation
    SM.21_FHS_Reset_via_NA.Test_Step:1 Resetting FHS
    SM.21_FHS_Reset_via_NA.Test_Step:2 Final Checkpoint

SM.21_FHS_Reset_via_NA.Test_Step:0 Test Preparation
    Log to console    \n========================================
    Log  Step: 0 Test Preparation  console=${True}
    Log to console    ========================================
    ${COUNTER_BEFORE_TEST}=  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}
    ${bts_info}  Get BTS Info
    ${fhs}  Set variable  ${bts_info['fhs']}
    ${num_of_fhss}=  Get Length  ${fhs}
    Run Keyword If  ${num_of_fhss}==${0}
    ...  Fail  msg=There isn't at least one FHS in configuration
    ${fhs_dict}   Evaluate  random.choice(${fhs})  random
    Set test variable    ${selected_fhs}    ${fhs_dict['id']['configuration']}
    netact.Upload Configuration  dist_names=PLMN-PLMN/MRBTS-${MRBTS_ID}
    Log to console  Selected FHS to reset is ${selected_fhs}

SM.21_FHS_Reset_via_NA.Test_Step:1 Resetting FHS
    Log to console    \n========================================
    Log  Step: 1 Resetting FHS  console=${True}
    Log to console    ========================================
    ${time_before}=  Get Current Date
    ${check_sw}=  Run Keyword And Return Status  Should Not Contain  ${active_sw_version}  23R
    Run Keyword If  ${check_sw}
    ...  netact.Reset NE    dist_names=PLMN-PLMN/${selected_fhs}  parameters=gracefulCellShutdown=false  verbose=True  timeout=190
    ...  ELSE  netact.Reset NE    dist_names=PLMN-PLMN/${selected_fhs}  verbose=True  timeout=190
    ${time_after}=  Get Current Date
    Log    ==Checking FHSs state:==\n == - reset FHS should be DISABLED== \n == - the rest of the FHSs should remain ENABLED==  console=True
    ${bts_info}  Get BTS Info
    ${fhss}  Set variable  ${bts_info['fhs']}
    FOR  ${fhs}  IN  @{fhss}
        ${fhs_states}  Get from dictionary  ${fhs}  stateInfo
        ${operational_state}  Get from dictionary  ${fhs_states}  operationalState
        Run keyword and ignore error    Run keyword if  '${fhs['id']['configuration']}' == '${selected_fhs}'
        ...  Should Be Equal As Strings  ${operational_state}  disabled  ignore_case=True
        ...  ELSE    Should Be Equal As Strings  ${operational_state}  enabled  ignore_case=True
        ${administrative_state}  Get from dictionary  ${fhs_states}  administrativeState
        Should Be Equal As Strings  ${administrative_state}  Unlocked  ignore_case=True
    END
    ${diff}=  Subtract Date From Date  ${time_after}  ${time_before}
    Should Be True  ${diff}<200  #OM_GEN_SFS_PERF_CAP.26575 + 10s for NetAct sync
    Log  ==Reset time is ${diff}==  console=true
    Log  ==Reset of ${selected_fhs} is done==  console=true
    Check If NLWG Cells Are OnAir
    Wait Until Keyword Succeeds  7x  10s  Check Cells State In Netact

SM.21_FHS_Reset_via_NA.Test_Step:2 Final Checkpoint
    Log to console    \n========================================
    Log  Step: 2 Final Checkpoint  console=${True}
    Log to console    ========================================
    ${COUNTER_AFTER_TEST}=  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}
    Run Keywords
    ...  Check SMODs State  ${SMOD_expected_states}
	...  AND  Check FHSs State
	...  AND  Check RMODs State  ${RMOD_expected_states}
	...  AND  Check If ALDs Are Connected And Achieved Expected State
#	...  AND  Check ALDs State  ${ALD_expected_states}
	...  AND  common.Check BTS State  ${BTS_expected_states}
	...  AND  Check If NLWG Cells Are OnAir
    ...  AND  Wait Until Keyword Succeeds  7x  10s  Check Cells State In Netact
	...  AND  Check If Unexpected Alarms Are Raised  ${skip_fault}
