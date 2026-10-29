import time
from datetime import datetime, timedelta


def get_next_quarter_hours(num_quarters=1):
    """Get the next quarter-hour time points"""
    now = datetime.now()
    minutes = now.minute
    remainder = minutes % 15
    if remainder == 0:
        next_quarter = now.replace(second=0, microsecond=0) + timedelta(minutes=15)
    else:
        next_quarter = now.replace(second=0, microsecond=0) + timedelta(minutes=(15 - remainder))
    return [next_quarter + timedelta(minutes=15*i) for i in range(num_quarters)]


def wait_until(target_time):
    """Wait until the specified time"""
    try:
        now = datetime.now()
        wait_seconds = (target_time - now).total_seconds()
        if wait_seconds > 0:
            time.sleep(wait_seconds)
            return True
        return False
    except KeyboardInterrupt:
        print("\nWaiting interrupted by user")
        return False
    except Exception as e:
        print(f"Error occurred during waiting: {e}")
        return False


def wait_for_quarters(num_quarters=1, return_format='datetime'):
    """
    Wait until the next quarter-hour(s) and return the time(s)
    Args:
        num_quarters: Number of quarter-hours to wait for
        return_format: Return format, 'datetime' or 'string'
    Returns:
        The first quarter-hour time reached and a list of subsequent quarter-hour times
        return time will minus 15 mins
    """
    # Validate input parameters
    if not isinstance(num_quarters, int) or num_quarters <= 0:
        raise ValueError("num_quarters must be a positive integer")
    if return_format not in ['datetime', 'string']:
        raise ValueError("return_format must be 'datetime' or 'string'")
    try:
        quarters = get_next_quarter_hours(num_quarters)
        # Wait until the first quarter-hour
        if quarters:
            success = wait_until(quarters[0])
            if not success:
                print("Waiting failed, returning calculated time points")
            # Format the return results
            if return_format == 'string':
                return quarters[0].strftime('%Y-%m-%d %H:%M:%S'), [q.strftime('%Y-%m-%d %H:%M:%S') for q in quarters]
            # print(quarters[0], quarters)
            couter_time = quarters[0] - timedelta(minutes=15)
            return couter_time.strftime('%Y-%m-%d %H:%M:%S')
        return None, []
    except Exception as e:
        print(f"Error occurred during execution: {e}")
        return None, []
