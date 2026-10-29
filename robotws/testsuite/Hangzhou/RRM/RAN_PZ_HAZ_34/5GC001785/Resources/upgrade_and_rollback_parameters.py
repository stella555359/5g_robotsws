from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value("${tl}")

__maintainer__ = 'Shi Ming'
__team__ = 'I_MN_5G_RAN_IV4_LINE_HZG_3_GMS <I_MN_5G_RAN_IV4_LINE_HZG_3@internal.nsn.com>'
__email__ = 'ming.shi@nokia-sbell.com'

_class_name = 'com.nokia.srbts.mnl:MPLANENW'

_gnb_id = str(tl.gnbs[0].instance_id)
_enb_id = str(tl.enbs[0].instance_id)
_BB1SFP1LANEname = 'MRBTS-'+_enb_id+'/EQM-1/APEQM-1/CABINET-1/BBMOD-1/SFP-1/LANE-1'
_BB1SFP2LANEname = 'MRBTS-'+_enb_id+'/EQM-1/APEQM-1/CABINET-1/BBMOD-1/SFP-2/LANE-1'
_BB2SFP1LANEname = 'MRBTS-'+_enb_id+'/EQM-1/APEQM-1/CABINET-1/BBMOD-2/SFP-1/LANE-1'
_BB3SFP1LANEname = 'MRBTS-'+_enb_id+'/EQM-1/APEQM-1/CABINET-1/BBMOD-3/SFP-1/LANE-1'
_BB3SFP2LANEname = 'MRBTS-'+_enb_id+'/EQM-1/APEQM-1/CABINET-1/BBMOD-3/SFP-2/LANE-1'
_BB3SFP3LANEname = 'MRBTS-'+_enb_id+'/EQM-1/APEQM-1/CABINET-1/BBMOD-3/SFP-3/LANE-1'


PARAM_enb_Lock_SFP_LANE = [
    dict(value='Locked', dist_name=_BB1SFP1LANEname, parameter='administrativeState'),
    dict(value='Locked', dist_name=_BB1SFP2LANEname, parameter='administrativeState'),
    dict(value='Locked', dist_name=_BB2SFP1LANEname, parameter='administrativeState'),
    dict(value='Locked', dist_name=_BB3SFP1LANEname, parameter='administrativeState'),
    dict(value='Locked', dist_name=_BB3SFP2LANEname, parameter='administrativeState'),
    dict(value='Locked', dist_name=_BB3SFP3LANEname, parameter='administrativeState'),
]
PARAM_enb_Unlock_SFP_LANE = [
    dict(value='Unlocked', dist_name=_BB1SFP1LANEname, parameter='administrativeState'),
    dict(value='Unlocked', dist_name=_BB1SFP2LANEname, parameter='administrativeState'),
    dict(value='Unlocked', dist_name=_BB2SFP1LANEname, parameter='administrativeState'),
    dict(value='Unlocked', dist_name=_BB3SFP1LANEname, parameter='administrativeState'),
    dict(value='Unlocked', dist_name=_BB3SFP2LANEname, parameter='administrativeState'),
    dict(value='Unlocked', dist_name=_BB3SFP3LANEname, parameter='administrativeState'),
]
