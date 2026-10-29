import json
import os
from datetime import datetime

from taf.transport.ssh import ssh
from robot.libraries.BuiltIn import BuiltIn


def show_environ():
    env_vars = os.environ
    for key, value in env_vars.items():
        print(f"{key}: {value}")


def get_image_present_status_on_ccr_repository(images_path: list, ocp_server_ip: str) -> bool:
    """
    Check whether the specified images are present in the CCR by performing the check from the given OCP

    Args:
        images_path (list): A list of image paths to check in the CCR repository.
        ocp_server_ip (str): The IP address of the OCP server from which the CCR repository will be accessed
                             and the presence of images will be verified.
    Returns:
        bool: True if all images are available on the ccr repository, False otherwise.
    """
    ssh_conn = None
    try:
        ssh_conn = ssh()
        ssh_conn.connect_to(ocp_server_ip, "core", "system123")
        for image in images_path:
            output = ssh_conn.execute(f"skopeo inspect docker://{image}")
            if "not found" in output:
                print(f"image not found: {image}")
                return False
        return True
    except Exception as e:
        print(f"Unexpected issue occurred: {e}")
    finally:
        if ssh_conn:
            ssh_conn.disconnect()


def get_main_chart_name(ssh_conn: object, namespace: str):
    charts = ssh_conn.execute(f"helm list -n {namespace}")
    for chart in charts.splitlines()[1:]:
        if "preparation" not in chart.split()[-2] and "prerequisite" not in chart.split()[-2]:
            return chart.split()[0]
    return None


def get_ccr_image_path_list_variable(variable_name: str):
    """
    Check if a variable exists in the Robot Framework suite, and if it's a list.
    Returns the list if found and valid, otherwise returns None.
    """
    variable_reference = f"${{{variable_name}}}"
    try:
        value = BuiltIn().get_variable_value(variable_reference)
        print(f"{variable_reference}: {value}")
        print(f"is a list: {isinstance(value, list)}")
        return value if isinstance(value, list) else None
    except Exception as e:
        print(f"e: {e}")
        return None


def add_path_to_storage_dir_list(storage_dir):
    """
    Check if the suite variable ${STORAGE_DIR_LIST} exists in the test suite.
    If not, create it as an empty list.
    Then, add storage_dir to the list if it is not already present.
    """
    value = BuiltIn().get_variable_value("${STORAGE_DIR_LIST}")
    value = value if isinstance(value, list) else []
    if storage_dir not in value:
        value.append(storage_dir)
    BuiltIn().set_suite_variable("${STORAGE_DIR_LIST}", value)


def create_storage_dir_dictionary(operation_type, directory):
    current_dict = BuiltIn().get_variable_value("${storage_dir}")
    current_dict = current_dict if isinstance(current_dict, dict) else {}
    current_dict[operation_type] = directory
    return current_dict


def sw_ccr_sync_needed(operation_type: str, ocp_ip: str) -> bool:
    """
    Check if software download and upload to ccr is needed

    Args:
        operation_type (str): accepted values: 'upgrade' 'rollback'.
        ocp_ip (str): The IP address of the OCP server from which the CCR repository will be accessed
                      and the presence of images will be verified.
    Returns:
        bool: True if software download and upload to ccr is required, False otherwise.
    """
    variable_name = 'CCR_IMAGE_PATH_LIST' if operation_type.lower() == 'upgrade' else 'ROLLBACK_CCR_IMAGE_PATH_LIST'
    images_to_check = get_ccr_image_path_list_variable(variable_name)
    print(f"images_to_check: {images_to_check}")
    if images_to_check:
        return get_image_present_status_on_ccr_repository(images_to_check, ocp_ip)
    return False


def check_if_cloud_execution():
    return False if os.environ.get("CM_EXECUTION_ID") is None else True


def get_sw_from_artifacts(cnf_type: str) -> str:
    """
    Get the software version for the given cnf_type from CM_ARTIFACTS.
    Args:
        cnf_type (str): Accepted values are 'fhgw', 'vcu_cnf', 'vdu_cnf' or 'ran-nic-sw-controller'.
    Returns:
        str: Software version corresponding to the given cnf_type from CM_ARTIFACTS.
    """
    cm_artifacts = json.loads(os.getenv("CM_ARTIFACTS", "[]"))
    related_artifacts = None
    print(f"cnf_type: {cnf_type}")
    for artifact in cm_artifacts:
        if cnf_type == "vdu_cnf":
            if 'vDUCNF' in artifact.get("name"):
                print(f"{cnf_type} sw version: {artifact.get('name')}")
                return artifact.get("name")
        if artifact.get("properties", {}).get('related_artifacts', {}).get('5G'):
            related_artifacts = artifact.get("properties").get('related_artifacts').get('5G')
            print(f"related_artifacts: {related_artifacts}")
    for artifact in related_artifacts:
        if artifact["default"] and artifact["name"] == cnf_type:
            print(f"{cnf_type} sw version: {artifact['version']}")
            return artifact["version"]
    raise ValueError(f"{cnf_type} is missing from CM_ARTIFACTS")


def get_test_name(test_name):
    test_name = test_name if test_name else BuiltIn().get_variable_value("${TEST_NAME}")
    if 'upgrade_via' in test_name:
        return 'upgrade'
    elif 'rollback_via' in test_name:
        return 'rollback'
    elif 'pre-check' in test_name:
        return 'pre_check'
    elif 'post-check' in test_name:
        return 'post_check'
    return 'other_test'


def get_log_dir(base_path, test_name, passed_log):
    status = "_passed" if passed_log else "_failed"
    iteration = BuiltIn().get_variable_value("${ITERATION_INDEX}", None)
    return f"{base_path}/iteration_{iteration}/{test_name}{status}" if iteration else f"{base_path}/{test_name}{status}"


def get_passed_logs_collected_status(iteration_test_name: str = ''):
    name = BuiltIn().get_variable_value("${TEST_NAME}") if iteration_test_name == '' else iteration_test_name
    passed_logs_status_dict = BuiltIn().get_variable_value("${passed_logs_status}", False)
    if passed_logs_status_dict:
        if name in passed_logs_status_dict:
            return passed_logs_status_dict[name]
        else:
            return False
    return False
