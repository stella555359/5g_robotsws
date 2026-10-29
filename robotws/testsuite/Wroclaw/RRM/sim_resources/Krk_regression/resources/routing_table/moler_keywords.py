from functools import wraps

from moler.exceptions import ConnectionObserverTimeout
from robot.libraries.BuiltIn import BuiltIn

from taf.rfrl.bts.devices.cu.alarm_verification import CuAlarmVerification
from taf.rfrl.utilities.tl_config import load_moler_configuration_from_tl
from taf.rfrl.bts.connections import device_aliases as connection_names
from moler.device import DeviceFactory
from moler.util.moler_test import MolerTest
from time import time as tm
from testsuite.Wroclaw.RRM.sim_resources.Krk_regression.resources.linux_accounts.system_account_permissions \
    import SystemAccountPermissions
import moler.config


class MolerKeywords(object):

    def __init__(self):
        tl = BuiltIn().get_variable_value('${{{}}}'.format("tl"), None)
        self.cu_instance_id = tl.gnbs[0].cu.instance_id
        self.cu_address = tl.gnbs[0].cu.oam_ssh_connection_details.addr

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions()
    def set_additional_device_path(self, yml_path):
        moler.config.load_config(config=yml_path)

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def check_static_ipv6_route(self, addr, should_be_removed=False, bts_id=0):
        """
        Check if static ipv6 route exists.

        :param addr: ipv6 address
        :param should_be_removed: True if route should be removed
        :param bts_id: ID of BTS
        :return: None
        """
        vm = DeviceFactory.get_device("GNB{}_CU_IPV6".format(bts_id), initial_state="UNIX_LOCAL")
        ip_cmd = vm.get_cmd(cmd_name="ip_route", cmd_params={"is_ipv6": True})
        res = ip_cmd()
        if should_be_removed:
            if addr in res["ADDRESS"]:
                MolerTest.error("ip -route output contains added route")
        else:
            if addr not in res["ADDRESS"]:
                MolerTest.error("ip -route output does not contain added route")
        MolerTest.steps_end()

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions()
    def check_static_route(self, addr, vm, device_tag="CU", should_be_removed=False, ipv6=False, timeout=90, bts_id=0,
                           du_id=0):
        """
        Check if static route exists.

        :param addr: address
        :param vm: vm where route should be checked
        :param device_tag: tag for moler device: DU or CU
        :param should_be_removed: True if route should be removed
        :param ipv6: True if addr is ipv6 address
        :param timeout: timeout
        :param bts_id: ID of BTS
        :param du_id: ID of DU
        :return: None
        """
        device = connection_names.ssh_gnb_cu.format(bts_id) if device_tag == "CU"\
            else connection_names.ssh_bts_du.format('GNB', bts_id, du_id)
        if ipv6 and device_tag == "CU":
            device = "GNB{}_CU_IPV6".format(bts_id)
        vm = DeviceFactory.get_device(device, initial_state=vm)
        start_time = tm()
        elapsed_time = 0
        flg = False
        cmd_params = {"is_ipv6": True} if ipv6 else {}
        while elapsed_time < timeout:
            ip_cmd = vm.get_cmd(cmd_name="ip_route", cmd_params=cmd_params)
            res = ip_cmd()
            for el in res["ALL"]:
                if addr in el["ADDRESS"]:
                    flg = True
            if flg and not should_be_removed or not flg and should_be_removed:
                return
            MolerTest.sleep(15)
            elapsed_time = int(tm() - start_time)
            flg = False
        if not should_be_removed:
            MolerTest.error("ip {}-route output does not contain added route".format("-6 " if ipv6 else ""))
        else:
            MolerTest.error("ip {}-route output contains added route".format("-6 " if ipv6 else ""))

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions()
    def check_local_address(self, addr, ipv6=False, timeout=60, bts_id=0, du_id=0):
        """
        Check if local address exists.

        :param addr: expected ipv4 address
        :param ipv6: True if addr is ipv6 address
        :param timeout: timeout
        :param bts_id: ID of BTS
        :param du_id: ID of DU
        :return: None
        """
        vm = DeviceFactory.get_device(connection_names.ssh_bts_du.format('GNB', bts_id, du_id), initial_state="FCT")
        start_time = tm()
        elapsed_time = 0
        ip = "IPV6" if ipv6 else "IPV4"
        while elapsed_time < timeout:
            ip_cmd = vm.get_cmd(cmd_name="ip_addr")
            res = ip_cmd()
            for el in res:
                if "IP" in res[el][ip][0] and res[el][ip][0]["IP"] == addr:
                    return
            MolerTest.sleep(15)
            elapsed_time = int(tm() - start_time)
        MolerTest.error("ip -addr output does not contain added address")

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def remove_scf_file(self, path, bts_id=0):
        """
        Remove scf file.

        :param path: path to scf
        :param bts_id: ID of BTS
        :return: None
        """
        vm = DeviceFactory.get_device(connection_names.ssh_gnb_cu.format(bts_id), initial_state="UNIX_LOCAL")
        rm_cmd = vm.get_cmd(cmd_name="rm", cmd_params={"file": path})
        rm_cmd()
        MolerTest.steps_end()

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def get_gateway_address(self, vm, bts_id=0):
        """
        Get gateway address.

        :param vm: path to scf
        :param bts_id: ID of BTS
        :return: gateway address
        """
        interface = vm.lower() if vm == "OAM" else "fronthaul"
        device = DeviceFactory.get_device(connection_names.ssh_gnb_cu.format(bts_id), initial_state=vm)
        ip_cmd = device.get_cmd(cmd_name="ip_addr",
                                cmd_params={"options": "show {}".format(interface)})
        addr = ip_cmd()[interface]["IPV4"][0]["IP"]
        gateway = MolerKeywords.next_address(addr)
        MolerTest.steps_end()
        return gateway

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def get_ipv6_gateway_address(self, vm, bts_id=0):
        """
        Get ipv6 gateway address.

        :param vm: CU VM name
        :param bts_id: ID of BTS
        :return: gateway address
        """
        interface = vm.lower() if vm == "OAM" else "fronthaul"
        device = DeviceFactory.get_device("GNB{}_CU_IPV6".format(bts_id), initial_state=vm)
        ip_cmd = device.get_cmd(cmd_name="ip_addr",
                                cmd_params={"options": "show {}".format(interface)})
        addr = ip_cmd()[interface]["IPV6"][0]["IP"]
        gateway = MolerKeywords.next_ipv6_address(addr)
        MolerTest.steps_end()
        return gateway

    @staticmethod
    def next_address(addr):
        """
        Get next ipv4 address.

        :param addr: ipv4 address
        :return: ipv6 address
        """
        next_addr = [int(i) for i in addr.split('.') if i.isdigit()]
        next_addr[3] = next_addr[3] + 1
        next_addr = '.'.join(map(str, next_addr))
        return next_addr

    @staticmethod
    def next_ipv6_address(addr):
        """
        Get next ipv6 address.

        :param addr: ipv6 address
        :return: ipv6 address
        """
        next_addr = addr.split(':')
        next_addr[-1] = int(next_addr[-1]) + 1
        next_addr = ':'.join(map(str, next_addr))
        return next_addr

    @staticmethod
    def get_gateway_address_du():
        """
        Get gateway address.

        :return: gateway address
        """
        sap = SystemAccountPermissions()
        local_ip_address = sap.get_param("localIpAddr")
        gateway = MolerKeywords.next_address(local_ip_address)
        return gateway

    def get_ipv6_gateway_address_du(self):
        """
        Get gateway address.

        :return: gateway address
        """
        sap = SystemAccountPermissions()
        local_ip_address = sap.get_param("localIpAddr", "MRBTS-{}/TNLSVC-1/TNL-1/IPNO-1/IPIF-2/IPADDRESSV6-1".format(
            self.cu_instance_id))
        gateway = MolerKeywords.next_ipv6_address(local_ip_address)
        return gateway

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def get_cpif_address(self, bts_id=0, ipv6=False):
        """
        Get cpif address.

        :param bts_id: ID of BTS
        :param ipv6: True if ipv6 oam address
        :return: cpif address
        """
        interface = "x2"
        device = DeviceFactory.get_device("GNB{}_CU_IPV6".format(bts_id) if ipv6
                                          else connection_names.ssh_gnb_cu.format(bts_id),
                                          initial_state="CPIF")
        ip_cmd = device.get_cmd(cmd_name="ip_addr", cmd_params={"options": "show {}".format(interface)})
        addr = ip_cmd()[interface]["IPV6"][0]["IP"]
        MolerTest.steps_end()
        return addr

    def get_oam_address(self):
        """
        Get oam address.

        :return: oam address
        """
        return self.cu_address

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def get_upue_address(self, bts_id=0, ipv6=False):
        """
        Get upue address.

        :param bts_id: ID of BTS
        :param ipv6: True if ipv6 oam address
        :return: upue address
        """
        interface = "backhaul"
        device = DeviceFactory.get_device("GNB{}_CU_IPV6".format(bts_id) if ipv6
                                          else connection_names.ssh_gnb_cu.format(bts_id),
                                          initial_state="UPUE")
        ip_cmd = device.get_cmd(cmd_name="ip_addr", cmd_params={"options": "show {}".format(interface)})
        addr = ip_cmd()[interface]["IPV6"][0]["IP"]
        MolerTest.steps_end()
        return addr

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def add_address(self, addr, bts_id=0):
        """
        Add address on specified vm.

        :param addr: address
        :param bts_id: ID of BTS
        """
        device = DeviceFactory.get_device("TEST_PC_2", initial_state="UNIX_REMOTE")
        ip_cmd = device.get_cmd(cmd_name="run_script",
                                cmd_params={"script_command": "sudo ip -6 addr add {}/112 dev eth2".format(addr)})
        ip_cmd()
        MolerTest.steps_end()

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def delete_address(self, addr, bts_id=0):
        """
        Delete address on specified vm.

        :param addr: address
        :param bts_id: ID of BTS
        """
        device = DeviceFactory.get_device("TEST_PC_2", initial_state="UNIX_REMOTE")
        ip_cmd = device.get_cmd(cmd_name="run_script",
                                cmd_params={"script_command": "sudo ip -6 addr del {}/112 dev eth2".format(addr)})
        ip_cmd()
        MolerTest.steps_end()

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions()
    def wait_for_cu_reset(self, addr, timeout=30, bts_id=0):
        """
        Wait until CU does not respond.

        :param addr: CU address
        :param timeout: timeout
        :param bts_id: ID of BTS
        """
        device = DeviceFactory.get_device("TEST_PC_2", initial_state="UNIX_REMOTE")
        event_no_response = device.get_event(event_name="ping_no_response", event_params={'till_occurs_times': 1})
        cmd_ping = device.get_cmd(cmd_name="ping", cmd_params={'destination': addr, 'options': '-O'})
        cmd_ping.start(timeout=3600)
        event_no_response.start(timeout=int(timeout))
        try:
            event_no_response.await_done(timeout=int(timeout))
        except ConnectionObserverTimeout:
            MolerTest.error("CU did not reset in {} seconds.".format(timeout))
        cmd_ping.cancel()
        event_no_response.cancel()

    @MolerTest.raise_background_exceptions()
    def wait_until_alarm_is_active_on_cu(self, fault_id, fault_name, alarm_id, timeout=300, bts_id=0):
        """
        Wait until alarm is active on CU WebEM.

        :param fault_id: fault id
        :param fault_name: full name of fault
        :param alarm_id: alarm id
        :param timeout: timeout
        :param bts_id: ID of BTS
        """
        alarm = CuAlarmVerification()
        start_time = tm()
        elapsed_time = 0
        flg = False
        exception = None
        while elapsed_time < int(timeout):
            try:
                alarm.verify_alarm_is_active(fault_id=fault_id, fault_name=fault_name, alarm_id=alarm_id,
                                             bts_id=bts_id)
            except Exception as e:
                flg = True
                exception = e
            if not flg:
                return
            MolerTest.sleep(15)
            elapsed_time = int(tm() - start_time)
            flg = False
        MolerTest.error(exception)

    @MolerTest.raise_background_exceptions()
    def wait_until_alarm_is_not_active_on_cu(self, fault_id, timeout=180, bts_id=0):
        """
        Wait until alarm is not active on CU WebEM.

        :param fault_id: fault id
        :param timeout: timeout
        :param bts_id: ID of BTS
        """
        alarm = CuAlarmVerification()
        start_time = tm()
        elapsed_time = 0
        flg = False
        exception = None
        while elapsed_time < int(timeout):
            try:
                alarm.verify_alarm_is_not_active(fault_id=fault_id, bts_id=bts_id)
            except Exception as e:
                flg = True
                exception = e
            if not flg:
                return
            MolerTest.sleep(15)
            elapsed_time = int(tm() - start_time)
            flg = False
        MolerTest.error(exception)

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def get_du_interface_address(self, interface_name, bts_id=0, vlan_tag_fp0=False, du_id=0):
        """
        Get DU interface IPv4 address.

        :param bts_id: ID of BTS
        :param interface_name: str, name of DU interface
        :param vlan_tag_fp0: bool, add str '@fp0' to interface name, suitable for F1 vlan, default False
        :param du_id: ID of DU
        :return: interface IP address
        """
        device = DeviceFactory.get_device(connection_names.ssh_bts_du.format('GNB', bts_id, du_id),
                                          initial_state="FCT")
        ip_cmd = device.get_cmd(cmd_name="ip_addr", cmd_params={"options": "show {}".format(interface_name)})
        if vlan_tag_fp0 is True:
            addr = ip_cmd()[interface_name+'@fp0']["IPV4"][0]["IP"]
        else:
            addr = ip_cmd()[interface_name]["IPV4"][0]["IP"]
        MolerTest.steps_end()
        return addr

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def get_cu_interface_address(self, interface_name, device_state, bts_id=0):
        """
        Get CU interface IPv4 address

        :param interface_name: str, name of CU interface
        :param device_state: str, input for get_device method from Moler library
        :param bts_id: int, ID of BTS
        :return: str, interface ip address
        """
        device = DeviceFactory.get_device(connection_names.ssh_gnb_cu.format(bts_id), initial_state=device_state)
        ip_cmd = device.get_cmd(cmd_name="ip_addr", cmd_params={"options": "show {}".format(interface_name)})
        addr = ip_cmd()[interface_name]["IPV4"][0]["IP"]
        MolerTest.steps_end()
        return addr

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def get_cu_gateway_address(self, device_state, bts_id=0):
        """
        Get default gateway IP address

        :param device_state: str, input for get_device method from Moler library
        :param bts_id: int, ID of BTS
        :return: str, gateway ip address
        """
        device = DeviceFactory.get_device(connection_names.ssh_gnb_cu.format(bts_id), initial_state=device_state)
        ip_cmd = device.get_cmd(cmd_name="ip_route")
        addr = ip_cmd()['ALL'][0]['VIA']
        MolerTest.steps_end()
        return addr
