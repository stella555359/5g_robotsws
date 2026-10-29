# -*- coding: utf-8 -*-
"""
:author: Jaroslaw Zima
:contact: jaroslaw.zima@nokia.com
:maintainer: I_TADEK_DEVS
:contact: I_TADEK_DEVS@internal.nsn.com
"""
import time
from datetime import datetime

import fields_config as fields


class BaseAnalyze(object):
    CRNTI_FIELD_MAP = {"dl": fields.DL_CRNTI, "ul": fields.UL_CRNTI}
    CAT_M_FIELD_MAP = {"dl": fields.DL_IS_CATM_UE, "ul": fields.UL_IS_CATM_UE}
    TRANS_MODE_FIELD_MAP = {"dl": fields.DL_TRANS_MODE, "ul": fields.UL_TRANS_MODE}

    def _get_traces_for_ue(self, traces, crnti, direction):
        """Filters out TTI traces for UE basing on it's cRnti

        :param list[dict] traces: list of parsed TTI traces
        :param str crnti: UE's cRnti id
        :param str direction: direction of throughput: ul for uplink, dl for downlink
        :return: filtered out TTI traces for UE
        :rtype: list[dict]
        """
        CRNTI = self.CRNTI_FIELD_MAP[direction]
        return [trace for trace in traces if trace[CRNTI] == crnti or trace[CRNTI] == "blocked;%s" % crnti]

    def _get_traces_for_ue_with_parameter_isCatM(self, traces, isCatM, direction):
        """Filters out TTI traces for UE basing on it's isCatM parameter

        :param list[dict] traces: list of parsed TTI traces
        :param str isCatM: indicate if UE belong to CAT-M UEs, possibel values are 0(Legacy UE) or 1(Cat-M UE)
        :param str direction: direction of throughput: ul for uplink, dl for downlink
        :return: filtered out TTI traces for UE
        :rtype: list[dict]
        """
        return [trace for trace in traces if trace[self.CAT_M_FIELD_MAP[direction]] == isCatM]

    def _get_traces_for_ue_based_on_transmode(self, traces, transMode, direction):
        """Filters out TTI traces for UE basing on it's transMode parameter

        :param list[dict] traces: list of parsed TTI traces
        :param str transMode: UE's transmission mode
        :param str direction: direction of throughput: ul for uplink, dl for downlink
        :return: filtered out TTI traces for UE
        :rtype: list[dict]
        """
        return [trace for trace in traces if trace[self.TRANS_MODE_FIELD_MAP[direction]] == transMode]

    def _get_unique_crntis(self, traces, direction):
        """Gets list of unique cRntis from TTI traces

        :param list[dict] traces: list of parsed TTI traces
        :param str direction: direction of throughput: ul for uplink, dl for downlink
        :return: list of cRntis
        :rtype: list[str]
        """
        CRNTI = self.CRNTI_FIELD_MAP[direction]
        crntis = {trace[CRNTI] for trace in traces if trace[CRNTI].isdigit()}
        return list(crntis)

    def _get_duration(self, traces):
        """Gets duration (seconds and microseconds) of throughput for list of TTI traces

        :param list[dict] traces: list of parsed TTI traces
        :return: duration of throughput
        :rtype: float
        """
        time_format = "%Y-%m-%dT%H:%M:%S.%fZ"
        start_datetime = datetime.strptime(traces[0][fields.TIME], time_format)
        end_datetime = datetime.strptime(traces[-1][fields.TIME], time_format)
        return self._calculate_time_delta(start_datetime, end_datetime)

    def _calculate_time_delta(self, start_datetime, end_datetime):
        """Calculates time delta between first and last TTI trace

        :param datetime start_datetime: datetime of first TTI trace
        :param datetime end_datetime: datetime of last TTI trace
        :return: time delta
        :rtype: float
        """
        start_time = time.mktime(start_datetime.timetuple()) + (start_datetime.microsecond / float(1000000))
        end_time = time.mktime(end_datetime.timetuple()) + (end_datetime.microsecond / float(1000000))
        return float(end_time) - float(start_time)

    def _convert_bytes_to_megabits(self, value):
        """Converts bytes to megabits

        :param str|int|float value: value to be converted
        :return: Value as megabits
        :rtype: float
        """
        return float(value) * 8 / float(1000000)

    def _convert_kbps_to_mbps(self, value):
        """Converts given kbps to Mbps

        :param str|int|float value: value to be converted
        :return: Value as Mbps
        :rtype: float
        """
        return float(value) / float(1000)

    def _get_CRNTI_for_ue_based_on_isCatM_parameter(self, traces, isCatM, direction):
        """Gets list of unique cRntis from TTI traces which parameter isCatM is set to 1(CAT-M UE ) or 0 (Legacy UE)

        :param list[dict] traces: list of parsed TTI traces
        :param str isCatM: indicate if UE belong to CAT-M UEs, possibel values are 0(Legacy UE) or 1(Cat-M UE)
        :param str direction: direction of throughput: ul for uplink, dl for downlink
        :return: list of cRntis
        :rtype: list[str]
        """
        ue_traces = self._get_traces_for_ue_with_parameter_isCatM(traces, isCatM, direction)
        return self._get_unique_crntis(ue_traces, direction)

    def _get_CRNTI_for_ue_based_on_transMode_parameter(self, traces, transMode, direction):
        """Gets list of unique cRntis from TTI traces which parameter transMode is set

        :param list[dict] traces: list of parsed TTI traces
        :param str transMode: UE transmission mode
        :param str direction: direction of throughput: ul for uplink, dl for downlink
        :return: list of cRntis
        :rtype: list[str]
        """
        ue_traces = self._get_traces_for_ue_based_on_transmode(traces, transMode, direction)
        return self._get_unique_crntis(ue_traces, direction)


class TtiThroughputAnalyze(BaseAnalyze):
    """Class used for analyzing throughput of collected TTI traces"""

    def get_average_throughput_per_ue(self, traces, direction):
        """Gets average uplink/downlink throughput per second in Mbps for each UE found in TTI traces

        :param list[dict] traces: list of parsed TTI traces
        :param str direction: direction of throughput: ul for uplink, dl for downlink
        :return: dictionary with pairs - <UE cRnti>: <average throughput in Mbps>
        :rtype: dict
        """
        crntis = self._get_unique_crntis(traces, direction)
        average_throughput = {crnti: self._get_average_throughput_for_ue(crnti, traces, direction) for crnti in crntis}
        return average_throughput

    def get_average_throughput(self, traces, direction):
        """Gets average uplink/downlink throughput per second in Mbps

        :param list[dict] traces: list of parsed TTI traces
        :param str direction: direction of throughput: ul for uplink, dl for downlink
        :return: average throughput in Mbps
        :rtype: float
        """
        duration = self._get_duration(traces)
        # avoid ZeroDivisionError
        if duration == 0.0:
            duration = 0.001  # sampling rate is 1ms
        throughput_sum = sum(map(lambda trace: self._get_throughput_value_from_trace(trace, direction), traces))
        average_throughput_per_second = float(self._convert_bytes_to_megabits(throughput_sum)) / float(duration)
        return average_throughput_per_second

    def _get_average_throughput_for_ue(self, crnti, traces, direction):
        """Gets average throughput for UE from parsed TTI traces

        :param str crnti: UE's cRnti id
        :param list[dict] traces: list of parsed TTI traces
        :param str direction: direction of throughput: ul for uplink, dl for downlink
        :return: average throughput for UE in Mbps
        :rtype: float
        """
        ue_traces = self._get_traces_for_ue(traces, crnti, direction)
        return self.get_average_throughput(ue_traces, direction)

    def _get_throughput_value_from_trace(self, trace, direction):
        """Gets throughput value from fields in TTI trace

        :param dict trace: parsed TTI trace
        :param str direction: direction of throughput: ul for uplink, dl for downlink
        :return: throughput value from fields in TTI trace
        :rtype: float
        """
        throughput_fields_map = {"ul": fields.UL_THROUGHPUT, "dl": fields.DL_THROUGHPUT}
        throughput_value = sum(
            [
                float(trace[tti_field]) if trace[tti_field] != "-" else 0
                for tti_field in throughput_fields_map[direction]
            ]
        )
        return throughput_value


class TtiCodewordsAnalyze(BaseAnalyze):
    """Class used for analyzing codewords data in TTI traces"""

    MIMO_TO_CODEWORDS_MAP = {"TX_div": 1, "2x2_Mimo_Single_CW": 1, "2x2_Mimo_Dual_CW": 2}

    def check_if_dl_codewords_match_target_number(self, traces, target_codewords):
        """Checks if codewords in TTI traces always match given target number of codewords basing on MiMo mode.

        :param list[dict] traces: list of parsed TTI traces
        :param int|str target_codewords: number of target codewords
        :return: verdict - True if all number of codewords in traces matches target number of codewords
        :rtype: bool
        """
        mimo_modes_in_traces = [trace[fields.DL_MIMO] for trace in traces if trace[fields.DL_MIMO] != "-"]
        codewords_in_traces = map(lambda mode: mode.replace(" ", "_"), mimo_modes_in_traces)
        return all(
            map(lambda codewords: self.MIMO_TO_CODEWORDS_MAP[codewords] == int(target_codewords), codewords_in_traces)
        )


class TtiAmbrAnalyze(BaseAnalyze):
    """Class used for analyzing AMBR data in TTI traces"""

    def get_average_ambr(self, traces):
        """Gets average AMBR in Mbps

        :param list[dict] traces: list of parsed TTI traces
        :return: average AMBR in Mbps
        :rtype: float
        """
        ambr_chunks = [float(trace[fields.DL_AMBR]) for trace in traces if trace[fields.DL_AMBR] != "-"]
        average_ambr = self._convert_kbps_to_mbps(sum(ambr_chunks)) / float(len(ambr_chunks))
        return average_ambr


class TtiCqiAnalyze(BaseAnalyze):
    """Class used for analyzing Cqi data in TTI traces"""

    def check_if_mimo_mode_changes_due_to_cqi_threshold(self, traces, threshold):
        """Checks if MiMo mode changes value depending on cqi value (ranges determined by threshold value)

        :param list[dict] traces: list of parsed TTI traces
        :param float threshold: cqi value working as threshold
        :return: verdict
        :rtype: bool
        """
        cqis_and_mimos = [
            (float(trace[fields.DL_MIMO_CQI]), trace[fields.DL_MIMO])
            for trace in traces
            if trace[fields.DL_MIMO_CQI] != "-" and trace[fields.DL_MIMO] != "-"
        ]
        min_cqi_mimo = cqis_and_mimos[cqis_and_mimos.index(min(cqis_and_mimos, key=lambda item: item[0]))][1]
        max_cqi_mimo = cqis_and_mimos[cqis_and_mimos.index(max(cqis_and_mimos, key=lambda item: item[0]))][1]
        mimo_checks = [
            mimo == min_cqi_mimo if cqi < threshold else mimo == max_cqi_mimo
            for cqi, mimo in cqis_and_mimos
            if cqi != threshold
        ]
        return all(mimo_checks)

    def check_if_delta_cqi_is_constant(self, traces, target_value):
        """Checks if delta CQI value in TTI traces always match given target value

        :param list[dict] traces: list of parsed TTI traces
        :param int|float|str target_value: target value of delta CQI
        :return: verdict - True if delta CQI is constant
        :rtype: bool
        """
        cqis = [float(trace[fields.DL_DELTA_CQI]) for trace in traces if trace[fields.DL_DELTA_CQI] != "-"]
        return all(map(lambda cqi: cqi == float(target_value), cqis))

    def get_last_value_of_the_cqishift(self, traces):
        """Gets last numeric value of the pddchCQIshift

        :param list[dict] traces: list of parsed TTI traces
        :return: last value of the pddchCQIshift
        :rtype: float
        """
        for trace in traces[::-1]:
            last_cqi_shift = trace[fields.DL_CQI_SHIFT]
            try:
                last_cqi_shift = float(last_cqi_shift)
                break
            except ValueError:
                continue
        else:
            raise ValueError("There is no numeric value of the pddchCQIshift in the TTI traces log")
        return last_cqi_shift


class TtiRiAnalyze(BaseAnalyze):
    """Class used for analyzing RI (rank indicator) data in TTI traces"""

    def check_if_mimo_mode_matches_ri(self, traces, target_mimo_mode, rank):
        """Checks if MiMo mode for given rank (ri - rank indicator) matches target MiMo mode

        :param list[dict] traces: list of parsed TTI traces
        :param str target_mimo_mode: expected MiMo mode
        :param float|int|str rank: rank indicator - ri
        :return: verdict
        :rtype: bool
        """
        ris_and_mimos = [
            (float(trace[fields.DL_MIMO_RI]), trace[fields.DL_MIMO])
            for trace in traces
            if trace[fields.DL_MIMO] != "-" and trace[fields.DL_MIMO_RI] != "-"
        ]
        mimos_filtered_by_ri = [mimo for ri, mimo in ris_and_mimos if round(ri, 2) == float(rank)]
        return all(map(lambda mimo: mimo.lower() == target_mimo_mode.lower(), mimos_filtered_by_ri))

    def check_if_mimo_mode_changes_due_to_ri_threshold(self, traces, threshold):
        """Checks if MiMo mode changes value depending on ri value (ranges determined by threshold value)

        :param list[dict] traces: list of parsed TTI traces
        :param float threshold: ri value working as threshold
        :return: verdict
        :rtype: bool
        """
        ris_and_mimos = [
            (float(trace[fields.DL_MIMO_RI]), trace[fields.DL_MIMO])
            for trace in traces
            if trace[fields.DL_MIMO_RI] != "-" and trace[fields.DL_MIMO] != "-"
        ]
        min_ri_mimo = ris_and_mimos[ris_and_mimos.index(min(ris_and_mimos, key=lambda item: item[0]))][1]
        max_ri_mimo = ris_and_mimos[ris_and_mimos.index(max(ris_and_mimos, key=lambda item: item[0]))][1]
        mimo_checks = [
            mimo == min_ri_mimo if ri < threshold else mimo == max_ri_mimo
            for ri, mimo in ris_and_mimos
            if ri != threshold
        ]
        return all(mimo_checks)


class TtiUllaOllaAnalyze(BaseAnalyze):
    """Class used for analyzing ULLA OLLA data in TTI traces"""

    def get_average_value_of_ulla_event_counter(self, traces):
        """ " Gets average value of ULLA OLLA event counter (ATB)

        :param list[dict] traces: list of parsed TTI traces
        :return: average ULLA OLLA event counter value
        :rtype: float
        """
        event_counter_chunks = [float(trace[fields.UL_ULLA]) for trace in traces if trace[fields.UL_ULLA] != "-"]
        average_ulla_event_counter = sum(event_counter_chunks) / float(len(event_counter_chunks))
        return average_ulla_event_counter

    def check_if_atb_event_counter_doesnt_exceed_limit(self, traces, counter_limit):
        """Checks if value of rrmUllaOllaEventCounter doesn't exceed set counter limit (eUlLaAtbPeriod parameter)

        :param list[dict] traces: list of parsed TTI traces
        :param int counter_limit: max counter value that can't be reached or exceeded
        :return: verdict - True if value is always under limit
        :rtype: bool
        """
        event_counter_chunks = [float(trace[fields.UL_ULLA]) for trace in traces if trace[fields.UL_ULLA] != "-"]
        return all(map(lambda counter_value: counter_value < counter_limit, event_counter_chunks))

    def check_if_change_of_delta_changes_event_counter(self, traces):
        """Checks if change of rrmDeltaC value is reflected by change of rrmUllaOllaEventCounter value

        :param list[dict] traces: list of parsed TTI traces
        :return: verdict - True if event counter is changed when delta changes
        :rtype: bool
        """
        event_counter_chunks = [float(trace[fields.UL_ULLA]) for trace in traces if trace[fields.UL_ULLA] != "-"]
        delta_chunks = [float(trace[fields.UL_DELTAC]) for trace in traces if trace[fields.UL_DELTAC] != "-"]
        change_checks = [
            self._check_if_delta_changes_counter_value(index, event_counter_chunks, delta_chunks)
            for index in range(1, len(event_counter_chunks))
        ]
        return all(change_checks)

    def _check_if_delta_changes_counter_value(self, index, counters, deltas):
        """Checks if change of rrmDeltaC value is reflected by change of rrmUllaOllaEventCounter value

        :param int index: index of item in list
        :param list counters: list of counter values
        :param list deltas: list of delta values
        :return: verdict
        :rtype: bool
        """
        return counters[index] != counters[index - 1] if deltas[index] != deltas[index - 1] else True


class TtiOfdmAnalyze(BaseAnalyze):
    """Class used for analyzing OFDM data in TTI traces"""

    def check_if_ofdm_symbols_match_target_number(self, traces, target_symbols):
        """Checks if OFDM symbols in TTI traces always match given target number of symbols.

        :param list[dict] traces: list of parsed TTI traces
        :param int|str target_symbols: number of target OFDM symbols
        :return: verdict - True if all number of symbols in traces matches target number of symbols
        :rtype: bool
        """
        ofdm_symbols_in_traces = [trace[fields.DL_OFDM] for trace in traces if trace[fields.DL_OFDM] != "-"]
        return all(map(lambda symbols: symbols == str(target_symbols), ofdm_symbols_in_traces))


class TtiHarqAnalyze(BaseAnalyze):
    """Class used for analyzing HARQ data in TTI traces"""

    def get_harq_nacks_percentage(self, traces, direction):
        """Gets percentage of HARQ nacks.
        (nacks / all traces) * 100

        :param list[dict] traces: list of parsed TTI traces
        :param str direction: direction of throughput: ul for uplink, dl for downlink
        :return: Percentage of HARQ nacks
        :rtype: float
        """
        harq_responses = [
            self._get_harq_response_from_trace(trace, direction)
            for trace in traces
            if "-" not in self._get_harq_response_from_trace(trace, direction)
        ]
        amount_of_harq_nacks = sum([1 if "NACK" in response else 0 for response in harq_responses])
        return (float(amount_of_harq_nacks) / float(len(harq_responses))) * 100

    def get_harq_nacks_percentage_per_ue(self, traces, direction):
        """Gets percentage of HARQ nacks for each UE found in TTI traces
        (nacks for ue / all traces for ue) * 100

        :param list[dict] traces: list of parsed TTI traces
        :param str direction: direction of throughput: ul for uplink, dl for downlink
        :return: dictionary with pairs - <UE cRnti>: <Percentage of HARQ nacks>
        :rtype: dict
        """
        crntis = self._get_unique_crntis(traces, direction)
        harq_nacks_percentage = {
            crnti: self._get_harq_nacks_percentage_for_ue(crnti, traces, direction) for crnti in crntis
        }
        return harq_nacks_percentage

    def _get_harq_nacks_percentage_for_ue(self, crnti, traces, direction):
        """Gets percentage of HARQ nacks for UE from parsed TTI traces

        :param str crnti: UE's cRnti id
        :param list[dict] traces: list of parsed TTI traces
        :param str direction: direction of throughput: ul for uplink, dl for downlink
        :return: Percentage of HARQ nacks for UE
        :rtype: float
        """
        ue_traces = self._get_traces_for_ue(traces, crnti, direction)
        return self.get_harq_nacks_percentage(ue_traces, direction)

    def _get_harq_response_from_trace(self, trace, direction):
        """Gets HARQ response (ACK / NACK) from TTI trace

        :param dict trace: parsed TTI trace
        :param str direction: direction of throughput: ul for uplink, dl for downlink
        :return: list with HARQ response values
        :rtype: list
        """
        harq_fields_map = {"ul": fields.UL_HARQ_NACK, "dl": fields.DL_HARQ_NACK}
        harq_response = [trace[tti_field] for tti_field in harq_fields_map[direction]]
        return harq_response


class TtiMimoAnalyze(BaseAnalyze):
    """Class used for analyzing MiMo data in TTI traces"""

    def check_if_transmission_mode_is_depending_on_mimo_mode(self, traces, mimo_mode, transmission_mode):
        """Checks if transmission mode is matching set MiMo mode

        :param list[dict] traces: list of parsed TTI traces
        :param str mimo_mode: set mimo mode: TxDiv or OpenLoopMimo
        :return: verdict - True if transmission modes matches mimo mode
        :return: verdict
        :rtype: bool
        """
        mimo_map = {"txdiv": ("tx div", "tx div"), "openloopmimo": ("2x2 mimo dual cw", "2x2 open loop")}
        checks = [
            trace[fields.DL_TRS_MODE].lower() == transmission_mode.lower()
            for trace in traces
            if (trace[fields.DL_MIMO].lower(), trace[fields.DL_DYNAMIC_MIMO].lower()) == mimo_map[mimo_mode.lower()]
        ]
        return checks and all(checks)


class TtiDrxAnalyze(BaseAnalyze):
    """Class used for analyzing DRX data in TTI traces"""

    def check_if_drx_timers_are_0x0(self, traces):
        """Checks if feature: DRX in RRC connected mode is turned off and not visible on MAC layer

        :param list[dict] traces: list of parsed TTI traces
        :return: verdict - True if all drx timers are 0
        :return: verdict
        :rtype: bool
        """

        checks = [
            True if trace[fields.DRX_BIT_MASK] == "0x0" or trace[fields.DRX_BIT_MASK] == "-" else False
            for trace in traces
        ]
        return all(checks)

    def check_if_drx_timers_are_not_0x0(self, traces):
        """Checks if feature: DRX in RRC connected mode is turned on and visible on MAC layer

        :param list[dict] traces: list of parsed TTI traces
        :return: verdict - True if all drx timers are NOT 0
        :return: verdict
        :rtype: bool
        """

        checks = [
            True if trace[fields.DRX_BIT_MASK] != "0x0" or trace[fields.DRX_BIT_MASK] == "-" else False
            for trace in traces
        ]
        return all(checks)
