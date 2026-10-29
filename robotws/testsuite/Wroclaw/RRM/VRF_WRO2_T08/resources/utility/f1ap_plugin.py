import re
import shutil
import subprocess
from glob import glob

import requests
from bs4 import BeautifulSoup

from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.wro_logger import logger


def prepare_f1ap_plugin():
    wireshark_ver = _get_major_wireshark_version()
    local_plugin_path = _download_newest_f1ap_plugin(wireshark_ver)
    if local_plugin_path is not None:
        left_plugins = _get_local_f1ap_plugins(wireshark_ver)
        if len(left_plugins) > 1:
            _remove_files(left_plugins)
            left_plugins = []
        if not len(left_plugins):
            _move_plugin_to_appropriate_directory(local_plugin_path, wireshark_ver)
    nr_of_active_plugins = len(_get_local_f1ap_plugins(wireshark_ver))
    assert nr_of_active_plugins == 1, f"{nr_of_active_plugins} f1ap plugins present after prepare_f1ap!"


def _get_major_wireshark_version():
    return '.'.join(str(subprocess.check_output(['wireshark', '-v'])).split(' ')[1].split('.')[:2])


def _remove_files(file_list):
    for f in file_list:
        logger.info(f"Removing f1ap plugin: {f}", also_to_console=True)
        subprocess.call(['sudo', 'rm', f])


def _get_local_f1ap_plugins(wireshark_ver):
    return glob("/usr/lib/x86_64-linux-gnu/wireshark/plugins/{}/epan/nokiaf1ap*bookworm.so".format(wireshark_ver))


def _download_newest_f1ap_plugin(wireshark_ver):
    local_plugin_path = None
    with open('/etc/token/ca_ute_artifactory_readonly', 'r', errors='ignore') as f:
        key = f.read()
        headers = {'Authorization': f'Bearer {key.strip()}'}
    repo_link = f"https://artifactory-hz1.int.net.nokia.com/artifactory/wslte5g_plugins-local/Nokia_F1_AP/"
    try:
        html_file = _get_html_repository_page(repo_link, f'/tmp/f1ap_plugins.html', headers)
        plugin_version = _scrap_correct_f1ap_plugin_version(html_file)
        html_file2 = _get_html_repository_page(f'{repo_link}{plugin_version}/', f'/tmp/f1ap_plugin.html', headers)
        plugin_name = _scrap_correct_f1ap_plugin_filename(html_file2, wireshark_ver)
        local_plugin_path = _download_f1ap_plugin(f'{repo_link}{plugin_version}/', plugin_name, headers)
    except requests.RequestException as e:
        logger.info(f"Failed to download f1ap plugin: {e}", also_to_console=True)
    finally:
        return local_plugin_path


def _get_html_repository_page(repository_link, target_file, headers):
    with requests.get(url=repository_link, stream=True, headers=headers, timeout=10) as request:
        if request.status_code == 200:
            logger.info(f"Downloading {repository_link} to {target_file}")
            with open(target_file, "wb") as f:
                shutil.copyfileobj(request.raw, f, length=16 * 1024 * 1024)
        else:
            raise requests.RequestException(f"'get' request error on link {repository_link}")
    return target_file


def _scrap_correct_f1ap_plugin_version(html_file):
    with open(html_file) as html:
        soup = BeautifulSoup(html, 'html.parser')
    files_on_repo = [link.get('href') for link in soup.find_all('a')]
    if not files_on_repo:
        raise ValueError("No F1AP plugins found on repo")
    plugin_version = sorted(files_on_repo)[-1]
    return plugin_version


def _scrap_correct_f1ap_plugin_filename(html_file, wireshark_ver):
    with open(html_file) as html:
        soup = BeautifulSoup(html, 'html.parser')
    files_on_repo = [link.get('href') for link in soup.find_all('a')]
    plugin_name = [name for name in files_on_repo if
                   re.match(r'^nokiaf1ap-{}-.*bookworm\.so$'.format(wireshark_ver), name)]
    if len(plugin_name) > 1:
        logger.info("Found {} matching plugins - first one will be applied. "
                    "All matching plugins found on repository: {}"
                    .format(len(plugin_name), plugin_name), also_to_console=True)
    return plugin_name[0]


def _download_f1ap_plugin(repo_link, plugin_name, headers):
    plugin_link = repo_link + plugin_name
    local_plugin_path = '/tmp/{}'.format(plugin_name)
    with requests.get(url=plugin_link, stream=True, headers=headers, timeout=10) as request:
        if request.status_code == 200:
            logger.info("Downloading f1ap plugin: {}".format(plugin_link), also_to_console=True)
            with open(local_plugin_path, "wb") as f:
                shutil.copyfileobj(request.raw, f, length=16 * 1024 * 1024)
        else:
            raise Exception("Invalid plugin link: '{}'".format(plugin_link))
    return local_plugin_path


def _move_plugin_to_appropriate_directory(plugin_path, wireshark_ver):
    subprocess.call(['sudo', 'mv', plugin_path,
                     '/usr/lib/x86_64-linux-gnu/wireshark/plugins/{}/epan/'.format(wireshark_ver)])


if __name__ == '__main__':
    prepare_f1ap_plugin()
