*** Settings ***
Resource    ../../../resources/common.robot
Resource    ../../../resources/alarms.robot
Resource    ../../../resources/ald.robot
Resource    ../../../resources/power_saving.robot
Resource    ../../../resources/L3_call.robot

Documentation
...  TEST NAME:     PS.30_CB008745_Switching_On_Tx_Path_LTE
...  AUTHORS:       roscislaw.szuminski@nokia.com
...  MAINTAINER:    RAN_PZ_WRO_3_SG01
...  *****************
...  Basic information
...  *****************
...  Purpose of this test case is to verify if 4G cells switching off/on tx procedure work properly
...  *****************
...  Pre-conditions
...  This test is dedicated for TL: 53103
...  *****************
...  N/A
...  ******************
...  History of changes
...  ******************
...  01.02.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-306 - Test case creation
...  27.07.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-386 - Increase tput for CB008745
...  15.12.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-489 - New KW Unbarring all cells added to teardowns
...  07.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAW-526 - added Stop tracing and download logs from SMOD to teardown
...  *******************
...  RAN PZ3 WRO1 TEMPLATE


*** Keywords ***
PS.30_CB008745_Switching_On_Tx_Path_LTE

    PS.30_CB008745_Switching_On_Tx_Path_LTE.Test_Step:0 Test Preparation
    PS.30_CB008745_Switching_On_Tx_Path_LTE.Test_Step:1 Disable Feature Before Test
    PS.30_CB008745_Switching_On_Tx_Path_LTE.Test_Step:2 Create PSGRP and pre-configure for PSG control logic improvement
    PS.30_CB008745_Switching_On_Tx_Path_LTE.Test_Step:3 Activate PSG Control Logic Improvement for 4G
    PS.30_CB008745_Switching_On_Tx_Path_LTE.Test_Step:4 Check if selected cells reach applicable states
    PS.30_CB008745_Switching_On_Tx_Path_LTE.Test_Step:5 Final Recovery and Checkpoint

PS.30_CB008745_Switching_On_Tx_Path_LTE.Test_Step:0 Test Preparation
    Log to console  \n========================================
    Log  Step: 0 Test Preparation  console=${True}
    Log to console  ========================================
    ${COUNTER_BEFORE_TEST}=  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}
    Set Test Variable  ${COUNTER_BEFORE_TEST}
    Set Test Variable  ${ue}  NOKIA83
    Set Test Variable  ${RESULTS}
###    Select Two Random LTE Cells
    @{feature_flags}=  Create List  actLbpsCtrlLogicEnh  actLBRTXPowerSaving
    Set Test Variable  ${feature_flags}

    Run Keyword If    '${MRBTS_ID}' == '10817'    Select Two Random LTE Cells for 10817
    Run Keyword If    '${MRBTS_ID}' == '10818'    Select Two LTE Cells for 10818
    ...    ELSE    Select Two Random LTE Cells

    Set Test Variable  ${1st_LNCEL_ID}  ${1st_LNCEL_ID}
    Set Test Variable  ${1st_LNCEL_DN}  ${1st_LNCEL_DN}
    Set Test Variable  ${2nd_LNCEL_ID}  ${2nd_LNCEL_ID}
    Set Test Variable  ${2nd_LNCEL_DN}  ${2nd_LNCEL_DN}
    ${selected_cells_IDs}=  Create List  ${1st_LNCEL_ID}  ${2nd_LNCEL_ID}
    Set Test Variable  ${selected_cells_IDs}

	${lncels_dn}=  Create List
    Set Test Variable  ${lncels_dn}
    ${lncels_dn_r}=  Create List    ${1st_LNCEL_DN}  ${2nd_LNCEL_DN}
    Set Test Variable  ${lncels_dn_r}
    FOR  ${cell}  IN  @{lncels_dn_r}
        ${cell_dn_split}=  Split String   ${cell}  separator=MRBTS_R-1/
        ${cell_dn_without_r}=  Replace String   MRBTS-${MRBTS_ID}/${cell_dn_split[1]}  _R  ${EMPTY}
        Append To List  ${lncels_dn}  ${cell_dn_without_r}
    END

    Log To Console  Reduced Energy Saving for LNCEL_R-${1st_LNCEL_ID}
    Check Power Saving  ${1st_LNCEL_ID}  ENABLED  NOTENERGYSAVING
    Check Power Saving  ${2nd_LNCEL_ID}  ENABLED  NOTENERGYSAVING
    ${selected_cells_DNs}=  Create List  ${1st_LNCEL_DN}  ${2nd_LNCEL_DN}
    Set Test Variable  ${selected_cells_DNs}
    Check If Not Energy Saving Cells Are Enabled  ENABLED  NOTENERGYSAVING  ${selected_cells_DNs}
    Cell barring for CB008745 LTE


PS.30_CB008745_Switching_On_Tx_Path_LTE.Test_Step:1 Disable Feature Before Test
    Log to console  \n========================================
    Log  Step: 1 Disable Feature Before Test  console=${True}
    Log to console  ========================================
    ${pre_action_reset_number}=  Get Reset Counter From Blackbox
    Set Feature Under Given Object  ${LNBTS_DistName}  ${feature_flags}  false
    Remove PSGRP/NRPGRP Objects If Exist  PSGRP
    Check If Unexpected Alarms Are Raised  ${skip_fault}
    ${post_action_reset_number}=  Get Reset Counter From Blackbox

PS.30_CB008745_Switching_On_Tx_Path_LTE.Test_Step:2 Create PSGRP and pre-configure for PSG control logic improvement
    Log to console  \n========================================
    Log  Step: 2 Activate Load-Based Extended Power Saving  console=${True}
    Log to console  ========================================
    ${pre_action_reset_number}=  Get Reset Counter From Blackbox
    Set Feature Under Given Object  ${LNBTS_DistName}  shutdownWindow  36
    ${if_actCo4g5g}  ${value_actCo4g5g}=  Run Keyword And Ignore Error  Get Parameter Value Under LNBTS  actCoordinated4g5gPowerSaving
    Set Test Variable  ${if_actCo4g5g}
	Commission LoadSettings For LNCELs    ${lncels_dn}     10
    Create And Activate PSGRP For CB008745  ${1st_LNCEL_DN}  ${2nd_LNCEL_DN}  PSGRP-11  18min
    ${post_action_reset_number}=  Get Reset Counter From Blackbox

PS.30_CB008745_Switching_On_Tx_Path_LTE.Test_Step:3 Activate PSG Control Logic Improvement for 4G
    Log to console  \n========================================
    Log  Step: 3 Configure Load-Based Extended Power Saving  console=${True}
    Log to console  ========================================
    ${pre_action_reset_number}=  Get Reset Counter From Blackbox
    Set Feature Under Given Object  ${LNBTS_DistName}  ${feature_flags}  true
    Check If Unexpected Alarms Are Raised  ${skip_fault}

PS.30_CB008745_Switching_On_Tx_Path_LTE.Test_Step:4 Check if selected cells reach applicable states
    Log to console  \n========================================
    Log  Step: 4 Check if selected cells reach applicable states  console=${True}
    Log to console  ========================================
    Log To Console  \Perform L3 call
	Sleep   120sec
	Call For CB008745 LTE
    Log To Console  \nWaiting for ENERGYSAVING on LNCEL_R-${1st_LNCEL_ID}
    Wait Until Keyword Succeeds  6min  15sec  Check Power Saving  ${1st_LNCEL_ID}  ENABLED  SWITCHINGOFFRTX
    Log To Console  LNCEL_R-${1st_LNCEL_ID} START TO SWITCHINGOFFRTX
    Wait Until Keyword Succeeds  50min  10sec  Check Power Saving  ${1st_LNCEL_ID}  ENABLED  REDUCEDENERGYSAVING
    Log To Console  LNCEL_R-${1st_LNCEL_ID} ENTER REDUCEDENERGYSAVING
    Check if not Energy Saving cells are enabled  ENABLED  NOTENERGYSAVING  ${selected_cells_DNs}
#    Check If Unexpected Alarms Are Raised  ${skip_fault}
    ${post_action_reset_number}=  Get Reset Counter From Blackbox
    Log To Console  \Perform L3 call
    Call For CB008745 LTE  tput_dl=80
    Log To Console  \Waiting For NotEnergySaving
    Wait Until Keyword Succeeds  1.5min  10sec  Check Power Saving  ${1st_LNCEL_ID}  ENABLED  NOTENERGYSAVING
    Log To Console  \n LNCEL-${1st_LNCEL_ID} NOTENERGYSAVING
    ${PSGRP_DN}=  Set Variable  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/PSGRP-11
    Shift Time For PSGRP  duration=13  PSGRP_DN=${PSGRP_DN}
    Set Feature Under NRPGRP/PSGRP Object  lbpsLoadCalcMethod  Max(G_N_combined, P)  PSGRP  ${PSGRP_DN}
    Set Feature Under NRPGRP/PSGRP Object  lbpsSOffTrRule  SlidingAverageMethod  PSGRP  ${PSGRP_DN}
    Set Feature Under NRPGRP/PSGRP Object  lbpsSOnTrRule  MinValueMethod  PSGRP  ${PSGRP_DN}
    Call For CB008745 LTE  tput_dl=80
    Log To Console  \nWaiting for ENERGYSAVING on LNCEL_R-${1st_LNCEL_ID}
    Wait Until Keyword Succeeds  6min  15sec  Check Power Saving  ${1st_LNCEL_ID}  ENABLED  SWITCHINGOFFRTX
    Log To Console  LNCEL_R-${1st_LNCEL_ID} start to SWITCHINGOFFRTX
    Wait Until Keyword Succeeds  75sec  10sec  Check Power Saving  ${1st_LNCEL_ID}  ENABLED  REDUCEDENERGYSAVING
    Log To Console  LNCEL_R-${1st_LNCEL_ID} enter ENERGYSAVING
    Check if not Energy Saving cells are enabled  ENABLED  NOTENERGYSAVING  ${selected_cells_DNs}
    Log To Console  Cells reach applicable states
    Check If Unexpected Alarms Are Raised  ${skip_fault}
    ${post_action_reset_number}=  Get Reset Counter From Blackbox
    Log To Console  \Perform L3 call
    Call For CB008745 LTE  tput_dl=80
    Wait Until Keyword Succeeds  1.5min  15sec  Check Power Saving  ${1st_LNCEL_ID}  ENABLED  NOTENERGYSAVING
    Wait Until Keyword Succeeds  1min  15sec  Check Power Saving  ${2nd_LNCEL_ID}  ENABLED  NOTENERGYSAVING
    Log To Console  \n Cell ${1st_LNCEL_ID} NOTENERGYSAVING

PS.30_CB008745_Switching_On_Tx_Path_LTE.Test_Step:5 Final Recovery and Checkpoint
    Log to console  \n========================================
    Log  Step: 5 Final Recovery and Checkpoint  console=${True}
    Log to console  ========================================
    ${pre_action_reset_number}=  Get Reset Counter From Blackbox
    Set Feature Under Given Object  ${LNBTS_DistName}  ${feature_flags}  false
    Remove PSGRP/NRPGRP Objects If Exist  PSGRP
    Set Feature Under Given Object  ${LNBTS_DistName}  shutdownWindow  180
    Unbarring all cells
    Check If Unexpected Alarms Are Raised  ${skip_fault}
    ${COUNTER_AFTER_TEST}=  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}

PS.30_CB008745_Switching_On_Tx_Path_LTE.Test Specific Teardown
    [Documentation]  Test Specific Teardown.
    admin.setup admin  admin_api_log_dir=${RESULTS}/admin_api/  alias=${ute_admin_alias}
    Run Keyword And Ignore Error  Set Feature Under Given Object  ${LNBTS_DistName}  ${feature_flags}  false
    Run Keyword And Ignore Error  Remove PSGRP/NRPGRP Objects If Exist  PSGRP
    Run Keyword And Ignore Error  Set Feature Under Given Object  ${LNBTS_DistName}  shutdownWindow  180
    Run keyword and ignore error  Stop Tracing and download logs from SMOD
    Unbarring all cells
    admin.teardown admin  alias=${ute_admin_alias}

PS.30_CB008745_Switching_On_Tx_Path_LTE.Test Case Teardown
    Run Keywords  common.Common Test Teardown
    Run Keyword If Test Failed  PS.30_CB008745_Switching_On_Tx_Path_LTE.Test Specific Teardown
