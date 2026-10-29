*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Setup           SISO Coam Test Setup    fail_with_alarms=${True}
Test Teardown        SISO Coam Test Teardown
Test Timeout         4h

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    Resource/CNI_112018_common_keyword.robot


Documentation
...    Author:kaihui fan
...    contact:kaihui.fan@nokia-sbell.com
...    squad group:SG_04
...    Feature Owner: Shi Gaofan
...    Feature CNI-112018_CB008990  AVQC in trunk program

Force Tags            5G_RAN    5G_RAN_TDD    RAN_5G_TDD    RAN_5G    STATE_SW_UPLOADED    PY310    HAZ4_T04


*** Test Cases ***
[1]CNI-112018_CB008990_02_Ecpri_RU_DFE_no_TX_Data_fault_activation
    [Tags]    2S-2CC-16D-2U_72E
    ${fault_list}    Create List    1904    1981    1907
    Allowed Watchdog additional alarms    fault_list=${fault_list}
    General_SiSo_Ecpri_RU_DFE_no_TX_Data_fault_activation   with_call=${True}  with_peak=${False}    ue_num_each_call=${2}

[1]CNI-112018_CB009226_01_SFP_alarm_monitoring_activation
    ${fault_list}    Create List    4698    4699    4700    4701
    Allowed Watchdog additional alarms    fault_list=${fault_list}
    General_SiSo_SFP_alarm_monitoring_activation