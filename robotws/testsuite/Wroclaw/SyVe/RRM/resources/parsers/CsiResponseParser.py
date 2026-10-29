"""
author/contact:   krzysztof.1.wrobel@nokia.com, I_MN_RAN_PZ1_WRO_7_SG_GMS <I_MN_RAN_PZ1_WRO_7_SG@internal.nsn.com>
Description:      functions to tracking params in csv
"""

import re
import csv
import math
from collections import deque
from testsuite.Wroclaw.SyVe.RRM.resources.Logger import Logger

MIMO_MODE_CLOSE_LOOP = "cl"
MIMO_MODE_OPEN_LOOP = "ol"
SHERPA_TTI_DELTA = 1.0


class CsiResponseParser(object):

    def __init__(self):
        self.requests_counter = 0
        self.response_counter = 0
        self.harq_counter = 0
        self.failed_resp = 0
        self.failed_resp_req_list = []
        self.failed_harq_msg_list = []
        self.found_requests_response = deque()
        self.found_requests_response_harq = deque()
        self.missing_harq_d_counter = 0
        self.missing_resp = 0
        self.missing_harq = 0

    def check_the_csv_file_req_resp_tdd(self, filepath, failedresp_percent=2):
        """
                Function is parsing and checking that a-csi request and responses are correct
        Example:
            CsiResponseParser.check_the_csv_file_req_resp_tdd("/home/ute/Desktop/micro__l1l2Trace.csv")
        :param filepath: Specify file path plus full file name
        :param failedresp_percent: percentage of failed responses 2 % is by default
        :return: None
        """
        self._check_the_csv_file_req_resp(
            filepath, self._validate_value_resp_tdd, subframe=19, failedresp_percent=failedresp_percent,
            mimo_mode=MIMO_MODE_CLOSE_LOOP)

    def check_the_csv_file_req_resp_fdd_cl(self, filepath, failedresp_percent=2):
        """
                Function is parsing and checking that a-csi request and responses are correct
        Example:
            CsiResponseParser.check_the_csv_file_req_resp_fdd_cl("/home/ute/Desktop/micro__l1l2Trace.csv")
        :param filepath: Specify file path plus full file name
        :param failedresp_percent: percentage of failed responses 2 % is by default
        :return: None
        """
        self._check_the_csv_file_req_resp(
            filepath, self._validate_value_resp_fddcl, subframe=9, failedresp_percent=failedresp_percent,
            mimo_mode=MIMO_MODE_CLOSE_LOOP)

    def check_the_csv_file_req_resp_fdd_ol(self, filepath, failedresp_percent=2):
        """
                Function is parsing and checking that a-csi request and responses are correct
        Example:
            CsiResponseParser.check_the_csv_file_req_resp_fdd_ol("/home/ute/Desktop/micro__l1l2Trace.csv")
        :param filepath: Specify file path plus full file name
        :param failedresp_percent: percentage of failed responses 2 % is by default
        :return: None
        """
        self._check_the_csv_file_req_resp(
            filepath,  self._validate_value_resp_fddol, subframe=9, failedresp_percent=failedresp_percent,
            mimo_mode=MIMO_MODE_OPEN_LOOP)

    def _check_the_csv_file_req_resp(self, filepath, parsing_func, subframe, failedresp_percent, mimo_mode):
        resp_pattern = self._choose_pattern_for_mimo_mode(mimo_mode)
        with open(filepath) as csvfile:
            for line in csv.DictReader(csvfile, delimiter=";"):
                self._check_uplink_indication_aperiodic_request(line)
                if self.found_requests_response:
                    self._check_resp_for_uplink_aperiodic_req(line, parsing_func,
                                                              subframe, resp_pattern)
                if self.found_requests_response_harq:
                    self._check_responses_for_pusch_harq(line, subframe)
        self._verify_acsi_harq_response(failedresp_percent)

    def _check_responses_for_pusch_harq(self, line, subframe):
        eldest_req = self.found_requests_response_harq[0]
        response_params = self._get_sherpatti_rnti_and_response_time(eldest_req, subframe)
        if self._is_harq_time_not_expired(response_params, line):
            self._validate_harq_tdd_and_fdd(line, response_params)

    def _check_resp_for_uplink_aperiodic_req(self, line, parsing_func, subframe,
                                             resp_pattern):
        eldest_req = self.found_requests_response[0]
        response_params = self._get_sherpatti_rnti_and_response_time(eldest_req, subframe)
        if self._is_response_time_not_expired(response_params, line) and \
                re.search(resp_pattern, "{} {}".format(line["MSGID"], line["TEXT"])):
            self._validate_resp_tdd_and_fdd(line, response_params, eldest_req, parsing_func)

    def _is_response_time_not_expired(self, response_params, line):
        req_sherpatti = response_params[0]
        if float(line["SHERPA TTI"]) > float(req_sherpatti) + SHERPA_TTI_DELTA:
            self.missing_resp += 1
            acsi_request = self.found_requests_response.popleft()
            # print("Missing response for request {}", acsi_request)    #left only for debug if needed
            return False
        return True

    def _is_harq_time_not_expired(self, response_params, line):
        req_sherpatti = response_params[0]
        if float(line["SHERPA TTI"]) > float(req_sherpatti) + SHERPA_TTI_DELTA:
            self.missing_harq += 1
            acsi_request = self.found_requests_response_harq.popleft()
            # print("Missing harq for request {}", acsi_request)     #left only for debug if needed
            return False
        return True

    @staticmethod
    def _choose_pattern_for_mimo_mode(mimo_mode):
        if mimo_mode == MIMO_MODE_CLOSE_LOOP:
            return re.compile("(Ul PuschReceiveRespPs).*(CSI -)")
        elif mimo_mode == MIMO_MODE_OPEN_LOOP:
            return re.compile("(Ul PuschReceiveRespPs)")

    def _check_uplink_indication_aperiodic_request(self, line):
        aperiodic_req_pattern = re.compile("(Dl PdcchSendReq).*(UL grant 0-1).*(bitMapACSI=1)")
        if re.search(aperiodic_req_pattern, "{} {}".format(line["MSGID"], line["TEXT"])):
            self.requests_counter += 1
            self.found_requests_response.append(line)
            self.found_requests_response_harq.append(line)

    def _verify_acsi_harq_response(self, failedresp_percent):
        Logger.info("All request {}, all responses {}, all harq {}, rdUciOnly - missing harqU found harqD {}"
                    .format(self.requests_counter, self.response_counter, self.harq_counter,
                            self.missing_harq_d_counter))
        Logger.info("Failed responses {}, failed harq {}, missing responses {}, missing harq {}"
                    .format(self.failed_resp, len(self.failed_harq_msg_list), self.missing_resp, self.missing_harq))

        most_important_info = slice(0, 4)
        assert self.requests_counter, "Missing aperiodic request:\n"
        failed_resp = math.ceil(failedresp_percent * (self.requests_counter / 100.))
        assert failed_resp > len(self.failed_harq_msg_list), "To many failed messages harq \n" \
                                                             "List 4 harq messages \n {}" \
                                                             .format(self.failed_harq_msg_list[most_important_info])
        assert failed_resp > len(self.failed_resp_req_list)/2, \
            "Too many failed responses, allowed number of failed messages is {} :\n" \
            "number failed responses {} \n" \
            "first 2 request and responses\n {}".format(failed_resp, self.failed_resp,
                                                        self.failed_resp_req_list[most_important_info])
        assert failed_resp > self.missing_resp, \
            "Too many missing responses {} allowed missing messages is {}".format(self.missing_resp, failed_resp)

        if failed_resp < self.missing_harq:
            Logger.warning("According to PR735408 harq messages is not mandatory, missing harq: {}"
                           .format(self.missing_harq))

    def _get_sherpatti_rnti_and_response_time(self, eldest_req, subframes):
        # remove walkaround because the responses for tdd are send in k2 = 8 not 7(for trunk)
        # other branch have k2 set to 7 and fdd k2 =2 for all branch
        k2_offset = int(self._get_param_from_text('k2', eldest_req["TEXT"]).split('=')[1])
        k2offset_resp = self._calculate_frame_resp(eldest_req["AIR TTI"], k2_offset, subframes)
        return [eldest_req["SHERPA TTI"], eldest_req["RNTI"], k2offset_resp]

    # @staticmethod
    def _validate_resp_tdd_and_fdd(self, line_resp, response_params, eldest_req, validation_function):
        resp_sherpatti = line_resp["SHERPA TTI"]
        req_sherpatti = response_params[0]
        req_rnti = response_params[1]
        k2offset_resp = response_params[2]
        if re.search(k2offset_resp, line_resp["AIR TTI"]) and re.search(req_rnti, line_resp["RNTI"]) and \
                float(req_sherpatti) <= float(resp_sherpatti) < float(req_sherpatti) + SHERPA_TTI_DELTA:
            self.found_requests_response.popleft()
            validation_function(line_resp, eldest_req)

    def _validate_harq_tdd_and_fdd(self, line_harq, response_params):
        resp_sherpatti = line_harq["SHERPA TTI"]
        req_sherpatti = response_params[0]
        req_rnti = response_params[1]
        k2offset_resp = response_params[2]
        if re.search(k2offset_resp, line_harq["AIR TTI"]) and re.search(req_rnti, line_harq["RNTI"]) and \
                float(req_sherpatti) <= float(resp_sherpatti) < float(req_sherpatti) + SHERPA_TTI_DELTA:
            self._check_if_harqu_is_present(line_harq)
            self._check_if_harqd_is_present(line_harq)

    def _check_if_harqu_is_present(self, line_harq):
        harqu_push_receive_resp = re.compile("Ul PuschReceiveRespHarqU")
        if re.search(harqu_push_receive_resp, line_harq["MSGID"]):
            self.found_requests_response_harq.popleft()
            self._validate_value_harq_tdd_fdd(line_harq)

    def _check_if_harqd_is_present(self, line_harq):
        harqd_push_receive_resp = re.compile("Ul PuschReceiveRespHarqD")
        if re.search(harqd_push_receive_resp, line_harq["MSGID"]):
            self.found_requests_response_harq.popleft()
            self.missing_harq_d_counter += 1
            # print(line_harq)      #left only for debug if needed

    def _validate_value_harq_tdd_fdd(self, line_harq):
        if self._is_ok_in_crc_harq(line_harq) and self._is_nodtx_found_in_harq(line_harq):
            self.harq_counter += 1
        else:
            self.failed_harq_msg_list.append(line_harq)

    def _is_ok_in_crc_harq(self, line_harq):
        return 'OK' in self._get_param_from_text('crc', line_harq["TEXT"])

    def _is_nodtx_found_in_harq(self, line_harq):
        return 'NODTX' in self._get_param_from_text('dtx', line_harq["TEXT"])

    def _validate_value_resp_tdd(self, line_resp, eldest_req):
        if self._are_csi_part_bits_not_zero(line_resp)\
                and self._is_nodtx_found_in_resp(line_resp) and self._are_crc_checks_zeros(line_resp):
            self.response_counter += 1
        else:
            self._perform_action_for_fails(eldest_req, line_resp)

    def _validate_value_resp_fddcl(self, line_resp, eldest_req):
        if self._is_pmi_x1_is_not_zero(line_resp) or self._is_pmi_x2_is_not_zero(line_resp)\
                or self._is_pmi_is_not_zero(line_resp):
            self._validate_value_resp_fddcl_pmi_x1_x2_not_zero(eldest_req, line_resp)
        else:
            self._validate_value_resp_fddcl_pmi_x1_x2_is_zero(eldest_req, line_resp)

    def _validate_value_resp_fddol(self, line_resp, eldest_req):
        if self._is_csi_part_1_not_zero(line_resp)\
                and self._is_nodtx_found_in_resp(line_resp) and self._are_crc_checks_zeros(line_resp):
            self.response_counter += 1
        else:
            self._perform_action_for_fails(eldest_req, line_resp)

    def _perform_action_for_fails(self, eldest_req, line_resp):
        self.failed_resp += 1
        self.failed_resp_req_list.append(eldest_req)
        self.failed_resp_req_list.append(line_resp)

    def _is_pmi_x1_is_not_zero(self, line_resp):
        _pmix1 = self._get_param_from_text('pmiX1', line_resp["TEXT"])
        if _pmix1 is not None:
            return int((_pmix1.split("=")[1]).split("?")[0], 16) != 0

    def _is_pmi_x2_is_not_zero(self, line_resp):
        _pmix2 = self._get_param_from_text('pmiX2', line_resp["TEXT"])
        if _pmix2 is not None:
            return int((_pmix2.split("=")[1]).split("?")[0], 16) != 0

    def _is_pmi_is_not_zero(self, line_resp):
        _pmi = self._get_param_from_text('pmi', line_resp["TEXT"])
        if _pmi is not None:
            return int((_pmi.split("=")[1]).split("?")[0], 16) != 0

    def _validate_value_resp_fddcl_pmi_x1_x2_not_zero(self, eldest_req, line_resp):
        if self._are_csi_part_bits_not_zero(line_resp) \
                and self._is_nodtx_found_in_resp(line_resp) and self._are_crc_checks_zeros(line_resp):
            self.response_counter += 1
        else:
            self._perform_action_for_fails(eldest_req, line_resp)

    def _validate_value_resp_fddcl_pmi_x1_x2_is_zero(self, eldest_req, line_resp):
        if self._is_csi_part_1_not_zero(line_resp) and self._is_csi_part_2_is_zero(line_resp)\
                and self._is_nodtx_found_in_resp(line_resp) and self._are_crc_checks_zeros(line_resp):
            self.response_counter += 1
        else:
            self._perform_action_for_fails(eldest_req, line_resp)

    def _are_csi_part_bits_not_zero(self, line_resp):
        return self._is_csi_part_1_not_zero(line_resp) and self._is_csi_part_2_not_zero(line_resp)

    def _is_csi_part_1_not_zero(self, line_resp):
        return int(self._get_param_from_text('uciCsiPart1Bits', line_resp["TEXT"]).split("=")[1], 16) != 0

    def _is_csi_part_2_not_zero(self, line_resp):
        return int(self._get_param_from_text('uciCsiPart2Bits', line_resp["TEXT"]).split("=")[1], 16) != 0

    def _is_csi_part_2_is_zero(self, line_resp):
        return int(self._get_param_from_text('uciCsiPart2Bits', line_resp["TEXT"]).split("=")[1], 16) == 0

    def _is_nodtx_found_in_resp(self, line_resp):
        return 'NODTX' in self._get_param_from_text('dtxCsiPart1', line_resp["TEXT"]) and\
                        'NODTX' in self._get_param_from_text('dtxCsiPart2', line_resp["TEXT"])

    def _are_crc_checks_zeros(self, line_resp):
        return int(self._get_param_from_text('csiPart1CrcCheck', line_resp["TEXT"]).split("=")[1]) == 0 and\
               int(self._get_param_from_text('csiPart2CrcCheck', line_resp["TEXT"]).split("=")[1]) == 0

    @staticmethod
    def _get_param_from_text(regexfilter, line_parse):
        param_pattern = re.compile(r'(?is)(' + regexfilter + r'=(.|\n)*?)(,|\n|$)')
        if re.search(param_pattern, line_parse):
            return re.search(param_pattern, line_parse).group(1)

    @staticmethod
    def _calculate_frame_resp(airtti, k2_offset, max_slot):
        frame_calculation_offset = 1
        max_nr_of_frames = 1024 + frame_calculation_offset
        split_airtti = str(airtti).split('.')
        frame = int(split_airtti[0])
        slot = int(split_airtti[1])
        frame = frame if slot + k2_offset <= max_slot else (frame + 1) % max_nr_of_frames
        slot = slot + k2_offset if slot + k2_offset <= max_slot else (slot + k2_offset - 1) % max_slot
        return "{}.{}".format(frame, str(slot).rjust(2, "0"))
