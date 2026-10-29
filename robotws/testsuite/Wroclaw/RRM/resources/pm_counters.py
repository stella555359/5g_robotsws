import testsuite.Wroclaw.RRM.resources.rrm_fixture as fixture
from testsuite.Wroclaw.RRM.resources.pcap_verification.param_tree_helper import TreeWalker
from datetime import datetime
from time import sleep


counters_report = None


@fixture.logged_keyword
def get_latest_counter_value(counter_id):
    with fixture.webUI.WebUIOperations() as webUI:
        if webUI.oam_type == 'megazone_client':
            val = _get_last_counter_value_from_megazone(counter_id)
        else:
            val = _get_last_counter_value_from_coam(counter_id)
    return val


@fixture.logged_keyword
def get_sum_of_counter_values(counter_id, reload_counters=True):
    with fixture.webUI.WebUIOperations() as webUI:
        if webUI.oam_type == 'megazone_client':
            val = _get_sum_of_counter_values_from_megazone(counter_id)
        else:
            val = _get_sum_of_counter_values_from_coam(counter_id, reload_counters)
    return val


@fixture.logged_keyword
def _get_last_counter_value_from_megazone(counter_number):
    most_recent_value = []
    cells = []
    cell_idx = 1
    with fixture.webUI.WebUIOperations() as webUI:
        pm_file = webUI.get_pm_file_content(webUI.get_pm_files_list()[-1])
    for line in pm_file.split('\n'):
        if counter_number in line:
            most_recent_value.append(line.strip().replace('<{}>'.format(counter_number), '').replace(
                '</{}>'.format(counter_number), ''))
            cells.append('NRCELL-{}'.format(cell_idx))
            cell_idx += 1
    assert most_recent_value, counter_number + " not found"
    if len(most_recent_value) == 1:
        return most_recent_value[0]
    else:
        return most_recent_value, cells


@fixture.logged_keyword
def _get_sum_of_counter_values_from_megazone(counter_id):
    count = 0
    with fixture.webUI.WebUIOperations() as webUI:
        for pm_file in webUI.get_pm_files_list():
            file_content = webUI.get_pm_file_content(pm_file)
            for line in file_content.split('\n'):
                if counter_id in line:
                    count += int(line.strip().replace('<{}>'.format(counter_id), '').replace(
                        '</{}>'.format(counter_id), ''))
    return count


@fixture.logged_keyword
def _get_last_counter_value_from_coam(counter_id):
    most_recent_value = []
    with fixture.webUI.WebUIOperations() as webUI:
        result = webUI.get_counters_info(dist_name="all")
        tw = TreeWalker(result)
        tw.find_all(counter_id)
        counters = tw.get_found_elements()
        assert bool(counters), counter_id + " not found"
        for counter in counters:
            most_recent_value.append(counter[[str(y) for y in sorted([int(x) for x in counter.keys()])][-1]])
    if len(most_recent_value) == 1:
        return most_recent_value[0]
    else:
        return most_recent_value, tw.search_result


@fixture.logged_keyword
def _get_sum_of_counter_values_from_coam(counter_id, reload_counters):
    sum_val = []
    result = _get_pm_counter_report(reload_counters=reload_counters)
    tw = TreeWalker(result)
    tw.find_all(counter_id)
    counters = tw.get_found_elements()
    assert bool(counters), counter_id + " not found"
    for counter in counters:
        sum_val.append(sum(counter.values()))
    if len(sum_val) == 1:
        return sum_val[0]
    else:
        return sum_val, tw.search_result


def _get_pm_counter_report(reload_counters):
    global counters_report
    if reload_counters or counters_report is None:
        with fixture.webUI.WebUIOperations() as webUI:
            counters_report = webUI.get_counters_info(dist_name="all")
    return counters_report


def sync_to_reporting_interval(offset_s=40, interval_m=5):
    interval_s = int(interval_m) * 60
    now = datetime.now()
    sleep((interval_s + int(offset_s) - now.minute * 60 - now.second) % interval_s)
