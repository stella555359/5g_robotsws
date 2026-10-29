
from robot.api import logger
from robot.libraries import BuiltIn

builtin = BuiltIn.BuiltIn()


def _pv(varname):
    if varname in builtin.get_variables():
        return builtin.get_variables()[varname]
    else:
        return ''


def _spv(varname, value):
    if '$' not in varname and '@' not in varname and '&' not in varname:
        varname = '${%s}' % (varname)
    builtin.set_global_variable(varname, value)


def _getattr(obj, attr_list=[]):
    tmp_obj = obj
    for attr in attr_list:
        if tmp_obj:
            if ',' in attr:
                name, index = attr.split(',')
                if hasattr(tmp_obj, name) and getattr(tmp_obj, name):
                    tmp_obj = getattr(tmp_obj, name)[int(index)]
                else:
                    tmp_obj = None
            else:
                if hasattr(tmp_obj, attr):
                    tmp_obj = getattr(tmp_obj, attr)
                else:
                    tmp_obj = None
    return tmp_obj if tmp_obj else ''


def convert_cus_site_info_to_gnbs(tl):
    from taf.config.testline.airscale import Airscale
    from taf.config.testline.gnb.du import DU
    from taf.config.testline.gnb.gnb import CU, ClassicalBts
    from taf.config.testline import NetworkAddress
    from taf.config.testline.connection_details import (
        SshServiceDetails,
        HttpConnectionDetails
    )
    tl_cloud_topology = _getattr(tl, ['tl_cloud_topology'])
    logger.info('Converting CUs to GNBs for TL: {}'.format(tl_cloud_topology))
    if "_CUS" in tl_cloud_topology:
        _airscale = _getattr(tl, ['enbs,0', 'system_module'])
        _du = DU(
            airscale=_airscale,
            f1_m_ip_addr="192.168.255.129"
        )
        _cu = CU(
            backhaul_site_oam_ip=NetworkAddress(
                v4="10.108.233.211",
                vlan_id=None
            ),
            oam_ssh_connection_details=SshServiceDetails(
                addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
            ),
            oam_http_connection_details=HttpConnectionDetails(
                addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
            )
        )
        _classical_bts = ClassicalBts(dus=[_du], cu=_cu, instance_id="1", global_bts_id="1")
        tl.gnbs = [_classical_bts]
        _spv('tl.gnbs', tl.gnbs)


def prepare_global_variables():
    tl = _pv('${tl}') or _pv('@{tl}')
    logger.warn('Preparing global variables')
    convert_cus_site_info_to_gnbs(tl)
    _spv('appserver_addr', _getattr(tl, ['ues,0', 'ssh_connection_details', 'addr']))
    _spv('appserver_username', _getattr(tl, ['ues,0', 'ssh_connection_details', 'username']))
    _spv('appserver_password', _getattr(tl, ['ues,0', 'ssh_connection_details', 'password']))
    _spv('attenuation_port', _getattr(tl, ['attenuator', 'port']))
    _spv('ATTENUATOR_ADDR', _getattr(tl, ['attenuator', 'ip_addr']))
    _spv('ENB_IP', _getattr(tl, ['enbs,0', 'airscale', 'common_units,0', 'lmp_connection', 'addr']))
    _spv('pdu_gnb_addr', _getattr(tl, ['gnbs,0', 'dus,0', 'airscale', 'common_units,0', 'pdu_port', 'pdu', 'addr']))
    _spv('@{pdu_gnb_port}', _getattr(tl, ['gnbs,0', 'dus,0', 'airscale', 'common_units,0', 'pdu_port', 'port_no']))
    _spv('attenuation_ports', _getattr(tl, ['attenuator', "attenuator_ports"]))
    _spv('attenuation_vendor', _getattr(tl, ['attenuator', "vendor"]))
    asib_ip = _getattr(tl, ['gnbs,0', "dus,0", "airscale", "common_units,0", "lmp_connection", "addr"])
    _spv('ASIB_IP', asib_ip if asib_ip is not None and asib_ip != "" else "192.168.255.129")
    asib_username = _getattr(tl, ['gnbs,0', "dus,0", "airscale", "common_units,0", "lmp_connection", "username"])
    _spv('ASIB_USERNAME', asib_username if asib_username is not None and asib_username != "" else "toor4nsn")
    asib_password = _getattr(tl, ['gnbs,0', "dus,0", "airscale", "common_units,0", "lmp_connection", "password"])
    _spv('ASIB_PASSWORD', asib_password if asib_password is not None and asib_password != "" else "oZPS0POrRieRtu")
    cu_ip = _getattr(tl, ['gnbs,0', "cu", "oam_http_connection_details", "addr"])
    logger.warn(f"Using cu_ip {cu_ip}")
    _spv('CU_IP', cu_ip if cu_ip is not None and cu_ip != "" else "192.168.255.129")
    http_username = _getattr(tl, ['gnbs,0', "cu", "oam_http_connection_details", "username"])
    _spv('http_USERNAME', http_username if http_username is not None and http_username != "" else "Nemuadmin")
    http_password = _getattr(tl, ['gnbs,0', "cu", "oam_http_connection_details", "password"])
    _spv('http_PASSWORD', http_password if http_password is not None and http_password != "" else "nemuuser")
    _spv('ABIL_MASTER_ADDR', _getattr(tl, ['gnbs,0', 'dus,0', 'airscale', 'common_units,0',
                                           'capacity_units,0', 'addr']))

    if builtin.get_variable_value("${MRBTS_ID}") is None:
        _spv('MRBTS_ID', _getattr(tl, ['gnbs,0', 'instance_id']))
    _spv('testline', "10_5_UTESRAN001T" + _pv('MRBTS_ID'))
    if builtin.get_variable_value("${NRBTS_ID}") is None:
        _spv('NRBTS_ID', _getattr(tl, ['gnbs,0', 'global_bts_id']))

    btsinfo = {"IP": _pv('${ASIB_IP}'),
               "USERNAME": _pv('${ASIB_USERNAME}'),
               "PASSWORD": _pv('${ASIB_PASSWORD}'),
               "LOCALIP": "192.168.255.129",
               "http_USERNAME": _pv('${http_USERNAME}'),
               "http_PASSWORD": _pv('${http_PASSWORD}'),
               "PORT": 443,
               "MRBTS_ID": _pv('${MRBTS_ID}'),
               "NRBTS_ID": _pv('${NRBTS_ID}'),
               "RRUS": _getattr(tl, ['gnbs,0', 'dus,0', "RUS"])}
    builtin.set_global_variable("&{BTS_INFO}",
                                f"IP={btsinfo['IP']}",
                                f"USERNAME={btsinfo['USERNAME']}",
                                f"PASSWORD={btsinfo['PASSWORD']}",
                                f"LOCALIP={btsinfo['LOCALIP']}",
                                f"http_USERNAME={btsinfo['http_USERNAME']}",
                                f"http_PASSWORD={btsinfo['http_PASSWORD']}",
                                f"PORT={btsinfo['PORT']}",
                                f"MRBTS_ID={btsinfo['MRBTS_ID']}",
                                f"NRBTS_ID={btsinfo['NRBTS_ID']}",
                                f"RRUS={btsinfo['RRUS']}")
    # logger.warn(builtin.get_variables())


def show_all_variables():
    alist = [x for x in builtin.get_variables()]
    alist.sort()
    for varname in alist:
        logger.info('Robot variable [{}]  -- [{}]'.format(
            varname, builtin.get_variables()[varname]))


prepare_global_variables()
