from ute_common_store import Store
from .mcs import MCS_64B16_B1


class mcs(object):

    ROBOT_LIBRARY_SCOPE = 'TEST SUITE'

    def __init__(self):
        self.store = Store()
        self.ssh_client = None

    def Prepare(self, ip,  port=3000, timeout=180, alias='default'):
        mcs = MCS_64B16_B1(ip=ip, port=port, timeout=timeout)
        self.store.add(mcs, alias)

    def SendCommand(self, request, alias='default'):
        return self.store.get(alias).send_command(request)

    def SendCommandWithWait(self, request, response, alias='default'):
        return self.store.get(alias).send_command_with_wait(request, response)

    def GenerateLayersSetting(self, ports, phase, att, alias='default'):
        return self.store.get(alias).generate_layers_setting(ports, phase, att)

    def GetVersion(self, alias='default'):
        return self.store.get(alias).get_version()

    def Destroy(self, alias='default'):
        """Disconnect mcs device, and close socket connect.

        :param string alias:                   alias
        :return:
        """
        try:
            self.store.get(alias).destroy()
        finally:
            self.store.remove(alias)
