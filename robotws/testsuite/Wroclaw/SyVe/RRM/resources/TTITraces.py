from time import sleep
import pip
import zipfile
from testsuite.Wroclaw.SyVe.RRM.resources.VmOs import VmOs
from testsuite.Wroclaw.SyVe.RRM.resources.Logger import Logger


CHAIN_COMMANDS = " && "


class TTITraces:
    def __init__(self):
        self.ute_home = "/home/ute/"
        self.content = None
        self._gnb_logs_url = "https://gitlabe1.ext.net.nokia.com/p5li/gnb_logs-tool/-"
        self._gnb_logs_tool = f"{self._gnb_logs_url}/raw/main/gnb_logs.zip"
        self._gnb_logs_commits = f"{self._gnb_logs_url}/commits/main"

    def download_gnb_logs_tool(self):
        Logger.info("Downloading gnb_logs tool")
        bts_logs_cmd = f"cd {self.ute_home}{CHAIN_COMMANDS}" \
                       f"(nohup wget --method GET --header 'authorization: Bearer {VmOs().ute_ca_token}' " \
                       f"{self._gnb_logs_tool} 1>/dev/null 2>/dev/null &); exit"
        VmOs.execute_single_command_in_shell(bts_logs_cmd)
        self._wait_for_process_end("wget", 300)
        self._unpack_gnb_logs_tool(f"{self.ute_home}gnb_logs.zip", f"{self.ute_home}")
        self._change_access_to_file()

    @staticmethod
    def _wait_for_process_end(process, timeout):
        interval = 3
        while timeout > 0:
            if not VmOs.check_if_process_running(process):
                return
            sleep(interval)
            timeout -= interval
        assert False, f"{process} takes too long."

    @staticmethod
    def _unpack_gnb_logs_tool(path_to_zip, path_to_extract_to):
        with zipfile.ZipFile(path_to_zip, 'r') as zip_ref:
            zip_ref.extractall(path_to_extract_to)

    def _change_access_to_file(self):
        chmod_cmd = f"cd {self.ute_home}gnb_logs{CHAIN_COMMANDS}" \
                    f"chmod +x gnb_logs"
        VmOs.execute_single_command_in_shell(chmod_cmd)

    def collect_tti_traces(self):
        file_init_path = f"{self.ute_home}gnb_logs/config.ini"
        self._change_config_file_to_decode_tti(file_init_path, r'^Tti_raw_logs_only = yes', r'Tti_raw_logs_only = no')
        Logger.info("collecting tti traces")
        collect_tti_traces_command = f"cd {self.ute_home}gnb_logs{CHAIN_COMMANDS}"\
                                     f"sudo ./gnb_logs -t5"
        VmOs.execute_single_command_in_shell(collect_tti_traces_command)
        self._wait_for_process_end("gnb_logs", 300)

    def remove_tti_traces(self):
        Logger.info("removing tti traces")
        remove_traces_cmd = f"sudo rm -rf {self.ute_home}gnb_logs/BTS-*"
        VmOs.execute_single_command_in_shell(f"{remove_traces_cmd}")

    def unpack_tti_traces(self, columns, types=None):
        try:
            import pandas as pd
        except ImportError:
            pip.main(['install', 'pandas'])
            import pandas as pd

        my_zip_dir_name = VmOs.get_files_with_names_starting_with(f"{self.ute_home}gnb_logs", "BTS-")[0]
        dl_and_ul_csv = "dlAndUl__all.csv"
        with (zipfile.ZipFile(f'{self.ute_home}gnb_logs/{my_zip_dir_name}') as tti_logs):
            for info in tti_logs.infolist():
                if dl_and_ul_csv in info.filename:
                    self.content = pd.read_csv(tti_logs.open(info.filename), usecols=columns, index_col=0)
                    if types:
                        self.content = self.content[self.content.index.isin(types)]
                        assert not self.content.empty, \
                            f"The CSV content is empty for {types} in the searched {columns} columns"
        assert self.content is not None, (f"{dl_and_ul_csv} file not found in {my_zip_dir_name}. "
                                          f"Please visit {self._gnb_logs_commits} to check recent "
                                          "gnb_logs tool changes first")

    def check_occurences_of_values(self, column_name, wanted_values=None):
        values = self.content[column_name].value_counts()
        return values[wanted_values] if wanted_values else values

    def get_percentage_of_values(self, column_name, wanted_values=None):
        values = self.content[column_name].value_counts(normalize=True)
        return values.get(wanted_values, 0.0) if wanted_values else values

    def get_filtered_data(self, column_name, values, exclude=False):
        if exclude:
            return self.content[~self.content[column_name].isin(values)]
        return self.content[self.content[column_name].isin(values)]

    def get_sum(self, column_name):
        return self.content[column_name].sum()

    def move_tti_traces_to(self, path_to_dir):
        Logger.info("Saving tti trace folder to test folder.")
        my_zip_dir_name = VmOs.get_files_with_names_starting_with(f"{self.ute_home}gnb_logs", "BTS-")
        if my_zip_dir_name:
            VmOs.move_dir(f"{self.ute_home}gnb_logs/{my_zip_dir_name[0]}", path_to_dir)
        else:
            Logger.warning("There is no tti trace to move. check if tti traces was correctly collected")

    def remove_gnb_logs_tool(self):
        Logger.info("Removing gnb_logs tool.")
        remove_gnb_logs_tool_cmd = f"sudo rm -rf {self.ute_home}*gnb_logs*"
        VmOs.execute_single_command_in_shell(remove_gnb_logs_tool_cmd)

    @staticmethod
    def _change_config_file_to_decode_tti(file_path, regex, replacement):
        import fileinput
        import re
        with fileinput.FileInput(file_path, inplace=True, backup='.bak') as file:
            for line in file:
                print(re.sub(regex, replacement, line), end='')
