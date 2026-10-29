*** Settings ***
Resource    ../../../resources_mem/common.robot
Resource    ../../../resources_mem/alarms.robot
Resource    ../../../resources_mem/ald.robot
Resource    ../../../resources_mem/netact.robot
Resource    ../../../resources_mem/power_saving.robot
Resource    ../../../resources_mem/L3_call.robot

Documentation
...  TEST NAME:     SM.27_Site_Reset_via_NA
...  AUTHORS:       tomasz.januszkiewicz@nokia.com
...  MAINTAINER:    RAN_PZ_WRO_3_SG01
...  *****************
...  Basic information
...  *****************
...  This User Scenario describes how to perform site reset from NetAct by using Open API.
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
...  08.05.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-355 - TC creation
...  31.07.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-381 - tests adaptation for CB006830 (graceful cell shutdown)
...  *******************
...  RAN PZ3 WRO1 TEMPLATE


*** Keywords ***
SM.27_Site_Reset_via_NA

    SM.27_Site_Reset_via_NA.Test_Step:0 Test Preparation
    SM.27_Site_Reset_via_NA.Test_Step:1 Resetting Site
    SM.27_Site_Reset_via_NA.Test_Step:2 Final Checkpoint

SM.27_Site_Reset_via_NA.Test_Step:0 Test Preparation

    Log to console    \n========================================
    Log  Step: 0 Test Preparation  console=${True}
    Log to console    ========================================
    ${COUNTER_BEFORE_TEST}=  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}
#    Set Test Variable  ${COUNTER_BEFORE_TEST}
    netact.Upload Configuration  dist_names=PLMN-PLMN/MRBTS-${MRBTS_ID}

SM.27_Site_Reset_via_NA.Test_Step:1 Resetting Site

    Log to console    \n========================================
    Log  Test_Step:1 Resetting Site  console=${True}
    Log to console    ========================================
    Check which RAT are on given TestLine
    Run Keyword If  '${IF_NR_EXIST}'=='EXIST'  Run Keywords
    ...  Allow Fault In Watchdog  faultID=6327  #fault_name: Setup of X2 connectivity to gNB failed
    ...  AND  Allow Fault In Watchdog  faultID=7300  #fault_name: No X2 link available
    ...  AND  Allow Fault In Watchdog  faultID=7319  #fault_name: No X2 link available for a specific LTEENB
    ${time_before}=  Get Current Date
    ${check_sw}=  Run Keyword And Return Status  Should Not Contain  ${active_sw_version}  23R
    @{parameters}    Create List    btsResetType=btsSiteReset    gracefulCellShutdown=false
    Run Keyword If  ${check_sw}
    ...        netact.Reset NE    dist_names=PLMN-PLMN/MRBTS-${MRBTS_ID}    parameters=${parameters}                verbose=True
    ...  ELSE  netact.Reset NE    dist_names=PLMN-PLMN/MRBTS-${MRBTS_ID}    parameters=btsResetType=btsSiteReset    verbose=True
    ${time_after}=  Get Current Date
    ${diff}=  Subtract Date From Date  ${time_after}  ${time_before}
    Should Be True  ${diff}<360  #OM_GEN_SFS_PERF_CAP.26203
    Log  ==Reset time is ${diff}==  console=true
    Run Keywords
    ...  Check SMODs State  ${SMOD_expected_states}
	...  AND  Check RMODs State  ${RMOD_expected_states}
	...  AND  Check If ALDs Are Connected And Achieved Expected State
#	...  AND  Check ALDs State  ${ALD_expected_states}
	...  AND  common.Check BTS State  ${BTS_expected_states}
	...  AND  Check If NLWG Cells Are OnAir
    ...  AND  Wait Until Keyword Succeeds  7x  10s  Check Cells State In Netact
	...  AND  Check If Unexpected Alarms Are Raised  ${skip_fault}
    Run Keyword If  '${IF_NR_EXIST}'=='EXIST'  Run Keywords  Wait Until Keyword Succeeds  10min  1min  Check X2 Link
    ...  AND  Disallow Fault In Watchdog  faultID=6327  #fault_name: Setup of X2 connectivity to gNB failed
    ...  AND  Disallow Fault In Watchdog  faultID=7300  #fault_name: No X2 link available
    ...  AND  Disallow Fault In Watchdog  faultID=7319  #fault_name: No X2 link available for a specific LTEENB

SM.27_Site_Reset_via_NA.Test_Step:2 Final Checkpoint

    Log to console    \n========================================
    Log  Step: 3 Final Checkpoint  console=${True}
    Log to console    ========================================
    ${COUNTER_AFTER_TEST}=  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}
    Run Keywords
    ...  Check SMODs State  ${SMOD_expected_states}
	...  AND  Check RMODs State  ${RMOD_expected_states}
	...  AND  Check If ALDs Are Connected And Achieved Expected State
#	...  AND  Check ALDs State  ${ALD_expected_states}
	...  AND  common.Check BTS State  ${BTS_expected_states}
	...  AND  Check If NLWG Cells Are OnAir
    ...  AND  Wait Until Keyword Succeeds  7x  10s  Check Cells State In Netact
	...  AND  Check If Unexpected Alarms Are Raised  ${skip_fault}
