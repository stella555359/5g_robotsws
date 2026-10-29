import os

__team__ = "MN 5G RAN I&V 4 Pz HZG SG1"
__email__ = "I_MN_5G_RAN_IV4_LINE_HZG_1@internal.nsn.com"


# modify CB008131_A_01 SCF #
PARAMS_TO_MODIFY_8131_A_01 = [
    dict(
        value="true", dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1", p_name="actAperCsi"
    ),
    dict(value="false", dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1", p_name="actCDrx"),
    dict(
        value="none",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1",
        p_name="a2MeashoEnabledSA",
    ),
    # dict(value='4x4 or 4x2 Closed Loop Spatial Multiplexing', dist_name='MRBTS-10037/NRBTS-10037/NRCELL-1',
    # p_name='dlMimoMode'),
    dict(
        value="longPucch",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1",
        p_name="pucchModeSelect",
    ),
    dict(
        value="false",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1",
        p_name="actUlDftSOfdm",
    ),
    dict(
        value="20",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELLGRP-0",
        p_name="ssBurstSetPeriod",
    ),
    dict(
        value="7",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1",
        p_name="msg1FrequencyStart",
    ),
    # dict(value='4DL4UL', dist_name='MRBTS-10037/NRBTS-10037/NRCELL-1', p_name='nrCellType'),
    dict(
        value="true", dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1", p_name="actDl256Qam"
    ),
    dict(
        value="true", dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1", p_name="actUl256Qam"
    ),
    dict(
        value="6",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1",
        p_name="type0CoresetConfigurationIndex",
    ),
    dict(
        value="pos2",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1",
        p_name="dmrsTypeAPosition",
    ),
    dict(
        value="true",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1",
        p_name="actPdschAtSsbSlots",
    ),
    dict(
        value="20MHz",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1/NRCELL_FDD-1",
        p_name="chBwDl",
    ),
    dict(
        value="20MHz",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1/NRCELL_FDD-1",
        p_name="chBwUl",
    ),
    dict(
        value="true", dist_name="MRBTS-10037/NRBTS-10037/NRCELL-2", p_name="actAperCsi"
    ),
    dict(value="false", dist_name="MRBTS-10037/NRBTS-10037/NRCELL-2", p_name="actCDrx"),
    dict(
        value="none",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-2",
        p_name="a2MeashoEnabledSA",
    ),
    # dict(value='4x4 or 4x2 Closed Loop Spatial Multiplexing', dist_name='MRBTS-10037/NRBTS-10037/NRCELL-2',
    # p_name='dlMimoMode'),
    dict(
        value="longPucch",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-2",
        p_name="pucchModeSelect",
    ),
    dict(
        value="false",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-2",
        p_name="actUlDftSOfdm",
    ),
    dict(
        value="20",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELLGRP-1",
        p_name="ssBurstSetPeriod",
    ),
    dict(
        value="7",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-2",
        p_name="msg1FrequencyStart",
    ),
    # dict(value='4DL4UL', dist_name='MRBTS-10037/NRBTS-10037/NRCELL-2', p_name='nrCellType'),
    dict(
        value="true", dist_name="MRBTS-10037/NRBTS-10037/NRCELL-2", p_name="actDl256Qam"
    ),
    dict(
        value="true", dist_name="MRBTS-10037/NRBTS-10037/NRCELL-2", p_name="actUl256Qam"
    ),
    dict(
        value="6",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-2",
        p_name="type0CoresetConfigurationIndex",
    ),
    dict(
        value="pos2",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-2",
        p_name="dmrsTypeAPosition",
    ),
    dict(
        value="true",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-2",
        p_name="actPdschAtSsbSlots",
    ),
    dict(
        value="20MHz",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-2/NRCELL_FDD-1",
        p_name="chBwDl",
    ),
    dict(
        value="20MHz",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-2/NRCELL_FDD-1",
        p_name="chBwUl",
    ),
    # CA related
    dict(
        value="MixedCAMode",
        dist_name="MRBTS-10037/NRBTS-10037/NRDU-1",
        p_name="flexibleCAMode",
    ),
    dict(
        value="bufferBased",
        dist_name="MRBTS-10037/NRBTS-10037",
        p_name="sCellActivationMethod",
    ),
    dict(
        value="rsrp",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1",
        p_name="a1MeasSCellAddEnabled",
    ),
    dict(
        value="0dB",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1/NRREL-1",
        p_name="cellIndividualSsbRsrpOffset",
    ),
    dict(
        value="0dB",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1/NRREL-1",
        p_name="cellIndividualSsbRsrqOffset",
    ),
    # dict(
    #     value="10037",
    #     dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1/NRREL-1",
    #     p_name="gNbId",
    # ),
    dict(
        value="32",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1/NRREL-1",
        p_name="gNbIdLength",
    ),
    dict(
        value="allowed",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1/NRREL-1",
        p_name="handoverAllowedSA",
    ),
    dict(
        value="2", dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1/NRREL-1", p_name="lcrId"
    ),
    dict(
        value="false",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1/NRREL-1",
        p_name="removeNotAllowed",
    ),
    dict(
        value="blind",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1/NRREL-1",
        p_name="sCellAdditionMethod",
    ),
]

PARAMS_TO_DELETE_8131_A_01 = [
    # CA related
    # dict(dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1/NRREL-1"),
    dict(
        dist_name="MRBTS-10037/NRBTS-10037/NRDU-1",
        list_name="carrierAggregationSupportList",
    ),
    dict(
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1",
        list_name="allowUnsuppBcOrBcs",
    ),
    dict(
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-2",
        list_name="allowUnsuppBcOrBcs",
    ),
]

ADD_MOs_8131_A_01 = [
    # CA related
    # dict(
    #     class_name="com.nokia.srbts.nrbts:NRREL",
    #     dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1/NRREL-1",
    #     version="NRBTSCL22R2_2111_100",
    # ),
]


LIST_TO_ADD_8131_A_01 = [
    # CA related
    dict(
        dist_name="MRBTS-5/NRBTS-5/NRDU-1",
        list_name="carrierAggregationSupportList",
        elements=["ca_Fdd_Fdd"],
    ),
    dict(
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1",
        list_name="allowUnsuppBcOrBcs",
        elements=["accept unknown band combinations"],
    ),
    dict(
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-2",
        list_name="allowUnsuppBcOrBcs",
        elements=["accept unknown band combinations"],
    ),
    # dict(
    #     dist_name="MRBTS-10038/NRBTS-10038/NRCELL-1/NRREL-1",
    #     list_name="gnbPlmn",
    #     elements=dict(mcc="460", mnc="2", mncLength="2"),
    # ),
]

LIST_PARAMS_TO_MODIFY_8131_A_01 = [
    dict(
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1",
        list_name="periodicCsiAcquisition",
        elements=[dict(p_name="csiReportPeriodicity", value="slots160", index=0)],
    ),
    dict(
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-2",
        list_name="periodicCsiAcquisition",
        elements=[dict(p_name="csiReportPeriodicity", value="slots160", index=0)],
    ),
    # BWP_PROFILE DN2/3----20M--ACSI true---------
    dict(
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1",
        list_name="cellBwpList",
        elements=[
            dict(p_name="bwpDN", value="MRBTS-10037/NRBTS-10037/BWP_PROFILE-3", index=0)
        ],
    ),
    dict(
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1",
        list_name="cellBwpList",
        elements=[
            dict(p_name="bwpDN", value="MRBTS-10037/NRBTS-10037/BWP_PROFILE-4", index=1)
        ],
    ),
    dict(
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-2",
        list_name="cellBwpList",
        elements=[
            dict(p_name="bwpDN", value="MRBTS-10037/NRBTS-10037/BWP_PROFILE-3", index=0)
        ],
    ),
    dict(
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-2",
        list_name="cellBwpList",
        elements=[
            dict(p_name="bwpDN", value="MRBTS-10037/NRBTS-10037/BWP_PROFILE-4", index=1)
        ],
    ),
]

# modify CB008131_A_06 SCF #
PARAMS_TO_MODIFY_8131_A_06 = [
    dict(
        value="true", dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1", p_name="actAperCsi"
    ),
    dict(value="false", dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1", p_name="actCDrx"),
    dict(
        value="none",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1",
        p_name="a2MeashoEnabledSA",
    ),
    # dict(value='4x4 or 4x2 Closed Loop Spatial Multiplexing',
    #   dist_name='MRBTS-10037/NRBTS-10037/NRCELL-1',
    #   p_name='dlMimoMode'),
    dict(
        value="longPucch",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1",
        p_name="pucchModeSelect",
    ),
    dict(
        value="false",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1",
        p_name="actUlDftSOfdm",
    ),
    dict(
        value="20",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELLGRP-0",
        p_name="ssBurstSetPeriod",
    ),
    dict(
        value="7",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1",
        p_name="msg1FrequencyStart",
    ),
    # dict(value='4DL4UL', dist_name='MRBTS-10037/NRBTS-10037/NRCELL-1', p_name='nrCellType'),
    dict(
        value="true", dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1", p_name="actDl256Qam"
    ),
    dict(
        value="true", dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1", p_name="actUl256Qam"
    ),
    dict(
        value="6",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1",
        p_name="type0CoresetConfigurationIndex",
    ),
    dict(
        value="pos2",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1",
        p_name="dmrsTypeAPosition",
    ),
    dict(
        value="true",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1",
        p_name="actPdschAtSsbSlots",
    ),
    dict(
        value="20MHz",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1/NRCELL_FDD-1",
        p_name="chBwDl",
    ),
    dict(
        value="20MHz",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1/NRCELL_FDD-1",
        p_name="chBwUl",
    ),
    dict(
        value="true", dist_name="MRBTS-10037/NRBTS-10037/NRCELL-2", p_name="actAperCsi"
    ),
    dict(value="false", dist_name="MRBTS-10037/NRBTS-10037/NRCELL-2", p_name="actCDrx"),
    dict(
        value="none",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-2",
        p_name="a2MeashoEnabledSA",
    ),
    # dict(
    #   value='4x4 or 4x2 Closed Loop Spatial Multiplexing',
    #   dist_name='MRBTS-10037/NRBTS-10037/NRCELL-2',
    #   p_name='dlMimoMode'),
    dict(
        value="longPucch",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-2",
        p_name="pucchModeSelect",
    ),
    dict(
        value="false",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-2",
        p_name="actUlDftSOfdm",
    ),
    dict(
        value="20",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELLGRP-1",
        p_name="ssBurstSetPeriod",
    ),
    dict(
        value="7",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-2",
        p_name="msg1FrequencyStart",
    ),
    # dict(value='4DL4UL', dist_name='MRBTS-10037/NRBTS-10037/NRCELL-2', p_name='nrCellType'),
    dict(
        value="true", dist_name="MRBTS-10037/NRBTS-10037/NRCELL-2", p_name="actDl256Qam"
    ),
    dict(
        value="true", dist_name="MRBTS-10037/NRBTS-10037/NRCELL-2", p_name="actUl256Qam"
    ),
    dict(
        value="6",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-2",
        p_name="type0CoresetConfigurationIndex",
    ),
    dict(
        value="pos2",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-2",
        p_name="dmrsTypeAPosition",
    ),
    dict(
        value="true",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-2",
        p_name="actPdschAtSsbSlots",
    ),
    dict(
        value="20MHz",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-2/NRCELL_FDD-1",
        p_name="chBwDl",
    ),
    dict(
        value="20MHz",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-2/NRCELL_FDD-1",
        p_name="chBwUl",
    ),
    # CA related
    dict(
        value="MixedCAMode",
        dist_name="MRBTS-10037/NRBTS-10037/NRDU-1",
        p_name="flexibleCAMode",
    ),
    dict(
        value="bufferBased",
        dist_name="MRBTS-10037/NRBTS-10037",
        p_name="sCellActivationMethod",
    ),
    dict(
        value="true",
        dist_name="MRBTS-10037/NRBTS-10037",
        p_name="actMeasBasedSCellAddition",
    ),
    dict(
        value="rsrp",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1",
        p_name="a1MeasSCellAddEnabled",
    ),
    dict(
        value="0dB",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1/NRREL-1",
        p_name="cellIndividualSsbRsrpOffset",
    ),
    dict(
        value="0dB",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1/NRREL-1",
        p_name="cellIndividualSsbRsrqOffset",
    ),
    # dict(
    #     value="10037",
    #     dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1/NRREL-1",
    #     p_name="gNbId",
    # ),
    dict(
        value="32",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1/NRREL-1",
        p_name="gNbIdLength",
    ),
    dict(
        value="allowed",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1/NRREL-1",
        p_name="handoverAllowedSA",
    ),
    dict(
        value="2", dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1/NRREL-1", p_name="lcrId"
    ),
    dict(
        value="false",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1/NRREL-1",
        p_name="removeNotAllowed",
    ),
    dict(
        value="covBasedA1",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1/NRREL-1",
        p_name="sCellAdditionMethod",
    ),
    dict(
        value="rsrp",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-2",
        p_name="a2MeasSCellRelEnabled",
    ),
    # MG related
    dict(
        value="-65",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1",
        p_name="qRxLevMin",
    ),
    dict(
        value="-50",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-2",
        p_name="qRxLevMin",
    ),
    dict(
        value="rsrp",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1",
        p_name="a2MeashoEnabledSA",
    ),
    dict(
        value="rsrp",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1",
        p_name="a1MeashoEnabledSA",
    ),
    dict(value="true", dist_name="MRBTS-10037/NRBTS-10037", p_name="actInterFreqHoSA"),
    dict(
        value="favourUeThroughput",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1",
        p_name="measGapSelectionSA",
    ),
    dict(
        value="250", dist_name="MRBTS-10037/NRBTS-10037", p_name="timerXnDataFwdGuard"
    ),
    dict(
        value="15min",
        dist_name="MRBTS-10037/NRBTS-10037/NRPMRNL-1",
        p_name="miNrRelReportCu",
    ),
    # MG HOIF related
    dict(
        value="false",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1/NRHOIF-1",
        p_name="a1BasedPCellSwitchEnabled",
    ),
    dict(
        value="false",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1/NRHOIF-1",
        p_name="a2BasedPCellSwitchEnabled",
    ),
    dict(
        value="rsrp",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1/NRHOIF-1",
        p_name="a3MeasEnabled",
    ),
    dict(
        value="none",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1/NRHOIF-1",
        p_name="a5MeasEnabled",
    ),
    dict(
        value="SA+NSA",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1/NRHOIF-1",
        p_name="cellDepType",
    ),
    dict(
        value="5",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1/NRHOIF-1",
        p_name="freqBandIndicatorNR",
    ),
    dict(
        value="15KHz",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1/NRHOIF-1",
        p_name="ifhoSsbScs",
    ),
    dict(
        value="sf5",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1/NRHOIF-1",
        p_name="ifhoSsbSmtcDuration",
    ),
    dict(
        value="sf20",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1/NRHOIF-1",
        p_name="ifhoSsbSmtcPeriodicity",
    ),
    dict(
        value="1 beam",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1/NRHOIF-1",
        p_name="numberOfTransmittedSsBlocks",
    ),
    dict(
        value="15 KHz",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1/NRHOIF-1",
        p_name="scs",
    ),
    dict(
        value="20",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1/NRHOIF-1",
        p_name="ssBurstSetPeriod",
    ),
    dict(
        value="156010",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1/NRHOIF-1",
        p_name="ssbFrequency",
    ),
]

PARAMS_TO_DELETE_8131_A_06 = [
    # CA related
    # dict(dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1/NRREL-1"),
    dict(
        dist_name="MRBTS-10037/NRBTS-10038/NRCELL-1", list_name="a1MeasSCellAddSsbRsrp"
    ),
    dict(
        dist_name="MRBTS-10037/NRBTS-10038/NRCELL-2", list_name="a2MeasSCellRelSsbRsrp"
    ),
    dict(
        dist_name="MRBTS-10037/NRBTS-10037/NRDU-1",
        list_name="carrierAggregationSupportList",
    ),
    dict(
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1",
        list_name="allowUnsuppBcOrBcs",
    ),
    dict(
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-2",
        list_name="allowUnsuppBcOrBcs",
    ),
    # MG related
    dict(
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1",
        list_name="a1MeashoSsbRsrpSA",
    ),
    dict(
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1",
        list_name="a2MeashoSsbRsrpSA",
    ),
    dict(
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1/NRHOIF-1",
    ),
]

ADD_MOs_8131_A_06 = [
    # dict(
    #     class_name="com.nokia.srbts.nrbts:NRREL",
    #     dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1/NRREL-1",
    #     version="NRBTSCL22R2_2111_100",
    # ),
    dict(
        class_name="com.nokia.srbts.nrbts:NRHOIF",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1/NRHOIF-1",
        version="NRBTSCL5G21B_2105_200",
    ),
]

LIST_TO_ADD_8131_A_06 = [
    # CA related
    dict(
        dist_name="MRBTS-5/NRBTS-5/NRDU-1",
        list_name="carrierAggregationSupportList",
        elements=["ca_Fdd_Fdd"],
    ),
    dict(
        dist_name="MRBTS-10037/NRBTS-10038/NRCELL-1",
        list_name="a1MeasSCellAddSsbRsrp",
        elements=dict(
            a1HysteresisSCellAddSsbRsrp="0",
            a1ThresholdSCellAddSsbRsrpFDD="80",
            a1TimeToTriggerSCellAddSsbRsrp="100ms",
        ),
    ),
    # dict(
    #     dist_name="MRBTS-10037/NRBTS-10038/NRCELL-1/NRREL-1",
    #     list_name="gnbPlmn",
    #     elements=dict(mcc="460", mnc="2", mncLength="2"),
    # ),
    dict(
        dist_name="MRBTS-10037/NRBTS-10038/NRCELL-2",
        list_name="a2MeasSCellRelSsbRsrp",
        elements=dict(
            a2HysteresisSCellRelSsbRsrp="0",
            a2ThresholdSCellRelSsbRsrp="40",
            a2TimeToTriggerSCellRelSsbRsrp="100ms",
        ),
    ),
    dict(
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1",
        list_name="allowUnsuppBcOrBcs",
        elements=["accept unknown band combinations"],
    ),
    dict(
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-2",
        list_name="allowUnsuppBcOrBcs",
        elements=["accept unknown band combinations"],
    ),
    # MG related
    dict(
        dist_name="MRBTS-10037/NRBTS-10038/NRCELL-1",
        list_name="a2MeashoSsbRsrpSA",
        elements=dict(
            a2HysteresishoSsbRsrpSA="0",
            a2ThresholdhoSsbRsrpSA="70",
            a2TimeToTriggerhoSsbRsrpSA="ms100",
        ),
    ),
    dict(
        dist_name="MRBTS-10037/NRBTS-10038/NRCELL-1",
        list_name="a1MeashoSsbRsrpSA",
        elements=dict(
            a1HysteresishoSsbRsrpSA="0",
            a1ThresholdhoSsbRsrpSA="87",
            a1TimeToTriggerhoSsbRsrpSA="ms100",
        ),
    ),
    # MG HOIF related
    dict(
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1/NRHOIF-1",
        list_name="a3MeasSsbRsrp",
        elements=dict(
            a3HysteresisSsbRsrp="2", a3OffsetSsbRsrp="1", a3TimeToTriggerSsbRsrp="ms256"
        ),
    ),
    dict(
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1/NRHOIF-1",
        list_name="a5MeasSsbRsrp",
        elements=dict(
            a5HysteresisSsbRsrp="0",
            a5Threshold1SsbRsrp="100",
            a5Threshold2SsbRsrp="57",
            a5TimeToTriggerSsbRsrp="ms320",
        ),
    ),
]

LIST_PARAMS_TO_MODIFY_8131_A_06 = [
    dict(
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1",
        list_name="periodicCsiAcquisition",
        elements=[dict(p_name="csiReportPeriodicity", value="slots160", index=0)],
    ),
    dict(
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-2",
        list_name="periodicCsiAcquisition",
        elements=[dict(p_name="csiReportPeriodicity", value="slots160", index=0)],
    ),
    # ----------BWP_PROFILE DN2/3----20M--ACSI true---------
    dict(
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1",
        list_name="cellBwpList",
        elements=[
            dict(p_name="bwpDN", value="MRBTS-10037/NRBTS-10037/BWP_PROFILE-3", index=0)
        ],
    ),
    dict(
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1",
        list_name="cellBwpList",
        elements=[
            dict(p_name="bwpDN", value="MRBTS-10037/NRBTS-10037/BWP_PROFILE-4", index=1)
        ],
    ),
    dict(
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-2",
        list_name="cellBwpList",
        elements=[
            dict(p_name="bwpDN", value="MRBTS-10037/NRBTS-10037/BWP_PROFILE-3", index=0)
        ],
    ),
    dict(
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-2",
        list_name="cellBwpList",
        elements=[
            dict(p_name="bwpDN", value="MRBTS-10037/NRBTS-10037/BWP_PROFILE-4", index=1)
        ],
    ),
]

# modify CB008131_A_09 SCF #
PARAMS_TO_MODIFY_8131_A_09 = [
    dict(
        value="true", dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1", p_name="actAperCsi"
    ),
    dict(value="false", dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1", p_name="actCDrx"),
    dict(
        value="none",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1",
        p_name="a2MeashoEnabledSA",
    ),
    # dict(value='4x4 or 4x2 Closed Loop Spatial Multiplexing',
    #   dist_name='MRBTS-10037/NRBTS-10037/NRCELL-1',
    #   p_name='dlMimoMode'),
    dict(
        value="longPucch",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1",
        p_name="pucchModeSelect",
    ),
    dict(
        value="true",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1",
        p_name="actUlDftSOfdm",
    ),
    dict(
        value="20",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELLGRP-0",
        p_name="ssBurstSetPeriod",
    ),
    dict(
        value="7",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1",
        p_name="msg1FrequencyStart",
    ),
    # dict(value='4DL4UL', dist_name='MRBTS-10037/NRBTS-10037/NRCELL-1', p_name='nrCellType'),
    dict(
        value="true", dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1", p_name="actDl256Qam"
    ),
    dict(
        value="true", dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1", p_name="actUl256Qam"
    ),
    dict(
        value="6",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1",
        p_name="type0CoresetConfigurationIndex",
    ),
    dict(
        value="pos2",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1",
        p_name="dmrsTypeAPosition",
    ),
    dict(
        value="true",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1",
        p_name="actPdschAtSsbSlots",
    ),
    dict(
        value="20MHz",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1/NRCELL_FDD-1",
        p_name="chBwDl",
    ),
    dict(
        value="20MHz",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1/NRCELL_FDD-1",
        p_name="chBwUl",
    ),
    dict(
        value="true", dist_name="MRBTS-10037/NRBTS-10037/NRCELL-2", p_name="actAperCsi"
    ),
    dict(value="false", dist_name="MRBTS-10037/NRBTS-10037/NRCELL-2", p_name="actCDrx"),
    dict(
        value="none",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-2",
        p_name="a2MeashoEnabledSA",
    ),
    # dict(
    #   value='4x4 or 4x2 Closed Loop Spatial Multiplexing',
    #   dist_name='MRBTS-10037/NRBTS-10037/NRCELL-2',
    #   p_name='dlMimoMode'),
    dict(
        value="longPucch",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-2",
        p_name="pucchModeSelect",
    ),
    dict(
        value="false",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-2",
        p_name="actUlDftSOfdm",
    ),
    dict(
        value="20",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELLGRP-1",
        p_name="ssBurstSetPeriod",
    ),
    dict(
        value="7",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-2",
        p_name="msg1FrequencyStart",
    ),
    # dict(value='4DL4UL', dist_name='MRBTS-10037/NRBTS-10037/NRCELL-2', p_name='nrCellType'),
    dict(
        value="true", dist_name="MRBTS-10037/NRBTS-10037/NRCELL-2", p_name="actDl256Qam"
    ),
    dict(
        value="true", dist_name="MRBTS-10037/NRBTS-10037/NRCELL-2", p_name="actUl256Qam"
    ),
    dict(
        value="6",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-2",
        p_name="type0CoresetConfigurationIndex",
    ),
    dict(
        value="pos2",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-2",
        p_name="dmrsTypeAPosition",
    ),
    dict(
        value="true",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-2",
        p_name="actPdschAtSsbSlots",
    ),
    dict(
        value="20MHz",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-2/NRCELL_FDD-1",
        p_name="chBwDl",
    ),
    dict(
        value="20MHz",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-2/NRCELL_FDD-1",
        p_name="chBwUl",
    ),
    # CA related
    dict(
        value="MixedCAMode",
        dist_name="MRBTS-10037/NRBTS-10037/NRDU-1",
        p_name="flexibleCAMode",
    ),
    dict(
        value="bufferBased",
        dist_name="MRBTS-10037/NRBTS-10037",
        p_name="sCellActivationMethod",
    ),
    dict(
        value="true",
        dist_name="MRBTS-10037/NRBTS-10037",
        p_name="actMeasBasedSCellAddition",
    ),
    dict(
        value="rsrp",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1",
        p_name="a1MeasSCellAddEnabled",
    ),
    dict(
        value="0dB",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1/NRREL-1",
        p_name="cellIndividualSsbRsrpOffset",
    ),
    dict(
        value="0dB",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1/NRREL-1",
        p_name="cellIndividualSsbRsrqOffset",
    ),
    # dict(
    #     value="10037",
    #     dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1/NRREL-1",
    #     p_name="gNbId",
    # ),
    dict(
        value="32",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1/NRREL-1",
        p_name="gNbIdLength",
    ),
    dict(
        value="allowed",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1/NRREL-1",
        p_name="handoverAllowedSA",
    ),
    dict(
        value="2", dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1/NRREL-1", p_name="lcrId"
    ),
    dict(
        value="false",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1/NRREL-1",
        p_name="removeNotAllowed",
    ),
    dict(
        value="covBasedA1",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1/NRREL-1",
        p_name="sCellAdditionMethod",
    ),
    dict(
        value="rsrp",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-2",
        p_name="a2MeasSCellRelEnabled",
    ),
]

PARAMS_TO_DELETE_8131_A_09 = [
    # CA related
    # dict(dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1/NRREL-1"),
    dict(
        dist_name="MRBTS-10037/NRBTS-10038/NRCELL-1", list_name="a1MeasSCellAddSsbRsrp"
    ),
    dict(
        dist_name="MRBTS-10037/NRBTS-10038/NRCELL-2", list_name="a2MeasSCellRelSsbRsrp"
    ),
    dict(
        dist_name="MRBTS-10037/NRBTS-10037/NRDU-1",
        list_name="carrierAggregationSupportList",
    ),
    dict(
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1",
        list_name="allowUnsuppBcOrBcs",
    ),
    dict(
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-2",
        list_name="allowUnsuppBcOrBcs",
    ),
]

ADD_MOs_8131_A_09 = [
    # dict(
    #     class_name="com.nokia.srbts.nrbts:NRREL",
    #     dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1/NRREL-1",
    #     version="NRBTSCL22R2_2111_100",
    # ),
]

LIST_TO_ADD_8131_A_09 = [
    # CA related
    dict(
        dist_name="MRBTS-5/NRBTS-5/NRDU-1",
        list_name="carrierAggregationSupportList",
        elements=["ca_Fdd_Fdd"],
    ),
    dict(
        dist_name="MRBTS-10037/NRBTS-10038/NRCELL-1",
        list_name="a1MeasSCellAddSsbRsrp",
        elements=dict(
            a1HysteresisSCellAddSsbRsrp="0",
            a1ThresholdSCellAddSsbRsrpFDD="80",
            a1TimeToTriggerSCellAddSsbRsrp="100ms",
        ),
    ),
    # dict(
    #     dist_name="MRBTS-10037/NRBTS-10038/NRCELL-1/NRREL-1",
    #     list_name="gnbPlmn",
    #     elements=dict(mcc="460", mnc="2", mncLength="2"),
    # ),
    dict(
        dist_name="MRBTS-10037/NRBTS-10038/NRCELL-2",
        list_name="a2MeasSCellRelSsbRsrp",
        elements=dict(
            a2HysteresisSCellRelSsbRsrp="0",
            a2ThresholdSCellRelSsbRsrp="40",
            a2TimeToTriggerSCellRelSsbRsrp="100ms",
        ),
    ),
    dict(
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1",
        list_name="allowUnsuppBcOrBcs",
        elements=["accept unknown band combinations"],
    ),
    dict(
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-2",
        list_name="allowUnsuppBcOrBcs",
        elements=["accept unknown band combinations"],
    ),
]

LIST_PARAMS_TO_MODIFY_8131_A_09 = [
    dict(
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1",
        list_name="periodicCsiAcquisition",
        elements=[dict(p_name="csiReportPeriodicity", value="slots160", index=0)],
    ),
    dict(
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-2",
        list_name="periodicCsiAcquisition",
        elements=[dict(p_name="csiReportPeriodicity", value="slots160", index=0)],
    ),
    dict(
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1",
        list_name="ulTransPrecodeCtl",
        elements=[
            dict(p_name="ulTransPrecodeOffSinrThresh", value="180", index=0),
            dict(p_name="ulTransPrecodeOnSinrThresh", value="160", index=0),
        ],
    ),
    # ----------BWP_PROFILE DN2/3----20M--ACSI true---------
    dict(
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1",
        list_name="cellBwpList",
        elements=[
            dict(p_name="bwpDN", value="MRBTS-10037/NRBTS-10037/BWP_PROFILE-3", index=0)
        ],
    ),
    dict(
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1",
        list_name="cellBwpList",
        elements=[
            dict(p_name="bwpDN", value="MRBTS-10037/NRBTS-10037/BWP_PROFILE-4", index=1)
        ],
    ),
    dict(
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-2",
        list_name="cellBwpList",
        elements=[
            dict(p_name="bwpDN", value="MRBTS-10037/NRBTS-10037/BWP_PROFILE-3", index=0)
        ],
    ),
    dict(
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-2",
        list_name="cellBwpList",
        elements=[
            dict(p_name="bwpDN", value="MRBTS-10037/NRBTS-10037/BWP_PROFILE-4", index=1)
        ],
    ),
]

# modify CB008131_W_01 SCF #
PARAMS_TO_MODIFY_8131_W_01 = [
    dict(
        value="true", dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1", p_name="actAperCsi"
    ),
    dict(value="false", dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1", p_name="actCDrx"),
    dict(
        value="none",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1",
        p_name="a2MeashoEnabledSA",
    ),
    # dict(value='4x4 or 4x2 Closed Loop Spatial Multiplexing', dist_name='MRBTS-10037/NRBTS-10037/NRCELL-1',
    # p_name='dlMimoMode'),
    dict(
        value="longPucch",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1",
        p_name="pucchModeSelect",
    ),
    dict(
        value="false",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1",
        p_name="actUlDftSOfdm",
    ),
    dict(
        value="20",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELLGRP-0",
        p_name="ssBurstSetPeriod",
    ),
    dict(
        value="7",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1",
        p_name="msg1FrequencyStart",
    ),
    # dict(value='4DL4UL', dist_name='MRBTS-10037/NRBTS-10037/NRCELL-1', p_name='nrCellType'),
    dict(
        value="true", dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1", p_name="actDl256Qam"
    ),
    dict(
        value="true", dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1", p_name="actUl256Qam"
    ),
    dict(
        value="6",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1",
        p_name="type0CoresetConfigurationIndex",
    ),
    dict(
        value="pos2",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1",
        p_name="dmrsTypeAPosition",
    ),
    dict(
        value="true",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1",
        p_name="actPdschAtSsbSlots",
    ),
    dict(
        value="20MHz",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1/NRCELL_FDD-1",
        p_name="chBwDl",
    ),
    dict(
        value="20MHz",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1/NRCELL_FDD-1",
        p_name="chBwUl",
    ),
    dict(
        value="true", dist_name="MRBTS-10037/NRBTS-10037/NRCELL-2", p_name="actAperCsi"
    ),
    dict(value="false", dist_name="MRBTS-10037/NRBTS-10037/NRCELL-2", p_name="actCDrx"),
    dict(
        value="none",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-2",
        p_name="a2MeashoEnabledSA",
    ),
    # dict(value='4x4 or 4x2 Closed Loop Spatial Multiplexing', dist_name='MRBTS-10037/NRBTS-10037/NRCELL-2',
    # p_name='dlMimoMode'),
    dict(
        value="longPucch",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-2",
        p_name="pucchModeSelect",
    ),
    dict(
        value="false",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-2",
        p_name="actUlDftSOfdm",
    ),
    dict(
        value="20",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELLGRP-1",
        p_name="ssBurstSetPeriod",
    ),
    dict(
        value="7",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-2",
        p_name="msg1FrequencyStart",
    ),
    # dict(value='4DL4UL', dist_name='MRBTS-10037/NRBTS-10037/NRCELL-2', p_name='nrCellType'),
    dict(
        value="true", dist_name="MRBTS-10037/NRBTS-10037/NRCELL-2", p_name="actDl256Qam"
    ),
    dict(
        value="true", dist_name="MRBTS-10037/NRBTS-10037/NRCELL-2", p_name="actUl256Qam"
    ),
    dict(
        value="6",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-2",
        p_name="type0CoresetConfigurationIndex",
    ),
    dict(
        value="pos2",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-2",
        p_name="dmrsTypeAPosition",
    ),
    dict(
        value="true",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-2",
        p_name="actPdschAtSsbSlots",
    ),
    dict(
        value="20MHz",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-2/NRCELL_FDD-1",
        p_name="chBwDl",
    ),
    dict(
        value="20MHz",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-2/NRCELL_FDD-1",
        p_name="chBwUl",
    ),
    # CA related
    dict(
        value="MixedCAMode",
        dist_name="MRBTS-10037/NRBTS-10037/NRDU-1",
        p_name="flexibleCAMode",
    ),
    dict(
        value="bufferBased",
        dist_name="MRBTS-10037/NRBTS-10037",
        p_name="sCellActivationMethod",
    ),
    dict(
        value="rsrp",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1",
        p_name="a1MeasSCellAddEnabled",
    ),
    dict(
        value="0dB",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1/NRREL-1",
        p_name="cellIndividualSsbRsrpOffset",
    ),
    dict(
        value="0dB",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1/NRREL-1",
        p_name="cellIndividualSsbRsrqOffset",
    ),
    # dict(
    #     value="10037",
    #     dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1/NRREL-1",
    #     p_name="gNbId",
    # ),
    dict(
        value="32",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1/NRREL-1",
        p_name="gNbIdLength",
    ),
    dict(
        value="allowed",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1/NRREL-1",
        p_name="handoverAllowedSA",
    ),
    dict(
        value="2", dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1/NRREL-1", p_name="lcrId"
    ),
    dict(
        value="false",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1/NRREL-1",
        p_name="removeNotAllowed",
    ),
    dict(
        value="blind",
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1/NRREL-1",
        p_name="sCellAdditionMethod",
    ),
]

PARAMS_TO_DELETE_8131_W_01 = [
    # CA related
    # dict(dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1/NRREL-1"),
    dict(
        dist_name="MRBTS-10037/NRBTS-10037/NRDU-1",
        list_name="carrierAggregationSupportList",
    ),
    dict(
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1",
        list_name="allowUnsuppBcOrBcs",
    ),
    dict(
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-2",
        list_name="allowUnsuppBcOrBcs",
    ),
]

ADD_MOs_8131_W_01 = [
    # CA related
    # dict(
    #     class_name="com.nokia.srbts.nrbts:NRREL",
    #     dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1/NRREL-1",
    #     version="NRBTSCL22R2_2111_100",
    # ),
]

LIST_TO_ADD_8131_W_01 = [
    # CA related
    dict(
        dist_name="MRBTS-5/NRBTS-5/NRDU-1",
        list_name="carrierAggregationSupportList",
        elements=["ca_Fdd_Fdd"],
    ),
    # dict(
    #     dist_name="MRBTS-10038/NRBTS-10038/NRCELL-1/NRREL-1",
    #     list_name="gnbPlmn",
    #     elements=dict(mcc="460", mnc="2", mncLength="2"),
    # ),
    dict(
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1",
        list_name="allowUnsuppBcOrBcs",
        elements=["accept unknown band combinations"],
    ),
    dict(
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-2",
        list_name="allowUnsuppBcOrBcs",
        elements=["accept unknown band combinations"],
    ),
]

LIST_PARAMS_TO_MODIFY_8131_W_01 = [
    dict(
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1",
        list_name="ulPowerControlCommon",
        elements=[
            dict(p_name="p0NominalPucch", value="-90", index=0),
            dict(p_name="p0NominalPucchF1F3", value="-100", index=0),
            dict(p_name="p0NominalPusch", value="-96", index=0),
            dict(p_name="p0NominalSrs", value="-96", index=0),
        ],
    ),
    dict(
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-2",
        list_name="ulPowerControlCommon",
        elements=[
            dict(p_name="p0NominalPucch", value="-90", index=0),
            dict(p_name="p0NominalPucchF1F3", value="-100", index=0),
            dict(p_name="p0NominalPusch", value="-96", index=0),
            dict(p_name="p0NominalSrs", value="-96", index=0),
        ],
    ),
    dict(
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1",
        list_name="periodicCsiAcquisition",
        elements=[dict(p_name="csiReportPeriodicity", value="slots160", index=0)],
    ),
    dict(
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-2",
        list_name="periodicCsiAcquisition",
        elements=[dict(p_name="csiReportPeriodicity", value="slots160", index=0)],
    ),
    # BWP_PROFILE DN2/3----20M--ACSI true---------
    dict(
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1",
        list_name="cellBwpList",
        elements=[
            dict(p_name="bwpDN", value="MRBTS-10037/NRBTS-10037/BWP_PROFILE-3", index=0)
        ],
    ),
    dict(
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-1",
        list_name="cellBwpList",
        elements=[
            dict(p_name="bwpDN", value="MRBTS-10037/NRBTS-10037/BWP_PROFILE-4", index=1)
        ],
    ),
    dict(
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-2",
        list_name="cellBwpList",
        elements=[
            dict(p_name="bwpDN", value="MRBTS-10037/NRBTS-10037/BWP_PROFILE-3", index=0)
        ],
    ),
    dict(
        dist_name="MRBTS-10037/NRBTS-10037/NRCELL-2",
        list_name="cellBwpList",
        elements=[
            dict(p_name="bwpDN", value="MRBTS-10037/NRBTS-10037/BWP_PROFILE-4", index=1)
        ],
    ),
]
