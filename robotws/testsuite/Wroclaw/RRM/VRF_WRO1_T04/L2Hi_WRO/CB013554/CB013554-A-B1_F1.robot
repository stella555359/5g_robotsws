*** Settings ***
Resource    CB013554_keywords.robot

Documentation
...    author: Paweł Konieczny
...    maintainer: Marcin Kotuła (marcin.kotula@nokia.com)
...    release: 25R1

*** Variables ***
${TRAFFIC_DURATION_SEC}=   20s
@{COUNTERS_ID_GRP_06}=
...    ${COUNTER_ID_DL_VOL_SNT_F1_QoS_GRP_06}
...    ${COUNTER_ID_DL_NUM_SNT_F1_QOS_GRP_06}
...    ${COUNTER_ID_UL_VOL_RCV_F1_QOS_GRP_06}
...    ${COUNTER_ID_UL_NUM_RCV_F1_QOS_GRP_06}
...    ${COUNTER_ID_MAX_DL_SNT_F1_QOS_GRP_06}
...    ${COUNTER_ID_MAX_UL_RCV_F1_QOS_GRP_06}

@{NRDU_COUNTERS_ID}=
...    ${COUNTER_ID_DL_PDCP_VOL_RCV_F1_QOS_GRP_06}
...    ${COUNTER_ID_DL_PDCP_NUM_RCV_F1_QOS_GRP_06}
...    ${COUNTER_ID_UL_PDCP_NUM_SNT_F1_QOS_GRP_06}
...    ${COUNTER_ID_UL_PDCP_VOL_SNT_F1_QOS_GRP_06}

@{PMQAP_PDCP_COUNTERS_ID}=
...    ${COUNTER_ID_DL_VOL_SNT_F1_PMQAP}
...    ${COUNTER_ID_DL_NUM_SNT_F1_PMQAP}
...    ${COUNTER_ID_UL_VOL_RCV_F1_PMQAP}
...    ${COUNTER_ID_UL_NUM_RCV_F1_PMQAP}
...    ${COUNTER_ID_UL_PDCP_VOL_SNT_F1_PMQAP}
...    ${COUNTER_ID_UL_PDCP_NUM_SNT_F1_PMQAP}
...    ${COUNTER_ID_DL_PDCP_VOL_RCV_F1_PMQAP}
...    ${COUNTER_ID_DL_PDCP_NUM_RCV_F1_PMQAP}


*** Keywords ***
CB013554-A-B1_1_F1-U_Pdu_And_Volume_Counters
    Register Ue With Default Pdu Session
    Start Data Traffic 110Mbps In Dl And 50 Mbps In Ul
    BuiltIn.Sleep    ${TRAFFIC_DURATION_SEC}
    Display Ue Statistics
    Check If Expected Throughout Is Reached
    Verify That Legacy F1 Pm Counters Were Incremented
    Verify That Profile F1 Pm Counters Were Not Incremented
    Enable Pdcp And Rlc Counters Update At NRPMQAP Level
    Wait For Next Full Pm Interval
    Verify That Profile F1 Pm Counters Were Incremented
    Verify That Legacy F1 Pm Counters Were Not Incremented

Start Data Traffic 110Mbps In Dl And 50 Mbps In Ul
    Execute Egate Command    cmd=sim_debug_log level=6
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=110
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=ul mbps=50

Display Ue Statistics
    Display Qfi stats    qfi_id=1
    Execute Egate Command And Wait For Data    cmd=uec_stats display type=cell_data_pdcp enb=2 cell=1 format=long

Check If Expected Throughout Is Reached
    Expected Throughput For Qfi Should Be Reached    ue_id=1    pdu_id=1    qfi_id=1
    ...    expected_throughput=110    unit=mbps    margin=0.2    direction=dl
    Expected Throughput For Qfi Should Be Reached    ue_id=1    pdu_id=1    qfi_id=1
    ...    expected_throughput=50    unit=mbps    margin=0.2    direction=ul

Verify That Legacy F1 Pm Counters Were Incremented
    Wait For Next Full Pm Interval
    ${PM_COUNTERS}=    Get Latest Unpacked Full Pm Counters File
    Verify If Latest Pm Counters From The List Are Bigger Than The Given Value    counter_list=${COUNTERS_ID_GRP_06}
    ...    value=0    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1    filepath=${PM_COUNTERS}
    Verify If Latest Pm Counters From The List Are Bigger Than The Given Value    counter_list=${NRDU_COUNTERS_ID}
    ...    value=0    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRDU-1    filepath=${PM_COUNTERS}

Verify That Profile F1 Pm Counters Were Not Incremented
    ${PM_COUNTERS}=    Get Latest Unpacked Full Pm Counters File
    Verify If Latest Pm Counters In Counter Id List Have Exact Value    counter_id_list=${PMQAP_PDCP_COUNTERS_ID}
    ...    value=0    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1   filepath=${PM_COUNTERS}

Verify That Profile F1 Pm Counters Were Incremented
    Wait For Next Full Pm Interval
    ${PM_COUNTERS}=    Get Latest Unpacked Full Pm Counters File
    Verify If Latest Pm Counters From The List Are Bigger Than The Given Value    counter_list=${PMQAP_PDCP_COUNTERS_ID}
    ...    value=0    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1    filepath=${PM_COUNTERS}

Verify That Legacy F1 Pm Counters Were Not Incremented
    ${PM_COUNTERS}=    Get Latest Unpacked Full Pm Counters File
    Verify If Latest Pm Counters In Counter Id List Have Exact Value    counter_id_list=${COUNTERS_ID_GRP_06}
    ...    value=0    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1    filepath=${PM_COUNTERS}
    Verify If Latest Pm Counters In Counter Id List Have Exact Value    counter_id_list=${NRDU_COUNTERS_ID}
    ...    value=0    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRDU-1    filepath=${PM_COUNTERS}
