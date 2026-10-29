import re
from subprocess import check_output
from traceback import format_exception
from robot.libraries.BuiltIn import BuiltIn
from testsuite.Oulu.TrunkEng.Common.Python.Interfaces.Logger import error, info
from testsuite.Oulu.TrunkEng.Common.Python.Resources.exceptions import (
    ClassNotFoundFromScfFile, ElementNotFoundFromScfFile, EnvironmentIssue)


class RFS:

    def __init__(self):
        self.bts = BuiltIn().get_library_instance("BTS")
        self.scf = BuiltIn().get_library_instance("SCF")
        self.cells = BuiltIn().get_library_instance("CELLS")

    def find_master_mplane_ip(self):
        print("Finding master mplane IP")
        object_distname = self.scf.get_distname_based_on_class("com.nokia.srbts.tnl:IPADDRESSV4")[0]
        if object_distname:
            master_mplane_ip = self.scf.get_value_from_scf(dist_name=object_distname, p_name="localIpAddr")
            if not master_mplane_ip:
                error("Could not find element localIpAddr from scf file.")
                raise ElementNotFoundFromScfFile("Class from where element localIpAddr was searched: "
                                                 "com.nokia.srbts.tnl:IPADDRESSV4")
            return master_mplane_ip
        else:
            error("Could not find class com.nokia.srbts.tnl:IPADDRESSV4 from scf file.")
            raise ClassNotFoundFromScfFile("Class com.nokia.srbts.tnl:IPADDRESSV4 doesn't exist in SCF file")

    @staticmethod
    def find_master_vm_ip():
        master_vm_ip = ""
        output = check_output(r"/sbin/ifconfig eth0 | grep 'inet' | grep -v 'inet6'", shell=True)
        pattern = re.compile(r".*inet\s+(?P<ip>\d+\.\d+\.\d+\.\d+)\s+netmask.*")
        match = pattern.match(str(output))
        if match:
            master_vm_ip = str(match.group("ip"))
        else:
            error("Could not find master VM IP from RFS")
        return master_vm_ip

    @staticmethod
    def _get_gnb_mplane_ip(unit_obj, ip=""):
        """
        Get mplane IP from GNB object. If ip is given and there are multiple smods, return the other mplane IP.
        """
        if unit_obj.cu.backhaul_site_oam_ip:
            if isinstance(unit_obj.cu.backhaul_site_oam_ip, str):
                return unit_obj.cu.backhaul_site_oam_ip
            else:
                return RFS._safe_split(unit_obj.cu.backhaul_site_oam_ip.v4, "/")[0]
        return None

    def find_all_mplane_ips(self):
        all_mplane_ips = []
        try:
            if self.bts.tl.gnbs:
                for unit_obj in self.bts.tl.gnbs:
                    all_mplane_ips.append(self._get_gnb_mplane_ip(unit_obj))
                    print(all_mplane_ips)
            if self.bts.tl.enbs:
                for unit_obj in self.bts.tl.enbs:
                    if unit_obj.oam_ip:
                        all_mplane_ips.append(RFS._safe_split(unit_obj.oam_ip.v4, "/")[0])
                        print(all_mplane_ips)
                    else:
                        info("No oam_ip found from enb object")
        except (AttributeError, TypeError) as e:
            error(f"Could not find all mplane IPs from tl init-file. Error: {e.__class__.__name__}{e}\n"
                  f"{''.join(format_exception(type(e), e, e.__traceback__))}")
            raise EnvironmentIssue
        return all_mplane_ips

    def find_all_vm_ips(self):
        all_vm_ips = []
        for unit_obj in self.bts.tl.test_pcs:
            # tuple of ip, password
            all_vm_ips.append((RFS._safe_split(unit_obj.default_ssh_connection_details.addr, "/")[0],
                              unit_obj.default_ssh_connection_details.password))
        return all_vm_ips

    def _find_remote_bts_ip_from_init(self, ip):
        try:
            if self.bts.tl.gnbs:
                for unit_obj in self.bts.tl.gnbs:
                    if (unit_obj.dus[0].airscale.common_units[0].lmp_connection.addr != "192.168.255.7" and
                            (unit_obj.dus[0].airscale.common_units[0].lmp_connection.addr != "192.168.255.119")):
                        remote_ipv4 = self._get_gnb_mplane_ip(unit_obj, ip)
                        if remote_ipv4 != ip:
                            return remote_ipv4
            if self.bts.tl.enbs:
                for unit_obj in self.bts.tl.enbs:
                    if (unit_obj.system_module.common_units[0].lmp_connection.addr != "192.168.255.7" and
                            unit_obj.system_module.common_units[0].lmp_connection.addr != "192.168.255.119"):
                        remote_ipv4 = RFS._safe_split(unit_obj.oam_ip.v4, "/")[0] if unit_obj.oam_ip else None
                        if remote_ipv4 != ip:
                            info(f"Other mplane IP: {remote_ipv4}")
                            return remote_ipv4
            error("Could not get the Other mplane IP")
            return None
        except (AttributeError, TypeError) as e:
            error(f"Could not find LMP IP from tl init-file. Error: {e.__class__.__name__}{e}\n"
                  f"{''.join(format_exception(type(e), e, e.__traceback__))}")
            raise EnvironmentIssue

    def _find_remote_vm_ip_from_init(self, ip):
        try:
            if self.bts.tl.test_pcs:
                for test_pc in self.bts.tl.test_pcs:
                    if (test_pc.connections[0].device.lmp_connection.addr != "192.168.255.7" and
                            test_pc.connections[0].device.lmp_connection.addr != "192.168.255.119"):
                        remote_vm_ip = RFS._safe_split(
                            test_pc.default_ssh_connection_details.addr, "/")[0]
                        if remote_vm_ip != ip:
                            remote_vm_password = test_pc.default_ssh_connection_details.password
                            return [remote_vm_ip, remote_vm_password]
            else:
                error("No tl.test_pcs in init file")
                return None
        except (AttributeError, TypeError) as e:
            error(f"Could not find VM IP from tl init-file. Error: {e.__class__.__name__}{e}\n"
                  f"{''.join(format_exception(type(e), e, e.__traceback__))}")
            raise EnvironmentIssue

    @staticmethod
    def _safe_split(value, sep):
        """Safely split values that may be None; returns list from splitting str(value)."""
        if value is None:
            return [""]
        return str(value).split(sep)

    def find_other_bts_mplane_ip(self):
        master_mplane = self.find_master_mplane_ip()
        all_mplane_ips = self.find_all_mplane_ips()
        if len(all_mplane_ips) == 2:
            return all_mplane_ips[0] if master_mplane == all_mplane_ips[1] else all_mplane_ips[1]
        elif len(all_mplane_ips) == 3:
            info("There are three mplane IPs on RFS environment. Checking LMP IP")
            info(f"Master mplane IP: {master_mplane}")
            return self._find_remote_bts_ip_from_init(master_mplane)
        else:
            error("There are more than two mplane IPs on RFS environment. Take contact to script developer")
            return None

    def find_remote_vm_ip(self):
        master_vm_ip = self.find_master_vm_ip()
        all_vm_ips = self.find_all_vm_ips()
        if len(all_vm_ips) == 2:
            return all_vm_ips[0] if master_vm_ip in all_vm_ips[1] else all_vm_ips[1]
        elif len(all_vm_ips) == 3:
            info("There are three VM IPs on RFS environment. Checking LMP IP")
            info(f"Master VM IP: {master_vm_ip}")
            return self._find_remote_vm_ip_from_init(master_vm_ip)
        else:
            error("There are more than two or three VM IPs on RFS environment. Take contact to script developer")
            return None

    @staticmethod
    def set_rfs_value_if_not_set(value, default_value):
        """Set RFS variable to default_value if it is not set yet."""
        variable_value = BuiltIn().get_variable_value(f"${{{value}}}")
        if isinstance(variable_value, str) and value == "RFS":
            if variable_value.lower() == "true":
                print("RFS is given as true string, change it to boolean True")
                BuiltIn().set_suite_variable("${RFS}", "${True}")
                variable_value = True
            elif variable_value.lower() == "false":
                print("RFS is given as false string, change it to boolean False")
                BuiltIn().set_suite_variable("${RFS}", "${False}")
                variable_value = False
        return variable_value if variable_value else default_value

    def check_other_bts_cells(self):
        cells_enabled = {"All_cells": {"operationalState": "enabled",
                                       "administrativeState": "unlocked"}}
        self.cells.check_cell_states(expected_states=cells_enabled, admin_connection="remote")
