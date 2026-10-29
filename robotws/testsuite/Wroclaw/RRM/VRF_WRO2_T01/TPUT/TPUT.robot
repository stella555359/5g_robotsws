*** Settings ***
Documentation
...  author:        Pawel Wisniewski
...  contact:       pawel.1.wisniewski@nokia.com
...  description:   Test suite for CIT test cases execution.
...                 Target Test Line -> 7_16_UTE5GCLOUDT161

Library     taf.transport.ssh       WITH NAME    ssh
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T01/TPUT/kw_max_tput.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/setup_teardown.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/ute_report.robot
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/stop_and_fix.py  WITH NAME  sf
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/common.py
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/Suite_repository.robot

Force Tags      CA_5G_RRM  RAN_5G  RAN_5G_FDD  RAN_5G_FDD_MP  STATE_SW_UPLOADED  CIT
...             SBTS00__WITH__CLOUD_5G_CLASSICAL_ANDROID_ATT_ASIML_2xABIO_ABIP_AHFIB_3xAHLOA_2xAEHC

Suite Setup     Suite Setup FDD CIT

Suite Teardown  Suite Teardown FDD CIT


*** Test Cases ***
# UDP CIT
[1]Bi-Directional_Throughput_20B_noDss_Nsa_TputNsaSplitUDP_AhloaS1_DL4x2CL_UL2x2CL_Bw5MhzAr126900
    [Tags]  5
    [Setup]     Test Setup FDD CIT
    run_keyword_and_allow_retest
    ...  [1]Bi-Directional_Throughput_20B_noDss_Nsa_TputNsaSplitUDP_AhloaS1_DL4x2CL_UL2x2CL_Bw5MhzAr126900
    [Teardown]    Test Teardown FDD CIT

[1]Bi-Directional_Throughput_20B_noDss_Nsa_TputNsaSplitUDP_AhloaS1_DL4x2CL_UL2x2CL_Bw10MhzAr126900
    [Tags]  10
    [Setup]     Test Setup FDD CIT
    run_keyword_and_allow_retest
    ...  [1]Bi-Directional_Throughput_20B_noDss_Nsa_TputNsaSplitUDP_AhloaS1_DL4x2CL_UL2x2CL_Bw10MhzAr126900
    [Teardown]    Test Teardown FDD CIT

[1]Bi-Directional_Throughput_20B_noDss_Nsa_TputNsaSplitUDP_AhloaS1_DL4x2CL_UL2x2CL_Bw20MhzAr126900
    [Tags]  20
    [Setup]     Test Setup FDD CIT
    run_keyword_and_allow_retest
    ...  [1]Bi-Directional_Throughput_20B_noDss_Nsa_TputNsaSplitUDP_AhloaS1_DL4x2CL_UL2x2CL_Bw20MhzAr126900
    [Teardown]    Test Teardown FDD CIT

# TCP CRT
[1]Bi-Directional_Throughput_20B_noDss_Nsa_TputNsaSplitTCP_AhloaS1_DL4x2CL_UL2x2CL_Bw5MhzAr126900
    [Setup]     Test Setup Tput
    [1]Bi-Directional_Throughput_20B_noDss_Nsa_TputNsaSplitTCP_AhloaS1_DL4x2CL_UL2x2CL_Bw5MhzAr126900
    [Teardown]    Test Teardown Tput


[1]Bi-Directional_Throughput_20B_noDss_Nsa_TputNsaSplitTCP_AhloaS1_DL4x2CL_UL2x2CL_Bw10MhzAr126900
    [Setup]     Test Setup Tput
    [1]Bi-Directional_Throughput_20B_noDss_Nsa_TputNsaSplitTCP_AhloaS1_DL4x2CL_UL2x2CL_Bw10MhzAr126900
    [Teardown]    Test Teardown Tput


[1]Bi-Directional_Throughput_20B_noDss_Nsa_TputNsaSplitTCP_AhloaS1_DL4x2CL_UL2x2CL_Bw20MhzAr126900
    [Setup]     Test Setup Tput
    [1]Bi-Directional_Throughput_20B_noDss_Nsa_TputNsaSplitTCP_AhloaS1_DL4x2CL_UL2x2CL_Bw20MhzAr126900
    [Teardown]    Test Teardown Tput
