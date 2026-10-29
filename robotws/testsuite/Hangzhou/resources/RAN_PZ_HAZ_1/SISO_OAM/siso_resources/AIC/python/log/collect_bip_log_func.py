import logging
import os.path

from taf.transport.ssh import ssh

from common_result_error import RunResult, ClusterConnectionFailure

sshlib = ssh()
ssh = ssh()


def _fail_keyword_on_error_if_needed(fail_on_error, result):
    if result.status != 0 and str(fail_on_error).lower() == "true":
        raise Exception('Command execution failed:' + str(result))


def execute_command(cmd, fail_on_error=False, conn=None, timeout='60'):
    try:
        sshlib.send_command(cmd, connection=conn, timeout=timeout)
        result_stdout = cmd + ": " + sshlib.read_output(connection=conn)
        result_stderr = cmd + ": " + sshlib.read_error(connection=conn)
        result_status = sshlib.get_exit_status(connection=conn)
        res = RunResult(stdout=result_stdout, stderr=result_stderr, status=result_status)
        logging.info(str(res))
        _fail_keyword_on_error_if_needed(fail_on_error, res)
        return res
    except AttributeError:
        raise ClusterConnectionFailure('Ssh connection to cluster does not work.')


def download_bip_log_to_master(pod_name, namespace, container_name, tmp_log_dir, pod_prefix="po-cran1",
                               container_prefix="ctr-cran1", conn=None, timeout="100"):
    cmd_exec = "kubectl exec -i " + pod_prefix + "-" + pod_name + "-0" + " -c " + \
               container_prefix + "-" + container_name + " -n " + namespace + " -- bash " + "-c "
    cmd_cp = "kubectl cp " + "-n " + namespace + " " + pod_prefix + "-" + pod_name + "-0"
    cmd_cp_postfix = " -c " + container_prefix + "-" + container_name
    remote_log_dir = tmp_log_dir.rstrip("/") + "/"
    clear_master_log = "rm -r " + remote_log_dir + "*"
    execute_command(cmd=clear_master_log, conn=conn, timeout=timeout)
    # list bip log
    list_bip_log = cmd_exec + "'ls -alh /tmp/dpdkdump'"
    execute_command(cmd=list_bip_log, conn=conn, timeout=timeout)
    # rename a bip log to a specific name
    tem_bip_log_name = "tmp-bip.pcap"
    log_dir_in_container = ":tmp/dpdkdump/"
    cmd_part_1 = log_dir_in_container + tem_bip_log_name
    bip_log_path = os.path.join(remote_log_dir, tem_bip_log_name)
    cmd_rename = "'mv /tmp/dpdkdump/*.pcap /tmp/dpdkdump/{}'".format(tem_bip_log_name)
    rename_bip_log = cmd_exec + cmd_rename
    execute_command(cmd=rename_bip_log, conn=conn, timeout=timeout)
    # copy start_bip log
    start_bip_log_name = "start_bip.log"
    start_bip_log_path = os.path.join(remote_log_dir, start_bip_log_name)
    cmd_part_2 = log_dir_in_container + start_bip_log_name
    copy_start_bip_log = cmd_cp + cmd_part_2 + " " + start_bip_log_path + cmd_cp_postfix
    execute_command(cmd=copy_start_bip_log, conn=conn, timeout=timeout)
    # copy the bip log
    copy_bip_log = cmd_cp + cmd_part_1 + " " + bip_log_path + cmd_cp_postfix
    execute_command(cmd=copy_bip_log, conn=conn, timeout=timeout)
    # clear bip log in the pod
    clear_pod_log = cmd_exec + "'rm -r /tmp/dpdkdump/*'"
    execute_command(cmd=clear_pod_log, conn=conn, timeout=timeout)
    return remote_log_dir
