from robot.libraries.BuiltIn import BuiltIn
from robot.errors import ExecutionFailed
from robot.api import logger
from datetime import datetime, timedelta
from robot.libraries.OperatingSystem import OperatingSystem
import ast
import netifaces as ni
import os
import datetime as dt
import glob
import zipfile
from testsuite.Wroclaw.RRM.VRF_WRO1_T04.resources.Tokens import Tokens

PM_COUNTERS_BASIC = ['M55349C00006', '>0', 'UL_RLC_TIME_UE_TPUT_QOS06',
                     'M55349C01006', '>0', 'UL_RLC_VOL_UE_TPUT_QOS06']

LOCAL_MOID_BTS_CELL1 = 'PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1'
COUNTER_ID_DL_PDCP_VOL_UE_TPUT_QOS06 = 'M55350C01006'
COUNTER_ID_DL_PDCP_VOL_UE_TPUT_5G_QOS06 = 'M55350C03006'
COUNTER_ID_DL_PDCP_VOL_UE_TPUT_LTE_QOS06 = 'M55350C05006'
COUNTER_ID_DL_PDCP_TIME_UE_TPUT_QOS06 = 'M55350C00006'

COUNTER_ID_UL_RLC_VOL_UE_TPUT_QOS06 = 'M55349C01006'
COUNTER_ID_UL_RLC_TIME_UE_TPUT_QOS06 = 'M55349C00006'

COUNTER_ID_MAX_UL_RLC_UE_TPUT = 'M55349C02001'

COUNTER_ID_MAX_DL_PDCP_BURST_TPUT = 'M55350C02001'
COUNTER_ID_MAX_DL_PDCP_BURST_TPUT_5GLEG = 'M55350C04001'
COUNTER_ID_MAX_DL_PDCP_BURST_TPUT_LTELEG = 'M55350C06001'

COUNTER_ID_MEAS_PERIOD_NR_MAC_SDU_REPORT = 'M55309C00001'
COUNTER_ID_DL_MAC_SDU_VOL_DTCH = 'M55309C01001'
COUNTER_ID_UL_MAC_SDU_VOL_DTCH = 'M55309C02001'
COUNTER_ID_MAC_DTCH_CELL_THP_DL_MAX = 'M55309C12001'
COUNTER_ID_MAC_DTCH_CELL_THP_UL_MAX = 'M55309C12002'


def get_cu_counter(counter_id, local_moid='MRBTS-1/NRBTS-1/NRCELL-1'):
    cu = BuiltIn().get_library_instance('taf.gnb.oam.coam.cu')
    try:
        vcu_data = cu.get_counter(counter_id=counter_id, dimension_dist_name=local_moid, measurement_id=None)
    except FileNotFoundError:
        raise ExecutionFailed(
            message=f"The PM counter {counter_id} does not exist or is not visible in WebEM",
            continue_on_failure=True,
        )
    return check_data_type_and_return_counter_value(vcu_data, counter_id)


def get_du_counter(counter_id, local_moid='MRBTS-1/NRBTS-1/NRCELL-1'):
    vdu = BuiltIn().get_library_instance('taf.gnb.oam.coam.vdu')
    try:
        vdu_data = vdu.get_counter_values(counter_id=counter_id, dimension_dn=local_moid)
    except FileNotFoundError:
        raise ExecutionFailed(
            message=f"The PM counter {counter_id} does not exist or is not visible in WebEM",
            continue_on_failure=True,
        )
    return check_data_type_and_return_counter_value(vdu_data, counter_id)


def check_data_type_and_return_counter_value(data, counter_id):
    if isinstance(data, list):
        counter_value = get_counter_value_from_latest_interval(data)
    elif isinstance(data, dict):
        value = data['values']
        counter_value = get_counter_value_from_latest_interval(value)
    else:
        raise ValueError("Input is not a list or dictionary")

    if counter_value is not None:
        try:
            return int(counter_value)
        except (TypeError, ValueError):
            pass
    else:
        logger.info(f"The PM Counter {counter_id} has no value in current timestamp", html=True, also_console=True)
        return counter_value


def get_counter_value_from_latest_interval(dictionary):
    latest_pm_counter_interval = get_timestamp()
    for item in dictionary:
        if item["start_time"] == latest_pm_counter_interval:
            return item.get("value")
    return None


def get_timestamp():
    current_time = datetime.utcnow()
    rounded_minutes = current_time.minute - (current_time.minute % 5)
    rounded_time = current_time.replace(minute=rounded_minutes, second=0, microsecond=0)
    last_counter_timestamp = rounded_time - timedelta(minutes=5)
    return last_counter_timestamp.strftime("%Y-%m-%dT%H:%M:%S+00:00")


def check_throughput_counters_for_sa_ue_aic(dl_tput, ul_tput):
    DL_PDCP_VOL_UE_TPUT_QOS06 = get_cu_counter(counter_id=COUNTER_ID_DL_PDCP_VOL_UE_TPUT_QOS06)
    DL_PDCP_VOL_UE_TPUT_5G_QOS06 = get_cu_counter(counter_id=COUNTER_ID_DL_PDCP_VOL_UE_TPUT_5G_QOS06)
    DL_PDCP_TIME_UE_TPUT_QOS06 = get_cu_counter(counter_id=COUNTER_ID_DL_PDCP_TIME_UE_TPUT_QOS06)

    if DL_PDCP_TIME_UE_TPUT_QOS06 != 0:
        PDCP_UE_TPUT_QOS06 = int(DL_PDCP_VOL_UE_TPUT_QOS06) / int(DL_PDCP_TIME_UE_TPUT_QOS06)
        PDCP_VOL_UE_TPUT_5G = int(DL_PDCP_VOL_UE_TPUT_5G_QOS06) / int(DL_PDCP_TIME_UE_TPUT_QOS06)
    else:
        PDCP_UE_TPUT_QOS06 = 0
        PDCP_VOL_UE_TPUT_5G = 0

    check_ip_scheduled_throughput_based_on_counter_value_vran('DL_PDCP_VOL/TIME_UE_TPUT_QOS06', PDCP_UE_TPUT_QOS06,
                                                              dl_tput)
    check_ip_scheduled_throughput_based_on_counter_value_vran('DL_PDCP_VOL_5G/TIME_UE_TPUT_QOS06', PDCP_VOL_UE_TPUT_5G,
                                                              dl_tput)
    UL_RLC_VOL_UE_TPUT_QOS06 = get_du_counter(counter_id=COUNTER_ID_UL_RLC_VOL_UE_TPUT_QOS06)
    UL_RLC_TIME_UE_TPUT_QOS06 = get_du_counter(counter_id=COUNTER_ID_UL_RLC_TIME_UE_TPUT_QOS06)

    if UL_RLC_TIME_UE_TPUT_QOS06 != 0:
        RLC_UE_TPUT_QOS06 = int(UL_RLC_VOL_UE_TPUT_QOS06) / int(UL_RLC_TIME_UE_TPUT_QOS06)
    else:
        RLC_UE_TPUT_QOS06 = 0

    check_ip_scheduled_throughput_based_on_counter_value_vran('RLC_VOL_UE_TPUT/UL_RLC_TIME_UE_TPUT', RLC_UE_TPUT_QOS06,
                                                              ul_tput)
    MAX_DL_PDCP_BURST_TPUT = get_cu_counter(counter_id=COUNTER_ID_MAX_DL_PDCP_BURST_TPUT)
    check_counter_value(COUNTER_ID_MAX_DL_PDCP_BURST_TPUT, MAX_DL_PDCP_BURST_TPUT, dl_tput, margin="5%")
    MAX_DL_PDCP_BURST_TPUT_5GLEG = get_cu_counter(COUNTER_ID_MAX_DL_PDCP_BURST_TPUT_5GLEG)
    check_counter_value(COUNTER_ID_MAX_DL_PDCP_BURST_TPUT_5GLEG, MAX_DL_PDCP_BURST_TPUT_5GLEG, dl_tput, margin="5%")


def all_aic_thput_counters_should_be_equal_to_0():
    DL_PDCP_VOL_UE_TPUT_QOS06 = get_cu_counter(counter_id=COUNTER_ID_DL_PDCP_VOL_UE_TPUT_QOS06)
    DL_PDCP_VOL_UE_TPUT_5G_QOS06 = get_cu_counter(counter_id=COUNTER_ID_DL_PDCP_VOL_UE_TPUT_5G_QOS06)
    DL_PDCP_TIME_UE_TPUT_QOS06 = get_cu_counter(counter_id=COUNTER_ID_DL_PDCP_TIME_UE_TPUT_QOS06)
    check_counter_value(COUNTER_ID_DL_PDCP_VOL_UE_TPUT_QOS06, DL_PDCP_VOL_UE_TPUT_QOS06, 0)
    check_counter_value(COUNTER_ID_DL_PDCP_VOL_UE_TPUT_5G_QOS06, DL_PDCP_VOL_UE_TPUT_5G_QOS06, 0)
    check_counter_value(COUNTER_ID_DL_PDCP_TIME_UE_TPUT_QOS06, DL_PDCP_TIME_UE_TPUT_QOS06, 0)

    UL_RLC_VOL_UE_TPUT_QOS06 = get_du_counter(counter_id=COUNTER_ID_UL_RLC_VOL_UE_TPUT_QOS06)
    UL_RLC_TIME_UE_TPUT_QOS06 = get_du_counter(counter_id=COUNTER_ID_UL_RLC_TIME_UE_TPUT_QOS06)
    check_counter_value(COUNTER_ID_UL_RLC_VOL_UE_TPUT_QOS06, UL_RLC_VOL_UE_TPUT_QOS06, 0)
    check_counter_value(COUNTER_ID_UL_RLC_TIME_UE_TPUT_QOS06, UL_RLC_TIME_UE_TPUT_QOS06, 0)


def check_if_any_counter_from_list_is_incremented(counter_list, local_moid):
    values_list = []
    for counter_id in counter_list:
        counter_value = get_cu_counter(counter_id, local_moid)
        values_list.append(int(counter_value))
    if max(values_list) > 0:
        counter = counter_list[values_list.index(max(values_list))]
        value = max(values_list)
        logger.info(f"Counter {counter} value {value}", html=True, also_console=True)
        return counter, value
    else:
        raise ExecutionFailed(
            message="No counter in the list is incremented",
            continue_on_failure=True)


def check_ip_scheduled_throughput_based_on_counter_value_vran(counter_id, pm_counters_values, expected_value_kbps,
                                                              margin='10%'):
    expected_value_mbps = int(expected_value_kbps)/1000
    margin_range = calculate_value_margin(margin, expected_value_mbps)
    if isinstance(pm_counters_values, list):
        values = pm_counters_values
    else:
        values = [pm_counters_values]
    for counter_value in values:
        if (float(counter_value) < min(margin_range)) or (float(counter_value) > max(margin_range)):
            raise ExecutionFailed(
                message="The PM counter {} doesn't have value in range ({} - {}) Current value - {}".format(
                    counter_id, min(margin_range), max(margin_range), counter_value
                ),
                continue_on_failure=True,
            )


def get_counter_values(counter_id, local_moid, pm_counter_file):
    ta5g_pm = BuiltIn().get_library_instance('ta5g_pm_counters')
    counter_values = ta5g_pm.get_pm_counter_value(counter_id, local_moid, pm_counter_file)
    if len(counter_values) == 0:
        raise ExecutionFailed(
            message="The PM counter {} doesn't have values'".format(counter_id),
            continue_on_failure=True,
        )
    else:
        return counter_values


def calculate_value_margin(margin, value):
    margin = float(margin.strip('%')) / 100
    return float(value) * (1 - margin), float(value) * (1 + margin)


def check_counter_value(counter_id, pm_counters_values, expected_value,  margin='10%'):
    margin_range = calculate_value_margin(margin, expected_value)
    if isinstance(pm_counters_values, list):
        values = pm_counters_values
    else:
        values = [pm_counters_values]
    for counter_value in values:
        if (float(counter_value) < min(margin_range)) or (float(counter_value) > max(margin_range)):
            raise ExecutionFailed(
                message="The PM counter {} doesn't have value in range ({} - {}) Current value - {}".format(
                    counter_id, min(margin_range), max(margin_range), counter_value
                ),
                continue_on_failure=True,
            )


def convert_to_list_from_json_string(list_string):
    try:
        return ast.literal_eval(list_string)
    except SyntaxError:
        raise AssertionError("Invalid JSON format")


def get_dict_of_parameters_for_vran_du_delta(params_list, op_type):
    available_operations = ('replace', 'add')
    if op_type not in available_operations:
        raise AssertionError("Bad operation type! Available operations:", available_operations)

    dict_of_params = {}

    for param_dict in params_list:
        parameter_path = param_dict['parameter_path']
        value = param_dict['value']

        if param_dict['operation_type'] == op_type:
            dict_of_params[parameter_path] = value

    return dict_of_params


def get_parent_mo_path(dist_name):
    return dist_name[:dist_name.rfind('/')]


def get_last_mo_name_from_path(dist_name):
    return dist_name[dist_name.rfind('/')+1:dist_name.rfind('-')]


def get_instance_id_for_mo(dist_name):
    return int(dist_name[dist_name.rfind('-')+1:])


def get_last_mo_name_with_id_from_path(dist_name):
    return dist_name[dist_name.rfind('/')+1:]


def get_vm_ip():
    addresses = ni.ifaddresses('eth0')[ni.AF_INET]
    vm_ip = addresses[0]['addr']
    return vm_ip


def download_dcap(version, filename, path):
    logger.info("Downloading UTF lab", html=True, also_console=True)
    repository_url = (
        "https://artifactory-espoo2.int.net.nokia.com/artifactory/tts-binaries-releases-local/utf_lab/releases/"
    )
    cmd = "wget --header='Authorization: Bearer {token}' {rel_url}/{ver}/{filename} -O {path}".format(
        token=Tokens().ute_ca_artifactory_token, rel_url=repository_url, ver=version, filename=filename, path=path
    )
    OperatingSystem().run(cmd)
    logger.info("Downloading UTF lab finished.", html=True, also_console=True)


def install_dcap(version):
    filename = "utf_lab_installer.{ver}.sh".format(ver=version)
    path = os.path.join(os.path.expanduser("~"), filename)
    host = get_vm_ip()
    download_dcap(version, filename, path)
    logger.info("Installing UTF lab...", html=True, also_console=True)
    cmd = "sudo UTE_CLOUD=1 bash {path} {vm_ip}".format(path=path, vm_ip=host)
    rc, output = OperatingSystem().run_and_return_rc_and_output(cmd)
    assert "SUCCESS: UTF Lab {ver} installed".format(ver=version) in str(output), "UTF Lab Installation Failed."
    logger.info("UTF lab {} Installed.".format(version), html=True, also_console=True)


def extract_dcap_to_dir(path, dir):
    azip = zipfile.ZipFile(path)
    for file in azip.namelist():
        azip.extract(file, dir)
    os.path.isfile(dir)
    return dir


def check_if_l2_trace_present(dir):
    date = dt.datetime.now().strftime("%Y%m%d")
    _now = dt.datetime.now()
    path_for_logs_folder_hour = os.path.join(dir, date)
    hour_list = glob.glob('{}/{}*'.format(path_for_logs_folder_hour, _now.strftime("%H")))
    hour = ''.join(map(str, hour_list))
    if dir == '/home/ute/logs/CB009917/CB009917_L2Hi_streaming/dcap/dcap_vdu':
        path_for_logs_folder = os.path.join(dir, date, hour, 'vdu', 'l2')
    else:
        path_for_logs_folder = os.path.join(dir, date, hour, 'vcu', 'l2')
    print(path_for_logs_folder)
    l2_component_pcap = glob.glob('{}/*.pcap'.format(path_for_logs_folder))
    print(l2_component_pcap)
    is_file = os.path.isfile(''.join(l2_component_pcap))
    return is_file
