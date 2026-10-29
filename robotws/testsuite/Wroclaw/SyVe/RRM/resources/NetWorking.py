import subprocess
from testsuite.Wroclaw.SyVe.RRM.resources.Logger import Logger
from testsuite.Wroclaw.SyVe.RRM.resources.TestEnvData import TestEnvData as Env

PORT_OPEN = "443/tcp open"
NMAP_FOR_HTTPS = "nmap -p 443 {}"
ONE_PING_THE_HOST = "ping -c 1 {}"
THREE_PINGS_THE_HOST = "ping -c 3 {}"
IP1 = "192.168.255.1"
IP129 = "192.168.255.129"
SPACE = " "
OFFLINE_RESP_LIST = ["Unreachable", f"{SPACE}0 received"]
ONLINE_RESP = f"{SPACE}0% packet loss"


class NetWorking(object):

    def __init__(self):
        self.gnb_ips = {}
        self.enb_ips = {}

    def get_gnb_mplane_ip(self, gnb_id=0, lmp_ip_if_gnb0=True):
        if lmp_ip_if_gnb0 and gnb_id == 0:
            return Env.GNB_HTTPS_CONNECTION_HOST
        if not self.gnb_ips.get(gnb_id):
            self._set_gnb_mplane_ip(gnb_id)
        return self.gnb_ips.get(gnb_id)

    def is_https_port_open_enb_mplane(self, enb_id=0):
        return self._is_https_port_open(self.get_enb_mplane_ip(enb_id))

    def is_pingable(self, ip):
        return True if "Unreachable" not in self._get_the_host_ping_output(ip) else False

    def get_enb_mplane_ip(self, enb_id=0):
        if not self.enb_ips.get(enb_id):
            self._set_enb_mplane_ip(enb_id)
        return self.enb_ips.get(enb_id)

    def get_local_bts_ip_with_open_https_port(self):
        is_https_open_on_ip1 = self._is_https_port_open(IP1)
        if is_https_open_on_ip1:
            return IP1
        is_https_open_on_ip129 = self._is_https_port_open(IP129)
        assert is_https_open_on_ip1 or is_https_open_on_ip129, \
            "There's no admin port open on both BTS IPs:\n" \
            "nmap {}\n{}\nnmap {}\n{}".format(IP1, self._get_nmap_output(IP1), IP129, self._get_nmap_output(IP129))
        return IP129

    def _set_gnb_mplane_ip(self, gnb_id):
        ipv4 = self.try_to_read_gnb_ipv4(gnb_id)
        ipv6 = self.try_to_read_gnb_ipv6(gnb_id)
        assert ipv4 or ipv6, "There is no IPv4 nor IPv6 address found for gNB"
        self.gnb_ips[gnb_id] = ipv4 if ipv4 else ipv6

    def _set_enb_mplane_ip(self, enb_id):
        ipv4 = self._try_to_read_enb_ipv4(enb_id)
        ipv6 = self._try_to_read_enb_ipv6(enb_id)
        assert ipv4 or ipv6, "There is no IPv4 nor IPv6 address found for eNB"
        self.enb_ips[enb_id] = ipv4 if ipv4 else ipv6

    @staticmethod
    def try_to_read_gnb_ipv4(gnb_id):
        try:
            return Env.GNBS[gnb_id].cu.f1m.v4
        except AttributeError:
            return Env.GNBS[gnb_id].cu.backhaul_site_oam_ip \
                if isinstance(Env.GNBS[gnb_id].cu.backhaul_site_oam_ip, str) \
                else Env.GNBS[gnb_id].cu.backhaul_site_oam_ip.v4
        except IndexError:
            NetWorking._log_warning(gnb_id)
        return None

    @staticmethod
    def try_to_read_gnb_ipv6(gnb_id):
        try:
            return Env.GNBS[gnb_id].cu.f1m.v6
        except AttributeError:
            # assume that only v4 can be string (legacy). IPs should be declared with v4/v6
            return None if isinstance(Env.GNBS[gnb_id].cu.backhaul_site_oam_ip, str) \
                else Env.GNBS[gnb_id].cu.backhaul_site_oam_ip.v6
        except IndexError:
            NetWorking._log_warning(gnb_id)
        return None

    @staticmethod
    def _try_to_read_enb_ipv4(enb_id):
        try:
            return Env.ENBS[enb_id].oam_ip.v4
        except IndexError:
            NetWorking._log_warning(enb_id)
        return None

    @staticmethod
    def _try_to_read_enb_ipv6(enb_id):
        try:
            return Env.ENBS[enb_id].oam_ip.v6
        except IndexError:
            NetWorking._log_warning(enb_id)
        return None

    @staticmethod
    def _log_warning(bts_id):
        Logger.warning("There is no BTS for id={} in the TL init file".format(bts_id))

    @staticmethod
    def _is_https_port_open(ip):
        return True if PORT_OPEN in NetWorking._get_nmap_output(ip) else False

    @staticmethod
    def _get_nmap_output(ip):
        subprocess_nmap_cmd_list = NMAP_FOR_HTTPS.format(ip).split()
        return subprocess.check_output(subprocess_nmap_cmd_list).decode()

    @staticmethod
    def _get_the_host_ping_output(ip):
        subprocess_ping_cmd_list = ONE_PING_THE_HOST.format(ip).split()
        return subprocess.check_output(subprocess_ping_cmd_list).decode()
