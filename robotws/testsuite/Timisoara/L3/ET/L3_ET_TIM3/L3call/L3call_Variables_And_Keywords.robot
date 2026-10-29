*** Variables ***
${TRF_DURATION}=        600

*** Keywords ***
Perform SA call
    [Arguments]     ${ue_id}    ${target_cell}   ${target_gnb}
    Execute Egate Command   cmd=set_pdu_param ue=${ue_id} pdu=${ue_id} trf_type=internal
    Attach Ue    ue_id=${ue_id}
    Establish Pdu Session    ue_id=${ue_id}    pdu_id=${ue_id}    gw_id=${ue_id}
    Start Data Traffic
    ...     ues=${ue_id}
    ...     pdu=${ue_id}
    ...     direction=both
    ...     throughput=10mbps
    ...     traffic_period=${TRF_DURATION}
    Get Throughput For Ue
    ...     ue_id=${ue_id}
    ...     layer=physical
    ...     selection_type=average
    ...     direction=dl
    ...     scells=0
    Get Throughput For Ue
    ...     ue_id=${ue_id}
    ...     layer=physical
    ...     selection_type=average
    ...     direction=ul
    ...     scells=0
    Expected Throughput For Ue Should Be Reached
    ...     ue_id=${ue_id}
    ...     throughput=10
    ...     margin=1.0
    ...     layer=physical
    ...     selection_type=average
    ...     direction=dl
    ...     scells=0
    Expected Throughput For Ue Should Be Reached
    ...     ue_id=${ue_id}
    ...     throughput=10
    ...     margin=1.0
    ...     layer=physical
    ...     selection_type=average
    ...     direction=ul
    ...     scells=0
#    ${PM_COUNTERS}=    Get Latest Unpacked Full Pm Counters File
#    Verify Any Counters In File
#    ...    M55310C01006     >350000000    DL_RLC_VOL_TX_L_QOS_GRP_06
#    ...    M55310C03006     >350000000    UL_RLC_VOL_RX_L_QOS_GRP_06
#    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${target_cell}
#    ...    file_path=${PM_COUNTERS}
    Deregister Ue Without Confirmation    ue_id=${ue_id}

Perform NSA call
    [Arguments]    ${ue_id}  ${target_cell}  ${target_gnb}
    Attach Ue To Enb    ue_id=${ue_id}  optional_parameters=profile=1
    Start Gnb Addition Procedure
    ...    ue=${ue_id}
    ...    target_cells=${target_cell}
    ...    target_gnb=${target_gnb}
    ...    bearer=2
    ...    dc_type=split_scg
    Start Data Traffic
    ...     ues=${ue_id}
    ...     bearer_id=2
    ...     direction=both
    ...     throughput=10mbps
    ...     traffic_period=${TRF_DURATION}
    Get Throughput For Ue
    ...     ue_id=${ue_id}
    ...     layer=physical
    ...     selection_type=average
    ...     direction=dl
    ...     scells=8
    Get Throughput For Ue
    ...     ue_id=${ue_id}
    ...     layer=physical
    ...     selection_type=average
    ...     direction=ul
    ...     scells=8
    Expected Throughput For Ue Should Be Reached
    ...     ue_id=${ue_id}
    ...     throughput=10
    ...     margin=1.0
    ...     layer=physical
    ...     selection_type=average
    ...     direction=dl
    ...     scells=8
    Expected Throughput For Ue Should Be Reached
    ...     ue_id=${ue_id}
    ...     throughput=10
    ...     margin=1.0
    ...     layer=physical
    ...     selection_type=average
    ...     direction=ul
    ...     scells=8
#    ${PM_COUNTERS}=    Get Latest Unpacked Full Pm Counters File
#    Verify Any Counters In File
#    ...    M55310C01009     >350000000    DL_RLC_VOL_TX_L_QOS_GRP_09
#    ...    M55310C03009     >350000000    UL_RLC_VOL_RX_L_QOS_GRP_09
#    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${target_cell}
#    ...    file_path=${PM_COUNTERS}
    Detach Ue    ue_id=${ue_id}

Perform SANSA call
    [Arguments]     ${sa_ue}    ${nsa_ue}   ${target_cell}   ${target_gnb}
    Execute Egate Command   cmd=set_pdu_param ue=${sa_ue} pdu=${sa_ue} trf_type=internal
    Attach Ue    ue_id=${sa_ue}
    Establish Pdu Session    ue_id=${sa_ue}    pdu_id=${sa_ue}   gw_id=${sa_ue}
    Attach Ue To Enb    ue_id=${nsa_ue}  optional_parameters=profile=1
    Start Gnb Addition Procedure
    ...    ue=${nsa_ue}
    ...    target_cells=${target_cell}
    ...    target_gnb=${target_gnb}
    ...    bearer=2
    ...    dc_type=split_scg
#   --------------- START SA call ------------------
    Start Data Traffic
    ...     ues=${sa_ue}
    ...     pdu=${sa_ue}
    ...     direction=both
    ...     throughput=10mbps
#    ...     traffic_period=${TRF_DURATION}
#   --------------- START NSA call ------------------
    Start Data Traffic
    ...     ues=${nsa_ue}
    ...     bearer_id=2
    ...     direction=both
    ...     throughput=10mbps
#    ...     traffic_period=${TRF_DURATION}
    Sleep   ${TRF_DURATION}
#   --------------- Verify SA traffic ------------------
    Get Throughput For Ue
    ...     ue_id=${sa_ue}
    ...     layer=physical
    ...     selection_type=average
    ...     direction=dl
    ...     scells=0
    ...     retry=2
    Get Throughput For Ue
    ...     ue_id=${sa_ue}
    ...     layer=physical
    ...     selection_type=average
    ...     direction=ul
    ...     scells=0
    ...     retry=2
    Expected Throughput For Ue Should Be Reached
    ...     ue_id=${sa_ue}
    ...     throughput=10
    ...     margin=1.0
    ...     layer=physical
    ...     selection_type=average
    ...     direction=dl
    ...     scells=0
    Expected Throughput For Ue Should Be Reached
    ...     ue_id=${sa_ue}
    ...     throughput=10
    ...     margin=1.0
    ...     layer=physical
    ...     selection_type=average
    ...     direction=ul
    ...     scells=0
#    Sleep   ${TRF_DURATION}
#   --------------- Verify NSA traffic ------------------
    Get Throughput For Ue
    ...     ue_id=${nsa_ue}
    ...     layer=physical
    ...     selection_type=average
    ...     direction=dl
    ...     scells=8
    ...     retry=2
    Get Throughput For Ue
    ...     ue_id=${nsa_ue}
    ...     layer=physical
    ...     selection_type=average
    ...     direction=ul
    ...     scells=8
    ...     retry=2
    Expected Throughput For Ue Should Be Reached
    ...     ue_id=${nsa_ue}
    ...     throughput=10
    ...     margin=1.0
    ...     layer=physical
    ...     selection_type=average
    ...     direction=dl
    ...     scells=8
    Expected Throughput For Ue Should Be Reached
    ...     ue_id=${nsa_ue}
    ...     throughput=10
    ...     margin=1.0
    ...     layer=physical
    ...     selection_type=average
    ...     direction=ul
    ...     scells=8
#    Sleep   ${TRF_DURATION}
#    ${PM_COUNTERS}=    Get Latest Unpacked Full Pm Counters File
#    Verify Any Counters In File
#    ...    M55310C01006     >350000000    DL_RLC_VOL_TX_L_QOS_GRP_06
#    ...    M55310C03006     >350000000    UL_RLC_VOL_RX_L_QOS_GRP_06
#    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${target_cell}
#    ...    file_path=${PM_COUNTERS}
    Deregister Ue Without Confirmation    ue_id=${sa_ue}
    Detach Ue    ue_id=${nsa_ue}
