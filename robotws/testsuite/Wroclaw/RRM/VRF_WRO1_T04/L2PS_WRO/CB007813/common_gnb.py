from robot.libraries.BuiltIn import BuiltIn
from robot.api import logger


from ute_common_admin.exception import (
    AdminApiConnectionClosedException,
    AdminApiProcedureFailureException,
    AdminApiProcedureTimeoutException
)

from taf.sbts.oam.coam.admin.facade import admin_interface_context
from taf.sbts.oam.coam.admin import admin
from functools import wraps
import time
import re


def handle_admin(func):
    """Wrapper function handling setting up and teardown of admin connection. Meant to be used as a decorator.
    Usage: when used in a function, in arguments **kwargs need to be specified.
    Then connection object to Admin API can be obtained using kwargs["connection"] syntax.

    Wrapper takes bts hostname, username and password from robot variables (GNB_IP, WEBEM_USERNAME, WEBEM_PASSWORD).
    When no such variables are recognised, connection to Admin API is established using default values of
    admin.connect_to() method.
    A custom gNB IP can be defined in keyword argument 'bts_host_ip'.

    Wrapper also handles Admin exceptions, mainly AdminApiProcedureFailureException
    and AdminApiConnectionClosedException.
    For recognised AdminApiProcedureFailureException function handles the exceptions accordingly. I.e. for
    error_code==27 (BTS is not ready due to ongoing RNW Plan File activation) function will wait 1min and retry the
    operation until the function succeeds or results in another exception.
    Uses functools.wraps because of https://github.com/sphinx-doc/sphinx/issues/3783

    :param func: function on which the wrapper is used
    :return: result of taf.gnb.oam.coam.admin function
    """
    @wraps(func)
    def inner(*args, **kwargs):
        result = None
        timeoutRetry = True
        connection_error = True
        rnw_retries = 30
        try:
            bts_host = kwargs['bts_host_ip']
        except KeyError:
            bts_host = BuiltIn().get_variable_value("${GNB_IP}")
        username = BuiltIn().get_variable_value("${WEBEM_USERNAME}")
        password = BuiltIn().get_variable_value("${WEBEM_PASSWORD}")

        if all(var is not None for var in [bts_host, username, password]):
            connection_args = {"bts_host": bts_host, "username": username, "password": password}
        else:
            connection_args = {}

        while True:
            try:
                with admin_interface_context(**connection_args) as connection:
                    result = func(connection=connection, *args, **kwargs)
                break
            except AdminApiProcedureFailureException as e:
                error_code = re.search(r'ErrorCode.\s*(\d+)', e.args[0])
                if error_code:
                    if int(error_code.group(1)) == 27 and rnw_retries > 0:
                        for _ in range(60):
                            logger.console('.', newline=False)
                            time.sleep(1)
                        rnw_retries -= 1
                        continue
                    if int(error_code.group(1)) == 7:
                        time.sleep(60)
                        continue
                raise
            except AdminApiProcedureTimeoutException as e:
                if timeoutRetry is True:
                    timeoutRetry = False
                    time.sleep(30)
                    continue
                else:
                    raise
            except AdminApiConnectionClosedException as e:
                raise
            except UnboundLocalError as e:
                if connection_error is True:
                    connection_error = False
                    wait_till_admin_is_online(retry=10)
                    time.sleep(30)
                    continue
                else:
                    raise
            except Exception as e:
                raise
        return result
    return inner


def wait_till_admin_is_online(retry=30, retry_interval=30):
    """Function waits until the Admin Api is available for the user. Sometimes after bts reboot AdminApi is unavailable
    for a long time, resulting in an error AdminApiConnectionClosedException.
    This function aims to resolve this problem.

    :param retry: count of retries
    :param retry_interval: interval between retries, in seconds
    """
    admin_instance = admin()
    bts_host = BuiltIn().get_variable_value("${GNB_IP}")
    username = BuiltIn().get_variable_value("${WEBEM_USERNAME}")
    password = BuiltIn().get_variable_value("${WEBEM_PASSWORD}")
    while retry > 0:
        try:
            if all(var is not None for var in [bts_host, username, password]):
                connection = admin_instance.connect_to(
                    bts_host=bts_host,
                    username=username,
                    password=password
                )
            else:
                connection = admin_instance.connect_to()
            break
        except AdminApiConnectionClosedException as e:
            logger.info("AdminApiConnectionClosedException: AdminApi is still offline")
        except Exception as e:
            logger.info("EXCEPTION: {} {}".format(e.args, e.message))
            raise
        time.sleep(retry_interval)
        retry -= 1
    admin_instance.teardown_all_aliases_for_admin()
    if retry == 0:
        raise AdminApiConnectionClosedException("Could not connect to AdminApi.")
