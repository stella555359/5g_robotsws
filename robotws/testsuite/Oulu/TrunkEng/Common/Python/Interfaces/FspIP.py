"""
:author:  Essi Passoja
:contact: I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com
"""

from robot.libraries.BuiltIn import BuiltIn
from testsuite.Oulu.TrunkEng.Common.Python.Interfaces.Logger import info, warning, error
from testsuite.Oulu.TrunkEng.Common.Python.Resources.exceptions import TestSettingsError, ScriptIssue


class FspIP(object):
    def __init__(self):
        self.admin = BuiltIn().get_library_instance("ADMIN")
        self.bts = BuiltIn().get_library_instance("BTS")
        self.logger = BuiltIn().get_library_instance("LOG")
        self.ssh = BuiltIn().get_library_instance("SSH")

    def get_side_of_bts_in_rfs_environment(self, smod_ssh=None):
        """
        Get the side of the BTS in RFS environment. Side can be right or left. This is determined by checking the RFS
        domain id. If domain id is 2, then the side is right, otherwise the side is left. This function is used in
        get_ip_of_selected_fsp function to determine the IP of the FSP based on the side of the BTS in RFS environment.

        :param smod_ssh: SSH library instance to use for sending command to get RFS domain id. This is needed because
                         the SSH connection settings can be different in RFS environments and the connection needs to be
                         made to the correct IP based on the RFS settings. If not given, default IP is used.
        """
        side = "left"
        ip = "192.168.255.129"
        if BuiltIn().get_variable_value("${DEFAULT_ADMIN_IP}"):
            ip = BuiltIn().get_variable_value("${DEFAULT_ADMIN_IP}")
        self.logger.debug("RFS is used. FSP IP will be determined based on the RFS settings.")
        if not smod_ssh or not self.ssh.check_if_pexpect_object_is_alive(smod_ssh):
            self.logger.debug("No smod_ssh given or given SSH library instance is not alive. ")
            remote_mplane_ip = BuiltIn().get_variable_value("${OTHER_BTS_MPLANE}")
            if BuiltIn().get_variable_value("${MASTER}") == "Other":
                ip = remote_mplane_ip
            smod_ssh = self.ssh.ssh_connection_to_smod(name_for_log=f"rfs_get_side", ip_to_connect=ip,
                                                       print_to_eventlog=True, raise_error=True)
        command = "ddal -s ddal_sysinfo_module_get_domain_id 0"
        output = self.ssh.send_command_to_smod_by_ssh(command, enb_ssh=smod_ssh, return_output=True, ssh_timeout=60,
                                                      print_to_eventlog=False, raise_error=False, disconnect_ssh=False)
        if output:
            if "dimd=2" in output or "dmid=2" in output:
                self.logger.debug("RFS domain id is 2, so the side is right.")
                side = "right"
            else:
                self.logger.debug("RFS domain id is not 2, so the side is left.")
        else:
            warning(f"No output from SSH to {ip}. Could not determine BTS domain id in RFS environment. Assuming the "
                    f"side is left.")
        return side

    def get_ip_of_selected_fsp(self, fsp, selected_soc="K2A", ipv6=False, smod_ssh=None):
        """
        Get IP of selected FSP (when connecting from BTS).

        :param str fsp: If BBMOD, you can use self.bts.bbmods to choose the BBMOD.
        :param str selected_soc: If K2A given when unit is not ABIA, changed to the unit's primary SoC.
                                 Can be K2A, K2B, K2C, K2D, SNF, LOKI#A, LOKI#B, LFA, LFB, LUNUM, Thor, Marlin, Magni.
        :param bool ipv6: (Optional) Assumes IPv4 is in use if not given.
        :param smod_ssh: (Optional) SSH library instance to use for sending command to get RFS domain id.
        :return str: Returns FSPs IP address.
        """
        side = "right" if self.bts.bts_side_is_right else "left"
        if BuiltIn().get_variable_value("${RFS}"):
            side = self.get_side_of_bts_in_rfs_environment(smod_ssh=smod_ssh)
        position = fsp[-1]
        if "FSPD" in fsp:
            return "192.168.253.18"
        elif "FBB" in fsp:
            return "192.168.253.19" if "1" in fsp else "192.168.253.20"
        elif "ABIA" in fsp:
            return self._get_ip_of_abia(selected_soc, side, ipv6, abia=position)
        elif any(i for i in ('ABIC', "ABIN", "ABIO", "ABIP", "ABIQ", "ABIL") if i in fsp):
            if selected_soc == "K2A" and any(i for i in ("ABIN", "ABIO") if i in fsp):
                selected_soc = "SNF"
            elif selected_soc == "K2A" and "ABIC" in fsp:
                selected_soc = "LFA"
            elif selected_soc == "K2A" and any(i for i in ("ABIP", "ABIQ") if i in fsp):
                selected_soc = "Marlin"
            elif selected_soc == "K2A" and "ABIL" in fsp:
                selected_soc = "XEONA"
            self.logger.debug(f"Changed SoC to {selected_soc} for unit {fsp}, when searching for FSP IP.")
            return self._get_ip_of_selected_soc(fsp, position, side, selected_soc)
        else:
            error(f"Unknown FSP '{fsp}'. No support for this BBMOD. Take contact to script development.")
            raise TestSettingsError(f"Unsupported FSP '{fsp}'.")

    def _get_ip_of_abia(self, selected_soc, side, ipv6, abia):
        """
        Abia can get values 1, 2, 3
        Side is 'right' or 'left'
        """
        if ipv6:
            s = "2" if side == "right" else "1"
            ip = "fd5f:4268:2387:a8e::3:{}{}3d".format(s, int(abia) + 1)
        else:
            start = 32 if side == "right" else 16
            ip = "192.168.253.{}".format(start + int(abia)*4)
        if selected_soc == "K2A":
            return ip
        elif selected_soc in ('K2B', 'K2C', 'K2D'):
            return self._get_ip_of_other_keplers(selected_soc, ip, ipv6)
        else:
            error("Unknown K2 '{}'. Check your test settings.".format(selected_soc))
            raise TestSettingsError("Unknown K2 '{}'. Check your test settings.".format(selected_soc))

    @staticmethod
    def _get_ip_of_other_keplers(selected_soc, ip, ipv6):
        """
        For K2B, K2C, K2D, supports ipv4 and ipv6
        """
        if ipv6:
            parts = FspIP._safe_split(ip, ':')
            last_part = int(parts[-1], 16)
            if selected_soc == "K2B":
                parts[-1] = hex(last_part + 16)[2:].zfill(4)
            elif selected_soc == "K2C":
                parts[-1] = hex(last_part + 32)[2:].zfill(4)
            elif selected_soc == "K2D":
                parts[-1] = hex(last_part + 48)[2:].zfill(4)
            return ':'.join(parts)
        else:
            parts = FspIP._safe_split(ip, '.')
            if selected_soc == "K2B":
                parts[3] = str(int(parts[3]) + 1)
            elif selected_soc == "K2C":
                parts[3] = str(int(parts[3]) + 2)
            elif selected_soc == "K2D":
                parts[3] = str(int(parts[3]) + 3)
            return '.'.join(parts)

    def _get_ip_of_selected_soc(self, fsp, position, side, selected_soc):
        last_digits = self._get_last_digits_of_ip_for_selected_soc(selected_soc)
        if position not in ("1", "2", "3"):
            error(f"Unknown FSP '{fsp}'. Take contact to script developer.")
            raise ScriptIssue(f"Unknown FSP '{fsp}'. Take contact to script developer.")
        s = "1" if (side == "right" or "." in fsp) else "0"
        return f"fd5f:4268:2387:a881:0040:43ff:fe80:{s}{position}{last_digits}"

    @staticmethod
    def _get_last_digits_of_ip_for_selected_soc(selected_soc):
        if selected_soc == "SNF" or selected_soc == "Marlin" or selected_soc == "XEONA":
            return "01"
        elif selected_soc == 'LOKI#A' or selected_soc == 'Thor' or selected_soc == "Magni":
            return "06"
        elif selected_soc == 'LOKI#B':
            return "16"
        elif selected_soc == "LFA":
            return "0b"
        elif selected_soc == "LFB":
            return "16"
        elif selected_soc == 'LUNUM' or selected_soc == "LONER":
            return "26"
        elif selected_soc == "XEONB":
            return "21"
        else:
            error(f"Unknown SOC '{selected_soc}' for the chosen unit. Check your test environment settings.")
            raise TestSettingsError(f"Unknown SOC '{selected_soc}' for the chosen unit. Check your test environment "
                                    "settings.")

    @staticmethod
    def _safe_split(value, sep):
        """Safely split values that may be None; returns list from splitting str(value)."""
        if value is None:
            return [""]
        return str(value).split(sep)
