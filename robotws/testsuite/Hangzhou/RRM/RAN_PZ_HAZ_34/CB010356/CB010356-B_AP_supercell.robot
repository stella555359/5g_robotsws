*** Settings ***
Documentation
...    author: Li Zhiguo
...    contact: zhiguo.li@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_08
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG8/resources/DevHZ5_resource_ET.robot
Suite Setup       Common Suite Setup And Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/supercell_ecpri
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        release-SBTS25R1    tl-CLOUD_5G_I_MP_AP_LOOO

*** Variables ***
${SYSCOM_FLAG}    True
${PositioningDeactivation}    f1ap.procedureCode == 51
${PositioningInformationResponse}    nrppa.id == 54
${positioningInformationExchange}    nrppa.NRPPA_PDU == 1
${PositioningInformationFailure}    nrppa.NRPPA_PDU == 2
${cell1_pci}    50
${cell3_pci}    52
@{pos_srs_info}    RelativeTime1900=[RE]967fbbffffff258c .*
...                SRSResource/sRSResourceID=0
...                SRSResource/nrofSRS-Ports=[RE]port1 .*
...                SRSResource/combOffset-n2=1
...                SRSResource/cyclicShift-n2=1
...                SRSResource/startPosition=1
...                SRSResource/nrofSymbols=[RE]n1 .*
...                SRSResource/resourceType=[RE]periodic .*
...                SRSResource/periodic/periodicity=[RE]slot5 .*
...                SRSResource/periodic/offset=1
...                SRSResourceSet/sRSResourceSetID=0
...                SRSResourceSet/sRSResourceID-List/SRSResourceID=0
...                SRSResourceSet/resourceSetType=[RE]periodic .*
...                SRSResourceSet/periodic/periodicSet=[RE]true .*
@{cell1_pos_srs_info}    pCI-NR=${cell1_pci}
...                      @{pos_srs_info}
@{cell3_pos_srs_info}    pCI-NR=${cell3_pci}
...                      @{pos_srs_info}
@{no_pos_srs_info}    RelativeTime1900=not_existing
...                   SRSResource=not_existing
...                   SRSResourceSet=not_existing
@{pos_info_fail}    Cause/radioNetwork=[RE]requested-item-temporarily-not-available .*
${UE_Capa_Support_UAI_VONR}    SEPARATOR=
...    E1A00000074E5A031E00038520001E09306400043C2C006201A0130180603806546C28D6080A1A0259651311000F5B0404041C3BC70E41870
...    0040C9E3EAE0009E00380027800546C4CD6080A1A0259651311000F5B0404041C3BC70E418700040C9E3EAE0009E00380027800546C4DD608
...    0A1A0259651311000F5B0404041C3BC70E418700040C9E3EAE0009E00380027800546C4ED6080A1A0259651311000F5B0404041C3BC70E418
...    700040C9E3EAA00000A000000410713400000041C4C0000000020268D8000160201100883D87C001800140E0A00E06013003800341F000000
...    000000072A68000800004B2CA801A55543C001C002C00000010020046AC4C0004080C1014181C202C4044484C648494989CA12982D
@{PDU_setup_and_IN_INACTIVE_state}    QoS Routing Table
...                                   Moving UE to NR_RRC_INACTIVE state
...                                   Is INACTIVE

*** Test Cases ***
CB010356-B-B1_ET_01_02_periodic infinite or no SRS configuration successful to LMF
    [Documentation]
    ...    1. The purpose of this test case is to check following scenarios:
    ...       periodic SRS configuration in NRPPA: POS INFORMATION
    ...    2. Test Case Steps:
    ...      1)LMF trigger "NRPPA: POS INFORMATION REQUEST" with including periodic SRS configuration for UE1
    ...      2)LMF trigger "NRPPA: POS INFORMATION REQUEST" with including non-periodic SRS configuration for UE2
    ...      3)LMF trigger "NRPPA: POS INFORMATION REQUEST" with including periodic SRS configuration without Transmission Characteristics for UE3
    [Tags]    B102
    log to console    step: UE1 attach and lmf requests periodic SRS configuration with Transmissions = 0
    start to capture wireshark log    tag=1_UE1_periodic_SRS
    SA UE attach with single PDU    target_cells=1
    Set SRS Configuration    num_periodic=0
    trigger Positioning Request For UE
    download and check wireshark fields    tag=1_UE1_periodic_SRS
    ...                                    capture_filter=${PositioningInformationResponse}
    ...                                    decode_filter=${PositioningInformationResponse}
    ...                                    check_fields=${cell1_pos_srs_info}
    log to console    step: UE2 attach and lmf requests non-periodic SRS configuration
    start to capture wireshark log    tag=2_UE2_non_periodic_SRS
    SA UE attach with single PDU    ue_id=2    target_cells=1
    Set SRS Configuration    type=aperiodic
    trigger Positioning Request For UE    ue_id=2
    download and check wireshark fields    tag=2_UE2_non_periodic_SRS
    ...                                    capture_filter=${PositioningInformationResponse}
    ...                                    decode_filter=${PositioningInformationResponse}
    ...                                    check_fields=${cell1_pos_srs_info}
    log to console    step: UE3 attach and lmf requests periodic SRS configuration without Transmission IE
    start to capture wireshark log    tag=3_UE3_periodic_SRS_wo_transmission
    SA UE attach with single PDU    ue_id=3    target_cells=1
    Set SRS Configuration    type=periodic
    trigger Positioning Request For UE without Retransmission    ue_id=3
    download and check wireshark fields    tag=3_UE3_periodic_SRS_wo_transmission
    ...                                    capture_filter=${positioningInformationExchange}
    ...                                    decode_filter=${positioningInformationExchange}
    ...                                    check_fields=${no_pos_srs_info}

CB010356-B-B1_ET_01_07_Successful SRS Configuration to LMF for UE with priority access call under overload condition with PDU session
    [Documentation]
    ...    1. The purpose of this test case is to check following scenarios:
    ...       periodic SRS configuration in NRPPA: POS INFORMATION for priority access call (PDU Sesstion) during CU/DU overload
    ...    2. Test Case Steps:
    ...      1) make CU overload
    ...      2) gNB sends "NRPPA: POS INFORMATION RESPONSE" with SRS configuration for PA UE23 and UE24
    ...      3) make DU overload
    ...      4) gNB sends "NRPPA: POS INFORMATION FAILURE" with SRS configuration for PA UE25 due to low priority
    [Tags]    B107
    log to console    step: PA UE23 ICS and lmf requests periodic SRS configuration during CU overload
    start to capture wireshark log    tag=1_UE23_CU_overload
    ICS With High Priority Call    ue_id=23    cell_id=3
    Enter CU Overload
    Set SRS Configuration
    trigger Positioning Request For UE    ue_id=23
    download and check wireshark fields    tag=1_UE23_CU_overload
    ...                                    capture_filter=${PositioningDeactivation}
    ...                                    decode_filter=${PositioningInformationResponse}
    ...                                    check_fields=${cell3_pos_srs_info}
    Exit CU Overload
    log to console    step: PA UE24 Add DRB and lmf requests periodic SRS configuration during CU overload
    start to capture wireshark log    tag=2_UE24_CU_overload
    SA UE attach with single PDU    ue_id=24    target_cells=3
    Enter CU Overload
    PDU Session Modification    ue_id=24    qos_flow_id=5    priority=6    action=add
    Set SRS Configuration
    trigger Positioning Request For UE    ue_id=24
    download and check wireshark fields    tag=2_UE24_CU_overload
    ...                                    capture_filter=${PositioningDeactivation}
    ...                                    decode_filter=${PositioningInformationResponse}
    ...                                    check_fields=${cell3_pos_srs_info}
    Exit CU Overload
    log to console    step: PA UE25 Resume and lmf requests periodic SRS configuration during DU overload
    Online Param Change    ${Trigger_UE_RRC_Inactive}
    start to capture wireshark log    tag=3_UE25_DU_overload
    SA UE attach with single PDU In Inactive State     ue_id=25    target_cells=3
    Enter DU Overload
    UE Resume to Active State     ue_id=25    cell_id=3    cause=highPriorityAccess
    trigger Positioning Request For UE    ue_id=25    pass_regexp=LMF Received Positioning Information Failure
    download and check wireshark fields    tag=3_UE25_DU_overload
    ...                                    capture_filter=${PositioningInformationFailure}
    ...                                    decode_filter=${PositioningInformationFailure}
    ...                                    check_fields=${pos_info_fail}
    [Teardown]    Exit CU and DU Overload State And Recover QoS

CB010356-B-B6_ET_01_07_Unsuccessful SRS Configuration to LMF caused by Radio Link Failure and Reestablishment
    [Documentation]
    ...    1. The purpose of this test case is to check following scenarios:
    ...       periodic SRS configuration in NRPPA: POS INFORMATION during UE RLF
    ...    2. Test Case Steps:
    ...      1) lmf sends "NRPPA: POS INFORMATION REQUEST" with SRS configuration for PA UE6
    ...      2) gNB sends "NRPPA: POS INFORMATION FAILURE" with caues: requested-item-temporarily-not-available due to RLF and RRE
    [Tags]    B607
    log to console    step: UE6 trigger RRE when lmf requests periodic SRS configuration
    start to capture wireshark log    tag=1_UE6_RLF
    SA UE attach with single PDU    ue_id=6    target_cells=1
    Set SRS Configuration
    trigger Positioning Request For UE    ue_id=6    pass_regexp=${EMPTY}
    Trigger UE RLF and RRE    ue_id=6    target_cell_id=1
    download and check wireshark fields    tag=1_UE6_RLF
    ...                                    capture_filter=${PositioningInformationFailure}
    ...                                    decode_filter=${PositioningInformationFailure}
    ...                                    check_fields=${pos_info_fail}

CB010356-B-B6_ET_01_02_Unsuccessful SRS Configuration to LMF caused by Intra-gNB HO
    [Documentation]
    ...    1. The purpose of this test case is to check following scenarios:
    ...       periodic SRS configuration in NRPPA: POS INFORMATION during UE HO
    ...    2. Test Case Steps:
    ...      1) lmf sends "NRPPA: POS INFORMATION REQUEST" with SRS configuration for UE1
    ...      2) gNB sends "NRPPA: POS INFORMATION FAILURE" with caues: requested-item-temporarily-not-available due to HO trigger
    [Tags]    B602
    start to capture wireshark log    tag=1_UE7_HO
    Set SRS Configuration
    log to console    step:attach UE7 to cell3
    Execute Egate Command    ue_nr_rrc_reconf_param id=7 if_contains=any nth=1 delay=0
    SA UE attach with single PDU    ue_id=7    target_cells=3
    log to console    step:set SRS configuration for UE7
    Set SRS Configuration    id=7    num_periodic=0    type=periodic
    log to console    step:make RRC reconfig delay 3s For UE7
    Execute Egate Command    ue_nr_rrc_reconf_param id=7 if_contains=any nth=1 delay=3s
    log to console    step:trigger A3 measurement report
    Execute Egate Command    ue_measurement_send_nr id=7 meas_id=1 event=A3 srsrp_nr=50 srsrq_nr=30 phycell_id=50 nrsrp_nr=70 nrsrq_nr=30
    ...    pass_regexp=Hit on error cases presence
    log to console    step:trigger position request during HO procedure
    Execute Egate Command    lmf_ue_send_pos_info_req id=1 ue=7 nrppa_transaction_id=1 req_srs_obj_id=1
    ...    pass_regexp=LMF Received Positioning Information Failure
    download and check wireshark fields    tag=1_UE7_HO
    ...                                    capture_filter=${PositioningInformationFailure}
    ...                                    decode_filter=${PositioningInformationFailure}
    ...                                    check_fields=${pos_info_fail}
    [Teardown]    Reset RRC Reconfig No Delay and Common Teardown    ue_id=7


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
    Update Cfg    set_nwslice id=1 qos_flows=6,5,4,3,2,1 qos_rules=1,2 snssai=0x01:0xD143A5 default=on ue=all amf=1
    Update Cfg    sim_trace lmf=1 protocol=nrppa on

Online Param Change
    [Arguments]    ${Online_Param}    ${sleep_time}=0
    Delta Commission Parameters    ${Online_Param}
    sleep    ${sleep_time}
    Cells Should Be OnAir

Update UE capa
    [Arguments]    ${ue_id}    ${SA_Capa_perUE_Full}=none
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_perUE_Full}
    Execute Egate Command    ${cmd}

SA UE attach with single PDU
    [Arguments]    ${ue_id}=1    ${target_cells}=1
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${target_cells}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=NG RM Registered
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal    sleep_time=5
    Execute Egate Command    ue_nr_rrc_setup_param id=${ue_id} establishment_cause=mo-Signalling
    Execute Egate Command    ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=1    pass_regexp=Initial Context Setup Successful

SA UE attach with single PDU In Inactive State
    [Arguments]    ${ue_id}=1    ${target_cells}=3
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${target_cells}
    ${command}    Catenate    amf_ue_ics_param id=1 core_network_assistance_info=on ue_identity_index_value=${ue_id} ue_specific_drx=64
    ...    periodic_registration_update_timer=1:10min plmn_id=311:489 tac_id=0
    Execute Egate Command    ${command}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=NG RM Registered
    Execute Egate Command    ue_param id=${ue_id} ignore_paging=off
    Execute Egate Command    ue_nr_rrc_setup_param id=${ue_id} establishment_cause=mo-Signalling
    Execute Egate Command    ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=1    pass_regexp=${PDU_setup_and_IN_INACTIVE_state}

UE Resume to Active State
    [Arguments]    ${ue_id}    ${cell_id}=1    ${msg}=resume_request_1    ${cause}=emergency
    @{resume_check}    Create List
    ...    rrcResumeRequest1
    ...    resumeCause ${cause}
    ...    QoS Routing Table
    Execute Egate Command    ue_nr_rrc_resume_request_param id=${ue_id} gnb=2 cell=${cell_id} msg=${msg} cause=${cause}
    Execute Egate Command    ue_nr_rrc_resume id=${ue_id}    pass_regexp=${resume_check}

Set SRS Configuration
    [Arguments]    ${id}=1    ${num_periodic}=1    ${type}=periodic
    Execute Egate Command    lmf_srs_trans_char_cfg object_id=${id} num_periodic_transmissions=${num_periodic} resource_type=${type}

trigger Positioning Request For UE
    [Arguments]    ${lmf_id}=1    ${ue_id}=1    ${nrppa_transaction_id}=1
    ...    ${srs_obj_id}=1    ${pass_regexp}=LMF Received Positioning Information Response
    ${cmd}    Catenate    lmf_ue_send_pos_info_req id=${lmf_id} ue=${ue_id} nrppa_transaction_id=${nrppa_transaction_id}
    ...    req_srs_obj_id=${srs_obj_id}
    Execute Egate Command    ${cmd}    pass_regexp=${pass_regexp}

trigger Positioning Request For UE without Retransmission
    [Arguments]    ${lmf_id}=1    ${ue_id}=1    ${srs_obj_id}=1
    ...    ${pass_regexp}=LMF Received Positioning Information Response
    ${cmd}    Catenate    lmf_ue_send_pos_info_req id=${lmf_id} ue=${ue_id} req_srs_obj_id=${srs_obj_id}
    ...    action=missing_mandatory_ie missing_mandatory_ie_name=requested_srs_transmission_characteristics
    Execute Egate Command    ${cmd}    pass_regexp=${pass_regexp}

trigger Positioning Deactivation Without Mandatory IE For UE
    # lmf_ue_send_pos_deactivation ue=1 id=1 nrppa_transaction_id=1 action=missing_mandatory_ie \
    # missing_mandatory_ie_name=abort_transmission abort_transmission=release_all
    [Arguments]    ${lmf_id}=1    ${ue_id}=1    ${nrppa_transaction_id}=1    ${pass_regexp}=Positioning Deactivation sent
    ${cmd}    Catenate    lmf_ue_send_pos_deactivation id=${lmf_id} ue=${ue_id} nrppa_transaction_id=${nrppa_transaction_id}
    ...    action=missing_mandatory_ie missing_mandatory_ie_name=abort_transmission abort_transmission=release_all
    Execute Egate Command    ${cmd}    pass_regexp=${pass_regexp}

Enter CU Overload
    Execute Aashell Cmd    rad -mow 0x89006f 0
    Sleep    5

Exit CU Overload
    Execute Aashell Cmd    rad -mow 0x89006f 1000
    Sleep    5

Enter DU Overload
    Execute Aashell Cmd    rad -mow 0x5901fa 1
    Execute Aashell Cmd    rad -mow 0x5901fb 2
    Execute Aashell Cmd    rad -mow 0x5901fc 1
    Execute Aashell Cmd    rad -mow 0x590226 0
    Sleep    5

Exit DU Overload
    Execute Aashell Cmd    rad -mow 0x5901fa 100000
    Execute Aashell Cmd    rad -mow 0x5901fb 125000
    Execute Aashell Cmd    rad -mow 0x5901fc 30
    Execute Aashell Cmd    rad -mow 0x590226 100
    Sleep    5

Exit CU and DU Overload State
    Exit CU Overload
    Exit DU Overload
    Common Test Teardown And Stop Capture Logs

Exit CU and DU Overload State And Recover QoS
    Exit CU Overload
    Exit DU Overload
    Recover QoS Flow Setting
    Online Param Change    ${Recover_UE_RRC_Inactive}
    Common Test Teardown And Stop Capture Logs

Register With Emergency Call
    [Arguments]    ${ue_id}    ${cell_id}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_nr_rrc_setup_param id=${ue_id} establishment_cause=emergency
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register

ICS With Emergency Call
    [Arguments]    ${ue_id}    ${cell_id}
    Update UE capa    ue_id=${ue_id}    SA_Capa_perUE_Full=${UE_Capa_Support_UAI_VONR}
    ${cmd1}    catenate    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=1 nwslice=1 request_type=initial-emergency-request
    ${cmd2}    catenate    ue_pdu_session_setup ue=${ue_id} pdu=2 gw=2 nwslice=1 request_type=initial-request
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_nr_rrc_setup_param id=${ue_id} establishment_cause=mo-Signalling
    Execute Egate Command    qosflow_modify qos_flow=2 default=on priority=1
    Execute Egate Command    qosflow_modify qos_flow=3 priority=1
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    smf_param id=1 additional_qosflows_to_activate=3
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ${cmd1}    QoS Routing Table
    Execute Egate Command    qosflow_modify qos_flow=1 default=on
    Execute Egate Command    smf_param id=1 reset
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=2 trf_type=internal
    Execute Egate Command    ${cmd2}    QoS Routing Table

Register With High Priority Call
    [Arguments]    ${ue_id}    ${cell_id}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_nr_rrc_setup_param id=${ue_id} establishment_cause=highPriorityAccess
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register

ICS With High Priority Call
    [Arguments]    ${ue_id}    ${cell_id}
    ${cmd}    catenate    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=1 nwslice=1
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_nr_rrc_setup_param id=${ue_id} establishment_cause=mo-Signalling
    Execute Egate Command    qosflow_modify qos_flow=5 priority=6
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    smf_param id=1 additional_qosflows_to_activate=5
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ${cmd}    QoS Routing Table
    Execute Egate Command    smf_param id=1 reset

PDU Session Modification
    [Arguments]    ${ue_id}    ${qos_flow_id}    ${priority}    ${action}=add   ${pdu_id}=1
    ${cmd}    catenate    ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id} qosflows_to_${action}=${qos_flow_id} by=amf
    Execute Egate Command    qosflow_modify qos_flow=${qos_flow_id} priority=${priority}
    Execute Egate Command    ${cmd}    QoS Routing Table

Recover QoS Flow Setting
    Execute Egate Command    qosflow_modify qos_flow=1 default=on
    Execute Egate Command    qosflow_modify qos_flow=2 priority=15
    Execute Egate Command    qosflow_modify qos_flow=3 priority=15
    Execute Egate Command    qosflow_modify qos_flow=5 priority=15
    Execute Egate Command    smf_param id=1 reset

download and check wireshark fields
    [Arguments]    ${tag}    ${capture_filter}    ${decode_filter}    ${check_fields}    ${repeat_num}=0
    ${wireshark_log_path}    stop_wireshark_log_after_filter_found    ${tag}    ${capture_filter}
    check_wireshark_fields    pcap_file=${wireshark_log_path}
    ...                       filter=${decode_filter}
    ...                       check_fields=${check_fields}
    ...                       packet_num=${repeat_num}

Trigger UE RLF and RRE
    [Arguments]    ${ue_id}=1    ${target_cell_id}=1    ${rlf_cause}=otherFailure
    ...    ${pass_regexp}=NR RRC Reestablishment sucessfully completed
    Execute Egate Command    ue_rrc_reestablish id=${ue_id} cell=${target_cell_id} cause=${rlf_cause}
    ...    pass_regexp=${pass_regexp}

Reset RRC Reconfig No Delay and Common Teardown
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_nr_rrc_reconf_param id=${ue_id} if_contains=any nth=1 delay=0
    Common Test Teardown And Stop Capture Logs
