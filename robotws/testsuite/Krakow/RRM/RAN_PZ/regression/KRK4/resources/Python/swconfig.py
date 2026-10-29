from taf.transport.ssh import ssh
from robot.api import logger
import abc
from moler.device import DeviceFactory
from taf.rfrl.utilities.tl_config import load_moler_configuration_from_tl

ABC = abc.ABCMeta('ABC', (object,), {'__slots__': ()})  # compatible with Python 2 *and* 3


def execute_command_on_the_remote(cmd, hostname, username="toor4nsn", password="oZPS0POrRieRtu"):
    """Wrapper for taf ssh library remote command execution.

    :param cmd: string of command to execute
    :param hostname: hostname of the remote
    :param username: username of the remote
    :param password: password of the remote
    :return: Tuple(exit_code, output)
    """
    ssh_instance = ssh()
    ssh_instance.connect_to(hostname=hostname, username=username, password=password)
    output = ssh_instance.execute(cmd)
    rc = ssh_instance.get_exit_status()
    ssh_instance.disconnect()
    return rc, output


@load_moler_configuration_from_tl()
def execute_command_on_the_remote_via_moler(cmd, hostname, username="toor4nsn", password="oZPS0POrRieRtu", bts_id=0):
    vm = DeviceFactory.get_device("GNB{}".format(bts_id), initial_state="UNIX_LOCAL")
    ssh_cmd = vm.get_cmd(cmd_name="ssh",
                         cmd_params={"login": username, "password": password, "host": hostname,
                                     "expected_prompt": "root@.*"})
    ssh_cmd()
    vm.get_cmd(cmd_name="run_script", cmd_params={"script_command": cmd})()


class RemoteFileManager(ABC):
    UNIT = None
    UNIT_ADDRESS = None

    @abc.abstractmethod
    def run_on_unit(self, cmd):
        return execute_command_on_the_remote(cmd, hostname=self.UNIT_ADDRESS, username="toor4nsn",
                                             password="oZPS0POrRieRtu")

    def run_on_unit_via_moler(self, cmd):
        return execute_command_on_the_remote_via_moler(cmd, hostname=self.UNIT_ADDRESS, username="toor4nsn",
                                                       password="oZPS0POrRieRtu")

    def append_line_to_file(self, line, file_path):
        cmd = 'echo -e "\n{}" >> {}'.format(line, file_path)
        rc, output = self.run_on_unit(cmd)
        return rc, output

    def is_string_in_file(self, string, file_path):
        cmd = 'grep -i "{}" {}'.format(string, file_path)
        rc, output = self.run_on_unit(cmd)
        return True if rc == 0 else False

    def delete_line_with_flag(self, flag, file_path):
        cmd = "sed -i '/{}/d' {}".format(flag, file_path)
        rc, output = self.run_on_unit(cmd)
        return rc, output

    def replace_pattern_in_file(self, sed_bre_regex, string, file_path):
        cmd = "sed -i 's/{}/{}/' {}".format(sed_bre_regex, string, file_path)
        rc, output = self.run_on_unit(cmd)
        return rc, output


class SwconfigManagerBase(RemoteFileManager):
    def run_on_unit(self, cmd):
        return super(SwconfigManagerBase, self).run_on_unit(cmd)

    def _is_flag_in_swconfig(self, flag):
        return self.is_string_in_file('^' + flag, '/ffs/run/swconfig.txt')

    def _is_flag_with_value_in_swconfig(self, flag_hex, value):
        return self.is_string_in_file('^' + flag_hex + "=" + value, '/ffs/run/swconfig.txt')

    def _add_flag_to_swconfig(self, flag):
        self.append_line_to_file(flag, '/ffs/run/swconfig.txt')

    def delete_flags_from_swconfig(self, flags):
        """
        :param flags: list of flags with their values, all in string, like so:
            ['0x10040=1', '0x10043=0xC739', '0x10042=0xC0A8FF7E']
        :type flags: list

        """
        for flag in flags:
            self.delete_line_with_flag(flag, '/ffs/run/swconfig.txt')

    def _replace_flag_value_in_swconfig(self, flag_hex, value):
        flag = flag_hex + "=" + value
        self.replace_pattern_in_file(r'^{}=[[:alnum:]_]\{{1,\}}'.format(flag_hex), flag, '/ffs/run/swconfig.txt')

    def _ensure_swconfig_flag_with_value_exists(self, flag):
        flag_hex, value = flag.split("=")
        if not self._is_flag_in_swconfig(flag_hex):
            self._add_flag_to_swconfig(flag)
        else:
            logger.debug("Flag {} exists in swconfig.txt".format(flag_hex))
            if not self._is_flag_with_value_in_swconfig(flag_hex, value):
                self._replace_flag_value_in_swconfig(flag_hex, value)
                logger.debug("Flag {} was replaced for value {} in swconfig.txt".format(flag_hex, value))
            else:
                logger.debug("Flag {} with value {} already exists in swconfig.txt".format(flag_hex, value))

    def ensure_flags_existence_in_swconfig(self, flags):
        """Provided a list of flags and their values, ensure that in swconfig.txt file the flag is set.
        If flag is already set, no action is taken. If flag is not set, it will be added to the swconfig file.
        For flags to take effect, unit needs to be rebooted.

        :param flags: list of flags with their values, all in string, like so:
            ['0x10040=1', '0x10043=0xC739', '0x10042=0xC0A8FF7E']
        :type flags: list of strings
        """
        for flag in flags:
            self._ensure_swconfig_flag_with_value_exists(flag)

    def log_swconfig_contents(self):
        _, swconfig_contents = self.run_on_unit("cat /rom/swconfig.txt")
        logger.info("{} /rom/swconfig/txt contents:\n{}".format(self.UNIT, swconfig_contents))
        return swconfig_contents


class GnbFileManager(RemoteFileManager):
    UNIT = "gNB"
    UNIT_ADDRESS = "192.168.255.129"

    def run_on_unit(self, cmd):
        return super(GnbFileManager, self).run_on_unit(cmd)


class ApFileManager(RemoteFileManager):
    UNIT = "AirPhone"
    UNIT_ADDRESS = "192.168.200.1"

    def run_on_unit(self, cmd):
        return super(ApFileManager, self).run_on_unit(cmd)


class GnbSwconfigManager(SwconfigManagerBase, GnbFileManager):
    pass


class ApSwconfigManager(SwconfigManagerBase, ApFileManager):
    pass
