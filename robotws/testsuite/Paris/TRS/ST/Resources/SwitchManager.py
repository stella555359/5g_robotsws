"""
        Keywords Purpose:
            Keywords to drive switches

        AUTHOR (I&V-2):
            Ismael Moliage          ismael.moliage@nokia.com
"""

from Switch import SwitchQuanta
from Switch import Switch7850
from Switch import Switch7750
from Switch import SwitchWbx
from Switch import SwitchTPS
from Switch import Switch7250
from robot.api import logger


class SwitchManager(object):
    _switch = None

    def __init__(self, debug=False, console=False):
        # Because of Robot retarded limitations we have to handle this ourselves.
        if type(debug) is bool:
            self._debug = debug
        else:
            if debug == 'True':
                self._debug = True
            else:
                self._debug = False
        if type(console) is bool:
            self._console = console
        else:
            if console == 'True':
                self._console = True
            else:
                self._console = False

    def switchmanager_debug(self, msg):
        if self._debug:
            logger.info(msg, html=True, also_console=self._console)

    def get_switch(self, switchdict):
        switchtype = switchdict.get('TorSwitch_type')
        self.switchmanager_debug(switchtype)
        if switchtype == 'quanta':
            self._switch = SwitchQuanta(switchdict, self._debug, self._console)
            return self._switch
        if switchtype == '7850':
            self._switch = Switch7850(switchdict, self._debug, self._console)
            return self._switch
        if switchtype == '7750':
            self._switch = Switch7750(switchdict, self._debug, self._console)
            return self._switch
        if switchtype == 'wbx':
            self._switch = SwitchWbx(switchdict, self._debug, self._console)
            return self._switch
        if switchtype == 'TPS':
            self._switch = SwitchTPS(switchdict, self._debug, self._console)
            return self._switch
        if switchtype == '7250':
            self._switch = Switch7250(switchdict, self._debug, self._console)
            return self._switch
        raise SwitchException("invalid switch type")

    def ssh_connect_to_switch(self):
        self._switch.ssh_connect_to_switch()

    def ssh_disconnect_to_switch(self):
        self._switch.ssh_disconnect_to_switch()

    def shutdown(self):
        self._switch.shutdown()

    def noshutdown(self):
        self._switch.noshutdown()

    def ptp_shutdown(self):
        self._switch.ptp_shutdown()

    def ptp_noshutdown(self):
        self._switch.ptp_noshutdown()

    def synce_set_ssm(self, ssm):
        self._switch.synce_set_ssm(ssm)

    def portShutdown(self, portlabel):
        self._switch.portShutdown(portlabel)

    def portNoshutdown(self, portlabel):
        self._switch.portNoshutdown(portlabel)

    def configure_switch_mirroring(self, tl, traffic_type):
        self._switch.configure_switch_mirroring(tl, traffic_type)

    def configure_filter(self, ip_version):
        self._switch.configure_filter(ip_version)

    def activate_filter(self, ip_version, filter_type):
        self._switch.activate_filter(ip_version, filter_type)

    def deactivate_filter(self, filter_type):
        self._switch.deactivate_filter(filter_type)


class SwitchException(Exception):
    pass
