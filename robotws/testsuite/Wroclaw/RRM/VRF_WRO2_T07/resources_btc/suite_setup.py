import os
import pathlib
import re
import shutil
import subprocess
import time
import xml.etree.ElementTree as ET
from subprocess import DEVNULL

import paramiko
import psutil
import requests
import taf.sbts.oam.coam.admin.interface as admin
from packaging.version import Version
from robot.api import logger
from taf.gnb.oam.coam.vdu import vdu
from ute_admin_infomodel import ute_admin_infomodel
from ute_admin_infomodel.exception import InfoModelQueryTimeoutException

path = os.path.dirname(os.path.abspath(__file__)) + '/config/resources/'

nsetapx_urls = ['https://artifactory-espoo1.int.net.nokia.com/artifactory/wslte5g_plugins-local/NSETAP_X/',
                'https://artifactory-blr1.int.net.nokia.com/artifactory/wslte5g_plugins-local/NSETAP_X/',
                'https://artifactory-fpark1.int.net.nokia.com/artifactory/wslte5g_plugins-local/NSETAP_X/',
                'https://artifactory-hz1.int.net.nokia.com/artifactory/wslte5g_plugins-local/NSETAP_X/']
nsetap_urls = ['https://artifactory-espoo1.int.net.nokia.com/artifactory/wslte5g_plugins-local/NSETAP/',
               'https://artifactory-blr1.int.net.nokia.com/artifactory/wslte5g_plugins-local/NSETAP/',
               'https://artifactory-fpark1.int.net.nokia.com/artifactory/wslte5g_plugins-local/NSETAP/',
               'https://artifactory-hz1.int.net.nokia.com/artifactory/wslte5g_plugins-local/NSETAP/']


def get_branch_name(sw_version):
    if 'ENB_999' in sw_version:
        branch_name = 'master'
    else:
        branch_name = sw_version.split('_')[0]
    return branch_name


def get_vran_branch_name(sw_version):
    if '_0.' in sw_version:
        branch_name = 'master'
    else:
        branch_name = 'SBTS' + sw_version.split('_')[0][-4:]
    return branch_name


def get_wireshark_version():
    wireshark_package = subprocess.check_output(['dpkg', '-s', 'wireshark']).decode('utf-8').splitlines()
    full_version = ''.join([line.split()[1] for line in wireshark_package if 'Version: ' in line])
    return '.'.join(full_version.split('.')[0:2])


def get_env_type():
    env_type = ''
    im = ute_admin_infomodel()
    with im.infomodel_context(address="192.168.255.129", port=443):
        check_4g = im.query_infomodel('check /MRBTS-1/RAT-1/BTS_L-*/BTS_CONF-1/NP-*/SCF-*/MRBTS_A-1/LNBTS_A-1',
                                      timeout=5, allow_negative_result=True)
        check_5g = im.query_infomodel('check /MRBTS-1/RAT-1/BTS_L-*/BTS_CONF-1/NP-*/SCF-*/MRBTS_A-1/NRBTS_A-1',
                                      timeout=5, allow_negative_result=True)
        if check_4g and not check_5g:
            env_type = 'LTE'
        elif not check_4g and check_5g:
            env_type = '5G'
        elif check_4g and check_5g:
            logger.error("There is applied multiRAT configuration, please check env type...")
            env_type = 'multiRAT'
        else:
            logger.error("Environment not detected..")
    if not env_type:
        logger.error("Environment is not detected. Stopping preparation of the environment...")
    return env_type


def get_sw_version_vdu():
    admin = vdu()
    admin.connect_to(host='192.168.255.129', port='443', username='Nemuadmin', password='nemuuser', secure=True)
    vdu_status = admin.get_vdu_state_data()
    sw_version = vdu_status['software_version']
    admin.disconnect()
    return sw_version


def get_smod_type():
    admin_conn = admin.admin()
    admin_conn.setup_admin(ip="192.168.255.129", port=443)
    smod_name = admin_conn.get_detected_hw_info()["systemModules"][0]["productName"]
    admin_conn.teardown_admin()
    return smod_name


def boldprint(x):
    return '\033[1m' + str(x) + '\033[0m'


def vran_connection_check():
    try:
        admin = vdu()
        admin.connect_to(host='192.168.255.129', port='443', username='Nemuadmin', password='nemuuser', secure=True)
        admin.disconnect()
        vran_out_msg = "vRAN configuration is present."
        vran = True
    except Exception as exception:
        template = "An exception of type {0} occurred."
        message = (template.format(type(exception).__name__))
        vran_out_msg = (message + " vRAN configuration is not present.")
        vran = False
    return vran, vran_out_msg


def configure_wireshark():
    dest = '/home/ute/.config/wireshark/'
    if vran_connection_check()[0]:
        environment = 'vran'
    else:
        environment = 'sbts'
    if not os.path.exists(dest):
        try:
            os.makedirs(dest, exist_ok=True)
            shutil.copy2(path + 'wireshark_preferences_5g_' + environment, dest + 'preferences')
            shutil.copy2(path + 'wireshark_sslkey_5g_' + environment, dest + 'ssl_keys')
        except OSError as e:
            logger.error(f"Error creating directory {dest}: {e}")
    else:
        shutil.copy2(path + 'wireshark_preferences_5g_' + environment, dest + 'preferences')
        shutil.copy2(path + 'wireshark_sslkey_5g_' + environment, dest + 'ssl_keys')


def change_wts_config_file():
    if vran_connection_check()[0]:
        environment = 'vran'
    else:
        smod_name = get_smod_type()
        if "ASOE" in smod_name:
            environment = 'sbts_asoe'
        elif "ASOH" in smod_name:
            environment = 'sbts_asoh'
        else:
            environment = 'sbts_asil'
    shutil.copy2(path + 'basic_setup_' + environment + '.cfg', '/opt/iphy/WTS_CURRENT/basic_setup.cfg')


def check_symlink_and_create_if_not_exists():
    check_if_symlink_exists = os.path.islink("/opt/iphy/WTS_CURRENT")
    if not check_if_symlink_exists:
        os.symlink("/opt/iphy/latest", "/opt/iphy/WTS_CURRENT")


def check_simulator():
    target_bd = subprocess.check_output(
        ['sshpass', '-p', 'oZPS0POrRieRtu', 'ssh', '-q', 'toor4nsn@192.168.200.1',
         'cd ' '/ffs/run;', 'find', 'TargetBD_*.xml'])
    matched = re.match(r'TargetBD_(.*).xml', target_bd.decode())
    enb_software_version = matched.group(1)
    if 'CUS' in enb_software_version.upper():
        return "CUS"
    elif 'WTS' in enb_software_version.upper():
        return "iPHY"
    elif '5G_AP' in enb_software_version.upper():
        return "5G_AP"
    else:
        dir_list = subprocess.check_output(['sshpass', '-p', 'oZPS0POrRieRtu', 'ssh', '-q', 'toor4nsn@192.168.200.1',
                                            'cd ' '/ffs/run;', 'ls'])
        if 'cus_meta_info' in dir_list.decode():
            return "CUS"
        raise Exception("Simulator could not be detected.")


def detect_plugin(wireshark_version):
    plugin_path = '/home/ute/.local/lib/wireshark/plugins/' + wireshark_version + '/epan/'
    plugin_directory_exists = os.path.isdir(plugin_path)
    if plugin_directory_exists:
        directory_content = os.listdir(plugin_path)
        for my_file in directory_content:
            plugin_name = boldprint(my_file.split('-')[0])
            if my_file.startswith("nsetap"):
                logger.info("%s plugin is in the %s. Proceeding with deletion, to avoid duplication"
                            " of the plugin..." % (plugin_name, plugin_path), also_console=True)
                os.remove(plugin_path + my_file)
    else:
        logger.info("Plugin path doesn\'t exist. It will be created in upcoming step...", also_console=True)


def start_uexgate():
    print("Starting uexgate process...")
    subprocess.Popen(['/opt/cus/bin/uexgate'],
                     stdout=DEVNULL)
    time.sleep(20)
    if check_if_process_is_running("uexgate"):
        logger.info('UExGate process is running.', also_console=True)
    else:
        logger.error('UExGate process is not running.')


def check_if_process_is_running(process_name):
    for proc in psutil.process_iter():
        try:
            if process_name.lower() in proc.name().lower():
                return True
        except (psutil.NoSuchProcess, psutil.AccessDenied, psutil.ZombieProcess):
            pass
    return False


def check_process_which_occupies_port():
    ports = range(49148, 49152)
    output = []
    logger.console("", newline=True)
    for port in ports:
        try:
            ps = subprocess.Popen(('sudo', 'ss', '-t', '-u', '-l', '-p', '-n'), stdout=subprocess.PIPE)
            output.append(subprocess.check_output(('grep', str(port)), stdin=ps.stdout))
            ps.wait()
        except subprocess.CalledProcessError:
            logger.info("%s port is currently not used." % port, also_console=True)
    return output


def kill_process_which_occupies_port():
    output = check_process_which_occupies_port()
    if output:
        for element in output:
            if not isinstance(output, str):
                if 'docker-proxy' in element.decode():
                    logger.info("\nTurning off DCAP...", also_console=True)
                    dcap = subprocess.Popen(['DCAP_Basic_controller', 'stop'], stdout=subprocess.PIPE)
                    out, err = dcap.communicate()
                    if "All DCAP Basic containers stopped successfully." in out.decode():
                        logger.info("DCAP stopped successfully.", also_console=True)
                    else:
                        logger.error("DCAP not stopped successfully.")
                else:
                    regex = re.search(r'pid=(\d+)', element.decode())
                    if regex:
                        pid = regex.group(1)
                        kill_pid = subprocess.run(('kill', str(pid)))
                        check_if_kill_success = kill_pid.returncode
                        if check_if_kill_success == 0:
                            logger.info("Process %s killed successfully." % str(pid), also_console=True)
                        else:
                            logger.error("Process %s not killed successfully." % str(pid))
    else:
        logger.info("SUCCESS All ports are not occupied.", also_console=True)


def reset_site():
    admin_conn = admin.admin()
    admin_conn.setup_admin(ip="192.168.255.129", port=443)
    admin_conn.reset_site(connection="default")
    admin_conn.teardown_admin()
    # Wait until RMODs are available, because of the commissioning in the preparation of the environment
    logger.info("Wait until RMODS are online...")
    check_if_rmods_available()


def execute_command_on_bts(cmd):
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect("192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu")
    ssh.exec_command(cmd)
    ssh.close()


def check_if_rmods_available():
    # Maximum 10 minutes waiting time for RMOD.
    max_rmod_detection_time = 600
    check_rmods = False
    im = ute_admin_infomodel()
    radio_detection_starts = time.time()
    # Timeout 700s, because sometimes it takes very long time for BTS to get up
    with im.infomodel_context(address="192.168.255.129", port=443, timeout=700):
        # Seting up all RMODs in one list.
        rmod_list = []
        get_rmods = im.query_infomodel('get list /MRBTS-1/RAT-1/BTS_L-*/EQM_L-1/RMOD_L-*', timeout=100)
        for dist_name in get_rmods:
            rmod_list.append(dist_name["dist_name"])
        while not check_rmods:
            for rmod in rmod_list:
                try:
                    im.query_infomodel('check {0} is [stateInfo.operationalState=regex"Enabled|enabled"]'
                                       .format(rmod), timeout=max_rmod_detection_time)
                    radio_detected = time.time()
                    logger.info('Radio module %s detected and online' % rmod, also_console=True)
                    logger.info("It has been {0} seconds since the radio module detection".format(
                        radio_detected - radio_detection_starts))
                except InfoModelQueryTimeoutException:
                    radios_detection_problem = time.time()
                    logger.debug('Radio module {0} still not online after {1} secs, rebooting BTS...'.format(
                        rmod, radios_detection_problem - max_rmod_detection_time))
                    reset_site()
                    check_rmod = im.query_infomodel(
                        'get object {0} is [stateInfo.operationalState=regex"Enabled|enabled"]'.format(rmod),
                        timeout=max_rmod_detection_time)
                    # Check if radio module is up and if it is still not reachable exit the loop.
                    if not check_rmod:
                        logger.error('Radio module still not online, please check the configuration...')
                        check_rmods = True
                        break
                # Exit for loop, when last radio module is detected.
                if rmod == rmod_list[-1]:
                    check_rmods = True
                    logger.info("All RMODs detected and online.", also_console=True)
                    break


def check_permissions(filepath):
    try:
        check = os.listdir(filepath)
        for item in check:
            if '.sh' in item:
                full_path = filepath + "/" + item
                access = os.access(full_path, os.X_OK)
                print("File", item, "status of the execution permission:", access)
                if not access:
                    os.chmod(full_path, 0o755)
                    access = os.access(full_path, os.X_OK)
                    logger.info('File %s changed executable permission to: %s' % (item, access), also_console=True)
    except OSError as e:
        print("File or directory not found", e.errno)


def get_download_url(args):
    url, filename = args[0], args[1]
    try:
        r = requests.get(url)
        with open(filename, 'wb') as f:
            f.write(r.content)
            return url
    except Exception as e:
        print('Exception in get_download_url():', e)


def select_newest_plugins_version(plugin_list):
    nsetapx_list = []
    nsetap_list = []
    for version in plugin_list:
        with open(version, "rt") as version_file:
            for line in version_file:
                if 'nsetapx-' in line:
                    nsetapx_split = line.split('<a href="')[1].split('">')[0].rstrip("/")
                    nsetapx_list.append(nsetapx_split)
                if 'nsetap-' in line:
                    nsetap_split = line.split('<a href="')[1].split('">')[0].rstrip("/")
                    nsetap_list.append(nsetap_split)
    nsetapx_list.sort(key=lambda x: Version(x.split('-', 1)[1]))
    nsetap_list.sort(key=lambda x: Version(x.split('-', 1)[1]))
    nsetapx_ver = nsetapx_list[-1]
    nsetap_ver = nsetap_list[-1]
    return nsetapx_ver, nsetap_ver


def select_plugin_file_to_download(plugins_file_content, wireshark_version):
    nsetapx_os = ""
    nsetap_os = ""
    for plugin in plugins_file_content:
        with open(plugin, "rt") as content:
            for line in content:
                if 'bookworm.so"' in line:
                    if wireshark_version in line:
                        if 'nsetapx-' in line:
                            nsetapx_os = line.split('<a href="')[1].split('">')[0]
                        if 'nsetap-' in line:
                            nsetap_os = line.split('<a href="')[1].split('">')[0]
    return nsetapx_os, nsetap_os


def download_plugin_to_proper_location(plugin_url, newest_plugin, plugin_os, wireshark_version, plugin_name):
    plugin_url = os.path.join(plugin_url, newest_plugin, plugin_os)
    plugin_path = '/home/ute/.local/lib/wireshark/plugins/' + wireshark_version + '/epan/'
    pathlib.Path(plugin_path).mkdir(parents=True, exist_ok=True)
    filename = f"{plugin_name}-{wireshark_version}-{newest_plugin.split('-')[1]}+bookworm.so"
    full_path = os.path.join(plugin_path, filename)
    response = requests.get(plugin_url)
    if response.status_code == 200:
        logger.info(f"File {filename} downloaded successfully")
        with open(full_path, "wb") as file:
            file.write(response.content)
        return True
    else:
        logger.error(f"Error during download of {filename}")
        return False


def download_plugin_to_proper_location_with_wget(plugin_url, newest_plugin, plugin_os, wireshark_version, plugin_name):
    plugin_url = os.path.join(plugin_url, newest_plugin, plugin_os)
    plugin_path = f'/home/ute/.local/lib/wireshark/plugins/{wireshark_version}/epan/'
    pathlib.Path(plugin_path).mkdir(parents=True, exist_ok=True)
    filename = f"{plugin_name}-{wireshark_version}-{newest_plugin.split('-')[1]}+bookworm.so"
    full_path = os.path.join(plugin_path, filename)
    command = ['wget', plugin_url, '-O', full_path]
    try:
        result = subprocess.run(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        if result.returncode == 0:
            logger.info(f"File {filename} downloaded successfully to {full_path}")
        else:
            logger.error(f"Error during download of {filename}. Stdout: {result.stdout}, Stderr: {result.stderr}")
        return result.returncode, result.stdout, result.stderr
    except subprocess.TimeoutExpired:
        logger.error(f"Timeout expired. Process not finished.")
        return 1, "", "Timeout expired."
    except Exception as e:
        logger.error(f"An error occurred: {str(e)}")
        return 1, "", f"Error: {str(e)}"


def download_plugin_source_url(urls):
    try:
        for plugin_url in urls:
            plugin_source = requests.get(plugin_url)
            status_code = plugin_source.status_code
            if status_code == 200:
                return True, plugin_source.url
            else:
                return False, plugin_source.url
    except requests.exceptions.HTTPErrorr as err:
        logger.error(f"During download there was error {err}")


def download_url_with_wget(urls):
    for url in urls:
        try:
            command = ["wget", url]
            result = subprocess.run(command, capture_output=True, text=True)
            if result.returncode == 0:
                logger.info(f"URL {url} downloaded successfully!", also_console=True)
                return url
            else:
                logger.error(f"Command failed with return code: {result.returncode}, error message: {result.stderr}")
        except subprocess.CalledProcessError as e:
            logger.error(f"Subprocess error occurred: {e}")
        except Exception as e:
            logger.error(f"An error occurred while downloading {url}: {e}")
    logger.error("All URLs failed to download.")
    return None


def plugin_source_download():
    status_code_nsetapx = 0
    status_code_nsetap = 0
    chosen_plugin_sources = []
    status, nsetapx_source_url = download_plugin_source_url(nsetapx_urls)
    status, nsetap_source_url = download_plugin_source_url(nsetap_urls)
    if (not nsetap_source_url) and (not nsetapx_source_url):
        nsetapx_source_url = download_url_with_wget(nsetapx_urls)
        nsetap_source_url = download_url_with_wget(nsetap_urls)
    while status_code_nsetapx != 200 and status_code_nsetap != 200:
        chosen_plugin_sources.append(nsetapx_source_url)
        chosen_plugin_sources.append(nsetap_source_url)
        if status_code_nsetapx != 200 and status_code_nsetap != 200:
            break
    check_plugin_url_existence(chosen_plugin_sources)
    return chosen_plugin_sources


def check_plugin_url_existence(chosen_plugin_sources):
    match_nsetapx = [x for x in chosen_plugin_sources if re.search('NSETAP_X/', x)]
    match_nsetap = [x for x in chosen_plugin_sources if re.search('NSETAP/', x)]
    if match_nsetapx and match_nsetap:
        print("Both plugin urls works.")
        return True
    elif match_nsetapx and not match_nsetap:
        logger.error("Problem with NSETAP Wireshark plugin URLs.")
        return False
    elif not match_nsetapx and match_nsetap:
        logger.error("Problem with NSETAP-X Wireshark plugin URLs.")
        return False
    else:
        logger.error("Problem with both Wireshark plugin URLs availability.")
        return False


def download_wireshark_plugins(wireshark_version):
    plugin_urls = plugin_source_download()
    plugin_lists = ['nsetapx_list.txt', 'nsetap_list.txt']
    plugin_files_content = ['nsetapx_list_content.txt', 'nsetap_list_content.txt']
    zip_plugins_to_txt = zip(plugin_urls, plugin_lists)
    for zipped_plugin in zip_plugins_to_txt:
        get_download_url(zipped_plugin)
    newest_nsetapx, newest_nsetap = select_newest_plugins_version(plugin_lists)
    download_latest_nsetapx = (plugin_urls[0] + newest_nsetapx, plugin_files_content[0])
    download_latest_nsetap = (plugin_urls[1] + newest_nsetap, plugin_files_content[1])
    for i in (download_latest_nsetapx, download_latest_nsetap):
        get_download_url(i)
    nsetapx_os, nsetap_os = select_plugin_file_to_download(plugin_files_content, str(wireshark_version))
    nsetapx = download_plugin_to_proper_location(
        plugin_urls[0], newest_nsetapx, nsetapx_os, str(wireshark_version), 'nsetapx')
    nsetap = download_plugin_to_proper_location(
        plugin_urls[1], newest_nsetap, nsetap_os, str(wireshark_version), 'nsetap')
    if (not nsetapx) or (not nsetap):
        download_plugin_to_proper_location_with_wget(
            plugin_urls[0], newest_nsetapx, nsetapx_os, str(wireshark_version), 'nsetapx')
        download_plugin_to_proper_location_with_wget(
            plugin_urls[1], newest_nsetap, nsetap_os, str(wireshark_version), 'nsetap')


def check_egate():
    interfaces_file = '/etc/network/interfaces'
    with open(interfaces_file) as f:
        if '10.0.1.3' in f.read():
            return True
        else:
            return False


def check_tox():
    try:
        import tox
        return True
    except Exception as exception:
        logger.info(type(exception).__name__, "module is not installed. "
                                              "Installation will be proceeded...", also_console=True)
        return False


def check_wts_5g():
    wts_script_dir = "/opt/iphy/latest/startWTS.sh"
    wts_needed_ip_list = ['10.0.1.131', '10.0.1.137', '10.0.1.133', '10.0.1.134', '10.0.1.135', '10.0.1.136']
    for ip in wts_needed_ip_list:
        ip_addr_show = subprocess.Popen(['ip', 'addr', 'show', 'eth3'], stdout=subprocess.PIPE)
        grep_configured_ip_address = subprocess.Popen(['grep', ip],
                                                      stdin=ip_addr_show.stdout, stdout=subprocess.PIPE)
        configured_ip_address_exists = list(grep_configured_ip_address.stdout)
        ip_addr_show.wait()
        if configured_ip_address_exists:
            subprocess.call(['sed', '-i', '/%s/d' % ip, wts_script_dir])


def check_iphy_and_cus_config():
    sim_path = '/opt/iphy/latest'
    wts_current = '/opt/iphy/WTS_CURRENT'
    epc_lua = os.path.isfile(sim_path + "/" + 'epc.lua')
    iphy_lua = os.path.isfile(sim_path + "/" + '1enb.lua')
    epc_sh = os.path.isfile(sim_path + "/" + 'epc.sh')
    directory_link = ''
    if os.path.isdir(wts_current) and os.path.islink(wts_current):
        directory_link = os.readlink(wts_current)
        print(directory_link)
    if (epc_lua or iphy_lua or epc_sh) \
            and directory_link == '/opt/iphy/latest':
        return True
    else:
        return False


def check_4g_commissioning():
    # Potential future check in common prep
    im = ute_admin_infomodel()
    im.setup_infomodel()
    im.connect_infomodel()
    check_ctrlts = im.query_infomodel(
        'check /MRBTS-*/RAT-*/BTS_L-*/BTS_CONF-*/NP-*/SCF-*/MRBTS_A-*/LNBTS_A-*/CTRLTS_A-*', timeout=20)

    if check_ctrlts:
        return True
    else:
        return False


def check_if_fttools_present():
    fttools_path = '/home/ute/FTTools'
    fttools_dir = os.path.isdir(fttools_path)
    if fttools_dir:
        return True
    else:
        return False


def check_if_all_common_prep_is_done():
    """Function for execution of common test line preparation both for 4G and 5G.

    It is considered to expand this with potential checks in another functions from this module.
    """
    if check_egate() and check_tox() and check_iphy_and_cus_config() and check_if_fttools_present():
        logger.info('Preparation of the test line already done.', also_console=True)
        return True
    else:
        return False


def install_syslog_flags(mandatory_flag, additional_flags):
    additional_flags.append(mandatory_flag)
    for flag in additional_flags:
        logger.info("%s syslog flag not present in the swconfig.txt. \nProceeding with addition..." % flag,
                    also_console=True)
        cmd = "echo {} >> /ffs/run/swconfig.txt".format(flag)
        execute_command_on_bts(cmd)


def get_swconfig():
    swconfig_txt = subprocess.check_output(
        ['sshpass', '-p', 'oZPS0POrRieRtu', 'ssh', '-q', 'toor4nsn@192.168.255.129',
         'cd ' '/ffs/run;', 'cat', 'swconfig.txt'])
    swconfig_without_spaces = "".join(swconfig_txt.decode().split())  # Create swconfig without spaces inside
    return swconfig_without_spaces


def check_syslog_flags_and_enable_if_needed():
    """This function handles gathering of the syslog file
       If the proper syslog flags are not present in the swconfig.txt on the BTS,
       they will be added to the swconfig.txt and BTS will reset to set this flags up.
    """
    logger.info("Checking proper syslog flags configuration on the BTS...", also_console=True)
    update_needed = False
    mandatory_flag = "0x10041=5"
    additional_flags = ["0x10040=1", "0x1003F=1", "0x210000=2"]
    swconfig = get_swconfig()
    # Negative lookbehind to check if flag is not preceded by '#' sign
    mandatory_flag_check = re.search(r'(?<!#)%s' % mandatory_flag, swconfig)
    if mandatory_flag_check:
        logger.info(
            "%s syslog flag present in the swconfig.txt. BTS reboot not needed." % mandatory_flag, also_console=True)
    else:
        update_needed = True
        install_syslog_flags(mandatory_flag, additional_flags)
    if update_needed:
        logger.info("\nRebooting BTS to enable flags...", also_console=True)
        reset_site()


def get_technology_from_bts():
    im = ute_admin_infomodel()
    with im.infomodel_context(address="192.168.255.129", port=443):
        check_im_object = im.query_infomodel('get object '
                                             '/MRBTS-1/RAT-1/BTS_L-*/BTS_CONF-1/NP-*/SCF-*/MRBTS_A-1/LNBTS_A-1',
                                             timeout=10, allow_negative_result=True)
        if check_im_object:
            return check_im_object['supportedCellTechnology']
        else:
            check_bbmod_object = im.query_infomodel('get object /MRBTS-1/RAT-1/BTS_L-*/BTS_CONF-1/NP-*/SCF-1/MRBTS_A-1/'
                                                    'EQM_A-1/APEQM_A-1/CABINET_A-1/BBMOD_A-1',
                                                    timeout=10, allow_negative_result=True)
            if check_bbmod_object:
                return check_bbmod_object['bbmodBoardConfigType']
            else:
                check_smod_object = im.query_infomodel('get object /MRBTS-1/RAT-1/BTS_L-*/BTS_CONF-1/NP-*/SCF-1/'
                                                       'MRBTS_A-1/EQM_A-1/APEQM_A-1/CABINET_A-1/SMOD_A-1/BBCAP_A-1',
                                                       timeout=10, allow_negative_result=True)
                return check_smod_object['smodBoardConfigType']


def connect_to_vdu():
    admin_vdu = vdu()
    try:
        admin_vdu.connect_to(
            host='192.168.255.129', port='443', username='Nemuadmin', password='nemuuser', secure=True)
        return admin_vdu
    except Exception as exception:
        template = "An exception occurred while connecting to vDU: {0}"
        logger.error(template.format(str(exception)))
        return None


def get_rmod_status(admin_vdu):
    try:
        rmod_status = []
        activation_status = admin_vdu.get_rmods_status()
        for rmod in activation_status:
            rmod_status.append(rmod['availability_status'])
        return rmod_status
    except Exception as exception:
        template = "An exception occurred while getting RMOD status: {0}"
        logger.error(template.format(str(exception)))
        return None


def check_rmod_status(rmod_status):
    if all(item == "on line" for item in rmod_status):
        logger.info("All radio modules on vDU are online.", also_console=True)
        return True
    else:
        logger.info("Not all radio modules are online. Retrying...")
        return False


def get_vdu_rmods_status():
    admin_vdu = connect_to_vdu()
    if not admin_vdu:
        return False
    try:
        number_of_tries = 10
        while number_of_tries > 0:
            time.sleep(12)
            number_of_tries -= 1
            rmod_status = get_rmod_status(admin_vdu)
            if rmod_status is None:
                return False  # Handle error case when getting RMOD status fails
            if check_rmod_status(rmod_status):
                return True  # Exit if all modules are online
            time.sleep(7)
        # If number_of_tries reaches 0 and modules are still not online
        raise AssertionError("Not all radio modules are online after retries.")
    finally:
        admin_vdu.disconnect()


def get_vdu_current_plan_file(vdu_path):
    admin_vdu = connect_to_vdu()
    try:
        filename = "current_plan_vdu.xml"
        admin_vdu.get_current_plan_file(local_dir_path=vdu_path, filename=filename)
        return os.path.join(vdu_path, filename)
    finally:
        admin_vdu.disconnect()


def parse_xml(file_path, uri):
    try:
        tree = ET.parse(file_path)
        ET.register_namespace(prefix='', uri=uri)
        return tree, tree.getroot()
    except ET.ParseError as e:
        logger.error(f"Error parsing XML file {file_path}: {e}")
        return None, None


def find_managed_object(root, target_distname, namespaces):
    return root.find(f".//ns:managedObject[@distName='{target_distname}']", namespaces)


def get_current_values_of_serial_number_and_prod_code(managed_object, namespaces):
    if managed_object is not None:
        prod_code_element = managed_object.find(".//ns:p[@name='prodCodePlanned']", namespaces)
        serial_code_element = managed_object.find(".//ns:p[@name='serialNumberPlanned']", namespaces)
        if prod_code_element is not None and serial_code_element is not None:
            return serial_code_element.text, prod_code_element.text
        else:
            logger.error(f"'prodCodePlanned' or 'serialNumberPlanned' element not found in managedObject")
            return None, None
    else:
        logger.error(f"managedObject not found.")
        return None, None


def update_serial_number_and_prod_code(managed_object, new_serial_number, new_prod_code, namespaces):
    if managed_object is not None:
        prod_code_element = managed_object.find(".//ns:p[@name='prodCodePlanned']", namespaces)
        serial_code_element = managed_object.find(".//ns:p[@name='serialNumberPlanned']", namespaces)
        if prod_code_element is not None and serial_code_element is not None:
            prod_code_element.text = new_prod_code
            serial_code_element.text = new_serial_number
            return True
        else:
            logger.error(f"'prodCodePlanned' or 'serialNumberPlanned' element not found for update")
            return False
    return False


def change_serial_number_and_product_code_from_default_scf(vdu_default_scf_path, vdu_new_plan, target_distname):
    namespaces = {'ns': 'raml21.xsd'}
    tree_current, root_current = parse_xml(vdu_default_scf_path, namespaces['ns'])  # Parse both XML files
    tree_new, root_new = parse_xml(vdu_new_plan, namespaces['ns'])
    if root_current is None or root_new is None:
        return None
    managed_object_current = find_managed_object(root_current, target_distname, namespaces)
    managed_object_new = find_managed_object(root_new, target_distname, namespaces)
    current_serial_number, current_prod_code = get_current_values_of_serial_number_and_prod_code(
        managed_object_current, namespaces)
    if current_serial_number is None or current_prod_code is None:
        return None
    if managed_object_new is not None and update_serial_number_and_prod_code(
            managed_object_new, current_serial_number, current_prod_code, namespaces):
        tree_new.write(vdu_new_plan, encoding='utf-8', xml_declaration=True)
        logger.info(f"Updated serial number and product code.", also_console=True)
        return current_serial_number, current_prod_code
    else:
        logger.error(f"Failed to update elements in managedObject with distName='{target_distname}'")
        return None
