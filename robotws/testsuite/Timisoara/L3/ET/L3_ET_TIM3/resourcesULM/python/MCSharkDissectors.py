"""
Library to install the MCShark dissectors using the installation script provided
by MCShark development. The download url for the script is hard coded,
but can be modified through the keyword "Set MCShark Install Script URL".

The library provides one keyword: "Update MCShark Dissectors"
This keyword gets by argument the sw version. It will check, if a dissector
is already installed. If a mcshark dissector is installed, it is checked, if the
installed dissector fits to the sw version.

If needed, a new/fitting mcshark dissector is installed.

"""
import os
import subprocess
import logging
try:
    from urllib.parse import urlparse
except ImportError:
    from urlparse import urlparse
from common_tools import python_log


logger = logging.getLogger()
__all__ = ['update_mcshark_dissector', 'get_mcshark_dissector_name']
SCRIPT_URL = 'https://artifactory-hz1.int.net.nokia.com/' \
             'artifactory/wslte5g_plugins-local/tools/install_wslte_plugins.bash'


@python_log
def set_mcshark_install_script_url(url):
    """
    overwrites the current set download url of the installation script
    :param url: full url to the bash script.
    """
    global SCRIPT_URL
    SCRIPT_URL = url


@python_log
def get_installed_tshark_plugins():
    """
    Determines all installed plugins and returns a list of all plugins with the folowing
    dictionary structure: {'library': ..., 'version': ..., 'type': ..., 'pat'h: ...}
    """
    data = subprocess.Popen(['tshark', '-G', 'plugins'],
                            stdout=subprocess.PIPE).communicate()
    lines = data[0].decode('ASCII').split("\n")
    for line in lines:
        logger.info(line)
    elements = [[y.strip() for y in x.split('\t')] for x in lines if x]
    return [dict(zip(('library', 'version', 'type', 'path'), item)) for item in elements]


@python_log
def get_mcshark_plugins(plugins):
    """
    Filters all plugins for only the plugins, which include 'mcshark' in the library name
    """
    return [plugin for plugin in plugins if 'mcshark' in plugin['library']]


@python_log
def get_gnb_dissectors(plugins):
    """
    Filters all plugins for only the plugins, which include 'SBTS' in the library name
    """
    mcshark_plugins = get_mcshark_plugins(plugins)
    return [plugin for plugin in mcshark_plugins if 'SBTS' in plugin['library']]


@python_log
def get_mcshark_dissector_name():
    """
    Checks for the current installed tshark/wireshark dissectors, filters for the
    mcshark dissectors and returns the name of the first found mcshark dissector.
    If no mcshark dissector is installed, None is returned.
    """
    plugins = get_installed_tshark_plugins()
    mcshark_plugins = get_gnb_dissectors(plugins)
    if mcshark_plugins:
        mcshark_plugin = mcshark_plugins[0]
        return mcshark_plugin['library']
    logger.warn('get_gnb_dissector_name: No mcshark plugin found!')


@python_log
def mcshark_plugin_fits_sw_version(sw_version):
    """
    Retrieves the name of the installed mcshark dissector and checks, if the
    sw_version is part of the dissector name. Returning True in case it is part
    of the name and False in all different cases.
    """
    mcshark_dissector_name = get_mcshark_dissector_name()
    if mcshark_dissector_name:
        return sw_version in mcshark_dissector_name
    return False


@python_log
def is_gnb_dissector_installed(plugins):
    """
    determines inside of the list of plugins dicts, if a gnb dissector is installed or not,
    and returns the corresponding boolean value
    """
    return bool(get_gnb_dissectors(plugins))


@python_log
def remove_mcshark_plugins():
    """
    Determines all mcshark plugins from tshark and removes them all from the plugin folders
    """
    plugins = get_installed_tshark_plugins()
    mcshark_plugins = get_mcshark_plugins(plugins)
    for plugin in mcshark_plugins:
        os.remove(plugin['path'])
        logger.info('Removed Plugin: [{}]'.format(plugin['path']))


@python_log
def get_target_path(script_url, target_dir):
    """
    Uses the filename, given by the script_url and the target directory, given by target_dir,
    to build up the full path to the downloaded file
    :param script_url: The full path to the download script
    :param target_dir: The path, where the file shall be stored on the local file system
    """
    data = urlparse(script_url)
    _, filename = os.path.split(data.path)
    return os.path.join(target_dir, filename)


@python_log
def download_mcshark_dissector_installatin_script(target_dir='/tmp'):
    """
    Downloads the mcshark install script by the configured url.
    If the file is already existing, before the download is started, the file is getting deleted.
    :param target_dir: The directory, where the file should be stored in. By default /tmp
    """
    target_file = get_target_path(SCRIPT_URL, target_dir)

    if os.path.exists(target_file):
        os.remove(target_file)

    stdout, stderr = subprocess.Popen(['wget', SCRIPT_URL],
                                      cwd=target_dir,
                                      stdout=subprocess.PIPE,
                                      stderr=subprocess.PIPE).communicate()
    logger.info(stdout.decode('utf-8'))
    return target_file


def update_mcshark_dissector(gnb_sw_version, force=False):
    """
    Checks, if the mcshark is installed. If the installed version fits the
    given sw version, nothing is done. If the version does not fit, the
    fitting mcshark is downloaded and installed. If no mcshark is installed,
    it is getting installed.
    """
    tshark_plugins = get_installed_tshark_plugins()
    if is_gnb_dissector_installed(tshark_plugins):
        if mcshark_plugin_fits_sw_version(gnb_sw_version) and not force:
            return
        remove_mcshark_plugins()

    install_mcshark_dissector_with_script(gnb_sw_version)

    if not mcshark_plugin_fits_sw_version(gnb_sw_version):
        logger.warn(
            "Failed to update dissector for gNodeB Load {}".format(gnb_sw_version))


@python_log
def install_mcshark_dissector_with_script(gnb_sw_version):
    """
    This function downloads the installation script, makes the script executable
    and executes it, with the gnb_sw_version as argument to the --sbts option
    :param gnb_sw_version: The gNodeB Software Version for the dissectors
    """
    if get_mcshark_plugins(get_installed_tshark_plugins()):
        remove_mcshark_plugins()

    installation_script = download_mcshark_dissector_installatin_script()
    subprocess.Popen(['chmod', '+x', installation_script]).communicate()
    stdout, stderr = subprocess.Popen([installation_script, '--sbts', gnb_sw_version],
                                      stdout=subprocess.PIPE, stderr=subprocess.PIPE).communicate()
    logger.info("Script installation stdout: {}".format(stdout))
    logger.info("Script installation stderr: {}".format(stderr))
