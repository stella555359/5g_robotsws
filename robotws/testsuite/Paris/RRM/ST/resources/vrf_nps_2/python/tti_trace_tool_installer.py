#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
:copyright: Nokia
:author: Abdrrahmane NEZROUK (Paris Saclay)
:contact: abderrahmane.nezrouk@nokia.com
:maintainer: Abderrahmane Nezrouk (Paris Saclay)
Helpful library to analyse PDML files
"""
import os
import sys
import re
import requests
import tarfile
from moler.device import DeviceFactory
from taf.rfrl.bts.connections import device_aliases
from taf.rfrl.utilities.tl_config import load_moler_configuration_from_tl
from taf.rfrl.utilities.transfer_files import upload_files
from robot.api import logger
from moler.exceptions import CommandFailure
import tempfile


def create_temp_folder():
    """Creates a new temporary folder and returns its path.

    Returns:
      str: The path to the newly created temporary folder.
    """
    temp_dir = tempfile.mkdtemp()
    return temp_dir


def download_and_extract_5g_ttitrace_tools(build_version, destination_dir=None):
    if destination_dir is None:
        destination_dir = "/tmp/ttiTrace"
    content = _get_url_content(f"https://wft.int.net.nokia.com/ext/build_content/{build_version}")
    pattern = r'<file title="{}_5g-ttitrace.txz" url="([^"]+)">.*?</file>'.format(build_version)
    match = re.search(pattern, content)
    _ttitools_txz_url = ""
    _ttidec_deb_url = ""
    if match:
        _ttitools_txz_url = match.group(1)

    pattern = r'<file title="{}_tti-dec.deb" url="([^"]+)">.*?</file>'.format(build_version)
    match = re.search(pattern, content)
    if match:
        _ttidec_deb_url = match.group(1)

    _download_5g_ttitrace_tools(_ttitools_txz_url, _ttidec_deb_url, destination_dir=destination_dir)
    return destination_dir


def Update_evnetsCollect_script(path, side="a"):
    script_file = os.path.join(path, "eventsCollect.sh")
    # Read the file content
    with open(script_file, 'r') as file:
        content = file.read()

    new_content = re.sub(r'OUTPUT_DIR=\/ram',
                         f'OUTPUT_DIR=/ram/node_L2RT{side}0/tmp/',
                         content)
    new_content = re.sub(r'echo "\$\(cat /tmp/CCSRT_NID\)"',
                         f'echo "$(cat /tmp/node_L2RT{side}0/tmp/CCSRT_NID)"',
                         new_content)
    new_content = re.sub(r'portno=\$\(\(5000 \+ \$\(\(16#\$stripped \& 16#F\)\)\)\)',
                         r'portno=$((4510 + $((16#$stripped & 16#F))))',
                         new_content)

    # Write the new content back to the file
    with open(script_file, 'w') as file:
        file.write(new_content)


@load_moler_configuration_from_tl()
def Install_5g_ttitrace_tools(build_version, destination_dir=None,
                              gnb_id=0, du_id=0, common_unit_id=0, capacity_unit_id=0,
                              install_tti_dec=False, force=False, eth_interface_name="etha01"):
    if destination_dir is None:
        destination_dir = create_temp_folder()
    download_and_extract_5g_ttitrace_tools(build_version=build_version, destination_dir=destination_dir)

    if install_tti_dec:
        # Install the 5G TTI trace tools on the test PC VM.
        pc_unit = DeviceFactory.get_device("TEST_PC")
        cmd_chmod = pc_unit.get_cmd(
            cmd_name="chmod",
            cmd_params={'filename': f"{destination_dir}/tti-dec.deb", 'permission': "777"})
        cmd_chmod()
        cmd_install = pc_unit.get_cmd(
            cmd_name="run_script",
            cmd_params={"script_command": f"dpkg -i {destination_dir}/tti-dec.deb"})
        cmd_install()

    source_dir = os.path.join(destination_dir, "ttitrace")
    capacity_unit_device_name = device_aliases.ssh_cap_unit.format('GNB', gnb_id, du_id, common_unit_id,
                                                                   capacity_unit_id)
    bts_cap_unit = DeviceFactory.get_device(capacity_unit_device_name)
    bts_cap_unit.goto_state("FSP")
    cmd_ip_addr = bts_cap_unit.get_cmd(cmd_name="ip_addr", cmd_params={"options": "show {}".format(eth_interface_name)})
    ip_addr = cmd_ip_addr()
    logger.info(f"Installing TTI trace tools on {capacity_unit_device_name} with IP address {ip_addr}",
                also_console=True)
    ipv4_addr = ip_addr.get(eth_interface_name, "").get("IPV4", "")[0].get("IP", "")
    if ipv4_addr in ["192.168.253.36", "192.168.253.40", "192.168.253.44"]:
        Update_evnetsCollect_script(path=source_dir, side="b")  # card on right side
    else:
        Update_evnetsCollect_script(path=source_dir, side="a")  # card on left side

    files = []
    cmd_ls = bts_cap_unit.get_cmd(cmd_name="ls",
                                  cmd_params={"options": '-ltr /opt/tools/ttiTrace/*'})
    try:
        ls_output = cmd_ls()
        logger.info(f" ls_output : {ls_output}", also_console=True)
        files = list(ls_output['files'].keys())
        if ("eventDecoder" in files and "eventsCollect.sh" in files and "eventsTraceCollector" in files
                and "eventsTraceStart.sh" in files and force is False):
            logger.info("TTI traces tools already exist in /opt/tools/ttiTrace/", also_console=True)
            return
    except CommandFailure:
        logger.warn("File /opt/tools/ttiTrace/* doesn't exists on {} device".format(capacity_unit_device_name))

    # installaling script on gNB
    cmd_mkdir = bts_cap_unit.get_cmd(
        cmd_name="run_script",
        cmd_params={"script_command": '[ ! -d "/opt/tools/ttiTrace/" ] && mkdir -p "/opt/tools/ttiTrace/"'}
    )
    cmd_mkdir()
    cmd_rm = bts_cap_unit.get_cmd(
        cmd_name="rm",
        cmd_params={"options": '-rf', "file": "/opt/tools/ttiTrace/*"}
    )
    cmd_rm()
    # Upload of scripts
    upload_files(
        local_dir=f"{source_dir}/tti-dec/bin",
        local_file="eventDecoder",
        device_name=capacity_unit_device_name,
        remote_dir="/opt/tools/ttiTrace",
        timeout=20,
        remove_source_file=False
    )
    filesname = [
        "eventsCollect.sh",
        "eventsTraceCollector",
        "eventsTraceStart.sh",
    ]
    for filename in filesname:
        upload_files(
            local_dir=source_dir,
            local_file=filename,
            device_name=capacity_unit_device_name,
            remote_dir="/opt/tools/ttiTrace",
            timeout=20,
            remove_source_file=False
        )
        logger.info(f"upload of {filename} to {capacity_unit_device_name} on /opt/tools/ttiTrace ")
    cmd_chmod = bts_cap_unit.get_cmd(
        cmd_name="chmod",
        cmd_params={'filename': "/opt/tools/ttiTrace/*", 'permission': "777"})
    cmd_chmod()


def extract_ipv4_address(ip_address_output):
    """
    Extracts only the IPv4 address from interface output.

    Args:
        ip_address_output (str): The output from 'ip addr' command

    Returns:
        str: The IPv4 address or empty string if not found
    """
    import re

    # Pattern to match IPv4 address in the format: inet 192.168.253.40/24
    pattern = r'inet\s+(\d+\.\d+\.\d+\.\d+)/\d+'
    match = re.search(pattern, ip_address_output)

    if match:
        return match.group(1)
    return ""


def _get_url_content(url, raw=False):
    response = requests.get(url)
    content = response.content
    if raw is False:
        if sys.version_info[0] >= 3:
            content = content.decode(errors='replace')
        return requests.utils.unquote(content)
    else:
        return content


def _download_5g_ttitrace_tools(ttitools_txz_url, ttidec_deb_url, destination_dir):
    """Downloads a .txz archive from a URL and extracts it to a specified directory.

    Args:
        url (str): The URL of the .txz archive.
        destination_dir (str): The directory to extract the archive to.
    """
    # Delete the destination directory if it exists
    if os.path.exists(destination_dir):
        os.rmdir(destination_dir)

    # Create the destination directory if it doesn't exist
    os.makedirs(destination_dir, exist_ok=True)

    if ttitools_txz_url:
        # Download the .txz file
        response = requests.get(ttitools_txz_url, stream=True)
        response.raise_for_status()  # Raise an exception for bad status codes

        # Save the downloaded file to a temporary file
        with open(os.path.join(destination_dir, 'temp.txz'), 'wb') as f:
            for chunk in response.iter_content(chunk_size=8192):
                f.write(chunk)

        # Extract the archive
        with tarfile.open(os.path.join(destination_dir, 'temp.txz'), 'r:xz') as tar:
            tar.extractall(path=destination_dir)

        # Delete the temporary file
        os.remove(os.path.join(destination_dir, 'temp.txz'))

    if ttidec_deb_url:
        # Download the tti-dec.deb file
        response = requests.get(ttidec_deb_url, stream=True)
        response.raise_for_status()  # Raise an exception for bad status codes
        # Save the downloaded file to a temporary file
        # Save the downloaded file to a temporary file
        with open(os.path.join(destination_dir, 'tti-dec.deb'), 'wb') as f:
            for chunk in response.iter_content(chunk_size=8192):
                f.write(chunk)
