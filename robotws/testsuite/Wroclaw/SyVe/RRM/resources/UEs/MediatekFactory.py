from testsuite.Wroclaw.SyVe.RRM.resources.TestEnvData import TestEnvData as Env
from testsuite.Wroclaw.SyVe.RRM.resources.UEs.AdbUeBase import AdbUeBase
from testsuite.Wroclaw.SyVe.RRM.resources.UEs.AdbCommands import AdbCommands
from testsuite.Wroclaw.SyVe.RRM.resources.Logger import Logger
from testsuite.Wroclaw.SyVe.RRM.resources.Ssh import execute_ssh_command
from time import sleep


class MediatekFactory(AdbUeBase):

    def __init__(self, id_):
        super(MediatekFactory, self).__init__(id_)
        self.ue_sn = "MTK_" + Env.testline_name().split("_")[-1]
        self.appserver.ue_sn = self.ue_sn
        self.appserver.log_prefix = "LOG_{}_".format(self.ue_sn)
        self.appserver.err_prefix = "ERR_{}_".format(self.ue_sn)
        self.appserver.client_file_prefix = self.appserver.log_prefix + "CLIENT_APPSERV_"
        self.appserver.server_file_prefix = self.appserver.log_prefix + "SERVER_APPSERV_"
        self.appserver.err_server_file_prefix = self.appserver.err_prefix + "SERVER_APPSERV_"
        self.appserver.err_client_file_prefix = self.appserver.err_prefix + "CLIENT_APPSERV_"
        self.ue_serial = self.ue.serial_number
        self.adb = AdbCommands(self.ue_serial, self.get_iperf_path())
        self.name = f"UE_{self.id}: {self.ue_sn}"

    def wait_for_ue_rebooted(self):
        self.ue_pc_ssh = Env().UES[self.ute_id].ssh_connection_details
        timeout = 121
        interval = 5
        for attempt in range(0, timeout, interval):
            sleep(interval)
            connected_devices = self._execute_adb_command(self.adb.devices)
            if self.ue_serial in connected_devices:
                Logger.info("{} - restarted after {}s".format(self.ue_sn, attempt+interval))
                return
        assert False, "UE '{}' missing after {}".format(self.ue_serial, timeout)

    def _make_sure_ue_is_authorized(self):
        self.ue_pc_ssh = Env().UES[self.ute_id].ssh_connection_details
        connected_devices = self._execute_adb_command(self.adb.devices)
        assert self.ue_serial in connected_devices, f"UE {self.ue_serial} not found!!!\n{connected_devices}"
        if "unauthorized" in connected_devices:
            self._execute_adb_command(self.adb.kill_server)
        self._execute_adb_command(self.adb.kill_all_iperf)

    def _wait_for_ue_is_rebooting(self):
        timeout = 20
        interval = 1
        for attempt in range(0, timeout, interval):
            sleep(interval)
            connected_devices = self._execute_adb_command(self.adb.devices)
            if self.ue_serial not in connected_devices:
                Logger.info("{} - rebooting...".format(self.ue_serial))
                return
        assert False, f"UE '{self.ue_serial}' is not rebooting after {timeout}"

    def _ping_appserver(self):
        ping_appserver = f"(nohup adb -s {self.ue_serial} shell ping -c {self.time_for_ping_traffic} -i 1 " \
                         f"{self.connection} 1> {self.ping_log_name} 2>{self.err_ping_log_name} &); exit"
        execute_ssh_command(self.ue_pc_ssh, ping_appserver)
        Logger.info(f"Ping traffic is started from ue to appserver, time for traffic: {self.time_for_ping_traffic}s")
