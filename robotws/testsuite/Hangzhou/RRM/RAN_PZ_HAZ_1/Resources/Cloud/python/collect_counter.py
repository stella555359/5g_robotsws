# -*- coding: utf-8 -*-
"""
Author: Yang Mengli
Contacts: mengli.yang@nokia-sbell.com
Description: this script is used for collect PM counter
with check status of all pods

"""

from taf.transport.ssh import ssh
from SSHLibrary import SSHLibrary
import logging
import time
import os
import gzip
from lxml import etree
from command_result import RunResult, ClusterConnectionFailure, TimeoutError

ssh = ssh()
SSHLibrary = SSHLibrary()
BufSize = 1024 * 8


def master_connect(hostname, username, password, port="22", alias="master", timeout="10"):
    """
    This keyword is used to connect to vdu/vcu master
    *Args:*
        - _ip_: k8s master ip address(mandatory)
        - _user_: user name of k8s master (mandatory)
        - _password_: password of user (mandatory)
        - _port_: k8s master ssh port
        - _timeout_: timeout of login, default is 10s

    *Command:*  None
    *Returns:*
        - connection alias
    *Example:*
    | master_connect | 10.71.174.254 | user |  password  | 22 |
     """
    conn = ssh.connect_to(hostname=hostname, username=username, password=password, port=port, alias=alias,
                          timeout=timeout)
    return conn


def master_close(alias='master'):
    """
    This keyword is used to close vdu master
    *Command:*  None
    *Returns:*
        - None
    *Example:*
    | vdu_master_close |  |
     """
    ssh.disconnect(connection=alias)


def connect_to_container(master_ip, username, password, pod_name, container_name, namespace):
    """
    *Args:*
        - master_ip: the OE20 cluster ip
        - username: the username that used to login master, it should be tenant username
        - password: the password that used to login master, it should be tenant username
        - pod_name: the pod name that container belongs to
        - container_name: the container name that you want to login

    *Command:* ``kubectl exec -it <pod_name> -c <container_name> -- bash``

    *Returns:*

    *Example:*

    """
    SSHLibrary.set_default_configuration(timeout=20)
    SSHLibrary.open_connection(master_ip, prompt='REGEXP:~]\\$')
    res = SSHLibrary.login(username, password, delay='5s')
    SSHLibrary.set_client_configuration(prompt='REGEXP:(bash.*\\$)|#')
    log_cmd = 'kubectl exec -it {} -c {} -n {} -- bash'.format(pod_name, container_name, namespace)
    # print log_cmd
    SSHLibrary.write(log_cmd)
    res = SSHLibrary.read_until_prompt()
    return res


def disconnect_from_container():
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
    sshlib.close_connection()


def execute_command_in_container(cmd='', prompt=""):
    """
        *Args:*
            - cmd: the command you want to execute
            - prompt: the prompt after the command executed

        *Command:*

        *Returns:none

        *Example:execute_command_in_container(cmd,prompt)

        """
    try:
        print(SSHLibrary.read())
    except Exception:
        pass
    if prompt is None or prompt == "":
        prompt = "bash.*\\$|#"

    SSHLibrary.write(cmd)
    try:
        ret = ''
        ret = SSHLibrary.read_until_regexp(prompt)
        return ret
    except Exception as e:
        print(e)


def download_all_pm_file_to_master(pod_name, namespace, container_name, tmp_log_dir, pod_prefix="po-cran1",
                                   container_prefix="ctr-cran1", conn=None, timeout="60"):
    """
        *Args:*
            - namespace: the tenant namespace which pod created in
            - pod_name: see `collect log in which pod `
            - container_name: see `collect log in which container `

        *Command:* `` kubectl cp -n cran1 po-cran1-up-0:/tmp/l1bipl1.pcap /tmp/dpdk/l1bipl1.pcap -c ctr-cran1-l1hi``

        *Returns:*
            - output

        *Example:*
        | ${remote_log_dir} | download_bip_log_to_master | pod_name=${pod_name} | namespace=${ns} |
        | container_name=${container_name} | tmp_log_dir=/tmp/pm/ | pod_prefix=${pod_prefix} |
        | container_prefix=${container_prefix} | conn=${conn} | timeout=${timeout} |
        """
    tar = "cd /mnt/services/SS_OAM/PMSTAT/pm_report_files/ && tar cvf pm.tar " \
          "/mnt/services/SS_OAM/PMSTAT/pm_report_files/"
    print(tar)
    execute_command_in_container(cmd=tar)
    tmp_log_dir = tmp_log_dir.rstrip("/") + "/"
    cmd1 = ("cd /tmp; rm -rf pm; mkdir pm")
    print(cmd1)
    output = ssh.send_command(cmd1, connection=conn, timeout=timeout)
    print(output)
    time.sleep(10)
    cmd2 = (
            "kubectl exec " + pod_prefix + "-" + pod_name + "-0" + " -c " + container_prefix + "-" +
            container_name + " -n " + namespace +
            " -- cat /mnt/services/SS_OAM/PMSTAT/pm_report_files/"
            "pm.tar > " + tmp_log_dir + "pm.tar")
    print(cmd2)
    output = ssh.send_command(cmd2, connection=conn, timeout=timeout)
    print(output)
    time.sleep(300)
    chmod_cmd = ("chmod -R 777 /tmp/pm/pm.tar")
    print(chmod_cmd)
    output = ssh.send_command(chmod_cmd, connection=conn, timeout=timeout)
    remote_log_dir = tmp_log_dir + "pm.tar"
    return remote_log_dir


def remove_pm_report_in_pm_container(master_ip, username, password, pod_name, container_name, namespace):
    """
        *Args:*
            - namespace: the tenant namespace which pod created in
            - pod_name: see `collect log in which pod `
            - container_name: see `collect log in which container `

        *Command:* `` kubectl cp -n cran1 po-cran1-up-0:/tmp/l1bipl1.pcap /tmp/dpdk/l1bipl1.pcap -c ctr-cran1-l1hi``

        *Returns:*
            - output

        *Example:*
        | ${remote_log_dir} | download_bip_log_to_master | pod_name=${pod_name} | namespace=${ns} |
        | container_name=${container_name} | tmp_log_dir=/tmp/pm/ | pod_prefix=${pod_prefix} |
        | container_prefix=${container_prefix} | conn=${conn} | timeout=${timeout} |
        """
    full_pod_name = "po-" + namespace + "-" + pod_name + "-0"
    full_container_name = "ctr-" + namespace + "-" + container_name
    connect_to_container(master_ip, username, password, pod_name=full_pod_name, container_name=full_container_name,
                         namespace=namespace)
    rm = "cd /var/opt/nokia/performancemanagement/storage/results/ && rm -rf *"
    logging.info(str(rm))
    execute_command_in_container(cmd=rm)
    disconnect_from_container


def vm_connect(hostname, username, password, port="22", alias=None, timeout="10"):
    """
    This keyword is used to connect to vdu master
    *Args:*
        - _ip_: k8s master ip address(mandatory)
        - _user_: user name of k8s master (mandatory)
        - _password_: password of user (mandatory)
        - _port_: k8s master ssh port
        - _timeout_: timeout of login, default is 10s

    *Command:*  None
    *Returns:*
        - connection alias
    *Example:*
    | vm_connect | 10.108.229.191 | user |  password  | 22 |
     """
    conn = ssh.connect_to(hostname=hostname, username=username, password=password, port=port, alias=alias,
                          timeout=timeout)
    return conn


def vm_close(alias=None):
    """
    This keyword is used to close vdu master
    *Command:*  None
    *Returns:*
        - None
    *Example:*
    | vm_close |
     """
    ssh.disconnect(connection=alias)


def download_pm_file_to_vm(conn, remote_path='/tmp/pm/pm.tar', local_path='/tmp/pm.tar'):
    ssh.download_file(remote_path=remote_path, local_path=local_path, connection=conn)
    time.sleep(10)


def tar_pm_file(hostname, username, password, local_path='/tmp/pm.tar', alias=None, timeout="60"):
    vm_conn = vm_connect(hostname, username, password, alias)
    # now_time = datetime.datetime.now().strftime("%Y-%m-%d_%H_%M_%S")
    # print(now_time)
    chmod_cmd = ("tar xvf " + local_path)
    # chmod_cmd = ("cd /tmp/ && tar zxvf /tmp/pm.tar")
    print(chmod_cmd)
    logging.info(str(chmod_cmd))
    # ssh.send_command(chmod_cmd, connection=vm_conn, timeout=timeout)
    output = execute_command(cmd=chmod_cmd, conn=alias, timeout=timeout)
    print(output)
    time.sleep(120)
    vm_close(alias=None)


def _fail_keyword_on_error_if_needed(fail_on_error, result):
    if result.status != 0 and str(fail_on_error).lower() == "true":
        raise Exception('Command execution failed:' + str(result))


def remove_pm_file_in_ute(hostname, username, password, alias=None, timeout="60"):
    vm_conn = vm_connect(hostname, username, password, alias)
    chmod_cmd = ("cd /tmp/ && rm -f pm.tar && rm -rf /tmp/var")
    print(chmod_cmd)
    logging.info(str(chmod_cmd))
    ssh.send_command(chmod_cmd, connection=alias, timeout=timeout)
    time.sleep(10)
    vm_close(alias)


def execute_command(cmd, fail_on_error=False, conn=None, timeout='60'):
    """
    This keyword executes command on remote cluster.

    *Args:*
        - _cmd_: command to execute (mandatory)
        - _fail_on_error_: see `Failing on command execution errors`
        - _conn_: connection which returned from helm_master_connect
        - _timeout_: timeout of

    *Returns:*
        - `result object` with command execution results
    """
    try:
        # cmd = "source /etc/profile && source ~/.bash_profile && " + cmd
        # print(cmd)
        ssh.send_command(cmd, connection=conn, timeout=timeout)
        result_stdout = ssh.read_output(connection=conn)
        result_stderr = ssh.read_error(connection=conn)
        result_status = ssh.get_exit_status(connection=conn)
        res = RunResult(stdout=result_stdout, stderr=result_stderr, status=result_status)
        logging.info(str(res))
        _fail_keyword_on_error_if_needed(fail_on_error, res)
        return res
    except AttributeError:
        raise ClusterConnectionFailure('Ssh connection to cluster does not work.')


def collect_counter_to_ute(master_ip, username, password,
                           vm_hostname, vm_username, vm_password, namespace,
                           pod_prefix, container_prefix, container_name, pod_name,
                           tmp_log_dir, local_path='/tmp/pm.tar'):
    pm_pod_name = pod_prefix + "-" + pod_name + "-0"
    pm_container_name = container_prefix + "-" + container_name
    res = connect_to_container(master_ip=master_ip, username=username, password=password,
                               pod_name=pm_pod_name, container_name=pm_container_name, namespace=namespace)
    print(res)
    conn = master_connect(hostname=master_ip, username=username, password=password, alias="master")
    remote_log_dir = download_all_pm_file_to_master(pod_name=pod_name, namespace=namespace,
                                                    container_name=container_name, tmp_log_dir=tmp_log_dir,
                                                    pod_prefix=pod_prefix, container_prefix=container_prefix,
                                                    conn="master")
    print(remote_log_dir)
    download_pm_file_to_vm(conn="master", local_path=local_path)
    master_close(alias="master")
    tar_pm_file(hostname=vm_hostname, username=vm_username, password=vm_password, alias=None)


def get_measurement_report_start_time(pod_name, container_name, namespace, alias, mea_interval):
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


def get_measurement_report_stop_time(start, interval):
    """
        this keyword is used to get the interval stop time base on start
        time, the minutes part shall as '0', '5' suffix. for example, if start time is
        2009-06-06T13:30:33.3428342+08:00, and interval is 5, the result is
        2009-06-06T13:35:33.3428342+08:00.

        | Parameters | Man. | Description                                                     |
        | start      | Yes  | Specify the start time in 2009-06-06T13:35:00.000+08:00 format. |
        | interval   | Yes  | Specify the interval time in minutes.                           |

        *RETRUN VALUE*
        | Return Value | The tidied time base on start time and interval |

        *EXAMPLE*
        | get_measurement_report_stop_time | ${start} | ${interval} |
        """

    if len(start) != 29:
        return

    # Get the components of the start time
    year = start[0:4]
    month = start[5:7]
    day = start[8:10]
    hour = start[11:13]
    min = start[14:16]
    sec = start[17:19]
    other = start[19:]

    # Caculate the time.
    d = datetime.datetime(int(year),
                          int(month),
                          int(day),
                          int(hour),
                          int(min),
                          int(sec))
    d1 = d + datetime.timedelta(minutes=int(interval))

    # Generate the time in specific format.
    ret = "{:0>4d}-{:0>2d}-{:0>2d}T{:0>2d}:{:0>2d}:{:0>2d}{}".format(d1.year, d1.month,
                                                                     d1.day, d1.hour,
                                                                     d1.minute, d1.second,
                                                                     other)

    return ret.strip()


def general_measurement_file_name(start, stop, file_suffix, f_type='A'):
    """
    this keyword is used to generate the measurement result file name

    | Parameters | Man. | Description                                                     |
    | start      | Yes  | Point out which period the statistic result file belongs to.        |
    | stop       | Yes  | Point out the Granularity Period End Time, format like period_begin |
    | file_suffix | Yes | report file suffix |
    | f_type     | Yes  | Point out the file type: A, B, C or D                               |

    *RETRUN VALUE*
    | Return Value | Measurement Report File Name |

    """

    fmt_start = _time_format_change(start)
    fmt_stop = _time_format_change(stop)

    """The format is:
    <Type><Startdate>.<Starttime>-[<Enddate>].<Endtime>_[<UniqueId][:<RC>]
    """
    file_name = "{}{}-{}_{}".format(f_type.strip(), fmt_start.strip(), fmt_stop.strip(),
                                    file_suffix.strip())
    return file_name.strip()


def parse_pm_result_xml_file(file_name):
    counter_values_all_mo = {}
    root = etree.parse(file_name).getroot()
    for pmmo in root.iter('PMMOResult'):
        counter_values_one_mo = {}
        mo = pmmo.find('MO')
        dist_name = mo.find('DN').text
        print(dist_name)
        dn = mo.find('DN').text.strip().split('/')[-1]
        print(dn)
        pmtarget = pmmo.find('PMTarget')
        for counter in pmtarget:
            counter_values_one_mo[counter.tag] = counter.text.strip()
        counter_values_all_mo[dn] = counter_values_one_mo
    return counter_values_all_mo[dn], dist_name


def list_all_files_with_path(files_path):
    files_list = []
    list_file = os.listdir(files_path)
    print(list_file)
    for i in range(0, len(list_file)):
        path = os.path.join(files_path, list_file[i])
        print(path)
        if os.path.isdir(path):
            files_list.extend(list_all_files(path))
            print(files_list)
        if os.path.isfile(path) and "xml" in list_file[i]:
            files_list.append(path)
            print(files_list)
    return files_list


def list_all_files(files_path):
    files_list = []
    list_files = os.listdir(files_path)
    print(list_files)
    return list_files


def get_pm_value(counter_list='M55311C44007', files_path='/tmp/var/opt/nokia/performancemanagement/storage/results',
                 output_path="/tmp/pm/"):
    files_list = list_all_files_with_path(files_path)
    if not os.path.exists(output_path):
        os.makedirs(output_path)
    for file in files_list:
        f_name = file.replace(".gz", "")
        path = os.path.join(output_path, f_name)
        gunZipFile(file, path)
    # counter_value_list = []
    # all_counter_value_list= []
    # counter_value_list1 = []
    counter_dic = {}
    counter_mo_dic = {}
    all_counter_dic = {}
    for file_path in files_list:
        counter_values_all_mo, dist_name = parse_pm_result_xml_file(file_name=file_path)
        print(counter_values_all_mo)
        for counter in counter_list:
            for k, v in counter_values_all_mo.items():
                if k == counter:
                    dic = {k: v}
                    counter_dic.update(dic)
            counter_mo_dic.update(counter_dic)
    all_counter_dic.update(counter_mo_dic)
    return all_counter_dic


def gunZipFile(gzFile, dst):
    fin = gzip.open(gzFile, 'rb')
    fout = open(dst, 'wb')
    in2out(fin, fout)


def in2out(fin, fout):
    while True:
        buf = fin.read(BufSize)
        if len(buf) < 1:
            break
        fout.write(buf)
    fin.close()
    fout.close()


def counter_piid_generator(start_id, stop_id, step=1):
    """
    this function is used to generate counter PI Id generator object

    Parameters:
    start_id(str): start value of the counter PI Id sequence
    stop_id(str): end value of the counter PI Id sequence
    step(int): denoting the difference between any two numbers in the sequence.

    Return: Returns a generator object.
    """
    start_measurement_id = start_id.split('C')[0]
    stop_measurement_id = stop_id.split('C')[0]
    if start_measurement_id != stop_measurement_id:
        raise Exception('The measurement id of start counter PI Id is not equal to the stop one. '
                        'Please check the input value!')

    start_id = int(start_id.split('C')[1])
    stop_id = int(stop_id.split('C')[1])

    for i in range(start_id, stop_id + 1, step):
        counter_id = '{:0>5d}'.format(i)
        counter_piid = start_measurement_id + 'C' + counter_id

        yield counter_piid
