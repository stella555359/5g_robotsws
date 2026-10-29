"""
Global static variables for F1AP messages

:copyright:     Nokia Networks
:author:        Piotr Brzezicki
:maintainer:    Piotr Brzezicki
:contact:       piotr.brzezicki@nokia.com
:team:          VRF_KRK_T06
"""

from taf.rfrl.utilities.parsers.pcap_checker import AwaitedMessage, inspectors

UE_CTX_SETUP_REQ = AwaitedMessage(
    name='UEContextSetupRequest',
    find_by=[inspectors.HasInspector('f1ap.UEContextSetupRequest_element')],
    verify_by=[],
)

UE_CTX_SETUP_REQ_8CC = AwaitedMessage(
    name='UEContextSetupRequest',
    find_by=[inspectors.HasInspector('f1ap.UEContextSetupRequest_element')],
    verify_by=[
        inspectors.HasInspector('f1ap.SCell_ToBeSetup_List', '7'),
        inspectors.HasInspector('nr-rrc.allowedBC_ListMRDC', '1'),
    ],
)

UE_CTX_SETUP_RESP = AwaitedMessage(
    name='UEContextSetupResponse',
    find_by=[inspectors.HasInspector('f1ap.UEContextSetupResponse_element')],
    verify_by=[],
)

UE_CTX_SETUP_RESP_8CC = AwaitedMessage(
    name='UEContextSetupResponse',
    find_by=[inspectors.HasInspector('f1ap.UEContextSetupResponse_element')],
    verify_by=[
        inspectors.HasInspector('f1ap.SelectedBandCombinationIndex'),
        inspectors.HasInspector('f1ap.SelectedFeatureSetEntryIndex'),
        inspectors.HasInspector('nr-rrc.sCellToAddModList', '7'),
    ],
)

UE_CTX_MOD_REQ = AwaitedMessage(
    name='UEContextModificationRequest',
    find_by=[inspectors.HasInspector('f1ap.UEContextModificationRequest_element')],
    verify_by=[],
)

UE_CTX_MOD_REQ_ALLOWEDBC_LISTMRDC = AwaitedMessage(
    name='UEContextModificationRequest',
    find_by=[inspectors.HasInspector('f1ap.UEContextModificationRequest_element')],
    verify_by=[inspectors.HasInspector('nr-rrc.allowedBC_ListMRDC')],
)

UE_CTX_MOD_REQ_SCG_RELEASE = AwaitedMessage(
    name='UEContextModificationRequest',
    find_by=[inspectors.HasInspector('f1ap.UEContextModificationRequest_element')],
    verify_by=[inspectors.HasInspector('f1ap.SCGIndicator', '0')],
)

UE_CTX_MOD_REQ_RRC_RECONFIG_COMPLETE_IND = AwaitedMessage(
    name='UEContextModificationRequest',
    find_by=[inspectors.HasInspector('f1ap.UEContextModificationRequest_element')],
    verify_by=[inspectors.HasInspector('f1ap.RRCReconfigurationCompleteIndicator', '0')],
)

UE_CTX_MOD_REQ_DU_CONFIG_QUERY = AwaitedMessage(
    name='UEContextModificationRequest',
    find_by=[inspectors.HasInspector('f1ap.UEContextModificationRequest_element')],
    verify_by=[inspectors.HasInspector('f1ap.GNB_DUConfigurationQuery', '0')],
)

UE_CTX_MOD_RESP = AwaitedMessage(
    name='UEContextModificationResponse',
    find_by=[inspectors.HasInspector('f1ap.UEContextModificationResponse_element')],
    verify_by=[],
)

UE_CTX_MOD_RESP_BC_IDX_FS_IDX = AwaitedMessage(
    name='UEContextModificationResponse',
    find_by=[inspectors.HasInspector('f1ap.UEContextModificationResponse_element')],
    verify_by=[
        inspectors.HasInspector('f1ap.SelectedBandCombinationIndex'),
        inspectors.HasInspector('f1ap.SelectedFeatureSetEntryIndex'),
    ],
)

UE_CTX_MOD_RESP_DUTOCURRCINFO = AwaitedMessage(
    name='UEContextModificationResponse',
    find_by=[inspectors.HasInspector('f1ap.DUtoCURRCInformation_element')],
    verify_by=[],
)

UE_CTX_MOD_REQ_STOP = AwaitedMessage(
    name='UEContextModificationRequest',
    find_by=[inspectors.HasInspector('f1ap.UEContextModificationRequest_element')],
    verify_by=[inspectors.HasInspector('f1ap.TransmissionActionIndicator', '0')],
)

UE_CTX_REL_COMMAND_RADIO_NETWORK_NORMAL_RELEASE = AwaitedMessage(
    name='UEContextReleaseCommand',
    find_by=[inspectors.HasInspector('f1ap.UEContextReleaseCommand_element')],
    verify_by=[inspectors.HasInspector('f1ap.radioNetwork', '10')],
)

UE_CTX_REL_COMMAND_RADIO_NETWORK_UNSPECIFIED = AwaitedMessage(
    name='UEContextReleaseCommand',
    find_by=[inspectors.HasInspector('f1ap.UEContextReleaseCommand_element')],
    verify_by=[inspectors.HasInspector('f1ap.radioNetwork', '0')],
)

UE_CTX_REL_COMPLETE = AwaitedMessage(
    name='UEContextReleaseComplete',
    find_by=[inspectors.HasInspector('f1ap.UEContextReleaseComplete_element')],
    verify_by=[],
)

RESET_PARTIAL_TRANSPORT_UNSPECIFIED = AwaitedMessage(
    name='Reset',
    find_by=[inspectors.HasInspector('f1ap.Reset_element')],
    verify_by=[
        inspectors.HasInspector('f1ap.partOfF1_Interface'),
        inspectors.HasInspector('f1ap.transport', '0'),
    ],
)

RESET_PARTIAL_MISC_OM_INTERVENTION = AwaitedMessage(
    name='Reset',
    find_by=[inspectors.HasInspector('f1ap.Reset_element')],
    verify_by=[
        inspectors.HasInspector('f1ap.partOfF1_Interface'),
        inspectors.HasInspector('f1ap.misc', '3'),
    ],
)

RESET_ACK = AwaitedMessage(
    name='ResetAcknowledge',
    find_by=[inspectors.HasInspector('f1ap.ResetAcknowledge_element')],
    verify_by=[inspectors.HasInspector('f1ap.UE_associatedLogicalF1_ConnectionListResAck')],
)
