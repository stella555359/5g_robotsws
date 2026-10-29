import os

__team__ = "MN 5G RAN I&V 4 Pz HZG SG1"
__email__ = "I_MN_5G_RAN_IV4_LINE_HZG_1@internal.nsn.com"

PARAMS_TO_DELETE_1473_90M_SA = [
    dict(
        dist_name="MRBTS-1914/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-5"
    ),
    dict(
        dist_name="MRBTS-1914/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-6"
    ),
    dict(
        dist_name="MRBTS-1914/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-7"
    ),
    dict(
        dist_name="MRBTS-1914/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-8"
    ),
    dict(dist_name="MRBTS-1914/NRBTS-14/NRCELL-2", p_name="configuredEpsTac"),
]

PARAMS_TO_MODIFY_1473_90M_SA = [
    dict(value="cOAM_SA_AZQG_TL014", dist_name="MRBTS-1914", p_name="btsName"),
    dict(value="90MHz", dist_name="MRBTS-1914/NRBTS-14/NRCELL-2", p_name="chBw"),
    dict(value="SA", dist_name="MRBTS-1914/NRBTS-14/NRCELL-2", p_name="cellDepType"),
    dict(value="false", dist_name="MRBTS-1914/NRBTS-14/NRCELL-2", p_name="actDl256Qam"),
    dict(value="SA", dist_name="MRBTS-1914/NRBTS-14", p_name="gNbCuType"),
    dict(value="0", dist_name="MRBTS-1914/NRBTS-14", p_name="x2LinkSupervisionTmr"),
    dict(value="2DL2UL", dist_name="MRBTS-1914/NRBTS-14/NRCELL-2", p_name="nrCellType"),
    dict(
        value="2x2 Open Loop Spatial Multiplexing",
        dist_name="MRBTS-1914/NRBTS-14/NRCELL-2",
        p_name="dlMimoMode",
    ),
    dict(
        value="false",
        dist_name="MRBTS-1914/NRBTS-14",
        p_name="actFdmEnhancedScheduling",
    ),
    dict(
        value="false", dist_name="MRBTS-1914/NRBTS-14/NRCELL-2", p_name="actBeamforming"
    ),
]

TL_ADD_MOS_1473_90M_SA = []

TL_LIST_PARAMS_TO_MODIFY_1473_90M_SA = []

TL_LIST_TO_ADD_1473_90M_SA = []

PARAMS_TO_DELETE_1473_90M_NSA = [
    dict(dist_name="MRBTS-1914/NRBTS-14/TRACKINGAREA-210", list_name="snssaiDNList"),
    dict(dist_name="MRBTS-1914/NRBTS-14/NRSYSINFO_PROFILE-1/NRLIM-1"),
    dict(dist_name="MRBTS-1914/NRBTS-14/NRCELL-2", p_name="trackingAreaDN"),
]

PARAMS_TO_MODIFY_1473_90M_NSA = [
    dict(value="cOAM_NSA_AZQG_TL014", dist_name="MRBTS-1914", p_name="btsName"),
    dict(value="90MHz", dist_name="MRBTS-1914/NRBTS-14/NRCELL-2", p_name="chBw"),
    dict(value="NSA", dist_name="MRBTS-1914/NRBTS-14", p_name="gNbCuType"),
    dict(
        value="false", dist_name="MRBTS-1914/NRBTS-14", p_name="actSACallProcessingDU"
    ),
    dict(value="NSA", dist_name="MRBTS-1914/NRBTS-14/NRCELL-2", p_name="cellDepType"),
]

TL_ADD_MOS_1473_90M_NSA = []

TL_LIST_PARAMS_TO_MODIFY_1473_90M_NSA = []

TL_LIST_TO_ADD_1473_90M_NSA = []

PARAMS_TO_DELETE_1473_90M_SA_256QAM = [
    dict(dist_name="MRBTS-1914/NRBTS-14/NRCELL-2", p_name="configuredEpsTac"),
]

PARAMS_TO_MODIFY_1473_90M_SA_256QAM = [
    dict(value="cOAM_SA_AZQG_TL014", dist_name="MRBTS-1914", p_name="btsName"),
    dict(value="90MHz", dist_name="MRBTS-1914/NRBTS-14/NRCELL-2", p_name="chBw"),
    dict(value="SA", dist_name="MRBTS-1914/NRBTS-14/NRCELL-2", p_name="cellDepType"),
    dict(value="SA", dist_name="MRBTS-1914/NRBTS-14", p_name="gNbCuType"),
    dict(value="0", dist_name="MRBTS-1914/NRBTS-14", p_name="x2LinkSupervisionTmr"),
    dict(value="true", dist_name="MRBTS-1914/NRBTS-14/NRCELL-2", p_name="actDl256Qam"),
]

PARAMS_TO_DELETE_1473_90M_SA_4layer = [
    # NRBTS/NRCELL
    dict(dist_name="MRBTS-1914/NRBTS-14/NRCELL-2", p_name="configuredEpsTac"),
    dict(dist_name="MRBTS-1914/NRBTS-14/NRCELL-2", list_name="fPdcchMonOccsnPo"),
]

PARAMS_TO_ADD_MOS_1473_90M_SA_4layer = [
    # SISO Configuration ANTL(cell1)
    dict(
        class_name="com.nokia.srbts.eqm:ANTL",
        dist_name="MRBTS-1914/EQM-1/APEQM-1/RMOD-1/ANTL-3",
        version="EQM20A_2003_002",
    ),
    dict(
        class_name="com.nokia.srbts.eqm:ANTL",
        dist_name="MRBTS-1914/EQM-1/APEQM-1/RMOD-1/ANTL-4",
        version="EQM20A_2003_002",
    ),
    dict(
        class_name="com.nokia.srbts.eqm:ANTL",
        dist_name="MRBTS-1914/EQM-1/APEQM-1/RMOD-1/ANTL-5",
        version="EQM20A_2003_002",
    ),
    dict(
        class_name="com.nokia.srbts.eqm:ANTL",
        dist_name="MRBTS-1914/EQM-1/APEQM-1/RMOD-1/ANTL-6",
        version="EQM20A_2003_002",
    ),
    dict(
        class_name="com.nokia.srbts.eqm:ANTL",
        dist_name="MRBTS-1914/EQM-1/APEQM-1/RMOD-1/ANTL-7",
        version="EQM20A_2003_002",
    ),
    dict(
        class_name="com.nokia.srbts.eqm:ANTL",
        dist_name="MRBTS-1914/EQM-1/APEQM-1/RMOD-1/ANTL-8",
        version="EQM20A_2003_002",
    ),
    # SISO Configuration CABLINK/LCELNR/CHANNELGROUP/CHANNEL(cell1)
    dict(
        class_name="com.nokia.srbts.mnl:CHANNEL",
        dist_name="MRBTS-1914/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-5",
        version="MNL5GC20A_2003_002",
    ),
    dict(
        class_name="com.nokia.srbts.mnl:CHANNEL",
        dist_name="MRBTS-1914/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-6",
        version="MNL5GC20A_2003_002",
    ),
    dict(
        class_name="com.nokia.srbts.mnl:CHANNEL",
        dist_name="MRBTS-1914/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-7",
        version="MNL5GC20A_2003_002",
    ),
    dict(
        class_name="com.nokia.srbts.mnl:CHANNEL",
        dist_name="MRBTS-1914/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-8",
        version="MNL5GC20A_2003_002",
    ),
    dict(
        class_name="com.nokia.srbts.mnl:CHANNEL",
        dist_name="MRBTS-1914/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-9",
        version="MNL5GC20A_2003_002",
    ),
    dict(
        class_name="com.nokia.srbts.mnl:CHANNEL",
        dist_name="MRBTS-1914/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-10",
        version="MNL5GC20A_2003_002",
    ),
    dict(
        class_name="com.nokia.srbts.mnl:CHANNEL",
        dist_name="MRBTS-1914/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-11",
        version="MNL5GC20A_2003_002",
    ),
    dict(
        class_name="com.nokia.srbts.mnl:CHANNEL",
        dist_name="MRBTS-1914/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-12",
        version="MNL5GC20A_2003_002",
    ),
    dict(
        class_name="com.nokia.srbts.mnl:CHANNEL",
        dist_name="MRBTS-1914/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-13",
        version="MNL5GC20A_2003_002",
    ),
    dict(
        class_name="com.nokia.srbts.mnl:CHANNEL",
        dist_name="MRBTS-1914/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-14",
        version="MNL5GC20A_2003_002",
    ),
    dict(
        class_name="com.nokia.srbts.mnl:CHANNEL",
        dist_name="MRBTS-1914/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-15",
        version="MNL5GC20A_2003_002",
    ),
    dict(
        class_name="com.nokia.srbts.mnl:CHANNEL",
        dist_name="MRBTS-1914/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-16",
        version="MNL5GC20A_2003_002",
    ),
]

PARAMS_TO_MODIFY_1473_90M_SA_4layer = [
    # SISO Configuration:ANTL3
    dict(
        value="3",
        dist_name="MRBTS-1914/EQM-1/APEQM-1/RMOD-1/ANTL-3",
        p_name="antPortId",
    ),
    dict(
        value="22",
        dist_name="MRBTS-1914/EQM-1/APEQM-1/RMOD-1/ANTL-3",
        p_name="antennaPathDelayDL",
    ),
    dict(
        value="22",
        dist_name="MRBTS-1914/EQM-1/APEQM-1/RMOD-1/ANTL-3",
        p_name="antennaPathDelayUL",
    ),
    dict(
        value="215",
        dist_name="MRBTS-1914/EQM-1/APEQM-1/RMOD-1/ANTL-3",
        p_name="cwaThreshold",
    ),
    dict(
        value="OFF",
        dist_name="MRBTS-1914/EQM-1/APEQM-1/RMOD-1/ANTL-3",
        p_name="dcVoltage",
    ),
    dict(
        value="false",
        dist_name="MRBTS-1914/EQM-1/APEQM-1/RMOD-1/ANTL-3",
        p_name="hdlcCommunicationAllowed",
    ),
    dict(
        value="30",
        dist_name="MRBTS-1914/EQM-1/APEQM-1/RMOD-1/ANTL-3",
        p_name="totalLoss",
    ),
    # SISO Configuration:ANTL4
    dict(
        value="4",
        dist_name="MRBTS-1914/EQM-1/APEQM-1/RMOD-1/ANTL-4",
        p_name="antPortId",
    ),
    dict(
        value="22",
        dist_name="MRBTS-1914/EQM-1/APEQM-1/RMOD-1/ANTL-4",
        p_name="antennaPathDelayDL",
    ),
    dict(
        value="22",
        dist_name="MRBTS-1914/EQM-1/APEQM-1/RMOD-1/ANTL-4",
        p_name="antennaPathDelayUL",
    ),
    dict(
        value="215",
        dist_name="MRBTS-1914/EQM-1/APEQM-1/RMOD-1/ANTL-4",
        p_name="cwaThreshold",
    ),
    dict(
        value="OFF",
        dist_name="MRBTS-1914/EQM-1/APEQM-1/RMOD-1/ANTL-4",
        p_name="dcVoltage",
    ),
    dict(
        value="false",
        dist_name="MRBTS-1914/EQM-1/APEQM-1/RMOD-1/ANTL-4",
        p_name="hdlcCommunicationAllowed",
    ),
    dict(
        value="30",
        dist_name="MRBTS-1914/EQM-1/APEQM-1/RMOD-1/ANTL-4",
        p_name="totalLoss",
    ),
    # SISO Configuration:ANTL5
    dict(
        value="5",
        dist_name="MRBTS-1914/EQM-1/APEQM-1/RMOD-1/ANTL-5",
        p_name="antPortId",
    ),
    dict(
        value="22",
        dist_name="MRBTS-1914/EQM-1/APEQM-1/RMOD-1/ANTL-5",
        p_name="antennaPathDelayDL",
    ),
    dict(
        value="22",
        dist_name="MRBTS-1914/EQM-1/APEQM-1/RMOD-1/ANTL-5",
        p_name="antennaPathDelayUL",
    ),
    dict(
        value="215",
        dist_name="MRBTS-1914/EQM-1/APEQM-1/RMOD-1/ANTL-5",
        p_name="cwaThreshold",
    ),
    dict(
        value="OFF",
        dist_name="MRBTS-1914/EQM-1/APEQM-1/RMOD-1/ANTL-5",
        p_name="dcVoltage",
    ),
    dict(
        value="false",
        dist_name="MRBTS-1914/EQM-1/APEQM-1/RMOD-1/ANTL-5",
        p_name="hdlcCommunicationAllowed",
    ),
    dict(
        value="30",
        dist_name="MRBTS-1914/EQM-1/APEQM-1/RMOD-1/ANTL-5",
        p_name="totalLoss",
    ),
    # SISO Configuration:ANTL6
    dict(
        value="6",
        dist_name="MRBTS-1914/EQM-1/APEQM-1/RMOD-1/ANTL-6",
        p_name="antPortId",
    ),
    dict(
        value="22",
        dist_name="MRBTS-1914/EQM-1/APEQM-1/RMOD-1/ANTL-6",
        p_name="antennaPathDelayDL",
    ),
    dict(
        value="22",
        dist_name="MRBTS-1914/EQM-1/APEQM-1/RMOD-1/ANTL-6",
        p_name="antennaPathDelayUL",
    ),
    dict(
        value="215",
        dist_name="MRBTS-1914/EQM-1/APEQM-1/RMOD-1/ANTL-6",
        p_name="cwaThreshold",
    ),
    dict(
        value="OFF",
        dist_name="MRBTS-1914/EQM-1/APEQM-1/RMOD-1/ANTL-6",
        p_name="dcVoltage",
    ),
    dict(
        value="false",
        dist_name="MRBTS-1914/EQM-1/APEQM-1/RMOD-1/ANTL-6",
        p_name="hdlcCommunicationAllowed",
    ),
    dict(
        value="30",
        dist_name="MRBTS-1914/EQM-1/APEQM-1/RMOD-1/ANTL-6",
        p_name="totalLoss",
    ),
    # SISO Configuration:ANTL7
    dict(
        value="7",
        dist_name="MRBTS-1914/EQM-1/APEQM-1/RMOD-1/ANTL-7",
        p_name="antPortId",
    ),
    dict(
        value="22",
        dist_name="MRBTS-1914/EQM-1/APEQM-1/RMOD-1/ANTL-7",
        p_name="antennaPathDelayDL",
    ),
    dict(
        value="22",
        dist_name="MRBTS-1914/EQM-1/APEQM-1/RMOD-1/ANTL-7",
        p_name="antennaPathDelayUL",
    ),
    dict(
        value="215",
        dist_name="MRBTS-1914/EQM-1/APEQM-1/RMOD-1/ANTL-7",
        p_name="cwaThreshold",
    ),
    dict(
        value="OFF",
        dist_name="MRBTS-1914/EQM-1/APEQM-1/RMOD-1/ANTL-7",
        p_name="dcVoltage",
    ),
    dict(
        value="false",
        dist_name="MRBTS-1914/EQM-1/APEQM-1/RMOD-1/ANTL-7",
        p_name="hdlcCommunicationAllowed",
    ),
    dict(
        value="30",
        dist_name="MRBTS-1914/EQM-1/APEQM-1/RMOD-1/ANTL-7",
        p_name="totalLoss",
    ),
    # SISO Configuration:ANTL8
    dict(
        value="8",
        dist_name="MRBTS-1914/EQM-1/APEQM-1/RMOD-1/ANTL-8",
        p_name="antPortId",
    ),
    dict(
        value="22",
        dist_name="MRBTS-1914/EQM-1/APEQM-1/RMOD-1/ANTL-8",
        p_name="antennaPathDelayDL",
    ),
    dict(
        value="22",
        dist_name="MRBTS-1914/EQM-1/APEQM-1/RMOD-1/ANTL-8",
        p_name="antennaPathDelayUL",
    ),
    dict(
        value="215",
        dist_name="MRBTS-1914/EQM-1/APEQM-1/RMOD-1/ANTL-8",
        p_name="cwaThreshold",
    ),
    dict(
        value="OFF",
        dist_name="MRBTS-1914/EQM-1/APEQM-1/RMOD-1/ANTL-8",
        p_name="dcVoltage",
    ),
    dict(
        value="false",
        dist_name="MRBTS-1914/EQM-1/APEQM-1/RMOD-1/ANTL-8",
        p_name="hdlcCommunicationAllowed",
    ),
    dict(
        value="30",
        dist_name="MRBTS-1914/EQM-1/APEQM-1/RMOD-1/ANTL-8",
        p_name="totalLoss",
    ),
    # SISO Configuration:CHANNEL
    dict(
        value="TX",
        dist_name="MRBTS-1914/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-5",
        p_name="direction",
    ),
    dict(
        value="MRBTS-1914/EQM-1/APEQM-1/RMOD-1/ANTL-3",
        dist_name="MRBTS-1914/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-5",
        p_name="antlDN",
    ),
    dict(
        value="RX",
        dist_name="MRBTS-1914/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-6",
        p_name="direction",
    ),
    dict(
        value="MRBTS-1914/EQM-1/APEQM-1/RMOD-1/ANTL-3",
        dist_name="MRBTS-1914/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-6",
        p_name="antlDN",
    ),
    dict(
        value="TX",
        dist_name="MRBTS-1914/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-7",
        p_name="direction",
    ),
    dict(
        value="MRBTS-1914/EQM-1/APEQM-1/RMOD-1/ANTL-4",
        dist_name="MRBTS-1914/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-7",
        p_name="antlDN",
    ),
    dict(
        value="RX",
        dist_name="MRBTS-1914/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-8",
        p_name="direction",
    ),
    dict(
        value="MRBTS-1914/EQM-1/APEQM-1/RMOD-1/ANTL-4",
        dist_name="MRBTS-1914/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-8",
        p_name="antlDN",
    ),
    dict(
        value="TX",
        dist_name="MRBTS-1914/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-9",
        p_name="direction",
    ),
    dict(
        value="MRBTS-1914/EQM-1/APEQM-1/RMOD-1/ANTL-5",
        dist_name="MRBTS-1914/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-9",
        p_name="antlDN",
    ),
    dict(
        value="RX",
        dist_name="MRBTS-1914/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-10",
        p_name="direction",
    ),
    dict(
        value="MRBTS-1914/EQM-1/APEQM-1/RMOD-1/ANTL-5",
        dist_name="MRBTS-1914/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-10",
        p_name="antlDN",
    ),
    dict(
        value="TX",
        dist_name="MRBTS-1914/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-11",
        p_name="direction",
    ),
    dict(
        value="MRBTS-1914/EQM-1/APEQM-1/RMOD-1/ANTL-6",
        dist_name="MRBTS-1914/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-11",
        p_name="antlDN",
    ),
    dict(
        value="RX",
        dist_name="MRBTS-1914/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-12",
        p_name="direction",
    ),
    dict(
        value="MRBTS-1914/EQM-1/APEQM-1/RMOD-1/ANTL-6",
        dist_name="MRBTS-1914/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-12",
        p_name="antlDN",
    ),
    dict(
        value="TX",
        dist_name="MRBTS-1914/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-13",
        p_name="direction",
    ),
    dict(
        value="MRBTS-1914/EQM-1/APEQM-1/RMOD-1/ANTL-7",
        dist_name="MRBTS-1914/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-13",
        p_name="antlDN",
    ),
    dict(
        value="RX",
        dist_name="MRBTS-1914/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-14",
        p_name="direction",
    ),
    dict(
        value="MRBTS-1914/EQM-1/APEQM-1/RMOD-1/ANTL-7",
        dist_name="MRBTS-1914/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-14",
        p_name="antlDN",
    ),
    dict(
        value="TX",
        dist_name="MRBTS-1914/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-15",
        p_name="direction",
    ),
    dict(
        value="MRBTS-1914/EQM-1/APEQM-1/RMOD-1/ANTL-8",
        dist_name="MRBTS-1914/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-15",
        p_name="antlDN",
    ),
    dict(
        value="RX",
        dist_name="MRBTS-1914/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-16",
        p_name="direction",
    ),
    dict(
        value="MRBTS-1914/EQM-1/APEQM-1/RMOD-1/ANTL-8",
        dist_name="MRBTS-1914/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-16",
        p_name="antlDN",
    ),
    # MRBTS
    dict(value="cOAM_SA_AZQG_TL014_4layer", dist_name="MRBTS-1914", p_name="btsName"),
    # NRBTS
    dict(value="SA", dist_name="MRBTS-1914/NRBTS-14", p_name="gNbCuType"),
    dict(value="0", dist_name="MRBTS-1914/NRBTS-14", p_name="x2LinkSupervisionTmr"),
    dict(value="true", dist_name="MRBTS-1914/NRBTS-14/NRCELL-2", p_name="actDl256Qam"),
    # NRBTS/NRCELL
    dict(value="90MHz", dist_name="MRBTS-1914/NRBTS-14/NRCELL-2", p_name="chBw"),
    dict(value="SA", dist_name="MRBTS-1914/NRBTS-14/NRCELL-2", p_name="cellDepType"),
    dict(
        value="true", dist_name="MRBTS-1914/NRBTS-14/NRCELL-2", p_name="actBeamforming"
    ),
    dict(
        value="4x4 or 4x2 Closed Loop Spatial Multiplexing",
        dist_name="MRBTS-1914/NRBTS-14/NRCELL-2",
        p_name="dlMimoMode",
    ),
    dict(value="4DL2UL", dist_name="MRBTS-1914/NRBTS-14/NRCELL-2", p_name="nrCellType"),
    dict(
        value="5",
        dist_name="MRBTS-1914/NRBTS-14/NRCELL-2",
        p_name="type0SearchSpaceConfigurationIndex",
    ),
    dict(
        value="2sub-sectors",
        dist_name="MRBTS-1914/NRBTS-14/NRCELL-2",
        p_name="numOfSubSectors",
    ),
    # NRBTS/NRCELLGRP
    dict(
        value="2 beams",
        dist_name="MRBTS-1914/NRBTS-14/NRCELLGRP-0",
        p_name="numberOfTransmittedSsBlocks",
    ),
]

LIST_TO_ADD_1473_90M_SA_4layer = [
    # NRBTS/NRCELL
    dict(
        dist_name="MRBTS-1914/NRBTS-14/NRCELL-2",
        list_name="fPdcchMonOccsnPo",
        elements=["2"],
    ),
]

LIST_PARAMS_TO_MODIFY_1473_90M_SA_4layer = [
    # NRBTS/NRCELL
    dict(
        dist_name="MRBTS-1914/NRBTS-14/NRCELL-2",
        list_name="beamSet",
        elements=[dict(p_name="basicBeamSet", value="beamSet_2SS", index=0)],
    ),
]
