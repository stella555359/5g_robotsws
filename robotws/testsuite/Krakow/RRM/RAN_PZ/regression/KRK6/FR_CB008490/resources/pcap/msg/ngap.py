"""
Global static variables for NGAP messages

:copyright:     Nokia Networks
:author:        Piotr Brzezicki
:maintainer:    Piotr Brzezicki
:contact:       piotr.brzezicki@nokia.com
:team:          VRF_KRK_T06
"""

from taf.rfrl.utilities.parsers.pcap_checker import AwaitedMessage, inspectors

INITIAL_UE_MESSAGE_REGISTRATION_REQUEST_NRCELLID = AwaitedMessage(
    name='InitialUEMessage',
    find_by=[inspectors.HasInspector('ngap.InitialUEMessage_element')],
    verify_by=[
        inspectors.HasInspector('nas_5gs.mm.message_type', '0x41'),
        inspectors.HasInspector('ngap.NRCellIdentity', '%s'),
    ],
)

INITIAL_UE_MESSAGE_NRCELLID = AwaitedMessage(
    name='InitialUEMessage',
    find_by=[inspectors.HasInspector('ngap.InitialUEMessage_element')],
    verify_by=[inspectors.HasInspector('ngap.NRCellIdentity', '%s')],
)

ICS_SETUP_REQ_PDU_SESSION = AwaitedMessage(
    name='InitialContextSetupRequest',
    find_by=[inspectors.HasInspector('ngap.InitialContextSetupRequest_element')],
    verify_by=[inspectors.HasInspector('ngap.PDUSessionResourceSetupListCxtReq')],
)

ICS_SETUP_RESP_PDU_SESSION = AwaitedMessage(
    name='InitialContextSetupResponse',
    find_by=[inspectors.HasInspector('ngap.InitialContextSetupResponse_element')],
    verify_by=[inspectors.HasInspector('ngap.PDUSessionResourceSetupListCxtRes')],
)

PDU_SESSION_RES_MOD_IND = AwaitedMessage(
    name='PDUSessionResourceModifyIndication',
    find_by=[inspectors.HasInspector('ngap.PDUSessionResourceModifyIndication_element')],
    verify_by=[],
)

PDU_SESSION_RES_MOD_CONFIRM = AwaitedMessage(
    name='PDUSessionResourceModifyConfirm',
    find_by=[inspectors.HasInspector('ngap.PDUSessionResourceModifyConfirm_element')],
    verify_by=[],
)

PDU_SESSION_RES_REL_COMMAND = AwaitedMessage(
    name='PDUSessionResourceReleaseCommand',
    find_by=[inspectors.HasInspector('ngap.PDUSessionResourceReleaseCommand_element')],
    verify_by=[
        inspectors.HasInspector('ngap.nas', '0'),
        inspectors.HasInspector('ngap.pDUSessionID', '2'),
    ],
)

PDU_SESSION_RES_REL_RESPONSE = AwaitedMessage(
    name='PDUSessionResourceReleaseResponse',
    find_by=[inspectors.HasInspector('ngap.PDUSessionResourceReleaseResponse_element')],
    verify_by=[inspectors.HasInspector('ngap.pDUSessionID', '2')],
)

UE_CTX_REL_REQ = AwaitedMessage(
    name='UEContextReleaseCommand',
    find_by=[inspectors.HasInspector('ngap.UEContextReleaseCommand_element')],
    verify_by=[],
)

UE_CTX_REL_REQ_RADIO_CONNECTION_WITH_UE_LOST = AwaitedMessage(
    name='UEContextReleaseCommand',
    find_by=[inspectors.HasInspector('ngap.UEContextReleaseCommand_element')],
    verify_by=[inspectors.HasInspector('ngap.radioNetwork', '21')],
)

UE_CTX_REL_REQ_RELEASE_DUE_TO_CN_DETECTED_MOBILITY = AwaitedMessage(
    name='UEContextReleaseCommand',
    find_by=[inspectors.HasInspector('ngap.UEContextReleaseCommand_element')],
    verify_by=[inspectors.HasInspector('ngap.radioNetwork', '44')],
)

UE_CTX_REL_REQ_NAS_DEREGISTER = AwaitedMessage(
    name='UEContextReleaseCommand',
    find_by=[inspectors.HasInspector('ngap.UEContextReleaseCommand_element')],
    verify_by=[inspectors.HasInspector('ngap.nas', '2')],
)

UE_CTX_RELEASE_COMPLETE = AwaitedMessage(
    name='UEContextReleaseComplete',
    find_by=[inspectors.HasInspector('ngap.UEContextReleaseComplete_element')],
    verify_by=[],
)

NG_RESET_RESP_PARTIAL_MISC_OM_INTERVENTION = AwaitedMessage(
    name='ResetRequest',
    find_by=[inspectors.HasInspector('ngap.NGReset_element')],
    verify_by=[
        inspectors.HasInspector('ngap.partOfNG_Interface'),
        inspectors.HasInspector('ngap.radioNetwork', '3'),
    ],
)

NG_RESET_ACK = AwaitedMessage(
    name='NGResetAcknowledge',
    find_by=[inspectors.HasInspector('ngap.NGResetAcknowledge_element')],
    verify_by=[inspectors.HasInspector('ngap.UE_associatedLogicalNG_connectionList')],
)
