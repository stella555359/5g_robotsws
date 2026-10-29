*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Setup           SISO Coam Test Setup    fail_with_alarms=${True}
Test Teardown        SISO Coam Test Teardown
Test Timeout         200 min

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    Resource/CB008990_common_keyword.robot

Documentation
...    Author:kaihui fan
...    contact:kaihui.fan@nokia-sbell.com
...    squad group:SG_04
...    Feature Owner: Shu Zhichao
...    Feature CB008990  AEQY in trunk program

Force Tags            5G_RAN    5G_RAN_TDD    RAN_5G_TDD    RAN_5G    STATE_SW_UPLOADED
...   PY36

*** Variables ***

*** Test Cases ***
[1]CB008990-SR-01_Ecpri_RU_DFE-Beamer_link_fault_activation
    ${fault_list}    Create List    1103    1904    1981
    Allowed Watchdog additional alarms    fault_list=${fault_list}
    General_SiSo_Ecpri_RU_DFE-Beamer_link_fault_activation   with_call=${True}  with_peak=${False}

[1]CB008990-SR-01_Ecpri_RU_DFE_no_TX_Data_fault_activation
    ${fault_list}    Create List    1981
    Allowed Watchdog additional alarms    fault_list=${fault_list}
    General_SiSo_Ecpri_RU_DFE_no_TX_Data_fault_activation   with_call=${True}  with_peak=${False}
