import time
from moler.device import DeviceFactory
from taf.rfrl.bts.devices.generic_bts import GenericBts
from taf.rfrl.bts.devices.du.du_operations import GnbDuOperations as GnbBbu
from taf.rfrl.bts.devices.ru.ru_operations import GnbRuOperations as GnbRu
from taf.rfrl.utilities.tl_config import load_moler_configuration_from_tl
from taf.rfrl.utilities.logger.custom_logger import log_info_to_console
from testsuite.Krakow.OAM.regression.RAN_PZ_KRK1.CB008501_7213.resources.exceptions import ConnectionNotCreated, \
     ConnectionNotStarted, RequiredCipherNotUsed, RequiredCipherNotSeen, ForbiddenCipherSeen


class BbuOperations(GnbBbu):

    @load_moler_configuration_from_tl()
    def set_dhcp(self, bts_id=0, du_id=0):
        """
        Sets correct DHCP mask and performs DHCP service reset and RU reset to apply changes
        :param bts_id: eNB/gNB id related to bts configuration
        :param du_id:  DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
        """
        bts_name = self.ssh_alias.format(bts_id, du_id)
        bts = DeviceFactory.get_device(bts_name)
        bts.goto_state('FCT')
        list_containers_cmd = bts.get_cmd(cmd_name="lxc_ls")
        container_name = list_containers_cmd()["RESULT"][0][0]
        sed_cmd = bts.get_cmd(cmd_name='sed',
                              cmd_params={
                                  'options': '-i',
                                  'scripts': ['s/subnet-mask 255.255.255.252/subnet-mask 255.255.255.248/g'],
                                  'input_files': ['/tmp/node_{}/tmp/dhcpd.cfg'.format(container_name)]
                              })
        sed_cmd()
        lxc_attach_cmd_1 = bts.get_cmd(cmd_name='lxc_attach',
                                       cmd_params={
                                           'name': container_name,
                                           'options': '--set-var COLUMNS=250  -- killall -HUP dhcpd'
                                       })
        lxc_attach_cmd_2 = bts.get_cmd(cmd_name='lxc_attach',
                                       cmd_params={
                                           'name': container_name,
                                           'options': '--set-var COLUMNS=250 -- /usr/sbin/dhcpd -cf /tmp/dhcpd.cfg -lf'
                                                      ' /var/tmp/radio-dhcpd/dhcp.leases -user root -group root -pf'
                                                      ' /tmp/dhcpPidFile rlan0.cpri rlan0.ecpri'
                                       })
        lxc_attach_cmd_1()
        time.sleep(10)
        lxc_attach_cmd_2()
        time.sleep(10)


class RuOperations(GnbRu):

    @load_moler_configuration_from_tl()
    def clear_ip_tables(self, bts_id=0, du_id=0, ru_id=0):
        """
        Clears iptables on RU
        :param bts_id:    BTS id - related to Test Line configuration. Default: 0
        :param du_id:     DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
        :param ru_id:     RU id - related to Test line configuration - gnbs.dus.rus[]
        """
        ru = self.get_ru_device(bts_id, du_id, ru_id)
        ru.get_cmd(cmd_name='iptables', cmd_params={'options': '-Z'})()

    @load_moler_configuration_from_tl()
    def get_transfer_devices_ips(self, bts_id=0, du_id=0, ru_id=0, test_pc_interface=None):
        """
        Gets needed IP/MAC addresses needed for data transfer (from Test PC to RU via FH)
        :param bts_id:               BTS id - related to Test Line configuration. Default: 0
        :param du_id:                DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
        :param ru_id:                RU id - related to Test line configuration - gnbs.dus.rus[]
        :param test_pc_interface:    Interface of Front Haul communication with RU on Test PC side
        """
        res_dict = dict.fromkeys(['PC_MAC', 'RU_MAC', 'RU_IPV4'])
        ru = self.get_ru_device(bts_id, du_id, ru_id)
        ru.goto_state('PROXY_PC')
        ip_addr_pc = ru.get_cmd(cmd_name='ip_addr')()
        res_dict['PC_MAC'] = ip_addr_pc[test_pc_interface]['LINK'][0]['MAC']
        brd_ip = ip_addr_pc[test_pc_interface]['IPV4'][0]['BRD']
        ru.goto_state('RU')
        ip_addr_ru = ru.get_cmd(cmd_name='ip_addr')()
        for interface in ip_addr_ru:
            if 'BRD' in ip_addr_ru[interface]['IPV4'][0] and ip_addr_ru[interface]['IPV4'][0]['BRD'] == brd_ip:
                res_dict['RU_MAC'] = ip_addr_ru[interface]['LINK'][0]['MAC']
                res_dict['RU_IPV4'] = ip_addr_ru[interface]['IPV4'][0]['IP']
        return res_dict


class WsOperations(GenericBts):
    def __init__(self):
        super().__init__()
        self.openssl_connections = []

    @load_moler_configuration_from_tl()
    def clone_ws_moler_devices(self, clones_num, bts_id=0, du_id=0):
        ws_name = self.ws_du_alias.format(bts_id, du_id)
        cloned_moler_devices = []
        for i in range(int(clones_num)):
            cloned_moler_devices.append(DeviceFactory.get_cloned_device(ws_name, '{}_{}'.format(ws_name, i)))
        return cloned_moler_devices

    @load_moler_configuration_from_tl()
    def create_openssl_connection(self, ipv4, port, moler_device, additional_params=None):
        if additional_params:
            self.openssl_connections.append(moler_device.get_cmd(cmd_name='openssl_s_client',
                                                                 cmd_params={'options': '-connect {}:{} -{}'
                                                                             .format(ipv4, port, additional_params)}))
        else:
            self.openssl_connections.append(moler_device.get_cmd(cmd_name='openssl_s_client',
                                                                 cmd_params={'options': '-connect {}:{}'
                                                                             .format(ipv4, port)}))

    def start_openssl_connections(self):
        if self.openssl_connections:
            log_info_to_console('Starting all created openssl connections')
            for connection in self.openssl_connections:
                connection.start(timeout=100)
        else:
            raise ConnectionNotCreated('There is no created connections to be started')

    def stop_openssl_connections(self):
        if self.openssl_connections:
            log_info_to_console('Waiting 5 seconds for connections to be established')
            time.sleep(5)
            conn_res = []
            for connection in self.openssl_connections:
                connection.break_cmd()
                connection.await_done()
                conn_res.append(connection.result())
            self.openssl_connections.clear()
            log_info_to_console(msg='All openssl connections are interrupted')
            return conn_res
        else:
            raise ConnectionNotStarted('There is no started connections')

    def wait_for_openssl_connections_interruption(self):
        if self.openssl_connections:
            for connection in self.openssl_connections:
                connection.await_done()
            self.openssl_connections.clear()
            log_info_to_console(msg='All openssl connections are interrupted')
        else:
            raise ConnectionNotStarted('There is no started connections')

    def nmap_cipher_scan(self, port=None, ip=None, forbidden_cipher=None, required_cipher=None):
        nmap_res = self._get_nmap_cmd_result(port=port, ip=ip)
        _check_nmap_output(nmap_res['CIPHERS'], forbidden_cipher, required_cipher)
        log_info_to_console('Cipher scan for {}:{} passed'.format(ip, port))

    def nmap_tls_version_scan(self, port=None, ip=None, forbidden_tls=None, required_tls=None):
        nmap_res = self._get_nmap_cmd_result(port=port, ip=ip)
        _check_nmap_output(nmap_res['CRYPTO'], forbidden_tls, required_tls)
        log_info_to_console('TLS version scan for {}:{} passed'.format(ip, port))

    @load_moler_configuration_from_tl()
    def _get_nmap_cmd_result(self, port=None, ip=None, bts_id=0, du_id=0):
        ws_name = self.ws_du_alias.format(bts_id, du_id)
        ws = DeviceFactory.get_device(ws_name)
        nmap_cmd_res = ws.get_cmd(cmd_name="nmap",
                                  cmd_params={"options": "--script ssl-enum-ciphers -p {}".format(port),
                                              "ip": ip})()
        return nmap_cmd_res


def verify_openssl_output(ssl_result, required_cipher):
    if required_cipher in ssl_result['Cipher']:
        log_info_to_console('Required cipher {} was used in connection, as intended'.format(required_cipher))
    else:
        raise RequiredCipherNotUsed('Required cipher {} was not used in connection, not as intended'
                                    .format(required_cipher))


def _check_nmap_output(nmap_output, forbidden_string, required_string):
    if forbidden_string and any(forbidden_string in item for item in nmap_output):
        raise ForbiddenCipherSeen('{} cipher should not be seen'.format(forbidden_string))
    if required_string and not any(required_string in item for item in nmap_output):
        raise RequiredCipherNotSeen('{} cipher should be seen'.format(required_string))
