import os
import time
from pathlib import Path

from typing import Any
from robot.libraries.BuiltIn import BuiltIn
from taf.gnb.oam.coam.vdu import vdu
from taf.hw.rf_attenuator import rf_attenuator

from test_constants import *
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.dcap.dcap_manager import DCAPManager
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.dcap.log_profile import LogProfile
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.log_collectors.elt_log_collector import EltLogCollector
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.perf_cap.throughput_curves.resources.elt_verification \
    import EltLogParser
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.robot_utils import get_robot_variable
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.testline_conf import TestlineConfiguration
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.wro_logger import logger

_vdu = vdu()
_elt = EltLogCollector()
_elt_parser = EltLogParser()
_dm = DCAPManager()
_attenuator = rf_attenuator()
_tl = TestlineConfiguration()
_vcu_log_profile = LogProfile().with_vcu_snapshot().with_vcu_syslog()
_vdu_log_profile = LogProfile().with_vdu_snapshot().with_vdu_cplane().with_vdu_syslog()
traces_trunk = {'vcu': {'log_profile': _vcu_log_profile,
                        'trace_id': '',
                        'mplane': _tl.get_gnb_oam_connection_details(0)['hostname'],
                        'stop_trace_name': 'dcap_vcu_stop_trace',
                        'download_log_name': 'dcap_collect_vcu_log',
                        'cells': ['2']},
                'vdu_2': {'log_profile': _vdu_log_profile,
                          'trace_id': '',
                          'mplane': _tl.get_du_oam_connection_details(0, 1)['hostname'],
                          'stop_trace_name': 'dcap_vdu_2_stop_trace',
                          'download_log_name': 'dcap_collect_vdu_2_log',
                          'cells': ['2']},
                }


def setup() -> None:
    """
    Sets up the system by initializing attenuators, configuring feature states,
    and deattenuating the source cell.

    :return: None
    """
    initialize_attenuators()
    setup_feature_state("false", "true")
    deattenuate_source_cell()
    start_utf_tracing()


def start_utf_tracing() -> None:
    """
    Start UTF tracing for all configured traces.

    This function connects to the tracing manager and initiates new traces
    for each trace configuration present in the global `traces` dictionary.
    Each trace is started with specified parameters including mplane, log profile,
    and number of cells.

    :raises ConnectionError: If unable to connect to the tracing manager.
    :raises TraceStartError: If any trace fails to start.
    """
    _dm.connect_to(port='9443', user=None, passwd=None)
    global traces_trunk
    for trace, params in traces_trunk.items():
        params['trace_id'] = _dm.start_new_trace(mplane=params['mplane'], log_profile=params['log_profile'],
                                                 nr_cells=params['cells'])


def teardown_utf() -> None:
    """
    Teardown the UTF environment.

    This function disconnects and cleans up resources related to the UTF environment.
    """
    _dm.teardown()


def stop_utf_tracing() -> None:
    """
    Stop UTF tracing and download logs.

    This function iterates over the traces, stops each trace, and downloads the logs to the specified output directory.

    :return: None
    """
    output_dir = get_path()
    for trace, params in traces_trunk.items():
        _dm.stop_trace(params['trace_id'])
        _dm.download_logs(params['trace_id'], target_dir=output_dir)


def teardown_tracing() -> None:
    """
    Tears down both UTF and ELT tracing.
    """
    teardown_utf()
    teardown_elt()


def teardown_elt() -> None:
    """
    Shuts down the ELT (Extract, Load, Transform) system.

    This function calls the shutdown method on the `_elt` object to properly
    terminate the ELT system.

    :return: None
    """
    _elt.shutdown()


def initialize_attenuators() -> None:
    """
    Initializes attenuators by configuring their setup and setting port attenuation.

    This function iterates over the list of attenuators defined in the test line configuration,
    logs the initialization process, sets up each attenuator, and configures the attenuation
    for the specified ports.

    :return: None
    """
    for idx, atten in enumerate(TestlineConfiguration().tl_init.attenuators):
        logger.info(f"Initializing attenuator {atten.ip_addr}", also_to_console=True)
        _attenuator.setup_attenuator(atten, alias=f"atten_{idx}")
        _attenuator.set_ports_attenuation(atten.attenuation_port_numbers, [90] * len(atten.attenuation_port_numbers),
                                          confirm=True, attenuator_device=f"atten_{idx}")


def deattenuate_source_cell() -> None:
    """
    Deattenuates the source cell to the minimum attenuation level.

    This function logs the deattenuation process and calls the `_attenuate_cell` function
    to set the attenuation of the source cell (identified by `TRUNK_SOURCE_CELL`) to the
    predefined minimum attenuation level (`MIN_ATTENUATION`).

    :return: None
    """
    logger.info(f"Deattenuating source cell (pci={TRUNK_SOURCE_CELL}) to {MIN_ATTENUATION}db",
                also_to_console=True)
    _attenuate_cell(TRUNK_SOURCE_CELL, MIN_ATTENUATION)


def attenuate_source_cell() -> None:
    """
    Attenuates the source cell to the maximum attenuation level.

    This function logs the attenuation process and calls the `_attenuate_cell` function
    to set the attenuation of the source cell (identified by `TRUNK_SOURCE_CELL`) to the
    predefined maximum attenuation level (`MAX_ATTENUATION`).

    :return: None
    """
    logger.info(f"Deattenuating source cell (pci={TRUNK_SOURCE_CELL}) to {MAX_ATTENUATION}db",
                also_to_console=True)
    _attenuate_cell(TRUNK_SOURCE_CELL, MAX_ATTENUATION)


def _attenuate_cell(cell_id, value):
    """
    Sets the attenuation level for a specific cell.

    This function retrieves the cell configuration from `CELL_PORTS` using the given `cell_id`,
    and sets the attenuation level for all ports of the cell to the specified `value`.

    :param cell_id: The ID of the cell whose ports need to be attenuated.
    :type cell_id: str
    :param value: The attenuation value to be applied to the cell's ports.
    :type value: int
    :return: None
    """
    cell = CELL_PORTS[cell_id]
    _attenuator.set_ports_attenuation(cell['ports'], [value] * len(cell['ports']), confirm=True,
                                      attenuator_device=f"atten_{cell['attenuator_id']}")


def setup_elt() -> None:
    """
    Sets up the ELT (Extract, Load, Transform) process with the specified configuration.

    This function logs the setup process, initializes the ELT with the given configuration,
    and applies a logging filter for the ELT operations.

    :return: None
    """
    logger.info(f"Setup ELT: {ELT_CONFIG_TRUNK}", also_to_console=True)
    _elt.setup(with_upload=True, configuration=ELT_CONFIG_TRUNK)
    _elt.set_logging_filter()


def start_elt_tracing() -> None:
    """
    Starts the ELT (Extract, Load, Transform) tracing process.

    This function initiates log collection for the ELT operations using the `_elt` object.

    :return: None
    """
    _elt.start_log_collecting()


def stop_elt_tracing(output_dir: str, elt_log_name: str) -> None:
    """
    Stops the ELT (Extract, Load, Transform) tracing process and downloads the collected logs.

    This function stops the log collection for ELT operations, and downloads the logs to the specified directory
    with the given log file name.

    :param output_dir: The directory where the ELT log file will be saved.
    :type output_dir: str
    :param elt_log_name: The name of the ELT log file to be saved.
    :type elt_log_name: str
    :return: None
    """
    output_dir = Path(output_dir)
    elt_path = str(output_dir / elt_log_name)
    _elt.stop_log_collecting()
    _elt.download_log(elt_path)


def get_params_for_eirp(state_1, state_2):
    return [{'parameterName': 'eirpControl',
             'operation': 'update',
             'value': [
                 {
                    'actEpic': state_1,
                    'epicMcsThreshold': '5',
                    'minGuaranteedBudgetRatio': '50',
                    'minGuaranteedBudgetRatioMode': 'actualEirpBudgetRatio',
                    'minSignificantNormalizedBeamGain': '-20',
                    'numOfSegmentAzimuthEdges': '0',
                    'numOfSegmentElevationEdges': '0',
                    'schedulWeightFactorEnabled': 'true',
                    'smoothingEffect': 'medium'
                 }]},
            {'parameterName': 'actEirpControl',
             'operation': 'update',
             'value': state_2}]


def get_path() -> str:
    """
    Constructs and returns a file path based on Robot Framework variables.

    This function retrieves the values of the `${OUTPUT_DIR}` and `${TEST_NAME}` variables
    from Robot Framework's BuiltIn library and combines them into a single file path.

    :return: The constructed file path as a string.
    :rtype: str
    """
    return os.path.join(BuiltIn().get_variable_value("${OUTPUT_DIR}"), BuiltIn().get_variable_value("${TEST_NAME}"))


def setup_feature_state(state_1: Any, state_2: Any) -> None:
    """
    Configures the feature state by performing object recommissioning on the VDU.

    This function retrieves parameters for EIRP based on the provided states, connects to the VDU,
    performs object recommissioning, and disconnects from the VDU after the operation.

    :param state_1: The first state parameter used to retrieve EIRP parameters.
    :type state_1: Any
    :param state_2: The second state parameter used to retrieve EIRP parameters.
    :type state_2: Any
    :return: None
    :rtype: None
    """
    parameter = get_params_for_eirp(state_1, state_2)
    admin = _vdu.connect_to(host="10.42.38.208", port='443', username='Nemuadmin', password='Nokia@123', secure=True)
    _vdu.perform_object_recommissioning(dist_name="MRBTS-8505/NRBTS-8505/NRCELL-2",
                                        parameter=parameter,
                                        operation="update",
                                        vdu_connection=admin)
    _vdu.disconnect(timeout=10)


def gather_elt_logs(elt_log_name: str) -> None:
    """
    Gathers ELT (Extract, Load, Transform) logs by starting tracing, waiting, and stopping tracing.

    This function initiates ELT tracing, waits for a specified duration to collect logs, and then stops tracing.
    The logs are saved to the directory specified by the `OUTPUT_DIR` Robot Framework variable, using the
    provided log name.

    :param elt_log_name: The name of the ELT log file to be saved.
    :type elt_log_name: str
    :return: None
    :rtype: None
    """
    start_elt_tracing()
    time.sleep(10)
    stop_elt_tracing(get_robot_variable('OUTPUT_DIR'), elt_log_name)


def analyze_elt_log_off(log_path: str) -> None:
    """
    Analyzes ELT logs and validates key performance metrics.

    This function resets the ELT parser, analyzes the provided log file, and prints key metrics
    such as Average MCS DL, Average PRB DL, and Average DL throughput. It also asserts that these
    metrics fall within expected ranges, raising an error if they do not.

    :param log_path: The path to the ELT log file to be analyzed.
    :type log_path: str
    :return: None
    :rtype: None

    :raises AssertionError: If any of the performance metrics are outside the expected range.
    """
    _elt_parser.reset()
    logs = _elt_parser.analyze_log(logfile=log_path)
    logger.info(f"Average MCS dl:, {float(logs['dl_mcs_all'])}")
    assert float(logs['dl_mcs_all']) > 26, 'Average DL MCS not as expected'
    logger.info(f"Average PRB dl:, {float(logs['dl_prb'])}")
    assert 40 < float(logs['dl_prb']) < 60, 'Average DL PRBs not as expected'
    logger.info(f"Average DL tput:, {float(logs['dl_pdcp_tput'])}")
    assert 70.0 < float(logs['dl_pdcp_tput']) < 90.0, 'Average DL tput not as expected'


def analyze_elt_log_on(log_path: str) -> None:
    """
    Analyzes ELT logs and validates key performance metrics for the "ON" configuration.

    This function resets the ELT parser, analyzes the provided log file, and prints key metrics
    such as Average MCS DL, Average PRB DL, and Average DL throughput. It also asserts that these
    metrics fall within expected ranges for the "ON" configuration, raising an error if they do not.

    :param log_path: The path to the ELT log file to be analyzed.
    :type log_path: str
    :return: None
    :rtype: None

    :raises AssertionError: If any of the performance metrics are outside the expected range.
    """
    _elt_parser.reset()
    logs = _elt_parser.analyze_log(logfile=log_path)
    logger.info(f"Average MCS dl:, {float(logs['dl_mcs_all'])}")
    assert float(logs['dl_mcs_all']) < 23, 'Average DL MCS not as expected'
    logger.info(f"Average PRB dl:, {float(logs['dl_prb'])}")
    assert float(logs['dl_prb']) > 105, 'Average DL PRBs not as expected'
    logger.info(f"Average DL tput:, {float(logs['dl_pdcp_tput'])}")
    assert 130.0 < float(logs['dl_pdcp_tput']) < 160.0, 'Average DL tput not as expected'
