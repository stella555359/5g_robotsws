import time
import xml.etree.ElementTree as Xml
from testsuite.Wroclaw.SyVe.RRM.resources.Logger import Logger


class ATStoAttenuator(object):
    """
    ATS to Attenuator converter/sender
    Basically implements ABC Tool functionality, .ats files can be used. It's useful for advanced attenuation routines.

    PREREQUISITES:
       1. 1 - n attenuators can be used (theoretically)
       2. For multiple attenuators setup, attenuators have to be exactly the same (especially ports number)
       3. Block attenuators are not supported
       4. Settings file has to be in .ats format (XML), with the first value starting from time=0
    """

    def __init__(self, ats_file, attenuators):
        self.attenuators = attenuators
        self.ats_file = ats_file
        self.port_count = len(self.attenuators[0].attenuator_ports)

    def set_initial_attenuation_values(self):
        self._set_on_ports_for_all_attenuators(0)

    def start_attenuation_change(self, attenuation_time):
        interval = 1
        elapsed_time = 0
        attenuation_time_counter = 0
        while attenuation_time_counter <= attenuation_time:
            time_and_ports_values = self._get_time_and_ports_values_from_ats()
            if elapsed_time <= max(time_and_ports_values):
                if elapsed_time in time_and_ports_values:
                    self._set_on_ports_for_all_attenuators(elapsed_time)
                elapsed_time += interval
                time.sleep(interval)
            else:
                elapsed_time = 0
            attenuation_time_counter += interval

    def _get_time_and_ports_values_from_ats(self):
        tree = Xml.parse(self.ats_file)
        root = tree.getroot()
        time_and_ports_values = {
            int(child_scriptrowsettings[0].text): [child.text for child in child_scriptrowsettings[2]]
            for child_scriptrowsettings in root[1]
        }
        return time_and_ports_values

    def _set_on_ports_for_all_attenuators(self, ats_time):
        time_and_ports_values = self._get_time_and_ports_values_from_ats()
        for port in range(0, self.port_count):
            for attenuator in self.attenuators:
                initial_value = time_and_ports_values[ats_time][port +
                                                                (self.port_count * self.attenuators.index(attenuator))]
                attenuator.set_port_attenuation(port + 1, initial_value)
                Logger.info(f'Port {port + 1} set to {initial_value} on attenuator {attenuator}')
