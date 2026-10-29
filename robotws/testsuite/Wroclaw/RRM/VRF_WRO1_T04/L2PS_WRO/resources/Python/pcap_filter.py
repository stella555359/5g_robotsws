"""
:copyright: Nokia Networks
:author: Gall Anonim
:maintainer: Mateusz Bilewicz
:contact: mateusz.bilewicz@nokia.com
:team: MN_RAN_L2_SW_WRO_7_SG
"""

from robot.errors import VariableError
from string import hexdigits


class PcapFilter:
    def __init__(self):
        pass

    def _is_ipv4(self, ip_addr):
        octets = ip_addr.split(".")
        if len(octets) != 4:
            return False

        for octet in octets:
            if not octet.isdigit():
                return False
            if not (0 <= int(octet) <= 255):
                return False

        return True

    def _count_overlap_string(self, string, substring):
        count = 0
        for index in range(len(string) - len(substring) + 1):
            if string[index:len(substring) + index] == substring:
                count += 1
        return count

    def _is_ipv6(self, ip_addr):
        count_double_colon = self._count_overlap_string(ip_addr, "::")
        if not (0 <= count_double_colon <= 1):
            return False

        blocks = ip_addr.split(":")
        if not ((count_double_colon == 0 and len(blocks) == 8) or (count_double_colon == 1 and 3 <= len(blocks) <= 9)):
            return False

        for block in blocks:
            if not (0 <= len(block) <= 4):
                return False
            if not set(block).issubset(hexdigits):
                return False

        return True

    def _get_type_of_ip_addr(self, ip_addr):
        if self._is_ipv4(ip_addr):
            return "ipv4"
        elif self._is_ipv6(ip_addr):
            return "ipv6"
        else:
            return "Invalid"

    def _create_src_filter(self, src_ip):
        type_of_ip_addr = self._get_type_of_ip_addr(src_ip)

        if type_of_ip_addr == "Invalid":
            raise VariableError("Invalid type of ip for ip={}".format(src_ip))
        elif type_of_ip_addr == "ipv4":
            return "ip.src=={}".format(src_ip)
        elif type_of_ip_addr == "ipv6":
            return "ipv6.src=={}".format(src_ip)

    def _create_dst_filter(self, dst_ip):
        type_of_ip_addr = self._get_type_of_ip_addr(dst_ip)

        if type_of_ip_addr == "Invalid":
            raise VariableError("Invalid type of ip for ip={}".format(dst_ip))
        elif type_of_ip_addr == "ipv4":
            return "ip.dst=={}".format(dst_ip)
        elif type_of_ip_addr == "ipv6":
            return "ipv6.dst=={}".format(dst_ip)

    def _prepare_filter(self, src_ip=None, dst_ip=None, src_and_dst_ip=None, logical_operator="or"):
        if logical_operator not in ("and", "or"):
            raise VariableError("Incorrect logical operator. Choose one: \"and\" or \"or\"")

        delimiter = "&&" if logical_operator == "and" else "||"

        filter_string_src = " {} ".format(delimiter).join([self._create_src_filter(ip) for ip in src_ip])
        filter_string_dst = " {} ".format(delimiter).join([self._create_dst_filter(ip) for ip in dst_ip])
        filter_string_src_and_dst = " {} ".format(delimiter).join(["({} && {})".format(
            self._create_src_filter(ip_pair[0]), self._create_dst_filter(ip_pair[1])) for ip_pair in src_and_dst_ip])

        return " {} ".format("&&").join(
            filter(None, [filter_string_src, filter_string_dst, filter_string_src_and_dst]))

    def get_tshark_filter_for_src_and_dst_ip(self, src_ip=None, dst_ip=None, src_and_dst_ip=None,
                                             logical_operator="or"):
        if dst_ip is None:
            dst_ip = []
        if src_ip is None:
            src_ip = []
        if src_and_dst_ip is None:
            src_and_dst_ip = []
        try:
            if isinstance(src_ip, basestring):
                src_ip = [src_ip]
            if isinstance(dst_ip, basestring):
                dst_ip = [dst_ip]
        except NameError:
            if isinstance(src_ip, str):
                src_ip = [src_ip]
            if isinstance(dst_ip, str):
                dst_ip = [dst_ip]

        return self._prepare_filter(src_ip, dst_ip, src_and_dst_ip, logical_operator)

    @staticmethod
    def get_capture_filter_for_host(host=[], sep='||'):
        filter_string = 'host '
        first_ip = True
        for host_ip in host:
            if not first_ip:
                filter_string += " {} ".format(sep)
            filter_string += host_ip
            first_ip = False
        return filter_string
