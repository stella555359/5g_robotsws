*** Settings ***
Resource    ../../../resources/common.robot
Resource    ../../../resources/alarms.robot
Resource    ../../../resources/ald.robot
Resource    ../../../resources/power_saving.robot
Resource    ../../../resources/L3_call.robot

Documentation
...  TEST NAME:     PS.54_CB010397-E_Load_Based_Power_Saving_Mixed_switch_off_method_load_estimation_over_lbpsRTXMaxLoad
...  AUTHORS:       roscislaw.szuminski@nokia.com
...  MAINTAINER:    RAN_VRF_TSR1_5
...  *****************
...  Basic information
...  *****************
...  Purpose of this test case is to verify if 5G cells switching off procedure work properly,
...  according to load-based monitoring windows.
...  *****************
...  Pre-conditions
...  This test is dedicated for TL: 8588
...  *****************
...  N/A
...  ******************
...  History of changes
...  ******************
...  12.03.2024 - https://jiradc.ext.net.nokia.com/browse/TAW-482 - Test case creation
...  *******************
...  RAN PZ3 WRO1 TEMPLATE

#*** Variables ***



*** Keywords ***
PS.54_CB010397-E_Load_Based_Power_Saving_Mixed_switch_off_method_load_estimation_over_lbpsRTXMaxLoad

    PS.54_CB010397-E_Load_Based_Power_Saving_Mixed_switch_off_method_load_estimation_over_lbpsRTXMaxLoad.Test_Step:0 Test Preparation
    PS.54_CB010397-E_Load_Based_Power_Saving_Mixed_switch_off_method_load_estimation_over_lbpsRTXMaxLoad.Test_Step:1 Disable Feature Before Test
    PS.54_CB010397-E_Load_Based_Power_Saving_Mixed_switch_off_method_load_estimation_over_lbpsRTXMaxLoad.Test_Step:2 Create And Activate PSGRP
    PS.54_CB010397-E_Load_Based_Power_Saving_Mixed_switch_off_method_load_estimation_over_lbpsRTXMaxLoad.Test_Step:4 Check Cell States
    PS.54_CB010397-E_Load_Based_Power_Saving_Mixed_switch_off_method_load_estimation_over_lbpsRTXMaxLoad.Test_Step:5 Final Recovery and Checkpoint

PS.54_CB010397-E_Load_Based_Power_Saving_Mixed_switch_off_method_load_estimation_over_lbpsRTXMaxLoad.Test_Step:0 Test Preparation
    Log to console  \n========================================
    Log  Step: 0 Test Preparation  console=${True}
    Log to console  ========================================
    ${COUNTER_BEFORE_TEST}=  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}
    Set Test Variable  ${COUNTER_BEFORE_TEST}
    Set Test Variable  ${ue}  NOKIA83
    Set Test Variable  ${RESULTS}
    @{precondition_flags_CB010397}  Create List   actLBPowerSaving  actLBRTXPowerSaving  actOnlineTXSwitch  actExtCellSOMethod  actMixedSOMethod
    Set Test Variable    ${precondition_flags_CB010397}

    ${LTE_cells}  admin.get parameters for all  LNCEL
    Set Test Variable    ${LTE_cells}
    ${cell}  Evaluate  random.sample(${LTE_cells}, 3)  random
    ${1st_LNCEL_ID}  ${1st_LNCEL_DN}  Get Id Of Selected Cell  ${cell}[0]
    ${2nd_LNCEL_ID}  ${2nd_LNCEL_DN}  Get Id Of Selected Cell  ${cell}[1]
    ${3rd_LNCEL_ID}  ${3rd_LNCEL_DN}  Get Id Of Selected Cell  ${cell}[2]

	Run Keyword If  '${MRBTS_ID}'=='10817'
    ...  Run Keywords
	...  Set Test Variable  ${1st_LNCEL_ID}  203
    ...  AND  Set Test Variable  ${1st_LNCEL_DN}  /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/LNBTS_R-10817/LNCEL_R-203
    ...	 AND  Set Test Variable  ${2nd_LNCEL_ID}  204
    ...  AND  Set Test Variable  ${2nd_LNCEL_DN}  /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/LNBTS_R-10817/LNCEL_R-204
    ...  AND  Set Test Variable  ${3rd_LNCEL_ID}  205
    ...  AND  Set Test Variable  ${3rd_LNCEL_DN}  /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/LNBTS_R-10817/LNCEL_R-205

    Run Keyword If  '${MRBTS_ID}'=='10818'
    ...  Run Keywords
	...  Set Test Variable  ${1st_LNCEL_ID}  48180
    ...  AND  Set Test Variable  ${1st_LNCEL_DN}  /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/LNBTS_R-10818/LNCEL_R-48180
    ...	 AND  Set Test Variable  ${2nd_LNCEL_ID}  48140
    ...  AND  Set Test Variable  ${2nd_LNCEL_DN}  /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/LNBTS_R-10818/LNCEL_R-48140
    ...  AND  Set Test Variable  ${3rd_LNCEL_ID}  48147
    ...  AND  Set Test Variable  ${3rd_LNCEL_DN}  /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/LNBTS_R-10818/LNCEL_R-48147

    Set Test Variable  ${1st_LNCEL_ID}
    Set Test Variable  ${2nd_LNCEL_ID}
    Set Test Variable  ${3rd_LNCEL_ID}
    ${cells_ID_to_PSGRP}=    Create List    ${1st_LNCEL_ID}    ${2nd_LNCEL_ID}    ${3rd_LNCEL_ID}
    Set Test Variable    ${cells_ID_to_PSGRP}
    Set Test Variable  ${1st_LNCEL_DN}
    Set Test Variable  ${2nd_LNCEL_DN}
    Set Test Variable  ${3rd_LNCEL_DN}
    ${lncels_dn}=  Create List
    Set Test Variable  ${lncels_dn}
    ${lncels_dn_r}=  Create List    ${1st_LNCEL_DN}  ${2nd_LNCEL_DN}  ${3rd_LNCEL_DN}
    Set Test Variable  ${lncels_dn_r}
    FOR  ${cell}  IN  @{lncels_dn_r}
        ${cell_dn_split}=  Split String   ${cell}  separator=MRBTS_R-1/
        ${cell_dn_without_r}=  Replace String   MRBTS-${MRBTS_ID}/${cell_dn_split[1]}  _R  ${EMPTY}
        Append To List  ${lncels_dn}  ${cell_dn_without_r}
    END
    Assign Chosen Cells to PSGRP
    Check Power Saving  ${1st_LNCEL_ID}  ENABLED  NOTENERGYSAVING
    Check Power Saving  ${2nd_LNCEL_ID}  ENABLED  NOTENERGYSAVING
    Check Power Saving  ${3rd_LNCEL_ID}  ENABLED  NOTENERGYSAVING
    Cell barring for CB010397 LTE    #added for 10818_TMO
    #Log To Console  Mixed switch off method for LNCEL_R-${1st_LNCELL_CB010397} and for LNCEL_R-${2nd_LNCELL_CB010397}

PS.54_CB010397-E_Load_Based_Power_Saving_Mixed_switch_off_method_load_estimation_over_lbpsRTXMaxLoad.Test_Step:1 Disable Feature Before Test
    Log to console  \n========================================
    Log  Step: 1 Disable Feature Before Test  console=${True}
    Log to console  ========================================
    Remove PSGRP/NRPGRP Objects If Exist  PSGRP
    Set Feature Under Given Object    ${LNBTS_DistName}  ${precondition_flags_CB010397}  false

PS.54_CB010397-E_Load_Based_Power_Saving_Mixed_switch_off_method_load_estimation_over_lbpsRTXMaxLoad.Test_Step:2 Create And Activate PSGRP
    Log to console  \n========================================
    Log  Step: 2 Create And Activate PSGRP  console=${True}
    Log to console  ========================================
    ${if_actExtCellSOMethod}  ${value_actExtCellSOMethod}=  Run Keyword And Ignore Error  Get Parameter Value Under LNBTS  actExtCellSOMethod
    Set Test Variable  ${if_actExtCellSOMethod}
    ${if_actCo4g5g}  ${value_actCo4g5g}=  Run Keyword And Ignore Error  Get Parameter Value Under LNBTS  actCoordinated4g5gPowerSaving
    Set Test Variable  ${if_actCo4g5g}
    Commission LoadSettings For LNCELs    ${lncels_dn}    10
    Set Feature Under Given Object  ${LNBTS_DistName}  shutdownWindow  36
    Set Feature Under Given Object   ${LNBTS_DistName}  ${precondition_flags_CB010397}  true
    Create And Activate PSGRP For CB010397_CB008800    PSGRP-12   45min

PS.54_CB010397-E_Load_Based_Power_Saving_Mixed_switch_off_method_load_estimation_over_lbpsRTXMaxLoad.Test_Step:4 Check Cell States
    Log to console  \n========================================
    Log  Step: 4 Check Cell States  console=${True}
    Log to console  ========================================
    Log To Console  \nWaiting for ENERGYSAVING on LNCEL_R-${1st_LNCEL_ID}
    Wait Until keyword Succeeds  10min  15sec  Check Power Saving  ${1st_LNCEL_ID}  DISABLED  ENERGYSAVING
    Check if not Energy Saving cells are enabled  ENABLED  NOTENERGYSAVING  ${selected_cells_DNs}
    Log To Console  \nWaiting for REDUCEDENERGYSAVING on LNCEL_R-${2nd_LNCEL_ID} and LNCEL_R-${3rd_LNCEL_ID}
    Wait Until keyword Succeeds  7min  15sec  Check Power Saving  ${2nd_LNCEL_ID}  ENABLED  REDUCEDENERGYSAVING
    Wait Until keyword Succeeds  1min  15sec  Check Power Saving  ${3rd_LNCEL_ID}  ENABLED  REDUCEDENERGYSAVING
    #Call For CB008745 LTE  tput_dl=150  duration=145
    Call For CB010397 LTE adapted    80     250    true     true
    Log To Console  \nWaiting for notES on selected cells.
    Wait Until keyword Succeeds  1min  15sec  Check Power Saving  ${1st_LNCEL_ID}  ENABLED  NOTENERGYSAVING
    Wait Until keyword Succeeds  5min  15sec  Check Power Saving  ${2nd_LNCEL_ID}  ENABLED  NOTENERGYSAVING
    Wait Until keyword Succeeds  1min  15sec  Check Power Saving  ${3rd_LNCEL_ID}  ENABLED  NOTENERGYSAVING
    Check if not Energy Saving cells are enabled  ENABLED  NOTENERGYSAVING  ${selected_cells_DNs}

PS.54_CB010397-E_Load_Based_Power_Saving_Mixed_switch_off_method_load_estimation_over_lbpsRTXMaxLoad.Test_Step:5 Final Recovery and Checkpoint
    Log to console  \n========================================
    Log  Step: 5 Final Recovery and Checkpoint  console=${True}
    Log to console  ========================================
    Commission LoadSettings For LNCELs  ${lncels_dn}  0.5
    Set Feature Under Given Object  ${LNBTS_DistName}  ${precondition_flags_CB010397}  false
    Remove PSGRP/NRPGRP Objects If Exist  PSGRP
    Set Feature Under Given Object  ${LNBTS_DistName}  shutdownWindow  180
    #Unbarring all cells
    ${COUNTER_AFTER_TEST}=  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}

PS.54_CB010397-E_Load_Based_Power_Saving_Mixed_switch_off_method_load_estimation_over_lbpsRTXMaxLoad.Specific Teardown
    [Documentation]  Test Specific Teardown.
    admin.setup admin  admin_api_log_dir=${RESULTS}/admin_api/  alias=${ute_admin_alias}
    Run Keyword And Ignore Error  Set Feature Under Given Object  ${LNBTS_DistName}  ${precondition_flags_CB010397}  false
    Run Keyword And Ignore Error  Remove PSGRP/NRPGRP Objects If Exist  PSGRP
    Run Keyword And Ignore Error  Commission LoadSettings For LNCELs    ${lncels_dn}    0.5
    Run Keyword And Ignore Error  Set Feature Under Given Object  ${LNBTS_DistName}  shutdownWindow  180
    admin.teardown admin  alias=${ute_admin_alias}

PS.54_CB010397-E_Load_Based_Power_Saving_Mixed_switch_off_method_load_estimation_over_lbpsRTXMaxLoad.Test Case Teardown
    Run Keywords  common.Common Test Teardown
    Run Keyword If Test Failed  PS.54_CB010397-E_Load_Based_Power_Saving_Mixed_switch_off_method_load_estimation_over_lbpsRTXMaxLoad.Specific Teardown

