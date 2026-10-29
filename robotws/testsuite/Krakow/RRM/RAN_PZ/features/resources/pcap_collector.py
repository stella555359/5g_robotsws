import os
from contextlib import contextmanager
from datetime import datetime
from robot.api import logger
from taf.rfrl.utilities.robot.general import get_builtin_value

from taf.analyzer.pdml import PdmlReader
from taf.transport.ssh import ssh


@contextmanager
def gnb_connection(ip, username, password):
    gnb_connection = ssh()
    gnb_connection.connect_to(ip, username, password)
    try:
        yield gnb_connection
    finally:
        gnb_connection.disconnect()


class PcapCollector:
    def __init__(self, ip=None, username=None, password=None):
        self.tl = get_builtin_value("tl")
        self.hostname = self.get_ip_address()
        self.username = self.tl.gnbs[0].cu.oam_ssh_connection_details.username if not username else username
        self.password = self.tl.gnbs[0].cu.oam_ssh_connection_details.password if not password else password

    def get_ip_address(self):
        try:
            if self.tl.enbs:
                return self.tl.enbs[0].oam_ip.v4.split("/")[0]
        except Exception:
            return self.tl.gnbs[0].oam_ip.v4.split("/")[0]

    def start_pcap_logs(self, interface="any", pcap_file="/tmp/test.pcap"):
        logger.info('Start collecting pcap logs {}'.format(pcap_file))
        with gnb_connection(self.hostname,
                            self.username,
                            self.password) as connection:
            status = connection.execute("killall tcpdump")
            logger.debug('start_pcap_logs - killall tcpdump has returned: {}'.format(status))
            connection.send_command("rm -rf {}".format(pcap_file))
            connection.send_command("tcpdump -i {} -w {} -n".format(interface, pcap_file))
            status = connection.execute("ps -ef | grep tcpdump | grep -v grep | grep {}".format(interface))
        logger.debug(status)

    def stop_pcap_logs(self):
        logger.info('Stop collecting pcap logs.')
        with gnb_connection(self.hostname,
                            self.username,
                            self.password) as connection:
            connection.execute("killall tcpdump")

    def download_pcap_file_on_vm(self, remote_pcap_file, file_name, dir_path):
        full_pcap_path = self.get_path_to_pdml_file(file_name, dir_path, extension='pcap')
        with gnb_connection(self.hostname,
                            self.username,
                            self.password) as connection:
            connection.send_command("ls -lthr /tmp")
            logger.console('Download {} to {}'.format(remote_pcap_file, full_pcap_path))
            connection.download_file(remote_path=remote_pcap_file, local_path=full_pcap_path)
            connection.execute("rm -rf {}".format(remote_pcap_file))
        return full_pcap_path

    def get_packet_list(self, remote_pcap_file="/tmp/test.pcap", file_name='test', dir_path="/tmp"):
        pcap_path = self.download_pcap_file_on_vm(remote_pcap_file, file_name, dir_path)
        pdml_path = self.get_path_to_pdml_file(file_name, dir_path)
        self.parse_pcap_to_pdml(pcap_path, pdml_path)
        self.__check_for_empty_file(pdml_path)
        packet_list = self.map_pdml_to_packet_list(pdml_path)
        return packet_list

    def parse_pcap_to_pdml(self, pcap_path, pdml_path):
        tshark_path = self.get_tshark_path()
        tshark_args = '-r {} -Y x2ap -T pdml > {}'.format(pcap_path, pdml_path)
        os.system('{} {}'.format(tshark_path, tshark_args))

    @staticmethod
    def get_path_to_pdml_file(file_name, parent_dir, extension='pdml'):
        pdml_file_name = '{}_{}.{}'.format(file_name, datetime.now().strftime("%d%m%Y_%H%M%S"), extension)
        return os.path.join(parent_dir, pdml_file_name)

    @staticmethod
    def __check_for_empty_file(file_path):
        logger.console('Checking file {}'.format(file_path))
        if os.stat(file_path).st_size == 0:
            raise IOError("File is empty")

    @staticmethod
    def get_tshark_path():
        tshark_location = os.popen('whereis tshark').read()
        tshark_location = tshark_location.split(' ')[1]
        return tshark_location

    @staticmethod
    def map_pdml_to_packet_list(pdml_path):
        packet_list = []
        with open(pdml_path, 'rb') as file_obj:
            for entry in PdmlReader(file_obj=file_obj):
                packet_list.append(entry.packet)
        return packet_list
