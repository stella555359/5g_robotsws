from taf.transport.ssh import ssh
from time import sleep
from robot.libraries.BuiltIn import BuiltIn
from datetime import datetime
import requests
import re
import os
import json
import ast
import signal
import subprocess
from packaging import version
from robot.api import logger
from taf.ue import ue

ssh = ssh()
taf_ue = ue()

# TESTLINE CONFIG (from testline_configuration init file)
tl = BuiltIn().get_variable_value("${tl}")
proxy_dict = {'WRO': '10.144.1.10:8080',
              'OULU': '10.158.100.4:8080',
              'TSR': '87.254.212.120:8080',
              'default': '10.144.1.10:8080'}
atlas_url = "https://api.atlas.ext.net.nokia.com/api/v1/get_pcs_to_upgrade/?format=json&team=QT"
taf_lib_source = "https://artifactory-espoo2.int.net.nokia.com/artifactory/api/pypi/ute-pypi-virtual/simple/"
ue_type_dict = {'android':  'android',
                'askey':    'at',
                'quectel':  'quectel',
                'simcom':   'simcom'}


# Define a timeout handler
def timeout_handler(signum, frame):
    raise TimeoutError("Function execution timed out")


# Decorator to add timeout to a function
def with_timeout(timeout):
    def decorator(func):
        def wrapper(*args, **kwargs):
            # Set the timeout handler
            signal.signal(signal.SIGALRM, timeout_handler)
            # Set the alarm
            signal.alarm(timeout)
            try:
                result = func(*args, **kwargs)
            finally:
                # Disable the alarm
                signal.alarm(0)
            return result
        return wrapper
    return decorator


def get_proxy(site):
    if site in proxy_dict:
        logger.debug('{} is found in proxy_dict!'.format(site))
        return proxy_dict[site]
    else:
        logger.debug('{} is NOT found in proxy_dict! \
Default proxy will be used!'.format(site))
        return proxy_dict['default']


def get_plugin_version(url, custom_plugin_version, api_key):
    headers = {
        "X-API-Key": api_key
    }

    response = requests.get(url, headers=headers)

    if response.status_code != 200:
        raise Exception(f"Failed to connect to {url} due to: {response.status_code}")
    builds = re.findall(r'NokiaAndroidApplication-vc-(\d+)-vn-([\d-]+)\.apk', response.text)

    if not builds:
        return None, None

    latest_vc, latest_vn = max(builds, key=lambda x: int(x[0]))
    latest_version = latest_vn.replace("-", ".")
    if custom_plugin_version and custom_plugin_version != "not_set":
        pattern = (
            r'NokiaAndroidApplication-vc-(\d+)-vn-{}\.apk'
            .format(custom_plugin_version.replace(".", "-"))
        )
        logger.info(f"Searching for custom plugin version: {custom_plugin_version}")
        full_build = re.search(pattern, response.text)
        logger.info(f"Full build match: {full_build}")
        if full_build:
            full_build = full_build.group(0)
        else:
            full_build = None
    else:
        full_build = f"NokiaAndroidApplication-vc-{latest_vc}-vn-{latest_vn}.apk"

    return full_build, latest_version


def check_and_upgrade_taf_lib_in_cpc(
        site,
        OS,
        taf_lib_name,
        alias,
        taf_lib_version='',
        proxy_mngr_version=None):
    lock = False
    if site == 'WRO':
        lock = check_lock_in_pc_and_lock_it(alias)
    if not lock:
        try:
            install_flag = False
            installed = ""
            latest = ""
            pip_cmd = 'python -m pip'
            proxy_addr = get_proxy(site)
            proxy = f"--proxy={proxy_addr}"
            check_cmd = "bash -lc '{} index versions {} -i {} {}'".format(
                    pip_cmd, taf_lib_name, taf_lib_source, proxy)
            logger.debug(f"taf lib check cmd: {check_cmd}")
            output = ssh.execute(check_cmd, connection=alias)
            logger.debug(f"taf lib check output: {output}")
            uninstall_cmd = "bash -lc 'echo Y | pip uninstall taf.ue.proxy.mngr_client'"
            uninstall_output = ssh.execute(uninstall_cmd, connection=alias)
            logger.debug(f"taf lib uninstall output: {uninstall_output}")
            for line in output.splitlines():
                if 'INSTALLED' in line:
                    installed = extract_version(line, 'Installed')
                elif 'LATEST' in line:
                    latest = extract_version(line, 'Latest')
            if len(installed) == 0 or len(latest) == 0:
                installed_cmd = "bash -lc '{} show {} | grep Version'".format(
                    pip_cmd, taf_lib_name)
                output = ssh.execute(installed_cmd, connection=alias)
                if 'not found' in output:
                    logger.console(
                        'TAF lib {} is not installed in PC'.format(taf_lib_name))
                    install_flag = True
                else:
                    logger.console("Installed {} {}".format(taf_lib_name, output))
                    BuiltIn().fail(
                        'Failed to get TAF lib {} version, skip TAF lib check!!!'.format(taf_lib_name))
                    return
            elif installed != latest:
                logger.console(
                    'Installed {} version is {}'.format(
                        taf_lib_name, installed))
                logger.console(
                    'Latest {} version is {}\n'.format(
                        taf_lib_name, latest))
            else:
                if proxy_mngr_version is None or proxy_mngr_version == latest:
                    logger.info(
                        "Installed {} version is the latest one, skip following steps!".format(taf_lib_name))
                    return
                else:
                    logger.warn(
                        'Latest proxy manager version is installed but running proxy manager version: {} \
which does not match latest version: {}, starts to kill proxy manager!!!'.format(proxy_mngr_version, latest))
                    kill_proxy(OS, alias)
            result, details = check_android_version_lower_than_10(alias)
            if details == 'skip':
                BuiltIn().fail(
                    'Failed to get UE OS version, skip TAF lib installation steps!!!',
                    'WARN')
                return
            target_proxy_mng_ver = latest if len(taf_lib_version) == 0 else taf_lib_version
            if (not result and compare_versions(installed, latest) > 0):
                logger.console(f"Skip upgrade {taf_lib_name} in PC, \
                               installed version {installed} is higher than target version {latest}!")
                return
            if result or compare_versions(installed, latest) < 0:
                logger.console(
                    '---> Start to install targe version {} of {} in PC\n'.format(target_proxy_mng_ver, taf_lib_name))
                install_taf_lib_in_cpc(OS, pip_cmd, taf_lib_name, target_proxy_mng_ver, site, alias)
            else:
                logger.info(
                    '{} is installed with the target version {}!'.format(taf_lib_name, target_proxy_mng_ver))
        except Exception as e:
            BuiltIn().fail(f"{taf_lib_name} update failed due to {e}")
        finally:
            if site == 'WRO' and not lock:
                unlock_pc(alias)
    else:
        logger.console("PC is locked, skip {} upgrade!".format(taf_lib_name))


def extract_version(line, installed_latest):
    logger.debug(f"{installed_latest} line: {line}")
    installed_latest_ver = line.split()[1].strip()
    pattern = re.compile(r'\d+.\d+.(\w+)?\d+')
    match = re.search(pattern, installed_latest_ver)
    if match:
        installed_latest_ver = match.group()
    else:
        logger.warn(
            'Failed to find a match. {} version: {}'.format(
                installed_latest,
                installed_latest_ver))
        installed_latest_ver = ''
    return installed_latest_ver


def kill_proxy(OS, alias):
    if OS == 'Linux':
        cmd = "ps -ef|grep python.*proxy| grep -v '[g]rep' | awk '{print $2}'"
        logger.debug(f"Kill proxy manager process via command {cmd}")
        output = ssh.execute(cmd, connection=alias)
        if output:
            for pid in output.splitlines():
                pid = pid.strip()
                logger.console(" Proxy process id is {}, start to kill it...\n".format(pid))
                ssh.execute('sudo kill -9 {}'.format(pid), connection=alias)
            sleep(40)
            python_processes = ssh.execute("ps -ef|grep python|grep -v grep", connection=alias)
            logger.console(" Python processes after killing proxy manager: {}".format(python_processes))
    else:
        output = ssh.execute("taskkill /F /IM python.exe", connection=alias)
        logger.debug(f"Kill proxy manager output: {output}")


@with_timeout(60)
def is_proxy_mngr_or_ue_proxy_running(OS, alias):
    """
    Check if the proxy manager or UE proxy is running.

    Args:
        OS (str): The operating system. Possible values are 'Linux' or 'Windows'.
        alias (str): The connection alias.

    Returns:
        tuple: A tuple containing two boolean values. The first value indicates if the proxy manager is running,
               and the second value indicates if the UE proxy is running.
    """
    if OS == 'Linux':
        cmd = "ps -ef|grep taf.ue.proxy| grep -v '[g]rep'"
    else:
        cmd = 'tasklist |findstr "python"'
    ssh.send_command(cmd, connection=alias)
    sleep(2)
    output = ssh.read_output(connection=alias).strip()
    logger.info("is_proxy_running check result is {}".format(output))
    if output and OS == 'Linux':
        return True, True
        '''
        if 'run_ue_proxy_mngr' in output:
            return True, True
        else:
            return False, True  # By default we assume proxy manager is running in linux
        '''
    elif OS == 'Linux':
        return True, False
    elif OS == 'Windows' and 'python' in output:
        return True, True
        '''
        if is_AutoRunProxyMngr_running(alias):
            return True, True
        else:
            return False, True
    elif OS == 'Windows' and is_AutoRunProxyMngr_running(alias):
        return True, False
    else:
        return False, False
        '''
    else:
        return True, False


def install_taf_lib_in_cpc(
        OS,
        pip_cmd,
        taf_lib_name,
        taf_lib_version,
        site,
        alias,
        user,
        kill_proxy_after_install=True):
    proxy_addr = get_proxy(site)
    proxy = f"--proxy={proxy_addr}"
    pip_update_cmd = '{} install --upgrade pip -i {}{}'.format(
        pip_cmd, taf_lib_source, proxy)
    if len(taf_lib_version) == 0:
        taf_lib_version_cmd = ""
    else:
        taf_lib_version_cmd = '=={}'.format(taf_lib_version)
    update_cmd = 'bash -lc "{}; \
{} install {}{} -i {} --proxy={}"'.format(
                                    pip_update_cmd,
                                    pip_cmd,
                                    taf_lib_name,
                                    taf_lib_version_cmd,
                                    taf_lib_source,
                                    proxy_addr
                                )
    logger.debug(f"taf lib update cmd is {update_cmd}")
    output = ssh.execute(update_cmd, connection=alias)
    logger.debug(f"taf lib update output is {output}")
    if 'ERROR' in output:
        BuiltIn().fail(
            "Install {} failed due to {}\n".format(
                taf_lib_name, output))
    elif 'Successfully installed' in output and kill_proxy_after_install:
        logger.console(
            ' Successfully installed {} with version {}!\n'.format(
                taf_lib_name, taf_lib_version))
        kill_proxy(OS, alias)
        proxy_check_and_recovery(OS, alias, user)
    elif 'Successfully installed' in output or 'Requirement already satisfied' in output:
        logger.console(' Successfully installed {}!'.format(taf_lib_name))
    else:
        BuiltIn().fail(
            "Install {} failed due to {}\n".format(
                taf_lib_name, output))


def check_android_version_lower_than_10(alias):
    output = ssh.execute("adb devices | awk '{print $1}'", connection=alias)
    logger.debug(output)
    try:
        if len(output) > 1:
            devices = output.strip().splitlines()[1:]
            for device in devices:
                if re.match(r'\x1b', device):
                    continue
                else:
                    clean_device = re.sub(r'\x1b.*', '', device)
                    logger.debug(clean_device + '\n')
                    adb_cmd = 'adb -s {} shell getprop ro.build.version.release'.format(
                        clean_device)
                    logger.debug('adb_cmd is {}'.format(adb_cmd))
                    release = ssh.execute(adb_cmd, connection=alias)
                    logger.debug(release.splitlines())
                    for line in release.strip().splitlines():
                        pattern = re.compile(r'\d+\b')
                        match = re.search(pattern, line.replace(';', ''))
                        if match:
                            release = match.group()
                            logger.debug('UE OS version is {}'.format(release))
                            if int(release.split('.')[0]) < 10:
                                return True, 'UE device {}\'s android release is {}'.format(
                                    device, release)
            return False, ''
    except Exception as err:
        logger.debug(err)
    return False, 'skip'


def reinstall_taf_lib(taf_lib_name, taf_lib_version):
    cmd = "bash -lc 'pip list|grep {}'".format(taf_lib_name)
    res = os.popen(cmd).read()
    logger.debug(f"taf lib list result is {res}")
    libs = res.strip().splitlines()
    for lib in libs:
        if lib.strip().split()[0] == taf_lib_name:
            installed_version = lib.strip().split()[1]
            logger.info(
                '{}\'s installed version is {}'.format(
                    taf_lib_name, installed_version))
            if installed_version != taf_lib_version:
                logger.console('\n --> {}\'s installed version is {}, \
target version is {}, force reinstallation started....'.format(taf_lib_name, installed_version, taf_lib_version))
                cmd = "bash -lc 'pip install {}=={}'".format(
                    taf_lib_name, taf_lib_version)
                res = os.popen(cmd).read()
                if 'Successfully installed' in res:
                    logger.console(' --> {} successfully installed \
with target version {}\n'.format(taf_lib_name, taf_lib_version))
                else:
                    logger.warn(" --> Install {} version {} failed \
due to {}\n".format(taf_lib_name, taf_lib_version, res))
                return
            return
    logger.console(
        ' {} is not installed in venv! Skip further steps!'.format(taf_lib_name))


def get_switch_on_script_path(alias):
    cmd = "find . -name 'Switch_ON.sh'"
    output = ssh.execute(cmd, connection=alias).splitlines()[0].strip()
    return output.split('/')[1]


def proxy_check_and_recovery(OS, alias, user, restart=False, fatal=False):
    """
    Checks if the proxy manager or UE proxy is running and attempts recovery if not.

    This function verifies the status of the proxy manager or UE proxy on the specified system.
    If the proxy is not running, it triggers recovery steps based on the operating system.
    For Linux, it runs the appropriate startup script. For Windows, it updates the batch file
    to comment out pip commands and restarts the proxy manager.

    Args:
        OS (str): The operating system ('Linux' or 'Windows').
        alias (str): The alias for the SSH connection.
        restart (bool): If True, forces a restart of the proxy.
        fatal (bool): If True, fails the test if update autorunproxymngr.bat is unsuccessful.

    Returns:
        None
    """
    logger.console(f"\n\t ---> Proxy Manager process check in PC... <---")
    is_proxy_mngr, is_proxy_started = is_proxy_mngr_or_ue_proxy_running(OS, alias)
    if not is_proxy_started:
        logger.warn("Proxy manager is not running! Recovery will be triggered!!!")
        if OS == 'Linux':
            if is_proxy_mngr:
                cmd = 'cd ~/.config/autostart; ./taf_ue_proxy_mngr_runner.sh'
            else:
                switch_on_path = get_switch_on_script_path(alias)
                logger.debug("script path is {}".format(switch_on_path))
                if switch_on_path:
                    cmd = 'cd ~/{}; ./Switch_ON.sh'.format(switch_on_path)
                else:
                    BuiltIn().fail("Proxy manager recovery cannot be executed due to missing Switch_ON.sh script !!!")
        else:
            if is_proxy_mngr:
                proxy_mngr_script_path = ssh.execute("find ~/ -name autorunproxymngr.bat", connection=alias).strip()
                proxy_mngr_script_wint_path = convert_to_windows_path(proxy_mngr_script_path)
                if proxy_mngr_script_wint_path:
                    logger.debug("proxy_mngr_script_win_path is {}".format(proxy_mngr_script_wint_path))
                    comment_pip_commands_in_bat_file(proxy_mngr_script_wint_path, fatal, alias)
                else:
                    proxy_mngr_script_path = ssh.execute(
                        f"find /cygdrive/c/Users/{user} -name autorunproxymngr.bat",
                        connection=alias
                    ).strip()
                    if proxy_mngr_script_path.startswith('/cygdrive/c/Users'):
                        comment_pip_commands_in_bat_file(proxy_mngr_script_wint_path, fatal, alias)
                    else:
                        BuiltIn().fail(
                            "Proxy manager recovery cannot be executed due to \
impossible to find autorunproxymngr.bat script !!!"
                        )
                cmd = "powershell Restart-Service AutoRunProxyMngr"
            else:
                cmd = "bash -lc 'python -m taf.ue.proxy.run_ue_proxy -p {}'".format(
                    tl.ues[0].ue_pc_port)
        logger.debug("cmd is {}".format(cmd))
        ssh.send_command(cmd, connection=alias)

        # Check the proxy status in 4 loops with 25 seconds sleep between each loop
        for attempt in range(1, 5):  # 4 attempts
            sleep(25)
            is_proxy_mngr, is_proxy_started = is_proxy_mngr_or_ue_proxy_running(OS, alias)
            if is_proxy_started:
                logger.console(f"Proxy manager is successfully recovered on checking attempt: {attempt}!")
                break
            else:
                logger.warn(f"Proxy manager recovery check attempt {attempt} failed. Retrying...")
        else:
            # If the last attempt fails, raise an error
            BuiltIn().fail("Proxy manager recovery failed after 4 attempts!!!")
    elif is_proxy_mngr:
        if tl.ues[0].proxy_mngr_port is not None and tl.ues[0].proxy_mngr_port != '':
            logger.console("\n Proxy manager is running!")
        else:
            BuiltIn().fail("\nProxy manager is running but proxy_mngr_port is not configured in testline init file!!!")
    else:
        if check_ue_proxy_version_higher_than_1_16_0():
            logger.console("\n UE proxy is running with expected version!")
        elif restart:
            BuiltIn().fail("UE Proxy is running with lower version, restart cannot help!!!")
        else:
            logger.console("\n UE proxy is running with lower version, proxy needs to be restarted!")
            kill_proxy(OS, alias)
            proxy_check_and_recovery(OS, alias, user, restart=True)


def is_AutoRunProxyMngr_running(alias):
    cmd = 'bash -lc "sc query |findstr AutoRunProxyMngr"'
    output = ssh.execute(cmd, connection=alias).strip()
    logger.info('AutoRunProxyMngr check result is {}'.format(output))
    if output:
        pattern = re.compile(r'AutoRunProxyMngr.*')
        proxy_mngr_match = re.search(pattern, output)
        if proxy_mngr_match:
            return True
        logger.debug("Match not found")
        return False
    return False


def check_ue_proxy_version_higher_than_1_16_0():
    try:
        url = 'http://{}:{}/about'.format(
            tl.ues[0].ssh_connection_details.addr,
            tl.ues[0].ue_pc_port)
        # url = 'http://10.42.172.180:5000/about'
        response_dict = requests.get(url).json()
        ue_proxy_version = response_dict['version']
        logger.info('UE proxy version is {}'.format(ue_proxy_version))
        if int(ue_proxy_version.replace('.', '')) < 1160:
            return False
        else:
            return True
    except Exception as err:
        logger.debug(err)
    return False


def get_running_ueproxy(cpc_addr, proxy_mngr_port, ue_type):
    """
    Fetches the running UE proxy service and returns its port and release version.

    This function sends a GET request to the UE proxy manager service to fetch the details of running services.
    It then extracts the port and release version of the first running service.

    Returns:
    list: A list containing the port and release version of the running UE proxy service.
    If no services are running, returns a list of two empty strings.
    """

    # Define the URL and headers for the GET request
    url = "http://{}:{}/services".format(
        cpc_addr,
        proxy_mngr_port)
    headers = {"accept": "application/json"}

    # Send the GET request
    response = requests.get(url, headers=headers)

    # Print the response text
    logger.debug("Running services: {}".format(response.text))

    # Check if the response status code indicates an error
    if response.status_code != 200:
        logger.debug(
            "Error: Received status code {} from server".format(
                response.status_code))
        logger.debug("Message: {}".format(response.text))
        return ["", ""]
    else:
        # Parse the response text into a dictionary
        try:
            # Parse the response text into a dictionary
            services = json.loads(response.text)

            # Print the services dictionary
            logger.debug("Services dict: {}".format(services))

            # Check if any services are running
            if len(services) == 0:
                # If no services are running, log a message and return a list
                # of two empty strings
                logger.console("\n No running services found!")
                return ["", ""]
            else:
                # If services are running, get the port of the first service
                for port, service in services.items():
                    if ue_type in service[0]["service"]["release"]:
                        logger.debug("port is: {}".format(port))

                        # Get the release version of the first service
                        running_ueproxy = services[port][0]["service"]["release"]

                        # Log the release version of the running service
                        logger.console(
                            "\n Running ueproxy release is {}".format(running_ueproxy))

                        # Return the port and release version of the running service
                        return [port, running_ueproxy]
                logger.console("\n No running services found!")
                return ["", ""]
        except json.JSONDecodeError:
            logger.debug("Error: Unable to parse server response as JSON")
            logger.debug("Response: {}".format(response.text))
            return ["", ""]


def get_running_ueproxy_version_from_ue_proxy(cpc_addr, ue_proxy_port):
    """
    Fetches the actual running UE proxy version.

    This function sends a GET request to the UE proxy service to fetch the details of running services.

    Returns:
    string: The actual running UE proxy version like 1.19.0
    If no services are running, returns empty string.
    """

    # Define the URL and headers for the GET request
    url = "http://{}:{}/about".format(
        cpc_addr,
        ue_proxy_port)
    headers = {"accept": "application/json"}

    # Send the GET request
    response = requests.get(url, headers=headers)

    # Print the response text
    logger.debug("Running ue proxy services: {}".format(response.text))

    # Check if the response status code indicates an error
    if response.status_code != 200:
        logger.debug(
            "Error: Received status code {} from server".format(
                response.status_code))
        logger.debug("Message: {}".format(response.text))
        return ""
    else:
        # Parse the response text into a dictionary
        try:
            # Parse the response text into a dictionary
            services = json.loads(response.text)

            # Print the services dictionary
            logger.debug("Services dict: {}".format(services))

            # Check if any services are running
            if len(services) == 0:
                logger.console("\n No running services found!")
                return ""
            else:
                # Get the ue proxy version
                running_ueproxy = services["version"]

                # Log the release version of the running service
                logger.console(
                    "\n Running ueproxy version is {}".format(running_ueproxy))

                # Return the port and release version of the running service
                return running_ueproxy
        except json.JSONDecodeError:
            logger.debug("Error: Unable to parse server response as JSON")
            logger.debug("Response: {}".format(response.text))
            return ""


def stop_ueproxy(cpc_addr, proxy_mngr_port, ue_type):
    port = get_running_ueproxy(cpc_addr, proxy_mngr_port, ue_type)[0]
    if len(port) == 0:
        logger.info("No running services found!")
        return True
    else:
        url = "http://{}:{}/services/stop".format(
            cpc_addr,
            proxy_mngr_port
        )
        headers = {"accept": "application/json"}
        data = {
            "port": port
        }
        response = requests.post(url, headers=headers, data=json.dumps(data))
        logger.debug(f"Stop ue proxy response: {response.text}")
        if response.status_code == 200:
            logger.info("UE proxy stops successfully!")
            return True
        else:
            logger.warn("Latest UE proxy stops Failed!")
            return False


def start_ueproxy_release(ueproxy_release, cpc_addr, proxy_mngr_port, loop_check=3):
    """
    Starts a specific version of the UE proxy.

    Parameters:
    ueproxy_release (str): The release string of the UE proxy.
    The format is 'ueproxy-<ueproxy_ver>-py<python_ver>-<os_name>-<ue_type>-<os_ver>.<rel_format>'.

    Returns:
    bool: True if the UE proxy starts successfully, False otherwise.
    """

    ueproxy_ver = ueproxy_release.split('-')[1]
    python_ver = ueproxy_release.split('-')[2].replace('py', '')
    os_name = ueproxy_release.split('-')[3]
    ue_type = ueproxy_release.split('-')[4]
    os_ver_pattern = r'(\d+\.\d+\.\d+)'
    os_ver = re.search(os_ver_pattern, ueproxy_release.split('-')[5]).group()
    rel_format = ueproxy_release.split('-')[5].split('.')[-1]
    logger.debug(
        "ueproxy_ver: {}, python_ver: {}, os_name: {}, ue_type: {}, os_ver: {}, rel_format: {}".format(
            ueproxy_ver,
            python_ver,
            os_name,
            ue_type,
            os_ver,
            rel_format))
    url = "http://{}:{}/services/start".format(
        cpc_addr,
        proxy_mngr_port
    )
    headers = {
        "accept": "application/json",
        "Content-Type": "application/json",
    }
    data = {
        "ver": ueproxy_ver,
        "python_ver": python_ver,
        "os_name": os_name,
        "ue_type": ue_type,
        "os_ver": os_ver,
        "rel_format": rel_format
    }
    for i in range(loop_check):
        logger.info(
            "Start to start UE proxy release {} for {} time...".format(
                ueproxy_release, i + 1))
        response = requests.post(url, headers=headers, data=json.dumps(data))
        logger.debug(f"ue proxy startup response: {response.text}")
        if response.status_code == 200:
            logger.info(
                "UE proxy release {} is running successfully! "
                "Start to check running ue proxy version...".format(ueproxy_ver)
            )
            running_ueproxy_port = get_running_ueproxy(cpc_addr, proxy_mngr_port, ue_type)[0]
            ueproxy_version = get_running_ueproxy_version_from_ue_proxy(cpc_addr, running_ueproxy_port)
            if ueproxy_version == ueproxy_ver:
                logger.info(
                    "UE proxy version {} is started successfully!".format(ueproxy_ver))
                return True
            elif int(ueproxy_ver.split('.')[-1]) > 100:
                logger.warn(
                    "UE proxy is running in dev version, skip check!!!\n "
                    "Expected version is {}, actual version is {}".format(
                        ueproxy_ver, ueproxy_version
                    )
                )
                return True
            else:
                logger.warn(
                    "UE proxy version {} is not started successfully! "
                    "Expected version is {}, actual version is {}".format(
                        ueproxy_ver, ueproxy_ver, ueproxy_version
                    )
                )
                stop_ueproxy(cpc_addr, proxy_mngr_port, ue_type)
                return False
        elif i == loop_check - 1:
            try:
                response_dict = json.loads(response.text)
                logger.warn(
                    "UE proxy version {} is not started successfully! "
                    "Error message is {}".format(ueproxy_ver, response_dict['detail']))
            except Exception as err:
                logger.warn(
                    "UE proxy version {} is not started successfully! "
                    "Error message is {}".format(ueproxy_ver, response.text))
            return False
        else:
            logger.warn(
                "UE proxy version {} is not started successfully! "
                "Retrying in 30 seconds...".format(ueproxy_ver))
            sleep(30)


def get_downloaded_ueproxy_release(cpc_addr, proxy_mngr_port, ue_type):
    url = "http://{}:{}/releases".format(
        cpc_addr,
        proxy_mngr_port)
    headers = {"accept": "application/json"}
    response = requests.get(url, headers=headers)
    # To print the response text
    logger.debug(f"Downloaded ueproxy releases: '{response.text}'")
    list = ast.literal_eval(response.text)
    # Filter all releases that contain the specified ue_type
    filtered_releases = [release for release in list if ue_type in release]

    # Log or return the filtered releases
    logger.debug(f"Filtered releases containing '{ue_type}': {filtered_releases}")
    return filtered_releases


def sort_downloaded_versions_from_high_to_low(releases):
    """
    Sorts a list of release versions from high to low.

    This function extracts the version number from each release string, parses it into a version object,
    and sorts the releases based on these version objects.

    Parameters:
    releases (list): A list of release strings.
    Each string is expected to have the version number as the second part when split by '-'.

    Returns:
    list: A list of release strings sorted by version number from high to low.
    """

    def extract_version(item):
        """
        Extracts and parses the version number from a release string.

        This function splits the release string by '-',
        takes the second part as the version number, and parses it into a version object.

        Parameters:
        item (str): A release string.

        Returns:
        Version: A version object representing the version number in the release string.
        """
        os_ver_pattern = r'(\d+\.\d+\.\d+)'
        os_ver_minor = re.search(os_ver_pattern, item.split('-')[-1]).group()
        os_ver_major = re.search(os_ver_pattern, item.split('-')[1]).group()
        os_ver = "{}.{}".format(os_ver_major, os_ver_minor)
        return version.parse(os_ver)

    # Sort the releases based on the version numbers
    sorted_releases = sorted(releases, key=extract_version, reverse=True)

    # Print the sorted versions
    logger.debug("Sorted versions are: {}".format(
        [extract_version(item) for item in sorted_releases]))

    # Return the sorted releases
    return sorted_releases


def download_latest_ueproxy_release(cpc_addr, proxy_mngr_port, ue_type):
    url = "http://{}:{}/releases/download/latest".format(
        cpc_addr, proxy_mngr_port)
    headers = {"accept": "application/json"}
    data = {
        "ue_type": ue_type,
        "rel_format": 'pyz'
    }
    response = requests.post(url, headers=headers, data=json.dumps(data))
    logger.debug(f"Download latest ue proxy response: {response.text}")
    if response.status_code == 200:
        logger.info("Latest UE proxy is downloaded successfully!")
        return True
    else:
        logger.warn("Latest UE proxy is downloaded Failed!")
        return False


def check_lock_in_pc_and_lock_it(alias):
    lock_info = ssh.execute('ls', connection=alias)
    logger.debug(f"lock info is {lock_info}")
    if 'controlPC.lock' in lock_info:
        logger.info("PC is locked!!!")
        return True
    else:
        logger.info("PC is not locked!!!")
        ssh.send_command(f"type nul > {tl.tl_cloud_topology}_controlPC.lock", connection=alias)
        logger.console(
            f"\n--> PC locked: /home/wro5gqt or C:\\Users\\wro5gqt\\ > \
{tl.tl_cloud_topology}_controlPC.lock"
        )
        return False


def unlock_pc(alias):
    ssh.send_command(f"rm {tl.tl_cloud_topology}_controlPC.lock", connection=alias)
    logger.console(f"\n--> PC unlocked: /home/wro5gqt or \
C:\\Users\\wro5gqt\\ > {tl.tl_cloud_topology}_controlPC.lock")


def start_latest_ue_proxy(OS, site, alias, ue=tl.ues[0], skip_lock_check=False):
    """
    Checks for the latest UE proxy release and starts it.

    This function first checks for downloaded UE proxy releases on the PC.
    If any are found, it stores the latest one.
    It then downloads the latest UE proxy release and checks the downloaded releases again.
    If the latest downloaded release is different from the previously stored one,
    or if it's not currently running, the function stops the running UE proxy and starts the latest one.
    If the latest release fails to start, and there was a previously stored release,
    the function attempts to start the previously stored release.
    If no new release is downloaded and the latest release is already running, the function does nothing.

    Returns:
    None
    """
    lock = False
    ue_type = ue_type_dict.get(ue.ue_type)
    logger.console(f"\n\t---> Start latest ue proxy for ue type {ue_type} <---")
    try:
        if hasattr(ue, 'ssh_connection_details') and ue.ssh_connection_details.addr:
            cpc_addr = ue.ssh_connection_details.addr
        else:
            cpc_addr = ue.ue_pc_address
        if site == 'WRO':
            lock = check_lock_in_pc_and_lock_it(alias)
        if not lock or skip_lock_check:
            is_proxy_mngr, is_proxy_started = is_proxy_mngr_or_ue_proxy_running(OS, alias)
            if is_proxy_mngr and is_proxy_started:
                last_ok_ueproxy = ""
                latest_downloaded_ueproxy_in_PC = ""
                logger.console("\n Start to check downloaded ue proxy releases in PC...")
                downloaded_releases_full_list = get_downloaded_ueproxy_release(cpc_addr, ue.proxy_mngr_port, ue_type)
                downloaded_releases = [release for release in downloaded_releases_full_list if ue_type in release]
                if len(downloaded_releases) > 0:
                    latest_downloaded_ueproxy_in_PC = sort_downloaded_versions_from_high_to_low(downloaded_releases)[0]
                logger.console("\n Downloaded ue proxy releases in PC: {}".format(', '.join(downloaded_releases)))
                logger.console("\n Start to download latest ue proxy release...")
                if ue_type is not None:
                    download_latest_ueproxy_release(cpc_addr, ue.proxy_mngr_port, ue_type)
                releases_after_download = get_downloaded_ueproxy_release(cpc_addr, ue.proxy_mngr_port, ue_type)
                logger.console("\n After downloading latest release, ue proxy releases in PC: {}".format(
                    ', '.join(releases_after_download)))
                latest_ueproxy = sort_downloaded_versions_from_high_to_low(releases_after_download)[0]
                last_ok_ueproxy_list = sort_downloaded_versions_from_high_to_low(releases_after_download)[1:]
                logger.debug("latest ue proxy: {}".format(latest_ueproxy))
                logger.debug("last ok ue proxy list: {}".format(last_ok_ueproxy_list))
                running_ueproxy = get_running_ueproxy(cpc_addr, ue.proxy_mngr_port, ue_type)[1]
                if latest_downloaded_ueproxy_in_PC != latest_ueproxy or running_ueproxy != latest_ueproxy:
                    logger.console("\n Stop running ue proxy to start ue proxy with latest release...")
                    if stop_ueproxy(cpc_addr, ue.proxy_mngr_port, ue_type):
                        sleep(10)  # Wait for a while to ensure the proxy is stopped
                        logger.console("\n Running UE proxy is successfully stopped. \
Now try to start latest ue proxy {}...".format(latest_ueproxy))
                        if start_ueproxy_release(latest_ueproxy, cpc_addr, ue.proxy_mngr_port):
                            logger.console("\n Start latest ue proxy successfully!")
                        elif len(last_ok_ueproxy_list) > 0:
                            logger.warn("\nLatest UE proxy version {} starts failed, \
now switch to last ok ue proxy list {}".format(latest_ueproxy, ', '.join(last_ok_ueproxy_list)))
                            for last_ok_ueproxy in last_ok_ueproxy_list:
                                if start_ueproxy_release(last_ok_ueproxy, cpc_addr, ue.proxy_mngr_port):
                                    logger.console(f"\n Last ok ue proxy {last_ok_ueproxy} is started successfully!")
                                elif last_ok_ueproxy == last_ok_ueproxy_list[-1]:
                                    BuiltIn().fail("\n Start last ok ue proxy {} failed!".format(last_ok_ueproxy))
                                    return
                                else:
                                    logger.warn(f"\nLast ok version {last_ok_ueproxy} starts failed, \
now switch to next ue proxy...")
                        else:
                            BuiltIn().fail("\nNo available working UE proxy releases can be used!")
                            return
                    else:
                        logger.warn("\nStop running ue proxy failed, skip further steps!")
                else:
                    logger.console("\n No new ue proxy release is downloaded, \
start to restart ueproxy to generate new log folder.")
                    if stop_ueproxy(cpc_addr, ue.proxy_mngr_port, ue_type):
                        sleep(10)  # Wait for a while to ensure the proxy is stopped
                        logger.console("\n Running UE proxy is successfully stopped. Now try to restart it...")
                        if start_ueproxy_release(running_ueproxy, cpc_addr, ue.proxy_mngr_port):
                            logger.console("\n Start ue proxy successfully!")
                        else:
                            BuiltIn().fail("\nStart ue proxy failed!")
                            return
                    else:
                        BuiltIn().fail("\nStop running ue proxy failed, \
please check manually why proxy manager failed to stop ue proxy!")
                        return
            else:
                BuiltIn().fail("\nUE proxy is running or proxy manager is not started, skip following steps!")
                return
        else:
            logger.console("\n Skip ue proxy startup process as PC is locked!!!")
    except Exception as e:
        BuiltIn().fail(f"Start latest ue proxy failed due to {e}")
    finally:
        if site == 'WRO' and not lock and not skip_lock_check:
            unlock_pc(alias)


def check_if_dns_configed_in_cpc(site, alias):
    nameservers_dict = {
        'WRO': {'nameserver 10.42.2.5', 'nameserver 10.42.2.35'},
        'TSR': {'nameserver 10.42.2.5', 'nameserver 10.42.2.35'}}
    nameservers = nameservers_dict.get(site, [])
    print(f"nameservers are {nameservers}")
    try:
        resolv_conf = ssh.execute('cat /etc/resolv.conf', connection=alias)
        logger.info(f"resolv.conf content is\n{resolv_conf}")
        if len(nameservers) == 0:
            logger.warn(f'No nameservers are configured for {site}!')
        else:
            for nameserver in nameservers:
                if nameserver not in resolv_conf:
                    output = ssh.execute(
                        f'echo {nameserver} | sudo tee -a /etc/resolv.conf',
                        connection=alias)
                    logger.info(f"add {nameserver} to resolv.conf\n{output}")
    except Exception as e:
        logger.warn(f"check DNS configuration in CPC failed due to {e}")


def save_proxy_mngr_logs(OS, alias):
    if OS == 'Windows':
        cmd = 'find . -name proxy_mngr.log'
    else:
        cmd = 'sudo find . -name proxy_mngr.log'
    logger.info(f"Command to find proxy_mngr logs is: {cmd}")
    files = ssh.execute(cmd, connection=alias, timeout='60s').splitlines()
    files = [file for file in files if file.endswith('proxy_mngr.log')]
    logger.debug(f"All proxy_mngr logs to be filtered is: {files}")
    if len(files) >= 2:
        files_detail = []
        for file in files:
            file_detail = ssh.execute(f'ls -l {file}', connection=alias).strip('\r\n')
            parse_file_date(file_detail)
            files_detail.append(file_detail)
        logger.info(f"detail info of all filtered logs: {files_detail}")
        files_detail.sort(key=parse_file_date, reverse=True)
        files = [file_detail.split()[-1] for file_detail in files_detail]
    if files:
        newest_file = files[0]
    else:
        newest_file = ''
    logger.info(f"proxy mngr log should be saved is: {newest_file}")
    return newest_file


def parse_file_date(file_detail):
    date_str = ' '.join(file_detail.split()[5:8])
    try:
        date = datetime.strptime(date_str, '%b %d %H:%M')
    except ValueError:
        date = datetime.min
    return date


def is_ue_interface_visible_in_cpc(ue, OS, alias):
    """
    Check if the interface name is visible in the PC.

    This function sends a command to the PC to check if the interface name is visible.
    """
    if hasattr(ue, 'data_transfer') and ue.data_transfer[0].interface_name:
        interface_name = ue.data_transfer[0].interface_name
        if OS == 'Linux':
            cmd = f"ifconfig -a | grep -i {interface_name}"
        else:
            cmd = f"ipconfig | findstr {interface_name}"
        logger.debug(f"Command to check network interface is: {cmd}")
        output = ssh.execute(cmd, connection=alias)
        logger.debug(f"Network interface check result is {output}")
        if interface_name in output:
            logger.info(f"UE interface {interface_name} is visible in the PC!")
        else:
            BuiltIn().fail(f"UE interface {interface_name} is not visible in the PC!")
    else:
        logger.debug("UE interface is not configured in the testline, skip check!")


def get_taf_proxy_mngr_version(cpc_addr, ue):
    try:
        response = subprocess.check_output(
            ["curl", f"http://{cpc_addr}:{ue.proxy_mngr_port}"],
            stderr=subprocess.STDOUT
        ).decode()
        logger.debug(f"Response from curl command is: {response}")
    except Exception as e:
        logger.warn(f"Error running curl: {e}")
        return None
    if response is not None and 'version' in response:
        match = re.search(r'\{.*\}', response)
        if match:
            json_str = match.group(0)
            try:
                # Convert the string output to a dictionary
                output_dict = json.loads(json_str)
                logger.debug("Converted output to dictionary: {}".format(output_dict))
                proxy_mngr_version = output_dict['version']
                logger.console(" Running proxy manager version: {}".format(proxy_mngr_version))
                return proxy_mngr_version
            except json.JSONDecodeError as e:
                logger.debug(f"Error decoding JSON: {e}")
        else:
            logger.debug("Failed to find dict in the response of curl command!")
    else:
        logger.debug("Output is None or does not contain 'version'")
    logger.warn("Failed to get proxy manager version!!!\n")
    return None


def download_taf_ue_package_to_vm(taf_ue_package_download_link, download_folder="~/Downloads"):
    """
    Downloads a TAF UE package from a given URL to the specified local folder.

    This function takes a download link for a TAF UE package, determines the package name,
    creates the download directory if it does not exist, and downloads the file to that directory.
    It streams the download to handle large files efficiently and logs progress to the console.
    If the download fails, it raises a Robot Framework test failure.

    Args:
        taf_ue_package_download_link (str): The URL to download the TAF UE package from.
        download_folder (str, optional): The local folder to save the downloaded file. Defaults to '~/Downloads'.

    Returns:
        None

    Raises:
        BuiltIn().fail: If the download fails due to a requests exception or any other unexpected error.
    """
    try:
        package_name = taf_ue_package_download_link.split("/")[-1]

        # Define the local download path
        downloads_folder = os.path.expanduser(download_folder)
        os.makedirs(downloads_folder, exist_ok=True)
        local_file_path = os.path.join(downloads_folder, package_name)

        # Download the file
        logger.console(f"Downloading {taf_ue_package_download_link} to {local_file_path}...\n")
        response = requests.get(taf_ue_package_download_link, stream=True)
        response.raise_for_status()
        with open(local_file_path, "wb") as file:
            for chunk in response.iter_content(chunk_size=8192):
                file.write(chunk)
        logger.console(f"File downloaded successfully to {local_file_path}.\n")
    except requests.exceptions.RequestException as e:
        BuiltIn().fail(f"Error downloading the file: {e}")
    except Exception as e:
        BuiltIn().fail(f"An unexpected error occurred: {e}")


def upload_taf_ue_package_to_cpc(
    taf_ue_package_download_link,
    pc_address,
    pc_username,
    pc_password,
    pc_download_folder="~/Downloads",
    destination_path="~/"
):
    """
    Downloads a TAF UE package from the specified URL to the local PC's download folder,
    then transfers it to the Control PC (CPC) using SCP.

    This function first ensures the package is downloaded to the local PC (default: ~/Downloads).
    It then uses SCP (with sshpass for password authentication) to copy the package to the
    specified destination path on the remote CPC.

    Args:
        taf_ue_package_download_link (str): The URL to download the TAF UE package from.
        pc_address (str): The address of the remote CPC (e.g., "192.168.1.100").
        pc_username (str): The username for the SCP connection.
        pc_password (str): The password for the SCP connection.
        pc_download_folder (str, optional): The local folder on the PC to save the downloaded file.
                                            Defaults to '~/Downloads'.
        destination_path (str, optional): The destination path on the remote CPC. Defaults to '~/'

    Returns:
        None

    Raises:
        BuiltIn().fail: If the SCP transfer fails or any unexpected error occurs.
    """
    try:
        package_name = taf_ue_package_download_link.split("/")[-1]
        downloads_folder = os.path.expanduser(pc_download_folder)
        local_file_path = os.path.join(downloads_folder, package_name)
        # Transfer the file via SCP
        logger.console(f"Transferring {local_file_path} to {pc_address}:{destination_path}...\n")
        fix_ssh_known_hosts(pc_address)
        scp_command = (
            f"sshpass -p {pc_password} "
            f"scp -o StrictHostKeyChecking=no {local_file_path} "
            f"{pc_username}@{pc_address}:{destination_path}/{package_name}"
        )
        # Use subprocess to execute the SCP command
        result = subprocess.run(scp_command, shell=True, check=True)
        logger.console("File transferred successfully.\n")

    except subprocess.CalledProcessError as e:
        BuiltIn().fail(f"Error transferring the file via SCP: {e}")
    except Exception as e:
        BuiltIn().fail(f"An unexpected error occurred: {e}")


def fix_ssh_known_hosts(ip_address):
    """
    Removes the old SSH host key for a given IP address from the known_hosts file.

    This function ensures that the SSH connection to the specified IP address does not fail
    due to a mismatched or outdated host key in the `~/.ssh/known_hosts` file. It removes
    the offending key and allows the user to establish a new trusted connection.

    Args:
        ip_address (str): The IP address of the remote host whose host key needs to be removed.

    Returns:
        None

    Raises:
        BuiltIn().fail: If the `ssh-keygen` command fails to remove the host key.

    Example Usage:
        fix_ssh_known_hosts("192.168.1.100")
    """
    try:
        # Remove the old host key
        subprocess.run(
            ["ssh-keygen", "-f", "/home/ute/.ssh/known_hosts", "-R", ip_address],
            check=True
        )
        logger.info(f"Removed old host key for {ip_address}")
    except subprocess.CalledProcessError as e:
        BuiltIn().fail(f"Failed to fix known_hosts for {ip_address}: {e}")


def shiv_folder_cleanup(pc_username, alias):
    """
    Cleans up the shiv folder on CPC.

    Args:
        pc_username (str): The username of CPC.
        alias (str): The alias for the PC connection.

    Returns:
        None
    """
    try:
        output = ssh.execute('uname', connection=alias).strip()
        print('the output of uname is: ', output)
        if ('CYGWIN' in output.upper()):
            shiv_folder_path = f"/cygdrive/c/Users/{pc_username}/.shiv"
        elif ("LINUX" in output.upper()):
            shiv_folder_path = f"/home/{pc_username}/.shiv"
        else:
            BuiltIn.fail("Unsupported OS type!")
        logger.console(f" Cleaning up shiv folder at {shiv_folder_path}...\n")
        output = ssh.execute(f"cd {shiv_folder_path} && rm -rf *", connection=alias)
        output = ssh.execute(f"ls {shiv_folder_path}", connection=alias)
        if output.strip():
            logger.console(f" Shiv folder contents after cleanup: {output}\n")
            BuiltIn().fail("Shiv folder is not empty after cleanup.")
            return
        else:
            logger.console(" Shiv folder cleaned up successfully.\n")
    except Exception as e:
        logger.warn(f"Error cleaning up shiv folder: {e}, continue test!!!")


def uninstall_proxy_mngr(OS, alias):
    """
    Uninstalls the proxy manager.

    Args:
        alias (str): The alias for the SSH connection.

    Returns:
        None
    """
    try:
        logger.info(" Uninstalling proxy manager...")
        max_retries = 3  # Maximum number of retries
        pip_check_mngr_cmd = 'bash -lc "python -m pip list|grep taf.ue.proxy.mngr"'
        for attempt in range(1, max_retries + 1):
            proxy_mngr_check_result = ssh.execute(pip_check_mngr_cmd, connection=alias).strip()
            if 'taf.ue.proxy.mngr' not in proxy_mngr_check_result:
                logger.console(" Proxy manager is not installed.\n")
                break
            elif 'No such file or directory' in proxy_mngr_check_result:
                BuiltIn.fail(f"Proxy manager could not be uninstalled due to {proxy_mngr_check_result}")
            else:
                logger.console(f" Proxy manager is installled: {proxy_mngr_check_result}\n")
                logger.console(f" -------> Attempt {attempt} to uninstall proxy manager...\n")
                kill_proxy(OS, alias)
                output = ssh.execute('bash -lc "python -m pip uninstall taf.ue.proxy.mngr -y"', connection=alias)
                logger.debug(f"Uninstall output: {output}")

                # Check if the package is still listed
                proxy_mngr_check_result = ssh.execute(pip_check_mngr_cmd, connection=alias).strip()
                if 'taf.ue.proxy.mngr' not in proxy_mngr_check_result:
                    logger.console(" Proxy manager uninstalled successfully.")
                    break
                else:
                    logger.warn(f" Proxy manager is still installed. Output: {proxy_mngr_check_result}")

                # If this is the last attempt, raise an error
                if attempt == max_retries:
                    BuiltIn.fail("Failed to uninstall proxy manager after maximum retries.")
    except Exception as e:
        BuiltIn.fail(f"Error uninstalling proxy manager: {e}")


def install_taf_lib_from_given_path(package_name, package_path, alias):
    """
    Installs the taf library from a given path.

    Args:
        package_name (str): The name of the package to install.
        package_name (str): The path of the package to install.
        alias (str): PC connection alias.

    Returns:
        None
    """
    try:
        install_cmd = f"bash -lc 'cd {package_path} && python -m pip install {package_name}'"
        logger.debug(f"Install command: {install_cmd}")
        install_output = ssh.execute(install_cmd, connection=alias)
        logger.debug(f"Install output: {install_output}")
        if 'Successfully installed' in install_output:
            logger.console(" Taf library is installed successfully.")
        else:
            BuiltIn.fail("Failed to install taf library, output is {}".format(install_output))
    except Exception as e:
        BuiltIn.fail(f"Error installing taf library: {e}")


def start_all_ue_proxies(cpc_addr, ue, ue_types_list):
    """
    Starts UE proxies for a list of UE types.

    This function checks for downloaded UE proxy releases for each UE type in the provided list.
    If no release is found, it downloads the latest release. It then stops any running UE proxy
    and attempts to start the latest release. If the latest release fails, it tries to start
    the last known working release.

    Args:
        cpc_addr (str): The address of the CPC (Control PC).
        ue (object): The UE object containing proxy manager port and other details.
        ue_types_list (list): A list of UE types for which proxies need to be started.

    Returns:
        dict: A dictionary where keys are UE types and values are lists containing a boolean
              indicating success or failure and a string with the release version or error message.
    """
    result_dict = {}
    try:
        for ue_type_from_list in ue_types_list:
            ue_type = ue_type_dict.get(ue_type_from_list)
            logger.console(f"\n-------> Start UE proxy for ue type: {ue_type}")
            if ue_type is None:
                logger.warn(f"\n Unsupported ue type: {ue_type_from_list}")
                logger.console(
                    "\n-------> Stop UE proxy test for {}! Please check the ue type in ue_types_list, "
                    "it should be one of the following: {}".format(
                        ue_type_from_list, ', '.join(ue_type_dict.keys())
                    )
                )
                result_dict[ue_type_from_list] = [False, "Unsupported ue type: {}".format(ue_type_from_list)]
                break
            last_ok_ueproxy = ""
            downloaded_releases_full_list = get_downloaded_ueproxy_release(cpc_addr, ue.proxy_mngr_port, ue_type)
            downloaded_releases = [release for release in downloaded_releases_full_list if ue_type in release]
            if len(downloaded_releases) > 0:
                sorted_downloaded_ueproxy_in_PC = sort_downloaded_versions_from_high_to_low(
                    downloaded_releases)
                logger.console(
                    "\n Downloaded ue proxy releases in PC for ue type {}: {}".format(
                        ue_type, ', '.join(downloaded_releases)))
            else:
                logger.console(
                    f"\n No ue proxy release for {ue_type} is avaialable in PC, start to download latest version...")
                download_latest_ueproxy_release(cpc_addr, ue.proxy_mngr_port, ue_type)
                downloaded_releases_full_list = get_downloaded_ueproxy_release(cpc_addr, ue.proxy_mngr_port, ue_type)
                sorted_downloaded_ueproxy_in_PC = [
                    release for release in downloaded_releases_full_list
                    if ue_type in release
                ]
                logger.console(
                    "\n After downloading latest release, ue proxy releases in PC for ue type {}: {}".format(
                        ue_type, ', '.join(sorted_downloaded_ueproxy_in_PC)))
            latest_ueproxy = sorted_downloaded_ueproxy_in_PC[0]
            # Assueme that last release list is from index 1 to -1
            last_ok_ueproxy_list = sort_downloaded_versions_from_high_to_low(
                sorted_downloaded_ueproxy_in_PC)[1:]
            logger.debug("latest ue proxy: {}".format(latest_ueproxy))
            logger.debug("last ok ue proxy list: {}".format(last_ok_ueproxy_list))
            logger.console(
                "\n Stop running ue proxy to start ue proxy with latest release...")
            if stop_ueproxy(cpc_addr, ue.proxy_mngr_port, ue_type):
                sleep(10)  # Wait for a while to ensure the proxy is stopped
                logger.console(
                    "\n Running UE proxy is successfully stopped. \
Now try to start latest ue proxy {}...".format(latest_ueproxy)
                    )
                if start_ueproxy_release(latest_ueproxy, cpc_addr, ue.proxy_mngr_port):
                    logger.console(f"\n-------> Latest ue proxy for ue type {ue_type} is started successfully!")
                    result_dict[ue_type] = [True, latest_ueproxy]
                elif len(last_ok_ueproxy_list) > 0:
                    logger.warn(
                        "\n Latest UE proxy version {} starts failed, \
now switch to last ok ue proxy list {}".format(latest_ueproxy, ', '.join(last_ok_ueproxy_list)))
                    for last_ok_ueproxy in last_ok_ueproxy_list:
                        if start_ueproxy_release(last_ok_ueproxy, cpc_addr, ue.proxy_mngr_port):
                            logger.console(
                                "\n-------> Last ok ue proxy {} is started successfully!".format(last_ok_ueproxy))
                            result_dict[ue_type] = [True, last_ok_ueproxy]
                            break
                        elif last_ok_ueproxy == last_ok_ueproxy_list[-1]:
                            logger.warn("\n Start last ok ue proxy {} failed!".format(last_ok_ueproxy))
                            result_dict[ue_type] = [False, "Start last ok ue proxy {} failed!".format(last_ok_ueproxy)]
                        else:
                            logger.warn(
                                "\n Last ok version {} starts failed, now switch to next ue proxy...".format(
                                    last_ok_ueproxy
                                )
                            )
                else:
                    result_dict[ue_type] = [False, "No last ok ue proxy release can be used!"]
                    logger.warn(
                        "\n No last ok ue proxy release can be used!")
            else:
                result_dict[ue_type] = [False, "Stop running ue proxy failed!"]
                logger.warn(
                        "\n Stop running ue proxy failed, skip futher steps!")
    except Exception as e:
        BuiltIn().fail(f"Start latest ue proxy failed due to {e}")
    finally:
        return result_dict


def convert_to_windows_path(unix_path):
    """
    Converts a Unix-style path to a Windows-style path.

    Args:
        unix_path (str): The Unix-style path to convert.

    Returns:
        str: The converted Windows-style path.
    """
    if unix_path.startswith("/home"):
        windows_path = unix_path.replace("/home", "C:\\cygwin64\\home")
        windows_path = windows_path.replace("/", "\\")
        return windows_path
    else:
        logger.debug("Unsupported path format. Only paths starting with '/home' are supported.")
        return ""


def comment_pip_commands_in_bat_file(bat_file_win_path, fatal=False, alias='cpc'):
    """
    Reads the autorunproxymngr.bat file and comments out lines containing 'pip uninstall' or 'pip install'
    if they are not already commented with 'REM'.

    Args:
        bat_file_win_path (str): The Windows-style path to the batch file.
        fatal (bool): If True, fail the test if the update fails.
        alias (str): The alias for the SSH connection.

    Returns:
        None
    """
    try:
        update_flag = False
        # Read the file content
        read_cmd = f'powershell -Command "Get-Content -Path \'{bat_file_win_path}\'"'
        file_content = ssh.execute(read_cmd, connection=alias).splitlines()

        # Prepare updated content
        updated_content = []
        for line in file_content:
            if (line.strip().startswith("python.exe")):
                logger.debug("python.exe found, comment out this line....\n")
                updated_content.append(f"Rem {line.strip()}")
                update_flag = True
            elif "@REM" in line:
                updated_content.append(line.strip().replace("@REM", "REM"))
            else:
                updated_content.append(line.strip())
        # Escape special characters in the content
        updated_content_str = "\n".join(updated_content).replace("'", "''")  # Escape single quotes for PowerShell

        if not update_flag:
            logger.info("No need to update the file, skip it...")
            return
        # Write the updated content back to the file
        logger.console("\n pip install command is found in the autorunproxymngr.bat file, \
start to update the file with pip commands commented out...\n")
        write_cmd = f'powershell -Command "\'{updated_content_str}\' | Set-Content -Path \'{bat_file_win_path}\'"'
        logger.debug(f"Writing updated content to {bat_file_win_path}... with cmd {write_cmd}")
        output = ssh.execute(write_cmd, connection=alias)
        logger.debug(output)

        logger.console(f"\n Updated {bat_file_win_path} successfully.")
    except Exception as e:
        logger.warn(f"Failed to update {bat_file_win_path} due to {e}")
        if fatal:
            BuiltIn.fail("It is not allowed to continue test with pip install commands uncommented!!!")


def get_releases_folder_path_in_PC(alias):
    cmd = "find $(pwd) -name 'releases' -type d -exec realpath {} + | sort -nr"
    return ssh.execute(cmd, connection=alias).strip()


def check_and_upgrade_proxy_mngr_in_cpc(
        site,
        OS,
        alias,
        user,
        target_proxy_manager_version="",
        proxy_mngr_version=None):
    """
    Checks and upgrades the proxy manager in the CPC (Control PC).

    This function verifies the installed version of the proxy manager in the CPC against the target version.
    If the installed version does not match the target version, it triggers an upgrade process.
    It also ensures that the running proxy manager version matches the target version.

    Args:
        site (str): The site where the CPC is located (e.g., 'WRO').
        OS (str): The operating system of the CPC ('Linux' or 'Windows').
        alias (str): The alias for the SSH connection to the CPC.
        target_proxy_manager_version (str, optional): The target version of the proxy manager to be installed.
            If empty latest version will be installed
        proxy_mngr_version (str, optional): The currently running proxy manager version. Defaults to None.

    Returns:
        None
    """
    lock = False
    taf_lib_name = 'taf.ue.proxy.mngr'
    if site == 'WRO':
        lock = check_lock_in_pc_and_lock_it(alias)
    if not lock:
        logger.console(
            f"\n\t---> {taf_lib_name} version check in PC... <---\n")
        try:
            install_flag = False
            installed = ""
            latest = ""
            pip_cmd = 'python -m pip'
            proxy_addr = get_proxy(site)
            proxy = f"--proxy={proxy_addr}"
            check_cmd = f"bash -lc '{pip_cmd} index versions {taf_lib_name} -i {taf_lib_source} {proxy}'"
            logger.debug(f"Command to check {taf_lib_name} version: {check_cmd}")
            output = ssh.execute(check_cmd, connection=alias)
            logger.debug(f"Output of command {check_cmd}:\n{output}")
            for line in output.splitlines():
                if 'INSTALLED' in line:
                    installed = extract_version(line, 'Installed')
                elif 'LATEST' in line:
                    latest = extract_version(line, 'Latest')
            if len(installed) == 0 or len(latest) == 0:
                installed_cmd = "bash -lc '{} show {} | grep Version'".format(
                    pip_cmd, taf_lib_name)
                output = ssh.execute(installed_cmd, connection=alias)
                if 'not found' in output:
                    logger.console(
                        ' TAF lib {} is not installed in PC'.format(taf_lib_name))
                    install_flag = True
                else:
                    installed = output.strip()
                    logger.console(" Installed {} {}".format(taf_lib_name, output))
                    logger.warn(
                        ' Failed to get TAF lib {} latest version!!!'.format(taf_lib_name))
                    if len(target_proxy_manager_version) == 0:
                        BuiltIn().fail(
                            ' Failed to get TAF lib {} latest version, please fix it!'.format(
                                taf_lib_name))
                        return
            elif installed != latest:
                logger.warn(f' Installed {taf_lib_name} version is {installed} and latest version is {latest}')
            if not install_flag:
                if len(target_proxy_manager_version) == 0:
                    target_proxy_manager_version = latest
                    logger.console(
                        ' Target {} version is not provided, \
using latest version {} as target version!'.format(
                            taf_lib_name, target_proxy_manager_version))
                if is_valid_proxy_manager_version(target_proxy_manager_version):
                    if installed == target_proxy_manager_version:
                        if proxy_mngr_version is None:
                            logger.console(
                                "Cannot get runing proxy manager version, \
skip proxy manager installation steps!".format(taf_lib_name))
                            return
                        elif proxy_mngr_version == target_proxy_manager_version:
                            logger.console(
                                " Installed {} version is the target one: {}, \
skip proxy manager installation steps!".format(taf_lib_name, target_proxy_manager_version))
                            return
                        else:
                            logger.warn(
                                f' Target proxy manager version is installed but running proxy manager version is: \
{proxy_mngr_version} which does not match target version: {target_proxy_manager_version}, \
starts to kill proxy manager!!!')
                            kill_proxy(OS, alias)
                    elif compare_versions(installed, latest) > 0:
                        logger.console(
                            f"\n Skipping installation, \
installed {taf_lib_name} version {installed} is newer than the latest version {latest}.")
                        return
                    else:
                        logger.warn(
                            ' Installed {} version is {} \
and target {} version is {}, reinstallation will be triggered!!!'.format(
                                taf_lib_name, installed, taf_lib_name, target_proxy_manager_version))
                        install_flag = True
                else:
                    BuiltIn().fail(
                        ' Target proxy manager version {} is not valid, \
please check the version format!'.format(
                            target_proxy_manager_version))
                    return
            if install_flag:
                logger.console(
                    ' ---> Start to install target version of {}\n'.format(taf_lib_name))
                uninstall_proxy_mngr(OS, alias)
                install_taf_lib_in_cpc(OS, pip_cmd, taf_lib_name, target_proxy_manager_version, site, alias, user)
            else:
                logger.console(
                    ' {} is installed with the target version!'.format(taf_lib_name))
        except Exception as e:
            BuiltIn().fail(f"{taf_lib_name} update failed due to {e}")
        finally:
            if site == 'WRO' and not lock:
                unlock_pc(alias)
    else:
        logger.console("PC is locked, skip {} upgrade!".format(taf_lib_name))


def is_valid_proxy_manager_version(version):
    """
    Checks if the given proxy manager version matches the format like '1.8.2'.

    Args:
        version (str): The version string to validate.

    Returns:
        bool: True if the version matches the format, False otherwise.
    """
    # Regular expression to match the format 'X.Y.Z' where X, Y, and Z are integers
    pattern = r'^\d+\.\d+\.\d+$'
    return bool(re.match(pattern, version))


def get_pcs_data_from_atlas():
    """
    Fetches PCS (Product Configuration System) data from the Atlas API.

    This function sends a GET request to the Atlas API to retrieve PCS data for the QT team in JSON format.

    Returns:
        dict: The JSON response from the API as a Python dictionary.
              Returns an empty dictionary if the request fails.
    """
    try:
        # Send a GET request with SSL verification disabled (-k equivalent)
        response = requests.get(atlas_url, verify=False)
        response.raise_for_status()  # Raise an exception for HTTP errors
        return response.json()  # Parse and return the JSON response
    except requests.exceptions.RequestException as e:
        print(f"Error fetching PCS data: {e}")
        return {}  # Return an empty dictionary in case of failure


def get_pc_info_by_tl(pcs_data, tl_name):
    """
    Finds and returns the PC info where the given testline (TL) name is present in the nodes list.

    Args:
        pcs_data (list): A list of PC info dictionaries retrieved from the Atlas API.
        tl_name (str): The testline (TL) name to search for.

    Returns:
        dict: The PC info dictionary where the TL name is found.
              Returns None if no matching PC is found.
    """
    for pc_info in pcs_data:
        if any(tl_name in node for node in pc_info.get("nodes", [])):
            return pc_info
    return None


def get_target_proxy_manager_version_from_atlas():
    """
    Fetches the target proxy manager version from the Atlas API.

    This function sends a GET request to the Atlas API to retrieve the target proxy manager version for the QT team.

    Returns:
        str: The target proxy manager version.
             Returns 'N/A' if the request fails or if the version is not found.
    """
    try:
        pcs_data = get_pcs_data_from_atlas()
        if pcs_data:
            pc_info = get_pc_info_by_tl(pcs_data, tl.tl_cloud_topology)
            if pc_info:
                logger.info(f"PC info for TL '{tl.tl_cloud_topology}': {json.dumps(pc_info, indent=2)}")
                return pc_info.get('target_proxy_manager_version', 'N/A')
        return 'N/A'
    except Exception as e:
        logger.warn(f"Failed to fetch target proxy manager version: {e}")
        return 'N/A'


def compare_versions(ver1, ver2):
    """
    Compare two version strings.

    Args:
        ver1 (str): First version string (e.g., '1.8.3').
        ver2 (str): Second version string (e.g., '1.8.4').

    Returns:
        int: 1 if ver1 > ver2, -1 if ver1 < ver2, 0 if equal.
    """
    v1 = version.parse(ver1)
    v2 = version.parse(ver2)
    if v1 > v2:
        return 1
    elif v1 < v2:
        return -1
    else:
        return 0


def stop_ueproxy_by_ue_type(cpc_addr, proxy_mngr_port, ue_type_from_init_file):
    """
    Stops the UE proxy by its type.

    Args:
        cpc_addr (str): The address of the CPC (Control PC).
        ue.proxy_mngr_port (int): The port of the proxy manager.
        ue_type_from_init_file (str): The UE type to stop.

    Returns:
        bool: True if the proxy was stopped successfully, False otherwise.
    """
    ue_type = ue_type_dict.get(ue_type_from_init_file)
    logger.console(f" Stop {ue_type} UE proxy for ue type: {ue_type_from_init_file}")
    return stop_ueproxy(cpc_addr, proxy_mngr_port, ue_type)


def save_ue_info(alias, ue_index, ue_info_file):
    """
    Saves UE information as an element of a list to a JSON file.
    If the serial or IMSI of the current UE info already exists in the file,
    it will not be saved again.

    Args:
        ue_info_file (str): The filename to save UE info to.
    """
    try:
        ue_info = taf_ue.get_ue_info(alias)
        logger.debug(f"UE info to be saved: {ue_info}")
        ue_info_file_path = os.path.join(os.getcwd(), ue_info_file)
        ue_info_list = []

        # Load existing UE info list if file exists
        if os.path.exists(ue_info_file_path):
            with open(ue_info_file_path, 'r') as json_file:
                ue_info_list = json.load(json_file)

        # # Check if 'serial' or 'imei' are missing in ue_info. If so, fill them from init
        for get_ue_id, init_id in (('serial', 'serial_number'), ('imei', 'imei')):
            ue_id = getattr(tl.ues[ue_index], init_id, None)
            if ue_id is not None and ue_info.get(get_ue_id) is None:
                ue_info[get_ue_id] = ue_id
                break

        # Check for duplicate serial or IMEI
        serial = ue_info.get('serial')
        imei = ue_info.get('imei')
        exists = any(
            (item.get('serial') == serial or item.get('imei') == imei)
            for item in ue_info_list
        )

        if not exists:
            ue_info_list.append(ue_info)
            with open(ue_info_file_path, 'w') as json_file:
                json.dump(ue_info_list, json_file, indent=4)
            logger.info(f"UE information saved to {ue_info_file_path}")
        else:
            logger.info(
                f"UE info with serial '{serial}' or IMEI '{imei}' already exists , not saving again."
            )
    except Exception as e:
        logger.error(f"Failed to save UE info: {e}")


if __name__ == '__main__':
    ssh.connect_to(hostname='10.56.108.50', username='ute', password='UTE.debian12', alias='cpc')
    # ssh.connect_to(hostname='10.69.69.146', username='ute', password='A8CuY#6Vc^a0m4MmiT_2', alias='cpc')
    # check_and_upgrade_taf_lib_in_cpc('HGZ', 'Windows', 'taf.ue.proxy.mngr', 'cpc')
    # is_proxy_mngr, is_proxy_started = is_proxy_mngr_or_ue_proxy_running('Linux', 'cpc')
    # print(is_AutoRunProxyMngr_running('cpc'))
    # proxy_check_and_recovery('Windows', 'cpc')
