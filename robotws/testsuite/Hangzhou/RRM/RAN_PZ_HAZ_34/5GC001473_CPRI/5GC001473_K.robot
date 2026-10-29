*** Settings ***
Documentation
...    Author: Lu Ming
...    Contact: ming.lun@nokia-sbell.com
...    squad SG_01
...    Feature 5GC001473-K in 5G20B program

Force Tags        RAN_5G  RAN_5G_TDD   STATE_SW_UPLOADED  SBTS00  SBTS22R2
...    CLOUD_5G_CLASSICAL_FULLRACK_QC_SA_ASIKL_ABILB1_AHPE-ASIKR_ABILB4_AEHC    PY36
Suite Setup         Run Keywords    robot_common_operations.Common Suite Setup    AND   Setup suite
Suite Teardown       Run Keywords    robot_common_operations.Common Suite Teardown    AND   Teardown Suite
Resource          Resource/5GC001473_Resources.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot

*** Variables ***


*** Test Cases ***
#[1]5GC001473_K_Cell_Setup_With_Configed_BandWidth
#    [Documentation]  5GC001473-K The purpose of this case is to test SA L3CALL to bandwidth 90M SA cell with eCPRI AEHC RU
#    [Tags]     CRT_22R1    CRT_21B
#    [Setup]    Setup case
#    [Teardown]  Teardown case
#    TC.Cell_Setup_With_Configed_BandWidth

#[1]5GC001473_K_Cell_Setup_With_Configed_BandWidth_SA
#    [Documentation]  5GC001473-K The purpose of this case is to test NSA cell on air with bandwidth 90M with eCPRI AEHC RU
#    [Tags]    TA
#    [Setup]    Setup case
#    [Teardown]  Teardown case
#    TC.Cell_Setup_With_Configed_BandWidth_SA

[1]5GC001473_K_L3_Call_Setup_With_Configed_BandWidth
    [Documentation]  5GC001473-K The purpose of this case is to test SA L3CALL to bandwidth 90M SA cell with eCPRI AEHC RU
    [Tags]    CRT_TRUNK   CRT_22R1    CRT_21A    CRT_21B    CRT_22R3    CRT_UTE
    [Setup]     Run Keywords    robot_common_operations.Common Case Setup    AND   Setup case
    [Teardown]  Run Keywords    robot_common_operations.Common Case Teardown   AND   Teardown case
    TC.L3_Call_Setup_With_Configed_BandWidth

#[1]UL_and_DL_LA_data_traffic_QAM64_2x2MIMO_SA
#    [Tags]    TA
#    [Setup]    Setup case
#    [Teardown]  Teardown case
#    TC.UL_and_DL_LA_data_traffic_QAM64_2x2MIMO_SA
#
#[1]UL_and_DL_LA_Peak_QAM256_2x2MIMO_SA
#    [Tags]    TA
#    [Setup]    Setup case
#    [Teardown]  Teardown case
#    TC.UL_and_DL_LA_Peak_QAM256_2x2MIMO_SA
#
#
#[1]UL_and_DL_LA_data_traffic_QAM256_4x4MIMO_SA
#    [Tags]    TA
#    [Setup]    Setup case
#    [Teardown]  Teardown case
#    TC.UL_and_DL_LA_data_traffic_QAM256_4x4MIMO_SA
