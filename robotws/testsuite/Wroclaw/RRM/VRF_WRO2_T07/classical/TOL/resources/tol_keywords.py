from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.admin_api import AdminApi
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.admin_utils import AdminUtils
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log import blog
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.tl_config import tl
from random import choice
from collections import namedtuple
import time
import json
import datetime

au = AdminUtils()

RMOD = namedtuple('RMOD', ['configuration', 'internal'])
BBMOD = namedtuple('BBMOD', ['configuration', 'internal'])


def block_and_unblock_site(timeout=300):
    with AdminApi(bts_host='192.168.255.129') as web_api:
        blog("Blocking site")
        web_api.block(timeout=timeout)
        blog("Sleeping for 10s before unblocking")
        time.sleep(10)
        blog("Unblocking site")
        web_api.unblock(timeout=timeout)
    blog("Waiting for cells to get on air")
    au.wait_for_all_cells_on_air_state(cell_type='nr')


def block_and_unblock_rat(rat='NR', timeout=300):
    with AdminApi(bts_host='192.168.255.129') as web_api:
        blog(f"Blocking {rat} rat")
        web_api.block_rat(rat=rat, timeout=timeout)
        blog("Sleeping for 10s before unblocking")
        time.sleep(10)
        blog(f"Unblocking {rat} rat")
        web_api.unblock_rat(rat=rat, timeout=timeout)
    blog("Waiting for cells to get on air")
    au.wait_for_all_cells_on_air_state(cell_type='nr')


def lock_and_unlock_bbmod(bbmod, timeout=300):
    with AdminApi(bts_host='192.168.255.129') as web_api:
        blog(f"Blocking {bbmod} bbmod")
        web_api.lock(dist_name=bbmod, timeout=timeout)
        blog("Sleeping for 10s before unblocking")
        time.sleep(10)
        blog(f"Unblocking {bbmod} bbmod")
        web_api.unlock(dist_name=bbmod, timeout=timeout)
    blog("Waiting for cells to get on air")
    au.wait_for_all_cells_on_air_state(cell_type='nr')


def lock_and_unlock_rmod(rmod, timeout=300):
    with AdminApi(bts_host='192.168.255.129') as web_api:
        blog(f"Locking {rmod} radio")
        web_api.lock(dist_name=rmod, timeout=timeout)
        blog("Sleeping for 10s before unblocking")
        time.sleep(10)
        blog(f"Unlocking {rmod} radio")
        web_api.unlock(dist_name=rmod, timeout=timeout)
    blog("Waiting for cells to get on air")
    au.wait_for_all_cells_on_air_state(cell_type='nr')


def reset_rmod(rmod, timeout=300):
    with AdminApi(bts_host='192.168.255.129') as web_api:
        blog(f"Resetting {rmod}")
        web_api.reset_unit(dist_name=rmod, timeout=timeout)
    blog("Waiting for cells to get on air")
    au.wait_for_all_cells_on_air_state(cell_type='nr')


def reset_rat(rat='NR', timeout=300):
    with AdminApi(bts_host='192.168.255.129') as web_api:
        blog(f"Resetting {rat}")
        web_api.rat_reset(rat_type=rat, timeout=timeout)
    blog("Waiting for cells to get on air")
    au.wait_for_all_cells_on_air_state(cell_type=rat.lower())


def get_all_bbmods_with_name(name):
    with AdminApi(bts_host='192.168.255.129') as web_api:
        return [BBMOD(distname['id']['configuration'], distname['id']['internal'])
                for distname in web_api.get_detected_hw_info()['basebandModules']
                if name.lower() in distname['productName'].lower()]


def get_all_rmods_with_name(name):
    with AdminApi(bts_host='192.168.255.129') as web_api:
        return [RMOD(r['id']['configuration'], r['id']['internal'])
                for r in web_api.get_detected_hw_info()['radioModules']["rmod"] if r['productName'] == name]


def select_random_bbmod_distname_with_name(name):
    bbmod = choice([bbmod.configuration for bbmod in get_all_bbmods_with_name(name)])
    blog(f"Selected random BBMOD: {bbmod}")
    return bbmod


def select_random_rmod_distname_with_name(name):
    rmod = choice([rmod.configuration for rmod in get_all_rmods_with_name(name)])
    blog(f"Selected random RMOD: {rmod}")
    return rmod


def select_all_rmods_distnames_with_name(name):
    rmods = get_all_rmods_with_name(name)
    return [rmod.configuration for rmod in rmods]


def select_all_bbmods_distnames_with_name(name):
    bbmods = get_all_bbmods_with_name(name)
    return [bbmod.configuration for bbmod in bbmods]


def get_all_cells_on_rmod(rmod_distname, technology):
    mrbts_id = au.get_bts_ids()[0]

    def format_cell_distname(distname):
        return f'MRBTS-{mrbts_id}/' + '/'.join(distname.replace('_R', '').split('/')[-2:])

    cell_type = {"nr": "NR", "lte": "LN"}.get(technology.lower())
    if not cell_type:
        raise RuntimeError("Unknown technology!")

    with AdminApi() as web_api:
        return [
            format_cell_distname(distname)
            for distname in web_api.get_cell_mapping_by_module_id(rmod_distname)
            if cell_type in distname
        ]


def select_random_cell_on_rmod(rmod_name, technology):
    random_rmod = choice([rmod.internal for rmod in get_all_rmods_with_name(rmod_name)])
    random_cell_on_rmod = choice(get_all_cells_on_rmod(random_rmod, technology))
    blog(f"Selected random CELL: {random_cell_on_rmod}")
    return random_cell_on_rmod


def prepare_rmod_pdu_info_by_name(rmod_name):
    try:
        return [{
            rmod.serial_number: {
                "model": rmod.pdu_port.pdu.model,
                "host": rmod.pdu_port.pdu.addr,
                "port": rmod.pdu_port.port_no,
                "version": rmod.pdu_port.pdu.version
            }
        } for rmod in tl.gnbs[0].dus[0].rus if rmod.radio_type == rmod_name]
    except AttributeError:
        raise RuntimeError("Preparing RMOD-PDU info failed! Likely missing serial_number attribute for RMOD.")


def get_sn_for_rmods_by_name(name):
    with AdminApi() as web_api:
        return [rmod['serialNumber'] for rmod in web_api.get_parameters_for_all("RMOD") if rmod['productName'] == name]


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


def get_hour_from_gnb_vm():
    return int(datetime.datetime.now().hour)


def get_minute_from_gnb_vm():
    return int(datetime.datetime.now().minute)


def get_day_of_week_from_gnb_vm():
    day_number = int(datetime.datetime.today().weekday())
    days = {0: 'Mon', 1: 'Tue', 2: 'Wed', 3: 'Thu', 4: 'Fri', 5: 'Sat', 6: 'Sun'}
    return days[day_number]


def set_power_saving_period_entrance(cell_id, nrpgrp, timeoffset=3):
    mrbts_id, nrbts_id = au.get_bts_ids()
    minute_with_offset = get_minute_from_gnb_vm() + int(timeoffset)
    hour_precondition = get_hour_from_gnb_vm() + 2

    if minute_with_offset >= 60:
        hour_precondition += 1
        minute_precondition = minute_with_offset - 60
    else:
        minute_precondition = minute_with_offset

    if hour_precondition >= 24:
        hour_precondition -= 24

    blog(minute_precondition, hour_precondition, get_day_of_week_from_gnb_vm())
    delta = [
        {
            'distName': 'MRBTS-{mrbts_id}/NRBTS-{nrbts_id}/NRPGRP-{nrpgrp}'.format(mrbts_id=mrbts_id,
                                                                                   nrbts_id=nrbts_id, nrpgrp=nrpgrp[0]),
            'operation': 'update',
            'parameters': [
                {
                    'parameterName': 'lbpsPeriodList',
                    'value': [
                        {
                            'lbpsDayOfWeek': str(get_day_of_week_from_gnb_vm()),
                            'lbpsDuration': '10',
                            'lbpsStartTimeHour': '{}'.format(hour_precondition),
                            'lbpsStartTimeMinute': '{}'.format(minute_precondition),
                            'lbpsSuspended': 'notSuspended'
                        }
                    ],
                    'operation': 'update'
                },
                {
                    'parameterName': 'lbpsCellPeriodList',
                    'value': [
                        {
                            'lbpsCellDayOfWeek': str(get_day_of_week_from_gnb_vm()),
                            'lbpsCellDuration': '10',
                            'lbpsCellSOMethod': '{}'.format(nrpgrp[1]),
                            'lbpsCellStartTimeHour': '{}'.format(hour_precondition),
                            'lbpsCellStartTimeMinute': '{}'.format(minute_precondition),
                            'nrCellId': '{}'.format(cell_id)
                        }
                    ],
                    'operation': 'update'
                }
            ]
        }
    ]
    blog("Performing delta recommissioning with energysaving setup")
    with AdminApi() as web_api:
        web_api.perform_delta_recommissioning(json.dumps(delta))


def is_cell_saving_energy(cell_id):
    cell_spec_info = get_info_about_cell(cell_id)
    return cell_spec_info['energySavingState'] == 'energySaving'
