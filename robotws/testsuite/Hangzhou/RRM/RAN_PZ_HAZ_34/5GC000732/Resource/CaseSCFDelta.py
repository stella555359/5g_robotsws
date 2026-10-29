import os

__team__ = "MN 5G RAN I&V 4 Pz HZG SG1"
__email__ = "I_MN_5G_RAN_IV4_LINE_HZG_1@internal.nsn.com"


# modify 5GC000732_A_03 SCF #
PARAMS_TO_MODIFY_732_A_03 = [
    dict(
        value="5GC000732_A_03",
        dist_name="MRBTS-10035",
        p_name="btsName",
    ),
    dict(
        value="false",
        dist_name="MRBTS-10035/NRBTS-10035",
        p_name="actGnbInitRlf",
    ),
    dict(value="false", dist_name="MRBTS-10035/NRBTS-10035/NRCELL-2", p_name="actCDrx"),
    dict(value="false", dist_name="MRBTS-10035/NRBTS-10035/NRCELL-2", p_name="actCDrxVoNR"),
    dict(
        value="60",
        dist_name="MRBTS-10035/NRBTS-10035",
        p_name="drbInactivityTimerSA5qi1",
    ),
    dict(
        value="60",
        dist_name="MRBTS-10035/NRBTS-10035",
        p_name="drbInactivityTimerSA5qi5",
    ),
    dict(value="60", dist_name="MRBTS-10035/NRBTS-10035", p_name="inactivityTimerSA"),
    dict(
        value="sameGNB", dist_name="MRBTS-10035/NRBTS-10035", p_name="rrcReestabTypeSA"
    ),
    dict(value="30000ms", dist_name="MRBTS-10035/NRBTS-10035", p_name="t311"),
    # dict(value="2000ms", dist_name="MRBTS-10035/NRBTS-10035", p_name="tRLFindForDU"),
    dict(value="60", dist_name="MRBTS-10035/NRBTS-10035", p_name="inactivityTimerSA"),
    dict(
        value="0",
        dist_name="MRBTS-10035/NRBTS-10035/NRCELL-2",
        p_name="rlpDetCsiBsiThreshold",
    ),
    dict(value="10000ms", dist_name="MRBTS-10035/NRBTS-10035", p_name="tWaitingRlRecover"),
    dict(value="2000ms", dist_name="MRBTS-10035/NRBTS-10035/NRCELL-2", p_name="t301"),
    dict(value="30000ms", dist_name="MRBTS-10035/NRBTS-10035/NRCELL-2", p_name="t311"),
    dict(
        value="t32",
        dist_name="MRBTS-10035/NRBTS-10035/NRDRB_RLC_AM-1",
        p_name="dlMaxRetxThreshold",
    ),
    dict(
        value="t1",
        dist_name="MRBTS-10035/NRBTS-10035/NRDRB_RLC_AM-1",
        p_name="ulMaxRetxThreshold",
    ),
    dict(
        value="t32",
        dist_name="MRBTS-10035/NRBTS-10035/NRDRB_RLC_AM-2",
        p_name="dlMaxRetxThreshold",
    ),
    dict(
        value="t1",
        dist_name="MRBTS-10035/NRBTS-10035/NRDRB_RLC_AM-2",
        p_name="ulMaxRetxThreshold",
    ),
    dict(
        value="15min",
        dist_name="MRBTS-10035/NRBTS-10035/NRPMRNL-1",
        p_name="miNrRRCC",
    ),
    dict(
        value="15min",
        dist_name="MRBTS-10035/NRBTS-10035/NRPMRNL-1",
        p_name="miNrNGCC",
    ),
    dict(
        value="15min",
        dist_name="MRBTS-10035/NRBTS-10035/NRPMRNL-1",
        p_name="miNrRRCD",
    ),
]

PARAMS_TO_DELETE_732_A_03 = []

ADD_MOs_732_A_03 = []


LIST_TO_ADD_732_A_03 = []

LIST_PARAMS_TO_MODIFY_732_A_03 = [
    dict(
        dist_name="MRBTS-10035/NRBTS-10035",
        list_name="srb1RlcAmProf",
        elements=[
            dict(p_name="dlMaxRetxThreshold", value="t32", index=0),
            dict(p_name="ulMaxRetxThreshold", value="t1", index=0),
        ],
    ),
    dict(
        dist_name="MRBTS-10035/NRBTS-10035",
        list_name="srb2RlcAmProf",
        elements=[
            dict(p_name="dlMaxRetxThreshold", value="t32", index=0),
            dict(p_name="ulMaxRetxThreshold", value="t1", index=0),
        ],
    ),
    dict(
        dist_name="MRBTS-10035/NRBTS-10035",
        list_name="srb3RlcAmProf",
        elements=[
            dict(p_name="dlMaxRetxThreshold", value="t32", index=0),
            dict(p_name="ulMaxRetxThreshold", value="t1", index=0),
        ],
    ),
]

# modify 5GC000732_F_02 SCF #
PARAMS_TO_MODIFY_732_F_02 = [
    dict(
        value="5GC000732_F_02",
        dist_name="MRBTS-10035",
        p_name="btsName",
    ),
    dict(
        value="false",
        dist_name="MRBTS-10035/NRBTS-10035",
        p_name="actGnbInitRlf",
    ),
    # dict(value="false", dist_name="MRBTS-10035/NRBTS-10035/NRCELL-1", p_name="actCDrx"),
    dict(
        value="60",
        dist_name="MRBTS-10035/NRBTS-10035",
        p_name="drbInactivityTimerSA5qi1",
    ),
    dict(
        value="60",
        dist_name="MRBTS-10035/NRBTS-10035",
        p_name="drbInactivityTimerSA5qi5",
    ),
    dict(value="60", dist_name="MRBTS-10035/NRBTS-10035", p_name="inactivityTimerSA"),
    dict(
        value="sameGNB", dist_name="MRBTS-10035/NRBTS-10035", p_name="rrcReestabTypeSA"
    ),
    dict(value="30000ms", dist_name="MRBTS-10035/NRBTS-10035", p_name="t311"),
    # dict(value="2000ms", dist_name="MRBTS-10035/NRBTS-10035", p_name="tRLFindForDU"),
    dict(value="60", dist_name="MRBTS-10035/NRBTS-10035", p_name="inactivityTimerSA"),
    dict(
        value="0",
        dist_name="MRBTS-10035/NRBTS-10035/NRCELL-2",
        p_name="rlpDetCsiBsiThreshold",
    ),
    dict(value="10000ms", dist_name="MRBTS-10035/NRBTS-10035", p_name="tWaitingRlRecover"),
    dict(value="2000ms", dist_name="MRBTS-10035/NRBTS-10035/NRCELL-2", p_name="t301"),
    dict(value="30000ms", dist_name="MRBTS-10035/NRBTS-10035/NRCELL-2", p_name="t311"),
    dict(
        value="t32",
        dist_name="MRBTS-10035/NRBTS-10035/NRDRB_RLC_AM-1",
        p_name="dlMaxRetxThreshold",
    ),
    dict(
        value="t1",
        dist_name="MRBTS-10035/NRBTS-10035/NRDRB_RLC_AM-1",
        p_name="ulMaxRetxThreshold",
    ),
    dict(
        value="t32",
        dist_name="MRBTS-10035/NRBTS-10035/NRDRB_RLC_AM-2",
        p_name="dlMaxRetxThreshold",
    ),
    dict(
        value="t1",
        dist_name="MRBTS-10035/NRBTS-10035/NRDRB_RLC_AM-2",
        p_name="ulMaxRetxThreshold",
    ),
    dict(
        value="15min",
        dist_name="MRBTS-10035/NRBTS-10035/NRPMRNL-1",
        p_name="miNrRRCC",
    ),
    dict(
        value="15min",
        dist_name="MRBTS-10035/NRBTS-10035/NRPMRNL-1",
        p_name="miNrNGCC",
    ),
    dict(
        value="15min",
        dist_name="MRBTS-10035/NRBTS-10035/NRPMRNL-1",
        p_name="miNrRRCD",
    ),
    # MG related
    dict(
        value="-65",
        dist_name="MRBTS-10035/NRBTS-10035/NRCELL-2",
        p_name="qRxLevMin",
    ),
    dict(
        value="rsrp",
        dist_name="MRBTS-10035/NRBTS-10035/NRCELL-2",
        p_name="a2MeashoEnabledSA",
    ),
    dict(
        value="rsrp",
        dist_name="MRBTS-10035/NRBTS-10035/NRCELL-2",
        p_name="a1MeashoEnabledSA",
    ),
    dict(value="true", dist_name="MRBTS-10035/NRBTS-10035", p_name="actInterFreqHoSA"),
    dict(
        value="favourUeThroughput",
        dist_name="MRBTS-10035/NRBTS-10035/NRCELL-2",
        p_name="measGapSelectionSA",
    ),
    dict(
        value="250", dist_name="MRBTS-10035/NRBTS-10035", p_name="timerXnDataFwdGuard"
    ),
    dict(
        value="15min",
        dist_name="MRBTS-10035/NRBTS-10035/NRPMRNL-1",
        p_name="miNrRelReportCu",
    ),
    # MG HOIF related
    dict(
        value="false",
        dist_name="MRBTS-10035/NRBTS-10035/NRCELL-2/NRHOIF-1",
        p_name="a1BasedPCellSwitchEnabled",
    ),
    dict(
        value="false",
        dist_name="MRBTS-10035/NRBTS-10035/NRCELL-2/NRHOIF-1",
        p_name="a2BasedPCellSwitchEnabled",
    ),
    dict(
        value="rsrp",
        dist_name="MRBTS-10035/NRBTS-10035/NRCELL-2/NRHOIF-1",
        p_name="a3MeasEnabled",
    ),
    dict(
        value="none",
        dist_name="MRBTS-10035/NRBTS-10035/NRCELL-2/NRHOIF-1",
        p_name="a4MeasHigherPrioFreqEnabled",
    ),
    dict(
        value="none",
        dist_name="MRBTS-10035/NRBTS-10035/NRCELL-2/NRHOIF-1",
        p_name="a5MeasEnabled",
    ),
    dict(
        value="none",
        dist_name="MRBTS-10035/NRBTS-10035/NRCELL-2/NRHOIF-1",
        p_name="a4MeasEnDcSteeringEnabled",
    ),
    dict(
        value="none",
        dist_name="MRBTS-10035/NRBTS-10035/NRCELL-2/NRHOIF-1",
        p_name="a4MeasNrDcEnabled",
    ),
    dict(
        value="SA+NSA",
        dist_name="MRBTS-10035/NRBTS-10035/NRCELL-2/NRHOIF-1",
        p_name="cellDepType",
    ),
    dict(
        value="78",
        dist_name="MRBTS-10035/NRBTS-10035/NRCELL-2/NRHOIF-1",
        p_name="freqBandIndicatorNR",
    ),
    dict(
        value="30 KHz",
        dist_name="MRBTS-10035/NRBTS-10035/NRCELL-2/NRHOIF-1",
        p_name="ifhoSsbScs",
    ),
    dict(
        value="sf1",
        dist_name="MRBTS-10035/NRBTS-10035/NRCELL-2/NRHOIF-1",
        p_name="ifhoSsbSmtcDuration",
    ),
    dict(
        value="sf5",
        dist_name="MRBTS-10035/NRBTS-10035/NRCELL-2/NRHOIF-1",
        p_name="ifhoSsbSmtcPeriodicity",
    ),
    dict(
        value="1 beam",
        dist_name="MRBTS-10035/NRBTS-10035/NRCELL-2/NRHOIF-1",
        p_name="numberOfTransmittedSsBlocks",
    ),
    dict(
        value="30 KHz",
        dist_name="MRBTS-10035/NRBTS-10035/NRCELL-2/NRHOIF-1",
        p_name="scs",
    ),
    dict(
        value="20",
        dist_name="MRBTS-10035/NRBTS-10035/NRCELL-2/NRHOIF-1",
        p_name="ssBurstSetPeriod",
    ),
    dict(
        value="633700",
        dist_name="MRBTS-10035/NRBTS-10035/NRCELL-2/NRHOIF-1",
        p_name="ssbFrequency",
    ),
]

PARAMS_TO_DELETE_732_F_02 = [
    # MG related
    dict(
        dist_name="MRBTS-10035/NRBTS-10035/NRCELL-2",
        list_name="a1MeashoSsbRsrpSA",
    ),
    dict(
        dist_name="MRBTS-10035/NRBTS-10035/NRCELL-2",
        list_name="a2MeashoSsbRsrpSA",
    ),
    dict(
        dist_name="MRBTS-10035/NRBTS-10035/NRCELL-2/NRHOIF-1",
    ),
]

ADD_MOs_732_F_02 = [
    dict(
        class_name="com.nokia.srbts.nrbts:NRHOIF",
        dist_name="MRBTS-10035/NRBTS-10035/NRCELL-2/NRHOIF-1",
        version="NRBTSCL5G21B_2105_200",
    ),
]

LIST_TO_ADD_732_F_02 = [
    # MG related
    dict(
        dist_name="MRBTS-10035/NRBTS-10038/NRCELL-2",
        list_name="a2MeashoSsbRsrpSA",
        elements=dict(
            a2HysteresishoSsbRsrpSA="15",
            a2ThresholdhoSsbRsrpSA="127",
            a2TimeToTriggerhoSsbRsrpSA="ms100",
        ),
    ),
    dict(
        dist_name="MRBTS-10035/NRBTS-10038/NRCELL-2",
        list_name="a1MeashoSsbRsrpSA",
        elements=dict(
            a1HysteresishoSsbRsrpSA="15",
            a1ThresholdhoSsbRsrpSA="127",
            a1TimeToTriggerhoSsbRsrpSA="ms100",
        ),
    ),
    # MG HOIF related
    dict(
        dist_name="MRBTS-10035/NRBTS-10035/NRCELL-2/NRHOIF-1",
        list_name="a3MeasSsbRsrp",
        elements=dict(
            a3HysteresisSsbRsrp="0",
            a3OffsetSsbRsrp="13",
            a3TimeToTriggerSsbRsrp="ms256",
        ),
    ),
    dict(
        dist_name="MRBTS-10035/NRBTS-10035/NRCELL-2/NRHOIF-1",
        list_name="a5MeasSsbRsrp",
        elements=dict(
            a5HysteresisSsbRsrp="0",
            a5Threshold1SsbRsrp="100",
            a5Threshold2SsbRsrp="57",
            a5TimeToTriggerSsbRsrp="ms320",
        ),
    ),
]

LIST_PARAMS_TO_MODIFY_732_F_02 = [
    dict(
        dist_name="MRBTS-10035/NRBTS-10035",
        list_name="srb1RlcAmProf",
        elements=[
            dict(p_name="dlMaxRetxThreshold", value="t32", index=0),
            dict(p_name="ulMaxRetxThreshold", value="t1", index=0),
        ],
    ),
    dict(
        dist_name="MRBTS-10035/NRBTS-10035",
        list_name="srb2RlcAmProf",
        elements=[
            dict(p_name="dlMaxRetxThreshold", value="t32", index=0),
            dict(p_name="ulMaxRetxThreshold", value="t1", index=0),
        ],
    ),
    dict(
        dist_name="MRBTS-10035/NRBTS-10035",
        list_name="srb3RlcAmProf",
        elements=[
            dict(p_name="dlMaxRetxThreshold", value="t32", index=0),
            dict(p_name="ulMaxRetxThreshold", value="t1", index=0),
        ],
    ),
]
