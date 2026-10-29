import subprocess
import re
import requests
import shutil
from bs4 import BeautifulSoup
from glob import glob
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.admin import Admin5G
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log import blog
from taf.sbts.oam.coam.admin import admin

"""
To run MCSharkInstaller go to robotws directory or run it with python3
"""


def prepare_mcshark():
    conn = admin().connect_to()
    soft_ver = _unify_branch_name(conn.get_sw_version())
    admin().teardown()
    wireshark_ver = _get_major_wireshark_version()
    local_plugin_path = _download_mcshark_plugin_for_soft(soft_ver, wireshark_ver)
    if local_plugin_path is not None:
        _remove_mcshark_plugins_not_containing(soft_ver, wireshark_ver)
        left_plugins = _get_local_mcshark_plugins(wireshark_ver)
        if len(left_plugins) > 1:
            _remove_files(left_plugins)
            left_plugins = []
        if not len(left_plugins):
            _move_plugin_to_appropriate_directory(local_plugin_path, wireshark_ver)
    nr_of_active_plugins = len(_get_local_mcshark_plugins(wireshark_ver))
    assert nr_of_active_plugins == 1, "{} mcshark plugins present after prepare_mcshark!".format(nr_of_active_plugins)


def _unify_branch_name(soft_version):
    if soft_version.split('_')[2] in ['9999', '9990']:
        return 'SBTS00_' + soft_version.split('_', 1)[1]
    return soft_version


def _get_major_wireshark_version():
    return '.'.join(str(subprocess.check_output(['wireshark', '-v'])).split(' ')[1].split('.')[:2])


def _remove_mcshark_plugins_not_containing(pattern, wireshark_ver):
    local_plugins = _get_local_mcshark_plugins(wireshark_ver)
    _remove_files([plugin for plugin in local_plugins if pattern not in plugin])


def _remove_files(file_list):
    for f in file_list:
        blog("Removing mcshark plugin: {}".format(f))
        subprocess.call(['sudo', 'rm', f])


def _get_local_mcshark_plugins(wireshark_ver):
    return glob("/usr/lib/x86_64-linux-gnu/wireshark/plugins/{}/epan/mcshark*buster.so".format(wireshark_ver))


def _download_mcshark_plugin_for_soft(soft_version, wireshark_ver):
    local_plugin_path = None
    # repo_link = "https://artifactory-hz1.int.net.nokia.com/artifactory/mcshark-local/{}/".format(soft_version)
    repo_link = f"https://artifactory-hz1.int.net.nokia.com/artifactory/wslte5g_plugins-local/MCShark/{soft_version}/"
    try:
        html_file = _get_html_repository_page(repo_link, '/tmp/mcshark_{}.html'.format(soft_version))
        plugin_name = _scrap_correct_mcshark_plugin_filename(html_file, wireshark_ver)
        local_plugin_path = _download_mcshark(repo_link, plugin_name)
    except Exception as e:
        blog("Failed to download mcshark plugin: {}".format(e))
    finally:
        return local_plugin_path


def _get_html_repository_page(repository_link, target_file):
    with requests.get(url=repository_link, stream=True, timeout=10) as request:
        if request.status_code == 200:
            print("Downloading {url} to {path}".format(url=repository_link, path=target_file))
            with open(target_file, "wb") as f:
                shutil.copyfileobj(request.raw, f, length=16 * 1024 * 1024)
        else:
            raise Exception("'get' request error")
    return target_file


def _scrap_correct_mcshark_plugin_filename(html_file, wireshark_ver):
    with open(html_file) as html:
        soup = BeautifulSoup(html, 'html.parser')
    files_on_repo = [link.get('href') for link in soup.find_all('a')]
    plugin_name = [name for name in files_on_repo if
                   re.match(r'^mcshark-{}-.*buster\.so$'.format(wireshark_ver), name)]
    if len(plugin_name) > 1:
        blog("Found {} matching plugins - first one will be applied. All matching plugins found on repository: {}"
             .format(len(plugin_name), plugin_name))
    return plugin_name[0]


def _download_mcshark(repo_link, plugin_name):
    plugin_link = repo_link + plugin_name
    local_plugin_path = '/tmp/{}'.format(plugin_name)
    with requests.get(url=plugin_link, stream=True, timeout=10) as request:
        if request.status_code == 200:
            blog("Downloading mcshark: {}".format(plugin_link))
            with open(local_plugin_path, "wb") as f:
                shutil.copyfileobj(request.raw, f, length=16 * 1024 * 1024)
        else:
            raise Exception("Invalid plugin link: '{}'".format(plugin_link))
    return local_plugin_path


def _move_plugin_to_appropriate_directory(plugin_path, wireshark_ver):
    subprocess.call(['sudo', 'mv', plugin_path,
                     '/usr/lib/x86_64-linux-gnu/wireshark/plugins/{}/epan/'.format(wireshark_ver)])


if __name__ == '__main__':
    prepare_mcshark()
