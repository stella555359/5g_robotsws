import ast
import datetime


def datetime_to_seconds_local(dt_str: str, fmt: str = "%Y-%m-%d %H:%M:%S") -> int:
    """Convert a datetime string (local time, e.g. UTC+8) to seconds since Unix epoch in local time."""
    dt = datetime.datetime.strptime(dt_str, fmt)
    seconds = int(dt.timestamp())
    return seconds


def load_pm_info_as_dict(data: str):
    pm_info = ast.literal_eval(data)
    return pm_info


def sum_counts_in_time_range(
    pm_info: dict,
    nrcell: str,
    nrpmqap: str,
    counterids,
    time_start: int,
    time_end: int
) -> dict:
    """
    Supports `counterids` as a list or string, calculates the sum of counts for each `counterid` within the specified
    time range, and returns a dictionary in the format {counterid: sum}.
    :param pm_info: The parsed `pm_info` dictionary
    :param nrcell: NRCELL-XX
    :param nrpmqap: NRPMQAP-X
    :param counterids: M55159C000XX or a list
    :param time_start: Start time (in seconds, int)
    :param time_end: End time (in seconds, int)
    :return: {counterid: sum}
    """
    try:
        if isinstance(counterids, str):
            counterids = [counterids]
        value = pm_info['BTS']
        result = {cid: 0 for cid in counterids}
        for mrbts in value:
            for nrbts in value[mrbts]:
                nrcell_dict = value[mrbts][nrbts]
                if nrcell in nrcell_dict:
                    nrpmqap_dict = nrcell_dict[nrcell]
                    if nrpmqap in nrpmqap_dict:
                        pdltq_dict = nrpmqap_dict[nrpmqap]
                        for pdltq in pdltq_dict:
                            counter_dict = pdltq_dict[pdltq]
                            for counterid in counterids:
                                if counterid in counter_dict:
                                    time_counts = counter_dict[counterid]
                                    result[counterid] += sum(
                                        v for t, v in time_counts.items()
                                        if time_start <= int(t) <= time_end
                                    )
        return result
    except Exception as e:
        print(f"Error: {e}")
        return {cid: 0 for cid in counterids}


def get_local_timestamp():
    """Get the current UTC+8 timestamp (in seconds)."""
    now_local = datetime.datetime.now()
    timestamp = int(now_local.timestamp())
    return timestamp


def get_nearest_5min_timestamps_up(ts: int = None) -> int:
    """
    Given a timestamp, round up to the nearest 5-minute (300 seconds) multiple. If no input is provided, use the
    current UTC+8 timestamp. Returns the rounded-up timestamp.
    """
    if ts is None:
        ts = get_local_timestamp()
    down = ts - (ts % 300)
    up = down if ts % 300 == 0 else down + 300
    return up


def get_nearest_5min_timestamps_down(ts: int = None) -> int:
    """
    Given a timestamp, round down to the nearest 5-minute (300 seconds) multiple. If no input is provided, use the
    current UTC+8 timestamp. Returns the rounded-down timestamp.
    """
    if ts is None:
        ts = get_local_timestamp()
    down = ts - (ts % 300)
    return down
