from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')
MODIFY_INVALID_MCS_VIA_WEBUI = [
    dict(
        new_value='-1',
        dist_name='NRCELL-1',
        abbr='ullaIniMcs',
        filter_param='Initial MCS for UL Transmission'),
    dict(
        new_value='30',
        dist_name='NRCELL-1',
        abbr='dllaIniMcs',
        filter_param='Initial MCS for DL Transmission')
]

# For modifying nidd parameters such as, nrarfcn - cell_1 , bandwidth - cell_2, pmax - cell_3
# Value above the AEQB required range.
MODIFY_VALUE_ABOVE_AEQB_REQUIRED_RANGE_VIA_API = [
    dict(
        value='2059003',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-1',
        parameter='nrarfcn'),
    dict(
        value='380',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-2',
        parameter='pMax')
]

# For modifying nidd parameters such as, nrarfcn - cell_1 , bandwidth - cell_2, pmax - cell_3
# Value below the AEQB required range.
MODIFY_VALUE_BELOW_AEQB_REQUIRED_RANGE_VIA_API = [
    dict(
        value='290030',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-1',
        parameter='nrarfcn'),
    dict(
        value='180',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-2',
        parameter='pMax')
]

# For modifying nidd parameters such as, nrarfcn - cell_1 , bandwidth - cell_2, pmax - cell_3
# Value ewithin the AEQB required range.
MODIFY_VALUE_WITHIN_AEQB_REQUIRED_RANGE_VIA_API = [
    dict(
        value='633356',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-1',
        parameter=' nrarfcn'),
    dict(
        value='280',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-2',
        parameter='pMax')
]

MODIFY_NRARFCN_WITH_AEQB_MIDDLE_BAND_EDGE_VALUE_VIA_API_1 = [
    dict(
        value='630000',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-1',
        parameter='nrarfcn')
]

MODIFY_NRARFCN_WITH_AEQB_MIDDLE_BAND_EDGE_VALUE_VIA_API_2 = [
    dict(
        value='636666',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-1',
        parameter='nrarfcn')
]

DISABLE_256QAM_VIA_API = [
    dict(
        value='false',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-1',
        parameter='actDl256Qam')
]


MODIFY_CHBW_100M = [
    dict(
        new_value='100MHz',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-1',
        filter_param='Channel bandwidth',
        abbr='chBw')
]

MODIFY_CHBW_90M = [
    dict(
        new_value='90MHz',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-1',
        filter_param='Channel bandwidth',
        abbr='chBw')
]
