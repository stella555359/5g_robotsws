*** Settings ***
Resource    CB001354_keywords.robot

Documentation
...    author: Pawel Konieczny
...    maintainer: Marcin Kotuła (marcin.kotula@nokia.com)
...    release: 23R1

*** Variables ***
${TRAFFIC_DURATION}=   30s

*** Keywords ***
5GC001354-D-5GC001354-A_With_5GC001248-J
    Attach Ue With Sgnb
    Start High Dl Data Traffic With Tcp
    Sleep    ${TRAFFIC_DURATION}
    Verify If Dl Tput Has Proper Value
    Force Packet Losts On X2-U
    Sleep    ${TRAFFIC_DURATION}
    Check For Ddds Messages Existence Due To Periodic Duplicate Transmission
    Display Bearer Stats
    Wait For Next Full Pm Interval
    Verify If Dl Pdcp Sdus Were Transmitted For Nsa Bearer
    Verify If DL Pdcp Pdu Were Sent Over Nr X2-u Dl Gtp-u Tunnel
    Verify If 1354-A X2 Retx Grp6 Counters Were Incremented
    Verify If There Was No Sgnb Release With Cause Equal To Radio Connection With UE Lost
    Verify If Pm Counters Related To 1248-J Were Incremented
    Detach Ue    ue_id=11

Start High Dl Data Traffic With Tcp
    Start Data Traffic  ues=11    bearer_id=2    direction=dl    throughput=120mbps    optional_parameters=protocol=tcp

Verify If Dl Tput Has Proper Value
    Display Bearer Stats
    Check Bearer Throughput For Multiple Ues        throughput=80    number_of_ues=1

Verify If There Was No Sgnb Release With Cause Equal To Radio Connection With UE Lost
    ${PM_COUNTERS}=    Get Latest Unpacked Full Pm Counters File
    Verify If Latest Pm Counter Has Exact Value    counter_id=${COUNTER_ID_SGNB_REL_SN_REQ_UE_LOST}
    ...    value=0    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1   filepath=${PM_COUNTERS}

Verify If Pm Counters Related To 1248-J Were Incremented
    ${PM_COUNTERS}=    Get Latest Unpacked Full Pm Counters File
    Verify If Latest Pm Counter Is Bigger Than The Given Value    counter_id=${COUNTER_ID_NUM_DL_PDU_LOST_X2_QOS_GRP_06}
    ...    value=0    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1    filepath=${PM_COUNTERS}
    Verify If Latest Pm Counter Is Bigger Than The Given Value    counter_id=${COUNTER_ID_DL_PDCP_VOL_SNT_X2_QOS_GRP_06}
    ...    value=0    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1    filepath=${PM_COUNTERS}
    Verify If Latest Pm Counter Is Bigger Than The Given Value    counter_id=${COUNTER_ID_DL_PDCP_VOL_RCV_F1_QoS_GRP_06}
    ...    value=0    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRDU-1    filepath=${PM_COUNTERS}
    Verify If Latest Pm Counter Is Bigger Than The Given Value    counter_id=${COUNTER_ID_DL_VOL_TX_NSA_QOS_GRP_06}
    ...    value=0    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1    filepath=${PM_COUNTERS}
    Verify If Latest Pm Counter Is Bigger Than The Given Value    counter_id=${COUNTER_ID_DL_VOL_SNT_F1_QoS_GRP_06}
    ...    value=0    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1    filepath=${PM_COUNTERS}
