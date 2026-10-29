*** Settings ***
Documentation
...    Author: Grzegorz Kaczor, grzegorz.kaczor@nokia.com
...    Maintainer: Slawomir Szopinski, slawomir.szopinski@nokia.com

Resource     ./resources/keywords.robot
Resource     ./resources/UE_keywords.robot

Suite Setup    Common Suite Setup With OnAir Test Line Preparation
...            swconfig_from_path=commissionings/Krakow/swconfig/default_swconfig.txt
...            increase_timeout_for_update_sw=1800
...            prefix_tag=TL153
...            list_of_additional_allowed_alarms=Failure detected on assigned antennas

Test Setup       Run Keywords
...              Set Allowed Alarms For ASiR    AND
...              Common Preconditions    AND
...              Verify ASiR Alarms

Test Teardown    Run Keywords
...              Verify ASiR Alarms    AND
...              Common Postconditions

*** Test Cases ***
# testsuite/Nanjing/OAM/CB009487/CB009487.robot
[1][1.0] CB009487-SR-G_TC68_ABIP_ABIO_6_NR_TDD_4T4R_6_LTE_FDD_2T2R_6_LTE_TDD_2T2R_gNB_reset
    Log Current Time
    Reset BTS And Wait For All Online Statuses
    Verify Active Alarms And Historic Alarms On BTS And ASiR After BTS Reset

[1][1.0] CB009487-SR-A_TC19_9487_3_3RU_12_100M_4T4R_Gen4_pRRH_prrh_reset
    Reset All BTS ASIRMODs
    Wait For All BTS ASIRMOD Modules To Be Operational
    Wait For All Online Statuses On BTS And ASiR

[1][1.0] CB009487-SR-G_TC72_ABIP_ABIO_6_NR_TDD_4T4R_6_LTE_FDD_2T2R_6_LTE_TDD_2T2R_ABIP_lock_unlock_reset
    Get All BTS BBMOD IDs
    Get ASiR BBMOD Cell Relation Mapping
    Lock All BBMOD Units One By One And Verify Cell Status
    Verify Active BTS And ASiR Alarms
    Unlock All BBMOD Units One By One And Verify Cell Status
    Verify Active BTS And ASiR Alarms
    Reset BBMODs And Wait For All Cells To Be OnAir
    Verify Active BTS And ASiR Alarms

[1][1.0] CB009487-SR-D_TC48_3_ASiR-sHUB_NR_FDD_TDD_concurrent_ASiR-sHUB_Gen4_pRRH_mrrh_mixture_bandwidth_4T4R_2T2R_data_traffic
    Block Selected Cells For TC48
    Prepare Ue
    Run One Way UDP UL TC48 Data Transfer
    Run One Way UDP DL TC48 Data Transfer
    [Teardown]    Test Teardown For TC48

[1][1.0] CB009487-SR-G_TC83_2_ABIP_6_NR_TDD_4T4R_6_LTE_FDD_2T2R_6_NR_FDD_2T2R_2_subracks_data_traffic
    Block Selected Cells For TC83
    Prepare Ue
    Run One Way UDP UL TC83 Data Transfer
    Run One Way UDP DL TC83 Data Transfer
    [Teardown]    Test Teardown For TC83
