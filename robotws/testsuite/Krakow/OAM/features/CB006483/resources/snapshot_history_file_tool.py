import json
import os
import subprocess
from time import sleep
from robot.api import logger


def parse_single_snapshot_history_entry_to_dict(entry):
    """
    Changes raw entry directly from snapshot to dict
    :param entry: One line of properly generated Snapshot_history file
    :return: Dict based of entry
    """
    return json.loads(entry.rstrip())


def parse_snapshot_history_file(path_to_file):
    """
    Parses snapshot_history_file to list of entries
    :param path_to_file: Path to snapshot_history file
    :return: List of dictionaries (every dict is based on single entry from snapshot_history)
    """
    parsed_file = []
    with open(path_to_file, "r") as snapshot_history_file:
        for line in snapshot_history_file.readlines():
            parsed_file.append(parse_single_snapshot_history_entry_to_dict(line))
    return parsed_file


def generate_diff_between_two_snapshot_files(snapshot_file_name_earlier, snapshot_file_name_latest, dir_path="/tmp"):
    """
    Generates dict based on difference between two snapshot history files
    :param dir_path:
    :param snapshot_file_name_earlier: generated earlier and smaller that the second one
    :param snapshot_file_name_latest: generated later than the previous one
    :returns: all entries that differ between snapshot history files
    """
    diff_output_filename = "incremental_diff_output.txt"
    diff_output_path = f"{dir_path}/{diff_output_filename}"

    path_earlier_file = f"{dir_path}/{snapshot_file_name_earlier}"
    path_latest_file = f"{dir_path}/{snapshot_file_name_latest}"

    _ = subprocess.check_output(
        r"comm -12 <(sort {0}) <(sort {1}) > buffer && comm -3 buffer <(sort {1}) | sed 's/\t//' > {2}".format(
            path_earlier_file,
            path_latest_file,
            diff_output_path,
        ), shell=True, executable='/usr/bin/bash'
    )
    sleep(2)  # without sleep line below rises no diff_output_filename file TODO: change this workaround
    return parse_snapshot_history_file(diff_output_path)


def format_trigger_type_from_webem_format(trigger_type):
    snapshot_history_trigger_types = {
        'onFaultDetection': 'On fault detection',
        'onFaultCancelation': 'On fault cancelation',
        'onAlarmSend': 'On alarm send',
        'onAlarmCancellation': 'On alarm cancellation',
    }
    if trigger_type in snapshot_history_trigger_types.keys():
        return snapshot_history_trigger_types.get(trigger_type)
    else:
        return trigger_type


def is_snapshot_entry_from_fault_triggering_mechanism(snapshot_entry):
    """
    Checks if entry from snapshot_history file has been triggered by fault triggering mechanism
    :param snapshot_entry: Dict describing snapshot from snapshot history file
    """
    if (
        snapshot_entry.get("trigger_originator") == "INTERNAL" and
        snapshot_entry.get("trigger_type") == "AUTOMATIC"
    ):
        return True
    else:
        return False


def is_entry_coming_from_desired_trigger_fault_and_reason(snapshot_entry, fault_id, trigger_type):
    return is_snapshot_entry_from_fault_triggering_mechanism(snapshot_entry) and \
           snapshot_entry.get("trigger_reason") == "{} - {}".format(
                   fault_id,
                   format_trigger_type_from_webem_format(trigger_type))


def check_if_same_fault_in_15_min_has_proper_info(snapshot_history_during_test, fault_id, trigger_type):
    # should differ by only two entries
    logger.console('Snapshot history generated during test: {}'.format(snapshot_history_during_test))
    if not len(snapshot_history_during_test) == 2:
        raise Exception('During test there should be only two entries within snapshot_history, but found {}'.
                        format(len(snapshot_history_during_test)))

    # should has been triggered by fault triggering mechanism with desired fault_id and trigger_type
    if not (
        is_entry_coming_from_desired_trigger_fault_and_reason(snapshot_history_during_test[0], fault_id, trigger_type)
        and is_snapshot_entry_from_fault_triggering_mechanism(snapshot_history_during_test[1])
    ):
        raise Exception('One of checking entries does not come from fault triggering mechanism')

    # one should be successfully collected, second should failed
    if not (snapshot_history_during_test[0].get('snapshot_result') == 'success' and
            snapshot_history_during_test[1].get('snapshot_result') == 'fail'):
        raise Exception('Unexpected snapshot results! The {} snapshot_result should has "success" value '
                        'and {} snapshot_result should has "fail" value.'.format(snapshot_history_during_test[0],
                                                                                 snapshot_history_during_test[1]))

    # reason of failing is 15 minutes limitation of same trigger
    if not snapshot_history_during_test[1].get('failed_reason') == 'Less than 15 minutes since the latest trigger':
        raise Exception('The second entry failed_reason is not associated with 15 minutes limitation')

    return True
