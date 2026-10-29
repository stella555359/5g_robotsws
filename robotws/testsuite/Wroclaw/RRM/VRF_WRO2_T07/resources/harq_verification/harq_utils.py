import testsuite.Wroclaw.RRM.resources.rrm_fixture as fixture
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log import blog
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log_analyzer.log_helper import LogHelper
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log_analyzer.matchers import PcapMessageMatcher


class PcapReader(object):
    def __init__(self, ts_filter, message_name_patterns, pcap_path=None):
        self.pcap_file = fixture.get_default_pcap_filepath() if not pcap_path else pcap_path
        self.ts_filter = ts_filter
        self.message_name_patterns = message_name_patterns
        self.frames = self._log_finder(self.pcap_file, self.ts_filter, self.message_name_patterns)

    @staticmethod
    def _log_finder(pcap_file, tfilter, message_name_patterns):
        with LogHelper() as lh:
            finder = lh.add_pcap(pcap_file_path=pcap_file, tshark_filter=tfilter, lua=None)
            output_list = []
            for message_pattern in message_name_patterns:
                found_patterns_list = finder.find_all(PcapMessageMatcher(message_pattern,
                                                                         message_type_pattern='empty'))
                output_list = output_list + found_patterns_list
            return output_list


class Harq(PcapReader):
    def __init__(self, ts_filter, message_name_patterns, pcap_path=None):
        super(Harq, self).__init__(ts_filter=ts_filter, message_name_patterns=message_name_patterns,
                                   pcap_path=pcap_path)
        self.crc, self.dtx = self._get_all_crc_and_dtx()

    def _get_all_crc_and_dtx(self):
        crc, dtx = [], []
        for frame in self.frames:
            crc.append(self._get_crc_from_frame(frame))
            dtx.append(self._get_dtx_from_frame(frame))
        assert crc and dtx, "No crc or dtx present in provided logs"
        return crc, dtx

    @staticmethod
    def _get_crc_from_frame(frame):
        return frame.find('*crc*').first()['val']

    @staticmethod
    def _get_dtx_from_frame(frame):
        return frame.find('*dtx*').first()['val']

    def verify_positive_harq_feedback(self, percent_margin_of_error=5):
        self._verify_positive_crc(percent_margin_of_error)
        self._verify_positive_dtx(percent_margin_of_error)

    def verify_negative_harq_feedback(self, percent_margin_of_error=20):
        self._verify_negative_crc(percent_margin_of_error)
        self._verify_negative_dtx(percent_margin_of_error)

    def _verify_positive_crc(self, percent_margin_of_error):
        count_errors = 0
        for single_crc in self.crc:
            if 'NOK' in single_crc:
                count_errors += 1

        error_in_percent = count_errors * 100 / len(self.crc)
        blog('CRC errors: {}%.'.format(error_in_percent))
        assert error_in_percent <= percent_margin_of_error, \
            fixture.assert_msg.format(message='Incorrect CRC.',
                                      expected='Less than {margin}%.'.format(margin=percent_margin_of_error),
                                      current='{errors}%'.format(errors=error_in_percent))

    def _verify_positive_dtx(self, percent_margin_of_error):
        count_errors = 0
        for single_dtx in self.dtx:
            if 'NON' not in single_dtx:
                count_errors += 1

        error_in_percent = count_errors * 100 / len(self.dtx)
        blog('DTX errors: {}%.'.format(error_in_percent))
        assert error_in_percent <= percent_margin_of_error, \
            fixture.assert_msg.format(message='Incorrect DTX.',
                                      expected='Less than {margin}%.'.format(margin=percent_margin_of_error),
                                      current='{errors}%'.format(errors=error_in_percent))

    def _verify_negative_crc(self, percent_margin_of_error):
        count_errors = 0
        for single_crc in self.crc:
            if 'NOK' in single_crc:
                count_errors += 1

        error_in_percent = 100 - (count_errors * 100 / len(self.crc))
        blog('error: {}%.'.format(error_in_percent))
        assert error_in_percent <= percent_margin_of_error, \
            fixture.assert_msg.format(message='Incorrect CRC.',
                                      expected='Less than {margin}%.'.format(margin=percent_margin_of_error),
                                      current='{errors}%'.format(errors=error_in_percent))

    def _verify_negative_dtx(self, percent_margin_of_error):
        count_errors = 0
        for single_dtx in self.dtx:
            if 'NON' not in single_dtx:
                count_errors += 1

        error_in_percent = 100 - (count_errors * 100 / len(self.dtx))
        blog('error: {}%.'.format(error_in_percent))
        assert error_in_percent <= percent_margin_of_error, \
            fixture.assert_msg.format(message='Incorrect DTX.',
                                      expected='Less than {margin}%.'.format(margin=percent_margin_of_error),
                                      current='{errors}%'.format(errors=error_in_percent))


class HarqU(Harq):
    def __init__(self, pcap_path=None):
        super(HarqU, self).__init__(ts_filter='uldata_puschreceiverespharqu',
                                    message_name_patterns=['PuschReceiveRespHarqU'], pcap_path=pcap_path)


class HarqD(Harq):
    def __init__(self, pcap_path=None):
        super(HarqD, self).__init__(ts_filter='uldata_pucchreceiverespharqd',
                                    message_name_patterns=['PuschReceiveRespHarqD'], pcap_path=pcap_path)
