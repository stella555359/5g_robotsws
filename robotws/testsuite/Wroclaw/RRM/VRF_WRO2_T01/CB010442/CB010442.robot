*** Settings ***
Documentation
...  Author:        Maciej Cupial, Adam Tokarski
...  Contact:       maciej.cupial@nokia.com, adam.tokarski@nokia.com
...  Feature owner: Karol Malutkiewicz, Witold Galka
...  Description:   Tagging concept:    [CDRT]  [item]  [sa / nsa]  [fdd / tdd]
...                 [item] - a/b/c/d/e/f

Library           taf.sbts.oam.coam.admin  WITH NAME    coam
Resource          testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/Suite_repository.robot
Resource          testsuite/Wroclaw/RRM/VRF_WRO2_T01/CB010442/resources/tests_10442.robot
Resource          testsuite/Wroclaw/RRM/VRF_WRO2_T01/CB010443/resources/tests_10443.robot
Resource          testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/setup_teardown.robot
Resource          testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/common_kw.robot
Resource          testsuite/Wroclaw/RRM/resources/preconditions.robot
Resource          testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/ute_report.robot


Force Tags        CA_5G_RRM  QCD_MN_5G  QCP_5G  RAN_5G   CRT

Suite Setup       Suite Setup power saving


*** Variables ***
@{UE}           UE_1

*** Test Cases ***
[1]CB010442_A#B1_One_X2_link_MeNB_requests_to_switch_on_one_NSA_NR_cell_and_feature_CB010442_is_activated
    [Tags]    10442  10442_ab1
    [Setup]     Test Setup power saving
    CB010442_A#B1_One_X2_link_MeNB_requests_to_switch_on_one_NSA_NR_cell_and_feature_CB010442_is_activated
    [Teardown]  Test Teardown power saving

[1]CB010442_A#EC1_MeNB_requests_to_switch_on_one_NSA_NR_cell_and_feature_CB010442_is_not_activated
    [Tags]    10442    10442_ae1
    [Setup]     Test Setup power saving
    CB010442_A#EC1_MeNB_requests_to_switch_on_one_NSA_NR_cell_and_feature_CB010442_is_not_activated
    [Teardown]  Test Teardown power saving

[1]Activation_and_configuration_of_feature_CB010443-A_Coordinated_4G-5G_power_saving_part2 - 4G
    [Tags]    10443  10443_act
    [Setup]     Test Setup power saving
    Activation_and_configuration_of_feature_CB010443-A_Coordinated_4G-5G_power_saving_part2 - 4G
    [Teardown]  Test Teardown power saving

[1]Deactivation_of_feature_CB010443-A_Coordinated_4G-5G_power_saving_part2 - 4G
    [Tags]    10443  10443_deact
    [Setup]     Test Setup power saving
    Deactivation_of_feature_CB010443-A_Coordinated_4G-5G_power_saving_part2 - 4G
    [Teardown]  Test Teardown power saving

Energy Saving with Deep Sleep pronto handling
    [Tags]    10766
    [Setup]     Test Setup power saving
    Energy Saving with Deep Sleep pronto handling
    [Teardown]  Test Teardown power saving

Energy Saving with SFCCR_1635
    [Tags]    1635
    [Setup]     Test Setup power saving
    Energy Saving with SFCCR_1635
    [Teardown]  Test Teardown power saving

Energy Saving with SFCCR_2438
    [Tags]    2438
    [Setup]     Test Setup power saving
    Energy Saving with SFCCR_2438
    [Teardown]  Test Teardown power saving
