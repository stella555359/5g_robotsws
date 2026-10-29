import os

CFG_DIR = os.path.dirname(os.path.abspath(__file__))
_NRBTSname = 'MRBTS-33/NRBTS-33'
_NRCELLname = 'MRBTS-33/NRBTS-33/NRCELL-1'
_NRCELLname2 = 'MRBTS-33/NRBTS-33/NRCELL-2'
_NRCELL1REL1 = 'MRBTS-33/NRBTS-33/NRCELL-1/NRREL-0'
_NRCELL2REL0 = 'MRBTS-33/NRBTS-33/NRCELL-2/NRREL-0'


PARAMS_TO_MODIFY_FEATURE05 = [
    dict(value='260', dist_name=_NRCELLname, list_name='plmnList', p_name='mcc', index='0'),
    dict(value='6', dist_name=_NRCELLname, list_name='plmnList', p_name='mnc', index='0'),
    dict(value='2', dist_name=_NRCELLname, list_name='plmnList', p_name='mncLength', index='0'),
    dict(value='NSA', dist_name=_NRCELLname, list_name='plmnList', p_name='plmnMode', index='0'),
    dict(value='244', dist_name=_NRCELLname, list_name='plmnList', p_name='mcc', index='1'),
    dict(value='9', dist_name=_NRCELLname, list_name='plmnList', p_name='mnc', index='1'),
    dict(value='2', dist_name=_NRCELLname, list_name='plmnList', p_name='mncLength', index='1'),
    dict(value='NSA', dist_name=_NRCELLname, list_name='plmnList', p_name='plmnMode', index='1'),
    dict(value='244', dist_name=_NRCELLname2, list_name='plmnList', p_name='mcc', index='0'),
    dict(value='9', dist_name=_NRCELLname2, list_name='plmnList', p_name='mnc', index='0'),
    dict(value='2', dist_name=_NRCELLname2, list_name='plmnList', p_name='mncLength', index='0'),
    dict(value='NSA', dist_name=_NRCELLname2, list_name='plmnList', p_name='plmnMode', index='0'),
]

PARAMS_TO_MODIFY_FEATURE08 = [
    dict(value='244', dist_name=_NRCELLname, list_name='plmnList', p_name='mcc', index='0'),
    dict(value='9', dist_name=_NRCELLname, list_name='plmnList', p_name='mnc', index='0'),
    dict(value='2', dist_name=_NRCELLname, list_name='plmnList', p_name='mncLength', index='0'),
    dict(value='NSA', dist_name=_NRCELLname, list_name='plmnList', p_name='plmnMode', index='0'),
    dict(value='460', dist_name=_NRCELLname, list_name='plmnList', p_name='mcc', index='1'),
    dict(value='0', dist_name=_NRCELLname, list_name='plmnList', p_name='mnc', index='1'),
    dict(value='2', dist_name=_NRCELLname, list_name='plmnList', p_name='mncLength', index='1'),
    dict(value='NSA', dist_name=_NRCELLname, list_name='plmnList', p_name='plmnMode', index='1'),
    dict(value='244', dist_name=_NRCELLname2, list_name='plmnList', p_name='mcc', index='0'),
    dict(value='9', dist_name=_NRCELLname2, list_name='plmnList', p_name='mnc', index='0'),
    dict(value='2', dist_name=_NRCELLname2, list_name='plmnList', p_name='mncLength', index='0'),
    dict(value='NSA', dist_name=_NRCELLname2, list_name='plmnList', p_name='plmnMode', index='0'),
]

PARAMS_TO_MODIFY_FEATURE04 = [
    dict(value='460', dist_name=_NRCELLname, list_name='plmnList', p_name='mcc', index='0'),
    dict(value='0', dist_name=_NRCELLname, list_name='plmnList', p_name='mnc', index='0'),
    dict(value='2', dist_name=_NRCELLname, list_name='plmnList', p_name='mncLength', index='0'),
    dict(value='NSA', dist_name=_NRCELLname, list_name='plmnList', p_name='plmnMode', index='0'),
    dict(value='245', dist_name=_NRCELLname, list_name='plmnList', p_name='mcc', index='1'),
    dict(value='9', dist_name=_NRCELLname, list_name='plmnList', p_name='mnc', index='1'),
    dict(value='2', dist_name=_NRCELLname, list_name='plmnList', p_name='mncLength', index='1'),
    dict(value='NSA', dist_name=_NRCELLname, list_name='plmnList', p_name='plmnMode', index='1'),
    dict(value='244', dist_name=_NRCELLname2, list_name='plmnList', p_name='mcc', index='0'),
    dict(value='9', dist_name=_NRCELLname2, list_name='plmnList', p_name='mnc', index='0'),
    dict(value='2', dist_name=_NRCELLname2, list_name='plmnList', p_name='mncLength', index='0'),
    dict(value='NSA', dist_name=_NRCELLname2, list_name='plmnList', p_name='plmnMode', index='0'),
]

PARAMS_TO_MODIFY_FEATURE09 = [
    dict(value='245', dist_name=_NRCELLname, list_name='plmnList', p_name='mcc', index='0'),
    dict(value='9', dist_name=_NRCELLname, list_name='plmnList', p_name='mnc', index='0'),
    dict(value='2', dist_name=_NRCELLname, list_name='plmnList', p_name='mncLength', index='0'),
    dict(value='NSA', dist_name=_NRCELLname, list_name='plmnList', p_name='plmnMode', index='0'),
    dict(value='461', dist_name=_NRCELLname, list_name='plmnList', p_name='mcc', index='1'),
    dict(value='0', dist_name=_NRCELLname, list_name='plmnList', p_name='mnc', index='1'),
    dict(value='2', dist_name=_NRCELLname, list_name='plmnList', p_name='mncLength', index='1'),
    dict(value='NSA', dist_name=_NRCELLname, list_name='plmnList', p_name='plmnMode', index='1'),
    dict(value='263', dist_name=_NRCELLname2, list_name='plmnList', p_name='mcc', index='0'),
    dict(value='3', dist_name=_NRCELLname2, list_name='plmnList', p_name='mnc', index='0'),
    dict(value='2', dist_name=_NRCELLname2, list_name='plmnList', p_name='mncLength', index='0'),
    dict(value='NSA', dist_name=_NRCELLname2, list_name='plmnList', p_name='plmnMode', index='0'),
]

PARAMS_TO_MODIFY_FEATURE_A06 = [
    dict(value='244', dist_name=_NRCELLname, list_name='plmnList', p_name='mcc', index='0'),
    dict(value='9', dist_name=_NRCELLname, list_name='plmnList', p_name='mnc', index='0'),
    dict(value='2', dist_name=_NRCELLname, list_name='plmnList', p_name='mncLength', index='0'),
    dict(value='NSA', dist_name=_NRCELLname, list_name='plmnList', p_name='plmnMode', index='0'),
    dict(value='262', dist_name=_NRCELLname, list_name='plmnList', p_name='mcc', index='1'),
    dict(value='3', dist_name=_NRCELLname, list_name='plmnList', p_name='mnc', index='1'),
    dict(value='2', dist_name=_NRCELLname, list_name='plmnList', p_name='mncLength', index='1'),
    dict(value='NSA', dist_name=_NRCELLname, list_name='plmnList', p_name='plmnMode', index='1'),
    dict(value='460', dist_name=_NRCELLname2, list_name='plmnList', p_name='mcc', index='0'),
    dict(value='0', dist_name=_NRCELLname2, list_name='plmnList', p_name='mnc', index='0'),
    dict(value='2', dist_name=_NRCELLname2, list_name='plmnList', p_name='mncLength', index='0'),
    dict(value='NSA', dist_name=_NRCELLname2, list_name='plmnList', p_name='plmnMode', index='0'),
    dict(value='262', dist_name=_NRCELL2REL0, list_name='plmnList', p_name='mcc', index='0'),
    dict(value='3', dist_name=_NRCELL2REL0, list_name='plmnList', p_name='mnc', index='0'),
    dict(value='2', dist_name=_NRCELL2REL0, list_name='plmnList', p_name='mncLength', index='0'),
]

PARAMS_TO_MODIFY_FEATURE_A07 = [
    dict(value='244', dist_name=_NRCELLname, list_name='plmnList', p_name='mcc', index='0'),
    dict(value='9', dist_name=_NRCELLname, list_name='plmnList', p_name='mnc', index='0'),
    dict(value='2', dist_name=_NRCELLname, list_name='plmnList', p_name='mncLength', index='0'),
    dict(value='NSA', dist_name=_NRCELLname, list_name='plmnList', p_name='plmnMode', index='0'),
    dict(value='263', dist_name=_NRCELLname, list_name='plmnList', p_name='mcc', index='1'),
    dict(value='3', dist_name=_NRCELLname, list_name='plmnList', p_name='mnc', index='1'),
    dict(value='2', dist_name=_NRCELLname, list_name='plmnList', p_name='mncLength', index='1'),
    dict(value='NSA', dist_name=_NRCELLname, list_name='plmnList', p_name='plmnMode', index='1'),
    dict(value='460', dist_name=_NRCELLname2, list_name='plmnList', p_name='mcc', index='0'),
    dict(value='0', dist_name=_NRCELLname2, list_name='plmnList', p_name='mnc', index='0'),
    dict(value='2', dist_name=_NRCELLname2, list_name='plmnList', p_name='mncLength', index='0'),
    dict(value='NSA', dist_name=_NRCELLname2, list_name='plmnList', p_name='plmnMode', index='0'),
    dict(value='244', dist_name=_NRCELL2REL0, list_name='plmnList', p_name='mcc', index='0'),
    dict(value='9', dist_name=_NRCELL2REL0, list_name='plmnList', p_name='mnc', index='0'),
    dict(value='2', dist_name=_NRCELL2REL0, list_name='plmnList', p_name='mncLength', index='0'),
]

PARAMS_TO_MODIFY_FEATURE_A14 = [
    dict(value='244', dist_name=_NRCELLname, list_name='plmnList', p_name='mcc', index='0'),
    dict(value='9', dist_name=_NRCELLname, list_name='plmnList', p_name='mnc', index='0'),
    dict(value='2', dist_name=_NRCELLname, list_name='plmnList', p_name='mncLength', index='0'),
    dict(value='NSA', dist_name=_NRCELLname, list_name='plmnList', p_name='plmnMode', index='0'),
    dict(value='262', dist_name=_NRCELLname, list_name='plmnList', p_name='mcc', index='1'),
    dict(value='3', dist_name=_NRCELLname, list_name='plmnList', p_name='mnc', index='1'),
    dict(value='2', dist_name=_NRCELLname, list_name='plmnList', p_name='mncLength', index='1'),
    dict(value='NSA', dist_name=_NRCELLname, list_name='plmnList', p_name='plmnMode', index='1'),
    dict(value='262', dist_name=_NRCELLname2, list_name='plmnList', p_name='mcc', index='0'),
    dict(value='3', dist_name=_NRCELLname2, list_name='plmnList', p_name='mnc', index='0'),
    dict(value='2', dist_name=_NRCELLname2, list_name='plmnList', p_name='mncLength', index='0'),
    dict(value='NSA', dist_name=_NRCELLname2, list_name='plmnList', p_name='plmnMode', index='0'),
    dict(value='262', dist_name=_NRCELL2REL0, list_name='plmnList', p_name='mcc', index='0'),
    dict(value='3', dist_name=_NRCELL2REL0, list_name='plmnList', p_name='mnc', index='0'),
    dict(value='2', dist_name=_NRCELL2REL0, list_name='plmnList', p_name='mncLength', index='0'),
]

PARAMS_TO_MODIFY_FEATURE_A11 = [
    dict(value='244', dist_name=_NRCELLname, list_name='plmnList', p_name='mcc', index='0'),
    dict(value='9', dist_name=_NRCELLname, list_name='plmnList', p_name='mnc', index='0'),
    dict(value='2', dist_name=_NRCELLname, list_name='plmnList', p_name='mncLength', index='0'),
    dict(value='NSA', dist_name=_NRCELLname, list_name='plmnList', p_name='plmnMode', index='0'),
    dict(value='262', dist_name=_NRCELLname, list_name='plmnList', p_name='mcc', index='1'),
    dict(value='3', dist_name=_NRCELLname, list_name='plmnList', p_name='mnc', index='1'),
    dict(value='2', dist_name=_NRCELLname, list_name='plmnList', p_name='mncLength', index='1'),
    dict(value='NSA', dist_name=_NRCELLname, list_name='plmnList', p_name='plmnMode', index='1'),
    dict(value='460', dist_name=_NRCELLname2, list_name='plmnList', p_name='mcc', index='0'),
    dict(value='0', dist_name=_NRCELLname2, list_name='plmnList', p_name='mnc', index='0'),
    dict(value='2', dist_name=_NRCELLname2, list_name='plmnList', p_name='mncLength', index='0'),
    dict(value='NSA', dist_name=_NRCELLname2, list_name='plmnList', p_name='plmnMode', index='0'),
    dict(value='262', dist_name=_NRCELL1REL1, list_name='plmnList', p_name='mcc', index='0'),
    dict(value='3', dist_name=_NRCELL1REL1, list_name='plmnList', p_name='mnc', index='0'),
    dict(value='2', dist_name=_NRCELL1REL1, list_name='plmnList', p_name='mncLength', index='0'),
    dict(value='5min', dist_name='MRBTS-38/NRBTS-38/NRPMRNL-1', p_name='miNrX2CB'),
]

PARAMS_TO_MODIFY_FEATURE_A10 = [
    dict(value='5min', dist_name='MRBTS-37/NRBTS-37/NRPMRNL-1', parameter='miNrRANS'),
]
