# -*- coding: utf-8 -*-


import re
from taf.ul.vdu.helm import helm
import time
import logging
from SSHLibrary import SSHLibrary
import json
from taf.transport.ssh import ssh


def get_vdu_pods_name_list(namespace='all', fail_on_error=False, conn=None):
    """
        *Args:*
            - namespace: the tenant namespace which pod created in
            - fail_on_error: see `Failing on command execution errors`

        *Command:* ``kubectl get pods -n <namespace>``

        *Returns:*
            - pod name list that deployed in one namespace

        *Example:*
        | ${pod_name_list} | get_vdu_pods_name_list | cran1
        """
    if namespace != '' and 'all' not in namespace:
        namespace = '-n ' + namespace
    elif 'all' in namespace:
        namespace = '--all-namespaces'
    cmd = 'kubectl get pods ' + namespace
    output = helm().execute_command_on_master_cluster(cmd, fail_on_error, conn=conn).stdout
    if 'No resources found' in output:
        logging.warning('No any pods found in the current namespace')
        return None
    pods_name_list = []
    lines = output.strip().splitlines()
    lines.pop(0)
    for line in lines:
        pods_name_list.append(line.split()[0].strip())
    return pods_name_list


def get_vdu_pv_list(namespace, fail_on_error=True, conn=None):
    cmd = 'kubectl get pv |grep ' + namespace
    output = helm().execute_command_on_master_cluster(cmd, fail_on_error, conn=conn).stdout
    pv_name_list = []
    lines = output.strip().splitlines()
    for line in lines:
        pv_name_list.append(line.split()[0].strip())
    return pv_name_list


def get_vdu_containers_status(pod_name='all', namespace='--all-namespaces', fail_on_error=False, conn=None):
    """
    *Args:*
        - pod_name: the pod name that containers existed (mandatory)
        - namespace: the tenant namespace which pod created in
        - fail_on_error: see `Failing on command execution errors`

    *Command:* ``kubectl describe pods <pod_name> -n <namespace>``

    *Returns:*
        - each container status as a dict

    *Example:*
    | ${container_status} | get_containers_status | vdu-pod-0 | cran1
    """
    all_containers_status = {}
    if 'all' in pod_name:
        pods_list = get_vdu_pods_name_list(namespace)
        if pods_list:
            for pod_name in pods_list:
                status = _get_containers_status(pod_name, namespace)
                all_containers_status[pod_name] = status
    else:
        status = _get_containers_status(pod_name, namespace)
        all_containers_status[pod_name] = status
    return all_containers_status


def _get_containers_status(pod_name, namespace, fail_on_error=False, conn=None):
    if namespace != '' and 'all' not in namespace:
        namespace = '-n ' + namespace
    elif 'all' in namespace:
        namespace = '--all-namespaces'
    command = "kubectl get pod %s %s --output=json" % (pod_name, namespace)
    result = helm().execute_command_on_master_cluster(command, fail_on_error, conn=conn)
    pod_info_json = result.stdout
    return parse_one_pod_container_status_from_json_string(pod_info_json)


def parse_one_pod_container_status_from_json_string(pod_json_str):
    one_pod_container_status = dict()
    pod_info_dict = json.loads(pod_json_str)
    if re.findall('initContainerStatuses', pod_json_str):
        init_container_dict = pod_info_dict['status']['initContainerStatuses'][0]
        init_state = list(init_container_dict['state'].keys())[0]
        init_started_time = init_container_dict['state'][list(init_container_dict['state'].keys())[0]]['startedAt']
        one_pod_container_status.update({init_container_dict['name']: [init_state, init_started_time]})
        status_dict = pod_info_dict['status']['containerStatuses']
        status_dict_len = len(status_dict)
        for i in range(status_dict_len):
            tdict = status_dict[i]
            tdict_state = list(tdict['state'].keys())[0]
            tdict_started_time = tdict['state'][list(tdict['state'].keys())[0]]['startedAt']
            one_pod_container_status.update({tdict['name']: [tdict_state, tdict_started_time]})
    else:
        status_dict = pod_info_dict['status']['containerStatuses']
        status_dict_len = len(status_dict)
        for i in range(status_dict_len):
            tdict = status_dict[i]
            tdict_state = list(tdict['state'].keys())[0]
            tdict_started_time = tdict['state'][list(tdict['state'].keys())[0]]['startedAt']
            one_pod_container_status.update({tdict['name']: [tdict_state, tdict_started_time]})
    return one_pod_container_status


def get_datatime_to_timestamp(datetime):
    """
    Author:   tina.luo@nokia-sbell.com
    *Args:*
        - datetime: datetime eg:2020-06-29T06:16:41Z
    *Returns:*
       -  timestamp: timestamp eg:1593382601.0
    *Example:*
    | ${timestamp} | get_datatime_to_timestamp  | datetime |
    """
    timestamp = time.mktime(time.strptime(datetime, '%Y-%m-%dT%H:%M:%SZ'))
    return timestamp


def wait_vdu_delete(fail_on_error=False, conn=None):
    """
    Author:   tina.luo@nokia-sbell.com
    *Args:*
        - fail_on_error: see `Failing on command execution errors`
    *Returns:*
       -  output.stdout: pod state
    *Example:*
    | ${output} | wait_vdu_delete |
    """
    count = 0
    while True:
        cmd = 'kubectl get pod'
        output = helm().execute_command_on_master_cluster(cmd, fail_on_error, conn=conn)
        if output.stderr:
            result = 'undeploy done!'
            break
        else:
            time.sleep(2)
            count = count + 1
            if count > 50:
                raise Exception('vdu can not be deleted')
    return output.stdout


def get_vdu_pvc_info(namespace='', fail_on_error=False, conn=None):
    """
    Author:   tina.luo@nokia-sbell.com
    *Args:*
        - namespace: the tenant namespace which pod created in
        - _fail_on_error_: see `Failing on command execution errors`
    *Command:*  ``kubectl get pvc``
    *Returns:*
        - `each tenant config pvc capacity as a dict
        {['capacity':'capacity_1', 'name':'pvc_1'],
         ['capacity':'capacity_2', 'name':'pvc_2']
        }
    *Example:*
    | ${result} | get vdu pvc info |  namespace  |
    """
    if namespace != '' and 'all' not in namespace:
        namespace = '-n ' + namespace
    elif 'all' in namespace:
        raise Exception('namespace should not be empty or all')
    cmd = 'kubectl get pvc ' + namespace
    output = helm().execute_command_on_master_cluster(cmd, fail_on_error, conn=conn).stdout
    return _get_vdu_pvc_capacity_info(output)


def _get_vdu_pvc_capacity_info(output):
    lines = output.splitlines()
    header = _get_namespace_result_header(lines)
    result = []
    for line in lines:
        if len(line.split()) < 3:
            continue
        item = {}
        item["name"] = line[header.index("NAME"): header.index("STATUS")].strip()
        item["capacity"] = line[header.index("CAPACITY"): header.index("ACCESS MODES")].strip()
        result.append(item)
    return result


def get_vdu_pvc_describe_info(namespace='', fail_on_error=False, conn=None):
    """
    Author:   tina.luo@nokia-sbell.com
    *Args:*
        - namespace: the tenant namespace which pod created in
        - _fail_on_error_: see `Failing on command execution errors`
    *Command:*  ``kubectl get pvc describe info``
    *Returns:*
        -  detail PVC shown  in this namespace
    *Example:*
    | ${result} | get vdu pvc describe info |  namespace  |
    """
    if namespace != '' and 'all' not in namespace:
        namespace = '-n ' + namespace
    elif 'all' in namespace:
        raise Exception('namespace should not be empty or all')
    cmd = 'kubectl describe pvc ' + namespace
    output = helm().execute_command_on_master_cluster(cmd, fail_on_error, conn=conn).stdout
    return output


def get_vdu_tenant_config_vlan_id_range(fail_on_error=False, conn=None):
    """
    Author:   tina.luo@nokia-sbell.com
    *Args:*
        - _fail_on_error_: see `Failing on command execution errors`
    *Command:*  ``kubectl get tc``
               ``kubectl describe tc <TENANT_CONFIG_NAME>``
    *Returns:*
        - `each tenant config vlan id range as a dict
        {'vni_name_1': ['vlan_id_1_start', 'vlan_id_1_end'],
        'vni_name_1': ['vlan_id_2_start', 'vlan_id_2_end']
        }
    *Example:*
    | ${result} | get vdu tenant config vlan id range |
    """
    cmd = 'kubectl get tc'
    output = helm().execute_command_on_master_cluster(cmd, fail_on_error, conn=conn)
    lines = output.stdout.splitlines()
    header = lines.pop(0)
    result = lines[0][header.index("NAME"): header.index("AGE")].strip()
    return _get_config_vlan_id_range(result)


def _get_config_vlan_id_range(result, fail_on_error=False, conn=None):
    cmd = 'kubectl describe tc ' + result
    output = helm().execute_command_on_master_cluster(cmd, fail_on_error, conn=conn)
    res = re.findall('\\sName:.*?Vni Type:', output.stdout, re.DOTALL)
    vlan_range = {}
    for res_vlan in res:
        vlan_name = re.search(':.*\n', res_vlan).group(0)[1:].strip()
        res_range = []
        res_range.append(re.search('\\s\\d+', res_vlan).group(0)[1:])
        res_range.append(re.search('\\-\\d+', res_vlan).group(0)[1:])
        vlan_range[vlan_name] = res_range
    return vlan_range


def get_vdu_configmap_ip_pool_info(fail_on_error=False, conn=None):
    """
    Author:   tina.luo@nokia-sbell.com
    *Args:*
        - _fail_on_error_: see `Failing on command execution errors`
    *Command:*  ``kubectl get cm``
               ``kubectl get cm <CONFIG_MAP> -o json``
    *Returns:*
        - `each configmap IP pool range as a dict
        {'oamcp': {'f1:[end_ip,start_ip,subnet]', ... },
        'up': {'f1:[end_ip,start_ip,subnet]', ...}
        }
    *Example:*
    | ${result} |  get vdu configmap ip pool info |
    """
    cmd = 'kubectl get cm'
    output = helm().execute_command_on_master_cluster(cmd, fail_on_error, conn=conn)
    results = output.stdout.splitlines()
    return _get_configmap_ip_pool_info(results, fail_on_error, conn)


def _get_configmap_ip_pool_info(lines, fail_on_error=False, conn=None):
    header = lines.pop(0)
    result = {}
    interface_list = ['f1', 'fhm', 'oam']
    for line in lines:
        item = line[header.index("NAME"): header.index("DATA")].strip()
        cmd = 'kubectl get cm ' + item + ' -o json'
        output = helm().execute_command_on_master_cluster(cmd, fail_on_error, conn=conn)
        if 'network-init' in output.stdout:
            cm_info_dict = json.loads(output.stdout)
            cm_network_info = cm_info_dict['data']['network-init']
            cm_name = item.split('-')[0]
            result_cm = {}
            for interface in interface_list:
                if interface in cm_network_info:
                    result_interface = []
                    r1 = ':[\\s\\S]*?(\\s*)(.*)[\\s\\S]*?(\\s*)(.*)[\\s\\S]*?(\\s*)(.*)[\\s\\S]*?(\\s*)(.*)[\\s\\S]*?'
                    r = '' + interface + '' + r1 + ''
                    cm_info = re.search(r, cm_network_info).group(0)
                    result_interface.append(re.search('start:.*', cm_info).group(0).strip()[8:-1])
                    result_interface.append(re.search('end:.*', cm_info).group(0).strip()[6:-1])
                    result_interface.append(re.search('subnet:.*', cm_info).group(0).strip()[9:-1])
                    result_cm[interface] = result_interface
            result[cm_name] = result_cm
    return result


def IP_should_in_network_segment(config_ip, ip_start, ip_end):
    """
    Author:   tina.luo@nokia-sbell.com
    *Args:*
        - _fail_on_error_: see `Failing on command execution errors`
    *Command:*  `` ``
    *Returns:*
        - ``  ``
         *Example:*
    | ${result} | get vdu tenant config vlan id range |
    """
    ip_list_1 = [ip_start, config_ip, ip_end]
    ip_list_2 = []
    for ip in ip_list_1:
        list_ip = ip.split('.')
        list_binary = []
        for item in list_ip:
            item = bin(int(item))
            item = item[2:]
            list_binary.append(item.zfill(8))
        ip_binary = int(''.join(list_binary), base=2)
        ip_list_2.append(ip_binary)
    if not (ip_list_2[0] <= ip_list_2[1] <= ip_list_2[2]):
        raise AssertionError("'%s' should be in network segment " % config_ip)


def get_vdu_containers_memory_usage(pod_name='all', memory_type='Requests',
                                    namespace='--all-namespaces', fail_on_error=False, conn=None):
    """
    *Args:*
        - pod_name: the pod name that containers existed (mandatory)
        - namespace: the tenant namespace which pod created in
        - memory_type: which type of the memory want to check, normal include 'Requests' and 'Limits' two types
        - fail_on_error: see `Failing on command execution errors`

    *Command:* ``kubectl describe pods <pod_name> -n <namespace>``

    *Returns:*
        - each container memory usage as a dict

    *Example:*
    | ${container_status} | get_vdu_containers_memory_usage | vdu-pod-0 | cran1
    """
    all_containers_memory = {}
    if 'all' in pod_name:
        pods_list = get_vdu_pods_name_list(namespace)
        if pods_list:
            for pod_name in pods_list:
                memory = _get_containers_memory_usage(pod_name, memory_type, namespace)
                all_containers_memory[pod_name] = memory
    else:
        memory = _get_containers_memory_usage(pod_name, memory_type, namespace)
        all_containers_memory[pod_name] = memory
    return all_containers_memory


def _get_containers_memory_usage(pod_name, memory_type, namespace, fail_on_error=False, conn=None):
    if 'all-namespaces' not in namespace:
        namespace = '-n ' + namespace
    command = 'kubectl describe pods ' + pod_name + ' ' + namespace
    result = helm().execute_command_on_master_cluster(command, fail_on_error, conn=conn)
    pod_description = result.stdout
    one_pod_container_memory = dict()
    if 'oamcp' in pod_name:
        containers = ['oam', 'oamfh', 'cprt', 'rcpsdl', 'nwmgmt']
    if 'uprt' in pod_name:
        containers = ['l2rt', 'l2hi', 'l1hi', 'nwmgmt']
    for container in containers:
        if memory_type == 'Limits':
            pattern = "Containers:.*?{}:.*?Limits:.*?memory:\\s+(.*?)\\s+".format(container)
        elif memory_type == 'Requests':
            pattern = "Containers:.*?{}:.*?Requests:.*?memory:\\s+(.*?)\\s+".format(container)
        memory = re.search(pattern, pod_description, re.DOTALL).group(1)
        one_pod_container_memory[container] = memory
    return one_pod_container_memory


def get_vdu_pods_info(pod_name='all', namespace='', fail_on_error=False, conn=None):
    """
    *Args:*
        - pod_name: the pod name that containers existed (mandatory)
        - namespace: the tenant namespace which pod created in
        - fail_on_error: see `Failing on command execution errors`

    *Command:* ``kubectl get pods <pod_name> -n <namespace>``

    *Returns:*
        - each container status as a dict

    *Example:*
    | ${container_status} | get_containers_status | vdu-pod-0 | cran1
    """
    if namespace != '' and 'all' not in namespace:
        namespace = '-n ' + namespace
    elif 'all' in namespace:
        namespace = '--all-namespaces'
    if pod_name == 'all':
        command = 'kubectl get pods ' + namespace + ' -o wide'
    else:
        command = 'kubectl get pods ' + pod_name + ' ' + namespace + ' -o wide'
    output = helm().execute_command_on_master_cluster(command, fail_on_error, conn=conn).stdout
    return parse_output_with_ps_format_to_dict(output)


def parse_output_with_ps_format_to_dict(output):
    pods_info = {}
    keys = []
    if 'No resources found' in output:
        raise Exception('No pods found in the current environment')
    for line in output.splitlines():
        if not keys:
            if line.strip().startswith('NAME'):
                line = re.sub(r'(\S+) (\S+)', r"\g<1>_\g<2>", line).strip()
                keys.extend([key.lower().replace(" ", "_") for key in line.split()])
                continue
        items = line.split()
        if len(items) != len(keys):
            restarts_index = keys.index('restarts')
            if items[restarts_index] != 0:
                for i in len(keys), len(items):
                    items.pop(restarts_index+1)
            if len(items) != len(keys):
                raise Exception('No pods found in the current environment')
        pod_info = {}
        for i, key in enumerate(keys):
            pod_info[key] = items[i]
        if pod_info:
            pods_info[pod_info['name']] = pod_info
    return pods_info


def get_vdu_namespace_info(fail_on_error=False, conn=None):
    """
    Author:   jianlin.zhang@nokia-sbell.com
    *Args:*
        - _fail_on_error_: see `Failing on command execution errors`
    *Command:*  ``kubectl get namespace``

    *Returns:*
        - `each namespace status as a dict
        {'name':'ns_name_1','status':'active','age':'16d'},
         'ns_name_2':{'name':'ns_name_2','status':'active','age':'16d'}
        }

    *Example:*
    | ${result} | get namespace info |
    """
    cmd = 'kubectl get namespace'
    result = helm().execute_command_on_master_cluster(cmd, fail_on_error, conn=conn)
    return _get_parsed_namespace_dic_info(result.stdout)


def _get_parsed_namespace_dic_info(stdout_result):
    lines = stdout_result.splitlines()
    header = _get_namespace_result_header(lines)
    result = []
    for line in lines:
        if len(line.split()) < 3:
            continue
        item = _get_namespace_header_items(header, line)
        result.append(item)
    return result


def _get_namespace_result_header(stdout_lines):
    header = ""
    while True:
        header = stdout_lines.pop(0)
        if header.strip().startswith("NAME"):
            break
    return header


def _get_namespace_header_items(header, line):
    item = {}
    item["name"] = line[header.index("NAME"): header.index("STATUS")].strip()
    item["status"] = line[header.index("STATUS"): header.index("AGE")].strip()
    item["age"] = line[header.index("AGE"):].strip()
    return item


def parse_syscomroute_result(syscom_result):
    """
        *Args:*
            - syscom route result getted by syscomroute command

        *Command:* ``

        *Returns:*
            - syscom info dict

        *Example:*

        """
    syscom_info = {}
    keys = []
    # if 'No resources found' in syscom_result:
    #     return None
    lines = syscom_result.splitlines()
    lines.pop()
    lines.pop()
    for line in lines:
        if not keys:
            if line.strip().startswith('ID'):
                line = re.sub(r'(\S+) (\S+)', r"\g<1>_\g<2>", line).strip()
                keys.extend([key.lower().replace(" ", "_") for key in line.split()])
                continue
            else:
                continue
        if not line.startswith('---'):
            items = line.split()
            # if len(items) != len(keys):
            #     return None
            if items[0].isdigit():
                one_info = {}
                for i, key in enumerate(keys):
                    one_info[key] = items[i]
                if one_info:
                    syscom_info[one_info['id']] = one_info

    return syscom_info


def parse_ping_result(ping_result):
    """
        *Args:*
            - ping result getted by ping command

        *Command:* ``

        *Returns:*
            - the result of ping dict

        *Example:*

        """
    ping_status = {}
    keys = ['transmitted', 'received', 'loss', 'time']
    pa = '.*?(\\d+)\\s+packets transmitted,\\s+(\\d+)\\s+received,\\s+(.*?)\\spacket loss,\\s+time\\s+(\\d+)ms'
    res = re.search(pa, ping_result, re.DOTALL)
    if not res:
        raise Exception('search ping result failed')
    for i, key in enumerate(keys):
        ping_status[key] = res.groups()[i]
    return ping_status


def parse_container_network_info(network_info):
    """
        *Args:*
            - container network info getted by ifconfig

        *Command:* ``

        *Returns:*
            - network info dict

        *Example:*

        """
    network_info_dict = {}
    keys = ['status', 'ip', 'rx_packets', 'tx_packets']
    interface_list = ['eth0', 'f12', 'internal1', 'oam3', 'f16', 'fhm4']
    for interface in interface_list:
        tmp_dict = {}
        pa = '{}: flags=\\d*<(.*?)>.*?inet\\s+(.*?)\\s+.*?RX packets\\s+(\\d*)\\s+.*?TX packets\\s+(\\d*)\\s+'\
            .format(interface)
        res = re.search(pa, network_info, re.DOTALL)
        # if not res:
        #     raise Exception('can not get the interface info')
        if res:
            for i, key in enumerate(keys):
                tmp_dict[key] = res.groups()[i]
        # tmp_dict['status'] = res.group(1)
        # tmp_dict['ip'] = res.group(2)
        # tmp_dict['rx_packets'] = res.group(3)
        # tmp_dict['tx_packets'] = res.group(4)
            network_info_dict[interface] = tmp_dict
    return network_info_dict


def parse_node_id(ps_info):
    """
        *Args:*
            - ps info getted by ps -ef|grep nid command

        *Command:* ``

        *Returns:*
            - the node id

        *Example:*

        """
    res = re.search('=nid=(\\w+)\\s+', ps_info, re.DOTALL)
    if not res:
        raise Exception('search nid failed')
    return res.group(1)


sshlib = SSHLibrary()


def connect_to_container(master_ip, username, password, pod_name, container_name, namespace):
    """
    *Args:*
        - master_ip: the OE19 cluster ip
        - username: the username that used to login master, it should be tenant username
        - password: the password that used to login master, it should be tenant username
        - pod_name: the pod name that container belongs to
        - container_name: the container name that you want to login

    *Command:* ``kubectl exec -it <pod_name> -c <container_name> -- bash``

    *Returns:*

    *Example:*

    """
    sshlib.set_default_configuration(timeout=20)
    sshlib.open_connection(master_ip, prompt='REGEXP:~]\\$')
    res = sshlib.login(username, password, delay='5s')
    sshlib.set_client_configuration(prompt='REGEXP:(bash.*\\$)|#')
    log_cmd = 'kubectl exec -it {} -c {} -n {} -- bash'.format(pod_name, container_name, namespace)
    # print(log_cmd)
    sshlib.write(log_cmd)
    res = sshlib.read_until_prompt()
    return res


def exit_from_container():
    try:
        print(sshlib.read())
    except Exception:
        pass
    sshlib.write('exit')
    res = sshlib.read(delay="2s", loglevel="INFO")
    if "'exit' is not a valid command" in res:
        sshlib.write('quit')
        # ssh.read_until_regexp('bash-4.4#')
        sshlib.read_until_prompt()
        sshlib.write('exit')
        res = sshlib.read(delay="2s", loglevel="INFO")
    # if '~]$' not in res:
    #     raise RuntimeError('exit from container failed')
    sshlib.close_connection()


def execute_command_in_container(cmd='', prompt=""):
    """
        *Args:*
            - cmd: the command you want to execute
            - prompt: the prompt after the command executed

        *Command:*

        *Returns:*

        *Example:*

        """
    try:
        print(sshlib.read())
    except Exception:
        pass
    if prompt is None or prompt == "":
        prompt = "bash.*\\$|#"

    sshlib.write(cmd)
    # ret = ssh.read_until_regexp(prompt)
    try:
        ret = ''
        ret = sshlib.read_until_regexp(prompt)
        # ret = sshlib.read_until_prompt()
        return ret
    except Exception as e:
        print(e)


def get_container_cpu(pod_list):
    all_containers_cpu = {}
    if pod_list:
        for pod_name in pod_list:
            one_pod_container_cpu = dict()
            if 'oamcp' in pod_name:
                containers = ['nwinit', 'oam', 'oamfh', 'cprt', 'rcpsdl', 'nwmgmt']
            if 'uprt' in pod_name:
                containers = ['nwinit', 'l2rt', 'l2hi', 'l1hi', 'nwmgmt']
            command = 'kubectl describe po ' + pod_name
            result = helm().execute_command_on_master_cluster(command, fail_on_error=False, conn=None)
            pod_description = result.stdout
            for container in containers:
                pattern = "Containers:.*?{}:.*?Limits:.*?cpu:\\s+(.*?)\\s+".format(container)
                pattern1 = "Containers:.*?{}:.*?Requests:.*?cpu:\\s+(.*?)\\s+".format(container)
                status = re.search(pattern, pod_description, re.DOTALL).group(1)
                status1 = re.search(pattern1, pod_description, re.DOTALL).group(1)
                one_pod_container_cpu[container + 'Limits'] = status
                one_pod_container_cpu[container + 'Requests'] = status1
            all_containers_cpu[pod_name] = one_pod_container_cpu
    return all_containers_cpu


def generate_vdu_measurement_report_start_time(pod_name, container_name, namespace, alias, mea_interval):
    cmd_base = 'kubectl exec -it {pod} -c {container} -n {ns} -- '.format(
        pod=pod_name, container=container_name, ns=namespace)
    year_hour_cmd = cmd_base + 'bash -c "date +%Y-%m-%dT%H:"'
    min_cmd = cmd_base + 'bash -c "date +%M"'
    tz_cmd = cmd_base + 'bash -c "date +%:z"'
    # execute the command, and get the related time factors.
    year_hour = ssh().execute(year_hour_cmd, connection=alias)
    min = ssh().execute(min_cmd, connection=alias)
    tz = ssh().execute(tz_cmd, connection=alias)

    year_hour = re.search('(^\\d+-\\d+-\\d+T\\d+:)', year_hour, re.M).group(1).strip()
    min = re.search('(^\\d+)', min, re.M).group(1).strip()
    tz = re.search('(^\\+\\d+:\\d+)', tz, re.M).group(1).strip()
    min_num = int(min, 10)
    interval = int(mea_interval, 10)

    tidy_min = min_num - min_num % interval

    tidy_time = '{}{:0>2d}:00.000{}'.format(year_hour, tidy_min, tz)

    return tidy_time.strip()
