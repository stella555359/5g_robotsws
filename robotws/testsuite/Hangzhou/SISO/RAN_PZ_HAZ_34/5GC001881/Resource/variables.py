from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value("${tl}")

__maintainer__ = 'qionghua.zhang'
__team__ = 'I_MN_5G_RAN_IV4_LINE_HZG_3_GMS <I_MN_5G_RAN_IV4_LINE_HZG_3@internal.nsn.com>'
__email__ = 'qionghua.zhang@nokia-sbell.com'

_class_name = 'com.nokia.srbts.mnl:MPLANENW'

_gnb_id = str(tl.gnbs[0].instance_id)
_MRBTSname = 'MRBTS-'+_gnb_id
_NRBTSname = _MRBTSname+'/NRBTS-'+_gnb_id
_NRCELLname = _NRBTSname+'/NRCELL-1'
_NRREDRTname = _NRCELLname+'/NRREDRT-0'
_DRB_4 = _NRBTSname+'/NRDRB-4'
_AMF1GNB1 = _NRBTSname+'/SERVEDAMF-1'
PATH_TO_SCF = ''

PARAM_1881_011_1 = [
    dict(new_value='30', dist_name=_NRCELLname,
         filter_param='Maximum output power', abbr='pMax')
]

PARAM_1881_011_2 = [
    dict(new_value='50', dist_name=_NRCELLname,
         filter_param='Maximum output power', abbr='pMax')
]

PARAMS_1881_arfcn_min = [
    dict(new_value='515000', dist_name=_NRCELLname,
         filter_param='NR Absolute radio frequency channel number nrarfcn', abbr='nrarfcn')
]

PARAMS_1881_arfcn_max = [
    dict(new_value='523000', dist_name=_NRCELLname,
         filter_param='NR Absolute radio frequency channel number nrarfcn', abbr='nrarfcn')
]

PARAMS_1881_arfcn = [
    dict(new_value='519000', dist_name=_NRCELLname,
         filter_param='NR Absolute radio frequency channel number nrarfcn', abbr='nrarfcn')
]

PARAMS_TO_MODIFY_LOCKG1 = [
    dict(
        value='Locked',
        dist_name=_NRCELLname,
        parameter='administrativeState')
]


PARAMS_TO_MODIFY_UNLOCKG1 = [
    dict(
        value='Unlocked',
        dist_name=_NRCELLname,
        parameter='administrativeState')
]

PARAMS_TO_MODIFY_LOCKG2 = [
    dict(
        value='Locked',
        dist_name='_NRBTSname/NRCELL-2',
        parameter='administrativeState')
]

PARAMS_TO_MODIFY_UNLOCKG2 = [
    dict(
        value='Unlocked',
        dist_name='_NRBTSname/NRCELL-2',
        parameter='administrativeState')
]

PARAMS_TO_RU_LOCKED1 = [
    dict(
        value='Locked',
        dist_name='_MRBTSname/EQM-1/APEQM-1/RMOD-1',
        parameter='administrativeState')
]

PARAMS_TO_RU_UNLOCKED1 = [
    dict(
        value='Unlocked',
        dist_name='_MRBTSname/EQM-1/APEQM-1/RMOD-1',
        parameter='administrativeState')
]

PARAMS_TO_RU_LOCKED2 = [
    dict(
        value='Locked',
        dist_name='_MRBTSname/EQM-1/APEQM-1/RMOD-2',
        parameter='administrativeState')
]

PARAMS_TO_RU_UNLOCKED2 = [
    dict(
        value='Unlocked',
        dist_name='_MRBTSname/EQM-1/APEQM-1/RMOD-2',
        parameter='administrativeState')
]

PARAMETERS_TO_UPDATE_B09 = [
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'dlMimoMode', 'value': '2x2 Closed Loop Spatial Multiplexing'},
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'nrCellType', 'value': '2DL2UL'},
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'pMax', 'value': '300'},
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'prachConfigurationIndex', 'value': '160'},
    dict(value=[dict(lteToNrFrameShift='3ms')], dist_name=_NRBTSname+'/NRCELL-1', parameter='tddFrameStructure'),
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'actDlLowPAPRoptimizedPrecoding', 'value': 'false'}
]

PARAMETERS_TO_UPDATE_B09_1 = [
    {'dist_name': '_MRBTSname/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-5'},
    {'dist_name': '_MRBTSname/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-6'}
]

PARAMETERS_TO_UPDATE_B09_16383 = [
    {'dist_name': '_MRBTSname/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-16383/CHANNELGROUP-1/CHANNEL-5'},
    {'dist_name': '_MRBTSname/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-16383/CHANNELGROUP-1/CHANNEL-6'}
]

PARAMETERS_TO_UPDATE_B37 = [
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'pMax', 'value': '300'},
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'prachConfigurationIndex', 'value': '160'},
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'dlQam256PowerBackoffSub6', 'value': '15'}
]

PARAMETERS_TO_UPDATE_B20_nsaDrbParam = [
    dict(value=[dict(actPrioritizeX2AfterInactivity='false', actX2DuplicateTxNSA3x='false',
                     dlDataSplitBufferBuildUpThreshold='5', dlDataSplitBufferBuildUpThresholdPrioritizeX2='5',
                     dlDataSplitGainThreshold='5', dlDataSplitMode='dlOverF1U', dlNumOfCongOrGainDdds='2',
                     inactivityThresholdForPrioritizeX2='300', inactivityThresholdForRestartPrioritizeX2='100',
                     initialDLTrafficRouting='initDLoverF1U', nsa3xBearerAllowed='true', prioritizeX2Period='500',
                     ulDataPath='ulOverNr', ulDataSplitThreshold='infinity')],
         dist_name=_DRB_4, parameter='nsaDrbParam'),
]

PARAMETERS_TO_DELETE_B20_nsaDrbParam = [
    dict(dist_name=_DRB_4, parameter='nsaDrbParam')
]

PARAMETERS_TO_UPDATE_B37_1 = [
    dict(value=[dict(lteToNrFrameShift='0ms')],
         dist_name=_NRBTSname+'/NRCELL-1', parameter='tddFrameStructure')
]

PARAMETERS_TO_UPDATE_B37_2 = [
    dict(value=[dict(frameStructureType='semiStatic', guardPeriodLength='2Symbols', ulDlDataSlotRatio='1/4')],
         dist_name=_NRBTSname+'/NRCELL-1', parameter='tddFrameStructure')
]

PARAMETERS_TO_UPDATE_A14 = [
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'chBw', 'value': '20MHz'},
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'freqBandIndicatorNR', 'value': '38'},
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'gscnOrSsPbchArfcn', 'value': '1'},
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'dlQam256PowerBackoffSub6', 'value': '15'}
]

AMOUNT_OF_CELLS = 1

Lock_gnb1_AMF1 = [
    dict(value='Locked', dist_name=_AMF1GNB1, parameter='administrativeState')
]

Unlock_gnb1_AMF1 = [
    dict(value='Unlocked', dist_name=_AMF1GNB1, parameter='administrativeState')
]
