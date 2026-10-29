from abc import ABCMeta, abstractproperty
from itertools import chain

from testsuite.Krakow.RRM.RAN_PZ.regression.KRK3.resources.log.log import blog
from testsuite.Krakow.RRM.RAN_PZ.regression.KRK3.resources.log.tshark import TSharkHelper
from testsuite.Krakow.RRM.RAN_PZ.regression.KRK3.resources.log.split_tshark_output_into_frames import \
    split_tshark_output_into_frames
from testsuite.Krakow.RRM.RAN_PZ.regression.KRK3.resources.log.tti_body_process_func import \
    tti_body_process_functions, \
    default_tti_process_message
from testsuite.Krakow.RRM.RAN_PZ.regression.KRK3.resources.common.str_pattern_dict import StrPatternDict
from testsuite.Krakow.RRM.RAN_PZ.regression.KRK3.resources.common.file_helper import yield_lines_from_file


import unittest
from mock import MagicMock, mock_open, patch, call


class LogReader(object):

    __metaclass__ = ABCMeta

    @abstractproperty
    def list(self):
        """  """
        pass

    @abstractproperty
    def generator(self):
        """  """
        pass

    @abstractproperty
    def reset_generator(self):
        """  """
        pass


class LogReaderBase(LogReader):
    """
    base class for log reader
    """

    def __init__(self, log_file):
        self.log_file = log_file
        self._gen = self._create_gen()

    def _create_gen(self):
        return yield_lines_from_file(self.log_file, skip_empty=True)

    def generator(self):
        return self._gen

    def reset_generator(self):
        self._gen = self._create_gen()
        return self._gen

    def list_rest(self):
        l_ = list(self._gen)
        self.reset_generator()
        return l_

    def list_all(self):
        self.reset_generator()
        return self.list_rest()

    def list(self):
        return self.list_all()


class SyslogReader(LogReaderBase):
    """
    reads syslog file/files if multiple are passed in list
    generators are chained so end effect is that it seen like
    one larger file
    """

    def __init__(self, log_files):
        if not isinstance(log_files, list):
            log_files = [log_files]
        self.log_files = log_files
        self._gen = self._create_gen()

    def _create_gen(self):
        return chain(*[yield_lines_from_file(f, skip_empty=True) for f in self.log_files])


class TTIReader(LogReaderBase):
    """
    reads tti in mesgname: .... format if multiple files are passed in list
    generators are chained so end effect is that it seen like one larger file
    reads tti processes body of message for eatch message based on one
    from tti_body_process_functions dict or default_tti_process_message
    if not found in tti_body_process_functions allows for passing custom
    dict {'message_name': body_process_function} whitch is merged to
    tti_body_process_functions dict
    [so passed keys will get updated but only inside class]
    """

    def __init__(self, log_files, additional_process_funcs=None, name_to_body_separator=': '):
        if not isinstance(log_files, list):
            log_files = [log_files]
        self.log_files = log_files
        self.separator = name_to_body_separator
        additions = additional_process_funcs if additional_process_funcs else {}
        self.process_funcs = dict(tti_body_process_functions, **additions)
        self._gen = self._create_gen()

    def _process_message(self, line):
        message_name, message_body = line.split(self.separator)
        message = StrPatternDict()
        message['message'] = message_name
        # ponder whitch approuch is better in long run
        # process = self.process_funcs.get(message_name, False)
        # if not process:
        #     message['unporcessed'] = True
        #     return message
        process = self.process_funcs.get(message_name, default_tti_process_message)
        message_body = process(message_body)
        message.update(message_body)
        return message

    def _create_gen(self):
        return (
            self._process_message(line)
            for line
            in chain(*[yield_lines_from_file(f, strip=True) for f in self.log_files])
        )


class TsharkOutputReader(LogReaderBase):
    """
    reads tshark string output file and returns frames
    """

    def __init__(self, log_file):
        self.log_file = log_file
        self._gen = self._create_gen()

    def _create_gen(self):
        return split_tshark_output_into_frames(
            yield_lines_from_file(
                self.log_file, skip_empty=True
            )
        )


class PcapReader(TsharkOutputReader):
    """
    reads pcap files and puts its string output to tmp file witch is then read
    the decoding of pcap file and writtiong its string output to file is done here
    """

    def __init__(
        self, pcap_file_path, lua=None, shark_filter=None,
        ts_output_data_file_path=None, shark_options=None
    ):
        """
        makes list of messages or generator form pcap file
        if no output_data_file_path is passed then semi random one is generated

        for lua=None,        no lua will be used
        for lua=True,        attached lua will be used
        for lua=script_path, script_path lua will be used

        shark_options: list of tuple e.g. [('-o', 'someparam:TRUE'), ('-o', 'otherparam:TRUE')]
        """
        self.lua = lua
        self.shark_filter = shark_filter
        self.pcap_file_path = pcap_file_path
        self.log_file = ts_output_data_file_path
        self.shark_options = shark_options
        self._prepare_log_file()  # prepares data file for TsharkOutputReader generator
        self._gen = self._create_gen()

    def _prepare_log_file(self):
        """
        assembles and runs tshark command
        and writes its output to tmp file
        from witch generator reads frames
        """
        m = self.__class__.__name__+': writting tshark output from pcap file to {}'
        blog(m.format(self.log_file))
        shark = TSharkHelper()
        shark.add_pcap(self.pcap_file_path)
        if self.lua is not None:
            # TSharkHelper.add_luascript attaches default lua on None
            shark.add_luascript(lua_path={True: None}.get(self.lua, self.lua))
        if self.shark_filter:
            shark.add_filter(self.shark_filter)
        if self.shark_options:
            for param, value in self.shark_options:
                shark.add(param, value)
        shark.bite(self.log_file)


class IterableReader(LogReaderBase):
    """
    log reder designed use in case of having many messages
    and not knowing order they are received so we use any other finder
    then pass list of mesgs to IterableReader so we can sertch through them again
    """

    def __init__(self, iterable):
        """
        takes iterable and allows for processing passed in intrable so
        we get desired output generator
        """
        self.iterable = iterable
        self._gen = self._create_gen()

    def _create_gen(self):
        return (i for i in self.iterable)


class TestLogReaderBase(unittest.TestCase):

    @patch(__name__+'.yield_lines_from_file')
    def test_class(self, m_yield_lines_from_file):
        m_yield_lines_from_file.side_effect = lambda *a, **k: (l_ for l_ in [
            'PrachReceiveInd: slot,sfn,2,4',
            'SlotTypeReq: slot,sfn,3,6',
            'SlotTypeReq: slot,sfn,4,8',
        ])
        reader = LogReaderBase('mocked')
        out = reader.list_all()     # list_rest tested
        assert len(out) == 3
        out = reader.list_rest()    # reset_generator tested
        assert len(out) == 3


class TestSyslogReader(unittest.TestCase):

    @patch(__name__+'.yield_lines_from_file')
    def test_class(self, m_yield_lines_from_file):
        m_yield_lines_from_file.side_effect = lambda *a, **k: (l_ for l_ in [
            'PrachReceiveInd: slot,sfn,2,4',
            'SlotTypeReq: slot,sfn,3,6',
            'SlotTypeReq: slot,sfn,4,8',
        ])
        reader = SyslogReader('mocked')  # init tested
        out = reader.list_all()
        assert len(out) == 3
        reader = SyslogReader(['mocked', 'mocked'])   # _create_gen tested
        out = reader.list_all()
        assert len(out) == 6


class TestTsharkOutputReader(unittest.TestCase):

    @patch(__name__ + '.yield_lines_from_file')
    def test_class(self, m_yield_lines_from_file):
        m_yield_lines_from_file.side_effect = lambda *a, **k: (l_ for l_ in [
            'Frame 1382056: 70 bytes on wire (560 bits), 70 bytes captured (560 bits)\n',
            '    Encapsulation type: Ethernet (1)\n',
            '    Arrival Time: Jun  4, 2020 11:58:22.008503000 CEST\n',
            'SW Event\n',
            '    SW Event Header: 0002021900000000\n',
            '        Reserved: 0x00\n',
            '        Timestamp and Event format indicator: 0x02\n',
            'ICOM 5G Protocol\n',
            '    PrachReceiveInd (Structure)\n',
            '        sfn (Uint16): 0x02dd(733)\n',
            '        slot (Uint8): 0x01(1)\n',
            '        slot_subcells_padding (Bytes): 00\n',
            #
            'Frame 22961: 60 bytes on wire (480 bits), 60 bytes captured (480 bits)\n',
            '    Encapsulation type: Ethernet (1)\n',
            '    Arrival Time: Jun  4, 2020 11:53:14.825230000 CEST\n',
            'SW Event\n',
            '    SW Event Header: 0002012200000000\n',
            '        Reserved: 0x00\n',
            '        Timestamp and Event format indicator: 0x02\n',
            'ICOM 5G Protocol\n',
            '    SlotTypeReq (Structure)\n',
            '        subcellId (Uint8): 0x02(2)\n',
            '        subcellId_sfn_padding (Bytes): 01\n',
            '        sfn (Uint16): 0x02df(735)\n',
            '        slot (Uint8): 0x03(3)\n',
            '        slotType (Enum): 32 (l1_common_slotType_t.SLOT_TYPE_C5)\n',
        ])
        reader = TsharkOutputReader(log_file='mocked')

        msg_list = reader.list_all()
        assert isinstance(msg_list[0], StrPatternDict)
        assert isinstance(msg_list[1], StrPatternDict)
        assert len(msg_list) == 2
        # checks _create_gen
        # checks reset_generator
        # checks list_rest
        # checks list_all
        # checks list


class TestTTIReader(unittest.TestCase):

    @patch(__name__+'.yield_lines_from_file')
    def test_class(self, m_yield_lines_from_file):
        m_yield_lines_from_file.side_effect = lambda *a, **k: (l_ for l_ in [
            'PrachReceiveInd: slot,sfn,2,4',
            'SlotTypeReq: slot,sfn,3,6',
            'SlotTypeReq: slot,sfn,4,8',
        ])
        reader = TTIReader('mocked')  # init tested
        assert reader.process_funcs == tti_body_process_functions
        out = reader.list_all()
        assert len(out) == 3
        spd = StrPatternDict()
        spd['message'] = 'PrachReceiveInd'
        spd['slot'] = '2'
        spd['sfn'] = '4'
        assert out[0] == spd    # default_tti_process_message tested

        reader = TTIReader(['mocked', 'mocked'], {'foo': 'bar'})   # _create_gen tested
        tti_body_process_functions['foo'] = 'bar'
        assert reader.process_funcs == tti_body_process_functions  # checked additional func
        out = reader.list_all()
        assert len(out) == 6


class TestPcapReader(unittest.TestCase):

    @patch(__name__ + '.TSharkHelper')
    @patch(__name__ + '.PcapReader._create_gen')
    def test_class(self, m_create_gen, m_tshark_helper):
        tshark_helper = MagicMock()
        tshark_helper.add = MagicMock()
        tshark_helper.add_pcap = MagicMock()
        tshark_helper.add_luascript = MagicMock()
        tshark_helper.add_filter = MagicMock()
        tshark_helper.run_and_write_output_to_file = MagicMock()
        m_tshark_helper.return_value = tshark_helper
        m_create_gen.return_value = MagicMock()

        reader = PcapReader(
            pcap_file_path='mocked', shark_filter=None,
            lua='mocked', ts_output_data_file_path='/path/to/file'
        )
        m_create_gen.assert_called_once()               # call to _create_gen tested
        m_tshark_helper.assert_called_once()
        tshark_helper.add_filter.assert_not_called()
        tshark_helper.add.assert_not_called()
        tshark_helper.add_pcap.assert_called_once_with('mocked')
        tshark_helper.add_luascript.assert_called_once_with(lua_path='mocked')

        reader = PcapReader(
            pcap_file_path='mocked', shark_filter='asd',
            lua=None, ts_output_data_file_path=None
        )
        tshark_helper.add_luascript.assert_called_once_with(lua_path='mocked')
        tshark_helper.add_filter.assert_called_once()

        reader = PcapReader(
            pcap_file_path='mocked', shark_filter='asd',
            lua=None, ts_output_data_file_path=None, shark_options=[('-x', 'xyz'), ('-y', 'yyy')]
        )
        tshark_helper.add.assert_has_calls([call('-x', 'xyz'), call('-y', 'yyy')], any_order=True)


class TestIterableReader(unittest.TestCase):

    def setUp(self):
        self.i = [
            ('UserSetupReq', {'slot': '0x05(5)'}),
            ('SlotTypeReq', {'slot': '0x03(3)'}),
        ]
        self.reader = IterableReader(iterable=self.i)

    def test_process_element(self):
        assert self.reader.list_all() == self.i
