
from os import remove

from testsuite.Krakow.RRM.RAN_PZ.resources.log.readers import \
    SyslogReader, \
    TsharkOutputReader, \
    PcapReader, \
    IterableReader, \
    TTIReader
from testsuite.Krakow.RRM.RAN_PZ.resources.log.finder import MessageFinder
from testsuite.Krakow.RRM.RAN_PZ.resources.log.log import blog
from testsuite.Krakow.RRM.RAN_PZ.resources.common.file_helper import get_tmp_file_file_path

import unittest
from mock import MagicMock, mock_open, patch, call


class LogHelper(object):
    """
    class tha is convenient wrapper around message finder/log reader combo
    every log gets its unique tag witch then underlying message finder
    can be accessed with in case of pcap creation and cleanup of
    temporary files is also performed, in such case it is
    recommended to use this class as context manager
    """

    def __init__(self):
        self._cleanup_list = []

    def __enter__(self):
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        self.clean_up()

    def clean_up(self):
        for tmp_file in self._cleanup_list:
            try:
                remove(tmp_file)
            except OSError as e:
                em = self.__class__.__name__+': __exit__ error {} while removing {}'
                blog(em.format(tmp_file, e))

    def add_iterable(self, iterable):
        return MessageFinder(IterableReader(iterable))

    def add_syslog(self, log_files):
        return MessageFinder(SyslogReader(log_files=log_files))

    def add_tti(self, log_files, additional_process_funcs=None, name_to_body_separator=': '):
        return MessageFinder(TTIReader(
            log_files=log_files, additional_process_funcs=additional_process_funcs,
            name_to_body_separator=name_to_body_separator
        ))

    def add_tshark_output(self, ts_output_file):
        return MessageFinder(TsharkOutputReader(log_file=ts_output_file))

    def add_pcap(
        self, pcap_file_path, lua=None, shark_filter=None,
        ts_output_data_file_path=None, clean_up_tmp_file=True, shark_options=None
    ):
        """
        ts_output_data_file_path is path to file to write tshark output to
        if None semi random one will be created and cleaned up after use
        unless clean_up_tmp_file is set to False,
        for lua=None,        no lua will be used
        for lua=True,        attached lua will be used
        for lua=script_path, script_path lua will be used
        shark_options: list of tuple e.g. [('-o', 'someparam:TRUE'), ('-o', 'otherparam:TRUE')]
        """

        if not ts_output_data_file_path:
            m = self.__class__.__name__+': generating semi random tshark output data file path'
            blog(m)
            ts_output_data_file_path = get_tmp_file_file_path(tail='.pcap')

        m = self.__class__.__name__+': tshark output data file path: {}'
        blog(m.format(ts_output_data_file_path))

        if clean_up_tmp_file:
            self._cleanup_list.append(ts_output_data_file_path)

        return MessageFinder(PcapReader(
            pcap_file_path=pcap_file_path, lua=lua, shark_filter=shark_filter,
            ts_output_data_file_path=ts_output_data_file_path, shark_options=shark_options
        ))


class TestLogHelper(unittest.TestCase):

    def setUp(self):
        self.lh = LogHelper()

    @patch(__name__+'.remove')
    def test_clean_up(self, m_remove):
        self.lh._cleanup_list = ['tmp/asd.tmp', 'tmp/zxc.tmp']
        self.lh.clean_up()
        m_remove.assert_has_calls([call('tmp/asd.tmp'), call('tmp/zxc.tmp')])

    @patch(__name__+'.TsharkOutputReader')
    @patch(__name__+'.MessageFinder')
    def test_add_tshark_output(self, m_message_finder, m_tshark_output_file_reader):
        finder = MagicMock()
        m_message_finder.return_value = finder
        reader = MagicMock()
        m_tshark_output_file_reader.return_value = reader
        returned_finder = self.lh.add_tshark_output('mocked')
        m_tshark_output_file_reader.assert_called_once_with(log_file='mocked')
        m_message_finder.assert_called_once_with(reader)
        assert returned_finder == finder

    @patch(__name__+'.SyslogReader')
    @patch(__name__+'.MessageFinder')
    def test_add_syslog(self, m_message_finder, m_syslog_log_reader):
        finder = MagicMock()
        m_message_finder.return_value = finder
        reader = MagicMock()
        m_syslog_log_reader.return_value = reader
        returned_finder = self.lh.add_syslog('mocked')
        m_syslog_log_reader.assert_called_once_with(log_files='mocked')
        m_message_finder.assert_called_once_with(reader)
        assert returned_finder == finder

    @patch(__name__ + '.IterableReader')
    @patch(__name__ + '.MessageFinder')
    def test_add_iterable(self, m_message_finder, m_iterable_log_reader):
        finder = MagicMock()
        m_message_finder.return_value = finder
        reader = MagicMock()
        m_iterable_log_reader.return_value = reader
        returned_finder = self.lh.add_iterable('process')
        m_iterable_log_reader.assert_called_once_with('process')
        m_message_finder.assert_called_once_with(reader)
        assert returned_finder == finder

    @patch(__name__+'.TTIReader')
    @patch(__name__+'.MessageFinder')
    def test_add_tti(self, m_message_finder, m_tti_Reader):
        finder = MagicMock()
        m_message_finder.return_value = finder
        reader = MagicMock()
        m_tti_Reader.return_value = reader
        returned_finder = self.lh.add_tti('mocked')
        m_tti_Reader.assert_called_once_with(
            log_files='mocked', additional_process_funcs=None, name_to_body_separator=': '
        )
        m_message_finder.assert_called_once_with(reader)
        assert returned_finder == finder

    @patch(__name__ + '.get_tmp_file_file_path')
    @patch(__name__ + '.PcapReader')
    @patch(__name__ + '.MessageFinder')
    def test_add_pcap(self, m_message_finder, m_pcap_reader, m_get_tmp_file_file_path):
        m_get_tmp_file_file_path.return_value = 'tmp/1234.tmp'
        finder = MagicMock()
        m_message_finder.return_value = finder
        reader = MagicMock()
        m_pcap_reader.return_value = reader
        returned_finder = self.lh.add_pcap(
            pcap_file_path='path/file.pcap', lua=None, shark_filter=None,
            ts_output_data_file_path=None, clean_up_tmp_file=True, shark_options=[('-a', 'abc')]
        )
        m_get_tmp_file_file_path.assert_called_once()
        assert self.lh._cleanup_list == ['tmp/1234.tmp']

        m_pcap_reader.assert_called_once_with(
            pcap_file_path='path/file.pcap', lua=None, shark_filter=None,
            ts_output_data_file_path='tmp/1234.tmp', shark_options=[('-a', 'abc')]
        )
        m_message_finder.assert_called_once_with(reader)
        assert returned_finder == finder
