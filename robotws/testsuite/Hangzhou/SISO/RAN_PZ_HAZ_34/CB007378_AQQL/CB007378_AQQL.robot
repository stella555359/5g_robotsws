*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Setup           #SISO Coam Test Setup
Test Teardown        #SISO Coam Test Teardown
Test Timeout         90 min

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    ${BASIC_PATH_5G}/BTS/General_SiSo_Peak_with_Given_Information.robot
Resource    ${BASIC_PATH_5G}/Cell/General_SiSo_Cell_block_and_unblock.robot
#Resource    ${BASIC_PATH_5G}/E2E_SiSo_RU_lock_and_unlock_gNB.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/ru_operation.robot

#Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/get_case_variables.py
#Variables   TestData/case_variables.yml

Documentation
...    Author: Liu Yue
...    Contact: yue.2.liu@nokia-sbell.com
...    squad group:SG_05
...    Feature CB007378 ABIN in SBTS22R4 program with configuration CB007378-A2 and CB007378-B3

Force Tags     RAN_5G     RAN_5G_TDD    STATE_SW_UPLOADED    SBTS00    PY36    master_classicalbts_all

*** Variables ***

*** Test Cases ***
[1]CB007378-A_02_02_AQQL_General_SiSo_Cell_block_and_unblock
    [Tags]    1S-2CC-8D4U_50-50M_7378-A2    CRT_23R2   CRT_23R3   CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    General_SiSo_Cell_block_and_unblock    with_call=${True}   with_peak=${False}

#    General_SiSo_Cell_block_and_unblock         with_call=${False}
#    General_SiSo_Peak_with_Given_Information    use_case_variable=${True}
#    ...                                         suite_name=${SUITE NAME}
#    ...                                         test_name=${TEST NAME}
    [Teardown]    SISO Coam Test Teardown

#[1]CB007378_A_02_04_AQQL_eCPRI_peak_Tput_with_Dual_carrier_100+100MHz_25GE
#    [Tags]    1S-2CC-8D4U_50-50M_7378-A2    CRT_23R2   CRT_23R3   CRT_TRUNK
#    [Setup]    SISO Coam Test Setup
#    General_SiSo_Peak_with_Given_Information    use_case_variable=${True}
#    ...                                         suite_name=${SUITE NAME}
#    ...                                         test_name=${TEST NAME}
#    [Teardown]    SISO Coam Test Teardown

[1]CB007378-B_03_04_AQQL_General_SiSo_RU_lock_unlock
    [Tags]    1S-2CC-4D4U_40-20M_7378-B3    CRT_23R2   CRT_23R3   CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    CB007511_E2E_SiSo_RU_lock_and_unlock_gNB    with_call=${True}   with_peak=${False}   call_duration=${300}
#    E2E_SiSo_RU_lock_and_unlock_gNB    with_call=${True}  with_peak=${False}  call_duration=${300}

#    E2E_SiSo_RU_lock_and_unlock_gNB             with_call=${False}
#    General_SiSo_Peak_with_Given_Information    use_case_variable=${True}
#    ...                                         suite_name=${SUITE NAME}
#    ...                                         test_name=${TEST NAME}
    [Teardown]    SISO Coam Test Teardown

#[1]CB007378-B_03_10_AQQL_eCPRI_peak_Tput_with_Dual_carrier_40+20MHz_25GE
#    [Tags]    1S-2CC-4D4U_40-20M_7378-B3    CRT_23R2   CRT_23R3   CRT_TRUNK
#   [Tags]    CRT_22R4   CRT_TRUNK
#    [Setup]    SISO Coam Test Setup
#    General_SiSo_Peak_with_Given_Information    use_case_variable=${True}
#    ...                                         suite_name=${SUITE NAME}
#    ...                                         test_name=${TEST NAME}
#    [Teardown]    SISO Coam Test Teardown

*** Keywords ***
CB007511_E2E_SiSo_RU_lock_and_unlock_gNB
    [Arguments]  ${with_call}=${True}  ${with_peak}=${False}  ${call_duration}=${60}
    ${ru_index_list}    get all ru index
    ${ru_num}    get length  ${ru_index_list}
    ${cell_list}    get all cell id
    Get X2 link shutdown waiting time
    Selenium Login And Disable Screen Lock
    ${check_alarm}    set variable if    ${ru_num}==1    ${True}    ${False}
    FOR  ${lock_id}  IN  @{ru_index_list}
        ${operate_list}    create list    ${lock_id}
        ${cell_list}    get all cell id    ru_index=${lock_id}
        Get UE From Init File and Make call    cell_list=${cell_list}  with_peak=${with_peak}    duration=${call_duration}
        ${status}    run keyword and return status    Create file in RU    ru_index=${lock_id}
        Lock all RUs and check status    ru_index_list=${operate_list}    check_alarm=${check_alarm}
        ...    gnb_type='${gNb_CuType}'
        ${PowerState}=    Check RU powerState    ru_index=${lock_id}
        Unlock all RUs and check status    ru_index_list=${operate_list}    check_alarm=${check_alarm}
        ...    gnb_type='${gNb_CuType}'
        Get UE From Init File and Make call    cell_list=${cell_list}  with_peak=${with_peak}    duration=${call_duration}
        run keyword if    ${status} and '${PowerState}'!='SLEEP'    Check file Exist in RU    ru_index=${lock_id}
    END
    run keyword if  ${ru_num}>1    run keywords
    ...    Lock and Unlock all RUs  lock_list=${ru_index_list}    AND
    ...    Get UE From Init File and Make call    cell_list=${cell_list}  with_peak=${with_peak}    duration=${call_duration}
    [Teardown]  Selenium Logout And Close Browser

Check RU powerState
    [Arguments]  ${ru_index}=${1}    ${connection}=GNB_OAM
    &{ru_status}    COAM get ru detial info by ru index     ru_index=${ru_index}   connection=${connection}
    ${ru_powerState}    Set Variable    ${ru_status['status']['powerState']}
    [Return]    ${ru_powerState}
