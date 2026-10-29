import os
from robot.libraries.BuiltIn import BuiltIn

tl = BuiltIn().get_variable_value("${tl}")
CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_gnb_id = str(tl.gnbs[0].instance_id)
_MRBTSname = 'MRBTS-'+_gnb_id
_NRBTSname = _MRBTSname+'/NRBTS-'+_gnb_id
_NRCELLname = _NRBTSname+'/NRCELL-1'
_NRSYSINFO = _NRBTSname+'/NRSYSINFO_PROFILE-1'
_NRLIM = _NRSYSINFO+'/NRLIM-1'

PARAMS_TO_MODIFY_SRB_DRB_INACTIVITY_TIMER = [
    dict(
        value='10',
        dist_name=_NRBTSname,
        parameter='srbInactivityTimerSA'),
    dict(
        value='10',
        dist_name=_NRBTSname,
        parameter='drbInactivityTimerSA')
]

PARAMS_TO_MODIFY_743_nrcell = [
    dict(
        value='4',
        dist_name=_NRCELLname,
        parameter='cellReselectionPriority'),
    dict(
        value='-65',
        dist_name=_NRCELLname,
        parameter='qRxLevMin'),
    dict(
        value='sl20',
        dist_name=_NRCELLname,
        parameter='raResponseWindow')
]

PARAMS_TO_MODIFY_743_nrSYSinfo = [
    dict(
        value='dB0',
        dist_name=_NRSYSINFO,
        parameter='qHyst'),
    dict(
        value='30',
        dist_name=_NRSYSINFO,
        parameter='sNonIntraSearchP'),
    dict(
        value='30',
        dist_name=_NRSYSINFO,
        parameter='sNonIntraSearchQ'),
    dict(
        value='s40',
        dist_name=_NRSYSINFO,
        parameter='siWindowLength'),
    dict(
        value='1',
        dist_name=_NRSYSINFO,
        parameter='systemInformationTargetRate'),
    dict(
        value='1',
        dist_name=_NRSYSINFO,
        parameter='tReselectionEutra'),
    dict(
        value='6',
        dist_name=_NRSYSINFO,
        parameter='threshServingLowP'),
    dict(
        value='1',
        dist_name=_NRSYSINFO,
        parameter='threshServingLowQ')
]

PARAMS_TO_MODIFY = [
    dict(value='10', dist_name=_NRBTSname, p_name='srbInactivityTimerSA'),
    dict(value='10', dist_name=_NRBTSname, p_name='drbInactivityTimerSA'),
    dict(value='4', dist_name=_NRCELLname, p_name='cellReselectionPriority'),
    dict(value='-65', dist_name=_NRCELLname, p_name='qRxLevMin'),
    dict(value='sl20', dist_name=_NRCELLname, p_name='raResponseWindow'),
    dict(value='dB0', dist_name=_NRSYSINFO, p_name='qHyst'),
    dict(value='30', dist_name=_NRSYSINFO, p_name='sNonIntraSearchP'),
    dict(value='30', dist_name=_NRSYSINFO, p_name='sNonIntraSearchQ'),
    dict(value='s40', dist_name=_NRSYSINFO, p_name='siWindowLength'),
    dict(value='0', dist_name=_NRSYSINFO, p_name='systemInformationTargetRate'),
    dict(value='1', dist_name=_NRSYSINFO, p_name='tReselectionEutra'),
    dict(value='6', dist_name=_NRSYSINFO, p_name='threshServingLowP'),
    dict(value='1', dist_name=_NRSYSINFO, p_name='threshServingLowQ'),
    dict(value='mbw100', dist_name=_NRLIM, p_name='allowedMeasBw'),
    dict(value='2600', dist_name=_NRLIM, p_name='carrierFreq'),
    dict(value='6', dist_name=_NRLIM, p_name='cellReselectionPriority'),
    dict(value='oDot2', dist_name=_NRLIM, p_name='cellReselectionSubPriority'),
    dict(value='23', dist_name=_NRLIM, p_name='pMaxEutra'),
    dict(value='true', dist_name=_NRLIM, p_name='presenceAntPort1'),
    dict(value='-30', dist_name=_NRLIM, p_name='qQualMin'),
    dict(value='-65', dist_name=_NRLIM, p_name='qRxLevMin'),
    dict(value='12', dist_name=_NRLIM, p_name='threshXHigh'),
    dict(value='10', dist_name=_NRLIM, p_name='threshXLow'),
    dict(value='6', dist_name=_NRLIM, p_name='threshXHighQ'),
    dict(value='5', dist_name=_NRLIM, p_name='threshXLowQ'),
    dict(value='42', dist_name=_NRLIM, list_name='eutraFreqNCellList', p_name='physCellId'),
    dict(value='0dB', dist_name=_NRLIM, list_name='eutraFreqNCellList', p_name='qOffsetCell'),
    dict(value='2', dist_name=_NRLIM, list_name='eutraFreqNCellList', p_name='qQualMinOffsetCell'),
    dict(value='2', dist_name=_NRLIM, list_name='eutraFreqNCellList', p_name='qRxLevMinOffsetCell')
]
