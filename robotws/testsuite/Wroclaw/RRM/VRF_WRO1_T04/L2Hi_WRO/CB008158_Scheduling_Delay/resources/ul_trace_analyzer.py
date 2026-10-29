"""
:copyright: Nokia Solutions and Networks
:authors:
    Michal Gorski <michal.gorski@nokia.com>
    Patryk Wójcik <patryk.wojcik@nokia.com>
:maintainers:
    Michal Gorski <michal.gorski@nokia.com>
    Patryk Wójcik <patryk.wojcik@nokia.com>
"""

from robot.api import logger
from robot.libraries.BuiltIn import BuiltIn
from testsuite.Wroclaw.RRM.VRF_WRO1_T04.L2Hi_WRO.resources_kr.python.csv_verifiers import csv_verifiers
import variant_helper


NUMBER_OF_LCG_IDS = 8

COLUMN_NAMES = (
    "hfnTickCount",
    "sfn",
    "slot",
    "rnti",
    "ulFdSchedData.dciFormat",
    "csiSrReportData.sr",
    "ulPucchReceiveRespPsData.dtx",
    "ulPucchReceiveRespPsData.srBit",
    "ulPucchReceiveRespPsData.rxPower",
    "ulPucchReceiveRespPsData.pucchFormat",
    "ulBsrRxData.bufferSizeIndex",
    "ulFdSchedAdditionalData.rrmBufferedDataUlLcg_bytes"
)

VERIFIER = csv_verifiers()

VARIANT = BuiltIn().get_variable_value('${variant}', default="FDD")
SLOTS_PER_SFN = variant_helper.get_slots_per_sfn(VARIANT)
SLOTS_TO_SUBTRACT = variant_helper.get_slots_to_subtract(VARIANT)
SLOT_LENGTH_MICROSECONDS = 10000 // SLOTS_PER_SFN


class TtiTraceManager:
    def __init__(self, tti_trace_path, column_names=COLUMN_NAMES):
        self._tti_trace_path = tti_trace_path
        self._entries = self._get_entries_from_traces(column_names)

    def _get_entries_from_traces(self, column_names):
        entries = []
        traces = self._get_tti_trace_columns(column_names)
        for index in range(len(traces[column_names[0]])):
            row_as_dict = {column_name: traces[column_name][index] for column_name in column_names}
            entries.append(TtiTraceEntry(row_as_dict))
        return entries

    def _get_tti_trace_columns(self, column_names):
        traces = VERIFIER.create_list_of_lists_from_csv(self._tti_trace_path)
        return VERIFIER.get_multiple_columns_values(input_list=traces, as_dict=True, ignore_wrong_column=True,
                                                    *column_names)

    def get_unique_rntis(self):
        """
        Get unique values of rntis in TtiTraces for which TtiTraceManager was created
        :return: set containing unique rnti values
        """
        return set([entry.rnti for entry in self._entries])

    def get_entries(self):
        """
        Get all TtiTraceEntry objects contained in TtiTraceManager object as list
        :return: list of TtiTraceEntry objects
        """
        return self._entries


class TtiTraceEntry:
    def __init__(self, fields):
        self._fields = fields

    @property
    def tick_count(self):
        return self._get_converted_field("hfnTickCount", target_type=int)

    @property
    def sfn(self):
        return self._get_converted_field("sfn", target_type=int)

    @property
    def slot(self):
        return self._get_converted_field("slot", target_type=int)

    @property
    def rnti(self):
        return self._get_converted_field("rnti", target_type=int)

    @property
    def dci_format(self):
        return self._get_converted_field("ulFdSchedData.dciFormat", target_type=str)

    @property
    def csi_sr(self):
        return self._get_converted_field("csiSrReportData.sr", target_type=str)

    @property
    def dtx(self):
        return self._get_converted_field("ulPucchReceiveRespPsData.dtx", target_type=str)

    @property
    def sr_bit(self):
        return int(self._get_converted_field("ulPucchReceiveRespPsData.srBit", target_type=float))

    @property
    def rx_power(self):
        return self._get_converted_field("ulPucchReceiveRespPsData.rxPower", target_type=float)

    @property
    def pucch_format(self):
        return int(self._get_converted_field("ulPucchReceiveRespPsData.pucchFormat", target_type=float))

    @property
    def buffer_size_index(self):
        return self._get_converted_list_field("ulBsrRxData.bufferSizeIndex", element_type=int)

    @property
    def rrm_buffer(self):
        return self._get_converted_list_field("ulFdSchedAdditionalData.rrmBufferedDataUlLcg_bytes", element_type=int)

    def _get_field(self, field_name):
        self._assert_fields_are_present(field_name)
        return self._fields[field_name]

    def _get_converted_field(self, field_name, target_type):
        field_value = self._get_field(field_name)
        return target_type(field_value) if field_value != "" else ""

    def _get_converted_list_field(self, field_name, element_type):
        field_value = self._get_field(field_name)
        if len(field_value) > 0:
            field_value = field_value.replace("[", "").replace("]", "")
            return [element_type(item) for item in field_value.split(", ")]
        else:
            return []

    def _assert_fields_are_present(self, *field_names):
        for field_name in field_names:
            assert field_name in self._fields, f"Field {field_name} not configured for TtiTraceEntry"

    def _is_pucch_format_1_positive_sr(self):
        return self.dtx == "NON_DTX" \
            and self.pucch_format == 1 \
            and self.rx_power >= -125 \
            and self.sr_bit == 1

    def _is_pucch_format_2_or_3_positive_sr(self):
        return self.csi_sr == "SR"

    def is_positive_sr(self):
        """
        Checks if TtiTraceEntry is a positive SR
        :return: True if TtiTraceEntry is a positive SR, False otherwise
        """
        return self._is_pucch_format_1_positive_sr() \
            or self._is_pucch_format_2_or_3_positive_sr()

    def _is_rrm_buffer_empty(self, lcg):
        return self.rrm_buffer[lcg] == 0 if len(self.rrm_buffer) > 0 else False

    def _is_bsr_received(self, lcg):
        return self.buffer_size_index[lcg] != 0 if len(self.buffer_size_index) > 0 else False

    def is_initial_bsr(self, lcg):
        """
        Checks if TtiTraceEntry is an initial BSR with given LCG ID
        :param lcg: LCG ID
        :return: True if TtiTraceEntry is an initial BSR with LCG ID = lcg, False otherwise
        """
        return self._is_rrm_buffer_empty(lcg) and self._is_bsr_received(lcg)

    def is_ul_grant(self):
        """
        Checks if TtiTraceEntry is an UL Grant
        :return: True if TtiTraceEntry is an UL Grant, False otherwise
        """
        return self.dci_format == "UL_01" or self.dci_format == "UL_00_FORCE"

    def get_entry_position(self):
        """
        Gets hfnTickCount, sfn and slot values as TtiTraceEntry position in TtiTraces, for logging purposes
        :return: hfnTickCount, sfn and slot values in single string
        """
        return f"hfnTickCount={self.tick_count} sfn={self.sfn} slot={self.slot}"

    def get_slot_time(self):
        """
        Gets absolute slot number for TtiTraceEntry as a time measure
        :return: total slot number including SLOTS_PER_SFN slots per passed sfn and 1024 sfns per passed hfnTickCount
        """
        return (self.tick_count * 1024 + self.sfn) * SLOTS_PER_SFN + self.slot


class TtiTraceEvent:
    def __init__(self, start):
        self.start = start
        self.end = None

    def has_not_ended(self):
        """
        Checks if TtiTraceEvent has not ended and thus is expecting an end TtiTraceEntry
        :return: True if end of event was not yet provided, False if event was concluded
        """
        return self.end is None

    def get_grant_delay(self):
        """
        Gets maximum time delay between the start and the end of the TtiTraceEvent
        :return: calculated time delay for the event in microseconds
        """
        slot_delta = self.end.get_slot_time() - self.start.get_slot_time()
        delay_in_slots = slot_delta - SLOTS_TO_SUBTRACT
        delay_in_microseconds = delay_in_slots * SLOT_LENGTH_MICROSECONDS
        self._log_event_details(f"slot_delta={slot_delta}\t"
                                f"delay_in_slots={delay_in_slots}\t"
                                f"delay_in_microseconds={delay_in_microseconds}")
        return delay_in_microseconds

    def _log_event_details(self, msg):
        logger.info(f"start: {self.start.get_entry_position()}\t"
                    f"end: {self.end.get_entry_position()}\t"
                    f"{msg}")


class EventManager:
    def __init__(self, unique_rntis):
        self._events = {rnti: [] for rnti in unique_rntis}

    def _is_new_event_expected(self, rnti):
        return not self._is_event_end_expected(rnti)

    def _is_event_end_expected(self, rnti):
        return len(self._events[rnti]) > 0 and self._events[rnti][-1].has_not_ended()

    def _record_start_of_event(self, entry):
        self._events[entry.rnti].append(TtiTraceEvent(entry))

    def _record_end_of_event(self, entry):
        self._events[-1][entry.rnti].end = entry

    def _get_all_events_as_list(self):
        return [event for events_per_rnti in self._events.values() for event in events_per_rnti]

    def get_count(self):
        """
        Get total number of events contained in EventManager object
        :return: total number of events
        """
        return len(self._get_all_events_as_list())

    def get_total_delay(self):
        """
        Get total delay for events contained in EventManager object
        :return: total delay of events
        """
        return sum(map(TtiTraceEvent.get_grant_delay, self._get_all_events_as_list()))

    def _record_start_of_event_if_expected(self, entry):
        if self._is_new_event_expected(entry.rnti):
            self._record_start_of_event(entry)
        else:
            logger.warn(f"Another SR request before the UL grant at {entry.get_entry_position()}")

    def _record_end_of_event_if_expected(self, entry):
        if self._is_event_end_expected(entry.rnti):
            self._events[entry.rnti][-1].end = entry

    @classmethod
    def _get_events(cls, traces, event_start_condition, *condition_params):
        events = cls(traces.get_unique_rntis())

        for entry in traces.get_entries():

            if event_start_condition(entry, *condition_params):
                events._record_start_of_event_if_expected(entry)
                continue

            if entry.is_ul_grant():
                events._record_end_of_event_if_expected(entry)

        return events

    @classmethod
    def get_sr_events(cls, traces):
        """
        Gets all positive SR events with subsequent UL Grants from TtiTraces
        :param traces: TtiTraceManager object
        :return: EventManager object containing positive SR events with subsequent UL Grants
        """
        return cls._get_events(traces, TtiTraceEntry.is_positive_sr)

    @classmethod
    def get_bsr_events(cls, traces):
        """
        Gets all initial BSR events with subsequent UL Grants from TtiTraces
        :param traces: TtiTraceManager object
        :return: list of EventManager objects containing initial BSR events with subsequent UL Grants per LCG ID
        """
        return [cls._get_events(traces, TtiTraceEntry.is_initial_bsr, lcg) for lcg in range(NUMBER_OF_LCG_IDS)]


def get_sr_expected_values(tti_trace_path):
    """
    Gets dictionary with INIT_UL_GRANT_SR and UL_SR_GRANT_DLY expected values
    +------------------+-------+------------+------------+-------+-----------+
    |     Example                                                            |
    +==================+=======+============+============+==========+========+
    | ${expected_values}=   Get SR expected values                           |
    | ...  tti_trace_path=${OUTPUT_DIR}/${TESTNAME}/Traces/output_ul.csv     |
    +------------------+-------+------------+------------+-------+-----------+
    :param tti_trace_path: path to TtiTrace file
    :return: dictionary containing expected value for INIT_UL_GRANT_SR under "count" key
             and expected value for UL_SR_GRANT_DLY under "delay" key
    """
    traces = TtiTraceManager(tti_trace_path)
    events = EventManager.get_sr_events(traces)
    count = events.get_count()
    delay = events.get_total_delay()
    if VARIANT == "TDD FR2":
        delay = f"{delay - count * SLOT_LENGTH_MICROSECONDS}-{delay}"
    return {"count": f"{count}", "delay": f"{delay}"}


def get_bsr_expected_values(tti_trace_path):
    """
    Gets dictionary with TOT_UL_BURST_MAC_LCGx and UL_MAC_CONT_DLY_LCGx expected values
    +------------------+-------+------------+------------+-------+-----------+
    |     Example                                                            |
    +==================+=======+============+============+==========+========+
    | ${expected_values}=   Get BSR expected values                          |
    | ...  tti_trace_path=${OUTPUT_DIR}/${TESTNAME}/Traces/output_ul.csv     |
    +------------------+-------+------------+------------+-------+-----------+
    :param tti_trace_path: path to TtiTrace file
    :return: dictionary containing list with expected values for TOT_UL_BURST_MAC_LCG0-7 under "counts" key
             and list with expected value ranges for UL_MAC_CONT_DLY_LCG0-7 under "delays" key;
             minimal values for the delays are taken as 1 microsecond per event
    """
    traces = TtiTraceManager(tti_trace_path)
    events = EventManager.get_bsr_events(traces)
    counts = [str(count) for count in list(map(EventManager.get_count, events))]
    delays = [str(delay) for delay in list(map(EventManager.get_total_delay, events))]
    delays = list(map(lambda min_val, max_val: f"{min_val}-{max_val}" if max_val != "0" else "0", counts, delays))
    return {"counts": counts, "delays": delays}


def get_init_ul_grant_sr(tti_trace_path, margin=2):
    """
    Gets INIT_UL_GRANT_SR expected value with margin
    +------------------+-------+------------+------------+-------+-----------+
    |     Example                                                            |
    +==================+=======+============+============+==========+========+
    | ${expected_values}=   Get INIT_UL_GRANT_SR                             |
    | ...  tti_trace_path=${OUTPUT_DIR}/${TESTNAME}/Traces/output_ul.csv     |
    +------------------+-------+------------+------------+-------+-----------+
    :param tti_trace_path:      path to TtiTrace file
    :param margin:              accepted error
    :return: expected range of values for INIT_UL_GRANT_SR as string
    """
    traces = TtiTraceManager(tti_trace_path)
    events = EventManager.get_sr_events(traces)
    count = events.get_count()
    return f'{max(count - margin, 0)}-{count + margin}'


def get_tot_ul_burst_mac_lcg(tti_trace_path, margin=2):
    """
    Gets TOT_UL_BURST_MAC_LCGx expected values with margin
    +------------------+-------+------------+------------+-------+-----------+
    |     Example                                                            |
    +==================+=======+============+============+==========+========+
    | ${expected_values}=   Get TOT_UL_BURST_MAC_LCG                         |
    | ...  tti_trace_path=${OUTPUT_DIR}/${TESTNAME}/Traces/output_ul.csv     |
    +------------------+-------+------------+------------+-------+-----------+
    :param tti_trace_path:      path to TtiTrace file
    :param margin:              accepted error
    :return: list of expected ranges of values for TOT_UL_BURST_MAC_LCG0-7 as strings
    """
    traces = TtiTraceManager(tti_trace_path)
    events = EventManager.get_bsr_events(traces)
    counts = list(map(EventManager.get_count, events))
    return [f'{max(count - margin, 0)}-{count + margin}' for count in counts]
