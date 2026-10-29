*** Settings ***
Documentation
...    Author: karthik.j@nokia.com
...    Test Description: Test cases to configure multiple bands and carriers with O-RAN compliant LTE Radio
...    References:
...    QualityCenter:
...    Sample execution:
...    AC/REQ:

Test Setup        Run Keywords    Admin Setup

Test Teardown     Run Keywords    Admin Teardown

Force Tags    QCD_MN_RAN    QCP_RAN_VRF
Resource    ./resources/CB009130_A_resource_ST.robot

*** Test Cases ***
[1][1.0]TC01_CB009130_A_To_configure_multiple_Band_with_one_Sectors_per_Band_for_ORAN_4G_radio
    [Tags]    TRUNK_SG04    9130A   	9130A_1
    CB009130_A_To_configure_multiple_Band_with_one_Sectors_per_Band_for_ORAN_4G_radio

[1][1.0]TC05_CB009130_A_To_configure_multiple_Band_and_multi_Sectors_for_ORAN_4G_radio
    [Tags]    9130A
    CB009130_A_To_configure_multiple_Band_and_multi_Sectors_for_ORAN_4G_radio

[1][1.0]TC08_CB009130_A_To_configure_multiple_Band_with_one_Sectors_2T2R_for_ORAN_4G_radio
    [Tags]    9130A
    CB009130_A_To_configure_multiple_Band_with_one_Sectors_2T2R_for_ORAN_4G_radio

[1][1.0]TC09_CB009130_A_To_configure_multiple_Band_with_one_Sectors_2T4R_for_ORAN_4G_radio
    [Tags]    9130A
    CB009130_A_To_configure_multiple_Band_with_one_Sectors_2T4R_for_ORAN_4G_radio
