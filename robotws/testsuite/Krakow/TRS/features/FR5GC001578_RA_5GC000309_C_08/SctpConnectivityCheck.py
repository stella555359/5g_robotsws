from moler.util.moler_test import MolerTest
from moler.device import DeviceFactory
from taf.ul.sc.perf.devices.bts.coam import login_logout
from taf.rfrl.utilities.tl_config import load_moler_configuration_from_tl
from taf.rfrl.bts.devices.cu.cu_operations import CuOperations
from taf.rfrl.bts.connections import device_aliases as connection_names


class SctpConnectivityCheck(CuOperations):
    def __init__(self):
        super(SctpConnectivityCheck, self).__init__()
        self.iptables_sctp_rule = False

    @login_logout
    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions()
    def Ssh_To_Cpif_Then_Execute_Ip_Tables_And_Tcpdump(self, password, bts_id=0):
        """
        Ssh to CPIF, Block SCTP connection between DU and CU, Verify on tcpdump, that connection is terminated (ABORT)
        :return: None
        """
        bts = DeviceFactory.get_device(format(connection_names.ssh_gnb_cu.format(bts_id)))
        bts.goto_state(state="CPIF")

        iptables_cmd = bts.get_cmd(cmd_name="iptables",
                                   cmd_params={"options": "-I INPUT 1 -i fronthaul -p sctp -j DROP",
                                               "v6": True})

        cmd_sudo = bts.get_cmd(cmd_name="sudo", cmd_params={"password": password, "cmd_object": iptables_cmd})
        cmd_sudo()
        self.iptables_sctp_rule = True

        tcpdump_cmd = bts.get_cmd(cmd_name="tcpdump", cmd_params={"options": "-ni fronthaul ",
                                                                  "break_exec_regex": r"\[ABORT\]"
                                                                  })

        cmd_sudo = bts.get_cmd(cmd_name="sudo", cmd_params={"password": password, "cmd_object": tcpdump_cmd})
        res = cmd_sudo(timeout=360)

    @login_logout
    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions()
    def Unblock_Sctp_Connection(self, password, bts_id=0):
        """
        Unblock SCTP connection between DU and CU
        :return: None
        """
        bts = DeviceFactory.get_device(format(connection_names.ssh_gnb_cu.format(bts_id)))
        iptables_cmd = bts.get_cmd(cmd_name="iptables", cmd_params={"options": "-D INPUT 1", "v6": True})
        cmd_sudo = bts.get_cmd(cmd_name="sudo", cmd_params={"password": password, "cmd_object": iptables_cmd})
        cmd_sudo()
        self.iptables_sctp_rule = False

    @login_logout
    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions()
    def clear_iptables(self, password, bts_id=0):
        """
        Delete iptables rule if it is still present at the end of the test.

        :return: None
        """
        bts = DeviceFactory.get_device(format(connection_names.ssh_gnb_cu.format(bts_id)))
        if self.iptables_sctp_rule:
            iptables_cmd = bts.get_cmd(cmd_name="iptables", cmd_params={"options": "-D INPUT 1",
                                                                        "v6": True})
            cmd_sudo = bts.get_cmd(cmd_name="sudo", cmd_params={"password": password, "cmd_object": iptables_cmd})
            cmd_sudo()
