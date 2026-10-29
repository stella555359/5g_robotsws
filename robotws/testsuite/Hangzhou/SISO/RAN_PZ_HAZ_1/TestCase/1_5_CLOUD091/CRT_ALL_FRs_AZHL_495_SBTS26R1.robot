*** Settings ***
Documentation    Suite description
...    Author:        len.lin@nokia-sbell.com
...    Maintainer:    lin len

Suite Setup    Suite Precondition
Suite Teardown    Suite Postcondition

Variables    ./env.py
Resource    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/common_setup.robot
Resource    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/test_fv.robot


Force Tags    CLOUD_RF_AIR_B4_AEQM    CA_RAN_PZ_HAZ_1  SBTS26R1  RAN_5G  RAN_5G_TDD  CRT


*** Variables ***

&{CLOUD_RF_AIR_B4_AZHL_SBTS26R1_T2_495}=    HW_ID=T2    ONAIR_TIME=20 min    site_mode=5G




*** Test Cases ***
[1][3.0] Operational_BTS SiteReset
    [Tags]    QC_252152    QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=siteReset
    ...    config_id=CLOUD_RF_AIR_B4_AZHL_SBTS26R1_T2_495
    [Timeout]      2h
    Site Reset
    [Teardown]    Testcase Basic Postcondition
