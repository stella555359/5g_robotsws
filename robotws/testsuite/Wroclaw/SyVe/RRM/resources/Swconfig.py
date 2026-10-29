from testsuite.Wroclaw.SyVe.RRM.resources.TestEnvData import TestEnvData as Env
from testsuite.Wroclaw.SyVe.RRM.resources.VmOs import VmOs as Os
from testsuite.Wroclaw.SyVe.RRM.resources.Ssh import download_file, upload_file, execute_ssh_command
from testsuite.Wroclaw.SyVe.RRM.resources.Logger import Logger


LOG_OUTPUT_MODE = "0x10041=5"
LOG_OUTPUT_LEVEL = "0x10040=1"
LOG_INPUT_LEVEL = "0x1003F=1"
CP_RT_LOG_LEVEL = "0x590072=1"
CP_NRT_LOG_LEVEL = "0x66001b=1"
ADMIN_DEV_PRIVILEGE = "0x45005a=1"
DISABLE_FIREWALL = "0x1A1300=0"
TRSW_DBG_ETHSEC_DISABLED = "0x1A0020=1"
SW_APP_DEF_CHECK_DISABLE = "0x10063=1"


BASIC_FLAGS = [LOG_OUTPUT_MODE, LOG_OUTPUT_LEVEL, LOG_INPUT_LEVEL, CP_RT_LOG_LEVEL, CP_NRT_LOG_LEVEL,
               ADMIN_DEV_PRIVILEGE, DISABLE_FIREWALL, TRSW_DBG_ETHSEC_DISABLED, SW_APP_DEF_CHECK_DISABLE]


class Swconfig(object):

    def __init__(self):
        self.file_name = "swconfig.txt"
        self.bts_swconfig_path = "/ffs/run/{}".format(self.file_name)
        self.swconfig_local_path = Os.join_path_elements(Env.OUTPUT_DIR,  self.file_name)

    def change_swconfig_flags(self, update_flags, comment_flags):
        """
        Function downloads, updates and comments flags and puts back swconfig file to the bts
        :param update_flags: list of flags to be updated. Ex. ["0x00001=1", "0x1234=2"]
        :param comment_flags: list of flags to be commented (deactivated). Ex. ["Ox111", "1235"]
        :return: None
        """
        self._download_swconfig()
        self._change_flags(update_flags, self._update_flag)
        self._change_flags(comment_flags, self._comment_flag)
        self._upload_swconfig()

    def update_swconfig_flags(self, flags_list):
        """
        Function downloads, updates flags and puts back swconfig file to the bts
        :param flags_list: list of flags to be updated. Ex. ["0x00001=1", "0x1234=2"]
        :return: None
        """
        self._download_swconfig()
        self._change_flags(flags_list, self._update_flag)
        self._upload_swconfig()

    def comment_swconfig_flags(self, flags_list):
        """
        Function downloads, comments (deactivates) flags and puts back swconfig file to the bts
        :param flags_list: list of flags to be deactivated. Ex. ["0x00001", "0x1234"]
        :return: None
        """
        self._download_swconfig()
        self._change_flags(flags_list, self._comment_flag)
        self._upload_swconfig()

    def _change_flags(self, flags_list, change_function):
        for flag in flags_list:
            updated_content = change_function(flag)
            with open(self.swconfig_local_path, "w") as swconfig:
                swconfig.write("".join(updated_content))

    def _download_swconfig(self):
        self._ensure_swconfig_file_is_present()
        download_file(Env.GNB_SSH_CONNECTION_DETAILS, self.bts_swconfig_path, self.swconfig_local_path)

    def _ensure_swconfig_file_is_present(self):
        if self.file_name not in execute_ssh_command(Env.GNB_SSH_CONNECTION_DETAILS,
                                                     "ls {}".format(self.bts_swconfig_path)):
            execute_ssh_command(Env.GNB_SSH_CONNECTION_DETAILS, "touch {}".format(self.bts_swconfig_path))
            execute_ssh_command(Env.GNB_SSH_CONNECTION_DETAILS, "crasign {}".format(self.bts_swconfig_path))

    def _upload_swconfig(self):
        upload_file(Env.GNB_SSH_CONNECTION_DETAILS, self.swconfig_local_path, self.bts_swconfig_path)
        execute_ssh_command(Env.GNB_SSH_CONNECTION_DETAILS, "crasign {}".format(self.bts_swconfig_path))

    def _update_flag(self, flag):
        end_line = "\n"
        with open(self.swconfig_local_path, "r") as file_:
            swconfig_lines = file_.readlines()
        for line_nr in range(len(swconfig_lines)):
            if swconfig_lines[line_nr].startswith(flag.split("=")[0]):
                Logger.debug("Updating swconfig '{}' flag".format(flag))
                swconfig_lines[line_nr] = flag + end_line
                return swconfig_lines
        Logger.debug("Adding not existing swconfig '{}' flag".format(flag))
        swconfig_lines.append(flag + end_line)
        return swconfig_lines

    def _comment_flag(self, flag):
        hash_comment = "#"
        with open(self.swconfig_local_path, "r") as file_:
            swconfig_lines = file_.readlines()
        for line_nr in range(len(swconfig_lines)):
            if swconfig_lines[line_nr].startswith(flag):
                Logger.debug("Commenting (deactivating) swconfig '{}' flag".format(flag))
                swconfig_lines[line_nr] = hash_comment + swconfig_lines[line_nr]
        return swconfig_lines
