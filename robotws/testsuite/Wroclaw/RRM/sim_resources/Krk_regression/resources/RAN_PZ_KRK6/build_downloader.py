"""
:copyright: Nokia Networks
:author: Mateusz Potoniec
:contact: mateusz.potoniec@nokia.com
"""

import argparse
import subprocess

from enum import Enum
from pathlib import Path


class Status(Enum):
    SUCCESS = 1
    ERROR = 0


class Logger:
    def __init__(self):
        self._print_colors = {
            'RED': '\033[91m',
            'GREEN': '\033[92m',
            'YELLOW': '\033[93m',
            'BLUE': '\033[94m',
            'END': '\033[0m'
        }

    def info(self, text: str) -> None:
        """
        Logs info type message on screen

        :param text: Text to print on screen
        :return: None
        """

        self.log(text=text, color="GREEN", text_type="INFO")

    def warning(self, text: str) -> None:
        """
        Logs warning type message on screen

        :param text: Text to print on screen
        :return: None
        """

        self.log(text=text, color="YELLOW", text_type="WARNING")

    def error(self, text: str) -> None:
        """
        Logs error type message on screen

        :param text: Text to print on screen
        :return: None
        """

        self.log(text=text, color="RED", text_type="ERROR")

    def log(self, text: str, color: str, text_type: str = None) -> None:
        """
        Logs message with colored type on screen or, full colored message if type is None.

        :param text: Text to print on screen
        :param color: Color of text, e.g GREEN, YELLOW, RED, BLUE
        :param text_type: Type of message to log e.g Info, Warning, Error. Default None
        :return: None
        """

        if text_type is None:
            print(self._print_colors[color.upper()], text, self._print_colors['END'])
        else:
            print(f"[{self._print_colors[color.upper()]}{text_type}{self._print_colors['END']}]: {text}")


class BuildDownloader:
    def __init__(self, logger=None):
        self._builds_path = "https://artifactory-espoo2.int.net.nokia.com/artifactory/" \
                             "mn-cosi-sran-central-public-local/build/"
        self._build_A54_type = "_release_BTSSM_downloadable_A54.zip"
        if logger is None:
            self._logger = Logger()
        else:
            self._logger = logger

    def run(
        self,
        build_name: str,
        local_path: str = None,
        silent: bool = False,
        check: bool = False,
        not_mount: bool = False
    ) -> Status:
        """
        Process build name and download it to custom path if it was specified or to proper directory in pubs,
        based on build release taken from name

        :param build_name: name of build to download
        :param local_path: path to download if specified or None
        :param silent: bool that determines downloading should print any logs
        :param check: bool that determines if script should only check if build already exist in local path
        :param not_mount: bool, if True script will not mount disks even if they are not mounted already
        :return: Enum class Status.SUCCESS in case of script ended without errors, otherwise Status.ERROR
        """

        if not_mount is False:
            self._mount_pubs(silent)
            self._mount_syve(silent)

        release = self._create_release(build_name)
        pubs_path = self._create_pubs_loacal_path(release)

        if local_path is None:
            local_path = pubs_path
        else:
            if not local_path.endswith('/'):
                local_path += '/'
            if local_path != pubs_path:
                is_build_already_in_pubs = self._check_if_build_already_exist_in_local_path(build_name, pubs_path)
                if is_build_already_in_pubs == Status.ERROR:
                    return Status.ERROR
                if is_build_already_in_pubs:
                    self._logger.warning(f"'{build_name}' is in '{pubs_path}. Your local path: '{local_path}'")
                    self._logger.info(f"Path to build: {pubs_path}{build_name}{self._build_A54_type}")

        is_build_already_in_local_path = self._check_if_build_already_exist_in_local_path(build_name, local_path)
        if is_build_already_in_local_path == Status.ERROR:
            return Status.ERROR

        if is_build_already_in_local_path:
            self._logger.info(f"'{build_name}', IS already in '{local_path}'")
            self._logger.info(f"Path to build: {local_path}{build_name}{self._build_A54_type}")
        else:
            if check:
                self._logger.warning(f"'{build_name}', IS NOT already '{local_path}'")
            else:
                if self._download_build(build_name, release, local_path, silent) == Status.ERROR:
                    return Status.ERROR
        return Status.SUCCESS

    def _download_build(self, build_name: str, release: str, local_path: str, silent: bool) -> Status:
        """
        Downloads specified build to specified local path. If silent is on True it will not print any logs.

        :param build_name: name of build to download
        :param release: release of build to download
        :param local_path: path to download if specified or None
        :param silent: bool that determines downloading should print any logs
        :return: Enum class Status.SUCCESS in case of build download was successful, otherwise Status.ERROR
        """

        download_path = self._process_build_name(build_name, release)
        if silent:
            result = subprocess.run(
                ["wget", download_path, "-P", local_path],
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT
            ).returncode

            if result == 0:
                return Status.SUCCESS
            else:
                return Status.ERROR

        else:
            self._logger.info(f"Downloading '{build_name}' to '{local_path}'")
            result = subprocess.run(["wget", download_path, "-P", local_path]).returncode
            if result == 0:
                self._logger.info(f"'{build_name}' was downloaded to '{local_path}'")
                self._logger.info(f"Path to build: {local_path}{build_name}{self._build_A54_type}")
                return Status.SUCCESS
            else:
                self._logger.error(f"'{build_name}' wasn't downloaded to {local_path}. Wget error code: {result}")
                self._logger.info(f"Check build name, connection to artifactory, or if build is still available.")
                return Status.ERROR

    def _create_release(self, build_name: str) -> str:
        """
        Create release from build name

        :param build_name: name of build to create release from
        :return: release as str
        """

        release = build_name.split("_")
        release = f"{release[0]}_{release[1]}" if release[1] == "FSM3" else release[0]
        return release

    def _create_pubs_loacal_path(self, release) -> str:
        """
        Create pubs local path based on release of build

        :param release: release of build to create path from
        :return: local_path as str
        """

        if "FSM3" in release:
            return f"/mnt/pubs/LOADS/FSM3_{release.split('_')[0]}/"
        else:
            return f"/mnt/pubs/LOADS/{release}/"

    def _process_build_name(self, build_name: str, release: str) -> str:
        """
        Process build name to create download link

        :param build_name: name of build to download
        :param release: release of build
        :return: download link
        """

        if release == "SBTS00" and build_name.split("_")[2] == "9200":
            return self._builds_path + "SBTS_FEINT" + "/" + build_name + "/" + build_name + self._build_A54_type
        return self._builds_path + release + "/" + build_name + "/" + build_name + self._build_A54_type

    def _check_if_build_already_exist_in_local_path(self, build_name: str, local_path: str) -> bool:
        """
        Checks if build is already present in specified local path

        :param build_name: build_name: name of build to download
        :param local_path: local_path: path to download if specified
        :return: True if build is present in local path directory, otherwise False
        """

        build_zip = build_name + self._build_A54_type

        try:
            result = subprocess.run(
                ["ls", local_path],
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT,
                check=True,
            )
            output = result.stdout.decode()
        except subprocess.CalledProcessError as e:
            if e.output.decode() == f"ls: cannot access '{local_path}': No such file or directory\n":
                self._logger.warning(f"Path '{local_path}' does not exist. Will be created with build download")
                return False
            else:
                self._logger.error("Unexpected error occured when checking if build exist in local path. Exiting!")
                return Status.ERROR

        return build_zip in output

    def _mount_pubs(self, silent: bool) -> Status:
        """
        Mounts pubs disk

        :param silent: bool that determines if mounting pubs should print any logs
        :return: Enum class Status.SUCCESS in case of mounting pubs ended without errors, otherwise Status.ERROR
        """

        if not Path('/mnt/pubs/').exists():
            self._logger.warning("Disk: /mnt/pubs/ is not mounted")
            return self._mount_disk(
                ["./mount_storages.sh", "-t", "pubs", "-u", "pubs", "-p", "pubs123"],
                silent
            )
        return Status.SUCCESS

    def _mount_syve(self, silent: bool) -> Status:
        """
        Mounts syve disk

        :param silent: bool that determines if mounting syve should print any logs
        :return: Enum class Status.SUCCESS in case of mounting syve ended without errors, otherwise Status.ERROR
        """

        if not Path('/mnt/syve/').exists():
            self._logger.warning("Disk: /mnt/syve/ is not mounted")
            return self._mount_disk(
                ["./mount_storages.sh", "-t", "syve", "-u", "pubs", "-p", "emssim4Nokia#"],
                silent
            )
        return Status.SUCCESS

    def _mount_disk(self, bash_command: list, silent: bool) -> Status:
        """
        Mounts disk

        :param bash_command: list of parameters for "mount_storages.sh" bash script
        :param silent: bool that determines if mounting disk should print any logs
        :return: Enum class Status.SUCCESS in case of mounting disk ended without errors, otherwise Status.ERROR
        """

        result = subprocess.run(
            bash_command,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            check=True,
        )
        result_stdout = result.stdout.decode("utf-8")

        if not silent:
            if result_stdout != f'Mounting "{bash_command[2]}" storage... \nSUCCESS\n':
                self._logger.error(f"Mounting {bash_command[2]} was not successful")
                return Status.ERROR
            self._logger.info(f"Mounting {bash_command[2]} was successful")
            return Status.SUCCESS

        if result_stdout != f'Mounting "{bash_command[2]}" storage... \nSUCCESS\n':
            return Status.ERROR
        return Status.SUCCESS


def main() -> None:
    """
    Takes arguments from terminal and downloads specified build to specified directory

    :return: None
    """

    parser = argparse.ArgumentParser()
    parser.add_argument("build", help="build name to download")
    parser.add_argument("-p", "--path", help="path to directory where build should be downloaded. "
                                             "If not specified build will be downloaded to proper directory in pubs")
    parser.add_argument("-s", "--silent", action='store_true', help="Perform downloading without printing on console")
    parser.add_argument("-c", "--check", action='store_true', help="Do not download build, just check if already is in "
                                                                   "given local path")
    parser.add_argument("-nm", "--not_mount", action='store_true', help="Don't mount disks, "
                                                                        "even if they are not mounted already.")
    args = parser.parse_args()

    logger = Logger()
    build_downloader = BuildDownloader(logger)
    build_downloader.run(args.build, args.path, args.silent, args.check, args.not_mount)


if __name__ == "__main__":
    main()
