import re
import telnetlib
import subprocess
import os
import stat
import time
import xml.etree.ElementTree as ET

from ute_admin_infomodel import ute_admin_infomodel
from ute_admin_infomodel.exception import InfoModelQueryTimeoutException
from robot.api import logger
from ta5g_testline_management import ta5g_testline_management
from taf.gnb.oam.coam.vdu import vdu

WTS_PATH = "/opt/iphy/latest"
EGATE_PORT = 20000
EDAEMON_PORT = 22222


def check_if_bts_is_onair(timeout=20):
    try:
        im = ute_admin_infomodel()
        with im.infomodel_context(address="192.168.255.129", port=443, timeout=timeout):
            get_onair_state = im.query_infomodel('check /MRBTS-*/RAT-*/MCTRL-*/BBTOP_M-*/MRBTS_M-*/NRBTS_M-* is '
                                                 '[stateInfo.proceduralState=regex"OnAir|onAir"]', timeout=timeout)
        logger.info(get_onair_state)
        if get_onair_state:
            return False
    except InfoModelQueryTimeoutException:
        logger.info("BTS is still not in onAir state after {0}s timeout.".format(timeout))
        return True


def start_wts():
    start_wts_path = WTS_PATH + "/" + "startWTS.sh"
    if os.path.exists(start_wts_path):
        st = os.stat(start_wts_path)
        os.chmod(start_wts_path, st.st_mode | stat.S_IEXEC)
        subprocess.run("sed -i '/WORK_DIR=$(dirname $0)/a cd $WORK_DIR' {}/startWTS.sh".format(WTS_PATH),
                       shell=True, executable="/bin/bash")
        subprocess.run(start_wts_path, shell=True, executable="/bin/bash")
    else:
        ta_mgmt = ta5g_testline_management()
        ta_mgmt.start_default_simulated_SANSA_interfaces()


def start_egate_edaemon():
    egate = subprocess.check_output("cd {0}; ./egate --port {1}".format(WTS_PATH, EGATE_PORT), shell=True)
    if "SERVER PORT = {}".format(EGATE_PORT).encode() in egate:
        logger.info("EGATE process with port {} successfully started.".format(EGATE_PORT))
    edaemon = subprocess.check_output("cd {0}; sudo ./edaemon --port {1}".format(WTS_PATH, EDAEMON_PORT), shell=True)
    if "SERVER PORT = {}".format(EDAEMON_PORT).encode() in edaemon:
        logger.info("EDAEMON process with port {} successfully started.".format(EDAEMON_PORT))


def apply_lua_on_egate(lua_file, host="localhost", egate_port=20000):
    check_bts = check_if_bts_is_onair()
    if check_bts:
        telnet = telnetlib.Telnet(host=host, port=egate_port)
        telnet.write(bytes("\r\ncfg file=" + lua_file + "\r\n", encoding="UTF-8"))
        expected_str = b"MasterInformationBlock-NR Updated"
        expect = telnet.read_until(expected_str, 60).decode()
        if re.search("MasterInformationBlock-NR Updated", expect):
            logger.info("Expected string {0} was find in the egate output.".format(expect))
            return True
        else:
            logger.error("Expected string {0} could not be find in the egate output.".format(expect))
            return False


def add_flag_to_swconfig(flag):
    subprocess.run(
        ['sshpass', '-p', 'oZPS0POrRieRtu', 'ssh', '-q', 'toor4nsn@192.168.255.1',
         'cd ' '/ffs/run;', f'echo {flag} >> swconfig.txt'])
    swconfig_txt = subprocess.check_output(
        ['sshpass', '-p', 'oZPS0POrRieRtu', 'ssh', '-q', 'toor4nsn@192.168.255.1',
         'cd ' '/ffs/run;', 'cat', 'swconfig.txt'])
    if flag in swconfig_txt.decode():
        logger.info(f"Flag {flag} successfully added to swconfig.txt!")
        return True
    else:
        logger.error(f"Flag {flag} still not present in swconfig.txt!")
        return False


def setup_wts_and_check_onair(lua_cfg):
    start_wts()
    start_egate_edaemon()
    apply_lua_on_egate(lua_cfg)


def connect_to_vdu():
    admin_vdu = vdu()
    try:
        admin_vdu.connect_to(
            host='192.168.255.129', port='443', username='Nemuadmin', password='nemuuser', secure=True)
        return admin_vdu
    except Exception as exception:
        template = "An exception occurred while connecting to vDU: {0}"
        logger.error(template.format(str(exception)))
        return None


def get_rmod_status(admin_vdu):
    try:
        rmod_status = []
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
    admin_vdu = connect_to_vdu()
    if not admin_vdu:
        return False
    try:
        number_of_tries = 10
        while number_of_tries > 0:
            time.sleep(12)
            number_of_tries -= 1
            rmod_status = get_rmod_status(admin_vdu)
            if rmod_status is None:
                return False  # Handle error case when getting RMOD status fails
            if check_rmod_status(rmod_status):
                return True  # Exit if all modules are online
            time.sleep(7)
        # If number_of_tries reaches 0 and modules are still not online
        raise AssertionError("Not all radio modules are online after retries.")
    finally:
        admin_vdu.disconnect()


def get_vdu_current_plan_file(vdu_path):
    admin_vdu = connect_to_vdu()
    try:
        filename = "current_plan_vdu.xml"
        admin_vdu.get_current_plan_file(local_dir_path=vdu_path, filename=filename)
        return os.path.join(vdu_path, filename)
    finally:
        admin_vdu.disconnect()


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


def touch(path):
    """Create empty file"""
    try:
        logger.info(f"Creating empty file {path}")
        with open(path, "a"):
            os.utime(path, None)
    except OSError as e:
        logger.error(f"Failed to create/update file {path}: {e}")
        raise


def move_and_create_empty_telemetry_file(path, destination="/opt/iphy", telemetry_file_name="telemetry.py"):
    """Move the telemetry file to a specified directory and create an empty file to free up resources.
    """
    destination_file_path = os.path.join(destination, telemetry_file_name)
    telemetry_file_path = os.path.join(path, telemetry_file_name)
    if os.path.exists(path):
        for root, dirs, files in os.walk(path):
            for name in files:
                if telemetry_file_name in name:
                    os.rename(os.path.join(root, name), destination_file_path)
                    touch(telemetry_file_path)
                    logger.info(f"File {telemetry_file_path} was moved to {destination}.", also_console=True)
                else:
                    logger.info(f"File {telemetry_file_path} does not exist.")
