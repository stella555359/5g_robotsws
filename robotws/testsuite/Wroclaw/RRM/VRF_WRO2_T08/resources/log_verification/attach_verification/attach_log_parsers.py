"""
Parser classes that extracts useful attach related information from various logs and stores them
in appropriate data objects. See ./attach_structures for more details

:copyright: Nokia
:author: adam.kropiwnicki@nokia.com
:maintainer: adam.kropiwnicki@nokia.com
"""

import json

from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log_analyzer.log_helper import \
    LogHelper
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log_analyzer.matchers import \
    PcapMessageMatcher as PM
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.log_verification.pcap_reader import \
    load_pcap
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.log_verification.qxdm_verification import \
    extract_raw_values_from_qxdm_log
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.averager import Averager
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.exceptions import \
    LogParsingError
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.wro_logger import logger
from .attach_structures import (BIPAttach, ELTAttach, NGAPAttach, QXDMAttach,
                                X2APAttach)


class BIPAttachParser:
    tshark_filter = {
        "prach_ind": "UlData_detectedPrachPreambles_t.prachPreambleIndex",
        "initial_ta": "UlData_detectedPrachPreambles_t.initialTa",
        "peak_metric": "UlData_detectedPrachPreambles_t.peakMetric",
        "rar_temp_crnti": "mac-nr.rar.temp_crnti",
        "rar_ta": "mac-nr.rar.ta",
        "rar_rapid": "mac-nr.rar.rapid",
        "rar_rnti": "mac-nr.rnti",
        "msg3_crc": "UlData_UePuschReceiveRespHarqU_t.crc",
        "msg3_dtx": "UlData_UePuschReceiveRespHarqU_t.dtx",
        "sfn": "3gpp.sfn",
        "slot": "3gpp.slot",
        "rnti": "3gpp.rnti",
        "frame_len": "frame.len",
    }
    update_25r3 = {
        "msg3_crc": "UlData_UePuschReceiveRespHarqUL1sw_t.crc",
        "msg3_dtx": "UlData_UePuschReceiveRespHarqUL1sw_t.dtx",
    }

    def __init__(self):
        self._attach_attempts = []

    def parse_pcap(self, pcap_path, sw_branch="25r2"):
        tshark_filter = self.tshark_filter.copy()
        if sw_branch.lower() == "sbts00" or sw_branch.lower() >= "sbts25r3":
            tshark_filter.update(self.update_25r3)

        self._attach_attempts = []
        loaded_pcap = load_pcap(input_pcap=pcap_path, tshark_fields=tshark_filter.values())
        for msg in loaded_pcap:
            msg = msg["_source"]["layers"]
            if tshark_filter['prach_ind'] in msg:
                if int(msg[tshark_filter['frame_len']][0]) < 80:
                    continue
                attempt = BIPAttach()
                attempt.msg1["peak_metric"] = float(msg[tshark_filter["peak_metric"]][0])
                attempt.msg1["sfn"], attempt.msg1["slot"] = int(msg[tshark_filter["sfn"]][0]), int(
                    msg[tshark_filter["slot"]][0]
                )
                attempt.msg1["rapid"] = msg[tshark_filter["prach_ind"]][0]
                attempt.msg1["initial_ta"] = int(msg[tshark_filter["initial_ta"]][0])
                self._attach_attempts.append(attempt)
            if tshark_filter["rar_temp_crnti"] in msg:
                for attempt in self._attach_attempts:
                    if (
                        attempt.msg1["rapid"] == msg[tshark_filter["rar_rapid"]][0]
                        and attempt.msg1["initial_ta"] == int(msg[tshark_filter["rar_ta"]][0])
                        and not attempt.msg2["rapid_match"]
                    ):
                        attempt.ra_rnti = int(msg[tshark_filter["rar_rnti"]][0], 16)
                        attempt.msg2["sfn"], attempt.msg2["slot"] = int(msg[tshark_filter["sfn"]][0]), int(
                            msg[tshark_filter["slot"]][0]
                        )
                        attempt.msg2["t_rnti"] = int(msg[tshark_filter["rar_temp_crnti"]][0], 16)
                        attempt.msg2["rapid_match"] = True
                        attempt.msg2["timing_advance"] = int(msg[tshark_filter["rar_ta"]][0])

            if tshark_filter["msg3_dtx"] in msg:
                for attempt in self._attach_attempts:
                    if attempt.msg2["t_rnti"] == int(msg[tshark_filter["rnti"]][0]) and attempt.msg3["harq_fb"] is None:
                        dtx = msg[tshark_filter["msg3_dtx"]][0]
                        crc = msg[tshark_filter["msg3_crc"]][0]
                        attempt.msg3["harq_fb"] = "FAIL" if dtx == "1" else "PASS"
                        attempt.msg3["dtx"] = dtx
                        attempt.msg3["crc"] = crc
                        attempt.msg3["sfn"], attempt.msg3["slot"] = int(msg[tshark_filter["sfn"]][0]), int(
                            msg[tshark_filter["slot"]][0]
                        )
        return self._attach_attempts


class QxdmAttachParser:
    def __init__(self):
        self._attach_attempts = []
        self._unused_prach_power_messages = []
        self._unused_msg3_power_messages = []

    def parse_log(self, log):
        self._attach_attempts = []
        self._unused_prach_power_messages = []
        self._unused_msg3_power_messages = []
        raw_values = extract_raw_values_from_qxdm_log(
            log,
            [
                "NR5G ML1 Searcher Measurement Database Update Ext",
                "NR5G LL1 FW MAC TX IU Power",
                "NR5G MAC RACH Attempt",
            ],
        )
        for msg, values in raw_values:
            if msg == "NR5G MAC RACH Attempt":
                attempt = QXDMAttach()
                attempt.rach_outcome = values["RACH Result"][0]
                attempt.num_attempt = int(values["Num Attempts"][0])
                attempt.contention_type = values["Contention Type"][0]
                self._extract_msg1_values(attempt, values)
                self._extract_msg2_values(attempt, values)
                self._extract_msg3_values(attempt, values)
                self._extract_msg4_values(attempt, values)
                if len(self._unused_prach_power_messages):
                    prach_values = self._unused_prach_power_messages.pop()
                    i = prach_values["Channel Type"][0].index("PRACH")
                    attempt.msg1["pathloss"] = prach_values["Pathloss_4"][0][i]
                    attempt.msg1["mtpl"] = prach_values["PHR MTPL_4"][0][i]
                if len(self._unused_msg3_power_messages):
                    msg3_values = self._unused_msg3_power_messages.pop()
                    i = msg3_values["Is Msg3"][0].index(1.0)
                    attempt.msg3["pathloss"] = msg3_values["Pathloss_1"][0][i]
                    attempt.msg3_mtpl = msg3_values["PHR MTPL_1"][0][i]
                self._attach_attempts.append(attempt)

            if msg == "NR5G LL1 FW MAC TX IU Power":
                is_prach_power_msg = True
                is_msg3_power_msg = True
                try:
                    i = values["Channel Type"][0].index("PRACH")
                except KeyError:
                    is_prach_power_msg = False
                except ValueError:
                    is_prach_power_msg = False
                if is_prach_power_msg:
                    used = False
                    for attempt in [attempt for attempt in self._attach_attempts if attempt.msg1["pathloss"] is None]:
                        attempt.msg1["pathloss"] = values["Pathloss_4"][0][i]
                        attempt.msg1["mtpl"] = values["PHR MTPL_4"][0][i]
                        used = True
                    if not used:
                        self._unused_prach_power_messages.append(values)
                try:
                    i = values["Is Msg3"][0].index(1.0)
                except KeyError:
                    is_msg3_power_msg = False
                except ValueError:
                    is_msg3_power_msg = False
                if is_msg3_power_msg:
                    used = False
                    for attempt in [attempt for attempt in self._attach_attempts if attempt.msg3["pathloss"] is None]:
                        attempt.msg3["pathloss"] = values["Pathloss_1"][0][i]
                        attempt.msg3["mtpl"] = values["PHR MTPL_1"][0][i]
                        used = True
                    if not used:
                        self._unused_msg3_power_messages.append(values)

            if msg == "NR5G ML1 Searcher Measurement Database Update Ext":
                if not values["SSB Periodicity Serv Cell"][0] == "INVALID":
                    cell_index = int(values["Serving Cell Index"][0])
                    for attempt in [attempt for attempt in self._attach_attempts if attempt.rsrp is None]:
                        rsrp = [QxdmAttachParser._get_avg(val) for val in values["NR2NR Filtered Tx Beam RSRP L3"]]
                        rsrq = [QxdmAttachParser._get_avg(val) for val in values["NR2NR Filtered Tx Beam RSRQ L3"]]
                        rsrp = [val for val in rsrp if val is not None]
                        rsrq = [val for val in rsrq if val is not None]
                        attempt.rsrp = rsrp[cell_index]
                        attempt.rsrq = rsrq[cell_index]
        return self._attach_attempts

    @staticmethod
    def _extract_msg1_values(attempt, values):
        try:
            attempt.ra_rnti = int(values["RA_RNTI"][0][0])
            attempt.msg1["prach_config"] = int(values["PRACH Config"][0][0])
            attempt.msg1["preamble_format"] = values["Preamble Format"][0][0]
            attempt.msg1["rapid"] = int(values["RAID"][0][0])
            attempt.msg1["sfn"] = int(values["Frame_1"][0][0])
            attempt.msg1["slot"] = int(values["Slot_1"][0][0])
        except KeyError as e:
            logger.info(e, also_to_console=True)

    @staticmethod
    def _extract_msg2_values(attempt, values):
        try:
            attempt.msg2["t_rnti"] = int(values["T_RNTI"][0][0])
            attempt.msg2["timing_advance"] = int(values["TA Value"][0][0])
            attempt.msg2["rapid_match"] = True if values["Result"][0][0] == "RAPID_MATCH" else False
            attempt.msg2["sfn"] = int(values["Frame"][0][1])
            attempt.msg2["slot"] = int(values["Slot"][0][1])
        except KeyError as e:
            logger.info(e, also_to_console=True)

    @staticmethod
    def _extract_msg3_values(attempt, values):
        try:
            attempt.msg3["harq_id"] = int(values["HARQ ID"][0][0])
            attempt.msg3["sfn"] = int(values["Frame"][0][2])
            attempt.msg3["slot"] = int(values["Slot"][0][2])
        except KeyError as e:
            logger.info(e, also_to_console=True)

    @staticmethod
    def _extract_msg4_values(attempt, values):
        try:
            attempt.msg4["c_rnti"] = int(values["C_RNTI"][0][0])
            attempt.msg4["sfn"] = int(values["Frame_1"][0][1])
            attempt.msg4["slot"] = int(values["Slot_1"][0][1])
            attempt.msg3["harq_fb"] = "PASS"
        except KeyError as e:
            attempt.msg3["harq_fb"] = "FAIL"
            logger.info(e, also_to_console=True)

    @staticmethod
    def _get_avg(sparse_list):
        current_sum, count = (0, 0)
        for value in sparse_list:
            if isinstance(value, float):
                current_sum += value
                count += 1
        return current_sum / count if count > 0 else None


class EltAttachParser:
    def __init__(self):
        self._attach_attempts = []

    def parse_log(self, elt_log):
        self._attach_attempts = []
        with open(elt_log, "r") as f:
            log = json.load(f)
        for msg in log:
            if not msg["valid"]:
                continue
            if msg["name"] == "NL1_RACH_Information":
                self._attach_attempts.append(ELTAttach())
                msg1 = msg["data"]["RACH_MSG1"]
                self._parse_msg1(msg1)
                msg2 = msg["data"]["RACH_MSG2"]
                self._parse_msg2(msg2)
                msg3 = msg["data"]["RACH_MSG3"]
                self._parse_msg3(msg3)
                msg4 = msg["data"]["RACH_MSG4"]
                self._parse_msg4(msg4)
                self._attach_attempts[-1].num_attempt = len(self._attach_attempts)
            if msg["name"] == "NL1_Serving_Cell_Measurement":
                for attempt in [attempt for attempt in self._attach_attempts if attempt.rsrq is None]:
                    cell_records = msg["data"]["Serving Cell SSS Measurement Records"]
                    avg = Averager()
                    for record in cell_records:
                        avg.update(rsrq=record.get("RSRQ", None))
                    attempt.rsrq = avg.avg("rsrq")
                    attempt.pci = msg["data"]["PCI"]
            if msg["name"] == "NL1_Sync_SSB_Measurement":
                for attempt in [attempt for attempt in self._attach_attempts if attempt.rsrp is None]:
                    ssb_sync_data = msg["data"]["Sync SSB Measurement records"]
                    avg = Averager()
                    for record in ssb_sync_data:
                        avg.update(rsrp=record.get("Sync SSB RSRP avarage", None))
                    attempt.rsrp = avg.avg("rsrp")
            if msg["name"] == "NL1_PUSCH_Power_Control":
                for attempt in [attempt for attempt in self._attach_attempts if attempt.msg3["pathloss"] is None]:
                    power_records = msg["data"]["Pusch Power Control Records"]
                    avg = Averager()
                    for record in power_records:
                        avg.update(pathloss=record.get("Path Loss", None))
                        avg.update(tx_power=record.get("Transmitted Power", None))
                    attempt.msg3["pathloss"] = avg.avg("pathloss")
                    attempt.msg3["mtpl"] = avg.avg("tx_power")
            if msg["name"] == "NL2_MAC_RACH_Attempt_Complete_Event":
                for attempt in [attempt for attempt in self._attach_attempts if attempt.pci is None]:
                    attempt.pci = msg["data"]["Physical Cell ID"]
        return self._attach_attempts

    def _parse_msg1(self, msg1):
        attempt = self._attach_attempts[-1]
        attempt.is_valid["msg1"] = True if msg1["Msg1 valid"] else False
        attempt.msg1["preamble_format"] = msg1["Preamble Format"]
        attempt.msg1["prach_config"] = msg1["Prach Config"]
        attempt.msg1["sfn"] = msg1["Preamble SFN"]
        attempt.msg1["slot"] = msg1["Preamble Slot"]
        attempt.msg1["mtpl"] = msg1["PRACH TX power"]
        attempt.msg1["pathloss"] = msg1["Pathloss"]

    def _parse_msg2(self, msg2):
        attempt = self._attach_attempts[-1]
        attempt.ra_rnti = msg2["RNTI Value"]
        attempt.is_valid["msg2"] = True if msg2["Msg2 valid"] else False
        attempt.msg2["timing_advance"] = msg2["Timing Advance Value"]
        attempt.msg2["rapid_match"] = bool(msg2["Timing_Advance_valid"])
        attempt.msg2["sfn"] = msg2["RAR SFN"]
        attempt.msg2["slot"] = msg2["RAR Slot"]

    def _parse_msg3(self, msg3):
        attempt = self._attach_attempts[-1]
        attempt.is_valid["msg3"] = True if msg3["Msg3 valid"] else False
        attempt.msg3["harq_id"] = msg3["HARQ ID"]
        attempt.msg3["mcs"] = msg3["MCS"]
        attempt.msg3["tx_power"] = msg3["Msg3 Power"]
        attempt.msg3["sfn"] = msg3["Msg3 SFN"]
        attempt.msg3["slot"] = msg3["Msg3 Slot"]

    def _parse_msg4(self, msg4):
        attempt = self._attach_attempts[-1]
        attempt.is_valid["msg4"] = True if msg4["Msg4 valid"] else False
        attempt.msg3["harq_fb"] = "PASS" if attempt.is_valid["msg4"] else "FAIL"
        attempt.msg4["sfn"] = msg4["Msg4 SFN"]
        attempt.msg4["slot"] = msg4["Msg4 Slot"]


class X2APAttachParser:
    def __init__(self):
        self._attach_attempts = []

    def parse_pcap(self, pcap):
        self._attach_attempts = []
        with LogHelper() as lh:
            finder = lh.add_pcap(
                pcap_file_path=pcap,
                lua=None,
                tshark_filter="x2ap || s1ap",
                output_log_file=None,
                clean_up_tmp_file=False,
            )

            messages = finder.find_all(
                [
                    PM("SgNBAdditionRequest", message_type_pattern="empty"),
                    PM("SgNBAdditionRequestAcknowledge", message_type_pattern="empty"),
                    PM("SgNBReconfigurationComplete", message_type_pattern="empty"),
                    PM("SNStatusTransfer", message_type_pattern="empty"),
                ]
            )
        for msg1 in messages.get("SgNBAdditionRequest", []):
            attempt = X2APAttach()
            attempt.sgnb_add_req = True
            attempt.rsrp = X2APAttachParser.__get_rsrp_from_sgnb_add_req_message(msg1)
            self._attach_attempts.append(attempt)
        for i in range(min(len(messages.get("SgNBAdditionRequestAcknowledge", [])), len(self._attach_attempts))):
            self._attach_attempts[i].sgnb_add_req_ack = True
        for i in range(min(len(messages.get("SgNBReconfigurationComplete", [])), len(self._attach_attempts))):
            self._attach_attempts[i].sgnb_rec_comp = True
        for i in range(min(len(messages.get("SNStatusTransfer", [])), len(self._attach_attempts))):
            self._attach_attempts[i].sn_status_trans = True
        self.__determine_attaches_state()
        logger.info("Output attach attempts list:")
        logger.info(self._attach_attempts)
        return self._attach_attempts

    @staticmethod
    def __get_rsrp_from_sgnb_add_req_message(msg):
        try:
            rsrp = msg.find("*rsrp*")[0]["val"].split("dB")[0].strip()
        except IndexError:
            logger.info("Erroneous message:   {}".format(msg))
            raise LogParsingError("Can't find rsrp value in given SgNBAdditionRequest")
        except ValueError:
            logger.info("Erroneous message:   {}".format(msg))
            raise LogParsingError("Can't decode rsrp value in given SgNBAdditionRequest")
        return rsrp

    def __determine_attaches_state(self):
        for attach in self._attach_attempts:
            attach.determine_state()


class NGAPAttachParser:
    def __init__(self):
        self._attach_attempts = []

    def parse_pcap(self, pcap):
        self._attach_attempts = []
        with LogHelper() as lh:
            finder = lh.add_pcap(
                pcap_file_path=pcap, lua=None, tshark_filter="ngap", output_log_file=None, clean_up_tmp_file=False
            )
            messages = finder.find_all(
                [
                    PM("InitialUEMessage", message_type_pattern="empty"),
                    PM("InitialContextSetupRequest", message_type_pattern="empty"),
                    PM("InitialContextSetupResponse", message_type_pattern="empty"),
                ]
            )
        for _ in messages.get("InitialUEMessage", []):
            attempt = NGAPAttach()
            attempt.init_ue_msg = True
            self._attach_attempts.append(attempt)
        for i in range(min(len(messages.get("InitialContextSetupRequest", [])), len(self._attach_attempts))):
            self._attach_attempts[i].init_context_setup_req = True
        for i in range(min(len(messages.get("InitialContextSetupResponse", [])), len(self._attach_attempts))):
            self._attach_attempts[i].init_context_setup_resp = True
        self.__determine_attaches_state()
        logger.info("Output attach attempts list:")
        logger.info(self._attach_attempts)
        return self._attach_attempts

    def __determine_attaches_state(self):
        for attach in self._attach_attempts:
            attach.determine_state()
