# -*- coding: utf-8 -*-
"""
Generic keywords for BTS.

:copyright: Nokia Networks
:author: I_MN_5GSC_KRK_AUTO
:contact: I_MN_5GSC_KRK_AUTO@internal.nsn.com
:maintainer: I_MN_5GSC_KRK_AUTO
:contact: I_MN_5GSC_KRK_AUTO@internal.nsn.com

"""
from moler.util.moler_test import MolerTest
from moler.device import DeviceFactory
from moler.exceptions import DeviceFailure, CommandTimeout, CommandFailure
from testsuite.Bangalore.ORAN.resources.python.Macro.Python.\
    exceptions import AaShellConnectionEstablished, F1LinkNotTerminated
from testsuite.Bangalore.ORAN.resources.python.Macro.Python.\
    bts.generic_bts import GenericBts
from testsuite.Bangalore.ORAN.resources.python.Macro.Python.\
    utilities import load_moler_configuration_from_tl
from testsuite.Bangalore.ORAN.resources.python.Macro.Python \
    import connection_names


class GenericLink(GenericBts):
    """Link keywords for eNB and gNB"""

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def verify_sctp_connection_is_active(self, bts_id=0, du_id=0):
        """
        Verify if SCTP Xp link socket stream exists and it's state
        is marked as ESTAB.

        :param bts_id: ID of BTS
        :param du_id: DU id(Distributed Unit) - id related to Test
        Line configuration - gnb.dus[]
        :return: True or False
        """
        device_name = self.ssh_alias.format(bts_id, du_id)
        bts = DeviceFactory.get_device(device_name)
        bts.goto_state("FCT")
        cmd_ss = bts.get_cmd(cmd_name="ss")
        result = cmd_ss()
        for connection_id in range(len(result["NETWORK_CONNECTIONS"])):
            try:
                if result["NETWORK_CONNECTIONS"][connection_id]["streams"]:
                    for stream_id in \
                            range(len(result["NETWORK_CONNECTIONS"][
                                          connection_id]["streams"])):
                        state = result["NETWORK_CONNECTIONS"][connection_id][
                            "streams"][stream_id]["state"]
                        xp_link_port = result["NETWORK_CONNECTIONS"][
                            connection_id]["streams"][stream_id]["local_port"]
                        if state == "ESTAB" and xp_link_port == "32742":
                            MolerTest.steps_end()
                            return True
                        else:
                            continue
                else:
                    continue
            except KeyError:
                continue
        MolerTest.steps_end()
        return False

    @load_moler_configuration_from_tl()
    def break_sctp_connectivity_between_enb_and_gnb(
            self, bts_id=0, du_id=0):
        """
        Verify sctp connection is active on device then block sctp
        protocol by firewall rule.

        :param bts_id: ID of BTS
        :param du_id: DU id(Distributed Unit) - id related to Test
         Line configuration - gnb.dus[]
        :return: None
        """
        if self.verify_sctp_connection_is_active(bts_id, du_id):
            device_name = self.ssh_alias.format(bts_id, du_id)
            gnb = DeviceFactory.get_device(device_name)
            gnb.goto_state("FCT")
            cmd_iptables = gnb.get_cmd(
                cmd_name="iptables",
                cmd_params={"options": "-I INPUT 1 -p sctp -j DROP"})
            cmd_iptables()
            MolerTest.info("SCTP connection blocked via firewall rule")
        else:
            MolerTest.error("SCTP connection is not active so it "
                            "cannot be terminated")

    @load_moler_configuration_from_tl()
    def restore_sctp_connectivity_between_enb_and_gnb(
            self, bts_id=0, du_id=0):
        """
        Verify sctp connection is inactive on device then unblock
        sctp protocol by firewall rule.

        :param bts_id: ID of BTS
        :param du_id: DU id(Distributed Unit) - id related to Test
        Line configuration - gnb.dus[]
        :return: None
        """
        if not self.verify_sctp_connection_is_active(bts_id, du_id):
            device_name = self.ssh_alias.format(bts_id, du_id)
            bts = DeviceFactory.get_device(device_name)
            bts.goto_state("FCT")
            cmd_iptables = bts.get_cmd(
                cmd_name="iptables",
                cmd_params={"options": "-I INPUT 1 -p sctp -j ACCEPT"})
            cmd_iptables()
            MolerTest.info("SCTP connection unblocked via firewall rule")
        else:
            MolerTest.error("SCTP connection is active so it cannot"
                            " be restored")

    def verify_sctp_connection_has_been_terminated(self, bts_id=0, du_id=0):
        """
        Verify if SCTP Xp link socket on device is NOT marked as ESTAB.

        :param bts_id: ID of BTS
        :param du_id: DU id(Distributed Unit) - id related to Test
         Line configuration - gnb.dus[]
        :return: None
        """
        if not self.verify_sctp_connection_is_active(bts_id, du_id):
            MolerTest.info("SCTP connection on Xp link has been terminated")
        else:
            raise MolerTest.error("SCTP connection on Xp link is still active")

    @load_moler_configuration_from_tl()
    def _verify_aashell_connection(
            self, bts_id=0, bts_ip='192.168.255.129', port='15007',
            timeout=20, du_id=0):
        """
        Verify AaShell connection

        :param bts_id: ID of BTS
        :param du_id: DU id(Distributed Unit) - id related to Test
        Line configuration - gnb.dus[]
        :param bts_ip: Ip address of BTS
        :param port: Port number
        :param timeout: Time to wait for positive procedure
        result
        """
        device_name = self.ssh_alias.format(bts_id, du_id)
        bts = DeviceFactory.get_device(device_name)
        try:
            bts.goto_state(state="PROXY_PC")
        except DeviceFailure:
            bts.goto_state(state="UNIX_LOCAL")

        telnet = bts.get_cmd(
            cmd_name="telnet", cmd_params={'host': bts_ip,
                                           'port': port,
                                           'expected_prompt': 'AaShell>'})
        telnet(timeout=timeout)

    def verify_aashell_connection_is_active(
            self, bts_id=0, bts_ip='192.168.255.129', port='15007',
            timeout=20,
            du_id=0):

        """
                Verify if connection to AaShell is established

                :param bts_id: ID of BTS
                :param du_id: DU id(Distributed Unit) - id related to Test
                Line configuration - gnb.dus[]
                :param bts_ip: Ip address of BTS
                :param port: Port number
                :param timeout: Time to wait for positive procedure result
                """
        self._verify_aashell_connection(bts_id, bts_ip, port, timeout, du_id)

    def verify_aashell_connection_is_not_active(
            self, bts_id=0, bts_ip='192.168.255.129', port='15007',
            timeout=20,
            du_id=0):
        """
        Verify if connection to AaShell is not established

        :param bts_id: ID of BTS
        :param du_id: DU id(Distributed Unit) - id related to
         Test Line configuration - gnb.dus[]
        :param bts_ip: Ip address of BTS
        :param port: Port number
        :param timeout: Time to wait for positive procedure result
        """
        try:
            self._verify_aashell_connection(
                bts_id, bts_ip, port, timeout, du_id)
            raise AaShellConnectionEstablished("Connection"
                                               " to AaShell should not be "
                                               "established")
        except (CommandTimeout, CommandFailure):
            MolerTest.info(msg="Connection to AaShell is"
                               " not established")

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def verify_f1_link_is_active(self, bts_id=0, du_id=0):
        """
        Verify if SCTP F1 link socket stream exists and it's
        state is marked as ESTAB.

        :param bts_id: ID of BTS
        :param du_id: DU id(Distributed Unit) - id related to
        Test Line configuration - gnb.dus[]
        :return: True or False
        """
        device_name = connection_names.ssh_gnb_cu.format(bts_id)
        bts = DeviceFactory.get_device(device_name)
        bts.goto_state("CPIF")
        cmd_ss = bts.get_cmd(cmd_name="ss")
        result = cmd_ss()
        for row in result["NETWORK_CONNECTIONS"]:
            if 'streams' in row:
                for stream_id in row["streams"]:
                    state = str(stream_id["state"])
                    f1_link_port = int(stream_id["local_port"])
                    if state == "ESTAB" and f1_link_port == 38472:
                        MolerTest.steps_end()
                        return True
        MolerTest.steps_end()
        return False

    @load_moler_configuration_from_tl()
    def break_f1_link_between_cu_and_du(self, bts_id=0, du_id=0):
        """
        Verify f1 connection is active on device then block sctp
        protocol by firewall rule.

        :param bts_id: ID of BTS
        :param du_id: DU id(Distributed Unit) - id related to Test
         Line configuration - gnb.dus[]
        :return: None
        """
        device_name = connection_names.ssh_gnb_cu.format(bts_id)
        bts = DeviceFactory.get_device(device_name)
        bts.goto_state("CPIF")
        cmd_iptables = bts.get_cmd(cmd_name="iptables",
                                   cmd_params={"options": "-t "
                                                          "filter -A "
                                                          "OUTPUT -p "
                                                          "sctp --dport "
                                                          "38472 -j DROP"})
        break_f1_link = bts.get_cmd(cmd_name="sudo",
                                    cmd_params={"cmd_object": cmd_iptables})
        break_f1_link()
        MolerTest.info("F1 connection blocked via firewall rule")

    @load_moler_configuration_from_tl()
    def restore_f1_link_between_cu_and_du(self, bts_id=0, du_id=0):
        """
        Verify f1 connection is inactive on device then unblock
         sctp protocol by firewall rule.

        :param bts_id: ID of BTS
        :param du_id: DU id(Distributed Unit) - id related to Test
         Line configuration - gnb.dus[]
        :return: None
        """
        device_name = connection_names.ssh_gnb_cu.format(bts_id)
        bts = DeviceFactory.get_device(device_name)
        bts.goto_state("CPIF")
        cmd_iptables = bts.get_cmd(
            cmd_name="iptables", cmd_params={"options": "-t filter -F OUTPUT"})
        restore_f1_link = bts.get_cmd(cmd_name="sudo",
                                      cmd_params={"cmd_object": cmd_iptables})
        restore_f1_link()
        MolerTest.info("F1 connection unblocked via firewall rule")

    def verify_f1_link_has_been_terminated(self, bts_id=0, du_id=0):
        """
        Verify if SCTP F1 link socket on device is NOT marked as ESTAB.

        :param bts_id: ID of BTS
        :param du_id: DU id(Distributed Unit) - id related to Test
         Line configuration - gnb.dus[]
        :return: None
        """
        if not self.verify_f1_link_is_active(bts_id, du_id):
            MolerTest.info("SCTP connection on F1 link has been terminated")
        else:
            raise F1LinkNotTerminated("SCTP connection on F1 "
                                      "link is still active")


class EnbLink(GenericLink):
    """Class contains Link keywords for eNB"""

    bts_type = 'ENB'

    def __init__(self):
        """
        Constructor of Enb class.

        """

        super(EnbLink, self).__init__(bts_type=EnbLink.bts_type)


class GnbLink(GenericLink):
    """Class contains Link keywords for gNB"""

    bts_type = 'GNB'

    def __init__(self):
        """
        Constructor of Gnb class.

        """
        super(GnbLink, self).__init__(bts_type=GnbLink.bts_type)
