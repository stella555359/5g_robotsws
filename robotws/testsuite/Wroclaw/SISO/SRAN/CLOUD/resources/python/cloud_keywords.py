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
    channel.send('kubectl exec -it {0} -c ctr-{1}-l1hi bash -n {1}\n'.format(up_node, tenant))
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
        if "Power" in str:
            return str
    return None


def check_rf_power(ipaddr, username, password, oam_node=None, tenant=None, ssh_key_file_path=None, alias=None,
                   is_fdd=True, port=22):
    command_list = ["/usr/bin/dapd -pwr 0\n", "/usr/bin/dapd -pwr 1\n"]
    power_vlaue_list = []
    power_vlaue_list_0 = []
    result_list = []
    ssh_client.connect(hostname=ipaddr, port=port, username=username, key_filename=ssh_key_file_path,
                       password=password, look_for_keys=False, banner_timeout=60, timeout=60)
    if not is_fdd:
        stdin, stdout, stderr = ssh_client.exec_command("ls")
        channel = ssh_client.invoke_shell()
        channel.send("kubectl exec -it {} -c ctr-{}-oamfh bash -n {}\n".format(oam_node, tenant, tenant))
        time.sleep(3)
        res1 = channel.recv(65536).decode().split('\r\n')
    else:
        stdin, stdout, stderr = ssh_client.exec_command("docker ps|grep ruproxy|awk '{{print $1}}'")
        ruproxy_id = stdout.read().decode().strip()
        print('ruproxy_id is:', ruproxy_id)
        channel = ssh_client.invoke_shell()
        channel.send("docker exec -it {} bash\n".format(ruproxy_id))
        time.sleep(3)
        res1 = channel.recv(65536).decode().split('\r\n')
        print('connect to ruproxy:', res1)
        print('connect to ruproxy2:', res1[-1])
    time.sleep(5)
    if not is_fdd and "bash" in res1[-1]:
        channel.send('arp -a\n')
        time.sleep(3)
        output = channel.recv(65536).decode()
        print('output of arp -a', output)
        res = re.search("\\((.*)\\) at .* \\[ether\\] on fhmplane", output)
        print('res ip is:', res)
        if res:
            ip = res.groups()[0]
            print('ip xx:', ip)
        else:
            ip = '192.168.254.34'
        print('rf assigned ip is:', ip)
        channel.send('ssh serviceuser@{}\n'.format(ip))
        time.sleep(3)
    elif is_fdd and "$" in res1[-1]:
        channel.send('ssh -oHostKeyAlgorithms=+ssh-rsa root@169.254.1.2\n')
        time.sleep(3)
    output = channel.recv(65536).decode().split('\r\n')
    if "yes" in output[-1]:
        channel.send('yes\n')
        time.sleep(3)
        output = channel.recv(65536).decode().split('\r\n')
        if "password:" in output[-1]:
            channel.send('bobuWrUHk7Xq7WPpY9ZcjEi8zNdX3plZ+/y420RZ7W4=\n')
            time.sleep(4)
            output2 = channel.recv(65536).decode().split('\r\n')
            print(output2)
            channel.send('ssh 192.168.100.2\n')
            time.sleep(5)
            output2 = channel.recv(65536).decode().split('\r\n')
        if is_fdd and "~#" in output[-1] or not is_fdd and "~#" in output2[-1]:
            print("***start to check ru power****")
            length = len(command_list)
            print('length is:', length)
            for i in range(0, length):
                if not is_fdd:
                    channel.send("sudo " + command_list[i])
                else:
                    channel.send(command_list[i])
                time.sleep(2)
                TX_output = channel.recv(65536).decode().split('\r\n')
                print('tx_output is:', TX_output)
                print("****stop rsponse****")
                rf_power = findPowerStr(TX_output)
                print(('***rf_power is {}'.format(rf_power)))
                if rf_power is None:
                    power_vlaue_list_0.append("RF power NOT checked")
                    power_vlaue_list.append("RF power NOT checked")
                    result_list.append("True")
                else:
                    power_vlaue_list_0.append(rf_power)
                    print(('***power_vlaue_list is {}'.format(power_vlaue_list_0)))
                    output = [str(i) for i in power_vlaue_list_0]
                    output = ''.join(output)
                    output = rf_power.split(",")
                    power_value = output[0].split("=")
                    print(('***power value is {}'.format(power_value)))
                    pattern = re.compile(r'^[-+]?[-0-9]\d*\.\d*|[-+]?\.?[0-9]\d*$')
                    result = pattern.match(power_value[1])
                    power_vlaue_list.append(power_value[1])
                    if result:
                        result_list.append("True")
                    else:
                        result_list.append("False")
    if not result_list:
        result_list = ["True", "True"]
        power_vlaue_list_0 = ["RF power NOT checked", "RF power NOT checked"]
        power_vlaue_list = ["RF power NOT checked", "RF power NOT checked"]
    print((power_vlaue_list, result_list))
    ssh_client.close()
    return power_vlaue_list, power_vlaue_list_0, result_list


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
        pod_name = (pod_list[i]['name']).split("-")[2]
        pod_name = pod_name + '_pod'
        pod_name_list.append(pod_name)
    print('pod name is:', pod_name_list)
    return pod_name_list


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
        if (result[i]["status"] == "CrashLoopBackOff"):
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
    print('mri_list is:', ', '.join(mri_list))
    print('command_list is:', (', ').join(command))
    for i in range(0, 2):
        mri_res1 = ssh.execute(command=command[0], connection=alias).strip().replace('"', '')
        print('MRI status:', mri_res1)
        if mri_res1 not in mri_list:
            BuiltIn().log('MRI status is "{}", not in allowed mri status list {}, \
recovery will be triggered by command "{}"'.format(mri_res1.strip(), ','.join(mri_list), command[1]), "WARN")
            recreate_ruproxy = ssh.execute(command=command[1], connection=alias)
            print('recreate_ruproxy result is: {}'.format(recreate_ruproxy))
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


def achieve_pod_info(command, alias):
    result = ssh.execute("{}".format(command), alias)
    lines = result.splitlines()
    header = get_result_header(lines)
    result = []
    for line in lines:
        item = get_pod_header_items(header, line)
        result.append(item)
    return result


def manage_service(cmd, verify_status, alias):
    try:
        output = ssh.execute(cmd, connection=alias, timeout='30')
        time.sleep(2)
        print('output of perform {} is: {}'.format(cmd, output))
        logger.info(f'output of perform {cmd} is:', output)
    except CommandOutputTimeoutError:
        print('CommandOutputTimeoutError occurred')
        output = ssh.execute(cmd, connection=alias, timeout='30')
        time.sleep(2)
    if re.search(verify_status, output):
        logger.info(f'{cmd} performed successfully')
        return True
    else:
        logger.warn(f'{cmd} performed failed: {output}')
        return False


def reinstall_rannic_sw_controller_on_OE(rannic_version, conn):
    result = False
    image_list = [
         'container-infra-local.artifactory-hz1.int.net.nokia.com/ran-nic-sw-controller',
         'container-infra-local.hzisoj70.china.nsn-net.net/ran-nic-sw-controller'
        ]
    uninstall_cmd = 'helm uninstall ran-nic-sw-controller -n ran-nic-sw-controller;\
kubectl delete crd rannicconfigs.rannic.nokia.com rannicnodeconfigs.rannic.nokia.com'
    for image in image_list:
        print(f'image is: {image}')
        uninstall_res = manage_service(uninstall_cmd, 'uninstalled|Release not loaded', conn)
        print(f'uninstall_res is: {uninstall_res}')
        if not uninstall_res:
            logger.debug('ran-nic-sw-controller uninstalled failed')
            return result
        install_cmd = 'helm install ran-nic-sw-controller --set image.registry={} -n ran-nic-sw-controller \
https://artifactory-espoo1.ext.net.nokia.com/artifactory/rcp-infra-local/ran-nic-sw-controller/{}.tgz'\
    .format(image, rannic_version)
        install_res = manage_service(install_cmd, 'STATUS: deployed', conn)
        print(f'install_res is: {install_res}')
        if not install_res:
            logger.debug('ran-nic-sw-controller installed failed')
            return result
        for i in range(0, 30):
            time.sleep(3)
            output = achieve_pod_info(command='kubectl get pod -n ran-nic-sw-controller', alias=conn)
            print('output is:', output, len(output))
            image_pull_backoff_occurred = False
            for j in range(0, len(output)):
                if 'ImagePull' in output[j]['status']:
                    image_pull_backoff_occurred = True
                    break
            if not image_pull_backoff_occurred:
                if (len(output) == sum(1 for pod in output if pod['status'] == 'Running')):
                    result = True
                    return result
            if image_pull_backoff_occurred:
                break
        if image_pull_backoff_occurred:
            print('ImagePullBackOff occurred, retry to install')
            time.sleep(15)
            continue
        return result


if __name__ == '__main__':
    ssh.connect_to(hostname='10.44.79.227', username='core', password='system123', alias='RM_alias')
    reinstall_rannic_sw_controller_on_OE('ran-nic-sw-controller-3.4.1-24r3', 'RM_alias')
