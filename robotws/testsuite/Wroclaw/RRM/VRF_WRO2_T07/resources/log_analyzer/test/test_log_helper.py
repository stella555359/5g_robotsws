import testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log_analyzer.log_helper as log_helper

import unittest
from mock import MagicMock, patch, call


class TestLogHelper(unittest.TestCase):

    def setUp(self):
        self.lh = log_helper.LogHelper()

    @patch(__name__+'.log_helper.remove')
    def test_cleanup(self, m_remove):
        self.lh._cleanup_list = ['tmp/asd.tmp', 'tmp/zxc.tmp']
        self.lh.clean_up()
        m_remove.assert_has_calls([call('tmp/asd.tmp'), call('tmp/zxc.tmp')])

    @patch(__name__+'.log_helper.LineReader')
    @patch(__name__+'.log_helper.MessageFinder')
    def test_add_syslog(self, m_message_finder, m_line_reader):
        finder = MagicMock()
        m_message_finder.return_value = finder
        reader = MagicMock()
        m_line_reader.return_value = reader
        returned_finder = self.lh.add_syslog('mocked')
        m_line_reader.assert_called_once_with(log_files='mocked')
        m_message_finder.assert_called_once_with(reader)
        assert returned_finder == finder

    @patch(__name__ + '.log_helper.IterableReader')
    @patch(__name__ + '.log_helper.MessageFinder')
    def test_add_iterable(self, m_message_finder, m_iterable_log_reader):
        finder = MagicMock()
        m_message_finder.return_value = finder
        reader = MagicMock()
        m_iterable_log_reader.return_value = reader
        returned_finder = self.lh.add_iterable('process')
        m_iterable_log_reader.assert_called_once_with('process')
        m_message_finder.assert_called_once_with(reader)
        assert returned_finder == finder

    @patch(__name__+'.log_helper.TsharkOutputReader')
    @patch(__name__+'.log_helper.MessageFinder')
    def test_add_tshark_output(self, m_message_finder, m_tshark_output_file_reader):
        finder = MagicMock()
        m_message_finder.return_value = finder
        reader = MagicMock()
        m_tshark_output_file_reader.return_value = reader
        returned_finder = self.lh.add_tshark_output('mocked')
        m_tshark_output_file_reader.assert_called_once_with(log_file='mocked')
        m_message_finder.assert_called_once_with(reader)
        assert returned_finder == finder

    @patch(__name__ + '.log_helper.TTIReader')
    @patch(__name__ + '.log_helper.MessageFinder')
    def test_add_tti(self, m_message_finder, m_tti_reader):
        finder = MagicMock()
        m_message_finder.return_value = finder
        reader = MagicMock()
        m_tti_reader.return_value = reader
        returned_finder = self.lh.add_tti('mocked')
        m_tti_reader.assert_called_once_with(
            log_files='mocked', additional_process_funcs=None, name_to_body_separator=': '
        )
        m_message_finder.assert_called_once_with(reader)
        assert returned_finder == finder

    @patch(__name__ + '.log_helper.get_tmp_filepath')
    @patch(__name__ + '.log_helper.PcapReader')
    @patch(__name__ + '.log_helper.MessageFinder')
    def test_add_pcap(self, m_message_finder, m_pcap_reader, m_get_tmp_filepath):
        m_get_tmp_filepath.return_value = 'tmp/1234.pcap.tmp'
        finder = MagicMock()
        m_message_finder.return_value = finder
        reader = MagicMock()
        m_pcap_reader.return_value = reader

        returned_finder = self.lh.add_pcap(
            pcap_file_path='path/file.pcap', lua=None, tshark_filter=None,
            output_log_file=None, clean_up_tmp_file=True, tshark_options=[('-a', 'abc')]
        )
        m_get_tmp_filepath.assert_called_once()
        assert self.lh._cleanup_list == ['tmp/1234.pcap.tmp']

        m_pcap_reader.assert_called_once_with(
            pcap_file_path='path/file.pcap',
            output_log_file='tmp/1234.pcap.tmp',
            lua=None, tshark_filter=None, tshark_options=[('-a', 'abc')]
        )
        m_message_finder.assert_called_once_with(reader)
        assert returned_finder == finder
