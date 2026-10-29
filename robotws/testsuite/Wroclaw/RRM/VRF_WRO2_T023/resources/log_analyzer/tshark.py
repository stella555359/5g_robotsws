from os import path
from abc import ABCMeta, abstractmethod
from subprocess import call, CalledProcessError

from testsuite.Wroclaw.RRM.VRF_WRO2_T023.resources.log_analyzer.common.log import blog


class CommandHelper(object):

    __metaclass__ = ABCMeta

    @abstractmethod
    def add(self, parameter, value):
        raise NotImplementedError

    @abstractmethod
    def run(self, file_path):
        raise NotImplementedError


class TSharkHelper(CommandHelper):
    """Assemble and execute tshark command"""
    opt_lua = '/opt/luashark/luashark.lua'

    def __init__(self, tshark_path='tshark', lua_path=opt_lua, packet_details=True):
        self.lua_path = lua_path
        self.tshark_path = tshark_path
        self.parameters = []

        self.add(tshark_path)
        if packet_details:
            self.add('-V')  # -V adds output of packet tree (Packet Details)

    def _print_params(self):
        blog('only for visualization purposes because it is not exactly known what subprocess.call will run',
             console=False)
        blog(' '.join(i for i in self.parameters), console=False)

    def add(self, parameter, value=None):
        p = [parameter]
        if value:
            p.append(value)
        self.parameters.extend(p)
        return self

    def add_pcap(self, pcap_path):
        self.add('-r', pcap_path)
        return self

    def add_luascript(self, lua_path=None):
        """Add lua_path to parameters. If lua_path is None, use self.lua_path. Raise exception if lua not found."""
        if not lua_path:
            lua_path = self.lua_path
        assert path.isfile(lua_path), '{} not found'.format(lua_path)
        self.add('-X', 'lua_script:{}'.format(lua_path))
        return self

    def add_filter(self, tshark_filter):
        self.add('-Y', tshark_filter)
        return self

    def run(self, file_path):
        self._print_params()
        with open(file_path, 'w+') as f:
            try:
                call(self.parameters, stdout=f)
            except CalledProcessError as e:
                blog(self.__class__, level='ERROR')
                blog(e)
