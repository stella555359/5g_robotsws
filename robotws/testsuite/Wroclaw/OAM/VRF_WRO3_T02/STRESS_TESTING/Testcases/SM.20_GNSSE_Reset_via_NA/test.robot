*** Settings ***
Resource    ../../../resources_mem/common.robot
Resource    ../../../resources_mem/alarms.robot
Resource    ../../../resources_mem/ald.robot
Resource    ../../../resources_mem/netact.robot
Resource    ../../../resources_mem/power_saving.robot
Resource    ../../../resources_mem/L3_call.robot

Documentation
...  TEST NAME:     SM.20_GNSSE_Reset_via_NA
...  AUTHORS:       damian.sliwinski@nokia.com
...  MAINTAINER:    RAN_PZ_WRO_3_SG01
...  *****************
...  Basic information
...  *****************
...  The purpose of this test case is to check if GNSSE reset procedure works correctly from NetAct by using Open API.
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
...  02.05.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-361 - TC creation
...  *******************
...  RAN PZ3 WRO1 TEMPLATE



*** Keywords ***
SM.20_GNSSE_Reset_via_NA

    SM.20_GNSSE_Reset_via_NA.Test_Step:0 Test Preparation
    SM.20_GNSSE_Reset_via_NA.Test_Step:1 Resetting GNSSE
    SM.20_GNSSE_Reset_via_NA.Test_Step:2 Final Checkpoint

SM.20_GNSSE_Reset_via_NA.Test_Step:0 Test Preparation
    Log to console    \n========================================
    Log  Step: 0 Test Preparation  console=${True}
    Log to console    ========================================
    ${COUNTER_BEFORE_TEST}=  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}
#    Set Test Variable  ${COUNTER_BEFORE_TEST}
    ${bts_info}=  admin.get bts info
    ${gnsse}=  Create List
    FOR  ${item}  IN  @{bts_info['gnsse']}
        Append To List  ${gnsse}  ${item['id']['configuration']}
    END
    ${num_of_gnsse}=  Get Length  ${gnsse}
    Run Keyword If  ${num_of_gnsse}==${0}
    ...  Fail  msg=There is no at least one GNSSE in configuration
    netact.Upload Configuration  dist_names=PLMN-PLMN/MRBTS-${MRBTS_ID}
    ${chosen_gnsse}=  Evaluate  random.choice(${gnsse})  random
    Set Test Variable  ${chosen_gnsse}

SM.20_GNSSE_Reset_via_NA.Test_Step:1 Resetting GNSSE
    Log to console    \n========================================
    Log  Test_Step:1 Resetting GNSSE  console=${True}
    Log to console    ========================================
    Log To Console  Resetting GNSSE: ${chosen_gnsse}
    ${time_before}=  Get Current Date
    netact.Reset NE  dist_names=PLMN-PLMN/${chosen_gnsse}
    ${time_after}=  Get Current Date
    ${diff}=  Subtract Date From Date  ${time_after}  ${time_before}
    Should Be True  ${diff}<120  #OM_GEN_SFS_PERF_CAP.26574
    wait until Keyword Succeeds  12x  10s  Check if GNSSE is resetting
    wait until Keyword Succeeds  12x  10s  Check if GNSSE is available

Check if GNSSE is resetting
    ${gnsse_info}  Get Gnsses Statuses
    Dictionary Should Contain Key  ${gnsse_info['GNSSE_R-1']}  availabilityStatus
    ${availability_status}  Get from dictionary  ${gnsse_info['GNSSE_R-1']}  availabilityStatus
    Should be equal  ${availability_status}  degraded

Check if GNSSE is available
    ${gnsse_info}  Get Gnsses Statuses
    Dictionary Should Not Contain Key  ${gnsse_info['GNSSE_R-1']}  availabilityStatus

SM.20_GNSSE_Reset_via_NA.Test_Step:2 Final Checkpoint
    Log to console    \n========================================
    Log  Step: 2 Final Checkpoint  console=${True}
    Log to console    ========================================
    ${COUNTER_AFTER_TEST}=  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}
    Run Keywords
    ...  Check SMODs State  ${SMOD_expected_states}
	...  AND  Check RMODs State  ${RMOD_expected_states}
	...  AND  Check ALDs State  ${ALD_expected_states}
	...  AND  common.Check BTS State  ${BTS_expected_states}
	...  AND  Check If NLWG Cells Are OnAir
    ...  AND  Wait Until Keyword Succeeds  7x  10s  Check Cells State In Netact
	...  AND  Check If Unexpected Alarms Are Raised  ${skip_fault}
