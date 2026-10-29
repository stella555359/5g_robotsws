from dateutil import parser
import datetime


def calculate_time_diff(ts1, ts2):
    """
    Calculate time difference in seconds between two timestamps.

    Args:
        ts1 (str): first timestamp in ISO format
        ts2 (str): second timestamp in ISO format

    Returns:
        float: time difference in seconds (ts2 - ts1)
    """
    dt1 = parser.parse(ts1)
    dt2 = parser.parse(ts2)

    # Normalize both datetimes to UTC
    if dt1.tzinfo is None:
        dt1 = dt1.replace(tzinfo=datetime.timezone.utc)
    else:
        dt1 = dt1.astimezone(datetime.timezone.utc)

    if dt2.tzinfo is None:
        dt2 = dt2.replace(tzinfo=datetime.timezone.utc)
    else:
        dt2 = dt2.astimezone(datetime.timezone.utc)

    return (dt2 - dt1).total_seconds()
