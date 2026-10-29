*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Setup           SISO Coam Test Setup    fail_with_alarms=${True}
Test Teardown        SISO Coam Test Teardown
Test Timeout         24h

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    ${BASIC_PATH_5G}/BTS/General_SiSo_Peak_with_Given_Information.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/nrarfcn_and_gscn.robot

Documentation
...    Author:zhihao shi
...    contact:zhihao.shi@nokia-sbell.com
...    squad group:SG_04
...    Feature CB009104 in SBTS00 program

Force Tags            5G_RAN    5G_RAN_TDD    RAN_5G_TDD    RAN_5G    STATE_SW_UPLOADED   CLOUD_5G_CLASSICAL_SA_ASIML_ABIOB1_AZNA
...    PY36

*** Variables ***

*** Test Cases ***
# TL568(SA)(UTE Cloud)  -- SBTS23R3
# CB009104-SR-A 30M  1 link peak call (avg:0.9 min:0.8)
[1]CB009104-SR-A_08_General_SiSo_E2E_system_setup_with_data_transfer_conducted_30M_SA_call
    [Tags]    SBTS00    CRT_UTE
    Modify_Three_Parameter_for_CB007331    carriermode=true    iqcompression=9bits    actdownsampling=false
    General_SiSo_Peak_with_Given_Information    band=30    frame_structure=1116_0ms_GP1_A8
    ...    suite_name=${SUITE NAME}    test_name=${TEST NAME}

# CB009104-SR-A 50M  1 link peak call (avg:0.9 min:0.8)
[1]CB009104-SR-B_08_General_SiSo_E2E_system_setup_with_data_transfer_conducted_50M_SA_call
    [Tags]    SBTS00    CRT_UTE
    Modify_Three_Parameter_for_CB007331    carriermode=true    iqcompression=9bits    actdownsampling=false
    General_SiSo_Peak_with_Given_Information    band=50    frame_structure=1116_0ms_GP1_A8

*** Keywords ***
