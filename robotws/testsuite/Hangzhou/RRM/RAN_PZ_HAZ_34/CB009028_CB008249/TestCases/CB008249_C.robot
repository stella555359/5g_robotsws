*** Settings ***
Resource    ./../Resources/CB008249_keywords.robot

Documentation    Suite description
...    author: Jin Journey
...    contact: journey.jin@nokia-sbell.com
...    squad group: NSB_MN_RAN_Pz_3_HAZ_1_SG
...    Feature CB009028_CB008249

Suite Setup  8249 Suite preparation
Suite Teardown  run keyword and ignore error    Common suite recovery    is_log_required=${True}

*** Variables ***
#UL TPUT only can be reached rank1 when enable ulsrs and dlsrs
${TDD_UL_EXP_TPUT}     110
${TDD_DL_EXP_TPUT}     1440

*** Test Cases ***
[1]CB008249-SR_C_010_Remote_interference_mitigation_in_eCPRI_1116_3ms_GP_6symbols_100M
    [Tags]    CRT_TRUNK
    [Documentation]     Author: Jin Journey
    ...    Description:The purpose of this test is to verify RI trigger and RI mitigation
    ...    step 1>  Lock aggressor gnb cell,enable feature in victim gnb and check tput
    ...    step 2>  Add interference from aggressor gnb and check if RI is detected in victim gnb
    ...    step 3>  Check RI mitigation action after RI detected
    ...    step 4>  Verify RI is disappear after stop interference

    [Setup]     8249 case setup

    run keyword and continue on failure    L3 call and check tput for each cell    cell_id=${TDD_CELL_ID}    dl_tput=${DL_TPUT}
    ...    ul_tput=${UL_TPUT}    exp_dl=${TDD_DL_EXP_TPUT}    exp_ul=${TDD_UL_EXP_TPUT}
    run keyword and continue on failure    Stop data transfer and detach UE
    Add interference from aggressor gnb and check RI is detected
    Capture Bip log and Check UL mitigation after RI detected in bip log
    Verify RI is disappear after stop interference

    [Teardown]  run keyword and ignore error    Common case teardown    detach_ue=${True}    restapi_restore_nidd=${RESTAPI_DISABLE_8249}
