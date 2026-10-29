# -*- coding: utf-8 -*-
import xml.etree.ElementTree as Et
from robot.api import logger
import subprocess
import time
import os
from multiprocessing import Pool
import pexpect


class NmapOperations:
    def __init__(self):
        self.port_number, self.protocol, self.service_name = [], [], []
        self.xml_files = []
        self.process_array = []

    def teardown(self):
        self.__init__()

    # def get_open_ports_from_nmap_output(self):
    #     """
    #     Get open port from nmap output
    #     """
    #     for xml_file in self.xml_files:
    #         nmap_root = Et.parse(xml_file).getroot()
    #         for port in nmap_root.iter('port'):
    #             if list(port[0].attrib.items())[0][1] == "open":
    #                 self.port_number.append(list(port.attrib.items())[1][1])
    #                 self.protocol.append(list(port.attrib.items())[0][1])
    #                 try:
    #                     self.service_name.append(list(port[1].attrib.items())[0][1])
    #                 except IndexError:
    #                     self.service_name.append('unknown')
    #         self.remove_nmap_output_file(xml_file)
    #     logger.console("\nOpen Ports from nmap scan(" + str(len(self.port_number)) + "):")
    #     return [self.port_number, self.protocol, self.service_name]

    def get_open_ports_from_nmap_output(self):
        """
        Get open port from nmap output
        """
        for xml_file in self.xml_files:
            nmap_root = Et.parse(xml_file).getroot()
            flag = False
            for port in nmap_root.iter('port'):
                if list(port[0].attrib.items())[0][1] == "open":
                    flag = True
                    self.port_number.append(list(port.attrib.items())[1][1])
                    self.protocol.append(list(port.attrib.items())[0][1])
                    try:
                        self.service_name.append(list(port[1].attrib.items())[0][1])
                    except IndexError:
                        self.service_name.append('unknown')
            for runstats in nmap_root.iter('runstats'):
                if list(runstats[0].attrib.items())[4][1] == "error":
                    flag = True
                    errormsg = list(runstats[0].attrib.items())[5][1]
                    logger.console("error exit in file: {}".format(xml_file))
                    logger.console("error msg: {}".format(errormsg, xml_file))

                    # self.port_number.append(list(port.attrib.items())[1][1])
                    # self.protocol.append(list(port.attrib.items())[0][1])
                    # try:
                    #     self.service_name.append(list(port[1].attrib.items())[0][1])
                    # except IndexError:
                    #     self.service_name.append('unknown')
            # if not flag:
            #     self.remove_nmap_output_file(xml_file)
        logger.console("\nOpen Ports from nmap scan(" + str(len(self.port_number)) + "):")
        res = []
        for i, j, k in zip(self.port_number, self.protocol, self.service_name):
            res.append([i, j, k])
        return res

    def get_ports_with_wrong_behavior(self, open_ports, element_type):
        """
        FOR CLASSICAL VERSION
        function check open port with communication matrix
        :param open_ports: str: open ports from nmap
        :param plane: str: type of plane, OAM/TRACE/F1C/X2C/F1U/X2U/S1U/XNC/NGC/F1U/XNU/NGU
        """
        vcu_accept_ports = {'443', '500', '514', '2152', '4500', '6514', '8080', '8443', '51274', '54000-65535'}
        vdu_accept_ports = {'21', '389', '68', '548', '111', '443', '500', '514', '2152', '4500', '6514', '8080',
                            '8443', '51274', '49152-65535'}
        accept_services = {'icmp', 'ipv6-icmp', 'tcp', 'udp'}
        wrong_ports = {}
        for i in open_ports:
            for j in open_ports[i]:
                if i == 'IP' and j[2] in accept_services:
                    continue
                elif i != 'IP' and element_type == 'VCU' and self.check_ports_in_range(vcu_accept_ports, j[0]):
                    continue
                elif i != 'IP' and element_type == 'VDU' and self.check_ports_in_range(vdu_accept_ports, j[0]):
                    continue
                else:
                    if i not in wrong_ports:
                        wrong_ports[i] = []
                    wrong_ports[i].append(j)
        return wrong_ports

    def check_ports_in_range(self, ports_range, port):
        for i in ports_range:
            if '-' not in i:
                if int(port) == int(i):
                    return True
            else:
                ports_list = i.split('-')
                if int(port) >= int(ports_list[0]) and int(port) <= int(ports_list[1]):
                    return True
        return False

    @staticmethod
    def remove_nmap_output_file(xml_file):
        res = os.path.splitext(xml_file)
        nmap_file = res[0]+'.nmap'
        gnmap_file = res[0] + '.gnmap'
        subprocess.Popen(['sudo', 'rm', '-f', xml_file], stdout=subprocess.PIPE)
        print("File removed {}".format(xml_file))
        subprocess.Popen(['sudo', 'rm', '-f', nmap_file], stdout=subprocess.PIPE)
        print("File removed {}".format(nmap_file))
        subprocess.Popen(['sudo', 'rm', '-f', gnmap_file], stdout=subprocess.PIPE)
        print("File removed {}".format(gnmap_file))

    # @staticmethod
    # def remove_nmap_namp_file(plane):
    #     cmd=['sudo', 'rm', '-f', "*{}*".format(plane)]
    #     subprocess.Popen(cmd, stdout=subprocess.PIPE)
    #     print("File removed {}".format(' '.join(cmd)))

    def run_nmap(self, name_of_scan, target, protocol,
                 port_range=('0', '65535'), path='home/ute/robotws5g/'):
        """
        Method to run nmap scan
        :param name_of_scan: str: name of scan output
        :param target: str: ip address of target
        :param protocol: str: communication protocol TCP/UDP/SCTP
        :param port_range: tuple: port range
        :return:
        """
        os.system('mkdir -p ' + path)
        name_of_scan = name_of_scan.replace(' ', '') + '_p_' + \
            port_range[0] + '_' + port_range[1]
        self.xml_files.append(
            path + '/' + name_of_scan + '.xml')
        protocols = {'TCP': '-sS', 'IP': '-sO', 'UDP': '-sU', 'SCTP': '-sY',
                     'TCPcon': '-sT', 'NULL': '-sN', 'FIN': '-sF',
                     'XMAS': '-sX', 'TCPack': '-sA', 'TCPwin': '-sW',
                     'TCPmai': '-sM', 'SCTPcookie': '-sZ'}
        if ':' in target:
            ipv = ' -6'
        else:
            ipv = ''
        command = 'sudo nmap{} {} -p {}-{} -Pn -vvv --reason --webxml -oA ' + path + '/{} --max-rate 300 {}'
        if protocol == "IP":
            command = 'sudo nmap{} {} -p {}-{} -vvv --reason --webxml -oA ' + path + '/{} --max-rate 300 {}'
        command = command.format(ipv, protocols[protocol], port_range[0], port_range[1], name_of_scan, target)
        logger.console('Sending command: ' + command)
        command = command.split()
        process = subprocess.Popen(command, stdout=subprocess.PIPE)
        self.process_array.append(process)

    def run_divided_nmap_scan(self, name_of_scan, target, protocol, divide=1, output_path='home/ute/robotws5g/'):
        divide = int(divide)
        scans_array = self.divide_scan(divide) if protocol != "IP" else self.divide_scan(divide, True)
        print(scans_array)
        running_scans = 0
        while running_scans > 0 or len(scans_array) > 0:
            if len(scans_array) > 0:
                for scan in scans_array:
                    self.run_nmap(name_of_scan, target, protocol, (scan[0], scan[1]), output_path)
                scans_array = []
            running_scans = self.get_running_scans()
            logger.console("Process in background: " + str(running_scans))
            time.sleep(2)

    def run_nmap_parallel(self, name_of_scan_orginal, target, protocol, divisor, port_ranges, path='home/ute/'):
        command_list = []
        protocols = {'TCP': '-sS', 'IP': '-sO', 'UDP': '-sU', 'SCTP': '-sY',
                     'TCPcon': '-sT', 'NULL': '-sN', 'FIN': '-sF',
                     'XMAS': '-sX', 'TCPack': '-sA', 'TCPwin': '-sW',
                     'TCPmai': '-sM', 'SCTPcookie': '-sZ'}
        if ':' in target:
            ipv = ' -6'
        else:
            ipv = ''

        os.system('mkdir -p ' + path)

        for port_range in port_ranges:
            name_of_scan = name_of_scan_orginal
            name_of_scan = name_of_scan.replace(' ', '') + '_p_' + port_range[0] + '_' + port_range[1]
            self.xml_files.append(path + '/' + name_of_scan + '.xml')
            command = 'sudo nmap{} {} -p {}-{} -Pn -vvv --reason --webxml -oA ' + path + '/{} --max-rate 300 {}'
            if protocol == "IP":
                command = 'sudo nmap{} {} -p {}-{} -vvv --reason --webxml -oA ' + path + '/{} --max-rate 300 {}'
            command = command.format(ipv, protocols[protocol], port_range[0], port_range[1], name_of_scan, target)
            command_list.append(command)
        process = Pool(divisor)
        process.map(os.system, command_list)

    def run_divided_nmap_scan_parallel(self, name_of_scan, target, protocol, divisor=1, output_path='home/ute/'):
        divisor = int(divisor)
        scans_array = self.divide_scan(divisor) if protocol != "IP" else self.divide_scan(divisor, True)
        running_scans = 0
        while running_scans > 0 or len(scans_array) > 0:
            if len(scans_array) > 0:
                self.run_nmap_parallel(name_of_scan, target, protocol, divisor, scans_array, output_path)
                scans_array = []
            running_scans = self.get_running_scans()
            logger.console("Process in background: " + str(running_scans))
            time.sleep(2)

    def get_running_scans(self):
        running_processes = 0
        for process in self.process_array:
            if self.process_exists(process):
                running_processes += 1
        return running_processes

    @staticmethod
    def process_exists(process):
        """Check whether pid exists in the current process table."""
        retcode = process.poll()
        return retcode is None

    @staticmethod
    def divide_scan(divide, isIP=False):
        if isIP:
            return [['0', '255']]
        rest_of_ports = 65535 % divide
        part_of_ports = 65535 // divide
        scans = []
        for cut in range(0, divide):
            start = cut * part_of_ports
            finish = (cut + 1) * part_of_ports - 1
            if cut == divide - 1:
                finish += rest_of_ports + 1
            scans.append([str(start), str(finish)])
        return scans

    @staticmethod
    def get_ports_with_wrong_behavior_with_netcat_check(open_ports, plane, target, protocol="TCP"):
        """
        FOR CLASSICAL VERSION
        function check open port with communication matrix
        :param open_ports: str: open ports from nmap
        :param plane: str: type of plane, Management Plane/Control Plane/User Plane/Synchronization plane/LMP
        """
        planes = {
            'LMP': 'Management plane',
            'Management plane': 'Management plane',
            'Control plane': 'Control plane',
            'Control planeX2': 'Control plane',
            'User plane': 'User plane',
            'User planeS1': 'User plane',
            'Synchronization plane': 'Synchronization plane',
            'NG-U': 'User plane',
            'NG-C': 'Control plane',
            'LMPDU': 'Management plane',
            'SplaneDU': 'Synchronization plane',
            'F1-CDU': 'Control plane',
            'F1-MDU': 'Management plane',
            'F1-UDU': 'User plane'}
        if not planes.get(plane):
            raise ValueError(plane
                             + " is not supported by CM or this test")
        accept_ports = {'22', '80', '443', '8443',
                        '20401', '8080', '38472', '36422'}
        if len(open_ports[0]) == 0:
            return []
        elif all([port in accept_ports for port in open_ports[0]]) and planes.get(plane) == 'Management plane':
            return []
        elif all([port in accept_ports for port in
                  open_ports[0]]) and protocol == 'SCTP':
            return []
        else:
            port_to_check = [item for item in open_ports[0] if item not in list(accept_ports)]
            logger.console("Invalid ports: {}".format(port_to_check))
            for port in port_to_check:
                cmd = 'netcat {} {}'.format(target, port)
                child = pexpect.spawn(cmd)
                i = child.expect(['>', '#', pexpect.TIMEOUT])
                if i == 2:
                    child = pexpect.spawn('id')
                    i = child.expect([pexpect.TIMEOUT, pexpect.EOF])
                if i == 0:
                    logger.console('Invalid port {}, netcat has access to {} shell'.format(port, child.before))
            raise ValueError("{} not in {}".format(open_ports[0], accept_ports))
        # cm = CommunicationMatrix(open_ports=open_ports,
        #                          network_element=network_element,
        #                          plane=planes.get(plane))
        # cm.get_data_from_communication_matrix_for_open_ports()
        # list_of_ports_with_wrong_behavior = cm.check_policy_for_ports()
        # logger.console('Number of ports with wrong policy: ' + str(len(list_of_ports_with_wrong_behavior)))
