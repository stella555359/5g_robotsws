*** Settings ***
Documentation
...  author: Mikolaj Guszpit
...  contact:       mikolaj.guszpit@nokia.com
...  maintainer:    mikolaj.guszpit@nokia.com
...  Description:   Test Cases for CB009324 feature: This sector will be filled in the future.

Library   taf.ue
Resource  testsuite/Wroclaw/RRM/VRF_WRO2_T01/CB009324/resources/keywords.resource
Resource  testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/multi_ue.robot

*** Keywords ***
[1]CB009324#A-US1_03_CAonLTE-ON,OFF_Traffic_shaping_FT_ON_OFF_FDD_full_buffer_dlDataSplit_0_FSTSCH_ETHIF.sir_2000000
    detach ues from cell  ${ues}
    attach ues to cell  ${ues}
    detach ues from cell  ${ues}
    sleep  15s
    attach ues to cell  ${ues}
    Start DL for UEs  ${ues}  protocol=tcp  duration=600s
    Wait for counters interval

    ${f1_qos_counter_ca}  Get M55323C01009 counter
    ${x2_qos_counter_ca}  Get M55313C08009 counter
    ${drop_counter_ca}    Get M55313C04009 counter
    check_counters_are_greater_than_zero  ${f1_qos_counter_ca}
    check_counters_are_greater_than_zero  ${x2_qos_counter_ca}
    check_counters_are_less_than_number   ${drop_counter_ca}  10

    run keyword and ignore error  Stop all datatransfers
    detach ues from cell  ${ues}
    Deactivate LTE CA
    attach ues to cell  ${ues}
    Wait for counters interval

    ${drop_counter_no_ca}    Get M55313C04009 counter
    ${drop_prev_value}  extract_value_from_counter  ${drop_counter_ca}
    ${drop_counter_no_ca_value}  extract_value_from_counter  ${drop_counter_no_ca}
    should be true  ${drop_prev_value} <= ${drop_counter_no_ca_value}


[1]CB009324#A-US3_09_CAonLTE_Traffic_shaping_at_gNB_DL_data_over_X2-U_FDD_PDCP_Fast.Retransmissions_small_DL_data_packet_size
    Activate LTE CA
    Activate retransimission

    detach ues from cell  ${ues}
    attach ues to cell  ${ues}
    Start DL for UEs  ${ues}  protocol=tcp  duration=600s
    Wait for counters interval

    ${f1_qos_counter_ca}  Get M55323C01009 counter
    ${x2_qos_counter_ca}  Get M55313C08009 counter
    ${drop_counter_ca}    Get M55313C04009 counter
    check_counters_are_greater_than_zero  ${f1_qos_counter_ca}
    check_counters_are_greater_than_zero  ${x2_qos_counter_ca}
    check_counters_are_less_than_number   ${drop_counter_ca}  10

    run keyword and ignore error  Stop all datatransfers
    detach ues from cell  ${ues}
    Deactivate LTE CA
    attach ues to cell  ${ues}
    Wait for counters interval

    ${drop_counter_no_ca}    Get M55313C04009 counter
    ${drop_prev_value}  extract_value_from_counter  ${drop_counter_ca}
    ${drop_counter_no_ca_value}  extract_value_from_counter  ${drop_counter_no_ca}
    should be true  ${drop_prev_value} <= ${drop_counter_no_ca_value}


[1]CB009324#A_05_CAonLTE_Traffic_shaping_at_gNB_DL_data_over_X2-U_TDD_small_DL_data_packet_size
    Activate LTE CA
    Lock FDD cells
    detach ues from cell  ${ues}
    attach ues to cell  ${ues}
    Start DL for UEs  ${ues}  protocol=tcp  duration=600s
    Wait for counters interval

    ${f1_qos_counter_ca}  Get M55323C01009 counter
    ${x2_qos_counter_ca}  Get M55313C08009 counter
    ${drop_counter_ca}    Get M55313C04009 counter
    check_counters_are_greater_than_zero  ${f1_qos_counter_ca}
    check_counters_are_greater_than_zero  ${x2_qos_counter_ca}
    check_counters_are_less_than_number   ${drop_counter_ca}  30

    run keyword and ignore error  Stop all datatransfers
    detach ues from cell  ${ues}
    Deactivate LTE CA
    attach ues to cell  ${ues}
    Wait for counters interval

    ${drop_counter_no_ca}    Get M55313C04009 counter
    Unlock FDD cells
    ${drop_prev_value}  extract_value_from_counter  ${drop_counter_ca}
    ${drop_counter_no_ca_value}  extract_value_from_counter  ${drop_counter_no_ca}
    should be true  ${drop_prev_value} <= 30

[1]CB009324#A_05_avg_tput_comparation
    detach ues from cell  ${ues}
    Deactivate feature
    attach ues to cell  ${ues}
    Start DL for UEs  ${ues}  protocol=tcp  duration=120s
    Start UL for UEs  ${ues}  protocol=tcp  duration=120s
    ${res1}    Await datatransfers finish
    log to console    ${res1}
    stop all datatransfers

    detach ues from cell  ${ues}
    Activate feature
    attach ues to cell  ${ues}
    Start DL for UEs  ${ues}  protocol=tcp  duration=120s
    Start UL for UEs  ${ues}  protocol=tcp  duration=120s
    ${res2}    Await datatransfers finish
    log to console    ${res2}
    stop all datatransfers

    # downlink
    Compare Tput Values    ${res2[0]}  ${res1[0]}
    #uplink
    Compare Tput Values    ${res2[1]}  ${res1[1]}