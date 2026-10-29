"""
:author: Terhi Talvitie
:contact: I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com
"""

import re
from robot.libraries.BuiltIn import BuiltIn
from testsuite.Oulu.TrunkEng.Common.Python.Interfaces.Logger import info, error
from testsuite.Oulu.TrunkEng.Common.Python.Resources.exceptions import ScriptIssue, EnvironmentIssue
import testsuite.Oulu.TrunkEng.Common.Python.Resources.RMODLoginInfo as RMODLoginInfo


class FaultingRmod:
    # dictionary with fault id and intra fault id
    fault_dict = {
        "1900": "1122",
        "1901": "1110",
        "1902": "1113",
        "1903": "1114",
        "1904": "1103",
        "1905": "1102",
        "1906": "1104",
        "1907": "1136",
        "1908": "1115",
        "1910": "1128",
        "1911": "1130",
        "1912": "1119",
        "1918": "1126",
        "1920": "1124",
        "1923": "1137",
        "1924": "1107",
        "1926": "1149",
        "1928": "1158",
        "1930": "1160",
        "1838": "1176",
        "1837": "1177",
    }
    # RRH units NOTE FHED has resources also in 1b
    rrhs = ['FHGB', 'FRGA', 'FHFB', 'UHFB', 'FHEH', 'AHEB', 'FRIG', 'FRIJ', 'FRHD', 'FRHE', 'FRHG', 'FRBG', 'FRBE',
            'FRBF', 'UHNA', 'FRNC']

    # # Basic numbering of RX when using sendfault command
    # antenna_rx_numbering = {
    #     "ANT1": 9,
    #     "ANT2": 10,
    #     "ANT3": 11,
    #     "ANT4": 12,
    #     "ANT5": 13,
    #     "ANT6": 14,
    #     "ANT7": 15,
    #     "ANT8": 16,
    # }

    def __init__(self):
        self.logger = BuiltIn().get_library_instance("LOG")
        self.ssh = BuiltIn().get_library_instance("SSH")
        self.bts = None

    def use_telnet_for_faulting(self, radio):
        """
        Check if radio fault is caused by sendFault telnet command or with other methods.

        :param object radio: Radio object.
        :return bool: Return True if telnet senFault is used, otherwise return False.
        """
        rmod_info = RMODLoginInfo.get_rmod(radio.name)
        if "test_rmod_faults" in rmod_info and rmod_info["test_rmod_faults"] == "telnet_sendfault":
            self.logger.debug("Radio Fault is caused by Telnet")
            return True
        else:
            self.logger.debug("Radio Fault is NOT caused by Telnet")
            return False

    def raise_fault_to_rmod(self, fault_id, radio, resource="", deactivate_fault=False, severity='0',
                            application_to_kill=""):
        """
        Cause fault to radio unit.

        :param str fault_id: Fault to cause to radio. For example 1904.
        :param object radio: Radio object.
        :param str resource: Can have values LTX, TX or RX.
        :param bool deactivate_fault: Default is False and then fault is activated, if True fault is cleared.
        :param str severity: Default value is 0 that means that fault given to radio is critical.
        :param str application_to_kill: If fault is caused by killing application, name of application to kill is given
                                        here. For example /opt/UCCS/uCcsSysComControlDaemon
        """
        if not radio:
            error("No radio object given to raise_fault_to_rmod method.")
            raise ScriptIssue
        rmod_info = RMODLoginInfo.get_rmod(radio.name)
        # check if user wants to cause fault by killing application, if yes, then cause fault by killing application
        if application_to_kill:
            self.kill_application_from_radio(radio, application_to_kill)
        elif "test_rmod_faults" in rmod_info and rmod_info["test_rmod_faults"] == "telnet_sendfault":
            self.send_fault_to_rf_module(radio, fault_id, resource, deactivate_fault, severity)
        elif "test_rmod_faults" in rmod_info and rmod_info["test_rmod_faults"] == "made_method":
            self.send_fault_to_made_rf_module(radio, fault_id)
        elif "test_rmod_faults" in rmod_info and rmod_info["test_rmod_faults"] == "mars_thor_rautu_method":
            self.send_fault_to_mars_thor_rautu_rf_module(radio, fault_id)
        else:
            error(f"Radio {radio.name} is not MADE/MARS/THOR/RAUTU radio and it also is not supporting sendFault "
                  f"functionality ({rmod_info}). Currently we do not have known method to cause fault to this radio.")
            raise ScriptIssue

    def get_rx_stat(self, radio_object):
        """
        Get rx stat from the radio. First tries command "rx -stat" and if it is not working  tries "rfctrl rxStat" and
        if it's not working either, inform user that cannot get rx stat.

        :param obj radio_object: Radio object.
        :return str: Returns output for rx stat command
        """
        rx_stat = self.ssh.send_command_to_radio_by_telnet(radio_object, "rx -stat", return_output=True,
                                                           expect_output=True, print_to_eventlog=False,
                                                           name_for_log="_stat")
        if rx_stat and "command not found" in rx_stat:
            info(f"Radio {radio_object.name} doesn't have command 'rx -stat' try command 'rfctrl rxStat' instead.")
            rx_stat = self.ssh.send_command_to_radio_by_telnet(radio_object, "rfctrl rxStat", return_output=True,
                                                               expect_output=True, print_to_eventlog=False,
                                                               name_for_log="_rxstat")
        if rx_stat and "command not found" in rx_stat:
            info(f"Cannot get rx status from radio. We don't have any known working commands for it for this radio type"
                 f" {radio_object.name}.")
        return rx_stat

    def get_tx_stat(self, radio_object):
        """
        Get tx stat from the radio. First tries command "tx -stat" and if it is not working  tries "rfctrl txStat" and
        if it's not working either, inform user that cannot get tx stat.

        :param obj radio_object: Radio object.
        :return str: Returns output for tx stat command
        """
        tx_stat = self.ssh.send_command_to_radio_by_telnet(
            radio_object, "tx -stat", return_output=True, expect_output=True,
            print_to_eventlog=False, name_for_log="_stat")
        if tx_stat and "command not found" in tx_stat:
            info(f"Radio {radio_object.name} doesn't have command 'tx -stat' try command 'rfctrl txStat' instead.")
            tx_stat = self.ssh.send_command_to_radio_by_telnet(
                radio_object, "rfctrl txStat", return_output=True, expect_output=True,
                print_to_eventlog=False, name_for_log="_txstat")
        if tx_stat and "command not found" in tx_stat:
            info(f"Cannot get tx status from radio. We don't have any known working commands for it for this radio type"
                 f" {radio_object.name}.")
        return tx_stat

    def _get_possible_rxs(self, all_rxs, active_pipes):
        possible_rxs = []
        if active_pipes:
            for idx, state in enumerate(active_pipes):
                # if state == "Running":  # this is if hw state used
                if state != "0.00":
                    self.logger.debug(f"RX {all_rxs[idx]} is {state}")
                    possible_rxs.append(all_rxs[idx])
                else:
                    self.logger.debug(f"RX {all_rxs[idx]} is {state}, not a possible selection")
        else:
            info(f"Couldn't parse active pipes from RX stat commands, most likely stat command for this radio type is "
                 f"not known -> Assuming that all pipes that are found from sendFault manual are possible: {all_rxs}")
            possible_rxs = all_rxs
        return possible_rxs

    def _get_sorted_active_rx(self, active_pipes, active_vrx):
        rx_dict = {}
        list_of_sorted = []
        if not active_pipes or not active_vrx:
            self.logger.debug(f"Not all necessary pipe information, returning active_pipes: {active_pipes}.")
            return active_pipes
        sorted_rx = sorted(active_vrx)
        if sorted_rx == active_vrx:
            self.logger.debug(f"No need for extra sorting {active_vrx} is already in right order")
            return active_pipes
        for indx, vrx in enumerate(active_vrx):
            rx_dict[vrx] = active_pipes[indx]
        self.logger.debug(f"_get_sorted_active_rx: {rx_dict}")
        for sort_rx in sorted_rx:
            list_of_sorted.append(rx_dict[sort_rx])
        self.logger.debug(f"Sorted active vrx: {list_of_sorted}")
        return list_of_sorted

    def _check_if_sendfault_includes_manual(self, manual_of_sendfault, radio_object):
        """
        Check that sendFault command prints manual.
        :param str manual_of_sendfault: Output of sendFault command.
        :param object radio_object: Radio object.
        """
        manual_ok = False
        try_time = 1
        while not manual_ok and try_time < 5:
            try_time += 1
            if not manual_of_sendfault or "Usage:" not in manual_of_sendfault:
                self.logger.debug(f"Output was not get, resend the command ({try_time})")
                manual_of_sendfault = self.ssh.send_command_to_radio_by_telnet(radio_object, "sendFault",
                                                                               return_output=True,
                                                                               expect_output=True,
                                                                               print_to_eventlog=False,
                                                                               name_for_log=f"_manual_{try_time}_try")
            else:
                self.logger.debug("SendFault output was OK.")
                manual_ok = True
                break
        return manual_of_sendfault, manual_ok

    def _get_possible_tx_pipes(self, all_txs, active_txs, all_rxs):
        """
        Get possible TX pipes from the radio capability.
        :param list all_txs: List of all TXs from the radio (parsed from the sendFault manual).
        :param list active_txs: List of active TXs from the radio (parsed from the admin interface).
        :param list all_rxs: List of all RXs from the radio (parsed from the sendFault manual).
        """
        possible_pipes = []
        if all_txs and active_txs:
            self.logger.debug(f"active_txs {active_txs}")
            if len(active_txs) == len(all_txs):
                possible_pipes = all_txs
            else:
                if len(all_rxs) == 2 * len(all_txs):
                    self.logger.debug("TX is only in every other pipe.")
                    for active_antenna in active_txs:
                        if active_antenna[-1] == "1":
                            possible_pipes.append(all_txs[0])
                        elif active_antenna[-1] == "3":
                            possible_pipes.append(all_txs[1])
                        elif active_antenna[-1] == "5":
                            possible_pipes.append(all_txs[2])
                if len(all_rxs) == len(all_txs):
                    self.logger.debug("Every pipe has TX and RX.")
                    for active_antenna in active_txs:
                        index = int(active_antenna[-1]) - 1
                        if len(all_txs) >= index:
                            possible_pipes.append(all_txs[index])
                        else:
                            error(f"Problem with getting active cells from radio. All TXs in {all_txs}, all "
                                  f"RX in radio {all_rxs} and active TXs {active_txs}.")
                            raise EnvironmentIssue
        return possible_pipes

    def check_if_telnet_is_ok_and_from_where_numbering_of_rx_starts(self, radio_object, resource):
        """
        This method checks if telnet connection to radio is working and if numbering of rx is started from 65.

        :param object radio_object: Radio object
        :param str resource: Can have values LTX, TX1-TX8, RX1-RX8, All_TX or All_RX.
        :return list: Returns list of possible pipes and boolean value if telnet connection is working or not.
        """
        no_telnet_problem = True
        manual_of_sendfault = self.ssh.send_command_to_radio_by_telnet(radio_object, "sendFault", return_output=True,
                                                                       expect_output=True, print_to_eventlog=False,
                                                                       name_for_log="_manual")
        possible_pipes = []
        if manual_of_sendfault:
            info("Telnet connection to radio is working.")
            manual_of_sendfault, manual_ok = self._check_if_sendfault_includes_manual(manual_of_sendfault, radio_object)
            if not manual_ok:
                error("Manual of sendFault command was not get.")
            if "RX" in resource:
                rx_stat = self.get_rx_stat(radio_object)
                rx_pattern = re.compile(r"antenna\d+\w+\s+.RX.\s+=\s+(\d+)")
                all_rxs = re.findall(rx_pattern, manual_of_sendfault)
                # pipe_pattern = re.compile(r"HW State\.+(\w+)")
                pipe_pattern = re.compile(r"Front End Gain\.+(\d+\.\d+)\s+dB")
                active_pipes = re.findall(pipe_pattern, rx_stat)
                vrx_pattern = re.compile(r"(RX\d+)\s+Virtual\s+Device\s+status")
                active_vrx = re.findall(vrx_pattern, rx_stat)
                info(f"Found RXs from RMOD HW: {all_rxs}")
                info(f"Found Front End Gain from RMOD HW: {active_pipes}")
                info(f"Found RX: {active_vrx}")
                a_pipes = self._get_sorted_active_rx(active_pipes, active_vrx)
                found_rxs = self._get_possible_rxs(all_rxs, a_pipes)
                active_rxs = self.bts.select_antenna_from_active_antennas_of_radio_by_position(
                    "All_RX", radio_object, print_to_eventlog=False)
                self.logger.debug(f"active_rxs {active_rxs}")
                # possible_rx = []
                for active_antenna in active_rxs:
                    possible_pipes.append(found_rxs[int(active_antenna[-1]) - 1])
                self.logger.debug(f"possible_rx {possible_pipes}")
                if not possible_pipes:
                    error("Couldn't get any active RX pipes.")
                    raise EnvironmentIssue
            elif "TX" in resource:
                self.get_tx_stat(radio_object)
                tx_pattern = re.compile(r"antenna\d+\w+\s+.TX.\s+=\s+(\d+)")
                rx_pattern = re.compile(r"antenna\d+\w+\s+.RX.\s+=\s+(\d+)")
                all_txs = re.findall(tx_pattern, manual_of_sendfault)
                all_rxs = re.findall(rx_pattern, manual_of_sendfault)
                info(f"TXs from RMOD HW: {all_txs}")
                info(f"RXs from RMOD HW: {all_rxs}")
                if all_txs:
                    all_txs = sorted(all_txs)
                    active_txs = self.bts.select_antenna_from_active_antennas_of_radio_by_position(
                        "All_TX", radio_object, print_to_eventlog=False)
                    active_txs = sorted(active_txs)
                    possible_pipes = self._get_possible_tx_pipes(all_txs, active_txs, all_rxs)
                    self.logger.debug(f"possible tx {possible_pipes}")
                    if not possible_pipes:
                        error("Couldn't get any active TX pipes.")
                        raise EnvironmentIssue
                else:
                    error("Couldn't get active TXs from the sendFault manual nor with method "
                          "select_antenna_from_active_antennas_of_radio_by_position. Check logs and take contact to "
                          "script developers if environment is working.")
                    raise EnvironmentIssue
        else:
            error("No output get for telnet command 'sendFault', unable to check manual of sendFault "
                  "and unable to send any sendFault commands via telnet.")
            no_telnet_problem = False
        return sorted(possible_pipes), no_telnet_problem

    def send_fault_to_rf_module(self, unit, fault_id, resource, deactivate_fault, severity):
        """
        Send fault to RF module via telnet.

        :param object unit: Radio object
        :param str fault_id: Fault to cause to radio. For example 1904.
        :param str resource: Can have values LTX, TX1-TX8, RX1-RX8, All_TX or All_RX.
        :param bool deactivate_fault: Default is False and then fault is activated, if True fault is cleared.
        :param str severity: Default value is 0 that means that fault is critical.
        """
        radio_object = unit
        unit = radio_object.name
        if not self.bts:
            self.bts = BuiltIn().get_library_instance("BTS")
        possible_pipes, no_telnet_problem = self.check_if_telnet_is_ok_and_from_where_numbering_of_rx_starts(
            radio_object, resource)
        if no_telnet_problem:  # telnet connection is working fine
            # RX failure, may need modifications in command, TX need resource checks and LTX doesn't need modifications
            if "LTX" in resource:
                antenna = 0
            elif "TX" in resource:
                if not resource[-1].isdigit():
                    error("Resource given to send_fault_to_rf_module method is invalid. It is expected to be TX1-TX8, "
                          "now {} is given, NOK.".format(resource))
                    raise ScriptIssue
                antenna = int(resource[-1])
                # tx = int(resource[-1])
                # self.logger.debug(f"tx {tx}")
                if possible_pipes and len(possible_pipes) < antenna:
                    error(f"There are just {len(possible_pipes)} TXs in the radio HW, user given value "
                          f"{resource} is impossible in this environment.")
                    raise ScriptIssue
                # antenna = possible_pipes[tx - 1]
                self.logger.debug(f"antenna {antenna}")
            elif "RX" in resource:  # and int(antenna) > 8:
                if not resource[-1].isdigit():
                    error("Resource given to send_fault_to_rf_module method is invalid. It is expected to be RX1-RX8, "
                          "now {} is given, NOK.".format(resource))
                    raise ScriptIssue
                rx = int(resource[-1])
                self.logger.debug(f"rx {rx}")
                if possible_pipes and len(possible_pipes) < rx:
                    error(f"There are just {len(possible_pipes)} active RXs in the environment, user given value "
                          f"{resource} is impossible in this environment.")
                    raise ScriptIssue
                antenna = possible_pipes[rx - 1]
                self.logger.debug(f"antenna {antenna}")
            else:
                error("Given resource should be LTX, TX1-TX8, or RX1-RX8, now {} given, NOK".format(resource))
                raise ScriptIssue
            if fault_id not in FaultingRmod.fault_dict:
                error("Given fault id {} is not found from the fault_dict.".format(
                    fault_id, FaultingRmod.fault_dict))
                raise ScriptIssue
            set_cancel = "0"
            if deactivate_fault:
                set_cancel = "1"
            command = "sendFault {} {} {} {} 0 0\n".format(FaultingRmod.fault_dict[fault_id], antenna, severity,
                                                           set_cancel)
            info("Give command '{}' to {} via telnet".format(command, unit))
            self.ssh.send_command_to_radio_by_telnet(
                radio_object, command, print_to_eventlog=False)
            info("Command has been given.")
        else:
            error("No telnet connection to {}".format(radio_object.name))
            raise EnvironmentIssue

    @staticmethod
    def _made_rmod_fault_commands(ip, fault_id, radio):
        commands = ["ip -4 neigh", "ssh {}".format(ip), "sudo su"]
        if str(fault_id) == "1911":
            commands.append("devmem 0xFC98025C 32 0x0")
        elif str(fault_id) == "1907":
            commands.append("devmem 0xFC9003A4 h 0x0")
        else:
            error("Fault {} to MADE radio {} is not yet implemented.".format(fault_id, radio.name))
            raise ScriptIssue
        return commands

    @staticmethod
    def _mars_thor_rautu_fault_commands(ip, fault_id, radio):
        if str(fault_id) == "1907":
            commands = ["sudo su", "ip -4 neigh", f"TERM=dumb ssh serviceuser@{ip}", "sudo su",
                        "frmonShellClient 127.0.0.1 2000", "/ action create DevMem /test",
                        "/test action read 0xf4200180 32"]
        elif str(fault_id) == "10":
            commands = ["sudo su", "frmonShellClient 127.0.0.1 2000", "/ action create DevMem /test",
                        "/test action read 0xf4200180 32"]
        else:
            error("Fault {} to MARS, THOR or RAUTU radio {} is not yet implemented.".format(fault_id, radio.name))
            raise ScriptIssue
        return commands

    @staticmethod
    def _kill_application_fault_commands(radio, fault_id):
        if str(fault_id) == "10":
            return ["sudo su", "killall -9 rmod"]
        elif str(fault_id) == "1907":
            return ["sudo su", "killall -9 rmod", "killall -9 rmod2"]
        else:
            error("Fault {} to kill application in radio {} is not yet implemented.".format(fault_id, radio.name))
            raise ScriptIssue

    def send_fault_to_made_rf_module(self, radio, fault_id):
        """
        This method causes faults to made radios.

        :param object radio: Radio object.
        :param str/int fault_id: Fault id, for example 1911 or 1907
        """
        commands = self._made_rmod_fault_commands("192.168.100.2", fault_id, radio)
        commands.extend(["exit", "exit"])
        commands2 = self._made_rmod_fault_commands("192.168.100.3", fault_id, radio)
        commands.extend(commands2)
        self.ssh.send_command_to_radio_by_ssh(radio, commands)

    def send_fault_to_mars_thor_rautu_rf_module(self, radio, fault_id):
        """
        This method causes faults to made radios.

        :param object radio: Radio object.
        :param str/int fault_id: Fault id, for example 1911 or 1907
        """
        commands = self._mars_thor_rautu_fault_commands("192.168.100.2", fault_id, radio)
        # commands.extend(["exit", "exit"])
        # commands2 = self._made_rmod_fault_commands("192.168.100.3", fault_id, radio)
        # commands.extend(commands2)
        ssh_object = self.ssh.send_command_to_radio_by_ssh(radio, commands, disconnect_ssh=False, set_dumb_term=True,
                                                           return_ssh_object=True)
        self.ssh.send_command_to_radio_by_ssh(
            radio, "/test action write 0xf4200180 32 0x0", enb_ssh=ssh_object, expect_output=False,
            remove_known_hosts=False, ssh_connection_to_radio=False, disconnect_ssh=False, return_ssh_object=True)
        BuiltIn().sleep(10)  # wait 10s before disconnecting ssh
        self.ssh.disconnect_ssh_connection(ssh_object, print_to_eventlog=False)

    def kill_application_from_radio(self, radio, application_to_kill):
        """
        This method causes faults to radios by killing application.

        :param object radio: Radio object.
        :param str application_to_kill: application to kill, for example /opt/UCCS/uCcsSysComControlDaemon
        """
        if not application_to_kill:
            error("No application given to kill_application_from_radio method.")
            raise ScriptIssue
        rmod_log_name = f"to_{radio.name.replace('.', '').replace('(', '').replace(')', '')}"
        enb_ssh = self.ssh.ssh_connection_to_smod_ltx_attach(rmod_log_name, print_to_eventlog=True, raise_error=True)
        try_time = 0
        process_found = False
        pid = ""
        process_cmd = "ps aux -w -w"
        if radio.name[:2] == "AQ":
            process_cmd = "ps -l -w -w"
        while not process_found and try_time < 5:
            processes = self.ssh.send_command_to_radio_by_ssh(
                radio, process_cmd, enb_ssh=enb_ssh, expect_output=False, return_output=True, print_to_eventlog=True,
                raise_error=True, ignore_expect=False, disconnect_ssh=False)
            if processes:
                pattern = re.compile(
                    fr"^\s*(?:(?:[A-Za-z]\S*\s+\d+\s+)|(?:\S+\s+))(\d+)\s+.*{re.escape(application_to_kill)}\s*$",
                    re.MULTILINE)
                match = pattern.search(processes)
                if match:
                    pid = match.group(1)
                    self.logger.debug(f"Process {application_to_kill} is found from radio. PID is {pid}.")
                    process_found = True
                else:
                    info(f"Process {application_to_kill} is not found from radio, try again ({try_time + 1}/5).")
                    try_time += 1
        if process_found:
            info(f"Process {application_to_kill} is found from radio {radio.name}, send kill command.")
            self.ssh.send_command_to_radio_by_ssh(radio, f"sudo kill -9 {pid}", enb_ssh=enb_ssh, expect_output=False,
                                                  print_to_eventlog=True, raise_error=True, disconnect_ssh=False,
                                                  remove_known_hosts=False, ssh_connection_to_radio=False)
            BuiltIn().sleep(10)  # wait 10s before disconnecting ssh
            self.ssh.disconnect_ssh_connection(enb_ssh, print_to_eventlog=False)
        else:
            error(f"Process {application_to_kill} is not found from radio {radio.name} after several tries, cannot send"
                  f" kill command. Check manually if application is running in radio and if environment is working.")
            raise EnvironmentIssue

    def rmod_ltx_spontaneous_reset(self, radio):
        """
        Reset radio. Reset command depends on radio type and command is given via telnet or via ssh connection.

        :param object radio: Radio object.
        """
        if self.use_telnet_for_faulting(radio):
            if "FHCA" in radio.name:
                command = "reset\r"
            elif "FRHF" in radio.name:
                command = "Mcu -r"
            elif any(unit_name for unit_name in ["FRHC", "FRGY", "FRIJ", "FRMC"] if unit_name in radio.name):
                command = "Mcu -r 11 6"
            else:
                command = "Mcu -r 1 6"
            info(f"Start to reset {radio.name} unit by using command '{command}'")
            self.ssh.send_command_to_radio_by_telnet(radio, command)
        else:
            command = "reboot"  # This command is suitable for nahka and made radios
            info(f"Start to reset {radio.name} unit by using command '{command}'")
            self.ssh.send_command_to_radio_by_ssh(radio, command, expect_output=False)

    def expect_reset_or_fault(self, ant_resource, lte441a_active, resources_on_two_rmod, index_value, last_index,
                              cells_of_rmod, all_one_by_one=False):
        """
        Check if fault is causing radio reset or if alarm should be activated.

        :param str ant_resource: Resource of the antenna, for example LTX, TX1-TX8, RX1-RX8, All_TX or All_RX.
        :param bool lte441a_active: Is LTE441A active or not. True or False.
        :param bool resources_on_two_rmod: Are resources on two rmod or not. True or False.
        :param int index_value: Index value of the antenna.
        :param int last_index: Last index value of the antenna. Amount of all antennas.
        :param list cells_of_rmod: List of cells of the rmod.
        :param bool all_one_by_one: If all antennas are faulted one by one, True or False.
        """
        if not self.bts:
            self.bts = BuiltIn().get_library_instance("BTS")
        fault_id = BuiltIn().get_variable_value("${FAULT}")
        tx_and_rx_on_same_pipe = False
        ant_position = 0
        faulted_cells = []
        if self.bts.rmod_ant_direction_and_cell:
            active_antennas = sorted(self.bts.rmod_ant_direction_and_cell.keys())
            for ant in active_antennas:
                ant_position += 1
                if all_one_by_one:
                    cells_of_ant = self.bts.rmod_ant_direction_and_cell[ant][1]
                    self.logger.debug(f"Cells of ant: {cells_of_ant}")
                    for cell in cells_of_ant:
                        if cell not in faulted_cells:
                            faulted_cells.append(cell)
                self.logger.debug(f"Faulted_cells {faulted_cells}, current index {index_value}, last index "
                                  f"{last_index}, antenna {ant}")
                if int(index_value) == ant_position:
                    tx_and_rx_on_same_pipe = True if self.bts.rmod_ant_direction_and_cell[ant][0] == "TX/RX" else False
                    break
        if "TX" in ant_resource and lte441a_active and index_value < last_index:
            return "fault"
        elif "TX" in ant_resource and lte441a_active and index_value == last_index:
            return "reset"
        elif "TX" in ant_resource and not lte441a_active and len(cells_of_rmod) == 1:
            return "reset"
        elif (fault_id in ["1905"] and "TX" in ant_resource and not lte441a_active and len(cells_of_rmod) >= 1 and
              index_value == last_index):
            return "reset"
        elif "TX" in ant_resource and not lte441a_active and len(cells_of_rmod) > 1 and (
                not faulted_cells or (faulted_cells and len(faulted_cells) < len(cells_of_rmod))):
            return "fault"
        elif "TX" in ant_resource and not lte441a_active and len(cells_of_rmod) > 1 and (
                faulted_cells and len(faulted_cells) == len(cells_of_rmod)):
            return "reset"
        elif (fault_id in ["1904"] and "RX" in ant_resource and not lte441a_active and len(cells_of_rmod) == 1 and
              tx_and_rx_on_same_pipe):
            return "reset"
        elif (fault_id in ["1904"] and "RX" in ant_resource and not lte441a_active and len(cells_of_rmod) > 1 and
              index_value < last_index):
            return "fault"
        elif (fault_id in ["1904"] and "RX" in ant_resource and not lte441a_active and len(cells_of_rmod) > 1 and
              index_value == last_index):
            return "reset"
        elif "RX" in ant_resource and index_value < last_index:
            return "fault"
        elif "RX" in ant_resource and not resources_on_two_rmod and index_value == last_index:
            return "reset"
        elif "RX" in ant_resource and resources_on_two_rmod and index_value == last_index:
            return "fault"
        else:
            error(f"Given parameters for expect_reset_or_fault method are not matching with any of the expected "
                  f"combinations. Check logs and take contact to script developers if environment is working. Given "
                  f"parameters: ant_resource {ant_resource}, lte441a_active {lte441a_active}, "
                  f"resources_on_two_rmod {resources_on_two_rmod}, index_value {index_value}, last_index "
                  f"{last_index}, cells_of_rmod {cells_of_rmod}.")
            raise ScriptIssue

    @staticmethod
    def get_number_from_resource(ant_resource):
        """
        Get number from the resource. For example if resource is RX1, return 1.

        :param str ant_resource: Resource of the antenna, for example TX1-TX8 or RX1-RX8
        :return int: Return number from the resource.
        """
        if "TX" in ant_resource or "RX" in ant_resource:
            tx_or_rx_number = int(re.search(r'\d+', ant_resource).group())
            if tx_or_rx_number:
                return tx_or_rx_number
            else:
                error(f"Resource given to get_number_from_resource method is invalid. It is expected to be TX1-TX8 or "
                      f"RX1-RX8, now {ant_resource} is given, NOK.")
                raise ScriptIssue
        else:
            error(f"Resource given to get_number_from_resource method is invalid. It is expected to be TX1-TX8 or "
                  f"RX1-RX8, now {ant_resource} is given, NOK.")
            raise ScriptIssue
