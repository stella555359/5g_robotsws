import logging
import os
import time

from SSHLibrary import SSHLibrary
from taf.transport.ssh import ssh

from common_result_error import RunResult, ClusterConnectionFailure

ssh = ssh()
sshlib = SSHLibrary()


def check_fail_keyword_on_error_if_needed(fail_on_error, result):
    if result.status != 0 and str(fail_on_error).lower() == "true":
        raise Exception('Command execution failed:' + str(result))


def execute_command(cmd, fail_on_error=False, conn=None, timeout='60'):
    try:
        ssh.send_command(cmd, connection=conn, timeout=timeout)
        result_stdout = ssh.read_output(connection=conn)
        result_stderr = ssh.read_error(connection=conn)
        result_status = ssh.get_exit_status(connection=conn)
        res = RunResult(stdout=result_stdout, stderr=result_stderr, status=result_status)
        logging.info(str(res))
        check_fail_keyword_on_error_if_needed(fail_on_error, res)
        return res
    except AttributeError:
        raise ClusterConnectionFailure('Ssh connection to cluster does not work.')


def start_wireshark_log(pod_name, namespace, container_name, conn, protocol, interface, timeout="10"):
    pod_prefix = "po-" + namespace
    container_prefix = "ctr-" + namespace
    start_cmd = (
            "kubectl exec -it " + pod_prefix + "-" + pod_name + "-0" + " -n " + namespace + " -c " +
            container_prefix + "-" + container_name + " -- tcpdump -i " + interface + " " +
            protocol + " -s 0 -w " + "/tmp/" + namespace + "_" + container_name + "_wireshark.pcap")

    print(start_cmd)
    output = ssh.send_command(start_cmd, connection=conn, timeout=timeout)
    print(output)


def stop_wireshark(pod_name, namespace, container_name='nwmgmt', conn=None, timeout="10"):
    pod_name = "po-" + namespace + "-" + pod_name + "-0"
    container_full_name = "ctr-" + namespace + "-" + container_name
    tool_name = "tcpdump"
    stop_cmd_1 = ("kubectl exec " + pod_name + " -n " + namespace + " -c " +
                  container_full_name + " -- pkill -f " + tool_name)
    print(stop_cmd_1)
    output = execute_command(cmd=stop_cmd_1, conn=conn, timeout=timeout)
    print("stop_cmd_1 result:\n", output)
    stop_cmd_2 = ("ps -ef|grep " + tool_name +
                  " |grep " + pod_name +
                  " |grep -v grep|awk '{print $2}'|xargs -r kill -9")
    print(stop_cmd_2)
    output = execute_command(cmd=stop_cmd_2, conn=conn, timeout=timeout)
    print("stop_cmd_2 result:\n", output)


def download_wireshark_log_to_master_with_gzip(pod_name, namespace, container_name, tmp_log_dir, conn=None,
                                               timeout="10"):
    pod_prefix = "po-" + namespace
    container_prefix = "ctr-" + namespace
    tmp_log_dir = tmp_log_dir.rstrip("/") + "/"
    log_name = namespace + "_" + container_name + "_wireshark.pcap"
    remote_log_dir = tmp_log_dir + log_name
    if os.path.isfile(remote_log_dir):
        rm_cmd = ("rm -rf " + tmp_log_dir)
        output = execute_command(cmd=rm_cmd, conn=conn, timeout=timeout)
    copy_cmd = ("kubectl exec " + "-n " + namespace + " " + pod_prefix + "-" + pod_name + "-0 " +
                " -c " + container_prefix + "-" + container_name +
                " -- /bin/gzip -c " + "/tmp/" + log_name + " |gunzip >" + remote_log_dir)
    print(copy_cmd)
    output = execute_command(cmd=copy_cmd, conn=conn, timeout=timeout)
    print(output)
    time.sleep(5)
    result = check_file_exist(remote_log_dir)
    print(result)
    return remote_log_dir


def check_file_exist(filename):
    if not os.path.isfile(filename):
        logging.info("%s not found." % filename)
        return False
    return True
