from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.decorators import logged_keyword
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.admin_api import AdminApi
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.admin_utils import AdminUtils
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log import blog
import testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.pm_counters as pm
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.DeltaStore import DeltaStore
from taf.sbts.oam.coam.admin import admin
import shutil
import random
import re
import json


au = AdminUtils()
cell_type_mapping = {'NR': 'NRCEL', 'LTE': 'LNCEL', 'GSM': 'GNCEL'}


@logged_keyword
def power_reset_via_admin():
    api = admin()
    connection = api.connect_to()
    result = connection.power_reset()


def update_software_for_daily_activities(sw_filepath):
    with AdminApi(bts_host='192.168.255.129') as web_api:
        web_api.update_software(sw_filepath, timeout=3600)


@logged_keyword
def rollback_software_for_daily_activities():
    with AdminApi(bts_host='192.168.255.129') as web_api:
        web_api.rollback_software(timeout=3600)


@logged_keyword
def get_software_download_link(sw_version):
    base_url = "https://artifactory-espoo2.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-local/build"
    url = f"{base_url}/{sw_version.split('_')[0]}/{sw_version}/{sw_version}_release_BTSSM_downloadable_A54.zip"
    return url


def check_disk_space_is_at_least_9_gb():
    total, used, free = shutil.disk_usage('/home/ute/')
    free = float(free)/(1024 * 1024 * 1024)
    blog("Free disk space", free)
    assert free >= 9, "Not enough disk space to download software package."


def prevent_downgrade(target_software_version, current_software_version):
    def replace_multiple_string(text, replacements):
        for old, new in replacements.items():
            text = text.replace(old, new)
        return text

    def is_trunk(version):
        return version.lower().startswith('sbts00')

    if is_trunk(target_software_version) and not is_trunk(current_software_version):
        return
    else:
        replacements = {'SBTS': '', 'R': '', 'ENB': '', '_': ''}
        target_sw = replace_multiple_string(target_software_version, replacements)
        source_sw = replace_multiple_string(current_software_version, replacements)
        assert int(source_sw) < int(target_sw), "Wrong target software, downgrade is prohibited"


def filter_alarms_by_severity(alarms, severity):
    return [alarm for alarm in alarms if alarm['severity'] == severity]


def omit_alarms(alarms, ommitted_alarms):
    return [alarm for alarm in alarms if alarm['faultName'] not in ommitted_alarms]


@logged_keyword
def block_and_unblock_all_cells(rats):
    with AdminApi(bts_host='192.168.255.129') as web_api:
        for rat in rats:
            blog("Blocking cells for {}".format(rat))
            web_api.block_all_cells(rat=rat, timeout=300)
            blog("Unblocking cells for {}".format(rat))
            web_api.unblock_all_cells(rat=rat, timeout=300)


@logged_keyword
def lock_and_unlock_all_rus():
    with AdminApi(bts_host='192.168.255.129') as web_api:
        ru_paths = web_api.get_ids_for_all('RMOD')
        for path in ru_paths:
            blog("Locking RU for {}".format(path))
            web_api.lock(path, timeout=300)
            blog("Unlocking RU for {}".format(path))
            web_api.unlock(path, timeout=300)


@logged_keyword
def reset_rats(rats):
    with AdminApi(bts_host='192.168.255.129') as web_api:
        for rat in rats:
            blog("Reseting {}".format(rat))
            web_api.reset_rat(rat_type=rat, timeout=600)


@logged_keyword
def get_active_rats():
    rats = []
    with AdminApi(bts_host='192.168.255.129') as web_api:
        rat_states = web_api.get_bts_info()['ratState']
        for rat, state in rat_states.items():
            if state != 'NO_CELLS':
                rats.append(rat.upper())
    return rats


@logged_keyword
def get_cell_ids_for_each_rat(rats):
    cell_info = {}
    for rat in rats:
        cell_info[rat] = au.get_all_cell_ids(cell_type=rat.lower())
    return cell_info


@logged_keyword
def reset_bbmods():
    with AdminApi(bts_host='192.168.255.129') as web_api:
        bbmod_paths = web_api.get_ids_for_all('BBMOD')
        for path in bbmod_paths:
            blog("Resetting {}".format(path))
            web_api.reset_unit(path, reset_type='Warm', timeout=300)


@logged_keyword
def block_site():
    with AdminApi(bts_host='192.168.255.129') as web_api:
        blog("Blocking site")
        web_api.block(timeout=300)


@logged_keyword
def wait_for_onair_for_all_rats(rats):
    for rat in rats:
        blog("Waiting for cells to be in OnAir state for: {}".format(rat))
        au.wait_for_all_cells_on_air_state(cell_type=rat.lower())


@logged_keyword
def check_counters_daily_activities(counters):
    pm_counters_path = pm.collect_counters()
    failed_tests = []

    for counter in counters:
        value_dict = pm.get_relevant_pm_counters(pm_counters_path, [counter])
        if not value_dict:
            blog(f"No counter {counter} found")
            failed_tests.append(counter)

    assert not failed_tests, f"Test failed for: {failed_tests}"


@logged_keyword
def setup_counters_daily(counter_params):
    mrbts_id, nrbts_id = au.get_bts_ids()
    ds = DeltaStore()
    ds.initialise_delta_store()
    path = f"MRBTS-{mrbts_id}/NRBTS-{nrbts_id}/NRPMRNL-1"
    for param in counter_params:
        ds.add_param_to_delta(path, param, '5min')
    ds.validate_scf(skip_parameter_relation_errors=False)
    delta = ds.collect_delta_store()
    ds.perform_delta_recommissioning(delta, skip_parameter_relation_errors=False)


def lock_random_cell(cell_info):
    rats = [rat for rat in cell_info.keys()]
    random_rat = random.choice(rats)
    random_cell_id = random.choice(cell_info[random_rat])
    random_cell_type = cell_type_mapping.get(random_rat, random_rat)
    au.lock_cells(cell_list=[str(random_cell_id)], cells_type=random_cell_type)


def reset_random_bbmod():
    with AdminApi(bts_host='192.168.255.129') as web_api:
        bbmod_paths = web_api.get_ids_for_all('BBMOD')
        random_path = random.choice(bbmod_paths)
        blog(f"Resetting random bbmod - {random_path}")
        web_api.reset_unit(random_path, reset_type='Warm', timeout=300)


def reset_random_ru():
    with AdminApi(bts_host='192.168.255.129') as web_api:
        ru_paths = web_api.get_ids_for_all('RMOD')
        random_path = random.choice(ru_paths)
        blog(f"Resetting random ru - {random_path}")
        web_api.reset_unit(random_path, reset_type='Warm', timeout=300)


def lock_random_ru():
    with AdminApi(bts_host='192.168.255.129') as web_api:
        ru_paths = web_api.get_ids_for_all('RMOD')
        random_path = random.choice(ru_paths)
        blog(f"Locking RU for {random_path}")
        web_api.lock(random_path, timeout=300)


def unlock_all_rus():
    with AdminApi(bts_host='192.168.255.129') as web_api:
        ru_paths = web_api.get_ids_for_all('RMOD')
        for path in ru_paths:
            blog(f"Unlocking RU for {path}")
            web_api.unlock(path, timeout=300)


def lock_random_bbmod():
    with AdminApi(bts_host='192.168.255.129') as web_api:
        bbmod_paths = web_api.get_ids_for_all('BBMOD')
        random_path = random.choice(bbmod_paths)
        blog(f"Locking BBMOD for {random_path}")
        web_api.lock(random_path, timeout=300)


def unlock_all_bbmods():
    with AdminApi(bts_host='192.168.255.129') as web_api:
        bbmod_paths = web_api.get_ids_for_all('BBMOD')
        for path in bbmod_paths:
            blog(f"Unlocking BBMOD for {path}")
            web_api.unlock(path, timeout=300)


def unlock_all_cells(cell_info):
    rats = [rat for rat in cell_info.keys()]
    cell_types = map(lambda s: cell_type_mapping.get(s, s), rats)
    for cell_type in cell_types:
        au.unlock_all_cells(cell_type)


def shuffle_activities(cell_info):
    rats = [rat for rat in cell_info.keys()]
    activities = [lock_random_cell, lock_random_ru, lock_random_bbmod, reset_random_bbmod, reset_random_ru]
    random.shuffle(activities)
    for activity in activities:
        if activity.__name__ == 'lock_random_cell':
            activity(cell_info)
        else:
            activity()
    unlock_all_rus()
    unlock_all_bbmods()
    unlock_all_cells(cell_info)
    for rat in rats:
        au.wait_for_all_cells_on_air_state(cell_type=rat.lower())


def check_for_filtered_prints(prints, whitelist_file, output_file):
    filtered_prints = []
    with open(whitelist_file, 'r') as file:
        whitelist_data = json.load(file)
    whitelist = whitelist_data['whitelist']
    for line in prints.split('\n'):
        is_whitelisted = any(re.match(regex, line) for regex in whitelist)
        if not is_whitelisted and line.strip():  # Ensure line is not empty
            filtered_prints.append(line)
    if filtered_prints:
        blog('Most likely valid prints for syslog cleanup found! Creating a file...')
        with open(output_file, 'w') as file:
            for message in filtered_prints:
                file.write(message + '\n')
    return filtered_prints
