"""
:copyright: Nokia
:author: adam.kropiwnicki@nokia.com
:maintainer: adam.kropiwnicki@nokia.com
"""


import traceback
from time import time, sleep

from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.exceptions import AllRetriesFailed, TimeoutExceeded
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.wro_logger import logger


def print_time(describtion, console=True):
    """
    Decorator for measuring and printing time it took to execute function
    :param describtion: (string) containing short description for called function.
                        print message = description + 'took x seconds'
    :param console: (boolean) determining whether to print on console or in log.html
    :return:
    """
    def wrapper(method):
        def time_it(*args, **kwargs):
            start = time()
            method_result = method(*args, **kwargs)
            timer_result = time() - start
            logger.info("{} took {} seconds".format(describtion, timer_result), also_to_console=console)
            return method_result
        return time_it
    return wrapper


def wait_until_function_succeeds(timeout=60, interval=1, exceptions=Exception, console=False):
    """
    Decorator for retrying decorated function until it succeeds or timeout exceeds. Raises AllRetriesFailed exception
     if unsuccessful.
    :param timeout: (int)  Total number of seconds to wait. It may be exceeded if decorated function takes
                             long to execute
    :param interval: (float)   Number of seconds to wait between consequitive function calls
    :param exceptions: (tuple) Exception classes to look for. If decorated function throws an exception that is not a
                               descendant of any of provided exceptions, it will not be caught and thus it will be
                               propagated further. Defaults to 'Exception' meaning that pretty much every error is
                               covered. This might be undesirable as it makes debugging slightly more difficult.
    :param console: (bool)  Should be printed also to console if running in robot
    :return:  Whatever decorated function returns
    """
    def wrapper(method):
        def retry_until_timeout(*args, **kwargs):
            method_id = "{}({}, {})".format(method.__name__, args, kwargs)
            start_time = time()
            stop_time = start_time + timeout
            timeout_exceeded = False
            iteration = 1
            while not timeout_exceeded:
                try:
                    method_result = method(*args, **kwargs)
                    return method_result
                except KeyboardInterrupt:
                    raise
                except exceptions as e:
                    logger.info("Method: {} - Try {}, Time passed: {} out of {} - Result: {}"
                                .format(method_id, iteration, time() - start_time, timeout, e),
                                also_to_console=console)
                    for line in traceback.format_exc().splitlines():
                        logger.info(line, also_to_console=console)
                iteration += 1
                timeout_exceeded = time() > stop_time
                if not timeout_exceeded:
                    sleep(interval)
                    timeout_exceeded = time() > stop_time
            raise TimeoutExceeded("Timeout exceeded while waiting {timeout} seconds for {id}".format(
                timeout=timeout, id=method_id))
        return retry_until_timeout
    return wrapper


def retry_until_function_succeeds(max_retries=5, interval=1, exceptions=Exception, console=False):
    """
    Decorator for retrying decorated function specified number of times until it succeeds or max retries is reached.
    Raises AllRetriesFailed exception if unsuccessful.
    :param max_retries: (int)  Total number of retries to perform
    :param interval: (float)   Number of seconds to wait between consequitive function calls
    :param exceptions: (tuple) Exception classes to look for. If decorated function throws an exception that is not a
                               descendant of any of provided exceptions, it will not be caught and thus it will be
                               propagated further. Defaults to 'Exception' meaning that pretty much every error is
                               covered. This might be undesirable as it makes debugging slightly more difficult.
    :param console: (bool)  Should be printed also to console if running in robot
    :return:  Whatever decorated function returns
    """
    def wrapper(method):
        def retry_until_max_retries(*args, **kwargs):
            method_id = "{}({}, {})".format(method.__name__, args, kwargs)
            iteration = 0
            while iteration < max_retries + 1:
                try:
                    method_result = method(*args, **kwargs)
                    return method_result
                except KeyboardInterrupt:
                    raise
                except exceptions as e:
                    logger.info("Method: {} - Try {} out of {} - Result: {}".format(method_id, iteration, max_retries,
                                                                                    e), also_to_console=console)
                    for line in traceback.format_exc().splitlines():
                        logger.info(line, also_to_console=console)
                iteration += 1
                sleep(interval)
            raise AllRetriesFailed("All {} retries failed".format(max_retries))
        return retry_until_max_retries
    return wrapper


def continue_on_failure(exceptions=Exception, console=False):
    """
    Decorator for catching errors and reporting them without breaking the execution flow.
    !!! Warning !!!: decoration alternates return value by adding failure indicator
    :param exceptions: (tuple) Exception classes to look for. If decorated function throws an exception that is not a
                               descendant of any of provided exceptions, it will not be caught and thus it will be
                               propagated further. Defaults to 'Exception' meaning that pretty much every error is
                               covered. This might be undesirable as it makes debugging slightly more difficult.
    :param console: (bool)  Should be printed also to console if running in robot
    :return:  (ret_val, boolean)   Tuple containing whatever decorated function returned and boolean indicating
                                   method executed without errors
    """
    def wrapper(method):
        def try_catch_block(*args, **kwargs):
            method_id = "{}({}, {})".format(method.__name__, args, kwargs)
            try:
                return method(*args, **kwargs), True
            except KeyboardInterrupt:
                raise
            except exceptions as e:
                logger.info("Method: {} - Result: {}".format(method_id, e), also_to_console=console)
                for line in traceback.format_exc().splitlines():
                    logger.info(line, also_to_console=console)
            return None, False
        return try_catch_block
    return wrapper
