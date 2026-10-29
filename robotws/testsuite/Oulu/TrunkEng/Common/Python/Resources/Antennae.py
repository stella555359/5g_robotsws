"""
:author:  Essi Passoja
:contact: I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com
"""

import re
from robot.libraries.BuiltIn import BuiltIn
from testsuite.Oulu.TrunkEng.Common.Python.Interfaces.Logger import info, warning, error
from testsuite.Oulu.TrunkEng.Common.Python.Resources.exceptions import SSHConnectionFailure, UnexpectedBTSStatus


class Antennae:
    """
    GetRCIs is used for finding radio configurations.
    Script creates radio objects and connection lists.

    GetRCIs is called in common_resources.robot.
    If the class is already initiated once, import robot
    BuiltIn
        >> from robot.libraries.BuiltIn import BuiltIn
    and call with
        >> BuiltIn().get_library_instance("RMODS")
    """
    def __init__(self):
        self.admin = BuiltIn().get_library_instance("ADMIN")
        self.bts = None
        self.logger = BuiltIn().get_library_instance("LOG")
        self.ssh = BuiltIn().get_library_instance("SSH")

        self.unit_info = []

    def get_txrx_powers(self, rmod, antenna, direction="TX"):
        """
        Get TX or RX power of an antenna in the given radio.

        :param obj rmod: Radio object.
        :param obj/list antenna: Antenna object(s) to be checked.
        :param str direction: 'TX' or 'RX'. Default is 'TX'.
        :return list: List of radio powers.
        """
        if direction == 'TX':
            regex_pattern = re.compile(r".*Power.*TX=(?P<power>\d+\.\d+|-\d+\.\d+),.*")
        else:
            regex_pattern = re.compile(r".*Power.*RX=(?P<power>\d+\.\d+|-\d+\.\d+),.*")

        if isinstance(antenna, Antenna):
            power = ""
            pipe = int(antenna.dist_name[-1]) - 1
            command = f"dapd -pwr {pipe}"
            output = self.ssh.send_command_to_radio_by_ssh(rmod, command, return_output=True, print_to_eventlog=False)

            if output:
                for o in output.split("\n"):
                    match = regex_pattern.match(o)
                    if match:
                        power = float(match.group("power"))
                        self.logger.debug(f"Power in pipe {pipe}: {power} dBm")
                    elif "Received with parameter" in o and 'Fail' in o:
                        power = "0"
                        self.logger.debug(f"No power in pipe {pipe} ({power} dBm)")
                if not power:
                    error(f"Could not get power from command {command} to unit {rmod.name}. Received output: {output}")
                    raise SSHConnectionFailure(f"Could not get power from command {command} to unit {rmod.name}")
            else:
                error(f"No output from command {command} to unit {rmod.name}")
                raise SSHConnectionFailure(f"No output from command {command} to unit {rmod.name}")
            return power
        if isinstance(antenna, list):
            commands = []
            powers = []
            for ant in antenna:
                pipe = int(ant.dist_name[-1]) - 1
                command = f"dapd -pwr {pipe}"
                commands.append(command)
            output = self.ssh.send_command_to_radio_by_ssh(rmod, commands, return_output=True, print_to_eventlog=False)
            if output:
                for o in output.split("\n"):
                    match = regex_pattern.match(o)
                    if match:
                        powers.append(float(match.group("power")))
                    elif "Received with parameter" in o and 'Fail' in o:
                        powers.append(float(0))
                if not powers:
                    error(
                        f"Could not get power from commands {commands} to unit {rmod.name}. Received output: {output}")
                    raise SSHConnectionFailure(f"Could not get power from commands {commands} to unit {rmod.name}")
            else:
                error(f"No output from commands {commands} to unit {rmod.name}")
                raise SSHConnectionFailure(f"No output from commands {commands} to unit {rmod.name}")
            return powers

    def check_that_all_antennas_have_tx_power_except(self, rmod, given_antenna, telnet=False):
        """
        Check that antenna has no TX power.

        :param obj rmod: Radio object.
        :param obj given_antenna: Antenna object.
        :param telnet: True if checking powers for radio with telnet
        """
        success = True
        antennas = self.get_all_antennas_in_radio(rmod)
        given_antenna_number = int(given_antenna.dist_name[-1]) - 1  # decrease by 1 to match index of powers
        if not telnet:
            powers = self.get_txrx_powers(rmod, antennas, "TX")
        else:
            powers = []
            command = "rfctrl txPower"
            output = self.ssh.send_command_to_radio_by_telnet(rmod, command, return_output=True,
                                                              print_to_eventlog=False)
            lines = output.split("\n")
            for line in lines:
                if ": ANT" in line:
                    match = re.search(r": ANT\d+ \[dBm\] :  (\d+\.\d+)", line)
                    if match:
                        powers.append(float(match.group(1)))
                    else:
                        powers.append(float(0))
        for i in range(len(powers)):
            if i == given_antenna_number:
                if powers[i] != 0.0:
                    error(f"TX power in antenna {i + 1} is {powers[i]} dBm, when it should be 0 dBm. NOK.")
                    success = False
                else:
                    info(f"TX power in antenna {i + 1} is {powers[i]} dBm. OK.")
            else:
                if powers[i] == 0.0:
                    error(f"No TX power in antenna {i + 1}. NOK.")
                    success = False
                else:
                    info(f"TX power in antenna {i + 1} is {powers[i]} dBm. OK.")
        if not success:
            raise UnexpectedBTSStatus("Antennas with unexpected TX powers.")

    def check_that_all_antennas_have_tx_power(self, rmod):
        """
        Check that all antennas have TX power.

        :param obj rmod: Radio object.
        """
        success = True
        antennas = self.get_all_antennas_in_radio(rmod)
        powers = self.get_txrx_powers(rmod, antennas, "TX")
        for i in range(len(powers)):
            if powers[i] == float(0):
                error(f"No TX power in antenna {i + 1}. NOK.")
                success = False
            else:
                info(f"TX power in antenna {i + 1} is {powers[i]} dBm. OK.")
        if not success:
            raise UnexpectedBTSStatus("Antennas with missing TX power.")

    def get_all_antennas_in_radio(self, rmod):
        """
        Get all antennas in the given radio.

        :param obj rmod: Radio object.
        """
        antennas = []
        for antenna in self.bts.antennae:
            if rmod.scf_dist_name in antenna.connected_radios and "ANTL" in antenna.dist_name:
                antennas.append(antenna)
        return antennas

    def get_antenna_connections(self):
        self.bts = BuiltIn().get_library_instance("BTS")
        antenna_list = []
        rmods = self.bts.bts_info["requestMessage"]["radioModules"]["rmod"]
        for rmod in rmods:
            antenna_list = self._get_all_rmod_antennas(antenna_list, rmod)
            antenna_list = self._find_connected_cells(antenna_list)
        return antenna_list

    def _get_all_rmod_antennas(self, antenna_list, rmod):
        ports = rmod["ports"]
        for port in ports:
            try:
                antenna_list = self._add_missing_antenna_to_antenna_list(
                    port["id"]["configuration"], port["id"]["internal"], port["label"], rmod["id"]["configuration"],
                    antenna_list)
            except KeyError:
                continue
        antenna_list = self._get_antenna_directions_from_rmod_info(antenna_list, rmod)
        return antenna_list

    def _add_missing_antenna_to_antenna_list(self, dist_name, runtime_dist_name, label, connected_radio, antenna_list):
        for antenna in antenna_list:
            if antenna.dist_name == dist_name:
                antenna.connected_radios.append(connected_radio)
                return antenna
        new_antenna = Antenna(dist_name, runtime_dist_name, label)
        new_antenna.connected_radios.append(connected_radio)
        new_antenna.unit_path = f"[{self.bts.bts_name}] {dist_name}"
        antenna_list.append(new_antenna)
        return antenna_list

    @staticmethod
    def _get_antenna_directions_from_rmod_info(antenna_list, rmod):
        for antenna in antenna_list:
            for antenna_usage_info in rmod["antenaUsageInfo"]:
                if antenna.dist_name == antenna_usage_info["id"]["configuration"]:
                    antenna.direction = antenna_usage_info["direction"]
                    break
        return antenna_list

    def _find_connected_cells(self, antenna_list):
        for cell in self.bts.cells:
            for antenna in antenna_list:
                if not antenna.direction:
                    antenna.direction = self._get_antenna_directions_from_cell_info(antenna, cell)
                for carrier in self.bts.cells[cell]["carrierList"]:
                    if (carrier["antennaLineId"]["configuration"] == antenna.dist_name and
                            cell not in antenna.connected_cells):
                        antenna.connected_cells.append(cell)
                if not antenna.direction and antenna.connected_cells:
                    warning("Could not get antenna directions for antenna {} from RMOD info nor from cell info. "
                            "Take contact to a script developer.".format(antenna.label))
        return antenna_list

    def _get_antenna_directions_from_cell_info(self, antenna, cell):
        direction = ""
        for carrier in self.bts.cells[cell]["carrierList"]:
            if carrier["antennaLineId"]["configuration"] == antenna.dist_name:
                direction += carrier["direction"]
        if "TX" in direction and "RX" in direction:
            direction = "TX/RX"
        return direction


class Antenna(object):
    """
    Initializes an antenna object.
    """
    def __init__(self, dist_name, runtime_dist_name, label):
        self.connected_cells = []
        self.connected_radios = []
        self.direction = None
        self.dist_name = dist_name
        self.runtime_dist_name = runtime_dist_name
        self.label = label
        self.unit_path = ""
