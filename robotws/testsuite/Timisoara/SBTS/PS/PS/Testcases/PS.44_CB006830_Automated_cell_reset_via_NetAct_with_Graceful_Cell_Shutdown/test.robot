*** Settings ***
Resource    ../../../resources/common.robot
Resource    ../../../resources/alarms.robot
Resource    ../../../resources/ald.robot
Resource    ../../../resources/netact.robot
Resource    ../../../resources/power_saving.robot
Resource    ../../../resources/L3_call.robot

Documentation
...  TEST NAME:     PS.44_CB006830_Automated_cell_reset_via_NetAct_with_Graceful_Cell_Shutdown
...  AUTHORS:       mateusz.gumieniak@nokia.com
...  MAINTAINER:    RAN_PZ_WRO_3_SG01
...  *****************
...  Basic information
...  *****************
...  This User Scenario performs graceful cell reset from NetAct by using Open API.
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
...  19.09.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-375 - TC creation
...  *******************
...  RAN PZ3 WRO1 TEMPLATE


*** Keywords ***
PS.44_CB006830_Automated_cell_reset_via_NetAct_with_Graceful_Cell_Shutdown
    PS.44_CB006830_Automated_cell_reset_via_NetAct_with_Graceful_Cell_Shutdown.Test_Step:0 Test Preparation
    PS.44_CB006830_Automated_cell_reset_via_NetAct_with_Graceful_Cell_Shutdown.Test_Step:1 Setup Shutdowns
    PS.44_CB006830_Automated_cell_reset_via_NetAct_with_Graceful_Cell_Shutdown.Test_Step:2 Resetting Cell
    PS.44_CB006830_Automated_cell_reset_via_NetAct_with_Graceful_Cell_Shutdown.Test_Step:3 Final Checkpoint

PS.44_CB006830_Automated_cell_reset_via_NetAct_with_Graceful_Cell_Shutdown.Test_Step:0 Test Preparation
    Log to console    \n========================================
    Log  Step: 0 Test Preparation  console=${True}
    Log to console    ========================================
    ${COUNTER_BEFORE_TEST}=  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}
    Check which RAT are on given TestLine
    ${cells_list}  Get cell list
    ${cells_list['cells']['lte']}  Ignore IoT Cells
    @{selected_cells}    Create List
    @{cell_tech_list}    Create List
    IF    '${IF_GSM_EXIST}'=='EXIST'    Append To List    ${cell_tech_list}    gsm
    IF    '${IF_WCDMA_EXIST}'=='EXIST'    Append To List    ${cell_tech_list}    wcdma
    IF    '${IF_LTE_EXIST}'=='EXIST'    Append To List    ${cell_tech_list}    lte
    IF    '${IF_NR_EXIST}'=='EXIST'    Append To List    ${cell_tech_list}    nr
    FOR    ${tech}    IN    @{cell_tech_list}
        ${cell_dict}   Evaluate  random.choice(${cells_list['cells']['${tech}']})  random
        Append To List    ${selected_cells}    ${cell_dict['id']['configuration']}
    END
    Set Test Variable    @{cell_tech_list}
    Set Test Variable    @{selected_cells}
    Log to console  choosen cell technology order: ${cell_tech_list}
    Log to console  choosen cells: ${selected_cells}

PS.44_CB006830_Automated_cell_reset_via_NetAct_with_Graceful_Cell_Shutdown.Test_Step:1 Setup Shutdowns
    IF  '${IF_LTE_EXIST}'=='EXIST' and '${IF_NR_EXIST}'=='EXIST'
        Log to console    \n========================================
        Set Parameters For LTE Graceful Cell Shutdown  enableGrflShdn=Enabled  shutdownStepAmount=6  shutdownWindow=60s
        Log to console    \n========================================
        Set Parameters For NR Graceful Cell Shutdown  actGrflShdn=true  shutdownStepAmount=6  shutdownWindow=60s
    ELSE IF  '${IF_LTE_EXIST}'=='EXIST' and '${IF_NR_EXIST}'=='NO'
        Log to console    \n========================================
        Set Parameters For LTE Graceful Cell Shutdown  enableGrflShdn=Enabled  shutdownStepAmount=6  shutdownWindow=60s
    ELSE IF  '${IF_NR_EXIST}'=='EXIST' and '${IF_LTE_EXIST}'=='NO'
        Log to console    \n========================================
        Set Parameters For NR Graceful Cell Shutdown  actGrflShdn=true  shutdownStepAmount=6  shutdownWindow=60s
    END

PS.44_CB006830_Automated_cell_reset_via_NetAct_with_Graceful_Cell_Shutdown.Test_Step:2 Resetting Cell
    Log to console    \n========================================
    Log  Test_Step:1 Resetting Cell  console=${True}
    Log to console    ========================================
    #tu walnij fora
    FOR    ${i}    ${tech}    IN ENUMERATE    @{cell_tech_list}
        ${time_before}=  Get Current Date
        Log to console    Reset: PLMN-PLMN/${selected_cells[${i}]}
        netact.Reset NE    dist_names=PLMN-PLMN/${selected_cells[${i}]}
        ${start_graceful_time}=  Get Current Date
        Sleep    20s
		Check graceful cell shutdown  ${start_graceful_time}  ${selected_cells[${i}]}  ${tech}
        ${time_after}=  Get Current Date
        ${diff}=  Subtract Date From Date  ${time_after}  ${time_before}
        IF  "${tech}"=="gsm"  Should Be True  ${diff}<270  #OM_GEN_SFS_PERF_CAP.26578
        IF  "${tech}"!="gsm"  Should Be True  ${diff}<210  #OM_GEN_SFS_PERF_CAP.26578
        Log  ==Reset time is ${diff}==  console=true
        Log  ==Reset ${selected_cells[${i}]} is done==  console=true
        Wait Until Keyword Succeeds  5min  20s  Check Syslog For Graceful Cell Shutdown Messages  ${tech}
        Wait until keyword succeeds  10x  20s  Check If NLWG Cells Are OnAir
    END

PS.44_CB006830_Automated_cell_reset_via_NetAct_with_Graceful_Cell_Shutdown.Test_Step:3 Final Checkpoint
    Log to console    \n========================================
    Log  Step: 3 Final Checkpoint  console=${True}
    Log to console    ========================================
    ${COUNTER_AFTER_TEST}=  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}
    Run Keywords
    ...  Check SMODs State  ${SMOD_expected_states}
	...  AND  Check RMODs State  ${RMOD_expected_states}
	...  AND  Check If ALDs Are Connected And Achieved Expected State
	...  AND  Check BTS State  ${BTS_expected_states}
	...  AND  Check If NLWG Cells Are OnAir
	...  AND  Check If Unexpected Alarms Are Raised  ${skip_fault}

PS.44_CB006830_Automated_cell_reset_via_NetAct_with_Graceful_Cell_Shutdown.Restore_Shutdown_Windows
    Log to console    \n========================================
    Log  Step: Test Specific Teardown  console=${True}
    Log to console    ========================================
    IF  '${IF_LTE_EXIST}'=='EXIST' and '${IF_NR_EXIST}'=='EXIST'
        Set Feature Under Given Object  ${LNBTS_DistName}  enableGrflShdn  Disabled
        Set Feature Under Given Object  ${LNBTS_DistName}  shutdownWindow  180
        Set Feature Under Given Object  ${NRBTS_DistName}  actGrflShdn  false
        Set Feature Under Given Object  ${NRBTS_DistName}  shutdownWindow  180
    ELSE IF  '${IF_LTE_EXIST}'=='EXIST' and '${IF_NR_EXIST}'=='NO'
        Set Feature Under Given Object  ${LNBTS_DistName}  enableGrflShdn  Disabled
        Set Feature Under Given Object  ${LNBTS_DistName}  shutdownWindow  180
    ELSE IF  '${IF_NR_EXIST}'=='EXIST' and '${IF_LTE_EXIST}'=='NO'
        Set Feature Under Given Object  ${NRBTS_DistName}  actGrflShdn  false
        Set Feature Under Given Object  ${NRBTS_DistName}  shutdownWindow  180
    END

PS.44_CB006830_Automated_cell_reset_via_NetAct_with_Graceful_Cell_Shutdown.Test_Specific_Teardown
    PS.44_CB006830_Automated_cell_reset_via_NetAct_with_Graceful_Cell_Shutdown.Restore_Shutdown_Windows
    Run Keywords  common.Common Test Teardown  AND  Teardown TAF Netact

Check graceful cell shutdown
    [Arguments]  ${time_before}  ${selected_cell}  ${technology}
    IF  "${technology}"!="wcdma"  NR/LTE/GSM variant  ${time_before}    ${selected_cell}
    IF  "${technology}"=="wcdma"  WCDMA variant  ${time_before}    ${selected_cell}

NR/LTE/GSM variant
    [Arguments]  ${time_before}    ${selected_cell}
    FOR    ${i}    IN RANGE    0    60
		Sleep   20 s    #added for NR mMIMO on AEHC(< 220s = estimated 150s reset opearation + 60s test shutdown window + 10s)
        ${current_date}  Get Current Date
        ${result}  Subtract Date From Date  ${current_date}    ${time_before}
        Exit For Loop If  ${result} >= 54
        Check cell_m operational state  ${selected_cell}  Enabled
        Sleep  1 s
    END
    Log to console  NR/LTE/GSM variant

WCDMA variant
    [Arguments]  ${time_before}    ${selected_cell}
    FOR    ${i}    IN RANGE    0    45
        ${current_date}  Get Current Date
        ${result}  Subtract Date From Date  ${time_before}  ${current_date}
        Exit For Loop If  ${result} >= 45
        Check cell_m operational state  ${selected_cell}  Enabled
        Sleep  1 s
    END
    Log to console  WCDMA variant
