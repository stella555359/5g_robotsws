*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Setup           SISO Coam Test Setup    fail_with_alarms=${True}    is_ru_log_collecting_enable=${True}
Test Teardown        SISO Coam Test Teardown
Test Timeout         4h

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/5G/General_SiSo_RF_module_reset_from_GUI.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource     ./Resources/CB010889_common_keywords.robot

Documentation
...    Author: Shifu Lan
...    Contact: shifu.lan@nokia-sbell.com
...    squad group:SG_04
...    Feature CB010889

Force Tags    HAZ4_T04


*** Test Cases ***
[1]CB010889_SR_CB_09_AQQY_3CC_16D8U_MIX_8D8U_L3Call_setup_with_data_transfer_conducted_80M_50M_50M_Regression
    [Tags]    1S-1CC-16D-8U-2CC-8D-8U    RF50
    L3Call_setup_with_data_transfer_conducted_80M_50M_50M    with_call=${True}
    [Teardown]    SISO Coam Test Teardown    perform_case_scf=${True}

[1]CB010889_SR_AVQC_Online_8Rx_Commission_with_L3Call_Regression
    [Tags]    2S-4CC-16D-8U    RF50
    Online_8Rx_Commission_with_L3Call_Regression    with_call=${True}    ue_num_each_call=${2}
    [Teardown]    SISO Coam Test Teardown    perform_case_scf=${True}

[1]CB010889_SR_DB-B1_03_AVQC_3CC_16D8U_General_SiSo_RU_module_reset_from_GUI
    [Tags]    2S-3CC-16D-8U    RF50
    General_SiSo_RF_module_reset_from_GUI    with_call=${True}    ue_num_each_call=${2}
