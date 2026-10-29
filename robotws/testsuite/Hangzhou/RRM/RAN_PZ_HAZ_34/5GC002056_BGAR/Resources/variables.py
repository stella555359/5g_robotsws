from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value("${tl}")

__maintainer__ = 'LiuJia'
__team__ = 'I_MN_5G_RAN_IV4_LINE_HZG_3_GMS <I_MN_5G_RAN_IV4_LINE_HZG_3@internal.nsn.com>'
__email__ = 'jia-rebecca.liu@nokia-sbell.com'

_class_name = 'com.nokia.srbts.mnl:MPLANENW'

_gnb_id = str(tl.gnbs[0].instance_id)
_MRBTSname = 'MRBTS-'+_gnb_id
_NNRBTSname = 'NRBTS-'+_gnb_id
_NRBTSname = _MRBTSname+'/NRBTS-'+_gnb_id
_NRCELL1_name = _NRBTSname+'/NRCELL-1'
_NRCELL2_name = _NRBTSname+'/NRCELL-2'
_bwpDN5 = _NRBTSname+'/BWP_PROFILE-5'
_bwpDN53 = _NRBTSname+'/BWP_PROFILE-53'
_bwpDN52 = _NRBTSname+'/BWP_PROFILE-52'
_bwpDN57 = _NRBTSname+'/BWP_PROFILE-57'

PARA_Modify_online_C07_22R3 = [
    dict(
        value='true',
        dist_name=_NRCELL1_name,
        parameter='actEirpControl'),
    dict(
        value=['-60', '-60', '-60', '-60', '-60', '-60', '-60', '-60', '-60', '-60', '-60', '-60'],
        dist_name=_NRCELL1_name,
        parameter='eirpControlPowerReductionFactorList',
    )
]

PARA_Modify_online_C07_Trunk = [
    dict(
        value='true',
        dist_name=_NRCELL1_name,
        parameter='actEirpControl'),
    dict(
        value=['-60', '-60', '-60', '-60', '-60', '-60', '-60', '-60', '-60', '-60', '-60', '-60'],
        dist_name=_NRCELL1_name,
        parameter='eirpControlPowerReductionFactorList',
    )
]

PARA_Modify_online_C07_22R2 = [
    dict(
        value='true',
        dist_name=_NRCELL2_name,
        parameter='actEirpControl'),
    dict(
        value=['-80', '-80', '-80', '-80', '-80', '-80', '-80', '-80', '-80', '-80', '-80', '-80'],
        dist_name=_NRCELL2_name,
        parameter='eirpControlPowerReductionFactorList',
    )
]

counter_id_C07_1 = [
    'M55324C00464', 'M55324C00400', 'M55324C00401', 'M55324C00402', 'M55324C00403', 'M55324C00404', 'M55324C00405'
]

counter_id_C07_0 = [
    'M55324C004'
]

counter_dic_path_CELL1 = [
    'BTS/CELLS/NRCELL-1/NREIRP'
]

counter_dic_path_CELL1_24R2 = [
    'BTS/{}/NRCELL-1/NREIRP'.format(_NRBTSname)
]

counter_dic_path_CELL2 = [
    'BTS/CELLS/NRCELL-2/NREIRP'
]

LOCK_GNB1_CELL1 = [
    dict(
        value='Locked',
        dist_name=_NRCELL1_name,
        parameter='administrativeState')
]

UNLOCK_GNB1_CELL1 = [
    dict(
        value='Unlocked',
        dist_name=_NRCELL1_name,
        parameter='administrativeState')
]

PARA_TO_DELETE = [
    dict(dist_name=_NRCELL1_name, list_name='tddFrameStructure')
]

PARA_TO_DELETE_22R2 = [
    dict(dist_name=_NRCELL2_name, list_name='tddFrameStructure')
]

LIST_TO_ADD_Trunk = [
    dict(
        dist_name=_NRCELL1_name,
        list_name='tddFrameStructure',
        elements=dict(
            frameStructureType='semiStatic',
            guardPeriodLength='2Symbols',
            ulDlDataSlotRatio='1/4'))
]

LIST_TO_ADD_22R2 = [
    dict(
        dist_name=_NRCELL2_name,
        list_name='tddFrameStructure',
        elements=dict(
            frameStructureType='semiStatic',
            guardPeriodLength='2Symbols',
            ulDlDataSlotRatio='1/4'))
]

PARA_TO_MODIFY_Trunk = [
    dict(dist_name=_NRCELL1_name, p_name='prachConfigurationIndex', value='157'),
    dict(dist_name=_NRCELL1_name, p_name='actDlMuMimo', value='false')
]

PARA_TO_MODIFY_22R2 = [
    dict(dist_name=_NRCELL2_name, p_name='prachConfigurationIndex', value='157'),
    dict(dist_name=_NRCELL2_name, p_name='actDlMuMimo', value='false'),
    dict(dist_name=_NRCELL1_name, p_name='administrativeState', value='Locked')
]

PARA_TO_MODIFY_22R3 = [
    dict(dist_name=_NRCELL1_name, p_name='chBw', value='60MHz'),
    dict(dist_name=_NRCELL1_name, p_name='actDlMuMimo', value='false')
]

LIST_TO_MODIFY_Trunk = [
    dict(dist_name=_NRCELL1_name, list_name='cellBwpList',
         elements=[dict(p_name='bwpDN', value=_bwpDN5, index=0),
                   dict(p_name='bwpDN', value=_bwpDN57, index=1)])
]

LIST_TO_MODIFY_22R3 = [
    dict(dist_name=_NRCELL1_name, list_name='cellBwpList',
         elements=[dict(p_name='bwpDN', value=_bwpDN5, index=0),
                   dict(p_name='bwpDN', value=_bwpDN53, index=1)])
]

LIST_TO_MODIFY_22R2 = [
    dict(dist_name=_NRCELL2_name, list_name='cellBwpList',
         elements=[dict(p_name='bwpDN', value=_bwpDN5, index=0),
                   dict(p_name='bwpDN', value=_bwpDN57, index=1),
                   dict(p_name='bwpDN', value=_bwpDN52, index=2)
                   ])
]

swconfig_C007_FLAG = [
    '0x58057b=0x201',
]
