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
import re
import json
import requests
import argparse

try:
    from urllib.parse import urlparse
except ImportError:
    from urlparse import urlparse


logger = logging.getLogger()
__all__ = ['update_mcshark_dissector',
           'get_mcshark_dissector_name',
           'is_tshark_plugin_installed',
           'get_f1ap_tshark_filter_string',
           'install_wireshark_plugins',
           'get_latest_available_versions_of_wireshark_plugins']

INSTALL_SCRIPT_URL = 'https://artifactory-hz1.int.net.nokia.com/' \
                     'artifactory/wslte5g_plugins-local/tools/install_wslte_plugins.bash'

VERSION_SCRIPT_URL = 'https://artifactory-hz1.int.net.nokia.com/' \
                     'artifactory/wslte5g_plugins-local/tools/wslte_plugins_info.py'


def read_artifactory_access_token():
    """
    Reads the access token for artifactory
    """
    assert os.path.exists("/etc/token/ca_ute_artifactory_readonly"), "No Token for artifactory found!"

    with open("/etc/token/ca_ute_artifactory_readonly", "r", encoding='utf-8') as token_file:
        access_token = token_file.read().rstrip()
        return access_token


def download_mcshark_dissector_installation_script(target_dir="/tmp", url=INSTALL_SCRIPT_URL):
    """Downloads TTI trace decoder from Artifactory to output_path

    :param str branch: SW branch name
    :param str build: tested SW build
    :param str output_path: target directory for TTI trace decoder download
    :return: str tti_decoder_file_path: direct path to compresed TTI trace decoder file
    """
    session = requests.Session()
    session.trust_env = False

    access_token = read_artifactory_access_token()
    headers = {"Authorization": f"Bearer {access_token}"}

    request = session.get(url, headers=headers, stream=True)

    if request.status_code == 404:
        msg = f"TTI not found, URL seems to be invalid: {url}"
        logger.error(msg)
        raise AssertionError(msg)

    request.raise_for_status()

    target_file = get_target_path(url, target_dir)
    with open(target_file, "wb") as file_:
        for chunk in request.iter_content(1024):
            file_.write(chunk)

    assert os.path.exists(target_file), "Error in downloading file!"
    return target_file


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


def get_mcshark_plugins(plugins):
    """
    Filters all plugins for only the plugins, which include 'mcshark' in the library name
    """
    return [plugin for plugin in plugins if 'mcshark' in plugin['library']]


def get_gnb_dissectors(plugins):
    """
    Filters all plugins for only the plugins, which include 'SBTS' in the library name
    """
    mcshark_plugins = get_mcshark_plugins(plugins)
    return [plugin for plugin in mcshark_plugins if 'SBTS' in plugin['library']]


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

    logger.warning('get_gnb_dissector_name: No mcshark plugin found!')
    return ''


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


def is_gnb_dissector_installed(plugins):
    """
    determines inside of the list of plugins dicts, if a gnb dissector is installed or not,
    and returns the corresponding boolean value
    """
    return bool(get_gnb_dissectors(plugins))


def remove_mcshark_plugins():
    """
    Determines all mcshark plugins from tshark and removes them all from the plugin folders
    """
    plugins = get_installed_tshark_plugins()
    mcshark_plugins = get_mcshark_plugins(plugins)
    for plugin in mcshark_plugins:
        os.remove(plugin['path'])
        logger.info('Removed Plugin: [%s]', plugin['path'])


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
        logger.warning(
            "Failed to update dissector for gNodeB Load %s", gnb_sw_version)


def is_tshark_plugin_installed(plugin_name):
    """
    This function checks in the installed plugins of tshark, if there is a plugin with
    where plugin_name is a part of the plugin name.
    :param plugin_name: (part of) plugin name to check for
    """
    fitting_plugins = [plugin for plugin in get_installed_tshark_plugins() if plugin_name in plugin['library']]

    if len(fitting_plugins) == 1:
        return True
    if len(fitting_plugins) == 0:
        return False

    logger.warning("More than one plugin found for %s", plugin_name)
    return True


def get_f1ap_tshark_filter_string():
    """
    This function returns the filter string for f1ap message filtering. In case the nokiaf1ap plugin
    is installed, it is no more possible to use the 3gpp filter "f1ap" and the filter "nokiaf1ap"
    must be used.
    """
    if is_tshark_plugin_installed("nokiaf1ap"):
        return "nokiaf1ap"
    return "f1ap"


def install_mcshark_dissector_with_script(gnb_sw_version):
    """
    This function downloads the installation script, makes the script executable
    and executes it, with the gnb_sw_version as argument to the --sbts option
    :param gnb_sw_version: The gNodeB Software Version for the dissectors
    """
    if get_mcshark_plugins(get_installed_tshark_plugins()):
        remove_mcshark_plugins()

    installation_script = download_mcshark_dissector_installation_script()
    subprocess.Popen(['chmod', '+x', installation_script]).communicate()
    stdout, stderr = subprocess.Popen([installation_script, '--sbts', gnb_sw_version,
                                       '--authtoken', read_artifactory_access_token()],
                                      stdout=subprocess.PIPE, stderr=subprocess.PIPE).communicate()
    logger.info("Script installation stdout: %s", str(stdout).replace("\\n", "\n"))
    logger.info("Script installation stderr: %s", str(stderr).replace("\\n", "\n"))


def install_wireshark_plugins(gnb_sw_version, plugins=None):
    """
    This function downloads the installation script and plugin info script to be able to install all available
    plugins in the desired or in the latest versions. The versions are given by a dictionary.

    As Version number you can give a specific version or the string "latest" to install the latest available
    plugin version.

    nsetap and nsetapy versions can be checked with help of WFT checking the sub_builds

    *Example Robot Code*

    | ${plugins}    Create Dictionary    nokiaf1ap    latest
    | ...                                nsetap       2.27.0
    | ...                                nsetapx      latest
    | ...                                nokiaxn      17.7.0-p151
    |
    | Install Wireshark Plugins    gnb_sw_version=SBTS00_ENB_9999_241122_000010
    | ...                          plugins=${plugins}


    :param gnb_sw_version: The gNodeB Software Version
    :param plugins: Dictionary containing desired plugins and their versions - see example above
    """
    if plugins is None:
        plugins = {plugin: "latest" for plugin in ["nsetap", "nsetapx", "nokiaf1", "nokiaxn"]}

    if "latest" in plugins.values():
        latest_required = [plugin for plugin, value in plugins.items() if value == "latest"]
        latest_versions = get_latest_available_versions_of_wireshark_plugins(latest_required)
        plugins.update(latest_versions)

    assert any(version != "latest" for version in plugins), "Error in obtaining latest versions"

    installation_script = download_mcshark_dissector_installation_script()
    subprocess.Popen(['chmod', '+x', installation_script]).communicate()
    command = [installation_script, "--force", "rename",
               "--sbts", gnb_sw_version,
               "--authtoken", read_artifactory_access_token()]

    command += [item for pair in plugins.items() for item in [f"--{pair[0]}", pair[1]]]

    logger.info(command)

    stdout, stderr = subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE).communicate()
    logger.info("Script installation stdout: %s", stdout)
    logger.info("Script installation stderr: %s", stderr)


def get_latest_available_versions_of_wireshark_plugins(plugins=None):
    """This calls the downloaded python script to get the latest versions for the given list
    of plugins

    :param plugins: list of plugins, default: ["nsetap", "nsetapx", "nokiaf1", "nokiaxn"]
    """
    version_script = download_mcshark_dissector_installation_script(url=VERSION_SCRIPT_URL)

    if plugins is None:
        plugins = ["nsetap", "nsetapx", "nokiaf1", "nokiaxn"]

    versions = {plugin: "0" for plugin in plugins}

    command = ["python", version_script,
               "--authtoken", read_artifactory_access_token()]

    command += [item for pair in versions.items() for item in [f"--{pair[0]}", pair[1]]]

    stdout, _ = subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE).communicate()
    output_string = str(stdout)
    json_pattern = r'\[.*?\]'
    output_string = output_string.replace("\\n", "")
    matches = re.findall(json_pattern, output_string, re.DOTALL)

    latest = None
    for match in matches:
        try:
            parsed_json = json.loads(match)
            latest = get_parsed_versions(versions.keys(), parsed_json)
        except json.JSONDecodeError:
            pass
    return latest


def get_parsed_versions(plugins, parsed_json):
    """
    This function gets the parsed plugin versions from the json data

    :param plugins: List of plugins to search for
    :param parsed_json: The parsed json data container
    """
    result = {}
    for plugin in plugins:
        item = next((x for x in parsed_json if x['plugin_name'] == plugin), {})
        result[plugin] = item.get('latest_version_available')
    return result


def parse_arguments():
    """
    This function parses the command line arguments providing an interface
    to run plugin installation on the command line
    """
    parser = argparse.ArgumentParser(description='Get latest available versions of Wireshark plugins.')
    parser.add_argument('gnb_sw_version',
                        type=str,
                        help='gNodeB Software Version for plugin installation')
    args = parser.parse_args()
    return args


def main():
    """
    Main function to run the installation from command line.
    Plugins and mcshark get installed for the given gnb_sw_version.
    """
    logging.basicConfig(level=logging.INFO)
    args = parse_arguments()
    print(f"Installing plugins for gNodeB Software Version: {args.gnb_sw_version}")
    install_wireshark_plugins(args.gnb_sw_version)
    print(f"Installing MCSHARK for gNodeB Software Version: {args.gnb_sw_version}")
    install_mcshark_dissector_with_script(args.gnb_sw_version)


if __name__ == "__main__":
    main()
