*** Settings ***
Documentation    Suite description
...    Author:        len.lin@nokia-sbell.com
...    Maintainer:    lin len

Suite Setup    Suite Precondition
Suite Teardown    Suite Postcondition

Variables    ./env.py
Resource    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/common_setup.robot
Resource    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/test_fv.robot


Force Tags    CLOUD_RF_AIR_B4_AEQM    CA_RAN_PZ_HAZ_1  SBTS24R3  RAN_5G  RAN_5G_TDD  CRT


*** Variables ***

&{CLOUD_RF_AIR_B4_AZHL_SBTS24R3_T2}=    HW_ID=T2    ONAIR_TIME=20 min    site_mode=5G


*** Test Cases ***
[1][1.0] CB010655_I_1_enhancement_of_reset_counter
    [Tags]    QC_861988    QCD_MN_RAN    QCP_RAN_ST
    [Setup]    Testcase Basic Precondition    case_name=Reset_Counter
    ...    config_id=CLOUD_RF_AIR_B4_AZHL_SBTS24R3_T2
    [Timeout]    2h
    BBOX5 File Reset Counter    AH222602994
    [Teardown]    Testcase Basic Postcondition

[1][1.0] CB010655_H_1_support_BTS_ID_and_BTS_SW_version
    [Tags]    QC_861989    QCD_MN_RAN    QCP_RAN_ST
    [Setup]    Testcase Basic Precondition    case_name=BTS_SW_version
    ...    config_id=CLOUD_RF_AIR_B4_AZHL_SBTS24R3_T2
    [Timeout]    2h
    Support BTSID And BTSSW    AH222602994
    [Teardown]    Testcase Basic Postcondition
