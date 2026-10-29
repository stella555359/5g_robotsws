*** Settings ***
Documentation
...   Test suite for regression testing of feature CNI99270 (Carrier aggregation 2CC) CRT
...   author: Szymon Laba
...   contact: szymon.laba@nokia.com
...   mainteiner: szymon.laba@nokia.com

Resource            ./resources/CNI99270_keywords.robot

Suite Setup      Common Suite Setup With OnAir Test Line Preparation  should_LTE_neighbour_be_changed=${False}
...                                                                   should_5G_neighbour_be_changed=${False}
...                                                                   increase_time_for_checking_bbmod=600
...                                                                   increase_timeout_for_update_sw=1800
...                                                                   increase_time_for_checking_radios=2100
...                                                                   increase_time_for_checking_cells=700
...                                                                   swconfig_from_path=commissionings/Krakow/swconfig/default_swconfig.txt
...                                                                   scfs_path=commissionings/Krakow/7_7_UTE5GCLOUDT4SK079/SBTS00/CNI99270
...                                                                   list_of_additional_allowed_alarms=${list_of_additional_allowed_alarms}

Suite Teardown      Common Suite Teardown

Test Setup          Common Preconditions With Watching Alarms
Test Teardown       Common Postconditions With Watching Alarms


*** Test Cases ***

[1][1.0] CNI-99270-A_2_SA_CA_2x3_ABIO_APHG_Ecpri_CPRI_2T2R_4T4R
    Verify On-Air
    Start DLUL Data Transfer And Verify Throughput
    ...    ue_index=1
    ...    duration=240s
    ...    dl_throughput=1700M
    ...    ul_throughput=120M
    ...    max_deviation=20%



