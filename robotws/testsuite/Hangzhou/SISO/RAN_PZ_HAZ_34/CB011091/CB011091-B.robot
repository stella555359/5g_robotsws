*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Setup           #SISO Coam Test Setup
Test Teardown        #SISO Coam Test Teardown
Test Timeout         120 min

Resource             testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource             ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource             ${BASIC_PATH_5G}/Cell/General_SiSo_Cell_lock_and_unlock.robot
Resource             ${BASIC_PATH_5G}/General_SiSo_RF_module_reset_from_GUI.robot
Resource             testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB006277/resource/resources_l3call.robot

Documentation
...    Author: Liu Yue
...    Contact: yue.2.liu@nokia-sbell.com
...    squad group:SG_05
...    Feature CB011091 FR1 TDD configs eCPRI for ASOG/ASOH which including sub-features in scope of HAZ4_T05:
...    CB011091-B:
...        FR1 TDD NR configuration on one ASOG/H up to 6 cells of up to 8DL4UL layers with 8Rx IRC on MAA radios
...    Configuration blocks:
...        FR1 TDD NR configuration on one ASOG/H up to 6 cells of 8DL4UL layers (8DL8UL streams) with 8Rx IRC on mMIMO radios
...            · Up to 3S-1CC-8DL4UL layers with 8Rx IRC on half ASOG/H     # 25R1_N_CB011091_B1
...            · Up to 3S-2CC-8DL4UL layers with 8Rx IRC on one ASOG/H      # 25R1_N_CB011091_B2
...            · Up to 1S-3CC-8DL4UL layers with 8RX IRC on half ASOG/H     # 25R1_N_CB011091_B3
...    BB cell set (CB011088-B):
...        up to 3 cells 8DL-4UL MIMO layers (8UL streams) BF with MAA radios on half ASOG/H, 8RX IRC receiver.

Force Tags     RAN_5G     RAN_5G_TDD    STATE_SW_UPLOADED    SBTS00    PY39    master_classicalbts_all

*** Variables ***

*** Test Cases ***
[1]CB011091_B1_General_SiSo_Cell_lock_and_unlock
    [Tags]    3S-1CC-8D8U_8Rx-4Rx-IRC_CB011091-B1    CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    General_SiSo_Cell_lock_and_unlock    with_call=${False}
#    sleep    3s
#    ${cell_list}    create list    ${1}
#    ${if_cpe3.2}    Run Keyword And Return Status   Should Contain Any   ${tl.ues[0].version}   3.2   cpe3.2   ignore_case=true
#    Run Keyword If    ${if_cpe3.2}    Get UE From Init File and Make call with cpe 3_2    cell_list=${cell_list}   with_peak=${False}
#    ...    ELSE    Get UE info and do L3 Call    cell_list=${cell_list}    with_peak=${False}
    [Teardown]    SISO Coam Test Teardown

[1]CB011091_B2_General_SiSo_E2E_system_setup_with_data_transfer_conducted
    [Tags]    3S-2CC-8D8U_8Rx-4Rx-IRC_CB011091-B2    CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    log to console    Commission with CB011091-B2 completed
#    ${cell_list}    create list    ${1}
#    ${if_cpe3.2}    Run Keyword And Return Status   Should Contain Any   ${tl.ues[0].version}   3.2   cpe3.2   ignore_case=true
#    Run Keyword If    ${if_cpe3.2}    Get UE From Init File and Make call with cpe 3_2
#    ...    cell_list=${cell_list}    with_peak=${True}   4G_check=${False}
#    ...    ELSE    Get UE info and do L3 Call    cell_list=${cell_list}    with_peak=${False}
    [Teardown]    SISO Coam Test Teardown

[1]CB011091_B3_General_SiSo_RU_module_reset_from_GUI
    [Tags]    1S-3CC-8D8U_8Rx-4Rx-IRC_CB011091-B3    CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    General_SiSo_RF_module_reset_from_GUI    with_call=${False}
#    ${cell_list}    create list    ${1}
#    ${if_cpe3.2}    Run Keyword And Return Status   Should Contain Any   ${tl.ues[0].version}   3.2   cpe3.2   ignore_case=true
#    Run Keyword If    ${if_cpe3.2}    Get UE From Init File and Make call with cpe 3_2
#    ...    cell_list=${cell_list}    with_peak=${True}   4G_check=${False}
#    ...    ELSE    Get UE info and do L3 Call    cell_list=${cell_list}    with_peak=${False}
    [Teardown]    SISO Coam Test Teardown

*** Keywords ***
