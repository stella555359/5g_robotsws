from contextlib import contextmanager
from taf.transport.ssh.connection import connect
from robot.libraries import BuiltIn
import logging


__all__ = ['get_cu_executor',
           'get_cu_namespace',
           'get_pm_pod_and_container_on_cu',
           'get_vdu_executor',
           'get_vdu_namespace',
           'get_pm_pod_and_container_on_vdu']

logger = logging.getLogger()

TL_CONFIG = None


def tl_config():
    global TL_CONFIG
    if TL_CONFIG is None:
        robot_builtin = BuiltIn.BuiltIn()
        TL_CONFIG = robot_builtin.get_variable_value("${tl}")
    return TL_CONFIG


def get_cu_master_node_ssh_details(gnb_id):
    return tl_config().gnbs[0].cloud_deployment.cloud_hosting.master_node.ssh_connection_details


def get_vdu_master_node_ssh_details(gnb_id, vdu_id):
    cloud_deployment = tl_config().gnbs[int(gnb_id)].dus[int(vdu_id)].cloud_deployment
    return cloud_deployment.cloud_hosting.master_node.ssh_connection_details


def get_vdu_namespace(gnb_id, vdu_id):
    return tl_config().gnbs[int(gnb_id)].dus[int(vdu_id)].cloud_deployment.cloud_hosting.namespace


def get_cu_namespace(gnb_id):
    return tl_config().gnbs[0].cloud_deployment.cloud_hosting.namespace


@contextmanager
def connect_to_cu_master_node(gnb_id):
    ssh_details = get_cu_master_node_ssh_details(gnb_id)
    ssh_connection = connect(hostname=ssh_details.addr,
                             username=ssh_details.username,
                             password=ssh_details.password)
    yield ssh_connection

    ssh_connection.disconnect()


@contextmanager
def connect_to_vdu_master_node(gnb_id=0, vdu_id=0):
    ssh_details = get_vdu_master_node_ssh_details(gnb_id, vdu_id)
    ssh_connection = connect(hostname=ssh_details.addr,
                             username=ssh_details.username,
                             password=ssh_details.password)
    yield ssh_connection

    ssh_connection.disconnect()


def get_pm_pod(ssh_connection, namespace):

    pod_list_output = ssh_connection.execute(
        command='kubectl get pod -n {}'.format(namespace))

    output_lines = [line.strip()
                    for line in pod_list_output.split('\n') if line.strip()]

    pm_pods = [line for line in output_lines for component in [
        '-pm-'] if component in line]

    assert len(pm_pods) == 1, "There should be one pm pod!"
    pod = pm_pods[0].split()[0]

    logger.info('pm pod: {}'.format(pod))
    return pod


def get_container_from_pod(pod, namespace, ssh_connection):
    output = ssh_connection.execute(
        "kubectl get pods -n {} {} -o jsonpath='{{.spec.containers[*].name}}'".format(namespace, pod))

    output_lines = [line.strip()
                    for line in output.split('\n') if line.strip()]
    pmcores = [x for x in output_lines if 'pmcore' in x]

    assert len(pmcores) == 1, "There should be one pmcore container!"
    pmcore = pmcores[0].split()[0]

    logger.info('pmcore container: {}'.format(pmcore))
    return pmcore


def get_pm_pod_and_container_on_cu(gnb_id=0):
    namespace = get_cu_namespace(gnb_id)
    with connect_to_cu_master_node(gnb_id) as ssh:
        pod = get_pm_pod(ssh, namespace)
        pmcore = get_container_from_pod(pod, namespace, ssh)

    return pod, pmcore


def get_pm_pod_and_container_on_vdu(gnb_id=0):
    namespace = get_vdu_namespace(gnb_id, vdu_id=0)
    with connect_to_vdu_master_node(gnb_id) as ssh:
        pod = get_pm_pod(ssh, namespace)
        pmcore = get_container_from_pod(pod, namespace, ssh)
    return pod, pmcore


def get_vdu_executor(gnb_id=0, vdu_id=0):
    k8_details = tl_config().gnbs[0].dus[int(vdu_id)].cloud_deployment.cloud_hosting.master_node.k8s_connection_details
    return {'host': k8_details.ip_addr,
            'user': k8_details.username,
            'password': k8_details.password}


def get_cu_executor(gnb_id=0):
    return {'host': tl_config().cloud_hostings[0].master_node.k8s_connection_details.ip_addr,
            'user': tl_config().cloud_hostings[0].master_node.k8s_connection_details.username,
            'password': tl_config().cloud_hostings[0].master_node.k8s_connection_details.password}
