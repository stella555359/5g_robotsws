import time
import os
import re
import subprocess
from taf.transport.ssh import ssh, ConnectFailedError
from robot.api import logger
from taf.sbts.oam.coam.admin import admin
from robot.libraries.BuiltIn import BuiltIn

ssh = ssh()
coam_admin = admin()

# TESTLINE CONFIG (from testline_configuration init file)
tl = BuiltIn().get_variable_value("${tl}")


def get_board_name(board, connection, hw_config='', index=0):
    board_nr = 0 if board == 'master' else 2
    module = 'systemModules' if board == 'master' else 'basebandModules'
    try:
        output = ssh.execute(
            'ddal -s ddal_sysinfo_module_get_unit_id {} | grep value'.format(board_nr),
            connection=connection)
        board_name = output.split("\'")[1]
    except Exception:
        try:
            api = coam_admin.connect_to(bts_host='192.168.255.129')
            bts_data = api.get_bts_info()
            board_name = bts_data[module][index]['productName'].split()[0]
        except Exception:
            board_regex = r'\b[A|F]S\w*' if board == 'master' else r'\b[A|F]B\w*'
            match = re.search(board_regex, hw_config)
            if match:
                board_name = match.group(0)
            else:
                board_name = ''
    return board_name


def trim_swconfig_path(path):
    return '/'.join(path.split('/')[-5:])


def check_container_status_on_smod_master(
        container, container_location, alias):
    py_check = ssh.execute("python --version", alias)
    py_ver = "python3" if "command not found" in py_check else "python"
    outcome = ssh.execute(
        "export PYTHONPATH=/opt/hwmt/python && "
        "{} /opt/hwmt/python/hwapi/SupervisorS.py -n 0x{} -o list_cbts -p 15004 | grep {}".
        format(py_ver, container_location, container),
        alias)
    logger.info("{}".format(outcome))
    if "nodeState:3" in outcome and "nodeState:4" not in outcome:
        logger.info("Check container successful")
        return True
    else:
        logger.error("Check container failed")
        return False


def sw_version_parse_coam(sw_d):
    """
    Script takes parameter sw_version from coam.admin in format: '5G19B_FDD_GNB_0008_001840_000358'
    and parses it to: '8.1840.380'
    If it is a knife it looks like: '5G19B_FDD_GNB_0008_001840_000358_0ijup_'
    """
    if 'SBTS' in sw_d:
        build = '_'.join([s for s in sw_d.split('_')[-3:]])
    else:
        try:
            build = '.'.join([str(int(s)) for s in sw_d.split('_')[-3:]])
        except ValueError:
            try:
                build = '.'.join([str(int(s)) for s in sw_d.split('_')[-5:-2]])
            except ValueError:
                build = '.'.join([str(int(s)) for s in sw_d.split('_')[-4:-1]])

    return build


def parse_test_data(filename, time):
    """
    this function is used to extract Bandwidth parameters and calculate average
    author: min.zheng
    """
    log_file = open(filename, "r")
    cnt = 0
    throughput = 0
    for line in log_file:
        cnt += 1
        data = line.replace("\n", "")
        if data != 'MBytes' and data != 'KBytes' and data != 'Bytes':
            throughput += float(data)
    try:
        average_throughput = round(throughput / int(time), 2)
    except ZeroDivisionError:
        average_throughput = 0
    return dict(
        throughput_time=cnt,
        average_throughput=average_throughput,
        average_throughput_unit='Mbits/sec',
        throughput_time_unit='sec')


def install_loadimage_by_yaft(yaft_dir, addr, af_dir):
    logger.info("Image install to {}: \n".format(af_dir))
    yaft_outcome = ssh.execute(
        "cd {} && sshpass -p 'oZPS0POrRieRtu' python3 ./yaft.py --ask_for_password -l /tmp -d /home/ute/YAFT_IMAGE "
        "-i {} -z {} -K".format(yaft_dir, addr, af_dir), 'host')
    if "Flashing done" in yaft_outcome:
        logger.info("Install loadimage successfully: \n")
        return True
    else:
        logger.info(yaft_outcome)
        logger.error("Failed to install Loadimage: \n")
        return False


def get_rf_list(output):
    res = []
    for line in output:
        res.append('RF' + line.split('/')[-1].split('-')[-1])
        logger.info(res)
    return res


def cut_rf_index(output):
    res = []
    for index in range(len(output)):
        res.append('RF' + str(index + 1))
    return res


def get_cloud_sw_version(image_file):
    return os.path.dirname(image_file).split('/')[-1]


def get_cloud_knife_version(image_path):
    """
    Get knife build name from image_path
    :author: min.zheng
    :param image_path:AF_PATH
    :return:knife build name like:0.1051.48
    """
    return image_path.split('/')[-1]


def kill_sshd_session_on_windows(alias):
    """
    Keeps only the 3 latest sshd.exe sessions on a Windows host.
    Kills all older sshd.exe processes except the 3 with the most recent PIDs.

    Args:
        alias (str): SSH connection alias.

    Returns:
        str: Output of remaining sshd processes.
    """
    cygwin_pid_res = ssh.execute(
        'ps -W | grep cygrunsrv | grep -v grep | awk \'{print $1}\'',
        connection=alias
    ).strip()
    cygwin_pid = re.match(r'\d+', cygwin_pid_res)
    if cygwin_pid:
        cygwin_pid = cygwin_pid.group(0)
        logger.info(f"Cygwin PID: {cygwin_pid}")
        sshd_pids = ssh.execute(
            f'ps -W | grep sshd | grep -v grep | grep -v {cygwin_pid} | awk \'{{print $4}}\'',
            connection=alias
        ).strip()
    else:
        sshd_pids = ssh.execute(
            'ps -W | grep sshd | grep -v grep | awk \'{print $4}\'',
            connection=alias
        ).strip()
    logger.info(f"sshd.exe PIDs with cygwin excluded: {sshd_pids}")
    sshd_pids_list = re.findall(r'\d+', sshd_pids)
    logger.info(f"sshd.exe PIDs list: {sshd_pids_list}")
    # Kill all but the last 3 PIDs
    if len(sshd_pids_list) > 3:
        logger.info(f"More than 3 sshd.exe processes found, keeping the latest 3.")
        for pid in sshd_pids_list[:-3]:
            logger.info(f"Killing sshd.exe PID: {pid}")
            ssh.execute(f'taskkill /F /PID {pid}', connection=alias)
            time.sleep(1)
    else:
        logger.info("Less than or equal to 3 sshd.exe processes found, no action taken.")
    return ssh.execute('ps -W | grep sshd | grep -v grep', connection=alias)


def check_and_recover_if_cygwin_disabled(cpc_addr, cpc_username, cpc_password):
    """
    Checks if Cygwin is enabled on the target Windows PC and attempts recovery if it is not.

    This function connects to the specified Control PC (CPC) using SSH credentials and checks
    if Cygwin is available by running 'cygcheck --version'. If Cygwin is not detected,
    it attempts to recover by restarting the Cygwin SSH service (cygsshd).

    Args:
        cpc_addr (str): The address of the Control PC.
        cpc_username (str): The username for SSH connection.
        cpc_password (str): The password for SSH connection.

    Returns:
        None. Logs the status and recovery attempts to the console.
    """
    ssh.connect_to(cpc_addr, cpc_username, cpc_password, alias='cpc')
    res = ssh.execute(command='cygrunsrv -Q cygsshd', connection='cpc')
    logger.info(f"Output of 'cygrunsrv -Q cygsshd': {res}")
    cygwin_enabled = re.search('Running', res)
    if cygwin_enabled:
        logger.console("INFO: cygwin is used")
    else:
        logger.console("WARN: cygwin is not enabled in PC, recovery try ongoing!")
        res = ssh.execute(
            command='net stop sshd && net start cygsshd',
            connection='cpc'
        )
        logger.info(f"Output of 'net stop sshd && net start cygsshd': {res}")
        if re.search('CYGWIN cygsshd service was started successfully', res):
            logger.console("INFO: Cygwin service recovered successfully")
        else:
            BuiltIn.fail(f"Cygwin service recovery failed.  Output: {res}")


def check_system_connection_type(alias):
    output = ssh.execute('pwd', connection=alias)
    logger.info('output: ' + output)
    if 'home' in output:
        system_connection = 'cygwin'
    else:
        system_connection = 'openssh'
    return system_connection


def check_file_size(file):
    """
    Return True if file exist and the size of this file is not 0
    author: zheng min
    para: log file
    """
    if os.path.exists(file) and os.path.getsize(file) > 0:
        return True
    else:
        logger.error("""
        Following check points can be used as a reference:
        1. if file was not exist, please manually check if log can be generated.
        2. if file size is 0, please check whether the file within the timestamp is missing. For example:
           syslog timestamp was used with HuaWei UE:
           sed -n '/01.07 01:32:23/,/01.07 01:33:33/p' /xxx/SYSLOG_* > /xxx/5Grach_traffic_RF1.txt
           if timestamp 01.07 01:32:23 and 01.07 01:33:33 were missing in SYSLOG, then the size of
           5Grach_traffic_RF1.txt will be 0
        """)
        return False


def get_cpc_osd(alias):
    output = ssh.execute(
        'uname',
        connection=alias)
    logger.info('the output of uname is: ' + output)
    if 'Linux' in output:
        system_OS = 'Linux'
    else:
        system_OS = 'Windows'
    return system_OS


def check_device_status(device, grep_cmd, alias='cpc'):
    ssh.send_command(
        f'adb devices|{grep_cmd} {device}', connection=alias)
    time.sleep(2)
    output = ssh.read_output(connection=alias)
    logger.info('the output of adb devices is: ' + output)
    if output is None:
        raise Exception(
            f"UE is not detected!\n' ' does not contain '{device}'")
    elif device in output and output.split()[1].startswith('device'):
        logger.info('UE is detected!' + output)
        logger.console('UE devices detected')
    else:
        raise Exception(
            f'UE is not detected!\n output: {output}')


def reset_usb_permissions(ue_type, device, grep_cmd, alias='cpc'):
    logger.info('Ue still has no permission, Trying to recover by reset USB permissions...')
    usb_serial_res = ssh.execute('lsusb', connection=alias)
    logger.info('the output of lsusb is: ' + usb_serial_res)
    if ue_type.lower() == 'android':
        grep_msg = 'MTP mode'
    else:
        grep_msg = ue_type.title()
    if grep_msg in usb_serial_res:
        output1 = ssh.execute(
            "lsusb|grep '{}'|awk '{{printf $6}}'|awk -F ':' '{{printf $1}}'" .format(
                grep_msg), connection='cpc').strip()
        logger.info('the output of output1 is: ' + output1)
        ssh.send_command(
            f"""sudo sh -c "echo 'SUBSYSTEM==\\"usb\\",SYSFS{{idVendor}}==\\"{output1}\\",\
MODE=\\"0666\\"'> /etc/udev/rules.d/51-android.rules" """,
            connection=alias)
        logger.info(
            'the content of /etc/udev/rules.d/51-android.rules is: ' +
            ssh.execute(
                'cat /etc/udev/rules.d/51-android.rules',
                connection='cpc').strip())
        pwd_res = ssh.execute('cd ~ && pwd', connection=alias).strip()
        ssh.send_command(
            f"sudo sh -c 'echo 0x{output1} > {pwd_res}/.android/adb_usb.ini'",
            connection=alias)
        logger.info(
            'the content of adb_usb.ini is: ' +
            ssh.execute(
                'cat {}/.android/adb_usb.ini'. format(pwd_res),
                connection=alias))
        finally_check_ue_status = ssh.execute(
            'sudo chmod a+rx /etc/udev/rules.d/51-android.rules && \
    sudo service udev restart && sudo adb kill-server && sudo adb start-server && sudo adb devices ',
            connection=alias)
        check_device_status(device, grep_cmd, alias=alias)
    else:
        logger.info('UE is not detected in by lsusb command!')
        raise Exception(
            f'UE is not detected!\n',
            ssh.execute(
                f'adb devices|{grep_cmd} {device}',
                connection=alias))


# Main function
def check_and_recover_ue_devices(host, username, password, device, ue_type):
    try:
        ssh.connect_to(
            hostname=host,
            username=username,
            password=password,
            alias='cpc')
    except ConnectFailedError as e:
        raise Exception(
            f"CPC connection failed: {host}/{username}/{password}")
    output = ssh.execute('uname', connection='cpc').strip()
    logger.info('the output of uname is: ' + output)
    if 'windows' in output or 'not recognized' in output:
        # To check the system kernel info, if Linux or Cygwin, use 'grep'
        # command. If Windows, use 'findstr' command
        grep_cmd = 'findstr'
    else:
        grep_cmd = 'grep'
    logger.info(
        f"Filter the ue status with command: adb devices|{grep_cmd} {device}")
    try:
        check_device_status(device, grep_cmd, alias='cpc')
    except Exception as e:
        logger.info('UE detection issue: {}'.format(e))
        logger.info('Device is not connected. Trying to recover by killing/starting adb service...')
        logger.info('reloading udev rules and killing adb service')
        ssh.send_command('sudo udevadm control --reload-rules && sudo service udev restart && \
sudo udevadm trigger && adb kill-server', connection='cpc')
        time.sleep(10)
        logger.info('starting adb service and sleeping 10s')
        ssh.send_command('adb start-server', connection='cpc')
        time.sleep(10)
        logger.info('send command adb devices|grep {} {} and sleep 2s'.format(grep_cmd, device))
        ssh.send_command('adb devices | {} {}'.format(grep_cmd, device), connection='cpc')
        time.sleep(2)
        output1 = ssh.read_output(connection='cpc')
        logger.info(f'the output of adb devices after recovery is: {output1}')
        if (get_cpc_osd('cpc') == 'Linux') and 'no permission' in output1:
            reset_usb_permissions(ue_type, device, grep_cmd, alias='cpc')
        check_device_status(device, grep_cmd, alias='cpc')
    ssh.disconnect(connection='cpc')


def check_battery_level_below_threshold(host, username, password, device, threshold):
    ssh.connect_to(
        hostname=host,
        username=username,
        password=password,
        alias='battery_cpc')

    adb_command = f"adb -s {device} shell dumpsys battery"
    output = ssh.execute(adb_command, connection='battery_cpc')
    ssh.disconnect(connection='battery_cpc')

    match = re.search(r'level:\s*(\d+)', output)
    if match:
        battery_level = int(match.group(1))
        logger.info(f"Phone battery level: {battery_level}%.")
        if battery_level < int(threshold):
            logger.warn(f"Phone is running out of battery: {battery_level}%.")
            raise Exception(f"Battery level is below {battery_level}%.")
    else:
        logger.warn(f"Failed to parse battery level from output:{output}")


def get_appserver_info():
    appserver_info_list = []
    appservers_info = set()
    for ue in tl.ues:
        try:
            address = None
            user = None
            password = None
            ue_class_name = ue.__class__.__name__

            if ue_class_name.startswith('TafUe'):
                if ue.data_transfer and ue.data_transfer[0]:
                    appserver = ue.data_transfer[0].app_server
                    address = appserver.address
                    user = appserver.user
                    password = appserver.password
            elif ue_class_name == 'Android':
                if ue.iperf_details:
                    appserver = ue.iperf_details.ssh_connection_details
                    address = appserver.addr
                    user = appserver.username
                    password = appserver.password

            if not address:
                logger.info(
                    f"Cannot find app server IP in the definition of {ue_class_name},\
                will check if app server is defined in tl")
                if tl.appserver is None:
                    logger.console("No appserver defined under tl. Appserver check will be skipped")
                    continue
                else:
                    appserver = tl.appserver.iperf_details.ssh_connection_details
                    address = appserver.addr
                    user = appserver.username
                    password = appserver.password
            else:
                logger.info(f"App server IP is: {address} for {ue_class_name}")

            if address and user and password:
                appserver_info = {
                    "address": address,
                    "user": user,
                    "password": password
                }
                appserver_info_tuple = (address, user, password)
                if appserver_info_tuple not in appservers_info:
                    appservers_info.add(appserver_info_tuple)
                    appserver_info_list.append(appserver_info)
        except Exception as e:
            logger.error(f"An unexpected error occurred: {e}")

    return appserver_info_list


def is_data_collector_running():
    """
    Checks if the data_collector Docker container is running.

    Returns:
        bool: True if running, False otherwise.
    """
    try:
        output = subprocess.check_output("docker ps --format '{{.Names}}'", shell=True).decode()
        for line in output.splitlines():
            if line.strip() == "data_collector":
                logger.info("data_collector container is running.")
                return True
        logger.info("data_collector container is NOT running.")
        return False
    except Exception as e:
        logger.error(f"Failed to check data_collector status: {e}")
        return False


if __name__ == '__main__':
    # ssh.connect_to("10.69.195.9", "ute", "UTE.debian12", alias="cpc")
    # check_device_status("cfe111d4", 'grep', alias='cpc')
    # reset_usb_permissions("android", "R5CNC0GF74Y", "grep", alias="cpc")
    check_and_recover_ue_devices('10.69.223.16', 'ute', 'UTE.debian12', 'WSY0220522004152', 'huawei')
