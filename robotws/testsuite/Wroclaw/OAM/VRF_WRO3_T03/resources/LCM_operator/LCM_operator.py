import requests
import re
import xmltodict
import yaml
import json
from datetime import datetime
from pprint import pprint
import logging
import time
from taf.rfrl.csv4all.resources.utilities.decorators import function_wrapper
from taf.rfrl.csv4all.resources.utilities.utilities import test_logger
from nacl import secret
from taf.transport.ssh import ssh


class UpgradeNotCompletedException(Exception):
    pass


class UpgradeFailedException(Exception):
    pass


class ShutdownPreparationNotComplete(Exception):
    pass


class UpuePodListNotFound(Exception):
    pass


class UpuePodDeletionError(Exception):
    pass


class FatalError(Exception):
    """ Raised when fatal error occured"""
    def __init__(self, exception):
        logging.error(exception)
        self.ROBOT_EXIT_ON_FAILURE = True


def get_lcm_latest_version() -> str:
    """
    Check and return the latest version of the LCM operator available in the artifactory.

    Returns:
        str: The latest available version as a string (e.g., "cnf-lcm-operator_3.4.0-amd64.zip")
    """
    lcm_artifactory_link = "https://artifactory-espoo1.ext.net.nokia.com/artifactory/rcp-infra-local/cnf-lcm-operator"
    pattern = r"^cnf-lcm-operator_[0-9]\.[0-9]\.[0-9]-amd64\.zip$"
    response = requests.get(lcm_artifactory_link, verify=True)
    releases = [
        lcm_release.split('"')[1] for lcm_release in response.text.splitlines() if 'cnf-lcm-operator_' in lcm_release
        if re.match(pattern, lcm_release.split('"')[1])]
    releases.sort(reverse=True)
    return releases[0]


def get_lcm_operator_version_if_installed(ssh_conn):
    output = ssh_conn.execute("helm list -n cnf-lcm-operator -o json | jq -r '.[].chart' | tr '\n' ' '")
    return output.replace("cnf-lcm-operator-", "cnf-lcm-operator_").rstrip() if output != '' else None


def get_lcm_operator_deployment_status(ssh_conn):
    deployed = pods_running = False
    helm_list_output = ssh_conn.execute("helm list -n cnf-lcm-operator")
    print(f"helm list output:\n{helm_list_output}")
    for line in helm_list_output.strip().splitlines()[1:]:
        column = line.split('\t')
        if column[0] == 'cnf-lcm-operator':
            deployed = True if column[4].lower() == 'deployed' else False
            print(f"cnf-lcm-operator deployed: {deployed}")
    pod_status = ssh_conn.execute("oc get pod -n cnf-lcm-operator")
    print(f"pod status:\n{pod_status}")
    for line in pod_status.strip().splitlines()[1:]:
        column = line.split()
        pods_running = True if column[2].lower() == 'running' else False
        print(f"cnf-lcm-operator pod running: {pods_running}")
    return True if deployed and pods_running else False


def wait_for_cnf_status(ssh_conn, namespace, resource_name):
    deployed = False
    output = ssh_conn.execute(f"kubectl get rancnf -n {namespace}")
    print(f"kubectl output:\n{output}")
    for line in output.strip().splitlines()[1:]:
        column = line.split()
        if column[0] == f"{resource_name}":
            deployed = True if column[3] == 'Succeed' else False
    print(f"Deployment STATUS is: {deployed}")
    pod_status = ssh_conn.execute(f"oc get pod -n {namespace}")
    print(f"pod status:\n{pod_status}")
    pod_status_dict = {}
    for line in pod_status.strip().splitlines()[1:]:
        column = line.split()
        pod_status_dict[column[0]] = column[2]
    print(f"pod status dict: {pod_status_dict}")
    pods_running = all(value == "Running" for value in pod_status_dict.values()) if pod_status_dict else False
    print(f"All pods running: {pods_running}")
    if deployed and pod_status:
        return True
    else:
        raise


def get_namespace_from_xml_plane(path_to_the_file):
    with open(path_to_the_file) as xml_file:
        data = xmltodict.parse(xml_file.read())
    managed_objects = data['raml']['cmData']['managedObject']
    for managed_object in managed_objects:
        if managed_object['@class'] == "NAMESPACE":
            return managed_object["@distName"].split("/")[-1].split("-")[-1]
    return None


def prepare_xml_plan(path_to_the_file, image_registry, sw_build):
    with open(path_to_the_file) as xml_file:
        data = xmltodict.parse(xml_file.read())
    managed_objects = data['raml']['cmData']['managedObject']
    for managed_object in managed_objects:
        if managed_object['@class'] == "CNFCONF":
            cnfconf = managed_object["p"]
            for cnf in cnfconf:
                if cnf['@name'] == "imageRegistry":
                    if image_registry != cnf['#text']:
                        cnf['#text'] = image_registry
                elif cnf['@name'] == "cnfSWBuild":
                    if sw_build != cnf['#text']:
                        cnf['#text'] = sw_build
    with open(path_to_the_file, 'w') as xml_file:
        xml_file.write(xmltodict.unparse(data, pretty=True))


def create_secrete_yaml(namespace, ssh_conn):
    part1 = f'apiVersion: v1\nkind: Secret\nmetadata:\n  name: "upgrade-secret"\n  namespace: "{namespace}"'
    part2 = f'\ntype: Opaque\nstringData:\n  swmupgrade: "Nokia@123"'
    secret = part1 + part2
    print(secret)
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    filename = f"{timestamp}_secret.yaml"
    ssh_conn.execute(f'echo "{secret}" > /tmp/{filename}')
    return f"/tmp/{filename}"


def add_cnf_config_parameters_to_yaml(path_to_yaml, parameters_dict):
    with open(path_to_yaml, 'r') as yaml_file:
        yaml_data = yaml.safe_load(yaml_file)
    for keys, value in parameters_dict.items():
        parameter = yaml_data
        for key in keys.split(".")[:-1]:
            if key not in parameter:
                parameter[key] = {}
            parameter = parameter[key]
        parameter[keys.split(".")[-1]] = value
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    filename = f"{timestamp}_BG_rancnf_config.yaml"
    new_path = f"/tmp/{filename}"
    pprint(yaml_data)
    with open(new_path, 'w') as yaml_file:
        yaml.dump(yaml_data, yaml_file, default_flow_style=False, sort_keys=False)
    return new_path


def is_bg_upgrade_completed(ssh_conn, namespace):
    cr_info = get_cr_json(ssh_conn, namespace)
    try:
        cr_operation_type = get_cr_operation_type(cr_info)
        cr_operation_status = get_cr_operation_status(cr_info)
        cr_phase = get_cr_phase(cr_info)
        if cr_operation_type == 'BlueGreenUpgrade' and cr_operation_status == "Succeed" and cr_phase == "Running":
            print(f"operation type: {cr_operation_type}, status: {cr_operation_status}, phase: {cr_phase}")
            return True
        elif cr_operation_status == "Failed":
            raise UpgradeFailedException(f"Operation failed, cr operation status: {cr_operation_status}")
        else:
            raise UpgradeNotCompletedException(
                f"operation type: {cr_operation_type}, status: {cr_operation_status}, phase: {cr_phase}")
    except UpgradeFailedException:
        raise FatalError("Upgrade failed!")


def get_cr_json(ssh_conn, namespace):
    return ssh_conn.execute(f"kubectl get rancnf -n {namespace} -o json")


def get_upue_pods_list(ssh_conn, namespace):
    pods = ssh_conn.execute(f"kubectl get pods -n {namespace} | grep upue")
    pods_list = [upue.split()[0] for upue in pods.split('\n')[:-1]]
    return sorted(pods_list, reverse=True)


def delete_upue_pod(ssh_conn, namespace):
    upue_pods_list = get_upue_pods_list(ssh_conn, namespace)
    return delete_pod(ssh_conn, namespace, upue_pods_list[0])


def delete_pod(ssh_conn, namespace, pod_name):
    return ssh_conn.execute(f"kubectl delete pods {pod_name} -n {namespace}")


def get_upue_shutdown_period_seconds(cr_json):
    return json.loads(cr_json)['items'][0]["spec"]["ranCnfConfig"]['spec']["upueShutdownPeriodSeconds"]


def get_cr_phase(cr_json):
    return json.loads(cr_json)['items'][0]["status"]["phase"]


def get_cr_operation_type(cr_json):
    return json.loads(cr_json)['items'][0]["status"]["operation"]["type"]


def get_cr_operation_status(cr_json):
    return json.loads(cr_json)['items'][0]["status"]["operation"]["status"]


def get_cr_conditions_list(cr_json):
    return sorted(json.loads(cr_json)['items'][0]["status"]["conditions"],
                  key=lambda x: datetime.strptime(x['lastTransitionTime'], "%Y-%m-%dT%H:%M:%SZ"),
                  reverse=True)


def conn_decorator(func):
    def wrapper(*args, **kwargs):
        ssh_conn = None
        try:
            ssh_conn = ssh()
            ssh_conn.connect_to("10.42.102.167", "core", "system123")
            return func(ssh_conn, *args, **kwargs)
        except Exception as e:
            print(f"Unexpected issue occurred: {e}")
        finally:
            if ssh_conn:
                ssh_conn.disconnect()
    return wrapper


def get_upue_pods_status(ssh_conn, namespace):
    pods = ssh_conn.execute(f"kubectl get pods -n {namespace} | grep upue")
    pods_status = {upue.split()[0]: upue.split()[2] for upue in pods.split('\n')[:-1]}
    return pods_status


def timeout_decorator(func):
    def wrapper(*args, **kwargs):
        timeout = kwargs.get('timeout', 300)
        waiting_interval = kwargs.get('waiting_interval', 5)
        start_time = time.time()
        while time.time() - start_time < timeout:
            try:
                return func(*args, **kwargs)
            except (ShutdownPreparationNotComplete, UpuePodListNotFound, UpuePodDeletionError):
                time.sleep(waiting_interval)
        raise TimeoutError(f"{func.__name__}: function execution timed out.")
    return wrapper


@function_wrapper
def get_lcm_engine_logs_and_fetch_by_timestamp(ssh_conn, timestamp, amount_of_lines=50):
    logs = get_lcm_engine_logs(ssh_conn, amount_of_lines=amount_of_lines)
    return fetch_lcm_logs_by_timestamp(timestamp, logs)


def get_lcm_pod_name(ssh_conn) -> str:
    pod_name = ssh_conn.execute("kubectl get pods -n cnf-lcm-operator | grep cnf-lcm | awk '{print $1}'")
    return pod_name.strip()


@function_wrapper
def get_lcm_engine_logs(ssh_conn, amount_of_lines=50) -> str:
    pod_name = get_lcm_pod_name(ssh_conn)
    logs = ssh_conn.execute(f"kubectl logs {pod_name} -c cnf-lcm-engine -n cnf-lcm-operator --tail={amount_of_lines}")
    return logs


def get_timestamp(ssh_conn) -> str:
    last_line = get_lcm_engine_logs(ssh_conn, amount_of_lines=1)
    return last_line.split()[1].strip()


def fetch_lcm_logs_by_timestamp(start_timestamp: str, logs: str) -> list:
    def is_valid_timestamp(ts: str) -> bool:
        try:
            datetime.strptime(ts, "%Y-%m-%dT%H:%M:%SZ")
            return True
        except ValueError:
            return False
    timestamp = datetime.strptime(start_timestamp, "%Y-%m-%dT%H:%M:%SZ")
    filtered_lines = [line for line in logs.splitlines() if line.split() if is_valid_timestamp(
        line.split()[1].strip()) if datetime.strptime(line.split()[1].strip(), "%Y-%m-%dT%H:%M:%SZ") >= timestamp]
    return filtered_lines


@function_wrapper
def filter_lcm_logs_by_keyword(keyword: str, logs: list) -> str:
    for log in logs:
        test_logger(log, console=False)
    filtered_line = next((line for line in logs if keyword in line), None)
    if not filtered_line:
        return None
    timestamp = filtered_line.split()[1].strip()
    test_logger(f"{keyword}: {timestamp}")
    return timestamp


# @conn_decorator
@function_wrapper
def verify_upue_shutdown_procedure(
        ssh_conn, upue_shutdown_period_seconds=300, delete_upue_pod=False, blue_namespace=None):
    start_time = get_timestamp(ssh_conn)
    upue_shutdown_completed_on_time = False
    shutdown_start_time = wait_for_upue_shutdown_operation_start(ssh_conn, start_time)
    pods_to_delete = get_shutdown_pods_list(ssh_conn, shutdown_start_time)
    if delete_upue_pod and blue_namespace:
        test_logger(f"deleting the {pods_to_delete[-1]}")
        delete_upue_pod_and_verify(ssh_conn=ssh_conn, namespace=blue_namespace, pod_name=pods_to_delete[-1])
    shutdown_stop_time = wait_for_upue_shutdown_operation_end(ssh_conn, start_time,
                                                              timeout=upue_shutdown_period_seconds + 70)
    time1 = datetime.strptime(shutdown_start_time, "%Y-%m-%dT%H:%M:%SZ")
    time2 = datetime.strptime(shutdown_stop_time, "%Y-%m-%dT%H:%M:%SZ")
    delta = (time2 - time1).total_seconds()
    if blue_namespace:
        confirm_pod_deletion(ssh_conn=ssh_conn, namespace=blue_namespace, pods_to_delete=pods_to_delete)
    test_logger(f"Shutdown duration (seconds): {delta}")
    if delta <= int(upue_shutdown_period_seconds) + 10:
        test_logger("UPUE shutdown procedure completed within the expected time.")
        upue_shutdown_completed_on_time = True
    return pods_to_delete, upue_shutdown_completed_on_time, delta


@timeout_decorator
@function_wrapper
def confirm_pod_deletion(ssh_conn, namespace, pods_to_delete, timeout=90):
    upue_pods = get_upue_pods_list(ssh_conn, namespace)
    upue_stasus = get_upue_pods_status(ssh_conn, namespace)
    upue_pods_set = set(upue_pods)
    pods_to_delete_set = set(pods_to_delete)
    test_logger(f"pupue pods status {namespace}: {upue_stasus}")
    if upue_pods_set.isdisjoint(pods_to_delete_set):
        test_logger(f"Pods {pods_to_delete} successfully deleted.")
    else:
        test_logger(f"Failed to delete pods {pods_to_delete}.")
        raise UpuePodDeletionError(f"Failed to delete pods {pods_to_delete}.")


@function_wrapper
def delete_upue_pod_and_verify(ssh_conn, namespace, pod_name):
    delete_pod(ssh_conn, namespace, pod_name)
    upue_pods_statuses = get_upue_pods_status(ssh_conn, namespace)
    test_logger(f"pupue_pods: {upue_pods_statuses}")
    if upue_pods_statuses[pod_name] == "Terminating" or upue_pods_statuses[pod_name] == "ContainerCreating":
        test_logger(f"Pod {pod_name} successfully deleted.")
    else:
        test_logger(f"Failed to delete pod {pod_name}.")
        raise UpuePodDeletionError(f"Failed to delete pod {pod_name}.")


@function_wrapper
def wait_for_upue_shutdown_operation_end(ssh_conn, start_time, timeout):
    return wait_for_upue_shutdown_preparation(ssh_conn, start_time, waiting_interval=60, timeout=timeout,
                                              amount_of_lines=600,
                                              is_waiting_for_stop=True)


@function_wrapper
def wait_for_upue_shutdown_operation_start(ssh_conn, start_time):
    return wait_for_upue_shutdown_preparation(ssh_conn, start_time, waiting_interval=30, timeout=300)


# @conn_decorator
@timeout_decorator
@function_wrapper
def wait_for_upue_shutdown_preparation(ssh_conn, timestamp, waiting_interval, timeout=600,
                                       amount_of_lines=50, is_waiting_for_stop=False):
    test_logger(
        f"Waiting for UPUE shutdown preparation, waiting interval: {waiting_interval}s, timeout: {timeout}s",
        console=False)
    filtered_logs = get_lcm_engine_logs_and_fetch_by_timestamp(ssh_conn, timestamp, amount_of_lines=amount_of_lines)
    keyword = "shutdown preparation successful" if is_waiting_for_stop else "shutdown preparation started"
    shutdown_timestamp = filter_lcm_logs_by_keyword(keyword, filtered_logs)
    if shutdown_timestamp:
        return shutdown_timestamp
    if is_waiting_for_stop:
        test_logger("Waiting for UPUE shutdown preparation to complete...")
    else:
        test_logger("Waiting for UPUE shutdown preparation to start...")
    raise ShutdownPreparationNotComplete


# @conn_decorator
@timeout_decorator
@function_wrapper
def get_shutdown_pods_list(ssh_conn, timestamp, timeout=60):
    filtered_logs = get_lcm_engine_logs_and_fetch_by_timestamp(ssh_conn, timestamp)
    filtered_line = next((line for line in filtered_logs if "shutdown Pods:" in line), None)
    if filtered_line:
        pods_list = filtered_line.split(",")[2].split(':')[1].replace("[", "").replace("]", "").strip().split()
        test_logger(f"UPUE pods to be shutdown: {pods_list}")
        return pods_list
    raise UpuePodListNotFound
