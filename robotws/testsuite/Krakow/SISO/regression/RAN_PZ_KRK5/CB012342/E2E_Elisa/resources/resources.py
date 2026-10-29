"""
Module contains implementation of keywords to multi ue throughput or multiple attach detach tests.
:author: Adam Klekowski, Piotr Bacior
:contact: adam.klekowski@nokia.com, piotr.bacior@nokia.com
"""
import time
from random import randint

from robot.libraries.BuiltIn import BuiltIn
from robot.errors import ExecutionFailed
from robot.api import logger
from ute_ue.utils.param_checker import tput_user_value2normalized, timestr_to_secs
from taf.internal.robot_typecasts import time_to_seconds
from taf.rfrl.bts.devices.du.pm_counters import GnbPmCounter, EnbPmCounter
import variables
import time


gnb_counter_obj = GnbPmCounter()
enb_counter_obj = EnbPmCounter()

gnb_pdcp_counters = None
enb_cell_counters = None


def teardown_objects():
    """
    Dedicated function used to teardown GenericBTS objects,
    which are sometimes not torn down properly by Robo
    """

    gnb_counter_obj.admin.teardown(get_gnb_connection())
    enb_counter_obj.admin.teardown(get_enb_connection())


def get_gnb_connection(bts_id=0, du_id=0):
    """
    Get admin API connection for TL gNB using a known REST alias

    :param bts_id: optional BTS ID
    :param du_id:  optional Distributed Unit ID
    :returns       instance of taf.sbts.oam.coam.admin
    """
    gnb_counter_obj.connect()
    return gnb_counter_obj.admin.store.get("REST_GNB{}_DU{}".format(bts_id, du_id))


def get_enb_connection(bts_id=0, du_id=0):
    """
        Get admin API connection for TL eNB using a known REST alias

        :param bts_id: optional BTS ID
        :param du_id:  optional Distributed Unit ID
        :returns       instance of taf.sbts.oam.coam.admin
        """
    enb_counter_obj.connect()
    return enb_counter_obj.admin.store.get("REST_ENB{}_DU{}".format(bts_id, du_id))


def setup_scf_parameters_for_each_nr_cell(dist_name_template, n_of_cells, parameter_set, bts_id=0, du_id=0):
    """
    Setup test parameters that need to be set for each NR cell.

    :param dist_name_template: str template of 'dist name' path to NR cell path in Parameter Editor
    :param n_of_cells:         number of cells to configure - assumes cells are numbered from 1 and increasing by 1
                               Could be improved by using GnbCellOperations.get_all_cells_id() from rfrl
    :param parameter_set:      Key to set of parameters stored in test variables- usually "before_test" or "after_test"
    :param bts_id:             optional BTS ID
    :param du_id:              optional Distributed Unit ID
    """
    try:
        parameter_pairs = variables.scf_parameters[parameter_set]
    except KeyError:
        logger.log_info_to_console("Wrong 'scf_parameters' key. Possible: {}".format(variables.scf_parameters.keys()))
        raise

    dist_name = gnb_counter_obj.adjust_dist_name(dist_name=dist_name_template, bts_id=bts_id, du_id=du_id)
    gnb_counter_obj.login_gui()
    for i in range(1, n_of_cells + 1):
        dist_name_for_cell = dist_name + str(i)

        for parameter in parameter_pairs.keys():
            gnb_counter_obj.gui_coam.set_parameter_value(dist_name=dist_name_for_cell,
                                                         filter_param=parameter,
                                                         new_value=parameter_pairs[parameter])

    gnb_counter_obj.gui_coam.validate_plan()
    gnb_counter_obj.gui_coam.activate_plan()
    gnb_counter_obj.logout_gui()


def setup_scf_parameters_for_each_nr_cell_oam(dist_name_template, n_of_cells, parameter_set, timeout=60, bts_id=0,
                                              du_id=0):
    """
        Setup parameters for the test using the OAM API. Could be improved further by using a single API call and
        a delta commissioning using GenericCommissioning from rfrl

        :param dist_name_template:  str template that points to the location of
                                    NR cells in Parameter Editor (to be formatted)
        :param n_of_cells:          int of cells under test, to iterate from 1 to n_of_cells+1 and append to
                                    dist_name_template
        :param parameter_set:       str key to scf_parameters describing the parameters to change for the test
        :param timeout:             int value for the timeout of setting EACH cell parameters
        :param bts_id:              int ID for BTS
        :param du_id:               int DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
    """
    try:
        parameter_pairs = variables.scf_parameters_oam[parameter_set]
    except KeyError:
        logger.error("Wrong 'scf_parameters' key. Possible keys: {}".format(variables.scf_parameters_oam.keys()))
        raise

    dist_name = gnb_counter_obj.adjust_dist_name(dist_name=dist_name_template, bts_id=bts_id, du_id=du_id)
    oam_connection = get_gnb_connection()
    for i in range(1, n_of_cells + 1):
        dist_name_for_cell = dist_name + str(i)
        set_cell_params_oam(dist_name_for_cell, parameter_pairs, timeout, oam_connection)


def set_cell_params_oam(dist_name_for_cell, value_dict, timeout, connection):
    default_parameters = variables.default_parameters.copy()
    default_parameters.update(value_dict)

    connection.perform_parameter_recommissioning(dist_name=dist_name_for_cell,
                                                 parameter="nsaDrbParam",
                                                 operation="update",
                                                 value=[default_parameters],
                                                 skip_parameter_relation_errors=True,
                                                 should_activate=True,
                                                 timeout=time_to_seconds(timeout, round_to=0))


def gather_counters_gnb(sum_counters, divide_counter):
    """
        Calculate the throughput value for the test using given counters

        We reuse the GNB and ENB responses because not only is it faster for this many counters
        than requesting a single counter multiple times, but also BTS seems to stop
        responding to API requests after too many requests.

        :param  sum_counters - iterable of counter IDs to sum up in the numerator
        :param  divide_counter  - str counter ID that is the divisor
        :return value for KPI NR_5084a or NR_5085a
    """
    global gnb_pdcp_counters
    if not gnb_pdcp_counters:
        response = get_gnb_connection().get_counters_info("BTS/BTS", timeout=120)["BTS"]["BTS"]
        nrbts_key = next(iter(filter(lambda object_name: not object_name.find("NRBTS"), response)))
        gnb_pdcp_counters = response[nrbts_key]["PDCP1"]

    total_sum = 0.0
    for counter in sum_counters:
        total_sum += list(gnb_pdcp_counters[counter].values())[-1]

    divisor = list(gnb_pdcp_counters[divide_counter].values())[-1]

    if divisor > 0:
        return 8 * total_sum / (1000 * divisor)
    else:
        raise ZeroDivisionError("Divisor (time) was zero for counter {}".format(divide_counter))


def gather_counters_enb(numerator_counter, divisor_counter):
    """
        Calculate the throughput value for the test using given counters

        :param      numerator_counter - str of counter ID for the numerator
        :param      divisor_counter - str of counter ID for the divisor
        :returns    value for KPI LTE_6639a or LTE_6644a
    """

    # Fetch counters only once, as it is time-consuming
    global enb_cell_counters
    if not enb_cell_counters:
        enb_cell_counters = get_enb_connection().get_counters_info("BTS/CELLS", timeout=120)

    total_tput = 0.0

    for cell in enb_cell_counters["BTS"]["CELLS"].keys():
        throughput_counters = enb_cell_counters["BTS"]["CELLS"][cell]["MCC-001_MNC-01"]["LTE_Cell_Throughput"]
        numerator_value = list(throughput_counters[numerator_counter].values())[-1]

        total_tput += (numerator_value / divisor_counter)

    return total_tput


def perform_unidirectional_throughput_test_for_single_ue(ue_alias, duration, protocol, direction, throughput,
                                                         tput_min, parallel_streams=None, packet=None,
                                                         max_segment_size=None, buffer=None, linux_congestion=None):
    # When tester requests throughput equal to 2 Gb/s with 2 streams,
    # the function should run iperf with 1 Gb/s per stream.
    throughput = _divide_throughput(throughput, parallel_streams) if parallel_streams else throughput
    optional_parameters = _create_list_with_optional_data_transfer_parameters(
        direction=direction, parallel_streams=parallel_streams, packet=packet, max_segment_size=max_segment_size,
        buffer=buffer, linux_congestion=linux_congestion, protocol=protocol, throughput=throughput)

    port_num_generator = _generate_port_number()
    BuiltIn().run_keyword("ute_ue.Start Data Transfer", "ue_alias={}".format(ue_alias),
                          "dt_name={}".format(_resolve_dt_name(ue_alias, direction)),
                          "direction={}".format(direction), "protocol={}".format(protocol),
                          "port={}".format(next(port_num_generator)), *optional_parameters)
    BuiltIn().run_keyword("Sleep", duration)
    BuiltIn().run_keyword("ute_ue.Stop Data Transfer", "dt_name={}".format(_resolve_dt_name(ue_alias, direction)))
    BuiltIn().run_keyword("ute_ue.Verify Average Throughput",
                          "dt_name={}".format(_resolve_dt_name(ue_alias, direction)),
                          "tput_min={}".format(tput_min),
                          "omit=5")


def perform_bidirectional_throughput_test_for_single_ue(ue_alias, duration, protocol,
                                                        tput_dl, tput_ul,
                                                        tput_min_dl, tput_min_ul,
                                                        parallel_streams_dl=None, parallel_streams_ul=None,
                                                        packet=None, max_segment_size=None, buffer=None,
                                                        linux_congestion=None):
    _perform_bidirectional_throughput_test_for_ues([ue_alias], duration=duration, protocol=protocol,
                                                   tput_dl=tput_dl, tput_ul=tput_ul,
                                                   tput_min_dl=tput_min_dl,
                                                   tput_min_ul=tput_min_ul,
                                                   parallel_streams_dl=parallel_streams_dl,
                                                   parallel_streams_ul=parallel_streams_ul, packet=packet,
                                                   max_segment_size=max_segment_size, buffer=buffer,
                                                   linux_congestion=linux_congestion)


def perform_bidirectional_throughput_test_for_single_ue_without_verification(
        ue_alias, duration, protocol, tput_dl, tput_ul, tput_min_dl, tput_min_ul, parallel_streams_dl=None,
        parallel_streams_ul=None, packet=None, max_segment_size=None, buffer=None, linux_congestion=None):
    _perform_bidirectional_throughput_test_for_ues([ue_alias], duration=duration, protocol=protocol,
                                                   tput_dl=tput_dl, tput_ul=tput_ul,
                                                   tput_min_dl=tput_min_dl,
                                                   tput_min_ul=tput_min_ul,
                                                   parallel_streams_dl=parallel_streams_dl,
                                                   parallel_streams_ul=parallel_streams_ul, packet=packet,
                                                   max_segment_size=max_segment_size, buffer=buffer,
                                                   linux_congestion=linux_congestion, is_verification_required=False)


def perform_bidirectional_throughput_test_for_multi_ue(ue_aliases, duration, protocol,
                                                       tput_dl, tput_ul,
                                                       tput_min_dl, tput_min_ul,
                                                       parallel_streams_dl=None, parallel_streams_ul=None,
                                                       packet=None, max_segment_size=None, buffer=None,
                                                       linux_congestion=None):
    _perform_bidirectional_throughput_test_for_ues(ue_aliases, duration=duration, protocol=protocol,
                                                   tput_dl=tput_dl, tput_ul=tput_ul,
                                                   tput_min_dl=tput_min_dl,
                                                   tput_min_ul=tput_min_ul,
                                                   parallel_streams_dl=parallel_streams_dl,
                                                   parallel_streams_ul=parallel_streams_ul, packet=packet,
                                                   max_segment_size=max_segment_size, buffer=buffer,
                                                   linux_congestion=linux_congestion)


def attach_throughput_detach(ue_alias, iteration, duration, protocol,
                             tput_dl, tput_ul, tput_min_dl, tput_min_ul,
                             next_iteration_delay="1min",
                             parallel_streams_dl=None, parallel_streams_ul=None,
                             packet=None, max_segment_size=None, buffer=None,
                             linux_congestion=None):
    """
    Performs multiple sequence of:
    - attach ue
    - bidirectional throughput
    - detach ud
    - sleep
    """
    for _ in range(int(iteration)):
        BuiltIn().run_keyword("ute_ue.Attach Ue", ue_alias)
        BuiltIn().run_keyword("Sleep", "5s")
        BuiltIn().run_keyword("ute_ue.Log Ue Info", ue_alias, 'ALL')

        perform_bidirectional_throughput_test_for_single_ue(ue_alias, duration=duration, protocol=protocol,
                                                            tput_dl=tput_dl, tput_ul=tput_ul,
                                                            tput_min_dl=tput_min_dl, tput_min_ul=tput_min_ul,
                                                            parallel_streams_dl=parallel_streams_dl,
                                                            parallel_streams_ul=parallel_streams_ul, packet=packet,
                                                            max_segment_size=max_segment_size, buffer=buffer,
                                                            linux_congestion=linux_congestion)

        BuiltIn().run_keyword("ute_ue.Detach Ue", ue_alias)
        BuiltIn().run_keyword("Sleep", next_iteration_delay)


def perform_bidirectional_tcp_throughput_test_for_multi_ue_with_delay(
        ue_aliases, tput_min_dl, tput_min_ul, duration, delay, buffer=None, packet=None, max_segment_size=None,
        parallel_streams_dl=None, parallel_streams_ul=None, linux_congestion=None, scheduler_delay=None):
    """
    The goal of this test is to test wheater the scheduler divide throughput equally to the many UEs.

    Let's consider the example of the test with 3 UEs and the maximum throughput of 3 Gb/s.
    At the beginning (interval 1.), only UE A has started data transfer, so we expect that throughput is 3 Gb/s.
    In the 2. interval, UE B has also started data transfer, so we expect an equal division of throughput -
    1.5 Gb/s per UE.
    +-------------+-----------------+
    |             |       UEs       |
    |    Interval +-----+-----+-----+
    | (e.g. min.) |  A  |  B  |  C  |
    +-------------+-----+-----+-----+
    |          1. |  3  |  -  |  -  |
    +-------------+-----+-----+-----+
    |          2. | 1.5 | 1.5 |  -  |
    +-------------+-----+-----+-----+
    |          3. |  1  |  1  |  1  |
    +-------------+-----+-----+-----+
    |          4. |  1  |  1  |  1  |
    +-------------+-----+-----+-----+
    |          5. |  1  |  1  |  1  |
    +-------------+-----+-----+-----+
    |          6. |  -  | 1.5 | 1.5 |
    +-------------+-----+-----+-----+
    |          7. |  -  |  -  |  3  |
    +-------------+-----+-----+-----+
    """
    port_num_generator = _generate_port_number()
    is_failed = []
    number_of_ues = len(ue_aliases)
    duration_sec = timestr_to_secs(duration)
    delay_sec = timestr_to_secs(delay)
    scheduler_delay_sec = timestr_to_secs(scheduler_delay) if scheduler_delay else 0
    starting_dt_timestamps = []
    stopping_dt_timestamps = []

    dl_optional_parameters = _create_list_with_optional_data_transfer_parameters(
        direction='dl', parallel_streams=parallel_streams_dl, packet=packet, max_segment_size=max_segment_size,
        buffer=buffer, linux_congestion=linux_congestion, protocol="tcp")
    ul_optional_parameters = _create_list_with_optional_data_transfer_parameters(
        direction='ul', parallel_streams=parallel_streams_ul, packet=packet, max_segment_size=max_segment_size,
        buffer=buffer, linux_congestion=linux_congestion, protocol="tcp")

    # Starting all bidirectional throughput with delay and verifying throughput in the first interval
    # (between starting specific data transfer and starting the NEXT data transfer).
    for i in range(number_of_ues):
        starting_dt_timestamps.append(time.time())
        BuiltIn().run_keyword("ute_ue.Start Data Transfer",
                              "dt_name={}".format(_resolve_dt_name(ue_aliases[i], "dl")),
                              "ue_alias={}".format(ue_aliases[i]), "direction=dl", "protocol=tcp",
                              "port={}".format(next(port_num_generator)), *dl_optional_parameters)
        BuiltIn().run_keyword("ute_ue.Start Data Transfer",
                              "dt_name={}".format(_resolve_dt_name(ue_aliases[i], "ul")),
                              "ue_alias={}".format(ue_aliases[i]), "direction=ul", "protocol=tcp",
                              "port={}".format(next(port_num_generator)), *ul_optional_parameters)

        if ue_aliases[i] != ue_aliases[-1]:
            BuiltIn().run_keyword("Sleep", delay)
            is_failed.append(_verify_average_throughput_and_continue_on_failure(
                ue_aliases[i], 'ul', _divide_throughput(tput_min_ul, i + 1), omit=scheduler_delay_sec))
            is_failed.append(_verify_average_throughput_and_continue_on_failure(
                ue_aliases[i], 'dl', _divide_throughput(tput_min_dl, i + 1), omit=scheduler_delay_sec))

    BuiltIn().run_keyword("Sleep", "{}s".format(duration_sec - (delay_sec * (number_of_ues - 1))))

    # Stopping data transfer and verifying throughput when all data transfer works at the same time.
    for i in range(number_of_ues):
        stopping_dt_timestamps.append(time.time())
        BuiltIn().run_keyword("ute_ue.Stop Data Transfer", "dt_name={}".format(_resolve_dt_name(ue_aliases[i], "ul")))
        BuiltIn().run_keyword("ute_ue.Stop Data Transfer", "dt_name={}".format(_resolve_dt_name(ue_aliases[i], "dl")))

        omit = int(abs(starting_dt_timestamps[-1] - starting_dt_timestamps[i]))
        end = int(abs(starting_dt_timestamps[i] - stopping_dt_timestamps[0]))
        is_failed.append(_verify_average_throughput_and_continue_on_failure(
            ue_aliases[i], 'ul', _divide_throughput(tput_min_ul, len(ue_aliases)),
            omit=omit + scheduler_delay_sec,
            end=end))
        is_failed.append(_verify_average_throughput_and_continue_on_failure(
            ue_aliases[i], 'dl', _divide_throughput(tput_min_dl, len(ue_aliases)),
            omit=omit + scheduler_delay_sec,
            end=end))
        if ue_aliases[i] != ue_aliases[-1]:
            BuiltIn().run_keyword("Sleep", delay)

    # Verifying throughput in the last interval
    # (between stopping specific data transfer and PREVIOUS data transfer).
    for i in range(1, number_of_ues):
        omit = int(abs(stopping_dt_timestamps[i-1] - starting_dt_timestamps[i]))
        is_failed.append(_verify_average_throughput_and_continue_on_failure(
            ue_aliases[i], 'ul', _divide_throughput(tput_min_ul, number_of_ues - 1),
            omit=omit + scheduler_delay_sec))
        is_failed.append(_verify_average_throughput_and_continue_on_failure(
            ue_aliases[i], 'dl', _divide_throughput(tput_min_dl, number_of_ues - 1),
            omit=omit + scheduler_delay_sec))

    if True in is_failed:
        raise ExecutionFailed("At least one data transfer verification failed.")


def _perform_bidirectional_throughput_test_for_ues(ue_aliases, duration, protocol,
                                                   tput_dl, tput_ul,
                                                   tput_min_dl, tput_min_ul,
                                                   parallel_streams_dl=None, parallel_streams_ul=None, buffer=None,
                                                   packet=None, max_segment_size=None, linux_congestion=None,
                                                   is_verification_required=True):
    # When tester requests throughput equal to 2 Gb/s with 2 streams,
    # the function should run iperf with 1 Gb/s per stream.
    tput_dl = _divide_throughput(tput_dl, parallel_streams_dl) if parallel_streams_dl else tput_dl
    tput_ul = _divide_throughput(tput_ul, parallel_streams_ul) if parallel_streams_ul else tput_ul

    dl_optional_parameters = _create_list_with_optional_data_transfer_parameters(
        direction='dl', parallel_streams=parallel_streams_dl, packet=packet, max_segment_size=max_segment_size,
        buffer=buffer, linux_congestion=linux_congestion, protocol=protocol, throughput=tput_dl)
    time.sleep(30)
    ul_optional_parameters = _create_list_with_optional_data_transfer_parameters(
        direction='ul', parallel_streams=parallel_streams_ul, packet=packet, max_segment_size=max_segment_size,
        buffer=buffer, linux_congestion=linux_congestion, protocol=protocol, throughput=tput_ul)

    port_num_generator = _generate_port_number()
    for ue_alias in ue_aliases:
        BuiltIn().run_keyword("ute_ue.Start Data Transfer", "dt_name={}".format(_resolve_dt_name(ue_alias, "dl")),
                              "ue_alias={}".format(ue_alias), "direction=dl", "protocol={}".format(protocol),
                              "port={}".format(next(port_num_generator)), *dl_optional_parameters)
        BuiltIn().run_keyword("ute_ue.Start Data Transfer", "dt_name={}".format(_resolve_dt_name(ue_alias, "ul")),
                              "ue_alias={}".format(ue_alias), "direction=ul", "protocol={}".format(protocol),
                              "port={}".format(next(port_num_generator)), *ul_optional_parameters)

    BuiltIn().run_keyword("Sleep", duration)
    for ue_alias in ue_aliases:
        BuiltIn().run_keyword("ute_ue.Stop Data Transfer", "dt_name={}".format(_resolve_dt_name(ue_alias, "dl")))
        BuiltIn().run_keyword("ute_ue.Stop Data Transfer", "dt_name={}".format(_resolve_dt_name(ue_alias, "ul")))

    if is_verification_required:
        is_failed = []
        for ue_alias in ue_aliases:
            is_failed.append(_verify_average_throughput_and_continue_on_failure(ue_alias, 'dl', tput_min_dl))
            is_failed.append(_verify_average_throughput_and_continue_on_failure(ue_alias, 'ul', tput_min_ul))
        if True in is_failed:
            raise ExecutionFailed("At least one data transfer verification failed.")


def _resolve_dt_name(ue_alias, direction):
    return "DT_{}_{}".format(ue_alias, direction.upper())


def _divide_throughput(tput, divisor):
    divided_tput = tput_user_value2normalized(tput) // int(divisor)
    return '{}Kbits/sec'.format(divided_tput)


def _generate_port_number():
    port_num = randint(7500, 15000)
    while True:
        yield port_num
        port_num += 1


def _create_list_with_optional_data_transfer_parameters(direction, protocol, throughput=None, parallel_streams=None,
                                                        packet=None, max_segment_size=None,
                                                        buffer=None, linux_congestion=None):
    optional_parameters = []
    if throughput and protocol.lower() == 'udp':
        optional_parameters.append("throughput={}".format(throughput))
    if parallel_streams:
        optional_parameters.append("parallel_streams={}".format(parallel_streams))
    if packet and protocol.lower() == 'udp':
        optional_parameters.append("packet={}".format(packet))
    if max_segment_size:
        optional_parameters.append("max_segment_size={}".format(max_segment_size))
    if buffer:
        optional_parameters.append("buffer={}".format(buffer))
    if linux_congestion and direction == 'dl':
        optional_parameters.append("linux_congestion={}".format(linux_congestion))
    return optional_parameters


def _verify_average_throughput_and_continue_on_failure(ue_alias, direction, tput_min, omit=5, end=0):
    # We would like to verify throughput, but without stopping test case execution.
    # Using e.g.:
    #   BuiltIn().run_keyword("Run Keyword And Continue On Failure")
    # or
    #   BuiltIn().run_keyword_and_continue_on_failure()
    # does not work as it should and interrupts test case execution.
    is_failed = False
    try:
        BuiltIn().run_keyword("ute_ue.Verify Average Throughput",
                              "dt_name={}".format(_resolve_dt_name(ue_alias, direction)),
                              "tput_min={}".format(tput_min),
                              "omit={}".format(omit), "end={}".format(end))
    except ExecutionFailed as err:
        logger.warn("Throughput Verification for {} direction {} failed! Details below.".format(ue_alias,
                                                                                                direction.upper()))
        logger.warn(err)
        logger.warn("-" * 70)
        is_failed = True
    return is_failed
