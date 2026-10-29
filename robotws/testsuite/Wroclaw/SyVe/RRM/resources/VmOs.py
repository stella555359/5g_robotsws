import shutil
import subprocess
import os
from pathlib import Path
from testsuite.Wroclaw.SyVe.RRM.resources.Ssh import execute_ssh_command
from testsuite.Wroclaw.SyVe.RRM.resources.Logger import Logger

R2D2_INSTALLATION_CMD = ('git clone https://wrgitlab.ext.net.nokia.com/r2d2/r2d2.git /home/ute/r2d2;'
                         ' bash /home/ute/r2d2/reservation_script.sh;')


class VmOs(object):

    @staticmethod
    def make_empty_dir(directory):
        """
        Creates or deletes everything in in to have empty directory
        :param directory: path to the directory to be created or cleaned
        :return: None
        """
        if os.path.exists(directory):
            shutil.rmtree(directory)
        os.makedirs(directory)

    @staticmethod
    def remove_dir(directory):
        """
        Removes given directory
        :param directory: directory to be removed
        :return: None
        """
        shutil.rmtree(directory)

    @staticmethod
    def check_if_dir_is_not_empty(directory):
        """
        Check if directory is not empty
        :param directory: path to the directory
        :return: True if not empty, False otherwise
        """
        if os.listdir(directory):
            return True
        else:
            return False

    @staticmethod
    def move_dir(src, dst):
        """
        Move directory or file to the new location
        :param src: path to the source directory
        :param dst: path to the destination directory
        :return: destination path
        """
        return shutil.move(src, dst)

    @staticmethod
    def make_dir(directory):
        """
        Creates directory if not exists (does not delete files)
        :param directory: path to the directory to be created
        :return: None
        """
        if not os.path.isdir(directory):
            os.makedirs(directory)

    @staticmethod
    def join_path_elements(*path_elements):
        """
        Joins different path elements to one path
        :param path_elements: Elements of the path to be joined ("/tmp", "dir_in_tmp", "example.file")
        :return: Joined path
        """
        return os.path.join(*path_elements)

    def confirm_file_exists(self, file_path):
        """
        Confirms the requested file exists on the file system
        :param file_path: Path to the file
        :return: None, raises exception if file does not exist
        """
        assert self.is_file_exist(file_path), "File {} does not created!".format(file_path)

    @staticmethod
    def is_file_exist(file_path):
        """
        Checks if file exists
        :param file_path: Path to the file
        :return: True if exists, False otherwise
        """
        return os.path.isfile(file_path)

    @staticmethod
    def get_files_with_names_starting_with(directory, startswith):
        """
        Searches for files in the directory starting with specific string
        :param directory: The directory to be searched for files
        :param startswith: Searched string starting the name of files
        :return: List of file names
        """
        return [name for name in os.listdir(directory) if name.startswith(startswith)]

    @staticmethod
    def get_time_sorted_files_from_youngest_with_names_starting_with(directory, startswith):
        """
        Searches for files in the directory starting with specific string
        :param directory: The directory to be searched for files
        :param startswith: Searched string starting the name of files
        :return: List of file names sorted from the youngest to the oldest
        """
        files = VmOs.get_files_with_names_starting_with(directory, startswith)
        files.sort(key=lambda x: os.path.getmtime(os.path.join(directory, x)), reverse=True)
        return files

    @staticmethod
    def get_the_newest_file(files_list):
        """
        Searches for the newest file in the list (paths)
        :param files_list: list of files to be analyzed
        :return: the newest file path
        """
        return max(files_list, key=os.path.getctime)

    @staticmethod
    def get_the_oldest_file(files_list):
        """
        Searches for the oldest file in the list (paths)
        :param files_list: list of files to be analyzed
        :return: the oldest file path
        """
        return min(files_list, key=os.path.getctime)

    @staticmethod
    def execute_command(command):
        command_list = command.split()
        return subprocess.check_output(command_list).decode("utf-8")

    @staticmethod
    def execute_single_command_in_shell(command):
        return subprocess.check_output(command, shell=True).decode("utf-8")

    @staticmethod
    def check_if_process_running(process):
        check_process_cmd = f"pgrep {process}"
        try:
            return subprocess.check_output(check_process_cmd, shell=True).decode("utf-8")
        except subprocess.CalledProcessError:
            return ""

    @staticmethod
    def make_empty_dir_remote(ssh_connection_details, directory):
        create_dir = "rm -rf {file_dir} && mkdir {file_dir}".format(file_dir=directory)
        output, _ = execute_ssh_command(ssh_connection_details, create_dir, look_for_keys=True)

    @staticmethod
    def create_fsp_only_abia_network_interface_list(provided_list):
        abia_network_interface_list = []
        for interface in provided_list:
            if 'fsp' in interface:
                abia_network_interface_list.append(interface)
        return abia_network_interface_list

    @staticmethod
    def get_list_of_network_interface_ips(network_interface_list):
        network_interface_ips = []
        for interface in network_interface_list:
            network_interface_ips.append(interface.split(' ')[1])
        return network_interface_ips

    def task_force_stop_and_fix_command(self):
        cm_execution_id = self.get_cm_execution_id()
        if cm_execution_id:
            ft_cmd = f'echo "put /opt/ute/execution.context.json {cm_execution_id}.json" |' \
                     f' cadaver http://webdav.ute.nsn-rdnet.net/tmp/stop_and_fix/'
            subprocess.call(ft_cmd, shell=True)
        else:
            Logger.warning("Couldn't get CM_EXECUTION_ID from the OS, skipping task force command execution")

    @staticmethod
    def get_cm_execution_id():
        return os.environ.get("CM_EXECUTION_ID")

    def is_it_manual_execution(self):
        return False if self.get_cm_execution_id() else True

    @staticmethod
    def list_files_in_the_pattern_directory(root_dir, pattern_dir):
        return list(Path(root_dir).glob(pattern_dir))

    @staticmethod
    def list_files_in_the_directory(target_dir):
        return [file_ for file_ in Path(target_dir).iterdir() if file_.is_file()]

    def get_debian_name(self):
        return self.execute_command("lsb_release -c").split()[1]

    def copy_and_rename_file(self, source_file, target_dir, new_name):
        new_file = self.join_path_elements(target_dir, new_name)
        return shutil.copyfile(source_file, new_file)

    def install_r2d2_package(self):
        return self.execute_single_command_in_shell(R2D2_INSTALLATION_CMD)

    def change_ute_password(self, password="ute"):
        return self.execute_single_command_in_shell(f"sudo bash -ce 'echo ute:{password} | chpasswd; "
                                                    f"echo root:{password} | chpasswd'")

    @property
    def ute_ca_token(self):
        with open("/etc/token/ca_ute_artifactory_readonly") as cert_file:
            return cert_file.read().strip()

    @property
    def authorization_bearer_token(self):
        return {"Authorization": "Bearer " + self.ute_ca_token}
