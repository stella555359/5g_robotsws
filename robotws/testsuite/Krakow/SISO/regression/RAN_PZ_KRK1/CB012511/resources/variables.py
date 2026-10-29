from taf.rfrl.utilities.robot.general import is_dry_run
from taf.rfrl.bts.devices.du.du_operations import GnbDuOperations
from taf.rfrl.bts.helpers.sw_versions import SbtsSwVersion, SwVersionFactory


parameters_to_change = [
    [
        {
            'dist_name': 'MRBTS-{}/NRBTS-{}',
            'parameter': 'Activate Paging',
            'value': 'true',
            'verification_value': 'true',
            'online': True
        },
        {
            'dist_name': 'MRBTS-{}/NRBTS-{}/NRPMRNL-1',
            'parameter': 'NR Paging',
            'value': '5min',
            'verification_value': '5min',
            'online': True
        },
    ],
    [
        {
            'dist_name': 'MRBTS-{}/NRBTS-{}/NRCELL-0',
            'parameter': 'PRACH configuration index',
            'value': '14',
            'verification_value': '14',
            'online': True
        },
    ],
    [
        {
            'dist_name': 'MRBTS-{}/MNL-1/MNLENT-1/SYNC-1',
            'parameter': 'Manual frame timing adjustment',
            'value': '1',
            'verification_value': '1 µs',
            'online': False
        },
    ],
    [
        {
            'dist_name': 'MRBTS-{}/NRBTS-{}/NRCELL-0',
            'parameter': 'Maximum output power',
            'value': '30',
            'verification_value': '30 dBm',
            'online': True
        },
    ],
]

incorrect_parameters = [
    {
        'dist_name': 'MRBTS-{}/NRBTS-{}/NRCELL-1',
        'parameter': 'Maximum output power',
        'value': '100',
        'verification_value': '27 dBm'
    },
]

delta_deactivate_rat_reset_enh = [{
    'distName': 'MRBTS-{}/MNL-1/MNLENT-1/FEATCADM-1',
    'operation': 'update',
    'parameters': [
        {
            'operation': 'update',
            'parameterName': 'actRatResetEnhancement',
            'value': 'false'},
        {
            'operation': 'update',
            'parameterName': 'actL1ReconfigImprovement',
            'value': 'false'},
        {
            'operation': 'update',
            'parameterName': 'actBbReconfigImprovement',
            'value': 'false'},
    ]
}]

delta_activate_rat_reset_enh = [{
    'distName': 'MRBTS-{}/MNL-1/MNLENT-1/FEATCADM-1',
    'operation': 'update',
    'parameters': [
        {
            'operation': 'update',
            'parameterName': 'actRatResetEnhancement',
            'value': 'true'},
        {
            'operation': 'update',
            'parameterName': 'actL1ReconfigImprovement',
            'value': 'true'},
        {
            'operation': 'update',
            'parameterName': 'actBbReconfigImprovement',
            'value': 'true'},
    ]
}]

allowed_alarms_during_cell_block = ['Cell blocked']

allowed_alarms_during_site_block = ['BTS blocked']


def _is_actRatResetEnhancement_frozen(active_sw_version):
    """ From 25R3 release onwards this parameter is frozen and its value can only be set to 'TRUE'"""
    if active_sw_version >= SbtsSwVersion('SBTS25R3_ENB_0000_000000_000000'):
        return True
    else:
        return False


def get_allowed_alarms_wifi(active_sw_version):
    """ Check PR865987 """
    if active_sw_version >= SbtsSwVersion('SBTS26R2_ENB_0000_000000_000000'):
        return [{'fault_id': 61675, 'fault_name': 'WiFi Configuration Issue'},
                {'fault_id': 61673, 'fault_name': 'WiFi Enabled Alarm'}]
    else:
        return [{'fault_id': 61675, 'fault_name': 'WiFi Configuration Issue'},
                {'fault_id': 61673, 'fault_name': 'Wifi Enabled Alarm'}]


def get_variables():
    if is_dry_run():
        return {}

    gnb_obj = GnbDuOperations()
    active_sw = gnb_obj.get_bts_sw_version()
    active_sw_version = SwVersionFactory.create_sw_version(active_sw)

    variables = {
        'allowed_alarms_during_cell_block': allowed_alarms_during_cell_block,
        'allowed_alarms_during_site_block': allowed_alarms_during_site_block,
        'delta_activate_rat_reset_enh': delta_activate_rat_reset_enh,
        'delta_deactivate_rat_reset_enh': delta_deactivate_rat_reset_enh,
        'incorrect_parameters': incorrect_parameters,
        'parameters_to_change': parameters_to_change,
        'allowed_alarms_during_tl_prep': get_allowed_alarms_wifi(active_sw_version),
        'is_actRatResetEnhancement_frozen': _is_actRatResetEnhancement_frozen(active_sw_version),
        'CUSTOM_ALLOWED_ALARMS': get_allowed_alarms_wifi(active_sw_version)
    }

    return variables
