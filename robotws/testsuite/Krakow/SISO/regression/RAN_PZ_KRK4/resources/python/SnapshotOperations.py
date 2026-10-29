"""
Operations on snapshot.

:copyright: Nokia Networks
:author: Rafal Kawa
:contact: rafal.kawa@nokia.com
:maintainer: rafal.kawa@nokia.com
"""

import os
import re

from moler.device import DeviceFactory
from taf.rfrl.utilities.tl_config import load_moler_configuration_from_tl
from taf.rfrl.bts.devices.generic_bts import GenericBts
from taf.rfrl.bts.parsers.snapshot_analyzer import parse_snapshot_file_list


class SnapshotOperations(GenericBts):
    """
    CustomKeywords class

    This class provides various operations related to snapshot.
    """

    def __init__(self, ):
        """
        Initializes the SnapshotOperations class.
        """
        super().__init__()

    def search_file_in_snapshot(self, snapshot_path, regex_pattern, search_sub_files=True):
        """
        Search for files in a snapshot_file_list.txt.

        Args:
            snapshot_path (str): Path to snapshot.
            regex_pattern (str): Filename regex pattern.
            search_sub_files (bool): Whether to search within sub-files. Default is True.

        Returns:
            list: List of matched filenames.

        Raises:
            FileNotFoundError: If no files match the regex pattern in snapshot files.
        """
        pattern = re.compile(regex_pattern, re.IGNORECASE)
        extract_dir = os.path.join(os.path.dirname(snapshot_path),
                                   f"Extracted_{os.path.basename(snapshot_path).split('.zip')[0]}")
        matched_files = []

        self.unzip_file(file_path=snapshot_path, extract_dir=extract_dir)

        for file_dict in parse_snapshot_file_list(file_path=os.path.join(extract_dir, "snapshot_file_list.txt")):
            if pattern.search(file_dict['file_name']):
                matched_files.append(file_dict['file_name'])
            if search_sub_files:
                for sub_file in file_dict['sub_files']:
                    if pattern.search(sub_file):
                        matched_files.append(sub_file)

        if not matched_files:
            raise FileNotFoundError(f"No files matching the pattern '{regex_pattern}' "
                                    f"were found in snapshot {snapshot_path}.")

        return matched_files

    @load_moler_configuration_from_tl()
    def unzip_file(self, file_path, unzip_options="", extract_dir=None, timeout=180, bts_id=0, du_id=0):
        """
        Unzips a file.

        Args:
            file_path (str): Path to the zip file to be unzipped.
            unzip_options (str, optional): Options to be used with the unzip command. Defaults to an empty string.
            extract_dir (str, optional): Directory where the files should be extracted. Defaults to None.
            timeout (int, optional): Timeout for the unzip command in seconds. Defaults to 180.
            bts_id (int, optional): BTS ID. Defaults to 0.
            du_id (int, optional): Distributed Unit (DU) ID. Defaults to 0.

        Returns:
            object: Result of the unzip command execution.
        """
        device = DeviceFactory.get_device(name=self.ssh_alias.format(bts_id, du_id), initial_state='PROXY_PC')
        cmd_unzip = device.get_cmd(cmd_name='unzip',
                                   cmd_params={"zip_file": file_path,
                                               "extract_dir": extract_dir,
                                               "options": unzip_options,
                                               "overwrite": True})
        return cmd_unzip(timeout=timeout)

    @staticmethod
    def verify_snapshot_name(file_path, regex):
        """
        Verifies if the snapshot name matches a regex pattern.

        Args:
            file_path (str): The path of the file.
            regex (str): The regex pattern to match the file name.

        Raises:
            ValueError: If the file name does not match the regex pattern.

        Returns:
            bool: True if the file name matches the regex pattern.
        """
        file_name = os.path.basename(file_path)
        pattern = re.compile(regex, re.IGNORECASE)
        if not pattern.match(file_name):
            raise ValueError(f"File name '{file_name}' does not match the pattern '{regex}'")
        return True
