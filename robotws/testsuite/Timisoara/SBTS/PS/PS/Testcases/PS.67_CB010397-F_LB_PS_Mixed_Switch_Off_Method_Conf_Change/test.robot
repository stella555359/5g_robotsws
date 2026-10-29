*** Settings ***
Resource    ../../../resources/common.robot
Resource    ../../../resources/alarms.robot
Resource    ../../../resources/ald.robot
Resource    ../../../resources/power_saving.robot
Resource    ../../../resources/netact.robot
Resource    ../../../resources/L3_call.robot

Documentation
...  TEST NAME:     PS.67_CB010397-F_LB_PS_Mixed_Switch_Off_Method_Conf_Change
...  AUTHORS:       roscislaw.szuminski@nokia.com
...  MAINTAINER:    RAN_VRF_TSR1_5
...  *****************
...  Basic information
...  *****************
...  Purpose of this test case is to verify if Mixed Switch Off method of load based power saving is working correctly after changing lb method
...  *****************
...  Pre-conditions
...  This test is dedicated for TL: 3 LTE cells required, call required
...  *****************
...  N/A
...  ******************
...  History of changes
...  ******************
...  08.05.2024 - https://jiradc.ext.net.nokia.com/browse/TAW-486 - Test case creation
...  *******************
...  RAN PZ3 WRO1 TEMPLATE

#*** Variables ***

*** Keywords ***
PS.67_CB010397-F_LB_PS_Mixed_Switch_Off_Method_Conf_Change
    PS.67_CB010397-F_LB_PS_Mixed_Switch_Off_Method_Conf_Change.Test_Step:0 Test Preparation
    PS.67_CB010397-F_LB_PS_Mixed_Switch_Off_Method_Conf_Change.Test_Step:1 Disable Feature Before Test
    PS.67_CB010397-F_LB_PS_Mixed_Switch_Off_Method_Conf_Change.Test_Step:2 Create PSGRP and Activate Mixed Switch Off Method
    PS.67_CB010397-F_LB_PS_Mixed_Switch_Off_Method_Conf_Change.Test_Step:3 Check if LNCEL_R-${1st_LNCELL_CB010397} transition to reducedEnergySaving
    PS.67_CB010397-F_LB_PS_Mixed_Switch_Off_Method_Conf_Change.Test_Step:4 Check if LNCEL_R-${2nd_LNCELL_CB010397} transition to reducedEnergySaving
    PS.67_CB010397-F_LB_PS_Mixed_Switch_Off_Method_Conf_Change.Test_Step:5 Check if LNCEL_R-${1st_LNCELL_CB010397} transition to EnergySaving
    PS.67_CB010397-F_LB_PS_Mixed_Switch_Off_Method_Conf_Change.Test_Step:6 Check if LNCEL_R-${1st_LNCELL_CB010397} transition to notEnergySaving
    PS.67_CB010397-F_LB_PS_Mixed_Switch_Off_Method_Conf_Change.Test_Step:7 Check if LNCEL_R-${1st_LNCELL_CB010397} transition to RES or EnergySaving
    PS.67_CB010397-F_LB_PS_Mixed_Switch_Off_Method_Conf_Change.Test_Step:8 Final Recovery and Checkpoint

PS.67_CB010397-F_LB_PS_Mixed_Switch_Off_Method_Conf_Change.Test_Step:0 Test Preparation
    Log to console  \n========================================
    Log  Step: 0 Test Preparation  console=${True}
    Log to console  ========================================
    ${COUNTER_BEFORE_TEST}=  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}
    Set Test Variable  ${COUNTER_BEFORE_TEST}
    Set Test Variable  ${ue}  NOKIA83_NR
    ${PSGRP_DN}=  Set Variable  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/PSGRP-11
    Set Test Variable  ${PSGRP_DN}
    Set Test Variable  ${RESULTS}
    @{precondition_flags_CB010397}  Create List   actLBPowerSaving  actLBRTXPowerSaving  actOnlineTXSwitch  actExtCellSOMethod  actMixedSOMethod
    Set Test Variable    ${precondition_flags_CB010397}
    ${LTE_cells}  admin.get parameters for all  LNCEL
    Set Test Variable    ${LTE_cells}
    #${cell}  Select 3 Random LNCEL From ${LTE_cells}
    ${cell}  Evaluate  random.sample(${LTE_cells}, 3)  random
    ${1st_LNCEL_ID}  ${1st_LNCEL_DN}  Get Id Of Selected Cell  ${cell}[0]
    ${2nd_LNCEL_ID}  ${2nd_LNCEL_DN}  Get Id Of Selected Cell  ${cell}[1]
    ${3rd_LNCEL_ID}  ${3rd_LNCEL_DN}  Get Id Of Selected Cell  ${cell}[2]

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
    Log To Console  Mixed switch off method for LNCEL_R-${1st_LNCELL_CB010397} and for LNCEL_R-${2nd_LNCELL_CB010397}

PS.67_CB010397-F_LB_PS_Mixed_Switch_Off_Method_Conf_Change.Test_Step:1 Disable Feature Before Test
    Log to console  \n========================================
    Log  Step: 1 Disable Feature Before Test  console=${True}
    Log to console  ========================================
    Remove PSGRP/NRPGRP Objects If Exist  PSGRP
    Set Feature Under Given Object   ${LNBTS_DistName}  ${precondition_flags_CB010397}  false

PS.67_CB010397-F_LB_PS_Mixed_Switch_Off_Method_Conf_Change.Test_Step:2 Create PSGRP and Activate Mixed Switch Off Method
    Log to console  \n========================================
    Log  Step: 2 Create PSGRP and Activate Mixed Switch Off Method  console=${True}
    Log to console  ========================================
    ${if_actExtCellSOMethod}  ${value_actExtCellSOMethod}=  Run Keyword And Ignore Error  Get Parameter Value Under LNBTS  actExtCellSOMethod
    Set Test Variable  ${if_actExtCellSOMethod}
    ${if_actCo4g5g}  ${value_actCo4g5g}=  Run Keyword And Ignore Error  Get Parameter Value Under LNBTS  actCoordinated4g5gPowerSaving
    Set Test Variable  ${if_actCo4g5g}
    Commission LoadSettings For LNCELs    ${lncels_dn}    10
    Set Feature Under Given Object   ${LNBTS_DistName}  ${precondition_flags_CB010397}  true
    Create And Activate PSGRP For CB010397    PSGRP-11   60min

PS.67_CB010397-F_LB_PS_Mixed_Switch_Off_Method_Conf_Change.Test_Step:3 Check if LNCEL_R-${1st_LNCELL_CB010397} transition to reducedEnergySaving
    Log to console  \n========================================
    Log  Step: 3 Check if LNCEL_R-${1st_LNCELL_CB010397} transitions to reducedEnergySaving   console=${True}
    Log to console  ========================================
    Log To Console  \Perform L3 call
    Call For CB010397 LTE adapted    25     200    true     false
    Log To Console  \nWaiting for REDUCEDENERGYSAVING on LNCEL_R-${1st_LNCELL_CB010397}
    Wait Until Keyword Succeeds  7min  5sec  Check Power Saving  ${1st_LNCELL_CB010397}  ENABLED  REDUCEDENERGYSAVING
    Log To Console  LNCEL_R-${1st_LNCELL_CB010397} ENTER REDUCEDENERGYSAVING
    Check if not Energy Saving cells are enabled  ENABLED  NOTENERGYSAVING  ${selected_cells_DNs}


PS.67_CB010397-F_LB_PS_Mixed_Switch_Off_Method_Conf_Change.Test_Step:4 Check if LNCEL_R-${2nd_LNCELL_CB010397} transition to reducedEnergySaving
    Log to console  \n========================================
    Log  Step: 4 Check if LNCEL_R-${2nd_LNCELL_CB010397} transitions to reducedEnergySaving   console=${True}
    Log to console  ========================================
    Log To Console  \Perform L3 call
    Call For CB010397 LTE adapted    25     250    false     false
    Log To Console  \nWaiting for REDUCEDENERGYSAVING on LNCEL_R-${2nd_LNCELL_CB010397}
    Wait Until Keyword Succeeds  7min  5sec  Check Power Saving  ${2nd_LNCELL_CB010397}  ENABLED  REDUCEDENERGYSAVING
    Log To Console  LNCEL_R-${2nd_LNCELL_CB010397} ENTER REDUCEDENERGYSAVING
    #Wait Until Keyword Succeeds  7min  5sec  Check Power Saving  ${1st_LNCELL_CB010397}  ENABLED  REDUCEDENERGYSAVING
    #Log To Console  LNCEL_R-${1st_LNCELL_CB010397} STILL IN REDUCEDENERGYSAVING
    Check if not Energy Saving cells are enabled  ENABLED  NOTENERGYSAVING  ${selected_cells_DNs}


PS.67_CB010397-F_LB_PS_Mixed_Switch_Off_Method_Conf_Change.Test_Step:5 Check if LNCEL_R-${1st_LNCELL_CB010397} transition to EnergySaving
    Log to console  \n========================================
    Log  Step: 5 Check if LNCEL_R-${1st_LNCELL_CB010397} transitions to EnergySaving   console=${True}
    Log to console  ========================================
    Log To Console  \nWaiting for ENERGYSAVING on LNCEL_R-${1st_LNCELL_CB010397}
    Wait Until Keyword Succeeds  10min  5sec  Check Power Saving  ${1st_LNCELL_CB010397}  DISABLED  ENERGYSAVING
    Log To Console  LNCEL_R-${1st_LNCELL_CB010397} ENTER ENERGYSAVING
    Wait Until Keyword Succeeds  6min  5sec  Check Power Saving  ${2nd_LNCELL_CB010397}  ENABLED  REDUCEDENERGYSAVING
    Log To Console  LNCEL_R-${2nd_LNCELL_CB010397} STILL IN REDUCEDENERGYSAVING
    Check if not Energy Saving cells are enabled  ENABLED  NOTENERGYSAVING  ${selected_cells_DNs}


PS.67_CB010397-F_LB_PS_Mixed_Switch_Off_Method_Conf_Change.Test_Step:6 Check if LNCEL_R-${1st_LNCELL_CB010397} transition to notEnergySaving
    Log to console  \n========================================
    Log  Step: 6 Check if LNCEL_R-${1st_LNCELL_CB010397} transitions to notEnergySaving   console=${True}
    Log to console  ========================================
    Log To Console  \Perform L3 call
    Call For CB010397 LTE adapted    25     300    false     true
    Log To Console  \nWaiting for NOTENERGYSAVING on LNCEL_R-${1st_LNCELL_CB010397}
    Wait Until Keyword Succeeds  2min  15sec  Check Power Saving  ${1st_LNCELL_CB010397}   ENABLED  NOTENERGYSAVING
    Log To Console  \n Cells ${1st_LNCELL_CB010397} NOTENERGYSAVING


PS.67_CB010397-F_LB_PS_Mixed_Switch_Off_Method_Conf_Change.Test_Step:7 Check if LNCEL_R-${1st_LNCELL_CB010397} transition to RES or EnergySaving
    Log to console  \n========================================
    Log  Step: 7 Check if LNCEL_R-${1st_LNCELL_CB010397} transitions to Reduced or EnergySaving   console=${True}
    Log to console  ========================================
    Log To Console  \nWaiting for ENERGYSAVING or REDUCEDENERGYSAVING on LNCEL_R-${1st_LNCELL_CB010397}
    Run Keyword And Ignore Error   Wait Until Keyword Succeeds  6min  5sec  Check Power Saving  ${1st_LNCELL_CB010397}  ENABLED  REDUCEDENERGYSAVING
    Wait Until Keyword Succeeds  12min  5sec  Check Power Saving  ${1st_LNCELL_CB010397}  DISABLED  ENERGYSAVING
    Log To Console  LNCEL_R-${1st_LNCELL_CB010397} ENTER ENERGYSAVING
    #DNS
    Wait Until Keyword Succeeds  12min  5sec  Check Power Saving  ${2nd_LNCELL_CB010397}  ENABLED  REDUCEDENERGYSAVING
    Log To Console  LNCEL_R-${2nd_LNCELL_CB010397} STILL IN REDUCEDENERGYSAVING
    Check if not Energy Saving cells are enabled  ENABLED  NOTENERGYSAVING  ${selected_cells_DNs}
    Log  Step: 7 Load-Based Configuration Change   console=${True}
    Set Feature Under Given Object  ${PSGRP_DN}  lbpsSOMethod  Legacy Mixed Switch Off
    Check Power Saving  ${1st_LNCEL_ID}  ENABLED  NOTENERGYSAVING
    Check Power Saving  ${2nd_LNCEL_ID}  ENABLED  NOTENERGYSAVING
    Check Power Saving  ${3rd_LNCEL_ID}  ENABLED  NOTENERGYSAVING


PS.67_CB010397-F_LB_PS_Mixed_Switch_Off_Method_Conf_Change.Test_Step:8 Final Recovery and Checkpoint
    Log to console  \n========================================
    Log  Step: 8 Final Recovery and Checkpoint  console=${True}
    Log to console  ========================================
    Set Feature Under Given Object  ${LNBTS_DistName}  ${precondition_flags_CB010397}  false
    Remove PSGRP/NRPGRP Objects If Exist  PSGRP
    Commission LoadSettings For LNCELs    ${lncels_dn}    0.5
    ${COUNTER_AFTER_TEST}=  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}

PS.67_CB010397-F_LB_PS_Mixed_Switch_Off_Method_Conf_Change.Test Case Teardown
    #Run Keyword And Ignore Error    Set Feature Under LNBTS/NRBTS Via NA  actMixedSOMethod  false    LNBTS
    Run Keywords  common.Common Test Teardown
    Run Keyword If Test Failed  PS.67_CB010397-F_LB_PS_Mixed_Switch_Off_Method_Conf_Change.Test Specific Teardown

PS.67_CB010397-F_LB_PS_Mixed_Switch_Off_Method_Conf_Change.Test Specific Teardown
    [Documentation]  Test Specific Teardown.
    admin.setup admin  admin_api_log_dir=${RESULTS}/admin_api/  alias=${ute_admin_alias}
    Run Keyword And Ignore Error  Set Feature Under Given Object  ${LNBTS_DistName}  ${precondition_flags_CB010397}  false
    Run Keyword And Ignore Error  Remove PSGRP/NRPGRP Objects If Exist  PSGRP
    admin.teardown admin  alias=${ute_admin_alias}
