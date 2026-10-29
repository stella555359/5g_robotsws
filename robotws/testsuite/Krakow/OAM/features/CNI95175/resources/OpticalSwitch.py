"""
Keywords for Feature CNI-95175: Setup connection to optical switch and trigger optical link breaks.

:author: Jaroslaw Lezon
:contact: jaroslaw.lezon@nokia.com

"""
import logging
import time

from taf.hw.optical_switch import optical_switch


class OpticalSwitch(optical_switch):

    def setup_optical_switch_connection(self, alias, optical_switch_device):
        """
        Setup optical switch device for later usage in the script.
        :param alias: alias of the crated device which will be used further in the script.
        :param optical_switch_device: instance of optical switch device defined in test line init file.
        """
        self.setup_optical_switch(optical_switch_device, alias)

    def trigger_short_link_break(self, alias, port_number_tx, port_number_rx,
                                 link_break_interval=10):
        """
        Trigger short link break with use of optical switch device.
        :param alias: alias of the previously crated device.
        :param port_number_tx: port on optical switch to which the affected link TX is connected. type: int
        :param port_number_rx: port on optical switch to which the affected link RX is connected. type: int
        :param link_break_interval: time in seconds for which optical port is switched off. type: float
        """

        self.set_optical_switch_channels({port_number_tx: 1}, alias)
        self.set_optical_switch_channels({port_number_rx: 1}, alias)
        opt_switch_status = self.get_optical_switch_channels(alias)
        logging.info(opt_switch_status)
        self.set_optical_switch_channels({port_number_tx: 2}, alias)
        self.set_optical_switch_channels({port_number_rx: 2}, alias)
        opt_switch_status = self.get_optical_switch_channels(alias)
        logging.info(opt_switch_status)
        time.sleep(link_break_interval)
        self.set_optical_switch_channels({port_number_tx: 1}, alias)
        self.set_optical_switch_channels({port_number_rx: 1}, alias)
        opt_switch_status = self.get_optical_switch_channels(alias)
        time.sleep(20)
