from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value("${tl}")

__maintainer__ = 'liujia'
__team__ = 'I_MN_5G_RAN_IV4_LINE_HZG_3@internal.nsn.com'
__email__ = 'jia-rebecca.liu@nokia-sbell.com'

_class_name = 'com.nokia.srbts.mnl:MPLANENW'

_gnb_id = str(tl.gnbs[0].instance_id)
_MRBTS1_name = 'MRBTS-'+_gnb_id
_NRBTS1_name = _MRBTS1_name+'/NRBTS-'+_gnb_id
_NRCELL1_name = _NRBTS1_name+'/NRCELL-1'
_NRCELL2_name = _NRBTS1_name+'/NRCELL-2'
_NRCELL3_name = _NRBTS1_name+'/NRCELL-3'
_SERVEDAMF_1 = _NRBTS1_name+'/SERVEDAMF-1'
_SERVEDAMF_2 = _NRBTS1_name+'/SERVEDAMF-2'
_bwpDN5 = _NRBTS1_name+'/BWP_PROFILE-5'
_bwpDN53 = _NRBTS1_name+'/BWP_PROFILE-53'
_bwpDN57 = _NRBTS1_name+'/BWP_PROFILE-57'
_NRPMRNL = _NRBTS1_name+'/NRPMRNL-1'
_UL_RLC_delay = 'BTS/BTS/NRBTS-' + _gnb_id + '/NRDU-1/NHRLC'
_DL_RLC_delay = 'BTS/CELLS/NRCELL-1/NLRLC'
_DL_PDCP_Report1 = 'BTS/NRBTS-' + _gnb_id + '/PDCP1'
_DL_PDCP_Report2 = 'BTS/NRBTS-' + _gnb_id + '/PDCP2'
_NR_cell_Utilization = 'BTS/CELLS/NRCELL-1/NCELA'
_NRCELL1_NRREL = _NRCELL1_name + '/NRREL-1'
_NRDU1 = _NRBTS1_name + '/NRDU-1'
PATH_TO_SCF = ''


ADD_PARA_Online = [
    dict(value='blind', dist_name=_NRCELL1_NRREL, parameter='sCellAdditionMethod'),
    dict(value='dlOnly', dist_name=_NRCELL1_NRREL, parameter='sCellOperationalMode'),
]

Modify_Para_Online_010 = [
    dict(
        value='Locked',
        dist_name=_SERVEDAMF_1,
        parameter='administrativeState'),
    dict(
        value='Unlocked',
        dist_name=_SERVEDAMF_2,
        parameter='administrativeState'),
]

Modify_Para_recovery_010 = [
    dict(
        value='Unlocked',
        dist_name=_SERVEDAMF_1,
        parameter='administrativeState'),
    dict(
        value='Locked',
        dist_name=_SERVEDAMF_2,
        parameter='administrativeState'),
]

Modify_Para_Online_CA = [
    dict(
        value='false',
        dist_name=_NRCELL3_name,
        parameter='actDlVoNrLimMaxMcsAndLayer'),
]

Modify_Para_recovery_CA = [
    dict(
        value='true',
        dist_name=_NRCELL3_name,
        parameter='actDlVoNrLimMaxMcsAndLayer'),
]
