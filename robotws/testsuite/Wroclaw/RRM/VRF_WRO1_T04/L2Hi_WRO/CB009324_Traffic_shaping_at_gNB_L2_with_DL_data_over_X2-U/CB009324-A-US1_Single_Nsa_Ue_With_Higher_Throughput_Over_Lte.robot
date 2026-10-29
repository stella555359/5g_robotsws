*** Settings ***
Resource    keywords_CB009324.robot

Documentation
...    author: Marcin Kotuła
...    maintainer: Marcin Kotuła (marcin.kotula@nokia.com)
...    release: 24R2

*** Variables ***
${TRAFFIC_DURATION_SEC}=   60s
${NSA_UE_ID_TDD}=    11
${NSA_UE_ID_FDD}=    15

*** Keywords ***
CB009324-A-US1_Single_Nsa_Ue_With_Higher_Throughput_Over_Lte_TDD
    Attach Ue To Enb    ue_id=${NSA_UE_ID_TDD}
    Start Gnb Addition Procedure    ue=${NSA_UE_ID_TDD}    bearer=2    target_cells=1    dc_type=split_scg
    Start High Dl Data Traffic
    BuiltIn.Sleep    ${TRAFFIC_DURATION_SEC}
    Display Bearer Stats
    Verify If Downlink PDCP Pdu QoS Grp 6 Pm Counters Were Incremented
    Verify Pdcp Pdu Packet Lost On X2-U
    Verify Packet Drops At Transport First Level Scheduler
    ta5g_ue_mobility.Detach Ue    ue_id=${NSA_UE_ID_TDD}

CB009324-A-US1_Single_Nsa_Ue_With_Higher_Throughput_Over_Lte_FDD
    Enable Traffic Shaping FDD
    Attach Ue To Enb    ue_id=${NSA_UE_ID_FDD}
    Start Gnb Addition Procedure    ue=${NSA_UE_ID_FDD}    bearer=2    target_cells=3    dc_type=split_scg
    Start High Dl Data Traffic    ${NSA_UE_ID_FDD}
    BuiltIn.Sleep    ${TRAFFIC_DURATION_SEC}
    Display Bearer Stats    ${NSA_UE_ID_FDD}
    Verify If Downlink PDCP Pdu QoS Grp 6 Pm Counters Were Incremented
    Verify Pdcp Pdu Packet Lost On X2-U
    Verify Packet Drops At Transport First Level Scheduler

Start High Dl Data Traffic
    [Arguments]    ${UE_ID}=${11}
    Execute Egate Command    cmd=debug_log level=6
    Execute Egate Command    cmd=trf_data_start ue=${UE_ID} id=2 dir=dl mbps=65 trf_id=1

Display Bearer Stats
    [Arguments]    ${UE_ID}=${11}
    Execute Egate Command And Wait For Data    cmd=bearer_stats ue=${UE_ID} id=2 dc_cell_group=mcg
    Execute Egate Command And Wait For Data    cmd=bearer_stats ue=${UE_ID} id=2 dc_cell_group=scg
