"""
:copyright: Nokia
:author: patryk.niewiejski@nokia.com
:maintainer: patryk.niewiejski@nokia.com

File contains software packages related methods
"""

import os
import requests
import random
import subprocess

from robot.api.deco import keyword
from robot.api import logger

from paramiko import SSHClient, AutoAddPolicy, SFTPClient
import requests


ROBOT_AUTO_KEYWORDS = False
ARTIFACTORY_SW_URL = \
    r"https://artifactory-espoo2.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-local/build/"
WFT_API_URL = "https://wft.int.net.nokia.com:8091/ALL/api/v1/promotion.json"
WFT_API_KEY = "59Tc7CmEXbofWQ1A1h6bBIQPhXIitNOWT65bxiyI"


@keyword(name="Download SW Package")
def download_sw_package(sw_package, download_path="/home/ute/Downloads", testpackage=None):
    """
    Downloads provided SW Package from Artifactory server. Allows to select testpackage and download location.
    Also checks if file already exists.
    Args:
        sw_package (string): SW package (ex. "SBTS00_ENB_9999_240410_000001")
        download_path (string): Location for downloaded files (default: /home/ute/Downloads)
        testpackage (string): Testpackage version ("T1", "T2" or None)

    Returns:
        full_path (string) - Returns full path of downloaded file
        (ex. "/home/ute/Downloads/SBTS00_ENB_9999_240410_000001_release_BTSSM_downloadable_A54.zip")
    """
    sw_dict = investigate_sw_package(sw_package)
    if sw_dict["trunk"]:  # Replace release to SBTS00 if Trunk
        sw_package = sw_package.replace(sw_dict["release"], "SBTS00")
    if sw_dict["testpackage"] is not None:  # Remove T1 or T2 from SW package
        sw_package = sw_package.replace(sw_dict["testpackage"], "")
        testpackage = sw_dict["testpackage"]

    full_file_name = build_package_name(sw_package, testpackage)

    full_path = os.path.join(download_path, full_file_name)
    if os.path.isfile(full_path):
        return full_path

    if not os.path.exists(download_path):
        os.makedirs(download_path)

    sufix_url = f"{sw_dict['release']}{'_FSM3' if sw_dict['platform'] == 'FSM3' else ''}/{sw_package}/{full_file_name}"
    url = ARTIFACTORY_SW_URL + sufix_url
    head = requests.head(url)
    if head.status_code == 200:
        response = requests.get(url, stream=True)
        with open(full_path, 'wb') as file:
            for chunk in response.iter_content(chunk_size=8192):
                file.write(chunk)
        return full_path
    else:
        raise Exception(f"SW package {full_file_name} does not exist on the server."
                        f"Status code: {response.status_code}")


@keyword(name="Investigate SW Package")
def investigate_sw_package(sw_package):
    """
    Parses provided SW package and returns detailed info from its name.
    Args:
        sw_package (string): SW package (ex. "SBTS00_ENB_9999_240410_000001")

    Returns:
        investigated_sw_package (dict) - Dictionary contains:
            - release (ex. "SBTS00"),
            - platform (ex. "ENB"),
            - trunk (ex. True),
            - version (ex. "240410"),
            - revision (ex. "000001"),
            - testpackage (ex. "T1")
    """
    splited_sw_package = sw_package.split("_")
    if len(splited_sw_package) != 5:
        raise Exception(f"SW Package should be build as RELEASE_PLATFORM_TRUNK_VERSION_REVISION as 5 elements."
                        f"Instead contains {len(splited_sw_package)} elements")
    release = splited_sw_package[0]
    platform = splited_sw_package[1]
    trunk = True if splited_sw_package[2] == "_9999_" else False
    version = splited_sw_package[3]
    revision = splited_sw_package[4]
    testpackage = "T1" if "T1" in revision else "T2" if "T2" in revision else None
    return {"release": release,
            "platform": platform,
            "trunk": trunk,
            "version": version,
            "revision": revision,
            "testpackage": testpackage}


@keyword(name="Build Package Name")
def build_package_name(sw_package, testpackage=None):
    """
    Helper for building proper SW package name.
    Args:
        sw_package (string): SW package (ex. "SBTS00_ENB_9999_240410_000001")
        testpackage (string): Testpackage version ("T1", "T2" or None)

    Returns:
        full_packge_name (str) - Full name of package file
        (ex. "SBTS00_ENB_9999_240410_000001_release_BTSSM_downloadable_A54")
    """
    package_sufix = "_release_BTSSM_downloadable_A54.zip"
    if testpackage is not None and (testpackage == "T1" or testpackage == "T2"):
        package_sufix = f"_release_BTSSM_downloadable_testpackage_{testpackage}_A54.zip"
    return sw_package + package_sufix


@keyword(name="Which SW Testpackage To Update")
def which_sw_package_to_update(active_sw_package, passive_sw_package):
    package_name = active_sw_package.replace("T1", "").replace("T2", "")

    # Passive is not same version as active
    if package_name not in passive_sw_package:
        if "T1" in active_sw_package:
            return package_name + "T2"
        elif "T2" in active_sw_package:
            return package_name
        else:
            return package_name + "T1"

    # Passive is same version as active
    available_options = ["", "T1", "T2"]
    active_testpackage = "T1" if "T1" in active_sw_package else "T2" if "T2" in active_sw_package else ""
    passive_testpackage = "T1" if "T1" in passive_sw_package else "T2" if "T2" in passive_sw_package else ""
    if active_testpackage in available_options:
        available_options.remove(active_testpackage)
    if passive_testpackage in available_options:
        available_options.remove(passive_testpackage)

    return package_name + random.choice(available_options)


@keyword(name="Copy File To Another Host")
def copy_file_to_another_host(local_file_path, remote_host, remote_file_path=None):
    if remote_file_path is None:
        remote_file_path = local_file_path

    # File has to exists on local host
    if not os.path.isfile(local_file_path):
        raise Exception(f"File or path to a file '{local_file_path}' does not exists!")
    logger.debug(f"File '{local_file_path}' exists on local host")

    # Get file size to check available space on remote host
    local_file_size = os.path.getsize(local_file_path)
    logger.debug(f"local_file_size: {local_file_size}")

    # Get chcksum to confirm files integrity
    local_file_checksum = subprocess.run(['sha256sum', local_file_path], capture_output=True, text=True,
                                         check=True).stdout.split()[0]
    logger.debug(f"local_file_checksum: {local_file_checksum}")

    with SSHClient() as ssh:
        ssh.load_system_host_keys()
        ssh.set_missing_host_key_policy(AutoAddPolicy())
        ssh.connect(remote_host)

        # Checking if file exists. If so calculate and compare its checksum with local one
        cmd = f"[ -f '{remote_file_path}' ] && sha256sum {remote_file_path} || :"
        file_exists = ssh.exec_command(cmd)[1].read().decode()
        if file_exists == "":
            logger.debug(f"File '{remote_file_path}' does not exists on remote host")
        else:
            file_exists = file_exists.split()[0]
            logger.info(f"File {remote_file_path} already exists on remote host. Its sha256 cheksum is {file_exists}")
            if file_exists == local_file_checksum:
                logger.info(f"Both local and remote file have same sha256 checksum. File sending skipped")
                return remote_file_path
            logger.info(f"Local ({local_file_checksum}) and remote ({file_exists}) file checksums are not the"
                        f"same!. File {local_file_path} will be send")

        # Checking disk space on remote host (in bytes)
        remote_disk_space = int(ssh.exec_command("df --output=avail /home | tail -1")[1].read().decode().strip())*1024
        logger.debug(f"remote_disk_space: {remote_disk_space}")
        if remote_disk_space < local_file_size:
            raise Exception(f"There are not enough disk space left on remote host to send file!")

        # Proper file transfer
        with ssh.open_sftp() as sftp:
            sftp.put(localpath=local_file_path, remotepath=remote_file_path)
            # Received file integrity valiation via checksum comparation
            remote_file_checksum = ssh.exec_command(f"sha256sum {remote_file_path}")[1].read().decode().split()[0]
            logger.debug(f"remote_file_checksum: {remote_file_checksum}")
            if remote_file_checksum != local_file_checksum:
                raise Exception(f"Local ({local_file_checksum}) and remote ({remote_file_checksum})"
                                f"file checksums are not the same!")
            logger.info("File transfer successfully completed!")
        return remote_file_path


@keyword(name="Get Last Promoted Builds For Branch")
def get_last_promoted_builds_for_branch(branch="SBTS00", items=1, promotion_tag="REGRESSION"):
    params = {
        "access_key": WFT_API_KEY,
        "view[items]": items,
        "view[sorting_field]": "created_at",
        "view[sorting_direction]": "DESC",
        "view[group_by]": "promotion_tag.tag",
        "view[columns[][id]]": ["branch.title", "build.baseline", "created_at"],
        "view[view_filters_attributes[880374364999341]][column]": "promotion_tag.tag",
        "view[view_filters_attributes[880374364999341]][operation]": "eq",
        "view[view_filters_attributes[880374364999341]][value][]": promotion_tag,
        "view[view_filters_attributes[799598192158904]][column]": "branch.title",
        "view[view_filters_attributes[799598192158904]][operation]": "eq",
        "view[view_filters_attributes[799598192158904]][value][]": branch,
    }
    response = requests.get(WFT_API_URL, params=params, timeout=60)
    if response.status_code == 200:
        data = response.json()
        returned_items_count = len(data["items"][promotion_tag])
        if returned_items_count < items:
            if returned_items_count == 0:
                raise Exception(f"Could not get any promoted builds")
            logger.warn(f"WFT returned {returned_items_count} instead of {items} requested promoted builds!")
        builds = [build["build.baseline"] for build in data["items"][promotion_tag]]
        logger.debug(f"Received {returned_items_count} promoted as {promotion_tag} "
                     f"{'builds' if returned_items_count > 1 else 'build'} for branch {branch}: {builds}")
        return builds
    else:
        raise Exception(f"Error: {response.status_code}")


@keyword("Handle Trunk Package")
def handle_trunk_package(sw_package):
    if "_9999_" not in sw_package:
        return sw_package
    return sw_package.replace(sw_package.split("_")[0], "SBTS00")
