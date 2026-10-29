import os
from taf.config.testline.info import info
from robot.libraries.BuiltIn import BuiltIn

tl = BuiltIn().get_variable_value("${tl}")
mr_bts_id = tl.gnbs[0].instance_id
nr_bts_id = tl.gnbs[0].global_bts_id
_MRBTSname = 'MRBTS-' + str(mr_bts_id)
_NRBTSname = _MRBTSname + '/NRBTS-' + str(nr_bts_id)
_NRBTS_ID = 'NRBTS-' + str(nr_bts_id)

PARAM_1655_ACTEIRPCONTROL = [
    dict(
        value='true',
        dist_name=_NRBTSname + '/NRCELL-1',
        parameter='actEirpControl')
]

PARAM_1655_EIRPCONTROL = [
    dict(
        value=[{'minGuaranteedBudgetRatio': 50,
                'minGuaranteedBudgetRatioMode': 'actualEirpBudgetRatio',
                'minSignificantNormalizedBeamGain': -20,
                'numOfSegmentAzimuthEdges': 3,
                'numOfSegmentElevationEdges': 0,
                'schedulWeightFactorEnabled': 'false',
                'segmentAzimuthEdge0': -20,
                'segmentAzimuthEdge1': 0,
                'segmentAzimuthEdge2': 20}],
        dist_name=_NRBTSname + '/NRCELL-1',
        parameter='eirpControl')
]

ADD_1655_EIRCP_CPRFLIST = [
    dict(
        dist_name=_NRBTSname + '/NRCELL-1',
        filter_param='List of EIRP control power reduction factor per cell segment',
        abbr='eirpControlPowerReductionFactorList')
]

PARAM_1655_EIRCP_CPRFLIST = [
    dict(
        new_value=-7,
        dist_name=_NRBTSname + '/NRCELL-1',
        filter_param='List of EIRP control power reduction factor per cell segment',
        abbr='eirpControlPowerReductionFactorList'),
    dict(
        new_value=-7,
        dist_name=_NRBTSname + '/NRCELL-1',
        filter_param='List of EIRP control power reduction factor per cell segment',
        abbr='eirpControlPowerReductionFactorList'),
    dict(
        new_value=-7,
        dist_name=_NRBTSname + '/NRCELL-1',
        filter_param='List of EIRP control power reduction factor per cell segment',
        abbr='eirpControlPowerReductionFactorList')
]

ALLOWED_FAULT = [
    {'faultId': 61652},
    {'faultId': 61524},
    {'faultId': 61649},
    {'faultId': 9000},
    {'faultId': 4592},
    {'faultId': 4527},
    {'faultId': 1932},
    {'faultId': 4334},
    {'faultId': 61074},
    {'faultId': 61618},
    {'faultId': 4687},
    {'faultId': 4654},
    {'faultId': 4655},
    {'faultId': 8150},
]

ALLOWED_HISTORY_FAULT = [
    {'faultId': 7319},
    {'faultId': 7300},
    {'faultId': 8150},
    {'faultId': 6327},
    {'faultId': 10},
]

ALLOWED_HISTORY_FAULT.extend(ALLOWED_FAULT)
