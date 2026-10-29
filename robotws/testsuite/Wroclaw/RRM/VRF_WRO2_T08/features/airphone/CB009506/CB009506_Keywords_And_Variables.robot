*** Settings ***

Documentation    :copyright: Nokia

Resource     ../../../../resources/airphone/5G_SW_WRO_Keywords.robot
Library      ta5g_testline_management
Library      ta5g_iphy
Library      ta5g_enb
Library      ta5g_delta
Library      ta5g_throughput
Library      ta5g_iperf_traffic
Library      taf.sbts.oam.coam.admin
Library      ta5g_cell_operations

*** Variables ***
${THROUGHPUT_DURATION}       30s
${DURATION}                  20
${THROUGHPUT_DL}             2m
${THROUGHPUT_UL}             1m
${CELL_MOC}                  MRBTS-1/NRBTS-1/NRCELL-1
${UE_STAT_CMD}               ue_stats_nr id=1
${UE_DEACTIVATED}            UE1: NR UEStats are supported only for Active UE

*** Keywords ***
Init UEs List
    ${UEs_list}=    Create List
    FOR    ${ueid}    IN RANGE    1    21
        Append To List    ${UEs_list}    ${ueid}
    END
    RETURN    ${UEs_list}

Attach UE And Establish PDU Session For Multiple UEs With Traffic
    [Arguments]    ${sa_ue_list}
    FOR    ${ue_id}    IN    @{sa_ue_list}
        Attach Ue    ue_id=${ue_id}
        Establish Pdu Session With Traffic    ue_id=${ue_id}    pdu_id=1    nwslice=1    gw_id=1    direction=both    throughput=1mbps
    END

Wait For Throughput
    sleep    ${THROUGHPUT_DURATION}

Release PDU Session For Multiple UEs
    [Arguments]    ${sa_ue_list}
    FOR    ${ue_id}    IN    @{sa_ue_list}
        Release PDU Session    ue_id=${ue_id}    pdu_id=1
    END

Deregister Multiple UEs
    [Arguments]    ${sa_ue_list}
    FOR    ${ue_id}    IN    @{sa_ue_list}
        Deregister UE    ue_id=${ue_id}
    END

Block First Cell
    [Arguments]    ${dist_name}    ${connection}
    Block Cell    dist_name=${dist_name}    connection=${connection}

Unblock First Cell
    [Arguments]    ${dist_name}    ${connection}
    Unblock Cell    dist_name=${dist_name}    connection=${connection}
    Wait For All Cells To Be Enabled

Attach Ue And Set Throuput
    [Arguments]    ${ue_id}    ${number_of_messages}
    Attach Ue    ue_id=${ue_id}
    Set Internal Traffic Type For Ue    ue=${ue_id}    pdu=1
    Establish Pdu Session    ue_id=${ue_id}    pdu_id=1   gw_id=1
    Verify Ngap Messages    packet_filter=${NGAP_INITIAL_CONTEXT_SETUP_RESPONSE}    number_of_messages=${number_of_messages}

Start UL And DL Traffic
        [Arguments]    ${ue_id}    ${pdu_id}
        Start Data Traffic    ues=${ue_id}    direction=dl    pdu=${pdu_id}    throughput=2mbps
        Start Data Traffic    ues=${ue_id}    direction=ul    pdu=${pdu_id}    throughput=1mbps
        Sleep    5s    reason=Wait for data traffic transfer to start

Verify Both Traffic For UE
    [Arguments]    ${ue_id}
    Wait For Throughput
    Expected Throughput For Ue Should Be Reached    ue_id=${ue_id}    throughput=1
    ...    direction=ul    selection_type=average    retry=10    layer=physical    margin=0.15
    Expected Throughput For Ue Should Be Reached    ue_id=${ue_id}    throughput=2
    ...    direction=dl    selection_type=average    retry=10    layer=physical    margin=0.15


Check If Ue Is Deregistered
    [Arguments]    ${cmd}    ${pass_regexp}
    Execute Egate Command    cmd=${cmd}    pass_regexp=${pass_regexp}

Wait For Sib Transmission
    Sleep    5s    reason=Waiting For Sib Transmission
