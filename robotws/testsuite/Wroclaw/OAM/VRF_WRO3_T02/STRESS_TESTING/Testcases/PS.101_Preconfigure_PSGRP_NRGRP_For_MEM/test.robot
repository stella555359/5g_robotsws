*** Settings ***
Resource    ../../../resources_mem/common.robot
Resource    ../../../resources_mem/alarms.robot
Resource    ../../../resources_mem/ald.robot
Resource    ../../../resources_mem/netact.robot
Resource    ../../../resources_mem/power_saving.robot
Resource    ../../../resources_mem/L3_call.robot

Documentation
...  TEST NAME:     PS.101_Preconfigure_PSGRP_NRGRP_For_MEM
...  AUTHORS:       roscislaw.szuminski@nokia.com
...  MAINTAINER:    RAN_PZ_WRO_3_SG01
...  *****************
...  Basic information
...  *****************
...  The test case activates and schedules power saving features and creates PSGRP/NRPGRP based on detected RATs
...  and site composition
...  *****************
...  Pre-conditions
...  *****************
...  N/A
...  ******************
...  History of changes
...  ******************
...  25.10.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-453 - Test case creation

...  *******************
...  RAN PZ3 WRO1 TEMPLATE

*** Variables ***
${delta_create_psgrp}  psgrp_create
${ps_nr_flags}  actNrLBPowerSaving  actLbpsCtrlLogicEnh

*** Keywords ***
PS.101_Preconfigure_PSGRP_NRGRP_For_MEM

    PS.101_Preconfigure_PSGRP_NRGRP_For_MEM.Test_Step:0 Test Preparation
    PS.101_Preconfigure_PSGRP_NRGRP_For_MEM.Test_Step:1 Select Random Cells Based On RAT Detection And Create And Activate PSGRP/NRPGRP For Each Hour

PS.101_Preconfigure_PSGRP_NRGRP_For_MEM.Test_Step:0 Test Preparation
    Log to console    \n========================================
    Log  Step: 0 Test Preparation  console=${True}
    Log to console    ========================================
    Set Default LoadSettings For LNCELs
    Remove PSGRP/NRPGRP Objects If Exist  PSGRP
    Remove PSGRP/NRPGRP Objects If Exist  NRPGRP
    ${ps_lte_flags}=  Create List    actLBPowerSaving
    Run Keyword If  '${SMOD_COMPOSITION}'!='FSMF' and '${SMOD_COMPOSITION}'!='FSMF+FSMF'
    ...  Append To List  ${ps_lte_flags}  actLbpsCtrlLogicEnh
    Set Test Variable  ${ps_lte_flags}
    ${COUNTER_BEFORE_TEST}=  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}
    ${if_actCo4g5g}  ${value_actCo4g5g}=  Run Keyword And Ignore Error  Get Parameter Value Under LNBTS  actCoordinated4g5gPowerSaving
    Set Test Variable  ${if_actCo4g5g}
    ${if_actNrExtCellSOMethod}  ${value_actNrExtCellSOMethod}=  Run Keyword And Ignore Error  Get Parameter Value Under NRBTS  actNrExtCellSOMethod
    Set Test Variable  ${if_actNrExtCellSOMethod}
    ${sw_splited}  Split String  ${active_sw_version}  _
    ${sw_prefix} = 	Get From List  ${sw_splited}  0
    Set Test Variable  ${sw_prefix}
    Check which RAT are on given TestLine

PS.101_Preconfigure_PSGRP_NRGRP_For_MEM.Test_Step:1 Select Random Cells Based On RAT Detection And Create And Activate PSGRP/NRPGRP For Each Hour
    Log to console  \n========================================
    Log  Step: 1 Select Random Cells Based On RAT Detection And Create And Activate PSGRP/NRPGRP For Each Hour  console=${True}
    Log to console  ========================================
    Run Keyword If  '${IF_LTE_EXIST}'=='EXIST' and '${IF_NR_EXIST}'=='NO' and ('${sw_prefix}'=='SBTS00' or '${sw_prefix}'=='SBTS24R1')
    ...  Run Keywords
    ...  Select Two Random LTE Cells
    ...  AND  Log To Console  Energy Saving for LNCEL_R-${1st_LNCEL_ID} and LNCEL_R-${2nd_LNCEL_ID}
    ...  AND  Create And Activate PSGRP For Each Hour  ${1st_LNCEL_DN}  ${2nd_LNCEL_DN}  PSGRP-1  55min
    ...  AND  Set Feature Under LNBTS/NRBTS Object  ${ps_lte_flags}  true  LNBTS
    ...  ELSE IF  '${IF_LTE_EXIST}'=='NO' and '${IF_NR_EXIST}'=='EXIST' and ('${sw_prefix}'=='SBTS00' or '${sw_prefix}'=='SBTS24R1')
    ...  Run Keywords
    ...  Select Two Random NR Cells
    ...  AND  Log To Console  Energy Saving for NRCEL_R-${1st_NRCELL_ID} and NRCEL_R-${2nd_NRCELL_ID}
    ...  AND  Create And Activate NRPGRP For Each Hour  ${1st_NRCELL_DN}  ${2nd_NRCELL_DN}  NRPGRP-1  55min
    ...  ELSE IF  '${IF_LTE_EXIST}'=='EXIST' and '${IF_NR_EXIST}'=='EXIST' and ('${sw_prefix}'=='SBTS00' or '${sw_prefix}'=='SBTS24R1')
    ...  Run Keywords
    ...  Select Two Random LTE Cells
    ...  AND  Select Two Random NR Cells
    ...  AND  Log To Console  Energy Saving for LNCEL_R-${1st_LNCEL_ID} and LNCEL_R-${2nd_LNCEL_ID}
    ...  AND  Log To Console  Energy Saving for NRCEL_R-${1st_NRCELL_ID} and NRCEL_R-${2nd_NRCELL_ID}
    ...  AND  Create And Activate PSGRP For Each Hour  ${1st_LNCEL_DN}  ${2nd_LNCEL_DN}  PSGRP-1  55min
    ...  AND  Set Feature Under LNBTS/NRBTS Object  ${ps_lte_flags}  true  LNBTS
    ...  AND  Create And Activate NRPGRP For Each Hour  ${1st_NRCELL_DN}  ${2nd_NRCELL_DN}  NRPGRP-1  55min
    ...  AND  Set Feature Under LNBTS/NRBTS Object  ${ps_nr_flags}  true  NRBTS

PS.101_Preconfigure_PSGRP_NRGRP_For_MEM.Test Specific Teardown
    [Documentation]  Test Specific Teardown.
    Log To Console  \n============ SPECIFIC TEST TEARDOWN =============
    admin.setup admin  admin_api_log_dir=${RESULTS}/admin_api/  alias=${ute_admin_alias}
    Run Keyword If  '${IF_NR_EXIST}'=='EXIST' and '${IF_LTE_EXIST}'=='EXIST'  Run Keywords
    ...  Run Keyword And Ignore Error  Set Feature Under LNBTS/NRBTS Object  ${ps_lte_flags}  false  LNBTS
    ...  AND  Run Keyword And Ignore Error  Set Feature Under LNBTS/NRBTS Object  ${ps_nr_flags}  false  NRBTS
    ...  AND  Run Keyword And Ignore Error  Remove PSGRP/NRPGRP Objects If Exist  PSGRP
    ...  AND  Run Keyword And Ignore Error  Remove PSGRP/NRPGRP Objects If Exist  NRPGRP
    ...  ELSE IF  '${IF_LTE_EXIST}'=='EXIST' and '${IF_NR_EXIST}'=='NO'  Run Keywords
    ...  Run Keyword And Ignore Error  Set Feature Under LNBTS/NRBTS Object  ${ps_lte_flags}  false  LNBTS
    ...  AND  Run Keyword And Ignore Error  Remove PSGRP/NRPGRP Objects If Exist  PSGRP
    ...  ELSE IF  '${IF_LTE_EXIST}'=='NO' and '${IF_NR_EXIST}'=='EXIST'  Run Keywords
    ...  Run Keyword And Ignore Error  Set Feature Under LNBTS/NRBTS Object  ${ps_nr_flags}  false  NRBTS
    ...  AND  Run Keyword And Ignore Error  Remove PSGRP/NRPGRP Objects If Exist  NRPGRP
    admin.teardown admin  alias=${ute_admin_alias}
    Log To Console  ========== SPECIFIC TEST TEARDOWN DONE ==========\n

PS.101_Preconfigure_PSGRP_NRGRP_For_MEM.Test Case Teardown
    Run Keywords  common.Common Test Teardown
    Run Keyword If Test Failed  PS.101_Preconfigure_PSGRP_NRGRP_For_MEM.Test Specific Teardown



