from robot.libraries.BuiltIn import BuiltIn


tl = BuiltIn().get_variable_value('${tl}')
all_cell_ids = BuiltIn().get_variable_value('${all_cell_ids}')
MR_BTS_NAME = 'MRBTS-' + str(tl.gnbs[0].instance_id)
BTS_ID = str(tl.gnbs[0].instance_id)
MR_NR_BTS_NAME = MR_BTS_NAME + '/NRBTS-' + str(tl.gnbs[0].global_bts_id)
NRIAFIM = MR_NR_BTS_NAME + '/NRSYSINFO_PROFILE-1/NRIAFIM-1'
NRIRFIM1 = MR_NR_BTS_NAME + '/NRSYSINFO_PROFILE-1/NRIRFIM-1'
NRIRFIM2 = MR_NR_BTS_NAME + '/NRSYSINFO_PROFILE-1/NRIRFIM-2'
NRPMRNL = MR_NR_BTS_NAME + '/NRPMRNL-1'


CELL_INDEX_1TH = str(all_cell_ids[0])
CELL_INDEX_2TH = str(all_cell_ids[1])
CELL_INDEX_3TH = str(all_cell_ids[2])
CELL_INDEX_4TH = str(all_cell_ids[3])
CELL_INDEX_5TH = str(all_cell_ids[4])
CELL_INDEX_6TH = str(all_cell_ids[5])
CELL_INDEX_7TH = str(all_cell_ids[6])
CELL_INDEX_8TH = str(all_cell_ids[7])


NRCELL_1TH = MR_NR_BTS_NAME + '/NRCELL-' + CELL_INDEX_1TH
NRCELL_2TH = MR_NR_BTS_NAME + '/NRCELL-' + CELL_INDEX_2TH
NRCELL_3TH = MR_NR_BTS_NAME + '/NRCELL-' + CELL_INDEX_3TH
NRCELL_4TH = MR_NR_BTS_NAME + '/NRCELL-' + CELL_INDEX_4TH
NRCELL_5TH = MR_NR_BTS_NAME + '/NRCELL-' + CELL_INDEX_5TH
NRCELL_6TH = MR_NR_BTS_NAME + '/NRCELL-' + CELL_INDEX_6TH
NRCELL_7TH = MR_NR_BTS_NAME + '/NRCELL-' + CELL_INDEX_7TH
NRCELL_8TH = MR_NR_BTS_NAME + '/NRCELL-' + CELL_INDEX_8TH


def enable_prach_format_B4(all_cell_ids):
    """
    author:Wang Yixiang
    """
    DICT_ENABLE_B4 = []
    for i in all_cell_ids:
        print(i)
        cellId = str(i)
        dist_name_cell = MR_NR_BTS_NAME + '/NRCELL-' + cellId
        set_ulMimoMode = dict(dist_name=dist_name_cell, parameter='ulMimoMode',
                              value='Closed loop Spatial Multiplexing (2x2)')
        set_prachConfigurationIndex = dict(dist_name=dist_name_cell, parameter='prachConfigurationIndex', value='121')
        set_zeroCorrelationZoneConfig = dict(dist_name=dist_name_cell, parameter='zeroCorrelationZoneConfig',
                                             value='0')
        set_rangeExtension = dict(dist_name=dist_name_cell, parameter='rangeExtension', value='0-6.9km')
        set_totalNumberOfRAPreambles = dict(dist_name=dist_name_cell, parameter='totalNumberOfRAPreambles', value='32')
        set_type0SearchSpaceConfigurationIndex = dict(dist_name=dist_name_cell,
                                                      parameter='type0SearchSpaceConfigurationIndex', value='13')
        set_guardPeriodLength = dict(dist_name=dist_name_cell,
                                     parameter='tddFrameStructure', value=[{'guardPeriodLength': '6Symbols'}])
        set_inactiveSsbFr2 = dict(dist_name=dist_name_cell, parameter='inactiveSsbFr2', value='0x8B00D8842100C210')
        set_numOfPagingFrames = dict(dist_name=dist_name_cell, parameter='numOfPagingFrames', value='oneEighthT')
        set_cbraPreamblesPerSsb = dict(dist_name=dist_name_cell, parameter='cbraPreamblesPerSsb', value='n32')
        set_ssBurstSetP = dict(dist_name=MR_NR_BTS_NAME + '/NRCELLGRP-0', parameter='ssBurstSetPeriod', value='40')
        DICT_ENABLE_B4.extend([set_ulMimoMode, set_prachConfigurationIndex,
                               set_zeroCorrelationZoneConfig, set_guardPeriodLength,
                               set_rangeExtension, set_totalNumberOfRAPreambles,
                               set_type0SearchSpaceConfigurationIndex,
                               set_inactiveSsbFr2, set_numOfPagingFrames,
                               set_cbraPreamblesPerSsb, set_ssBurstSetP])
    return DICT_ENABLE_B4


# CB008294_A_B3_006
A_B3_006_PRE_API = [
    dict(dist_name=MR_NR_BTS_NAME, parameter='sCellActivationMethod', value='blind'),
    dict(dist_name=MR_NR_BTS_NAME, parameter='actCarrierAggregationFr2SA', value='false'),
    dict(dist_name=MR_NR_BTS_NAME, parameter='maxNumScellsDlFr2SA', value='6'),
    dict(dist_name=MR_NR_BTS_NAME, parameter='maxNumScellsUlFr2SA', value='2'),
    dict(dist_name=NRCELL_1TH, parameter='maxNumOf3To4CCUsersFr2SA', value='10'),
    dict(dist_name=NRCELL_1TH, parameter='maxNumOf5To8CCUsersFr2SA', value='10'),
    dict(dist_name=NRCELL_1TH, parameter='sCellDeactivationTimerGNB', value='infinity'),
    dict(dist_name=NRCELL_2TH, parameter='sCellDeactivationTimerGNB', value='infinity'),
    dict(dist_name=NRCELL_3TH, parameter='sCellDeactivationTimerGNB', value='infinity'),
    dict(dist_name=NRCELL_4TH, parameter='sCellDeactivationTimerGNB', value='infinity'),
    dict(dist_name=NRCELL_5TH, parameter='sCellDeactivationTimerGNB', value='infinity'),
    dict(dist_name=NRCELL_6TH, parameter='sCellDeactivationTimerGNB', value='infinity'),
    dict(dist_name=NRCELL_7TH, parameter='sCellDeactivationTimerGNB', value='infinity'),
    dict(dist_name=NRCELL_8TH, parameter='sCellDeactivationTimerGNB', value='infinity'),
]

ACT_CA_API = [
    dict(dist_name=MR_NR_BTS_NAME, parameter='actCarrierAggregationFr2SA', value='true'),
]

CA_4CCDL_4CCUL_API = [
    dict(dist_name=MR_NR_BTS_NAME, parameter='maxNumScellsDlFr2SA', value='7'),
    dict(dist_name=MR_NR_BTS_NAME, parameter='maxNumScellsUlFr2SA', value='3'),
    dict(dist_name=NRCELL_1TH, parameter='maxNumOf3To4CCUsersFr2SA', value='10'),
    dict(dist_name=NRCELL_1TH, parameter='maxNumOf5To8CCUsersFr2SA', value='0'),
]

CA_8CCDL_4CCUL_API = [
    dict(dist_name=NRCELL_1TH, parameter='maxNumOf5To8CCUsersFr2SA', value='1'),
    # dict(dist_name=NRCELL_1TH, parameter='sCellOnlyFr2Sa', value='true'),
    # dict(dist_name=NRCELL_4TH, parameter='sCellOnlyFr2Sa', value='false'),

]

PRACH_FORMAT_B4 = enable_prach_format_B4(all_cell_ids)

A_PMO1_API = [
    dict(dist_name=MR_NR_BTS_NAME, parameter='sCellActivationMethod', value='bufferAndRLQualityBased'),
    dict(dist_name=MR_NR_BTS_NAME, parameter='mcsDeactSCellDl', value='3'),
    dict(dist_name=MR_NR_BTS_NAME, parameter='mcsDeactSCellUl', value='3'),
    dict(dist_name=MR_NR_BTS_NAME, parameter='pathlossDeltaActSCellDl', value='3'),
    dict(dist_name=MR_NR_BTS_NAME, parameter='pathlossDeltaActSCellUl', value='3'),
    dict(dist_name=MR_NR_BTS_NAME, parameter='actIpThpt', value='true'),
    dict(dist_name=MR_NR_BTS_NAME, parameter='actMacUserThpt', value='true'),
    dict(dist_name=NRPMRNL, parameter='miNrCaCu', value='5min'),
    dict(dist_name=NRPMRNL, parameter='miNrRSACU', value='5min'),
    dict(dist_name=NRPMRNL, parameter='miNrRSADU', value='5min'),
    dict(dist_name=NRPMRNL, parameter='miNrRacCu', value='5min'),
    dict(dist_name=NRPMRNL, parameter='miNrRacDu', value='5min'),
    dict(dist_name=NRPMRNL, parameter='miNrCaDu', value='5min'),
    dict(dist_name=NRPMRNL, parameter='miNrLowRlcReport', value='5min'),
    dict(dist_name=NRPMRNL, parameter='miNrCUCM', value='5min'),
]

# restore default NIDD in case teardown
CA_CASE_TEARDOWN_API = [
    dict(dist_name=MR_NR_BTS_NAME, parameter='maxNumScellsDlFr2SA', value='7'),
    dict(dist_name=MR_NR_BTS_NAME, parameter='maxNumScellsUlFr2SA', value='3'),
    dict(dist_name=NRCELL_1TH, parameter='maxNumOf3To4CCUsersFr2SA', value='255'),
    dict(dist_name=NRCELL_1TH, parameter='maxNumOf5To8CCUsersFr2SA', value='255'),
    dict(dist_name=NRCELL_1TH, parameter='sCellOnlyFr2Sa', value='false'),
    dict(dist_name=NRCELL_4TH, parameter='sCellOnlyFr2Sa', value='true'),
]

# 2103 23R4 not support
A_PMO1_001_API = A_PMO1_API + PRACH_FORMAT_B4
# A_PMO1_001_API = A_PMO1_API

# enable CB001732
DICT_ENABLE_1732_15 = [
    dict(dist_name=MR_NR_BTS_NAME, parameter='actCsiReportsMuxOnPucch', value='true'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRPMRNL-1', parameter='miNrRachUsage', value='5min'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELLGRP-0', parameter='pucchF2MaxCodeRate', value='zeroDot15')
]

disable_8294_8CC = [
    dict(dist_name=MR_NR_BTS_NAME, parameter='actCarrierAggregationFr2SA', value='false')
]

DICT_ENABLE_1732_25 = [
    dict(dist_name=MR_NR_BTS_NAME, parameter='actCsiReportsMuxOnPucch', value='true'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELLGRP-0', parameter='pucchF2MaxCodeRate', value='zeroDot25')
]

MODIFY_ENABLE_CNI_94156 = [
    {'dist_name': MR_NR_BTS_NAME, 'parameter': 'actMultipleDedicatedBWPs', 'value': 'false'},
    {'dist_name': NRCELL_1TH, 'parameter': 'ueConnectionEstablishmentMode', 'value': 'useInitialBwp'}]
