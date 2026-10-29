"""
Global static variables for E1AP messages

:copyright:     Nokia Networks
:author:        Piotr Brzezicki
:maintainer:    Piotr Brzezicki
:contact:       piotr.brzezicki@nokia.com
:team:          VRF_KRK_T06
"""

from taf.rfrl.utilities.parsers.pcap_checker import AwaitedMessage, inspectors

BEARER_SETUP_REQ = AwaitedMessage(
    name='BearerContextSetupRequest',
    find_by=[inspectors.HasInspector('e1ap.BearerContextSetupRequest_element')],
    verify_by=[],
)

BEARER_SETUP_RESP = AwaitedMessage(
    name='BearerContextSetupResponse',
    find_by=[inspectors.HasInspector('e1ap.BearerContextSetupResponse_element')],
    verify_by=[],
)

BEARER_MOD_REQ = AwaitedMessage(
    name='BearerContextModificationRequest',
    find_by=[inspectors.HasInspector('e1ap.BearerContextModificationRequest_element')],
    verify_by=[],
)

BEARER_MOD_REQ_STOP = AwaitedMessage(
    name='BearerContextModificationRequest',
    find_by=[inspectors.HasInspector('e1ap.BearerContextModificationRequest_element')],
    verify_by=[
        inspectors.HasInspector('e1ap.cell_Group_ID', '0'),
        inspectors.HasInspector('e1ap.dL_TX_Stop', '0'),
        inspectors.HasInspector('e1ap.cell_Group_ID', '1'),
        inspectors.HasInspector('e1ap.dL_TX_Stop', '0'),
    ],
)

BEARER_MOD_REQ_RELEASE = AwaitedMessage(
    name='BearerContextModificationRequest',
    find_by=[inspectors.HasInspector('e1ap.BearerContextModificationRequest_element')],
    verify_by=[
        inspectors.HasInspector('e1ap.PDU_Session_Resource_To_Remove_Item_element'),
        inspectors.HasInspector('e1ap.radioNetwork', '20'),
    ],
)

BEARER_MOD_RESP = AwaitedMessage(
    name='BearerContextModificationResponse',
    find_by=[inspectors.HasInspector('e1ap.BearerContextModificationResponse_element')],
    verify_by=[],
)

BEARER_CONTEXT_INACTIVITY_NOTIFICATION_ACTIVE = AwaitedMessage(
    name='BearerContextInactivityNotification',
    find_by=[inspectors.HasInspector('e1ap.BearerContextInactivityNotification_element')],
    verify_by=[inspectors.HasInspector('e1ap.uE_Activity', '0')],
)

BEARER_CONTEXT_INACTIVITY_NOTIFICATION_PSCELLADD = AwaitedMessage(
    name='BearerContextInactivityNotification',
    find_by=[inspectors.HasInspector('e1ap.BearerContextInactivityNotification_element')],
    verify_by=[
        inspectors.HasInspector('e1ap.dRB_Activity_List'),
        inspectors.HasInspector('e1ap.dRB_ID', '1'),
        inspectors.HasInspector('e1ap.dRB_Activity', '0'),
    ],
)

BEARER_CONTEXT_INACTIVITY_NOTIFICATION_NOT_ACTIVE = AwaitedMessage(
    name='BearerContextInactivityNotification',
    find_by=[inspectors.HasInspector('e1ap.BearerContextInactivityNotification_element')],
    verify_by=[inspectors.HasInspector('e1ap.uE_Activity', '1')],
)

BEARER_REL_COMMAND_RADIO_NETWORK_NORMAL_RELEASE = AwaitedMessage(
    name='BearerContextReleaseCommand',
    find_by=[inspectors.HasInspector('e1ap.BearerContextReleaseCommand_element')],
    verify_by=[inspectors.HasInspector('e1ap.radioNetwork', '20')],
)

BEARER_REL_COMMAND_RADIO_NETWORK_UNSPECIFIED = AwaitedMessage(
    name='BearerContextReleaseCommand',
    find_by=[inspectors.HasInspector('e1ap.BearerContextReleaseCommand_element')],
    verify_by=[inspectors.HasInspector('e1ap.radioNetwork', '0')],
)

BEARER_REL_COMPLETE = AwaitedMessage(
    name='BearerContextReleaseComplete',
    find_by=[inspectors.HasInspector('e1ap.BearerContextReleaseComplete_element')],
    verify_by=[],
)

RESET_PARTIAL_TRANSPORT_UNSPECIFIED = AwaitedMessage(
    name='Reset',
    find_by=[inspectors.HasInspector('e1ap.Reset_element')],
    verify_by=[
        inspectors.HasInspector('e1ap.partOfE1_Interface'),
        inspectors.HasInspector('e1ap.transport', '0'),
    ],
)

RESET_PARTIAL_MISC_OM_INTERVENTION = AwaitedMessage(
    name='Reset',
    find_by=[inspectors.HasInspector('e1ap.Reset_element')],
    verify_by=[
        inspectors.HasInspector('e1ap.partOfE1_Interface'),
        inspectors.HasInspector('e1ap.misc', '3'),
    ],
)

RESET_ACK = AwaitedMessage(
    name='ResetAcknowledge',
    find_by=[inspectors.HasInspector('e1ap.ResetAcknowledge_element')],
    verify_by=[inspectors.HasInspector('e1ap.UE_associatedLogicalE1_ConnectionListResAck')],
)
