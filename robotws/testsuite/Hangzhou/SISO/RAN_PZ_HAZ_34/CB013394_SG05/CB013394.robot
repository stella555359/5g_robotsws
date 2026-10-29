*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Setup           SISO Coam Test Setup
Test Teardown        SISO Coam Test Teardown
Test Timeout         230 min

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    ${BASIC_PATH_5G}/E2E_SiSo_RU_lock_and_unlock_gNB.robot
Documentation
...    Author: Liu Yue
...    Contact: yue.2.liu@nokia-sbell.com
...    squad group:SG_05
...    Feature 26R2 CB013394-SR-A-A3

Force Tags    RAN_5G_TDD
...    PY36

*** Test Cases ***
[1]CB013394-SR-A-A3_001_RU_Lock_Unlock_with_subBandBF_Celltype_16DL8UL
    [Tags]    SBTS00    1S-4CC-16D8U_16Rx_CB013394-A
    E2E_SiSo_RU_lock_and_unlock_gNB    with_peak=${False}    call_duration=${300}
