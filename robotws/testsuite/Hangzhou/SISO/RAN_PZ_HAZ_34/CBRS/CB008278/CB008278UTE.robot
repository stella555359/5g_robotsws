*** Settings ***
Suite Setup          CBRS UTE Upgrade Suite Setup    UTECloud=True
Suite Teardown       CBRS Suite Teardown
Test Setup           CBRS Test Setup
Test Teardown        CBRS Test Teardown

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_RF_module_reset_from_GUI.robot
Resource    resources/CB008278_common_keywords.robot

Documentation
...    Author:linjiangjing
...    contact:jiangjing.lin@nokia-sbell.com
...    squad group:SG_08
...    Feature CB008278

Force Tags    RAN_5G_TDD    5G_RAN_TDD    RAN_5G    5G_RAN    CRT_UTE    STATE_SW_UPLOADED    SBTS00
...    PY36
...    CLOUD_5G_CLASSICAL_SA_ASOE_AWHQU_HAZ

*** Test Cases ***
[1]CB008278-B_22_CBSD_behavior_check_when_RU_reset_AWHQU
    [Tags]    CRT_TRUNK
    ${SCF_10M_10M}    Replace String    ${Golden_SCF_Path}    SCF_    SCF_8278_10M_10M_
    Commissioning SCF And Check RU On Air   scf_file_path=${SCF_10M_10M}
    Activate feature CBRS By Coam
    Start SAS server
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    General_SiSo_RF_module_reset_from_GUI

[1]CB008278-B_5_General_SiSo_E2E_system_setup_with_data_transfer_on_10MHz_AWHUQ_2CC
    [Tags]    CRT_TRUNK
    ${SCF_10M_10M}    Replace String    ${Golden_SCF_Path}    SCF_    SCF_8278_10M_10M_
    Commissioning SCF And Check RU On Air   scf_file_path=${SCF_10M_10M}
    General_SiSo_E2E_system_setup_with_data_transfer_conducted (max MCS L3 call)_2CC_10MHz+10MHz
