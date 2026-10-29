*** Settings ***
Suite Setup          CBRS Suite Setup
Suite Teardown       CBRS Suite Teardown
Test Setup           CBRS Test Setup
Test Teardown        CBRS Test Teardown

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_RF_module_reset_from_GUI.robot
Resource    ../CB007857/resources/CB007857_common_keywords.robot
Variables    ../CB007857/TestData/7857_variables.py

Documentation
...    Author:Ye Tianyi
...    contact:tianyi.ye@nokia-sbell.com
...    squad group:SG_08
...    Feature CB008827

Force Tags    SBTS00    CRT_TRUNK    CRT_23R1

*** Variables ***

*** Test Cases ***
[1]General_SiSo_RU_module_reset_from_GUI
    ${10M_SCF}    Replace String    ${Golden_SCF_Path}    SCF_    SCF_10M_
    Commissioning SCF And Check RU On Air    scf_file_path=${10M_SCF}
    Activate feature CBRS By Coam
    Verify_CBRS_L3_call_10MHz    tput_self_define=${tput_define_10}
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    General_SiSo_RF_module_reset_from_GUI

*** Keywords ***
