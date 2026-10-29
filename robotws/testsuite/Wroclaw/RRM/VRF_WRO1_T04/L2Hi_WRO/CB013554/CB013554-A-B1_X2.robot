*** Settings ***
Resource    CB013554_keywords.robot

Documentation
...    author: Paweł Konieczny
...    maintainer: Marcin Kotuła (marcin.kotula@nokia.com)
...    release: 25R1

*** Variables ***
${TRAFFIC_DURATION_SEC}=   20s
${UE_ID_TDD}=    14
@{COUNTERS_ID_GRP_09}=
...    ${COUNTER_ID_DL_PDCP_VOL_SNT_X2_QOS_GRP_09}
...    ${COUNTER_ID_DL_PDCP_NUM_SNT_X2_QOS_GRP_09}
...    ${COUNTER_ID_UL_PDCP_VOL_RCV_X2_QOS_GRP_09}
...    ${COUNTER_ID_UL_PDCP_NUM_RCV_X2_QOS_GRP_09}
...    ${COUNTER_ID_MAX_DL_PDCP_SNT_X2_QOS_GRP_09}
...    ${COUNTER_ID_MAX_UL_PDCP_RCV_X2_QOS_GRP_09}

@{PMQAP_COUNTERS_ID}=
...    ${COUNTER_ID_DL_PDCP_VOL_SNT_X2_PMQAP}
...    ${COUNTER_ID_DL_PDCP_NUM_SNT_X2_PMQAP}
...    ${COUNTER_ID_UL_PDCP_VOL_RCV_X2_PMQAP}
...    ${COUNTER_ID_UL_PDCP_NUM_RCV_X2_PMQAP}

*** Keywords ***
CB013554-A-B1_2_X2-U_Pdu_And_Volume_Counters
    Attach Ue To Enb    ue_id=${UE_ID_TDD}
    Start Gnb Addition Procedure    ue=${UE_ID_TDD}    bearer=2    target_cells=1    dc_type=split_scg
    Start Data Traffic 80Mbps In Dl And 30 Mbps In Ul    ue_id=${UE_ID_TDD}
    BuiltIn.Sleep    ${TRAFFIC_DURATION_SEC}
    Display Bearer Stats On Scell 8 And 9
    Verify That Legacy X2 Pm Counters Were Incremented
    Enable Pdcp And Rlc Counters Update At NRPMQAP Level
    Wait For Next Full Pm Interval
    Verify That Profile X2 Pm Counters Were Incremented
    Verify That Legacy X2 Pm Counters Were Not Incremented

Set Cfgqcirange To 9
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/Pm_counters/delta_set_cfgQciRange_to_9.json

Enable Split F1UX2U And Set Paths Over X2
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/Split_Mode/delta_enable_F1UX2U_paths_over_X2.json

Start Data Traffic 80Mbps In Dl And 30 Mbps In Ul
    [Arguments]    ${ue_id}=14
    Start Data Traffic  ues=${ue_id}    bearer_id=2    direction=dl    throughput=80mbps    optional_parameters=protocol=udp
    Start Data Traffic  ues=${ue_id}    bearer_id=2    direction=ul    throughput=30mbps    optional_parameters=protocol=udp

Display Bearer Stats On Scell 8 And 9
    Execute Egate Command And Wait For Data   cmd=ue_stats_nr id=${UE_ID_TDD} type=pdsch scell=8,9
    Execute Egate Command And Wait For Data   cmd=bearer_stats ue=${UE_ID_TDD} id=2 dir=dl

Verify That Legacy X2 Pm Counters Were Incremented
    Wait For Next Full Pm Interval
    ${PM_COUNTERS}=    Get Latest Unpacked Full Pm Counters File
    Verify If Latest Pm Counters From The List Are Bigger Than The Given Value    counter_list=${COUNTERS_ID_GRP_09}
    ...    value=0    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1    filepath=${PM_COUNTERS}

Verify That Profile X2 Pm Counters Were Incremented
    Wait For Next Full Pm Interval
    ${PM_COUNTERS}=    Get Latest Unpacked Full Pm Counters File
    Verify If Latest Pm Counters From The List Are Bigger Than The Given Value    counter_list=${PMQAP_COUNTERS_ID}
    ...    value=0    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1    filepath=${PM_COUNTERS}

Verify That Legacy X2 Pm Counters Were Not Incremented
    ${PM_COUNTERS}=    Get Latest Unpacked Full Pm Counters File
    Verify If Latest Pm Counters In Counter Id List Have Exact Value    counter_id_list=${COUNTERS_ID_GRP_09}
    ...    value=0    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1    filepath=${PM_COUNTERS}
