*** Settings ***
Documentation
...      == COPYRIGHT ==
...      Nokia Networks
...      == AUTHORS ==
...      - Maciej Madej <maciej.madej@nokia.com>
...      - Mateusz Matusik <mateusz.matusik@nokia.com>
...      == MAINTAINER ==
...      - Maciej Madej <maciej.madej@nokia.com>
...      - Mateusz Matusik <mateusz.matusik@nokia.com>
...      - I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>

Resource    CB007564_common_keywords.robot

*** Keywords ***
Add secondary PDU Session to UE${ue_id:[1-9]} with one QoS Flow with s-nssai not supported in NRCELL-1
    Execute egate command   cmd=ue_pdu_session_setup ue=${ue_id} pdu=3 gw=3 nwslice=2

Attach UE${ue_id:\d+} to gNB2 NRCELL-${cell_id:[1-9]} and setup initial PDU Session with one QoS Flow
    Expect RRC messages flow for UE${ue_id} during UE Attach prcedure
    Expect NGAP messages flow for UE${ue_id} during UE Attach prcedure

    Execute egate command   cmd=change_ue_location id=${ue_id} enb=2 cell=${cell_id}
    Sleep  2s
    Attach UE   ue_id=${ue_id}
    Execute egate command
    ...   cmd=ue_pdu_session_setup pdu=1 ue=${ue_id} gw=${ue_id} nwslice=1
    ...   pass_regexp=UE${ue_id}: UE${ue_id}: Established PDU session

Cleanup after test B104-TC1
    Execute egate command   cmd=ue_nr_rrc_reconf_param id=1 reset
    Deregister UE1
    Execute egate command   cmd=change_ue_location id=1 enb=2 cell=1
    Execute egate command   cmd=qosflow_modify qos_flow=5 priority=15
    Execute egate command   cmd=qosflow_modify qos_flow=1 priority=5
    Execute egate command   cmd=ue_param id=1 nr_usage_setting=data_centric
    Execute egate command   cmd=ue_nr_rrc_setup_param id=1 establishment_cause=mo-Data

Configure UE${ue_id:[1-9]} for emergency call
    Execute egate command   cmd=qosflow_modify qos_flow=1 priority=5
    Execute egate command   cmd=qosflow_modify qos_flow=5 priority=5
    Execute egate command   cmd=ue_param id=${ue_id} nr_usage_setting=voice_centric
    Execute egate command   cmd=ue_nr_rrc_setup_param id=${ue_id} establishment_cause=emergency

Expect F1AP UE Context Modification flow for UE${ue_id:[1-9]} intra-gNB handover with HandoverPreparationInformation IE
    Expect Message Flow
    ...     gNB2:F1AP_UEContextModificationRequest (HandoverPreparationInformation is present)
    ...     gNB2:F1AP_UEContextModificationResponse
    ...     alias=F1AP_HO_flow
    ...     overall_timeout=10

Prepare test environment B104-TC1
    Enable internal mirroring for alias  gNB2
    Collect PM counters file

Prepare UE${ue_id:[1-9]} for partial HO
    Execute egate command
    ...   cmd=deregister_ue id=${ue_id} by=amf
    ...   pass_regexp=UEC-1: UE${ue_id}: detached
    Configure UE1 for emergency call

    Execute egate command
    ...   cmd=register_ue id=${ue_id} registration_type=EmergencyRegistration
    ...   pass_regexp=Received REGISTRATION COMPLETE from UE
    Execute egate command
    ...   cmd=ue_pdu_session_setup pdu=1 ue=${ue_id} gw=1 nwslice=1
    ...   pass_regexp=AMF-1: Setup QosFlow with QFI:1 5QI:5 SEID:1
    Execute egate command
    ...   cmd=ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=1
    ...   pass_regexp=AMF-1: Added QosFlow with QFI:2 5QI:1 SEID:1

Remove emergency configuration from UE${ue_id:[1-9]}
    Execute egate command   cmd=qosflow_modify qos_flow=1 priority=15
    Execute egate command   cmd=qosflow_modify qos_flow=4 priority=5
    Execute egate command   cmd=ue_param id=${ue_id} nr_usage_setting=data_centric
    Execute egate command   cmd=ue_nr_rrc_setup_param id=${ue_id} establishment_cause=mo-Data

Trigger intra-gNB Handover to NRCELL-${nrcell_id} for UE${ue_id:[1-9]}
    Expect F1AP UE Context Modification flow for UE${ue_id} intra-gNB handover with HandoverPreparationInformation IE
    Expect RRC reconfiguration flow for UE${ue_id}

    Sleep  2s
    Execute egate command
    ...   cmd=ue_measurement_send_nr id=${ue_id} meas_id=1 event=A3 srsrp_nr=11 phycell_id=${phy_cell_id}[${nrcell_id}] nrsrp_nr=40
    ...   pass_regexp=Intra-eNB handover from EXT_ENB

Trigger partial intra-gNB Handover to NRCELL-${nrcell_id} for UE${ue_id:[1-9]}
    Expect F1AP UE Context Modification flow for UE${ue_id} intra-gNB handover with HandoverPreparationInformation IE
    Expect RRC reconfiguration flow for UE${ue_id}

    Expect Message Flow
    ...     AMF1:NGAP_PDUSessionResourceNotify (cause contains (radioNetwork eq 'slice-not-supported'))
    ...     alias=UE${ue_id}_PDU_notify
    ...     overall_timeout=10

    Sleep  2s
    Execute egate command
    ...   cmd=ue_measurement_send_nr id=${ue_id} meas_id=1 event=A3 srsrp_nr=11 phycell_id=${phy_cell_id}[${nrcell_id}] nrsrp_nr=40
    ...   pass_regexp=UEC-1: UE${ue_id}: Intra-eNB handover from EXT_ENB

Trigger unsuccessful intra-gNB Handover to NRCELL-${nrcell_id} for UE${ue_id:[1-9]}
    Sleep  2s
    Expect F1AP UE Context Modification flow for UE${ue_id} intra-gNB handover with HandoverPreparationInformation IE

    Expect Message Flow
    ...     UE_${ue_id}:NR-RRC_RRCReconfiguration
    ...     alias=UE${ue_id}_RRC_Reconfiguration
    ...     overall_timeout=10

    Expect message will not occur
    ...     UE_${ue_id}:NR-RRC_RRCReconfigurationComplete
    ...     alias=UE${ue_id}_RRC_Reconfiguration_complete
    ...     overall_timeout=10

    Expect Message Flow
    ...     AMF1:NGAP_UEContextReleaseRequest (Cause contains (radioNetwork eq 'radio-connection-with-ue-lost'))
    ...     AMF1:NGAP_UEContextReleaseCommand (Cause contains (radioNetwork eq 'radio-connection-with-ue-lost'))
    ...     AMF1:NGAP_UEContextReleaseComplete
    ...     alias=UE${ue_id}_UE_Context_Release
    ...     overall_timeout=30

    Execute egate command   cmd=ue_nr_rrc_reconf_param id=1 if_contains=any action=drop
    Execute egate command
    ...   cmd=ue_measurement_send_nr id=${ue_id} meas_id=1 event=A3 srsrp_nr=11 phycell_id=${phy_cell_id}[${nrcell_id}] nrsrp_nr=40

Verify that UE${ue_id:[1-9]} handover failed due to lack of response to RRC Reconfiguration
    Flow occurred as expected   alias=F1AP_HO_flow
    Flow occurred as expected   alias=UE${ue_id}_RRC_Reconfiguration
    Flow Not Occurred For Message    alias=UE${ue_id}_RRC_Reconfiguration_complete

Verify that UE${ue_id:[1-9]} handover was successful
    Flow occurred as expected   alias=F1AP_HO_flow
    Flow occurred as expected   alias=UE${ue_id}_RRC_Reconfiguration

Verify that UE${ue_id:[1-9]} partial handover was successful
    Verify that UE${ue_id} handover was successful
    Flow occurred as expected   alias=UE${ue_id}_PDU_notify

Verify that UE${ue_id:[1-9]} was attached to gNB2 NRCELL-${nrcell_id}
    Flow occurred as expected   alias=UE${ue_id}_RRC_attach
    Flow occurred as expected   alias=UE${ue_id}_NGAP_attach

Trigger intra-gNB reestablishment for UE${ue_id} to NRCell-2
    Expect Message Flow
    ...     UE_${ue_id}:NR-RRC_RRCReestablishmentRequest
    ...     UE_${ue_id}:NR-RRC_RRCReestablishment
    ...     UE_${ue_id}:NR-RRC_RRCReestablishmentComplete
    ...     UE_${ue_id}:NR-RRC_RRCReconfiguration
    ...     UE_${ue_id}:NR-RRC_RRCReconfigurationComplete
    ...     alias=UE${ue_id}_RRC_reestablishment
    ...     overall_timeout=30

    Execute egate command  cmd=ue_rrc_reestablish id=1 gnb=2 cell=2

Verify that gNB sends RRC Reestablishment to UE${ue_id}
    Flow occurred as expected  alias=UE${ue_id}_RRC_reestablishment

Set UE1 reestablishment to fail by ignoring gNB2 RRC Reestablishment message
    Execute egate command  cmd=ue_rrc_reestablish_param id=1 if_contains=any action=drop

Trigger failed intra-gNB reestablishment for UE${ue_id} to NRCell-2
    Expect Message Flow
    ...     UE_${ue_id}:NR-RRC_RRCReestablishmentRequest
    ...     UE_${ue_id}:NR-RRC_RRCReestablishment
    ...     alias=UE${ue_id}_RRC_reestablishment_fail
    ...     overall_timeout=30

    Expect Message Flow
    ...     UE_${ue_id}:NR-RRC_RRCReestablishmentComplete
    ...     alias=UE${ue_id}_RRC_reestablishment_complete
    ...     overall_timeout=30

    Expect Message Flow
    ...     AMF1:NGAP_UEContextReleaseRequest as ue_contex_req
    ...     AMF1:NGAP_UEContextReleaseCommand
    ...     AMF1:NGAP_UEContextReleaseComplete
    ...     alias=UE${ue_id}_context_release
    ...     overall_timeout=30

    Execute egate command  cmd=ue_rrc_reestablish id=1 gnb=2 cell=2

Verify that UE${ue_id} reestablishment failed due to lack of RRC Reestablishment Complete
    Flow occurred as expected  alias=UE${ue_id}_RRC_reestablishment_fail
    Flow not occurred for message  alias=UE${ue_id}_RRC_reestablishment_complete

Verify that UE${ue_id} was released after reestablishment failure
    Flow occurred as expected  alias=UE${ue_id}_context_release

Set up HO for UE1
    Execute egate command  cmd=ue_history_information_list_add_ngran id=1 gnb_id=1 cell_type=medium nrcgi=311:489|0x01 time_ue_stayed_in_cell=100
    Execute egate command  cmd=ue_history_information_list_add_ngran id=1 gnb_id=2 cell_type=medium nrcgi=311:489|0x01 time_ue_stayed_in_cell=100
    Execute egate command  cmd=ue_history_information_list_add_ngran id=1 gnb_id=1 cell_type=medium nrcgi=311:489|0x02 time_ue_stayed_in_cell=100
    Execute egate command  cmd=ue_history_information_list_add_ngran id=1 gnb_id=2 cell_type=medium nrcgi=311:489|0x02 time_ue_stayed_in_cell=100
    Execute egate command  cmd=ue_history_information_list id=1 action=commit
    Execute egate command  cmd=ue_enb_param id=1 ue_history_list=1

Trigger inter-gNB handover to gNB3 NRCELL-31 for UE${ue_id}
    Expect Message Flow
    ...     gNB2:XNAP_HandoverRequest as HO_Req
    ...     gNB2:XNAP_HandoverRequestAcknowledge as HO_Req_Ack
    ...     gNB2:XNAP_SNStatusTransfer
    ...     alias=UE${ue_id}_Handover   overall_timeout=15

    Execute egate command  cmd=ue_measurement_send_nr id=1 meas_id=2 event=A3 srsrp_nr=19 srsrq_nr=10 phycell_id=52 nrsrp_nr=85 nrsrq_nr=31

Verify that UE${ue_id} inter gNB handover was successfull
    Flow occurred as expected  alias=UE${ue_id}_Handover

Trigger inter-RAT handover to eNB1 CELL_11 for UE${ue_id}
    Expect Message Flow
    ...     UE_${ue_id}:NR-RRC_RRCReconfiguration as RRCReconfiguration
    ...     UE_${ue_id}:NR-RRC_RRCReconfigurationComplete
    ...     alias=UE${ue_id}_A2_meas  overall_timeout=15

    Execute egate command  cmd=ue_measurement_send_nr id=${ue_id} meas_id=3 event=A2 srsrp_nr=19 srsrq_nr=10 phycell_id=11 nrsrp_nr=85 nrsrq_nr=31

    Flow occurred as expected  alias=UE${ue_id}_A2_meas
    Sleep  3
    Expect message flow
    ...    AMF1:NGAP_HandoverRequired
    ...    AMF1:NGAP_HandoverCommand
    ...    AMF1:NGAP_UEContextReleaseCommand
    ...    AMF1:NGAP_UEContextReleaseComplete
    ...    alias=UE_${ue_id}_interrat_ho  overall_timeout=15

    Execute egate command  cmd=ue_measurement_send_nr id=${ue_id} meas_id=7 event=B2 srsrp_nr=19 srsrq_nr=10 phycell_id=11 nrsrp_nr=85 nrsrq_nr=31

Verify that UE${ue_id} interRAT handover was successfull
    Flow occurred as expected  alias=UE_${ue_id}_interrat_ho
