import testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log_analyzer.tshark as tshark

import unittest
from mock import MagicMock, patch


class TestTSharkHelper(unittest.TestCase):

    def setUp(self):
        self.assembler = tshark.TSharkHelper()

    def test_init(self):
        assert self.assembler.tshark_path == 'tshark'
        assert self.assembler.lua_path == '/opt/luashark/luashark.lua'
        assert self.assembler.parameters == ['tshark', '-V']

        detail_less = tshark.TSharkHelper(packet_details=False)
        assert detail_less.parameters == ['tshark']

    @patch('os.path.isfile')
    def test_add_params(self, m_isfile):
        expected = [
            'tshark', '-V',
            '-r', 'log.pcap',
            '-X', 'lua_script:luashark.lua',
            '-Y', 'dldata_slottypereq',
            '-foo', '+bar',
        ]
        self.assembler.add_pcap('log.pcap')
        self.assembler.add_luascript('luashark.lua')
        self.assembler.add_filter('dldata_slottypereq')
        self.assembler.add('-foo', '+bar')
        assert expected == self.assembler.parameters

        self.assembler.parameters = []
        self.assembler.add_luascript(None)
        assert self.assembler.parameters == [
            '-X', 'lua_script:{}'.format(tshark.TSharkHelper.opt_lua)
        ]

    @patch(__name__ + '.tshark.TSharkHelper._print_params')
    @patch(__name__ + '.tshark.blog')
    @patch(__name__ + '.tshark.call')
    @patch('__builtin__.open')
    def test_run(self, m_open, m_call, m_blog, m_print_params):
        m_open.__enter__ = MagicMock()
        target_file = 'target_file'
        self.assembler.run(target_file)
        m_print_params.assert_called_once()
        m_open.assert_called_once_with(target_file, 'w+')
        m_call.assert_called_once_with(['tshark', '-V'], stdout=m_open().__enter__())

        m_call.side_effect = tshark.CalledProcessError(None, None, None)
        self.assembler.run(target_file)
        self.assertEqual(m_blog.call_count, 2)
