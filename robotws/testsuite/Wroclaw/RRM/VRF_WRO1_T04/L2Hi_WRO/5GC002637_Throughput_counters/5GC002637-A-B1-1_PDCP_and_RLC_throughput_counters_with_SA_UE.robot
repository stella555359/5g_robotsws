*** Settings ***
Resource    ../resources/common_keywords.robot
Resource    ../resources/common_variables.robot
Library     keywords_5GC002637.py

Documentation
...    author: Mariusz Waczynski
...    maintainer: Marcin Kotula (marcin.kotula@nokia.com)
...    release: 22R3

*** Variables ***
${TRAFFIC_DURATION_SEC}=   60s

*** Keywords ***
5GC002637-A-B1-1_PDCP_and_RLC_throughput_counters_with_SA_UE
    Register Ue With Default Pdu Session
    Start Data Traffic 150Mbps In Dl And 50Mbps In Ul For 120s
    Check Throughput Counters For Sa Ue    dl_tput=150000    ul_tput=50000


Start Data Traffic 150Mbps In Dl And 50Mbps In Ul For 120s
    Execute Egate Command    cmd=sim_debug_log level=6
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=ul kbps=1
    Wait For Next Full Pm Interval
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl kbps=150000 seconds=120s
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=ul kbps=50000 seconds=120s
    BuiltIn.Sleep    10s
    Display Qfi stats    qfi_id=1
    BuiltIn.Sleep    120s    Waiting for traffic stops
    ta5g_ue_mobility.Deregister Ue    ue_id=1
