import re
import shutil
import subprocess
from glob import glob

import requests
from bs4 import BeautifulSoup

from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.admin import Admin5G
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.wro_logger import logger


def prepare_mcshark():
    with Admin5G() as admin:
        soft_ver = _unify_branch_name(admin.get_sw_version())
    wireshark_ver = _get_major_wireshark_version()
    os_release = _get_os_release_version()
    local_plugin_path = _download_mcshark_plugin_for_soft(soft_ver, wireshark_ver, os_release)
    if local_plugin_path is not None:
        _remove_mcshark_plugins_not_containing(soft_ver, wireshark_ver, os_release)
        left_plugins = _get_local_mcshark_plugins(wireshark_ver, os_release)
        if len(left_plugins) > 1:
            _remove_files(left_plugins)
            left_plugins = []
        if not len(left_plugins):
            _move_plugin_to_appropriate_directory(local_plugin_path, wireshark_ver)
    nr_of_active_plugins = len(_get_local_mcshark_plugins(wireshark_ver, os_release))
    assert nr_of_active_plugins == 1, f"{nr_of_active_plugins} mcshark plugins present after prepare_mcshark!"


def _unify_branch_name(soft_version):
    if soft_version.split('_')[2] in ['9999', '9990']:
        return 'SBTS00_' + soft_version.split('_', 1)[1]
    return soft_version


def _get_major_wireshark_version():
    return '.'.join(str(subprocess.check_output(['wireshark', '-v'])).split(' ')[1].split('.')[:2])


def _get_os_release_version():
    with open('/etc/os-release', 'r') as f:
        for line in f:
            if 'VERSION_CODENAME' in line:
                return line.split('=')[-1].strip()
    raise ValueError("Could not find OS version in /etc/os-release")


def _remove_mcshark_plugins_not_containing(pattern, wireshark_ver, os_release):
    local_plugins = _get_local_mcshark_plugins(wireshark_ver, os_release)
    _remove_files([plugin for plugin in local_plugins if pattern not in plugin])


def _remove_files(file_list):
    for f in file_list:
        logger.info(f"Removing mcshark plugin: {f}", also_to_console=True)
        subprocess.call(['sudo', 'rm', f])


def _get_local_mcshark_plugins(wireshark_ver, os_release):
    return glob(f"/usr/lib/x86_64-linux-gnu/wireshark/plugins/{wireshark_ver}/epan/mcshark*{os_release}.so")


def _download_mcshark_plugin_for_soft(soft_version, wireshark_ver, os_release):
    local_plugin_path = None
    repo_link = f"https://artifactory-hz1.int.net.nokia.com/artifactory/wslte5g_plugins-local/MCShark/{soft_version}/"
    try:
        html_file = _get_html_repository_page(repo_link, f'/tmp/mcshark_{soft_version}.html')
        plugin_name = _scrap_correct_mcshark_plugin_filename(html_file, wireshark_ver, os_release)
        local_plugin_path = _download_mcshark(repo_link, plugin_name)
    except requests.RequestException as e:
        logger.info(f"Failed to download mcshark plugin: {e}", also_to_console=True)
        if soft_version[-6:] != '000000':
            fallback_soft = soft_version[:-6] + '000000'
            logger.info(f"Trying to download fallback mcshark plugin for soft {fallback_soft}", also_to_console=True)
            local_plugin_path = _download_mcshark_plugin_for_soft(fallback_soft, wireshark_ver)
    finally:
        return local_plugin_path


def _get_html_repository_page(repository_link, target_file):
    with requests.get(url=repository_link, stream=True, timeout=10) as request:
        if request.status_code == 200:
            logger.info(f"Downloading {repository_link} to {target_file}")
            with open(target_file, "wb") as f:
                shutil.copyfileobj(request.raw, f, length=16 * 1024 * 1024)
        else:
            raise requests.RequestException(f"'get' request error on link {repository_link}")
    return target_file


def _scrap_correct_mcshark_plugin_filename(html_file, wireshark_ver, os_release):
    with open(html_file) as html:
        soup = BeautifulSoup(html, 'html.parser')
    files_on_repo = [link.get('href') for link in soup.find_all('a')]
    plugin_name = [name for name in files_on_repo if
                   re.match(rf'^mcshark-{wireshark_ver}-.*{os_release}\.so$', name)]
    if len(plugin_name) > 1:
        logger.info(f"Found {len(plugin_name)} matching plugins - first one will be applied. "
                    f"All matching plugins found on repository: {plugin_name}", also_to_console=True)
    return plugin_name[0]


def _download_mcshark(repo_link, plugin_name):
    plugin_link = repo_link + plugin_name
    local_plugin_path = f'/tmp/{plugin_name}'
    with requests.get(url=plugin_link, stream=True, timeout=10) as request:
        if request.status_code == 200:
            logger.info(f"Downloading mcshark: {plugin_link}", also_to_console=True)
            with open(local_plugin_path, "wb") as f:
                shutil.copyfileobj(request.raw, f, length=16 * 1024 * 1024)
        else:
            raise Exception(f"Invalid plugin link: '{plugin_link}'")
    return local_plugin_path


def _move_plugin_to_appropriate_directory(plugin_path, wireshark_ver):
    subprocess.call(['sudo', 'mv', plugin_path, f'/usr/lib/x86_64-linux-gnu/wireshark/plugins/{wireshark_ver}/epan/'])


if __name__ == '__main__':
    prepare_mcshark()
