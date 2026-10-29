from robot.api import logger
from taf.rfrl.bts.devices.du.pm_counters import GnbPmCounter
from testsuite.Krakow.resources.RAN_PZ_KRK7.tools.keywords import use_admin_connection, get_mrbts_id
from taf.rfrl.utilities.test_config import DefaultFileLocation
from taf.rfrl.bts.devices.du.du_operations import GnbDuOperations
from moler.device import DeviceFactory
from taf.rfrl.bts.helpers.sw_versions import SbtsSwVersion
from robot.libraries.BuiltIn import BuiltIn
import json
import os
import lxml.etree as ET
from pathlib import Path
from ta_a2a import ta_a2a
from pathlib import Path


def wait_for_next_pm_counter_period(interval, delay=30):
    """
    Waiting for the next period to collect pm counter

    :param  interval  time of the next period
    :param  delay     delay time
    :return None
    """
    GnbPmCounter().wait_for_next_pm_period(interval=interval, delay=int(delay))


def get_default_scf_path(file_name):
    commission_dir = DefaultFileLocation().get_commissioning_dir()
    scf_path = os.path.join(commission_dir, file_name)
    return scf_path


def get_counters_info(dist_name, timeout):
    with use_admin_connection() as conn:
        return conn.get_counters_info(dist_name=dist_name, timeout=timeout)


def get_all_counters_info_for_bts():
    mrbts_id = get_mrbts_id()
    return get_counters_info(dist_name="all", timeout=200)['BTS'][f'MRBTS-{mrbts_id}'][f'NRBTS-{mrbts_id}']


def get_all_counters_info_for_cell(cell_num='1'):
    counter_info = get_all_counters_info_for_bts()
    return counter_info[f'NRCELL-{cell_num}']


def collect_value_for_counter_id(counter_result, MO_name, counter_ids_list):
    result = counter_result[MO_name]
    output_list = []
    for counter in counter_ids_list:
        counter_value = list(result[counter].values())[-1]
        output_list.append(counter_value)
    return output_list


def collect_value_for_counter_id_with_pmqap(counter_result, MO_name, PMQAP, counter_ids_list):
    result = counter_result[MO_name][PMQAP]
    output_list = []
    for counter in counter_ids_list:
        counter_value = list(result[counter].values())[-1]
        output_list.append(counter_value)
    return output_list


def get_patameters_for_nsadrb():
    with use_admin_connection() as conn:
        result = conn.get_managed_objects(class_name="NRDRB_A", timeout=60)
        parameters = [drb["parameters"] for drb in result if "A-4" in drb["distName"]]
        return [param["nsaDrbParam"] for param in parameters][0]


def change_actX2DuplicateTxNSA3x_status():
    mrbts_id = get_mrbts_id()
    dist_name = f"MRBTS-{mrbts_id}/NRBTS-{mrbts_id}/NRDRB-4"
    change_values = {'actX2DuplicateTxNSA3x': 'true', 'inactPeriodX2PdcpDuplication': 3000}
    result_dict = get_patameters_for_nsadrb()
    result_dict.update(change_values)

    actx2_delta_parameter_update = [
        {
            "distName": dist_name,
            "operation": "update",
            "parameters": [
                {
                    "parameterName": "nsaDrbParam",
                    "operation": "update",
                    "value": [result_dict]
                }
            ]
        }
    ]

    with use_admin_connection() as conn:
        conn.perform_delta_recommissioning(
            delta_file=json.dumps(actx2_delta_parameter_update),
            skip_parameter_relation_errors=True
        )


def change_actCDrx_status(status):
    mrbts_id = get_mrbts_id()
    dist_name = f"MRBTS-{mrbts_id}/NRBTS-{mrbts_id}/NRCELL-1"

    actCDrx_delta_parameter_update = [
        {
            "distName": dist_name,
            "operation": "update",
            "parameters": [
                {
                    "parameterName": "actCDrx",
                    "operation": "update",
                    "value": status
                }
            ]
        }
    ]

    with use_admin_connection() as conn:
        conn.perform_delta_recommissioning(
            delta_file=json.dumps(actCDrx_delta_parameter_update),
            skip_parameter_relation_errors=True
        )


def Check_DRX_related_counters_when_actCDrx_is_false():
    counter_result_for_cell = get_all_counters_info_for_cell()
    value_M55308C00060, value_M55308C00061 = collect_value_for_counter_id(counter_result_for_cell, 'NCELA',
                                                                          ['M55308C00060', 'M55308C00061'])
    value_M55356C00005, value_M55356C00007 = collect_value_for_counter_id_with_pmqap(counter_result_for_cell,
                                                                                     'NRPMQAP-17', 'UESPQ',
                                                                                     ['M55356C00005', 'M55356C00007'])

    logger.console(f"Counters: M55308C00060 {value_M55308C00060}\n M55308C00061 {value_M55308C00061}\n"
                   f"M55356C00005 {value_M55356C00005}\n M55356C00007 {value_M55356C00007}\n")

    assert int(value_M55308C00060) == 0, f"Counter M55308C00060 should be 0"
    assert int(value_M55308C00061) == 0, f"Counter M55308C00061 should be 0"
    assert int(value_M55356C00005) == 0, f"Counter M55356C00005 should be 0"
    assert int(value_M55356C00007) == 0, f"Counter M55356C00007 should be 0"


def Check_DRX_related_counters_when_actCDrx_is_true():
    counter_result_for_cell = get_all_counters_info_for_cell()
    value_M55308C00060, value_M55308C00061 = collect_value_for_counter_id(counter_result_for_cell, 'NCELA',
                                                                          ['M55308C00060', 'M55308C00061'])
    value_M55356C00005_17, value_M55356C00007_17 = collect_value_for_counter_id_with_pmqap(counter_result_for_cell,
                                                                                           'NRPMQAP-17',
                                                                                           'UESPQ',
                                                                                           ['M55356C00005',
                                                                                            'M55356C00007'])
    value_M55356C00005_19, value_M55356C00007_19 = collect_value_for_counter_id_with_pmqap(counter_result_for_cell,
                                                                                           'NRPMQAP-19', 'UESPQ',
                                                                                           ['M55356C00005',
                                                                                            'M55356C00007'])

    logger.console(f"Counters: M55308C00060 {value_M55308C00060}\n M55308C00061 {value_M55308C00061}\n"
                   f"M55356C00005_17 {value_M55356C00005_17}\n M55356C00007_17 {value_M55356C00007_17}\n"
                   f"M55356C00005_19 {value_M55356C00005_19}\n M55356C00007_19 {value_M55356C00007_19}\n")

    assert int(value_M55308C00060) > 0, f"Counter M55308C00060 should not be 0"
    assert int(value_M55308C00061) > 0, f"Counter M55308C00061 should not be 0"
    assert int(value_M55308C00060) == int(value_M55356C00005_17) + int(value_M55356C00005_19), \
        f"Counters should be equal"
    assert int(value_M55308C00061) == int(value_M55356C00007_17) + int(value_M55356C00007_19), \
        f"Counters should be equal"
    assert int(value_M55308C00060)/(int(value_M55308C00061)) < 300000


def _convert_pcap_to_csv(pcap_file,
                         csv_file=None,
                         fields=None,
                         filters=None,
                         options=None,
                         timeout=30 * 60,
                         device=None):
    """
    Convert pcap file to csv format.

    :param pcap_file:   path to source pcap_file
    :param csv_file:    path to destination csv file
    :param fields:      list of fields - option -e
    :param filters:     list of filters - option -Y
    :param options:     additional options used in conversion, eg -Y SCTP
    :param timeout:     conversion timeout
    """
    if device is None:
        local_pc = DeviceFactory.get_device(name='UnixLocal')
    else:
        local_pc = device

    if not csv_file:
        file_name, extension = os.path.splitext(pcap_file)

        csv_file = "{}_{}_{}.csv".format(file_name, extension.lstrip('.'), filters[0])

    tshark_options = "-E header=y -E separator=, -E quote=d -E occurrence=a"

    if fields:
        field_options = ' -T fields -e {} '.format(' -e '.join(fields))
        tshark_options = tshark_options + field_options

    if filters:
        filters_options = ' -Y "{}"'.format(' || '.join(filters))
        tshark_options = tshark_options + filters_options

    if options:
        tshark_options = tshark_options + ' ' + options

    cmd_options = "-r {} {} > {}".format(pcap_file, tshark_options, csv_file)
    convert_cmd = local_pc.get_cmd(cmd_name="tshark", cmd_params={'options': cmd_options})
    convert_cmd.start(timeout=timeout)

    chmod = local_pc.get_cmd(cmd_name='chmod', cmd_params={'permission': '777', 'filename': f"{csv_file}"})
    chmod()
    return csv_file, convert_cmd


def check_dldata_dci_info(pcap_file):
    fields = ['DlData_DciInfo.rachStatus == 2', 'DlData_DciInfo.rachStatus == 0']
    filters = ['DlData_DciInfo.rachStatus']
    _convert_pcap_to_csv(pcap_file=pcap_file, fields=fields, filters=filters)


def find_pcap_file(output_dir):
    pcap_folder_path = os.path.join(output_dir, 'BipCollectorAdmin_GNB0_DU0')
    dir_list = os.listdir(pcap_folder_path)
    pcpa_file = [item for item in dir_list if 'pcap' in item][0]
    return os.path.join(pcap_folder_path, pcpa_file)


def check_l2ps_cellsetupreq_parameters(pcap_full_path, pdml_path):
    find_message = "itf_l2_ps_cell_cellsetupreq"
    pdml_path_file = convert_pcap_to_pdml_for_message(pcap_path=pcap_full_path, pdml_path=pdml_path,
                                                      message=find_message)

    verify_load_info = BuiltIn().get_variable_value("${LOAD_INFO_DICT}")

    structure = {find_message: [
                     {'itf_l2_ps_artificialload_artificialloadinfo.totalLoad': 'show',
                      'itf_l2_ps_artificialload_artificialloadinfo.mcsIndex': 'show'}
                 ]}

    output = extract_structure_from_pdml(pdml_path_file, structure)
    logger.debug(f"Extract structure: {output}")
    result_of_load_info = list(output.values())[0]
    compare_result = [info for info in result_of_load_info if verify_load_info != info]
    if not compare_result:
        raise Exception(f'Result should be the same but does not: {compare_result}')


def verify_numOfBitsOfUciInformation_parameter(pcap_full_path, pdml_path):
    find_message = "uldata_pucchreceivereql1sw"
    pdml_path_file = convert_pcap_to_pdml_for_message(pcap_path=pcap_full_path, pdml_path=pdml_path,
                                                      message=find_message)

    numOfBitsOfUciInformation = BuiltIn().get_variable_value("${numOfBitsOfUciInformation}")
    numOfPrb = BuiltIn().get_variable_value("${numOfPrb}")

    structure = {
        find_message: [
            {
                'UlData_pucchReceiveReqPucchResourceL1sw_t.numOfBitsOfUciInformation': 'show',
                'UlData_pucchReceiveReqPucchResourceL1sw_t.numOfPrb': 'show'
            }
        ]
    }

    output = extract_structure_from_pdml(pdml_path_file, structure)
    result = list(output.values())[0]
    find_expected_value = [
        ul_data for ul_data in result
        if (
            numOfBitsOfUciInformation in ul_data.values() and numOfPrb in ul_data.values()
        )
    ]
    assert find_expected_value, f"Not found numOfBitsOfUciInformation {numOfBitsOfUciInformation}"


def check_l2ps_cellgroupreconfigreq_parameters(pcap_full_path, pdml_path):
    pdml_path_file = convert_pcap_to_pdml_for_message(pcap_path=pcap_full_path, pdml_path=pdml_path,
                                                      message="itf_l2_ps_cell_cellgroupsetupreq")

    find_message = "itf_l2_ps_cell_cellgroupsetupreq"
    structure = {find_message: [{'beamIndexListForArtificialLoad.Length': 'show'}]}
    output = extract_structure_from_pdml(pdml_path_file, structure)
    logger.debug(f"Extract structure: {output}")
    result_of_beam_index = list(output.values())[0]
    logger.debug(result_of_beam_index)


def convert_pcap_to_pdml_for_message(pcap_path, pdml_path, message):
    tshark_path = get_tshark_path()
    tshark_args = '-r {} -V -q -Y "{}" -T pdml > {}'.format(pcap_path, message, pdml_path)
    os.system('{} {}'.format(tshark_path, tshark_args))
    return pdml_path


def get_tshark_path():
    tshark_location = os.popen('whereis tshark').read()
    tshark_location = tshark_location.split(' ')[1]
    return tshark_location


def extract_structure_from_pdml(pdml_file, structure):
    root = ET.parse(pdml_file).getroot()
    structure = _extract_structure_from_etree_element(root, structure)
    return structure


def _extract_structure_from_etree_element(etree_elem, structure):
    output_structure = {}
    for elem_name, value in structure.items():
        if isinstance(value, str):
            pdml_value = _search_deep_in_xml_for_message(etree_elem, elem_name, value)
        if isinstance(value, list):
            pdml_elements = _find_elements(etree_elem, elem_name)
            pdml_value = [_extract_structure_from_etree_element(element, value[0]) for element in pdml_elements]
        output_structure.update({elem_name: pdml_value})
    return output_structure


def _search_deep_in_xml_for_message(root, message, attrib_name):
    if len(root) > 1:
        for element in root:
            found = _search_deep_in_xml_for_message(element, message, attrib_name)
            if found is not None:
                return found
    else:
        for item in root.iter():
            if str(item.attrib.get('name', '')).endswith(message):
                return item.attrib[attrib_name]


def _find_elements(root, element_name):
    find_expression = ".//proto[contains(@showname, '{}')]".format(element_name)
    return root.xpath(find_expression)


def get_commissioning_path_for_test_case(scf_name):
    current_suite_file = Path(BuiltIn().get_variable_value("${SUITE SOURCE}"))
    current_suite_dir = current_suite_file.parent.absolute()
    scf_file_path = f"{current_suite_dir}/commisionings/{scf_name}"

    if not os.path.isfile(scf_file_path):
        raise FileNotFoundError(f'There are no file')
    return scf_file_path


def convert_bip_to_csv(pcap_file, csv_file_name, fields, filters):
    csv_file_path, _ = _convert_pcap_to_csv(pcap_file=pcap_file,
                                            csv_file=csv_file_name,
                                            fields=fields, filters=filters)
    return csv_file_path


def convert_to_csv_and_analysis(pcap_file):
    branch = (GnbDuOperations().get_bts_sw_version()).split("_")[0]
    if branch > "SBTS25R1":
        fields = ['3gpp.slot', '3gpp.subcellid', 'DlData_SsBlockSendReqL1sw_t.patternId_item',
                  'DlData_SsBlockSendReqL1sw_t.ceAxCIndex_item']
        filters = ['dldata_ssblocksendreql1sw']
        csv_file_name = os.path.join("/home/ute", 'mirroring_L2L1_trunk.csv')
        csv_full_path = convert_bip_to_csv(pcap_file, csv_file_name, fields, filters)
        ta_a2a().check_log_with_au2anlysis(
            ini_path=os.path.join(os.path.dirname(os.path.abspath(__file__)), 'A009_trunk.ini'),
            log_need_to_check="i",
            ini_modify=csv_full_path,
            save_log_directory="/home/ute")
    else:
        fields = ['3gpp.slot', '3gpp.subcellid', 'DlData_SsBlockSendReq_t.patternId_item',
                  'DlData_SsBlockSendReq_t.ceAxCIndex_item']
        filters = ['dldata_ssblocksendreq']
        csv_file_name = os.path.join("/home/ute", 'mirroring_L2L1.csv')
        csv_full_path = convert_bip_to_csv(pcap_file, csv_file_name, fields, filters)
        ta_a2a().check_log_with_au2anlysis(
            ini_path=os.path.join(os.path.dirname(os.path.abspath(__file__)), 'A009.ini'),
            log_need_to_check="i",
            ini_modify=csv_full_path,
            save_log_directory="/home/ute")
