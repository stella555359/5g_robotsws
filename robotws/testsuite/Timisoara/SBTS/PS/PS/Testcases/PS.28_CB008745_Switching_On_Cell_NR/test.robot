*** Settings ***
Resource    ../../../resources/common.robot
Resource    ../../../resources/alarms.robot
Resource    ../../../resources/ald.robot
Resource    ../../../resources/power_saving.robot
Resource    ../../../resources/L3_call.robot

Documentation
...  TEST NAME:     PS.28_CB008745_Switching_On_Cell_NR
...  AUTHORS:       roscislaw.szuminski@nokia.com
...  MAINTAINER:    RAN_PZ_WRO_3_SG01
...  *****************
...  Basic information
...  *****************
...  Purpose of this test case is to verify if 5G cells switching off procedure work properly,
...  according to load-based monitoring windows.
...  *****************
...  Pre-conditions
...  This test is dedicated for TL: 53103
...  *****************
...  N/A
...  ******************
...  History of changes
...  ******************
...  05.01.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-302 - Test case creation
...  26.04.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-350 - Test case adaption for CB010683 - mandatory parameter lbpsUseExtConfig added
...  08.09.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-445 - enb8391 added to KW Call For CB008745 NR
...  04.12.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-477 - added Select Two Random NR Cells NSA for enb8070
...  15.12.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-489 - New KW Unbarring all cells added to teardowns
...  07.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAW-526 - added Stop tracing and download logs from SMOD to teardown
...  14.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAW-518 - Add FID:49 to allowed during L3 call; unblock all cells in teardown
...  *******************
...  RAN PZ3 WRO1 TEMPLATE


*** Keywords ***
PS.28_CB008745_Switching_On_Cell_NR

    PS.28_CB008745_Switching_On_Cell_NR.Test_Step:0 Test Preparation
    PS.28_CB008745_Switching_On_Cell_NR.Test_Step:1 Disable Feature Before Test
    PS.28_CB008745_Switching_On_Cell_NR.Test_Step:2 Create NRPGRP and pre-configure for PSG control logic improvement
    PS.28_CB008745_Switching_On_Cell_NR.Test_Step:3 Activate PSG Control Logic Improvement for 5G
    PS.28_CB008745_Switching_On_Cell_NR.Test_Step:4 Check if selected cells reach applicable states
    PS.28_CB008745_Switching_On_Cell_NR.Test_Step:5 Final Recovery and Checkpoint

PS.28_CB008745_Switching_On_Cell_NR.Test_Step:0 Test Preparation
    Log to console  \n========================================
    Log  Step: 0 Test Preparation  console=${True}
    Log to console  ========================================
    ${COUNTER_BEFORE_TEST}=  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}
    Set Test Variable  ${COUNTER_BEFORE_TEST}
    Set Test Variable  ${ue}  NOKIA83
    Set Test Variable  ${RESULTS}
    @{feature_flags}=  Create List  actLbpsCtrlLogicEnh  actNrLBPowerSaving
    Set Test Variable  ${feature_flags}
    IF  '${MRBTS_ID}'=='10817'
        Select Three Random NR Cells NSA
	ELSE
	    Select Three Random NR Cells
	END
    Set Test Variable  ${1st_NRCELL_ID}  ${1st_NRCELL_ID}
    Set Test Variable  ${1st_NRCELL_DN}  ${1st_NRCELL_DN}
    Set Test Variable  ${2nd_NRCELL_ID}  ${2nd_NRCELL_ID}
    Set Test Variable  ${2nd_NRCELL_DN}  ${2nd_NRCELL_DN}
    Set Test Variable  ${3rd_NRCELL_ID}  ${3rd_NRCELL_ID}
    Set Test Variable  ${3rd_NRCELL_DN}  ${3rd_NRCELL_DN}
    ${selected_cells_IDs}=  Create List  ${1st_NRCELL_ID}  ${2nd_NRCELL_ID}  ${3rd_NRCELL_ID}
    Set Test Variable  ${selected_cells_IDs}
    Log To Console  Energy Saving for NRCEL_R-${1st_NRCELL_ID} and NRCEL_R-${2nd_NRCELL_ID} and NRCEL_R-${3rd_NRCELL_ID}
    Check Power Saving NR  ${1st_NRCELL_ID}  ENABLED  NOTENERGYSAVING
    Check Power Saving NR  ${2nd_NRCELL_ID}  ENABLED  NOTENERGYSAVING
    Check Power Saving NR  ${3rd_NRCELL_ID}  ENABLED  NOTENERGYSAVING
    ${selected_cells_DNs}=  Create List  ${1st_NRCELL_DN}  ${2nd_NRCELL_DN}  ${3rd_NRCELL_DN}
    Set Test Variable  ${selected_cells_DNs}
    Check If Not Energy Saving Cells Are Enabled  ENABLED  NOTENERGYSAVING  ${selected_cells_DNs}
    Cell barring for CB008745 NR

PS.28_CB008745_Switching_On_Cell_NR.Test_Step:1 Disable Feature Before Test
    Log to console  \n========================================
    Log  Step: 1 Disable Feature Before Test  console=${True}
    Log to console  ========================================
    ${pre_action_reset_number}=  Get Reset Counter From Blackbox
    Set Feature Under Given Object  ${NRBTS_DistName}  ${feature_flags}  false
    Remove PSGRP/NRPGRP Objects If Exist  NRPGRP
    Check If Unexpected Alarms Are Raised  ${skip_fault}
    ${post_action_reset_number}=  Get Reset Counter From Blackbox

PS.28_CB008745_Switching_On_Cell_NR.Test_Step:2 Create NRPGRP and pre-configure for PSG control logic improvement
    Log to console  \n========================================
    Log  Step: 2 Activate Load-Based Extended Power Saving  console=${True}
    Log to console  ========================================
    ${pre_action_reset_number}=  Get Reset Counter From Blackbox
    ${if_actNrExtCellSOMethod}  ${value_actNrExtCellSOMethod}=  Run Keyword And Ignore Error  Get Parameter Value Under NRBTS  actNrExtCellSOMethod
    Set Test Variable  ${if_actNrExtCellSOMethod}
    Set Feature Under Given Object  ${NRBTS_DistName}  shutdownWindow  36
    Create And Activate NRPGRP For CB008745  1  25min
    ${post_action_reset_number}=  Get Reset Counter From Blackbox

PS.28_CB008745_Switching_On_Cell_NR.Test_Step:3 Activate PSG Control Logic Improvement for 5G
    Log to console  \n========================================
    Log  Step: 3 Configure Load-Based Extended Power Saving  console=${True}
    Log to console  ========================================
    ${pre_action_reset_number}=  Get Reset Counter From Blackbox
    Set Feature Under Given Object  ${NRBTS_DistName}  ${feature_flags}  true
    Check If Unexpected Alarms Are Raised  ${skip_fault}

PS.28_CB008745_Switching_On_Cell_NR.Test_Step:4 Check if selected cells reach applicable states
    Log to console  \n========================================
    Log  Step: 4 Check if selected cells reach applicable states  console=${True}
    Log to console  ========================================
    ${status}  Run Keyword And Return Status  Call For CB008745 NR
    IF  not ${status}  Teardown if call failed
    Log To Console  \nWaiting for ENERGYSAVING on NRCEL_R-${2nd_NRCELL_ID}
    Wait Until Keyword Succeeds  4min  15sec  Check Power Saving NR  ${2nd_NRCELL_ID}  ENABLED  SWITCHINGOFF
    Log To Console  NRCEL_R-${2nd_NRCELL_ID} START TO SWITCHINGOFF
    Wait Until Keyword Succeeds  50sec  10sec  Check Power Saving NR  ${2nd_NRCELL_ID}  DISABLED  ENERGYSAVING
    Log To Console  NRCEL_R-${2nd_NRCELL_ID} ENTER ENERGYSAVING
    Check if not Energy Saving cells are enabled  ENABLED  NOTENERGYSAVING  ${selected_cells_DNs}
    Check If Unexpected Alarms Are Raised  ${skip_fault}
    ${post_action_reset_number}=  Get Reset Counter From Blackbox
    Log To Console  \Perform L3 call
    ${status}  Run Keyword And Return Status  Call For CB008745 NR
    IF  not ${status}  Teardown if call failed
    Log To Console  \Waiting For NotEnergySaving
    Wait Until Keyword Succeeds  1.5min  15sec  Check Power Saving NR  ${2nd_NRCELL_ID}  ENABLED  NOTENERGYSAVING
    Log To Console  \n Cell ${2nd_NRCELL_ID} NOTENERGYSAVING
    ${NRPGRP_DN}=  Set Variable  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRPGRP-1
    Shift Time For NRPGRP  duration=25  NRPGRP_DN=${NRPGRP_DN}
    Set Feature Under NRPGRP/PSGRP Object  lbpsLoadCalcMethod  Max(G_N_combined, P)  NRPGRP  ${NRPGRP_DN}
    Set Feature Under NRPGRP/PSGRP Object  lbpsSOffTrRule  SlidingAverageMethod  NRPGRP  ${NRPGRP_DN}
#    Set Feature Under NRPGRP/PSGRP Object  lbpsSOnTrRule  MinValueMethod  NRPGRP  ${NRPGRP_DN}
    Set Feature Under NRPGRP/PSGRP Object  lbpsSOnTrRule  SlidingAverageMethod  NRPGRP  ${NRPGRP_DN}
    ${status}  Run Keyword And Return Status  Call For CB008745 NR
    IF  not ${status}  Teardown if call failed
    Log To Console  \nWaiting for ENERGYSAVING on NRCEL_R-${2nd_NRCELL_ID}
    Wait Until Keyword Succeeds  4min  15sec  Check Power Saving NR  ${2nd_NRCELL_ID}  ENABLED  SWITCHINGOFF
    Log To Console  NRCEL_R-${2nd_NRCELL_ID} start to SWITCHINGOFF
    Wait Until Keyword Succeeds  50sec  10sec  Check Power Saving NR  ${2nd_NRCELL_ID}  DISABLED  ENERGYSAVING
    Log To Console  NRCEL_R-${2nd_NRCELL_ID} enter ENERGYSAVING
    Check if not Energy Saving cells are enabled  ENABLED  NOTENERGYSAVING  ${selected_cells_DNs}
    Log To Console  Cells reach applicable states
    Check If Unexpected Alarms Are Raised  ${skip_fault}
    ${post_action_reset_number}=  Get Reset Counter From Blackbox
    Log To Console  \Perform L3 call
    ${status}  Run Keyword And Return Status  Call For CB008745 NR
    IF  not ${status}  Teardown if call failed$$
##    Wait Until Keyword Succeeds  1.5min  15sec  Check Power Saving NR  ${1st_NRCELL_ID}  ENABLED  NOTENERGYSAVING
##    Wait Until Keyword Succeeds  1min  15sec  Check Power Saving NR  ${2nd_NRCELL_ID}  ENABLED  NOTENERGYSAVING
##    Wait Until Keyword Succeeds  1min  15sec  Check Power Saving NR  ${3nd_NRCELL_ID}  ENABLED  NOTENERGYSAVING
    Log To Console  \n Cell ${2nd_NRCELL_ID} NOTENERGYSAVING

PS.28_CB008745_Switching_On_Cell_NR.Test_Step:5 Final Recovery and Checkpoint
    Log to console  \n========================================
    Log  Step: 5 Final Recovery and Checkpoint  console=${True}
    Log to console  ========================================
    ${pre_action_reset_number}=  Get Reset Counter From Blackbox
    Set Feature Under Given Object  ${NRBTS_DistName}  ${feature_flags}  false
    Remove PSGRP/NRPGRP Objects If Exist  NRPGRP
    Set Feature Under Given Object  ${NRBTS_DistName}  shutdownWindow  180
    Unbarring all cells
    Check If Unexpected Alarms Are Raised  ${skip_fault}
    ${COUNTER_AFTER_TEST}=  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}

PS.28_CB008745_Switching_On_Cell_NR.Test Specific Teardown
    [Documentation]  Test Specific Teardown.
    admin.setup admin  admin_api_log_dir=${RESULTS}/admin_api/  alias=${ute_admin_alias}
    Run Keyword And Ignore Error  Set Feature Under Given Object  ${NRBTS_DistName}  ${feature_flags}  false
    Run Keyword And Ignore Error  Remove PSGRP/NRPGRP Objects If Exist  NRPGRP
    Run Keyword And Ignore Error  Set Feature Under Given Object  ${NRBTS_DistName}  shutdownWindow  180
    Run keyword and ignore error  Stop Tracing and download logs from SMOD
    Unbarring all cells
    admin.teardown admin  alias=${ute_admin_alias}

PS.28_CB008745_Switching_On_Cell_NR.Test Case Teardown
    Run Keywords  common.Common Test Teardown
    Run Keyword If Test Failed  PS.28_CB008745_Switching_On_Cell_NR.Test Specific Teardown
