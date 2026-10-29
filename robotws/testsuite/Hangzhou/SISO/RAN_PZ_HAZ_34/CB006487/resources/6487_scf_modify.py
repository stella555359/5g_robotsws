from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')
MR_BTS_NAME = 'MRBTS-' + str(tl.gnbs[0].instance_id)
MR_NR_BTS_NAME = MR_BTS_NAME + '/NRBTS-' + str(tl.gnbs[0].global_bts_id)
NR_NAME = 'NRBTS-' + str(tl.gnbs[0].global_bts_id)
NR_CELL_NAME1 = NR_NAME + '/NRCELL-1'
NR_CELL_NAME2 = NR_NAME + '/NRCELL-2'
CABLINK_5_distname = MR_BTS_NAME+'/EQM-1/HWTOP-1/CABLINK-5'
CABLINK_3_distname = MR_BTS_NAME+'/EQM-1/HWTOP-1/CABLINK-3'

config_22 = [
    dict(value=MR_BTS_NAME+'/'+NR_NAME+'/BWP_PROFILE-53',
         dist_name=NR_CELL_NAME2, p_name='bwpDN', list_name='cellBwpList', index='1'),
    dict(
        value='60MHz',
        dist_name=NR_CELL_NAME2,
        p_name='chBw')
]

config_23 = [
    dict(value=MR_BTS_NAME+'/'+NR_NAME+'/BWP_PROFILE-54',
         dist_name=NR_CELL_NAME2, p_name='bwpDN', list_name='cellBwpList', index='1'),
    dict(
        value='80MHz',
        dist_name=NR_CELL_NAME2,
        p_name='chBw')
]

config_24 = [
    dict(value=MR_BTS_NAME+'/'+NR_NAME+'/BWP_PROFILE-54',
         dist_name=NR_CELL_NAME2, p_name='bwpDN', list_name='cellBwpList', index='1'),
    dict(
        value='100MHz',
        dist_name=NR_CELL_NAME2,
        p_name='chBw')
]

config_21 = [
    dict(value=MR_BTS_NAME+'/'+NR_NAME+'/BWP_PROFILE-52',
         dist_name=NR_CELL_NAME2, p_name='bwpDN', list_name='cellBwpList', index='1'),
    dict(
        value='50MHz',
        dist_name=NR_CELL_NAME2,
        p_name='chBw')
]

config_20 = [
    dict(value=MR_BTS_NAME+'/'+NR_NAME+'/BWP_PROFILE-51',
         dist_name=NR_CELL_NAME2, p_name='bwpDN', list_name='cellBwpList', index='1'),
    dict(
        value='40MHz',
        dist_name=NR_CELL_NAME2,
        p_name='chBw'),
    dict(
        value='80MHz',
        dist_name=NR_CELL_NAME1,
        p_name='chBw')
]

config_19 = [
    dict(value=MR_BTS_NAME + '/' + NR_NAME + '/BWP_PROFILE-51',
         dist_name=NR_CELL_NAME2, p_name='bwpDN', list_name='cellBwpList', index='1'),
    dict(value=MR_BTS_NAME + '/' + NR_NAME + '/BWP_PROFILE-52',
         dist_name=NR_CELL_NAME1, p_name='bwpDN', list_name='cellBwpList', index='1'),
    dict(
        value='40MHz',
        dist_name=NR_CELL_NAME2,
        p_name='chBw'),
    dict(
        value='50MHz',
        dist_name=NR_CELL_NAME1,
        p_name='chBw')
]

config_18 = [
    dict(value=MR_BTS_NAME + '/' + NR_NAME + '/BWP_PROFILE-51',
         dist_name=NR_CELL_NAME2, p_name='bwpDN', list_name='cellBwpList', index='1'),
    dict(value=MR_BTS_NAME + '/' + NR_NAME + '/BWP_PROFILE-50',
         dist_name=NR_CELL_NAME1, p_name='bwpDN', list_name='cellBwpList', index='1'),
    dict(
        value='40MHz',
        dist_name=NR_CELL_NAME2,
        p_name='chBw'),
    dict(
        value='20MHz',
        dist_name=NR_CELL_NAME1,
        p_name='chBw')
]
