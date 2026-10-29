import os
import subprocess
import time
import xml.etree.ElementTree as ET
import re
import telnetlib
import json

from taf.gnb.oam.coam.vdu import vdu
from taf.gnb.oam.coam.cu import cu
from robot.api import logger
from robot.libraries.BuiltIn import BuiltIn
from contextlib import contextmanager


WTS_PATH = "/opt/iphy/latest"
EGATE_PORT = 20000
EDAEMON_PORT = 22222


def _get_credentials_from_object(conn_details):
    """Extracts credentials from a connection details object."""
    return conn_details.addr, conn_details.port, conn_details.username, conn_details.password


def _get_credentials_for_type(tl, vran_type, vdu_number):
    """Helper function to retrieve credentials based on vRAN type."""
    if vran_type == "vcu":
        return _get_credentials_from_object(tl.gnbs[0].cu.oam_http_connection_details)
    elif vran_type == "vdu":
        return _get_credentials_from_object(tl.gnbs[0].dus[int(vdu_number) - 1].oam_http_connection_details)
    else:
        logger.error("Please provide correct vRAN type (vcu/vdu).")
        return None


def get_vran_credentials(vran_type, vdu_number=1):
    """Retrieves credentials for the specified vRAN type."""
    tl = BuiltIn().get_variable_value("${tl}")
    return _get_credentials_for_type(tl, vran_type, vdu_number)


@contextmanager
def connect_to_vcu():
    host, port, username, password = get_vran_credentials("vcu")
    admin_vcu = cu()
    try:
        admin_vcu.connect_to(
            host=host, port=port, username=username, password=password, secure=True)
        yield admin_vcu
    finally:
        admin_vcu.disconnect()


@contextmanager
def connect_to_vdu():
    host, port, username, password = get_vran_credentials("vdu")
    admin_vdu = vdu()
    try:
        admin_vdu.connect_to(
            host=host, port=port, username=username, password=password, secure=True)
        yield admin_vdu
    except Exception as exception:
        template = "An exception occurred while connecting to vDU: {0}"
        logger.error(template.format(str(exception)))
        return None
    finally:
        admin_vdu.disconnect()


def perform_delta_recommissioning_vcu(delta_file):
    with connect_to_vcu() as admin_vcu:
        admin_vcu.perform_delta_recommissioning(delta_file=delta_file)


def perform_delta_recommissioning_vdu(delta_file):
    with connect_to_vdu() as admin_vdu:
        admin_vdu.perform_delta_recommissioning(delta_file=delta_file)


def get_pod_name(pod_name):
    pods_list = []
    with connect_to_vdu() as admin_vdu:
        pods_info = admin_vdu.get_pods_info()
        for pod in pods_info:
            if pod_name in pod['name']:
                pods_list.append(pod['name'])
    if len(pods_list) != 0:
        print(pods_list)
        return pods_list[0]
    else:
        logger.error(f"Pod with name {pod_name} was not found.")


def get_rmod_status():
    try:
        rmod_status = []
        with connect_to_vdu() as admin_vdu:
            activation_status = admin_vdu.get_rmods_status()
        for rmod in activation_status:
            rmod_status.append(rmod['availability_status'])
        return rmod_status
    except Exception as exception:
        template = "An exception occurred while getting RMOD status: {0}"
        logger.error(template.format(str(exception)))
        return None


def check_rmod_status(rmod_status):
    if all(item == "on line" for item in rmod_status):
        logger.info("All radio modules on vDU are online.", also_console=True)
        return True
    else:
        logger.info("Not all radio modules are online. Retrying...")
        return False


def get_vdu_rmods_status():
    logger.console("Waiting for RMODs to be online...")
    number_of_tries = 15
    while number_of_tries > 0:
        time.sleep(12)
        number_of_tries -= 1
        rmod_status = get_rmod_status()
        if rmod_status is None:
            return False  # Handle error case when getting RMOD status fails
        if check_rmod_status(rmod_status):
            return True  # Exit if all modules are online
        time.sleep(7)
    # If number_of_tries reaches 0 and modules are still not online
    raise AssertionError("Not all radio modules are online after retries.")


def check_cells_status(cell_status):
    if all(item.lower() == "on line" or item.lower() == "online" for item in cell_status):
        logger.info("All cells on vDU are online.", also_console=True)
        return True
    else:
        logger.info("Not all cells are online. Retrying...")
        return False


def get_vdu_cells_availability_status():
    try:
        cells_status = []
        with connect_to_vdu() as admin_vdu:
            activation_status = admin_vdu.get_vdu_cells_status()
        for cell in activation_status:
            cells_status.append(cell['availability_status'])
        return cells_status
    except Exception as exception:
        template = "An exception occurred while getting cells status: {0}"
        logger.error(template.format(str(exception)))
        return None


def wait_for_all_cells_to_be_online():
    logger.console("Waiting for cells to be online...")
    number_of_tries = 15
    while number_of_tries > 0:
        time.sleep(12)
        number_of_tries -= 1
        cell_status = get_vdu_cells_availability_status()
        if cell_status is None:
            return False  # Handle error case when getting CELL status fails
        if check_cells_status(cell_status):
            return True  # Exit if all cells are online
        time.sleep(7)
    # If number_of_tries reaches 0 and cells are still not online
    raise AssertionError("Not all cells are online after retries.")


def reset_vcu_and_vdu():
    with connect_to_vcu() as admin_vcu:
        admin_vcu.reset_cu()
    with connect_to_vdu() as admin_vdu:
        admin_vdu.reset_vdu()


def check_f1_status(f1_link_status):
    if f1_link_status.lower() == "available":
        logger.info("F1 link is available.", also_console=True)
        return True
    else:
        logger.info("F1 link is still not available. Retrying...")
        return False


def get_f1_link_status():
    try:
        with connect_to_vdu() as admin_vdu:
            vdu_data = admin_vdu.get_vdu_state_data()
            f1_link_status = vdu_data['f1_c_link_status_du']
            return f1_link_status
    except ValueError as err:
        logger.error(f"Pattern not found in the input string. {err}")


def wait_for_f1_link_to_be_available():
    def try_waiting_for_f1_link(number_of_tries):
        logger.console("Waiting for F1 link to be available...")
        while number_of_tries > 0:
            time.sleep(15)
            number_of_tries -= 1
            f1_link_status = get_f1_link_status()
            if f1_link_status is None:
                return False  # Handle error case when getting F1 link status fails
            if check_f1_status(f1_link_status):
                return True  # Exit if F1 link is available
            time.sleep(7)
        return False
    max_retries = 30
    if not try_waiting_for_f1_link(max_retries):
        reset_vcu_and_vdu()
        if not try_waiting_for_f1_link(max_retries):
            raise AssertionError("F1 link is still not available after retries.")


def get_vdu_current_plan_file(vdu_path):
    with connect_to_vdu() as admin_vdu:
        filename = "current_plan_vdu.xml"
        admin_vdu.get_current_plan_file(local_dir_path=vdu_path, filename=filename)
        return os.path.join(vdu_path, filename)


def get_vdu_active_sw_build():
    try:
        with connect_to_vdu() as admin_vdu:
            vdu_data = admin_vdu.get_vdu_state_data()
            vdu_rel_pattern = r".*?CNF(\d+\D+\d+)"
            sw_version = vdu_data["software_version"]
            release = re.match(vdu_rel_pattern, sw_version).group(1)
            if "0.300" in sw_version:
                vdu_sw_version = sw_version.replace(release, "00")
            else:
                vdu_sw_version = sw_version
            return vdu_sw_version
    except ValueError as err:
        logger.error(f"Pattern not found in the input string. {err}")


def get_vcu_active_sw_build():
    try:
        with connect_to_vcu() as admin_vcu:
            vcu_data = admin_vcu.get_active_software_version()
            vcu_rel_pattern = r".*?CNF(\d+\D+\d+)"
            release = re.match(vcu_rel_pattern, vcu_data).group(1)
            vcu_sw_version = vcu_data.replace(release, "00")
            return vcu_sw_version
    except ValueError as err:
        logger.error(f"Pattern not found in the input string. {err}")


def delta_recommission_vcu(converted_delta_json, timeout=120):
    """Example accepted json:
    [
        {
            "class_name": "NRBTS",
            "dist_name": "MRBTS-1/NRBTS-1",
            "operation_type": "update",
            "payload": "{\"cuOvlHa\": {\"ovlBeamSwitchRej\": \"enabled\", \"ovlNsaA4TimerDiscard\": \"disabled\"\"}}"
        }
    ]
    """
    with open(converted_delta_json) as json_file:
        converted_json = json.load(json_file)
    with connect_to_vcu() as admin_vcu:
        provision_info = admin_vcu.provision_vcu_delta_plan(converted_json, timeout=timeout)
        operation_id = provision_info['id']
        counter = 0
        while counter < timeout:
            status = admin_vcu.get_provision_vcu_delta_plan_status(operation_id)
            if status['status'] == 'success':
                logger.info("Delta applied successfully to vCU.", also_console=True)
                return
            elif status['status'] == 'failure':
                logger.error(status)
                raise Exception("Failure during delta activation on vCU")
            counter += 10
            time.sleep(10)
        logger.error("Unsuccessful delta activation on vCU.")


def delta_recommission_vdu(converted_delta_json, timeout=120):
    with open(converted_delta_json) as json_file:
        converted_json = json.load(json_file)
    with connect_to_vdu() as admin_vdu:
        provision_info = admin_vdu.provision_vdu_delta_plan(converted_json, timeout=timeout)
        operation_id = provision_info['id']
        counter = 0
        while counter < timeout:
            status = admin_vdu.get_provision_vdu_delta_plan_status(operation_id)
            if status['status'] == 'success':
                logger.info("Delta applied successfully to vDU.", also_console=True)
                return
            elif status['status'] == 'failure':
                logger.error(status)
                raise Exception("Failure during delta activation on vCU")
            counter += 10
            time.sleep(10)
        logger.error("Unsuccessful delta activation on vDU.")


def start_netcat(port="49150"):
    subprocess.run("ncat -vklnp %s > /dev/null 2>&1 &" % port, shell=True)


def stop_netcat():
    os.system("sudo killall ncat")


def check_handover_params():
    with connect_to_vcu() as admin_vcu:
        obj_params = {"nrAdjGnbId": "NRADJGNB", "nrAdjNrCellId": "NRADJNRCELL"}
        for obj_param in obj_params:
            obj_dict = admin_vcu.search_parameters_of_current_plan(obj_param)
            if not obj_dict["items"]:
                return True
        return False


def commission_handover_params_if_needed(delta):
    if check_handover_params():
        perform_delta_recommissioning_vcu(delta)
    else:
        logger.info("Handover params are already present in SCF.")


def parse_xml(file_path, uri):
    try:
        tree = ET.parse(file_path)
        ET.register_namespace(prefix='', uri=uri)
        return tree, tree.getroot()
    except ET.ParseError as e:
        logger.error(f"Error parsing XML file {file_path}: {e}")
        return None, None


def find_managed_object(root, target_distname, namespaces):
    return root.find(f".//ns:managedObject[@distName='{target_distname}']", namespaces)


def get_current_values_of_serial_number_and_prod_code(managed_object, namespaces):
    if managed_object is not None:
        prod_code_element = managed_object.find(".//ns:p[@name='prodCodePlanned']", namespaces)
        serial_code_element = managed_object.find(".//ns:p[@name='serialNumberPlanned']", namespaces)
        if prod_code_element is not None and serial_code_element is not None:
            return serial_code_element.text, prod_code_element.text
        else:
            logger.error(f"'prodCodePlanned' or 'serialNumberPlanned' element not found in managedObject")
            return None, None
    else:
        logger.error(f"managedObject not found.")
        return None, None


def update_serial_number_and_prod_code(managed_object, new_serial_number, new_prod_code, namespaces):
    if managed_object is not None:
        prod_code_element = managed_object.find(".//ns:p[@name='prodCodePlanned']", namespaces)
        serial_code_element = managed_object.find(".//ns:p[@name='serialNumberPlanned']", namespaces)
        if prod_code_element is not None and serial_code_element is not None:
            prod_code_element.text = new_prod_code
            serial_code_element.text = new_serial_number
            return True
        else:
            logger.error(f"'prodCodePlanned' or 'serialNumberPlanned' element not found for update")
            return False
    return False


def change_serial_number_and_product_code_from_default_scf(vdu_default_scf_path, vdu_new_plan, target_distname):
    """
    Updates the serial number and product code in a new VDU plan based on the values from a default SCF file.

    Args:
        vdu_default_scf_path (str): Path to the default SCF file.
        vdu_new_plan (str): Path to the new VDU plan file.
        target_distname (str): The distribution name of the managed object to update.
    """
    namespaces = {'ns': 'raml21.xsd'}
    tree_current, root_current = parse_xml(vdu_default_scf_path, namespaces['ns'])  # Parse both XML files
    tree_new, root_new = parse_xml(vdu_new_plan, namespaces['ns'])
    if root_current is None or root_new is None:
        return None
    managed_object_current = find_managed_object(root_current, target_distname, namespaces)
    managed_object_new = find_managed_object(root_new, target_distname, namespaces)
    current_serial_number, current_prod_code = get_current_values_of_serial_number_and_prod_code(
        managed_object_current, namespaces)
    if current_serial_number is None or current_prod_code is None:
        return None
    if managed_object_new is not None and update_serial_number_and_prod_code(
            managed_object_new, current_serial_number, current_prod_code, namespaces):
        tree_new.write(vdu_new_plan, encoding='utf-8', xml_declaration=True)
        logger.info(f"Updated serial number and product code.", also_console=True)
        return current_serial_number, current_prod_code
    else:
        logger.error(f"Failed to update elements in managedObject with distName='{target_distname}'")
        return None


def change_rad_debug_parameters(flags_list, domain_name, persistency="persistent"):
    with connect_to_vdu() as admin_vdu:
        admin_vdu.update_rad_debug_params(
            persistency=persistency, domain_name=domain_name, parameters=flags_list)


def reapply_lua_on_egate(lua_file, host="localhost", egate_port=20000):
    telnet = telnetlib.Telnet(host=host, port=egate_port)
    telnet.write(bytes("\r\nreset" + "\r\n", encoding="UTF-8"))
    telnet.write(bytes("\r\ncfg file=" + lua_file + "\r\n", encoding="UTF-8"))
    expected_str = b"MasterInformationBlock-NR Updated"
    expect = telnet.read_until(expected_str, 60).decode()
    if re.search("MasterInformationBlock-NR Updated", expect):
        logger.info("Expected string {0} was find in the egate output.".format(expect))
        return True
    else:
        logger.error("Expected string {0} could not be find in the egate output.".format(expect))
        return False


def get_sum_of_rejects(*args):
    result = 0
    for num in args:
        result += int(num)
    return str(result)
