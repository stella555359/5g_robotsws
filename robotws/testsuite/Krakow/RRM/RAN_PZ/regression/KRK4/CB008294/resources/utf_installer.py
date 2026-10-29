import subprocess
import os
import re

from robot.libraries.BuiltIn import BuiltIn
from robot.api import logger

tl = BuiltIn().get_variable_value("${tl}")

INSTALLER_PATTERN = r"utf_lab_installer\.FB\d{3,4}\.\d\.sh"


def install_latest_utf(download_path="/home/ute/Downloads"):
    """Installs the latest version of UTF Lab.

    :param str download_path: The path to the Downloads folder.
    :return: None if installation succeeded, otherwise raise an exception.
    """
    try:
        update_required = _download_latest_and_verify_update()
        latest_utf = _find_latest_installer(download_path)
        if update_required:
            _run_installer_script(latest_utf, download_path)
        else:
            logger.info("UTF Lab is up to date, no update is needed.", also_console=True)
    except Exception as e:
        logger.error(f"UTF Lab installation failed: {e}")


def remove_existing_installers(download_path):
    """Removes all existing UTF Lab scripts from the specified path.

    :param str download_path: The path to the folder with UTF Lab scripts.
    :return: None
    """
    for filename in os.listdir(download_path):
        if re.match(INSTALLER_PATTERN, filename):
            os.remove(os.path.join(download_path, filename))


def _download_latest_and_verify_update():
    process = subprocess.run(["utf_lab-updates"], capture_output=True, text=True, timeout=60)
    current_version = re.search(r"Currently installed version\s+:\s+(FB\d{3,4}\.\d)", process.stdout)
    latest_version = re.search(r"Latest released version\s+:\s+(FB\d{3,4}\.\d)", process.stdout)
    if current_version and latest_version:
        current_version = current_version.group(1)
        latest_version = latest_version.group(1)
        logger.info(f"\nCurrent UTF Lab version: {current_version} \nLatest UTF Lab version: {latest_version}",
                    also_console=True)
        return current_version < latest_version
    raise ValueError("UTF Lab download failed.")


def _find_latest_installer(download_path):
    latest_installer = None
    for filename in os.listdir(download_path):
        if re.match(INSTALLER_PATTERN, filename):
            if latest_installer is None or int(re.findall(r"FB(\d+)", filename)[0]) > int(
                    re.findall(r"FB(\d+)", latest_installer)[0]):
                latest_installer = filename
    if latest_installer is None:
        raise ValueError("UTF Lab package not found.")
    return latest_installer


def _run_installer_script(installer_filename, download_path):
    logger.info(f"Installing UTF Lab: {installer_filename}", also_console=True)
    installer_path = os.path.join(download_path, installer_filename)
    vm_ip = tl.test_pc.default_ssh_connection_details.addr
    command = ["sudo", "UTE_CLOUD=1", "bash", installer_path, vm_ip]
    subprocess.run(command, check=True, timeout=1200, stdout=subprocess.DEVNULL)
    logger.info(f"UTF Lab installed: {installer_filename}", also_console=True)
