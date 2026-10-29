*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
#Test Setup           SISO Coam Test Setup
#Test Teardown        SISO Coam Test Teardown
Test Timeout         100 min

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_RF_module_reset_from_GUI.robot
Resource    ${BASIC_PATH_5G}/Cell/General_SiSo_Cell_block_and_unblock.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_NR-ARFCN_check.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot.robot
Resource    ${BASIC_PATH_5G}/5GC000399/5GC000399_eCPRI_FREERUN_state_handling.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_RF_module_power_reset.robot
Resource    ${BASIC_PATH_5G}/E2E_SiSo_RU_lock_and_unlock_gNB.robot
Resource     ../resource/resources_l3call.robot

Documentation
...    Author: Liu Yue
...    Contact: yue.2.liu@nokia-sbell.com
...    squad group:SG_05
...    Feature CB006277 in 5G22R1 program

Force Tags    RAN_5G_TDD
...    PY36

*** Variables ***

&{PARA_MODIFY}    dist_name=MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1
...    p_name=topDomainNumber    filter_param=ToP domain number    value=43
@{TOP_DOMAIN_NUMBER_MODIFY}    &{PARA_MODIFY}

*** Test Cases ***
[1]CB006277_AC_06_AQQL_eCPRI_RF_module_reset_from_GUI
    [Tags]    master_classicalbts_all    CIT_TRUNK   CDRT_22R2   CIT_22R3    CDRT_22R1   CIT_22R4
    [Setup]    SISO Coam Test Setup
    General_SiSo_RF_module_reset_from_GUI    with_call=${False}
    sleep    3s
    ${cell_list}    create list    ${1}
    #Run Keyword If    ${MRBTS_ID}==${2599}    Samsung open screen
    Get UE info and do L3 Call    cell_list=${cell_list}    with_peak=${False}
    [Teardown]    SISO Coam Test Teardown    is_check_historyalarm=${True}

[1]CB006277_AC_04_AQQL_eCPRI_General_SiSo_Cell_lock_and_unlock
    [Tags]    master_classicalbts_all    CIT_TRUNK   CDRT_22R2   CIT_22R3   CIT_22R4
    [Setup]    SISO Coam Test Setup
    ${fault_49}    Create Dictionary    faultId=${49}
    Append To List     ${ALLOWED_HISTORY_FAULT}    ${fault_49}
    Set Suite Variable    ${ALLOWED_HISTORY_FAULT}
    General_SiSo_Cell_block_and_unblock    with_call=${False}
    sleep    3s
    ${cell_list}    create list    ${1}
    #Run Keyword If    ${MRBTS_ID}==${2599}    Samsung open screen
    Get UE info and do L3 Call    cell_list=${cell_list}    with_peak=${False}
    [Teardown]    SISO Coam Test Teardown     is_check_historyalarm=${True}

#[1]CB006277_AC_07_AQQL_eCPRI_NR-ARFCN_check
#    [Tags]    master_classicalbts_all
#    [Setup]    SISO Coam Test Setup
#    General_SiSo_NR-ARFCN_check
#    [Teardown]    SISO Coam Test Teardown
#[1]CB006277_AC_09_AQQL_eCPRI_Basic_RU_logs_collection
#    [Tags]    master_classicalbts_all
#    [Setup]    SISO Coam Test Setup
#    General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot
#    [Teardown]    SISO Coam Test Teardown
[1]CB006277_AC_11_AQQL_eCPRI_FREERUN_state_handling
    [Tags]    master_classicalbts_all    CRT_TRUNK    CRT_22R2   CRT_22R3   CDRT_22R1    CRT_22R4
    [Setup]    SISO Coam Test Setup
    5GC000399_eCPRI_FREERUN_state_handling
    [Teardown]    SISO Coam Test Teardown
[1]CB006277_AC_03_AQQL_eCPRI_General_SiSo_RF_module_power_reset
    [Tags]    master_classicalbts_all    CIT_TRUNK   CDRT_22R2   CIT_22R3   CDRT_22R1   CIT_22R4
    [Setup]    SISO Coam Test Setup
    ${fault_4589}    Create Dictionary    faultId=${4589}
    Append To List     ${ALLOWED_HISTORY_FAULT}    ${fault_4589}
    Set Suite Variable    ${ALLOWED_HISTORY_FAULT}
    General_SiSo_RF_module_power_reset    with_call=${False}
    sleep    3s
    ${cell_list}    create list    ${1}
    #Run Keyword If    ${MRBTS_ID}==${2599}    Samsung open screen
    Get UE info and do L3 Call    cell_list=${cell_list}    with_peak=${False}
    [Teardown]    SISO Coam Test Teardown    is_check_historyalarm=${True}
[1]CB006277_AC_05_AQQL_eCPRI_General_SiSo_RU_lock_and_unlock
    [Tags]    master_classicalbts_all     CIT_TRUNK   CRT_22R3   CDRT_22R2   CIT_22R4
    [Setup]    SISO Coam Test Setup
    #General_SiSo_RU_lock_unlock    with_call=${False}
    E2E_SiSo_RU_lock_and_unlock_gNB      with_call=${False}
    sleep    3s
    ${cell_list}    create list    ${1}
    #Run Keyword If    ${MRBTS_ID}==${2599}    Samsung open screen
    Get UE info and do L3 Call    cell_list=${cell_list}    with_peak=${False}
    [Teardown]    SISO Coam Test Teardown    is_check_historyalarm=${True}

