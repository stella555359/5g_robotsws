from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value("${tl}")

__maintainer__ = 'qionghua.zhang'
__team__ = 'I_MN_5G_RAN_IV4_LINE_HZG_3_GMS <I_MN_5G_RAN_IV4_LINE_HZG_3@internal.nsn.com>'
__email__ = 'qionghua.zhang@nokia-sbell.com'

_class_name = 'com.nokia.srbts.mnl:MPLANENW'

_gnb_id = str(tl.gnbs[0].instance_id)
_enb_id = str(tl.enbs[0].instance_id)
_MRBTSname = 'MRBTS-'+_gnb_id
_NRBTSname = _MRBTSname+'/NRBTS-'+_gnb_id
_LNBTSSname = _MRBTSname+'/LNBTS-'+_enb_id
_NRCELLname = _NRBTSname+'/NRCELL-1'
_LNCEL1name = _LNBTSSname+'/LNCEL-1'
_LNCEL2name = _LNBTSSname+'/LNCEL-2'
_LNCEL3name = _LNBTSSname+'/LNCEL-3'
_LNCEL4name = _LNBTSSname+'/LNCEL-4'
_LNCEL5name = _LNBTSSname+'/LNCEL-5'
_LNCEL6name = _LNBTSSname+'/LNCEL-6'
_NRREDRTname = _NRCELLname+'/NRREDRT-0'

PATH_TO_SCF = ''

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

PARAMS_TO_MODIFY_LTE_LOCKG1 = [
    dict(
        value='locked',
        dist_name=_LNCEL1name,
        parameter='administrativeState')
]


PARAMS_TO_MODIFY_LTE_UNLOCKG1 = [
    dict(
        value='unlocked',
        dist_name=_LNCEL1name,
        parameter='administrativeState')
]

PARAMS_TO_MODIFY_LTE_LOCKG2 = [
    dict(
        value='locked',
        dist_name=_LNCEL2name,
        parameter='administrativeState')
]


PARAMS_TO_MODIFY_LTE_UNLOCKG2 = [
    dict(
        value='unlocked',
        dist_name=_LNCEL2name,
        parameter='administrativeState')
]

PARAMS_TO_MODIFY_LTE_LOCKG3 = [
    dict(
        value='locked',
        dist_name=_LNCEL3name,
        parameter='administrativeState')
]


PARAMS_TO_MODIFY_LTE_UNLOCKG3 = [
    dict(
        value='unlocked',
        dist_name=_LNCEL3name,
        parameter='administrativeState')
]

PARAMS_TO_MODIFY_LTE_LOCKG4 = [
    dict(
        value='locked',
        dist_name=_LNCEL4name,
        parameter='administrativeState')
]


PARAMS_TO_MODIFY_LTE_UNLOCKG4 = [
    dict(
        value='unlocked',
        dist_name=_LNCEL4name,
        parameter='administrativeState')
]

PARAMS_TO_MODIFY_LTE_LOCKG5 = [
    dict(
        value='locked',
        dist_name=_LNCEL5name,
        parameter='administrativeState')
]


PARAMS_TO_MODIFY_LTE_UNLOCKG5 = [
    dict(
        value='unlocked',
        dist_name=_LNCEL5name,
        parameter='administrativeState')
]

PARAMS_TO_MODIFY_LTE_LOCKG6 = [
    dict(
        value='locked',
        dist_name=_LNCEL6name,
        parameter='administrativeState')
]


PARAMS_TO_MODIFY_LTE_UNLOCKG6 = [
    dict(
        value='unlocked',
        dist_name=_LNCEL6name,
        parameter='administrativeState')
]

AMOUNT_OF_CELLS = 1
