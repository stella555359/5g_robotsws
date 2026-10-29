"""
:modified:06.03.2025

:author: Mateusz Kawka
:maintainer: Mateusz Kawka
:contact: mateusz.kawka@nokia.com
"""
from robot.api import logger
import zipfile
import re


class FileInterface:
    def __init__(self):
        pass

    @staticmethod
    def _get_list_of_files_in_zip_archive(zip_path):
        """
        Retrieve a list of files contained within a ZIP archive.

        Args:
            zip_path (str): The path to the ZIP archive.

        Returns:
            list: A list containing the names of all files present within the ZIP archive.

        Raises:
            FileNotFoundError: If the specified ZIP archive does not exist.
            zipfile.BadZipFile: If the specified file is not a valid ZIP archive.

        Example:
            Suppose we have a ZIP archive named 'example.zip' containing two files: 'file1.txt' and 'file2.txt'.
            Calling _get_list_of_files_in_zip_archive('example.zip') will return ['file1.txt', 'file2.txt'].
        """
        with zipfile.ZipFile(zip_path, 'r') as zip_arch:
            file_list = zip_arch.namelist()
            logger.debug(f'List of files found in ZIP {zip_path}:\n{file_list}')

        return file_list

    @staticmethod
    def _extract_text_file_from_zip_archive(zip_path, file_name):
        """
        Extract the content of a text file from a ZIP archive.

        Args:
            zip_path (str): The path to the ZIP archive.
            file_name (str): The name of the text file to extract from the ZIP archive.

        Returns:
            str: The content of the extracted text file.

        Raises:
            FileNotFoundError: If the specified ZIP archive does not exist.
            zipfile.BadZipFile: If the specified file is not a valid ZIP archive.
            KeyError: If the specified file does not exist within the ZIP archive.

        Example:
            Suppose we have a ZIP archive named 'example.zip' containing a text file named 'example.txt'
            and its content is 'Hello, world!'.
            Calling _extract_text_file_from_zip_archive('example.zip', 'example.txt') will return 'Hello, world!'.
        """
        with zipfile.ZipFile(zip_path, 'r') as zip_arch:
            with zip_arch.open(file_name) as file:
                text_file = file.read().decode()

        return text_file

    def _extract_list_of_files_from_webem_snapshot(self, snapshot_zip_archive):
        """
        Extract a list of files from a webem snapshot ZIP archive.

        Args:
            snapshot_zip_archive (str): The path to the ZIP archive containing the webem snapshot.

        Returns:
            list: A list containing the names of files extracted from the webem snapshot.

        Raises:
            FileNotFoundError: If the specified ZIP archive does not exist.
            zipfile.BadZipFile: If the specified file is not a valid ZIP archive.
            KeyError: If the specified file does not exist within the ZIP archive.

        Example:
            Suppose we have a webem snapshot ZIP archive named 'webem_snapshot.zip' containing a file list
            'snapshot_file_list.txt' with the following content:
            ```
            file1.txt
            file2.gz
            file3.zip
            ```
            Calling _extract_list_of_files_from_webem_snapshot('webem_snapshot.zip')
            will return ['file1.txt', 'file2.gz', 'file3.zip'].
            """
        list_of_files = self._extract_text_file_from_zip_archive(snapshot_zip_archive, 'snapshot_file_list.txt')
        files_list = []
        for file in list_of_files.splitlines():
            files_list.append(file.lstrip())

        return files_list

    def _compare_radio_module_and_webem_snapshots(self, ru_serial_number, ru_snapshot_path, webem_snapshot_path):
        """
        Compare the files in a radio module snapshot with the files in a WebEM snapshot.

        Args:
            ru_serial_number (str): The serial number of the radio module.
            ru_snapshot_path (str): The path to the ZIP archive containing the radio module snapshot.
            webem_snapshot_path (str): The path to the ZIP archive containing the WebEM snapshot.

        Raises:
            FileNotFoundError: If the specified ZIP archives do not exist.
            zipfile.BadZipFile: If the specified files are not valid ZIP archives.
            KeyError: If the specified files do not exist within the ZIP archives.
            ValueError: If the number of files in the radio module snapshot does not match
                        the number of files for the specified radio module in the WebEM snapshot.

        Example:
            Suppose we have a radio module snapshot ZIP archive named 'ru_snapshot.zip' and a WebEM snapshot
            ZIP archive named 'webem_snapshot.zip'. We want to compare the files in these snapshots for
            radio module with serial number '12345'.
            Calling _compare_radio_module_and_webem_snapshots('12345', 'ru_snapshot.zip', 'webem_snapshot.zip')
            will compare the files and raise appropriate exceptions if discrepancies are found.
        """
        ru_files = self._get_list_of_files_in_zip_archive(ru_snapshot_path)
        webem_snap_file = self._extract_list_of_files_from_webem_snapshot(webem_snapshot_path)
        logger.info(f'Radio module snapshot contains: {len(ru_files)} files')

        sliced_webem_snap_file = [file for file in webem_snap_file if re.search(rf'BTS\d*_{ru_serial_number}', file)]
        logger.debug(f'List of files found in snapshot_file_list.txt in WebEM snapshot:\n{sliced_webem_snap_file}')
        logger.info(f'WebEM snapshot contains: {len(sliced_webem_snap_file)} files from '
                    f'{ru_serial_number} radio module')

        webem_snap_pattern = re.compile(r"^BTS\d*_L\d+_RMOD_L_\d+_|\.gz$|:")
        webem_list_sliced = set([webem_snap_pattern.sub('', item) for item in sliced_webem_snap_file])

        radio_snap_pattern = re.compile(r"^\d{4}_")
        radio_list_sliced = set([radio_snap_pattern.sub('', item) for item in ru_files])

        unique_radio = radio_list_sliced - webem_list_sliced
        unique_webem = webem_list_sliced - radio_list_sliced
        logger.info("Below lists of unique values.\n***This does not necessarily mean an error, "
                    "a slightly different spelling of the names may have resulted in a mismatch to the pattern***")
        logger.info(f"Unique files in radio module snapshot: {unique_radio}")
        logger.info(f"Unique files in WebEM snapshot: {unique_webem}")

        if len(ru_files) != len(sliced_webem_snap_file):
            raise ValueError(f'Number of files in radio module snapshot ({len(ru_files)})'
                             f' is NOT equal number of files for radio module {ru_serial_number} '
                             f'in WebEM snapshot ({len(sliced_webem_snap_file)})')

    @staticmethod
    def _check_file_in_zip_archive(zip_path, regex_pattern):
        """
        Check if a file exists within a ZIP archive based on a regular expression pattern.

        Args:
            zip_path (str): The path to the ZIP archive.
            regex_pattern (str): The regular expression pattern to match file names within the ZIP archive.

        Returns:
            list: A list of matching file names found in the ZIP archive.

        Raises:
            FileNotFoundError: If the specified ZIP archive does not exist.
            zipfile.BadZipFile: If the specified file is not a valid ZIP archive.

        Example:
            Suppose we have a ZIP archive named 'example.zip' containing files: '1011_BBOX5.txt' and '1012_BBOX5.txt'.
            Calling check_file_in_zip('example.zip', '\\d+_BBOX5') will return ['1011_BBOX5.txt', '1012_BBOX5.txt'].
        """
        with zipfile.ZipFile(zip_path, 'r') as zip_arch:
            matching_files = [file_name for file_name in zip_arch.namelist()
                              if re.search(rf'{regex_pattern}', file_name)]
            logger.debug(matching_files)

        if not matching_files:
            raise FileNotFoundError(
                f"No files matching the regex pattern '{regex_pattern}' found in the ZIP archive '{zip_path}'")

        return matching_files
