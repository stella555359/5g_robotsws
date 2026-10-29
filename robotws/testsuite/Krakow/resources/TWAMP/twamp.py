import os
import re
from time import time as tm
from datetime import datetime

from moler.exceptions import CommandFailure, ExecutionException
from robot.libraries.BuiltIn import BuiltIn

from taf.rfrl.utilities.tl_config import load_moler_configuration_from_tl
from moler.device import DeviceFactory
from moler.util.moler_test import MolerTest
from testsuite.Krakow.resources.linux_accounts.system_account_permissions import admin_connect, \
    SystemAccountPermissions
from taf.sbts.oam.coam.admin import admin
from taf.config.scf.scf_operations import SCFOperations


class Twamp(object):

    def __init__(self):
        tl = BuiltIn().get_variable_value('${{{}}}'.format("tl"), None)
        self.http_address = tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr
        self.mplane_ip = tl.gnbs[0].dus[0].oam_ip.v4.split('/')[0]
        self.mplane_ip_v6 = tl.gnbs[0].dus[0].oam_ip.v6.split('/')[0]
        self.gnb_id = tl.gnbs[0].dus[0].global_bts_id
        self.twamp_vm = tl.test_pcs[0].default_ssh_connection_details.addr
        self.twamp_vm_v6 = tl.test_pcs[1].default_ssh_connection_details.addr
        self.admin = admin()
        self.curr_dir = os.path.dirname(os.path.realpath(__file__))
        self.twampy_cmd_ipv4 = [None, None]
        self.twampy_cmd_ipv6 = [None, None]
        self.twampy_cmd_ipv6_dscp = None
        self.tcpdump_cmd = None
        self.netcat_cmd_ipv4 = None
        self.netcat_cmd_ipv6 = None
        self.scf = SCFOperations()
        self.netem_ipv4 = "10.0.1.254"
        self.gnb_ip = "10.0.1.238"
        self.sap = SystemAccountPermissions()
        self.twamp1_params = dict()
        self.twamp2_params = dict()
        self.pm_twamp_counters = dict()

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions()
    def send_and_verify_packets_from_twamp_ipv4(self, packet_count, should_fail=False, bts_id=0):
        """
        Send ipv4 Twamp packets.

        :param packet_count: number of packets to be sent
        :param should_fail: True if fail expected
        :param bts_id: ID of BTS
        :return: None
        """
        self.send_packets(packet_count, self.mplane_ip, self.twamp_vm, 5001, should_fail, bts_id)

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions()
    def send_and_verify_packets_from_twamp_ipv6(self, packet_count, should_fail=False, bts_id=0):
        """
        Send ipv6 Twamp packets.

        :param packet_count: number of packets to be sent
        :param should_fail: True if fail expected
        :param bts_id: ID of BTS
        :return: None
        """
        self.send_packets(packet_count, "[{}]".format(self.mplane_ip_v6), "[{}]".format(self.twamp_vm_v6),
                          5000, should_fail, bts_id)

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def send_packets(self, packet_count, addr1, addr2, port, should_fail=False, bts_id=0):
        """
        Send Twamp packets.

        :param packet_count: number of packets to be sent
        :param addr1: responder address
        :param addr2: sender address
        :param port: NetEM port
        :param should_fail: True if fail expected
        :param bts_id: ID of BTS
        :return: None
        """
        vm = DeviceFactory.get_device("GNB{}".format(bts_id), initial_state="PROXY_PC")
        ssh_cmd = vm.get_cmd(cmd_name="ssh",
                             cmd_params={"login": "ute", "password": "ute", "host": self.twamp_vm,
                                         "expected_prompt": "ute@.*"})
        ssh_cmd()
        twampy_cmd = vm.get_cmd(cmd_name="twampy", cmd_params={
            "options": "sender -c {} -i 1000 -d {}:5018 {}:{}".format(packet_count, addr1, addr2, port)})
        twampy_output = twampy_cmd(timeout=50)
        ssh_exit = vm.get_cmd(cmd_name="exit", cmd_params={"expected_prompt": "ute@.*"})
        ssh_exit()
        self.verify_packets(twampy_output, packet_count, should_fail)
        MolerTest.steps_end()

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def verify_packets(self, twampy_output, packet_count=None, should_fail=False):
        """
        Verify TWAMP packets.

        :param twampy_output: twampy.py output
        :param packet_count: NetEM port
        :param should_fail: True if fail expected
        :return: None
        """
        MolerTest.info("Twampy output", dump=twampy_output)
        packets_transmitted_correctly = 0
        zero_flg = False
        for line in twampy_output["PARSED_LINES"]:
            if "SSEQ" in line.keys() and "RSEQ" not in line.keys():
                sseq = line["SSEQ"]
                if not zero_flg and sseq != 0:
                    MolerTest.error("sseq (={}) does not start with 0".format(sseq))
                    MolerTest.steps_end()
                    return
                elif not zero_flg:
                    zero_flg = True
            elif "SSEQ" in line.keys() and "RSEQ" in line.keys() and "RTT" in line.keys():
                self._validate_sseq_and_rseq(line["SSEQ"], line["RSEQ"])
                packets_transmitted_correctly += 1
                if line["SSEQ"] != sseq:
                    MolerTest.error("Transmitted sseq is different than received sseq")
                    MolerTest.steps_end()
                    return
        if not packet_count:
            MolerTest.steps_end()
            return
        if int(packets_transmitted_correctly) == int(packet_count):
            MolerTest.info("All packets transmitted correctly")
        else:
            if should_fail and packets_transmitted_correctly == 0:
                MolerTest.steps_end()
                return
            MolerTest.error(
                "Transmission error {} / {} packets received".format(packets_transmitted_correctly, packet_count),
                raise_exception=True)
        MolerTest.steps_end()

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def verify_packets_discarded(self, twampy_output):
        """
        Verify TWAMP packets are discarded.

        :param twampy_output: twampy.py script output
        :return: None
        """
        MolerTest.info("Twampy output", dump=twampy_output)
        sseq = None
        for line in twampy_output["PARSED_LINES"]:
            if "SSEQ" in line.keys():
                if sseq and sseq == line["SSEQ"]:
                    MolerTest.error("Packets are not discarded")
                sseq = line["SSEQ"]
        MolerTest.steps_end()

    @staticmethod
    def _validate_sseq_and_rseq(sseq, rseq):
        if sseq == rseq:
            MolerTest.info("SSEQ value and RSEQ value are the same (={})".format(sseq))
        else:
            MolerTest.error("SSEQ value (={}) and RSEQ value (={}) are NOT the same".format(sseq, rseq),
                            raise_exception=True)

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions()
    def check_destination_unreachable_ipv4(self, destination_unreachable=False, bts_id=0):
        """
        Check if "unreachable destination" line is in tcpdump output for ipv4.

        :return: None
        """
        self.check_destination_unreachable(self.mplane_ip, destination_unreachable, bts_id)

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions()
    def check_destination_unreachable_ipv6(self, destination_unreachable=False, bts_id=0):
        """
        Check if "unreachable destination" line is in tcpdump output for ipv6.

        :return: None
        """
        self.check_destination_unreachable(self.mplane_ip, destination_unreachable, bts_id)

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def start_tcpdump(self, bts_id=0):
        """
        Start tcpdump  command

        :return: None
        """
        vm = DeviceFactory.get_cloned_device("GNB{}".format(bts_id), "GNB{}_cloned3".format(bts_id),
                                             initial_state="PROXY_PC")
        ssh_cmd = vm.get_cmd(cmd_name="ssh",
                             cmd_params={"login": "ute", "password": "ute", "host": self.twamp_vm,
                                         "expected_prompt": "ute@.*"})
        ssh_cmd()
        sudo_cmd = vm.get_cmd(cmd_name="sudo",
                              cmd_params={"sudo_params": "su", "expected_prompt": "root@.*"})
        sudo_cmd()
        self.tcpdump_cmd = vm.get_cmd(cmd_name="tcpdump", cmd_params={"options": "-c 10 -i eth2 > tmp"})
        self.tcpdump_cmd.start(timeout=999)
        MolerTest.steps_end()

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def check_destination_unreachable(self, addr, destination_unreachable=False, bts_id=0):
        """
        Check if "unreachable destination" line is in tcpdump output.

        :param addr: address
        :param destination_unreachable: True if destination unreachable expected
        :param bts_id: ID of BTS
        :return: None
        """
        MolerTest.sleep(10)
        self.tcpdump_cmd.cancel()
        vm = DeviceFactory.get_cloned_device("GNB{}".format(bts_id), "GNB{}_cloned3".format(bts_id))
        cat_cmd = vm.get_cmd(cmd_name="cat", cmd_params={"path": "tmp", "prompt": "root@.*"})
        tcpdump = cat_cmd()
        flg = False
        for el in tcpdump["LINES"]:
            if "ICMP{}, destination unreachable, unreachable port, {} udp port 5018" \
                    .format("6" if ":" in addr else "", addr) in el:
                flg = True
        ssh_exit = vm.get_cmd(cmd_name="exit", cmd_params={"expected_prompt": "ute@.*"})
        ssh_exit()
        ssh_exit = vm.get_cmd(cmd_name="exit", cmd_params={"expected_prompt": "ute@.*"})
        ssh_exit()
        if not flg and destination_unreachable:
            MolerTest.error("ICMP Destnation Unreachable has not been sent")
        elif flg and not destination_unreachable:
            MolerTest.error("ICMP Destnation Unreachable has been sent")
        MolerTest.steps_end()

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def start_sending_packets(self, responder_port="5018", ipv4_sender_port="5001", ipv6_sender_port="5000",
                              options="", cloned_devices=False, bts_id=0):
        """
        Send packets with twampy.py.

        :param responder_port: responder port
        :param ipv4_sender_port: ipv6 sender port
        :param ipv6_sender_port: ipv6 sender port
        :param options: additional options
        :param cloned_devices: True if new sessions are to be created
        :param bts_id: ID of BTS
        :return: None
        """
        idx = 0 if not cloned_devices else 1
        vm = DeviceFactory.get_cloned_device("GNB{}".format(bts_id),
                                             "GNB{}_cloned{}".format(bts_id, "1" if not cloned_devices else "4"),
                                             initial_state="PROXY_PC")
        ssh_cmd = vm.get_cmd(cmd_name="ssh",
                             cmd_params={"login": "ute", "password": "ute", "host": self.twamp_vm,
                                         "expected_prompt": "ute@.*"})
        ssh_cmd()
        self.twampy_cmd_ipv4[idx] = vm.get_cmd(cmd_name="twampy", cmd_params={
            "options": "sender -c 999 -i 1000 -d {} {}:{} {}:{}".format(options, self.mplane_ip, responder_port,
                                                                        self.twamp_vm, ipv4_sender_port)})
        self.twampy_cmd_ipv4[idx].start(timeout=9999)
        vm2 = DeviceFactory.get_cloned_device("GNB{}".format(bts_id),
                                              "GNB{}_cloned{}".format(bts_id, "2" if not cloned_devices else "5"),
                                              initial_state="PROXY_PC")
        ssh_cmd = vm2.get_cmd(cmd_name="ssh", cmd_params={"login": "ute", "password": "ute", "host": self.twamp_vm,
                                                          "expected_prompt": "ute@.*"})
        ssh_cmd()
        self.twampy_cmd_ipv6[idx] = vm2.get_cmd(cmd_name="twampy", cmd_params={
            "options": "sender -c 999 -i 1000 -d {} [{}]:{} [{}]:{}"
                                                .format(options, self.mplane_ip_v6, responder_port, self.twamp_vm_v6,
                                                        ipv6_sender_port)})
        self.twampy_cmd_ipv6[idx].start(timeout=9999)
        MolerTest.steps_end()

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions()
    def start_sending_packets_simultaneously(self):
        """
        Start sending packets with twampy.py with 2 different responder ports.

        :return: None
        """
        self.start_sending_packets()
        self.start_sending_packets(responder_port="7", ipv4_sender_port="5003", ipv6_sender_port="5002",
                                   cloned_devices=True)

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def start_sending_packets_with_different_dscp_number(self, dscp, bts_id=0):
        """
        Start sending packets with twampy.py with provided dscp number.

        :param dscp: dscp number
        :param bts_id: ID of BTS
        :return: None
        """
        vm = DeviceFactory.get_cloned_device("GNB{}".format(bts_id), "GNB{}_cloned3".format(bts_id),
                                             initial_state="PROXY_PC")
        ssh_cmd = vm.get_cmd(cmd_name="ssh",
                             cmd_params={"login": "ute", "password": "ute", "host": self.twamp_vm,
                                         "expected_prompt": "ute@.*"})
        ssh_cmd()
        self.twampy_cmd_ipv6_dscp = vm.get_cmd(cmd_name="twampy", cmd_params={
            "options": "sender -c 999 -i 1000 -v --dscp {} [{}]:5018 [{}]:5000".format(dscp, self.mplane_ip_v6,
                                                                                       self.twamp_vm_v6)})
        self.twampy_cmd_ipv6_dscp.start(timeout=999)
        MolerTest.steps_end()

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def stop_sending_and_verify_packets(self, discarded=False, cloned_devices=False, bts_id=0):
        """
        Stop sending and verify TWAMP packets.

        :param discarded: True if discarding packets is expected
        :param cloned_devices: True sessions are on cloned devices
        :param bts_id: ID of BTS
        :return: None
        """
        idx = 0 if not cloned_devices else 1
        vm = DeviceFactory.get_device("GNB{}_cloned{}".format(bts_id, "1" if not cloned_devices else "4"))
        self.twampy_cmd_ipv4[idx].break_cmd()
        output = self.twampy_cmd_ipv4[idx].await_done()
        if not discarded:
            self.verify_packets(output)
        else:
            self.verify_packets_discarded(output)
        ssh_exit = vm.get_cmd(cmd_name="exit", cmd_params={"expected_prompt": "ute@.*"})
        ssh_exit()
        vm2 = DeviceFactory.get_device("GNB{}_cloned{}".format(bts_id, "2" if not cloned_devices else "5"))
        self.twampy_cmd_ipv6[idx].break_cmd()
        output = self.twampy_cmd_ipv6[idx].await_done()
        if not discarded:
            self.verify_packets(output)
        else:
            self.verify_packets_discarded(output)
        ssh_exit = vm2.get_cmd(cmd_name="exit", cmd_params={"expected_prompt": "ute@.*"})
        ssh_exit()
        MolerTest.steps_end()

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def stop_sending_simultaneously_and_verify_packets(self, bts_id=0):
        """
        Stop sending packets with twampy.py with 2 different responder ports.

        :return: None
        """
        self.stop_sending_and_verify_packets(bts_id=bts_id)
        self.stop_sending_and_verify_packets(cloned_devices=True, bts_id=bts_id)

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def stop_sending_and_check_response(self, bts_id=0):
        """
        Stop sending and verify TWAMP packets.

        :param bts_id: ID of BTS
        :return: None
        """
        vm = DeviceFactory.get_device("GNB{}_cloned1".format(bts_id))
        self.twampy_cmd_ipv4[0].break_cmd()
        output = self.twampy_cmd_ipv4[0].await_done()
        self._compare_sseq_rseq(output)
        ssh_exit = vm.get_cmd(cmd_name="exit", cmd_params={"expected_prompt": "ute@.*"})
        ssh_exit()
        vm2 = DeviceFactory.get_device("GNB{}_cloned2".format(bts_id))
        self.twampy_cmd_ipv6[0].break_cmd()
        output = self.twampy_cmd_ipv6[0].await_done()
        self._compare_sseq_rseq(output)
        ssh_exit = vm2.get_cmd(cmd_name="exit", cmd_params={"expected_prompt": "ute@.*"})
        ssh_exit()
        MolerTest.steps_end()

    @staticmethod
    def _compare_sseq_rseq(twampy_output):
        zero_flg = False
        for line in twampy_output["PARSED_LINES"]:
            if "SSEQ" in line.keys() and "RSEQ" not in line.keys():
                sseq = line["SSEQ"]
                if not zero_flg and sseq != 0:
                    MolerTest.error("sseq (={}) does not start with 0".format(sseq))
                    MolerTest.steps_end()
                    return
                elif not zero_flg:
                    zero_flg = True
            elif "SSEQ" in line.keys() and "RSEQ" in line.keys():
                if line["RSEQ"] != sseq:
                    MolerTest.error(
                        "Transmitted sseq (={}) is different than received rseq (={})".format(sseq, line["RSEQ"]))
                    MolerTest.steps_end()
                    return

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def stop_sending_and_verify_packets_with_different_dscp_number(self, bts_id=0):
        """
        Stop sending and verify TWAMP packets.

        :param bts_id: ID of BTS
        :return: None
        """
        vm = DeviceFactory.get_device("GNB{}_cloned3".format(bts_id))
        self.twampy_cmd_ipv6_dscp.break_cmd()
        output = self.twampy_cmd_ipv6_dscp.await_done()
        self.verify_packets_with_different_dscp_number(output)
        ssh_exit = vm.get_cmd(cmd_name="exit", cmd_params={"expected_prompt": "ute@.*"})
        ssh_exit()

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def verify_packets_with_different_dscp_number(self, twampy_output):
        """
        Verify TWAMP packets.

        :param twampy_output: output from twampy.py
        :return: None
        """
        MolerTest.info("Twampy output", dump=twampy_output)
        for line, i in zip(twampy_output["PARSED_LINES"][0:3], range(3)):
            if i in [0, 1]:
                if line["SSEQ"] != 0:
                    MolerTest.error("sseq (={}) does not start with 0".format(line["SSEQ"]))
            else:
                if line["SSEQ"] in [0, 1]:
                    MolerTest.error("sseq (={}) is not continued after setting new sender".format(line["SSEQ"]))
            if "SSEQ" in line.keys() and "RSEQ" in line.keys():
                self._validate_sseq_and_rseq(line["SSEQ"], line["RSEQ"])
        MolerTest.steps_end()

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def stop_sending_packets(self, cloned_devices=False, bts_id=0):
        """
        Stop sending TWAMP packets.

        :param cloned_devices: True if packets are sent from cloned devices.
        :param bts_id: ID of BTS
        :return: None
        """
        idx = 0 if not cloned_devices else 1
        vm = DeviceFactory.get_device("GNB{}_cloned{}".format(bts_id, "1" if not cloned_devices else "4"))
        self.twampy_cmd_ipv4[idx].cancel()
        ssh_exit = vm.get_cmd(cmd_name="exit", cmd_params={"expected_prompt": "ute@.*"})
        ssh_exit()
        vm2 = DeviceFactory.get_device("GNB{}_cloned{}".format(bts_id, "2" if not cloned_devices else "5"))
        self.twampy_cmd_ipv6[idx].cancel()
        ssh_exit = vm2.get_cmd(cmd_name="exit", cmd_params={"expected_prompt": "ute@.*"})
        ssh_exit()
        MolerTest.steps_end()

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions()
    def stop_sending_packets_simultaneously(self, bts_id=0):
        """
        Stop sending TWAMP packets simultaneously.

        :param bts_id: ID of BTS
        :return: None
        """
        self.stop_sending_packets(bts_id=bts_id)
        self.stop_sending_packets(cloned_devices=True, bts_id=bts_id)

    @admin_connect
    @MolerTest.raise_background_exceptions()
    def change_pmtnl_twamp_statistics_interval_parameter(self, value):
        """
        Change 'twampStatisticsInterval' WebEM parameter of PMTNL object to provided value.

        :param value: planned value of parameter
        :return: None
        """
        self.admin.perform_parameter_recommissioning("MRBTS-{}/TNLSVC-1/TNL-2/PMTNL-1".format(self.gnb_id),
                                                     "twampStatisticsInterval",
                                                     "update", value=value, skip_parameter_relation_errors=True)

    @admin_connect
    @MolerTest.raise_background_exceptions()
    def change_pmtnlint_twamp_statistics_interval_parameter(self, value):
        """
        Change 'twampStatisticsInterval' WebEM parameter of PMTNLINT object to provided value.

        :param value: planned value of parameter
        :return: None
        """
        self.admin.perform_parameter_recommissioning("MRBTS-{}/TNLSVC-1/PMTNLINT-1".format(self.gnb_id),
                                                     "twampStatisticsInterval",
                                                     "update", value=value, skip_parameter_relation_errors=True)

    @admin_connect
    @MolerTest.raise_background_exceptions()
    def change_twamp_reflector_parameter(self, param, value, twampreflect):
        """
        Change twamp reflector WebEM parameter to provided value.

        :param param: parameter to be changed
        :param value: planned value of parameter
        :param twampreflect: TWAMPREFLECT number
        :return: None
        """
        self.admin.perform_parameter_recommissioning(
            "MRBTS-{}/TNLSVC-1/TNL-2/IPAPP-1/TWAMPREFLECT-{}".format(self.gnb_id, twampreflect),
            param, "update", value=value, skip_parameter_relation_errors=True)

    @admin_connect
    @MolerTest.raise_background_exceptions()
    def change_administrative_state_parameter(self, value, twamp_number):
        """
        Change 'administrativeState' WebEM parameter to provided value.

        :param value: planned value of parameter
        :param twamp_number: number of TWAMP object
        :return: None
        """
        self.admin.perform_parameter_recommissioning(
            "MRBTS-{}/TNLSVC-1/TNL-2/IPAPP-1/TWAMP-{}".format(self.gnb_id, twamp_number),
            "administrativeState",
            "update", value=value, skip_parameter_relation_errors=True)

    @admin_connect
    @MolerTest.raise_background_exceptions()
    def change_administrative_state_parameters(self):
        """
        Change TWAMP 'administrativeState' WebEM parameters.

        :return: None
        """
        if self.sap.get_param(param="administrativeState",
                              dist_name="MRBTS-{}/TNLSVC-1/TNL-2/IPAPP-1/TWAMP-1".format(self.gnb_id)) == "unlocked":
            self.change_administrative_state_parameter("locked", 1)
            self.change_administrative_state_parameter("unlocked", 2)
            self.change_administrative_state_parameter("locked", 3)
            self.change_administrative_state_parameter("unlocked", 4)
        else:
            self.change_administrative_state_parameter("unlocked", 1)
            self.change_administrative_state_parameter("locked", 2)
            self.change_administrative_state_parameter("unlocked", 3)
            self.change_administrative_state_parameter("locked", 4)

    @admin_connect
    @MolerTest.raise_background_exceptions()
    def deactivate_all_twamp_sender_sessions(self):
        """
        Set TWAMP 'administrativeState' WebEM parameters to locked.

        :return: None
        """
        self.change_administrative_state_parameter("locked", 1)
        self.change_administrative_state_parameter("locked", 2)
        self.change_administrative_state_parameter("locked", 3)
        self.change_administrative_state_parameter("locked", 4)

    @admin_connect
    @MolerTest.raise_background_exceptions()
    def get_twampstatres(self):
        """
        Get 'TWAMPSTATRES' object.

        :return: None
        """
        bts_configuration = self.admin.get_scf(export_type="configurationAndRuntimeObjects")
        ret = str(bts_configuration).partition('distName="{}"'.format(
            "MRBTS-{}/TNLSVC-1/TNL-2/IPAPP-1/TWAMP-1/TWAMPSTATREQ-1/TWAMPSTATRES-1".format(self.gnb_id)))[2].partition(
            '</managedObject>')[0]
        re_parameter_and_value = r'<p\s\w+=\"(?P<KEY>.+)\">(?P<VALUE>.*)</p>'
        ret_dict = dict()
        for line in ret.splitlines():
            determinate_parameter = re.search(re_parameter_and_value, line)
            if determinate_parameter:
                ret_dict[determinate_parameter.group('KEY')] = determinate_parameter.group('VALUE')
        return ret_dict

    @admin_connect
    @MolerTest.raise_background_exceptions()
    def compare_twampstatres(self, dict1, dict2):
        """
        Compare twampstatres object dicts

        :param dict1: twampstatres expected output
        :param dict2: twampstatres actual output
        :return: None
        """
        error_msg = ""
        for el in dict1:
            if dict1[el] > dict2[el]:
                if not error_msg:
                    error_msg += "Incorrect TWAMPSTATRES values:\n"
                error_msg += "{}: {} > {}\n".format(el, dict1[el], dict2[el])
        if error_msg:
            MolerTest.error(error_msg)

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions()
    def verify_test_session_status(self, file_number, bts_id=0):
        """
        Verify status of test session

        :param file_number: number of file with expected output
        :param bts_id: :param bts_id: ID of BTS
        :return: None
        """
        vm = DeviceFactory.get_device("GNB{}".format(bts_id), initial_state="UNIX_LOCAL")
        ssh_cmd = vm.get_cmd(cmd_name="cat",
                             cmd_params={"path": "{}/twamp_Reflector_session_info_B_36_0{}.apt".format(self.curr_dir,
                                                                                                       file_number)})
        expected = ssh_cmd()
        vm.goto_state("FCT")
        ssh_cmd = vm.get_cmd(cmd_name="cat",
                             cmd_params={"path": "/tmp/twamp_Reflector_session_info.txt"})
        session_info = ssh_cmd()
        self._compare_twamp_session_info(expected, session_info)

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions()
    def _compare_twamp_session_info(self, expected, actual):
        error_msg = ""
        expected["LINES"].pop(1)
        actual["LINES"].pop(1)
        for line_ex, line_ac in zip(expected["LINES"], actual["LINES"]):
            if line_ex != line_ac:
                if "Last Seq Number" in line_ac or "Time last Pkt Recv" in line_ac:
                    continue
                if not error_msg:
                    error_msg += "Unexpected line in twamp session info:\n"
                error_msg += "expected: {}\nactual: {}\n".format(line_ex, line_ac)
        if error_msg:
            MolerTest.error(error_msg)

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions()
    def get_twamp_session_info(self, bts_id=0):
        """
        Get TWAMP session info

        :param bts_id: :param bts_id: ID of BTS
        :return: None
        """
        vm = DeviceFactory.get_device("GNB{}".format(bts_id), initial_state="FCT")
        twamp_cmd = vm.get_cmd(cmd_name="run_script", cmd_params={
            "script_command": "/opt/trs/bin/trs-twamp-d -f /tmp/twampd.ini -s "
                              "/tmp/twampd.sock execute dumpReflectorTestSessionsInfo"})
        twamp_cmd()

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions()
    def compare_twampd_files(self, file_number, bts_id=0):
        """
        Compare twampd.ini files

        :param file_number: number of file with expected output
        :param bts_id: ID of BTS
        :return: None
        """
        vm = DeviceFactory.get_device("GNB{}".format(bts_id), initial_state="UNIX_LOCAL")
        ssh_cmd = vm.get_cmd(cmd_name="cat",
                             cmd_params={"path": "{}/twampd_B_36_0{}.ini".format(self.curr_dir, file_number)})
        expected = ssh_cmd()
        vm.goto_state("FCT")
        ssh_cmd = vm.get_cmd(cmd_name="cat",
                             cmd_params={"path": "/tmp/twampd.ini"})
        actual = ssh_cmd()
        error_msg = ""
        for line_ex, line_ac in zip(expected["LINES"], actual["LINES"]):
            if line_ex != line_ac:
                if not error_msg:
                    error_msg += "Unexpected line in twampd.ini:\n"
                error_msg += "expected: {}\nactual: {}\n".format(line_ex, line_ac)
        if error_msg:
            MolerTest.error(error_msg)

    @load_moler_configuration_from_tl()
    def add_twamp_object(self, scf_path):
        """
        Add Twamp objects to scf.

        :param scf_path: path to scf
        :return: None
        """
        class_name = "com.nokia.srbts.tnl:TWAMP"
        dist_name = "MRBTS-{}/TNLSVC-1/TNL-2/IPAPP-1/TWAMP-{}"
        version = "TNL5GC21A_2012_002"
        new_path = scf_path[0:-4] + "new" + scf_path[-4:]
        self.scf.load_scf(scf_path)
        for i in range(4):
            self.scf.add_object_to_scf(class_name, dist_name.format(self.gnb_id, i + 1), version, "create")
        params = [{"administrativeState": "unlocked", "destIpAddress": self.netem_ipv4, "destPort": "5018",
                   "messageSize": "100", "plrAlarmThreshold": "10000",
                   "rttAlarmThreshold": "1000000",
                   "sourceIpAddressDN": "MRBTS-{}/TNLSVC-1/TNL-2/IPNO-1/IPIF-3/IPADDRESSV4-1".format(self.gnb_id),
                   "twampDscp": "34", "enhancedMetric": "true"},
                  {"administrativeState": "locked", "destIpAddress": self.netem_ipv4, "destPort": "7",
                   "messageSize": "100", "plrAlarmThreshold": "10000",
                   "rttAlarmThreshold": "1000000",
                   "sourceIpAddressDN": "MRBTS-{}/TNLSVC-1/TNL-2/IPNO-1/IPIF-3/IPADDRESSV4-1".format(self.gnb_id),
                   "twampDscp": "34", "enhancedMetric": "true"},
                  {"administrativeState": "unlocked", "destIpAddress": self.twamp_vm_v6, "destPort": "5018",
                   "messageSize": "100", "plrAlarmThreshold": "10000",
                   "rttAlarmThreshold": "1000000",
                   "sourceIpAddressDN": "MRBTS-{}/TNLSVC-1/TNL-2/IPNO-1/IPIF-3/IPADDRESSV6-1".format(self.gnb_id),
                   "twampDscp": "34", "enhancedMetric": "true"},
                  {"administrativeState": "locked", "destIpAddress": self.twamp_vm_v6, "destPort": "7",
                   "messageSize": "100", "plrAlarmThreshold": "10000",
                   "rttAlarmThreshold": "1000000",
                   "sourceIpAddressDN": "MRBTS-{}/TNLSVC-1/TNL-2/IPNO-1/IPIF-3/IPADDRESSV6-1".format(self.gnb_id),
                   "twampDscp": "34", "enhancedMetric": "true"}]
        for i, _dict in zip(range(4), params):
            for el in _dict:
                self.scf.add_element_to_scf(dist_name.format(self.gnb_id, i + 1), el, _dict[el])
        self.scf.save_scf(new_path)
        return new_path

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions()
    def configure_responder(self, bts_id=0):
        """
        Configure ipv4 and ipv6 responder.

        :param bts_id: ID of BTS
        :return: None
        """
        vm = self._ssh_to_netem("GNB{}_cloned1".format(bts_id))
        vm2 = self._ssh_to_netem("GNB{}_cloned2".format(bts_id))
        self.twampy_cmd_ipv4[0] = vm.get_cmd(cmd_name="twampy", cmd_params={
            "options": "responder -v {}:5018 --timer 15".format(self.netem_ipv4), "prompt": "root.*"})
        self.twampy_cmd_ipv4[0].start(timeout=9999)
        self.twampy_cmd_ipv6[0] = vm2.get_cmd(cmd_name="twampy", cmd_params={
            "options": "responder -v [{}]:5018 --timer 15".format(self.twamp_vm_v6), "prompt": "root.*"})
        self.twampy_cmd_ipv6[0].start(timeout=9999)
        MolerTest.steps_end()

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions()
    def run_dbgrrc_and_start_tcpdump(self, bts_id=0):
        vm = DeviceFactory.get_cloned_device("GNB{}".format(bts_id), "GNB{}_tcpdump".format(bts_id),
                                             initial_state="PROXY_PC")
        self._ssh_to_netem("GNB{}_tcpdump".format(bts_id))
        cmd_list = ["tc filter del dev eth2", "tc qdisc del dev eth2 root"]
        for cmd in cmd_list:
            try:
                cmd_object = vm.get_cmd(cmd_name="run_script", cmd_params={"script_command": cmd, "prompt": "root.*"})
                cmd_object()
            except CommandFailure:
                pass
        self._exit_netem("GNB{}_tcpdump".format(bts_id))
        vm.goto_state("FCT")
        self.tcpdump_cmd = \
            vm.get_cmd(cmd_name="run_script",
                       cmd_params={"script_command": "dbgrrc set port 2 mtu 15360;"
                                                     " dbgrrc mirror sport 14 dport 2 e b;"
                                                     " tcpdump -ni etha01 udp port 5018 -w /tmp/twamp.pcap"})
        self.tcpdump_cmd.start(timeout=9999)
        MolerTest.steps_end()

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions()
    def stop_tcpdump(self):
        self.tcpdump_cmd.break_cmd()
        self.tcpdump_cmd.await_done()
        MolerTest.steps_end()

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions()
    def _ssh_to_netem(self, device, bts_id=0):
        """
        ssh to NetEM on provided device.

        :param bts_id: ID of BTS
        :param device: moler device
        :return: None
        """
        vm = DeviceFactory.get_cloned_device("GNB{}".format(bts_id), device, initial_state="PROXY_PC")
        ssh_cmd = vm.get_cmd(cmd_name="ssh",
                             cmd_params={"login": "ute", "password": "ute", "host": self.twamp_vm,
                                         "expected_prompt": "ute@.*"})
        ssh_cmd()
        sudo_cmd = vm.get_cmd(cmd_name="sudo",
                              cmd_params={"sudo_params": "su", "expected_prompt": "root@.*"})
        sudo_cmd()
        return vm

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions()
    def _exit_netem(self, device, bts_id=0):
        """
        Exit NetEM on provided device.

        :param bts_id: ID of BTS
        :param device: moler device
        :return: None
        """
        vm = DeviceFactory.get_device(device)
        vm2 = DeviceFactory.get_device(device)
        ssh_exit = vm.get_cmd(cmd_name="exit", cmd_params={"expected_prompt": "ute@.*"})
        ssh_exit()
        ssh_exit = vm.get_cmd(cmd_name="exit", cmd_params={"expected_prompt": "ute@.*"})
        ssh_exit()
        MolerTest.steps_end()
        return vm, vm2

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def stop_responder_and_verify_packets(self, bts_id=0):
        """
        Stop ipv4 and ipv6 responder and verify TWAMP packets.

        :param bts_id: ID of BTS
        :return: None
        """
        self.twampy_cmd_ipv4[0].break_cmd()
        output = self.twampy_cmd_ipv4[0].await_done()
        self.verify_packets(output)
        self.twampy_cmd_ipv6[0].break_cmd()
        output = self.twampy_cmd_ipv6[0].await_done()
        self.verify_packets(output)
        self._exit_netem("GNB{}_cloned1".format(bts_id))
        self._exit_netem("GNB{}_cloned2".format(bts_id))
        MolerTest.steps_end()

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def stop_responder(self, bts_id=0):
        """
        Stop ipv4 and ipv6 responder.

        :param bts_id: ID of BTS
        :return: None
        """
        self.twampy_cmd_ipv4[0].break_cmd()
        self.twampy_cmd_ipv6[0].break_cmd()
        self._exit_netem("GNB{}_cloned1".format(bts_id))
        self._exit_netem("GNB{}_cloned2".format(bts_id))
        MolerTest.steps_end()

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def simulate_echoserver(self, ip_version, bts_id=0):
        """
        Simulate ipv4 or ipv6 echoserver.

        :param ip_version: ip_v4 or ip_v6
        :param bts_id: ID of BTS
        :return: None
        """
        if ip_version.upper() == "IP_V4":
            vm = self._ssh_to_netem("GNB{}_cloned1".format(bts_id))
            self.netcat_cmd_ipv4 = vm.get_cmd(cmd_name="run_script", cmd_params={
                "script_command": "netcat -4 -e /bin/cat -u -l -p 7 -s {}".format(self.netem_ipv4),
                "prompt": "root.*"})
            self.netcat_cmd_ipv4.start(timeout=999)
        elif ip_version.upper() == "IP_V6":
            vm2 = self._ssh_to_netem("GNB{}_cloned2".format(bts_id))
            self.netcat_cmd_ipv6 = vm2.get_cmd(cmd_name="run_script", cmd_params={
                "script_command": "netcat -6 -e /bin/cat -u -l -p 7 -s {}".format(self.twamp_vm_v6),
                "prompt": "root.*"})
            self.netcat_cmd_ipv6.start(timeout=999)
        MolerTest.steps_end()

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def stop_echoserver(self, ip_version, bts_id=0):
        """
        Stop ipv4 or ipv6 echoserver.

        :param ip_version: ip_v4 or ip_v6
        :param bts_id: ID of BTS
        :return: None
        """
        if ip_version.upper() == "IP_V4":
            self.netcat_cmd_ipv4.break_cmd()
            self._exit_netem("GNB{}_cloned1".format(bts_id))
        elif ip_version.upper() == "IP_V6":
            self.netcat_cmd_ipv6.break_cmd()
            self._exit_netem("GNB{}_cloned2".format(bts_id))
        MolerTest.steps_end()

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def verify_echoserver_packets(self, bts_id=0):
        """
        Verify packets in output of tcpdump command

        :param bts_id: ID of BTS
        :return: None
        """
        device = "GNB{}_cloned3".format(bts_id)
        vm = DeviceFactory.get_cloned_device("GNB{}".format(bts_id), "GNB{}_cloned3".format(bts_id),
                                             initial_state="PROXY_PC")
        self._ssh_to_netem(device)

        self.tcpdump_cmd = vm.get_cmd(cmd_name="tcpdump", cmd_params={"options": "-ni eth2 udp", "prompt": "root.*"})
        self.tcpdump_cmd.start(timeout=25)
        MolerTest.sleep(10)
        self.tcpdump_cmd.break_cmd()
        output = self.tcpdump_cmd.await_done()
        expected = [["{}.{}".format(self.mplane_ip_v6, "5004"), "{}.{}".format(self.twamp_vm_v6, "7")],
                    ["{}.{}".format(self.gnb_ip, "5002"), "{}.{}".format(self.netem_ipv4, "7")],
                    ["{}.{}".format(self.twamp_vm_v6, "7"), "{}.{}".format(self.mplane_ip_v6, "5004")],
                    ["{}.{}".format(self.netem_ipv4, "7"), "{}.{}".format(self.gnb_ip, "5002")]]
        for i in range(1, 5):
            actual = [output[str(i)]["destination"], output[str(i)]["source"]]
            if actual not in expected:
                MolerTest.error("Incorrect tcpdump output: {}\nexpected addresses:".format(output[str(i)]),
                                dump=expected)
        self._exit_netem(device)
        MolerTest.steps_end()

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def run_tc_commands(self, ip_version, alarm_type="PLR", bts_id=0):
        """
        Run tc commands

        :param ip_version: ip_v4 or ip_v6
        :param alarm_type: PLR or RTT
        :param bts_id: ID of BTS
        :return: None
        """
        device = "GNB{}_cloned3".format(bts_id)
        vm = DeviceFactory.get_cloned_device("GNB{}".format(bts_id), "GNB{}_cloned3".format(bts_id),
                                             initial_state="PROXY_PC")
        self._ssh_to_netem(device)
        cmd_list = ["tc filter del dev eth2", "tc qdisc del dev eth2 root"]
        for cmd in cmd_list:
            try:
                cmd_object = vm.get_cmd(cmd_name="run_script", cmd_params={"script_command": cmd, "prompt": "root.*"})
                cmd_object()
            except CommandFailure:
                pass
        cmd_list = ["tc qdisc add dev eth2 root handle 1: htb default 30",
                    "tc class add dev eth2 parent 1: classid 1:1 htb rate 950mbit",
                    "tc class add dev eth2 parent 1:1 classid 1:10 htb rate 950mbit prio 1",
                    "tc class add dev eth2 parent 1:1 classid 1:30 htb rate 950mbit prio 3",
                    "tc qdisc add dev eth2 parent 1:10 netem {}".format(
                        "loss 100%" if alarm_type == "PLR" else "delay 20ms"),
                    "tc qdisc add dev eth2 parent 1:30 fq_codel",
                    "tc filter add dev eth2 parent 1: handle 11 fw classid 1:10",
                    "ip{}tables -F POSTROUTING -t mangle".format("6" if ip_version.upper() == "IP_V6" else ""),
                    "ip{}tables -A POSTROUTING -t mangle -d {} -j MARK --set-mark 11".format(
                        "6" if ip_version.upper() == "IP_V6" else "",
                        self.gnb_ip if ip_version.upper() == "IP_V4" else self.mplane_ip_v6)]
        for cmd in cmd_list:
            cmd_object = vm.get_cmd(cmd_name="run_script", cmd_params={"script_command": cmd, "prompt": "root.*"})
            cmd_object()
        self._exit_netem(device)
        MolerTest.steps_end()

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def remove_additional_delay(self, ip_version, bts_id=0):
        """
        Remove additional delay.

        :param ip_version: ip_v4 or ip_v6
        :param bts_id: ID of BTS
        :return: None
        """
        device = "GNB{}_cloned3".format(bts_id)
        vm = DeviceFactory.get_cloned_device("GNB{}".format(bts_id), "GNB{}_cloned3".format(bts_id),
                                             initial_state="PROXY_PC")
        self._ssh_to_netem(device)
        cmd_list = ["tc qdisc del dev eth2 root", "tc qdisc del dev eth2 root",
                    "ip{}tables -F POSTROUTING -t mangle".format("6" if ip_version.upper() == "IP_V6" else "")]
        for cmd in cmd_list:
            try:
                cmd_object = vm.get_cmd(cmd_name="run_script", cmd_params={"script_command": cmd, "prompt": "root.*"})
                cmd_object()
            except CommandFailure:
                pass
        self._exit_netem(device)
        MolerTest.steps_end()

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions()
    def check_dscp_value(self, value, port=5018, protocol="UDP", sleep_time=10, bts_id=0):
        """
        Remove additional delay.

        :param value: expected dscp value
        :param port: port
        :param protocol: protocol
        :param sleep_time: tshark run time
        :param bts_id: ID of BTS
        :return: None
        """
        device = "GNB{}_cloned3".format(bts_id)
        vm = DeviceFactory.get_cloned_device("GNB{}".format(bts_id), "GNB{}_cloned3".format(bts_id),
                                             initial_state="PROXY_PC")
        self._ssh_to_netem(device)
        tshark_cmd = vm.get_cmd(cmd_name="run_script",
                                cmd_params={
                                    "script_command": "tshark -f \"port {}\"  -i eth2 -i eth0 -c 8 > tmp".format(port),
                                    "prompt": "root.*"})

        tshark_cmd.start(timeout=25)
        MolerTest.sleep(sleep_time)
        tshark_cmd.break_cmd()
        tshark_cmd.await_done()
        cat_cmd = vm.get_cmd(cmd_name="cat", cmd_params={"path": "tmp", "prompt": "root.*"})
        output = cat_cmd()
        for line in output["LINES"]:
            if "Session" in line and "{} {}".format(value, protocol) not in line:
                MolerTest.error("Wrong dscp value in line:", dump=line, raise_exception=True)
        rm_cmd = vm.get_cmd(cmd_name="rm", cmd_params={"file": "tmp", "prompt": "root.*"})
        rm_cmd()
        self._exit_netem(device)

    @MolerTest.raise_background_exceptions()
    def check_twamp_counters(self, expected_1min, expected_15min, expected_txtwampmessages,
                             max_losttwampmessages=0):
        """
        Check values of twamp counters.

        :param expected_1min: expected value of 1min counter
        :param expected_15min: expected value of 15min counter
        :param expected_txtwampmessages: expected value of txtwampmessages counter
        :param max_losttwampmessages: max losttwampmessages counter value
        :return: config
        """
        params = ["avgRTT_15Min", "avgRTT_1Min", "maxRTT_15Min", "maxRTT_1Min", "minRTT_15Min", "minRTT_1Min",
                  "txTwampMessages"]
        twamp1, twamp2 = self.get_twamp_counters()
        MolerTest.info('TWAMP1 counters:', dump=twamp1)
        MolerTest.info('TWAMP2 counters:', dump=twamp2)
        error_dict = {"TWAMP1": dict(), "TWAMP2": dict()}
        error_dict = self._check_twamp_stats("1Min", params, expected_1min, twamp1, twamp2, error_dict)
        error_dict = self._check_twamp_stats("15Min", params, expected_15min, twamp1, twamp2, error_dict)
        error_dict = self._check_txtwampmessages(params, expected_txtwampmessages, twamp1, twamp2, error_dict)
        self.twamp1_params["lostTwampMessages"], self.twamp2_params["lostTwampMessages"] = self._get_losttwampmessages(
            twamp1, twamp2)
        self._check_losttwampmessages(max_losttwampmessages, error_dict)
        if error_dict["TWAMP1"] or error_dict["TWAMP2"]:
            MolerTest.error("Incorrect values of TWAMPSTATRES parameters:", dump=error_dict)

    @admin_connect
    @MolerTest.raise_background_exceptions()
    def get_twamp_counters(self):
        """
        Get values of twamp counters.

        :return: counters
        """
        dist_name = 'distName="MRBTS-{}/TNLSVC-1/TNL-2/IPAPP-1/TWAMP-{}/TWAMPSTATREQ-1/TWAMPSTATRES-1"'
        bts_configuration = self.admin.get_scf(export_type="configurationAndRuntimeObjects")
        twamp1 = str(bts_configuration).partition(dist_name.format(self.gnb_id, "1"))[2].partition('</managedObject>')[
            0]
        twamp2 = str(bts_configuration).partition(dist_name.format(self.gnb_id, "2"))[2].partition('</managedObject>')[
            0]
        return twamp1, twamp2

    @MolerTest.raise_background_exceptions()
    def _check_losttwampmessages(self, expected_losttwampmessages, error_dict):
        if self.twamp1_params["lostTwampMessages"] > int(expected_losttwampmessages):
            error_dict = self._prepare_error_dict(error_dict, "TWAMP1", "lostTwampMessages",
                                                  self.twamp1_params["lostTwampMessages"],
                                                  "<={}".format(expected_losttwampmessages))
        if self.twamp2_params["lostTwampMessages"] > int(expected_losttwampmessages):
            error_dict = self._prepare_error_dict(error_dict, "TWAMP2", "lostTwampMessages",
                                                  self.twamp2_params["lostTwampMessages"],
                                                  "<={}".format(expected_losttwampmessages))
        return error_dict

    @MolerTest.raise_background_exceptions()
    def _check_twamp_stats(self, minutes, params, expected, twamp1, twamp2, error_dict):
        for param in params:
            if minutes in param:
                twamp1_value, twamp2_value = self._get_twamp_params(param, twamp1, twamp2)
                self.twamp1_params[param] = twamp1_value
                self.twamp2_params[param] = twamp2_value
                expected_twamp1_value, expected_twamp2_value = self._get_expected_twamp_params(expected, twamp1_value,
                                                                                               twamp2_value)
                if expected_twamp1_value:
                    error_dict = self._prepare_error_dict(error_dict, "TWAMP1", param, twamp1_value,
                                                          expected)
                if expected_twamp2_value:
                    error_dict = self._prepare_error_dict(error_dict, "TWAMP2", param, twamp2_value,
                                                          expected)
        return error_dict

    @staticmethod
    def _get_twamp_params(param, twamp1, twamp2):
        twamp1_value = int(twamp1.partition('{}">'.format(param))[2].partition('</p>')[0])
        twamp2_value = int(twamp2.partition('{}">'.format(param))[2].partition('</p>')[0])
        return twamp1_value, twamp2_value

    @staticmethod
    def _get_expected_twamp_params(expected, twamp1_value, twamp2_value):
        if expected != "0":
            expected_twamp1_value = not twamp1_value
            expected_twamp2_value = not twamp2_value
        else:
            expected_twamp1_value = bool(twamp1_value)
            expected_twamp2_value = bool(twamp2_value)
        return expected_twamp1_value, expected_twamp2_value

    @MolerTest.raise_background_exceptions()
    def _check_txtwampmessages(self, params, expected, twamp1, twamp2, error_dict):
        for param in params:
            if "txTwampMessages" in param:
                twamp1_value, twamp2_value = self._get_twamp_params(param, twamp1, twamp2)
                if twamp1_value < int(expected[0]) or twamp1_value > int(expected[1]):
                    error_dict = self._prepare_error_dict(error_dict, "TWAMP1", param, twamp1_value,
                                                          expected)
                if twamp2_value < int(expected[0]) or twamp2_value > int(expected[1]):
                    error_dict = self._prepare_error_dict(error_dict, "TWAMP2", param, twamp2_value,
                                                          expected)
        return error_dict

    @MolerTest.raise_background_exceptions()
    def _get_losttwampmessages(self, twamp1, twamp2):
        twamp1_value, twamp2_value = self._get_twamp_params("lostTwampMessages", twamp1, twamp2)
        return twamp1_value, twamp2_value

    @admin_connect
    @MolerTest.raise_background_exceptions()
    def change_rtt_alarm_threshold(self, value):
        """
        Change rtt alarm threshold parameter to provided value.

        :param value: planned value of parameter
        :return: None
        """
        for i in range(1, 5):
            self.admin.perform_parameter_recommissioning(
                "MRBTS-{}/TNLSVC-1/TNL-2/IPAPP-1/TWAMP-{}".format(self.gnb_id, i),
                "rttAlarmThreshold", "update", value=value, skip_parameter_relation_errors=True)

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def introduce_jitter_and_packet_drop(self, bts_id=0):
        """
        Run tc command to introduce jitter.

        :return: None
        """
        device = "GNB{}_cloned3".format(bts_id)
        vm = DeviceFactory.get_cloned_device("GNB{}".format(bts_id), "GNB{}_cloned3".format(bts_id),
                                             initial_state="PROXY_PC")
        self._ssh_to_netem(device)
        cmd = "tc qdisc add dev eth2 root netem loss 30% delay 50ms"
        tc_cmd = vm.get_cmd(cmd_name="run_script", cmd_params={"script_command": cmd, "prompt": "root.*"})
        tc_cmd()
        self._exit_netem(device)
        MolerTest.steps_end()

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def remove_jitter_and_packet_drop(self, bts_id=0):
        """
        Run tc commands

        :param bts_id: ID of BTS
        :return: None
        """
        device = "GNB{}_cloned3".format(bts_id)
        vm = DeviceFactory.get_cloned_device("GNB{}".format(bts_id), "GNB{}_cloned3".format(bts_id),
                                             initial_state="PROXY_PC")
        self._ssh_to_netem(device)
        cmd = "tc qdisc del dev eth2 root"
        tc_cmd = vm.get_cmd(cmd_name="run_script", cmd_params={"script_command": cmd, "prompt": "root.*"})
        tc_cmd()
        self._exit_netem(device)
        MolerTest.steps_end()

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions()
    def verify_values_of_twamp_parameters_are_higher(self, bts_id=0):
        """
        Verify values of twamp parameters are higher.

        :param bts_id: ID of BTS
        :return: None
        """
        params = ["avgRTT_1Min", "maxRTT_1Min", "lostTwampMessages"]
        error_dict = {"TWAMP1": dict(), "TWAMP2": dict()}
        twamp1, twamp2 = self.get_twamp_counters()
        for param in params:
            twamp1_value, twamp2_value = self._get_twamp_params(param, twamp1, twamp2)
            if int(self.twamp1_params[param]) >= int(twamp1_value):
                error_dict = self._prepare_error_dict(error_dict, "TWAMP1", param, twamp1_value,
                                                      self.twamp1_params[param])
            if int(self.twamp2_params[param]) >= int(twamp2_value):
                error_dict = self._prepare_error_dict(error_dict, "TWAMP2", param, twamp2_value,
                                                      self.twamp2_params[param])
        if error_dict["TWAMP1"] or error_dict["TWAMP2"]:
            MolerTest.error("Current values should be higher than expected values:", dump=error_dict)

    @admin_connect
    @MolerTest.raise_background_exceptions()
    def get_pm_twamp_counters(self, overwrite=False):
        """
        Get values of pm twamp counters.

        :param overwrite: True if counter values are to be overwritten
        :return: None
        """
        twamp1 = dict()
        twamp2 = dict()
        counters = self.admin.get_pm_counters("M51331C0,M51331C1,M51331C2,M51331C3,M51331C4")
        for el in counters["TRS"]["TNL-2"]["TWAMP"]["TWAMP-1"]["TWAMP_Stats"]:
            keys = sorted(list(counters["TRS"]["TNL-2"]["TWAMP"]["TWAMP-1"]["TWAMP_Stats"][el]))
            twamp1[el] = counters["TRS"]["TNL-2"]["TWAMP"]["TWAMP-1"]["TWAMP_Stats"][el][keys[-1]]
            twamp2[el] = counters["TRS"]["TNL-2"]["TWAMP"]["TWAMP-2"]["TWAMP_Stats"][el][keys[-1]]
        res = {"Twamp1": twamp1, "Twamp2": twamp2}
        MolerTest.info("PM Counters:", dump=res)
        if overwrite:
            self.pm_twamp_counters = res
        return res

    @MolerTest.raise_background_exceptions()
    def check_pm_twamp_counters(self, expected_15min, expected_txtwampmessages, max_losttwampmessages=False):
        """
        Check values of pm twamp counters.

        :param expected_15min: expected value of 15min counter
        :param expected_txtwampmessages: expected value of txtwampmessages counter
        :param max_losttwampmessages: max value of losttwampmessages counter
        :return: None
        """
        error_dict = {"TWAMP1": dict(), "TWAMP2": dict()}
        rtt_params = ["M51331C0", "M51331C1", "M51331C2"]
        lost_param = "M51331C3"
        tx_param = "M51331C4"
        counters = self.get_pm_twamp_counters()
        self.pm_twamp_counters = counters
        for counter in counters["Twamp1"]:
            twamp1 = counters["Twamp1"][counter]
            twamp2 = counters["Twamp2"][counter]
            if counter in rtt_params:
                expected_twamp1, expected_twamp2 = self._get_expected_twamp_params(expected_15min, twamp1, twamp2)
                if expected_twamp1:
                    error_dict = self._prepare_error_dict(error_dict, "TWAMP1", counter, twamp1, expected_15min)
                if expected_twamp2:
                    error_dict = self._prepare_error_dict(error_dict, "TWAMP2", counter, twamp2, expected_15min)
            elif counter == lost_param and max_losttwampmessages:
                if twamp1 > int(max_losttwampmessages):
                    error_dict = self._prepare_error_dict(error_dict, "TWAMP1", counter, twamp1, max_losttwampmessages)
                if twamp2 > int(max_losttwampmessages):
                    error_dict = self._prepare_error_dict(error_dict, "TWAMP2", counter, twamp1, max_losttwampmessages)
            elif counter == tx_param:
                if twamp1 < int(expected_txtwampmessages[0]) or twamp1 > int(expected_txtwampmessages[1]):
                    error_dict = self._prepare_error_dict(error_dict, "TWAMP1", counter, twamp1,
                                                          expected_txtwampmessages)
                if twamp2 < int(expected_txtwampmessages[0]) or twamp2 > int(expected_txtwampmessages[1]):
                    error_dict = self._prepare_error_dict(error_dict, "TWAMP2", counter, twamp1,
                                                          expected_txtwampmessages)
        if error_dict["TWAMP1"] or error_dict["TWAMP2"]:
            MolerTest.error("Incorrect values of TWAMP counters:", dump=error_dict)

    @staticmethod
    def _prepare_error_dict(error_dict, twamp, key, current, expected):
        error_dict[twamp][key] = dict()
        error_dict[twamp][key]["current"] = current
        error_dict[twamp][key]["expected"] = expected
        return error_dict

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions()
    def compare_values_of_pm_twamp_parameters(self, expected, counters=None):
        """
        Compare counter values with previous values.

        :param expected: HIGHER or LOWER or EQUAL or UNEQUAL
        :return: None
        """
        error_dict = {"Twamp1": dict(), "Twamp2": dict()}
        params = ["M51331C0", "M51331C1", "M51331C3"] if not counters else counters
        counters = self.get_pm_twamp_counters()
        for twamp in counters:
            for counter in counters[twamp]:
                if expected.upper() == "HIGHER" and counter in params and counters[twamp][counter] <= \
                        self.pm_twamp_counters[twamp][counter]:
                    error_dict = self._prepare_error_dict(error_dict, twamp, counter, counters[twamp][counter],
                                                          self.pm_twamp_counters[twamp][counter])
                elif expected.upper() == "LOWER" and counter in params and counters[twamp][counter] > \
                        self.pm_twamp_counters[twamp][counter]:
                    error_dict = self._prepare_error_dict(error_dict, twamp, counter, counters[twamp][counter],
                                                          self.pm_twamp_counters[twamp][counter])
                elif expected.upper() == "EQUAL" and counter in params and counters[twamp][counter] != \
                        self.pm_twamp_counters[twamp][counter]:
                    error_dict = self._prepare_error_dict(error_dict, twamp, counter, counters[twamp][counter],
                                                          self.pm_twamp_counters[twamp][counter])
                elif expected.upper() == "UNEQUAL" and counter in params and counters[twamp][counter] == \
                        self.pm_twamp_counters[twamp][counter]:
                    error_dict = self._prepare_error_dict(error_dict, twamp, counter, counters[twamp][counter],
                                                          self.pm_twamp_counters[twamp][counter])
        if error_dict["Twamp1"] or error_dict["Twamp2"]:
            MolerTest.error("Current values should be {} than expected values:".format(expected), dump=error_dict)

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions()
    def wait_until_counters_change(self, timeout=900):
        """
        Wait until counters change.

        :param timeout: timeout
        :return: None
        """
        start_time = tm()
        elapsed_time = 0
        while elapsed_time < int(timeout):
            try:
                self.compare_values_of_pm_twamp_parameters("EQUAL")
            except ExecutionException as e:
                self.pm_twamp_counters = self.get_pm_twamp_counters()
                return
            MolerTest.sleep(15)
            elapsed_time = int(tm() - start_time)
        MolerTest.error("Counter values did not change in {} seconds".format(timeout))

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def configure_multiple_twamp_reflectors(self, bts_id=0):
        """
        Configure multiple twamp reflectors.

        :param bts_id: ID of BTS
        :return: None
        """
        vm = self._ssh_to_netem("GNB{}_cloned1".format(bts_id))
        self.twampy_cmd_ipv4[0] = vm.get_cmd(cmd_name="run_script", cmd_params={
            "script_command": "for i in {{1..67}} {{69..102}}; do python /home/ute/twampy.py responder"
                              " {}:$i --timer 10 & done".format(self.netem_ipv4), "prompt": "root.*"})
        self.twampy_cmd_ipv4[0].start(timeout=9999)
        MolerTest.steps_end()

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def kill_all_twampy_processes(self, bts_id=0):
        """
        Kill all twampy processes.

        :param bts_id: ID of BTS
        :return: None
        """
        vm = DeviceFactory.get_device("GNB{}_cloned1".format(bts_id))
        kill_cmd = vm.get_cmd(cmd_name="killall", cmd_params={
            "name": "python", "prompt": "root.*"})
        kill_cmd()
        self._exit_netem("GNB{}_cloned1".format(bts_id))
        MolerTest.steps_end()

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions()
    def verify_sessions(self, sessions, version="5G22R1", sleep_time=15, bts_id=0):
        """
        Verify sessions.

        :param sessions: number of sessions
        :param version: "5G21B" or "5G22R1"
        :param sleep_time: tshark run time
        :param bts_id: ID of BTS
        :return: None
        """
        device = "GNB{}_cloned3".format(bts_id)
        vm = DeviceFactory.get_cloned_device("GNB{}".format(bts_id), "GNB{}_cloned3".format(bts_id),
                                             initial_state="PROXY_PC")
        self._ssh_to_netem(device)
        tshark_cmd = vm.get_cmd(cmd_name="run_script",
                                cmd_params={"script_command": "tshark -f  \"host {}\" -i eth2 -d"
                                                              "udp.port==5000-5900,twamp -T fields"
                                                              " -e udp.srcport > tmp".format(self.mplane_ip),
                                            "prompt": "root@.*"})
        tshark_cmd.start(timeout=25)
        MolerTest.sleep(int(sleep_time))
        tshark_cmd.break_cmd()
        tshark_cmd.await_done()
        MolerTest.sleep(0.5)
        cat_cmd = vm.get_cmd(cmd_name="cat", cmd_params={"path": "tmp", "prompt": "root@.*"})
        tshark = cat_cmd()
        rm_cmd = vm.get_cmd(cmd_name="rm", cmd_params={"file": "tmp", "prompt": "root.*"})
        rm_cmd()
        self._exit_netem(device)
        self._check_twamp_ports(tshark, sessions, version)

    @staticmethod
    @MolerTest.raise_background_exceptions()
    def _check_twamp_ports(tshark_output, number_of_sessions, version):
        port_list = Twamp.get_port_list(tshark_output, version)
        expected_list = list(range(5001, 5011)) + list(range(5021, 5011 + int(number_of_sessions)))
        error_list = list()
        for x in expected_list:
            if x not in port_list:
                error_list.append(x)
        if error_list:
            MolerTest.error("No expected sessions on ports:", dump=error_list)

    @staticmethod
    def get_port_list(tshark_output, version):
        port_list = list()
        if version == "5G21B":
            for port in tshark_output["LINES"]:
                port_list.append(int(port))
        elif version == "5G22R1":
            for el in tshark_output["LINES"]:
                port = re.search(r".*\s\s(?P<PORT>\d+)\s.*", el)
                if port:
                    port_list.append(int(port.group("PORT")))
        return port_list

    @load_moler_configuration_from_tl()
    def add_twamp_100(self, scf_path):
        """
        Add Twamp objects to scf.

        :param scf_path: path to scf
        :return: None
        """
        class_name = "com.nokia.srbts.tnl:TWAMP"
        dist_name = "MRBTS-{}/TNLSVC-1/TNL-2/IPAPP-1/TWAMP-100"
        version = "TNL5GC21A_2012_002"
        new_path = scf_path[0:-4] + "new" + scf_path[-4:]
        self.scf.load_scf(scf_path)
        self.scf.add_object_to_scf(class_name, dist_name.format(self.gnb_id), version, "create")
        params = {"administrativeState": "unlocked", "destIpAddress": self.netem_ipv4, "destPort": "100",
                  "enhancedMetric": "false", "messageSize": "100", "plrAlarmThreshold": "10000",
                  "rttAlarmThreshold": "1000000",
                  "sourceIpAddressDN": "MRBTS-{}/TNLSVC-1/TNL-2/IPNO-1/IPIF-1/IPADDRESSV4-1".format(self.gnb_id),
                  "twampDscp": "37"}
        for param in params:
            self.scf.add_element_to_scf(dist_name.format(self.gnb_id), param, params[param])
        self.scf.save_scf(new_path)
        return new_path

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def configure_multiple_twamp_senders(self, number_of_senders, port, ingress=1, port1=False, options=None,
                                         bts_id=0):
        """
        Configure multiple twamp senders.

        :param number_of_senders: number of senders to configure
        :param port: port
        :param ingress: ingress value
        :param port1: true if sender ports start with 1
        :param options: additional options
        :param bts_id: ID of BTS
        :return: None
        """
        vm = self._ssh_to_netem("GNB{}_cloned1".format(bts_id))
        self.twampy_cmd_ipv4[0] = vm.get_cmd(cmd_name="run_script", cmd_params={
            "script_command": "for i in {{1..{}}}; do python twampy.py sender -i {} {} {}:{} {}:{}$i& done"
                              " > tmp".format(number_of_senders, ingress, options, self.mplane_ip, port, self.twamp_vm,
                                              "" if port1 else "500"),
            "prompt": "root.*"})
        self.twampy_cmd_ipv4[0].start(timeout=9999)
        MolerTest.steps_end()

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions()
    def check_dropped_packets(self, min_dropped_percentage, max_dropped_percentage, bts_id=0):
        """
        Check dropped packets.

        :param min_dropped_percentage: min dropped packet in %
        :param max_dropped_percentage: max dropped packet in %
        :param bts_id: ID of BTS
        :return: None
        """
        device = "GNB{}_cloned1".format(bts_id)
        vm = self._ssh_to_netem(device)
        cat_cmd = vm.get_cmd(cmd_name="cat", cmd_params={"path": "tmp", "prompt": "root@.*"})
        twampy = cat_cmd()
        rm_cmd = vm.get_cmd(cmd_name="rm", cmd_params={"file": "tmp", "prompt": "root.*"})
        rm_cmd()
        self._exit_netem(device)
        self._check_dropped_packets(twampy, min_dropped_percentage, max_dropped_percentage)

    @MolerTest.raise_background_exceptions()
    def _check_dropped_packets(self, twampy_output, min_dropped_percentage, max_dropped_percentage):
        twampy = twampy_output["LINES"]
        loss = 0
        senders = 0
        for line in twampy:
            if "Roundtrip" in line:
                seq = re.search(r".*\s(?P<LOSS>\d+\.\d+)%", line)
                loss += float(seq.group("LOSS"))
                senders += 1
                MolerTest.info(line)
                MolerTest.info(loss)
                MolerTest.info(seq.group("LOSS"))
        if not senders:
            MolerTest.error("No packets received", raise_exception=True)
        loss = loss / senders
        MolerTest.info(loss)
        if loss > int(max_dropped_percentage):
            MolerTest.error("More dropped packets ({}%) than expected ({}%)."
                            .format(loss, max_dropped_percentage), raise_exception=True)
        elif loss < int(min_dropped_percentage):
            MolerTest.error("Fewer dropped packets ({}%) than expected ({}%)."
                            .format(loss, min_dropped_percentage), raise_exception=True)

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions()
    def check_received_packets(self, min_dropped_percentage, max_dropped_percentage, bts_id=0):
        """
        Check received packets.

        :param min_dropped_percentage: min dropped packet in %
        :param max_dropped_percentage: max dropped packet in %
        :param bts_id: ID of BTS
        :return: None
        """
        device = "GNB{}_cloned1".format(bts_id)
        vm = self._ssh_to_netem(device)
        cat_cmd = vm.get_cmd(cmd_name="cat", cmd_params={"path": "tmp", "prompt": "root@.*"})
        twampy = cat_cmd()
        rm_cmd = vm.get_cmd(cmd_name="rm", cmd_params={"file": "tmp", "prompt": "root.*"})
        rm_cmd()
        self._exit_netem(device)
        self._check_received_packets(twampy, min_dropped_percentage, max_dropped_percentage)

    @MolerTest.raise_background_exceptions()
    def _check_received_packets(self, twampy_output, min_dropped_percentage, max_dropped_percentage):
        sent_counter = 0
        received_counter = 0
        for line in twampy_output["LINES"]:
            if "short packet received: 14 bytes" in line:
                received_counter += 1
            elif "Sent to {}".format(self.mplane_ip):
                sent_counter += 1
        min_received = sent_counter - int(sent_counter * int(max_dropped_percentage) / 100)
        max_received = sent_counter - int(sent_counter * int(min_dropped_percentage) / 100)
        if received_counter < min_received:
            MolerTest.error("More dropped packets than expected: received={} min_received={}"
                            .format(received_counter, min_received, ), raise_exception=True)
        elif received_counter > max_received:
            MolerTest.error("Fewer dropped packets than expected: received={} max_received={}"
                            .format(received_counter, max_received), raise_exception=True)
        if sent_counter == 0:
            MolerTest.error("No packets sent", raise_exception=True)

    @admin_connect
    @MolerTest.raise_background_exceptions()
    def get_iprmdroppedpacketsratelimiting_counter(self):
        """
        Get value of ipRmDroppedPacketsRateLimiting counters.

        :return: None
        """

        counter = self.admin.get_pm_counters("M51328C0")
        MolerTest.info(counter)
        keys = sorted(list(counter["TRS"]["TNL-2"]["IPNO"]["IPNO-1"]["IP_filtering_Stats"]["M51328C0"]))
        res = counter["TRS"]["TNL-2"]["IPNO"]["IPNO-1"]["IP_filtering_Stats"]["M51328C0"][keys[-1]]
        MolerTest.info("ipRmDroppedPacketsRateLimiting Counter:", dump=res)
        return res

    @MolerTest.raise_background_exceptions()
    def verify_iprmdroppedpacketsratelimiting_counter_is_higher(self, counter):
        """
        Verify value of ipRmDroppedPacketsRateLimiting counter is higher than before.

        :param counter: previous value of counter
        :return: None
        """
        current = self.get_iprmdroppedpacketsratelimiting_counter()
        if int(counter) >= current:
            MolerTest.error(
                "Current value of ipRmDroppedPacketsRateLimiting counter ({})"
                " is not greater than last value ({})".format(current, counter), raise_exception=True)

    @MolerTest.raise_background_exceptions()
    def wait_for_counter_change(self):
        minutes = datetime.now().minute
        sleep_time = (61 - minutes if minutes >= 30 else 31 - minutes) * 60
        MolerTest.sleep(sleep_time)
