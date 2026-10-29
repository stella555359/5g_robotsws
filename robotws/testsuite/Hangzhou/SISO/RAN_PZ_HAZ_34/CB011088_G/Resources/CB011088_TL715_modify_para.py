# -*- coding: utf-8 -*
import os
from robot.libraries.BuiltIn import BuiltIn

tl = BuiltIn().get_variable_value("${tl}")
CFG_DIR = os.path.dirname(os.path.abspath(__file__))

NRBTS_ID = (
    "MRBTS-" + str(tl.gnbs[0].instance_id) + "/NRBTS-" + str(tl.gnbs[0].instance_id)
)
MRBTS_NRDU = NRBTS_ID + "/NRDU-1"
GNB_NRCELL_ID = NRBTS_ID + "/NRCELL-"
GNB_SMOD_SFP = (
    "MRBTS-" + str(tl.gnbs[0].instance_id) + "/EQM-1/APEQM-1/CABINET-1/SMOD-1"
)
ALARM_RU_NAME = (
    "[TL726" + "] MRBTS-" + str(tl.gnbs[0].instance_id) + "/EQM-1/APEQM-1/RMOD-"
)
SMOD_TYPE = (
    "MRBTS-" + str(tl.gnbs[0].instance_id) + "/EQM-1/APEQM-1/CABINET-1/SMOD-1/BBCAP-1"
)
# modify parameter
gnb_para1 = [
    dict(
        dist_name=SMOD_TYPE,
        parameter="smodBoardConfigType",
        value="Auto",
        operation="update",
    ),
    dict(
        dist_name=MRBTS_NRDU,
        parameter="flexibleCAMode",
        value="ConfigurationIndependent",
        operation="update",
    ),
    dict(
        dist_name=MRBTS_NRDU,
        parameter="carrierAggregationSupportList",
        value=["ca_Fr1Tdd_Sa", "ca_Fr1Tdd_Fdd_Sa", "ca_Fr1Tdd_Any_Sa"],
        operation="update",
    ),
    dict(
        dist_name=MRBTS_NRDU,
        parameter="actNonBfAndBfCa",
        value="true",
        operation="update",
    ),
    dict(
        dist_name=MRBTS_NRDU,
        parameter="actInterNumerologyCa",
        value="true",
        operation="update",
    ),
    dict(
        dist_name=MRBTS_NRDU,
        parameter="actConnectedModeMobilityCA",
        value="true",
        operation="update",
    ),
    dict(
        dist_name=NRBTS_ID,
        parameter="sCellActivationMethod",
        value="blind",
        operation="update",
    ),
    dict(
        dist_name=GNB_NRCELL_ID + "1",
        parameter="sCellDeactivationTimerGNB",
        value="infinity",
        operation="update",
    ),
    dict(
        dist_name=GNB_NRCELL_ID + "4",
        parameter="sCellDeactivationTimerGNB",
        value="infinity",
        operation="update",
    ),
    dict(
        dist_name=GNB_NRCELL_ID + "1",
        parameter="allowUnsuppBcOrBcs",
        value=["accept unknown band combinations"],
        operation="update",
    ),
    dict(
        dist_name=GNB_NRCELL_ID + "4",
        parameter="allowUnsuppBcOrBcs",
        value=["accept unknown band combinations"],
        operation="update",
    ),
    dict(
        dist_name=GNB_NRCELL_ID + "4",
        parameter="chBw",
        value="50MHz",
        operation="update",
    ),
    dict(
        dist_name=NRBTS_ID,
        parameter="actSlowPrbPooling",
        value="false",
        operation="update",
    ),
    dict(
        dist_name=NRBTS_ID,
        parameter="actOverheatingAssistance",
        value="false",
        operation="update",
    ),
    dict(
        dist_name=GNB_NRCELL_ID + "1" + "/NRREL-1",
        parameter="sCellAdditionMethod",
        value="blind",
        operation="update",
    ),
    dict(
        dist_name=GNB_NRCELL_ID + "1" + "/NRREL-1",
        parameter="sCellOperationalMode",
        value="dlOnly",
        operation="update",
    ),
    dict(
        dist_name=GNB_NRCELL_ID + "4",
        parameter="nrarfcn",
        value="524820",
        operation="update",
    ),
    dict(
        dist_name=GNB_NRCELL_ID + "4",
        parameter="cellBwpList",
        value=[
            {
                "bwpDN": "MRBTS-37485/NRBTS-37485/BWP_PROFILE-4",
                "cellBwpId": "0",
                "actPdcchCceFragmentControl": "false",
                "actUpperThrAckNackFiltering": "false",
                "actUpperThrAckNackHrFiltering": "false",
                "pdcchResourcePreference": "peakRate",
            },
            {
                "bwpDN": "MRBTS-37485/NRBTS-37485/BWP_PROFILE-88",
                "cellBwpId": "1",
                "actPdcchCceFragmentControl": "false",
                "actUpperThrAckNackFiltering": "false",
                "actUpperThrAckNackHrFiltering": "false",
                "pdcchBlockingThresholdDL": "30",
                "pdcchBlockingThresholdUL": "30",
                "pdcchFreeThresholdDL": "50",
                "pdcchFreeThresholdUL": "50",
                "pdcchResourcePreference": "peakRate",
            },
        ],
        operation="update",
    ),
    dict(
        dist_name=GNB_NRCELL_ID + "1",
        parameter="cellBwpList",
        value=[
            {
                "bwpDN": "MRBTS-37485/NRBTS-37485/BWP_PROFILE-8",
                "cellBwpId": "0",
                "actPdcchCceFragmentControl": "false",
                "actUpperThrAckNackFiltering": "false",
                "actUpperThrAckNackHrFiltering": "false",
                "pdcchResourcePreference": "peakRate",
            },
            {
                "bwpDN": "MRBTS-37485/NRBTS-37485/BWP_PROFILE-82",
                "cellBwpId": "1",
                "actPdcchCceFragmentControl": "false",
                "actUpperThrAckNackFiltering": "false",
                "actUpperThrAckNackHrFiltering": "false",
                "pdcchBlockingThresholdDL": "30",
                "pdcchBlockingThresholdUL": "30",
                "pdcchFreeThresholdDL": "50",
                "pdcchFreeThresholdUL": "50",
                "pdcchResourcePreference": "peakRate",
            },
        ],
        operation="update",
    ),
]

vonr_fiveQI_1 = [
    dict(
        xpath="PDUSessionResourceModifyRequest/PDUSessionResourceModifyRequestTransfer",
        expected_value={"fiveQI": "1"},
        n="1",
    )
]

vonr_setup_message_flow = dict(
    order_list=[
        "PDUSessionResourceModifyRequest",
        "rrcReconfiguration",
        "rrcReconfigurationComplete",
        "PDUSessionResourceModifyResponse",
    ]
)

attached_pci_90 = [
    dict(
        xpath="UEContextModificationResponse/spCellConfig/spCellConfigCommon",
        expected_value={"physCellId": "90"},
        n="1",
    )
]

attached_pci_91 = [
    dict(
        xpath="UEContextModificationResponse/spCellConfig/spCellConfigCommon",
        expected_value={"physCellId": "91"},
        n="1",
    )
]

attached_pci_92 = [
    dict(
        xpath="UEContextModificationResponse/spCellConfig/spCellConfigCommon",
        expected_value={"physCellId": "92"},
        n="1",
    )
]

attached_pci_93 = [
    dict(
        xpath="UEContextModificationResponse/spCellConfig/spCellConfigCommon",
        expected_value={"physCellId": "93"},
        n="1",
    )
]

attached_pci_94 = [
    dict(
        xpath="UEContextModificationResponse/spCellConfig/spCellConfigCommon",
        expected_value={"physCellId": "94"},
        n="1",
    )
]

attached_scell_94 = [
    dict(
        xpath="UEContextModificationResponse/SCellConfig/sCellConfigCommon",
        expected_value={"physCellId": "94"},
        n="1",
    )
]

para_NRREL = [
    dict(
        dist_name=GNB_NRCELL_ID + "1" + "/NRREL-1",
        parameter="lcrId",
        value="3",
        operation="update",
    ),
]

para_NRREL1 = [
    dict(
        dist_name=GNB_NRCELL_ID + "1" + "/NRREL-1",
        parameter="lcrId",
        value="0",
        operation="update",
    ),
]

gnb_para1_lock = [
    dict(
        dist_name=GNB_SMOD_SFP + "/SFP-9/LANE-1",
        parameter="administrativeState",
        value="Locked",
        operation="update",
    ),
    dict(
        dist_name=GNB_SMOD_SFP + "/SFP-10/LANE-1",
        parameter="administrativeState",
        value="Locked",
        operation="update",
    ),
    dict(
        dist_name=GNB_SMOD_SFP + "/SFP-11/LANE-1",
        parameter="administrativeState",
        value="Locked",
        operation="update",
    ),
    dict(
        dist_name=GNB_SMOD_SFP + "/SFP-12/LANE-1",
        parameter="administrativeState",
        value="Locked",
        operation="update",
    ),
]

gnb_para1_unlock = [
    dict(
        dist_name=GNB_SMOD_SFP + "/SFP-9/LANE-1",
        parameter="administrativeState",
        value="Unlocked",
        operation="update",
    ),
    dict(
        dist_name=GNB_SMOD_SFP + "/SFP-10/LANE-1",
        parameter="administrativeState",
        value="Unlocked",
        operation="update",
    ),
    dict(
        dist_name=GNB_SMOD_SFP + "/SFP-11/LANE-1",
        parameter="administrativeState",
        value="Unlocked",
        operation="update",
    ),
    dict(
        dist_name=GNB_SMOD_SFP + "/SFP-12/LANE-1",
        parameter="administrativeState",
        value="Unlocked",
        operation="update",
    ),
]
