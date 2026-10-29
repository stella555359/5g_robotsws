"""
Module with help functions for connections
"""
import logging
import os
import time
from taf.config.testline import RealEnb
from robot.libraries.BuiltIn import BuiltIn
from robot.utils import robottime

import utils
# api = admin()

logger = logging.getLogger()


def is_same_node(obj, nodeb):
    """
    Check if the given object is the same as the nodeb or its common unit.

    :param obj: The object to compare.
    :param nodeb: The nodeb to compare against.
    :return: True if obj is the same as nodeb or its common unit, False otherwise.
    """
    is_node = False

    if obj == nodeb:
        is_node = True
    else:
        try:
            common_unit = nodeb.dus[0].airscale.common_units[0]
            is_node = obj == common_unit
        except KeyError:
            pass
        except AttributeError:
            pass

    return is_node


def get_test_pc_ip_for_remote_connection(tl, node_type, node_id):
    """
    Retrieves the IP address of the remote test PC associated with a given NodeB.

    This func determines the appropriate test PC for the specified NodeB using the
    `get_test_pc_for_nodeb` func. It then returns the IP address of the test PC
    for remote connection purposes. If the test PC's IP address matches the default
    test PC's IP address, it returns `None`, indicating no remote connection is needed.

    :param tl: TestLine object containing test PCs and node information
    :param node_type: note_type object to find the associated test PC
    :return: IP address of the remote test PC
    """
    node = None

    if node_type == "gnb":
        node = tl.gnbs[node_id]
    elif node_type == "enb":
        node = tl.enbs[node_id]
    if node is None:
        raise ValueError("Invalid node type provided.")
    nb_test_pc = get_test_pc_for_nodeb(tl, node)
    logging.info(
        "nb_test_pc_ip: %s", nb_test_pc.default_ssh_connection_details.addr)
    logging.info("VM_ip: %s", tl.test_pc.default_ssh_connection_details.addr)
    if nb_test_pc.default_ssh_connection_details.addr == tl.test_pc.default_ssh_connection_details.addr:
        remote_ip = None
    else:
        remote_ip = nb_test_pc.default_ssh_connection_details.addr
    return remote_ip


def setup_oam_http_session(
    tl,
    node_id=0,
    node_type='gnb',
    admin_api_log_path='/tmp/',
    timeout='3min',
    bts_id='192.168.255.129'
):
    """
    Establishes an HTTP session with the help of the admin library and returns the sw_release

    :param tl: TestLine object containing test PCs and node information
    :param node_type the given node type if its a gnb or enb
    :param timeout the timeout specified for the wait_until_succeeds func

    Returns the oam_alias
    """
    try:
        api = BuiltIn().get_library_instance("admin")
    except RuntimeError as exc:
        raise AssertionError(
            "You need to import: 'Library   taf.sbts.oam.coam.admin  WITH NAME  admin'"
        ) from exc

    node_type = node_type.lower()
    oam_alias = f"{node_type}-{node_id}-OAM-http-session"
    timeout_secs = robottime.timestr_to_secs(timeout)

    session_exists = False

    # check if there is an active working session
    try:
        _log_amount_of_admin_sessions(api, oam_alias)
        session_exists = True
        logger.debug("Existing session '%s' is functional.", oam_alias)
    except Exception as e:
        logger.debug(
            "Session check failed for '%s': %s - will setup new admin connection",
            oam_alias, e
        )

    # if not teardown and perform new setup
    if not session_exists:
        try:
            logger.debug(
                "Teardown admin connection, in case there is still one with same '%s'.",
                oam_alias
            )
            api.teardown(connection=oam_alias)
        except Exception as teardown_exc:
            logger.debug("Exception during teardown: %s", teardown_exc)

        remote_ip = get_test_pc_ip_for_remote_connection(tl, node_type, node_id)
        os.makedirs(admin_api_log_path, exist_ok=True)
        logging.info(
            "Setup admin connection with Node %s%s via %s", node_type, node_id, remote_ip
        )
        utils.wait_until_succeeds(
            func=api.setup_admin,
            kwargs={
                "bts_host": bts_id,
                "name": oam_alias,
                "remote_host": remote_ip,
                "admin_api_log_dir": admin_api_log_path
            },
            timeout=timeout_secs,
            retry_interval=30,
        )
        _log_amount_of_admin_sessions(api, oam_alias)

    # fetch SW Release, re-try if it fails until success or timeout
    _wait_for_sw_release(api, oam_alias, timeout=timeout_secs)

    return oam_alias


def _wait_for_sw_release(api, oam_alias, timeout=300):
    """
    Wait for software release to be available, retrying on both empty responses and exceptions.

    :param api: The admin API instance
    :param oam_alias: The connection alias
    :param timeout: Maximum time to wait in seconds
    :raises TimeoutError: If sw_release is not available within timeout
    """
    logger.debug(
        f"Waiting for sw_release for connection {oam_alias} with timeout {timeout} seconds."
    )
    start_time = time.time()
    last_exception = None
    sw_release = None

    timeout = 1 if timeout == 0 else timeout

    while True:
        waiting_time = time.time() - start_time

        if waiting_time > timeout:
            error_msg = (
                f"Timed out waiting for sw_release for connection {oam_alias} "
                f"with timeout {timeout} seconds after {waiting_time:.1f} seconds."
            )
            if last_exception:
                error_msg += f" Last error: {last_exception}"
            raise TimeoutError(error_msg)

        try:
            logger.info(f"Checking sw_release for connection {oam_alias}")
            sw_release = api.get_sw_release_name(connection=oam_alias)

            if sw_release:
                logger.debug(
                    f"Sw release '{sw_release}' found for connection {oam_alias} "
                    f"after {waiting_time:.1f} seconds."
                )
                return sw_release
            else:
                logger.debug(
                    f"Empty sw_release received for connection {oam_alias}, retrying..."
                )
        except Exception as e:
            last_exception = e
            logger.debug(
                f"Exception while getting sw_release for connection {oam_alias}: {e}, retrying..."
            )

        time.sleep(1)


def _log_amount_of_admin_sessions(api, alias):
    link_status = api.check_link_status(connection=alias, detailed_output=True)
    request_message = link_status.get("requestMessage")
    if request_message:
        logger.info("Open admin Sessions: " + str(len(request_message)))


def get_test_pc_for_nodeb(tl, nodeb):
    """
    Retrieve the appropriate test PC for a given NodeB.

    This function determines the test PC that should be used for a specified NodeB.
    It checks the test PCs associated with the given tl

    Parameters:
    :param tl: The testline object which we use to return the test pc
    :param nodeb: The NodeB object which may contain common units either in 'dus' or 'system_module'.

    Returns the selected test PC object. If no suitable test PC is found, it returns the default test PC.
    """

    test_pcs = []

    if not hasattr(tl, 'test_pcs'):
        logging.warning(
            "test_pcs were not found and connecting to default test_pc")
        return tl.test_pc

    uses_connection_object = any(
        hasattr(connection, 'device')
        for test_pc in tl.test_pcs
        for connection in test_pc.connections
    )

    nodeb_common_units = []
    if uses_connection_object:
        if hasattr(nodeb, "dus"):
            nodeb_common_units = [
                common_unit for du in nodeb.dus for common_unit in du.airscale.common_units]
        elif hasattr(nodeb, "system_module"):
            nodeb_common_units = nodeb.system_module.common_units
        for test_pc in tl.test_pcs:
            for connection in test_pc.connections:
                if hasattr(connection, 'device') and connection.device in nodeb_common_units:
                    test_pcs.append(test_pc)

        # remove duplicates from test_pc list
        test_pcs = list(set(test_pcs))
    else:
        test_pcs = [
            test_pc for test_pc in tl.test_pcs for obj in test_pc.connections if is_same_node(obj, nodeb)]

    if test_pcs:
        return test_pcs[0]
    logging.warning("test_pcs were not found and connecting to default test_pc")
    return tl.test_pc


def get_proxy(tl, nodeb):
    """
    This function gets the proxy for a given NodeB
    It checks the configuration, which test pc is connected to the nodeb
    if the NodeB control pc is not the same as the local pc (tl.test_pc),
    the connection details for the control pc of the nodeb is returned in
    form of a dictionary, describing the connection details.
    :param tl: The testline configuration
    :param nodeb: The NodeB, i.e. tl.gnbs[0]
    """
    nodeb_test_pc = get_test_pc_for_nodeb(tl, nodeb)

    local_pc_addr = tl.test_pc.default_ssh_connection_details.addr
    nodeb_pc_addr = nodeb_test_pc.default_ssh_connection_details.addr

    if local_pc_addr != nodeb_pc_addr:
        return {'host': nodeb_test_pc.default_ssh_connection_details.addr,
                'user': nodeb_test_pc.default_ssh_connection_details.username,
                'password': nodeb_test_pc.default_ssh_connection_details.password}
    return None


def get_webservice_for_collector(tl, gnb_id, du_id=None):
    """
    This function returns the details to connect to the webservice.
    This dictionary is used by different collectors

    !!! TD 09.01.2026: add workaround for https://jiradc.ext.net.nokia.com/browse/TAF-5213 !!!
    :param tl: The testline configuration
    :param gnb_id: The id of the gNodeB
    """
    try:
        gnb_id = int(gnb_id)
    except ValueError as exc:
        raise AssertionError(
            f'Error in get_webservicefor_collector: gnb_id is [{gnb_id}] but must be of integer type!') from exc

    remote_proxy = get_proxy(tl, tl.gnbs[gnb_id])

    if du_id:
        try:
            du_id = int(du_id)
        except ValueError as exc:
            raise AssertionError(
                f'Error in get_webservicefor_collector:du_id is[{gnb_id}] but must be of int type!') from exc
        connection_details = tl.gnbs[gnb_id].dus[du_id].oam_http_connection_details
    else:
        connection_details = tl.gnbs[gnb_id].cu.oam_http_connection_details

    webservice = {'host': connection_details.addr,
                  'user': connection_details.username,
                  'password': connection_details.password,
                  'port': 443}

    if remote_proxy:
        webservice.update({'remote_host': remote_proxy['host'],
                           'remote_host_username': remote_proxy['user'],
                           'remote_host_password': remote_proxy['password'],
                           'reuse': False})

    return webservice


def get_lmp_connection_details_for_collector(tl, nodeb, du_id=0, cu_id=0):
    """
    This function returns the details to connect to the lmp of a given nodeb
    In case of a needed proxy, because the nodeb control pc is not the same as the test pc,
    the proxy will be configured.
    :param tl: the testline configuration
    :param nodeb: The nodeB to connect to (i.e. tl.gnbs[0])
    :param du_id: The du_id from testline config
    :param cu_id: The commun unit id from testline config
    """
    du_id = int(du_id)
    cu_id = int(cu_id)

    if isinstance(nodeb, RealEnb):
        lmp_connection = nodeb.system_module.common_units[cu_id].lmp_connection
    else:
        lmp_connection = nodeb.dus[du_id].airscale.common_units[cu_id].lmp_connection

    proxy = get_proxy(tl, nodeb)

    lmp_connection = {'host': lmp_connection.addr,
                      'user': lmp_connection.username,
                      'password': lmp_connection.password}
    if proxy:
        lmp_connection['proxy'] = proxy

    return lmp_connection


def get_slave_connection_details_for_collector(tl, nodeb, slave_ip, du_id=0, cu_id=0):
    """
    This function returns the connection details to connect to a slave cpu of gNB.
    :param tl: the testine configuration
    :param nodeb: The nodeB to connect to (i.e. tl.gnbs[0])
    :param slave_ip: the ip of the slave host
    :param du_id: The du_id from testline config
    :param cu_id: The commun unit id from testline config
    """
    slave_connection = {'host': slave_ip,
                        'user': nodeb.dus[du_id].airscale.common_units[cu_id].lmp_connection.username,
                        'password': nodeb.dus[du_id].airscale.common_units[cu_id].lmp_connection.password}

    lmp_connection = get_lmp_connection_details_for_collector(
        tl, nodeb, du_id, cu_id)
    slave_connection['proxy'] = lmp_connection
    return slave_connection
