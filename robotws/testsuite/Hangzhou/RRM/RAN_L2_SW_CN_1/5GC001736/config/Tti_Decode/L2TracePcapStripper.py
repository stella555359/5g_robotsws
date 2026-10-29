# -*- coding: utf-8 -*-
import struct


class L2TracePcapStripper():
    global_pcap_header_length = 24
    packet_header_len = 16
    udp_header_len = 8

    def __init__(self, pcap_content):
        self._pcap = pcap_content
        self._pcap.seek(self.global_pcap_header_length)

    def __iter__(self):
        return self

    def next(self):
        header_data = self._pcap.read(self.packet_header_len)
        if not (len(header_data)):
            raise StopIteration
        (packet_header, eth_header, ip_header) = self._read_network_headers(header_data)
        common_headers_length = eth_header.len + ip_header.len + self.udp_header_len
        return self._pcap.read(packet_header.packet_len - common_headers_length)

    def _read_network_headers(self, pcap_packet_header_data):
        packet_header = PcapPacketHeader(pcap_packet_header_data)
        eth_header = EthernetHeader(self._pcap)
        ip_header = IPv4Header(self._pcap) if eth_header.is_ether_type_ipv4() else IPv6Header(self._pcap)
        self._pcap.read(self.udp_header_len)
        return (packet_header, eth_header, ip_header)


class PcapPacketHeader():
    header_format = "IIII"

    def __init__(self, header_data):
        unpacked_data = struct.unpack(self.header_format, header_data)
        self.packet_len = unpacked_data[2]


class EthernetHeader():
    network_order = "!"
    dest_format = "BBBBBB"
    source_format = "BBBBBB"
    ether_type_format = "H"
    header_format = network_order + dest_format + source_format + ether_type_format

    def __init__(self, data):
        self.len = struct.calcsize(self.header_format)
        content = data.read(self.len)
        unpacked_data = struct.unpack(self.header_format, content)
        self.ether_type = unpacked_data[12]

    def is_ether_type_ipv4(self):
        return self.ether_type == 0x0800


class IPv4Header():
    header_format_no_options = ">BBBBIIII"
    length_no_options = struct.calcsize(header_format_no_options)

    def __init__(self, data):
        content = data.read(self.length_no_options)
        unpacked_data = struct.unpack(self.header_format_no_options, content)
        self.len = (unpacked_data[0] & 0xF) * 4  # IHL is in octets
        if self.len > self.length_no_options:
            data.read(self.len - self.length_no_options)


class IPv6Header():
    len = 40

    def __init__(self, data):
        data.read(self.len)
