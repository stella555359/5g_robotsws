import os
from robot.libraries.BuiltIn import BuiltIn

tl = BuiltIn().get_variable_value("${tl}")
CFG_DIR = os.path.dirname(os.path.abspath(__file__))
_gnb_id_0 = str(tl.gnbs[0].instance_id)
_MRBTSname_0 = 'MRBTS-'+_gnb_id_0
_NRBTSname_0 = _MRBTSname_0+'/NRBTS-'+_gnb_id_0
_NRCELLname_0 = _NRBTSname_0+'/NRCELL-1'
_NRCELLname_01 = _NRBTSname_0+'/NRCELL-2'

_gnb_id_1 = str(tl.gnbs[1].instance_id)
_MRBTSname_1 = 'MRBTS-'+_gnb_id_1
_NRBTSname_1 = _MRBTSname_1+'/NRBTS-'+_gnb_id_1
_NRCELLname_1 = _NRBTSname_1+'/NRCELL-1'
_NRLIM_1 = _NRBTSname_1+'/NRSYSINFO_PROFILE-1/NRLIM-1'

MODIFY_LOCKG_0 = [
    dict(
        value='Locked',
        dist_name=_NRCELLname_0,
        parameter='administrativeState')
]

MODIFY_LOCKG_01 = [
    dict(
        value='Locked',
        dist_name=_NRCELLname_0,
        parameter='administrativeState'),
    dict(
        value='Locked',
        dist_name=_NRCELLname_01,
        parameter='administrativeState')
]

MODIFY_LOCKG_1 = [
    dict(
        value='Locked',
        dist_name=_NRCELLname_1,
        parameter='administrativeState')
]

MODIFY_UNLOCKG_0 = [
    dict(
        value='Unlocked',
        dist_name=_NRCELLname_0,
        parameter='administrativeState')
]

MODIFY_UNLOCKG_01 = [
    dict(
        value='Unlocked',
        dist_name=_NRCELLname_0,
        parameter='administrativeState'),
    dict(
        value='Unlocked',
        dist_name=_NRCELLname_01,
        parameter='administrativeState')
]

MODIFY_UNLOCKG_1 = [
    dict(
        value='Unlocked',
        dist_name=_NRCELLname_1,
        parameter='administrativeState')
]

PARAMS_OF_LTE_BLACKLIST_on_gNB2 = [
    dict(
        value=[dict(physCellId='50')],
        dist_name=_NRLIM_1,
        parameter='pciBlackList'),
]
