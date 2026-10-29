# -*- coding: utf-8 -*-

import re
import os
import six

from taf.gnb.oam.coam.admin import admin
from taf.ul.moler.converter import load_moler_configuration
from robot.libraries.BuiltIn import BuiltIn
from taf.rfrl.bts.connections import device_aliases as connection_names
from moler.exceptions import MolerException, CommandTimeout
from taf.rfrl.utilities.tl_config import load_moler_configuration_from_tl
from moler.device import DeviceFactory
from moler.util.moler_test import MolerTest
from moler.helpers import copy_list
from testsuite.Krakow.resources.firewall_scf import FirewallScf

from testsuite.Krakow.resources.scf import Scf

from testsuite.Krakow.resources.cu_webem.cu_webem_keywords import CuWebem
from testsuite.Krakow.resources.linux_accounts.system_account_permissions import admin_connect


class Firewall(object):

    def __init__(self):
        self._tl = BuiltIn().get_variable_value('${{{}}}'.format("tl"), None)

    def get_oam_ip(self):
        return self._tl.gnbs[0].cu.oam_ssh_connection_details.addr

    @MolerTest.raise_background_exceptions()
    @load_moler_configuration_from_tl()
    def firewall_syslog_streaming(self, bts_id=0, states=None, tcpdump_time=10):
        """
        Test 5GC001024_A_000_SyVe_Firewall_syslog_streaming
        :param bts_id: id of gNB
        :param states: states to check tcpdump. If None then default will be used: OAM, CPIF, UPUE
        :param tcpdump_time: time of execution of tcpdump (in seconds).
        :return: None
        """
        if states is None:
            states = ['OAM', 'CPIF', 'UPUE']
        bts_id = int(bts_id)
        tcpdump_params = r'-i any port 51000 and dst host 192.168.129.190 -n -c 1 --direction out'
        device_name = format(connection_names.ssh_gnb_cu.format(bts_id))
        device = DeviceFactory.get_device(name=device_name)
        for state in states:
            MolerTest.info("Checks in state: '{}'.".format(state))
            device.goto_state(state=state, rerun=3)
            cmd_tcpdump = device.get_cmd(cmd_name='tcpdump', cmd_params={'options': tcpdump_params})
            cmd_sudo = device.get_cmd(cmd_name='sudo', cmd_params={'cmd_object': cmd_tcpdump})
            cmd_sudo.start(timeout=2*tcpdump_time)
            MolerTest.sleep(seconds=tcpdump_time)
            cmd_sudo.break_cmd()
            ret = cmd_sudo.await_done(timeout=tcpdump_time)
            if 'packets captured' in ret:
                try:
                    packets_captured = int(ret['packets captured'])
                except ValueError as ve:
                    MolerTest.error("Value of 'packets captured' returned by command tcpdump is not a number: '{}'->"
                                    "'{}'".format(ve, repr(ve)), dump=ret)
                    continue
                if 0 == packets_captured:
                    MolerTest.info("Found '{}' packets in state '{}', as expected.".format(packets_captured, state))
                else:
                    MolerTest.error("Found '{}' packets in state '{}' but expected 0.".format(packets_captured, state))
            else:
                MolerTest.error("Cannot find 'packets captured' in data returned by tcpdump.", dump=ret)

    @MolerTest.raise_background_exceptions()
    @load_moler_configuration_from_tl()
    def no_aclrules_for_cu_vms_with_internal_ifs_only(self, bts_id=0):
        """
        Test 5GC001024_A_000_SyVe_no_aclrules_for_CU_VMs_with_internal_IFs_only
        :param bts_id: id of gNB
        :return: None
        """
        device_name = format(connection_names.ssh_gnb_cu.format(bts_id))
        self._check_no_aclrues_for_state(device_name=device_name, state='OAM', owner_find=re.compile(r"oam|cpif|upue"))

    @MolerTest.raise_background_exceptions()
    @load_moler_configuration_from_tl()
    def stateful_filtering_for_gnb_initiated_traffic(self, bts_id=0, state='OAM'):
        """
        Test 5GC001024_A_000_SyVe_UC01_stateful_filtering_for_gNB_initiated_traffic_allowed_ports_CU_OAM
        :param bts_id: id of gNB
        :param state: state to test for GNB_CU
        :return: None
        """
        device_name = format(connection_names.ssh_gnb_cu.format(bts_id))
        source = '/etc/profile'
        destination = '/tmp/test.tmp'
        ip_for_scp, user, password, base_state = self._get_ip_address_to_ping_from_vm(device_name=device_name,
                                                                                      state=state)
        if ip_for_scp is None:
            MolerTest.error("Cannot get IP from '{}' to ping to external.".format(state))
            return
        is_ipv6 = not self._is_ip_v4(ip=ip_for_scp)
        self._clear_iptables(device_name=device_name, ipv6=is_ipv6)
        self._send_file_from_vm_to_external_ip(device_name=device_name, state=state, external_ip=ip_for_scp, user=user,
                                               password=password, source=source, destination=destination)
        self._check_iptables(device_name=device_name, state=state, ipv6=is_ipv6)
        self._rm_file_in_state(device_name=device_name, state=base_state, path=destination)

    @MolerTest.raise_background_exceptions()
    @load_moler_configuration_from_tl()
    def compare_aclrules(self, bts_id=0, state='OAM'):
        """
        Test 5GC001024_A_000_SyVe_parse_aclrule_list_for_CU_OAM
        :param bts_id: id of gNB
        :param state: state to test for GNB_CU
        :return: None
        """
        bts_id = int(bts_id)
        mplane = self. _get_mplane_ip(bts_id=bts_id)
        ip_id = "IPv4" if self._is_ip_v4(ip=mplane) else 'IPv6'
        device_name = format(connection_names.ssh_gnb_cu.format(bts_id))
        bts_prefix = self._tl.test_pc.default_ssh_connection_details.addr
        path = "{}{}{}{}aclrules_{}_{}_{}.csv".format(os.path.dirname(os.path.abspath(__file__)), os.sep, "csv",
                                                      os.sep, bts_prefix, state, ip_id)
        old_data = None
        MolerTest.info("Execute commands to know aclrules:")
        skip_action = True
        current_data = self._aclrule_owner(device_name=device_name, state=state, skip_action=skip_action,
                                           with_owner=True)
        try:
            MolerTest.info("Try to load data from file: {}.".format(path))
            old_data = self._load_shownetworkingaclrule_from_csv(path=path, skip_action=True)
            MolerTest.info("Data is loaded")
        except (IOError, OSError):
            MolerTest.warning("Cannot load csv from {}. Data will be saved and not compared.".format(path))
        if old_data is None:
            self._save_shownetworkingaclrule_to_csv(ret=current_data, path=path)
        else:
            MolerTest.info("Check consistency current data against data loaded form file: '{}'.".format(path))
            self._check_consistency(current_ret=current_data, base_ret=old_data, mplane=mplane)

    @MolerTest.raise_background_exceptions()
    @load_moler_configuration_from_tl()
    def firewall_iwf_classifier(self, bts_id=0, state='UPUE'):
        """
        5GC001024_A_000_SyVe_firewall_iwf_classifier_CU_UPUE
        :param bts_id: id of gNB
        :param state: state to test for GNB_CU
        :return: None
        """
        bts_id = int(bts_id)
        device_name = format(connection_names.ssh_gnb_cu.format(bts_id))
        self._check_policies(device_name=device_name, state=state)

    @MolerTest.raise_background_exceptions()
    @load_moler_configuration_from_tl()
    def firewall_ntp(self, bts_id=0, du_id=0, default_ntp_servers=None, fake_ip='10.83.244.244'):
        """
        5GC001024_A_000_SyVe_Firewall_rule_for_NTP

        :param bts_id: id of gNB
        :param du_id: id of DU
        :param default_ntp_servers: List of NTP servers to use if the list is empty in SCF on gNB.
        :param fake_ip: IP of fake NTP server.
        :return: None
        """
        bts_id = int(bts_id)
        du_id = int(du_id)
        device_name = format(connection_names.ssh_gnb_cu.format(bts_id))
        mplane = self. _get_mplane_ip(bts_id=bts_id)
        ipv6 = not self._is_ip_v4(ip=mplane)
        local_dir_path = "/home/ute/"
        file_name = "firewall_scf.xml"
        local_path = "{}{}".format(local_dir_path, file_name)
        if default_ntp_servers is None:
            default_ntp_servers = ['10.83.200.2', '10.83.200.3', '10.83.200.4']
        scf = FirewallScf()

        MolerTest.info("Get current SCF form CU.")
        scf.get_current_scf_from_site(local_dir_path=local_dir_path, file_name=file_name,
                                      timeout=180, bts_id=bts_id, du_id=du_id)
        org_local_path = scf.make_bak(path=local_path, suffix="_src")
        MolerTest.info("Original scf fie location: '{}'. Work on: '{}'".format(org_local_path, local_path))
        ntp_read_data = self._find_ntp_servers_begin(local_path=local_path, scf=scf,
                                                     default_ntp_servers=default_ntp_servers)
        if not ntp_read_data:
            MolerTest.error("Cannot find any NTP server. Restore original scf.")
            scf.use_scf_on_gnb(local_path=org_local_path)
            return
        servers_list_from_scf = self._check_ntp_servers_iptables_and_aclrules(
            device_name=device_name, ntp_read_data=ntp_read_data, mplane=mplane, ipv6=ipv6)

        MolerTest.info("Check rules with NTP servers wth fake IP.")
        self._add_fake_ntp_server(servers_list_from_scf=servers_list_from_scf, fake_ip=fake_ip, scf=scf,
                                  ntp_read_data=ntp_read_data, local_path=local_path)

        MolerTest.info("Check rules after change NTP servers.")
        self._check_ntp_servers_iptables_and_aclrules(
            device_name=device_name, ntp_read_data=ntp_read_data, mplane=mplane, ipv6=ipv6)

        MolerTest.info("Restore original scf")
        scf.use_scf_on_gnb(local_path=org_local_path)

    @MolerTest.raise_background_exceptions()
    @load_moler_configuration_from_tl()
    def firewall_dns(self, bts_id=0, du_id=0, default_dns_servers=None, fake_ip='10.83.244.244'):
        """
        5GC001024_A_000_SyVe_Firewall_rule_for_DNS
        :param bts_id: id of gNB
        :param du_id: id of DU
        :param default_dns_servers: List of DNS servers to use if the list is empty in SCF on gNB.
        :param fake_ip: ip address of not existed DNS server.
        :return: None
        """
        bts_id = int(bts_id)
        du_id = int(du_id)
        device_name = format(connection_names.ssh_gnb_cu.format(bts_id))
        mplane = self. _get_mplane_ip(bts_id=bts_id)
        ipv6 = not self._is_ip_v4(ip=mplane)
        local_dir_path = "/home/ute/"
        file_name = "firewall_scf.xml"
        local_path = "{}{}".format(local_dir_path, file_name)
        scf = FirewallScf()

        MolerTest.info("Get current SCF form CU.")
        scf.get_current_scf_from_site(local_dir_path=local_dir_path, file_name=file_name,
                                      timeout=180, bts_id=bts_id, du_id=du_id)
        org_local_path = scf.make_bak(path=local_path, suffix="_src")
        MolerTest.info("Original scf fie location: '{}'. Work on: '{}'".format(org_local_path, local_path))
        dns_read_data = self._find_dns_servers_begin(local_path=local_path, scf=scf,
                                                     default_dns_servers=default_dns_servers)
        if not dns_read_data:
            MolerTest.error("Cannot find any DNS server. Restore original scf.")
            scf.use_scf_on_gnb(local_path=org_local_path)
            return
        servers_list_from_scf = self._check_dns_servers_iptables_and_aclrules(
            device_name=device_name, dns_read_data=dns_read_data, mplane=mplane, ipv6=ipv6)

        MolerTest.info("Check rules with default DNS servers.")
        self._add_fake_dns_server(servers_list_from_scf=servers_list_from_scf, fake_ip=fake_ip, scf=scf,
                                  dns_read_data=dns_read_data, local_path=local_path)

        MolerTest.info("Check rules after change DNS servers.")
        self._check_dns_servers_iptables_and_aclrules(
            device_name=device_name, dns_read_data=dns_read_data, mplane=mplane, ipv6=ipv6)

        MolerTest.info("Restore original scf")
        scf.use_scf_on_gnb(local_path=org_local_path)

    def _check_policies(self, device_name, state):
        ip_front = self._get_ip_for_haul(device_name=device_name, state=state, haul_name='fronthaul')
        ip_back = self._get_ip_for_haul(device_name=device_name, state=state, haul_name='backhaul')
        device = DeviceFactory.get_device(name=device_name)
        device.goto_state(rerun=3, state=state)
        cmd_trs_cli = device.get_cmd(cmd_name='trs_cli', cmd_params={'options': r'-c "classifier show policy"'})
        ret = cmd_trs_cli()
        # id_front = id_back = None
        ids_front = list()
        ids_back = list()
        policy_type = 'POLICY-TYPE'
        for id in ret.keys():
            if policy_type in ret[id]:
                if 'fronthaul' == ret[id][policy_type]:
                    ids_front.append(id)
                elif 'backhaul' == ret[id][policy_type]:
                    ids_back.append(id)
        if not ids_front or not ids_back:
            MolerTest.error("Cannot find id for front haul ('{}') and/or back haul ('{}') in output: {}".format(
                ids_front, ids_back, ret))
            return
        self._check_haul_dport(ret=ret, haul_ids=ids_front, haul_name='Front')
        self._check_haul_dport(ret=ret, haul_ids=ids_back, haul_name='Back')
        self._check_haul_sport(ret=ret, haul_ids=ids_front, haul_name='Front')
        self._check_haul_sport(ret=ret, haul_ids=ids_back, haul_name='Back')
        self._check_haul_address(ret=ret, haul_ids=ids_front, haul_name='Front', haul_expeced_ip=ip_front)
        self._check_haul_address(ret=ret, haul_ids=ids_back, haul_name='Back', haul_expeced_ip=ip_back)

    def _check_haul_sport(self, ret, haul_ids, haul_name):
        expected_range = 65535
        for haul_id in haul_ids:
            minimum = int(ret[haul_id]['MIN-SPORT'])
            maximum = int(ret[haul_id]['MAX-SPORT'])
            current_range = maximum - minimum
            if expected_range == current_range:
                MolerTest.info("{} haul. Range for SPORT is as expected: {}. Min: {}. Max: {}".format(
                    haul_name, current_range, minimum, maximum))
            else:
                MolerTest.error("{} haul. Range for SPORT  ({}) is NOT as expected: {}. Min: {}. Max: {}".format(
                    haul_name, current_range, expected_range, minimum, maximum))

    def _check_haul_address(self, ret, haul_ids, haul_name, haul_expeced_ip):
        found = False
        for haul_id in haul_ids:
            if (ret[haul_id]['MIN-DST-IP'] == ret[haul_id]['MAX-DST-IP']) \
                    and (haul_expeced_ip == ret[haul_id]['MIN-DST-IP'])\
                    and (haul_expeced_ip == ret[haul_id]['MIN-DST-IP']):
                MolerTest.info("{} haul. Values for MIN-DST-IP ('{}') and MAX-DST-IP ('{}') are as expected.".format(
                    haul_name, ret[haul_id]['MIN-DST-IP'], ret[haul_id]['MAX-DST-IP']))
                found = True
                break
        if not found:
            min_dst_ips = list()
            max_dst_ips = list()
            for haul_id in haul_ids:
                min_dst_ips.append(ret[haul_id]['MIN-DST-IP'])
                max_dst_ips.append(ret[haul_id]['MAX-DST-IP'])
            MolerTest.error("{} haul. Values for MIN-DST-IP ('{}') and/or MAX-DST-IP ('{}') are NOT as"
                            " expected '{}'.".format(haul_name, min_dst_ips, max_dst_ips, haul_expeced_ip))
        min_exp_src_ip = '::'
        max_exp_src_ip = 'ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff'
        if self._is_ip_v4(ip=haul_expeced_ip):
            min_exp_src_ip = '0.0.0.0'
            max_exp_src_ip = '255.255.255.255'
        for haul_id in haul_ids:
            if ret[haul_id]['MIN-SRC-IP'] == min_exp_src_ip and max_exp_src_ip == ret[haul_id]['MAX-SRC-IP']:
                MolerTest.info("{} haul. Values for MIN-SRC-IP ('{}') and MAX-SRC-IP ('{}') are as expected.".format(
                    haul_name, ret[haul_id]['MIN-SRC-IP'], ret[haul_id]['MAX-SRC-IP']
                ))
            else:
                MolerTest.error("{} haul. Values for MIN-SRC-IP ('{}') and/or MAX-SRC-IP ('{}') are NOT as expected:"
                                " '{}' and '{}'.".format(haul_name, ret[haul_id]['MIN-SRC-IP'],
                                                         ret[haul_id]['MAX-SRC-IP'],
                                                         min_exp_src_ip, max_exp_src_ip))

    def _check_haul_dport(self, ret, haul_ids, haul_name):
        expected = '2152'
        for haul_id in haul_ids:
            if (ret[haul_id]['MIN-DPORT'] == ret[haul_id]['MAX-DPORT']) and (expected == ret[haul_id]['MIN-DPORT']):
                MolerTest.info("{} haul. Values for MIN-DPORT ('{}') and MAX_DPORT ('{}') are as expected.".format(
                    haul_name, ret[haul_id]['MIN-DPORT'], ret[haul_id]['MAX-DPORT']))
            else:
                MolerTest.error("{} haul. Values for MIN-DPORT ('{}') and/or MAX_DPORT ('{}') are NOT as"
                                " expected '{}'.".format(haul_name, ret[haul_id]['MIN-DPORT'],
                                                         ret[haul_id]['MAX-DPORT'], expected))

    def _get_ip_for_haul(self, device_name, state, haul_name):
        device = DeviceFactory.get_device(name=device_name)
        device.goto_state(state=state, rerun=3)
        cmd_ipa = device.get_cmd(cmd_name='ip_addr', cmd_params={'options': 'show {}'.format(haul_name)})
        ret = cmd_ipa()
        ip_dict = ret[haul_name]
        if 'IPV4' in ip_dict and 'IP' in ip_dict['IPV4'][0]:
            ip_ret = ip_dict['IPV4'][0]['IP']
        else:
            ip_ret = ip_dict['IPV6'][0]['IP']
        return ip_ret

    @MolerTest.raise_background_exceptions()
    @load_moler_configuration_from_tl()
    def check_connection_with_interface_when_icmpResponseEnabled_is_set_on_flag(self, interface_name, flag, bts_id=0):
        """
        5GC001024_A_000_SyVe_UC04_icmpResponseEnabled_flag_CU_OAM
        :param interface_name: name of interface to check connection e.g. OAM, X2, BACKHAUL
        :param flag: icmpResponseEnabled value
        :param bts_id: id of gNB
        :return: None
        """
        flag = True if flag.upper() == u"TRUE" else False
        self._set_device_name(bts_id)
        device = self._get_device()

        MolerTest.info("Get ip to test")
        ip_to_check = self._get_interface_ip(device, interface_name)
        MolerTest.info("IP", ip_to_check)

        self._set_device_name(bts_id)
        device = self._get_device()
        device.goto_state(state="UNIX_LOCAL")

        MolerTest.info("Test ping")
        self._test_ping(device, ip_to_check, 2, flag)
        MolerTest.info("Test traceroute")
        self._test_traceroute(device, ip_to_check, flag)

    def _get_interface_ip(self, device, interface_name):
        interface_name = str(interface_name).upper()

        if interface_name == "BACKHAUL":
            ip_to_check = self._get_ip_for_haul(device_name=device.name, state="UPUE", haul_name='backhaul')
        elif interface_name == "X2":
            ip_to_check = self._get_ip_for_haul(device_name=device.name, state="CPIF", haul_name='x2')
        elif interface_name == "OAM":
            ip_to_check = self.get_oam_ip()
        else:
            MolerTest.error("interface name {} is not handle".format(interface_name))
        MolerTest.info(ip_to_check)
        return ip_to_check

    def get_icmpResponseEnabled_flag_state(self):
        """
        :return: icmpResponseEnabled flag state (true or false)
        """
        cuWebem = CuWebem()
        state = cuWebem.get_icmpResponseEnabled_flag_state()
        return state

    def switch_flag(self, flag):
        """
        :param flag: icmpResponseEnabled value
        :return: swiched flag
        """
        flag = "false" if flag.upper() == u"TRUE" else "true"
        return flag

    def create_scf_to_edit(self, local_dir_path, file_name):
        """
        :param local_dir_path: path to dir with scf
        :param file_name: name of scf file
        :return: None
        """
        fwScf = FirewallScf()
        fwScf.get_current_scf_from_site(local_dir_path, file_name)

    def change_icmpResponseEnabled_value_in_scf(self, scf_file_path, dist_name, value):
        """
        :param scf_file_path: path to scf file
        :param dist_name: path in WebEM to the particular parameter  e.g. MRBTS-392/TNLSVC-1/TNL-1/IPNO-1
        :param value: icmpResponseEnabled value, true or false
        :return: None
        """
        cu_id = self._tl.gnbs[0].cu.instance_id
        dist_name = dist_name.format(cu_id)
        scf = Scf()
        scf.change_icmpResponseEnabled_value(scf_file_path, dist_name, value)

    def _test_ping(self, device, destination_ip, packets_number, flag):
        cmd_ping = device.get_cmd(cmd_name='ping', cmd_params={'destination': destination_ip,
                                                               'options': '-c' + packets_number.__str__()})
        ping_ret = cmd_ping()
        self._check_ping(ping_ret, packets_number, flag)

    def _test_traceroute(self, device, destination_ip, flag):
        traceroute_cmd = device.get_cmd(cmd_name='traceroute', cmd_params={'destination': destination_ip})
        try:
            traceroute_ret = traceroute_cmd()
            MolerTest.info("traceroute ret:", dump=traceroute_ret)
        except Exception:
            if flag is False:
                return
            else:
                MolerTest.error("Cannot use traceroute to '{}'.".format(self.destination_ip), raise_exception=True)

        self._check_traceroute(traceroute_ret, destination_ip)

    def _get_device(self):
        device = DeviceFactory.get_device(self.device_name)

        if not device:
            MolerTest.error("Cannot find device with name '{}'.".format(self.device_name), raise_exception=True)

        return device

    def _set_device_name(self, bts_id):
        self.device_name = format(connection_names.ssh_gnb_cu.format(bts_id))

    @admin_connect
    def _get_current_flag_state(self, parameter_abbreviation):
        """
        get up current state of parameter parameter_abbreviation on DU by WebEm

       :return: value of parameter
       """

        bts_configuration = self.admin.get_scf(export_type="configurationAndRuntimeObjects")
        value = str(bts_configuration).partition('<p name="{}">'.format(parameter_abbreviation))[2].partition('</p>')[
            0]
        MolerTest.info(value)

        return value

    def _check_traceroute(self, traceroute_ret, destination_ip):
        row = traceroute_ret['hops'][-1]

        if row["address"] != destination_ip:
            MolerTest.error("Expected address {} got {}".format(destination_ip, row["address"]), raise_exception=True)

        ttl_time_values = [row[key] for key in row if re.findall('ttl.$', key)]
        for time in ttl_time_values:
            if time > 1:
                MolerTest.error("Expected shorter ttl time. Expect < 1 got {} ".format(time))

    def _check_ping(self, ping_ret, packets_number, icmpResponseEnabledvalue):

        if icmpResponseEnabledvalue is False:
            packets_number = 0

        if ping_ret["packets_received"] != packets_number:
            MolerTest.error("Expected '{}' packets, got {}.".format(packets_number, ping_ret["packets_received"]),
                            raise_exception=True)
        elif ping_ret["time_seconds"] > 2:
            MolerTest.error("Expected ping time < 2 got {}".format(ping_ret["time_seconds"]), raise_exception=True)

    def _check_iptables(self, device_name, state, regex_to_find=re.compile("RELATED"), ipv6=False):
        """
        Check if output of iptables contain given regex.
        :param device_name: Name of device to test
        :param state: State of devie to test.
        :return: None
        """
        device = DeviceFactory.get_device(name=device_name)
        device.goto_state(rerun=3, state=state)
        cmd_iptables = device.get_cmd(cmd_name='iptables', cmd_params={'options': '-L INPUT -nvx -t mangle',
                                                                       'v6': ipv6})
        cmd_sudo = device.get_cmd(cmd_name='sudo', cmd_params={'cmd_object': cmd_iptables})
        prev_item = None
        iptables_ret = cmd_sudo(timeout=40)
        for key in iptables_ret:
            for key2 in iptables_ret[key]:
                for item in iptables_ret[key][key2]:
                    if 'REST' in item:
                        value = item['REST']
                        m = re.search(regex_to_find, value)
                        if m:
                            try:
                                if 'PKTS' in item:
                                    pkts = int(item['PKTS'])
                                else:
                                    pkts = int(prev_item['PKTS'])  # For backward compatibility.
                                if pkts > 0:
                                    MolerTest.info("Found {} packets".format(pkts))
                                else:
                                    MolerTest.error("Found {} packets, expected greater than 0.".format(pkts))
                                return
                            except Exception as ex:
                                MolerTest.error(
                                    "Cannot get info about number of packets. Exception: >>{}<< >>{}<<,"
                                    " item={}, prev_item={}, ret={}".format(
                                        ex, repr(ex), item, prev_item, iptables_ret
                                    )
                                )
                    prev_item = item
        MolerTest.error("Cannot find '{}' in iptables output '{}'.".format(regex_to_find, iptables_ret))

    def _check_iptables_firewall(self, device_name, state, regex_to_find=re.compile("RELATED"), ipv6=False):
        """
        Check if output of iptables contain given regex.
        :param device_name: Name of device to test
        :param state: State of devie to test.
        :return: None
        """
        device = DeviceFactory.get_device(name=device_name)
        device.goto_state(rerun=3, state=state)
        cmd_iptables = device.get_cmd(cmd_name='iptables', cmd_params={'options': '-L INPUT -t mangle -n',
                                                                       'v6': ipv6})
        cmd_sudo = device.get_cmd(cmd_name='sudo', cmd_params={'cmd_object': cmd_iptables})
        prev_item = None
        iptables_ret = cmd_sudo(timeout=40)
        for key in iptables_ret:
            for key2 in iptables_ret[key]:
                for item in iptables_ret[key][key2]:
                    if 'REST' in item:
                        value = item['REST']
                        m = re.search(regex_to_find, value)
                        if m:
                            try:
                                if 'PKTS' in item:
                                    pkts = int(item['PKTS'])
                                else:
                                    pkts = int(prev_item['PKTS'])  # For backward compatibility.
                                if pkts > 0:
                                    MolerTest.info("Found {} packets".format(pkts))
                                else:
                                    MolerTest.error("Found {} packets, expected greater than 0.".format(pkts))
                                return
                            except Exception as ex:
                                MolerTest.error(
                                    "Cannot get info about number of packets. Exception: >>{}<< >>{}<<,"
                                    " item={}, prev_item={}, ret={}".format(
                                        ex, repr(ex), item, prev_item, iptables_ret
                                    )
                                )
                    prev_item = item
        MolerTest.error("Cannot find '{}' in iptables output.".format(repr(regex_to_find)))

    def _send_file_from_vm_to_external_ip(self, device_name, state, external_ip, user, password,
                                          source='/etc/profile', destination='/tmp/test.tmp'):
        """
        Send file by scp from vm to external IP. Scp may fail.
        :param device_name: Name of device to test
        :param state: state to execute command scp.
        :param external_ip: address of server to scp file.
        :param user: user.
        :param password: password.
        :param source: path to source file.
        :param destination: path to destination file.
        :return: None
        """
        dev = DeviceFactory.get_device(name=device_name)
        dev.goto_state(rerun=3, state=state)
        options = '-F /dev/null'
        if not self._is_ip_v4(ip=external_ip):
            options = '-6 {}'.format(options)
            external_ip = '[{}]'.format(external_ip)
        destination_with_address = "{}@{}:{}".format(user, external_ip, destination)
        MolerTest.info("scp in state {} from {} to {}.".format(state, source, destination_with_address))
        cmd_scp = dev.get_cmd(cmd_name="scp", cmd_params={'source': source, 'dest': destination_with_address,
                                                          'password': password,
                                                          'options': options}
                              )
        try:
            cmd_scp()
        except MolerException as ex:
            MolerTest.info("Transfer was not finished but it may suffice for check TCP transfer: '{}'.".format(ex))

    @load_moler_configuration_from_tl()
    def _get_ip_address_to_ping_from_vm(self, device_name, state):
        """
        Get ip address and credentials for scp.
        :param device_name: Name of device.
        :param state: State of device to execute command.
        :return: ip, user, password
        """
        return_ip = None
        user = self._tl.test_pc.default_ssh_connection_details.username
        password = self._tl.test_pc.default_ssh_connection_details.password
        dev = DeviceFactory.get_device(name=device_name)
        state_local = 'UNIX_LOCAL'
        try:
            configurations = dev.get_configurations(source_state='UNIX_LOCAL', dest_state='PROXY_PC')
            dev.goto_state(rerun=3, state="PROXY_PC", log_stacktrace_on_fail=False)
            user = configurations['command_params']['login']
            password = configurations['command_params']['password']
            state_local = 'PROXY_PC'
        except KeyError:
            dev.goto_state(rerun=3, state="UNIX_LOCAL")
        ip_addr = dev.get_cmd(cmd_name='ip_addr', cmd_params={'options': 'show'})
        ip_ret = ip_addr()
        MolerTest.info("ip_addr ret", dump=ip_ret)
        dev.goto_state(rerun=3, state=state)
        ip_keys = ['IPV4', 'IPV6']
        for interface in ip_ret:
            if interface == 'lo':
                continue
            MolerTest.info("Processing interface {}".format(interface))
            for ip_key in ip_keys:
                try:
                    ip = ip_ret[interface][ip_key][0]['IP']
                    if ip == '127.0.0.1' or ip == '::1':
                        continue
                    cmd_ping = dev.get_cmd(cmd_name='ping', cmd_params={'destination': ip, 'options': '-c 2'})
                    try:
                        ret = cmd_ping()
                        if ret['packets_received'] > 0:
                            return_ip = ip
                            break
                    except MolerException:
                        pass
                except KeyError:
                    pass
        MolerTest.info("Found IP: '{}'".format(return_ip))
        return return_ip, user, password, state_local

    def _clear_iptables(self, device_name='GNB0_CU', ipv6=False):
        """
        Clear iptables counters.
        :param device_name: Name of device.
        :return: None
        """
        self._iptables_clear_counters(device_name=device_name, state='OAM', ipv6=ipv6)
        self._iptables_clear_counters(device_name=device_name, state='CPIF', ipv6=ipv6)
        self._iptables_clear_counters(device_name=device_name, state='UPUE', ipv6=ipv6)

    @load_moler_configuration_from_tl()
    def _check_no_aclrues_for_state(self, device_name='GNB0_CU', state='OAM', owner_find=re.compile('oam')):
        """
        Check if no aclrules in output of show networking aclrule.
        :param device_name: Name of device.
        :param state: State to execute command.
        :param owner_find: regex to find.
        :return: None
        """
        device = DeviceFactory.get_device(name=device_name)
        if not device:
            MolerTest.error("Cannot find device with name '{}'.".format(device_name), raise_exception=True)
        device.goto_state(rerun=3, state=state)
        cmd_fsclish = device.get_cmd(
            cmd_name='fsclish',
            cmd_params={
                'cmd_class_name': 'ta_moler.cmd.shared.fsclish.show_networking_aclrule.ShowNetworkingAclrule',
            }
        )
        cmd_sudo = device.get_cmd(cmd_name='sudo', cmd_params={'cmd_object': cmd_fsclish})
        ret = cmd_sudo()
        found = 0
        for index in ret.keys():
            if 'owner' in ret[index]:
                owner = ret[index]['owner']
                if re.search(owner_find, owner):
                    found += 1
                else:
                    MolerTest.error("Cannot find '{}' in '{}' for index '{}'.".format(owner_find, owner, index))
            else:
                MolerTest.error("Cannot find owner for index: '{}'.".format(index))
        if 0 == found:
            MolerTest.error("Cannot find any '{}' in owner.".format(owner_find))
        else:
            MolerTest.info("Found '{}' {} time(s) in owner field.".format(owner_find, found))

    def _iptables_clear_counters(self, device_name, state, ipv6):
        """
        Clear counter from iptables.
        :param device_name: Name of device.
        :param state: State to clear iptables.
        :return: None
        """
        device = DeviceFactory.get_device(name=device_name)
        device.goto_state(rerun=3, state=state)
        if not device:
            MolerTest.error("Cannot find device with name '{}'.".format(device_name), raise_exception=True)
        device.goto_state(rerun=3, state=state)
        cmd_iptables = device.get_cmd(cmd_name='iptables', cmd_params={'options': '-Z -t mangle', 'v6': ipv6})
        cmd_sudo = device.get_cmd(cmd_name='sudo', cmd_params={'cmd_object': cmd_iptables})
        cmd_sudo()

    def _rm_file_in_state(self, device_name, state, path):
        device = DeviceFactory.get_device(name=device_name)
        device.goto_state(rerun=3, state=state)
        cmd_rm = device.get_cmd(cmd_name='rm', cmd_params={'options': '-rf', 'file': path})
        try:
            cmd_rm()
            MolerTest.info("Removed file '{}'.".format(path))
        except MolerException:
            MolerTest.log("Cannot rm file: '{}'. It may happen.".format(path))

    def _get_hostname(self, device_name, state):
        device = DeviceFactory.get_device(name=device_name)
        device.goto_state(rerun=3, state=state)
        cmd_hostname = device.get_cmd(cmd_name='hostname')
        ret = cmd_hostname()
        return ret['hostname']

    def _aclrule_owner(self, device_name, state, skip_action, with_owner=True):
        hostname = self._get_hostname(device_name=device_name, state=state)
        device = DeviceFactory.get_device(name=device_name)
        device.goto_state(rerun=3, state='OAM')
        cmd_sna_params = dict()
        if with_owner:
            cmd_sna_params = {'options': 'owner {}'.format(hostname)}
        cmd_fsclish = device.get_cmd(
            cmd_name='fsclish',
            cmd_params={
                'cmd_class_name': 'ta_moler.cmd.shared.fsclish.show_networking_aclrule.ShowNetworkingAclrule',
                'cmd_params': cmd_sna_params
            }
        )
        cmd_sudo = device.get_cmd(cmd_name='sudo', cmd_params={'cmd_object': cmd_fsclish})
        ret = cmd_sudo()
        if skip_action:
            ret = self._remove_aclrule_owner(aclrules=ret)
        return ret

    def _remove_aclrule_owner(self, aclrules):
        keys_list = copy_list(src=aclrules.keys())
        aclrules2remove = ('13000', '13001')
        for item_key in keys_list:
            if ('action' in aclrules[item_key] and 'dscp-mark' == aclrules[item_key]['action']) or (
                    'source port' in aclrules[item_key] and '53' == aclrules[item_key]['source port']) or (
                    'source port' in aclrules[item_key] and '123' == aclrules[item_key]['source port']
            ):
                del aclrules[item_key]
            elif item_key in aclrules2remove:
                del aclrules[item_key]
        return aclrules

    def _save_shownetworkingaclrule_to_csv(self, ret, path):
        MolerTest.info("_save_shownetworkingaclrule_to_csv ret: {}".format(ret))
        with open(path, "w") as f:
            MolerTest.info("File is open")
            for item_key in sorted(ret.keys()):
                for key in sorted(ret[item_key].keys()):
                    value = ret[item_key][key]
                    line = "{};{};{}{}".format(item_key, key, value, os.linesep)
                    f.write(line)

    def _load_shownetworkingaclrule_from_csv(self, path, skip_action):
        ret = dict()
        value_nr = 0
        with open(path) as f:
            for line in f:
                re_line_csv = re.compile(r"(?P<ITEM_KEY>\S+|\S.*\S);(?P<KEY>\S+|\S.*\S);(?P<VALUE>\S+|\S.*\S)")
                m = re.search(re_line_csv, line)
                if m:
                    item_key = m.group("ITEM_KEY")
                    key = m.group("KEY")
                    value = m.group("VALUE")
                    if item_key not in ret:
                        ret[item_key] = dict()
                    ret[item_key][key] = value
                    value_nr += 1
                else:
                    MolerTest.warning("Cannot decode line: '{}'".format(line))
        if skip_action:
            ret = self._remove_aclrule_owner(aclrules=ret)
        if value_nr < 100:
            MolerTest.error("Loaded only {} values from file. Check file: '{}'.".format(value_nr, path))
        else:
            MolerTest.info("Loaded {} values from '{}'".format(value_nr, path))
        return ret

    def _check_consistency(self, current_ret, base_ret, mplane):
        was_error = False
        to_skip = self._aclrule_to_skip()
        indexes_to_skip = self._aclrule_index_to_skip()
        mplane_indexes = self._alcrule_mplane_indexes()
        for item_key in sorted(current_ret.keys()):
            if item_key in indexes_to_skip:
                continue
            if item_key not in base_ret.keys():
                was_error = True
                MolerTest.error("Item key '{}' found in current output but not found in base output.".format(
                    item_key))
        for item_key in sorted(base_ret.keys()):
            if item_key in indexes_to_skip:
                continue
            if item_key not in sorted(current_ret.keys()):
                was_error = True
                MolerTest.error("Item key '{}' found in baseline output but not found in current output.".format(
                    item_key))
            else:
                if item_key in mplane_indexes:
                    self._check_aclrule_for_mplane(current_ret=current_ret, index_key=item_key, mplane=mplane)
                for key in sorted(base_ret[item_key].keys()):
                    if key in to_skip:
                        continue
                    if key not in current_ret[item_key]:
                        was_error = True
                        MolerTest.error("Key '{}' for item '{}' found in baseline output but not found"
                                        " in current output.".format(key, item_key))
                    else:
                        current_value = current_ret[item_key][key]
                        base_value = current_ret[item_key][key]
                        if current_value != base_value:
                            was_error = True
                            MolerTest.error("Item: '{}', key: '{}' current value: '{}' but base value '{}'.".format(
                                item_key, key, current_value, base_value
                            ))
        if was_error is False:
            MolerTest.info("All checks passed.")

    def _check_aclrule_for_mplane(self, current_ret, index_key, mplane):
        item = current_ret[index_key]
        key = 'dest addr'
        if key in item:
            current_mplane_with_mask = item[key]
            current_mplane = current_mplane_with_mask
            m = re.search(r"(?P<ADDRESS>[\d.:]+)/\d+", current_mplane_with_mask)
            if m:
                current_mplane = m.group("ADDRESS")
            if current_mplane != mplane:
                MolerTest.error("Current mplane address ('{}') is different than expected: '{}',"
                                " at index {}:{}.".format(current_mplane, mplane, index_key, item)
                                )
        else:
            MolerTest.error("Cannot find field 'dest addr' (expected address of mplame) in alrule for index:"
                            " {}: {}".format(index_key, current_ret[index_key]))

    def _aclrule_to_skip(self):
        return ['owner', 'source addr', 'dest addr', 'addr-family', 'value', 'VRF name(ID)', 'hashlimit', 'mode',
                'ipset-flag']

    def _aclrule_index_to_skip(self):
        return ['11081', '12757', '12758', '12759', '12760', '12761', '12762']

    def _alcrule_mplane_indexes(self):
        return ['11081', '11082', '11083', '11084', '11085', '11086', '11087', '11088', '20101', '20102']

    def _is_ip_v4(self, ip):
        m = re.match(r"\d+\.\d+\.\d+\.\d+", ip)
        if not m:
            return False
        return True

    def _add_fake_ntp_server(self, servers_list_from_scf, fake_ip, scf, ntp_read_data, local_path):
        MolerTest.info("Add fake IP addr to ntpServerIpAddrList")
        # 5. using delta file, add fake IP addr to ntpServerIpAddrList (10.83.244.244)
        keys = ntp_read_data.keys()
        dist_name = None
        for item in keys:
            dist_name = item
            break
        if len(servers_list_from_scf) > 3:
            servers_list_from_scf[3] = fake_ip
        else:
            servers_list_from_scf.append(fake_ip)
        ntp_read_data[dist_name] = servers_list_from_scf
        lines = scf.replace_ntp_servers(path=local_path, servers=ntp_read_data)
        scf.save_file(path=local_path, lines=lines)
        scf.use_scf_on_gnb(local_path=local_path)

    def _add_fake_dns_server(self, servers_list_from_scf, fake_ip, scf, dns_read_data, local_path):
        MolerTest.info("change serverIpAddressPrimary to fake IP (10.83.244.244)")
        keys = dns_read_data.keys()
        dist_name = None
        for item in keys:
            dist_name = item
            break
        servers_list_from_scf[0] = fake_ip
        dns_read_data[dist_name] = servers_list_from_scf
        lines = scf.replace_dns_servers(path=local_path, servers=dns_read_data)
        scf.save_file(path=local_path, lines=lines)
        scf.use_scf_on_gnb(local_path=local_path)

    def _check_ntp_servers_iptables_and_aclrules(self, device_name, ntp_read_data, mplane, ipv6):
        MolerTest.info("#2. on oam VM list all acl rules:")
        aclrule_ret = self._aclrule_owner(device_name=device_name, state='OAM', skip_action=False, with_owner=False)
        MolerTest.info("#3. make sure that for each list item proper rule se present:")
        keys = ntp_read_data.keys()
        dist_name = None
        for item in keys:
            dist_name = item
            break
        servers_list_from_scf = ntp_read_data[dist_name]
        MolerTest.info("servers list form scf: '{}' on '{}'.".format(servers_list_from_scf, dist_name))
        self._check_ntp_in_aclr(aclrules_ret=aclrule_ret, mplane_ip=mplane, list_addresses=servers_list_from_scf,
                                port="123")
        MolerTest.info("#4. make sure iptables shows the same number of rows with “dpt:123”")
        self._check_iptables_ntp(device_name=device_name, state='OAM', list_addresses=servers_list_from_scf,
                                 mplane_address=mplane, ipv6=ipv6)
        return servers_list_from_scf

    def _check_dns_servers_iptables_and_aclrules(self, device_name, dns_read_data, mplane, ipv6):
        MolerTest.info("#2. on oam VM list all acl rules:")
        aclrule_ret = self._aclrule_owner(device_name=device_name, state='OAM', skip_action=False, with_owner=False)
        MolerTest.info("#3. make sure that for each list item proper rule se present:")
        keys = dns_read_data.keys()
        dist_name = None
        for item in keys:
            dist_name = item
            break
        servers_list_from_scf = dns_read_data[dist_name]
        MolerTest.info("servers list form scf: '{}' for '{}'.".format(servers_list_from_scf, dist_name))
        self._check_dns_in_aclr(aclrules_ret=aclrule_ret, mplane_ip=mplane, list_addresses=servers_list_from_scf,
                                port="53")
        MolerTest.info("#4. make sure iptables shows the same number of rows with “dpt:53”")
        self._check_iptables_dns(device_name=device_name, state='OAM', list_addresses=servers_list_from_scf,
                                 mplane_address=mplane, ipv6=ipv6)
        return servers_list_from_scf

    def _find_ntp_servers_begin(self, local_path, scf, default_ntp_servers):
        ntp_read_data = scf.find_ntp_servers(path=local_path)
        if not ntp_read_data and default_ntp_servers:
            MolerTest.info("NTP data is not set in SCF on setup under test. Default NTP servers will be used with {}.".
                           format(default_ntp_servers))
            lines = scf.fill_if_empty_ntp(path=local_path, default_list_servers=default_ntp_servers)
            scf.save_file(path=local_path, lines=lines)
            scf.use_scf_on_gnb(local_path=local_path)
            ntp_read_data = scf.find_ntp_servers(path=local_path)
        return ntp_read_data

    def _find_dns_servers_begin(self, local_path, scf, default_dns_servers):
        dns_read_data = scf.find_dns_servers(path=local_path)
        if not dns_read_data and default_dns_servers:
            MolerTest.info("DNS data is not set in SCF on setup under test. Default DNS servers will be used with {}.".
                           format(default_dns_servers))
            lines = scf.fill_if_empty_dns(path=local_path, default_list_servers=default_dns_servers)
            scf.save_file(path=local_path, lines=lines)
            scf.use_scf_on_gnb(local_path=local_path)
            dns_read_data = scf.find_dns_servers(path=local_path)
        return dns_read_data

    def _check_iptables_ntp(self, device_name, state, list_addresses, mplane_address, ipv6,
                            regex_to_find=re.compile(r"udp spt:123 dpt:123")):
        device = DeviceFactory.get_device(name=device_name)
        device.goto_state(rerun=3, state=state)
        cmd_iptables = device.get_cmd(cmd_name='iptables', cmd_params={'options': '-L INPUT -t mangle -n',
                                                                       'v6': ipv6})
        cmd_sudo = device.get_cmd(cmd_name='sudo', cmd_params={'cmd_object': cmd_iptables})
        iptables_ret = cmd_sudo()
        list_addresses_org = list_addresses
        list_addresses = copy_list(src=list_addresses, deep_copy=True)
        for address in list_addresses_org:
            if self._is_item_for_address_in_iptables_ntp(mplane_address=mplane_address, regex_to_find=regex_to_find,
                                                         address=address, iptables_ret=iptables_ret):
                MolerTest.info("Found item for address '{}'.".format(address))
                list_addresses.remove(address)
            else:
                MolerTest.error("Cannot find item for '{}' (mplane) -> '{}' in iptables ret:.".format(mplane_address,
                                                                                                      address),
                                dump=iptables_ret)

    def _is_item_for_address_in_iptables_ntp(self, mplane_address, regex_to_find, address, iptables_ret):
        for key in iptables_ret:
            for key2 in iptables_ret[key]:
                for item in iptables_ret[key][key2]:
                    if 'REST' in item:
                        value = item['REST']
                        m = re.search(regex_to_find, value)
                        if m:
                            try:
                                if 'ACCEPT' == prev_item['TARGET'] and address == prev_item['SOURCE'] and 'udp' == \
                                        prev_item['PROT'] and mplane_address == prev_item['DESTINATION']:
                                    return True
                            except KeyError:
                                pass
                    prev_item = item
        return False

    def _check_iptables_dns(self, device_name, state, list_addresses, mplane_address, ipv6,
                            regex_to_find=re.compile(r"udp spt:53")):
        device = DeviceFactory.get_device(name=device_name)
        device.goto_state(rerun=3, state=state)
        cmd_iptables = device.get_cmd(cmd_name='iptables', cmd_params={'options': '-L INPUT -t mangle -n',
                                                                       'v6': ipv6})
        cmd_sudo = device.get_cmd(cmd_name='sudo', cmd_params={'cmd_object': cmd_iptables})
        iptables_ret = cmd_sudo()
        list_addresses_org = list_addresses
        list_addresses = copy_list(src=list_addresses, deep_copy=True)
        for address in list_addresses_org:
            if self._is_item_for_address_in_iptables_dns(mplane_address=mplane_address, regex_to_find=regex_to_find,
                                                         address=address, iptables_ret=iptables_ret):
                MolerTest.info("Found item for address '{}'.".format(address))
                list_addresses.remove(address)
            else:
                MolerTest.error("Cannot find item for '{}' (mplane) -> '{}' in iptables ret:.".format(mplane_address,
                                                                                                      address),
                                dump=iptables_ret)

    def _is_item_for_address_in_iptables_dns(self, mplane_address, regex_to_find, address, iptables_ret):
        for key in iptables_ret:
            for key2 in iptables_ret[key]:
                for item in iptables_ret[key][key2]:
                    if 'REST' in item:
                        value = item['REST']
                        m = re.search(regex_to_find, value)
                        if m:
                            MolerTest.info("Found '{}' in '{}'.".format(regex_to_find, value))
                            try:
                                if 'ACCEPT' == prev_item['TARGET'] and address == prev_item['SOURCE'] and 'udp' == \
                                        prev_item['PROT'] and mplane_address == prev_item['DESTINATION']:
                                    return True
                            except KeyError:
                                pass
                    prev_item = item
        return False

    def _check_ntp_in_aclr(self, aclrules_ret, mplane_ip, list_addresses, port='123'):
        self._check_rule_against_aclr(aclrules_ret=aclrules_ret, mplane_ip=mplane_ip, list_addresses=list_addresses,
                                      port=port)

    def _check_dns_in_aclr(self, aclrules_ret, mplane_ip, list_addresses, port='53'):
        self._check_rule_against_aclr(aclrules_ret=aclrules_ret, mplane_ip=mplane_ip, list_addresses=list_addresses,
                                      port=port)

    def _check_rule_against_aclr(self, aclrules_ret, mplane_ip, list_addresses, port):
        list_addresses_org = list_addresses
        list_addresses = copy_list(src=list_addresses, deep_copy=True)
        for item_key in sorted(aclrules_ret.keys()):
            item = aclrules_ret[item_key]
            try:
                if mplane_ip in item['dest addr'] and item['source port'] == port \
                        and item['chain'] == 'input' and item['protocol'] == 'udp' and item['action'] == 'accept':
                    for address in list_addresses:
                        if 'source addr' in item and address in item['source addr']:
                            MolerTest.info("Found aclr for '{}'.".format(address))
                            list_addresses.remove(address)
                            break
            except KeyError:
                pass
            if len(list_addresses) == 0:
                break
        if len(list_addresses) > 0:
            MolerTest.error("Could not find following addresses in output from acl rule show: '{}' from {}.".format(
                list_addresses, list_addresses_org))

    def _get_mplane_ip(self, bts_id):
        mplane = self._tl.gnbs[bts_id].cu.backhaul_site_oam_ip
        mplane_string = None
        if isinstance(mplane, six.string_types):
            mplane_string = mplane
        else:
            try:
                mplane_string = mplane.v4
                if mplane_string is None or "" == mplane_string:
                    mplane_string = mplane.v6
            except AttributeError:
                try:
                    mplane_string = mplane.v6
                except AttributeError:
                    MolerTest.error(
                        "Cannot get IP from '{}'. No attribute v4 nor v6. '{}'".format(mplane, repr(mplane))
                    )
        if mplane_string is None:
            MolerTest.error("Cannot get IP from '{}'.".format(mplane))
        else:
            MolerTest.info("Use mplane address: '{}'".format(mplane_string))
        return mplane_string
