import re
import time
import json
import paramiko
import SSHLibrary
from robot.api import logger
from robot.libraries.BuiltIn import BuiltIn
from taf.transport.ssh import ssh
from taf.transport.ssh.exceptions import CommandOutputTimeoutError
from collections import OrderedDict
from string import Template
import yaml
import sys
import socket

# from ruamel import yaml
ssh_client = paramiko.SSHClient()
ssh_client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
ssh = ssh()
content1 = None
content2 = None


def check_l1_symboldata(alias, up_node, tenant):
    result = "None"
    connection = ssh.get_connection_by_alias(alias)
    channel = connection.invoke_shell()
    time.sleep(3)
    container_name = f"ctr-{tenant}-l1hi" if tenant in up_node else "ctr-l1hi"
    channel.send(f'kubectl exec -it {up_node} -c {container_name} bash -n {tenant}\n')
    time.sleep(15)
    output = channel.recv(65536)
    output1 = output.decode().split('\r\n')
    print(output1)
    try:
        if "bash" in output1[-1]:
            print("***yes****")
            time.sleep(5)
            channel.send('/opt/nokia/bin/fhp_cli\n')
            time.sleep(5)
            output = channel.recv(65536)
            if "FHP_CLI" in output:
                time.sleep(10)
                channel.send('fhpshow stats summary\n')
                time.sleep(10)
                output = channel.recv(65536)
                print((type(output)))
                output_list = output.decode().split("\r\n")
                pattern = re.compile(r'\w*\s*:\s(\d*)')
                totle = float(pattern.search(output_list[1]).group(1))
                late = float(pattern.search(output_list[7]).group(1))
                early = float(pattern.search(output_list[8]).group(1))
                print((totle, late, early))
                if totle > 0.0 and early/totle < 0.05 and late/totle < 0.05:
                    result = "True"
                else:
                    result = "False"
    except Exception as e:
        print(e)
        print('Failed')
    finally:
        print((output, result))
        return output, result


def get_dl_tput_from_l2_log(log_path, duration):
    tb_list = list()
    with open(log_path, 'r') as f:
        lines = f.readlines()
        for line in lines:
            if "ttisFromUpdate" in line:
                timestamp = re.findall(r' <.*>', line)
                tb_size = re.findall(r'\|DataPdu:\s*\d+\|', line)
                if len(tb_size) != 0:
                    tb_size = re.findall(r'\d+', tb_size[0])
                    tb_list.append(int(tb_size[0]))
        logger.info("dl tb_size is {}".format(tb_list))
        if tb_list:
            dl_tput = round(float(sum(tb_list)) / float(duration) * 8 / 1024 / 1024, 3)
        else:
            dl_tput = 0.0
    return dl_tput, len(tb_list)


def get_ul_tput_from_l2_log(log_path, duration):
    tb_list = list()
    with open(log_path, 'r') as f:
        lines = f.readlines()
        for line in lines:
            if "UlCounterUpdate" in line:
                timestamp = re.findall(r' <.*>', line)
                tb_size = re.findall(r'/UL:\s*\d+\s*Bytes received', line)
                tb_size = re.findall(r'\d+', tb_size[0])
                tb_list.append(int(tb_size[0]))
        logger.info("ul tb_size is {}".format(tb_list))
        if tb_list:
            ul_tput = round(float(sum(tb_list)) / float(duration) * 8 / 1024 / 1024, 3)
        else:
            ul_tput = 0.0
    return ul_tput, len(tb_list)


def check_l1_symbol(out1, out2):
    Ingress_res1 = out1[9].split(":")[1]
    # resp1 = [line.split(",")[9].split(":")[1] for line in out1[0]]
    Ingress_res2 = out2[9].split(":")[1]
    Egress_res1 = out1[20].split(":")[1]
    Egress_res2 = out2[20].split(":")[1]
    print((int(Ingress_res2) - int(Ingress_res1), int(Egress_res2) - int(Egress_res1)))
    if int(Ingress_res2) - int(Ingress_res1) > 1000 and int(Egress_res2) - int(Egress_res1) > 100:
        return True
    else:
        return False


def kubectl_get_pods(namespace, conn):
    result = ssh.execute("kubectl get pod -n {}".format(namespace), conn)
    return result


def read_override_file(file_path):
    with open(file_path) as f:
        content = yaml.load(f, Loader=yaml.FullLoader)
    return content


def dicMeg(dic1, dic2):
    for i in dic2:
        if i in dic1:
            if type(dic1[i]) is dict and type(dic2[i]) is dict:
                dicMeg(dic1[i], dic2[i])
            else:
                dic1[i] = dic2[i]
        else:
            dic1[i] = dic2[i]
    return dic1


def edit_yaml_file(filepath, data):
    with open(filepath) as f:
        content = yaml.load(f, Loader=yaml.FullLoader)
        dicMeg(content, data)

    with open(filepath, 'w') as nf:
        yaml.dump(content, nf)
    return content


def update_yaml_file(template_file, new_yaml_file):
    with open(template_file) as f:
        template = yaml.load(f, Loader=yaml.FullLoader)
        print(('***template is \n{}'.format(template)))
    with open(new_yaml_file) as f:
        new_yaml = yaml.load(f, Loader=yaml.FullLoader)
        print(('***new yaml is \n{}'.format(new_yaml)))
        update_yaml(template, new_yaml)
        print(('***yaml to be updated is \n{}'.format(template)))
    with open(new_yaml_file, 'w') as nf:
        yaml.dump(new_yaml, nf, default_flow_style=False, sort_keys=False)
    return new_yaml


def update_yaml(templated_dict, new_yaml_dict):
    # if value_to_be_updated has value, use it, if not, use value in template_dict. key use template
    templated_dict1 = dict((k.lower(), v) for k, v in list(templated_dict.items()))
    for key in list(new_yaml_dict.keys()):
        key_1 = key.lower()
        # templated_dict1 = dict((k.lower(), v) for k, v in templated_dict.items())
        update_value = templated_dict1.get(key_1)
        # print('***update_value is \n{}'.format(update_value))
        if update_value:
            if type(update_value) is list and key == "ipInfo":
                # new_yaml_dict[key][0].update(update_value[0])
                update_yaml(update_value[0], new_yaml_dict[key][0])
            elif type(update_value) is list and key == "vlanInfo":
                new_key_value = new_yaml_dict.get(key)
                for value in update_value:
                    vlName = value["vlName"]
                    for temp in new_key_value:
                        if vlName == temp["vlName"]:
                            update_yaml(value, temp)
            elif type(update_value) is dict:
                update_yaml(update_value, new_yaml_dict[key])
            else:
                new_yaml_dict[key] = update_value
    return new_yaml_dict


def get_node_list(cmd, alias):
    output = ssh.execute("{}|awk '{{print $1}}'".format(cmd), connection=alias)
    res = output.split("\r\n")[1:-1]
    return res


def get_build_name(path):
    return path.split('/')[-1]


def get_aic_knife_version(build_name):
    if "CU_CNF" in build_name:
        return build_name.split('-', 1)[-1]
    elif "CNF" in build_name:
        return build_name.split('_', 1)[-1]
    else:
        return build_name.split('-', 1)[-1]


def get_aic_helm_list(namespace, conn):
    cmd1 = 'helm3 list -n {}|grep -v rbac '.format(namespace)
    cmd = cmd1 + r" |awk -F '\t' " + "'{0}print $1 {1} $3 {1} $4 {1} $5 {1} $6 {1} $7 {1} $2{2}'".format(
        "{", '\"\\t\"', "}")
    output = ssh.execute(cmd, connction=conn)
    return output


def findPowerStr(txOutput):
    for str in txOutput:
        if "Power" in str or 'Received with parameter' in str:
            return str
    return None


def check_rf_power(ipaddr, conn_username, conn_password, rf_username=None, rf_password=None, oam_node=None, tenant=None,
                   ssh_key_file_path=None, is_fdd=True, is_lte=False, site=None, port=22):
    if is_lte:
        if 'OULU' in site:
            command_list = ["/usr/bin/dapd -pwr 1\n"]
        else:
            command_list = ["/usr/bin/dapd -pwr 0\n", "/usr/bin/dapd -pwr 2\n"]
    else:
        command_list = ["/usr/bin/dapd -pwr 0\n", "/usr/bin/dapd -pwr 1\n"]
    result = True
    ssh_client.connect(hostname=ipaddr, port=port, username=conn_username, key_filename=ssh_key_file_path,
                       password=conn_password, look_for_keys=False, banner_timeout=60, timeout=60)
    if not is_fdd:
        logger.info('***TDD setup, connecting to oamfh container***')
        stdin, stdout, stderr = ssh_client.exec_command("ls")
        channel = ssh_client.invoke_shell()
        container_name = f"ctr-{tenant}-oamfh" if tenant in oam_node else "ctr-oamfh"
        channel.send("kubectl exec -it -n {} {} -c {} -- bash \n".format(tenant, oam_node, container_name))
        time.sleep(3)
        res1 = channel.recv(65536).decode().split('\r\n')
        logger.debug(f'output of entering oamfh is: {res1}')
    else:
        logger.info('***FDD setup, connecting to ruproxy***')
        stdin, stdout, stderr = ssh_client.exec_command("docker ps|grep ruproxy|awk '{{print $1}}'")
        ruproxy_id = stdout.read().decode().strip()
        logger.debug(f'ruproxy_id is: {ruproxy_id}')
        channel = ssh_client.invoke_shell()
        channel.send("docker exec -it {} bash\n".format(ruproxy_id))
        time.sleep(3)
        res1 = channel.recv(65536).decode().split('\r\n')
        logger.debug(f'connect to ruproxy: {res1}')
        logger.debug(f'connect to ruproxy2: {res1[-1]}')
    time.sleep(5)
    if not is_fdd and "bash" in res1[-1]:
        logger.info('***Start to get rf ip in oam fh container***')
        channel.send('arp -a\n')
        time.sleep(3)
        output = channel.recv(65536).decode()
        logger.debug(f'output of arp -a: {output}')
        res = re.search(r"\((.*)\) at .* \[ether\] on fhm.*", output)
        logger.debug(f'fhm ip search result: {res}')
        if res:
            ip = res.groups()[0]
            logger.debug('fhmplane ip :' + ip)
        else:
            ip = '192.168.254.34'
            logger.debug(f'failed to find fhmplane ip, use default value: {ip}')
        logger.info(f'***rf assigned ip is: {ip}***')
#        print(f"username is {username}")
        channel.send('ssh {}@{}\n'.format(rf_username, ip))
        time.sleep(3)
    elif is_fdd and "$" in res1[-1]:
        logger.info(f'***Login to RF via ip 169.254.1.2***')
        channel.send('ssh -oHostKeyAlgorithms=+ssh-rsa root@169.254.1.2\n')
        time.sleep(3)
    output = channel.recv(65536).decode().split('\r\n')
    logger.debug(f"The output after login rf is: {output}")
    if "yes" in output[-1]:
        logger.info("Send 'yes' to query Are you sure you want to continue connecting (yes/no/[fingerprint])")
        channel.send('yes\n')
        time.sleep(3)
        output = channel.recv(65536).decode().strip().split('\r\n')
        output2 = output
        logger.debug(f"the output after send yes is: {output}")
        if "password:" in output[-1]:
            logger.info(f"***Send RF password {rf_password}***")
            channel.send(rf_password + '\n')
            time.sleep(10)
            output2 = channel.recv(65536).decode().split('\r\n')
            logger.debug(f"the output if sending psw is: {output2}")
            if not is_lte:
                logger.info("***Send 'ssh 192.168.100.2' for 5G setups***")
                channel.send('ssh 192.168.100.2\n')
                time.sleep(10)
                output2 = channel.recv(65536).decode().strip().split('\r\n')
        logger.debug(f"output2: {output2}")
        if (is_fdd and (re.search(r'(~#)', output[-1]))) or (not is_fdd and re.search(r'(~#|\$)', output2[-1])):
            logger.info("***Start to check ru power****")
            for command in command_list:
                if not is_fdd and not is_lte:
                    channel.send("sudo " + command)
                else:
                    channel.send(command)
                time.sleep(2)
                TX_output = channel.recv(65536).decode().split('\r\n')
                logger.debug(f'tx_output is: {TX_output}')
                logger.info("****Stop response****")
                rf_power = findPowerStr(TX_output)
                logger.info(f'***rf_power is: {rf_power}')
                if rf_power is None:
                    logger.console(f'\nRF power NOT checked')
                else:
                    logger.console('\n' + rf_power)
                    power_value = re.findall(r'TX=\d+\.\d+|\d+', rf_power.split(',')[0])
                    if power_value:
                        logger.info(f"Start to check if power value is valid: {power_value[0]}")
                        if power_value[0] == "TX=0.0":
                            logger.warn(f"Power value is zero")
                            result = False
                    else:
                        logger.warn(f"Power value is invalid!")
                        result = False
        else:
            logger.warn("Skip RF power check due to failed login")
    else:
        logger.warn("Skip RF power check due to no query pops up: \
Are you sure you want to continue connecting (yes/no/[fingerprint])")
    ssh_client.close()
    return result


def ports(pod_name, container_name, namespace, conn):
    """ Author: Yang, Le"""
    cmd1 = 'kubectl exec -it {} -c ctr-{}-{} -n {} -- dpdk-cli '.format(pod_name, namespace, container_name, namespace)
    cmd = cmd1 + r"show port table | grep BIP | awk -F ' ' '{print $1}'"
    output = ssh.execute(cmd, connection=conn)
    res = output.decode().split("\r\n")[:-1]
    return list(map(str.strip, res))


def pcaps(pod_name, container_name, namespace, conn):
    """ Author: Yang, Le"""
    cmd1 = 'kubectl exec -it {} -c ctr-{}-{} -n {} -- ls -l '.format(pod_name, namespace, container_name, namespace)
    cmd = cmd1 + r"/tmp | grep pcap | grep -v fh | awk '{print $9}'"
    output = ssh.execute(cmd, connection=conn)
    res = output.decode().split("\r\n")[:-1]
    return list(map(str.strip, res))


def process(pod_name, container_name, namespace, conn):
    """ Author: Yang, Le"""
    cmd1 = "kubectl exec -it {} -c ctr-{}-{} -n {} -- ps -ef ".format(pod_name, namespace, container_name, namespace)
    cmd = cmd1 + r"| grep -i 'pdump' | grep -v grep | awk '{print $2}' | sed -n '1p'"
    output = ssh.execute(cmd, connection=conn)
    res = output.decode().split("\r\n")[:-1]
    return list(map(str.strip, res))


def tailor(items):
    """ Author: Yang, Le"""
    return {
        "remove": ['rm -rf ' + item for item in items],
        "copy": ['cp tmp/' + item + ' /var/core' for item in items],
        "pdump": ['dpdk-cli pdump port ' + item for item in items],
        "kill": ['kill -9 ' + item for item in items]
    }


def generate_command(pod_name, container_name, namespace, cmd_bash):
    """ Author: Yang, Le"""
    cmd = Template("${enter_cont} -- bash -c '${cmd_param}'")
    enter_cont1 = "kubectl exec -it " + pod_name + " -n " + namespace
    enter_cont = enter_cont1 + " -c " + "ctr" + "-" + namespace + "-" + container_name
    return cmd.substitute(enter_cont=enter_cont, cmd_param=cmd_bash)


def cmd_handle_pcap(pod_name, container_name, namespace, conn, sub_cmd):
    """ Author: Yang, Le"""
    func_dict = {'remove': pcaps, 'copy': pcaps, 'kill': process, 'pdump': ports}
    result = func_dict[sub_cmd](pod_name, container_name, namespace, conn)
    cmd1 = ';'.join(tailor(result)[sub_cmd])
    cmd = generate_command(pod_name, container_name, namespace, cmd_bash=cmd1)
    if sub_cmd == 'pdump':
        cmd = 'nohup ' + cmd
    return cmd


def filter_href_cont(cont):
    res = re.findall(r"href=\"(\w.*)\"", cont)
    res_list = []
    for value in res:
        cont = value.replace('/', '')
        res_list.append(cont)
    return res_list


def check_all_pods_status(namespace, conn=None):
    global test_result
    test_result = "False"
    result = ssh.execute("kubectl get pod -n {}".format(namespace), conn)
    print("get pod result is:", result)
    lines = result.splitlines()
    header = get_result_header(lines)
    result = []
    for line in lines:
        item = get_pod_header_items(header, line)
        result.append(item)
    if len(result) < 20:
        test_result = 'False'
        return test_result
    for i in range(0, len(result)):
        pod_res = re.findall(r'\d+', result[i]['ready'])
        if (result[i]["status"] != "Running"):
            test_result = "False"
            return test_result
        elif len(pod_res) != 0 and pod_res[0] != pod_res[1]:
            test_result = "False"
            return test_result
        else:
            test_result = "True"
    return test_result


def get_result_header(lines):
    while True:
        header = lines.pop(0)
        if header.strip().startswith("NAME"):
            break
    return header


def get_pod_header_items(header, line):
    item = {}
    item["name"] = line[header.index("NAME"): header.index("READY")].strip()
    item["ready"] = line[header.index("READY"): header.index("STATUS")].strip()
    item["status"] = line[header.index("STATUS"): header.index("RESTARTS")].strip()
    item["restarts"] = line[header.index("RESTARTS"): header.index("AGE")].strip()
    item["age"] = line[header.index("AGE"):].strip()
    return item


def get_all_pod_name(cont):
    pod_list = []
    lines = cont.splitlines()
    header = get_result_header(lines)
    pod_name_list = []
    for line in lines:
        item = get_pod_header_items(header, line)
        pod_list.append(item)
    print('pod list is:', pod_list)
    for i in range(0, len(pod_list)):
        pod_name = (pod_list[i]['name']).split("-")[-2]
        pod_name = pod_name + '_pod'
        pod_name_list.append(pod_name)
    print('pod name is:', pod_name_list)
    return pod_name_list


def set_all_pods_name(cont):
    pod_list = []
    lines = cont.splitlines()
    header = get_result_header(lines)
    for line in lines:
        item = get_pod_header_items(header, line)
        pod_list.append(item)
    print('pod list is:', pod_list)
    for i in range(0, len(pod_list)):
        pod_name = (pod_list[i]['name']).split("-")[-2] + '_pod'
        BuiltIn().set_suite_variable('${' + pod_name + '}', pod_list[i]['name'])


def get_vcu_vdu_helm_file(path, match_name, alias=None):
    result_list = ["True"]
    file_output = ssh.execute("ls -l {}|grep -P '{}'".format(path, match_name), connection=alias)
    print('file output:', file_output)
    if len(file_output) == 0:
        logger.error('cannot find tgz file, please manually check!')
        result_list = ["False", "None"]
        return result_list
    tgz_file = file_output.split()[-1].strip()
    unzip_file = ssh.execute("cd {};tar -zxvf {}".format(path, tgz_file), connection=alias)
    print('unzip file:', unzip_file)
    if len(unzip_file) == 0 or 'Error is not recoverable' in unzip_file:
        logger.error('unzip {} file failed, please manually check!'.format(tgz_file))
        result_list = ["False", "None"]
        return result_list
    folder_ouput = unzip_file.split('\r')[0].split('/')[0]
    result_list.append(folder_ouput)
    return result_list[0], result_list[1]


def get_system_pod_status(command, alias):
    global test_result
    test_result = "True"
    result = ssh.execute("{}".format(command), alias)
    lines = result.splitlines()
    header = get_result_header(lines)
    result = []
    for line in lines:
        item = get_pod_header_items(header, line)
        result.append(item)
    for i in range(0, len(result)):
        if (result[i]["status"] == "CrashLoopBackOff" and 'openshift' in result[i]["name"]):
            logger.warn('System pod status check failed: {}'.format(result[i]))
            test_result = "False"
    return test_result


def get_pod_containers(namespace, conn):
    """
    Retrieve the containers running in the specified namespace using the provided connection.

    Args:
        namespace (str): The namespace to search for pods.
        conn: The connection object used to execute commands.

    Returns:
        list: A list of dictionaries, where each dictionary represents a pod and its associated containers.
              The dictionary has the pod name as the key and a list of container names as the value.
    """
    container_dict = []
    pod_list = []
    pod_name_list = []
    pod_ouput = ssh.execute("kubectl get pod -n {}".format(namespace), connection=conn)
    lines = pod_ouput.splitlines()
    header = get_result_header(lines)
    for line in lines:
        item = get_pod_header_items(header, line)
        pod_list.append(item)
    for i in range(0, len(pod_list)):
        pod_name = (pod_list[i]['name'])
        pod_name_list.append(pod_name)
    print('pod name is:', pod_name_list)
    for i in range(0, len(pod_name_list)):
        container_list = []
        output = ssh.execute("kubectl describe pod {} -n {} | grep -w 'CONTAINER_NAME' | awk '{{print $2}}'"
                             .format(pod_name_list[i], namespace), connection=conn)
        output1 = output.split()
        for j in range(0, len(output1)):
            container_list.append(output1[j])
        item = {pod_name_list[i]: container_list}
        container_dict.append(item)
    print('container dict is:', container_dict)
    return container_dict


def check_mri_state_on_FHGW_and_print_warning(mri, alias):
    result = False
    command = ["redis-cli -h redis -n 18 GET mriState", "systemctl restart rumoduleagent"]
    mri_list = mri.split()
    logger.debug('mri_list is: {}'.format(', '.join(mri_list)))
    logger.debug('command_list is: {}'.format((', ').join(command)))
    for i in range(0, 2):
        mri_res1 = ssh.execute(command=command[0], connection=alias).strip().replace('"', '')
        logger.info('MRI status: {}'.format(mri_res1))
        if mri_res1 not in mri_list:
            BuiltIn().log('MRI status is "{}", not in allowed mri status list {}, \
recovery will be triggered by command "{}"'.format(mri_res1.strip(), ','.join(mri_list), command[1]), "WARN")
            recreate_ruproxy = ssh.execute(command=command[1], connection=alias)
            logger.debug('recreate_ruproxy result is: {}'.format(recreate_ruproxy))
            time.sleep(120)
            mri_res = ssh.execute(command=command[0], connection=alias).strip().replace('"', '')
            BuiltIn().log_to_console('After recovery, MRI status is: "{}"'.format(mri_res.strip()))
            if mri_res in mri_list:
                result = True
                break
        else:
            result = True
            break
    if result is False:
        logger.warn('Warning: FHGW issues, need fixed from FHGW side\n \
Recovery operation reference (How to recreate ruproxy pod):\
https://confluence.ext.net.nokia.com/pages/viewpage.action?pageId=1126978076')


def check_mri_state_on_FHGW_for_sync_in_rinline2(mri, alias):
    result = [False, ""]
    command = "redis-cli -h redis -n 18 GET mriState"
    mri_list = mri.split()
    logger.debug('mri_list is: {}'.format(', '.join(mri_list)))
    logger.debug('command is: {}'.format(command))
    mri_res = ssh.execute(command=command, connection=alias).strip().replace('"', '')
    logger.info('MRI status: {}'.format(mri_res))
    if mri_res in mri_list:
        result = [True, mri_res]
    else:
        result = [False, mri_res]
    return result


def check_if_scc_service_exists(command, alias):
    """
    Checks if the SCC time-sync-daemon service exists by executing a command over SSH.

    Args:
        command (str): The command to execute over SSH.
        alias (str): The alias of the SSH connection.

    Returns:
        bool: True if the SCC time-sync-daemon service exists, False otherwise.
    """
    content = ssh.execute(command=command, connection=alias)
    result = False
    lines = content.splitlines()
    headers = lines[0].split()
    print('headers:', headers)
    for line in lines[1:]:
        values = line.split()
        print('values:', values)
        result = dict(zip(headers, values))
        print('result:', result)
        if result['NAME'] == 'time-sync-daemon':
            result = True
    return result


def check_plan_validation_errors(validation_result):
    error_type_dict = {
        'totalErrorOfDefinitionError': 'definitionErrors',
        'totalErrorOfRelationError': 'relationErrors'
    }
    try:
        if validation_result['totalError'] > 0:
            for error_key, error_type in error_type_dict.items():
                if validation_result[error_key] > 0:
                    error_list = validation_result[error_type]
                    BuiltIn().log("{} visble, please check SCF!!!".format(error_type.capitalize()), "WARN")
                    for error in error_list:
                        error_message = error['errorDescription']
                        BuiltIn().log("{}".format(error_message), "WARN")
            return False
    except Exception as err:
        BuiltIn().fail("\nCheck plan validation errors failed due to error {}".format(err), "WARN")
    return True


def update_cr_yaml_file(
        yaml_file_path,
        sw_build,
        rancnf_name,
        namespace,
        imageRegistry,
        apiVersion='cnf.k8s.nokia.com/v1alpha2'
):
    """
    Update a RAN CNF Custom Resource YAML file with the specified parameters.

    This function loads a YAML file, updates its key fields (apiVersion, metadata, spec)
    with the provided arguments, and writes the changes back to the file. It also ensures
    that the 'ruProtocol' field is set for each DHCP pool (defaulting to 'Nokia' for the
    first two pools and 'Oran' for others), and that 'vlanId' is set to 1 for each lrip's
    first roundchk if not already present.

    Validation performed:
    - Validates that 'spec' field under 'spec.ranCnfConfig' is not null or empty
    - Validates that 'network' field under 'spec.ranCnfConfig.spec' is not null or empty
    - Validates that 'fronthaul' field under 'spec.ranCnfConfig.spec.network' is not null or empty (vDU build only)
    - Validates that 'mode' field under 'spec.ranCnfConfig.spec.network.fronthaul' is not null or empty (vDU build only)

    Args:
        yaml_file_path (str): The path to the YAML file to update.
        sw_build (str): The software build version to set in the YAML.
        rancnf_name (str): The name to set for the RAN CNF resource.
        namespace (str): The Kubernetes namespace to set in the YAML.
        imageRegistry (str): The image registry URL to set in the YAML.
        apiVersion (str, optional): The apiVersion to set. Defaults to 'cnf.k8s.nokia.com/v1alpha2'.

    Returns:
        bool: True if the file was updated successfully, False otherwise.

    Example:
        success = update_cr_yaml_file(
            yaml_file_path='/tmp/rancnf.yaml',
            sw_build='1.2.3',
            rancnf_name='my-rancnf',
            namespace='cran1',
            imageRegistry='my.registry.com'
        )
        if success:
            print("YAML file updated successfully.")
        else:
            print("Failed to update YAML file.")
    """
    try:
        with open(yaml_file_path, 'r') as file:
            yaml_content = yaml.safe_load(file)

        # Validate spec configuration
        if not yaml_content['spec']['ranCnfConfig']['spec']:
            raise ValueError("The 'spec' field under 'ranCnfConfig' is missing or empty.")

        # Validate network configuration
        if not yaml_content['spec']['ranCnfConfig']['spec']['network']:
            raise ValueError("The 'network' field is missing or empty.")

        # Validate fronthaul configuration (only for vDU builds)
        is_vdu_build = 'vDU' in sw_build
        if is_vdu_build:
            if not yaml_content['spec']['ranCnfConfig']['spec']['network']['fronthaul']:
                raise ValueError("The 'fronthaul' field is missing or empty.")

            # Validate fronthaul mode exists
            if not yaml_content['spec']['ranCnfConfig']['spec']['network']['fronthaul']['mode']:
                raise ValueError("The 'mode' field in 'fronthaul' is missing or empty.")

        # Update the YAML content with the provided parameters
        yaml_content['apiVersion'] = apiVersion
        yaml_content['metadata']['name'] = rancnf_name
        yaml_content['metadata']['namespace'] = namespace
        yaml_content['spec']['cnfConfig']['cnfSWBuild'] = sw_build
        yaml_content['spec']['cnfConfig']['imageRegistry'] = imageRegistry
        # DU cr yaml workaround
        if 'lrip' in yaml_content['spec']['ranCnfConfig']['spec']['network']:
            for lrip in yaml_content['spec']['ranCnfConfig']['spec']['network']['lrip']:
                if 'vlanId' not in lrip['roundchk'][0]:
                    lrip['roundchk'][0]['vlanId'] = 1

        with open(yaml_file_path, 'w') as file:
            yaml.safe_dump(yaml_content, file)
    except Exception as e:
        logger.warn(f"Error updating YAML file: {e}")
        return False
    return True


def get_rancnf_result(namespace, conn='RM_alias'):
    """
    Get the status and details of the RAN CNF resource in a given namespace.

    Args:
        namespace (str): The Kubernetes namespace to query for the RAN CNF.
        conn (str, optional): The alias of the SSH connection to use for executing the kubectl command.
                              Defaults to 'RM_alias'.

    Returns:
        dict: A dictionary containing the following keys:
            - console_output: The raw output string from the kubectl command.
            - cnf_quantity: The number of lines in the output.
            - cnf_name: The name of the RAN CNF resource (if found).
            - required_cnf_build: The required CNF build version (if found).
            - action: The current action for the CNF (if found).
            - status: The status of the CNF (if found).
            - cnf_phase: The phase of the CNF (if found).
            - age: The age of the CNF resource (if found).
            - effective_cnf_build: The effective CNF build version, or 'N/A' if not available.

    Example:
        result = get_rancnf_result(namespace='cran1')
        print(result)
    """
    result_dict = {}
    command = f"kubectl get rancnf -n {namespace}"
    output = ssh.execute(command=command, connection=conn)
    logger.info(f"Output of {command}: {output}")
    json_command = "kubectl get rancnf -n {} -o json".format(namespace)
    json_result = ssh.execute(command=json_command, connection=conn)
    result_dict['console_output'] = output.strip()
    if json_result:
        try:
            cnf_status = json.loads(json_result)
        except json.JSONDecodeError as e:
            logger.info(f"Failed to decode JSON: {e} | Output: {json_result}")
            result_dict['cnf_quantity'] = 0
            return result_dict
        if len(cnf_status['items']) == 0:
            logger.info(f"No RAN CNF found in namespace {namespace}")
            result_dict['cnf_quantity'] = 0
            return result_dict
        cnf_name = cnf_status['items'][0]['metadata']['name']
        result_dict['cnf_name'] = cnf_name
        item = cnf_status['items'][0]
        status_info = item.get('status', {})
        result_dict['status'] = status_info.get('operation', {}).get('status', '')
        result_dict['action'] = status_info.get('operation', {}).get('type', '')
        result_dict['cnf_phase'] = status_info.get('phase', '')
        result_dict['effective_cnf_build'] = status_info.get('effectiveCnfSWBuild', '')
        result_dict['cnf_quantity'] = len(cnf_status['items'])
    else:
        result_dict['cnf_quantity'] = 0
    return result_dict


def get_rancnf_result_yaml(namespace, output_path, conn='RM_alias'):
    """
    Export the RAN CNF resource in a given namespace to a YAML file using kubectl.

    Args:
        namespace (str): The Kubernetes namespace to query for the RAN CNF.
        output_path (str): The file path where the YAML output will be saved.
        conn (str, optional): The alias of the SSH connection to use for executing the kubectl command.
                              Defaults to 'RM_alias'.

    Returns:
        None. The function writes the YAML output to the specified file.

    Example:
        get_rancnf_result_yaml(
            namespace='cran1',
            output_path='/tmp/hgz-1105/0.300.31859/rancnf_result.yaml',
            conn='RM_alias'
        )
    """
    command = f"kubectl get rancnf -n {namespace} -o yaml > {output_path}"
    output = ssh.execute(command=command, connection=conn)
    logger.info(f"Output of {command}: {output}")


def get_cnf_creation_status_from_yaml(
        namespace,
        save_error_to_file_path='',
        cnf_phase='install',
        log_to_console=True,
        conn='RM_alias'
):
    """
    Retrieve the creation status of a RAN CNF resource in a given Kubernetes namespace.

    This function executes a `kubectl get rancnf` command via SSH, parses the JSON output,
    and extracts the status of the first RAN CNF resource found.
    Optionally, it prints the status
    to the console and/or saves it to a file.

    Args:
        namespace (str): The Kubernetes namespace to query for the RAN CNF resource.
        save_error_to_file_path (str, optional): If provided,
        saves the CNF status to this file path.
        cnf_phase (str, optional): The phase label to use in console/file output
        (default: 'install').
        log_to_console (bool, optional): If True, prints the CNF status to the console
        (default: True).
        conn (str, optional): The SSH connection alias to use for executing the command
        (default: 'RM_alias').

    Returns:
        dict: The status dictionary of the first RAN CNF resource found,
        or an empty dict if none found.

    Example:
        status = get_cnf_creation_status_from_yaml(
            namespace='cran1',
            save_error_to_file_path='/tmp/cnf_status.txt',
            cnf_phase='install',
            log_to_console=True,
            conn='RM_alias'
        )
        if status:
            print("CNF status:", status)
        else:
            print("No CNF found in namespace.")
    """
    json_command = "kubectl get rancnf -n {} -o json".format(namespace)
    json_result = ssh.execute(command=json_command, connection=conn)
    if json_result:
        cnf_result = json.loads(json_result)
        if len(cnf_result['items']) == 0:
            logger.info(f"No RAN CNF found in namespace {namespace}")
            return {}
        cnf_status = cnf_result['items'][0].get('status', {})
        if cnf_status:
            if log_to_console:
                logger.console(f"\nCNF {cnf_phase} status:\n{json.dumps(cnf_status, indent=2)}")
            if save_error_to_file_path:
                with open(save_error_to_file_path, 'w') as file:
                    file.write(f"\n>>>>>>>CNF {cnf_phase} status:<<<<<\n")
                    file.write(json.dumps(cnf_status, indent=2))
            return cnf_status
    return {}


def remove_rancnf_finalizer(resource_name, namespace, conn="RM_alias"):
    """
    Remove the finalizer from a rancnf resource in the specified namespace via SSH.

    Args:
        resource_name (str): The name of the rancnf resource.
        namespace (str): The Kubernetes namespace.
        conn (str): The SSH connection alias. Default is "RM_alias".

    Returns:
        str: The output of the patch command.
    """
    # This patch removes all finalizers from the resource
    patch_cmd = (
        f'oc patch rancnf {resource_name} -n {namespace} '
        '--type=json -p \'[{"op": "remove", "path": "/metadata/finalizers"}]\''
    )
    output = ssh.execute(patch_cmd, connection=conn)
    logger.info(f"Removed finalizer from rancnf {resource_name}: {output}")


def get_release_name_from_helm_list(namespace, conn='RM_alias'):
    """
    Retrieve Helm release names in a given namespace, sorted by updated time in descending order.

    Args:
        namespace (str): The Kubernetes namespace to query for Helm releases.
        conn (str, optional): The SSH connection alias to use for executing the Helm command.
                              Defaults to 'RM'.

    Returns:
        list: A list of release names (str) in the specified namespace,
              sorted by their updated time (most recent first).

    Example:
        releases = get_release_name_from_helm_list('cran1')
        print(releases)
    """
    command = "helm list -a -A -n {} -o json".format(namespace)
    result = ssh.execute(command=command, connection=conn)
    if result:
        releases = json.loads(result)
        return [release['name'] for release in sorted(
            [r for r in releases if r['namespace'] == namespace],
            key=lambda x: x['updated'], reverse=True)]
    return []


def delete_ccr_secret_if_exists(hostname, username, password, namespace, secret_name='nokia-cnf-ccr-creds'):
    """
    Deletes the specified CCR (Container Credential Registry) secret from a given OpenShift namespace if it exists.

    This function connects to a remote host via SSH, checks if the secret exists in the specified namespace,
    and deletes it if found. It logs all actions and raises a failure if deletion is unsuccessful.

    Args:
        hostname (str): The hostname or IP address of the remote OpenShift node.
        username (str): The SSH username for the remote host.
        password (str): The SSH password for the remote host.
        namespace (str): The OpenShift namespace to check for the secret.
        secret_name (str, optional): The name of the secret to delete. Defaults to 'nokia-cnf-ccr-creds'.

    Raises:
        AssertionError: If the secret exists but cannot be deleted.

    Example:
        delete_ccr_secret_if_exists('10.107.115.2', 'core', 'system123', 'cu1105')
    """
    ssh.connect_to(hostname=hostname, username=username, password=password, alias='RM_alias')
    ccr_secret_check_cmd = f"oc get secrets -n {namespace} | grep {secret_name}"
    output = ssh.execute(command=ccr_secret_check_cmd, connection='RM_alias')
    logger.info(f"Checking for CCR secret with command: {ccr_secret_check_cmd}")
    logger.info(f"Command output: {output}")
    if output.strip() and output.find(secret_name) != -1:
        delete_ccr_secret_cmd = f"oc delete secret {secret_name} -n {namespace}"
        delete_result = ssh.execute(command=delete_ccr_secret_cmd, connection='RM_alias')
        logger.info(f"CCR secret found. Deletion command executed: {delete_ccr_secret_cmd}")
        logger.info(f"Deletion command output: {delete_result}")
        if "deleted" in delete_result:
            logger.info(f"CCR secret '{secret_name}' successfully deleted from namespace '{namespace}'.")
        else:
            BuiltIn().fail(f"Failed to delete CCR secret '{secret_name}' from namespace '{namespace}'.")
    else:
        logger.info(f"No CCR secret named '{secret_name}' found in namespace '{namespace}'.")
    ssh.disconnect(connection='RM_alias')


def is_ocp_version_higher_than_4_18(hostname, username, password):
    """
    Check if the OCP version is higher than 4.18.

    Args:
        hostname (str): The hostname or IP address of the OCP cluster.
        username (str): The username for SSH login.
        password (str): The password for SSH login.
        alias (str): The alias for the SSH connection.
    """
    try:
        ssh.connect_to(hostname=hostname, username=username, password=password, alias='RM_alias')
        command = "oc get nokiaclusters.nokia.com -o yaml |grep -i '  NokiaRelease'"
        output = ssh.execute(command=command, connection='RM_alias')
        logger.info(f"OCP version output of command '{command}': {output}")
        ssh.disconnect('RM_alias')
        match = re.search(r'ocp-(\d+)\.(\d+)', output)
        if match:
            major = int(match.group(1))
            minor = int(match.group(2))
            if major > 4 or (major == 4 and minor >= 18):
                return True
    except Exception as e:
        logger.warn(f"Error checking OCP version on {hostname}: {e}, returning False")
    return False


def get_cnf_pvc_cluster_release_names_from_helm_list(namespace, conn='RM_alias'):
    """
    Retrieve Helm release names for CNF, PVC prerequisite,
    and cluster releases in a given namespace.

    This function calls `get_release_name_from_helm_list` to get all Helm release names
    in the specified namespace,
    then classifies them into three categories based on their name:
      - 'pvc_release': Release name containing 'prerequisite'
      - 'cluster_release': Release name containing 'cluster'
      - 'cnf_release': Any other release name (assumed to be the main CNF release)

    Args:
        namespace (str): The Kubernetes namespace to query for Helm releases.
        conn (str, optional):
        The SSH connection alias to use for executing the Helm command. Defaults to 'RM_alias'.

    Returns:
        dict: A dictionary with keys 'cnf_release', 'pvc_release', and 'cluster_release',
        each mapping to the corresponding release name (str).
              If a release is not found, its value will be an empty string.

    Example:
        release_names = get_cnf_pvc_cluster_release_names_from_helm_list('cran1')
        print(release_names)
        # Output:
        # {'cnf_release': 'my-cnf', 'pvc_release': 'my-prerequisite', 'cluster_release': 'my-cluster'}
    """
    release_name_dict = {'cnf_release': "", 'pvc_release': "", 'cluster_release': ""}
    releases = get_release_name_from_helm_list(namespace, conn=conn)
    logger.info(f"Helm releases in namespace '{namespace}': {releases}")
    if len(releases) == 3:
        release_name_dict['cnf_release'] = releases[0]
        release_name_dict['pvc_release'] = releases[1]
        release_name_dict['cluster_release'] = releases[2]
        return release_name_dict
    for release in releases:
        if "prerequisite" in release or "pvc" in release:
            release_name_dict['pvc_release'] = release
        elif "cluster" in release:
            release_name_dict['cluster_release'] = release
        else:
            release_name_dict['cnf_release'] = release
    return release_name_dict


def delete_helm_secrets(namespace, conn='RM_alias'):
    """
    Delete all Kubernetes secrets in the specified namespace whose names start with 'sh.helm.release'.

    This function connects to the target cluster via SSH, lists all secrets in the given namespace,
    filters those whose names begin with 'sh.helm.release', and deletes each matching secret.
    It logs all actions and outputs the remaining secrets after deletion.

    Args:
        namespace (str): The Kubernetes namespace to search for Helm secrets.
        conn (str, optional): The SSH connection alias to use for executing commands.
        Defaults to 'RM_alias'.

    Returns:
        None

    Example:
        delete_helm_secrets('cran1')
        # Deletes all secrets named like 'sh.helm.release.*' in the 'cran1' namespace.
    """
    logger.console(f"\nDeleting secrets starting with 'sh.helm.release' in namespace: {namespace}")
    get_helm_secrets_cmd = (
        f"oc get secret -n {namespace} --no-headers | "
        "awk '/^sh.helm.release/ {print $1}'"
    )
    logger.debug(f"Command to get Helm secrets: {get_helm_secrets_cmd}")
    output = ssh.execute(command=get_helm_secrets_cmd, connection=conn)
    logger.debug(f"Output of Helm secrets command: {output}")
    if not output.strip():
        logger.console(f"No Helm secrets found in namespace: {namespace}")
        return

    for secret in output.splitlines():
        delete_secret_cmd = f"oc delete secret {secret} -n {namespace}"
        logger.debug(f"Command to delete Helm secret: {delete_secret_cmd}")
        delete_result = ssh.execute(command=delete_secret_cmd, connection=conn)
        logger.debug(f"Output of delete command for secret {secret}: {delete_result}")

    get_helm_secrets_cmd = f"oc get secret -n {namespace}"
    remain_secrets_output = ssh.execute(command=get_helm_secrets_cmd, connection=conn)
    logger.debug(
        f"Remaining secrets in namespace {namespace} after deletion attempt: {remain_secrets_output}"
    )


def force_delete_rancnf(rancnf, namespace, conn='RM_alias'):
    """
    Forcefully delete a RAN CNF custom resource in the specified namespace by removing its finalizers.

    This function performs a two-step deletion process for a RAN CNF resource:
      1. Removes any Kubernetes finalizers from the resource,
      allowing it to be deleted even if it is stuck in a terminating state.
      2. Executes a forceful delete command to remove the resource immediately,
      bypassing the normal grace period.

    All actions are logged to the console. After deletion,
    the function checks if the resource still exists and reports success or failure.

    Args:
        rancnf (str): The name of the RAN CNF resource to delete.
        namespace (str): The Kubernetes namespace containing the resource.
        conn (str, optional): The SSH connection alias to use for executing commands.
        Defaults to 'RM_alias'.

    Returns:
        None

    Example:
        force_delete_rancnf('my-rancnf', 'cran1')
        # Removes finalizers and force deletes the 'my-rancnf' resource in the 'cran1' namespace.
    """
    logger.console(f"\nForce deleting RAN CNF: {rancnf} in namespace: {namespace}")
    remove_rancnf_finalizer(rancnf, namespace, conn=conn)
    force_delete_rancnf_cmd = f"oc delete rancnf {rancnf} -n {namespace} --grace-period=0 --force"
    logger.info(f"Command to force delete RAN CNF: {force_delete_rancnf_cmd}")
    delete_result = ssh.execute(command=force_delete_rancnf_cmd, connection=conn)
    logger.info(f"Output of force delete command for RAN CNF {rancnf}: {delete_result}")
    rancnf_result_dict = get_rancnf_result(namespace, conn=conn)
    if rancnf_result_dict.get('cnf_quantity', 0) == 0:
        logger.console(f"------> DONE")
    else:
        BuiltIn.fail(f"Failed to delete RAN CNF {rancnf} from namespace {namespace}.")


def collect_cnf_lcm_pod_and_logs(
    namespace='cnf-lcm-operator',
    controller_log_path='/tmp/cnf_controller.log',
    engine_log_path='/tmp/cnf_engine.log',
    upload_path_prefix='/tmp/test',
    conn='RM_alias'
):
    """
    Get the CNF LCM pod name in the given namespace and fetch logs for its controller and engine containers.

    Args:
        conn (str): SSH connection alias.
        namespace (str): Namespace to search for the pod.
        controller_log_path (str): Path to save controller logs.
        engine_log_path (str): Path to save engine logs.

    Returns:
        None.
    """
    try:
        # Get pod list
        cmd_get_pods = f"kubectl get pods -n {namespace} --no-headers"
        output = ssh.execute(cmd_get_pods, connection=conn)
        logger.info(f"Pods in namespace {namespace}:\n{output}")
        # Find the pod name (starts with 'cnf-lcm-')
        pod_name = None
        for line in output.splitlines():
            if line.startswith('cnf-lcm-'):
                pod_name = line.split()[0]
                break
        if not pod_name:
            raise Exception("CNF LCM pod not found in namespace {}".format(namespace))
        # Get controller logs
        cmd_controller = f"oc logs {pod_name} -n {namespace} -c cnf-lcm-controller >> {controller_log_path}"
        ssh.execute(cmd_controller, connection=conn)
        # Get engine logs
        cmd_engine = f"oc logs {pod_name} -n {namespace} -c cnf-lcm-engine >> {engine_log_path}"
        ssh.execute(cmd_engine, connection=conn)
        ssh.download_file(controller_log_path, f"{upload_path_prefix}_cnf_controller.log", connection=conn)
        ssh.download_file(engine_log_path, f"{upload_path_prefix}_cnf_engine.log", connection=conn)
        logger.info(f"CNF LCM logs are uploaded")
    except Exception as e:
        logger.warn(f"Failed to collect CNF LCM logs: {e}")


def get_cnf_apiVersion(crd='rancnfs.cnf.k8s.nokia.com', conn='RM_alias'):
    """
    Get the apiVersion of the specified Custom Resource Definition (CRD).

    Args:
        crd (str): The name of the CRD to query.
        conn (str): SSH connection alias.

    Returns:
        str: The apiVersion of the CRD, or an empty string if not found.
    """
    try:
        cmd = f"oc get crd {crd} -o json"
        output = ssh.execute(cmd, connection=conn).strip()
        logger.info(f"apiVersion of CRD {crd}: {output}")
        if output:
            crd_info = json.loads(output)
            api_version = crd_info.get('status', {}).get('storedVersions', [])
            if api_version:
                return api_version[0]
        return ""
    except Exception as e:
        logger.warn(f"Failed to get apiVersion for CRD {crd}: {e}")
        return ""


def get_events_of_given_pod(namespace, pod_name, conn='RM_alias'):
    """
    Retrieve events related to a specific pod in a given namespace.

    Args:
        namespace (str): The Kubernetes namespace where the pod is located.
        pod_name (str): The name of the pod to retrieve events for.
        conn (str): SSH connection alias.
    Returns:
        str: The events related to the specified pod.
    """
    try:
        cmd = f"kubectl get events -n {namespace} --field-selector involvedObject.name={pod_name} -o wide"
        output = ssh.execute(cmd, connection=conn).strip()
        logger.info(f"Events for pod {pod_name} in namespace {namespace}:\n{output}")
        return output
    except Exception as e:
        logger.warn(f"Failed to get events for pod {pod_name} in namespace {namespace}: {e}")
        return ""


def get_image_pull_backoff_pods_list(namespace, conn='RM_alias'):
    """
    Retrieve a list of pods in the specified namespace that are in 'ImagePullBackOff' status.

    Args:
        namespace (str): The Kubernetes namespace to search for pods.
        conn (str): SSH connection alias.

    Returns:
        list: A list of pod names that are in 'ImagePullBackOff' status.
    """
    image_pull_backoff_pods = []
    try:
        cmd = f"kubectl get pods -n {namespace} --no-headers"
        output = ssh.execute(cmd, connection=conn).strip()
        logger.info(f"Pods in namespace {namespace}:\n{output}")
        for line in output.splitlines():
            parts = line.split()
            pod_name = parts[0]
            pod_status = parts[2]
            if re.match(r"ImagePullBackOff|ErrImagePull", pod_status):
                image_pull_backoff_pods.append(pod_name)
    except Exception as e:
        logger.warn(f"Failed to get ImagePullBackOff pods in namespace {namespace}: {e}")
    return image_pull_backoff_pods


def log_events_of_image_pull_backoff_pods(namespace, conn='RM_alias'):
    """
    Log events for all pods in the specified namespace that are in 'ImagePullBackOff' status.

    Args:
        namespace (str): The Kubernetes namespace to search for pods.
        conn (str): SSH connection alias.

    Returns:
        None
    """
    pods = get_image_pull_backoff_pods_list(namespace, conn=conn)
    if not pods:
        logger.info(f"No pods in 'ImagePullBackOff' status found in namespace {namespace}.")
        return
    for pod in pods:
        events = get_events_of_given_pod(namespace, pod, conn=conn)
        logger.warn(f"\nEvents for pod {pod} in namespace {namespace}:\n{events}")


def is_host_reachable(host, port=443, timeout=5):
    """
    Check if a host is reachable on a given port.

    Args:
        host (str): Hostname or IP address to check.
        port (int): Port number to check (default: 443).
        timeout (int): Timeout in seconds (default: 5).

    Returns:
        bool: True if reachable, False otherwise.
    """
    try:
        with socket.create_connection((host, port), timeout=timeout):
            logger.info(f"{host}:{port} is reachable.")
            return True
    except Exception as e:
        logger.warn(f"{host}:{port} is NOT reachable: {e}")
        return False


if __name__ == '__main__':
    # ssh.connect_to(hostname='10.44.79.231', username='core', password='system123', alias='RM_alias')
    # print(log_events_of_image_pull_backoff_pods('ran-nic-sw-controller', conn='RM_alias'))
    print(is_host_reachable('harbor-qt.ocp.hz.nsn-rdnet.net'))
