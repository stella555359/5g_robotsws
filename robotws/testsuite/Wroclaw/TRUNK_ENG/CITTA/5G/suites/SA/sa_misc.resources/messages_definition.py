NGAP_MESSAGES = [
    {
        "name": "Initial Context Setup Request",
        "filter": "ngap.InitialContextSetupRequest_element"
    },
    {
        "name": "Initial Context Setup Response",
        "filter": "ngap.InitialContextSetupResponse_element",
    },
    {
        "name": "MRL element",
        "filter": "ngap.MobilityRestrictionList_element"
    }
]

XNAP_MESSAGES = [
    {
        "name": "XnAP Setup Request Element",
        "filter": "xnap.XnSetupRequest_element"
    },
    {
        "name": "XnAP Setup Response Element",
        "filter": "xnap.XnSetupResponse_element",
    },
    {
        "name": "5GC Mobility Restriction List Container",
        "filter": "xnap.FiveGCMobilityRestrictionListContainer"
    }
]

NAS_DL_MESSAGES = [
    {
        "name": "DownlinkNASTransport",
        "filter": "(nas_5gs.msg_auth_code) && "
                  "(ngap.DownlinkNASTransport_element) && (nas_5gs.security_header_type == 2)",
    },
    {
        "name": "DownlinkRRCInformationTransfer",
        "filter": "(nas_5gs.msg_auth_code) "
                  "&& (nr-rrc.dlInformationTransfer_element) && (nas_5gs.security_header_type == 2)",
    },
    {
        "name": "DownlinkRRCMessagesTransfer",
        "filter": "(nas-5gs) && (ngap.InitialUEMessage_element)"
    }
]

NAS_UL_MESSAGES = [
    {
        "name": "UplinkNASTransport",
        "filter": "(nas_5gs.msg_auth_code) && (ngap.UplinkNASTransport_element)"
    },
    {
        "name": "ULInformationTransfer/AutenticationNASMessage",
        "filter": "(nas_5gs.mm.message_type == 0x57) && (ngap.NGAP_PDU == 0)",
    },
    {
        "name": "ULInformationTransfer/RegistrationNASMessage",
        "filter": "(nas_5gs.mm.message_type == 0x43) && (ngap.NGAP_PDU == 0)"
    }
]
