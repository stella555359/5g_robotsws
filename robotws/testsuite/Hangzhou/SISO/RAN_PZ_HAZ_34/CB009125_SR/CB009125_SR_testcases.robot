*** Settings ***
Suite Setup       9125 Coam Suite Setup
Suite Teardown    Run Keyword And Ignore Error     SISO Coam Suite Teardown
Test Setup        CB009125_SR Case Setup
Test Teardown     CB009125_SR Case Teardown
Force Tags    RAN_5G   RAN_5G_TDD   STATE_SW_UPLOADED   CLOUD_5G_CLASSICAL_ANDROID_SA_ASIBL_ABIOB1_AQHA_AHPH_2xAHPF   SBTS00   CRT_UTE
...    PY39
Library            OperatingSystem
Library            Collections
Library            BuiltIn
Library            String
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/5G/5G_Setup_And_Teardown.robot
Resource     testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB009125_SR/Resource/CB009125_SR_common_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot

Documentation
...   author: yulu
...   contact: lu.1.yu@nokia-sbell.com
...   squad group: SG_02

*** Test Cases ***
[1]CB009125_SR_B_B2_SISO_AQHA_02_ General_SiSo_Auto_RF_lock_unlock
    Run Keyword And Ignore Error    Restart CPE 5G19-A before start traffic for 9125    pc_index=${2}
    Sleep    5min
    Run Keyword And Ignore Error     Multiple UE Attach NR and LTE then Start Traffic
    Selenium Login And Disable Screen Lock
    ${ru_index_list}    Get All RU Index
    ${cell_list}    Get All Cell Id
    Connect to all rus with allocated IP
    Lock all RUs    ru_index_list=${ru_index_list}
    Unock all RUs    ru_index_list=${ru_index_list}
    Run Keyword And Ignore Error     Multiple UE Attach NR and LTE

[1]CB009125_SR_B_B2_SISO_AQHA_01_General_SiSo_Commissioning_BTS_Template_Commissioning
    Run Keyword And Ignore Error    Restart CPE 5G19-A before start traffic for 9125    pc_index=${2}
    Sleep    5min
    Run Keyword And Ignore Error     Multiple UE Attach NR and LTE then Check UL DL when delete one of LTE cell

[1]CB009125_SR_E_B2_3CC_RRM_Peak_throughput_with_DL_256QAM_and_UL_64QAM Modulation
    Run Keyword And Ignore Error    Restart CPE 5G19-A before start traffic for 9125    pc_index=${2}
    Sleep    5min
    Run Keyword And Ignore Error     Multiple UE Attach NR and LTE then Check UL DL maximum Tput
