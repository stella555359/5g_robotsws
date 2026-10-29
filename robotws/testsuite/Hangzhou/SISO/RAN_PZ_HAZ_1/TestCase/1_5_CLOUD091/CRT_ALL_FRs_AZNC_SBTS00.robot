*** Settings ***
Documentation    Suite description
...    Author:        len.lin@nokia-sbell.com
...    Maintainer:    lin len

Suite Setup    Suite Precondition
Suite Teardown    Suite Postcondition

Variables    ./env.py
Resource    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/common_setup.robot
Resource    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/test_fv.robot


Force Tags    CLOUD_RF_AIR_B4_AEQM    CA_RAN_PZ_HAZ_1  SBTS00  RAN_5G  RAN_5G_TDD  CRT


*** Variables ***

${GGMAP}     {'6Q180811674': {'1' : '1.2.1:1.2.3','2': '1.3.1:1.3.3'}}


&{CLOUD_RF_AIR_B4_AZNC_SBTS00_T8}=    HW_ID=T8    ONAIR_TIME=20 min    site_mode=5G
${INIT_CONFIG_ID}     CLOUD_RF_AIR_B4_AZNC_SBTS00_T8


*** Test Cases ***
[1]CB007447_Short_PL_break_with_recovery
    [Tags]    QC_33280    QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=Short_PL
    ...    config_id=CLOUD_RF_AIR_B4_AZNC_SBTS00_T8
    [Timeout]    2h
    Short_Break_PrimaryLink    rf_sn=6Q180811674    break_time=80ms
    [Teardown]    Testcase Basic Postcondition

[1]CB007447_Long_SL_break_with_recovery
    [Tags]    QC_33279    QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=Long_SL
    ...    config_id=CLOUD_RF_AIR_B4_AZNC_SBTS00_T8
    [Timeout]    2h
    Long_Break_SecondaryLink    rf_sn=6Q180811674    break_time=2000ms
    [Teardown]    Testcase Basic Postcondition
