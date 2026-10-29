"""
:author: Patryk Kostrzewski, Patryk Brodziak
:current version author: Jakub Czekaj, Bartlomiej Trybuch
:contact: jakub.czekaj@nokia.com, bartlomiej.trybuch@nokia.com
"""
import argparse
from ipaddress import ip_address, IPv4Address
import scapy.all as scapy
from robot.api.logger import console
from datetime import datetime
from multiprocessing import Process


class PacketCreator(object):
    """
    Class for packet creating using scapy

    To create packet use:
        create_packet(ip_ver,  protocol, destination, source=None, **kwargs)

    To get created packet use:
        get_packet()

    To send packet go to PacketSender class
    """

    protocols = {
        "ICMP": scapy.ICMP,
        "TCP": scapy.TCP,
        "UDP": scapy.UDP,
        "SCTP": scapy.SCTP,
        "ICMPv6_Echo_Request": scapy.ICMPv6EchoRequest,
        "ICMPv6_Echo_Replay": scapy.ICMPv6EchoReply,
        "ICMPv6_destination_unreachable": scapy.ICMPv6DestUnreach,
        "ICMPv6_packet_too_big": scapy.ICMPv6PacketTooBig,
        "ICMPv6_time_exceeded": scapy.ICMPv6TimeExceeded,
        "ICMPv6_parameter_problem": scapy.ICMPv6ParamProblem,
        "ICMPv6_NDP_TYPE_135": scapy.ICMPv6ND_NS,
        "ICMPv6_NDP_TYPE_136": scapy.ICMPv6ND_NA,
        "ICMPv6_MLDv2_TYPE_130": scapy.ICMPv6MLQuery2,
        "ICMPv6_MLDv2_TYPE_143": scapy.ICMPv6MLReport2

    }
    ip_version = {
        "IPV4": scapy.IP,
        "IPV6": scapy.IPv6
    }

    def __init__(self):
        self.packet = None

    def create_packet(self, ip_ver, protocol, destination_address, source=None,
                      **kwargs):
        """
        Function for packet creation, saves result as self.packet

        :param ip_ver: IPv4/IPv6. use: _get_network_layer() function,
        :param protocol: ICMP/TCP/UDP. use: _get_transport_layer() function,
        :param destination_address: str, destination ip,
        :param source: str, optional source ip,
        :param kwargs: additional arguments for packet creation.
        :return: scapy packet to be sent by PacketSender
        """
        for k, v in list(kwargs.items()):
            if v is None:
                del kwargs[k]
        first_layer = self._get_network_layer(ip_ver, source,
                                              destination_address)
        if protocol:
            second_layer = self._get_transport_layer(protocol, **kwargs)
            self.packet = scapy.Ether() / first_layer / second_layer
        else:
            self.packet = scapy.Ether() / first_layer
        return self.packet

    def get_packet(self):
        assert self.packet is not None, "Create the packet first."
        return self.packet

    @staticmethod
    def get_icmp_code(type_name):
        icmp_types = {
            "Echo_Request": 8,
            "Echo_Reply": 0,
            "Destination_Unreachable": 3,
            "Packet_Too_Big": 4,
            "Time_Exceeded": 11,
            "Parameter_Problem": 12,
            "Incorrect_Type": 1,
            "Timestamp": 13,
            "Address_Mask": 17
        }
        assert type_name in icmp_types.keys(), \
            "ICMP packet type name is not defined."
        return icmp_types[type_name]

    def save_packet_to_pcap(self, pcap_path, how_many=1):
        packet = self.get_packet()
        scapy.wrpcap(pcap_path, [packet] * int(how_many), append=False)

    def _get_network_layer(self, ip, source, destination):
        return self.ip_version[ip](src=source, dst=destination)

    def _get_transport_layer(self, protocol, **kwargs):
        if "type" in kwargs.keys():
            kwargs["type"] = self.get_icmp_code(kwargs["type"])
        if "code" in kwargs.keys():
            kwargs["code"] = int(kwargs["code"])
        if "dport" in kwargs.keys():
            kwargs["dport"] = int(kwargs["dport"])
        if "sport" in kwargs.keys():
            kwargs["sport"] = int(kwargs["sport"])
        if "seq" in kwargs.keys():
            kwargs["seq"] = int(kwargs["seq"])
        if "flags" in kwargs.keys():
            kwargs["flags"] = (kwargs["flags"])
        return self.protocols[protocol](**kwargs)


class PacketSender(object):
    """
    Setup:
    - use this command to set up perimssions:
        sudo setcap cap_net_raw=eip /home/ute/test_repo/bin/python
    - in order to use send_packet_fast method:
        1) install tcpreplay
        2) add suid bit to executable: sudo chmod a+s /usr/bin/tcpreplay

    class for packet sending using scapy
    To create packet go to PacketCreator class
    """

    ROBOT_LIBRARY_SCOPE = 'TEST SUITE'

    @staticmethod
    def send_packets(packet, interval, number_of_packets, interface):
        """
        send packets at layer 2
        :param packet: scapy packet created in PacketCreator
        :param interval: time (in s) between two packets
        :param number_of_packets: number of packets to send
        :param interface: output interface
        :return: None
        """
        assert packet is not None, "Packet is None"
        scapy.sendp(packet,
                    inter=float(interval),
                    count=int(number_of_packets),
                    iface=interface,
                    verbose=False)
        console("Sent {} packets with {} interval.".format(number_of_packets,
                                                           interval))

    @staticmethod
    def fast_send_packets(packet, pps, loop, interface):
        """
        Send packets at layer 2 using tcpreplay for performance
        :param packet: scapy packet created in PacketCreator
        :param pps: packets per second
        :param loop: number of times to process the packet list
        :param interface: output interface
        :return: None
        """
        assert packet is not None, "Packet is None"
        scapy.sendpfast(packet, pps=int(pps), loop=int(loop), iface=interface)
        console("Sent FAST packets with {} loop {}".format(pps, loop))

    def send_packets_parallel(self, udp_packet, tcp_unlock_packet, tcp_packet, icmp_packet, interface):
        """
        Send packets in parallel
        :param udp_packet: udp_packet to be send
        :param tcp_unlock_packet: tcp_unlock_packet to be send
        :param tcp_packet: tcp_packet to be send
        :param icmp_packet: icmp_packet to be send
        :param interface: output interface
        """
        assert udp_packet is not None, "udp_packet is None"
        assert tcp_unlock_packet is not None, "tcp_unlock_packet is None"
        assert tcp_packet is not None, "tcp_packet is None"
        assert icmp_packet is not None, "icmp_packet is None"

        scapy.sendp(tcp_unlock_packet, inter=0.05, count=1, iface=interface, verbose=False)

        processes = []
        processes.append(Process(target=self._package_runner,
                                 kwargs={'ids': 'UDP', 'function': scapy.sendpfast,
                                         'x': udp_packet, 'pps': 10000, 'loop': 100000, 'iface': interface}))
        processes.append(Process(target=self._package_runner,
                                 kwargs={'ids': 'TCP', 'function': scapy.sendpfast,
                                         'x': tcp_packet, 'pps': 15000, 'loop': 150000, 'iface': interface}))
        processes.append(Process(target=self._package_runner,
                                 kwargs={'ids': 'ICMP', 'function': scapy.sendpfast,
                                         'x': icmp_packet, 'pps': 400, 'loop': 4000, 'iface': interface}))

        for proc in processes:
            proc.start()

        for proc in processes:
            proc.join()

    def _package_runner(self, ids, function, **args):
        """
        Helper function to print start and end times of parallel functions.
        :param ids: print name of function
        :param function: Name of function
        :param args: arguments to be passed to function
        """
        console("{} {} start".format(datetime.now(), ids))
        function(**args)
        console("{} {} end".format(datetime.now(), ids))


def create_and_send_packet(ip_ver, protocol, destination_address,
                           source=None, sport=None, dport=None,
                           flags=None, type=None, interval=None,
                           number_of_packets=None, interface=None,
                           pps=None, loop=None):
    """
    Creates and send packets based on passed arguments.
    """
    packet = pc.create_packet(
        ip_ver=ip_ver,
        protocol=protocol,
        destination_address=destination_address,
        source=source,
        sport=sport,
        dport=dport,
        flags=flags,
        type=type
    )
    if args.pps is None:
        ps.send_packets(
            packet=packet,
            interval=interval,
            number_of_packets=number_of_packets,
            interface=interface
        )
    else:
        ps.fast_send_packets(
            packet=packet,
            pps=pps,
            loop=loop,
            interface=interface
        )


def create_and_send_packet_parallel(ip_ver, destination_address, source, interface):
    """
    Creates and sends packets parallel (hard coded for FGCR7304 Feature Test)
    """
    udp_packet = pc.create_packet(
        ip_ver=ip_ver,
        protocol="UDP",
        destination_address=destination_address,
        source=source,
        sport=13001,
        dport=13100,
    )
    tcp_unlock_packet = pc.create_packet(
        ip_ver=ip_ver,
        protocol="TCP",
        destination_address=destination_address,
        source=source,
        sport=55556,
        dport=21,
        flags="S"
    )
    tcp_packet = pc.create_packet(
        ip_ver=ip_ver,
        protocol="TCP",
        destination_address=destination_address,
        source=source,
        sport=55556,
        dport=21,
        flags="A"
    )
    icmp_packet = pc.create_packet(
        ip_ver=ip_ver,
        protocol="ICMP",
        destination_address=destination_address,
        type="Echo_Request"
    )

    ps.send_packets_parallel(
        udp_packet=udp_packet,
        tcp_unlock_packet=tcp_unlock_packet,
        tcp_packet=tcp_packet,
        icmp_packet=icmp_packet,
        interface=interface
    )


if __name__ == "__main__":
    parser = argparse.ArgumentParser()

    parser.add_argument('-interval', help='time( in s) between two packets')
    parser.add_argument('-number_of_packets', help='number of packets to send')
    parser.add_argument('-interface', help='output interface')
    parser.add_argument('-destination_address', help='destination ip')
    parser.add_argument('-protocol', help='ICMP/TCP/UDP', choices=['ICMP', 'TCP', 'UDP'])
    parser.add_argument('-source', help='source ip')
    parser.add_argument('-type', help='icmp packet type', choices=[
        'Echo_Request',
        'Echo_Reply',
        'Destination_Unreachable',
        'Packet_Too_Big',
        'Time_Exceeded',
        'Parameter_Problem',
        'Incorrect_Type',
        'Timestamp',
        'Address_Mask'])
    parser.add_argument('-sport', help='source port')
    parser.add_argument('-dport', help='destination port')
    parser.add_argument('-flags', help='flags to be used')
    parser.add_argument('-pps', help='packets per second')
    parser.add_argument('-loop', help='number of times to process the packet list')
    parser.add_argument('-parallel', action="store_true")

    args = parser.parse_args()

    ip_ver = "IPV4" if type(ip_address(str(args.source))) is IPv4Address else "IPV6"

    pc = PacketCreator()
    ps = PacketSender()

    if args.parallel is True:
        create_and_send_packet_parallel(ip_ver, args.destination_address, args.source, args.interface)
    else:
        create_and_send_packet(ip_ver, args.protocol, args.destination_address, args.source, args.sport, args.dport,
                               args.flags, args.type, args.interval, args.number_of_packets, args.interface, args.pps,
                               args.loop)
