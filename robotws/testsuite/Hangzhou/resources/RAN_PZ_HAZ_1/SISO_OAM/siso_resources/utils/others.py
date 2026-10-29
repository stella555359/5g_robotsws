import json
import socket
import os
import shutil
import pysftp
import time
import subprocess
import re
import datetime
from robot.libraries.XML import XML
from robot.libraries.BuiltIn import BuiltIn


def convert_to_dict(json_str):
    return json.load(json_str)


def get_udp_port(direction):
    host_name = socket.gethostname()
    print(host_name)
    reg_str = "(CLOUD|UTE4G|UTE5G|Cloud|UTESRAN)(\\d+)"
    import re

    result = re.search(reg_str, host_name)
    port = 0
    if result:
        port = int(result.group(2))
    else:
        raise Exception("The hostname is not correct")
    # print(direction, port)
    # print(direction == "UL")
    if direction == "UL":
        return 5000 + (port % 1000) * 2 + port/1000 * 1000
    elif direction == "DL":
        return 5000 + (port % 1000) * 2 + 1 + port/1000 * 1000
    else:
        raise Exception("That doesn't  support direction type:{}".format(direction))


def sftp_download(host, port, usr, pwd, remote, local=None, **kwargs):
    """sftp download"""
    if local is not None and os.path.split(local)[0] != "":
        if os.path.exists(os.path.split(local)[0]) is False:
            os.makedirs(os.path.split(local)[0])
        if os.path.split(local)[1] == "":
            local = local + "/" + os.path.split(remote)[1]
    elif local is not None and os.path.split(local)[0] == "":
        local = os.getcwd() + "/" + local
    else:
        local = os.getcwd() + "/" + os.path.split(remote)[1]

    local = os.path.normpath(local)

    try:
        cnopts = pysftp.CnOpts()
        cnopts.hostkeys = None
        pysftp_con = pysftp.Connection(
            host, username=usr, password=pwd, port=int(port), cnopts=cnopts
        )
    except Exception as err:
        pysftp_con = pysftp.Connection(host, username=usr, password=pwd, port=int(port))
    with pysftp_con as sftp:
        if os.path.split(remote)[1] != "":
            sftp.get(remote, local)
            ret = local
        else:
            localpath = os.path.join(local, remote.split("/")[-2])
            if os.path.isdir(localpath) is True:
                shutil.rmtree(localpath)
            sftp.get_r(remote, local)
            ret = None
        sftp.close()
        return ret


def recalculate_muticarrier(cell_list):
    for cell_info in cell_list:
        if "multi_carries" in cell_info.keys():
            continue
        carrier_list = [cell_info]
        carrier_pci_list = [cell_info["phyCellId"]]
        for i in range(0, len(cell_list)):
            current_cell_info = cell_list[i]
            if (
                current_cell_info["phyCellId"] == cell_info["phyCellId"]
                or "multi_carries" in current_cell_info.keys()
            ):
                continue
            for RF in current_cell_info["RF"]:
                if (
                    cell_info["RF"][0]["serialNumber"] == RF["serialNumber"]
                    and cell_info["RF"][0]["antl"][0] in RF["antl"]
                ):
                    carrier_list.append(current_cell_info)
                    carrier_pci_list.append(current_cell_info["phyCellId"])
        for carrier in carrier_list:
            carrier["multi_carries"] = carrier_pci_list
            carrier["carries"] = len(carrier_pci_list)
        del carrier_list[:]


def resort_rf_topo_for_one_cell(cell_info, bts_rf_topos):
    rf_info_for_cell = cell_info["RF"]
    rf_list = []
    rf_topo_list_for_bts = []
    rf_topo_list_for_cell = []
    for rf_info in rf_info_for_cell:
        print(rf_info["serialNumber"])
        if rf_info["serialNumber"] not in rf_list:
            rf_list.append(rf_info["serialNumber"])

    for bts_rf_topo in bts_rf_topos:
        rf_topo_list_for_bts.append(bts_rf_topo.split("->"))

    while rf_list:
        rf_serial_num = rf_list[0]
        current_topo = None
        for rf_topo_info_for_bts in rf_topo_list_for_bts:
            if rf_serial_num in rf_topo_info_for_bts:
                current_topo = rf_topo_info_for_bts
                break
        if not current_topo:
            rf_topo_list_for_cell.append([rf_serial_num])
            rf_list.remove(rf_serial_num)
        else:
            rf_topo_list_for_cell.append([])
            for chain_fr in current_topo:
                if chain_fr in rf_list:
                    rf_topo_list_for_cell[-1].append(chain_fr)
                    rf_list.remove(chain_fr)

    return rf_topo_list_for_cell


def get_cell_bar_parameter_list(cell_bar_list, bar_type):
    para_list = {}
    for cell_info in cell_bar_list:
        para_list[cell_info["distName"]] = {"cellBarred": bar_type}

    return para_list


def compare_time(current_date_time, date_time):
    if int(time.mktime(time.strptime(current_date_time, "%d.%m.%Y %H:%M:%S"))) >= int(
        time.mktime(time.strptime(date_time, "%d.%m.%Y %H:%M:%S"))
    ):
        return False
    else:
        return True


def get_cell_rf_diagnostic_test_result(cell_id, test_result):
    date_time = "1.1.1970 0:0:0"
    t_info = {}
    reg_str = r"(\d+\.\d+\.\d+ \d+:\d+:\d+)"
    for t_res in test_result:
        current_time = re.search(reg_str, t_res["results"]["actualStartTime"]).group(1)
        if t_res['cellId'] == int(cell_id) and compare_time(date_time, current_time):
            date_time = current_time
            t_info = t_res
    return t_info


def sw_package_download(sw_version, target_dir, package_type="Normal", package_variant="A54", timeout=3600):
    url = "http://files.ute.nsn-rdnet.net/builds/enb/base/{}/{}_release_BTSSM_downloadable{}.zip"
    artifactory_hz = "https://artifactory-hz1.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-remote/build/"
    url_wft = "{base}/{release}/{build}/{build}_release_BTSSM_downloadable{pack_type}_{pack_variant}.zip"
    release = sw_version.split("_")[0]
    if 'FSM3' in sw_version:
        release = release + '_FSM3'
    suffix = ""
    if package_type == "T1":
        suffix = "_testpackage_T1"
    if package_type == "T2":
        suffix = "_testpackage_T2"

    if package_type == "CMCC":
        suffix = "_CMCC"
        package_variant = "A50"
    elif package_type == "E":
        package_variant += "E"

#    if package_type == "Normal" and package_variant == "A54":
#        package_url = url.format(sw_version, sw_version, suffix)
#    else:
    package_url = url_wft.format(base=artifactory_hz,
                                 release=release,
                                 build=sw_version,
                                 pack_type=suffix,
                                 pack_variant=package_variant)
    print(package_url)
    wget_cmd = ['timeout', str(timeout), 'wget', '-P', str(target_dir), str(package_url)]
    proc = subprocess.Popen(wget_cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    out, err = proc.communicate()
    if proc.returncode != 0:
        raise Exception('Software package has not been downloaded.\n STDOUT: {}\n STDERR: {}\n RETURN_CODE: {}'.
                        format(out, err, proc.returncode))

    return os.path.join(target_dir, package_url.split("/")[-1])


def get_reset_counter_info(file_content):
    info_list = file_content.split("\n")
    reset_info_list = []
    i = 0
    start_pos = 0
    end_pos = len(info_list) - 1
    for line in info_list:
        i += 1
        if line.startswith("RESET COUNTER"):
            start_pos = i + 1
        elif line.startswith("SW VERSION"):
            end_pos = i - 2
            break
    if end_pos < start_pos:
        raise Exception("no reset info")
    pattern = re.compile(r"(\d\S+?)\s+?(\S+?)\s+?(\S+?)\s+?(\S+?)\s+?(\S+?)\s+?(.*)")
    i = start_pos
    while i <= end_pos:
        result = re.match(pattern, info_list[i])
        if result:
            reset_info_list.append(result.groups())
        i += 1
    return reset_info_list


def compare_reset_counter_info(previous_reset_list, current_reset_list):
    if len(previous_reset_list) == 0:
        return len(current_reset_list)

    i = 0
    last_reset_info = previous_reset_list[-1]
    for reset_info in current_reset_list:
        i += 1
        if reset_info[0] == last_reset_info[0] and reset_info[3] == last_reset_info[3]:
            break

    return len(current_reset_list) - i


def check_rf_diagnostic_band_config_info(scfc_path, dist_name, bands_thresholds):
    if not bands_thresholds:
        return

    expression = '//managedObject[@distName="{}"]/list[@name="bandRfTestThresholds"]/item'. \
        format(dist_name)

    band_items = XML(use_lxml=True).evaluate_xpath(source=scfc_path, expression=expression)
    band_item_list = []
    for band_info in band_items:
        band_class = XML(use_lxml=True).get_element_text(source=band_info, xpath='p[@name="bandClass"]')
        totalRFPowerHighThreshold = XML(use_lxml=True).get_element_text(source=band_info,
                                                                        xpath='p[@name="totalRFPowerHighThreshold"]')
        totalRFPowerLowThreshold = XML(use_lxml=True).get_element_text(source=band_info,
                                                                       xpath='p[@name="totalRFPowerLowThreshold"]')
        band_item_list.append((band_class, totalRFPowerHighThreshold, totalRFPowerLowThreshold))
    print(band_item_list)
    for bands_threshold in bands_thresholds:
        is_find = False
        for band_item in band_item_list:
            if bands_threshold[0] == band_item[0] and bands_threshold[1] == band_item[1] and \
                    bands_threshold[2] == band_item[2]:
                is_find = True

        if not is_find:
            raise Exception("{} set failed".format(bands_threshold))


def get_change_channelgroup_id(cell_info, fr_sn_list, smod_product_name):
    channelgroup = cell_info["channelgroup"]
    change_channelgroup_id = []
    if "ASOE" in smod_product_name:
        channel_group_list = list(channelgroup.keys())
        count = int(len(channel_group_list)/2)
        change_channelgroup_id = channel_group_list[:count]
    else:
        for channel_group_id, fr_list in channelgroup.items():
            for fr_info in fr_list:
                if fr_info["serialNumber"] in fr_sn_list:
                    change_channelgroup_id.append(channel_group_id)
                    break
    return change_channelgroup_id


def calculate_duration(start, end):
    try:
        start = datetime.datetime.strptime(start, "%Y-%m-%dT%H:%M:%S")
        end = datetime.datetime.strptime(end, "%Y-%m-%dT%H:%M:%S")
        duration = end - start
        print(start, end)
        print(duration.seconds)
        return duration.seconds
    except TypeError as e:
        print("except:", e)
        print("get reset time failed:", start, end)
        return None


def get_timestamp(line):
    """
    This keyword is used to find timestamp like 2022-07-14T06:19:33.393Z.
    """
    regex = "(\\d{4}-\\d{1,2}-\\d{1,2}T\\d{1,2}:\\d{1,2}:\\d{1,2})"
    t = re.search(regex, line)
    if t:
        return t.group(1)
    return None


def assert_ru_startup_time(logs, start_time="", end_time="", expected_duration=180):
    log_list = logs.split("\n")
    for log in log_list:
        if not start_time and re.search(r"RU_L-\d+/RESET_TASK|RESET_IND", log):
            start_time = get_timestamp(log)
        if not end_time and "Radio Module detected" in log:
            end_time = get_timestamp(log)
        if start_time and end_time:
            break

    duration = calculate_duration(start_time, end_time)
    print(start_time)
    print(end_time)
    BuiltIn().log_to_console("start time: {}, end_time: {}, duration: {}".format(start_time, end_time, duration))
    assert start_time != "", "start_time is empty"
    assert end_time != "", "end_time is empty"
    assert duration < expected_duration, "duration: {} is greater than {}".format(duration, expected_duration)
    assert duration > 0, "duration: {} is less than 0".format(duration)


def update_related_cells(cell_info, cell_list):
    all_cell_list = [cell_info["phyCellId"]]
    if "related_cell" in cell_info.keys():
        del cell_info["related_cell"][:]
    else:
        cell_info["related_cell"] = []
    cell_info["related_cell"].extend(cell_list)
    all_cell_list.extend(cell_list)

    return cell_info, all_cell_list


def check_if_in_list(list1, a1, list2):
    for list_info in list1:
        if len(list_info) != len(list2) + 1:
            continue

        if a1 not in list_info:
            continue
        count = 1
        for list2_value in list2:
            if list2_value in list_info:
                count += 1
        if count == len(list_info):
            return True
    return False


def should_contiain_ip(ip_info):
    if not len(ip_info):
        return False
    return True


def log_check_l3_cache_qos(logs, message, node_id_list, cache_config_id="0"):
    if message == "API_HWCTRL_SET_CACHE_CONFIG_REQ_MSG received":
        pattern = r"API_HWCTRL_SET_CACHE_CONFIG_REQ_MSG received.*nodeId: {}.*cacheConfigId: %s" % cache_config_id
    else:
        pattern = r"Received API_HWCTRL_SET_CACHE_CONFIG_RESP_MSG from {}.*Status: NoError"
    log_list = logs.split("\n")
    for node_id in node_id_list:
        flag = False
        for log in log_list:
            if message in log:
                full_pattern = pattern.format(node_id)
                if re.search(full_pattern, log):
                    flag = True
        assert flag, "nodeId: {} not found or cacheConfigId: {} error".format(node_id, cache_config_id)


def _get_value_by_key(ue_key, json_repr):
    def _decode_dict(a_dict):
        try:
            results[ue_key] = a_dict[ue_key]
        except KeyError:
            pass
        return a_dict
    results = dict()
    json.loads(json_repr, object_hook=_decode_dict)
    return results.get(ue_key)


def get_ue_common_config(ue_info, index=0):
    """This Keyword can read the android definition that not supported by taf.ue but can supported by ute-ue,
    inspite of the ue defined in testline_configuration_5G __init__ or yml format, combine the ue parameters in
    unique structure but not only e.g. ${tl.ues[<index>].serial_number} but also yml file contents to use the
    android_common_keyword possibility
    :param ue_info: ue_info=${tl.ues[${ue_index}]}
    :param index: list index from tl.ues[], it will use the index UE for traffic"""
    ue_output = {}
    index = int(index)
    if isinstance(ue_info, dict):
        _ues = []
        inline_config = _get_value_by_key('inline_config', json.dumps(ue_info, sort_keys=False))
        for k, v in inline_config.items():
            _ues.append(json.dumps(v))
        ue_output['capabilities'] = _get_value_by_key('CAPABILITIES', _ues[index])
        ue_output['cpc_ip'] = _get_value_by_key('ue_pc_ip', _ues[index])
        ue_output['cpc_username'] = _get_value_by_key('login', _ues[index])
        ue_output['cpc_password'] = _get_value_by_key('password', _ues[index])
        ue_output['data_transfer'] = _get_value_by_key('data_transfer', _ues[index])
        ue_output['ue_type'] = "ute"
        ue_output['serial_number'] = _get_value_by_key('serial_number', _ues[index]) or "1234567890"
        _qci = _get_value_by_key('qci', _ues[index])
        ue_output['qci'] = True if _qci and _qci.get('5') and _qci.get('6') else False
    else:
        ue_output['capabilities'] = ue_info.capabilities
        ue_output['cpc_ip'] = ue_info.ssh_connection_details.addr
        ue_output['cpc_username'] = ue_info.ssh_connection_details.username
        ue_output['cpc_password'] = ue_info.ssh_connection_details.password
        ue_output['ue_type'] = "taf"
        ue_output['serial_number'] = ue_info.serial_number
    return ue_output


def modify_xml(source_xml, target_xml, modify_parameters):
    xml = XML(use_lxml=True)
    parser = xml.parse_xml(source_xml)
    for parameter in modify_parameters:
        parameter = str(parameter)

        if parameter == '':
            continue
        error_msg = "parameter need modify should given like:" + \
                    " 'xml_component|value|xpath', your input '%s'" % parameter
        assert parameter.count("|") >= 2, error_msg
        element_component, parameter_value, xpath = parameter.split("|", 2)
        elements = xml.get_elements(source=parser, xpath=xpath)
        for element in elements:
            if element_component.lower().strip() == "text":
                xml.set_element_text(source=element, text=parameter_value)
            elif element_component.lower().strip() == "tag":
                xml.set_element_tag(source=element, tag=parameter_value)
            elif element_component.lower().strip().startswith("attr"):
                _, attrib_name = element_component.split("=", 1)
                xml.set_element_attribute(source=element, name=attrib_name, value=parameter_value)

    xml.save_xml(parser, target_xml)


def verify_vendor_value(parameters, para_name, expected_value):
    para_name_list = para_name.split(".")
    error_msg = "actual value({}) not equal expected value({})"
    if len(para_name_list) == 1:
        actual_value = str(parameters[para_name_list[0]])
        assert actual_value == expected_value, error_msg.format(actual_value, expected_value)
    elif len(para_name_list) == 2:
        para_list = parameters[para_name_list[0]]
        for para in para_list:
            actual_value = str(para[para_name_list[1]])
            assert actual_value == expected_value, error_msg.format(actual_value, expected_value)
    else:
        raise Exception("para_name should given like: value or value.value")
