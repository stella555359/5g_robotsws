import testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log_analyzer.readers as readers
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log_analyzer.common.str_pattern_dict import StrPatternDict

import unittest
from mock import MagicMock, patch, call


class TestLogReaderBase(unittest.TestCase):

    @patch(__name__+'.readers.yield_lines_from_file')
    def test_class(self, m_yield_lines_from_file):
        m_yield_lines_from_file.side_effect = lambda *a, **k: (l_ for l_ in [
            'PrachReceiveInd: slot,sfn,2,4',
            'SlotTypeReq: slot,sfn,3,6',
            'SlotTypeReq: slot,sfn,4,8',
        ])
        reader = readers.LogReaderBase('mocked')
        assert len(list(reader.generator())) == 3
        assert len(list(reader.generator())) == 0
        reader.reset_generator()
        assert len(list(reader.generator())) == 3


class TestLineReader(unittest.TestCase):

    @patch(__name__+'.readers.yield_lines_from_file')
    def test_class(self, m_yield_lines_from_file):
        m_yield_lines_from_file.side_effect = lambda *a, **k: (l_ for l_ in [
            'PrachReceiveInd: slot,sfn,2,4',
            'SlotTypeReq: slot,sfn,3,6',
            'SlotTypeReq: slot,sfn,4,8',
        ])
        reader = readers.LineReader('mocked')  # init tested
        out = list(reader.generator())
        assert len(out) == 3

        reader = readers.LineReader(['mocked', 'mocked'])
        out = list(reader.generator())
        assert len(out) == 6


class TestTTIReader(unittest.TestCase):

    @patch(__name__+'.readers.yield_lines_from_file')
    def test_class(self, m_yield_lines_from_file):
        m_yield_lines_from_file.side_effect = lambda *a, **k: (l_ for l_ in [
            'PrachReceiveInd: slot,sfn,2,4',
            'SlotTypeReq: slot,sfn,3,6',
            'SlotTypeReq: slot,sfn,4,8',
        ])
        reader = readers.TTIReader('mocked')  # init tested
        assert reader.process_funcs == readers.tti_body_process_functions
        out = list(reader.generator())
        assert len(out) == 3
        spd = StrPatternDict()
        spd['message'] = 'PrachReceiveInd'
        spd['slot'] = '2'
        spd['sfn'] = '4'
        assert out[0] == spd    # default_tti_process_message tested

        reader = readers.TTIReader(['mocked', 'mocked'], {'foo': 'bar'})   # _create_gen tested
        readers.tti_body_process_functions['foo'] = 'bar'
        assert reader.process_funcs == readers.tti_body_process_functions  # checked additional func
        out = list(reader.generator())

        assert len(out) == 6


class TestTsharkOutputReader(unittest.TestCase):

    @patch(__name__ + '.readers.yield_lines_from_file')
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
        reader = readers.TsharkOutputReader(log_file='mocked')

        msg_list = list(reader.generator())
        assert isinstance(msg_list[0], StrPatternDict)
        assert isinstance(msg_list[1], StrPatternDict)
        assert len(msg_list) == 2
        # checked underneath _create_gen method


class TestPcapReader(unittest.TestCase):

    @patch(__name__ + '.readers.TSharkHelper')
    @patch(__name__ + '.readers.PcapReader._create_gen')
    def test_class(self, m_create_gen, m_tshark_helper):
        tshark = MagicMock()
        tshark.add_pcap = MagicMock()
        tshark.add_luascript = MagicMock()
        tshark.add_filter = MagicMock()
        tshark.run = MagicMock()
        m_tshark_helper.return_value = tshark
        m_create_gen.return_value = MagicMock()

        readers.PcapReader(
            pcap_file_path='mocked', tshark_filter=None,
            lua='mocked', output_log_file='/path/to/file'
        )
        m_tshark_helper.assert_called_once()
        tshark.add_filter.assert_not_called()
        tshark.add_pcap.assert_called_once_with('mocked')
        tshark.add_luascript.assert_called_once_with(lua_path='mocked')
        tshark.run.assert_called_once_with('/path/to/file')
        readers.PcapReader(
            pcap_file_path='mocked', tshark_filter='asd',
            lua=None, output_log_file='/path/to/file'
        )
        tshark.add_luascript = MagicMock()  # reset 'counter'
        tshark.add_luascript.assert_not_called()
        tshark.add_filter.assert_called_once()

        readers.PcapReader(
            pcap_file_path='mocked', tshark_filter='asd',
            lua=None, output_log_file=None, tshark_options=[('-x', 'xyz'), ('-y', 'yyy')]
        )
        tshark.add.assert_has_calls([call('-x', 'xyz'), call('-y', 'yyy')], any_order=True)


class TestIterableReader(unittest.TestCase):

    def setUp(self):
        self.i = [
            ('UserSetupReq', {'slot': '0x05(5)'}),
            ('SlotTypeReq', {'slot': '0x03(3)'}),
        ]
        self.reader = readers.IterableReader(iterable=self.i)

    def test_class(self):
        assert list(self.reader.generator()) == self.i
