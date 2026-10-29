import json
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.admin_session import AdminSession
from testsuite.Wroclaw.RRM.resources.pcap_verification.tsharkWithLuaVerifier import TSharkCommandAssembler
from testsuite.Wroclaw.RRM.resources.pcap_verification.message_to_tree import message_to_tree
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.regression.global_variables import bts_prefix
from robot.api import logger
from taf.sw.scout import scout as taf_scout
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.utilities import get_testline_name
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.counters import get_sum_of_n_last_pm_counters_values
from kpi_pm_counters import SPLITMODE_COUNTERS_GROUP, LATENCY_COUNTERS_GROUP
import time


nsa_drb_params = {
    'actPrioritizeX2AfterInactivity': 'false',
    'actX2DuplicateTxNSA3x': 'true',
    'dlDataSplitBufferBuildUpThreshold': 5,
    'dlDataSplitBufferBuildUpThresholdPrioritizeX2': 5,
    'dlDataSplitGainThreshold': 5,
    'dlNumOfCongOrGainDdds': 2,
    'inactivityThresholdForPrioritizeX2': 300,
    'inactivityThresholdForRestartPrioritizeX2': 100,
    'inactPeriodX2PdcpDuplication': 300,
    'initialDLTrafficRouting': 'initDLoverF1U',
    'nsa3xBearerAllowed': 'true',
    'prioritizeX2Period': 500,
}

data_split_settings = {
    "NRDRB-3": {
        "dlDataSplitMode": "dlOverF1U",
        "actX2DuplicateTxNSA3x": "false",
        "ulDataPath": "ulOverLteNr_PrimaryPathOverNr",
        "ulDataPathForUlSplitNotCapableUe": "ulPrimaryPathOverNr",
        "ulDataSplitThreshold": "b0",
    },
    "NRDRB-4": {
        "dlDataSplitMode": "dlOverF1UX2U",
        "actX2DuplicateTxNSA3x": "true",
        "ulDataPath": "ulOverLteNr_PrimaryPathOverNr",
        "ulDataPathForUlSplitNotCapableUe": "ulPrimaryPathOverNr",
        "ulDataSplitThreshold": "b0",
    },
    "NRDRB-6": {
        "dlDataSplitMode": "dlOverX2U",
        "actX2DuplicateTxNSA3x": "false",
        "ulDataPath": "ulOverNr",
        "ulDataPathForUlSplitNotCapableUe": "",
        "ulDataSplitThreshold": "infinity",
    },
}

data_split_default = {
    "dlDataSplitMode": "dlOverF1UX2U",
    "actX2DuplicateTxNSA3x": "true",
    "ulDataPath": "ulOverLteNr_PrimaryPathOverNr",
    "ulDataPathForUlSplitNotCapableUe": "ulPrimaryPathOverNr",
    "ulDataSplitThreshold": "b0",
}


def calculate_latency_kpis(cell="700"):
    values = get_sum_of_n_last_pm_counters_values(counters=prepare_latency_counters_list())
    nr_59 = sum(v for k, v in values.items() if k.startswith("M55311C100")) / sum(
        v for k, v in values.items() if k.startswith("M55311C130")
    )
    nr_973 = sum(
        inner.get("NRCELL-{}".format(cell), 0)
        for k, inner in values.items()
        if k.startswith("M55310C050") and isinstance(inner, dict)
    ) / sum(
        inner.get("NRCELL-{}".format(cell), 0)
        for k, inner in values.items()
        if k.startswith("M55310C170") and isinstance(inner, dict)
    )

    return round(nr_59, 2), round(nr_973, 2)


def prepare_latency_counters_list():
    counters = []
    for pm in LATENCY_COUNTERS_GROUP:
        for i in range(1, 21):
            counters.append(pm + str(i).zfill(2))
    return counters


def _prepare_list_elements(nrdrb, default):
    list_elements = nsa_drb_params.copy()
    list_elements["dlDataSplitMode"] = (
        data_split_settings[nrdrb]["dlDataSplitMode"]
        if not default
        else data_split_default["dlDataSplitMode"]
    )
    list_elements["actX2DuplicateTxNSA3x"] = (
        data_split_settings[nrdrb]["actX2DuplicateTxNSA3x"]
        if not default
        else data_split_default["actX2DuplicateTxNSA3x"]
    )
    list_elements["ulDataPath"] = (
        data_split_settings[nrdrb]["ulDataPath"]
        if not default
        else data_split_default["ulDataPath"]
    )
    list_elements["ulDataPathForUlSplitNotCapableUe"] = (
        data_split_settings[nrdrb]["ulDataPathForUlSplitNotCapableUe"]
        if not default
        else data_split_default["ulDataPathForUlSplitNotCapableUe"]
    )
    list_elements["ulDataSplitThreshold"] = (
        data_split_settings[nrdrb]["ulDataSplitThreshold"]
        if not default
        else data_split_default["ulDataSplitThreshold"]
    )
    dl_split_mode = data_split_settings[nrdrb]["dlDataSplitMode"]
    if dl_split_mode == 'dlOverX2U' or dl_split_mode == 'dlOverF1U':
        list_elements
    else:
        list_elements['dlPreferredPath'] = 'F1-U'
    if default:
        list_elements['dlPreferredPath'] = 'F1-U'
    return list_elements


def create_delta(distname, parameter_name, parameter_value):
    parameter_delta = {
        "distName": distname,
        "operation": "update",
        "parameters": [
            {
                "parameterName": parameter_name,
                "operation": "update",
                "value": parameter_value
            }
        ]
    }
    return parameter_delta


def set_data_split_mode_parameters(default=False):
    delta_list = []
    for nrdrb in data_split_settings:
        list_elements = _prepare_list_elements(nrdrb, default)
        distname = "{}/{}".format(bts_prefix, nrdrb)
        delta_list.append(create_delta(distname, "nsaDrbParam", [list_elements]))
    delta = json.dumps(delta_list)
    with AdminSession() as admin:
        admin.perform_delta_recommissioning(delta_file=delta)


def prepare_counters_list():
    counters = []
    for pm in SPLITMODE_COUNTERS_GROUP:
        for i in range(1, 21):
            counters.append(pm + str(i).zfill(2))
    return counters


def check_qos_group(pcap_file):
    filter = 'x2ap.SgNBAdditionRequestAcknowledge_element'
    output = TSharkCommandAssembler()\
        .with_filter(filter) \
        .with_pcap_file(pcap_file) \
        .build()
    return message_to_tree(output).find('qCI').filter('mCG-E-RAB-Level-QoS-Parameters').first()['val']


def validate_counters_for_no_tput_qci(counter_values):
    for qci in range(1, 21):
        data_qci = [6, 7, 9]
        if qci == 5:
            for pm in SPLITMODE_COUNTERS_GROUP:
                assert counter_values[pm + str(qci).zfill(2)] >= 0, 'wrong data'
        elif qci in data_qci:
            logger.info("calculation in other function", also_console=False)
        else:
            for pm in SPLITMODE_COUNTERS_GROUP:
                assert counter_values[pm + str(qci).zfill(2)] == 0, 'wrong data'


def calculate_tput_from_counters(pm_values, ues_no, split_mode, f1_counters, x2_counters, pm_interval=300):
    if split_mode == "F1U":
        for pm in x2_counters:
            assert pm_values[pm] == 0, "{} counter should not be icremented".format(pm)
    if split_mode == "X2U":
        for pm in f1_counters:
            assert pm_values[pm] == 0, "{} counter should not be icremented".format(pm)
    if split_mode == "F1UX2U":
        f1x2_counters = f1_counters + x2_counters
        for pm in f1x2_counters:
            assert pm_values[pm] > 0, "{} counter should be icremented".format(pm)
    avg_tput = round(
            ((((pm_values[f1_counters[0]] + pm_values[x2_counters[0]]) / 1000) * 8) / ues_no) / pm_interval, 2)
    max_tput = round(
        (((pm_values[f1_counters[1]] + pm_values[x2_counters[1]]) / 1000000) * 8) / ues_no, 2)
    return avg_tput, max_tput


def get_kpi_values(kpi, start_time, level="bts", timeout=300, retry_interval=30):
    try:
        scout = taf_scout()
        scout.setup_scout(scout_testline_name=get_testline_name()[1])

        start_time_check = time.time()
        scout_report = None

        while scout_report is None and (time.time() - start_time_check) < timeout:
            scout_report = scout.get_kpi(kpi_code=kpi, start_time=start_time)
            if scout_report is None:
                time.sleep(retry_interval)

        if scout_report is None:
            logger.info("Timeout - KPI: {} not catched from Scout".format(kpi), also_console=True)
            return None, None
        logger.info("\n scout report:\n {}".format(scout_report), also_console=False)

        bts_values = [item["value"] for item in scout_report if item["level"] == level]
        total_sum = round(sum(bts_values), 2)
        average = round(total_sum / len(bts_values), 2)
        return total_sum, average

    finally:
        scout.teardown_scout_api()
