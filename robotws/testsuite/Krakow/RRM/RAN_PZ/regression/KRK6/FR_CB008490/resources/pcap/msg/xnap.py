"""
Global static variables for XNAP messages

:copyright:     Nokia Networks
:author:        Piotr Brzezicki
:maintainer:    Piotr Brzezicki
:contact:       piotr.brzezicki@nokia.com
:team:          VRF_KRK_T06
"""

from taf.rfrl.utilities.parsers.pcap_checker import AwaitedMessage, inspectors

SNODE_ADD_REQ_ALLOWED_BC = AwaitedMessage(
    name='SgNBAdditionRequest',
    find_by=[inspectors.HasInspector('xnap.SNodeAdditionRequest_element')],
    verify_by=[inspectors.HasInspector('nr-rrc.allowedBC_ListMRDC')],
)
SNODE_ADD_REQ_ACK = AwaitedMessage(
    name='SNodeAdditionRequestAcknowledge',
    find_by=[inspectors.HasInspector('xnap.SNodeAdditionRequestAcknowledge_element')],
    verify_by=[
        inspectors.HasInspector('nr-rrc.bandCombinationIndex'),
        inspectors.HasInspector('nr-rrc.requestedFeatureSets'),
    ],
)

SNODE_ADD_REQ_ACK_8CC = AwaitedMessage(
    name='SNodeAdditionRequestAcknowledge',
    find_by=[inspectors.HasInspector('xnap.SNodeAdditionRequestAcknowledge_element')],
    verify_by=[
        inspectors.HasInspector('nr-rrc.sCellIndex', '2'),
        inspectors.HasInspector('nr-rrc.sCellIndex', '3'),
        inspectors.HasInspector('nr-rrc.sCellIndex', '4'),
        inspectors.HasInspector('nr-rrc.sCellIndex', '5'),
        inspectors.HasInspector('nr-rrc.sCellIndex', '6'),
        inspectors.HasInspector('nr-rrc.sCellIndex', '7'),
        inspectors.HasInspector('nr-rrc.bandCombinationIndex'),
        inspectors.HasInspector('nr-rrc.requestedFeatureSets'),
    ],
)

XNU_ADDR_IND = AwaitedMessage(
    name='XnUAddressIndication',
    find_by=[inspectors.HasInspector('xnap.XnUAddressIndication_element')],
    verify_by=[],
)

SN_STATUS_TRANSFER = AwaitedMessage(
    name='SNStatusTransfer',
    find_by=[inspectors.HasInspector('xnap.SNStatusTransfer_element')],
    verify_by=[],
)

SNODE_RECONF_COMPLETE = AwaitedMessage(
    name='SNodeReconfigurationComplete',
    find_by=[inspectors.HasInspector('xnap.SNodeReconfigurationComplete_element')],
    verify_by=[],
)

SNODE_RELEASE_REQ = AwaitedMessage(
    name='SNodeReleaseRequest',
    find_by=[inspectors.HasInspector('xnap.SNodeReleaseRequest_element')],
    verify_by=[],
)

SNODE_REL_REQ_RADIO_NETWORK_NORMAL_RELEASE = AwaitedMessage(
    name='SNodeReleaseRequest',
    find_by=[inspectors.HasInspector('xnap.SNodeReleaseRequest_element')],
    verify_by=[inspectors.HasInspector('xnap.radioNetwork', '65')],
)

snode_rel_req_radio_network_radio_connection_with_ue_lost = AwaitedMessage(
    name='SNodeReleaseRequest',
    find_by=[inspectors.HasInspector('xnap.SNodeReleaseRequest_element')],
    verify_by=[inspectors.HasInspector('xnap.radioNetwork', '36')],
)

SNODE_REL_REQ_ACK = AwaitedMessage(
    name='SNodeReleaseRequestAcknowledge',
    find_by=[inspectors.HasInspector('xnap.SNodeReleaseRequestAcknowledge_element')],
    verify_by=[],
)

UE_CTX_REL = AwaitedMessage(
    name='UEContextRelease',
    find_by=[inspectors.HasInspector('xnap.UEContextRelease_element')],
    verify_by=[],
)

RESET_REQ_PARTIAL_MISC_OM_INTERVENTION = AwaitedMessage(
    name='ResetRequest',
    find_by=[inspectors.HasInspector('xnap.ResetRequest_element')],
    verify_by=[
        inspectors.HasInspector('xnap.partialReset_element'),
        inspectors.HasInspector('xnap.misc', '2'),
    ],
)

RESET_RESP_PARTIAL_MISC_OM_INTERVENTION = AwaitedMessage(
    name='ResetRequest',
    find_by=[inspectors.HasInspector('xnap.ResetResponse_element')],
    verify_by=[inspectors.HasInspector('xnap.partialReset_element')],
)

ACTIVITY_NOTIFICATION_INACTIVE = AwaitedMessage(
    name='ActivityNotification',
    find_by=[inspectors.HasInspector('xnap.ActivityNotification_element')],
    verify_by=[inspectors.HasInspector('xnap.UserPlaneTrafficActivityReport', '0')],
)

ACTIVITY_NOTIFICATION_REACTIVATED = AwaitedMessage(
    name='ActivityNotification',
    find_by=[inspectors.HasInspector('xnap.ActivityNotification_element')],
    verify_by=[inspectors.HasInspector('xnap.UserPlaneTrafficActivityReport', '1')],
)

SNODE_MODIFICATION_REQ = AwaitedMessage(
    name='SNodeModificationRequired',
    find_by=[inspectors.HasInspector('xnap.SNodeModificationRequired_element')],
    verify_by=[],
)
