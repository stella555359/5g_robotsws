# -*- coding: utf-8 -*-
"""
:author: Jaroslaw Zima
:contact: jaroslaw.zima@nokia.com
:maintainer: I_TADEK_DEVS
:contact: I_TADEK_DEVS@internal.nsn.com
"""

import tti_analyzer
from tti_parser import TtiParser


class TtiTracesContainer(object):
    """ Container made just to hide massive amount of output in log files """

    def __init__(self, traces):
        self.traces = traces


def parse_tti_traces_from_txt_file(path_to_file, filter_broken_traces=True):
    """ Parses file with collected TTI traces.

    :param str path_to_file: path to file with TTI traces
    :param bool filter_broken_traces: If set to True, can filter out broken traces (those without cRnti)
    :return: container with parsed TTI traces (workaround for robot's log output)
    :rtype: TtiTracesContainer
    """
    return TtiTracesContainer(TtiParser().parse_traces(path_to_file, filter_broken_traces))


def get_tti_column_headers_from_txt_file(path_to_file):
    """ Gets headers for each column from file with TTI traces

    :param str path_to_file: path to file with TTI traces
    :return: headers for each column
    :rtype: list[str]
    """
    return TtiParser().get_headers(path_to_file)


def get_average_throughput_per_ue(tti_traces, traffic_direction):
    """ Gets average uplink/downlink throughput per second in Mbps for each UE found in TTI traces

    :param TtiTracesContainer tti_traces: container with parsed TTI traces traces from txt file
    :param str traffic_direction: direction of throughput: ul for uplink, dl for downlink
    :return: dictionary with pairs - <UE cRnti>: <average throughput in Mbps>
    :rtype: dict
    """
    analyzer = tti_analyzer.TtiThroughputAnalyze()
    result = analyzer.get_average_throughput_per_ue(tti_traces.traces, traffic_direction)
    return result


def get_overall_average_throughput(tti_traces, traffic_direction):
    """ Gets average uplink/downlink throughput per second in Mbps

    :param TtiTracesContainer tti_traces: container with parsed TTI traces traces from txt file
    :param str traffic_direction: direction of throughput: ul for uplink, dl for downlink
    :return: average throughput in Mbps
    :rtype: float
    """
    analyzer = tti_analyzer.TtiThroughputAnalyze()
    result = analyzer.get_average_throughput(tti_traces.traces, traffic_direction)
    return result


def check_if_dl_codewords_match_target_number(tti_traces, target_codewords):
    """ Checks if codewords in TTI traces always match given target number of codewords basing on MiMo mode.

    :param TtiTracesContainer tti_traces: container with parsed TTI traces traces from txt file
    :param int|str|float target_codewords: number of target codewords
    :return: verdict - True if all number of codewords in traces matches target number of codewords
    :rtype: bool
    """
    analyzer = tti_analyzer.TtiCodewordsAnalyze()
    result = analyzer.check_if_dl_codewords_match_target_number(tti_traces.traces, target_codewords)
    return result


def get_average_ambr_value(tti_traces):
    """ Gets average AMBR in Mbps

    :param TtiTracesContainer tti_traces: container with parsed TTI traces traces from txt file
    :return: average AMBR in Mbps
    :rtype: float
    """
    analyzer = tti_analyzer.TtiAmbrAnalyze()
    result = analyzer.get_average_ambr(tti_traces.traces)
    return result


def check_if_mimo_mode_changes_due_to_cqi_threshold(tti_traces, cqi_threshold):
    """ Checks if MiMo mode changes value depending on cqi value (ranges determined by threshold value)

    :param TtiTracesContainer tti_traces: container with parsed TTI traces traces from txt file
    :param int|str|float cqi_threshold: cqi value working as threshold
    :return: verdict
    :rtype: bool
    """
    analyzer = tti_analyzer.TtiCqiAnalyze()
    result = analyzer.check_if_mimo_mode_changes_due_to_cqi_threshold(tti_traces.traces, cqi_threshold)
    return result


def check_if_delta_cqi_is_constant(tti_traces, target_value):
    """ Checks if delta CQI value in TTI traces always match given target value

    :param TtiTracesContainer tti_traces: container with parsed TTI traces traces from txt file
    :param str|int|float target_value: target value of delta CQI
    :return: verdict - True if delta CQI is constant
    :rtype: bool
    """
    analyzer = tti_analyzer.TtiCqiAnalyze()
    result = analyzer.check_if_delta_cqi_is_constant(tti_traces.traces, target_value)
    return result


def get_last_value_of_the_cqishift(tti_traces):
    """ Gets last numeric value of the pddchCQIshift

    :param TtiTracesContainer tti_traces: container with parsed TTI traces traces from txt file
    :return: last value of the pddchCQIshift
    :rtype: float
    """
    analyzer = tti_analyzer.TtiCqiAnalyze()
    result = analyzer.get_last_value_of_the_cqishift(tti_traces.traces)
    return result


def check_if_mimo_mode_matches_ri(tti_traces, target_mimo_mode, rank):
    """ Checks if MiMo mode for given rank (ri - rank indicator) matches target MiMo mode

    :param TtiTracesContainer tti_traces: container with parsed TTI traces traces from txt file
    :param str target_mimo_mode: expected MiMo mode
    :param float|int|str rank: rank indicator - ri
    :return: verdict
    :rtype: bool
    """
    analyzer = tti_analyzer.TtiRiAnalyze()
    result = analyzer.check_if_mimo_mode_matches_ri(tti_traces.traces, target_mimo_mode, rank)
    return result


def check_if_mimo_mode_changes_due_to_ri_threshold(tti_traces, ri_threshold):
    """ Checks if MiMo mode changes value depending on ri value (ranges determined by threshold value)

    :param TtiTracesContainer tti_traces: container with parsed TTI traces traces from txt file
    :param int|str|float ri_threshold: ri value working as threshold
    :return: verdict
    :rtype: bool
    """
    analyzer = tti_analyzer.TtiRiAnalyze()
    result = analyzer.check_if_mimo_mode_changes_due_to_ri_threshold(tti_traces.traces, ri_threshold)
    return result


def get_average_value_of_ulla_event_counter(tti_traces):
    """ Gets average value of ULLA OLLA event counter (rrmUllaOllaEventCounter - used to execute ATB)

    :param TtiTracesContainer tti_traces: container with parsed TTI traces traces from txt file
    :return: average ULLA OLLA event counter value
    :rtype: float
    """
    analyzer = tti_analyzer.TtiUllaOllaAnalyze()
    result = analyzer.get_average_value_of_ulla_event_counter(tti_traces.traces)
    return result


def check_if_atb_event_counter_doesnt_exceed_limit(tti_traces, counter_limit):
    """ Checks if value of rrmUllaOllaEventCounter doesn't exceed set counter limit (eUlLaAtbPeriod parameter)

    :param TtiTracesContainer tti_traces: container with parsed TTI traces traces from txt file
    :param str|float|int counter_limit: max conter value can't be reached or exceeded
    :return: verdict - True if value is always under limit
    :rtype: bool
    """
    analyzer = tti_analyzer.TtiUllaOllaAnalyze()
    result = analyzer.check_if_atb_event_counter_doesnt_exceed_limit(tti_traces.traces, counter_limit)
    return result


def check_if_change_of_delta_changes_event_counter(tti_traces):
    """ Checks if change of rrmDeltaC value is reflected by change of rrmUllaOllaEventCounter value

    :param TtiTracesContainer tti_traces: container with parsed TTI traces traces from txt file
    :return: verdict - True if event counter is changed when delta changes
    :rtype: bool
    """
    analyzer = tti_analyzer.TtiUllaOllaAnalyze()
    result = analyzer.check_if_change_of_delta_changes_event_counter(tti_traces.traces)
    return result


def check_if_ofdm_symbols_match_target_number(tti_traces, target_number_of_ofdm_symbols):
    """ Checks if OFDM symbols in TTI traces always match given target number of symbols.

    :param TtiTracesContainer tti_traces: container with parsed TTI traces traces from txt file
    :param str|int|float target_number_of_ofdm_symbols: number of target OFDM symbols
    :return: verdict - True if all number of symbols in traces matches target number of symbols
    :rtype: bool
    """
    analyzer = tti_analyzer.TtiOfdmAnalyze()
    result = analyzer.check_if_ofdm_symbols_match_target_number(tti_traces.traces, target_number_of_ofdm_symbols)
    return result


def get_harq_nacks_percentage(tti_traces, traffic_direction):
    """ Gets percentage of HARQ nacks.
    (nacks / all traces) * 100

    :param TtiTracesContainer tti_traces: container with parsed TTI traces traces from txt file
    :param str traffic_direction: direction of throughput: ul for uplink, dl for downlink
    :return: Percentage of HARQ nacks
    :rtype: float
    """
    analyzer = tti_analyzer.TtiHarqAnalyze()
    result = analyzer.get_harq_nacks_percentage(tti_traces.traces, traffic_direction)
    return result


def get_harq_nacks_percentage_per_ue(tti_traces, traffic_direction):
    """ Gets percentage of HARQ nacks for each UE found in TTI traces
    (nacks for ue / all traces for ue) * 100

    :param TtiTracesContainer tti_traces: container with parsed TTI traces traces from txt file
    :param str traffic_direction: direction of throughput: ul for uplink, dl for downlink
    :return: dictionary with pairs - <UE cRnti>: <Percentage of HARQ nacks>
    :rtype: dict
    """
    analyzer = tti_analyzer.TtiHarqAnalyze()
    result = analyzer.get_harq_nacks_percentage_per_ue(tti_traces.traces, traffic_direction)
    return result


def check_if_transmission_mode_is_depending_on_mimo_mode(tti_traces, mimo_mode, expected_transmission_mode):
    """ Checks if transmission mode is matching set MiMo mode

    :param TtiTracesContainer tti_traces: container with parsed TTI traces traces from txt file
    :param str mimo_mode: set mimo mode: TxDiv or OpenLoopMimo
    :param str expected_transmission_mode: expected transmission mode
    :return: verdict - True if transmission modes matches mimo mode
    :rtype; bool
    """
    analyzer = tti_analyzer.TtiMimoAnalyze()
    result = analyzer.check_if_transmission_mode_is_depending_on_mimo_mode(
        tti_traces.traces, mimo_mode, expected_transmission_mode
    )
    return result


def get_CRNTI_for_ue_based_on_isCatM_parameter(tti_traces, isCatM, direction):
    """ Gets list of unique cRntis from TTI traces which parameter isCatM is set to 1(CAT-M UE ) or 0 (Legacy UE)

    :param TtiTracesContainer tti_traces: container with parsed TTI traces traces from txt file
    :param str isCatM: indicate if UE belong to CAT-M UEs, possibel values are 0(Legacy UE) or 1(Cat-M UE)
    :param str direction: direction of throughput: ul for uplink, dl for downlink
    :return: list of cRntis
    :rtype: list[str]
    """
    analyzer = tti_analyzer.BaseAnalyze()
    result = analyzer._get_CRNTI_for_ue_based_on_isCatM_parameter(tti_traces.traces, isCatM, direction)
    return result


def get_CRNTI_for_ue_based_on_transMode_parameter(tti_traces, transMode, direction):
    """ Gets list of unique cRntis from TTI traces which parameter transMode is set

    :param TtiTracesContainer tti_traces: container with parsed TTI traces traces from txt file
    :param str transMode: UE transmission mode
    :param str direction: direction of throughput: ul for uplink, dl for downlink
    :return: list of cRntis
    :rtype: list[str]
    """
    analyzer = tti_analyzer.BaseAnalyze()
    result = analyzer._get_CRNTI_for_ue_based_on_transMode_parameter(tti_traces.traces, transMode, direction)
    return result


def check_if_tti_drx_timers_are_0x0(tti_traces):
    """ Checks if feature: DRX in RRC connected mode is turned off and not visible on MAC layer
    :param TtiTracesContainer tti_traces: container with parsed TTI traces traces from txt file
    :return: verdict - True if all drx timers are 0
    :rtype: bool
    """
    analyzer = tti_analyzer.TtiDrxAnalyze()
    result = analyzer.check_if_drx_timers_are_0x0(tti_traces.traces)
    return result


def check_if_tti_drx_timers_are_NOT_0x0(tti_traces):
    """ Checks if feature: DRX in RRC connected mode is turned on and visible on MAC layer
    :param TtiTracesContainer tti_traces: container with parsed TTI traces traces from txt file
    :return: verdict - True if all drx timers are NOT 0
    :rtype: bool
    """
    analyzer = tti_analyzer.TtiDrxAnalyze()
    result = analyzer.check_if_drx_timers_are_not_0x0(tti_traces.traces)
    return result
