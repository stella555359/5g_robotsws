import time
import os
import re
import requests
import subprocess
from taf.transport.ssh import ssh, ConnectFailedError
from robot.api import logger
from taf.sbts.oam.coam.admin import admin
from robot.libraries.BuiltIn import BuiltIn

ssh = ssh()
coam_admin = admin()

# TESTLINE CONFIG (from testline_configuration init file)
tl = BuiltIn().get_variable_value("${tl}")


def get_board_name(board, connection, index=0):
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
            board_name = 'ASIK' if board == 'master' else 'ABIL'
            logger.error(
                'Reading {} board name failed. Set default value: {}'.format(
                    board, board_name))
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
        print(yaft_outcome)
        logger.error("Failed to install Loadimage: \n")
        return False


def get_rf_list(output):
    res = []
    for line in output:
        res.append('RF' + line.split('/')[-1].split('-')[-1])
        print(res)
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
    process_info = ssh.execute(f'tasklist | more | findstr sshd', connection=alias)
    process_info = re.findall(r'^sshd\.exe.*', process_info, re.MULTILINE)
    print('List sshd process:\n', process_info, type(process_info))
    process_ids = [int(re.search(r'\d+', p).group()) for p in process_info if p.strip()]
    print('List of process ids: ', process_ids)
    if len(process_ids) > 2:
        process_ids_to_kill = process_ids[1:-1]
        print('process list that should be delete: ', process_ids_to_kill)
        for pid in process_ids_to_kill:
            ssh.execute(f'taskkill /F /PID {pid}', connection=alias)
            time.sleep(1)
    return (ssh.execute(f'tasklist | more | findstr sshd', connection=alias))


def check_system_connection_type(alias):
    output = ssh.execute('pwd', connection=alias)
    print('output: ', output)
    if 'home' in output:
        system_connection = 'cygwin'
    else:
        system_connection = 'openssh'
    return system_connection


def check_askey_info(status_info):
    print('INFO: ', status_info)
    if '5G_NSA' in status_info:
        tech_status = '5G_NSA'
    elif '5G_SA' in status_info:
        tech_status = '5G_SA'
    elif 'LTE' in status_info:
        tech_status = 'LTE'
    else:
        tech_status = 'No Service'
    return tech_status


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
        'bash -lc \'python -c "import platform; print(platform.system())"\'',
        connection=alias)
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
    print('the output of adb devices is: ', output)
    if output is None:
        raise Exception(
            f"UE is not detected!\n' ' does not contain '{device}'")
    elif 'device' not in output:
        raise Exception(
            f'UE is not detected!\n output: {output}')
    else:
        print('UE is detected!', output)
        logger.console('UE devices detected')


def reset_usb_permissions(ue_type, device, grep_cmd, alias='cpc'):
    print('Ue still has no permission, Trying to recover by reset USB permissions...')
    usb_serial_res = ssh.execute('lsusb', connection=alias)
    print('the output of lsusb is: ', usb_serial_res)
    if ue_type.title() in usb_serial_res:
        output1 = ssh.execute(
            "lsusb|grep {}|awk '{{printf $6}}'|awk -F ':' '{{printf $1}}'" .format(
                ue_type.title()), connection='cpc').strip()
        print('the output of output1 is: ', output1)
        ssh.send_command(
            f"""sudo sh -c "echo 'SUBSYSTEM==\\"usb\\",SYSFS{{idVendor}}==\\"{output1}\\",\
MODE=\\"0666\\"'> /etc/udev/rules.d/51-android.rules" """,
            connection=alias)
        print(
            'the content of /etc/udev/rules.d/51-android.rules is: ',
            ssh.execute(
                'cat /etc/udev/rules.d/51-android.rules',
                connection='cpc').strip())
        pwd_res = ssh.execute('cd ~ && pwd', connection=alias).strip()
        ssh.send_command(
            f"sudo sh -c 'echo 0x{output1} > {pwd_res}/.android/adb_usb.ini'",
            connection=alias)
        print(
            'the content of adb_usb.ini is: ',
            ssh.execute(
                'cat {}/.android/adb_usb.ini'. format(pwd_res),
                connection=alias))
        finally_check_ue_status = ssh.execute(
            'sudo chmod a+rx /etc/udev/rules.d/51-android.rules && \
    sudo service udev restart && sudo adb kill-server && sudo adb start-server && sudo adb devices ',
            connection=alias)
        check_device_status(device, grep_cmd, alias=alias)
    else:
        print('UE is not detected in by lsusb command!')
        raise Exception(
            f'UE is not detected!\n',
            ssh.execute(
                f'adb devices|{grep_cmd} {device}',
                connection=alias))


def get_latest_promoted_builds_for_branch(branch, num_builds):
    access_key = "59Tc7CmEXbofWQ1A1h6bBIQPhXIitNOWT65bxiyI"
    url = ("https://wft.int.net.nokia.com:8091/ALL/api/v1/promotion.json?access_key=" + access_key +
           "&view[items]=" + str(num_builds) +
           "&view[sorting_field]=created_at&view[sorting_direction]=DESC&view[group_by]"
           "=promotion_tag.tag&view[columns[][id]]=branch.title&view[columns[][id]]=build.baseline&view[columns[][id]]"
           "=created_at&view[view_filters_attributes[33999848078554]][column]"
           "=active&view[view_filters_attributes[33999848078554]][operation]"
           "=eq&view[view_filters_attributes[33999848078554]]"
           "[value][]=" + str(num_builds) + "&view[view_filters_attributes[880374364999341]]"
           "[column]=promotion_tag.tag&view[view_filters_attributes[880374364999341]][operation]"
           "=eq&view[view_filters_attributes[880374364999341]][value][]=REGRESSION&view[view_filters_attributes"
           "[799598192158904]][column]=branch.title&view[view_filters_attributes[799598192158904]][operation]"
           "=eq&view[view_filters_attributes[799598192158904]][value][]=" + branch + "&")
    logger.debug(url)
    request = requests.get(url, stream=True, timeout=(10, 10))
    builds = re.findall(r'"build\.baseline":"(.*?\d+)"', request.text)

    if not builds:
        raise BaseException("This release has no candidates yet! WFT request output: " + request.text)

    return builds[:int(num_builds)]


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
    print('the output of uname is: ', output)
    if 'windows' in output or 'not recognized' in output:
        # To check the system kernel info, if Linux or Cygwin, use 'grep'
        # command. If Windows, use 'findstr' command
        grep_cmd = 'findstr'
    else:
        grep_cmd = 'grep'
    print(
        f"Filter the ue status with command: adb devices|{grep_cmd} {device}")
    try:
        check_device_status(device, grep_cmd, alias='cpc')
    except Exception as e:
        print('UE detection issue: ', e)
        print('Device is not connected. Trying to recover by killing/starting device...')
        print('send command adb kill-sever and sleep 10s')
        ssh.send_command('adb kill-server', connection='cpc')
        time.sleep(10)
        print('send command adb start-sever and sleep 10s')
        ssh.send_command('adb start-server', connection='cpc')
        time.sleep(10)
        print('send command adb devices|grep {} {} and sleep 2s'.format(grep_cmd, device))
        ssh.send_command('adb devices | {} {}'.format(grep_cmd, device), connection='cpc')
        time.sleep(2)
        output1 = ssh.read_output(connection='cpc')
        print('the output of adb devices after recovery is: ', output1)
        if get_cpc_osd('cpc') == 'Linux' and 'no permission' in output1:
            reset_usb_permissions(ue_type, device, grep_cmd, alias='cpc')
        check_device_status(device, grep_cmd, alias='cpc')
    ssh.disconnect(connection='cpc')


if __name__ == '__main__':
    ssh.connect_to("10.42.172.187", "wro5gqt", "5Gqtmoth", "cpc")
    check_device_status("cfe111d4", 'grep', alias='cpc')
