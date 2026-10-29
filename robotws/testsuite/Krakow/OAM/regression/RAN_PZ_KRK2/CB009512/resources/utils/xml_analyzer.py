# testsuite/Wroclaw/OAM/VRF_WRO3_T04/common_resources/pcap_analysis/xml_pcap_utils.py

import xml.etree.ElementTree as ET


class XMLPcapAnalyzer(object):
    """Library for analyzing PCAP converted to XML"""
    CLIENT_HELLO = '1'

    def __init__(self):
        self.root = None

    def get_all_client_hello_packets(self):
        """Get packets with Client Hello message"""
        for idx, packet in enumerate(self.root.findall('packet')):
            for handshake_type in packet.findall('.//*[@name="tls.handshake.type"]'):
                if handshake_type.get('show') == self.CLIENT_HELLO:
                    yield Packet(packet, idx)

    def get_all_packets(self):
        """Get all packets from pcap"""
        for idx, packet in enumerate(self.root.findall('packet')):
            yield Packet(packet, idx)

    def get_packet_by_frame_number(self, frame_number):
        for packet in self.get_all_packets():
            if packet.frame_number == frame_number:
                return packet

    def get_packet_by_index(self, packet_idx):
        """Get nth packet from pcap"""
        for idx, packet in enumerate(self.root.findall('packet')):
            if idx == packet_idx:
                return Packet(packet, idx)

    def load_xml_file(self, xml_filepath):
        """
        Method for initializing instance with path to XML file
        (it cannot be done in constructor due to RobotFramework limitations).
        @param xml_filepath:    XML file path
        @type xml_filepath:     string
        """
        self.root = ET.parse(xml_filepath).getroot()


class Packet:
    """
    Parser for XML packets.
    Class fields contain common packet's attributes. Feel free to add more in similar way.
    """

    def __init__(self, packet, packet_idx):
        """
        @param packet:       XML Element with tag "packet"
        @param packet_idx:   Index of packet object in list of all packets in XML file
        """
        self.idx = packet_idx
        self.frame_number = packet.find('proto').find('field').get('show')
        self.description = self._get_desc(packet)
        self.handshake_type = self._get_handshake_type(packet)
        self.content_type = self._get_content_type(packet)
        self.cipher_suites = self._get_cipher_suites(packet)

    def __repr__(self):
        return 'PACKET {}\nFrame number: {}\nPacket info: {}\n\n'.format(self.idx, self.frame_number, self.description)

    @staticmethod
    def _get_cipher_suites(packet):
        return [p.get('show') for p in packet.findall('.//*[@name="tls.handshake.ciphersuite"]')]

    @staticmethod
    def _get_content_type(packet):
        fields_list = packet.findall('.//*[@name="tls.record.content_type"]') + \
            packet.findall('.//*[@name="tls.record.opaque_type"]')
        return [p.get('show') for p in fields_list]

    @staticmethod
    def _get_desc(packet):
        return [p.get('showname')
                for p in packet.find('.//proto[@name="tls"]').findall('.//field[@name="tls.record"]')]

    @staticmethod
    def _get_handshake_type(packet):
        return [p.get('show') for p in packet.findall('.//*[@name="tls.handshake.type"]')]
