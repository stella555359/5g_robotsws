
from os import path
from abc import ABCMeta, abstractproperty
from subprocess import call, CalledProcessError

from testsuite.Krakow.RRM.RAN_PZ.regression.KRK3.resources.log.log import blog

import unittest
from mock import MagicMock, patch


class CommandHelper(object):

    __metaclass__ = ABCMeta

    @abstractproperty
    def add(self):
        pass

    @abstractproperty
    def run(self):
        pass


class TSharkHelper(CommandHelper):
    """
    assemble and execute tshark command
    """

    def __init__(
        self,
        tshark_path="tshark",
        ute_lua_path='/opt/luashark/luashark.lua'
    ):
        self.ute_lua_path = ute_lua_path
        self.tshark_path = tshark_path
        self.parameters = []
        self.add_tshark(tshark_path)

    def _print_params(self):
        blog(' '.join(i for i in self.parameters))

    def add(self, parameter, value):
        self.parameters.extend([parameter, value])
        return self

    def add_tshark(self, tshark_path=None):
        self.add(tshark_path, '-V')  # -V adds output of packet tree (Packet Details)
        return self

    def add_pcap(self, pcap_path):
        self.add('-r', pcap_path)
        return self

    def add_luascript(self, lua_path=None):
        """
        add lua_path to parameters if lua_path is None use self.ute_lua_path
        asserts file in lua_path or ute_lua_path exists
        """
        if not lua_path:
            lua_path = self.ute_lua_path
        assert path.isfile(lua_path), '{} not found'.format(lua_path)
        self.add('-X', 'lua_script:{}'.format(lua_path))
        return self

    def add_filter(self, shark_filter):
        self.add('-Y', shark_filter)
        return self

    def run(self, file_path):
        self._print_params()
        with open(file_path, 'w+') as f:
            try:
                call(self.parameters, stdout=f)
            except CalledProcessError as e:
                blog(self.__class__, level='ERROR')
                blog(e)

    bite = run   # ;-) kekeke


class TestTSharkHelper(unittest.TestCase):

    def setUp(self):
        self.assembler = TSharkHelper()

    def test_init(self):
        assert self.assembler.tshark_path == "tshark"         # add_tshark check
        assert self.assembler.ute_lua_path == '/opt/luashark/luashark.lua'
        assert self.assembler.parameters == ["tshark", "-V"]
        # add_tshark check and
        # underneath add method check

    @patch('os.path.isfile')
    def test_full_command(self, m_isfile):
        m_isfile = MagicMock()
        m_isfile.return_value = True  # for lua path check
        expected = [
            'tshark', '-V',
            '-r', 'log.pcap',
            '-X', 'lua_script:luashark.lua',
            '-Y', 'dldata_slottypereq',
            '>', 'target_file'
        ]
        self.assembler.add_pcap('log.pcap')               # add_pcap check
        self.assembler.add_luascript('luashark.lua')      # add_luascript check
        self.assembler.add_filter('dldata_slottypereq')   # add_filter check
        self.assembler.add_output_to_file_redirection('target_file')
        assert expected == self.assembler.parameters

    #
    # NOT REALLY SURE HOW TO TEST THIS SINCE IN THIS EXAMPLE
    # LOOKS LIKE check_output ALWAYS RAISES ERROR CONTAINING
    # CORRECT OUTPUT FROM TSHARK COMMAND SO IM A BIT LOST HERE
    #
    # @patch('subprocess.CalledProcessError')
    # @patch('subprocess.check_output')
    # def test_run(self, m_check_output, m_called_process_error):
    #     pass
    #

    #
    # run_and_write_output_to_file only calls run and add_output_to_file_redirection
    # don't really feel need to test this
    #
