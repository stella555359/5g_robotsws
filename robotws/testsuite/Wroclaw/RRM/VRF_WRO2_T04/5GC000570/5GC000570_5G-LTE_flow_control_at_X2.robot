*** Settings ***
Documentation
...  author: Pawel Zabawczuk
...  contact: pawel.k.zabawczuk@nokia.com

Library         ute_ue
Resource        ./resources/keywords.robot


*** Keywords ***
5GC000570_A_Max_expected_TCP_Downlink_and_Uplink_data_throughput_splitted_over_F1UX2U_interfaces_for_given_qci
    [Documentation]   Purpose of this test is check successful TCP Downlink and Uplink data throughput
    ...               splitted over F1U and/or X2U interfaces for given QCI, check and report NR_59b and NR_973a KPIs.
    set_data_split_mode_parameters
    Update Parameter   param=pdcpAndRlcCountersUpdateConf   value=QoS Level
    Attach UEs To NR Cell n71
    Start Data Transfer In Given Direction   @{ues}   direction=DLUL   duration=1800s

    Show Text on Console   [Synchronize to next PM interval to start traffic analysis]
    wro4_pm.sync_to_next_reporting_interval   offset=0
    Show Text on Console   [Wait for full PM interval passed to analyse traffic in this period]
    BuiltIn.sleep   ${reportingIntervalPm}s    run tput in whole pm interval
    Verify Average Tput in Whole Time Period

    Show Text on Console   [Calculate latency KPIs: NR_59b, NR_973a, validate them and send report to REP]
    wro4_pm.sync_to_next_reporting_interval
    Calculate KPIs and send report to REP

    [Teardown]  Run Keywords
    ...        Stop data transfers for all ues
    ...   AND  Detach UEs
    ...   AND  Update Parameter   param=pdcpAndRlcCountersUpdateConf   value=NRPMQAP Level
    ...   AND  set_data_split_mode_parameters   default=${True}
