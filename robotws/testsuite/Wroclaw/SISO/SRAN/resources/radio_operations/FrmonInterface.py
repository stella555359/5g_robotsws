"""
:modified:06.12.2024

:author: Mateusz Kawka
:maintainer: Mateusz Kawka
:contact: mateusz.kawka@nokia.com
"""
import time

from robot.api import logger
import radio_variables as variables
from tabulate import tabulate
from collections import OrderedDict
import re
import RadioInterface as radio_interface
from RadioBaseConnection import RadioBaseConnection
from exceptions import NotSupportedAntennaLineDirection, NotSupportedTypeOfFrmonData, TempSensorNotFound


class FrmonInterface(RadioBaseConnection):
    def __init__(self, RadioInterface=None):
        super(FrmonInterface, self).__init__()
        if RadioInterface is None:
            RadioInterface = radio_interface.RadioInterface(FrmonInterface=self)
        self.radio = RadioInterface

    @staticmethod
    def _frmon_get_carriers_data_dictionary(raw_output, data_dict):

        cmd_output = raw_output.splitlines()
        cmd_output = [i for i in cmd_output if i.startswith('ret')]
        for line in cmd_output:
            antenna = re.findall(r'ant\d+', line)[0]
            carrier = re.findall(r'(?<=")\S*(?=")', line)[0]
            data_dict[antenna][carrier] = {}
            try:
                cell_type = re.findall(r'(?<=read_config )".*"', line)[0][1]
                if cell_type == 'N':
                    cell_type = 'NR'
                elif cell_type == 'L':
                    cell_type = 'LTE'
                elif cell_type == 'W':
                    cell_type = 'WCDMA'
                else:
                    cell_type = 'GSM'
            except Exception:
                cell_type = 'N/A'
            try:
                frequency = re.findall(r'(?<=FREQUENCY )\d+', line)[0]
                frequency = float(frequency) / 1000
            except Exception:
                frequency = 'N/A'
            try:
                bandwidth = re.findall(r'(?<=BANDWIDTH )\d+', line)[0]
            except Exception:
                bandwidth = 'N/A'
            try:
                state = re.findall(r'(?<=STATE )\w+', line)[0]
            except Exception:
                state = 'N/A'

            data_dict[antenna][carrier]['bandwidth'] = bandwidth
            data_dict[antenna][carrier]['frequency'] = frequency
            data_dict[antenna][carrier]['type'] = cell_type
            data_dict[antenna][carrier]['state'] = state

        return data_dict

    @staticmethod
    def _frmon_get_carriers_power_dictionary(raw_output, dict_of_power):
        cmd_output = raw_output.splitlines()
        cmd_output = [i for i in cmd_output if i.startswith('ret')]
        for line in cmd_output:
            antenna = re.findall(r'ant\d+', line)[0]
            carrier = re.findall(r'(?<=")\S*(?=")', line)[0]
            try:
                power = float(re.findall(r'[-]?\d+[.]\d+', line)[0])
            except Exception:
                power = 'OFF'

            dict_of_power[antenna][carrier] = power

        return dict_of_power

    @staticmethod
    def frmon_get_carriers_list(raw_output):
        carriers_list = re.findall(r'(?<=")\S*(?=")', raw_output)
        carriers_list = [carrier for carrier in carriers_list if carrier.startswith(("N", "L", "W", "G"))]

        return carriers_list

    @staticmethod
    def _frmon_set_carriers_map_command(list_of_ants, direction):

        first_ant_num = list_of_ants[0]
        last_ant_num = list_of_ants[-1]

        cmd_a = [
            f"/ action create AntennaPath /ant{num}_radio_operation /rf/ant{num}"
            for num in range(first_ant_num, last_ant_num + 1)
        ]
        cmd_b = [
            f"/ant{num}_radio_operation get {direction}_carrier_ids"
            for num in range(first_ant_num, last_ant_num + 1)
        ]

        return "\n".join(cmd_a + cmd_b)

    def _frmon_set_carriers_power_command(self, raw_output):
        otp = raw_output.splitlines()

        carrier_with_power = list(filter(lambda x: '.TX' in x or '.RX' in x, otp))

        cmds_list = []
        for i in carrier_with_power:
            ant = re.findall(r'ant\d+', i)[0]
            carriers = self.frmon_get_carriers_list(i)
            for carrier in carriers:
                cmd = f'/{ant}_radio_operation action measure_power "{carrier}"'
                cmds_list.append(cmd)

        return "\n".join(cmds_list)

    def _frmon_set_carriers_data_command(self, raw_output):

        otp = raw_output.splitlines()

        carrier_with_power = list(filter(lambda x: '.TX' in x or '.RX' in x, otp))

        cmds_list = []
        for i in carrier_with_power:
            ant = re.findall(r'ant\d+', i)[0]
            carriers = self.frmon_get_carriers_list(i)
            for carrier in carriers:
                cmd = f'/{ant}_radio_operation action read_config "{carrier}"'
                cmds_list.append(cmd)

        return "\n".join(cmds_list)

    def _frmon_convert_to_physical_antennas(self, power_dictionary, ru_name, direction):

        direction = direction.upper()
        band_number = int(self.radio.get_bands_number(ru_name))
        mapping = None

        if ru_name in variables.CUSTOM_MAPPING:
            logger.debug('Converting dictionary to physical antennas for custom mapping!')
            return self._frmon_custom_convert_to_physical_antennas(power_dictionary, ru_name, direction)

        for ru_class, ru_list in variables.RADIO_MODULES.items():
            if ru_name in ru_list:
                ru_group = ru_class
                txrx_mapping = variables.ANTENNA_MAPPING[ru_group]
                if direction == 'TX':
                    mapping = txrx_mapping['TX']
                elif direction == 'RX':
                    mapping = txrx_mapping['RX']
                else:
                    raise NotSupportedAntennaLineDirection(direction)

        if isinstance(mapping, tuple):
            mapping = [item for sublist in mapping for item in sublist]

        temp_dict = dict.fromkeys(mapping)
        final_dict = {}
        band_delta = int(band_number) - 1

        for k in temp_dict.keys():
            first_tx_for_ant = (k * int(band_number)) - band_delta
            last_tx_for_ant = k * int(band_number)
            temp_list = []
            for i in range(first_tx_for_ant, last_tx_for_ant + 1):
                temp_list.append(power_dictionary['ant' + str(i)])
                flat_dict = {k: v for d in temp_list for k, v in d.items()}
                final_dict['ant' + str(k)] = flat_dict

        return final_dict

    @staticmethod
    def frmon_get_virtual_antenna_lines_for_radio(ru_group, ant_mapping):
        ru_group_split = ru_group.split('_')
        band = re.findall(r'\d+', ru_group_split[-1])[0]
        logger.debug(f"Antenna mapping from variables.ANTENNA_MAPPING dictionary: {ant_mapping}")
        band_delta = int(band) - 1

        virtual_numeric_ant_mapping = []
        for ant in ant_mapping:
            first_tx_for_ant = (ant * int(band)) - band_delta
            last_tx_for_ant = ant * int(band)
            for i in range(first_tx_for_ant, last_tx_for_ant + 1):
                virtual_numeric_ant_mapping.append(i)

        logger.debug(f"Antenna mapping for FRMON:{virtual_numeric_ant_mapping}")
        return virtual_numeric_ant_mapping

    @staticmethod
    def _frmon_custom_convert_to_physical_antennas(power_dictionary, ru_name, direction):

        converted_dict = {}
        logger.debug(f"Custom {direction} mapping for {ru_name}")
        ru_mapping = variables.CUSTOM_MAPPING.get(ru_name)
        for direct, mapping in ru_mapping.items():
            if direction in direct:
                ru_mapping = mapping.get('FRMON')
                for soc, ant_maps in ru_mapping.items():
                    for ant, virtual_ant in ant_maps.items():
                        converted_dict[ant] = {}
                        for v_ant in virtual_ant:
                            carrier_power = power_dictionary.get('ant' + str(v_ant))
                            try:
                                converted_dict[ant].update(carrier_power)
                            except IndexError:
                                pass

        return converted_dict

    @staticmethod
    def _frmon_print_table_with_power(ru_name, direction, dict_of_power):

        direction = direction.upper()
        flat_carriers_dict = {}
        for k, v in dict_of_power.items():
            for carrier, power in v.items():
                flat_carriers_dict[carrier] = power

        d = OrderedDict(sorted(flat_carriers_dict.items()))

        values_count = len([x for x in d.values() if x != 'OFF'])
        if values_count != 0:
            new_tb = tabulate(d.items(),
                              headers=[direction + " carrier", "Power"], tablefmt="fancy_grid")
            logger.info(new_tb, also_console=True)
        else:
            logger.info("No power on any {0} carrier for {1}".
                        format(direction, ru_name), also_console=True)

    def _get_carriers_information_frmon(self, type_of_info, ru_name, direction, print_table, return_antennas):
        antennas = self.radio.get_antenna_lines_for_radio_module(ru_name, direction, type_of_ant='frmon')
        ru_family = self.radio.get_radio_family(ru_name)
        if ru_family == '6.1':
            logger.info("RU family 6.1 -> Connecting to first SoC via 192.168.101.2")
            self._send_command('ssh 192.168.101.2')
            self._read_until_prompt('$')
            logger.info('Connected to SoC 192.168.101.2')

        antennas = antennas.values()
        flat_antennas_list = [x for xs in antennas for x in xs]
        dict_of_info = ({'ant' + str(i): {} for i in flat_antennas_list})
        counter = 1
        for antenna in antennas:
            if counter == 2:
                second_soc_ip = '192.168.101.2' if ru_family == '6.2' else '192.168.101.3'
                logger.info(f"Connecting to second SoC via {second_soc_ip}...")
                self._send_command(f'ssh {second_soc_ip}')
                output = self._read_until_regexp('fingerprint|Node2|made2|made')
                if 'fingerprint' in output:
                    logger.info("Found fingerprint, adding key to .known_hosts file")
                    self._send_command('y', delay=1)
                    self._read_until_regexp('Node2|made2')
                logger.info(f'Connected to SoC {second_soc_ip}')
            if type_of_info == 'power':
                single_soc_dict = self._get_power_single_soc(direction, antenna, dict_of_info)
            elif type_of_info == 'data':
                single_soc_dict = self._get_carriers_data_single_soc(direction, antenna, dict_of_info)
            else:
                raise NotSupportedTypeOfFrmonData(type_of_info)

            for ant, carriers in single_soc_dict.items():
                dict_of_info[ant] = carriers
            counter += 1

        dict_of_info = self._frmon_convert_to_physical_antennas(dict_of_info, ru_name, direction)

        if print_table:
            self._frmon_print_table_with_power(ru_name, direction, dict_of_info)

        self.disconnect()

        if not return_antennas:
            flat_dict = dict()
            for ant, value in dict_of_info.items():
                for carrier, power in value.items():
                    flat_dict[carrier] = power
            logger.info(flat_dict)
            return flat_dict
        else:
            logger.info(dict_of_info)
            return dict_of_info

    def _get_carriers_data_single_soc(self, direction, antenna, dict_of_data):

        cmd = self._frmon_set_carriers_map_command(antenna, direction)
        self._send_command(f"echo $'{cmd}' | frmonShellClient localhost 2000", delay=1)
        otp = self._read_until_regexp('closed')
        cmd_2 = self._frmon_set_carriers_data_command(otp)
        self._send_command(f"echo $'{cmd_2}' | frmonShellClient localhost 2000", delay=1)
        otp_2 = self._read_until_regexp('closed', timeout=5)
        data_dict = self._frmon_get_carriers_data_dictionary(otp_2, dict_of_data)

        return data_dict

    def _get_power_single_soc(self, direction, antenna, dict_of_power):

        cmd = self._frmon_set_carriers_map_command(antenna, direction)
        self._send_command(f"echo $'{cmd}' | frmonShellClient localhost 2000", delay=1)
        otp = self._read_until_regexp('closed')
        cmd_2 = self._frmon_set_carriers_power_command(otp)
        self._send_command(f"echo $'{cmd_2}' | frmonShellClient localhost 2000", delay=1)
        otp_2 = self._read_until_regexp('closed', timeout=30)
        power_dict = self._frmon_get_carriers_power_dictionary(otp_2, dict_of_power)

        return power_dict

    def _get_radio_unit_temperature_by_sensor(self, sensor_name):
        """
        Retrieves the temperature from a specified sensor on the radio unit.

        Args:
            sensor_name (str): The name of the sensor to retrieve the temperature from.

        Returns:
            float: The temperature value from the specified sensor.

        Raises:
            TempSensorNotFound: If the sensor name is not valid for the radio unit.
        """
        frmon_set_cmd = f'/ action create ThermometerDevice /radio_op/thermometerDevice/{sensor_name} {sensor_name}'
        frmon_get_cmd = f'/radio_op/thermometerDevice/{sensor_name} get temperature'
        self._send_command(f"echo $'{frmon_set_cmd}' | frmonShellClient localhost 2000")
        set_output = self._read_until_regexp('closed')
        if 'not one of' in set_output:
            possible_sensors = re.search(r'\[([^]]+)]', set_output).group(1)
            raise TempSensorNotFound(sensor_name, possible_sensors)
        self._send_command(f"echo $'{frmon_get_cmd}' | frmonShellClient localhost 2000")
        get_output = self._read_until_regexp('closed')
        temperature = float(re.findall(r'-?\d+[.]\d+', get_output)[0])
        return temperature

    def _get_radio_unit_psu_measurements(self):

        frmon_set_cmd = '/ action create PsuMeasurements /radio_op/PsuMeasurements /module'
        frmon_get_cmd = '/radio_op/PsuMeasurements action measure'

        self._send_command(f"echo $'{frmon_set_cmd}' | frmonShellClient localhost 2000")
        self._read_until_regexp('closed')
        self._send_command(f"echo $'{frmon_get_cmd}' | frmonShellClient localhost 2000")
        get_output = self._read_until_regexp('closed')

        pattern = r"VOLTAGE (\d+\.\d+) CURRENT (\d+\.\d+) POWER (\d+\.\d+)"

        match = re.search(pattern, get_output)
        if match:
            result = {
                "voltage": float(match.group(1)),
                "current": float(match.group(2)),
                "power": float(match.group(3)),
            }
            logger.info(f"PSU measurements: {result}")
            return result
        else:
            logger.info("No PSU measurements found.")

    def _get_a_few_radio_unit_psu_measurements(self, number_of_measurements, interval):
        psu_measurements = []
        for i in range(number_of_measurements):
            logger.info(f"Starting measurement {i + 1}/{number_of_measurements}")
            psu_measurements.append(self._get_radio_unit_psu_measurements())
            time.sleep(interval)
            logger.info(f"Measurement {i + 1}/{number_of_measurements} finished.")

        return psu_measurements
