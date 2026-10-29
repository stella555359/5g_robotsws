from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value("${tl}")

__maintainer__ = 'liujia'
__team__ = 'I_MN_5G_RAN_IV4_LINE_HZG_3@internal.nsn.com'
__email__ = 'jia-rebecca.liu@nokia-sbell.com'

_class_name = 'com.nokia.srbts.mnl:MPLANENW'

_gnb_id = str(tl.gnbs[0].instance_id)
_global_bts_id = str(tl.gnbs[0].global_bts_id)
_MRBTS1_name = 'MRBTS-'+_global_bts_id
_NRBTS1_name = _MRBTS1_name+'/NRBTS-'+_gnb_id
_NRCELL1_name = _NRBTS1_name+'/NRCELL-1'
_NRCELL2_name = _NRBTS1_name+'/NRCELL-2'
_NRCELL3_name = _NRBTS1_name+'/NRCELL-3'
_NRCELL37401_name = _NRBTS1_name+'/NRCELL-37401'
_NRCELL37402_name = _NRBTS1_name+'/NRCELL-37402'
_NRCELL37403_name = _NRBTS1_name+'/NRCELL-37403'
_NRCELL3_NRREL1 = _NRCELL3_name+'/NRREL-256'
_NRCELL3_NRREL2 = _NRCELL3_name+'/NRREL-255'
_NRCELL1_NRREL1 = _NRCELL1_name+'/NRREL-256'
_NRCELL1_NRREL2 = _NRCELL1_name+'/NRREL-255'
_NRCELL2_NRREL1 = _NRCELL2_name+'/NRREL-256'
_NRCELL2_NRREL2 = _NRCELL2_name+'/NRREL-255'
_SERVEDAMF_1 = _NRBTS1_name+'/SERVEDAMF-1'
_bwpDN5 = _NRBTS1_name+'/BWP_PROFILE-5'
_bwpDN53 = _NRBTS1_name+'/BWP_PROFILE-53'
_bwpDN52 = _NRBTS1_name+'/BWP_PROFILE-52'
_bwpDN57 = _NRBTS1_name+'/BWP_PROFILE-57'
_NRPMRNL_1 = _NRBTS1_name+'/NRPMRNL-1'

PATH_TO_SCF = ''

# ----------------------swconfig-------------------#
Enable_RD_Flag = [
    '0x450027 = 1',
]
# ----------------------counter----------------- #
counter_dic_path_b34001 = [
    'BTS/{}/NRCELL-37403/NRUC'.format(_NRBTS1_name),
    'BTS/{}/NRCELL-37403/NRUC'.format(_NRBTS1_name),
    'BTS/{}/NRCELL-37403/NULH'.format(_NRBTS1_name),
    'BTS/{}/NRCELL-37403/NULH'.format(_NRBTS1_name),
]

counter_id_b34001 = [
    'M55165C00037', 'M55165C00038', 'M55370C00033', 'M55370C00037',
]

counter_dic_path_C56001 = [
    'BTS/{}/NRCELL-3/NRUC'.format(_NRBTS1_name),
    'BTS/{}/NRCELL-3/NRUC'.format(_NRBTS1_name),
    'BTS/{}/NRCELL-3/NRUC'.format(_NRBTS1_name),
    'BTS/{}/NRCELL-3/NULH'.format(_NRBTS1_name),
    'BTS/{}/NRCELL-3/NULH'.format(_NRBTS1_name),
    'BTS/{}/NRCELL-3/NULH'.format(_NRBTS1_name),
    'BTS/{}/NRCELL-3/NULH'.format(_NRBTS1_name),
    'BTS/{}/NRCELL-3/NULH'.format(_NRBTS1_name),
    'BTS/{}/NRCELL-3/NULH'.format(_NRBTS1_name),
]

counter_id_C56001 = [
    'M55165C00036', 'M55165C00037', 'M55165C00038',
    'M55370C00032', 'M55370C00033', 'M55370C00034',
    'M55370C00035', 'M55370C00036', 'M55370C00037',
]

counter_dic_path_D4001 = [
    'BTS/{}/NRCELL-1/NRUC'.format(_NRBTS1_name),
    'BTS/{}/NRCELL-1/NRUC'.format(_NRBTS1_name),
    'BTS/{}/NRCELL-1/NULH'.format(_NRBTS1_name),
    'BTS/{}/NRCELL-1/NULH'.format(_NRBTS1_name),
    'BTS/{}/NRCELL-1/NULH'.format(_NRBTS1_name),
    'BTS/{}/NRCELL-1/NULH'.format(_NRBTS1_name),
    'BTS/{}/NRCELL-1/NULH'.format(_NRBTS1_name),
    'BTS/{}/NRCELL-2/NLRLC'.format(_NRBTS1_name),
    'BTS/{}/NRCELL-3/NLRLC'.format(_NRBTS1_name),

]

counter_id_D4001 = [
    'M55165C00036', 'M55165C00037', 'M55370C00032',
    'M55370C00034', 'M55370C00035', 'M55370C00036', 'M55370C00037',
    'M55310C20000', 'M55310C20000'
]

# -------------------------alwaysoff--------------------------- #
MODIFY_PARA_PucchF3_alwaysoff = [
    dict(
        value='false',
        dist_name=_NRCELL37403_name,
        p_name='pucchF3Rel16Pi2BpskAlwaysOn'),
    dict(
        value='true',
        dist_name=_NRCELL37403_name,
        p_name='actUlDftSOfdm'),
    dict(
        value='true',
        dist_name=_NRCELL37403_name,
        p_name='actRel16DmrsForPucchF3'),
    dict(
        value='true',
        dist_name=_NRCELL37403_name,
        p_name='actRel16DmrsForPusch'),
    dict(
        value='qpsk_4psk',
        dist_name=_NRCELL37403_name,
        p_name='pucchF3ModulationScheme'),
]

MODIFY_LIST_PucchF3_alwaysoff = [
    dict(dist_name=_NRCELL37403_name, list_name='ulTransPrecodeCtl',
         elements=[dict(p_name='ulTransPrePi2BpskPwrBoost', value='false', index=0)]),
    dict(dist_name=_NRCELL37403_name, list_name='ulTransPrecodeCtl',
         elements=[dict(p_name='ulTransPrecodePi2Bpsk', value='true', index=0)]),
]

# -----------------------CB007103_B#34_001---------------------- #
Online_MODIFY_B34001 = [
    dict(
        value='true',
        dist_name=_NRCELL37403_name,
        parameter='actRel16DmrsForPucchF3'),
    dict(
        value='false',
        dist_name=_NRCELL37403_name,
        parameter='actRel16DmrsForPusch'),
    dict(
        value='false',
        dist_name=_NRCELL37403_name,
        parameter='actPucchAdditionalDmrs'),
    dict(
        value='qpsk_4psk',
        dist_name=_NRCELL37403_name,
        parameter='pucchF3ModulationScheme'),
    dict(value=[dict(ulTransPrecodePi2Bpsk='true', ulTransPrePi2BpskPwrBoost='false')],
         dist_name=_NRCELL37401_name, parameter='ulTransPrecodeCtl')
]

# -------------------------CB007103_C#5&6_001----------------------- #

Online_MODIFY_C56001 = [
    dict(
        value='true',
        dist_name=_NRCELL3_name,
        parameter='actRel16DmrsForPucchF3'),
    dict(
        value='qpsk_4psk',
        dist_name=_NRCELL3_name,
        parameter='pucchF3ModulationScheme'),
    dict(
        value='true',
        dist_name=_NRCELL3_name,
        parameter='actRel16DmrsForPusch'),
    dict(value=[dict(ulTransPrecodePi2Bpsk='true', ulTransPrePi2BpskPwrBoost='false')],
         dist_name=_NRCELL3_name, parameter='ulTransPrecodeCtl')
]

# -------------------------CB007103_D#1_001----------------------- #
Online_MODIFY_D1001 = [
    dict(
        value='blind',
        dist_name=_NRCELL1_NRREL1,
        parameter='sCellAdditionMethod'),
    dict(
        value='dlOnly',
        dist_name=_NRCELL1_NRREL1,
        parameter='sCellOperationalMode'),
    dict(
        value='blind',
        dist_name=_NRCELL2_NRREL1,
        parameter='sCellAdditionMethod'),
    dict(
        value='dlOnly',
        dist_name=_NRCELL2_NRREL1,
        parameter='sCellOperationalMode'),
    dict(
        value='blind',
        dist_name=_NRCELL3_NRREL1,
        parameter='sCellAdditionMethod'),
    dict(
        value='blind',
        dist_name=_NRCELL3_NRREL2,
        parameter='sCellAdditionMethod'),
    dict(
        value='dlOnly',
        dist_name=_NRCELL3_NRREL1,
        parameter='sCellOperationalMode'),
    dict(
        value='dlOnly',
        dist_name=_NRCELL3_NRREL2,
        parameter='sCellOperationalMode'),
    dict(
        value='true',
        dist_name=_NRCELL3_name,
        parameter='actRel16DmrsForPucchF3'),
    dict(
        value='qpsk_4psk',
        dist_name=_NRCELL3_name,
        parameter='pucchF3ModulationScheme'),
    dict(
        value='true',
        dist_name=_NRCELL3_name,
        parameter='actRel16DmrsForPusch'),
    dict(value=[dict(ulTransPrecodePi2Bpsk='true', ulTransPrePi2BpskPwrBoost='false')],
         dist_name=_NRCELL3_name, parameter='ulTransPrecodeCtl'),
    dict(
        value='true',
        dist_name=_NRCELL1_name,
        parameter='actRel16DmrsForPucchF3'),
    dict(
        value='qpsk_4psk',
        dist_name=_NRCELL1_name,
        parameter='pucchF3ModulationScheme'),
    dict(
        value='true',
        dist_name=_NRCELL1_name,
        parameter='actRel16DmrsForPusch'),
    dict(value=[dict(ulTransPrecodePi2Bpsk='true', ulTransPrePi2BpskPwrBoost='false')],
         dist_name=_NRCELL1_name, parameter='ulTransPrecodeCtl'),
    dict(
        value='barred',
        dist_name=_NRCELL1_name,
        parameter='cellBarred'),
    dict(
        value='barred',
        dist_name=_NRCELL2_name,
        parameter='cellBarred'),
]

Online_MODIFY_unbarred = [
    dict(
        value='notBarred',
        dist_name=_NRCELL1_name,
        parameter='cellBarred'),
    dict(
        value='notBarred',
        dist_name=_NRCELL2_name,
        parameter='cellBarred'),
    dict(
        value='notBarred',
        dist_name=_NRCELL3_name,
        parameter='cellBarred'),
]

# -------------------------CB007103_D#4_001----------------------- #
Online_MODIFY_D4001 = [
    dict(
        value='blind',
        dist_name=_NRCELL1_NRREL1,
        parameter='sCellAdditionMethod'),
    dict(
        value='dlOnly',
        dist_name=_NRCELL1_NRREL1,
        parameter='sCellOperationalMode'),
    dict(
        value='blind',
        dist_name=_NRCELL1_NRREL2,
        parameter='sCellAdditionMethod'),
    dict(
        value='dlOnly',
        dist_name=_NRCELL1_NRREL2,
        parameter='sCellOperationalMode'),
    dict(
        value='blind',
        dist_name=_NRCELL2_NRREL1,
        parameter='sCellAdditionMethod'),
    dict(
        value='dlOnly',
        dist_name=_NRCELL2_NRREL1,
        parameter='sCellOperationalMode'),
    dict(
        value='blind',
        dist_name=_NRCELL3_NRREL1,
        parameter='sCellAdditionMethod'),
    dict(
        value='blind',
        dist_name=_NRCELL3_NRREL2,
        parameter='sCellAdditionMethod'),
    dict(
        value='dlOnly',
        dist_name=_NRCELL3_NRREL1,
        parameter='sCellOperationalMode'),
    dict(
        value='dlOnly',
        dist_name=_NRCELL3_NRREL2,
        parameter='sCellOperationalMode'),
    dict(
        value='true',
        dist_name=_NRCELL3_name,
        parameter='actRel16DmrsForPucchF3'),
    dict(
        value='qpsk_4psk',
        dist_name=_NRCELL3_name,
        parameter='pucchF3ModulationScheme'),
    dict(
        value='true',
        dist_name=_NRCELL3_name,
        parameter='actRel16DmrsForPusch'),
    dict(value=[dict(ulTransPrecodePi2Bpsk='true', ulTransPrePi2BpskPwrBoost='false')],
         dist_name=_NRCELL3_name, parameter='ulTransPrecodeCtl'),
    dict(
        value='true',
        dist_name=_NRCELL1_name,
        parameter='actRel16DmrsForPucchF3'),
    dict(
        value='qpsk_4psk',
        dist_name=_NRCELL1_name,
        parameter='pucchF3ModulationScheme'),
    dict(
        value='true',
        dist_name=_NRCELL1_name,
        parameter='actRel16DmrsForPusch'),
    dict(value=[dict(ulTransPrecodePi2Bpsk='true', ulTransPrePi2BpskPwrBoost='false')],
         dist_name=_NRCELL1_name, parameter='ulTransPrecodeCtl'),
    dict(
        value='barred',
        dist_name=_NRCELL3_name,
        parameter='cellBarred'),
    dict(
        value='barred',
        dist_name=_NRCELL2_name,
        parameter='cellBarred'),
    dict(
        value='notBarred',
        dist_name=_NRCELL1_name,
        parameter='cellBarred'),
]

ONLINE_MODIFY_D4001_FDD_TDD = [
    dict(
        value='blind',
        dist_name=_NRCELL2_NRREL2,
        parameter='sCellAdditionMethod'),
    dict(
        value='dlAndUl',
        dist_name=_NRCELL2_NRREL2,
        parameter='sCellOperationalMode'),
    dict(
        value='barred',
        dist_name=_NRCELL3_name,
        parameter='cellBarred'),
    dict(
        value='notBarred',
        dist_name=_NRCELL2_name,
        parameter='cellBarred'),
    dict(
        value='barred',
        dist_name=_NRCELL1_name,
        parameter='cellBarred'),
    dict(
        value='true',
        dist_name=_NRCELL1_name,
        parameter='increasePUSCHPrepTimeULCA'),
]
# -------------------------alwayson-------------------------- #
MODIFY_PARA_PucchF3_alwayson = [
    dict(
        value='true',
        dist_name=_NRCELL37403_name,
        p_name='pucchF3Rel16Pi2BpskAlwaysOn'),
    dict(
        value='true',
        dist_name=_NRCELL37403_name,
        p_name='actUlDftSOfdm'),
    dict(
        value='false',
        dist_name=_NRCELL37403_name,
        p_name='actRel16DmrsForPucchF3'),
    dict(
        value='true',
        dist_name=_NRCELL37403_name,
        p_name='actPucchAdditionalDmrs'),
    dict(
        value='qpsk_4psk',
        dist_name=_NRCELL37403_name,
        p_name='pucchF3ModulationScheme'),
    dict(
        value='false',
        dist_name=_NRCELL37403_name,
        p_name='actPucchF3EnhanceDTX'),
]

MODIFY_LIST_PucchF3_alwayson = [
    dict(dist_name=_NRCELL37403_name, list_name='ulTransPrecodeCtl',
         elements=[dict(p_name='ulTransPrePi2BpskPwrBoost', value='false', index=0)]),
    dict(dist_name=_NRCELL37403_name, list_name='ulTransPrecodeCtl',
         elements=[dict(p_name='ulTransPrecodePi2Bpsk', value='true', index=0)]),
]

# -----------------------CB007103_B#1_001---------------------- #
Online_Modify_B1001_casesetup = [
    dict(
        value='false',
        dist_name=_NRCELL3_name,
        parameter='actRel16DmrsForPusch'),
    dict(
        value='false',
        dist_name=_NRCELL3_name,
        parameter='actRel16DmrsForPucchF3'),
]

Online_Modify_B1001 = [
    dict(
        value='true',
        dist_name=_NRCELL3_name,
        parameter='actRel16DmrsForPucchF3'),
]

# -----------------------CB007103_C#1_001---------------------- #
ONLINE_MODIFY_C1001_1 = [
    dict(
        value='false',
        dist_name=_NRCELL3_name,
        parameter='actRel16DmrsForPucchF3'),
    dict(
        value='false',
        dist_name=_NRCELL3_name,
        parameter='actRel16DmrsForPusch'),
]

ONLINE_MODIFY_C1001_2 = [
    dict(
        value='true',
        dist_name=_NRCELL3_name,
        parameter='actRel16DmrsForPucchF3'),
    dict(
        value='true',
        dist_name=_NRCELL3_name,
        parameter='actRel16DmrsForPusch'),
]


# ----------------C#2_001------------------- #
Online_MODIFY_C2001 = [
    dict(
        value='false',
        dist_name=_NRCELL37403_name,
        parameter='actRel16DmrsForPucchF3'),
    dict(
        value='pi2bpsk',
        dist_name=_NRCELL37403_name,
        parameter='pucchF3ModulationScheme'),
    dict(
        value='false',
        dist_name=_NRCELL37403_name,
        parameter='actRel16DmrsForPusch'),
]

ONLINE_MODIFY_C2001_2 = [
    dict(
        value='true',
        dist_name=_NRCELL37403_name,
        parameter='actRel16DmrsForPucchF3'),
    dict(
        value='true',
        dist_name=_NRCELL37403_name,
        parameter='actRel16DmrsForPusch'),
]

# ----------------F#9_001------------------- #
Online_MODIFY_F9001 = [
    dict(
        value='true',
        dist_name=_NRCELL3_name,
        parameter='actRel16DmrsForPucchF3'),
    dict(
        value='qpsk_4psk',
        dist_name=_NRCELL3_name,
        parameter='pucchF3ModulationScheme'),
    dict(
        value='true',
        dist_name=_NRCELL3_name,
        parameter='actRel16DmrsForPusch'),
    dict(
        value='false',
        dist_name=_NRCELL3_name,
        parameter='pucchF3Rel16Pi2BpskAlwaysOn'),
    dict(
        value='true',
        dist_name=_NRCELL3_name,
        parameter='actAdaptiveReTxResMcs'),
    dict(value=[dict(ulTransPrecodePi2Bpsk='true', ulTransPrePi2BpskPwrBoost='false')],
         dist_name=_NRCELL3_name, parameter='ulTransPrecodeCtl')
]
