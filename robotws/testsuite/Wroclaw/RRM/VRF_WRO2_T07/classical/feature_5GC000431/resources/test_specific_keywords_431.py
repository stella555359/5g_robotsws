import json
import datetime
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.admin_utils import AdminUtils
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.tl_config import tl
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.testline_preparation import wait_for_onair
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.admin_api import AdminApi
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log import blog
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.scf_tools.delta_modifier import edit_delta_object
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.scf_tools.scf_manager import ScfManager
from ute_common_admin.exception import AdminApiProcedureFailureException
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.decorators import logged_keyword


swconfig_flags_431 = {'0x590072': ('1', '5GC000431 flag'), '0x5900a9': ('30', '5GC000431 flag'),
                      '0x5900aa': ('12', '5GC000431 flag')}

utils_api = AdminUtils()
mrbts_id = tl.gnbs[0].global_bts_id
nrbts_id = tl.gnbs[0].instance_id
release = ""


@logged_keyword
def initialize():
    try:
        global mrbts_id, nrbts_id
        mrbts_id, nrbts_id = utils_api.get_bts_ids()
        with AdminApi() as web_api_:
            global release
            release = web_api_.get_sw_release_name()
    except Exception as exception:
        blog("Setting bts ids from init due to ", exception)


initialize()


@logged_keyword
def add_nrpgrp_object():
    if release == "":
        initialize()
    delta = {'distName': 'MRBTS-{mrbts_id}/NRBTS-{nrbts_id}/NRPGRP-1'.format(mrbts_id=mrbts_id,
                                                                             nrbts_id=nrbts_id),
             'lbpsCSONCtlEnabled': 'false',
             'lbpsCellList': [
                 {'lbpsCellSOOrder': 100, 'nrCellId': 1, 'lbpsUseExtConfig': 'false'},
                 {'lbpsCellSOOrder': 1, 'nrCellId': 2, 'lbpsUseExtConfig': 'false'},
                 {'lbpsCellSOOrder': 3, 'nrCellId': 3, 'lbpsUseExtConfig': 'false'}],
             'lbpsLastCellMinLoad': 2,
             'lbpsLastCellSOEnabled': 'false',
             'lbpsMaxLoad': 40,
             'lbpsMinLoad': 20,
             'lbpsPdcchLoadOffset': 15,
             'lbpsPeriodList': [
                 {'lbpsDayOfWeek': 'Thu',
                  'lbpsDuration': '60',
                  'lbpsStartTimeHour': '14',
                  'lbpsStartTimeMinute': '4',
                  'lbpsSuspended': 'notSuspended'},
                 {'lbpsDayOfWeek': 'Thu',
                  'lbpsDuration': '60',
                  'lbpsStartTimeHour': '14',
                  'lbpsStartTimeMinute': '4',
                  'lbpsSuspended': 'suspended'}],
             'lbpsSOMethod': 'cell switch off'}
    if release in ['SBTS22R{}'.format(i) for i in range(1, 4)]:
        delta.pop('lbpsSOMethod')

    if release in ['SBTS' + str(version) for version in ['2{}R{}'.format(i, j) for i in [2, 3] for j in range(1, 5)]
                   if version.split('SBTS')[0] not in ['23R3', '23R4']]:
        for cell in delta['lbpsCellList']:
            cell.pop('lbpsUseExtConfig')
    edit_delta_object(**delta)


@logged_keyword
def feature_activate(bool_value):
    delta = [
        {
            'distName': 'MRBTS-{mrbts_id}/NRBTS-{nrbts_id}'.format(mrbts_id=mrbts_id, nrbts_id=nrbts_id),
            'operation': 'update',
            'parameters': [
                {
                    'parameterName': 'actNrLBPowerSaving',
                    'value': bool_value,
                    'operation': 'update'
                }
            ]
        }
    ]
    with AdminApi() as web_api:
        web_api.perform_delta_recommissioning(json.dumps(delta))


@logged_keyword
def save_scf_file():
    scf_file_path = utils_api.download_current_scf(local_dir_path='/tmp',
                                                   file_name='scf_backup.xml')
    return scf_file_path


@logged_keyword
def lpbsso_with_too_small_value():
    try:
        set_lpbs_cells_order_delta(first_cell_order=-1, second_cell_order=2)
    except AdminApiProcedureFailureException as e:
        blog("AdminApiProcedureFailureException occurred")
        assert 'VALUE_IS_TOO_SMALL' in e.message, 'Given value should raise error "VALUE_IS_TOO_SMALL"'


@logged_keyword
def lpbsso_with_correct_value():
    set_lpbs_cells_order_delta(first_cell_order=1, second_cell_order=2)


@logged_keyword
def lpbsso_with_too_big_value():
    try:
        set_lpbs_cells_order_delta(first_cell_order=101, second_cell_order=2)
    except AdminApiProcedureFailureException as e:
        blog("AdminApiProcedureFailureException occurred")
        assert 'VALUE_IS_TOO_BIG' in e.message, 'Given value should raise error "VALUE_IS_TOO_BIG"'


@logged_keyword
def lpbsso_with_two_same_values():
    try:
        set_lpbs_cells_order_delta(first_cell_order=1, second_cell_order=1)
    except AdminApiProcedureFailureException as e:
        blog("AdminApiProcedureFailureException occurred")
        assert '(value: 1) must be unique' in e.message, \
            'Given value should raise error "(value: 1) must be unique"'


@logged_keyword
def lpbsso_with_two_hundreds():
    set_lpbs_cells_order_delta(first_cell_order=100, second_cell_order=100)


@logged_keyword
def set_lpbs_cells_order_delta(first_cell_order, second_cell_order):
    delta = [
        {
            'distName': 'MRBTS-{mrbts_id}/NRBTS-{nrbts_id}/NRPGRP-1'.format(mrbts_id=mrbts_id,
                                                                            nrbts_id=nrbts_id),
            'operation': 'update',
            'parameters': [
                {
                    'parameterName': 'lbpsCellList',
                    'value': [
                        {
                            'lbpsCellSOOrder': first_cell_order,
                            'nrCellId': 1,
                            'lbpsUseExtConfig': 'false'
                        },
                        {
                            'lbpsCellSOOrder': second_cell_order,
                            'nrCellId': 2,
                            'lbpsUseExtConfig': 'false'
                        },
                        {
                            'lbpsCellSOOrder': 3,
                            'nrCellId': 3,
                            'lbpsUseExtConfig': 'false'
                        }
                    ],
                    'operation': 'update'
                }
            ]
        }
    ]

    if release in ['SBTS' + str(version) for version in ['2{}R{}'.format(i, j) for i in [2, 3] for j in range(1, 5)]
                   if version.split('SBTS')[0] not in ['23R3', '23R4']]:
        for cell in delta[0]['parameters'][0]['value']:
            cell.pop('lbpsUseExtConfig')
    with AdminApi() as web_api:
        web_api.perform_delta_recommissioning(json.dumps(delta))


@logged_keyword
def lbps_nrcellid_correct():
    cell_ids = []
    with AdminApi() as web_api:
        results = web_api.get_cells_info()
        for cell in results:
            cell_ids.append(cell['globalCellId'])
    set_lbps_nrcellid_param_delta(first_cell_id=cell_ids[0], second_cell_id=cell_ids[1],
                                  third_cell_id=cell_ids[2])


@logged_keyword
def lbps_nrcellid_two_same_values():
    cell_ids = []
    with AdminApi() as web_api:
        results = web_api.get_cells_info()
        for cell in results:
            cell_ids.append(cell['globalCellId'])
    try:
        set_lbps_nrcellid_param_delta(first_cell_id=cell_ids[0], second_cell_id=cell_ids[0],
                                      third_cell_id=cell_ids[2])
    except AdminApiProcedureFailureException as e:
        blog("AdminApiProcedureFailureException occurred")
        assert '(value: {}) must be unique'.format(cell_ids[0]) in e.message, \
            'Given value should raise error "(value: {}) must be unique"'.format(cell_ids[0])


@logged_keyword
def lbps_nrcellid_incorrect_value():
    cell_ids = []
    with AdminApi() as web_api:
        results = web_api.get_cells_info()
        for cell in results:
            cell_ids.append(cell['globalCellId'])
    try:
        set_lbps_nrcellid_param_delta(first_cell_id=cell_ids[0] + 15,
                                      second_cell_id=cell_ids[1],
                                      third_cell_id=cell_ids[2])
    except AdminApiProcedureFailureException as e:
        blog("AdminApiProcedureFailureException occurred")
        assert 'NRCELL-* having NRCELL.nrCellId equal to ${NRPGRP-1.lbpsCellList-1.nrCellId}' in e.message, \
            'Given value should raise error ' \
            '"NRCELL-* having NRCELL.nrCellId equal to ${NRPGRP-1.lbpsCellList-1.nrCellId}"'


@logged_keyword
def set_lbps_nrcellid_param_delta(first_cell_id, second_cell_id, third_cell_id):

    delta = [
        {
            'distName': 'MRBTS-{mrbts_id}/NRBTS-{nrbts_id}/NRPGRP-1'.format(mrbts_id=mrbts_id,
                                                                            nrbts_id=nrbts_id),
            'operation': 'update',
            'parameters': [
                {
                    'parameterName': 'lbpsCellList',
                    'value': [
                        {
                            'lbpsCellSOOrder': 100,
                            'nrCellId': first_cell_id,
                            'lbpsUseExtConfig': 'false'
                        },
                        {
                            'lbpsCellSOOrder': 1,
                            'nrCellId': second_cell_id,
                            'lbpsUseExtConfig': 'false'
                        },
                        {
                            'lbpsCellSOOrder': 3,
                            'nrCellId': third_cell_id,
                            'lbpsUseExtConfig': 'false'
                        }
                    ],
                    'operation': 'update'
                }
            ]
        }
    ]

    if release in ['SBTS' + str(version) for version in ['2{}R{}'.format(i, j) for i in [2, 3] for j in range(1, 5)]
                   if version.split('SBTS')[0] not in ['23R3', '23R4']]:
        for cell in delta[0]['parameters'][0]['value']:
            cell.pop('lbpsUseExtConfig')
    with AdminApi() as web_api:
        web_api.perform_delta_recommissioning(json.dumps(delta))


@logged_keyword
def lpbs_last_cell_min_load_below_range():
    try:
        set_lpbs_last_cell_min_load_delta(last_cell_min_load_value=-1)
    except AdminApiProcedureFailureException as e:
        blog("AdminApiProcedureFailureException occurred")
        assert 'VALUE_IS_TOO_SMALL' in e.message, 'Given value should raise error "VALUE_IS_TOO_SMALL"'


@logged_keyword
def lpbs_last_cell_min_load_in_range():
    set_lpbs_last_cell_min_load_delta(last_cell_min_load_value=5)


@logged_keyword
def lpbs_last_cell_min_load_above_range():
    try:
        set_lpbs_last_cell_min_load_delta(last_cell_min_load_value=101)
    except AdminApiProcedureFailureException as e:
        blog("AdminApiProcedureFailureException occurred")

        assert 'VALUE_IS_TOO_BIG' in e.message, 'Given value should raise error "VALUE_IS_TOO_BIG"'


@logged_keyword
def set_lpbs_last_cell_min_load_delta(last_cell_min_load_value):
    delta = [
        {
            'distName': 'MRBTS-{mrbts_id}/NRBTS-{nrbts_id}/NRPGRP-1'.format(mrbts_id=mrbts_id,
                                                                            nrbts_id=nrbts_id),
            'operation': 'update',
            'parameters': [
                {
                    'parameterName': 'lbpsLastCellMinLoad',
                    'value': last_cell_min_load_value,
                    'operation': 'update'
                }
            ]
        }
    ]
    with AdminApi() as web_api:
        web_api.perform_delta_recommissioning(json.dumps(delta))


@logged_keyword
def lpbs_max_load_below_range():
    try:
        set_lpbs_max_load_delta(max_load_value=-1)
    except AdminApiProcedureFailureException as e:
        blog("AdminApiProcedureFailureException occurred")
        assert 'VALUE_IS_TOO_SMALL' in e.message, 'Given value should raise error "VALUE_IS_TOO_SMALL"'


@logged_keyword
def lpbs_max_load_in_range():
    set_lpbs_max_load_delta(max_load_value=55)


@logged_keyword
def lpbs_max_load_above_range():
    try:
        set_lpbs_max_load_delta(max_load_value=101)
    except AdminApiProcedureFailureException as e:
        blog("AdminApiProcedureFailureException occurred")
        assert 'VALUE_IS_TOO_BIG' in e.message, 'Given value should raise error "VALUE_IS_TOO_BIG"'


@logged_keyword
def set_lpbs_max_load_delta(max_load_value):
    delta = [
        {
            'distName': 'MRBTS-{mrbts_id}/NRBTS-{nrbts_id}/NRPGRP-1'.format(mrbts_id=mrbts_id,
                                                                            nrbts_id=nrbts_id),
            'operation': 'update',
            'parameters': [
                {
                    'parameterName': 'lbpsMaxLoad',
                    'value': max_load_value,
                    'operation': 'update'
                }
            ]
        }
    ]
    with AdminApi() as web_api:
        web_api.perform_delta_recommissioning(json.dumps(delta))


@logged_keyword
def lpbs_min_load_below_range():
    try:
        set_lpbs_min_load_delta(min_load_value=-1)
    except AdminApiProcedureFailureException as e:
        blog("AdminApiProcedureFailureException occurred")
        assert 'VALUE_IS_TOO_SMALL' in e.message, 'Given value should raise error "VALUE_IS_TOO_SMALL"'


@logged_keyword
def lpbs_min_load_in_range():
    set_lpbs_min_load_delta(min_load_value=15)


@logged_keyword
def lpbs_min_load_above_range():
    try:
        set_lpbs_min_load_delta(min_load_value=101)
    except AdminApiProcedureFailureException as e:
        blog("AdminApiProcedureFailureException occurred")
        assert 'VALUE_IS_TOO_BIG' in e.message, 'Given value should raise error "VALUE_IS_TOO_BIG"'


@logged_keyword
def lpbs_min_load_higher_than_max_load():
    try:
        set_lpbs_min_load_delta(min_load_value=50, max_load_value=30)
    except AdminApiProcedureFailureException as e:
        blog("AdminApiProcedureFailureException occurred")
        assert 'greater/equal to ${NRPGRP-1.lbpsMinLoad}' in e.message, \
            'Given value should raise error "greater/equal to ${NRPGRP-1.lbpsMinLoad}"'


@logged_keyword
def set_lpbs_min_load_delta(min_load_value, max_load_value=55):
    delta = [
        {
            'distName': 'MRBTS-{mrbts_id}/NRBTS-{nrbts_id}/NRPGRP-1'.format(mrbts_id=mrbts_id,
                                                                            nrbts_id=nrbts_id),
            'operation': 'update',
            'parameters': [
                {
                    'parameterName': 'lbpsMinLoad',
                    'value': min_load_value,
                    'operation': 'update'
                },
                {
                    'parameterName': 'lbpsMaxLoad',
                    'value': max_load_value,
                    'operation': 'update'
                }
            ]
        }
    ]

    with AdminApi() as web_api:
        web_api.perform_delta_recommissioning(json.dumps(delta))


@logged_keyword
def lbps_pdcch_load_offset_below_range():
    try:
        set_lbps_pdcch_load_offset_delta(pdcch_load_offset_value=-1)
    except AdminApiProcedureFailureException as e:
        blog("AdminApiProcedureFailureException occurred")
        assert 'VALUE_IS_TOO_SMALL' in e.message, 'Given value should raise error "VALUE_IS_TOO_SMALL"'


@logged_keyword
def lbps_pdcch_load_offset_in_range():
    set_lbps_pdcch_load_offset_delta(pdcch_load_offset_value=5)


@logged_keyword
def lbps_pdcch_load_offset_above_range():
    try:
        set_lbps_pdcch_load_offset_delta(pdcch_load_offset_value=101)
    except AdminApiProcedureFailureException as e:
        blog("AdminApiProcedureFailureException occurred")
        assert 'VALUE_IS_TOO_BIG' in e.message, 'Given value should raise error "VALUE_IS_TOO_BIG"'


@logged_keyword
def set_lbps_pdcch_load_offset_delta(pdcch_load_offset_value):
    delta = [
        {
            'distName': 'MRBTS-{mrbts_id}/NRBTS-{nrbts_id}/NRPGRP-1'.format(mrbts_id=mrbts_id,
                                                                            nrbts_id=nrbts_id),
            'operation': 'update',
            'parameters': [
                {
                    'parameterName': 'lbpsPdcchLoadOffset',
                    'value': pdcch_load_offset_value,
                    'operation': 'update'
                }
            ]
        }
    ]
    with AdminApi() as web_api:
        web_api.perform_delta_recommissioning(json.dumps(delta))


@logged_keyword
def set_lbps_day_of_week_delta():
    days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
    for day in days:
        set_lbps_period_list_delta(day=day)


@logged_keyword
def lbps_duration_below_range():
    try:
        set_lbps_period_list_delta(duration=0)
    except AdminApiProcedureFailureException as e:
        blog("AdminApiProcedureFailureException occurred")
        assert 'VALUE_IS_TOO_SMALL' in e.message, 'Given value should raise error "VALUE_IS_TOO_SMALL"'


@logged_keyword
def lbps_duration_in_range():
    set_lbps_period_list_delta(duration=60)


@logged_keyword
def lbps_duration_above_range():
    try:
        set_lbps_period_list_delta(duration=1441)
    except AdminApiProcedureFailureException as e:
        blog("AdminApiProcedureFailureException occurred")
        assert 'VALUE_IS_TOO_BIG' in e.message, 'Given value should raise error "VALUE_IS_TOO_BIG"'


@logged_keyword
def lbps_start_time_hour_below_range():
    try:
        set_lbps_period_list_delta(hour=-1)
    except AdminApiProcedureFailureException as e:
        blog("AdminApiProcedureFailureException occurred")
        assert 'VALUE_IS_TOO_SMALL' in e.message, 'Given value should raise error "VALUE_IS_TOO_SMALL"'


@logged_keyword
def lbps_start_time_hour_in_range():
    set_lbps_period_list_delta(hour=12)


@logged_keyword
def lbps_start_time_hour_above_range():
    try:
        set_lbps_period_list_delta(hour=24)
    except AdminApiProcedureFailureException as e:
        blog("AdminApiProcedureFailureException occurred")
        assert 'VALUE_IS_TOO_BIG' in e.message, 'Given value should raise error "VALUE_IS_TOO_BIG"'


@logged_keyword
def lbps_start_time_minute_below_range():
    try:
        set_lbps_period_list_delta(minute=-1)
    except AdminApiProcedureFailureException as e:
        blog("AdminApiProcedureFailureException occurred")
        assert 'VALUE_IS_TOO_SMALL' in e.message, 'Given value should raise error "VALUE_IS_TOO_SMALL"'


@logged_keyword
def lbps_start_time_minute_in_range():
    set_lbps_period_list_delta(minute=30)


@logged_keyword
def lbps_start_time_minute_above_range():
    try:
        set_lbps_period_list_delta(minute=61)
    except AdminApiProcedureFailureException as e:
        blog("AdminApiProcedureFailureException occurred")
        assert 'VALUE_IS_TOO_BIG' in e.message, 'Given value should raise error "VALUE_IS_TOO_BIG"'


@logged_keyword
def set_lbps_period_list_delta(day='Mon', duration=60, hour=12, minute=30):
    delta = [
        {
            'distName': 'MRBTS-{mrbts_id}/NRBTS-{nrbts_id}/NRPGRP-1'.format(mrbts_id=mrbts_id,
                                                                            nrbts_id=nrbts_id),
            'operation': 'update',
            'parameters': [
                {
                    'parameterName': 'lbpsPeriodList',
                    'value': [
                        {
                            'lbpsDayOfWeek': day,
                            'lbpsDuration': duration,
                            'lbpsStartTimeHour': hour,
                            'lbpsStartTimeMinute': minute,
                            'lbpsSuspended': 'notSuspended'
                        }
                    ],
                    'operation': 'update'
                }
            ]
        }
    ]
    with AdminApi() as web_api:
        web_api.perform_delta_recommissioning(json.dumps(delta))


@logged_keyword
def check_feature_activation():
    with ScfManager() as Scf:
        feature_act_value = Scf.get_all_values_from_scf(dist_name='MRBTS-{mrbts_id}/NRBTS-{nrbts_id}'.
                                                        format(mrbts_id=mrbts_id,
                                                               nrbts_id=nrbts_id),
                                                        p_name='actNrLBPowerSaving')
        return str(feature_act_value[0])


@logged_keyword
def check_if_all_cells_are_not_saving_energy():
    state = []
    with AdminApi() as web_api:
        result = web_api.get_cells_info()
        for elem in range(len(result)):
            state.append(result[elem]['energySavingState'])
            if result[elem]['energySavingState'] == 'energySaving':
                stt = False
                assert stt, 'at least one of cells is on energySavingMode'


@logged_keyword
def set_cell_handover_correlated_params():
    cell_ids = []
    with AdminApi() as web_api:
        results = web_api.get_cells_info()
        for cell in results:
            cell_ids.append(cell['globalCellId'])
    for cell_id in cell_ids:
        delta = [
            {
                'distName': 'MRBTS-{mrbts_id}/NRBTS-{nrbts_id}/NRCELL-{cell_id}'.format(mrbts_id=mrbts_id,
                                                                                        nrbts_id=nrbts_id,
                                                                                        cell_id=cell_id),
                'operation': 'update',
                'parameters': [
                    {
                        'parameterName': 'a3MeasSsbRsrp',
                        'value': [
                            {
                                'a3HysteresisSsbRsrp': 1,
                                'a3OffsetSsbRsrp': 1,
                                'a3TimeToTriggerSsbRsrp': 'ms320',
                            }
                        ],
                        'operation': 'update'
                    },
                    {
                        'parameterName': 'a3MeasEnabled',
                        'value': 'rsrp',
                        'operation': 'update'
                    }
                ]
            }
        ]

        with AdminApi() as web_api:
            web_api.perform_delta_recommissioning(json.dumps(delta))


@logged_keyword
def activate_handover():
    delta = [
        {
            'distName': 'MRBTS-{mrbts_id}/NRBTS-{nrbts_id}'.format(mrbts_id=mrbts_id,
                                                                   nrbts_id=nrbts_id),
            'operation': 'update',
            'parameters': [
                {
                    'parameterName': 'actIntraFreqHoSA',
                    'value': 'true',
                    'operation': 'update'
                },
                {
                    'parameterName': 'actIntraFreqIntraGnbMobilityNSA',
                    'value': 'true',
                    'operation': 'update'
                }
            ]
        },
        {
            'distName': 'MRBTS-{mrbts_id}/NRBTS-{nrbts_id}/NRPMRNL-1'.format(mrbts_id=mrbts_id,
                                                                             nrbts_id=nrbts_id),
            'operation': 'update',
            'parameters': [
                {
                    'parameterName': 'miNrRelReportCu',
                    'value': '5min',
                    'operation': 'update'
                }
            ]
        }
    ]

    with AdminApi() as web_api:
        web_api.perform_delta_recommissioning(json.dumps(delta))


@logged_keyword
def set_cell_relation_parameters():
    cell_ids = []
    with AdminApi() as web_api:
        results = web_api.get_cells_info()
        for cell in results:
            cell_ids.append(cell['globalCellId'])
    for cell_id in cell_ids:
        nr_rel = 0
        for relation in range(1, len(cell_ids) + 1):
            if relation == cell_id:
                continue  # Skip this iteration if relation equals cell_id
            nr_rel += 1
            delta = [
                {
                    'distName': 'MRBTS-{mrbts_id}/NRBTS-{nrbts_id}/NRCELL-{cell_id}/NRREL-{nr_rel}'
                    .format(mrbts_id=mrbts_id, nrbts_id=nrbts_id, cell_id=cell_id, nr_rel=nr_rel),
                    'operation': 'update',
                    'parameters': [
                        {
                            'parameterName': 'cellIndividualSsbRsrpOffset',
                            'value': '0dB',
                            'operation': 'update'
                        },
                        {
                            'parameterName': 'cellIndividualSsbRsrqOffset',
                            'value': '0dB',
                            'operation': 'update'
                        },
                        {
                            'parameterName': 'lcrId',
                            'value': '{relation}'.format(relation=relation),
                            'operation': 'update'
                        },
                        {
                            'parameterName': 'removeNotAllowed',
                            'value': 'false',
                            'operation': 'update'
                        }
                    ]
                }
            ]
            try:
                with AdminApi() as web_api:
                    web_api.perform_delta_recommissioning(json.dumps(delta))
            except Exception as e:
                print(f"Error processing cell_id {cell_id} with relation {relation}: {e}")
                continue  # Continue to the next relation or cell_id


@logged_keyword
def set_graceful_cell_shutdown(window=60, step_amount=10):
    delta = [
        {
            'distName': 'MRBTS-{mrbts_id}/NRBTS-{nrbts_id}'.format(mrbts_id=mrbts_id,
                                                                   nrbts_id=nrbts_id),
            'operation': 'update',
            'parameters': [
                {
                    'parameterName': 'shutdownWindow',
                    'value': window,
                    'operation': 'update'
                },
                {
                    'parameterName': 'shutdownStepAmount',
                    'value': step_amount,
                    'operation': 'update'
                },
                {
                    'parameterName': 'actGrflShdn',
                    'value': 'true',
                    'operation': 'update'
                }
            ]
        }
    ]
    with AdminApi() as web_api:
        web_api.perform_delta_recommissioning(json.dumps(delta))


@logged_keyword
def get_hour_from_gnb_vm():
    return int(datetime.datetime.now().hour)


@logged_keyword
def get_minute_from_gnb_vm():
    return int(datetime.datetime.now().minute)


@logged_keyword
def get_day_of_week_from_gnb_vm():
    day_number = int(datetime.datetime.today().weekday())
    days = {0: 'Mon', 1: 'Tue', 2: 'Wed', 3: 'Thu', 4: 'Fri', 5: 'Sat', 6: 'Sun'}
    return days[day_number]


@logged_keyword
def set_cell_power_saving_mode_preconditions(timeoffset=2, max_load=40, min_load=20):
    with AdminApi() as web_api:
        delta = [
            {
                'distName': 'MRBTS-{mrbts_id}/NRBTS-{nrbts_id}/NRPGRP-1'.format(mrbts_id=mrbts_id,
                                                                                nrbts_id=nrbts_id),
                'operation': 'update',
                'parameters': [
                    {
                        'parameterName': 'lbpsCSONCtlEnabled',
                        'value': 'false',
                        'operation': 'update'
                    },
                    {
                        'parameterName': 'lbpsLastCellMinLoad',
                        'value': 2,
                        'operation': 'update'
                    },
                    {
                        'parameterName': 'lbpsLastCellSOEnabled',
                        'value': 'false',
                        'operation': 'update'
                    },
                    {
                        'parameterName': 'lbpsMaxLoad',
                        'value': max_load,
                        'operation': 'update'
                    },
                    {
                        'parameterName': 'lbpsMinLoad',
                        'value': min_load,
                        'operation': 'update'
                    },
                    {
                        'parameterName': 'lbpsPdcchLoadOffset',
                        'value': 15,
                        'operation': 'update'
                    },
                    {
                        'parameterName': 'lbpsCellList',
                        'value': [
                            {
                                'lbpsCellSOOrder': 100,
                                'nrCellId': 1,
                                'lbpsUseExtConfig': 'false'
                            },
                            {
                                'lbpsCellSOOrder': 1,
                                'nrCellId': 2,
                                'lbpsUseExtConfig': 'false'
                            },
                            {
                                'lbpsCellSOOrder': 2,
                                'nrCellId': 3,
                                'lbpsUseExtConfig': 'false'
                            }
                        ],
                        'operation': 'update'
                    }
                ]
            }
        ]

        if release in ['SBTS' + str(version) for version in ['2{}R{}'.format(i, j) for i in [2, 3] for j in range(1, 5)]
                       if version.split('SBTS')[0] not in ['23R3', '23R4']]:
            for cell in delta[0]['parameters'][6]['value']:
                cell.pop('lbpsUseExtConfig')
        web_api.perform_delta_recommissioning(json.dumps(delta))
    set_power_saving_period_entrance(timeoffset=timeoffset)


@logged_keyword
def set_power_saving_period_entrance(timeoffset=2):
    minute_with_offset = get_minute_from_gnb_vm() + int(timeoffset)
    hour_precondition = get_hour_from_gnb_vm()

    if minute_with_offset >= 60:
        hour_precondition += 1
        minute_precondition = minute_with_offset - 60
    else:
        minute_precondition = minute_with_offset

    if hour_precondition >= 24:
        hour_precondition -= 24

    delta = [
        {
            'distName': 'MRBTS-{mrbts_id}/NRBTS-{nrbts_id}/NRPGRP-1'.format(mrbts_id=mrbts_id,
                                                                            nrbts_id=nrbts_id),
            'operation': 'update',
            'parameters': [
                {
                    'parameterName': 'lbpsPeriodList',
                    'value': [
                        {
                            'lbpsDayOfWeek': str(get_day_of_week_from_gnb_vm()),
                            'lbpsDuration': '60',
                            'lbpsStartTimeHour': '{}'.format(hour_precondition),
                            'lbpsStartTimeMinute': '{}'.format(minute_precondition),
                            'lbpsSuspended': 'notSuspended'
                        }
                    ],
                    'operation': 'update'
                }
            ]
        }
    ]

    with AdminApi() as web_api:
        web_api.perform_delta_recommissioning(json.dumps(delta))


@logged_keyword
def update_power_saving_period_entrance(timeoffset=2):
    set_power_saving_period_entrance(timeoffset=timeoffset)


@logged_keyword
def get_info_about_cell(cell_id):
    cell_id = int(cell_id)
    cells_info = []
    with AdminApi() as web_api:
        results = web_api.get_cells_info()
        for cell in results:
            cell_info = {'cell_id': cell['globalCellId'],
                         'energySavingState': cell['energySavingState']}
            cells_info.append(cell_info)
        for cell_info in cells_info:
            if cell_info['cell_id'] == cell_id:
                return cell_info
            else:
                pass


@logged_keyword
def is_cell_saving_energy(cell_id):
    cell_spec_info = get_info_about_cell(cell_id)
    return cell_spec_info['energySavingState'] == 'energySaving'


@logged_keyword
def set_test_7_power_saving_mode_preconditions():
    feature_activate(True)
    set_cell_handover_correlated_params()
    activate_handover()
    set_cell_relation_parameters()
    set_graceful_cell_shutdown()
    set_cell_power_saving_mode_preconditions(timeoffset=2, max_load=5, min_load=1)
    wait_for_onair()


@logged_keyword
def set_test_11_power_saving_mode_preconditions():
    feature_activate(True)
    set_cell_handover_correlated_params()
    activate_handover()
    set_cell_relation_parameters()
    set_graceful_cell_shutdown()
    set_cell_power_saving_mode_preconditions()
    wait_for_onair()


@logged_keyword
def update_second_entrance_period_and_suspend_first_one():
    offset = 3
    minute_with_plus_offset = get_minute_from_gnb_vm() + offset
    minute_with_minus_offset = get_minute_from_gnb_vm() - offset
    hour_plus = get_hour_from_gnb_vm()
    hour_minus = get_hour_from_gnb_vm()

    if minute_with_plus_offset >= 60:
        hour_plus += 1
        minute_with_plus_offset -= 60

    if minute_with_minus_offset < 0:
        hour_minus -= 1
        minute_with_minus_offset += 60

    if hour_plus >= 24:
        hour_plus -= 24

    if hour_minus >= 24:
        hour_minus -= 24

    with AdminApi() as web_api:
        delta = [
            {
                'distName': 'MRBTS-{mrbts_id}/NRBTS-{nrbts_id}/NRPGRP-1'.format(mrbts_id=mrbts_id,
                                                                                nrbts_id=nrbts_id),
                'operation': 'update',
                'parameters': [
                    {
                        'parameterName': 'lbpsPeriodList',
                        'value': [
                            {
                                'lbpsDayOfWeek': str(get_day_of_week_from_gnb_vm()),
                                'lbpsDuration': '5',
                                'lbpsStartTimeHour': '{}'.format(hour_minus),
                                'lbpsStartTimeMinute': '{}'.format(minute_with_minus_offset),
                                'lbpsSuspended': 'suspended'
                            },
                            {
                                'lbpsDayOfWeek': str(get_day_of_week_from_gnb_vm()),
                                'lbpsDuration': '60',
                                'lbpsStartTimeHour': '{}'.format(hour_plus),
                                'lbpsStartTimeMinute': '{}'.format(minute_with_plus_offset),
                                'lbpsSuspended': 'notSuspended'
                            }
                        ],
                        'operation': 'update'
                    }
                ]
            }
        ]
        web_api.perform_delta_recommissioning(json.dumps(delta))


@logged_keyword
def change_suspension(suspension=True, timeoffset=3):
    minute_with_offset = get_minute_from_gnb_vm() + int(timeoffset)
    hour_precondition = get_hour_from_gnb_vm()

    if minute_with_offset >= 60:
        hour_precondition += 1
        minute_precondition = minute_with_offset - 60
    else:
        minute_precondition = minute_with_offset

    if hour_precondition >= 24:
        hour_precondition -= 24

    delta = [
        {
            'distName': 'MRBTS-{mrbts_id}/NRBTS-{nrbts_id}/NRPGRP-1'.format(mrbts_id=mrbts_id,
                                                                            nrbts_id=nrbts_id),
            'operation': 'update',
            'parameters': [
                {
                    'parameterName': 'lbpsPeriodList',
                    'value': [
                        {
                            'lbpsDayOfWeek': str(get_day_of_week_from_gnb_vm()),
                            'lbpsDuration': '30',
                            'lbpsStartTimeHour': '{}'.format(hour_precondition),
                            'lbpsStartTimeMinute': '{}'.format(minute_precondition),
                            'lbpsSuspended': 'notSuspended'
                        }
                    ],
                    'operation': 'update'
                }
            ]
        }
    ]

    if suspension:
        delta[0]['parameters'][0]['value'][0]['lbpsSuspended'] = 'suspended'

    with AdminApi() as web_api:
        web_api.perform_delta_recommissioning(json.dumps(delta))


@logged_keyword
def assert_cell_saving_energy_is_on(cell_id):
    assert is_cell_saving_energy(cell_id), "Cell with id {cell} isn't saving energy".format(cell=cell_id)


@logged_keyword
def energy_saving_test_case_teardown():
    utils_api.unlock_all_cells()
    change_suspension(suspension=True)


@logged_keyword
def change_last_cell_energy_saving_possibility(bool_value):
    delta = [
        {
            'distName': 'MRBTS-{mrbts_id}/NRBTS-{nrbts_id}/NRPGRP-1'.format(mrbts_id=mrbts_id,
                                                                            nrbts_id=nrbts_id),
            'operation': 'update',
            'parameters': [
                {
                    'parameterName': 'lbpsLastCellSOEnabled',
                    'value': bool_value,
                    'operation': 'update'
                }
            ]
        }
    ]
    with AdminApi() as web_api:
        web_api.perform_delta_recommissioning(json.dumps(delta))


@logged_keyword
def lock_cell(cell_id, lock=True):
    if lock:
        value = "Locked"
    else:
        value = "Unlocked"
    delta = [
        {
            'distName': 'MRBTS-{mrbts_id}/NRBTS-{nrbts_id}/NRCELL-{cell_id}'.format(mrbts_id=mrbts_id,
                                                                                    nrbts_id=nrbts_id,
                                                                                    cell_id=cell_id),
            'operation': 'update',
            'parameters': [
                {
                    'parameterName': 'administrativeState',
                    'value': value,
                    'operation': 'update'
                }
            ]
        }
    ]
    with AdminApi() as web_api:
        web_api.perform_delta_recommissioning(json.dumps(delta))
