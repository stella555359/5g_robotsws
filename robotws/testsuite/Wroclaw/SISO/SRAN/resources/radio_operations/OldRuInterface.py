"""
:modified:23.05.2024

:author: Mateusz Kawka
:maintainer: Mateusz Kawka
:contact: mateusz.kawka@nokia.com
"""
import re
from robot.api import logger
from tabulate import tabulate
from collections import OrderedDict
from RadioBaseConnection import RadioBaseConnection
from exceptions import CannotGetPowerFromRU


class OldRuInterface(RadioBaseConnection):
    def __init__(self):
        super(OldRuInterface, self).__init__()
        self._trx_list = list()
        self._channel_status = list()
        self._frequency = list()
        self._channel_type = list()
        self._bandwidth = list()
        self._resource = list()
        self._trx_per_antenna = dict()

    @staticmethod
    def _parse_raw_tx_power_wmp(output):
        tx_power, pattern_re = dict(), r"^TX(\d{1,2})\s*(-?\d{1,}.\d{1,}|Power)"
        tx_iterator = re.finditer(pattern_re, output, re.M)
        [
            tx_power.setdefault(power.group(1), "OFF")
            if power.group(2) == "Power"
            else tx_power.setdefault(power.group(1), power.group(2))
            for power in tx_iterator
        ]
        return tx_power

    @staticmethod
    def _parse_raw_rx_power_wmp(output):
        rx_power, pattern_re = dict(), r"RX(\d{1,2})\s*(-?\d{1,}.\d{1,}|N/A)"
        rx_iterator = re.finditer(pattern_re, output, re.M)
        [
            rx_power.setdefault(power.group(1), "OFF")
            if power.group(2) == "N/A"
            else rx_power.setdefault(power.group(1), power.group(2))
            for power in rx_iterator
        ]
        return rx_power

    def _get_carriers_data_wmp(self, direction):
        return self._get_raw_carriers_data_wmp(direction)

    def _get_raw_carriers_data_wmp(self, direction):
        self._send_command(f'{direction} -stat')
        raw_data = self._read_output()
        self.disconnect()
        self._prepare_carriers_data_wmp(raw_data)
        return self._parse_carrier_by_antenna('wmp')

    def _get_carriers_power_wmp(self, direction, print_table):
        power_dict = self._get_raw_power_wmp(direction)
        if print_table:
            self.print_table_with_power(power_dict, direction, type_of_radio='wmp')

        self.disconnect()
        return power_dict

    def _get_raw_power_wmp(self, direction):
        self._send_command(f'{direction} -power')
        raw_power = self._read_output()
        if raw_power is not None:
            if direction == 'tx':
                return self._parse_raw_tx_power_wmp(raw_power)
            else:
                return self._parse_raw_rx_power_wmp(raw_power)
        else:
            raise CannotGetPowerFromRU

    def _prepare_carriers_data_wmp(self, output):
        self.__init__()
        for line in output.splitlines():
            antenna = re.match(
                r"\s*[TR]X(?P<number_a>[0-9]{1,2}) Virtual Device status:", line
            )
            if antenna:
                antenna_id = f'ANT{antenna.group("number_a")}'
            elif re.match(r".*[TR]X[0-9]{1,2}", line) and not antenna:
                self._trx_per_antenna.setdefault(antenna_id, line.split())
                self._trx_list.extend(line.split())
            elif re.match(r"\s*Channel Status:", line):
                self._channel_status.extend(line[line.index(":") + 1:].split())
            elif re.match(r"\s*Frequency:", line):
                self._frequency.extend(line[line.index(":") + 1:].split())
            elif re.match(r"\s*Channel type:", line):
                self._channel_type.extend(line[line.index(":") + 1:].split())
            elif re.match(r"\s*Band\s?[Ww]idth:", line):
                self._bandwidth.extend(line[line.index(":") + 1:].split())

    def _parse_carrier_by_trx_wmp(self):
        carrier_data = {
            value: {
                "state": self._channel_status[index],
                "frequency": self._frequency[index],
                "type": self._channel_type[index],
                "bandwidth": self._bandwidth[index],
            }
            for index, value in enumerate(self._trx_list)
        }
        return carrier_data

    @staticmethod
    def _parse_raw_tx_power_gaia(output):
        tx_power_dict = dict()
        output = output.splitlines()
        for line in output:
            resource = re.match(r":\s{2}resource\s{2}:\s*(\d{1,2}/\d{1,2}.*)", line)
            antenna = re.match(
                r":\sANT(?P<antenna_no>\d{1,2})\s\[dBm]\s:\s*(?P<antenna_power>.*)",
                line,
            )
            if resource:
                tx_power_dict.setdefault("resource", list()).extend(
                    resource.group(1).split()
                )
            if antenna:
                tx_power_dict.setdefault(
                    f'{antenna.group("antenna_no")}', list()
                ).extend(antenna.group("antenna_power").split())

        return tx_power_dict

    @staticmethod
    def _parse_raw_rx_power_gaia(output):
        rx_power_dict = dict()
        output = output.splitlines()
        for line in output:
            resource = re.match(r":\s*<NCO>\s*:\s*(\d{1,2}/\d{1,2}.*)", line)
            antenna = re.match(
                r":\sANT(?P<antenna_no>\d{1,2})\s\[dBm]\[resource]\s:\s*(?P<antenna_power>.*)",
                line,
            )
            if resource:
                rx_power_dict.setdefault("resource", list()).extend(
                    resource.group(1).split()
                )
            if antenna:
                rx_power_dict.setdefault(
                    f'{antenna.group("antenna_no")}', list()
                ).extend(antenna.group("antenna_power").split())

        return rx_power_dict

    def _prepare_carriers_data_gaia(self, output):
        self.__init__()
        output = output.splitlines()
        for line in output:
            antenna = re.match(r"\s*ANT:\s(?P<number_a>\d{1,2})", line)
            if antenna:
                antenna_id = f'ANT{antenna.group("number_a")}'
            trx_re = re.match(r".*Uoam ID\s*:", line)
            if trx_re:
                self._trx_per_antenna.setdefault(
                    antenna_id, line[trx_re.end():].split()[:-1]
                )
                self._trx_list.extend(line[trx_re.end():].split()[:-1])
            elif re.match(r"\s*state\s*:", line):
                self._channel_status.extend(line[line.index(":") + 1:].split()[:-1])
            elif re.match(r"\s*frequency\[MHz].*:", line):
                self._frequency.extend(line[line.index(":") + 1:].split()[:-1])
            elif re.match(r"\s*type.*:", line):
                self._channel_type.extend(line[line.index(":") + 1:].split()[:-1])
            elif re.match(r"\s*bandwidth.*:", line):
                self._bandwidth.extend(line[line.index(":") + 1:].split()[:-1])
            elif re.match(r"\s*resource.*", line):
                self._resource.extend(line[line.index(":") + 1:].split()[:-1])

    def _get_carriers_data_gaia(self, direction):
        return self._get_raw_carriers_data_gaia(direction)

    def _get_raw_carriers_data_gaia(self, direction):
        check_data_pattern = re.compile(
            r"IMPORTANT NOTICE: resource and NCO index has been changed to 0 based"
        )
        self._send_command(f'rfctrl {direction}Stat')
        raw_data = self._read_until_regexp('rtose@gaia>')
        self.disconnect()
        if check_data_pattern.search(raw_data):
            self._prepare_carriers_data_gaia(raw_data)
            return self._parse_carrier_by_antenna('gaia')
        else:
            raise CannotGetPowerFromRU

    def _get_carriers_power_gaia(self, direction, print_table):

        power_dict = dict()
        raw_power_dict = self._get_raw_power_gaia(direction)
        data_dict = self._get_raw_carriers_data_gaia(direction)

        for antenna, uoam_ids in data_dict.items():
            ant_number = re.findall(r'\d+', antenna)[0]
            antenna_power_list = raw_power_dict.get(ant_number)
            if direction == 'tx':
                for uoam_id, values in uoam_ids.items():
                    resource_nr = int(values.get('resource'))
                    if resource_nr >= 16:
                        resource_nr = resource_nr - 16
                    power = antenna_power_list[resource_nr]
                    if power == 'n.a':
                        power = 'OFF'
                    power_dict.setdefault(f'{ant_number}/{resource_nr}', power)
            else:
                for power in antenna_power_list:
                    power_check = re.compile(r'\d+.\d+')
                    if power_check.search(power):
                        resource_nr = re.search(r'\[(\d+)]', power).group(1)
                        power_value = re.search(r'([-+]?\d*\.\d+)', power).group(1)
                        power_dict.setdefault(f'{ant_number}/{int(resource_nr)}', float(power_value))
                    else:
                        continue

        if print_table:
            self.print_table_with_power(power_dict, direction, type_of_radio='gaia')

        logger.info(power_dict)
        self.disconnect()
        return power_dict

    def _get_raw_power_gaia(self, direction):
        check_power_pattern = re.compile(
            r"IMPORTANT NOTICE: resource and NCO index has been changed to 0 based"
        )
        self._send_command(f'rfctrl {direction}Power')
        raw_power = self._read_until_regexp('rtose@gaia>')
        if check_power_pattern.search(raw_power):
            if direction == 'tx':
                return self._parse_raw_tx_power_gaia(raw_power)
            else:
                return self._parse_raw_rx_power_gaia(raw_power)
        else:
            raise CannotGetPowerFromRU

    def _parse_carrier_by_trx_gaia(self):
        carrier_data = {
            value: {
                "state": self._channel_status[index],
                "frequency": self._frequency[index],
                "type": self._channel_type[index],
                "bandwidth": self._bandwidth[index],
                "resource": self._resource[index],
            }
            for index, value in enumerate(self._trx_list)
        }
        return carrier_data

    def _parse_carrier_by_antenna(self, radio_type):

        if radio_type == 'gaia':
            carrier_data_by_trx = self._parse_carrier_by_trx_gaia()
        else:
            carrier_data_by_trx = self._parse_carrier_by_trx_wmp()

        carrier_data = dict()
        for antena, trx_list in self._trx_per_antenna.items():
            trx_on_antena = dict()
            for trx in trx_list:
                trx_on_antena.setdefault(trx, carrier_data_by_trx[trx])
            carrier_data.setdefault(antena, trx_on_antena)

        logger.info(carrier_data)
        return carrier_data

    @staticmethod
    def print_table_with_power(power_dict, direction, type_of_radio):

        power_dict = {k: v for k, v in power_dict.items() if v != 'OFF'}
        if type_of_radio == 'wmp':
            power_dict = {int(k): v for k, v in power_dict.items()}

        power_dict = OrderedDict(sorted(power_dict.items()))

        values_count = len([x for x in power_dict.values() if x != 'OFF'])
        if values_count != 0:
            new_tb = tabulate(power_dict.items(),
                              headers=[direction.upper(), "Power"], tablefmt="fancy_grid", floatfmt=".2f")
            logger.info(new_tb, also_console=True)
        else:
            logger.info("No power on any {0} carrier".
                        format(direction.upper()), also_console=True)
