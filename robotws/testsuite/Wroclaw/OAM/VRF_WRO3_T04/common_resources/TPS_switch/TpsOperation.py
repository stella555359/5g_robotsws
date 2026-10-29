# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Maciej Jopek
:contact: maciej.jopekO@nokia.com
:maintainer: Maciej Jopek
"""
import pexpect
import time
import logging
import vm_operation
import re
from robot.api.logger import console

logging.basicConfig(format='%(asctime)s - %(levelname)s: %(message)s',
                    filename='example.log',
                    level=logging.INFO)


def process_output(output):
    """Function to precess output form switch"""
    return output.decode()


class TpsOperation:
    """
    Usage example:
        ssh = TpsOperation()
        connection = ssh.connect_to_switch('vm_ip_address')
        output = ssh.execute_command_on_switch('show version', connection)
        ssh.disconnect_from_switch(connection)
    """
    ROBOT_LIBRARY_SCOPE = 'TEST SUITE'

    def __init__(self):
        self.child = None
        self.vm_operation = None

    def check_connectivity_to_switch(self, switch_ip_address, how_many=10):
        """Function to check connectivity to switch"""
        counter = 0
        while counter < how_many:
            counter += 1
            output = process_output(self.send_ping_command(switch_ip_address))
            logging.info('Send ping command to switch')
            if '1 received' in output:
                logging.info('Ping command successful')
                break
            time.sleep(10)
        assert counter < how_many - 1, 'Switch connectivity error'

    @staticmethod
    def check_output(output, should_be):
        """Function to compare expected output from command and obtained output"""
        assert should_be in output, \
            'Expected output is not in output. Expected output: {}, Output: {}'.format(should_be, output)

    def connect_to_switch(self, vm_ip_address, switch_ip_address='172.16.0.1', vm_username='ute', vm_password='ute',
                          ssh_switch_username='cli', switch_username='admin', switch_password='Admin@1830'):
        """Function to create connection to switch CIT"""
        try:
            self.vm_operation = vm_operation.VmOperation()
            self.child = self.vm_operation.connect_to_vm(vm_ip_address, vm_username, vm_password)
            self.check_connectivity_to_switch(switch_ip_address)
            self.child.sendline('ssh {}@{}'.format(ssh_switch_username, switch_ip_address))
            self.child.expect('Username:')
            self.child.sendline(switch_username)
            self.child.expect('Password:')
            self.child.sendline(switch_password)
            self.child.expect('\\?')
            self.child.sendline('y')
            self.child.expect('#')
            status = process_output(self.child.before)
            self.check_output(status, 'Alarm Status')
            self.child.sendline("paging status disabled")
            self.child.expect('#')
            logging.info("Paging disabled")
            logging.info("Connection to switch created")
            return self.child
        except AssertionError as e:
            logging.error('Connection to switch can not be created despite connectivity test success')

    def disconnect_from_switch(self, child):
        """Function to disconnect from switch"""
        child.sendline('logout')
        child.expect('\\$')
        logging.info('Connection to switch closed')
        self.vm_operation.disconnect_from_vm()

    def execute_command_on_switch(self, command, child, counter=1, should_be=None):
        """Function to execute command"""
        if counter == 0:
            return 0
        child.sendline(command)
        child.expect('#')
        output = process_output(child.before)
        if should_be:
            try:
                self.check_output(output, should_be)
            except AssertionError as e:
                time.sleep(10)
                logging.error(e)
                self.execute_command_on_switch(command, child, counter - 1, should_be)
        return output

    def send_ping_command(self, switch_ip_address='172.16.0.1'):
        """Function to send ping command to switch"""
        self.child.sendline('ping -c 1 {}'.format(switch_ip_address))
        self.child.expect('\\$')
        return self.child.before

    def check_vpls_in_input(self, console_input, vpls_id):
        services = [re.split(r'\s{2,}', line.strip()) for line in console_input.split("\n") if "VPLS" in line]
        for service in services:
            if service[0] == vpls_id:
                return True
        return False

    def check_sap_in_input(self, console_input, sap_port_number):
        services = [re.split(r'\s{2,}', line.strip()) for line in console_input.split("\n") if "sap" in line]
        for service in services:
            if f'{sap_port_number}:' in service[0]:
                return True
        return False

    def check_is_session_timeout_in_input(self, console_input, session_timeout):
        correct_output = [re.split(r'\s{2,}', line.strip()) for line in console_input.split("\n") if "Timeout" in line]
        for output in correct_output:
            if session_timeout in output[-1]:
                return True
        return False

    def parse_vpls_status(self, console_input, vpls_id, type):
        services = [re.split(r'\s{2,}', line.strip()) for line in console_input.split("\n") if "VPLS" in line]
        if type == "Opr":
            status = [service[3] for service in services if service[0] == vpls_id]
        elif type == "Adm":
            status = [service[2] for service in services if service[0] == vpls_id]
        else:
            assert False, "Invalid type of VPLS status: {}".format(type)
        assert len(status) == 1, \
            "Could not find VPLS with id: {} (or found more than one VPLS with same id)".format(vpls_id)
        return status[0]

    def parse_sap_status(self, console_input, sap_port_number, type):
        services = [re.split(r'\s{2,}', line.strip()) for line in console_input.split("\n") if "sap" in line]
        if type == "Opr":
            status = [service[3] for service in services if f'{sap_port_number}:' in service[0]]
        elif type == "Adm":
            status = [service[2] for service in services if f'{sap_port_number}:' in service[0]]
        else:
            assert False, "Invalid type of SAP status: {}".format(type)
        assert len(status) == 1, \
            "Could not find SAP with port number: {} " \
            "(or found more than one SAP port with same number)".format(sap_port_number)
        return status[0]

    def parse_number_of_mac_adresses(self, console_input):
        return len([re.split(r'\s{2,}', line.strip()) for line in console_input.split("\n") if "sap" in line])

    def parse_sap_counter(self, console_input, counter_type):
        types_of_counters = ["IngressPktsForwarded", "IngressOctetsForwarded", "EgressPktsForwarded",
                             "EgressOctetsForwarded", "IngressPktsDropped", "IngressOctetsDropped"]
        assert counter_type in types_of_counters, \
            "Invalid counter type: {} (available types: {})".format(counter_type, ", ".join(types_of_counters))
        return [line.strip() for line in console_input.split("\n") if counter_type in line][0].split(":")[-1].strip()

    def get_sap_list(self, console_input, sap_type):
        output = [re.split(r'\s{2,}', line.strip())[0] for line in console_input.split("\n") if "sap" in line]
        pattern = r'X\d+' if sap_type.upper() == "X" else r'C\d+'
        return [re.search(pattern, text).group() for text in output if re.search(pattern, text) is not None]

    @staticmethod
    def get_ru_port_for_test_line(tps_output, test_line, ru_type):
        """
        Takes a list of information about TPS connections and
        returns a "Location" field of TPS port string for specific TL and RU.
        Location is represented like "1/4/X4" or "1/4/X5", like in example below.

                  Port                                      Admin Oper  State
     Location Function     Description               Dir State State Qualifier
-------------------------------------------------------------------------------
       1/4/X4 Uplink                                 Bi  Down  Down  FLT SDEE
       1/4/X5 Uplink       Uplink_TPS-Rack_556-BBU_~ Bi  Up    Up    SDEE
        """
        lines = tps_output.split('\r\n')
        for line in lines:
            if ru_type in line and test_line in line:
                return line.split()[0]

    @staticmethod
    def get_all_ru_ports_for_test_line(tps_output, test_line):
        """
        Takes a list of information about TPS connections and
        returns a "Location" field of TPS port string for specific TL and RU.
        Location is represented like "1/4/X4" or "1/4/X5", like in example below.

                  Port                                      Admin Oper  State
     Location Function     Description               Dir State State Qualifier
-------------------------------------------------------------------------------
       1/4/X4 Uplink                                 Bi  Down  Down  FLT SDEE
       1/4/X5 Uplink       Uplink_TPS-Rack_556-BBU_~ Bi  Up    Up    SDEE
        """
        lines = tps_output.split('\r\n')
        ports = []
        for line in lines:
            if test_line in line:
                ports.append(line.split()[0])
        return ports
