*** Settings ***
Documentation
...    author: Geng lishuo
...    contact: lishuo.geng@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_08
Suite Setup       Common Suite Setup And Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/10cells_ecpri_100M/2_AEQE_4_AWHQN
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        release-SBTS25R1    tl-CLOUD_5G_I_MP_AP_LOOO
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG8/resources/DevHZ5_resource_ET.robot

*** Variables ***
@{FAULTS_EXCLUDED_CHECKING}    8000
${SYSCOM_FLAG}    True
${PositioningInformationResponse}    nrppa.id == 54
${NRPPA_UPDATE_INFO_RESPONSE_FILTER}    nrppa.procedureCode == 10
${F1AP_DEACTIVE_RESPONSE_FILTER}    f1ap.procedureCode == 51

@{PARAMS_IN_SWCONFIG}
...    ${set_ultdoa_enable_param1}
...    ${set_ultdoa_enable_param2}
...    ${set_positioning_information_update}
...    ${rdPreventOverloadActivationBeforeUeTresholdIsReached}

${set_ultdoa_enable_param1}    0x59029B = 1
${set_ultdoa_enable_param2}    0x890092 = 1
${set_positioning_information_update}    0x59025d=1
${rdPreventOverloadActivationBeforeUeTresholdIsReached}    0x89008e=0

@{PDU_setup_and_IN_INACTIVE_state}
...    QoS Routing Table
...    Moving UE to NR_RRC_INACTIVE state
...    Is INACTIVE

${mba_positioningInformationExchange}    (tcp.port == 49150) && (nrppa.procedureCode == 9) && (nsetapx.traceActivationType == 0)
${sba_positioningInformationExchange}    (tcp.port == 49150) && (nrppa.procedureCode == 9) && (nsetapx.traceActivationType == 1)
${mba_PositioningInformationUpdate}    (tcp.port == 49150) && (nrppa.procedureCode == 10) && (nsetapx.traceActivationType == 0)
${sba_PositioningInformationUpdate}    (tcp.port == 49150) && (nrppa.procedureCode == 10) && (nsetapx.traceActivationType == 1)
${mba_PositioningDeactivation}    (tcp.port == 49150) && (nrppa.procedureCode == 18) && (nsetapx.traceActivationType == 0)
${sba_PositioningDeactivation}    (tcp.port == 49150) && (nrppa.procedureCode == 18) && (nsetapx.traceActivationType == 1)
${mba_PositioningDeactivation_f1ap}    (tcp.port == 49150) && (f1ap.procedureCode == 51) && (nsetapx.traceActivationType == 0)
${mba_PositioningInformationFailure}    (tcp.port == 49150) && (nrppa.NRPPA_PDU == 2) && (nsetapx.traceActivationType == 0)
${sba_PositioningInformationFailure}    (tcp.port == 49150) && (nrppa.NRPPA_PDU == 2) && (nsetapx.traceActivationType == 1)
${deactivate_trace}    (tcp.port == 49150) && (ngap.procedureCode == 3) && (nsetapx.traceActivationType == 0)
${deact_pos_srs}    PositioningDeactivation/AbortTransmission=[RE]releaseALL .*
${pos_srs_fail}    PositioningInformationFailure/Cause/radioNetwork=[RE]requested-item-temporarily-not-available .*

*** Test Cases ***
CB010356-B-B5_ET_01_01_Successful SRS Configuration to LMF for inactive UE with RAN Paging Successful
    [Documentation]    cover CB010356-A-B5_ET_01_01 and CB010356-A-B5_ET_01_02

    [Tags]    TC01    owner-lishuo.geng

    log to console    step: Attach UE-1 to cell-3,UE change to inactive state after drbRrcInactInactivityTimerSA timeout
    SA UE attach with single PDU In Inactive State    ue_id=1
    log to console    step:set SRS configuration with infinite periodicity
    Set SRS Configuration    id=1    num_periodic=0    type=periodic
    log to console    step:trigger positioning request for UE1, and UE paging successfully
    start to capture wireshark log    tag=1_for_pagging_UE_with_positioning
    trigger Positioning Request For UE    ue_id=1
    log to console    step: check SRS info in position response
    ${srs_info}    create list    RelativeTime1900=[RE]967fbbffffff258c .*
    ...                           pCI-NR=52
    ...                           SRSResource/sRSResourceID=0
    ...                           SRSResource/nrofSRS-Ports=[RE]port1 .*
    ...                           SRSResource/combOffset-n2=1
    ...                           SRSResource/cyclicShift-n2=1
    ...                           SRSResource/startPosition=1
    ...                           SRSResource/nrofSymbols=[RE]n1 .*
    ...                           SRSResource/resourceType=[RE]periodic .*
    ...                           SRSResource/periodic/periodicity=[RE]slot5 .*
    ...                           SRSResource/periodic/offset=1
    ...                           SRSResourceSet/sRSResourceSetID=0
    ...                           SRSResourceSet/sRSResourceID-List/SRSResourceID=0
    ...                           SRSResourceSet/resourceSetType=[RE]periodic .*
    ...                           SRSResourceSet/periodic/periodicSet=[RE]true .*
    download and check wireshark fields    tag=1_for_pagging_UE_with_positioning
    ...                                    filter=${PositioningInformationResponse}
    ...                                    check_fields=${srs_info}
    log to console    step: Attach UE-2 to cell-3,UE change to inactive state after drbRrcInactInactivityTimerSA timeout
    SA UE attach with single PDU In Inactive State    ue_id=2
    log to console    step: set paging message is dropped at UE2
    Execute Egate Command    ue_param id=2 ignore_paging=on
    log to console    step: trigger positon request for UE-2, and position response failure since paging fail
    trigger Positioning Request For UE    ue_id=2    pass_regexp=LMF Received Positioning Information Failure

CB010356-B-B4_ET_01_01_Successful release of SRS Configuration initiated by LMF and gnb when positioning is enabled
    [Documentation]
    ...    The purpose of this test case is to verify:
    ...    1. Successful release of SRS Configuration initiated by LMF when positioning is to be ended
    ...    2. Successful release of SRS configuration initiated from gNB when finite number of periodic SRS transmissions is reached

    [Tags]    B401
    OnlineParamChange    ${srbInactivityTimerSA_30}
    SA UE attach with single PDU    target_cells=2
    log to console    step: LMF trigger "NRPPA: POSITIONING INFORMATION REQUEST" with Number Of Periodic Transmissions is 0
    start to capture wireshark log    tag=1_periodic_0
    Set SRS Configuration    id=1    num_periodic=0    type=periodic
    trigger Positioning Request For UE
    trigger Positioning Deactivation Without Mandatory IE For UE should fail
    ${update_info}    create list    pCI-NR=51
    ...                           SRSResourceSet/periodic/periodicSet=[RE]true .*
    ...                           SRSResourceSet/sRSResourceSetID=0
    download and check wireshark fields    tag=1_periodic_0
    ...                                    filter=${NRPPA_UPDATE_INFO_RESPONSE_FILTER}
    ...                                    check_fields=${update_info}
    start to capture wireshark log    tag=2_deactivation
    log to console    step:LMF trigger "NRPPA: POSITIONING INFORMATION DEACTIVATION"
    trigger Positioning Deactivation For UE
    ${release_info}    create list    AbortTransmission=[RE]releaseALL .*
    download and check wireshark fields    tag=2_deactivation
    ...                                    filter=${F1AP_DEACTIVE_RESPONSE_FILTER}
    ...                                    check_fields=${release_info}
    log to console    step:LMF trigger "NRPPA: POSITIONING INFORMATION REQUEST" with Number Of Periodic Transmissions is not 0
    start to capture wireshark log    tag=3_periodic_500
    Set SRS Configuration    id=1    num_periodic=500    type=periodic
    trigger Positioning Request For UE
    sleep    1s    #wait gnb send deactive
    ${wireshark_log_path}    stop_wireshark_log_after_filter_found    tag=3_periodic_500    filter=${F1AP_DEACTIVE_RESPONSE_FILTER}
    ${update_info2}    create list    pCI-NR=51
    ...                           SRSResourceSet/periodic/periodicSet=[RE]true .*
    ...                           SRSResourceSet/sRSResourceSetID=0
    check_wireshark_fields    pcap_file=${wireshark_log_path}
    ...                         filter=${NRPPA_UPDATE_INFO_RESPONSE_FILTER}
    ...                    check_fields=${update_info2}
    ${release_info2}    create list    AbortTransmission=[RE]releaseALL .*
    check_wireshark_fields    pcap_file=${wireshark_log_path}
    ...                         filter=${F1AP_DEACTIVE_RESPONSE_FILTER}
    ...                   check_fields=${release_info2}

CB010356-B-B2_ET_01_03_Unsuccessful SRS Configuration to LMF for UE with normal call caused by overload
    [Tags]    BB2_03    CRT
    [Documentation]    5G-CP-UE shall send NRPPa: PositioningInformationFailure with cause "RNL:Requested Item Temporarily
    ...    Not Available" to AMF as per [5G_CP_ARC_ALG_13980].
    ...    the position for one UE is exclusive, that means: One UE can only handle one position request at one time;
    ...    when cprt notify that du overload after cu send postionrquest to du, should cprt refuse it
    ...    when cpue notify cu that cu overload after postion request received at du side, should cprt refuse it
    OnlineParamChange    ${enable_gnbOvlProtMode}
    Execute Egate Command    sim_trace lmf=1 protocol=nrppa on
    Set SRS Configuration    id=1    num_periodic=1    type=periodic
    log to console    position should be failure when CU Overload

    Register For Number Of Normal Calls with Default PDU    cell_id=4    ue_id_start=5    ue_id_end_before=7    nwslice=1
    Enter CU Overload
    sleep    5s    wait for cu overload take effect
    trigger Positioning Request For UE    lmf_id=1    ue_id=6    nrppa_transaction_id=1    srs_obj_id=1
    ...    pass_regexp=${requested_item_temporarily_not_available}
    Exist CU Overload

    log to console    position should be failure when DU Overload
    Enter DU Overload
    sleep    10s    wait for du overload take effect
    trigger Positioning Request For UE    lmf_id=1    ue_id=6    nrppa_transaction_id=1    srs_obj_id=1
    ...    pass_regexp=${requested_item_temporarily_not_available}
    trigger Positioning Request For UE    lmf_id=1    ue_id=5    nrppa_transaction_id=1    srs_obj_id=1
    ...    pass_regexp=${requested_item_temporarily_not_available}
    Exist DU Overload

    log to console    position should be failure when DU Overload if HPA cells resume.
    OnlineParamChange    ${longer_srbinactvity_drbrrcinactivty_timer}
    Set_ICS_param_for_resume_before_ue_attach
    UEs Attach To Target Cell with HPA call    ${HPA_ue_list}    cell_id=4
    Wait UE2 for srbInactivityTimerSA expired    ${INACTIVE_check_UE2}
    Trigger UE resume Should be Successfully    ue_id=1    cell_id=4    msg=resume_request_1    cause=highPriorityAccess
    ...    pass_regexp=${ResumeReq1_regexp_with_hpa}
    Trigger UE resume Should be Successfully    ue_id=2    cell_id=4    msg=resume_request_1    cause=mt_Access
    ...    pass_regexp=${ResumeReq1_regexp_with_mt_Access}
    Enter DU Overload
    sleep    10s     wait for du overload take effect
    trigger Positioning Request For UE    lmf_id=1    ue_id=1    nrppa_transaction_id=1    srs_obj_id=1
    ...    pass_regexp=${requested_item_temporarily_not_available}
    trigger Positioning Request For UE    lmf_id=1    ue_id=2    nrppa_transaction_id=1    srs_obj_id=1
    ...    pass_regexp=${requested_item_temporarily_not_available}
    Exist DU Overload
    OnlineParamChange    ${rollback_srbinactvity_drbrrcinactivty_timer}

CB010356-B-B7_ET_01_01_Activation and Deactivation of cell and subscriber trace content related to Common procedures for NR positioning methods
    [Documentation]
    ...    1. The purpose of this test case is to check following scenarios:
    ...       PCMD Trace for POSITIONING INFORMATION REQUEST / RESPONSE / FAILURE / UPDATE / DEACTIVATION
    ...    2. Test Case Steps:
    ...      1)LMF trigger "NRPPA: TRP INFORMATION REQUEST" with including infinite periodic SRS configuration for UE11
    ...      2)LMF trigger "NRPPA: TRP INFORMATION REQUEST" with including finite periodic SRS configuration for UE12
    ...      3)LMF trigger "NRPPA: TRP INFORMATION REQUEST" with including periodic SRS configuration without Transmission Characteristics for UE13
    [Tags]    B701
	OnlineParamChange    ${srbInactivityTimerSA_600}
	Start TCE    ${TCE_PORT}
    log to console    step: UE11 attach and lmf requests periodic SRS configuration with Transmissions = 0
    start to capture wireshark log    tag=1_UE11_periodic_SRS_deact_by_lmf
    Set UE Trace Activation    ue_id=11
    SA UE attach with single PDU    ue_id=11    target_cells=1
    Set SRS Configuration    num_periodic=0
    trigger Positioning Request For UE    ue_id=11    pass_regexp=LMF Received Positioning Information Update
    trigger Positioning Deactivation For UE    ue_id=11
    Deactivate UE Trace    ue_id=11
    download and check successful trace    tag=1_UE11_periodic_SRS_deact_by_lmf

    log to console    step: UE12 attach and lmf requests periodic SRS configuration with Transmissions = 5
    start to capture wireshark log    tag=2_UE12_periodic_SRS_deact_by_timeout
    Set UE Trace Activation    ue_id=12
    SA UE attach with single PDU    ue_id=12    target_cells=1
    Set SRS Configuration    num_periodic=5
    trigger Positioning Request For UE    ue_id=12    pass_regexp=LMF Received Positioning Information Update
    Deactivate UE Trace    ue_id=12
    download and check successful trace    tag=2_UE12_periodic_SRS_deact_by_timeout    transmission=5

    log to console    step: UE13 attach and lmf requests periodic SRS configuration during overload
    start to capture wireshark log    tag=3_UE13_failure_by_overload
    Set UE Trace Activation    ue_id=13
    SA UE attach with single PDU    ue_id=13    target_cells=1
    Enter CU Overload
    trigger Positioning Request For UE    ue_id=13    pass_regexp=LMF Received Positioning Information Failure
    Deactivate UE Trace    ue_id=13
    download and check failure trace    tag=3_UE13_failure_by_overload
    [Teardown]    Exit CU Overload And Capture Log

*** Keywords ***
Modify Cfg
    Update Cfg    set_lmf id=1 daemon=$SERVER_IP:$DAEMON_PORT nfId=abcdef01234567gh
    Update Cfg    set_lmf id=2 daemon=$SERVER_IP:$DAEMON_PORT nfId=abcdef12345678gh

    Update Cfg    set_qosflow id=2 5qi=5
    Update Cfg    set_qosflow id=3 5qi=1
    Update Cfg    set_qosflow id=4 5qi=4
    Update Cfg    set_qosflow id=5 5qi=6
    Update Cfg    set_qosflow id=6 5qi=7
    Update Cfg    set_qosrule id=1 proto=tcp qos_flow=1
    Update Cfg    set_qosrule id=2 proto=udp qos_flow=2
    Update Cfg    set_nwslice id=1 qos_flows=6,5,4,3,2,1 qos_rules=1,2 snssai=0x01:0xD143A5 default=on ue=all amf=1-6

    ${set_gnb3}    catenate
    ...    set_gnb id=3 type=simulated plmn=311:489 ng=10.0.1.123 gnb_id=0x23:22 daemon=10.0.2.1:22222 x2_peers=none
    ...    xn=10.0.1.122 nssai=0x1:0xd143a5 amf=1
    Update Cfg    ${set_gnb3}
    ${set_gnb3_cell1}    catenate    set_cell id=1 gnb=3 pci=127:0 tac=200 nrci=0x01 tdd_cell=on proxy=10.0.2.90:9999
    ...    nr_arfcn=513234:513234 gscn=6414 mandatory_for_activation=off
    Update Cfg    ${set_gnb3_cell1}
    Update Cfg    gnb_param id=3 xn_listening_socket=1
    Update Cfg    gnb_param id=3 sa_ho=ng_based measEvent=A2 measEvent=A3

    Update Cfg    set_gnb id=5 type=simulated plmn=311:489 ng=10.0.1.14 daemon=$SERVER_IP:$EDAEMON_PORT gnb_id=0x19:28 nssai=0x01:0xD143A5
    ${set_gnb5_cell1}    catenate    set_cell id=1 gnb=5 pci=4:0 earfcn=39750:39750 tac=200 proxy=$SERVER_IP:12220 nrci=0x1
    ...    tdd_cell=on bw=20MHz technology=lte mandatory_for_activation=off
    Update Cfg    ${set_gnb5_cell1}

    Update Cfg    gnb_param id=5 xn_listening_socket=1
    Update Cfg    sim_trace lmf=1 protocol=nrppa on

Wait UE2 for srbInactivityTimerSA expired
    [Arguments]    ${pass_regexp}    ${timeout}=30s
    Execute Egate Command    Wait UE2 for srbInactivityTimerSA expired    pass_regexp=${pass_regexp}    timeout=${timeout}

trigger TRP Information request for All TRPs
    #lmf_send_trp_info_req id=1 amf_id=1 gnb_id=2 nrppa_transaction_id=0 trp_info_type=nr_pci
    [Arguments]    ${trp_info_type}    ${lmf_id}=1    ${transaction_id}=1    ${pass_regexp}=LMF Received TRPInformationResponse
    ${cmd}    Catenate    lmf_send_trp_info_req id=${lmf_id} amf_id=1 gnb_id=2 nrppa_transaction_id=${transaction_id}
    ...    trp_info_type=${trp_info_type}
    Execute Egate Command    ${cmd}    pass_regexp=${pass_regexp}

trigger TRP Information request for Specific TRP
    #lmf_send_trp_info_req id=1 amf_id=1 gnb_id=2 nrppa_transaction_id=0 trp_info_type=nr_pci trp_id=$_trp_id}
    [Arguments]    ${trp_info_type}    ${tid}=1    ${lmf_id}=1    ${transaction_id}=1     ${pass_regexp}=LMF Received TRPInformationResponse
    ${cmd}    Catenate    lmf_send_trp_info_req id=${lmf_id} amf_id=1 gnb_id=2 nrppa_transaction_id=${transaction_id} trp_id=${tid}
    ...    trp_info_type=${trp_info_type}
    Execute Egate Command    ${cmd}    pass_regexp=${pass_regexp}

download and check wireshark fields
    [Arguments]    ${tag}    ${filter}    ${check_fields}
    ${wireshark_log_path}    stop_wireshark_log_after_filter_found    ${tag}    ${filter}
    check_wireshark_fields    pcap_file=${wireshark_log_path}
    ...                       filter=${filter}
    ...                       check_fields=${check_fields}

Unlock NRcells And Collect Logs
    Unlock NRCell2
    common test teardown and stop capture logs

Set_ICS_param_for_resume_before_ue_attach
    Execute Egate Command    smf_param id=1 reset
    Execute Egate Command    amf_ue_pdu_setup_param id=1 reset
    ${set_ics_param}     catenate    amf_ue_ics_param id=1 core_network_assistance_info=on ue_identity_index_value=1
    ...    ue_specific_drx=64 periodic_registration_update_timer=1:10min plmn_id=311:489 tac_id=200
    Execute Egate Command    ${set_ics_param}

Trigger UE resume Should be Successfully
   [Arguments]    ${ue_id}    ${cell_id}    ${msg}    ${cause}    ${pass_regexp}=${Resume_regexp_with_mo_Data}
    Execute Egate Command    ue_nr_rrc_resume_request_param id=${ue_id} gnb=2 cell=${cell_id} msg=${msg} cause=${cause}
    Execute Egate Command    ue_nr_rrc_resume id=${ue_id}     pass_regexp=${pass_regexp}

UEs Attach To Target Cell with HPA call
    [Arguments]    ${ue_list}    ${pdu_id}=1    ${nwslice}=1    ${cell_id}=3
    FOR    ${ue_id}    IN    @{ue_list}
        Update UE capa    ${ue_id}    ${UE_Capa_Support_UAI_VONR}
        Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
        Execute Egate Command    ue_nr_rrc_setup_param id=${ue_id} establishment_cause=highPriorityAccess
        Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
        Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
        Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} gw=${ue_id} nwslice=${nwslice}    QoS Routing Table
    END

Update UE capa
    [Arguments]    ${ue_id}=81    ${SA_Capa_perUE_Full}=none
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_perUE_Full}
    Execute Egate Command    ${cmd}

Register For Number Of Normal Calls with Default PDU
    [Arguments]    ${cell_id}    ${ue_id_start}    ${ue_id_end_before}    ${nwslice}=1
    FOR    ${ue_id}    IN RANGE    ${ue_id_start}    ${ue_id_end_before}
        Register For Normal Call Successfully    ${ue_id}    ${cell_id}
        ${v1}    catenate    ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=${nwslice} gw=${ue_id}    QoS Routing Table
        ...    timeout=5s
        Execute Egate Command    ${v1}
    END

Register For Normal Call Successfully
    [Arguments]    ${ue_id}    ${cell_id}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Modify UE Establishemnt Cause    ${ue_id}    mo-Signalling
    UE Register To GNB    ${ue_id}

Modify UE Establishemnt Cause
    [Arguments]    ${ue_id}    ${cause}
    Execute Egate Command    ue_nr_rrc_setup_param id=${ue_id} establishment_cause=${cause}

UE Register To GNB
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Reg

SA UE attach with single PDU In Inactive State
    [Arguments]    ${ue_id}=1    ${target_cells}=3
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${target_cells}
    ${command}    Catenate    amf_ue_ics_param id=1 core_network_assistance_info=on ue_identity_index_value=${ue_id} ue_specific_drx=64
    ...    periodic_registration_update_timer=1:10min plmn_id=311:489 tac_id=0
    Execute Egate Command    ${command}
    Execute Egate Command    ue_nr_rrc_setup_param id=${ue_id} establishment_cause=mo-Signalling
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=NG RM Registered
    Execute Egate Command    ue_param id=${ue_id} ignore_paging=off
    Execute Egate Command    ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=${ue_id}    pass_regexp=${PDU_setup_and_IN_INACTIVE_state}

SA UE attach with single PDU
    [Arguments]    ${ue_id}=1    ${target_cells}=4
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${target_cells}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=NG RM Registered
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal    sleep_time=5
    Execute Egate Command    ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=1    pass_regexp=Initial Context Setup Successful

Set SRS Configuration
    #lmf_srs_trans_char_cfg object_id=1 num_periodic_transmissions=1 resource_type=periodic
    [Arguments]    ${id}=1    ${num_periodic}=1    ${type}=periodic
    Execute Egate Command    lmf_srs_trans_char_cfg object_id=${id} num_periodic_transmissions=${num_periodic} resource_type=${type}

trigger Positioning Request For UE
    #lmf_ue_send_pos_info_req id=1 ue=1 nrppa_transaction_id=1 req_srs_obj_id=1
    [Arguments]    ${lmf_id}=1    ${ue_id}=1    ${nrppa_transaction_id}=1    ${srs_obj_id}=1
    ...    ${pass_regexp}=LMF Received Positioning Information Response
    ${cmd}    Catenate    lmf_ue_send_pos_info_req id=${lmf_id} ue=${ue_id} nrppa_transaction_id=${nrppa_transaction_id}
    ...    req_srs_obj_id=${srs_obj_id}
    Execute Egate Command    ${cmd}    pass_regexp=${pass_regexp}

trigger Positioning Deactivation Without Mandatory IE For UE should fail
    [Arguments]    ${lmf_id}=1    ${ue_id}=1    ${nrppa_transaction_id}=1    ${pass_regexp}=Positioning Deactivation sent
    ${cmd}    Catenate    lmf_ue_send_pos_deactivation id=${lmf_id} ue=${ue_id} nrppa_transaction_id=${nrppa_transaction_id}
    ...    action=missing_mandatory_ie missing_mandatory_ie_name=abort_transmission abort_transmission=release_all
    Execute Egate Command    ${cmd}    pass_regexp=${pass_regexp}
    trigger Positioning Request again should fail

trigger Positioning Request again should fail
    [Arguments]    ${lmf_id}=1    ${ue_id}=1    ${nrppa_transaction_id}=1    ${srs_obj_id}=1
    ...    ${fail_regexp}=LMF Received Positioning Information Response
    ${cmd}    Catenate    lmf_ue_send_pos_info_req id=${lmf_id} ue=${ue_id} nrppa_transaction_id=${nrppa_transaction_id}
    ...    req_srs_obj_id=${srs_obj_id}
    Execute Egate Command    ${cmd}    fail_regexp=${fail_regexp}

trigger Positioning Deactivation For UE
    [Arguments]    ${lmf_id}=1    ${ue_id}=1    ${nrppa_transaction_id}=1    ${abort_transmission}=release_all
    ...    ${pass_regexp}=Positioning Deactivation sent
    ${cmd}    Catenate    lmf_ue_send_pos_deactivation id=${lmf_id} ue=${ue_id} nrppa_transaction_id=${nrppa_transaction_id}
    ...    abort_transmission=${abort_transmission}
    Execute Egate Command    ${cmd}    pass_regexp=${pass_regexp}

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir

Enter CU Overload
    Execute Aashell Cmd    rad -mow 0x89006f 0    #rdOverloadHighThreshold
    Sleep    5

Exist CU Overload
    Execute Aashell Cmd    rad -mow 0x89006f 1000    #sshenb telnet 0 15007

Exit CU Overload And Capture Log
    Execute Aashell Cmd    rad -mow 0x89006f 1000
    Sleep    5
    Common Test Teardown And Stop Capture Logs

Enter DU Overload
    Execute Aashell Cmd    rad -mow 0x5901fa 1    #rdOverloadRejectionLowerMessageQueuingTimeName
    Execute Aashell Cmd    rad -mow 0x5901fb 2    #rdOverloadRejectionUpperMessageQueuingTimeName
    Execute Aashell Cmd    rad -mow 0x5901fc 1    #rdOverloadTriggeringMessageNumberName
    Execute Aashell Cmd    rad -mow 0x590226 0    #rdOverloadIndicationThresholdName
    Execute Aashell Cmd    rad -mow 0x590221 3000    #rdKeepOverloadDuration
    Execute Aashell Cmd    rad -mow 0x590227 200    #rdOverloadIndicationDurationThreshold

Exist DU Overload
    Execute Aashell Cmd    rad -mow 0x5901fa 100000    #rdOverloadRejectionLowerMessageQueuingTimeName
    Execute Aashell Cmd    rad -mow 0x5901fb 125000    #rdOverloadRejectionUpperMessageQueuingTimeName
    Execute Aashell Cmd    rad -mow 0x5901fc 30    #rdOverloadTriggeringMessageNumberName
    Execute Aashell Cmd    rad -mow 0x590226 100    #rdOverloadIndicationThresholdName
    Execute Aashell Cmd    rad -mow 0x590221 3000    #rdKeepOverloadDuration
    Execute Aashell Cmd    rad -mow 0x590227 200    #rdOverloadIndicationDurationThreshold

Set UE Trace Activation
    [Arguments]    ${ue_id}=1
    ${command}    Catenate    amf_ue_ics_param id=1 ue=${ue_id} object_id=1 location_reporting_reference_id=1 trace_activation=on
    ...    trace_plmn=311:489 trace_ref_id=1 trace_rec_session_ref_id=1 trace_depth=medium ifaces_to_trace=Uu,NG-C,Xn-C tce_ip=${TCE_IP}
    Execute Egate Command    ${command}

Deactivate UE Trace
    [Arguments]    ${ue_id}=1    ${sleep_time}=2
    Sleep    ${sleep_time}
    Execute Egate Command    ng_ue_trace_stop id=${ue_id} trace_plmn=311:489 trace_ref_id=1 trace_rec_session_ref_id=1

download and check successful trace
    [Arguments]    ${tag}    ${cell_pci}=50    ${transmission}=0
    ${wireshark_log_path}    stop_wireshark_log_after_filter_found    ${tag}    ${deactivate_trace}
    # Check Request and Response
    check nrppa trace fields    log_path=${wireshark_log_path}
    ...                         decode_filter=${mba_positioningInformationExchange}
    ...                         pdu_type=F1AP-PDU
    ...                         pos_msg=PositioningInformationResponse
    ...                         cell_pci=${cell_pci}
    ...                         transmission=${transmission}
    check nrppa trace fields    log_path=${wireshark_log_path}
    ...                         decode_filter=${sba_positioningInformationExchange}
    ...                         pdu_type=NGAP-PDU
    ...                         pos_msg=PositioningInformationResponse
    ...                         cell_pci=${cell_pci}
    ...                         transmission=${transmission}
    # Check Update
    check nrppa trace fields    log_path=${wireshark_log_path}
    ...                         decode_filter=${mba_PositioningInformationUpdate}
    ...                         pdu_type=F1AP-PDU
    ...                         pos_msg=PositioningInformationUpdate
    ...                         cell_pci=${cell_pci}
    ...                         transmission=${transmission}
    check nrppa trace fields    log_path=${wireshark_log_path}
    ...                         decode_filter=${sba_PositioningInformationUpdate}
    ...                         pdu_type=NGAP-PDU
    ...                         pos_msg=PositioningInformationUpdate
    ...                         cell_pci=${cell_pci}
    ...                         transmission=${transmission}
    # Check Deactivation
    ${deact_filter}    Set Variable If    ${transmission} == 0    ${mba_PositioningDeactivation}    ${mba_PositioningDeactivation_f1ap}
    check_wireshark_fields    pcap_file=${wireshark_log_path}
    ...                       filter=${deact_filter}
    ...                       check_fields=F1AP-PDU/${deact_pos_srs}
    Run Keyword If    ${transmission} == 0    check_wireshark_fields
    ...                       pcap_file=${wireshark_log_path}
    ...                       filter=${sba_PositioningDeactivation}
    ...                       check_fields=NGAP-PDU/${deact_pos_srs}

check nrppa trace fields
    [Arguments]    ${log_path}    ${decode_filter}    ${pdu_type}    ${pos_msg}    ${cell_pci}    ${transmission}
    ${nr_pci}    Set Variable If    '${pdu_type}' == 'F1AP-PDU'    pci=${cell_pci}    pCI-NR=${cell_pci}
    @{pos_srs_info}    Create List
    ...    ${pdu_type}/${pos_msg}/RelativeTime1900=[RE]967fbbffffff258c.*
    ...    ${pdu_type}/${pos_msg}/SRSResource/sRSResourceID=0
    ...    ${pdu_type}/${pos_msg}/SRSResource/nrofSRS-Ports=[RE]port1 .*
    ...    ${pdu_type}/${pos_msg}/SRSResource/combOffset-n2=1
    ...    ${pdu_type}/${pos_msg}/SRSResource/cyclicShift-n2=1
    ...    ${pdu_type}/${pos_msg}/SRSResource/startPosition=1
    ...    ${pdu_type}/${pos_msg}/SRSResource/nrofSymbols=[RE]n1 .*
    ...    ${pdu_type}/${pos_msg}/SRSResource/resourceType=[RE]periodic .*
    ...    ${pdu_type}/${pos_msg}/SRSResource/periodic/periodicity=[RE]slot5 .*
    ...    ${pdu_type}/${pos_msg}/SRSResource/periodic/offset=1
    ...    ${pdu_type}/${pos_msg}/SRSResourceSet/sRSResourceSetID=0
    ...    ${pdu_type}/${pos_msg}/SRSResourceSet/sRSResourceID-List/SRSResourceID=0
    ...    ${pdu_type}/${pos_msg}/SRSResourceSet/resourceSetType=[RE]periodic .*
    ...    ${pdu_type}/${pos_msg}/SRSResourceSet/periodic/periodicSet=[RE]true .*
    ...    ${pdu_type}/${pos_msg}/${nr_pci}
    Run Keyword If    '${pos_msg}' == 'PositioningInformationResponse'
    ...    Append To List    ${pos_srs_info}    ${pdu_type}/PositioningInformationRequest/numberOfTransmissions=${transmission}
    check_wireshark_fields    pcap_file=${log_path}
    ...                       filter=${decode_filter}
    ...                       check_fields=${pos_srs_info}

download and check failure trace
    [Arguments]    ${tag}
    ${wireshark_log_path}    stop_wireshark_log_after_filter_found    ${tag}    ${deactivate_trace}
    # Cell Trace
    check_wireshark_fields    pcap_file=${wireshark_log_path}
    ...                       filter=${mba_PositioningInformationFailure}
    ...                       check_fields=${pos_srs_fail}
    # PCMD
    check_wireshark_fields    pcap_file=${wireshark_log_path}
    ...                       filter=${sba_PositioningInformationFailure}
    ...                       check_fields=${pos_srs_fail}
