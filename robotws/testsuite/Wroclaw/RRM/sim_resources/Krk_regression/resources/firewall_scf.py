# -*- coding: utf-8 -*-

import re
import os
from shutil import copyfile
from moler.util.moler_test import MolerTest
from taf.rfrl.bts.devices.cu.cu_operations import CuOperations
from taf.gnb.oam.coam.cu import cu
from taf.rfrl.utilities import tl_config
from taf.internal.gnb.oam.rap.client.rap.v2.rest import ApiException


class FirewallScf(object):

    def __init__(self):
        self._gnbcu = CuOperations()

    def get_current_scf_from_site(self, local_dir_path, file_name, bts_id=0, du_id=0, timeout=180):
        """
        Get current scf file from gNB.

        :param local_dir_path: Local dir where SCF file will be saved.
        :param file_name: name of file to save.
        :param bts_id: id of BTS
        :param du_id: id of DU
        :param timeout: Timeout for download SCF file.
        :return: None
        """
        credentials = tl_config.get_web_credentials_for_cu(bts_id, 'GNB')
        cu_object = cu()
        cu_object.connect_to(host=credentials['ip'],
                             port='',
                             username=credentials['username'],
                             password=credentials['password'],
                             cu_version="cuoam_19b",
                             secure=True)
        cu_object.get_current_plan_file(path="{}{}".format(local_dir_path, file_name), include_runtime_data=True,
                                        timeout=timeout)
        cu_object.disconnect()

    def use_scf_on_gnb(self, local_path, scf_timeout=1200, sleep_after_commissioning=25, bts_id=0):
        """
        Commission local SCF on gNB.
        :param local_path: local path to SCF file.
        :param scf_timeout: Timeout for commissioning.
        :param sleep_after_commissioning: Sleep after commissioning.
        :param bts_id: Id of BTS.
        :return: None
        """
        MolerTest.info("Perform commissioning with file: '{}'.".format(local_path))
        try:
            MolerTest.info("Try to perform commissioning via API")
            self._gnbcu.perform_cu_commissioning(file_path=local_path)
        except ApiException:
            MolerTest.info("Perform commissioning via GUI with file: '{}'.".format(local_path))
            MolerTest.info("Loading configuration...")
            self._gnbcu.load_cu_configuration_via_GUI(file_path=local_path)
            MolerTest.info("Fixing errors...")
            self._gnbcu.fix_errors_with_uploaded_configuration(True, True, 60, False, False, bts_id)
            MolerTest.info("Activating...")
            self._gnbcu.activate_cu_configuration_via_GUI(plan_name="NEW_PLAN")
        MolerTest.info("Nap after activation.")
        MolerTest.sleep(seconds=sleep_after_commissioning)

    def find_ntp_servers(self, path):
        """
        Find ntp servers in scf xml file..

        :param path: Path to xml file.
        :return: Dict with distName as kay and list of servers as value. If no servers then empty dict.
        """
        return self._find_servers(path=path, match_begin_servers=self._match_begin_ntp_servers)

    def find_dns_servers(self, path):
        """
        Find dns servers in scf xml file..

        :param path: Path to xml file.
        :return: Dict with distName as kay and list of servers as value. If no servers then empty dict.
        """
        return self._find_servers(path=path, match_begin_servers=self._match_begin_dns_servers)

    def replace_ntp_servers(self, path, servers):
        """
        Replace NTP servers in scf xml file.

        :param path: Path to xlm file.
        :param servers: Dict where key is dist name and value is list of IPs
        :return: List of lines with the new content of xml.
        """
        return self._replace_servers(path=path, servers=servers, match_begin_servers=self._match_begin_ntp_servers,
                                     lines_for_servers=self._lines_for_ntp_severs)

    def replace_dns_servers(self, path, servers):
        """
        Replace DNS servers in scf xml file.

        :param path: Path to xlm file.
        :param servers: Dict where key is dist name and value is list of IPs
        :return: List of lines with the new content of xml.
        """
        return self._replace_servers(path=path, servers=servers, match_begin_servers=self._match_begin_dns_servers,
                                     lines_for_servers=self._lines_for_dns_severs)

    def fill_if_empty_ntp(self, path, default_list_servers):
        """
        Add NTP servers in scf xml file for every empty NTP item.

        :param path: Path to xlm file.
        :param default_list_servers: List of IPs
        :return: List of lines with the new content of xml.
        """
        return self._fill_if_empty_server(path=path, lines_for_servers=self._lines_for_ntp_severs,
                                          list_servers=default_list_servers, is_empty_server=self._is_empty_ntp)

    def fill_if_empty_dns(self, path, default_list_servers):
        """
        Add DNS servers in scf xml file for every empty NTP item.

        :param path: Path to xlm file.
        :param default_list_servers: List of IPs
        :return: List of lines with the new content of xml.
        """
        return self._fill_if_empty_server(path=path, lines_for_servers=self._lines_for_dns_severs,
                                          list_servers=default_list_servers, is_empty_server=self._is_empty_dns)

    def save_file(self, path, lines):
        """
        Save list of lines to file.

        :param path: Path to file.
        :param lines: List of lines to save.
        :return: None
        """
        MolerTest.info("saving to file '{}'".format(path))
        with open(path, "w") as fp:
            fp.write('\n'.join(lines))
            fp.write("\n")

    def make_bak(self, path, suffix="_org"):
        """
        Make a bak file for scf file.
        :param path: Path to source file
        :param suffix: Suffix to add to source file name before extension.
        :return: None
        """
        pre_path, ext = os.path.splitext(path)
        new_file_path = "{}{}{}".format(pre_path, suffix, ext)
        copyfile(src=path, dst=new_file_path)
        return new_file_path

    #  <managedObject class="com.nokia.srbts.mnl:NTP" distName="MRBTS-143/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/NTP-1"
    #  version="MNLDU20B_2010_001" operation="create"/>
    _str_empty_ntp1 = r'<managedObject\s+class="com.nokia.srbts.mnl:NTP"\s+distName=' \
                      r'"(?P<DIST_NAME>MRBTS-\d+/MNL-\d+/MNLENT-\d+/SYNC-\d+/CLOCK-\d+/NTP-\d+)"\s+' \
                      r'version="(?P<VERSION>\S+)"\s+operation="create"\s*' \
                      r'(/>|>\s*</managedObject>)'

    _str_empty_ntp2 = \
        r'<managedObject class="com.nokia.srbts.mnl:NTP" distName='"" \
        r'"(?P<DIST_NAME>MRBTS-\d+/MNL-\d+/MNLENT-\d+/SYNC-\d+/CLOCK-\d+/NTP-\d+)"\s+operation="create"' \
        r'\s+version="(?P<VERSION>\S+)"\s*' \
        r'(/>|>\s*</managedObject>)'

    _re_empty_ntps = [re.compile(_str_empty_ntp1), re.compile(_str_empty_ntp2)]

    def _fill_if_empty_server(self, path, lines_for_servers, list_servers, is_empty_server):
        lines = list()
        org_lines = self._load_file(path=path)
        for line in org_lines:
            dist_name, version = is_empty_server(line=line)
            if dist_name:
                lines_to_add = lines_for_servers(dist_name=dist_name, version=version,
                                                 list_servers=list_servers)
                lines.extend(lines_to_add)
            else:
                lines.append(line)
        return lines

    def _is_empty_ntp(self, line):
        for regex in FirewallScf._re_empty_ntps:
            m = re.search(regex, line)
            if m:
                return m.group('DIST_NAME'), m.group('VERSION')
        return None, None

    #  <managedObject class="com.nokia.srbts.mnl:DNS" distName="MRBTS-76018/MNL-1/MNLENT-1/DNS-1"
    #  version="MNLDU20B_2010_001" operation="create"/>
    _str_empty_dns1 = r'<managedObject\s+class="com.nokia.srbts.mnl:DNS"\s+distName=' \
                      r'"(?P<DIST_NAME>MRBTS-\d+/MNL-\d+/MNLENT-\d+/DNS-\d+)"\s+' \
                      r'version="(?P<VERSION>\S+)"\s+operation="create"\s*' \
                      r'(/>|>\s*</managedObject>)'

    _str_empty_dns2 = r'<managedObject class="com.nokia.srbts.mnl:DNS" distName='"" \
                      r'"(?P<DIST_NAME>MRBTS-\d+/MNL-\d+/MNLENT-\d+/DNS-\d+)"\s+operation="create"' \
                      r'\s+version="(?P<VERSION>\S+)"\s*' \
                      r'(/>|>\s*</managedObject>)'

    _re_empty_dnses = [re.compile(_str_empty_dns1), re.compile(_str_empty_dns2)]

    def _is_empty_dns(self, line):
        for regex in FirewallScf._re_empty_dnses:
            m = re.search(regex, line)
            if m:
                return m.group('DIST_NAME'), m.group('VERSION')
        return None, None

    def _replace_servers(self, path, servers, match_begin_servers, lines_for_servers):
        lines = list()
        org_servers = dict()
        org_lines = self._load_file(path=path)
        version = '1'
        for exp_dist_name in servers.keys():
            dist_name = None
            for line in org_lines:
                if dist_name:
                    address = self._match_address(line=line)
                    if address:
                        if dist_name not in org_servers:
                            org_servers[dist_name] = list()
                        org_servers[dist_name].append(address)
                    elif self._is_finish_managed(line=line):
                        lines_to_add = lines_for_servers(dist_name=dist_name, version=version,
                                                         list_servers=servers[dist_name])
                        lines.extend(lines_to_add)
                        dist_name = None
                else:
                    dist_name, version = match_begin_servers(line=line, exp_dist_name=exp_dist_name)
                    if dist_name:
                        org_servers[dist_name] = list()
                    else:
                        lines.append(line)
        return lines

    def _lines_for_ntp_severs(self, dist_name, version, list_servers):
        lines = list()
        lines.append('<managedObject class="com.nokia.srbts.mnl:NTP" distName="{}" version="{}"'
                     ' operation="create">'.format(dist_name, version))
        lines.append("  <list name=\"ntpServerIpAddrList\">")
        for address in list_servers:
            lines.append("    <p>{}</p>".format(address))
        lines.append("  </list>")
        lines.append("</managedObject>")
        return lines

    def _lines_for_dns_severs(self, dist_name, version, list_servers):
        lines = list()
        lines.append('<managedObject class="com.nokia.srbts.mnl:DNS" distName="{}" version="{}"'
                     ' operation="create">'.format(dist_name, version))
        i = 0
        names = ('serverIpAddressPrimary', 'serverIpAddressSecondary', 'serverIpAddressTertiary',
                 'serverIpAddressQuaternary', 'serverIpAddressQuinary', 'serverIpAddressSenary',
                 'serverIpAddressSeptenary', 'serverIpAddressOctonary', 'serverIpAddressNonary',
                 )
        for address in list_servers:
            lines.append("  <p  name=\"{}\">{}</p>".format(names[i], address))
            i += 1
        lines.append("</managedObject>")
        return lines

    def _find_servers(self, path, match_begin_servers):
        servers = dict()
        org_lines = self._load_file(path=path)
        dist_name = None
        tmp_server_list = list()
        for line in org_lines:
            if dist_name:
                address = self._match_address(line=line)
                if address:
                    tmp_server_list.append(address)
                elif self._is_finish_managed(line=line):
                    if len(tmp_server_list) > 0:
                        servers[dist_name] = tmp_server_list
                        tmp_server_list = list()
                    dist_name = None
            else:
                dist_name, version = match_begin_servers(line=line)
        return servers

    def _load_file(self, path):
        lines = list()
        with open(path, "r") as fp:
            org_lines = fp.readlines()
        for line in org_lines:
            line = line.rstrip("\n")
            lines.append(line)
        return lines

    # <p>192.168.1.2</p>
    _re_address = re.compile(r"<p.*>\s*(?P<ADDRESS>\d+\.\d+\.\d+\.\d+)\s*</p>")

    def _match_address(self, line):
        m = re.search(FirewallScf._re_address, line)
        if m:
            return m.group("ADDRESS")
        return None

    _re_finish_managed_object = re.compile(r"</managedObject>")

    def _is_finish_managed(self, line):
        m = re.search(FirewallScf._re_finish_managed_object, line)
        if m:
            return True
        return False

    #  <managedObject class="com.nokia.srbts.mnl:NTP" distName="MRBTS-143/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/NTP-1"
    #  version="MNLDU20B_2010_001" operation="create>
    _str_begin_ntp1 = r'<managedObject\s+class="com.nokia.srbts.mnl:NTP"\s+distName=' \
                      r'"(?P<DIST_NAME>MRBTS-\d+/MNL-\d+/MNLENT-\d+/SYNC-\d+/CLOCK-\d+/NTP-\d+)"\s+' \
                      r'version="(?P<VERSION>\S+)"\s+operation="create">'

    _str_begin_ntp2 = \
        r'<managedObject class="com.nokia.srbts.mnl:NTP" distName='"" \
        r'"(?P<DIST_NAME>MRBTS-\d+/MNL-\d+/MNLENT-\d+/SYNC-\d+/CLOCK-\d+/NTP-\d+)"\s+operation="create"' \
        r'\s+version="(?P<VERSION>\S+)">'

    _re_begin_ntps = [re.compile(_str_begin_ntp1), re.compile(_str_begin_ntp2)]

    def _match_begin_ntp_servers(self, line, exp_dist_name=None):
        for regex in FirewallScf._re_begin_ntps:
            m = re.search(regex, line)
            if m:
                dist_name = m.group("DIST_NAME")
                version = m.group('VERSION')
                if exp_dist_name:
                    if exp_dist_name == dist_name:
                        return dist_name, version
                    else:
                        pass
                else:
                    return dist_name, version
        return None, None

    #  <managedObject class="com.nokia.srbts.mnl:DNS" distName="MRBTS-76018/MNL-1/MNLENT-1/DNS-1"
    #  operation="create" version="MNLCU20B_2010_001">
    _str_begin_dns1 = r'<managedObject\s+class="com.nokia.srbts.mnl:DNS"\s+distName=' \
                      r'"(?P<DIST_NAME>MRBTS-\d+/MNL-\d+/MNLENT-\d+/DNS-\d+)"\s+' \
                      r'version="(?P<VERSION>\S+)"\s+operation="create">'

    _str_begin_dns2 = r'<managedObject class="com.nokia.srbts.mnl:DNS" distName='"" \
                      r'"(?P<DIST_NAME>MRBTS-\d+/MNL-\d+/MNLENT-\d+/DNS-\d+)"\s+operation="create"' \
                      r'\s+version="(?P<VERSION>\S+)">'

    _re_begin_dnses = [re.compile(_str_begin_dns1), re.compile(_str_begin_dns2)]

    def _match_begin_dns_servers(self, line, exp_dist_name=None):
        for regex in FirewallScf._re_begin_dnses:
            m = re.search(regex, line)
            if m:
                dist_name = m.group("DIST_NAME")
                version = m.group('VERSION')
                if exp_dist_name:
                    if exp_dist_name == dist_name:
                        return dist_name, version
                    else:
                        pass
                else:
                    return dist_name, version
        return None, None
