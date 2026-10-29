*** Settings ***
Documentation
...    author: Li Zhiguo
...    contact: zhiguo.li@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup        Common Suite Setup And Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_4T2F
Suite Teardown     Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup         Common Test Setup And Start To Capture Logs
Test Teardown      Common Test Teardown And Stop Capture Logs
Force Tags         release-SBTS24R2    CLOUD_5G_I_BOO_AP_LOO    QCD_MN_RAN    QCP_RAN_VRF
Resource           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG8/resources/DevHZ5_resource_ET.robot

*** Variables ***
${NRARFCN127180}    127210
${ECIDMeasurementInitiationRequest_filter}    nrppa.E_CIDMeasurementInitiationRequest_element
@{ECIDMeasurementInitiationRequest_field}
...    E-CIDMeasurementInitiationRequest/ReportCharacteristics=[RE]onDemand .*
...    MeasurementQuantities/measurementQuantitiesValue=[RE]sS-RSRP .*,[RE]sS-RSRQ .*,[RE]timingAdvanceNR .*
${ECIDMeasurementInitiationResponse_filter}    nrppa.E_CIDMeasurementInitiationResponse_element
@{ECIDMeasurementInitiationResponse_field}
...    MeasuredResultsValue/valueSS-RSRP-Cell=11
...    MeasuredResultsValue/valueSS-RSRQ-Cell=11
...    MeasuredResultsValue/NR-TADV=32

*** Test Cases ***
CB009842-SR-A-B4_ET_21_01_Verify the measurement result when B2 Inter-RAT mobility during E-CID for TADV along with RSRP and RSRQ
    [Documentation]    This case will verify the measurement result when B2 Inter-RAT mobility during E-CID for 
    ...    TADV along with RSRP and RSRQ
    ...    Case steps:
    ...    1.setup SA call for UE1 sucessfully with CA
    ...    2.delay 8s to send MR
    ...    3.egate trigger "E-CID Measurement Initiation request" containing Measurement Quantity requested:SS-RSRP and SS-RSRQ
    ...      and Tadv from LMF to UE1
    ...    4.Send A2 measurement report to configure B2
    ...    5.Trigger B2 measurement report to HO to interRAT LTE
    [Tags]
    start to capture wireshark log    tag=1_UE83_ECID
    Attach UE for waiting L3 call OK
    Delay Measurement Report from UE
    ${a2_mrid}    Get A2 Measurement ID
    trigger E-CID Measurement Initiation request
    Report A2 and configured B2 for UE    meas_id=${a2_mrid}
    Report B2 and Trigger HO from cell12 to lte cell
    ${wireshark_log_path}    stop_wireshark_log_after_filter_found    1_UE83_ECID    ngap.PDUSessionResourceListCxtRelCpl
    check_wireshark_fields    pcap_file=${wireshark_log_path}
    ...                       filter=${ECIDMeasurementInitiationRequest_filter}
    ...                       check_fields=${ECIDMeasurementInitiationRequest_field}
    check_wireshark_fields    pcap_file=${wireshark_log_path}
    ...                       filter=${ECIDMeasurementInitiationResponse_filter}
    ...                       check_fields=${ECIDMeasurementInitiationResponse_field}

*** Keywords ***
Modify Cfg
    Update Cfg    set_lmf id=1 daemon=$SERVER_IP:$EDAEMON_PORT nfId=abcdef01234567gh
    ${ue_83}    catenate
    ...    set_ue simulated id=83 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nea=null+zuc
    ...    nia=null+zuc sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:0000:0:0:021645483 enb=2 cell=12 mode=nr
    Update Cfg    ${ue_83}
    Update Cfg    set_gnb id=5 type=simulated plmn=311:489 ng=10.0.1.14 daemon=$SERVER_IP:$EDAEMON_PORT gnb_id=0x12:28 nssai=0x01:0xD143A5
    ${V1}    catenate
    ...    set_cell id=1 gnb=5 pci=3:2 earfcn=1:18001 tac=0 proxy=$SERVER_IP:12220 nrci=0x1 tdd_cell=on bw=20MHz technology=lte
    ...    mandatory_for_activation=off
    Update Cfg    ${V1}
    Update Cfg    gnb_param id=5 xn_listening_socket=off
    
Attach UE for waiting L3 call OK
    [Arguments]    ${ueid}=83
    Execute Egate Command    ue_location_change id=${ueid} enb=2 cell=12
    Execute Egate Command    qosflow_modify qos_flow=1 default=on
    Execute Egate Command    ue_register id=${ueid}    Received REGISTRATION COMPLETE
    Execute Egate Command    set_pdu_param ue=${ueid} pdu=2 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup pdu=2 ue=${ueid} nwslice=1 gw=1    SCellIndex 1 activated successfully at airphone

Delay Measurement Report from UE
    [Arguments]    ${ue_id}=83
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=0 report_type=periodical action=send_after_rrc_reconf_complete
    ...    delay=8000 srsrp_nr=40 srsrq_nr=50 srs_result=0:40:50:40
    Execute Egate Command    ${cmd}    pass_regexp=send this meas report

trigger E-CID Measurement Initiation request
    [Arguments]    ${ue_id}=83    ${meas_qty}=SS-RSRP,SS-RSRQ    ${tid}=1
    ${cmd}    Catenate    lmf_send_ecid_meas_req id=1 ue=${ue_id} nrppa_transaction_id=${tid} lmf_ue_measurement_id=${tid}
    ...    report_characteristics=OnDemand meas_qty=SS-RSRP,SS-RSRQ,NR_Timing_Advance
    Execute Egate Command    ${cmd}    pass_regexp=saved periodic meas report will be sent after 8000 ms with MeasId

Report A2 and configured B2 for UE
    [Arguments]    ${meas_id}    ${ue_id}=83
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 srsrp_nr=30 srsrq_nr=30
    ...    rrcReconfigurationComplete

Report B2 and Trigger HO from cell12 to lte cell
    [Arguments]    ${ue_id}=83
    ${mea_id}    get nr meas id for specific type and frequency    ${ue_id}    1    B2    EUTRAN
    ${A3_cmd}    catenate    ue_measurement_send_nr id=${ue_id} meas_id=${mea_id} event=B2 srsrp_nr=11 srsrq_nr=11 
    ...    phycell_id=11 nrsrp_nr=30 nrsrq_nr=30
    Execute Egate Command    ${A3_cmd}    Successful handover from EXT_ENB-2.12 to ENB-5.1

Get A2 Measurement ID
    [Arguments]    ${ue_id}=83    ${ssbfreq}=${NRARFCN127180}
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}    ${ssbfreq}    A2
    [Return]    ${meas_id}
