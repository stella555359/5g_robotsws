from functools import wraps
from time import sleep
from robot.api import logger
from ute_common_admin.exception import AdminApiProcedureFailureException


def retry_if_fail(exception=Exception, max_retries=10, interval_sec=10, part_of_msg=None):
    '''
    :param exception:       Exception object
    :param max_retries:     (int) number of times to retry execute decorated function
    :param interval_sec:    (int) time between retries
    :param part_of_msg:     (string) part of Exception.message
                            If None, retry function if specified Exception exists
                            (Exception.message not relevant)
    :return:                function
    '''

    def failure_func(func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            i = max_retries
            while i > 0:
                try:
                    return func(*args, **kwargs)
                except exception as e:
                    logger.console(str(e.message))
                    if part_of_msg in str(e.message) or part_of_msg is None:
                        logger.console(str(e) + " - retrying...  ({}/{})".format(max_retries - i + 1, max_retries))
                        sleep(interval_sec)
                        i -= 1
                    else:
                        raise e
        return wrapper
    return failure_func


def create_object_if_update_fails():
    def failure_func(func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            try:
                return func(*args, **kwargs)
            except AdminApiProcedureFailureException as e:
                if "object not exist" in str(e.message):
                    logger.console("\033[1;35m Exception with 'object not exist' message found.\x1b[0m")
                    dist_name = kwargs["dist_name"]
                    param_name = kwargs["param_name"]
                    connection = kwargs["connection"]
                    logger.console("Creating object...")
                    return func(dist_name, param_name, 'create', connection, skip_parameter_relation_errors=True)
                elif 'object already exists' in str(e.message):
                    logger.console("\033[1;35m Exception with 'object already exists' message found.\x1b[0m")
                    dist_name = kwargs["dist_name"]
                    param_name = kwargs["param_name"]
                    connection = kwargs["connection"]
                    logger.console("Deleting object...")
                    func(dist_name, param_name, 'delete', connection, skip_parameter_relation_errors=True)
                    logger.console("Creating object...")
                    return func(dist_name, param_name, 'create', connection, skip_parameter_relation_errors=True)
                elif "parameter cannot be updated" in str(e.message):
                    logger.console(str(e.message))
                    logger.console("Parameter cannot be updated...")
                    return None
                elif "\"error\"" not in str(e.message):
                    logger.console(str(e.message))
                else:
                    logger.console(str(e.message))
                    raise Exception
        return wrapper
    return failure_func
