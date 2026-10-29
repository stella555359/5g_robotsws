import os
from robot.libraries.BuiltIn import BuiltIn

tl = BuiltIn().get_variable_value("${tl}")
CFG_DIR = os.path.dirname(os.path.abspath(__file__))
_MRBTS_id = str(tl.gnbs[0].instance_id)
_NRBTS_id = str(tl.gnbs[0].global_bts_id)
_MRBTSname = 'MRBTS-'+_MRBTS_id
_NRBTSname = _MRBTSname+'/NRBTS-'+_NRBTS_id
_NRCELLname1 = _NRBTSname+'/NRCELL-1'
_NRCELLname2 = _NRBTSname+'/NRCELL-2'
_NRCELLname3 = _NRBTSname+'/NRCELL-3'


PARAMS_TO_MODIFY_5MHz_FDD_TMO = [
    dict(value='5MHz', dist_name=_NRCELLname1 + '/NRCELL_FDD-1', p_name='chBwDl'),
    dict(value='5MHz', dist_name=_NRCELLname1 + '/NRCELL_FDD-1', p_name='chBwUl'),
    dict(value='126900', dist_name=_NRCELLname1 + '/NRCELL_FDD-1', p_name='nrarfcnDl'),
    dict(value='133600', dist_name=_NRCELLname1 + '/NRCELL_FDD-1', p_name='nrarfcnUl'),
    dict(value='5MHz', dist_name=_NRCELLname2 + '/NRCELL_FDD-1', p_name='chBwDl'),
    dict(value='5MHz', dist_name=_NRCELLname2 + '/NRCELL_FDD-1', p_name='chBwUl'),
    dict(value='126900', dist_name=_NRCELLname2 + '/NRCELL_FDD-1', p_name='nrarfcnDl'),
    dict(value='133600', dist_name=_NRCELLname2 + '/NRCELL_FDD-1', p_name='nrarfcnUl'),
    dict(value='5MHz', dist_name=_NRCELLname3 + '/NRCELL_FDD-1', p_name='chBwDl'),
    dict(value='5MHz', dist_name=_NRCELLname3 + '/NRCELL_FDD-1', p_name='chBwUl'),
    dict(value='126900', dist_name=_NRCELLname3 + '/NRCELL_FDD-1', p_name='nrarfcnDl'),
    dict(value='133600', dist_name=_NRCELLname3 + '/NRCELL_FDD-1', p_name='nrarfcnUl'),
    dict(value='1587', dist_name=_NRCELLname1, p_name='gscn'),
    dict(value='1587', dist_name=_NRCELLname2, p_name='gscn'),
    dict(value='1587', dist_name=_NRCELLname3, p_name='gscn'),
]

PARAMS_TO_MODIFY_15MHz_FDD_TMO = [
    dict(value='15MHz', dist_name=_NRCELLname1 + '/NRCELL_FDD-1', p_name='chBwDl'),
    dict(value='15MHz', dist_name=_NRCELLname1 + '/NRCELL_FDD-1', p_name='chBwUl'),
    dict(value='124900', dist_name=_NRCELLname1 + '/NRCELL_FDD-1', p_name='nrarfcnDl'),
    dict(value='134100', dist_name=_NRCELLname1 + '/NRCELL_FDD-1', p_name='nrarfcnUl'),
    dict(value='15MHz', dist_name=_NRCELLname2 + '/NRCELL_FDD-1', p_name='chBwDl'),
    dict(value='15MHz', dist_name=_NRCELLname2 + '/NRCELL_FDD-1', p_name='chBwUl'),
    dict(value='126900', dist_name=_NRCELLname2 + '/NRCELL_FDD-1', p_name='nrarfcnDl'),
    dict(value='136100', dist_name=_NRCELLname2 + '/NRCELL_FDD-1', p_name='nrarfcnUl'),
    dict(value='15MHz', dist_name=_NRCELLname3 + '/NRCELL_FDD-1', p_name='chBwDl'),
    dict(value='15MHz', dist_name=_NRCELLname3 + '/NRCELL_FDD-1', p_name='chBwUl'),
    dict(value='124900', dist_name=_NRCELLname3 + '/NRCELL_FDD-1', p_name='nrarfcnDl'),
    dict(value='134100', dist_name=_NRCELLname3 + '/NRCELL_FDD-1', p_name='nrarfcnUl'),
    dict(value='1553', dist_name=_NRCELLname1, p_name='gscn'),
    dict(value='1578', dist_name=_NRCELLname2, p_name='gscn'),
    dict(value='1553', dist_name=_NRCELLname3, p_name='gscn'),
]

PARAMS_TO_MODIFY_15MHz_FDD_TMO_dss = [
    dict(value='15MHz', dist_name=_NRCELLname1 + '/NRCELL_FDD-1', p_name='chBwDl'),
    dict(value='15MHz', dist_name=_NRCELLname1 + '/NRCELL_FDD-1', p_name='chBwUl'),
    dict(value='125900', dist_name=_NRCELLname1 + '/NRCELL_FDD-1', p_name='nrarfcnDl'),
    dict(value='135100', dist_name=_NRCELLname1 + '/NRCELL_FDD-1', p_name='nrarfcnUl'),
    dict(value='15MHz', dist_name=_NRCELLname2 + '/NRCELL_FDD-1', p_name='chBwDl'),
    dict(value='15MHz', dist_name=_NRCELLname2 + '/NRCELL_FDD-1', p_name='chBwUl'),
    dict(value='124900', dist_name=_NRCELLname2 + '/NRCELL_FDD-1', p_name='nrarfcnDl'),
    dict(value='134100', dist_name=_NRCELLname2 + '/NRCELL_FDD-1', p_name='nrarfcnUl'),
    dict(value='15MHz', dist_name=_NRCELLname3 + '/NRCELL_FDD-1', p_name='chBwDl'),
    dict(value='15MHz', dist_name=_NRCELLname3 + '/NRCELL_FDD-1', p_name='chBwUl'),
    dict(value='124900', dist_name=_NRCELLname3 + '/NRCELL_FDD-1', p_name='nrarfcnDl'),
    dict(value='134100', dist_name=_NRCELLname3 + '/NRCELL_FDD-1', p_name='nrarfcnUl'),
    dict(value='1567', dist_name=_NRCELLname1, p_name='gscn'),
    dict(value='DL_CRS_TDM_UL_FDM', dist_name=_NRCELLname1, p_name='lteNrDssMode'),
    dict(value='1553', dist_name=_NRCELLname2, p_name='gscn'),
    dict(value='1553', dist_name=_NRCELLname3, p_name='gscn'),
    dict(value='true', dist_name=_NRBTSname, p_name='actLteNrDss'),
]

PARAMS_TO_MODIFY_15MHz_SMS_FDD_TMO = [
    dict(value='10.108.234.5', dist_name=_NRBTSname + '/SERVEDAMF-1', p_name='amfIPAddress'),
]

PARAMS_TO_MODIFY_10MHz_FDD_TMO = [
    dict(value='10MHz', dist_name=_NRCELLname1 + '/NRCELL_FDD-1', p_name='chBwDl'),
    dict(value='10MHz', dist_name=_NRCELLname1 + '/NRCELL_FDD-1', p_name='chBwUl'),
    dict(value='126400', dist_name=_NRCELLname1 + '/NRCELL_FDD-1', p_name='nrarfcnDl'),
    dict(value='135600', dist_name=_NRCELLname1 + '/NRCELL_FDD-1', p_name='nrarfcnUl'),
    dict(value='10MHz', dist_name=_NRCELLname2 + '/NRCELL_FDD-1', p_name='chBwDl'),
    dict(value='10MHz', dist_name=_NRCELLname2 + '/NRCELL_FDD-1', p_name='chBwUl'),
    dict(value='126400', dist_name=_NRCELLname2 + '/NRCELL_FDD-1', p_name='nrarfcnDl'),
    dict(value='135600', dist_name=_NRCELLname2 + '/NRCELL_FDD-1', p_name='nrarfcnUl'),
    dict(value='10MHz', dist_name=_NRCELLname3 + '/NRCELL_FDD-1', p_name='chBwDl'),
    dict(value='10MHz', dist_name=_NRCELLname3 + '/NRCELL_FDD-1', p_name='chBwUl'),
    dict(value='126400', dist_name=_NRCELLname3 + '/NRCELL_FDD-1', p_name='nrarfcnDl'),
    dict(value='135600', dist_name=_NRCELLname3 + '/NRCELL_FDD-1', p_name='nrarfcnUl'),
    dict(value='1580', dist_name=_NRCELLname1, p_name='gscn'),
    dict(value='1580', dist_name=_NRCELLname2, p_name='gscn'),
    dict(value='1580', dist_name=_NRCELLname3, p_name='gscn'),
]

PARAMS_TO_MODIFY_20MHz_FDD_TMO = [
    dict(value='20MHz', dist_name=_NRCELLname1 + '/NRCELL_FDD-1', p_name='chBwDl'),
    dict(value='20MHz', dist_name=_NRCELLname1 + '/NRCELL_FDD-1', p_name='chBwUl'),
    dict(value='127400', dist_name=_NRCELLname1 + '/NRCELL_FDD-1', p_name='nrarfcnDl'),
    dict(value='136600', dist_name=_NRCELLname1 + '/NRCELL_FDD-1', p_name='nrarfcnUl'),
    dict(value='20MHz', dist_name=_NRCELLname2 + '/NRCELL_FDD-1', p_name='chBwDl'),
    dict(value='20MHz', dist_name=_NRCELLname2 + '/NRCELL_FDD-1', p_name='chBwUl'),
    dict(value='127400', dist_name=_NRCELLname2 + '/NRCELL_FDD-1', p_name='nrarfcnDl'),
    dict(value='136600', dist_name=_NRCELLname2 + '/NRCELL_FDD-1', p_name='nrarfcnUl'),
    dict(value='20MHz', dist_name=_NRCELLname3 + '/NRCELL_FDD-1', p_name='chBwDl'),
    dict(value='20MHz', dist_name=_NRCELLname3 + '/NRCELL_FDD-1', p_name='chBwUl'),
    dict(value='127400', dist_name=_NRCELLname3 + '/NRCELL_FDD-1', p_name='nrarfcnDl'),
    dict(value='136600', dist_name=_NRCELLname3 + '/NRCELL_FDD-1', p_name='nrarfcnUl'),
    dict(value='1579', dist_name=_NRCELLname1, p_name='gscn'),
    dict(value='1579', dist_name=_NRCELLname2, p_name='gscn'),
    dict(value='1579', dist_name=_NRCELLname3, p_name='gscn'),
]
