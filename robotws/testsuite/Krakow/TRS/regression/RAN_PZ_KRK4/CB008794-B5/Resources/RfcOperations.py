import logging
import re

from moler.device import DeviceFactory
from taf.rfrl.bts.connections.device_aliases import ssh_bts_hub
from taf.rfrl.utilities.tl_config import load_moler_configuration_from_tl
from taf.rfrl.utilities.robot.general import get_builtin_value
from taf.ul.moler.converter.interface import add_device_to_already_loaded_configuration
from taf.ul.moler.converter.moler_converter import MolerConverter


class RfcOperations(object):
    """Class for performing operations on RFC device."""

    def __init__(self):
        """Initialize RfcOperations object."""
        self.rfc_device_name = None
        self.tl = get_builtin_value("tl")

    @load_moler_configuration_from_tl()
    def load_rfc_device(self, rfc_address="195.60.16.254", rfc_password="team2", rfc_id=0, rfc_test_pc_id=1, gnb_id=0):
        """
        Load RFC device to Moler configuration.
        :param rfc_address: RFC device address.
        :type rfc_address: str
        :param rfc_password: RFC device password.
        :type rfc_password: str
        :param rfc_id: RFC device ID.
        :type rfc_id: int
        :param rfc_test_pc_id: RFC device test PC ID.
        :type rfc_test_pc_id: int
        :param gnb_id: GNB device ID.
        :type gnb_id: int
        return: None
        """
        self.rfc_device_name = ssh_bts_hub.format("GNB", gnb_id, "_RFC_{}".format(rfc_id))
        mc = MolerConverter()
        all_devices = mc.moler_devices.get_moler_device_config()['DEVICES']
        mc.moler_devices.add_remote_unix_configuration(
            device_name=self.rfc_device_name,
            host=rfc_address,
            login="root",
            password=rfc_password,
            root_password=None,
            root_prompt=r"(root@|[\w-]+).*?:.*#\s+",
            proxy_pc_host=self.tl.test_pcs[rfc_test_pc_id].default_ssh_connection_details.addr,
            proxy_pc_login=self.tl.test_pcs[rfc_test_pc_id].default_ssh_connection_details.username,
            proxy_pc_password=self.tl.test_pcs[rfc_test_pc_id].default_ssh_connection_details.password,
            root_login_cmd=None)
        add_device_to_already_loaded_configuration(config=all_devices)

    def check_permissions_of_rfc_files(self, find_cmd_operators, required_permissions):
        """
        Check permissions of RFC files.
        :param find_cmd_operators: Find command operators.
        :type find_cmd_operators: str
        :param required_permissions: Required permissions.
        :type required_permissions: str
        return: None
        """
        self.load_rfc_device()
        files = self._search_for_files_in_directory(operators=find_cmd_operators)
        for file_path in files:
            self._check_permissions(file_path=file_path, required_permissions=required_permissions)

    def check_permissions_of_particular_rfc_file(self, file_path, required_permissions):
        """
        Check permissions of particular RFC file.
        :param file_path: File path.
        :type file_path: str
        :param required_permissions: Required permissions.
        :type required_permissions: str
        return: None
        """
        self.load_rfc_device()
        self._check_permissions(file_path=file_path, required_permissions=required_permissions)

    def check_rfc_system_users(self):
        """
        Check RFC system users.
        return: None
        """
        required_users = ["root", "sshd"]
        self.load_rfc_device()
        system_users = self._concatenate_and_print_files(path="/etc/passwd")
        logging.info(f"RFC system users: {system_users}")

        if len(system_users) == 2:
            for required_user in required_users:
                required_user_found = False
                for system_user in system_users:
                    if required_user in system_user:
                        required_user_found = True
                        logging.info(f"Required user '{required_user}' found among RFC system users: '{system_user}'.")
                        break
                if not required_user_found:
                    raise RfcOperationException(f"Error: Required user '{required_user}' not found"
                                                f" among RFC system users: '{system_users}'.")
        else:
            raise RfcOperationException(f"Error: No extra users allowed among RFC system users: '{system_users}'."
                                        f" Only '{required_users}' users allowed!")

    def check_rfc_directories_with_permissions_777(self):
        """
        Check RFC directories with permissions.
        return: None
        """
        self.load_rfc_device()
        found_dirs = self._search_for_files_in_directory(
            operators=f"/ -type d -perm 777 -print 2>/dev/null")
        if found_dirs:
            for dir_path in found_dirs:
                ls_cmd_output = self._list_directory_content(path=dir_path, options="-ld")
                dir_permissions = ls_cmd_output[list(ls_cmd_output.keys())[0]]['permissions']
                self._verify_sticky_bit(permissions=dir_permissions, path=dir_path)
        else:
            logging.info(
                f"Verification skipped. Not found directories with permissions 777 in RFC files system")

    def check_permissions_in_rfc_webserver(self):
        """
        Check permissions in RFC webserver.
        return: None
        """
        self.load_rfc_device()
        executables = ["cgi-bin", "js"]
        webserver_elements = self._list_directory_content(path="/home/webserver/www")
        logging.info(f"RFC webserver content: '{webserver_elements}'")
        for element_key in list(webserver_elements.keys()):
            element_permissions = webserver_elements[element_key]['permissions']
            if "x" in element_permissions:
                if element_key in executables:
                    logging.info(f"Found allowed RFC /home/webserver/www element:"
                                 f" '{element_key}' with execute permission.")
                else:
                    raise RfcOperationException(f"Error: '{element_key}' is not allowed to have execute permission"
                                                f" in RFC /home/webserver/www directory: '{webserver_elements}'."
                                                f" Only '{executables}' are allowed!")

    def _check_permissions(self, file_path, required_permissions):
        """
        Check permissions of file.
        :param file_path: File path.
        :type file_path: str
        :param required_permissions: Required permissions.
        :type required_permissions: str
        return: None
        """
        ls_output = self._list_directory_content(path=file_path)
        logging.info(f"ls_output: {ls_output}")
        ls_output_key = list(ls_output.keys())[0]
        file_permissions = ls_output[ls_output_key]['permissions']
        file_permissions_octal = self._convert_permission_string_to_octal(file_permissions)

        if file_permissions_octal == required_permissions:
            logging.info(f"Passed: File '{file_path}' permissions: '{file_permissions_octal}'"
                         f" match required permissions: '{required_permissions}'")
        else:
            raise RfcOperationException(f"Error: File '{file_path}' permissions: '{file_permissions_octal}'"
                                        f" do not match required permissions: '{required_permissions}'.")

    def _list_directory_content(self, path, options="-l"):
        """
        List information about files.
        :param path: Path of directory.
        :type path: str
        :param options: Options.
        :type options: str
        return: Directory content.
        :rtype: dict
        """
        device = DeviceFactory.get_device(
            name=self.rfc_device_name,
            initial_state="UNIX_REMOTE"
        )
        cmd_list_dir_content = device.get_cmd(
            cmd_name="ls",
            cmd_params={
                "options": options,
                "path": path})
        return cmd_list_dir_content()['files']

    def _search_for_files_in_directory(self, operators, paths=None, options=None):
        """
        Search for files in directory.
        :param operators: Find command operators.
        :type operators: str
        :param paths: Paths.
        :type paths: list
        :param options: Options.
        :type options: str
        return: Found files.
        :rtype: list
        """
        device = DeviceFactory.get_device(
            name=self.rfc_device_name,
            initial_state="UNIX_REMOTE"
        )
        cmd_get_files = device.get_cmd(
            cmd_name="find",
            cmd_params={
                "paths": paths,
                "options": options,
                "operators": operators})
        return cmd_get_files()["RESULT"]

    def _concatenate_and_print_files(self, path, options=None):
        """
        Concatenate and print files.
        :param path: Path of file.
        :type path: str
        :param options: Options.
        :type options: str
        return: File content.
        :rtype: list
        """
        device = DeviceFactory.get_device(
            name=self.rfc_device_name,
            initial_state="UNIX_REMOTE"
        )
        cmd_cat_files = device.get_cmd(
            cmd_name="cat",
            cmd_params={
                "path": path,
                "options": options})
        return cmd_cat_files()["LINES"]

    @staticmethod
    def _convert_permission_string_to_octal(permission_string):
        """
        Convert permission string to octal.
        :param permission_string: Permission string.
        :type permission_string: str
        return: Octal permissions.
        :rtype: str
        """
        if len(permission_string) != 10:
            raise ValueError(f"Invalid permission string '{permission_string}'."
                             f" It should be a 10-character string.")
        # Mapping of permission characters to their binary representation
        permission_map = {'-': 0, 'r': 4, 'w': 2, 'x': 1}
        # Convert each group of permission characters to its binary representation
        binary_permissions = [permission_map[char] for char in permission_string[1:]]
        logging.info(f"binary permissions: {binary_permissions}")
        # Combine the binary representation and convert it to octal
        octal_permissions = []
        group_first_index = 0
        for i in range(3):
            octal_permissions.append(str(sum(binary_permissions[group_first_index:group_first_index + 3])))
            group_first_index += 3
        return ''.join(octal_permissions)

    @staticmethod
    def _verify_sticky_bit(permissions, path):
        """
        Verify sticky bit.
        :param permissions: Permissions.
        :type permissions: str
        :param path: Path.
        :type path: str
        return: None
        """
        sticky_bit_pattern = re.compile(r'^d(rwx){2}rwt$')
        match = re.search(sticky_bit_pattern, permissions)
        if match:
            logging.info(f"Passed: sticky bit set for others permission group: '{permissions}' of '{path}'")
        else:
            raise RfcOperationException(
                f"Failed: sticky bit not set for others permission group: '{permissions}' of '{path}'")


class RfcOperationException(Exception):
    """Exception class for RfcOperations class."""
    pass
