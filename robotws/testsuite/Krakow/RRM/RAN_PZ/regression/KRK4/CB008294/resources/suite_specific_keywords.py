"""
:copyright: Nokia Networks
:author: Mateusz Plinta
:maintainer: Mateusz Plinta
:contact: mateusz.plinta@nokia.com
:team: MN RAN L2 SW 2 KRK Vrf SG
"""

import json
import os
import re
import zipfile
import shutil
import glob

from robot.libraries.BuiltIn import BuiltIn
from taf.config.scf import scf
from ta5g_testline_management import ta5g_testline_management
from ta5g_interface_tools import ta5g_interface_tools
from taf.internal.sbts.admin.exceptions import AdminApiException
from taf.rfrl.utilities.logger import custom_logger

from testsuite.Krakow.RRM.RAN_PZ.regression.KRK4.resources.Python import common_gnb
from testsuite.Krakow.RRM.RAN_PZ.regression.KRK4.resources.Python import pm_counters
from testsuite.Krakow.RRM.RAN_PZ.regression.KRK4.resources.Python import utilities
from log_collection import get_test_log_dirpath
from testsuite.Krakow.RRM.RAN_PZ.regression.KRK4.CB008294.resources.deltas import delta_vars
from variables import *


def set_variables_based_on_deployment_and_release():
    capacity_unit = common_gnb.get_capability_unit_name()
    release = common_gnb.get_gnb_build_release(convert_to_trunk=True)
    release_no_conv = common_gnb.get_gnb_build_release(convert_to_trunk=False)
    pm_interval = pm_counters.get_measurement_period_from_scf()
    pm_interval = int(pm_interval.replace("min", ""))
    output_dir = ta5g_interface_tools().get_robot_output_dir()
    suite_name = ta5g_interface_tools().get_robot_suite_name()
    BuiltIn().set_suite_variable("${BASE_SCF_PATH}",
                                 os.path.join(output_dir, suite_name, "base_scf.xml"))
    BuiltIn().set_suite_variable("${PM_PERIOD}", pm_interval)
    BuiltIn().set_suite_variable("${UNIT_NAME}", capacity_unit)
    BuiltIn().set_suite_variable("${RELEASE}", release)
    BuiltIn().set_suite_variable("${RELEASE_NO_CONV}", release_no_conv)


def set_proper_vlan_id_in_base_scf(scf_filename):
    dist_name = "MRBTS-1/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/VLANIF-1"
    vlan_id = common_gnb.get_parameter_value_from_scf(dist_name=dist_name, parameter="vlanId")
    scf_path = os.path.join(SCFS_DIRECTORY_PATH, scf_filename)
    taf_scf_instance = scf()
    taf_scf_instance.load_scf(file_path=scf_path)
    taf_scf_instance.modify_scf_element(dist_name=dist_name, p_name="vlanId", value=vlan_id)
    taf_scf_instance.save_scf(file_path=scf_path)
    utilities.logger_console_info(f"SCFs: Vlan ID reconfigured to {vlan_id}")


def test_is_crt():
    return "CRT" in BuiltIn().get_variable_value("@{TEST TAGS}")


def get_test_info_from_test_name():
    tc_name = BuiltIn().get_variable_value("${TEST_NAME}")
    tc_regex = r"CB00(?P<feature>8294)_(?P<split_subfeature>(?P<fsplit>\w)_(?P<subfeature>\w+))_(?P<tc>\d\d)_.*"
    match = re.search(tc_regex, tc_name)
    if not match:
        raise ValueError(f"Test case name: {tc_name} is not recognized by regex pattern: {tc_regex}.")
    return match.groupdict()


def set_test_specific_variables(pcell, cc_dl, cc_ul, ue_ids=(), cell_subcell_map=None):
    """

    :param pcell:
    :param cc_dl:
    :param cc_ul:
    :param ue_ids:
    :param activated_scells_nrcell_ids_map:
    :param scells_nrcell_ids_with_expected_traffic_map:
    :param cell_subcell_map:
    :return:
    """
    pcell = int(pcell)
    cc_dl = int(cc_dl)
    cc_ul = int(cc_ul)
    pcell_pci = CELL_ID_TO_PCI_MAP[pcell]
    if cell_subcell_map is None:
        cell_subcell_map = DEFAULT_CELL_SUBCELL_MAP
    if isinstance(cell_subcell_map, str):
        cell_subcell_map = eval(cell_subcell_map)

    utilities.logger_info(f"CELL_SUBCELL_MAP used by internal validaiton methods: {cell_subcell_map}")
    BuiltIn().set_test_variable("${CELL_SUBCELL_MAP}", cell_subcell_map)
    BuiltIn().set_test_variable("${PCELL_PCI}", pcell_pci)
    BuiltIn().set_test_variable("${UE_IDS}", ue_ids)
    BuiltIn().set_test_variable("${CC_DL}", cc_dl)
    BuiltIn().set_test_variable("${CC_UL}", cc_ul)


def prepare_subcell_delta():
    def get_cell_id(pci):
        return PCI_TO_CELL_ID_MAP[pci]

    def need_to_add_ul_subcells(pci, subcell_list):
        if "UL" in subcell_list and "UL" not in DEFAULT_CELL_SUBCELL_MAP[pci]:
            return True
        return False

    def need_to_remove_ul_subcells(pci, subcell_list):
        if "UL" not in subcell_list and "UL" in DEFAULT_CELL_SUBCELL_MAP[pci]:
            return True
        return False

    delta = []
    pcell_pci = BuiltIn().get_variable_value("${PCELL_PCI}")
    cell_subcell_map = BuiltIn().get_variable_value("${CELL_SUBCELL_MAP}")
    if pcell_pci != DEFAULT_PCELL_PCI:
        delta.extend(delta_vars.UNSET_PRIMARY_CELL_TEMPLATE(get_cell_id(DEFAULT_PCELL_PCI)))
        delta.extend(delta_vars.SET_PRIMARY_CELL_TEMPLATE(get_cell_id(pcell_pci)))
    for pci, subcell_list in cell_subcell_map.items():
        if need_to_add_ul_subcells(pci, subcell_list):
            delta.extend(delta_vars.ADD_UL_SUBCELLS_TEMPLATE(get_cell_id(pci)))
        if need_to_remove_ul_subcells(pci, subcell_list):
            delta.extend(delta_vars.REMOVE_UL_SUBCELLS_TEMPLATE(get_cell_id(pci)))
    return delta


def combine_test_specific_delta_with_subcell_delta(test_delta=None):
    if test_delta is None:
        test_delta = []
    subcell_delta = prepare_subcell_delta()
    test_dirpath = get_test_log_dirpath()
    test_delta_final = [*test_delta, *subcell_delta]
    with open(os.path.join(test_dirpath, 'test_adapted_delta.json'), 'w', encoding='utf-8') as delta_fileobj:
        json.dump(test_delta_final, delta_fileobj, ensure_ascii=False, indent=4)
    return json.dumps(test_delta_final) if test_delta_final else None


def combine_test_specific_delta_with_subcell_delta_for_b6_b7(test_delta=None):
    if test_delta is None:
        test_delta = []
    else:
        test_dirpath = get_test_log_dirpath()
        with open(os.path.join(test_dirpath, 'test_adapted_delta.json'), 'w', encoding='utf-8') as delta_fileobj:
            json.dump(test_delta, delta_fileobj, ensure_ascii=False, indent=4)
    return json.dumps(test_delta) if test_delta else None


def extract_logfile(file_path, log_name):
    """
    Internal log extractor
    Logs are stored in zip as:
    <...>_<log_name>.<extension>. Script looks for the file that contains specified log_name param.

    :param file_path: Path to the unpacked archive (directory)
    :param log_name: Log name to look for
    """
    path = os.path.normpath(file_path)
    result_dir_regex = r"[0-9]{8}/"
    filepath = None
    for file in glob.glob(glob.escape(path) + f'/**/*{log_name}*.*', recursive=True):
        if re.search(result_dir_regex, file):
            filepath = file
    try:
        new_path = os.path.join(os.path.split(path)[:-1][0], os.path.basename(filepath))
    except TypeError as e:
        raise Exception(f"Unable to find logfile in the archive. Error: {e}")
    new_filepath = os.path.join(os.path.dirname(new_path), os.path.basename(path) + f"_{log_name}")
    new_filepath += os.path.splitext(new_path)[1]
    os.rename(filepath, new_filepath)
    return new_filepath


def gather_utf_lab_tracing_logs(path):
    """
    Collects UTF Lab own logs.

    :param path: Path to the unpacked archive (directory)
    """
    new_name = os.path.basename(path)
    logs_path = f"{path}/logs"
    zip_path = os.path.join(os.path.dirname(path), f"utf_lab_trace_logs_{new_name}")
    with zipfile.ZipFile(f"{zip_path}.zip", "w") as zf:
        for _, _, filenames in os.walk(logs_path):
            for filename in filenames:
                filepath = os.path.join(logs_path, filename)
                zf.write(filepath, os.path.basename(filepath))


def extract_5gm_logfile_from_zip(path, log_name, filename=None, delete_zip=True, collect_trace_logs=True):
    """
    Extracts specified logfile from the collected archive.
    1) Unpacks the archive
    2) Finds the 5gm log in the unpacked directory

    :param path: Path to the collected archive
    :param log_name: Logname to look for in the archive (scf, snapshot, etc.).
    :param filename: (optional) The name of the extracted file. Defaults to `path` argument
    :param delete_zip: (optional) Whether to delete initial archive or not
    :param collect_trace_logs: (optional) Whether to collect UTF Lab tool trace logs or not
    """
    dir_path, _ = os.path.splitext(path)
    with zipfile.ZipFile(path, 'r') as zf:
        zf.extractall(dir_path)
    extracted_filepath = extract_logfile(dir_path, log_name)
    while not extracted_filepath.endswith("5gm"):
        try:
            extracted_filepath = extract_logfile(dir_path, log_name)
        except Exception:
            utilities.logger_info("Unable to find 5gm logfile in the archive.")
            break
    if collect_trace_logs:
        gather_utf_lab_tracing_logs(dir_path)
    shutil.rmtree(dir_path)
    if delete_zip:
        os.remove(path)
    if not filename:
        filename = path
    else:
        filename = os.path.join(os.path.dirname(path), filename)
    name, _ = os.path.splitext(filename)
    _, ext = os.path.splitext(extracted_filepath)
    filename = f"{name}{ext}"
    os.rename(extracted_filepath, filename)
    custom_logger.log_info_to_console(f"Extracted file path: {filename}")
    return filename
