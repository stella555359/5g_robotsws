import os.path

from taf.analyzer.ims2 import Ims2ChangesetLogEntry, Ims2LogReader, Ims2ResetLogEntry
import re
import datetime
import pytz
import json
from taf.ul.oam_kpi_calculations.parsers.ims.patterns import DistNamePatterns
from scenario_iterator import ScenarioIterator, ScenarioList


def _get_log_entry(ims_file_path):
    if not isinstance(ims_file_path, (list, tuple)):
        ims_file_path = [ims_file_path]
    for file_path in ims_file_path:
        for log_entry in Ims2LogReader.from_file(file_path=file_path):
            yield log_entry


def analyse_ims2_log(ims2_file_path, distname, start_point_timestamp=None, end_point_timestamp=None):
    rs = []
    if start_point_timestamp is None:
        start_point_timestamp = datetime.datetime.min.replace(tzinfo=pytz.utc)
    if end_point_timestamp is None:
        end_point_timestamp = datetime.datetime.max.replace(tzinfo=pytz.utc)
    for log_entry in _get_log_entry(ims2_file_path):
        if isinstance(log_entry, Ims2ChangesetLogEntry):
            if log_entry.timestamp >= start_point_timestamp and log_entry.timestamp <= end_point_timestamp:
                for dist_name, value in log_entry.updates.items():
                    if re.search(distname,
                                 dist_name):
                        rs.append(
                            {
                                "timestamp": log_entry.timestamp.isoformat(),
                                "distName": dist_name,
                                "value": value
                            }
                        )
    return rs


def _save_2_json_file(data, file_path):
    with open(file_path, "w") as f:
        json.dump(data, f, indent=4)


def get_nrcels_infos(ims_file_path, start_point_timestamp=None, end_point_timestamp=None):
    return analyse_ims2_log(ims_file_path, DistNamePatterns.NR_CELL_INFO, start_point_timestamp, end_point_timestamp)


def get_bbmod_infos(ims_file_path, start_point_timestamp=None, end_point_timestamp=None):
    return analyse_ims2_log(ims_file_path, DistNamePatterns.BBMOD_INFO, start_point_timestamp, end_point_timestamp)


def get_rmod_infos(ims_file_path, start_point_timestamp=None, end_point_timestamp=None):
    return analyse_ims2_log(ims_file_path, DistNamePatterns.RMOD_INFO, start_point_timestamp, end_point_timestamp)


def get_alarm_infos(ims_file_path, start_point_timestamp=None, end_point_timestamp=None):
    return analyse_ims2_log(ims_file_path, DistNamePatterns.ALARM, start_point_timestamp, end_point_timestamp)


def save_nrcells_infos(ims_file_path, start_point_timestamp=None, end_point_timestamp=None):
    if not isinstance(ims_file_path, (list, tuple)):
        ims_file_path = [ims_file_path]
    file_path = os.path.join(os.path.dirname(ims_file_path[0]), 'nrcells_infos.json')
    data = get_nrcels_infos(ims_file_path, start_point_timestamp, end_point_timestamp)
    _save_2_json_file(data, file_path)
    return file_path


def save_bbmod_infos(ims_file_path, start_point_timestamp=None, end_point_timestamp=None):
    if not isinstance(ims_file_path, (list, tuple)):
        ims_file_path = [ims_file_path]
    file_path = os.path.join(os.path.dirname(ims_file_path[0]), 'bbmod_infos.json')
    data = get_bbmod_infos(ims_file_path, start_point_timestamp, end_point_timestamp)
    _save_2_json_file(data, file_path)
    return file_path


def save_rmod_infos(ims_file_path, start_point_timestamp=None, end_point_timestamp=None):
    if not isinstance(ims_file_path, (list, tuple)):
        ims_file_path = [ims_file_path]
    file_path = os.path.join(os.path.dirname(ims_file_path[0]), 'rmod_infos.json')
    data = get_rmod_infos(ims_file_path, start_point_timestamp, end_point_timestamp)
    _save_2_json_file(data, file_path)
    return file_path


def save_alarm_infos(ims_file_path, start_point_timestamp=None, end_point_timestamp=None):
    if not isinstance(ims_file_path, (list, tuple)):
        ims_file_path = [ims_file_path]
    file_path = os.path.join(os.path.dirname(ims_file_path[0]), 'alarm_infos.json')
    data = get_alarm_infos(ims_file_path, start_point_timestamp, end_point_timestamp)
    _save_2_json_file(data, file_path)
    return file_path


def _extract_pattern_list(data, pattern, start_point_timestamp, end_point_timestamp):
    rs = []
    for d in data:
        if re.search(pattern, d["distName"]):
            d["value"]["timestamp"] = d["timestamp"]
            d["value"]["distName"] = d["distName"]
            timestamp = datetime.datetime.fromisoformat(d["timestamp"])
            if timestamp >= start_point_timestamp and timestamp <= end_point_timestamp:
                rs.append(d["value"])
    return rs


def check_scenario(json_file_path, expected_scenario, patterns, start_point_timestamp=None,
                   end_point_timestamp=None, delay=60):
    if not patterns:
        raise ValueError("Pattern is required.")
    if not os.path.exists(json_file_path):
        raise ValueError("File not found.")
    if not expected_scenario:
        raise ValueError("Expected scenario is required.")
    if not isinstance(patterns, (list, tuple)):
        patterns = [patterns]
    if start_point_timestamp is None:
        start_point_timestamp = datetime.datetime.min.replace(tzinfo=pytz.utc)
    else:
        start_point_timestamp = datetime.datetime.fromisoformat(start_point_timestamp)
        # start_point_timestamp -= datetime.timedelta(seconds=delay)
    if end_point_timestamp is None:
        end_point_timestamp = datetime.datetime.max.replace(tzinfo=pytz.utc)
    else:
        end_point_timestamp = datetime.datetime.fromisoformat(end_point_timestamp)
    with open(json_file_path, "r") as f:
        data = json.load(f)
    results = []
    for i, pattern in enumerate(patterns):
        scenario_list = _extract_pattern_list(data, pattern, start_point_timestamp, end_point_timestamp)
        if not scenario_list:
            results.append({"id": i, "passed": False, "error": "No data found."})
            continue
        scenario_iterator = ScenarioIterator(expected_scenario)
        try:
            passed = scenario_iterator.check_scenario(scenario_list)
            error = None
        except ValueError as e:
            passed = False
            error = str(e)
        results.append({"id": i, "passed": passed, "error": error})
    return results


def check_nrcell_scenario(json_file_path, cell_ids, expected_scenario_name, start_point_timestamp=None,
                          end_point_timestamp=None, delay=60):
    if not isinstance(cell_ids, (list, tuple)):
        cell_ids = [cell_ids]
    expected_scenario = getattr(ScenarioList, expected_scenario_name, None)
    if not expected_scenario:
        raise ValueError(f"Expected scenario {expected_scenario_name} is not defined.")
    _pattern = DistNamePatterns.NR_CELL_INFO[:-4]
    patterns = []
    for cell_id in cell_ids:
        pattern = r"{pattern}{cell_id}$".format(pattern=_pattern, cell_id=cell_id)
        patterns.append(pattern)
    results = check_scenario(json_file_path, expected_scenario, patterns,
                             start_point_timestamp, end_point_timestamp, delay)
    rs = []
    final_reult = True
    for result in results:
        rs.append({
            "cell_id": cell_ids[result["id"]],
            "passed": result["passed"],
            "error": result["error"]
        })
        if not result["passed"]:
            final_reult = False
    return final_reult, rs


def check_raized_alarm(json_file_path, expected_alarms=[], alarm_to_ignor=[], start_point_timestamp=None,
                       end_point_timestamp=None, delay=60):
    if not json_file_path:
        raise ValueError("File path is required.")
    with open(json_file_path, "r") as f:
        data = json.load(f)
        # Iterate through the alarms and check their timestamps
    if start_point_timestamp is None:
        start_point_timestamp = datetime.datetime.min.replace(tzinfo=pytz.utc)
    else:
        start_point_timestamp = datetime.datetime.fromisoformat(start_point_timestamp)
        start_point_timestamp -= datetime.timedelta(seconds=delay)
    if end_point_timestamp is None:
        end_point_timestamp = datetime.datetime.max.replace(tzinfo=pytz.utc)
    else:
        end_point_timestamp = datetime.datetime.fromisoformat(end_point_timestamp)

    new_alarms = []
    for alarm in data:
        alarm_time = datetime.datetime.fromisoformat(alarm["timestamp"])
        if alarm_time >= start_point_timestamp and alarm_time <= end_point_timestamp:
            new_alarms.append(alarm)
    not_expected_alarm = []
    for alarm in new_alarms:
        faultId = alarm["value"]["faultId"]
        if faultId in expected_alarms and faultId not in alarm_to_ignor:
            not_expected_alarm.append(alarm)
    passed = not not_expected_alarm
    return passed, not_expected_alarm
