*** Settings ***
Documentation
...   Test suite for regression testing of feature CB008278 (10MHz TDD attach and tput) CRT
...   author: Szymon Laba
...   contact: szymon.laba@nokia.com
...   mainteiner: szymon.laba@nokia.com

Resource            ./resources/CB008278_keywords.robot

Suite Setup      Common Suite Setup With OnAir Test Line Preparation  should_LTE_neighbour_be_changed=${False}
...                                                                   should_5G_neighbour_be_changed=${False}
...                                                                   increase_time_for_checking_bbmod=600
...                                                                   increase_timeout_for_update_sw=1800
...                                                                   increase_time_for_checking_radios=2100
...                                                                   increase_time_for_checking_cells=700
...                                                                   swconfig_from_path=commissionings/Krakow/swconfig/default_swconfig.txt
...                                                                   scfs_path=commissionings/Krakow/7_7_UTE5GCLOUDT4SK079/SBTS00/CB008278
...                                                                   list_of_additional_allowed_alarms=${list_of_additional_allowed_alarms}

Suite Teardown      Common Suite Teardown

Test Setup          Common Preconditions With Watching Alarms
Test Teardown       Common Postconditions With Watching Alarms


*** Test Cases ***

[1][1.0] CB008278-SR-B_6_UE_Attach_Traffic_Longpucch_256QAM_semistatic1028_RBG4_PDSCHSchedInSS_CPRI_without_IQC_ABIO_SA
    Verify On-Air
    Start DLUL Data Transfer And Verify Throughput
    ...    ue_index=1
    ...    duration=240s
    ...    dl_throughput=117M
    ...    ul_throughput=15M
    ...    max_deviation=30%

[1][1.0] CB008278-SR-B_5_UE_Attach_Traffic_Longpucch_256QAM_1116_3ms_CPRI_with_IQC_ABIO_SA
    Prepare environment configuration
    Verify On-Air
    Start DLUL Data Transfer And Verify Throughput
    ...    ue_index=1
    ...    duration=240s
    ...    dl_throughput=117M
    ...    ul_throughput=15M
    ...    max_deviation=30%
