*** Settings ***
Documentation    Keywords for the 5G000705

Library      ta5g_pm_counters
Library      ta5g_tshark
Variables    ta5g_global_var


*** Variables ***
${NGAP: HANDOVER REQUEST}=         ((ngap.HandoverRequest_element)&&(ngap.HandoverType == intra5gs)&&(ngap.dLForwarding == dl-forwarding-proposed))
${NGAP: HANDOVER FAILURE}=         ngap.HandoverFailure_element
${NGAP: HO_Target_Not_Allowed}=    (ngap.HandoverFailure_element)&&(ngap.radioNetwork == 8)

${NG_HO_RES_ALC_ATT_TRG}=      M55125C07503
${NG_HO_RES_ALC_F_OTH_TRG}=    M55125C07506

@{counters_list_failure_scenario}=    ${NG_HO_RES_ALC_ATT_TRG}    ${NG_HO_RES_ALC_F_OTH_TRG}


*** Keywords ***
TC__5GC000705-NGAP_HANDOVER_FAILURE_target_cell_barred
    Get Next Unpacked Full Pm Counters File
    Set Internal Traffic Type To UE With Sib Period Configuration
    Change Simulation UE Location
    Register UE To Simulation gNB
    Start Data Traffic
    Perform NGAP Handover
    Verify NGAP: HANDOVER REQUEST Message Includes Handover Type Set To Intra5GS And dl-fwd-proposed IE Present
    Verify Ngap Messages    packet_filter=${NGAP: HANDOVER REQUEST}    timeout=120
    Verify Ngap Messages    packet_filter=${NGAP: HANDOVER FAILURE}    timeout=120
    Verify Ngap Messages    packet_filter=${NGAP: HO_Target_Not_Allowed}    timeout=120
    ${pm_counter_file}=    Get Next Unpacked Full Pm Counters File
    Verify That Appropriate Counters Incremented Correctly
    ...    counters_list=@{counters_list_failure_scenario}    pm_counter_path=${pm_counter_file}

Start Vm Ethernet Interfaces
    Start Vm Ethernet Interface    if_name=eth3:GNB3_NG_ADDR    ip_with_mask=10.0.1.3/24
    Start Vm Ethernet Interface    if_name=eth3:GNB3_XN_ADDR    ip_with_mask=10.0.1.4/24
    Start Vm Ethernet Interface    if_name=eth3:AMF_NG    ip_with_mask=10.0.1.1/24

Set Internal Traffic Type To UE With Sib Period Configuration
    Execute Egate Command    cmd=gnb_param id=3 sib1_period=40
    Execute Egate Command    cmd=gnb_param id=3 sib2_period=40
    Execute Egate Command    cmd=gnb_param id=3 sib5_period=40
    Execute Egate Command    cmd=set_pdu_param ue=1 pdu=1 trf_type=internal

Change Simulation UE Location
    Execute Egate Command    cmd=ue_change_location id=1 enb=3 cell=1
    Sleep    2s

Register UE To Simulation gNB
    Attach Ue    ue_id=1
    Execute Egate Command    cmd=ue_pdu_session_setup ue=1 pdu=1 nwslice=1 gw=1
    Sleep    2s

Start Data Traffic
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=10
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=ul mbps=5

Perform NGAP Handover
    Execute Egate Command    cmd=ue_measurement_send_nr id=1 meas_id=1 event=A3 srsrp_nr=19 phycell_id=50 nrsrp_nr=100
    Sleep    5s

Verify NGAP: HANDOVER REQUEST Message Includes Handover Type Set To Intra5GS And dl-fwd-proposed IE Present
    Verify Ngap Messages    ${NGAP: HANDOVER REQUEST}

Verify That Appropriate Counters Incremented Correctly
    [Arguments]    ${counters_list}    ${pm_counter_path}
    Verify If Latest Pm Counters From The List Are Bigger Than The Given Value
    ...    counter_list=${counters_list}
    ...    value=0
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    filepath=${pm_counter_path}
