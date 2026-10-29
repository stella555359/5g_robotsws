import os
from robot.api import logger
from taf.transport.ssh import ssh
from swconfig_operations import swconfig_operations


class swconfig_mgmt(swconfig_operations):

    ROBOT_LIBRARY_SCOPE = 'TEST SUITE'

    def __init__(self, path_to_swconfig=None):
        super(swconfig_mgmt, self).__init__(path_to_swconfig)

    def add_flag_to_swconfig(self, flag_id, flag_value, path_to_swconfig):
        """
        Add single flag to swconfig. This flag will overwrite value if already exist.

        :param flag_id: flag id which will be added e.g. 0x123456
        :param flag_value: flag value which will be added e.g. 1
        :param path_to_swconfig:
        """
        super(swconfig_mgmt, self).__init__(path_to_swconfig)
        self.append_flag(flag_id, flag_value)
        self.save_swconfig(path_to_swconfig)

    def add_flags_to_swconfig(self, flags, path_to_swconfig):
        """
        Add multiple flags to swconfig. Flags which exist will be overwritten.

        :param flags: dict in which key is a flag id and value is flag value, e.g.:
        {"0x123456": "0", "0xabcdef": "1"}
        :param path_to_swconfig:
        """
        super(swconfig_mgmt, self).__init__(path_to_swconfig)
        self.append_flags(flags)
        self.save_swconfig(path_to_swconfig)

    def clear_swconfig(self, path_to_swconfig):
        """
        Clear given swconfig from all flags and saves it.
        """
        self.current_flags = {}
        self.save_swconfig(path_to_swconfig)

    def create_swconfig_with_flags(self, flags, output_filename):
        """
        Create new swconfig filled with given flags.

        :param flags: list of flags which will be added to swconfig.
        :type flags: dict in which key is a flag id and value is flag value, e.g.:
        {"0x123456": "0", "0xabcdef": "1"}
        :param output_filename: file name to which flags will be saved.
        """
        self.append_flags(flags)
        self.save_swconfig(output_filename)

    def get_current_flags_from_swconfig(self, path_to_swconfig):
        """
        Get current flags from given swconfig.

        :return: dict in which key is a flag id and value is flag value, e.g.:
        {"0x123456": "0", "0xabcdef": "1"}
        """
        super(swconfig_mgmt, self).__init__(path_to_swconfig)
        return self.get_current_active_flags()

    def remove_flag_from_swconfig(self, flag_id, path_to_swconfig):
        """
        Remove single flag from swconfig. This will do nothing if flag does not exist.

        :param flag_id: flag id which will be removed e.g. 0x123456
        :param path_to_swconfig:
        """
        super(swconfig_mgmt, self).__init__(path_to_swconfig)
        self.remove_flag(flag_id)
        self.save_swconfig(path_to_swconfig)

    def remove_flags_from_swconfig(self, flags, path_to_swconfig):
        """
        Remove multiple flags from swconfig. Nothing will happen to flags which do not exist.

        :param flags: dict in which key is a flag id and value is flag value, e.g.:
        {"0x123456": "0", "0xabcdef": "1"}
        :param path_to_swconfig:
        """
        super(swconfig_mgmt, self).__init__(path_to_swconfig)
        self.remove_flags(flags)
        self.save_swconfig(path_to_swconfig)

    @staticmethod
    def check_if_swconfig_file_exist(bts_ip="192.168.255.129", bts_user="toor4nsn", bts_password="oZPS0POrRieRtu"):
        """
        Logs to BTS with given credentials and check if swconfig.txt file exist.
        """
        csn = ssh()
        csn.connect_to(bts_ip, bts_user, bts_password)
        path = "/ffs/run/"
        command = "ls {} | grep swconfig".format(path)
        logger.console("Check if swconfig exist -> run command: '{}' ".format(command))
        log = csn.execute(command)
        logger.console("The result of command is: \n{}".format(log))
        csn.disconnect()
        return log

    @staticmethod
    def create_swconfig_file(bts_ip="192.168.255.129", bts_user="toor4nsn", bts_password="oZPS0POrRieRtu"):
        """
        Logs to BTS with given credentials and create swconfig.txt file.
        """
        csn = ssh()
        csn.connect_to(bts_ip, bts_user, bts_password)
        path = "/ffs/run/"
        command = "touch {}swconfig.txt".format(path)
        csn.execute(command)
        csn.disconnect()

    @staticmethod
    def delete_swconfig_txt_p7_file(bts_ip="192.168.255.129", bts_user="toor4nsn", bts_password="oZPS0POrRieRtu"):
        """
        Logs to BTS with given credentials and delete old swconfig.txt.p7 file.
        """
        csn = ssh()
        csn.connect_to(bts_ip, bts_user, bts_password)
        path = "/ffs/run/"
        command = "rm {}swconfig.txt.p7".format(path)
        csn.execute(command)
        csn.disconnect()

    @staticmethod
    def get_swconfig_from_bts(save_filepath="swconfig.txt", bts_ip="192.168.255.129",
                              bts_user="toor4nsn", bts_password="oZPS0POrRieRtu"):
        """
        Logs to BTS with given credentials and downloads current swconfig to local `save_filepath` file.
        :return: Absolute path to saved file.
        """
        csn = ssh()
        csn.connect_to(bts_ip, bts_user, bts_password)
        csn.download_file("/ffs/run/swconfig.txt", save_filepath)
        csn.disconnect()
        return os.path.abspath(save_filepath)

    @staticmethod
    def put_swconfig_into_bts(upload_filepath="swconfig.txt", bts_ip="192.168.255.129",
                              bts_user="toor4nsn", bts_password="oZPS0POrRieRtu"):
        """
        Logs to BTS with given credentials and uploads `upload_filepath` as a new swconfig file.
        """
        csn = ssh()
        csn.connect_to(bts_ip, bts_user, bts_password)
        csn.upload_file(upload_filepath, "/ffs/run/swconfig.txt")
        csn.send_command("crasign /ffs/run/swconfig.txt")
        csn.disconnect()
