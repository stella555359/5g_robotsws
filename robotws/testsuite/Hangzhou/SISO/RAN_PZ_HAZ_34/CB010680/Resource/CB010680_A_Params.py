from robot.libraries.BuiltIn import BuiltIn

tl = BuiltIn().get_variable_value('${tl}')

# actPRBBlanking nbrOfBlankedPRBsHighEdgeDL nbrOfBlankedPRBsHighEdgeUL
# nbrOfBlankedPRBsLowEdgeDL nbrOfBlankedPRBsLowEdgeUL
# NRCELL.srsForPositioning.cSRS = 59
prbBlanking_srs = [{
            'cSRS': '59',
            'comb': 'comb4',
            'numberOfCS': '2 cycle shifts',
            'srsUePeriodicity': 'slots80'
         }
    ]

default_srs = [{
            'cSRS': '63',
            'comb': 'comb2',
            'numberOfCS': '4 cycle shifts',
            'srsUePeriodicity': 'slots20'
         }
    ]

srs_change_only = [{
            'cSRS': '61',
            'comb': 'comb4',
            'numberOfCS': '2 cycle shifts',
            'srsUePeriodicity': 'slots20'
         }
    ]

drx_srs = [{
            'cSRS': '60',
            'comb': 'comb4',
            'numberOfCS': '2 cycle shifts',
            'srsUePeriodicity': 'slots20',
            'posNrDrxDN': 'NRDRX-11'
         }
    ]

NRCELL_DIST_NAME = BuiltIn().get_variable_value('${GNB_CELL_NAME}')

actPrbBlanking_ENABLE_PARAM = [
    dict(dist_name=NRCELL_DIST_NAME, parameter='actPRBBlanking', value='true', operation='update'),
    dict(dist_name=NRCELL_DIST_NAME, parameter='nbrOfBlankedPRBsHighEdgeDL', value='6', operation='update'),
    dict(dist_name=NRCELL_DIST_NAME, parameter='nbrOfBlankedPRBsHighEdgeUL', value='6', operation='update'),
    dict(dist_name=NRCELL_DIST_NAME, parameter='nbrOfBlankedPRBsLowEdgeDL', value='6', operation='update'),
    dict(dist_name=NRCELL_DIST_NAME, parameter='nbrOfBlankedPRBsLowEdgeUL', value='6', operation='update'),
    dict(dist_name=NRCELL_DIST_NAME, parameter='chBw', value='100MHz', operation='update'),
    dict(dist_name=NRCELL_DIST_NAME, parameter='srsForPositioning', value=prbBlanking_srs, operation='update')
]

actPrbBlanking_DISABLE_PARAM = [
    dict(dist_name=NRCELL_DIST_NAME, parameter='actPRBBlanking', value='false', operation='update'),
    dict(dist_name=NRCELL_DIST_NAME, parameter='nbrOfBlankedPRBsHighEdgeDL', value='0', operation='update'),
    dict(dist_name=NRCELL_DIST_NAME, parameter='nbrOfBlankedPRBsHighEdgeUL', value='0', operation='update'),
    dict(dist_name=NRCELL_DIST_NAME, parameter='nbrOfBlankedPRBsLowEdgeDL', value='0', operation='update'),
    dict(dist_name=NRCELL_DIST_NAME, parameter='nbrOfBlankedPRBsLowEdgeUL', value='0', operation='update'),
    dict(dist_name=NRCELL_DIST_NAME, parameter='srsForPositioning', value=default_srs, operation='update')
]

SRS_CHANGE_ONLY_PARAM = [
    dict(dist_name=NRCELL_DIST_NAME, parameter='actPRBBlanking', value='false', operation='update'),
    dict(dist_name=NRCELL_DIST_NAME, parameter='nbrOfBlankedPRBsHighEdgeDL', value='0', operation='update'),
    dict(dist_name=NRCELL_DIST_NAME, parameter='nbrOfBlankedPRBsHighEdgeUL', value='0', operation='update'),
    dict(dist_name=NRCELL_DIST_NAME, parameter='nbrOfBlankedPRBsLowEdgeDL', value='0', operation='update'),
    dict(dist_name=NRCELL_DIST_NAME, parameter='nbrOfBlankedPRBsLowEdgeUL', value='0', operation='update'),
    dict(dist_name=NRCELL_DIST_NAME, parameter='srsForPositioning', value=srs_change_only, operation='update')
]

CSRS_PRBNUM_MAPPING = {
    0: 4, 1: 8, 2: 12, 3: 16, 4: 16, 5: 20, 6: 24, 7: 24, 8: 28, 9: 32, 10: 36, 11: 40, 12: 48, 13: 48, 14: 52,
    15: 56, 16: 60, 17: 64, 18: 72, 19: 72, 20: 76, 21: 80, 22: 88, 23: 96, 24: 96, 25: 104, 26: 112, 27: 120,
    28: 120, 29: 120, 30: 128, 31: 128, 32: 128, 33: 132, 34: 136, 35: 144, 36: 144, 37: 144, 38: 144, 39: 152,
    40: 160, 41: 160, 42: 160, 43: 168, 44: 176, 45: 184, 46: 192, 47: 192, 48: 192, 49: 192, 50: 208, 51: 216,
    52: 224, 53: 240, 54: 240, 55: 240, 56: 240, 57: 256, 58: 256, 59: 256, 60: 264, 61: 272, 62: 272, 63: 272
}

BTS_DIST_749 = 'MRBTS-37600/NRBTS-37600'

posDrx_enable_PARAM = [
    dict(dist_name=BTS_DIST_749, parameter='actDrbDrx', value='true', operation='update'),
    dict(dist_name=BTS_DIST_749 + '/NRDRX-11', parameter='', value='', operation='create_object'),
    dict(dist_name=BTS_DIST_749 + '/NRDRX-11', parameter='drxInactivityTimer', value='2ms', operation='update'),
    dict(dist_name=BTS_DIST_749 + '/NRDRX-11', parameter='drxLongCycle', value='10ms', operation='update'),
    dict(dist_name=BTS_DIST_749 + '/NRDRX-11', parameter='drxOnDurationTimer', value='2ms', operation='update'),
    dict(dist_name=BTS_DIST_749 + '/NRDRX-11', parameter='drxPriority', value='12', operation='update'),
    dict(dist_name=BTS_DIST_749 + '/NRDRX-11', parameter='userLabel', value='NRPOS', operation='update'),
    dict(dist_name=BTS_DIST_749 + '/NRCELL-0', parameter='srsForPositioning', value=drx_srs, operation='update'),
    dict(dist_name=BTS_DIST_749 + '/NRCELL-1', parameter='srsForPositioning', value=drx_srs, operation='update'),
    dict(dist_name=BTS_DIST_749 + '/NRCELL-2', parameter='srsForPositioning', value=drx_srs, operation='update'),
    dict(dist_name=BTS_DIST_749 + '/NRCELL-3', parameter='srsForPositioning', value=drx_srs, operation='update'),
    dict(dist_name=BTS_DIST_749 + '/NRCELL-4', parameter='srsForPositioning', value=drx_srs, operation='update'),
    dict(dist_name=BTS_DIST_749 + '/NRCELL-5', parameter='srsForPositioning', value=drx_srs, operation='update'),
]

DRX_SRS_CONFIG_LIST = [
    '10ms_4ms_2ms_12_slots20',
    '40ms_4ms_2ms_12_slots80'
 ]

DRX_SRS_CONFIG_LIST_VONR = [
    '40ms_10ms_5ms_12_slots80'
 ]

DRX_SRS_CONFIG_LIST_FULL = [
    '10ms_4ms_2ms_12_slots20',
    '20ms_4ms_2ms_12_slots40',
    '40ms_4ms_2ms_12_slots80',
    '80ms_4ms_2ms_12_slots160',
    '160ms_4ms_2ms_12_slots320',
    '320ms_4ms_2ms_12_slots640',
    '640ms_4ms_2ms_12_slots1280'
 ]

shareTrp_enable_PARAM = [
    dict(dist_name=BTS_DIST_749, parameter='allowSlowPrbPoolingStatNdmSrs', value='false', operation='update'),
    dict(dist_name=BTS_DIST_749 + '/NRCELL-0', parameter='ssPbchBlockPower', value='-16', operation='update'),
    dict(dist_name=BTS_DIST_749 + '/NRCELL-1', parameter='ssPbchBlockPower', value='-6', operation='update'),
    dict(dist_name=BTS_DIST_749 + '/NRCELL-0', parameter='nrPosDN', value='NRPOSPR-0', operation='update'),
    dict(dist_name=BTS_DIST_749 + '/NRCELL-1', parameter='nrPosDN', value='NRPOSPR-0', operation='update'),
    dict(dist_name=BTS_DIST_749 + '/NRCELL-2', parameter='nrPosDN', value='NRPOSPR-1', operation='update'),
    dict(dist_name=BTS_DIST_749 + '/NRCELL-3', parameter='nrPosDN', value='NRPOSPR-2', operation='update'),
    dict(dist_name=BTS_DIST_749 + '/NRCELL-4', parameter='nrPosDN', value='NRPOSPR-3', operation='update'),
    dict(dist_name=BTS_DIST_749 + '/NRCELL-5', parameter='nrPosDN', value='NRPOSPR-4', operation='update'),
    dict(dist_name=BTS_DIST_749 + '/NRPOSPR-0', parameter='', value='', operation='create_object'),
    dict(dist_name=BTS_DIST_749 + '/NRPOSPR-1', parameter='', value='', operation='create_object'),
    dict(dist_name=BTS_DIST_749 + '/NRPOSPR-2', parameter='', value='', operation='create_object'),
    dict(dist_name=BTS_DIST_749 + '/NRPOSPR-3', parameter='', value='', operation='create_object'),
    dict(dist_name=BTS_DIST_749 + '/NRPOSPR-4', parameter='', value='', operation='create_object'),
    dict(dist_name=BTS_DIST_749 + '/NRPOSPR-0', parameter='reuseGroupNumber', value='2', operation='update'),
    dict(dist_name=BTS_DIST_749 + '/NRPOSPR-1', parameter='reuseGroupNumber', value='3', operation='update'),
    dict(dist_name=BTS_DIST_749 + '/NRPOSPR-2', parameter='reuseGroupNumber', value='4', operation='update'),
    dict(dist_name=BTS_DIST_749 + '/NRPOSPR-3', parameter='reuseGroupNumber', value='5', operation='update'),
    dict(dist_name=BTS_DIST_749 + '/NRPOSPR-4', parameter='reuseGroupNumber', value='6', operation='update'),
]
