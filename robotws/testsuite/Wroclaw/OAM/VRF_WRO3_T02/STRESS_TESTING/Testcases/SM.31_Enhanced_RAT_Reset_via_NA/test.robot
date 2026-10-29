*** Settings ***
Resource    ../../../resources_mem/common.robot
Resource    ../../../resources_mem/alarms.robot
Resource    ../../../resources_mem/ald.robot
Resource    ../../../resources_mem/netact.robot
Resource    ../../../resources_mem/power_saving.robot
Resource    ../../../resources_mem/L3_call.robot

Documentation
...  TEST NAME:     SM.31_Enhanced_RAT_Reset_via_NA
...  AUTHORS:       jakub.hirny@nokia.com
...  MAINTAINER:    RAN_PZ_WRO_3_SG01
...  *****************
...  Basic information
...  *****************
...  This User Scenario describes how to perform enhanced RAT reset from NetAct by using Open API with Graceful Cell Shutdown inactive.
...  *****************
...  Pre-conditions
...  *****************
...  BTS-NetAct M-Plane connection is working
...  ACTIONS NIDD adaptation is supported by SW releases on both NetAct and BTS
...  SRNCLAB with "pure trunk base"
...  NetActTrunk - NetAct - 99.23.04.0.96 (or higher)
...  ******************
...  History of changes
...  ******************
...  11.09.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-436 - TC creation
...  *******************
...  RAN PZ3 WRO1 TEMPLATE




*** Keywords ***
SM.31_Enhanced_RAT_Reset_via_NA
    SM.31_Enhanced_RAT_Reset_via_NA.Test_Step:0 Test Preparation
    SM.31_Enhanced_RAT_Reset_via_NA.Test_Step:1 Resetting RAT
    SM.31_Enhanced_RAT_Reset_via_NA.Test_Step:2 Final Checkpoint

SM.31_Enhanced_RAT_Reset_via_NA.Test_Step:0 Test Preparation
    Log to console    \n========================================
    Log  Step: 0 Test Preparation  console=${True}
    Log to console    ========================================
    ${COUNTER_BEFORE_TEST}=  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}
    ${fhs}=  Run Keyword And Return Status  Check For FHS
    Set Test Variable  ${fhs_exists}  ${fhs}
    ${rats}=  Detect RATs
    FOR  ${rat}  IN  @{rats}
        ${gsm_or_wcdma}=  Run Keyword And Return Status  Should Contain Any  '${rat}'  gsm  wcdma
        Run Keyword If  ${gsm_or_wcdma}
        ...  Remove Values From List  ${rats}  ${rat}
    END
    Set Test Variable    ${rats}
    ${lte_or_nr}=  Run Keyword And Return Status  Should Contain Any  ${rats}  lte  nr
    Run Keyword If  ${lte_or_nr}
    ...  Log    ==Detected RATs suitable for Enhanced Reset: ${rats}==  console=true
    ...  ELSE  Fail  msg=There is no RAT suitable for Enhanced Reset.
    netact.Upload Configuration  dist_names=PLMN-PLMN/MRBTS-${MRBTS_ID}

SM.31_Enhanced_RAT_Reset_via_NA.Test_Step:1 Resetting RAT
    Log to console    \n========================================
    Log  Step: 1 Perform RAT reset with actRatResetEnhancement activated  console=${True}
    Log to console    ========================================
    FOR  ${rat}  IN  @{rats}
        Log  ==Resetting ${rat}...==  console=true
        Run Keyword If  '${rat}' == 'lte'  Run Keywords
        ...  Set Test Variable    ${RAT_ID}  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}
        ...  AND  Allow Fault In Watchdog  faultID=7300  #fault_name: No X2 link available
        ...  AND  Allow Fault In Watchdog  faultID=7319  #fault_name: No X2 link available for a specific LTEENB
        ...  AND  Allow Fault In Watchdog  faultID=7107  #Cell problem due to associated X2/NG/E1 link unavailability
        Run Keyword If  '${rat}' == 'nr'  Run Keywords
        ...  Set Test Variable    ${RAT_ID}  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
        ...  AND  Allow Fault In Watchdog  faultID=7300  #fault_name: No X2 link available
        ...  AND  Allow Fault In Watchdog  faultID=7319  #fault_name: No X2 link available for a specific LTEENB
        ...  AND  Allow Fault In Watchdog  faultID=7107  #Cell problem due to associated X2/NG/E1 link unavailability
        ...  AND  Run Keyword If  ${fhs_exists}  Allow Fault In Watchdog  faultID=10  #No connection to unit (visible on FHS)
        ${time_before}=  Get Current Date
        netact.Reset NE  dist_names=${RAT_ID}  parameters=gracefulCellShutdown=false  timeout=700
        ${time_after}=  Get Current Date
        ${diff}=  Subtract Date From Date  ${time_after}  ${time_before}
        Should Be True  ${diff}<200  #OM_GEN_SFS_PERF_CAP.26204
        Log  ==Reset of ${rat} is done==  console=true
        Log  ==Reset time was ${diff}==  console=true
        Check If NLWG Cells Are OnAir
        Disallow Fault In Watchdog  faultID=7300  #fault_name: No X2 link available
        Disallow Fault In Watchdog  faultID=7319  #fault_name: No X2 link available for a specific LTEENB
        Disallow Fault In Watchdog  faultID=7107  #Cell problem due to associated X2/NG/E1 link unavailability
        Disallow Fault In Watchdog  faultID=10  #No connection to unit (visible on FHS)
    END

SM.31_Enhanced_RAT_Reset_via_NA.Test_Step:2 Final Checkpoint
    Log to console    \n========================================
    Log  Step: 2 Final Checkpoint  console=${True}
    Log to console    ========================================
    ${COUNTER_AFTER_TEST}=  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}
    Run Keywords
    ...  Check SMODs State  ${SMOD_expected_states}
	...  AND  Check RMODs State  ${RMOD_expected_states}
	...  AND  Check If ALDs Are Connected And Achieved Expected State
	...  AND  common.Check BTS State  ${BTS_expected_states}
	...  AND  Check If NLWG Cells Are OnAir
	...  AND  Check If Unexpected Alarms Are Raised  ${skip_fault}

Check For FHS
    ${bts_info}=  Get BTS Info
    ${object}=  Set variable  ${bts_info['fhs']}
    ${num_of_fhs}=  Get Length  ${object}
    Run Keyword If  ${num_of_fhs}==${0}
    ...  Fail
    ...  ELSE  No Operation
