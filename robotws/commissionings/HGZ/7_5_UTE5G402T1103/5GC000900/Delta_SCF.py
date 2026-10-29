import os

__team__ = "MN 5G RAN I&V 4 Pz HZG SG1"
__email__ = "I_MN_5G_RAN_IV4_LINE_HZG_1@internal.nsn.com"

HandOverPAForRU0 = 20
cellDepType = "SA+NSA"

cell_idx_of_900_B5 = 1
cell_group_idx_of_900_B5 = 0

# modify 900_AA_005 SCF #
PARAMS_TO_MODIFY_900_AA_005 = [
    dict(
        value="TL003_AEQN_S1_SA_900_AA_005", dist_name="MRBTS-10031", p_name="btsName"
    ),
    #    dict(value='7848', dist_name='MRBTS-10031/NRBTS-10031/NRCELL-1', p_name='gscn'),
]

# modify 900_B_007 SCF #
PARAMS_TO_MODIFY_900_B_007 = [
    dict(value="TL003_AEQN_S1_SA_900_B_007", dist_name="MRBTS-10031", p_name="btsName"),
    dict(
        value="NSA", dist_name="MRBTS-10031/NRBTS-10031/NRCELL-1", p_name="cellDepType"
    ),
]

PARAMS_TO_DELETE_900_B_007 = [
    dict(dist_name="MRBTS-10031/NRBTS-10031/NRCELL-1", p_name="trackingAreaDN"),
]

# modify 900_A_004 SCF #
PARAMS_TO_MODIFY_900_A_004 = [
    dict(value="S1_SA_900_A_004", dist_name="MRBTS-10031", p_name="btsName"),
    dict(
        value="NSA", dist_name="MRBTS-10031/NRBTS-10031/NRCELL-1", p_name="cellDepType"
    ),
    dict(
        value="SA", dist_name="MRBTS-10031/NRBTS-10031/NRCELL-2", p_name="cellDepType"
    ),
    dict(
        value="120",
        dist_name="MRBTS-10031/NRBTS-10031",
        p_name="nsaCellActivationAlarmTimer",
    ),
    dict(
        value="120",
        dist_name="MRBTS-10031/NRBTS-10031",
        p_name="saCellActivationAlarmTimer",
    ),
    dict(
        value="120",
        dist_name="MRBTS-10031/NRBTS-10031",
        p_name="waitForRecovBeforeCellBarringTimer",
    ),
]

PARAMS_TO_DELETE_900_A_004 = [
    dict(dist_name="MRBTS-10031/NRBTS-10031/NRCELL-1", p_name="trackingAreaDN"),
    dict(dist_name="MRBTS-10031/NRBTS-10031/NRCELL-2", p_name="configuredEpsTac"),
    dict(dist_name="MRBTS-10031/NRBTS-10031/NRCELL-1/NRREL-1"),
    dict(dist_name="MRBTS-10031/NRBTS-10031/NRCELL-2/NRREL-1"),
]

# modify 900_B_005 SCF #
PARAMS_TO_MODIFY_900_B_05 = [
    dict(
        value="30",
        dist_name="MRBTS-10031/NRBTS-10031",
        p_name="nsaCellActivationAlarmTimer",
    ),
    dict(
        value="30",
        dist_name="MRBTS-10031/NRBTS-10031",
        p_name="saCellActivationAlarmTimer",
    ),
    dict(
        value="120",
        dist_name="MRBTS-10031/NRBTS-10031",
        p_name="waitForRecovBeforeCellBarringTimer",
    ),
    # modify AMF parameters to trigger 900 B05
    dict(
        value="10.110.90.100",
        dist_name="MRBTS-10031/NRBTS-10031/SERVEDAMF-1",
        p_name="amfIPAddress",
    ),
    dict(
        value="Locked",
        dist_name="MRBTS-10031/NRBTS-10031/SERVEDAMF-2",
        p_name="administrativeState",
    ),
    dict(
        value="10.110.227.5",
        dist_name="MRBTS-10031/NRBTS-10031/SERVEDAMF-2",
        p_name="amfIPAddress",
    ),
    dict(
        value="true",
        dist_name="MRBTS-10031/NRBTS-10031/SERVEDAMF-2",
        p_name="defaultAMF",
    ),
]

PARAMS_TO_DELETE_900_B_05 = []

ADD_MOs_900_B_05 = [
    dict(
        class_name="com.nokia.srbts.nrbts:SERVEDAMF",
        dist_name="MRBTS-10031/NRBTS-10031/SERVEDAMF-2",
        version="NRBTSCL5G21A_2012_200",
    ),
]

ADD_TO_List_900_B_05 = []

# modify 900_D_012 SCF #
PARAMS_TO_MODIFY_900_D_012 = [
    dict(
        value="cOAM_SA_AEQA_TL207_900_D_012", dist_name="MRBTS-10031", p_name="btsName"
    ),
    dict(
        value="NSA",
        dist_name="MRBTS-10031/NRBTS-10031/NRCELL-1",
        p_name="pciRangeValidity",
    ),
    #    dict(value='52', dist_name='MRBTS-10031/NRBTS-10031/NRCELL-1', list_name='pciBlackList',p_name='physCellId'),
    dict(value="n4", dist_name="MRBTS-10031/NRBTS-10031/NRCELL-1", p_name="range"),
    dict(
        value="NSA",
        dist_name="MRBTS-10031/NRBTS-10031/NRCELL-2",
        p_name="pciRangeValidity",
    ),
    #    dict(value='51', dist_name='MRBTS-10031/NRBTS-10031/NRCELL-2', list_name='pciBlackList',p_name='physCellId'),
    dict(value="n4", dist_name="MRBTS-10031/NRBTS-10031/NRCELL-2", p_name="range"),
    dict(
        value="NSA",
        dist_name="MRBTS-10031/NRBTS-10031/NRCELL-1/NRREL-2",
        p_name="cellDepType",
    ),
    dict(
        value="NSA",
        dist_name="MRBTS-10031/NRBTS-10031/NRCELL-1/NRREL-2",
        p_name="plmnMode",
    ),
    dict(
        value="NSA",
        dist_name="MRBTS-10031/NRBTS-10031/NRCELL-2/NRREL-2",
        p_name="cellDepType",
    ),
    dict(
        value="NSA",
        dist_name="MRBTS-10031/NRBTS-10031/NRCELL-2/NRREL-2",
        p_name="plmnMode",
    ),
    dict(
        value="NSA", dist_name="MRBTS-10031/NRBTS-10031/NRCELL-3", p_name="cellDepType"
    ),
    dict(value="NSA", dist_name="MRBTS-1903/NRBTS-3/NRCELL-3", p_name="cellDepType"),
    dict(value="true", dist_name="MRBTS-1903/NRBTS-3", p_name="actIntraFreqHoSA"),
    dict(value="false", dist_name="MRBTS-1903/NRBTS-3", p_name="actGnbInitRlf"),
    dict(
        value="true",
        dist_name="MRBTS-1903/NRBTS-3",
        p_name="actInterFreqIntraGnbMobilityNSA",
    ),
    dict(value="true", dist_name="MRBTS-1903/NRBTS-3", p_name="actIntraMeNBMobility"),
    dict(value="15min", dist_name="MRBTS-1903/NRBTS-3/NRPMRNL-1", p_name="miNrRSACU"),
    dict(value="15min", dist_name="MRBTS-1903/NRBTS-3/NRPMRNL-1", p_name="miNrRSADU"),
    dict(value="15min", dist_name="MRBTS-1903/NRBTS-3/NRPMRNL-1", p_name="miNrRSANB"),
    dict(
        value="15min",
        dist_name="MRBTS-1903/NRBTS-3/NRPMRNL-1",
        p_name="miNrRelReportCu",
    ),
    dict(value="rsrp", dist_name="MRBTS-1903/NRBTS-3/NRCELL-1", p_name="a3MeasEnabled"),
    dict(
        value="70",
        dist_name="MRBTS-1903/NRBTS-3/NRCELL-1",
        p_name="absThreshSsbRsrpConsolidation",
    ),
    dict(
        value="100", dist_name="MRBTS-1903/NRBTS-3/NRCELL-1", p_name="ccLoadThreshold"
    ),
    #    dict(value='7880', dist_name='MRBTS-1903/NRBTS-3/NRCELL-1', p_name='gscn'),
    #    dict(value='636666', dist_name='MRBTS-1903/NRBTS-3/NRCELL-1', p_name='nrarfcn'),
    dict(value="51", dist_name="MRBTS-1903/NRBTS-3/NRCELL-1", p_name="physCellId"),
    dict(
        value="20",
        dist_name="MRBTS-1903/NRBTS-3/NRCELL-1",
        p_name="rlpRecDlHarqThreshold",
    ),
    dict(
        value="SA+NSA",
        dist_name="MRBTS-1903/NRBTS-3/NRCELL-1/NRREL-1",
        p_name="cellDepType",
    ),
    dict(
        value="0dB",
        dist_name="MRBTS-1903/NRBTS-3/NRCELL-1/NRREL-1",
        p_name="cellIndividualSsbRsrpOffset",
    ),
    dict(
        value="0dB",
        dist_name="MRBTS-1903/NRBTS-3/NRCELL-1/NRREL-1",
        p_name="cellIndividualSsbRsrqOffset",
    ),
    #    dict(value='200', dist_name='MRBTS-1903/NRBTS-3/NRCELL-1/NRREL-1', p_name='fiveGsTac'),
    #    dict(value='3', dist_name='MRBTS-1903/NRBTS-3/NRCELL-1/NRREL-1', p_name='gNbId'),
    dict(
        value="32",
        dist_name="MRBTS-1903/NRBTS-3/NRCELL-1/NRREL-1",
        p_name="gNbIdLength",
    ),
    dict(value="2", dist_name="MRBTS-1903/NRBTS-3/NRCELL-1/NRREL-1", p_name="lcrId"),
    #    dict(value='636666', dist_name='MRBTS-1903/NRBTS-3/NRCELL-1/NRREL-1', p_name='nrarfcn'),
    dict(
        value="52", dist_name="MRBTS-1903/NRBTS-3/NRCELL-1/NRREL-1", p_name="physCellId"
    ),
    dict(
        value="NSA",
        dist_name="MRBTS-1903/NRBTS-3/NRCELL-1/NRREL-2",
        p_name="cellDepType",
    ),
    dict(
        value="0dB",
        dist_name="MRBTS-1903/NRBTS-3/NRCELL-1/NRREL-2",
        p_name="cellIndividualSsbRsrpOffset",
    ),
    dict(
        value="0dB",
        dist_name="MRBTS-1903/NRBTS-3/NRCELL-1/NRREL-2",
        p_name="cellIndividualSsbRsrqOffset",
    ),
    #    dict(value='200', dist_name='MRBTS-1903/NRBTS-3/NRCELL-1/NRREL-2', p_name='fiveGsTac'),
    #    dict(value='3', dist_name='MRBTS-1903/NRBTS-3/NRCELL-1/NRREL-2', p_name='gNbId'),
    dict(
        value="32",
        dist_name="MRBTS-1903/NRBTS-3/NRCELL-1/NRREL-2",
        p_name="gNbIdLength",
    ),
    dict(value="3", dist_name="MRBTS-1903/NRBTS-3/NRCELL-1/NRREL-2", p_name="lcrId"),
    #    dict(value='636666', dist_name='MRBTS-1903/NRBTS-3/NRCELL-1/NRREL-2', p_name='nrarfcn'),
    dict(
        value="53", dist_name="MRBTS-1903/NRBTS-3/NRCELL-1/NRREL-2", p_name="physCellId"
    ),
    dict(value="rsrp", dist_name="MRBTS-1903/NRBTS-3/NRCELL-2", p_name="a3MeasEnabled"),
    dict(
        value="70",
        dist_name="MRBTS-1903/NRBTS-3/NRCELL-2",
        p_name="absThreshSsbRsrpConsolidation",
    ),
    dict(
        value="100", dist_name="MRBTS-1903/NRBTS-3/NRCELL-2", p_name="ccLoadThreshold"
    ),
    #    dict(value='7880', dist_name='MRBTS-1903/NRBTS-3/NRCELL-2', p_name='gscn'),
    #    dict(value='636666', dist_name='MRBTS-1903/NRBTS-3/NRCELL-2', p_name='nrarfcn'),
    dict(value="52", dist_name="MRBTS-1903/NRBTS-3/NRCELL-2", p_name="physCellId"),
    dict(
        value="20",
        dist_name="MRBTS-1903/NRBTS-3/NRCELL-2",
        p_name="rlpRecDlHarqThreshold",
    ),
    dict(
        value="SA+NSA",
        dist_name="MRBTS-1903/NRBTS-3/NRCELL-2/NRREL-1",
        p_name="cellDepType",
    ),
    dict(
        value="0dB",
        dist_name="MRBTS-1903/NRBTS-3/NRCELL-2/NRREL-1",
        p_name="cellIndividualSsbRsrpOffset",
    ),
    dict(
        value="0dB",
        dist_name="MRBTS-1903/NRBTS-3/NRCELL-2/NRREL-1",
        p_name="cellIndividualSsbRsrqOffset",
    ),
    #    dict(value='200', dist_name='MRBTS-1903/NRBTS-3/NRCELL-2/NRREL-1', p_name='fiveGsTac'),
    #    dict(value='3', dist_name='MRBTS-1903/NRBTS-3/NRCELL-2/NRREL-1', p_name='gNbId'),
    dict(
        value="32",
        dist_name="MRBTS-1903/NRBTS-3/NRCELL-2/NRREL-1",
        p_name="gNbIdLength",
    ),
    dict(value="1", dist_name="MRBTS-1903/NRBTS-3/NRCELL-2/NRREL-1", p_name="lcrId"),
    dict(
        value="636666",
        dist_name="MRBTS-1903/NRBTS-3/NRCELL-2/NRREL-1",
        p_name="nrarfcn",
    ),
    dict(
        value="51", dist_name="MRBTS-1903/NRBTS-3/NRCELL-2/NRREL-1", p_name="physCellId"
    ),
    dict(
        value="NSA",
        dist_name="MRBTS-1903/NRBTS-3/NRCELL-2/NRREL-2",
        p_name="cellDepType",
    ),
    dict(
        value="0dB",
        dist_name="MRBTS-1903/NRBTS-3/NRCELL-2/NRREL-2",
        p_name="cellIndividualSsbRsrpOffset",
    ),
    dict(
        value="0dB",
        dist_name="MRBTS-1903/NRBTS-3/NRCELL-2/NRREL-2",
        p_name="cellIndividualSsbRsrqOffset",
    ),
    #    dict(value='200', dist_name='MRBTS-1903/NRBTS-3/NRCELL-2/NRREL-2', p_name='fiveGsTac'),
    #    dict(value='3', dist_name='MRBTS-1903/NRBTS-3/NRCELL-2/NRREL-2', p_name='gNbId'),
    dict(
        value="32",
        dist_name="MRBTS-1903/NRBTS-3/NRCELL-2/NRREL-2",
        p_name="gNbIdLength",
    ),
    dict(value="3", dist_name="MRBTS-1903/NRBTS-3/NRCELL-2/NRREL-2", p_name="lcrId"),
    #    dict(value='636666', dist_name='MRBTS-1903/NRBTS-3/NRCELL-2/NRREL-2', p_name='nrarfcn'),
    dict(
        value="53", dist_name="MRBTS-1903/NRBTS-3/NRCELL-2/NRREL-2", p_name="physCellId"
    ),
    dict(value="rsrp", dist_name="MRBTS-1903/NRBTS-3/NRCELL-3", p_name="a3MeasEnabled"),
    dict(
        value="70",
        dist_name="MRBTS-1903/NRBTS-3/NRCELL-3",
        p_name="absThreshSsbRsrpConsolidation",
    ),
    dict(
        value="100", dist_name="MRBTS-1903/NRBTS-3/NRCELL-3", p_name="ccLoadThreshold"
    ),
    #    dict(value='7880', dist_name='MRBTS-1903/NRBTS-3/NRCELL-3', p_name='gscn'),
    #    dict(value='636666', dist_name='MRBTS-1903/NRBTS-3/NRCELL-3', p_name='nrarfcn'),
    dict(value="53", dist_name="MRBTS-1903/NRBTS-3/NRCELL-3", p_name="physCellId"),
    dict(
        value="20",
        dist_name="MRBTS-1903/NRBTS-3/NRCELL-3",
        p_name="rlpRecDlHarqThreshold",
    ),
]

PARAMS_TO_DELETE_900_D_012 = [
    dict(dist_name="MRBTS-1903/NRBTS-3/NRCELL-3", p_name="trackingAreaDN")
]

ADD_MOs_900_D_012 = [
    #    dict(class_name='com.nokia.srbts.nrbts:NRREL', dist_name='MRBTS-1903/NRBTS-3/NRCELL-1/NRREL-1',
    #        version='NRBTSCL5G20A_2003_200'),
    #    dict(class_name='com.nokia.srbts.nrbts:NRREL', dist_name='MRBTS-1903/NRBTS-3/NRCELL-1/NRREL-2',
    #         version='NRBTSCL5G20A_2003_200'),
    #    dict(class_name='com.nokia.srbts.nrbts:NRREL', dist_name='MRBTS-1903/NRBTS-3/NRCELL-2/NRREL-1',
    #         version='NRBTSCL5G20A_2003_200'),
    #    dict(class_name='com.nokia.srbts.nrbts:NRREL', dist_name='MRBTS-1903/NRBTS-3/NRCELL-2/NRREL-2',
    #         version='NRBTSCL5G20A_2003_200'),
]

ADD_TO_List_900_D_012 = [
    #    dict(dist_name='MRBTS-1903/NRBTS-3/NRCELL-1', list_name='a3MeasSsbRsrp',
    #         elements=dict(a3HysteresisSsbRsrp='0', a3OffsetSsbRsrp='-10', a3TimeToTriggerSsbRsrp='ms0')),
    dict(
        dist_name="MRBTS-1903/NRBTS-3/NRCELL-1",
        list_name="pciBlackList",
        elements=dict(pciRangeValidity="NSA", physCellId="52", range="n4"),
    ),
    #    dict(dist_name='MRBTS-1903/NRBTS-3/NRCELL-1/NRREL-1', list_name='gnbPlmn',
    #         elements=dict(mcc='460', mnc='2', mncLength='2')),
    #    dict(dist_name='MRBTS-1903/NRBTS-3/NRCELL-1/NRREL-1', list_name='plmnList',
    #         elements=dict(mcc='460', mnc='2', mncLength='2',plmnMode='both')),
    #    dict(dist_name='MRBTS-1903/NRBTS-3/NRCELL-1/NRREL-2', list_name='gnbPlmn',
    #         elements=dict(mcc='460', mnc='2', mncLength='2')),
    #    dict(dist_name='MRBTS-1903/NRBTS-3/NRCELL-1/NRREL-2', list_name='plmnList',
    #         elements=dict(mcc='460', mnc='2', mncLength='2', plmnMode='NSA')),
    #    dict(dist_name='MRBTS-1903/NRBTS-3/NRCELL-2', list_name='a3MeasSsbRsrp',
    #         elements=dict(a3HysteresisSsbRsrp='3', a3OffsetSsbRsrp='0', a3TimeToTriggerSsbRsrp='ms0')),
    dict(
        dist_name="MRBTS-1903/NRBTS-3/NRCELL-2",
        list_name="pciBlackList",
        elements=dict(pciRangeValidity="NSA", physCellId="51", range="n4"),
    ),
    #    dict(dist_name='MRBTS-1903/NRBTS-3/NRCELL-2/NRREL-1', list_name='gnbPlmn',
    #         elements=dict(mcc='460', mnc='2', mncLength='2')),
    #    dict(dist_name='MRBTS-1903/NRBTS-3/NRCELL-2/NRREL-1', list_name='plmnList',
    #         elements=dict(mcc='460', mnc='2', mncLength='2', plmnMode='both')),
    #    dict(dist_name='MRBTS-1903/NRBTS-3/NRCELL-2/NRREL-2', list_name='gnbPlmn',
    #         elements=dict(mcc='460', mnc='2', mncLength='2')),
    #    dict(dist_name='MRBTS-1903/NRBTS-3/NRCELL-2/NRREL-2', list_name='plmnList',
    #         elements=dict(mcc='460', mnc='2', mncLength='2', plmnMode='NSA')),
    #    dict(dist_name='MRBTS-1903/NRBTS-3/NRCELL-3', list_name='a3MeasSsbRsrp',
    #         elements=dict(a3HysteresisSsbRsrp='2', a3OffsetSsbRsrp='0', a3TimeToTriggerSsbRsrp='ms0')),
]
