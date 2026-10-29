"""
Module for filtering and checking alarms.
It adds functionality to the robot keywords in alarm_handling.robot.
"""
from typing import List, Dict, Tuple
from datetime import datetime, timezone, timedelta
import logging
import re


logger = logging.getLogger(__name__)
logger.addHandler(logging.NullHandler())


def _parse_exclude_list(raw: str) -> List[Tuple[str, str]]:
    return [tuple(entry.split(":", 1)) for entry in raw.split() if ":" in entry]


def filter_alarms(
    alarm_list: List[Dict],
    exclude_raw: str,
    log: bool,
    label: str
) -> List[Dict]:
    """
    Removes all alarms from the list that match any of the given key:value filters.

    :param alarm_list: List of alarm dicts
    :param exclude_raw: Space-separated filter string in format key:value, e.g. "alarmId:4711 faultId:123"
    :param log: Whether to log excluded alarms
    :param label: Label to include in logs
    :return: Filtered list of alarms
    """
    exclude = _parse_exclude_list(exclude_raw)

    result = []
    for alarm in alarm_list:
        if any(str(alarm.get(key)) == value for key, value in exclude):
            if log:
                logger.info(f"{label} excluded: alarmId:{alarm.get('alarmId')} , faultId:{alarm.get('faultId')}")
            continue
        result.append(alarm)
    return result


def check_for_new_alarms(
    alarm_list_1: List[Dict],
    alarm_list_2: List[Dict],
    exclude_cleared_alarms: str = "",
    exclude_active_alarms: str = "",
    console_log: bool = False
) -> Tuple[List[Dict], List[Dict]]:
    """
    Compares 2 alarm lists and returns:
    - Cleared Alarms: alarms in list 1 active but cleared in list 2
    - Active Alarms: alarms not in list 1 but newly active in list 2

    Optional: space separated list of filters for alarms to be ignored.
    Format of each filter is <Key>:<Value>, e.g. alarmId:4711.
    If console_log is true, some output info will be added to the log.

    :param alarm_list_1: First list for checking for cleared alarms
    :param alarm_list_2: Second list for checking for new alarms
    :param exclude_cleared_alarms: filters for cleared alarms
    :param exclude_active_alarms: filters for active alarms
    :param console_log: Flag to activate output to console
    :return: Tuple of (cleared_alarms, active_alarms)
    """
    # Filter alarms only in list 2, could be cleared or new
    filtered_alarms = [a for a in alarm_list_2 if a not in alarm_list_1]

    cleared_alarms = []
    active_alarms = []

    # Separate cleared and new alarms into dedicated lists
    for alarm in filtered_alarms:
        if alarm.get('clearedTime') is not None:
            cleared_alarms.append(alarm)
        else:
            active_alarms.append(alarm)

    # Apply exclusions using the public filter function
    cleared_alarms = filter_alarms(cleared_alarms, exclude_cleared_alarms, console_log, "Cleared alarm")
    active_alarms = filter_alarms(active_alarms, exclude_active_alarms, console_log, "Active alarm")

    # Log remaining alarms, if enabled
    if console_log:
        for alarm in active_alarms:
            logger.warning(
                f"ACTIVE ALARM: {alarm.get('btsObservationTime')} "
                f"faultId:{alarm.get('faultId')} {alarm.get('faultName')}"
            )
        for alarm in cleared_alarms:
            logger.warning(
                f"CLEARED ALARM: {alarm.get('btsObservationTime')} "
                f"faultId:{alarm.get('faultId')} {alarm.get('faultName')} "
                f"cleared:{alarm.get('clearedTime')}"
            )

    return cleared_alarms, active_alarms


def _parse_timezone_offset(tz_str: str) -> timezone:
    """
    Converts a string like 'GMT+02:00' to a timezone object.
    Raises ValueError if format is invalid.
    """
    match = re.match(r"^GMT([+-])(\d{2}):(\d{2})$", tz_str)
    if not match:
        raise ValueError(f"Invalid timezone format: '{tz_str}' (expected 'GMT±HH:MM')")

    sign, hours, minutes = match.groups()
    offset_minutes = int(hours) * 60 + int(minutes)
    if sign == "-":
        offset_minutes = -offset_minutes
    return timezone(timedelta(minutes=offset_minutes))


def _filter_by_observation_time(
    alarms: List[Dict],
    timestamp_ms: float,
    comparator: str,  # "before" or "after"
    log: bool = False,
) -> List[Dict]:
    """
    Filters alarm dictionaries by comparing their btsObservationTime (in local timezone from btsObservationTimezone)
    to a UTC timestamp in milliseconds. It returns all alarms either with btsObservationTime `before`(older)
    or `after` (newer) than the given timestamp.

    The function raises ValueError if time formats are invalid or not consistent between btsObservationTime and
    btsObservationTimezone!

    :param alarms: List of dicts with keys 'btsObservationTime' and 'btsObservationTimezone'
    :param timestamp_ms: Host-local timestamp in milliseconds (UTC converted internally)
    :param comparator: 'before' or 'after'
    :param log: Whether to log excluded alarms
    :return: Filtered list of alarms
    """
    if comparator not in ("before", "after"):
        raise ValueError("Comparator must be 'before' or 'after'")

    # Convert host-local timestamp_ms to UTC datetime
    local_dt = datetime.fromtimestamp(timestamp_ms)
    utc_reference = local_dt.astimezone(timezone.utc)
    ref_ts_ms_utc = utc_reference.timestamp()

    kept_count = 0
    removed_count = 0
    filtered = []

    for alarm in alarms:
        obs_str = alarm.get("btsObservationTime")
        tz_str = alarm.get("btsObservationTimezone", "GMT+00:00")

        if not obs_str:
            raise ValueError(f"Missing 'btsObservationTime' in alarm: {alarm}")
        if not tz_str:
            raise ValueError(f"Missing 'btsObservationTimezone' in alarm: {alarm}")

        # Remove trailing +0000 etc., since we rely only on the timezone field
        obs_str_cleaned = re.sub(r'[+-]\d{4}$', '', obs_str)

        try:
            # Parse timezone
            tz = _parse_timezone_offset(tz_str)

            # Parse observation time (strict format)
            obs_naive = datetime.strptime(obs_str_cleaned, "%Y%m%d%H%M%S.%f")

            # Localize and convert to UTC
            obs_local = obs_naive.replace(tzinfo=tz)
            obs_utc = obs_local.astimezone(timezone.utc)
            obs_ts_ms = obs_utc.timestamp()
        except ValueError as e:
            raise ValueError(f"Invalid observation time or timezone in alarm: {alarm} → {str(e)}") from e

        # Decision: keep or remove?
        should_keep = (
         (comparator == "before" and obs_ts_ms <= ref_ts_ms_utc) or
         (comparator == "after" and obs_ts_ms >= ref_ts_ms_utc)
        )

        if should_keep:
            filtered.append(alarm)
            kept_count += 1
        else:
            removed_count += 1

        if log:
            action = "kept" if should_keep else "removed"
            logger.debug(
                f"alarm {action}: alarmId:{alarm.get('alarmId')}/faultId:{alarm.get('faultId')} "
                f"faultName:{alarm.get('faultName')}\n"
                f"(btsObservationTime: {datetime.utcfromtimestamp(obs_ts_ms).strftime('%Y-%m-%d %H:%M:%S')} "
                f"referenceTime: {datetime.utcfromtimestamp(ref_ts_ms_utc).strftime('%Y-%m-%d %H:%M:%S')})"
            )

    logger.info(f"Total alarms kept: {kept_count}, removed: {removed_count}")

    return filtered


def get_alarms_before(
    timestamp_ms: float,
    alarms: List[Dict],
    log: bool = False,
) -> List[Dict]:
    """
    Compares all alarms by their btsObservationTime (in local timezone from btsObservationTimezone)
    to a reference UTC timestamp in milliseconds. It removes all alarms newer than the given timestamp
    and returns only those alarms older than the given reference time.
    This filetering can be applied to active, historical or combined alarms lists (list of alarm dicts).
    This should support the detailled alarm analysis for a whole test suite or specific periods, e,g. where your
    test scenario was executed.

    The function raises ValueError if time formats are invalid or not consistent between btsObservationTime and
    btsObservationTimezone!

    :param timestamp_ms: Host-local timestamp in milliseconds (UTC converted internally)
    :param alarms: List of dicts with keys 'btsObservationTime' and 'btsObservationTimezone'
    :param log: Whether to log the action for each alarms
    :return: Filtered list of alarms
    """
    return _filter_by_observation_time(alarms, timestamp_ms, "before", log)


def get_alarms_after(
    timestamp_ms: float,
    alarms: List[Dict],
    log: bool = False,
) -> List[Dict]:
    """
    Compares all alarms by their btsObservationTime (in local timezone from btsObservationTimezone)
    to a reference UTC timestamp in milliseconds. It removes all alarms older than the given timestamp
    and returns only those alarms newer than the given reference time.
    This filetering can be applied to active, historical or combined alarms lists (list of alarm dicts).
    This should support the detailled alarm analysis for a whole test suite or specific periods, e,g. where your
    test scenario was executed.

    The function raises ValueError if time formats are invalid or not consistent between btsObservationTime and
    btsObservationTimezone!

    :param timestamp_ms: Host-local timestamp in milliseconds (UTC converted internally)
    :param alarms: List of dicts with keys 'btsObservationTime' and 'btsObservationTimezone'
    :param log: Whether to log the action for each alarms
    :return: Filtered list of alarms
    """
    return _filter_by_observation_time(alarms, timestamp_ms, "after", log)


def get_current_timestamp_ms() -> float:
    """
    Returns the current UTC time as a Unix timestamp in milliseconds. This keyword can be used to get proper
    `timestamp_ms` argument for keywords `get_alarms_before` and `get_alarms_after`.
    """
    return datetime.utcnow().timestamp()


def get_fault_or_alarm_ids(alarm_list: list[dict], key_name: str = 'faultId', remove_duplicates: bool = True) -> str:
    """
    Iterates over a list of dictionaries and returns a string with the specified key and its corresponding value.

    Args:
        alarm_list (list[dict]): A list of dictionaries containing alarm information.
        key_name (str): The name of the key to extract. Defaults to 'faultId'.
        remove_duplicates (bool): Whether to remove duplicates from the result string. Defaults to True.

    Returns:
        str: A string containing a sequence of keys and their corresponding value.
    """
    try:
        if remove_duplicates:
            fault_ids = set(f"{key_name}:{alarm[key_name]}" for alarm in alarm_list if key_name in alarm)
        else:
            fault_ids = [f"{key_name}:{alarm[key_name]}" for alarm in alarm_list if key_name in alarm]
        result = ' '.join(fault_ids)
        logger.info("Successfully extracted fault IDs.")
        return result
    except Exception as e:
        logger.error(f"An error occurred: {e}")
        return ""


def is_alarm_active(
    alarm_list: List[Dict],
    filter_raw: str,
    log: bool = False
) -> bool:
    """
    Checks if any alarm matching the given key:value filters is currently active (not cleared).

    An alarm is considered active if it has no 'clearedTime' set.

    :param alarm_list: List of alarm dicts
    :param filter_raw: Space-separated filter string in format key:value, e.g. "alarmId:4711 faultId:123"
    :param log: Whether to log matching active alarms
    :return: True if at least one matching alarm is active, False otherwise
    """
    matching_active = get_matching_active_alarms(alarm_list, filter_raw, log)
    return len(matching_active) > 0


def get_matching_active_alarms(
    alarm_list: List[Dict],
    filter_raw: str,
    log: bool = False,
    label: str = "Active alarm"
) -> List[Dict]:
    """
    Returns all active alarms that match any of the given key:value filters.

    An alarm is considered active if it has no 'clearedTime' set.
    This function uses the same filter interface as `filter_alarms` for consistency.

    :param alarm_list: List of alarm dicts
    :param filter_raw: Space-separated filter string in format key:value, e.g. "alarmId:4711 faultId:123"
    :param log: Whether to log matching active alarms
    :param label: Label to include in logs
    :return: List of active alarms matching the filter criteria
    """
    filters = _parse_exclude_list(filter_raw)

    if not filters:
        logger.warning("No valid filters provided. Returning empty list.")
        return []

    result = []
    for alarm in alarm_list:
        # Check if alarm is active (no clearedTime)
        if alarm.get('clearedTime') is not None:
            continue

        # Check if alarm matches any of the filter criteria
        if any(str(alarm.get(key)).lower() == value.lower() for key, value in filters):
            if log:
                logger.info(
                    "%s matched: alarmId:%s, faultId:%s, faultName:%s",
                    label,
                    alarm.get('alarmId'),
                    alarm.get('faultId'),
                    alarm.get('faultName')
                )
            result.append(alarm)

    if log:
        logger.info(f"Total matching active alarms: {len(result)}")

    return result


def count_active_alarms(
    alarm_list: List[Dict],
    filter_raw: str = "",
    log: bool = False
) -> int:
    """
    Counts the number of active alarms, optionally filtered by the given criteria.

    If no filter is provided, counts all active alarms in the list.

    :param alarm_list: List of alarm dicts
    :param filter_raw: Optional space-separated filter string in format key:value
    :param log: Whether to log the count
    :return: Number of matching active alarms
    """
    if filter_raw:
        active_alarms = get_matching_active_alarms(alarm_list, filter_raw, log=False)
    else:
        active_alarms = [a for a in alarm_list if a.get('clearedTime') is None]

    count = len(active_alarms)

    if log:
        filter_info = f" matching '{filter_raw}'" if filter_raw else ""
        logger.info(f"Active alarms{filter_info}: {count}")

    return count
