import logging
import time

from taf.transport.ssh import ssh

from common_result_error import RunResult, ClusterConnectionFailure

sshlib = ssh()


def check_fail_keyword_on_error_if_needed(fail_on_error, result):
    if result.status != 0 and str(fail_on_error).lower() == "true":
        raise Exception('Command execution failed:' + str(result))


def execute_command(cmd, fail_on_error=False, conn=None, timeout='60'):
    try:
        sshlib.send_command(cmd, connection=conn, timeout=timeout)
        result_stdout = sshlib.read_output(connection=conn)
        result_stderr = sshlib.read_error(connection=conn)
        result_status = sshlib.get_exit_status(connection=conn)
        res = RunResult(stdout=result_stdout, stderr=result_stderr, status=result_status)
        logging.info(str(res))
        check_fail_keyword_on_error_if_needed(fail_on_error, res)
        return res
    except AttributeError:
        raise ClusterConnectionFailure('Ssh connection to cluster does not work.')


def collect_k8s_log(pod_name, namespace, container_name, tmp_log_dir, conn=None, timeout="10", duration="1h"):
    pod_prefix = "po-" + namespace
    container_prefix = "ctr-" + namespace
    tmp_log_dir = tmp_log_dir.rstrip("/") + "/"
    mkdir_cmd = "mkdir -p /tmp/k8s"
    print(mkdir_cmd)
    output = sshlib.send_command(mkdir_cmd, connection=conn, timeout=timeout)
    print(output)
    if container_name == 'All':
        all_container_cmd = ("kubectl logs " + "-n " + namespace + " " + pod_prefix + "-" + pod_name + "-0" +
                             " --all-containers=True --since=" + duration + " > " + tmp_log_dir + pod_name +
                             "_all_container_journal.log")
        print(all_container_cmd)
        output = sshlib.send_command(all_container_cmd, connection=conn, timeout=timeout)
        print(output)
    else:
        container_cmd = (
                "kubectl logs " + "-n " + namespace + " " + pod_prefix + "-" + pod_name + "-0" +
                " -c " + container_prefix + "-" + container_name + " --since=" + duration + " > "
                + tmp_log_dir + container_name + "_journal.log")
        print(container_cmd)
        output = sshlib.send_command(container_cmd, connection=conn, timeout=timeout)
        print(output)
        remote_log_dir = tmp_log_dir + container_name + "_journal.log"
        return remote_log_dir


def collect_sys_log(namespace, tmp_log_dir, syslog_name, conn=None, timeout="10", duration="1h"):
    cmd_get_syspod = "kubectl get pods -n {cran} | grep logservice | awk '{awk1}'" \
        .format(cran=namespace, awk1='{print $1}')
    syspod = execute_command(cmd=cmd_get_syspod, conn=conn, timeout=timeout).stdout.strip()
    cmd_show_syslogs = "kubectl exec -it {syspod} -c ctr-{cran}-logstorageserver -n {cran} \
        -- bash -c \"cat /var/log/syslog/syslog 2> /dev/null \"".format(syspod=syspod, cran=namespace)
    syslog = execute_command(cmd=cmd_show_syslogs, conn=conn, timeout=timeout).stdout.strip()
    tmp_log_dir = tmp_log_dir.rstrip('/')
    syslog_file = "{tmp_log_dir}/{syslog_name}".format(tmp_log_dir=tmp_log_dir, syslog_name=syslog_name)
    with open(syslog_file, 'w+', encoding='utf-8') as f:
        f.write(syslog)
    return "{tmp_log_dir}/{syslog_name}".format(tmp_log_dir=tmp_log_dir, syslog_name=syslog_name)


def remove_sys_log(namespace, conn=None, timeout="10", duration="1h"):
    cmd_get_syspod = "kubectl get pods -n {cran} | grep logservice | awk '{awk1}'" \
        .format(cran=namespace, awk1='{print $1}')
    syspod = execute_command(cmd=cmd_get_syspod, conn=conn, timeout=timeout).stdout.strip()
    cmd_show_syslogs = "kubectl exec -it {syspod} -c ctr-{cran}-logstorageserver -n {cran}\
         -- bash -c \"ls /var/log/syslog/ 2> /dev/null\" ".format(syspod=syspod, cran=namespace)
    syslogs = execute_command(cmd=cmd_show_syslogs, conn=conn, timeout=timeout).stdout.strip()
    logging.info(syslogs)
    cmd_remv_syslog = "kubectl exec -it {syspod} -c ctr-{cran}-logstorageserver -n {cran}\
         -- bash -c \"rm /var/log/syslog/syslog*\" ".format(syspod=syspod, cran=namespace)
    output = execute_command(cmd=cmd_remv_syslog, conn=conn, timeout=timeout).stdout.strip()
    time.sleep(5)
    syslogs = execute_command(cmd=cmd_show_syslogs, conn=conn, timeout=timeout).stdout.strip()
    logging.info(syslogs)
