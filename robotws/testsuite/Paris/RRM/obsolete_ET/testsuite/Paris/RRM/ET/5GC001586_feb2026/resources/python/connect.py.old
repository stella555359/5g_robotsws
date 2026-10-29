"""
Module with help functions for connections
"""
import logging
from taf.config.testline import RealEnb


def get_test_pc_for_nodeb(tl, nodeb):

    test_pcs = []

    if not hasattr(tl, 'test_pcs'):
        logging.info(
            "test_pcs were not found and connecting to default test_pc")
        return tl.test_pc

    uses_connection_object = any([hasattr(connection, 'device')
                                 for test_pc in tl.test_pcs for connection in test_pc.connections])

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
            test_pc for test_pc in tl.test_pcs for obj in test_pc.connections if obj is nodeb]

    if test_pcs:
        return test_pcs[0]
    else:
        logging.info(
            "test_pcs were not found and connecting to default test_pc")
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


def get_webservice_for_collector(tl, gnb_id, du_id=None):
    """
    This function returns the details to connect to the webservice.
    This dictionary is used by different collectors
    :param tl: The testline configuration
    :param gnb_id: The id of the gNodeB
    """
    try:
        gnb_id = int(gnb_id)
    except ValueError:
        raise AssertionError('Error in get_webservicefor_collector: gnb_id is [{}] but must be of integer type!'
                             .format(gnb_id))

    remote_proxy = get_proxy(tl, tl.gnbs[gnb_id])

    if du_id:
        try:
            du_id = int(du_id)
        except ValueError:
            raise AssertionError('Error in get_webservicefor_collector: du_id is [{}] but must be of integer type!'
                                 .format(gnb_id))
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
                           'remote_host_password': remote_proxy['password']})

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
    This function returns the connection details to connect to a slave host (bsh)
    of a gNodeB
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
