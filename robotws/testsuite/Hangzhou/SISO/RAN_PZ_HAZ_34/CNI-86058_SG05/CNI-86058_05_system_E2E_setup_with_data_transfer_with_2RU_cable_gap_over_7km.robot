*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Timeout         40 min

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot
Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB008952_SG05/resource/resource.robot



Documentation
...    Author: Liu Yue
...    Contact: yue.2.liu@nokia-sbell.com
...    squad group:SG_05
...    Feature CNI-86058 in 5G22R1 program

Force Tags    5G_RAN_TDD

*** Variables ***

*** Test Cases ***
[1]CNI-86058_05_system_E2E_setup_with_data_transfer_with_2RU_cable_gap_over_7km
    [Setup]    SISO Coam Test Setup
    ${cell_list}    create list    ${1}
    Get UE From Init File and Make call with cpe 3_2    cell_list=${cell_list}    with_peak=${True}    4G_check=${False}
    [Teardown]    SISO Coam Test Teardown
### part-3: CB006277 peak cases - 5 TCs  ###
[1]CB006277_BB_02_AQQL_eCPRI_peak_Tput_with_chbw_20Mhz
    [Tags]   1S-1CC-8D4U_A8_20M_C2-195_2089-41    CLOUD_5G_CLASSICAL_ASIBR_ABIOB4_AQQL_ENB
    [Setup]    SISO Coam Test Setup
    sleep    6min
    ${cell_list}    create list    ${1}
    Get UE From Init File and Make call with cpe 3_2    cell_list=${cell_list}    with_peak=${True}
    [Teardown]    SISO Coam Test Teardown

[1]CB006277_BG_02_AQQL_eCPRI_peak_Tput_with_chbw_40Mhz
    [Tags]    1S-1CC-8D4U_A6_40M_A2-98_2089-41    CLOUD_5G_CLASSICAL_ASIBR_ABIOB4_AQQL_ENB
    [Setup]    SISO Coam Test Setup
    sleep    6min
    ${cell_list}    create list    ${1}
    Get UE From Init File and Make call with cpe 3_2    cell_list=${cell_list}    with_peak=${True}
    [Teardown]    SISO Coam Test Teardown

[1]CB006277_BH_02_AQQL_eCPRI_peak_Tput_with_chbw_50Mhz
    [Tags]    1S-1CC-8D4U_A3_50M_F0-7_2089-41    CLOUD_5G_CLASSICAL_ASIBR_ABIOB4_AQQL_ENB   
    [Setup]    SISO Coam Test Setup
    sleep    6min
    ${cell_list}    create list    ${1}
    Get UE From Init File and Make call with cpe 3_2    cell_list=${cell_list}    with_peak=${True}
    [Teardown]    SISO Coam Test Teardown

[1]CB006277_BI_02_AQQL_eCPRI_peak_Tput_with_chbw_60Mhz
    [Tags]    1S-1CC-8D4U_A8_60M_B4-156_2089-41    CLOUD_5G_CLASSICAL_ASIBR_ABIOB4_AQQL_ENB
    [Setup]    SISO Coam Test Setup
    sleep    6min
    ${cell_list}    create list    ${1}
    Get UE From Init File and Make call with cpe 3_2    cell_list=${cell_list}    with_peak=${True}
    [Teardown]    SISO Coam Test Teardown

[1]CB006277_AE_03_AQQL_eCPRI_peak_Tput_with_4x4MIMO
    [Tags]    1S-1CC-8D4U_A5_100M_C2-191_TA-3000_2089-41    CLOUD_5G_CLASSICAL_ASIBR_ABIOB4_AQQL_ENB
    [Setup]    SISO Coam Test Setup
    sleep    6min
    ${cell_list}    create list    ${1}
    Get UE From Init File and Make call with cpe 3_2    cell_list=${cell_list}    with_peak=${True}
    [Teardown]    SISO Coam Test Teardown

