import re
import subprocess
import time
import SSHLibrary
from tabulate import tabulate
from robot.api import logger
from typing import Dict, List, Optional, Union


ru_rfsw_dict = {
    'AZQP': '5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ=',
    'AZHL': '5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ=',
    'AEHC': "bdS%ztWG3v7%SjreCVA79wTPb",
    'AVQL': "f6gh0K2nXq0O8XqVFkUuMtJnzuKm0U3box0QcYgugn0=",
    'AVQC': "f6gh0K2nXq0O8XqVFkUuMtJnzuKm0U3box0QcYgugn0=",
    'AWHQN': "KRG3dFggxxHw+s0z64U0AR22VyjfnXdHrAVdSv5jpc4=",
    'AKQJ': "KRG3dFggxxHw+s0z64U0AR22VyjfnXdHrAVdSv5jpc4="
}


ru_serviceuser_dict = {
    'AZQP': 'wcdjLlTpqEY3cAmOe11u6aELwGI3rDvpGJQvCkcyHZc=',
    'AZHL': 'wcdjLlTpqEY3cAmOe11u6aELwGI3rDvpGJQvCkcyHZc=',
    'AEHC': "bdS%ztWG3v7%SjreCVA79wTPb",
    'AVQL': "kQ2QZWY22987AsO4QaK/Yzj/gh3yksrLESosPRHF6Og=",
    'AVQC': "kQ2QZWY22987AsO4QaK/Yzj/gh3yksrLESosPRHF6Og=",
    'AWHQN': "Nokia@123",
    'AKQJ': "oBrd1RgbOasUtYAeVfxrW9yGHb6ONl0w+MJUoKrBMGE="
}


def connect_and_execute_command_on_ru(rmod_id='AVQL', command='bfcali -stat',
                                      user="serviceuser",
                                      ip='192.168.255.1'):
    assert command, "[ERROR] command is missing."
    FRIps_info_list = get_FRIps_from(ip)
    specific_rmod = [rf for rf in FRIps_info_list if rmod_id in rf]
    assert specific_rmod, f"[ERROR] {rmod_id} is NOT found in {FRIps_info_list}."
    assert len(specific_rmod) <= 1, f"[ERROR] found more {rmod_id} RU from FRIps.txt."
    p_name = specific_rmod[0].split(';')[-1]
    p_sn = specific_rmod[0].split(';')[-2]
    rmod_ip = specific_rmod[0].split(';')[-3]

    c = SSHLibrary.SSHLibrary()
    password_dict = ru_serviceuser_dict if user == 'serviceuser' else ru_rfsw_dict
    password = password_dict.get(p_name)
    logger.console('-' * (len(password) + 12))
    logger.console(
        'RMOD TYPE : {}\nRMOD SN   : {}\nRMOD IP   : {}\nPASSWORD  : {}'.format(
            p_name, p_sn, rmod_ip, password
        )
    )
    logger.console('-' * (len(password) + 12))
    try:
        c.open_connection(ip)
        output = c.login('toor4nsn', 'oZPS0POrRieRtu')
        logger.console('[INFO] Login successfully\n' + output)
        if "password" in output:
            c.write('oZPS0POrRieRtu')
            logger.console('[INFO] Enter password successfully')
        else:
            c.write("rm /user/toor4nsn/.ssh/known_hosts")
            c.write("rm /root/.ssh/known_hosts")

        c.write('lxc-attach -n 0x1018')
        output = c.read(delay=2)
        logger.console('[INFO] lxc attach successfully\n' + output)

        c.write('ssh {}@{}'.format(user, rmod_ip))
        time.sleep(5)
        output = c.read_until_regexp('fingerprint')
        c.write('yes')
        time.sleep(5)
        output = c.read_until_regexp('password:')
        if "password:" in output:
            logger.console(f'[INFO][1]Login rmod[{rmod_id}][{user}@{rmod_ip}] ... ...\n\n{output}')
            c.write(password)
            time.sleep(5)
            tmp_key = f'{user}@'
        else:
            logger.console('[INFO][2]Login rmod[{}][root@{}] ... ...\n\n{}'.format(rmod_id, rmod_ip, output))
            c.write("ssh root@{}".format(rmod_ip))
            tmp_key = 'root@'
        output = c.read_until_regexp(tmp_key)
        logger.console('[INFO][1]Login rmod[{}][{}] successfully.\n\n{}'.format(rmod_id, rmod_ip, output))

        if isinstance(command, list) and len(command) > 0:
            command_list = command
            for command in command_list:
                if 'SWmanShellCommand -s' in command:
                    try:
                        if 'FRU6' in command:
                            load_delay_time = 800
                        else:
                            load_delay_time = 160
                        c.write(command)
                        exec_output = c.read(delay=load_delay_time)
                        match = re.findall(r'status:\s+(\w+)', exec_output)
                        if match:
                            status = match[0]
                            if status == 'OK':
                                logger.console(f'[INFO] SWmanShellCommand upgrade successfully.\n{exec_output}')
                            else:
                                raise Exception(f'[INFO] SWmanShellCommand upgrade failed.\n{exec_output}')
                    except Exception as e:
                        logger.console("[INFO] Execute ['{}'] on {} ... SWmanShellCommand upgrade fail as {}"
                                       .format(command, rmod_id, e))
                        exec_output = None
                        return exec_output

                if 'SWmanShellCommand -a' in command:
                    try:
                        c.write(command)
                        # exec_output = c.read_until_regexp(tmp_key)
                        exec_output = c.read(delay=60)
                        match = re.findall(r'status:\s+(\w+)', exec_output)
                        if match:
                            status = match[0]
                            if status == 'OK':
                                logger.console(f'[INFO] SWmanShellCommand active successfully.\n{exec_output}')
                            else:
                                raise Exception(f'[INFO] SWmanShellCommand active failed.\n{exec_output}')
                    except Exception as e:
                        logger.console("[INFO] Execute ['{}'] on {} ... SWmanShellCommand active fail as {}"
                                       .format(command, rmod_id, e))
                        exec_output = None
                        return exec_output

        if 'SWmanShellCommand -i' in command:
            try:
                c.write(command)
                exec_output = c.read(delay=30)
                logger.console(f'[INFO] SWmanShellCommand inquire successfully.\n{exec_output}')
                return exec_output
            except Exception as e:
                logger.console("[INFO] Execute ['{}'] on {} ... SWmanShellCommand inquire SW fail as {}"
                               .format(command, rmod_id, e))
                exec_output = None
                return exec_output

        if 'reboot' in command:
            try:
                c.write(command)
                exec_output = c.read_until_regexp(tmp_key)
            except Exception:
                logger.console("[INFO] Execute ['{}'] on {} ... Rebooting ... ".format(command, rmod_id))
                exec_output = None
                return exec_output
        else:
            c.write(command)
            time.sleep(20)
            exec_output = c.read_until_regexp(tmp_key)
            logger.console("[INFO] Execute ['{}'] on {} successfully.\n\n{}\n".format(command, rmod_id, exec_output))
            c.write("exit")
            c.write("exit")
            c.write("exit")
    except AssertionError as e:
        logger.console(e)
        return e
    except Exception as e:
        logger.console(e)
        raise e
    finally:
        c.close_connection()
        if exec_output:
            return exec_output
        else:
            return None


def connect_and_scp_file_to_ru(local_files, rmod_id='AVQL', ip='192.168.255.1', user='serviceuser'):
    to_fct = '/ffs/run/logs/rf_build/'
    filenames = None  # Initialize filenames to avoid UnboundLocalError

    fri_ps_info_list = get_FRIps_from(ip)
    specific_rmod = [rf for rf in fri_ps_info_list if rmod_id in rf]

    data1 = [
        ['bts ip', ip],
        ['to FCT', to_fct],
        ['rmod_id', rmod_id],
        ['rmod info', specific_rmod]
    ]
    print(tabulate(data1, tablefmt='psql', headers=['Para.', 'Value']))

    assert local_files, "[ERROR] local_files is missing."
    assert specific_rmod, f"[ERROR] {rmod_id} is NOT found in {fri_ps_info_list}."
    assert len(specific_rmod) <= 1, f"[ERROR] found more {rmod_id} RU from FRIps.txt."
    p_name = specific_rmod[0].split(';')[-1]
    ipaddr = specific_rmod[0].split(';')[-3]

    files_list = [local_files] if isinstance(local_files, str) else local_files

    c = SSHLibrary.SSHLibrary()
    ru_password = ru_serviceuser_dict.get(p_name) if user == 'serviceuser' else ru_rfsw_dict.get(p_name)
    data2 = [
        ['rmod name', p_name],
        ['rmod ip', ipaddr],
        ['rmod password', ru_password]
    ]
    print(tabulate(data2, tablefmt='psql', headers=[]))

    subprocess.Popen(
        f"sshpass -p oZPS0POrRieRtu ssh toor4nsn@{ip} 'rm -rf {to_fct}; mkdir {to_fct}'",
        stdout=subprocess.PIPE, shell=True
    )

    try:
        c.open_connection(ip)
        output = c.login('toor4nsn', 'oZPS0POrRieRtu')
        logger.console('[INFO] Login successfully\n' + output)
        if "password" in output:
            c.write('oZPS0POrRieRtu')
            logger.console('[INFO] Enter password successfully')
        else:
            c.write("rm /user/toor4nsn/.ssh/known_hosts")
            c.write("rm /root/.ssh/known_hosts")

        # Upload files to FCT: /ffs/run/logs/rf_build/
        for file in files_list:
            c.put_file(file, to_fct)
        files = c.list_files_in_directory(to_fct)
        assert files, f'[ERROR] Failed to upload {local_files} to [{to_fct}]:\n{files}'
        logger.console(f'[INFO] Uploaded file to FCT successfully:\n{files}')

        c.write('lxc-attach -n 0x1018')
        output = c.read(delay=2)
        logger.console('[INFO] lxc attach successfully\n' + output)

        c.write(f'scp {to_fct}* {user}@{ipaddr}:/tmp/')
        output = c.read_until_regexp('fingerprint')
        c.write('yes')
        time.sleep(5)
        output = c.read_until_regexp('password:')
        c.write(ru_password)
        time.sleep(20)
        if p_name in ['AWHQN']:
            scp_delay = 300
        elif p_name in ['AVQL', 'AVQC']:
            scp_delay = 30
        else:
            scp_delay = 60
        scp_output = c.read(delay=scp_delay)
        output_result = scp_output
        logger.console(f'[INFO] scp [{local_files}] process.\n{scp_output}')
        match_list = []
        for idx, line in enumerate(output_result.strip().splitlines(), 1):
            match = re.findall(r'(.*[sh|tar])\s+100%', line)
            if match:
                match_list.append(match[0])
        match_list = list(set(match_list))
        for file in files_list:
            filename = file.split("/")[-1]
            if filename not in match_list:
                raise Exception(f"Upload process not completed for {filename}.")
            else:
                logger.console(f'[INFO] scp [{file}] successfully.\n')

        c.write("exit")
        c.write("exit")

        filenames = []
        for line in scp_output.strip('root@FHNET00').splitlines():
            match = re.match(r"(\S+)", line)
            if match:
                filenames.append(match.group(1))

    except AssertionError as e:
        logger.console(e)
        return e
    except UnboundLocalError as e:
        logger.console(e)
        scp = None
        return scp
    except Exception as e:
        logger.console(e)
        raise e
    finally:
        c.close_connection()
        if filenames:
            return set(filenames)
        else:
            return None


def get_FRIps_from(ip):
    cmd = "sshpass -p oZPS0POrRieRtu ssh toor4nsn@{} 'cat /rom/config/FRIps.txt'".format(ip)
    output = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True)
    out = output.stdout.read().decode(encoding='utf-8', errors='ignore')
    return [item for item in out.strip().split('\n') if 'MRBTS-1/' in item]


def check_bfcali_state(stat_info):
    assert stat_info, '[ERROR] the bfcali stat info is EMPTY.'
    tmp_antenna_list = stat_info.strip().split('Status: IDLE')
    keys_list = bfcali_stat_keys()

    def re_findall(name, stat):
        return re.findall('{}: (.*)'.format(name), stat)

    def checktor(antenna_cali_info, tmp_dict=dict()):
        for key in keys_list:
            tmp_dict[key] = re_findall(key, antenna_cali_info)
        assert tmp_dict, '[ERROR] Can NOT get the values of {}.'.format(keys_list)
        calibration = True if tmp_dict['Calibration attempts'] == tmp_dict['Successful calibrations'] else False
        failed_cali = True if int(tmp_dict['Failed calibrations'][0]) == 0 else False
        antenna_elements = tmp_dict['Successfully calibrated antenna elements'][0].split('/')
        elements_cali = True if int(antenna_elements[0]) == int(antenna_elements[1]) else False
        assert calibration, "[ERROR] Calibration is FAILURE:{}".format(antenna_cali_info)
        assert failed_cali, "[ERROR] Failed calibrations is NOT 0:{}".format(antenna_cali_info)
        assert elements_cali, "[ERROR] Antenna elements calibration is FAILURE:{}".format(antenna_cali_info)

    checktor(tmp_antenna_list[0])
    checktor(tmp_antenna_list[1])


def bfcali_stat_keys():
    return ['Carrier name',
            'Carrier frequency',
            'Carrier bandwidth',
            'Calibration attempts',
            'Successful calibrations',
            'Failed calibrations',
            'Successfully calibrated antenna elements',
            'Latest calibration']


def _ssh_jump_and_auth(client: SSHLibrary.SSHLibrary,
                       user: str,
                       host: str,
                       password: str,
                       final_prompt_regex: str = r'asp-',
                       timeout: int = 10):
    """
    处理二次 ssh 跳转的交互:
    可能出现顺序:
      1) fingerprint -> yes -> password:
      2) 直接 password:
      3) 已缓存 host key -> 直接进入 prompt
    """
    start = time.time()
    buffer = ''
    # 使用 StrictHostKeyChecking=no 可直接跳过 fingerprint (保留兼容处理)
    client.write(f"ssh {user}@{host}")
    time.sleep(1)

    while True:
        chunk = client.read(delay=1)
        if chunk:
            buffer += chunk
        low = buffer.lower()

        # 处理 fingerprint 提示
        if ('fingerprint' in low) or ('are you sure you want to continue connecting' in low) or ('yes/no' in low):
            client.write('yes')
            buffer = ''
            continue

        # 处理密码提示
        if 'password:' in low:
            client.write(password)
            buffer = ''
            continue

        # 成功进入目标机 (提示符或用户前缀)
        if re.search(final_prompt_regex, buffer):
            return True, buffer

        if time.time() - start > timeout:
            return False, buffer


def connect_and_execute_command_on_bbmod(bbmod, core, command, ip='192.168.255.1',
                                         user="toor4nsn",
                                         password='oZPS0POrRieRtu'):
    """Execute command on BBMOD via SSH.

    Args:
        bbmod: BBMOD identifier
        core: Core identifier
        command: Command or list of commands to execute
        ip: IP address (default: '192.168.255.1')
        user: Username (default: 'toor4nsn')
        password: Password (default: 'oZPS0POrRieRtu')

    Returns:
        Command execution output or None
    """
    assert command, "[ERROR] Command is missing."
    sysbshtopo_dict = get_sysbshtopo_from(ip='192.168.255.1', user='toor4nsn', password='oZPS0POrRieRtu')
    selected_module = [item for item in sysbshtopo_dict.values() if item['module'] == bbmod and item['core'] == core]
    assert selected_module, f'[ERROR] No {bbmod} and {core} in {sysbshtopo_dict}'
    host_name = selected_module[0].get('hostName')

    c = SSHLibrary.SSHLibrary()
    logger.console('-' * (len(password) + 12))
    logger.console(
        'BBMOD       : {}\nCORE        : {}\nHOST NAME   : {}'.format(
            selected_module[0].get("module"), selected_module[0].get("core"), host_name
        )
    )
    logger.console('-' * (len(password) + 12))
    exec_output = None
    try:
        c.open_connection(ip)
        first = c.login('toor4nsn', 'oZPS0POrRieRtu')
        if "password" in first.lower():
            c.write('oZPS0POrRieRtu')
        else:
            c.execute_command("rm -f /user/toor4nsn/.ssh/known_hosts")
            c.execute_command("rm -f /root/.ssh/known_hosts")

        # 跳转 SSH，处理 fingerprint / password / 直接进入三种情况
        ok, auth_buf = _ssh_jump_and_auth(c, user, host_name, password, final_prompt_regex=r'asp-')
        if not ok:
            raise Exception(f"[ERROR] SSH jump auth failed:\n{auth_buf}")

        # 执行命令
        if isinstance(command, list):
            for cmd in command:
                if any(k in cmd for k in ('devmem', 'confmgmtbrowser', 'kill', 'reboot')):
                    c.execute_command(cmd)
                    logger.console(f"[INFO] Execute ['{cmd}'] on {host_name}")
                else:
                    c.write(cmd)
                    time.sleep(2)
                    out = c.read_until_regexp(r'asp-').strip().strip('asp-').strip()
                    logger.console(f"[INFO] Execute [{cmd}] on {host_name} successfully.\n{out}\n")
                    exec_output = out
        else:
            c.write(command)
            time.sleep(2)
            out = c.read_until_regexp(r'asp-').strip().strip('asp-').strip()
            logger.console(f"[INFO] Execute [{command}] on {host_name} successfully.\n{out}\n")
            exec_output = out

        c.write("exit")
        c.write("exit")
    except Exception as e:
        logger.console(e)
        raise
    finally:
        c.close_connection()
        return exec_output


def get_sysbshtopo_from(ip='192.168.255.1', user='toor4nsn', password='oZPS0POrRieRtu'):
    """Get system bash topology information.

    Args:
        ip: IP address (default: '192.168.255.1')
        user: Username (default: 'toor4nsn')
        password: Password (default: 'oZPS0POrRieRtu')

    Returns:
        Dictionary of system bash topology
    """
    cmd = f"sshpass -p {password} ssh {user}@{ip} 'chk sysbsh'"
    output = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True)
    result = output.stdout.read().decode(encoding='utf-8', errors='ignore')
    tmp_list = [item.strip() for item in result.strip().split('\n') if re.search(r'.*(ASI\w|ABI\w)', item)]
    sysbsh_dict = extract_modules_information(tmp_list)
    return sysbsh_dict


def parse_module_line(line: str) -> Optional[Dict[str, str]]:
    """Parse single line of module information.

    Args:
        line: String containing module information

    Returns:
        Parsed module information dictionary or None
    """
    line = line.strip()

    # 检查是否包含目标模块
    if not re.search(r'A[SB]I\w', line):
        return None

    # 提取基本信息
    node_id_match = re.search(r'\[(0x\w+)\]', line)
    module_match = re.search(r'A[SB]I\w+', line)

    if not (node_id_match and module_match):
        return None

    node_id = node_id_match.group(1)
    module = module_match.group(0)

    # 提取核心类型
    parts = line.split()
    core = 'Unknown'
    hostname = 'Unknown'

    # 查找核心类型（在nodeId之后）
    bracket_index = None
    for i, part in enumerate(parts):
        if '0x' in part and '[' in part:
            bracket_index = i
            break

    if bracket_index is not None and bracket_index + 1 < len(parts):
        core = parts[bracket_index + 1]

    # 提取hostname（在括号中）
    hostname_match = re.search(r'\((\w+)\)', line)
    if hostname_match:
        hostname = hostname_match.group(1)
    elif 'ASIM' in module:
        # 对于ASIM，尝试提取最后的用户信息
        user_match = re.search(r'(\d+:\d+)', line)
        if user_match:
            hostname = user_match.group(1)
    if hostname:
        tmp_id = hostname.strip('icom')[-1]
    return {
        'nodeId': node_id,
        'module': module,
        'core': f'{core}_{tmp_id}',
        'hostName': hostname
    }


def extract_modules_information(module_lines: List[str]) -> Dict[str, Dict[str, str]]:
    """Extract module information from lines.

    Args:
        module_lines: List of module information lines

    Returns:
        Dictionary with nodeId as key and module info as value
    """
    result = {}

    for line in module_lines:
        module_info = parse_module_line(line)
        if module_info:
            node_id = module_info.pop('nodeId')
            result[node_id] = module_info

    return result


if __name__ == '__main__':
    # Example usage
    pass
