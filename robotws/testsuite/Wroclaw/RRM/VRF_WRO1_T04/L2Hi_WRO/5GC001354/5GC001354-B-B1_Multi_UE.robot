*** Settings ***
Resource    CB001354_keywords.robot
Library     ta5g_bearers

Documentation
...    author: Marek Niescioruk
...    maintainer: Marcin Kotuła (marcin.kotula@nokia.com)
...    release: 22R2

*** Variables ***
${TRAFFIC_DURATION_SEC}=    20s
${ADDITIONAL_TIME_TO_COMPLETE_THE_PROCEDURE}=    2s
${EXPECTED_THROUGHPUT_DL_Mbps}=    5

*** Keywords ***
5GC001354-B-B1_Nsa_Non_Gbr_Drb_Periodic_Duplicate_Transmission_Of_Pdcp_Pdu_Over_X2_U_Interface_Multi_UE_Udp_Tcp
    Attach 3 Nsa Ues And Check If Sgnb Reconfig Succeed
    Start 5mbps Dl Data Traffic
    Verify If 1354-B Counters For Qos Groups 06-08 Were Incremented
    Verify If 1354-B Counters For Qos Group 09 Were Not Incremented
    Check Bearer Throughput For Multiple Ues    throughput=${EXPECTED_THROUGHPUT_DL_Mbps}
    Add Second Bearer for UE    ue_id_added=13    bearer_id_added=3
    Start Gnb Addition Procedure    ue=13    bearer=2,3    target_cells=1    dc_type=split_scg
    Start 5mbps Dl Data Traffic With Udp/tcp    ues_id=13    user_bearer_id=3    Type_of_traffic=tcp
    Verify If 1354-B Counters For Qos Groups 06-09 Were Incremented
    Check Bearer Throughput For Single Ue     ue_id=13    bearer_id=3    throughput=${EXPECTED_THROUGHPUT_DL_Mbps}
    Detach Multiple Ues Without Confirmation    first_ue_id=11    last_ue_id=13

Attach 3 Nsa Ues And Check If Sgnb Reconfig Succeed
    Attach Multiple Nsa Ues With Sgnb Addition
    Verify Tshark For Given Number Of Messages
    ...    alias=${DEFAULT_S1_MME_ALIAS}
    ...    packet_filter=${SGNB_RECONFIG_COMPLETE}
    ...    number_of_messages=3

Start 5mbps Dl Data Traffic
    Start 5mbps Dl Data Traffic With Udp/tcp    ues_id=11    user_bearer_id=2    Type_of_traffic=udp
    Start 5mbps Dl Data Traffic With Udp/tcp    ues_id=12    user_bearer_id=2    Type_of_traffic=udp
    Start 5mbps Dl Data Traffic With Udp/tcp    ues_id=13    user_bearer_id=2    Type_of_traffic=udp
    Sleep    ${TRAFFIC_DURATION_SEC}

Verify If 1354-B Counters For Qos Groups 06-08 Were Incremented
    Wait For Next Full Pm Interval
    Verify If 1354-B Counters For Qos Group Were Incremented    counter_id_num=${COUNTER_ID_DL_NUM_DUP_X2_QOS_GRP_06}
    ...                                                         counter_id_vol=${COUNTER_ID_DL_VOL_DUP_X2_QOS_GRP_06}
    Verify If 1354-B Counters For Qos Group Were Incremented    counter_id_num=${COUNTER_ID_DL_NUM_DUP_X2_QOS_GRP_07}
    ...                                                         counter_id_vol=${COUNTER_ID_DL_VOL_DUP_X2_QOS_GRP_07}
    Verify If 1354-B Counters For Qos Group Were Incremented    counter_id_num=${COUNTER_ID_DL_NUM_DUP_X2_QOS_GRP_08}
    ...                                                         counter_id_vol=${COUNTER_ID_DL_VOL_DUP_X2_QOS_GRP_08}

Verify If 1354-B Counters For Qos Groups 06-09 Were Incremented
    Wait For Next Full Pm Interval
    Verify If 1354-B Counters For Qos Group Were Incremented    counter_id_num=${COUNTER_ID_DL_NUM_DUP_X2_QOS_GRP_06}
    ...                                                         counter_id_vol=${COUNTER_ID_DL_VOL_DUP_X2_QOS_GRP_06}
    Verify If 1354-B Counters For Qos Group Were Incremented    counter_id_num=${COUNTER_ID_DL_NUM_DUP_X2_QOS_GRP_07}
    ...                                                         counter_id_vol=${COUNTER_ID_DL_VOL_DUP_X2_QOS_GRP_07}
    Verify If 1354-B Counters For Qos Group Were Incremented    counter_id_num=${COUNTER_ID_DL_NUM_DUP_X2_QOS_GRP_08}
    ...                                                         counter_id_vol=${COUNTER_ID_DL_VOL_DUP_X2_QOS_GRP_08}
    Verify If 1354-B Counters For Qos Group Were Incremented    counter_id_num=${COUNTER_ID_DL_NUM_DUP_X2_QOS_GRP_09}
    ...                                                         counter_id_vol=${COUNTER_ID_DL_VOL_DUP_X2_QOS_GRP_09}

Enable MultiDrbNSA
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/5GC001354/delta_enable_actMultiDrbNSA.json

Add Second Bearer for UE
    [Arguments]    ${ue_id_added}    ${bearer_id_added}
    Execute Egate Command    cmd=ue_dc_enb_release ue=${ue_id_added} by=enb cause=off
    Sleep    ${ADDITIONAL_TIME_TO_COMPLETE_THE_PROCEDURE}
    Add Bearer    ue_id=${ue_id_added}     bearer_id=${bearer_id_added}    filter=3    precedence=3
    ...    pass_regexp=Bearer-${bearer_id_added} .* created

Start 5mbps Dl Data Traffic With Udp/tcp
    [Arguments]    ${ues_id}    ${Type_of_traffic}    ${user_bearer_id}
    Start Data Traffic  ues=${ues_id}     bearer_id=${user_bearer_id}    direction=dl
    ...    throughput=5mbps    optional_parameters=protocol=${Type_of_traffic}

Verify If 1354-B Counters For Qos Group Were Incremented
    [Arguments]    ${counter_id_num}    ${counter_id_vol}
    ${PM_COUNTERS}=    Get Latest Unpacked Full Pm Counters File
    Verify If Latest Pm Counter Is Bigger Than The Given Value    counter_id=${counter_id_num}
    ...    value=0    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1    filepath=${PM_COUNTERS}
    Verify If Latest Pm Counter Is Bigger Than The Given Value    counter_id=${counter_id_vol}
    ...    value=0    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1    filepath=${PM_COUNTERS}

Verify If 1354-B Counters For Qos Group 09 Were not Incremented
    ${PM_COUNTERS}=    Get Latest Unpacked Full Pm Counters File
    Verify If Latest Pm Counter Has Exact Value    counter_id=${COUNTER_ID_DL_NUM_DUP_X2_QOS_GRP_09}
    ...    value=0    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1    filepath=${PM_COUNTERS}
