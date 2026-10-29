# -*- coding: utf-8 -*-
import os

__team__ = "MN 5G RAN I&V 4 Pz HZG SG1"
__email__ = "I_MN_5G_RAN_IV4_LINE_HZG_1@internal.nsn.com"

TLSCF_CELL_NUMs = [3]
GoldenSCF = "/21B/GoldenSCF_6Cell_v8.xml"
# modify Golden SCF to 1Cell SCF

# DELETE

PARAMS_TO_DELETE_HW_TOPO = [
    dict(dist_name="MRBTS-11103/EQM-1/APEQM-1/CABINET-1/SMOD-1"),
    dict(dist_name="MRBTS-11103/EQM-1/APEQM-1/CABINET-1/BBMOD-1"),
    dict(dist_name="MRBTS-11103/EQM-1/APEQM-1/CABINET-1/BBMOD-2"),
    dict(dist_name="MRBTS-11103/EQM-1/APEQM-1/CABINET-1/BBMOD-3"),
    dict(dist_name="MRBTS-11103/EQM-1/APEQM-1/RMOD-1"),
    dict(dist_name="MRBTS-11103/EQM-1/APEQM-1/RMOD-2"),
    dict(dist_name="MRBTS-11103/EQM-1/APEQM-1/RMOD-3"),
    # If FEATCADM.rfSharingEnabled is equal to FALSE, there shall be no SMOD_EXT instance.
    dict(dist_name="MRBTS-11103/EQM-1/SMOD_EXT-1"),
    dict(dist_name="MRBTS-11103/EQM-1/HWTOP-1/CABLINK-1"),
    dict(dist_name="MRBTS-11103/EQM-1/HWTOP-1/CABLINK-2"),
    dict(dist_name="MRBTS-11103/EQM-1/HWTOP-1/CABLINK-3"),
    dict(dist_name="MRBTS-11103/EQM-1/HWTOP-1/CABLINK-4"),
    dict(dist_name="MRBTS-11103/EQM-1/HWTOP-1/CABLINK-5"),
    dict(dist_name="MRBTS-11103/EQM-1/HWTOP-1/CABLINK-6"),
    dict(dist_name="MRBTS-11103/EQM-1/HWTOP-1/CABLINK-7"),
    dict(dist_name="MRBTS-11103/MNL-1/MNLENT-1/CELLMAPPING-1"),
    dict(dist_name="MRBTS-11103/MRBTSDESC-0"),
    dict(dist_name="MRBTS-11103/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/VLANIF-1"),
    dict(dist_name="MRBTS-11103/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/VLANIF-2"),
    dict(dist_name="MRBTS-11103/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/VLANIF-3"),
    dict(dist_name="MRBTS-11103/TNLSVC-1/TNL-1/IPNO-1/IPIF-2"),
    dict(dist_name="MRBTS-11103/TNLSVC-1/TNL-1/IPNO-1/IPIF-3"),
    dict(
        dist_name="MRBTS-12345/TNLSVC-1/TNL-1/IPNO-1/IPRT-1", list_name="staticRoutes"
    ),
]

PARAMS_TO_DELETE_SW_CONF = [
    dict(dist_name="MRBTS-11103/NRBTS-1103/NRCELL-1/NRCELL_FDD-1"),
    dict(dist_name="MRBTS-11103/NRBTS-1103/NRCELL-1", p_name="chBw"),
    dict(dist_name="MRBTS-11103/NRBTS-1103/NRDU-1", list_name="refNrCellGroup"),
    dict(dist_name="MRBTS-11103/TNLSVC-1/TNL-2/ETHSVC-1/ETHLK-2"),
    dict(dist_name="MRBTS-11103/NRBTS-1103/TRACKINGAREA-8201"),
    dict(dist_name="MRBTS-11103/NRBTS-1103/BWP_PROFILE-2"),
    dict(dist_name="MRBTS-11103/NRBTS-1103/BWP_PROFILE-2/PDCCH-1"),
    dict(
        dist_name="MRBTS-11103/NRBTS-1103/BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_COMMON-1"
    ),
    dict(dist_name="MRBTS-11103/NRBTS-1103/BWP_PROFILE-21"),
    dict(dist_name="MRBTS-11103/NRBTS-1103/BWP_PROFILE-21/PDCCH-1"),
    dict(
        dist_name="MRBTS-11103/NRBTS-1103/BWP_PROFILE-21/PDCCH-1/PDCCH_CONFIG_COMMON-1"
    ),
    dict(
        dist_name="MRBTS-11103/NRBTS-1103/BWP_PROFILE-21/PDCCH-1/PDCCH_CONFIG_DEDICATED-1"
    ),
]

PARAMS_TO_DELETE_SW_TOPO_5CELL = [
    dict(dist_name="MRBTS-11103/NRBTS-1103/NRCELL-2"),
    dict(dist_name="MRBTS-11103/NRBTS-1103/NRCELL-3"),
    dict(dist_name="MRBTS-11103/NRBTS-1103/NRCELL-4"),
    dict(dist_name="MRBTS-11103/NRBTS-1103/NRCELL-5"),
    dict(dist_name="MRBTS-11103/NRBTS-1103/NRCELL-6"),
    dict(dist_name="MRBTS-11103/NRBTS-1103/NRCELLGRP-1"),
    dict(dist_name="MRBTS-11103/NRBTS-1103/NRCELLGRP-2"),
    dict(dist_name="MRBTS-11103/NRBTS-1103/NRCELLGRP-3"),
    dict(dist_name="MRBTS-11103/NRBTS-1103/NRCELLGRP-4"),
    dict(dist_name="MRBTS-11103/NRBTS-1103/NRCELLGRP-5"),
]
TL_PARAMS_TO_DELETE_1Cell = (
    PARAMS_TO_DELETE_HW_TOPO + PARAMS_TO_DELETE_SW_CONF + PARAMS_TO_DELETE_SW_TOPO_5CELL
)

# Modify

PARAMS_TO_MODIFY_HW_TOPO = [
    # Hardware Topy
    dict(
        value="473764A.102",
        dist_name="MRBTS-11103/EQM-1/APEQM-1/CABINET-1/SMOD-1",
        p_name="prodCodePlanned",
    ),
    dict(
        value="false",
        dist_name="MRBTS-11103/EQM-1/APEQM-1/CABINET-1/SMOD-1",
        p_name="climateControlOcxoTemperatureLearning",
    ),
    dict(
        value="474020A.102",
        dist_name="MRBTS-11103/EQM-1/APEQM-1/CABINET-1/BBMOD-1",
        p_name="prodCodePlanned",
    ),
    dict(
        value="true",
        dist_name="MRBTS-11103/EQM-1/APEQM-1/CABINET-1/BBMOD-1",
        p_name="useFullCapacity",
    ),
    dict(
        value="Unlocked",
        dist_name="MRBTS-11103/EQM-1/APEQM-1/CABINET-1/BBMOD-1",
        p_name="administrativeState",
    ),
    dict(
        value="not used",
        dist_name="MRBTS-11103/EQM-1/APEQM-1/CABINET-1/BBMOD-1",
        p_name="fddNrCellConfigTradeoff",
    ),
    dict(
        value="false",
        dist_name="MRBTS-11103/EQM-1/APEQM-1/RMOD-1",
        p_name="actPimCancellation",
    ),
    dict(
        value="false",
        dist_name="MRBTS-11103/EQM-1/APEQM-1/RMOD-1",
        p_name="legacyWideCarrierMode",
    ),
    dict(
        value="AWAKE",
        dist_name="MRBTS-11103/EQM-1/APEQM-1/RMOD-1",
        p_name="oruEnergySavingMode",
    ),
    dict(
        value="false",
        dist_name="MRBTS-11103/EQM-1/APEQM-1/RMOD-1",
        p_name="actSnapshotCollection",
    ),
    dict(
        value="Unlocked",
        dist_name="MRBTS-11103/EQM-1/APEQM-1/RMOD-1",
        p_name="administrativeState",
    ),
    dict(
        value="475208A.101",
        dist_name="MRBTS-11103/EQM-1/APEQM-1/RMOD-1",
        p_name="prodCodePlanned",
    ),
    dict(
        value="Auto", dist_name="MRBTS-11103/EQM-1/APEQM-1/RMOD-1", p_name="linkSpeed"
    ),
    dict(
        value="false",
        dist_name="MRBTS-11103/EQM-1/APEQM-1/RMOD-1",
        p_name="pimCancellingEnabled",
    ),
    dict(
        value="false",
        dist_name="MRBTS-11103/EQM-1/APEQM-1/RMOD-1",
        p_name="pimCancellingEnabled",
    ),
    dict(
        value="MRBTS-11103/EQM-1/APEQM-1/CABINET-1/BBMOD-1",
        dist_name="MRBTS-11103/EQM-1/APEQM-1/RMOD-1",
        p_name="radioMasterDN",
    ),
    dict(
        value="1",
        dist_name="MRBTS-11103/EQM-1/APEQM-1/RMOD-1/ANTL-1",
        p_name="antPortId",
    ),
    dict(
        value="22",
        dist_name="MRBTS-11103/EQM-1/APEQM-1/RMOD-1/ANTL-1",
        p_name="antennaPathDelayDL",
    ),
    dict(
        value="22",
        dist_name="MRBTS-11103/EQM-1/APEQM-1/RMOD-1/ANTL-1",
        p_name="antennaPathDelayUL",
    ),
    dict(
        value="215",
        dist_name="MRBTS-11103/EQM-1/APEQM-1/RMOD-1/ANTL-1",
        p_name="cwaThreshold",
    ),
    dict(
        value="OFF",
        dist_name="MRBTS-11103/EQM-1/APEQM-1/RMOD-1/ANTL-1",
        p_name="dcVoltage",
    ),
    dict(
        value="false",
        dist_name="MRBTS-11103/EQM-1/APEQM-1/RMOD-1/ANTL-1",
        p_name="hdlcCommunicationAllowed",
    ),
    dict(
        value="30",
        dist_name="MRBTS-11103/EQM-1/APEQM-1/RMOD-1/ANTL-1",
        p_name="totalLoss",
    ),
    dict(
        value="0", dist_name="MRBTS-11103/EQM-1/APEQM-1/RMOD-1/ANTL-1", p_name="ulDelay"
    ),
    dict(
        value="3",
        dist_name="MRBTS-11103/EQM-1/APEQM-1/RMOD-1/ANTL-2",
        p_name="antPortId",
    ),
    dict(
        value="22",
        dist_name="MRBTS-11103/EQM-1/APEQM-1/RMOD-1/ANTL-2",
        p_name="antennaPathDelayDL",
    ),
    dict(
        value="22",
        dist_name="MRBTS-11103/EQM-1/APEQM-1/RMOD-1/ANTL-2",
        p_name="antennaPathDelayUL",
    ),
    dict(
        value="215",
        dist_name="MRBTS-11103/EQM-1/APEQM-1/RMOD-1/ANTL-2",
        p_name="cwaThreshold",
    ),
    dict(
        value="OFF",
        dist_name="MRBTS-11103/EQM-1/APEQM-1/RMOD-1/ANTL-2",
        p_name="dcVoltage",
    ),
    dict(
        value="false",
        dist_name="MRBTS-11103/EQM-1/APEQM-1/RMOD-1/ANTL-2",
        p_name="hdlcCommunicationAllowed",
    ),
    dict(
        value="30",
        dist_name="MRBTS-11103/EQM-1/APEQM-1/RMOD-1/ANTL-2",
        p_name="totalLoss",
    ),
    dict(
        value="0", dist_name="MRBTS-11103/EQM-1/APEQM-1/RMOD-1/ANTL-2", p_name="ulDelay"
    ),
    dict(
        value="MRBTS-11103/EQM-1/APEQM-1/CABINET-1/SMOD-1",
        dist_name="MRBTS-11103/EQM-1/HWTOP-1/CABLINK-1",
        p_name="firstEndpointDN",
    ),
    dict(
        value="BACKPLANE",
        dist_name="MRBTS-11103/EQM-1/HWTOP-1/CABLINK-1",
        p_name="firstEndpointLabel",
    ),
    dict(
        value="1",
        dist_name="MRBTS-11103/EQM-1/HWTOP-1/CABLINK-1",
        p_name="firstEndpointPortId",
    ),
    dict(
        value="false",
        dist_name="MRBTS-11103/EQM-1/HWTOP-1/CABLINK-1",
        p_name="linkModeConfiguration",
    ),
    dict(
        value="false",
        dist_name="MRBTS-11103/EQM-1/HWTOP-1/CABLINK-1",
        p_name="linkModeDC",
    ),
    dict(
        value="false",
        dist_name="MRBTS-11103/EQM-1/HWTOP-1/CABLINK-1",
        p_name="linkModeData",
    ),
    dict(
        value="false",
        dist_name="MRBTS-11103/EQM-1/HWTOP-1/CABLINK-1",
        p_name="linkModeSynchronization",
    ),
    dict(
        value="MRBTS-11103/EQM-1/APEQM-1/CABINET-1/BBMOD-1",
        dist_name="MRBTS-11103/EQM-1/HWTOP-1/CABLINK-1",
        p_name="secondEndpointDN",
    ),
    dict(
        value="BACKPLANE",
        dist_name="MRBTS-11103/EQM-1/HWTOP-1/CABLINK-1",
        p_name="secondEndpointLabel",
    ),
    dict(
        value="MRBTS-11103/EQM-1/APEQM-1/CABINET-1/BBMOD-1",
        dist_name="MRBTS-11103/EQM-1/HWTOP-1/CABLINK-2",
        p_name="firstEndpointDN",
    ),
    dict(
        value="SFP",
        dist_name="MRBTS-11103/EQM-1/HWTOP-1/CABLINK-2",
        p_name="firstEndpointLabel",
    ),
    dict(
        value="1",
        dist_name="MRBTS-11103/EQM-1/HWTOP-1/CABLINK-2",
        p_name="firstEndpointPortId",
    ),
    dict(
        value="none",
        dist_name="MRBTS-11103/EQM-1/HWTOP-1/CABLINK-2",
        p_name="iqCompression",
    ),
    dict(
        value="Cpri7",
        dist_name="MRBTS-11103/EQM-1/HWTOP-1/CABLINK-2",
        p_name="linkSpeed",
    ),
    dict(
        value="FDDCPRI",
        dist_name="MRBTS-11103/EQM-1/HWTOP-1/CABLINK-2",
        p_name="radioProtocolType",
    ),
    dict(
        value="MRBTS-11103/EQM-1/APEQM-1/RMOD-1",
        dist_name="MRBTS-11103/EQM-1/HWTOP-1/CABLINK-2",
        p_name="secondEndpointDN",
    ),
    dict(
        value="SFP",
        dist_name="MRBTS-12345/EQM-1/HWTOP-1/CABLINK-2",
        p_name="secondEndpointLabel",
    ),
    dict(
        value="1",
        dist_name="MRBTS-12345/EQM-1/HWTOP-1/CABLINK-2",
        p_name="secondEndpointPortId",
    ),
    dict(
        value="GPS only",
        dist_name="MRBTS-11103/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/GNSSE-1",
        p_name="gnssControlMode",
    ),
    dict(
        value="(GMT+8) Asia/Shanghai",
        dist_name="MRBTS-11103/MNL-1/MNLENT-1/SYNC-1/TIME-1",
        p_name="timeZone",
    ),
    dict(
        value="false",
        dist_name="MRBTS-11103/MNL-1/MNLENT-1/FEATCADM-1",
        p_name="rfSharingEnabled",
    ),
    dict(
        value="1048576",
        dist_name="MRBTS-11103/TNLSVC-1/TNL-1/ETHSVC-1/L2SWI-1/BRGPRT-1",
        p_name="l2BurstSize",
    ),
    dict(
        value="1000000",
        dist_name="MRBTS-11103/TNLSVC-1/TNL-1/ETHSVC-1/L2SWI-1/BRGPRT-1",
        p_name="l2ShaperRate",
    ),
    dict(
        value="MRBTS-11103/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1",
        dist_name="MRBTS-11103/MNL-1/MNLENT-1/MPLANENW-1",
        p_name="mPlaneIpv4AddressDN",
    ),
    dict(
        value="MRBTS-11103/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1",
        dist_name="MRBTS-11103/TNLSVC-1/TNL-1/IPNO-1/IPIF-1",
        p_name="interfaceDN",
    ),
    dict(
        value="10.108.221.70",
        dist_name="MRBTS-11103/NRBTS-1103/SERVEDAMF-1",
        p_name="amfIPAddress",
    ),
    dict(
        value="10.101.49.228",
        dist_name="MRBTS-11103/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1",
        p_name="localIpAddr",
    ),
]
PARAMS_TO_MODIFY_SW_CONF = [
    dict(value="SG1_TL1103_FDD", dist_name="MRBTS-11103", p_name="btsName"),
    # Both related
    dict(value="SA+NSA", dist_name="MRBTS-11103/NRBTS-1103", p_name="gNbCuType"),
    dict(value="true", dist_name="MRBTS-11103/NRBTS-1103", p_name="actPaging"),
    dict(
        value="15min", dist_name="MRBTS-11103/NRBTS-1103/NRPMRNL-1", p_name="miNrPaging"
    ),
    dict(
        value="true", dist_name="MRBTS-11103/NRBTS-1103", p_name="actSACallProcessingDU"
    ),
    dict(
        value="210",
        dist_name="MRBTS-11103/NRBTS-1103/TRACKINGAREA-210",
        p_name="fiveGsTac",
    ),
    dict(
        value="Unlocked",
        dist_name="MRBTS-11103/NRBTS-1103/SNSSAI-1",
        p_name="administrativeState",
    ),
    dict(value="13714341", dist_name="MRBTS-11103/NRBTS-1103/SNSSAI-1", p_name="sd"),
    dict(value="1", dist_name="MRBTS-11103/NRBTS-1103/SNSSAI-1", p_name="sst"),
    dict(
        value="dB0",
        dist_name="MRBTS-11103/NRBTS-1103/NRSYSINFO_PROFILE-1",
        p_name="qHyst",
    ),
    dict(
        value="s40",
        dist_name="MRBTS-11103/NRBTS-1103/NRSYSINFO_PROFILE-1",
        p_name="siWindowLength",
    ),
    dict(
        value="251",
        dist_name="MRBTS-11103/NRBTS-1103/NRSYSINFO_PROFILE-1",
        p_name="systemInformationTargetRate",
    ),
    dict(
        value="0",
        dist_name="MRBTS-11103/NRBTS-1103/NRSYSINFO_PROFILE-1",
        p_name="tReselectionEutra",
    ),
    dict(
        value="0",
        dist_name="MRBTS-11103/NRBTS-1103/NRSYSINFO_PROFILE-1",
        p_name="threshServingLowP",
    ),
    dict(
        value="-56",
        dist_name="MRBTS-11103/NRBTS-1103/NRSYSINFO_PROFILE-1/NRIAFIM-1",
        p_name="qRxLevMin",
    ),
    dict(
        value="22",
        dist_name="MRBTS-11103/NRBTS-1103/NRSYSINFO_PROFILE-1/NRIAFIM-1",
        p_name="sIntraSearchP",
    ),
    dict(
        value="1",
        dist_name="MRBTS-11103/NRBTS-1103/NRSYSINFO_PROFILE-1/NRIAFIM-1",
        p_name="tReselectionNr",
    ),
    dict(value="460", dist_name="MRBTS-11103/NRBTS-1103", p_name="mcc"),
    dict(value="2", dist_name="MRBTS-11103/NRBTS-1103", p_name="mnc"),
    dict(value="460", dist_name="MRBTS-11103/NRBTS-1103/NRPLMN-1", p_name="mcc"),
    dict(value="2", dist_name="MRBTS-11103/NRBTS-1103/NRPLMN-1", p_name="mnc"),
    dict(value="2", dist_name="MRBTS-11103/NRBTS-1103/NRPLMN-1", p_name="mncLength"),
    dict(value="32", dist_name="MRBTS-11103/NRBTS-1103", p_name="gNbIdLength"),
    dict(
        value="initial",
        dist_name="MRBTS-11103/NRBTS-1103/BWP_PROFILE-1",
        p_name="bwpType",
    ),
    dict(
        value="static",
        dist_name="MRBTS-11103/NRBTS-1103/BWP_PROFILE-1/PDCCH-1",
        p_name="alSelection",
    ),
    dict(
        value="AL4",
        dist_name="MRBTS-11103/NRBTS-1103/BWP_PROFILE-1/PDCCH-1",
        p_name="dciDedicatedAggregationLevel",
    ),
    dict(
        value="AL4",
        dist_name="MRBTS-11103/NRBTS-1103/BWP_PROFILE-1/PDCCH-1",
        p_name="dciPagingAggregationLevel",
    ),
    dict(
        value="AL4",
        dist_name="MRBTS-11103/NRBTS-1103/BWP_PROFILE-1/PDCCH-1",
        p_name="dciRaCompletionAggregationLevel",
    ),
    dict(
        value="AL4",
        dist_name="MRBTS-11103/NRBTS-1103/BWP_PROFILE-1/PDCCH-1",
        p_name="dciRaMsg2AggregationLevel",
    ),
    dict(
        value="AL4",
        dist_name="MRBTS-11103/NRBTS-1103/BWP_PROFILE-1/PDCCH-1",
        p_name="dciSiAggregationLevel",
    ),
    dict(
        value="allowed",
        dist_name="MRBTS-11103/NRBTS-1103/BWP_PROFILE-1/PDCCH-1",
        p_name="downgradeAL16toAL8",
    ),
    dict(
        value="dedicated",
        dist_name="MRBTS-11103/NRBTS-1103/BWP_PROFILE-2",
        p_name="bwpType",
    ),
    dict(
        value="static",
        dist_name="MRBTS-11103/NRBTS-1103/BWP_PROFILE-2/PDCCH-1",
        p_name="alSelection",
    ),
    dict(
        value="AL4",
        dist_name="MRBTS-11103/NRBTS-1103/BWP_PROFILE-2/PDCCH-1",
        p_name="dciDedicatedAggregationLevel",
    ),
    dict(
        value="AL4",
        dist_name="MRBTS-11103/NRBTS-1103/BWP_PROFILE-2/PDCCH-1",
        p_name="dciPagingAggregationLevel",
    ),
    dict(
        value="AL4",
        dist_name="MRBTS-11103/NRBTS-1103/BWP_PROFILE-2/PDCCH-1",
        p_name="dciRaCompletionAggregationLevel",
    ),
    dict(
        value="AL4",
        dist_name="MRBTS-11103/NRBTS-1103/BWP_PROFILE-2/PDCCH-1",
        p_name="dciRaMsg2AggregationLevel",
    ),
    dict(
        value="AL4",
        dist_name="MRBTS-11103/NRBTS-1103/BWP_PROFILE-2/PDCCH-1",
        p_name="dciSiAggregationLevel",
    ),
    dict(
        value="allowed",
        dist_name="MRBTS-11103/NRBTS-1103/BWP_PROFILE-2/PDCCH-1",
        p_name="downgradeAL16toAL8",
    ),
    # XnLink
    dict(value="false", dist_name="MRBTS-11103/NRBTS-1103", p_name="actIncXn"),
]
PARAMS_TO_MODIFY_SW_TOPO_CELL1 = [
    # dict(value='30 KHz', dist_name='MRBTS-11103/NRBTS-1103/NRCELLGRP-0', p_name='scs'),
    # dict(value='none', dist_name='MRBTS-11103/NRBTS-1103/NRCELL-1', p_name='chBw'),
    dict(
        value="none",
        dist_name="MRBTS-11103/NRBTS-1103/NRCELL-1",
        p_name="a1MeashoEnabledSA",
    ),
    dict(
        value="none",
        dist_name="MRBTS-11103/NRBTS-1103/NRCELL-1",
        p_name="a2MeashoEnabledSA",
    ),
    dict(
        value="MRBTS-11103/NRBTS-1103/NRSYSINFO_PROFILE-1",
        dist_name="MRBTS-11103/NRBTS-1103/NRCELL-1",
        p_name="nrSysInfoProfileDN",
    ),
    dict(
        value="pagingDciAggregation",
        dist_name="MRBTS-11103/NRBTS-1103/NRCELL-1",
        p_name="pagingTargetRate",
    ),
    dict(
        value="sl20",
        dist_name="MRBTS-11103/NRBTS-1103/NRCELL-1",
        p_name="raResponseWindow",
    ),
    dict(value="15KHz", dist_name="MRBTS-11103/NRBTS-1103/NRCELL-1", p_name="ssbScs"),
    dict(
        value="MRBTS-11103/NRBTS-1103/TRACKINGAREA-210",
        dist_name="MRBTS-11103/NRBTS-1103/NRCELL-1",
        p_name="trackingAreaDN",
    ),
    dict(
        value="0",
        dist_name="MRBTS-11103/NRBTS-1103/NRCELL-1",
        p_name="siChangeIndDuration",
    ),
    dict(
        value="SA+NSA",
        dist_name="MRBTS-11103/NRBTS-1103/NRCELL-1",
        p_name="cellDepType",
    ),
    dict(value="1", dist_name="MRBTS-11103/NRBTS-1103/NRCELL-1", p_name="lcrId"),
    dict(value="214", dist_name="MRBTS-11103/NRBTS-1103/NRCELL-1", p_name="physCellId"),
    dict(
        value="6",
        dist_name="MRBTS-11103/NRBTS-1103/NRCELL-1",
        p_name="type0CoresetConfigurationIndex",
    ),
    dict(
        value="4",
        dist_name="MRBTS-11103/NRBTS-1103/NRCELL-1",
        p_name="type0SearchSpaceConfigurationIndex",
    ),
    dict(
        value="n0",
        dist_name="MRBTS-11103/NRBTS-1103/NRCELL-1",
        p_name="timingAdvanceOffset",
    ),
    dict(value="-65", dist_name="MRBTS-11103/NRBTS-1103/NRCELL-1", p_name="qRxLevMin"),
    # dict(value='10MHz', dist_name='MRBTS-11103/NRBTS-1103/NRCELL-1', p_name='chBw'),
    dict(
        value="12",
        dist_name="MRBTS-11103/NRBTS-1103/NRCELL-1",
        p_name="prachConfigurationIndex",
    ),
    dict(
        value="FDD",
        dist_name="MRBTS-11103/NRBTS-1103/NRCELL-1",
        p_name="cellTechnology",
    ),
    dict(
        value="28",
        dist_name="MRBTS-11103/NRBTS-1103/NRCELL-1",
        p_name="freqBandIndicatorNR",
    ),
    dict(
        value="2x2 Open Loop Spatial Multiplexing",
        dist_name="MRBTS-11103/NRBTS-1103/NRCELL-1",
        p_name="dlMimoMode",
    ),
    dict(value="1949", dist_name="MRBTS-11103/NRBTS-1103/NRCELL-1", p_name="gscn"),
    dict(
        value="2DL2UL", dist_name="MRBTS-11103/NRBTS-1103/NRCELL-1", p_name="nrCellType"
    ),
    dict(
        value="10MHz",
        dist_name="MRBTS-11103/NRBTS-1103/NRCELL-1/NRCELL_FDD-1",
        p_name="chBwDl",
    ),
    dict(
        value="10MHz",
        dist_name="MRBTS-11103/NRBTS-1103/NRCELL-1/NRCELL_FDD-1",
        p_name="chBwUl",
    ),
    dict(
        value="156100",
        dist_name="MRBTS-11103/NRBTS-1103/NRCELL-1/NRCELL_FDD-1",
        p_name="nrarfcnDl",
    ),
    dict(
        value="145100",
        dist_name="MRBTS-11103/NRBTS-1103/NRCELL-1/NRCELL_FDD-1",
        p_name="nrarfcnUl",
    ),
    dict(
        value="TX",
        dist_name="MRBTS-11103/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-1",
        p_name="direction",
    ),
    dict(
        value="MRBTS-11103/EQM-1/APEQM-1/RMOD-1/ANTL-1",
        dist_name="MRBTS-11103/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-1",
        p_name="antlDN",
    ),
    dict(
        value="RX",
        dist_name="MRBTS-11103/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-2",
        p_name="direction",
    ),
    dict(
        value="MRBTS-11103/EQM-1/APEQM-1/RMOD-1/ANTL-1",
        dist_name="MRBTS-11103/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-2",
        p_name="antlDN",
    ),
    dict(
        value="TX",
        dist_name="MRBTS-11103/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-3",
        p_name="direction",
    ),
    dict(
        value="MRBTS-11103/EQM-1/APEQM-1/RMOD-1/ANTL-2",
        dist_name="MRBTS-11103/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-3",
        p_name="antlDN",
    ),
    dict(
        value="RX",
        dist_name="MRBTS-11103/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-4",
        p_name="direction",
    ),
    dict(
        value="MRBTS-11103/EQM-1/APEQM-1/RMOD-1/ANTL-2",
        dist_name="MRBTS-11103/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-4",
        p_name="antlDN",
    ),
]
TL_PARAMS_TO_MODIFY_1Cell = (
    PARAMS_TO_MODIFY_HW_TOPO + PARAMS_TO_MODIFY_SW_CONF + PARAMS_TO_MODIFY_SW_TOPO_CELL1
)

# ADD MOS
TL_ADD_MOS_HW_TOPO = [
    # HW Topo
    dict(
        class_name="com.nokia.srbts.eqm:SMOD",
        dist_name="MRBTS-11103/EQM-1/APEQM-1/CABINET-1/SMOD-1",
        version="EQM21B_2105_002",
    ),
    dict(
        class_name="com.nokia.srbts.eqm:BBMOD",
        dist_name="MRBTS-11103/EQM-1/APEQM-1/CABINET-1/BBMOD-1",
        version="EQM21B_2105_002",
    ),
    dict(
        class_name="com.nokia.srbts.eqm:RMOD",
        dist_name="MRBTS-11103/EQM-1/APEQM-1/RMOD-1",
        version="EQM21B_2105_002",
    ),
    dict(
        class_name="com.nokia.srbts.eqm:ANTL",
        dist_name="MRBTS-11103/EQM-1/APEQM-1/RMOD-1/ANTL-1",
        version="EQM21B_2105_002",
    ),
    dict(
        class_name="com.nokia.srbts.eqm:ANTL",
        dist_name="MRBTS-11103/EQM-1/APEQM-1/RMOD-1/ANTL-2",
        version="EQM21B_2105_002",
    ),
    dict(
        class_name="com.nokia.srbts.eqm:CABLINK",
        dist_name="MRBTS-11103/EQM-1/HWTOP-1/CABLINK-1",
        version="EQM21B_2105_002",
    ),
    dict(
        class_name="com.nokia.srbts.eqm:CABLINK",
        dist_name="MRBTS-11103/EQM-1/HWTOP-1/CABLINK-2",
        version="EQM21B_2105_002",
    ),
]
TL_ADD_MOS_SW_CONF = [
    # SW Configuration
    dict(
        class_name="com.nokia.srbts.nrbts:NRCELL_FDD",
        dist_name="MRBTS-11103/NRBTS-1103103/NRCELL-1/NRCELL_FDD-1",
        version="NRBTSCL5G20B_2008_101",
    ),
    dict(
        class_name="com.nokia.srbts.nrbts:NRSYSINFO_PROFILE",
        dist_name="MRBTS-11103/NRBTS-1103/NRSYSINFO_PROFILE-1",
        version="NRBTSCL5G20B_2008_101",
    ),
    dict(
        class_name="com.nokia.srbts.nrbts:NRIAFIM",
        dist_name="MRBTS-11103/NRBTS-1103/NRSYSINFO_PROFILE-1/NRIAFIM-1",
        version="NRBTSCL5G20B_2008_101",
    ),
    dict(
        class_name="com.nokia.srbts.nrbts:SNSSAI",
        dist_name="MRBTS-11103/NRBTS-1103/SNSSAI-1",
        version="NRBTSCL5G20B_2008_200",
    ),
    dict(
        class_name="com.nokia.srbts.nrbts:TRACKINGAREA",
        dist_name="MRBTS-11103/NRBTS-1103/TRACKINGAREA-210",
        version="NRBTSCL5G20B_2008_101",
    ),
    dict(
        class_name="com.nokia.srbts.nrbts:NRPLMN",
        dist_name="MRBTS-11103/NRBTS-1103/NRPLMN-1",
        version="NRBTSCL5G20B_2008_101",
    ),
    dict(
        class_name="com.nokia.srbts.nrbts:BWP_PROFILE",
        dist_name="MRBTS-11103/NRBTS-1103/BWP_PROFILE-1",
        version="EQM20B_2010_001",
    ),
    dict(
        class_name="com.nokia.srbts.nrbts:PDCCH",
        dist_name="MRBTS-11103/NRBTS-1103/BWP_PROFILE-1/PDCCH-1",
        version="EQM20B_2010_001",
    ),
    dict(
        class_name="com.nokia.srbts.nrbts:PDCCH_CONFIG_COMMON",
        dist_name="MRBTS-11103/NRBTS-1103/BWP_PROFILE-1/PDCCH-1/PDCCH_CONFIG_COMMON-1",
        version="EQM20B_2010_001",
    ),
    dict(
        class_name="com.nokia.srbts.nrbts:BWP_PROFILE",
        dist_name="MRBTS-11103/NRBTS-1103/BWP_PROFILE-2",
        version="EQM20B_2010_001",
    ),
    dict(
        class_name="com.nokia.srbts.nrbts:PDCCH",
        dist_name="MRBTS-11103/NRBTS-1103/BWP_PROFILE-2/PDCCH-1",
        version="EQM20B_2010_001",
    ),
    dict(
        class_name="com.nokia.srbts.nrbts:PDCCH_CONFIG_COMMON",
        dist_name="MRBTS-11103/NRBTS-1103/BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_COMMON-1",
        version="EQM20B_2010_001",
    ),
    dict(
        class_name="com.nokia.srbts.nrbts:PDCCH_CONFIG_DEDICATED",
        dist_name="MRBTS-11103/NRBTS-1103/BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_DEDICATED-1",
        version="EQM20B_2010_001",
    ),
    # XnLink
]

TL_ADD_MOS_SW_TOPO_CELL1 = [
    # SW Topo
    dict(
        class_name="com.nokia.srbts.mnl:CELLMAPPING",
        dist_name="MRBTS-11103/MNL-1/MNLENT-1/CELLMAPPING-1",
        version="MNL5GC20B_2008_001",
    ),
    dict(
        class_name="com.nokia.srbts.mnl:LCELNR",
        dist_name="MRBTS-11103/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1",
        version="MNL5GC20B_2008_001",
    ),
    dict(
        class_name="com.nokia.srbts.mnl:CHANNELGROUP",
        dist_name="MRBTS-11103/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1",
        version="MNL5GC20B_2008_001",
    ),
    dict(
        class_name="com.nokia.srbts.mnl:CHANNEL",
        dist_name="MRBTS-11103/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-1",
        version="MNL5GC20B_2008_001",
    ),
    dict(
        class_name="com.nokia.srbts.mnl:CHANNEL",
        dist_name="MRBTS-11103/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-2",
        version="MNL5GC20B_2008_001",
    ),
    dict(
        class_name="com.nokia.srbts.mnl:CHANNEL",
        dist_name="MRBTS-11103/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-3",
        version="MNL5GC20B_2008_001",
    ),
    dict(
        class_name="com.nokia.srbts.mnl:CHANNEL",
        dist_name="MRBTS-11103/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-4",
        version="MNL5GC20B_2008_001",
    ),
]

TL_ADD_MOS_1Cell = TL_ADD_MOS_HW_TOPO + TL_ADD_MOS_SW_CONF + TL_ADD_MOS_SW_TOPO_CELL1

# LIST TO ADD
# Both related
LIST_TO_ADD_HW_TOPO = []
LIST_TO_ADD_SW_CONF = [
    dict(
        dist_name="MRBTS-11103/NRBTS-1103/NRSYSINFO_PROFILE-1",
        list_name="sibSchedulingList",
        elements=dict(
            sibBroadcastStatus="broadcasting",
            sibPeriodicity="rf64",
            sibScope="cellSpecific",
            sibType="sibType2",
        ),
    ),
    dict(
        dist_name="MRBTS-11103/NRBTS-1103/NRSYSINFO_PROFILE-1",
        list_name="sibSchedulingList",
        elements=dict(
            sibBroadcastStatus="broadcasting",
            sibPeriodicity="rf64",
            sibScope="cellSpecific",
            sibType="sibType3",
        ),
    ),
    dict(
        dist_name="MRBTS-11103/NRBTS-1103/NRSYSINFO_PROFILE-1",
        list_name="sibSchedulingList",
        elements=dict(
            sibBroadcastStatus="broadcasting",
            sibPeriodicity="rf64",
            sibScope="cellSpecific",
            sibType="sibType4",
        ),
    ),
    dict(
        dist_name="MRBTS-11103/NRBTS-1103/NRSYSINFO_PROFILE-1",
        list_name="sibSchedulingList",
        elements=dict(
            sibBroadcastStatus="broadcasting",
            sibPeriodicity="rf64",
            sibScope="cellSpecific",
            sibType="sibType5",
        ),
    ),
    dict(
        dist_name="MRBTS-11103/NRBTS-1103/NRSYSINFO_PROFILE-1",
        list_name="sibSchedulingList",
        elements=dict(
            sibBroadcastStatus="broadcasting",
            sibPeriodicity="rf16",
            sibScope="cellSpecific",
            sibType="sibType6",
        ),
    ),
    dict(
        dist_name="MRBTS-11103/NRBTS-1103/NRSYSINFO_PROFILE-1",
        list_name="sibSchedulingList",
        elements=dict(
            sibBroadcastStatus="broadcasting",
            sibPeriodicity="rf16",
            sibScope="cellSpecific",
            sibType="sibType7",
        ),
    ),
    dict(
        dist_name="MRBTS-11103/NRBTS-1103/NRSYSINFO_PROFILE-1",
        list_name="sibSchedulingList",
        elements=dict(
            sibBroadcastStatus="broadcasting",
            sibPeriodicity="rf16",
            sibScope="cellSpecific",
            sibType="sibType8",
        ),
    ),
    dict(
        dist_name="MRBTS-11103/NRBTS-1103/SNSSAI-1",
        list_name="nrPlmnDNList",
        elements=["MRBTS-11103/NRBTS-1103103/NRPLMN-1"],
    ),
    dict(
        dist_name="MRBTS-11103/NRBTS-1103/TRACKINGAREA-210",
        list_name="snssaiDNList",
        elements=["MRBTS-11103/NRBTS-1103103/SNSSAI-1"],
    ),
    dict(
        dist_name="MRBTS-11103/NRBTS-1103",
        list_name="ngCplane",
        elements=dict(
            ipV4AddressDN1="MRBTS-11103/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1"
        ),
    ),
    dict(
        dist_name="MRBTS-11103/NRBTS-1103",
        list_name="ngUplane",
        elements=dict(
            ipV4AddressDN1="MRBTS-11103/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1"
        ),
    ),
    dict(
        dist_name="MRBTS-11103/NRBTS-1103",
        list_name="xnCplane",
        elements=dict(
            ipV4AddressDN1="MRBTS-11103/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1"
        ),
    ),
    dict(
        dist_name="MRBTS-11103/NRBTS-1103",
        list_name="xnUplane",
        elements=dict(
            ipV4AddressDN1="MRBTS-11103/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1"
        ),
    ),
    dict(
        dist_name="MRBTS-11103/TNLSVC-1/TNL-1/IPNO-1/IPRT-1",
        list_name="staticRoutes",
        elements=dict(
            destinationIpPrefixLength="0", destIpAddr="0.0.0.0", gateway="10.101.49.225"
        ),
    ),
    dict(
        dist_name="MRBTS-11103/NRBTS-1103/BWP_PROFILE-1",
        list_name="locationAndBandwidthDl",
        elements=dict(cRbSizeDl="coreset0", cRbStartDl="coreset0"),
    ),
    dict(
        dist_name="MRBTS-11103/NRBTS-1103/BWP_PROFILE-1",
        list_name="locationAndBandwidthUl",
        elements=dict(cRbSizeUl="sameAsDl", cRbStartUl="sameAsDl"),
    ),
    dict(
        dist_name="MRBTS-11103/NRBTS-1103/BWP_PROFILE-2",
        list_name="locationAndBandwidthDl",
        elements=dict(cRbSizeDl="allRb", cRbStartDl="crb0"),
    ),
    dict(
        dist_name="MRBTS-11103/NRBTS-1103/BWP_PROFILE-2",
        list_name="locationAndBandwidthUl",
        elements=dict(cRbSizeUl="sameAsDl", cRbStartUl="sameAsDl"),
    ),
    dict(
        dist_name="MRBTS-11103/NRBTS-1103/BWP_PROFILE-1/PDCCH-1/PDCCH_CONFIG_COMMON-1",
        list_name="searchSpaceCommon",
        elements=dict(
            coresetId="0",
            dciFormat="formats0-0-And-1-0",
            duration="1",
            monitoringSymbolWithinSlot="symbol_0",
            numOfPdcchCandidatesInAL16="n0",
            numOfPdcchCandidatesInAL2="n0",
            numOfPdcchCandidatesInAL4="n2",
            numOfPdcchCandidatesInAL8="n0",
            periodicity="sl1",
            searchSpaceId="1",
            searchSpaceType="Type0A",
            slotOffset="0",
        ),
    ),
    dict(
        dist_name="MRBTS-11103/NRBTS-1103/BWP_PROFILE-1/PDCCH-1/PDCCH_CONFIG_COMMON-1",
        list_name="searchSpaceCommon",
        elements=dict(
            coresetId="0",
            dciFormat="formats0-0-And-1-0",
            duration="1",
            monitoringSymbolWithinSlot="symbol_0_1",
            numOfPdcchCandidatesInAL16="n0",
            numOfPdcchCandidatesInAL2="n0",
            numOfPdcchCandidatesInAL4="n4",
            numOfPdcchCandidatesInAL8="n0",
            periodicity="sl1",
            searchSpaceId="2",
            searchSpaceType="Type1",
            slotOffset="0",
        ),
    ),
    dict(
        dist_name="MRBTS-11103/NRBTS-1103/BWP_PROFILE-1/PDCCH-1/PDCCH_CONFIG_COMMON-1",
        list_name="searchSpaceCommon",
        elements=dict(
            coresetId="0",
            dciFormat="formats0-0-And-1-0",
            duration="1",
            monitoringSymbolWithinSlot="symbol_0",
            numOfPdcchCandidatesInAL16="n1",
            numOfPdcchCandidatesInAL2="n0",
            numOfPdcchCandidatesInAL4="n4",
            numOfPdcchCandidatesInAL8="n2",
            periodicity="sl1",
            searchSpaceId="3",
            searchSpaceType="Type2",
            slotOffset="0",
        ),
    ),
    dict(
        dist_name="MRBTS-11103/NRBTS-1103/BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_COMMON-1",
        list_name="searchSpaceCommon",
        elements=dict(
            coresetId="0",
            dciFormat="formats0-0-And-1-0",
            duration="1",
            monitoringSymbolWithinSlot="symbol_0",
            numOfPdcchCandidatesInAL16="n0",
            numOfPdcchCandidatesInAL2="n0",
            numOfPdcchCandidatesInAL4="n2",
            numOfPdcchCandidatesInAL8="n0",
            periodicity="sl1",
            searchSpaceId="11",
            searchSpaceType="Type0A",
            slotOffset="0",
        ),
    ),
    dict(
        dist_name="MRBTS-11103/NRBTS-1103/BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_COMMON-1",
        list_name="searchSpaceCommon",
        elements=dict(
            coresetId="0",
            dciFormat="formats0-0-And-1-0",
            duration="1",
            monitoringSymbolWithinSlot="symbol_0_1",
            numOfPdcchCandidatesInAL16="n0",
            numOfPdcchCandidatesInAL2="n0",
            numOfPdcchCandidatesInAL4="n2",
            numOfPdcchCandidatesInAL8="n0",
            periodicity="sl1",
            searchSpaceId="12",
            searchSpaceType="Type1",
            slotOffset="0",
        ),
    ),
    dict(
        dist_name="MRBTS-11103/NRBTS-1103/BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_COMMON-1",
        list_name="searchSpaceCommon",
        elements=dict(
            coresetId="0",
            dciFormat="formats0-0-And-1-0",
            duration="1",
            monitoringSymbolWithinSlot="symbol_0",
            numOfPdcchCandidatesInAL16="n0",
            numOfPdcchCandidatesInAL2="n0",
            numOfPdcchCandidatesInAL4="n2",
            numOfPdcchCandidatesInAL8="n0",
            periodicity="sl1",
            searchSpaceId="13",
            searchSpaceType="Type2",
            slotOffset="0",
        ),
    ),
    dict(
        dist_name="MRBTS-11103/NRBTS-1103/BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_DEDICATED-1",
        list_name="searchSpaceDedicated",
        elements=dict(
            coresetId="0",
            dciFormat="formats0-0-And-1-0",
            duration="1",
            monitoringSymbolWithinSlot="symbol_0_1",
            numOfPdcchCandidatesInAL1="n0",
            numOfPdcchCandidatesInAL16="n0",
            numOfPdcchCandidatesInAL2="n0",
            numOfPdcchCandidatesInAL4="n2",
            numOfPdcchCandidatesInAL8="n0",
            periodicity="sl1",
            searchSpaceId="4",
            searchSpaceType="Type3",
            slotOffset="0",
        ),
    ),
    dict(
        dist_name="MRBTS-11103/NRBTS-1103/BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_DEDICATED-1",
        list_name="searchSpaceDedicated",
        elements=dict(
            coresetId="0",
            dciFormat="formats0-1-And-1-1",
            duration="1",
            monitoringSymbolWithinSlot="symbol_0_1",
            numOfPdcchCandidatesInAL1="n0",
            numOfPdcchCandidatesInAL16="n0",
            numOfPdcchCandidatesInAL2="n0",
            numOfPdcchCandidatesInAL4="n2",
            numOfPdcchCandidatesInAL8="n0",
            periodicity="sl1",
            searchSpaceId="5",
            searchSpaceType="UE-Specific",
            slotOffset="0",
        ),
    ),
    # XnLink
]
LIST_TO_ADD_SW_TOPO_CELL1 = [
    dict(
        dist_name="MRBTS-11103/NRBTS-1103/NRDU-1",
        list_name="refNrCellGroup",
        elements=["0"],
    ),
    # dict(dist_name='MRBTS-11103/NRBTS-1103/NRCELLGRP-0', list_name='nrCellList', elements=['1']),
]

TL_LIST_TO_ADD_1CELL = (
    LIST_TO_ADD_HW_TOPO + LIST_TO_ADD_SW_CONF + LIST_TO_ADD_SW_TOPO_CELL1
)

# LIST PARAMS TO MODIFY
LIST_PARAMS_TO_MODIFY_HW_TOPO = []
LIST_PARAMS_TO_MODIFY_SW_CONF = [
    dict(
        dist_name="MRBTS-11103/NRBTS-1103",
        list_name="x2Cplane",
        elements=[
            dict(
                p_name="ipV4AddressDN1",
                value="MRBTS-11103/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1",
                index=0,
            )
        ],
    ),
]
LIST_PARAMS_TO_MODIFY_SW_TOPO_CELL1 = [
    dict(
        dist_name="MRBTS-11103/NRBTS-1103/NRCELL-1",
        list_name="cellBwpList",
        elements=[
            dict(p_name="bwpDN", value="MRBTS-11103/NRBTS-1103/BWP_PROFILE-1", index=0)
        ],
    ),
    dict(
        dist_name="MRBTS-11103/NRBTS-1103/NRCELL-1",
        list_name="cellBwpList",
        elements=[
            dict(p_name="bwpDN", value="MRBTS-11103/NRBTS-1103/BWP_PROFILE-2", index=1)
        ],
    ),
    # TL_Change: Lower the value of iBler
    dict(
        dist_name="MRBTS-11103/NRBTS-1103/NRCELL-1",
        list_name="periodicCsiAcquisition",
        elements=[dict(p_name="csiReportPeriodicity", value="slots320", index=0)],
    ),
    dict(
        dist_name="MRBTS-11103/NRBTS-1103/NRCELL-1",
        list_name="ulPowerControlCommon",
        elements=[
            dict(p_name="p0NominalPucch", value="-80", index=0),
            dict(p_name="p0NominalPusch", value="-74", index=0),
        ],
    ),
]

TL_LIST_PARAMS_TO_MODIFY_1Cell = (
    LIST_PARAMS_TO_MODIFY_HW_TOPO
    + LIST_PARAMS_TO_MODIFY_SW_CONF
    + LIST_PARAMS_TO_MODIFY_SW_TOPO_CELL1
)


TL_LIST_PARAMS_TO_MODIFY_2CELL = []
TL_LIST_PARAMS_TO_MODIFY_3CELL = []


TL_ADD_MOS_3CELL = []

TL_LIST_TO_ADD_1CELL = []
TL_LIST_TO_ADD_3CELL = []

TL_PARAMS_TO_DELETE_1CELL = []
TL_PARAMS_TO_DELETE_3CELL = []

TL_PARAMS_TO_MODIFY_1CELL = []
TL_PARAMS_TO_MODIFY_3CELL = []
