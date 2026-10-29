import functools
import re
import logging
from types import FunctionType, MethodType

from taf.sbts.oam.coam.admin import admin, AdminConnection

LOCK_TIMEOUT = 120


def webem_connection(callback: FunctionType):
    """
       Decorator for establishing and managing a connection to the Webem server.

       This decorator ensures a connection to the Webem server is established before
       executing the decorated function and then closes the connection afterwards.
       It also provides the connection object as an argument to the decorated function.

       Args:
           callback (FunctionType): The function to be decorated.

       Returns:
           FunctionType: The decorated function.
       """

    @functools.wraps(callback)
    def inner(*args, **kwargs):
        api = admin()
        try:
            conn = None

            if 'enb_host' in kwargs:
                rel_conn = api.connect_to(bts_host=kwargs['enb_host'])
                release = rel_conn.get_sw_release_name()
                api.teardown(connection=rel_conn)
                conn = api.connect_to(
                    bts_host=kwargs['enb_host'], release=release)
                # To call admin methods we use enb_host(additional paramater with eNB mplane).
                # Some of admin methods needs 'rat' parameter to specify eNB interface.
                # To avoid adding 'rat' and 'enb_host' parameters in our bundler
                # We inject the 'rat' parameter automatically in this decorator.
                # But some methods don't need it.
                # Current mechanism tries call method with 'rat' parameter ,
                # if admin method doesn't take this parametr there is retry without it.
                try:
                    return callback(*args, rat="lte", connection=conn, **kwargs)
                except TypeError:
                    return callback(*args, connection=conn, **kwargs)
            else:
                rel_conn = api.connect_to()
                release = rel_conn.get_sw_release_name()
                api.teardown(connection=rel_conn)
                conn = api.connect_to(release=release)
                return callback(*args, connection=conn, **kwargs)

        finally:
            api.teardown(connection=conn)

    return inner


@webem_connection
def lock_all_cells_except(cell_id: int, rat: str = 'nr', connection: AdminConnection = None, **kwargs):
    """
        Locks all cells except the specified cell.

       Args:
            rat (str): if enb_host is set rat is provided by decorator automatically
            cell_id (int): The ID of the cell to exclude from locking.
            connection (AdminConnection, optional): The Webem connection object. Defaults to None.
        """
    cells_info = connection.get_cells_info(cell_type=rat.lower())
    for cell_i in cells_info:
        if str(cell_id) != str(cell_i['globalCellId']):
            logging.log(logging.INFO, "Locking cell: {}".format(
                cell_i['globalCellId']))
            connection.lock(cell_i['id']['configuration'],
                            timeout=LOCK_TIMEOUT)


@webem_connection
def unlock_all_cells_except(cell_id: int, rat: str = 'nr', connection: AdminConnection = None, **kwargs):
    """
        Unlocks all cells except the specified cell.

        Args:
            rat (str): if enb_host is set rat is provided by decorator automatically
            cell_id (int): The ID of the cell to exclude from unlocking.
            connection (AdminConnection, optional): The Webem connection object. Defaults to None.
            :param rat:
        """
    cells_info = connection.get_cells_info(rat.lower())
    for cell_i in cells_info:
        if cell_id != cell_i['globalCellId']:
            connection.unlock(
                cell_i['id']['configuration'], timeout=LOCK_TIMEOUT)


@webem_connection
def lock_all_cells(rat: str = 'nr', connection: AdminConnection = None, **kwargs):
    """
        Locks all cells.

        Args:
            rat (str): if enb_host is set rat is provided by decorator automatically
            connection (AdminConnection, optional): The Webem connection object. Defaults to None.
            :param rat:
            :param rat:
        """
    cells_info = connection.get_cells_info(rat.lower())
    for cell_i in cells_info:
        connection.lock(cell_i['id']['configuration'], timeout=LOCK_TIMEOUT)


@webem_connection
def lock_cell(cell_id: str, rat: str = 'nr', connection: AdminConnection = None, **kwargs):
    """
      Locks single cells.

      Args:
        cell_id (str): Cell id as a string
        rat (str): if enb_host is set rat is provided by decorator automatically
          connection (AdminConnection, optional): The Webem connection object. Defaults to None.
          :param rat:
      """
    cells_info = connection.get_cells_info(rat.lower())
    for cell_i in cells_info:
        if cell_id == str(cell_i['globalCellId']):
            connection.lock(
                cell_i['id']['configuration'], timeout=LOCK_TIMEOUT)


@webem_connection
def unlock_all_cells(rat: str = 'nr', connection: AdminConnection = None, **kwargs):
    """
      Unlocks all cells.

      Args:
        rat (str): if enb_host is set rat is provided by decorator automatically
          connection (AdminConnection, optional): The Webem connection object. Defaults to None.
          :param rat:
      """
    cells_info = connection.get_cells_info(rat.lower())
    for cell_i in cells_info:
        connection.unlock(cell_i['id']['configuration'], timeout=LOCK_TIMEOUT)


@webem_connection
def unlock_cell(cell_id: str, rat: str = 'nr', connection: AdminConnection = None, **kwargs):
    """
      Unlocks single cells.

      Args:
        cell_id (str): Cell id as a string
        rat (str): if enb_host is set rat is provided by decorator automatically
          connection (AdminConnection, optional): The Webem connection object. Defaults to None.
          :param rat:
      """
    cells_info = connection.get_cells_info(rat.lower())
    for cell_i in cells_info:
        if cell_id == str(cell_i['globalCellId']):
            connection.unlock(
                cell_i['id']['configuration'], timeout=LOCK_TIMEOUT)


@webem_connection
def get_counter_values(counter: str, connection: AdminConnection = None, **kwargs) -> dict:
    """
        Locks all cells.

        Args:
            connection (AdminConnection, optional): The Webem connection object. Defaults to None.
            :param connection:
            :param counter:
        """
    counter_values = connection.get_pm_counters(counter)
    return counter_values


@webem_connection
def verify_cell_status(cell_path: str, connection: AdminConnection = None, **kwargs):
    """Verifies the status of a cell against expected values.

        This function retrieves the status information of a specific cell using the provided connection
        and checks if it matches the expected status values. If any discrepancy is found, an exception
        is raised.

        Args:
            cell_path (str): The path to the cell to be verified.
            connection (AdminConnection, injected by decorator): The connection object to the network management system.
                If not provided, the default connection will be injected. Defaults to None.

        Raises:
            Exception: If the cell status does not match the expected values.
        """
    cell_info = connection.get_cell_specific_info(cell_path)

    expected_cell_state = {'operationalState': 'Enabled', 'proceduralStatus': 'configured',
                           'blockingState': 'Unblocked', 'availabilityStatus': 'Online',
                           'administrativeState': 'Unlocked', 'usageState': 'Active',
                           'barringStatus': 'unbarred'}

    for key, val in cell_info['status'].items():
        exp_val = expected_cell_state[key]
        if not re.search(exp_val, val, flags=re.I):
            raise Exception("The cell status is not as expected. Current cell status: {} "
                            "and Expected Cell Status: {}".format(cell_info['status'], expected_cell_state))


@webem_connection
def verify_nr_cells_are_on_air(cell_type: str = 'nr', connection: AdminConnection = None, **kwargs):
    """Verifies the onair status of all cell of

        Args:
            cell_path (str): The path to the cell to be verified.
            connection (AdminConnection, injected by decorator): The connection object to the network management system.
                If not provided, the default connection will be injected. Defaults to None.

        Raises:
            Exception: If the cell status does not match the expected values.

            :param connection:
            :param cell_type:
        """

    cells_info = connection.get_cells_info(cell_type=cell_type)

    expected_cell_state = {'operationalState': 'Enabled', 'proceduralStatus': 'configured',
                           'blockingState': 'Unblocked', 'availabilityStatus': 'Online',
                           'administrativeState': 'Unlocked', 'usageState': 'Active',
                           'barringStatus': 'unbarred'}

    for cell_info in cells_info:
        for key, val in cell_info['status'].items():
            exp_val = expected_cell_state[key]
            if not re.search(exp_val, val, flags=re.I):
                raise Exception("The cell status is not as expected. Current cell status: {} "
                                "and Expected Cell Status: {}".format(cell_info['status'], expected_cell_state))


@webem_connection
def verify_enb_cells_are_on_air(cell_type: str = 'lte', connection: AdminConnection = None, **kwargs):
    """Verifies the onair status of all cell of

        Args:
            cell_path (str): The path to the cell to be verified.
            connection (AdminConnection, injected by decorator): The connection object to the network management system.
                If not provided, the default connection will be injected. Defaults to None.

        Raises:
            Exception: If the cell status does not match the expected values.

            :param connection:
            :param cell_type:
        """
    cells_info = connection.get_cells_info(cell_type=cell_type)

    expected_cell_state = {'operationalState': 'Enabled', 'proceduralStatus': 'configured',
                           'blockingState': 'Unblocked', 'availabilityStatus': 'Online',
                           'administrativeState': 'Unlocked',
                           'barringStatus': 'unbarred'}
    to_skip = ['usageState']

    for cell_info in cells_info:
        for key, val in cell_info['status'].items():
            if key in to_skip:  # skip some keys which are not important for enb cells
                continue
            exp_val = expected_cell_state[key]
            if not re.search(exp_val, val, flags=re.I):
                raise Exception("The cell status is not as expected. Current cell status: {} "
                                "and Expected Cell Status: {}".format(cell_info['status'], expected_cell_state))


@webem_connection
def activate_delta_recommissioning(delta, connection: AdminConnection = None, **kwargs):
    """Activates delta recommissioning for the given delta.
       To avoid handle admin connection in robotframework keyword you can use this function to perform delta
       recommissioning without taking care about connect to and teardown keywords.

       Args:
           delta: The delta to recommission.
           connection: The AdminConnection object to use for the operation. Injected by decorator.
       Raises:
           Exception: If an error occurs during the recommissioning process.
       """
    connection.perform_delta_recommissioning(delta)


@webem_connection
def activate_scf_commissioning(scf_path: str, connection: AdminConnection = None, **kwargs):
    """Activates scf commissioning for the given file.
       To avoid handle admin connection in robotframework keyword you can use this function.

       Args:
           :param connection:
           :param scf_path:
           connection: The AdminConnection object to use for the operation. Injected by decorator.
       Raises:
           Exception: If an error occurs during the recommissioning process.

       """
    connection.perform_commissioning(scf_file=scf_path)


@webem_connection
def perform_rat_block(rat_name: str, connection: AdminConnection = None, **kwargs):
    """Blocks the specified RAT.

        Args:
            rat_name (str): The name of the RAT to block.
            connection (AdminConnection, injected by decorator): The connection object to the network management system.
                If not provided, the default connection will be injected. Defaults to None.
        """
    connection.block_rat(rat_name.upper(), timeout=300)


@webem_connection
def perform_rat_unblock(rat_name: str, connection: AdminConnection = None, **kwargs):
    """Unblocks the specified RAT.

        Args:
            rat_name (str): The name of the RAT to unblock.
            connection (AdminConnection, injected by decorator): The connection object to the network management system.
                If not provided, the default connection will be injected. Defaults to None.
        """
    connection.unblock_rat(rat_name.upper(), timeout=300)


@webem_connection
def get_sw_version_from_webem(connection: AdminConnection = None, **kwargs) -> str:
    """Gets the software version from the Webem server.

        Args:
            connection (AdminConnection, injected by decorator): The connection object to the network management system.
                If not provided, the default connection will be injected. Defaults to None.

        Returns:
            str: The software version.
        """
    return connection.get_sw_version()


@webem_connection
def generic_webem_call(method_name: str, connection: AdminConnection = None, **kwargs):
    """Performs a generic Webem call. Using this function you can call any method from the Webem connection object.
       Decorator will take care about connection to and teardown.

        Args:
            method_name (str): The method to execute.
            connection (AdminConnection, injected by decorator): The connection object to the network management system.
                If not provided, the default connection will be injected. Defaults to None.
            **kwargs: Additional arguments to pass to the method.

        Returns:
            Depends on method.
        """
    # Get the method from the connection object
    method = getattr(connection, method_name, None)

    # Check if the method exists and is callable
    if not isinstance(method, MethodType):
        raise ValueError(
            f"Method '{method_name}' is not callable or does not exist.")

    # Call the method with the provided arguments
    if 'enb_host' in kwargs:
        del kwargs['enb_host']
    return method(**kwargs)


def check_if_sw_is_trunk() -> bool:
    """Checks if BTS sw is a Trunk release
        Args:
        connection: injected by decorator
        Returns:
            bools - true/false"""

    bts_release = get_sw_version_from_webem()
    if "ENB_9999" in bts_release:
        return True
    return False
