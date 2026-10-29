# -*- coding: utf-8 -*-
"""
Keywords for collecting info from config __init__.py.

:copyright: Nokia Networks
:author: I_MN_5GSC_KRK_AUTO
:contact: I_MN_5GSC_KRK_AUTO@internal.nsn.com
:maintainer: I_MN_5GSC_KRK_AUTO
:contact: I_MN_5GSC_KRK_AUTO@internal.nsn.com

"""
from taf.config.testline import Airscale, ClassicalBts, \
    CloudBts, RealEnb, Enb, gNB, NetworkAddress
from testsuite.Bangalore.ORAN.resources.python.\
    Macro.Python.utilities import get_builtin_value

tl = get_builtin_value(param_name="tl")


def get_web_credentials_for_du(bts_id=0, du_id=0, bts_type='GNB'):
    """
    Get WEB credentials for du.

    :param bts_id: Id of BTS
    :param du_id: Id of DistributionUnit
    :param bts_type: BTS type: GNB or ENB

    :return: sample results
    :rtype: dict
    """

    credentials = {}
    bts = _get_bts_object(bts_id=bts_id, bts_type=bts_type)

    if isinstance(bts, ClassicalBts):
        credentials = {
            'ip': bts.cu.oam_http_connection_details.addr,
            'username': bts.cu.oam_http_connection_details.username,
            'password': bts.cu.oam_http_connection_details.password,
        }
    elif isinstance(bts, CloudBts):
        du = bts.dus[du_id]
        default_ip = '192.168.255.129'
        if hasattr(du, 'oam_ip'):
            if isinstance(du.oam_ip, str):
                oam_ip = du.oam_ip
            elif isinstance(du.oam_ip, NetworkAddress) and \
                    hasattr(du.oam_ip, 'v4'):
                oam_ip = du.oam_ip.v4.split('/')[0]
            else:
                oam_ip = default_ip
        else:
            oam_ip = default_ip
        credentials = {
            'ip': oam_ip,
            'username': 'Nemuadmin',
            'password': 'nemuuser',
        }
    elif isinstance(bts, RealEnb):
        credentials = {
            'ip': bts.oam_ip.v4,
            'username': 'Nemuadmin',
            'password': 'nemuuser',
        }

    credentials['ip'] = credentials['ip'].split('/')[0]

    return credentials


def get_web_credentials_for_cu(bts_id=0, bts_type='GNB'):
    """
    Get WEB credentials for du.

    :param bts_id: Id of BTS
    :param bts_type: BTS type: GNB or ENB

    :return: sample results
    :rtype: dict
    """

    credentials = {}
    bts = _get_bts_object(bts_id=bts_id, bts_type=bts_type)

    if isinstance(bts, CloudBts):
        credentials = {
            'ip': bts.cu.oam_http_connection_details.addr,
            'username': bts.cu.oam_http_connection_details.username,
            'password': bts.cu.oam_http_connection_details.password,
        }

    return credentials


def _get_bts_object(bts_id, bts_type):
    btss = tl.gnbs if bts_type == 'GNB' else tl.enbs
    return btss[int(bts_id)]


def get_count_of_radios(bts_id=0, du_id=0, bts_type='GNB'):
    """
    Get count of radios from configuration init file.

    :param bts_id: Id of BTS
    :param du_id: Id of DistributionUnit
    :param bts_type: BTS type: GNB or ENB

    :return: Radios count
    :rtype: int
    """
    bts = _get_bts_object(bts_id=bts_id, bts_type=bts_type)
    return len(bts.dus[int(du_id)].rus)


def get_count_of_capacity_units(bts_id=0, du_id=0, common_unit_id=0,
                                bts_type='GNB'):
    """
    Get count of Ablis from configuration init file.

    :param bts_id: Id of BTS
    :param du_id: Id of DistributionUnit
    :param common_unit_id: Id of CommonUnit
    :param bts_type: BTS type: GNB or ENB

    :return: Capacity Units(eg: Abil) count
    :rtype: int
    """
    bts = _get_bts_object(bts_id=bts_id, bts_type=bts_type)

    airscale = _get_airscale_object(bts=bts, du_id=du_id)
    return len(airscale.common_units[int(common_unit_id)].capacity_units)


def get_count_of_distributed_units(bts_id=0, bts_type='GNB'):
    """
    Get count of Ablis from configuration init file.

    :param bts_id: Id of BTS
    :param bts_type: BTS type: GNB or ENB

    :return: Distributed Units count
    :rtype: int
    """
    bts = _get_bts_object(bts_id=bts_id, bts_type=bts_type)

    return len(bts.dus)


def _get_airscale_object(bts, du_id):
    airscale = None
    if bts.dus and isinstance(bts.dus[int(du_id)].airscale, Airscale):
        airscale = bts.dus[int(du_id)].airscale
    elif isinstance(bts.system_module, Airscale):
        airscale = bts.system_module
    elif isinstance(bts.airscale, Airscale):
        airscale = bts.airscale

    return airscale


def _get_test_pc_object(bts_type):
    test_pc_type = gNB if bts_type == 'GNB' else Enb

    for test_pc in tl.test_pcs:
        if len(test_pc.connections):
            if isinstance(test_pc.connections[0], test_pc_type):
                return test_pc


def get_bts_ws_credentials(bts_id=0, du_id=0, common_unit_id=0,
                           bts_type='GNB'):
    """
    Get credentials for workstation to BTS.

    :param bts_id: Id of BTS
    :param du_id: Id of DistributionUnit
    :param common_unit_id: Id of CommonUnit
    :param bts_type: BTS type: GNB or ENB

    :return: Dict of 'host', 'user', 'password'
    :rtype: dict
    """
    ws_credentials = dict.fromkeys(('host', 'user', 'password'))

    try:
        test_pc = _get_test_pc_object(bts_type=bts_type)

        ws_credentials['host'] = test_pc.default_ssh_connection_details.\
            addr
        ws_credentials['user'] = test_pc.default_ssh_connection_details.\
            username
        ws_credentials['password'] = test_pc.default_ssh_connection_details.\
            password

        return ws_credentials

    except AttributeError:

        bts = _get_bts_object(bts_id=bts_id, bts_type=bts_type)
        airscale = _get_airscale_object(bts=bts, du_id=du_id)
        cu = airscale.common_units[int(common_unit_id)]

        if hasattr(cu.lmp_connection, "proxy") and \
                cu.lmp_connection.proxy is not None:
            ws_credentials['host'] = cu.lmp_connection.proxy.addr
            ws_credentials['user'] = cu.lmp_connection.proxy.username
            ws_credentials['password'] = cu.lmp_connection.proxy.password
        else:
            ws_credentials['host'] = tl.test_pc.\
                default_ssh_connection_details.addr
            ws_credentials['user'] = tl.test_pc.\
                default_ssh_connection_details.username
            ws_credentials['password'] = tl.\
                test_pc.default_ssh_connection_details.password

        return ws_credentials


def get_global_bts_id(bts_id=0, du_id=0, bts_type='GNB'):
    """
    Get global BTS id from config file.

    :param bts_id: Id of BTS
    :param du_id: Id of DistributionUnit
    :param bts_type: BTS type: GNB or ENB

    :return: global BTS ID, nrbts_id for GNB or lnbts_id for ENB
    :rtype: int
    """

    bts = _get_bts_object(bts_id=bts_id, bts_type=bts_type)
    if isinstance(bts, CloudBts) and hasattr(bts.dus[int(du_id)],
                                             'global_bts_id'):
        global_bts_id = bts.dus[int(du_id)].global_bts_id
    else:
        global_bts_id = bts.global_bts_id

    return global_bts_id


def get_bts_instance_id(bts_id=0, du_id=0, bts_type='GNB'):
    """
    Get BTS Instance id from config file.

    :param bts_id: Id of BTS
    :param du_id: Id of DistributionUnit
    :param bts_type: BTS type: GNB or ENB

    :return: global BTS ID - MRBTS
    :rtype: int
    """

    bts = _get_bts_object(bts_id=bts_id, bts_type=bts_type)
    if isinstance(bts, CloudBts) and hasattr(bts.dus[int(du_id)],
                                             'instance_id'):
        instance_id = bts.dus[int(du_id)].instance_id
    else:
        instance_id = bts.instance_id

    return instance_id


def get_count_of_ru_extensions(bts_id=0, du_id=0, ru_id=0, bts_type='GNB'):
    """
    Get count of RU extension module from configuration init file.

    :param bts_id: Id of BTS
    :param du_id: Id of DistributionUnit
    :param ru_id: Id of Radio Unit
    :param bts_type: BTS type: GNB or ENB

    :return: Capacity Units(eg: Abil) count
    :rtype: int
    """
    bts = _get_bts_object(bts_id=bts_id, bts_type=bts_type)

    extensions = bts.dus[int(du_id)].rus[int(ru_id)].ru_extensions
    count_of_extensions = 0 if extensions is None else len(extensions)
    return count_of_extensions


def get_bts_pdu_port(bts_id=0, du_id=0, common_unit_id=0, bts_type='GNB'):
    """
    Get BTS PDU port from config file.

    :param bts_id: Id of BTS
    :param du_id: Id of DistributionUnit
    :param common_unit_id: Id of CommonUnit
    :param bts_type: BTS type: GNB or ENB

    :return:  one of the taf.pdu classes objects.
    :rtype: pdu object
    """

    bts = _get_bts_object(bts_id=bts_id, bts_type=bts_type)
    airscale = _get_airscale_object(bts=bts, du_id=du_id)
    return airscale.common_units[int(common_unit_id)].pdu_port


def get_radio_unit_type(bts_id=0, du_id=0, ru_id=0, bts_type='GNB'):
    """
        Get Radio Unit type from config file.

        :param bts_id: Id of BTS
        :param du_id: Id of DistributionUnit
        :param bts_type: BTS type: GNB or ENB
        :param ru_id: Id of Radio Unit

        :return: Radio Unit type
        :rtype: str
        """

    bts = _get_bts_object(bts_id=bts_id, bts_type=bts_type)
    radio_type = bts.dus[int(du_id)].rus[int(ru_id)].radio_type

    return radio_type


def get_du_lmp_credentials(bts_id=0, du_id=0, bts_type='GNB'):
    """
    Get credentials for the DU LMP connection

    :param bts_id: Id of BTS
    :param du_id: Id of DistributionUnit
    :param bts_type: BTS type: GNB or ENB

    :return:  DU LMP connection credentials
    :rtype:  dict
    """

    bts = _get_bts_object(bts_id=bts_id, bts_type=bts_type)

    credentials = {
        'username': bts.dus[int(du_id)].airscale.common_units[int(du_id)].
        lmp_connection.username,
        'password': bts.dus[int(du_id)].airscale.common_units[int(du_id)].
        lmp_connection.password,
        'host': bts.dus[int(du_id)].airscale.common_units[int(du_id)].
        lmp_connection.addr
    }

    return credentials


def is_testline_of_cloud_type(bts_id=0, bts_type='GNB'):
    """
        Check if  testline is Cloud configuration

       :param bts_id: Id of BTS
       :param bts_type: BTS type: GNB or ENB

       :return: True or False
       :rtype: bool
       """
    bts = _get_bts_object(bts_id=bts_id, bts_type=bts_type)
    if isinstance(bts, CloudBts):
        return True
    return False


def get_ue_pc_credentials(ue_id=0):
    """
    Get credentials to UE_PC.

    :param ue_id:           UE id - related to Test Line configuration
    - tl.ues.
    """
    host = tl.ues[int(ue_id)].ssh_connection_details.addr
    username = tl.ues[int(ue_id)].ssh_connection_details.username
    password = tl.ues[int(ue_id)].ssh_connection_details.password

    return host, username, password


def get_cu_oam_ssh_credentials(bts_id=0, bts_type='GNB'):
    """
    Get credentials for the CU OAM VM

    :param bts_id: Id of BTS
    :param bts_type: BTS type: GNB or ENB

    :return:  DU LMP connection credentials
    :rtype:  dict
    """

    bts = _get_bts_object(bts_id=bts_id, bts_type=bts_type)

    credentials = {
        'username': bts.cu.oam_ssh_connection_details.username,
        'password': bts.cu.oam_ssh_connection_details.password,
        'host': bts.cu.oam_ssh_connection_details.addr,
    }

    return credentials


def get_du_f1_plane_addresses(bts_id=0, du_id=0, bts_type='GNB'):
    """
    Get DU F1-plane addresses

    :param bts_id:      ID of BTS
    :param du_id:       Id of DistributionUnit
    :param bts_type:    BTS type: GNB or ENB

    :return:            DU F1-plane addresses
    :rtype:             dict
    """

    bts = _get_bts_object(bts_id=bts_id, bts_type=bts_type)

    f1_plane_addresses = {
        'f1_mplane': bts.dus[int(du_id)].f1_m_ip_addr.v4.split('/')[0],
        'f1_cplane': bts.dus[int(du_id)].f1_c_ip_addr.v4.split('/')[0],
        'f1_uplane': bts.dus[int(du_id)].f1_u_ip_addr.v4.split('/')[0],
    }

    return f1_plane_addresses


def get_vm_credentials():
    test_pc_ssh = tl.test_pc.default_ssh_connection_details

    credentials = {
        'username': test_pc_ssh.username,
        'password': test_pc_ssh.password,
        'host': test_pc_ssh.addr,
    }

    return credentials
