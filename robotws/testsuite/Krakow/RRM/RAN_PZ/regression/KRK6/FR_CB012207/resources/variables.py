"""
This file contains variables used in verification of CB012207.

:copyright: Nokia Networks
:author:   Kamil Bielecki <kamil.bielecki@nokia.com>
:maintainer:   Kamil Bielecki <kamil.bielecki@nokia.com>
"""

delta_shuttingdown = [{"distName": "MRBTS-{}/NRBTS-{}/NRCELL-270",
                       "operation": "update",
                       "parameters": [{"parameterName": "administrativeState",
                                       "value": "Shutting Down",
                                       "operation": "update"}]}]

ng_ho_shutdown_0 = [{"distName": "MRBTS-{}/NRBTS-{}/NRCELL-260", "operation": "update",
                     "parameters": [{"parameterName": "a5MeasSsbRsrp",
                                     "value": [{"a5Threshold1SsbRsrp": "125", "a5Threshold2SsbRsrp": "90",
                                                "a5HysteresisSsbRsrp": "0", "a5TimeToTriggerSsbRsrp": "ms5120"}],
                                     "operation": "update"},
                                    ]},
                    ]

ng_ho_shutdown_1 = [{"distName": "MRBTS-{}/NRBTS-{}/NRCELL-270", "operation": "update",
                     "parameters": [{"parameterName": "a5MeasSsbRsrp",
                                     "value": [{"a5Threshold1SsbRsrp": "113", "a5Threshold2SsbRsrp": "90",
                                                "a5HysteresisSsbRsrp": "0", "a5TimeToTriggerSsbRsrp": "ms5120"}],
                                     "operation": "update"},
                                    ]},
                    ]

full_rrc_reconfiguration_enable_gnb0 = [{"distName": "MRBTS-{}/NRBTS-{}",
                                         "operation": "update",
                                         "parameters": [{"parameterName": "actForceFullRRCConfigurationSaHo",
                                                         "value": "enabled",
                                                         "operation": "update"}]}]

full_rrc_reconfiguration_disable_gnb0 = [{"distName": "MRBTS-{}/NRBTS-{}",
                                          "operation": "update",
                                          "parameters": [{"parameterName": "actForceFullRRCConfigurationSaHo",
                                                          "value": "disabled",
                                                          "operation": "update"}]}]

full_rrc_reconfiguration_enable_gnb1 = [{"distName": "MRBTS-{}/NRBTS-{}",
                                         "operation": "update",
                                         "parameters": [{"parameterName": "actForceFullRRCConfigurationSaHo",
                                                         "value": "enabled",
                                                         "operation": "update"}]}]

full_rrc_reconfiguration_disable_gnb1 = [{"distName": "MRBTS-{}/NRBTS-{}",
                                          "operation": "update",
                                          "parameters": [{"parameterName": "actForceFullRRCConfigurationSaHo",
                                                          "value": "disabled",
                                                          "operation": "update"}]}]

initial_ue_message_nrcellid = """
    InitialUEMessage is RegistrationRequest {
        findBy { has(ngap.InitialUEMessage_element) }
        verifyBy { has(ngap.NRCellIdentity:=%s) }}
"""

ics_setup_req_pdu_session = """
    InitialContextSetupRequest has PDU Session {
        findBy { has(ngap.InitialContextSetupRequest_element) }
        verifyBy { has(ngap.PDUSessionResourceSetupListCxtReq) }}
"""

ics_setup_resp_pdu_session = """
    InitialContextSetupResponse has PDU Session {
        findBy { has(ngap.InitialContextSetupResponse_element) }
        verifyBy { has(ngap.PDUSessionResourceSetupListCxtRes) }}
"""

ue_ctx_rel_req = """
    UEContextReleaseCommand {
        findBy { has(ngap.UEContextReleaseCommand_element) }}
"""

ng_ho_request = """
    HandoverRequest with Cause radioNetwork: handover-desirable-for-radio-reason {
        findBy { has(ngap.HandoverRequest_element) }}
"""

ng_ho_notify = """
    HandoverNotify {
        findBy { has(ngap.HandoverNotify_element) }}
"""

xn_ho_request = """
    HandoverRequest with Cause radioNetwork: handover-desirable-for-radio-reasons {
        findBy { has(xnap.HandoverRequest_element) }}
"""

xn_ho_path_switch_request = """
    PathSwitchRequest {
        findBy { has(ngap.PathSwitchRequest_element) }}
"""

ecid_initiation_request = """
    DownlinkUEAssociatedNRPPaTransport {
        findBy { has(nrppa.E_CIDMeasurementInitiationRequest_element) }
        verifyBy { has(nrppa.ReportCharacteristics:=0)
                   has(nrppa.measurementQuantitiesValue:=11) }}
"""

ecid_initiation_response = """
    UplinkUEAssociatedNRPPaTransport {
        findBy { has(nrppa.E_CIDMeasurementInitiationResponse_element) }
        verifyBy { has(nrppa.NR_TADV) }}
"""
