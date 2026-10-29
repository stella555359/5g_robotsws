import json
import re
import ipaddress
import paramiko
import robot.api.logger as logger
from taf.sbts.oam.coam.admin import admin as coam_admin


# IMPORTANT:
# Robot library name must match the class name
class CB007821_functions:

    # --------------------------------------------------------
    # Robot Keyword Mappings (Public Keywords Robot Uses)
    # --------------------------------------------------------

    def get_bts_info(self, bts_id, option, param_name, dhcp_type):
        """Robot Keyword: Get BTS Info"""
        return self._get_BTS_info(bts_id, option, param_name, dhcp_type)

    def get_regex(self, param_name):
        """Robot Keyword: Get Regex"""
        return self._get_regex(param_name)

    def get_regex_matches(self, lines, regex):
        """Robot Keyword: Get Regex Matches"""
        return self._get_regex_matches(lines, regex)

    def join_output(self, output):
        """Robot Keyword: Join Output"""
        return ''.join(output)

    def check_if_in_range(self, output, dhcp_range):
        """Robot Keyword: Check If In Range"""
        return self._check_if_in_range(output, dhcp_range)

    def ping_r_us(self, rus_ips, ip):
        """Robot Keyword: Ping R Us"""
        return self._ping_RUs(rus_ips, ip)

    # --------------------------------------------------------
    # INTERNAL FUNCTIONS (not exposed directly as keywords)
    # --------------------------------------------------------

    @staticmethod
    def _get_regex(param_name: str) -> str:
        with open(functions_path, "r") as f:
            data = json.load(f)
            return data["Regex"][param_name]

    @staticmethod
    def _get_regex_matches(lines, regex):
        return bool([re.findall(regex, str(line)) for line in lines])

    @staticmethod
    def _get_BTS_info(bts_id, option, param_name, dhcp_type):
        with open(functions_path, "r") as f:
            data = json.load(f)
            bts_id = str(bts_id)
            dhcp_type = str(dhcp_type)
            return data["BTS"][bts_id][dhcp_type][option][param_name]

    def _check_if_in_range(self, output, dhcp_range):
        if output is None:
            return []

        validated_ip = []
        start_ip = ipaddress.IPv4Address(dhcp_range[0])
        end_ip = ipaddress.IPv4Address(dhcp_range[1])

        ip_list = re.findall(r"\b(?:\d{1,3}\.){3}\d{1,3}\b", str(output))

        for ip in ip_list:
            if ip != "0.0.0.0" and start_ip <= ipaddress.IPv4Address(ip) <= end_ip:
                logger.info(
                    f"{ip} is confirmed inside DHCP range",
                    html=True,
                    also_console=True
                )
                validated_ip.append(ip)

        return validated_ip

    @staticmethod
    def execute_command_and_read_output(cmd: str, ip: str):
        client = paramiko.SSHClient()
        client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        client.load_system_host_keys()
        client.connect(ip, username="toor4nsn", password="oZPS0POrRieRtu")

        _, stdout, _ = client.exec_command(cmd)
        output = stdout.readlines()
        client.close()
        return output

    def _ping_RUs(self, rus_ips, ip):
        results = []

        for ru_ip in rus_ips:
            cmd = (
                f"lxc-attach --set-var COLUMNS=250 -n 0x3018 -- "
                f"ping -c 1 {ru_ip}"
            )
            result = self.execute_command_and_read_output(cmd, ip)

            if "1 packets transmitted, 1 received" in str(result):
                results.append(True)

        return all(results)
