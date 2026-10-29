from testsuite.Wroclaw.SyVe.RRM.resources.Logger import Logger
from testsuite.Wroclaw.SyVe.RRM.resources.UEs.AdbUeBase import AdbUeBase
from time import sleep
import re

ADB_AT_CMD_SUCCESS = "OK"
ADB_AT_CMD_ERROR = "ERROR"
ADB_AT_CMD_FAILURE_MSG = "AT command '{}' not successful via ADB\n{}"
ADB_AT_HANDLING_TIME = 5


class CompalAtAdbFactory(AdbUeBase):

    def __init__(self, id_):
        super(CompalAtAdbFactory, self).__init__(id_)
        self.name = "UE_{}: Compal {}".format(self.id, self.ue_sn)

    def attach(self):
        Logger.info("{} - attaching...".format(self.name))
        self._execute_at_command_via_adb(self.adb.at_cli_cfun_attach)
        workaround_pause_between_commands = 3
        sleep(workaround_pause_between_commands)
        self._execute_at_command_via_adb(self.adb.at_cli_cops_attach)
        self._execute_at_command_via_adb(self.adb.at_cli_cgatt_attach)
        self._wait_for_ue_ip_address(timeout=30, interval=3)

    def detach(self):
        if not self.is_prepared:
            Logger.warning("UE {} was not prepared, please check with adb is it on the devices list".format(self.name))
            return
        if AdbUeBase.UE_IP_ADDRESS_FIRST_OCTETS in self._execute_adb_command(self.adb.at_cli_get_cgpaddr):
            self.verify_ue_ip()
        elif "CFUN: 4" in self._execute_adb_command(self.adb.at_cli_get_cfun):
            Logger.info("{} - Already detached".format(self.name))
            return
        Logger.info("{} - detaching...".format(self.name))
        self._execute_at_command_via_adb(self.adb.at_cli_cops_detach)
        self._execute_at_command_via_adb(self.adb.at_cli_cfun_detach)
        self._wait_for_cleared_ue_ip_address()
        self.ue_ip = None

    def _wait_for_ue_ip_address(self, timeout=20, interval=1):
        while timeout > 0:
            output = self._execute_adb_command(self.adb.at_cli_get_cgpaddr)
            if AdbUeBase.UE_IP_ADDRESS_FIRST_OCTETS in output:
                Logger.info("{} - IP {} assigned (UE attached)".format(self.name, self.ue_ip))
                return
            sleep(interval)
            timeout -= interval
        assert False, "{} - Ue IP not assigned, UE not attached".format(self.name)

    def _wait_for_cleared_ue_ip_address(self, timeout=20, interval=1):
        while timeout > 0:
            output = self._execute_adb_command(self.adb.at_cli_get_cgpaddr)
            if AdbUeBase.UE_IP_ADDRESS_FIRST_OCTETS not in output:
                Logger.info("{} - IP removed (UE detached)".format(self.name))
                return
            sleep(interval)
            timeout -= interval
        assert False, "{} - Ue IP still assigned. Ue not detached".format(self.name)

    def _get_ue_ip(self):
        output = self._execute_adb_command(self.adb.at_cli_get_cgpaddr)
        ue_ips = re.search(r'({}\.\d+\.\d+)'.format(AdbUeBase.UE_IP_ADDRESS_FIRST_OCTETS), output)
        assert ue_ips, \
            "UE {} has lost connection to the base station".format(self.name)
        Logger.info("{} - IP address: {}".format(self.name, ue_ips.group(0)))
        return ue_ips.group(0)

    def _execute_at_command_via_adb(self, command):
        for _ in range(3):
            output = self._execute_adb_command(command)
            assert ADB_AT_CMD_ERROR not in output, ADB_AT_CMD_FAILURE_MSG.format(command, output)
            if ADB_AT_CMD_SUCCESS in output:
                Logger.debug("Command '{}' executed".format(command))
                break
            sleep(ADB_AT_HANDLING_TIME)
            Logger.debug("Retrying {} command".format(command))
