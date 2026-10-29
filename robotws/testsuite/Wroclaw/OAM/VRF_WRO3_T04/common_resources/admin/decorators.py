from robot.api import logger
from functools import wraps
from testsuite.Wroclaw.OAM.VRF_WRO3_T04.common_resources.admin.admin_utils import create_admin_connection
import inspect


def inject_admin_connection(func):
    """
    Decorator for injecting ADMIN connection into
    RobotFramework keywords in case if it was not
    explicitly passed by `connection` parameter.

    If needed, a new ADMIN connection instance is created and
    closed after the decorated keyword execution.
    """

    @wraps(func)
    def wrapper(*args, **kwargs):

        signature = inspect.signature(func)
        binding = signature.bind(*args, **kwargs)
        binding.apply_defaults()

        if binding.arguments['connection'] is None:
            logger.debug('{}: Creating new ADMIN connection...'.format(func.__name__))
            with create_admin_connection() as temp_connection:
                binding.arguments['connection'] = temp_connection
                return func(*binding.args, **binding.kwargs)
        else:
            return func(*binding.args, **binding.kwargs)

    return wrapper
