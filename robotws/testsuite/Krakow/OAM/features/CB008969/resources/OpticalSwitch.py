"""
Keywords for Feature CB008969: Setup connection to optical switch and trigger optical link breaks.

:author: Arkadiusz Kowalczyk
:contact: arkadiusz.kowalczyk@nokia.com

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

    def trigger_short_link_break(self, alias, measurement_interval, port_number, breaks_number=1,
                                 link_break_interval=0.1, timeframe=60):
        """
        Trigger short link break with use of optical switch device.
        :param alias: alias of the previously crated device.
        :param measurement_interval: length of measurement interval in minutes. type: int
        :param port_number: port on optical switch to which the affected link is connected. type: int
        :param breaks_number: number of desired short link breaks. type: int
        :param link_break_interval: time in seconds for which optical port is switched off. type: float
        :param timeframe: time in seconds during which certain break number must be performed. type: int
        """
        if breaks_number == 1:
            timeframe = 60
        time.sleep(0.8)
        for minute in range(measurement_interval):
            for execution in range(breaks_number):
                self.set_optical_switch_channels({port_number: 1}, alias)
                opt_switch_status = self.get_optical_switch_channels(alias)
                logging.info(opt_switch_status)
                self.set_optical_switch_channels({port_number: 2}, alias)
                opt_switch_status = self.get_optical_switch_channels(alias)
                logging.info(opt_switch_status)
                time.sleep(link_break_interval)
                self.set_optical_switch_channels({port_number: 1}, alias)
                opt_switch_status = self.get_optical_switch_channels(alias)
                logging.info(opt_switch_status)
                if ((minute != (measurement_interval - 1)) and measurement_interval != 1) or execution != \
                        breaks_number - 1:
                    time.sleep(round(timeframe / breaks_number)-0.06*timeframe)
            time.sleep(0.06*timeframe*breaks_number-0.4 + 60 - timeframe)
