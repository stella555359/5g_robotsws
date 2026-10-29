"""
Module for Common Utilities
"""

import time


def wait_until_succeeds(
    func,
    retry_interval,
    args=None,
    kwargs=None,
    timeout=120,
):
    """
    Retries a func until it suceeds within the given timeout frame

    :param func: The func that is supposed to be executed by calling this function
    :param retry_interval: Interval that the process is sleeping between each func call
    :param args: positional arguements for the func as a list []
    :param kwargs: Keyword arguements for the func as a dictionary {}
    :param timeout: Timeout frame for the function to be retried for

    Returns the function result if it succeeds within the timeout frame, otherwise it
    Raises an AssertionError if the certain timeout frame is exceeded
    """
    args = args or []
    kwargs = kwargs or {}
    deadline = time.monotonic() + timeout  # using monotonic to avoid issues with system time changes
    while True:
        try:
            return func(*args, **kwargs)
        except Exception as e:
            if time.monotonic() >= deadline:
                error_message = (
                    f"It was not possible to execute {func.__name__} successfully within {timeout} seconds!"
                    f"Raised Exception: {e}"
                )
                raise AssertionError(error_message) from e
            time.sleep(retry_interval)
