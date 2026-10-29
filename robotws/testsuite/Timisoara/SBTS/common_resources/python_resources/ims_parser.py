from datetime import datetime
import regex
from taf.analyzer.ims2 import Ims2ChangesetLogEntry, Ims2LogReader

"""
File to keep IMS parser functions.
"""


class EventNotFound(Exception):
    def __init__(self, message):
        self.message = message

    def __str__(self):
        return self.message


def get_ims_events(ims_path, dist_name_pattern, status=None):
    """
    Keyword to return list of events for distname and status from IMS file.
    Parameters:
        ims_path = path to IMS file
        dist_name_pattern = regex pattern for object distname
        status = dictionary with parameter name=value, e.g: {'s1LinkStatus': 'unavailable'}
    Return:
        list of dictionaries
            each dictionary has:
             timestamp = time data when event occurred - datetime object
             dist_name = object dist_name - str
             value = IMS object parameters - dictionary
    """
    events = []
    for log_entry in Ims2LogReader.from_file(file_path=ims_path):
        if isinstance(log_entry, Ims2ChangesetLogEntry):
            for dist_name, value in log_entry.updates.items():
                if regex.match(dist_name_pattern, dist_name):
                    if status is None or event_has_required_status(value, status):
                        event = {'timestamp': log_entry.timestamp.replace(tzinfo=None),
                                 'dist_name': dist_name,
                                 'value': value
                                 }
                        events.append(event)
    if len(events) == 0:
        raise EventNotFound("Change event {} with status {} was not found in IMS.".
                            format(dist_name_pattern, status))
    return events


def event_has_required_status(event_status, required_status):
    """
    This keyword checks if event status is as expected.
    Parameters:
        event_status = dictionary with event parameters
        required_status = dictionary with expected values for specific parameters
    Return:
        True if event has specific parameters with expected values
        False otherwise
    """
    for item in required_status.items():
        if item in event_status.items():
            return True
    return False


def get_first_timestamp(ims_path, dist_name_pattern, status=None, search_after=None):
    """
    This keyword returns first timestamp of specific event.
    Parameters:
        ims_path = path to IMS file
        dist_name_pattern = regex pattern for object distname
        status = dictionary with parameter name=value, e.g: {'s1LinkStatus': 'unavailable'}
        search_after = timestamp to search after
    Return:
        timestamp value
    """
    if search_after is None:
        events = get_ims_events(ims_path, dist_name_pattern, status)
    else:
        events = (event for event in get_ims_events(ims_path, dist_name_pattern, status)
                  if event['timestamp'] > search_after)
    events_sorted = sorted(events, key=lambda x: x['timestamp'])
    return events_sorted[0]['timestamp']


def _convert_to_epoch(timestamp):
    if timestamp in (None, ''):
        return None
    if isinstance(timestamp, (int, float)):
        return float(timestamp)
    if isinstance(timestamp, datetime):
        return timestamp.timestamp()
    if isinstance(timestamp, str):
        try:
            return datetime.fromisoformat(timestamp).timestamp()
        except ValueError:
            for fmt in ("%Y-%m-%d %H:%M:%S", "%Y%m%d %H:%M:%S", "%Y/%m/%d %H:%M:%S"):
                try:
                    return datetime.strptime(timestamp, fmt).timestamp()
                except ValueError:
                    continue
    raise ValueError(f"Unsupported timestamp format: {timestamp}")


def get_fault_occurrences(ims_path, fault_id, begin=None, end=None):
    """
    Return every IMS alarm entry that matches the given fault id.

    Parameters:
        ims_path - path to IMS file
        fault_id - fault identifier to be matched (string or integer)
        begin    - optional lower bound timestamp (datetime/int/float/string)
        end      - optional upper bound timestamp (datetime/int/float/string)

    Returns:
        list with the raw alarm payloads that matched (value dicts from IMS trace)
    """
    begin_epoch = _convert_to_epoch(begin)
    end_epoch = _convert_to_epoch(end)
    occurrences = []

    for log_entry in Ims2LogReader.from_file(file_path=ims_path):
        if not isinstance(log_entry, Ims2ChangesetLogEntry):
            continue

        entry_epoch = log_entry.timestamp.timestamp()
        if begin_epoch and entry_epoch < begin_epoch:
            continue
        if end_epoch and entry_epoch > end_epoch:
            continue

        for dist_name, value in log_entry.updates.items():
            if "ALARM-" not in dist_name:
                continue
            if str(value.get('faultId')) != str(fault_id):
                continue
            occurrences.append(value)

    return occurrences
