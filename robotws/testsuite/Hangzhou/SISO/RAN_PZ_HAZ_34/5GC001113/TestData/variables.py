from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')
program = BuiltIn().get_variable_value('${PROGRAM}')
# # General_SiSo_E2E_system_setup_with_data_transfer
# Exp_Len = '5m'
# frame_structure_list_100MHz = ['1116_0ms_GP2_A7']

# rate_for_stream = {
#     '20A': 'peak',
#     '20B': '0.8',
#     'master': '0.8'
# }
if program == '21B':
    GSCN_NAME = 'gscn'
else:
    GSCN_NAME = 'gscnOrSsPbchArfcn'

# General_SiSo_NR-ARFCN_check
MODIFY_NRARFCN_HIGHEST_BOUNDARY_AEQB_REQUIRED_RANGE_VIA_API_2 = [
    dict(
        value='636666',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-1',
        parameter='nrarfcn'),
    dict(
        value='7880',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-1',
        parameter=GSCN_NAME),
    dict(
        value='10',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-1',
        parameter='type0CoresetConfigurationIndex')
]

MODIFY_NRARFCN_LOWEST_BOUNDARY_AEQB_REQUIRED_RANGE_VIA_API_4 = [
    dict(
        value='630000',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-1',
        parameter='nrarfcn'),
    dict(
        value='7811',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-1',
        parameter=GSCN_NAME),
    dict(
        value='10',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-1',
        parameter='type0CoresetConfigurationIndex')
]

MODIFY_CHBW_30MHZ_VIA_API = [
    dict(
        value='30MHz',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-1',
        parameter='chBw'
    ),
]
