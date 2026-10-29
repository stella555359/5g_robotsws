*** Settings ***
Resource    CB001354_keywords.robot

Documentation
...    author: Pawel Konieczny
...    maintainer: Bartlomiej Urbanowicz (bartlomiej.urbanowicz@nokia.com)
...    release: 23R1

*** Variables ***
${TRAFFIC_DURATION_SEC}=   20s
${UE_DC_ID}=    14
${SCG_BEARER_ID}=    2
${srsrp_part}=    srsrp_nr=11 srsrq_nr=11 ssinr_nr=11
${nrsrp_part}=    nrsrp_nr=30 nrsrq_nr=30 nsinr_nr=30
${UE_NR_CAPA}=    21000000010800000004DE4D0780720800000520800001520800002524A000034C00454000000000000054
${UE_EUTRA_NR_CAPA}=    A10180902C100389A0000008800B0400F89A000008000800080402004008

*** Keywords ***
5GC001354-A-B5_Nsa_Non_Gbr_Drb_Duplicate_Transmission_Of_Pdcp_Pdu_For_Ddds_Handling_During_Pdcp_Sn_Rollover_Classical
    Attach NSA Ue ID14 And Start Gnb Addition
    Start Dl Data Traffic    ue_id=${UE_DC_ID}    mbps=120mbps    protocol=tcp
    Sleep    ${TRAFFIC_DURATION_SEC}
    Trigger Handover To Second Cell With Event A3
    Sleep    ${TRAFFIC_DURATION_SEC}
    Display Bearer Stats  ue_id=${UE_DC_ID}  bearer_id=${SCG_BEARER_ID}
    Wait For Next Full Pm Interval
    Verify If 1354-B Counters For Qos Group 09 Were Incremented
    Detach Ue    ue_id=${UE_DC_ID}

Enable HO
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/Mobility/delta_enable_intra_gnb_ho_and_a3_meas.json
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/Mobility/delta_enable_NSA_mobility.json

Attach NSA Ue ID14 And Start Gnb Addition
    Execute Egate Command    cmd=ue_param id=${UE_DC_ID} ue_nr_capabilities=${UE_NR_CAPA}
    Execute Egate Command    cmd=ue_param id=${UE_DC_ID} ue_eutra_nr_capabilities=${UE_EUTRA_NR_CAPA}
    Attach Ue To Enb    ue_id=${UE_DC_ID}
    Start Gnb Addition Procedure    ue=${UE_DC_ID}    bearer=${SCG_BEARER_ID}    target_cells=1    dc_type=split_scg
    Verify Tshark For Single Message    alias=${DEFAULT_S1_MME_ALIAS}    packet_filter=${SGNB_RECONFIG_COMPLETE}

Trigger Handover To Second Cell With Event A3
    Execute Egate Command   cmd=ue_measurement_send_nr id=${UE_DC_ID} meas_id=1 event=A3 ${srsrp_part} phycell_id=51 ${nrsrp_part}
