*** Settings ***
Library     keywords_5GC002637.py
Library     ../5GC000774_ROHC/keywords_ROHC.py

Documentation
...    author: Mariusz Waczynski
...    maintainer: Marcin Kotuła (marcin.kotula@nokia.com)
...    release: 22R3

*** Keywords ***
5GC002637-A-B1-3_PDCP_and_RLC_throughput_counters_with_NSA_UE
    Set Flow Control to F1U
    Attach Ue To Enb    ue_id=11
    Start Gnb Addition Procedure    ue=11    bearer=2    target_cells=1    dc_type=split_scg
    Verify Tshark For Single Message    alias=${DEFAULT_S1_MME_ALIAS}    packet_filter=${SGNB_RECONFIG_COMPLETE}
    Start Data Traffic 150Mbps In Dl And 50Mbps In Ul
    Check Throughput Counters For Nsa Ue F1u    dl_tput=150000    ul_tput=50000
    Set Flow Control to X2
    Attach Ue To Enb    ue_id=11
    Start Gnb Addition Procedure    ue=11    bearer=2    target_cells=1    dc_type=split_scg
    Start Data Traffic 150Mbps In Dl And 50Mbps In Ul
    Check Throughput Counters For Nsa Ue X2   dl_tput=150000    ul_tput=50000

Set Flow Control to F1U
    Send Delta Commissioning     input_filepath=${DELTA_FILES_PATH}/Split_Mode/delta_dlDataSplitMode_set_to_dlOverF1U.json

Set Flow Control to X2
    Send Delta Commissioning     input_filepath=${DELTA_FILES_PATH}/Split_Mode/delta_dlDataSplitMode_set_to_dlOverX2U_ulDataPath_ulOverNR.json

Start Data Traffic 150Mbps In Dl And 50Mbps In Ul
    Execute Egate Command    cmd=sim_debug_log level=6
    Execute Egate Command    cmd=trf_data_start ue=11 id=2 dir=ul kbps=1
    Wait For Next Full Pm Interval
    Execute Egate Command    cmd=trf_data_start ue=11 id=2 dir=dl mbps=150 seconds=120s
    Execute Egate Command    cmd=trf_data_start ue=11 id=2 dir=ul mbps=50 seconds=120s
    Sleep    10s
    Execute Egate Command And Wait For Data    cmd=bearer_stats ue=11 id=2 dir=dl dc_cell_group=mcg
    Execute Egate Command And Wait For Data    cmd=bearer_stats ue=11 id=2 dir=dl dc_cell_group=scg
    Sleep    120s    Waiting for traffic stops
    Detach Ue    ue_id=11
