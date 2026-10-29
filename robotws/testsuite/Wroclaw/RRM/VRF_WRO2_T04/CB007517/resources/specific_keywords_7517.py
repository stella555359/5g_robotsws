import random
import json
import testsuite.Wroclaw.RRM.resources.webUI_operations as webUI
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.regression.global_variables import bts_prefix
from testsuite.Wroclaw.RRM.resources.log.helper import LogHelper
from testsuite.Wroclaw.RRM.resources.log.matchers import PcapMessageMatcher as pm
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.admin_api import AdminApi
from robot.api import logger


def verify_a4_measurements(pcap_file):
    with LogHelper() as lh:
        filtered = lh.add_pcap(
            pcap_file_path=pcap_file,
            lua=None,
            shark_filter="x2ap.SgNBModificationRequestAcknowledge_element",
            ts_output_data_file_path=None,
            clean_up_tmp_file=False,
        )
    a4_event = filtered.find_one(
        pm("eventTriggered", name_line_pattern="empty").containing("eventA4")
    )
    assert a4_event, "event A4 not used during HO"


def verify_a4_meas_max_number(no_cells, pcap_file, a4_meas_max_number):
    with LogHelper() as lh:
        filtered = lh.add_pcap(
            pcap_file_path=pcap_file,
            lua=None,
            shark_filter="x2ap.SgNBModificationRequestAcknowledge_element && nr-rrc.measuredFrequenciesSN == "
            + no_cells,
            ts_output_data_file_path=None,
            clean_up_tmp_file=False,
        )
    a4_event = filtered.find_exactly(
        int(a4_meas_max_number), pm("RRCReconfiguration", name_line_pattern="empty")
    )
    assert a4_event


def create_delta(distname, parameter_name, parameter_value):
    parameter_delta = {
        "distName": distname,
        "operation": "update",
        "parameters": [
            {
                "parameterName": parameter_name,
                "value": parameter_value,
                "operation": "update",
            }
        ],
    }
    return parameter_delta


def set_random_parameters_in_webui():
    max_number = random.randint(2, 6)
    retry_timer = random.randint(10, 15)
    delta_list = []
    for cell in range(webUI.get_cells_number()):
        distname = "{}/NRCELL-{}".format(bts_prefix, str(cell + 50))
        delta_list.append(
            create_delta(
                distname,
                "a4PeriodicMeasControlNSA",
                [
                    {
                        "a4Fr1SupervisionTimer": 4000,
                        "a4Fr2SupervisionTimer": 6000,
                        "a4MeasMaxNumber": max_number,
                        "a4RetryTimer": retry_timer,
                    }
                ],
            )
        )
        delta = json.dumps(delta_list)
    with AdminApi() as web_api:
        web_api.perform_delta_recommissioning(delta_file=delta)
    log_collecting_time = str((max_number * retry_timer) + 2 * retry_timer)
    logger.info(
        "\n\nParameters set as random value: \n a4MeasMaxNumber: {} \n a4RetryTimer: {}s \n".format(
            max_number, retry_timer
        ),
        also_console=True,
    )
    return max_number, retry_timer, log_collecting_time
