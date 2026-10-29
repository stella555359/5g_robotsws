"""
CommissioningFileModifier.py v1.0
:author:  Terhi Talvitie
:contact: I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com
"""


import re
import os
import xml.etree.ElementTree as etree
import json
from traceback import format_exception
from robot.libraries.BuiltIn import BuiltIn
from testsuite.Oulu.TrunkEng.Common.Python.Interfaces.Logger import info, error
from testsuite.Oulu.TrunkEng.Common.Python.Resources.exceptions import (ScriptIssue, EnvironmentIssue, InvalidUserInput)


class CommissioningFileModifier(object):
    """
    This class is used to update IP information to commissioning file/json file.
    IPs are got from init file of cloud environment and updated to user given commissioning file.

    NOTE that this CommissioningFileModifier class is not called in common_resources.robot.
    """
    def __init__(self):
        self.logger = BuiltIn().get_library_instance("LOG")
        self.get_from_admin = BuiltIn().get_library_instance("GET_FROM_ADMIN")
        self.bts = BuiltIn().get_library_instance("BTS")
        self.commissioning_file_path = ""
        self.get_commissioning_file()
        self.ips_in_cloud_environment = {}
        self.ips_in_given_commissioning_file = {}
        self.scf = BuiltIn().get_library_instance("SCF")

    def get_commissioning_file(self):
        """Get path to commissioning file given by user."""
        if "${COMMISSIONING_FILE}" in BuiltIn().get_variables():
            self.commissioning_file_path = BuiltIn().get_variable_value("${COMMISSIONING_FILE}")
        else:
            error("There is no commissioning file path given by user. Add path to file to ${COMMISSIONING_FILE}"
                  " suite variable")
            raise InvalidUserInput
        if ".xml" in self.commissioning_file_path or ".json" in self.commissioning_file_path:
            self.verify_path(self.commissioning_file_path)
        else:
            error("Given commissioning file is not XML nor JSON file. Please give path to XML or JSON file.")
            raise InvalidUserInput

    def __exit__(self, exc_type, exc_value, traceback):
        if exc_type:
            return False
        return True

    def get_commifile_path(self):
        """Return path to commissioning file."""
        return self.commissioning_file_path

    def verify_path(self, path_to_verify):
        """
        Verify if given path exists and is a file.

        :param str path_to_verify: Path to verify for example /home/ute/config/TLVD/TAF/__init__.py
        """
        self.logger.debug(f"Verifying path: {path_to_verify}")
        if not os.path.exists(path_to_verify):
            error(f"Path does not exist: {path_to_verify}")
            raise ScriptIssue
        if not os.path.isfile(path_to_verify):
            error(f"Path is not a file: {path_to_verify}")
            raise ScriptIssue

    def get_ips_from_cloud_configuration(self):
        try:
            parameters = {
                "mme_ipv6": "",
                "mme_ip": "",
                "ntp_server": "",
                "ntp_server_ipv6": "",
                "top_ip": "",
                "trans_def_gw": "",
                "trans_def_gw_ipv6": "",
                "trs_ip": "",
                "trs_ipv6": "",
                "bts_id": "",
            }
            if not self.bts:
                self.bts = BuiltIn().get_library_instance("BTS")
            if self.bts.tl.core:
                if self.bts.tl.core.four_g:
                    if self.bts.tl.core.four_g.mme and self.bts.tl.core.four_g.mme.s1:
                        if self.bts.tl.core.four_g.mme.s1.v4:
                            parameters["mme_ip"] = self.bts.tl.core.four_g.mme.s1.v4
                        if self.bts.tl.core.four_g.mme.s1.v6:
                            parameters["mme_ipv6"] = self.bts.tl.core.four_g.mme.s1.v6
                    if self.bts.tl.core.four_g.ntp:
                        if self.bts.tl.core.four_g.ntp.v4:
                            parameters["ntp_server"] = self.bts.tl.core.four_g.ntp.v4
                        if self.bts.tl.core.four_g.ntp.v6:
                            parameters["ntp_server_ipv6"] = self.bts.tl.core.four_g.ntp.v6
            if self.bts.tl.enbs:
                for unit_obj in self.bts.tl.enbs:
                    if unit_obj.oam_ip:
                        if unit_obj.oam_ip.v4:
                            parameters["trs_ip"] = unit_obj.oam_ip.v4.split("/")[0]
                        if unit_obj.oam_ip.v6:
                            parameters["trs_ipv6"] = unit_obj.oam_ip.v6.split("/")[0]
                        if unit_obj.oam_ip.routing_v4.gateway:
                            parameters["trans_def_gw"] = unit_obj.oam_ip.routing_v4.gateway
                        if unit_obj.oam_ip.routing_v6.gateway:
                            parameters["trans_def_gw_ipv6"] = unit_obj.oam_ip.routing_v6.gateway
                    else:
                        error("No oam_ip found from enb object")
                        raise EnvironmentIssue
                    if unit_obj.global_bts_id:
                        parameters["bts_id"] = unit_obj.global_bts_id
                    if hasattr(unit_obj.system_module, "common_units") and unit_obj.system_module.common_units:
                        for smod in unit_obj.system_module.common_units:
                            if smod.sync_input.splane_ip_address:
                                parameters["top_ip"] = smod.sync_input.splane_ip_address
                    # at least ASOE has sometimes core_units instead of common_units
                    if hasattr(unit_obj.system_module, "core_units") and unit_obj.system_module.core_units:
                        for smod in unit_obj.system_module.core_units:
                            if smod.sync_input.splane_ip_address:
                                parameters["top_ip"] = smod.sync_input.splane_ip_address
            if not list(filter(None, list(parameters.values()))):
                error("Cannot parse information of UTE cloud environment. Check content of init file and contact script"
                      " developers.")
                raise EnvironmentIssue
            else:
                self.ips_in_cloud_environment = dict(parameters)
                info(f"Information parsed from UTE cloud init file: {self.ips_in_cloud_environment}")
        except (TypeError, ValueError, IndexError, KeyError, OSError) as ex:
            error(f"Problems while trying to read environment information from ute cloud ini file. "
                  f"{ex.__class__.__name__}:{ex} was raised.")
            info(f"{''.join(format_exception(type(ex), ex, ex.__traceback__))}")
            if "No space left on device" in str(ex):
                self.logger.command_via_commandline("df -h")
                BuiltIn().fatal_error("No space left on device. Stopping execution of the suite.")
            raise EnvironmentIssue(f"Problems while trying to read environment information from ute cloud ini file.")
        return parameters

    def check_if_ipv4_or_ipv6_address(self, ip_address):
        """
        Check if given IP is in IPv4 or IPv6 format.

        :param str ip_address: IP address to check.
        """
        return_text = ""
        dot_count = ip_address.count('.')
        colon_count = ip_address.count(':')
        if not ip_address:
            self.logger.debug("IP address is not get.")
        elif dot_count == 0 and colon_count > 2:
            return_text = "ipv6"
        elif dot_count == 0 and colon_count == 2:  # ::
            return_text = "empty_ipv6"
        elif dot_count == 3 and colon_count == 0 and ip_address.count('0') == 4:  # 0.0.0.0
            return_text = "empty_ipv4"
        elif dot_count > 0 and colon_count == 0:
            return_text = "ipv4"
        else:
            self.logger.debug("{i} is not in IPv4 nor IPv6 format".format(i=ip_address))
        self.logger.debug(f"IP address {ip_address} is in {return_text} format")
        return return_text

    def check_json_ip_info_return_item(self, item, i, parametername, save_name, bts_id, id_in_file):
        """
        Check if IP address in json file is the same as in cloud environment and update it if needed.

        :param dict item: Dictionary of the json file.
        :param int i: Index of the item in the json file.
        :param str parametername: Name of the parameter in the json file.
        :param str save_name: Name of the IP address in the cloud environment.
        :param str bts_id: BTS ID in the cloud environment.
        :param str id_in_file: BTS ID in the json file.
        """
        if parametername == 'update_id':
            if save_name == 'TRSNW':  # uplane, cplane
                for j in range(0, len(item['parameters'][i]['value'])):
                    org_4 = item['parameters'][i]['value'][j]["ipV4AddressDN1"]
                    org_6 = item['parameters'][i]['value'][j]["ipV6AddressDN1"]
                    pn = item['parameters'][i]['parameterName']
                    if bts_id not in org_4:
                        info("IPv4 distname of {pn} in deltafile is '{o}', BTS id needs to be changed according to used"
                             " UTE environment to {i}".format(pn=pn, o=org_4, i=bts_id))
                    else:
                        info("IPv4 distname of {pn} in deltafile is '{o}', it is the same as in UTE environment, no "
                             "need to update".format(pn=pn, o=org_4))
                    if bts_id not in org_6:
                        info("IPv6 distname of {pn} in deltafile is '{o}', BTS id need to be changed according to UTE"
                             " environment to {i}".format(pn=pn, o=org_6, i=bts_id))
                    else:
                        info("IPv6 distname of {pn} in deltafile is '{o}', it is the same as in UTE environment. No "
                             "need to update.".format(pn=pn, o=org_6))
                    item['parameters'][i]['value'][j]["ipV6AddressDN1"] = org_6.replace(id_in_file, bts_id)
                    item['parameters'][i]['value'][j]["ipV4AddressDN1"] = org_4.replace(id_in_file, bts_id)
            elif save_name == 'mplane':
                pn = item['parameters'][i]['parameterName']
                org = item['parameters'][i]['value']
                if bts_id not in org:
                    info("Distname of {pn} in deltafile is '{o}', BTS id needs to be changed according to UTE "
                         "environment to {i}".format(pn=pn, o=org, i=bts_id))
                else:
                    info("Distname of {pn} in deltafile is '{o}', it is the same as in used UTE environment. No need to"
                         " update.".format(pn=pn, o=org))
                item['parameters'][i]['value'] = org.replace(id_in_file, bts_id)
        elif parametername == 'staticIpv6Routes':
            for j in range(0, len(item['parameters'][i]['value'])):
                i_in_f = item['parameters'][i]['value'][j]["gatewayIpv6Addr"]
                if self.check_if_ipv4_or_ipv6_address(str(i_in_f)) == "ipv6":
                    if i_in_f != self.ips_in_cloud_environment['%s_ipv6' % save_name]:
                        item['parameters'][i]['value'][j]["gatewayIpv6Addr"] =\
                            self.ips_in_cloud_environment['%s_ipv6' % save_name]
                        info("{s} is '{oi}' in delta file, it is updated according to used UTE environment to "
                             "'{i}'".format(s=save_name, oi=i_in_f,
                                            i=self.ips_in_cloud_environment['%s_ipv6' % save_name]))
                    else:
                        info("{s} in delta file already has the same IP '{oi}' that is in used UTE environment. No "
                             "need to update.".format(s=save_name, oi=i_in_f))
        elif item['parameters'][i]['parameterName'] == parametername:
            i_in_f = item['parameters'][i]['value']
            if self.check_if_ipv4_or_ipv6_address(str(i_in_f)) == "ipv4":
                if parametername == 'ntpServerIpAddrList':
                    il = list(i_in_f)
                    if il:
                        for g in range(0, len(il)):
                            org = item['parameters'][i]['value'][g]
                            if org != self.ips_in_cloud_environment['%s' % save_name]:
                                item['parameters'][i]['value'][g] = self.ips_in_cloud_environment['%s' % save_name]
                                info("'{oi}' is updated according to used UTE environment to '{i}'".format(
                                    oi=org, i=self.ips_in_cloud_environment['%s' % save_name]))
                            else:
                                info("IP of {s} in delta file already has the same value '{oi}' that is in used UTE "
                                     "environment. No need to update.".format(s=save_name, oi=org))
                else:
                    if item['parameters'][i]['value'] != self.ips_in_cloud_environment['%s_ip' % save_name]:
                        if ("${USE_IP_FROM_JSON}" in BuiltIn().get_variables() and
                                BuiltIn().get_variable_value("${USE_IP_FROM_JSON}")):
                            info("IP of {s} is '{oi}' in delta file, in used UTE environment IP is '{i}'. Because "
                                 "USE_IP_FROM_JSON is set to True use ip given in the delta file.".format(
                                    s=save_name, oi=i_in_f, i=self.ips_in_cloud_environment['%s_ip' % save_name]))
                        else:
                            info("IP of {s} is '{oi}' in delta file, it will be updated according to used UTE "
                                 "environment to '{i}'".format(s=save_name, oi=i_in_f,
                                                               i=self.ips_in_cloud_environment['%s_ip' % save_name]))
                            item['parameters'][i]['value'] = self.ips_in_cloud_environment['%s_ip' % save_name]
                    else:
                        info("{s} in delta file already has the same IP '{oi}' in used UTE environment. No need to "
                             "update.").format(s=save_name, oi=i_in_f)
            elif self.check_if_ipv4_or_ipv6_address(str(i_in_f)) == "ipv6":
                if parametername == 'ntpServerIpAddrList':
                    info("Do not update ntpServerIpAddrList according to UTE environment, use the IP that is in "
                         "commissioning file")
                    # FCA_TATSCRIPTS-181059  Airscale TRS-SEC: Take NTP server IPv6 address from comm./.json file
                    # not from UTE cloud init file)
                else:
                    if item['parameters'][i]['value'] != self.ips_in_cloud_environment['%s_ipv6' % save_name]:
                        item['parameters'][i]['value'] = self.ips_in_cloud_environment['%s_ipv6' % save_name]
                        info("IP of {s} is '{oi}' in delta file, it will be updated according to used UTE environment"
                             " to '{i}'".format(s=save_name, oi=i_in_f,
                                                i=self.ips_in_cloud_environment['%s_ipv6' % save_name]))
                    else:
                        info("IP of {s} in delta file already has the same value '{oi}' that is in used UTE "
                             "environment. No need to update.".format(s=save_name, oi=i_in_f))
            elif self.check_if_ipv4_or_ipv6_address(str(i_in_f)) == "empty_ipv6":
                info("{s} has an empty IPv6 address '{oi}' in delta file, no updated according to used UTE environment"
                     " will be made.".format(s=save_name, oi=i_in_f))
            elif self.check_if_ipv4_or_ipv6_address(str(i_in_f)) == "empty_ipv4":
                info("{s} has an empty IPv4 address '{oi}' in delta file, no updated according to used UTE environment"
                     " will be made.".format(s=save_name, oi=i_in_f))
        return item

    def update_information_of_env_to_json(self):
        """Get information from cloud environment and update it to user given commissioning file."""
        try:
            self.get_ips_from_cloud_configuration()
            bts_id = "1"
            id_in_file = '1'
            if "bts_id" in self.ips_in_cloud_environment:
                bts_id = str(self.ips_in_cloud_environment["bts_id"])
            if '.json' in self.commissioning_file_path:
                with open(self.commissioning_file_path, 'r+') as f:
                    data = json.load(f)
                    for item in data:
                        # Update BTS ID to distnames to json
                        org_dist_name = item['distName']
                        if id_in_file == '1':
                            id_parser = re.compile(r"MRBTS-(?P<id_in_file>\d+).*")
                            match = id_parser.match(org_dist_name)
                            if match:  # text found
                                if match.group("id_in_file"):  # if more than 0
                                    id_in_file = str(match.group("id_in_file"))
                        item['distName'] = org_dist_name.replace(id_in_file, bts_id)
                        info(f"Distname '{org_dist_name}' in delta file is updated according to used UTE environment to"
                             f" '{item['distName']}'.")
                        if 'MME' in str(item['distName']):
                            for i in range(0, len(item['parameters'])):
                                item = self.check_json_ip_info_return_item(
                                    item, i, 'ipAddrPrim', 'mme', bts_id, id_in_file)
                        if 'TRSNW' in str(item['distName']):
                            for i in range(0, len(item['parameters'])):
                                item = self.check_json_ip_info_return_item(item, i, 'update_id', 'TRSNW', bts_id,
                                                                           id_in_file)
                        if 'MPLANENW' in str(item['distName']):
                            for i in range(0, len(item['parameters'])):
                                item = self.check_json_ip_info_return_item(item, i, 'update_id', 'mplane', bts_id,
                                                                           id_in_file)
                        if '/NTP-' in str(item['distName']):
                            for i in range(0, len(item['parameters'])):
                                item = self.check_json_ip_info_return_item(item, i, 'ntpServerIpAddrList', 'ntp_server',
                                                                           bts_id, id_in_file)
                        if "IPNO-1/IPRTV6-1" in str(item['distName']):
                            for i in range(0, len(item['parameters'])):
                                item = self.check_json_ip_info_return_item(item, i, 'staticIpv6Routes', 'trans_def_gw',
                                                                           bts_id, id_in_file)
                        if "IPNO-1/IPIF-1/IPADDRESSV6-1" in str(item['distName']):
                            for i in range(0, len(item['parameters'])):
                                item = self.check_json_ip_info_return_item(item, i, 'localIpAddr', 'trs', bts_id,
                                                                           id_in_file)
                    info(f"Write updated content to delta file {self.commissioning_file_path}")
                    f.seek(0)
                    json.dump(data, f, indent=4)
                    f.truncate()
        except OSError as e:
            error(f"{e.__class__.__name__}:{e}")
            info(f"{''.join(format_exception(type(e), e, e.__traceback__))}")
            if "No space left on device" in str(e):
                self.logger.command_via_commandline("df -h")
                BuiltIn().fatal_error("No space left on device. Stopping execution of the suite.")

    def update_value_to_configuration_file(self, one, oni, class_name, elementname, name_in_env, child_name=""):
        try:
            if one.attrib[oni] == class_name:
                lapset = list(one)
                for laps in lapset:
                    lapsdict = dict(laps.attrib)
                    for _, v in lapsdict.items():
                        if str(v) == elementname and elementname == 'ntpServerIpAddrList':
                            lapslaps = list(laps)
                            for lapslap in lapslaps:
                                l_name = str(lapslap.text)
                                if self.check_if_ipv4_or_ipv6_address(str(l_name)) == "ipv4":
                                    name_in_env = "%s" % name_in_env
                                elif self.check_if_ipv4_or_ipv6_address(str(l_name)) == "ipv6":
                                    name_in_env = "%s_ipv6" % name_in_env
                                elif self.check_if_ipv4_or_ipv6_address(str(l_name)) in ("empty_ipv4", "empty_ipv6"):
                                    info("There is no IP in user given configuration file for %s. No need to update the"
                                         " file" % elementname)
                                    name_in_env = ''
                                if name_in_env:
                                    env_value = self.ips_in_cloud_environment[name_in_env]
                                    if l_name != env_value:
                                        info("{e} of {c} is '{oi}' in given commissioning file, it needs to be updated "
                                             "according to used UTE environtment to '{i}'".format(
                                                e=elementname, c=class_name, oi=l_name, i=env_value))
                                        lapslap.text = env_value
                        elif str(v) == elementname and elementname in ('ntpServerStatusList', 'forwardingEntries',
                                                                       'staticRoutes', 'topMasterList',
                                                                       'staticIpv6Routes'):
                            lapslaps = list(laps)
                            for lapslap in lapslaps:
                                lapslapslaps = list(lapslap)
                                for lapslapslap in lapslapslaps:
                                    lapslapslapdict = dict(lapslapslap.attrib)
                                    for _, g in lapslapslapdict.items():
                                        if str(g) == child_name:  # in ('ntpServerIpAddr', 'preSrcIpv4Addr'):
                                            l_name = str(lapslapslap.text)
                                            if self.check_if_ipv4_or_ipv6_address(str(l_name)) == "ipv4":
                                                if child_name in ('ntpServerIpAddr', 'gateway'):
                                                    name_in_env = "%s" % name_in_env
                                                else:
                                                    name_in_env = "%s_ip" % name_in_env
                                            elif self.check_if_ipv4_or_ipv6_address(str(l_name)) == "ipv6":
                                                name_in_env = "%s_ipv6" % name_in_env
                                            elif self.check_if_ipv4_or_ipv6_address(str(l_name)) in ("empty_ipv4",
                                                                                                     "empty_ipv6"):
                                                info("There is no IP in user given configuration file for %s. No need "
                                                     "to update the file" % elementname)
                                                name_in_env = ''
                                            if name_in_env:
                                                env_value = self.ips_in_cloud_environment[name_in_env]
                                                if l_name != env_value:
                                                    info(
                                                        "{ee} of {e} of {c} is '{oi}' in given commissioning file, it "
                                                        "needs to be updated according to used UTE environment to "
                                                        "'{i}'".format(ee=str(g), e=elementname, c=class_name,
                                                                       oi=l_name, i=env_value))
                                                    lapslapslap.text = env_value
                        elif str(v) == elementname and elementname == "connectorLabel":
                            l_name = laps.text
                            if l_name != name_in_env:
                                info(f"There is {l_name} for element {elementname} (class: {class_name}) in user given "
                                     f"configuration file. We have to update it to {name_in_env} according to used "
                                     f"environment.")
                                laps.text = name_in_env
                            else:
                                info(f"There is {l_name} for element {elementname} (class: {class_name}) in user given "
                                     f"configuration file. Same as currently active commissioning. No need for update.")
                        elif str(v) == elementname:
                            l_name = laps.text
                            if name_in_env in 'mme':
                                if self.check_if_ipv4_or_ipv6_address(str(l_name)) == "ipv4":
                                    name_in_env = "%s_ip" % name_in_env
                                elif self.check_if_ipv4_or_ipv6_address(str(l_name)) == "ipv6":
                                    name_in_env = "%s_ipv6" % name_in_env
                                elif self.check_if_ipv4_or_ipv6_address(str(l_name)) in ("empty_ipv4", "empty_ipv6"):
                                    info("There is no IP in user given configuration file for %s. No need to update the"
                                         " file" % elementname)
                                    name_in_env = ''
                            if name_in_env:
                                env_value = self.ips_in_cloud_environment[name_in_env]
                                if l_name != env_value:
                                    info("{e} of {c} is '{oi}' in given commissioning file, it needs to be updated "
                                         "according to used UTE environment to '{i}'".format(
                                            e=elementname, c=class_name, oi=l_name, i=env_value))
                                    laps.text = env_value
        except OSError as e:
            error(f"{e.__class__.__name__}:{e}")
            info(f"{''.join(format_exception(type(e), e, e.__traceback__))}")
            if "No space left on device" in str(e):
                self.logger.command_via_commandline("df -h")
                BuiltIn().fatal_error("No space left on device. Stopping execution of the suite.")

    def update_value_to_configuration_file_id(self, one, oni, class_name, element_name, id_in_file, bts_id, child=""):
        """
        Update value to configuration file according to used UTE environment.

        :param element one: Element of the commissioning file.
        :param str oni: Attribute of the element.
        :param str class_name: Class name of the element.
        :param str element_name: Name of the element.
        :param str id_in_file: BTS ID in the commissioning file.
        :param str bts_id: BTS ID in the cloud environment.
        :param str child: (Optional) Child of the element.
        """
        try:
            if one.attrib[oni] == class_name:
                self.logger.debug(f"Updating value of {element_name} of {class_name}")
                lapset = list(one)
                for laps in lapset:
                    if child:
                        l2 = list(laps)
                        for childrenchild in l2:
                            l3 = list(childrenchild)
                            for ll in l3:
                                l3dict = dict(ll.attrib)
                                for _, g in l3dict.items():
                                    if str(g) == child:
                                        l_name = ll.text
                                        env_value = l_name.replace(id_in_file, bts_id)
                                        if l_name != env_value:
                                            info(f"{child} of {element_name} of {class_name} is '{l_name}' in given "
                                                 f"commissioning file, it needs to be updated according to used UTE "
                                                 f"environment to '{env_value}'")
                                            ll.text = env_value
                    else:
                        lapsdict = dict(laps.attrib)
                        for _, v in lapsdict.items():
                            if str(v) == element_name:
                                l_name = laps.text
                                if l_name:
                                    env_value = l_name.replace(id_in_file, bts_id)
                                    if l_name != env_value:
                                        info(
                                            "{e} of {c} is '{oi}' in given commissioning file, it needs to be updated "
                                            "according to used UTE environment to '{i}'".format(
                                                e=element_name, c=class_name, oi=l_name, i=env_value))
                                        laps.text = env_value
        except OSError as e:
            error(f"{e.__class__.__name__}:{e}")
            info(f"{''.join(format_exception(type(e), e, e.__traceback__))}")
            if "No space left on device" in str(e):
                self.logger.command_via_commandline("df -h")
                BuiltIn().fatal_error("No space left on device. Stopping execution of the suite.")

    def find_bts_id_in_file(self, text):
        id_in_file = '1'
        id_parser = re.compile(r".*MRBTS-(?P<id_in_file>\d+).*")
        match = id_parser.match(text)
        if match:
            id_in_file = str(match.group("id_in_file"))
            self.logger.debug(f"id_in_file: {id_in_file}")
        return id_in_file

    def update_ips_to_configurationfile(self):
        """
        Parse commissioning file and update IP addresses according to used UTE environment.
        """
        try:
            self.get_ips_from_cloud_configuration()
            bts_id = "1"
            id_in_file = '1'
            if "bts_id" in self.ips_in_cloud_environment:
                bts_id = str(self.ips_in_cloud_environment["bts_id"])
            if 'xml' in self.commissioning_file_path:
                etree.register_namespace("", "raml21.xsd")
                # Note! this is xmlns information in commissioning file, without it creates ns0 before elements
                xml = etree.parse(self.commissioning_file_path)
                for setup in xml.getroot():
                    for one in setup:
                        for oni in one.attrib:
                            if oni == 'class':
                                dn = one.attrib['distName']
                                if id_in_file == '1':
                                    id_in_file = self.find_bts_id_in_file(dn)
                                distname_in_environment = dn.replace(id_in_file, bts_id)
                                if not distname_in_environment:
                                    info("DistName of class %s is %s in configuration file, but it doesn't exist in "
                                         "current configuration." % (one.attrib[oni], dn))
                                    info("Unable to do any DistName updating for this class according to used "
                                         "environment. DistName will be the same that was in the file given by user.")
                                if distname_in_environment and distname_in_environment != dn:
                                    info("DistName of class %s is '%s' in configuration file -> it needs to be updated"
                                         " to '%s'" % (one.attrib[oni], dn, distname_in_environment))
                                    one.set('distName', distname_in_environment)
                                if one.attrib[oni] == "com.nokia.srbts.tnl:ETHLK":
                                    object_distname = self.scf.get_distname_based_on_class(
                                        "com.nokia.srbts.tnl:ETHLK")[0]
                                    self.logger.debug(f"object distname: {object_distname}")
                                    con_label = self.scf.get_value_from_scf(dist_name=object_distname,
                                                                            p_name="connectorLabel")
                                    self.update_value_to_configuration_file(one, oni, "com.nokia.srbts.tnl:ETHLK",
                                                                            'connectorLabel', con_label)
                                if one.attrib[oni] == "com.nokia.srbts.tnl:IPADDRESSV4":
                                    self.update_value_to_configuration_file(one, oni, "com.nokia.srbts.tnl:IPADDRESSV4",
                                                                            'localIpAddr', 'trs_ip')
                                if one.attrib[oni] == "com.nokia.srbts.tnl:IPADDRESSV4_R":
                                    self.update_value_to_configuration_file(one, oni,
                                                                            "com.nokia.srbts.tnl:IPADDRESSV4_R",
                                                                            'localIpAddrAllocated', 'trs_ip')
                                if one.attrib[oni] == "com.nokia.srbts.tnl:IPADDRESSV6":
                                    self.update_value_to_configuration_file(one, oni, "com.nokia.srbts.tnl:IPADDRESSV6",
                                                                            'localIpAddr', 'trs_ipv6')
                                if one.attrib[oni] == "com.nokia.srbts.tnl:IPADDRESSV6_R":
                                    self.update_value_to_configuration_file(one, oni,
                                                                            "com.nokia.srbts.tnl:IPADDRESSV6_R",
                                                                            'localIpAddrAllocated', 'trs_ipv6')
                                if one.attrib[oni] == "NOKLTE:LNMME":
                                    self.update_value_to_configuration_file(one, oni, "NOKLTE:LNMME", 'ipAddrPrim',
                                                                            'mme')
                                if one.attrib[oni] == "com.nokia.srbts.mnl:NTP":
                                    self.update_value_to_configuration_file(one, oni, "com.nokia.srbts.mnl:NTP",
                                                                            'ntpServerIpAddrList', 'ntp_server')
                                if one.attrib[oni] == "com.nokia.srbts.mnl:NTP_R":
                                    self.update_value_to_configuration_file(one, oni, "com.nokia.srbts.mnl:NTP_R",
                                                                            'ntpServerStatusList', 'ntp_server',
                                                                            'ntpServerIpAddr')
                                if one.attrib[oni] == "com.nokia.srbts.tnl:IPRT":
                                    self.update_value_to_configuration_file(one, oni, "com.nokia.srbts.tnl:IPRT",
                                                                            'staticRoutes', 'trans_def_gw', 'gateway')
                                if one.attrib[oni] == "com.nokia.srbts.tnl:IPRTV6":
                                    self.update_value_to_configuration_file(one, oni, "com.nokia.srbts.tnl:IPRTV6",
                                                                            'staticIpv6Routes', 'trans_def_gw',
                                                                            'gatewayIpv6Addr')
                                if one.attrib[oni] == "com.nokia.srbts.tnl:IPRT_R":
                                    self.update_value_to_configuration_file(one, oni, "com.nokia.srbts.tnl:IPRT_R",
                                                                            'forwardingEntries', 'trs',
                                                                            'preSrcIpv4Addr')
                                    self.update_value_to_configuration_file(one, oni, "com.nokia.srbts.tnl:IPRT_R",
                                                                            'forwardingEntries', 'trans_def_gw',
                                                                            'gateway')
                                if one.attrib[oni] == "com.nokia.srbts.mnl:TOPF":
                                    self.update_value_to_configuration_file(one, oni, "com.nokia.srbts.mnl:TOPF",
                                                                            'topMasterList', 'top', 'masterIpAddr')
                                if one.attrib[oni] == "com.nokia.srbts.mnl:MPLANENW":
                                    self.update_value_to_configuration_file_id(one, oni, "com.nokia.srbts.mnl:MPLANENW",
                                                                               'mPlaneIpv4AddressDN', id_in_file,
                                                                               bts_id)
                                    self.update_value_to_configuration_file_id(one, oni, "com.nokia.srbts.mnl:MPLANENW",
                                                                               'mPlaneIpv6AddressDN', id_in_file,
                                                                               bts_id)
                                if one.attrib[oni] == "NOKLTE:TRSNW":
                                    self.update_value_to_configuration_file_id(one, oni, "NOKLTE:TRSNW", 'cPlane',
                                                                               id_in_file, bts_id, 'ipV4AddressDN1')
                                    self.update_value_to_configuration_file_id(one, oni, "NOKLTE:TRSNW", 'cPlane',
                                                                               id_in_file, bts_id, 'ipV6AddressDN1')
                                    self.update_value_to_configuration_file_id(one, oni, "NOKLTE:TRSNW", 'uPlane',
                                                                               id_in_file, bts_id, 'ipV4AddressDN1')
                                    self.update_value_to_configuration_file_id(one, oni, "NOKLTE:TRSNW", 'uPlane',
                                                                               id_in_file, bts_id, 'ipV6AddressDN1')
                                if one.attrib[oni] == "com.nokia.srbts.mnl:TOP":
                                    self.update_value_to_configuration_file_id(one, oni, "com.nokia.srbts.mnl:TOP",
                                                                               'sPlaneIpAddressDN', id_in_file, bts_id)
                    xml.write(self.commissioning_file_path)
                info(f"Updated commissioning file is saved to {self.commissioning_file_path}")
                content = open(self.commissioning_file_path).read()
                self.logger.debug("Content of commissioning file after updating:\n%s" % content)

            else:
                error(f"Commissioning file {self.commissioning_file_path} is not a xml file. Provide proper "
                      f"commissioning file.")
                raise InvalidUserInput("Commissioning file is not a xml file. Provide proper commissioning file.")
        except (TypeError, ValueError, SystemError, OSError) as ex:
            error(f"Problems while trying to update information to configuration file. {ex.__class.__name__}:{ex} "
                  f"was raised.")
            info(f"{''.join(format_exception(type(ex), ex, ex.__traceback__))}")
            if "No space left on device" in str(ex):
                self.logger.command_via_commandline("df -h")
                BuiltIn().fatal_error("No space left on device. Stopping execution of the suite.")
            raise ScriptIssue(f"Problems while trying to update information to configuration file.")

    def parse_meaningful_ips_from_user_given_commissioning_file(self):
        """Get IPs from user given commissioning file."""
        ips_in_given_commissioning_file = {}
        try:
            if 'xml' in self.commissioning_file_path:
                etree.register_namespace("", "raml21.xsd")
                # Note! this is xmlns information in commissioning file, without it creates ns0 before elements
                xml = etree.parse(self.commissioning_file_path)
                for setup in xml.getroot():
                    for one in setup:
                        for oni in one.attrib:
                            v = ""
                            if oni == 'class':
                                if one.attrib[oni] == "com.nokia.srbts.tnl:IPADDRESSV4":
                                    ips_in_given_commissioning_file.update(
                                        self.get_children_info_return_dict(one, 'localIpAddr', 'trs'))
                                if one.attrib[oni] == "com.nokia.srbts.tnl:IPADDRESSV6":
                                    ips_in_given_commissioning_file.update(
                                        self.get_children_info_return_dict(one, 'localIpAddr', 'trs'))
                                if one.attrib[oni] == "NOKLTE:LNMME":
                                    ips_in_given_commissioning_file.update(
                                        self.get_children_info_return_dict(one, 'ipAddrPrim', 'mme'))
                                if one.attrib[oni] == "com.nokia.srbts.mnl:NTP":
                                    ips_in_given_commissioning_file.update(
                                        self.get_children_info_return_dict(one, 'ntpServerIpAddrList', 'ntp_server'))
                                if one.attrib[oni] == "NOKLTE:GTPU":
                                    ips_in_given_commissioning_file.update(self.get_children_info_return_dict(
                                        one, 'sgwIpAddressList', 'saegw'))
                                if one.attrib[oni] == "NOKLTE:IPNO":
                                    ips_in_given_commissioning_file.update(
                                        self.get_children_info_return_dict(one, 'oamIpAddr', 'oms'))
                                    ips_in_given_commissioning_file.update(
                                        self.get_children_info_return_dict(one, 'mPlaneIpAddress', 'mplane'))
                                    ips_in_given_commissioning_file.update(
                                        self.get_children_info_return_dict(one, 'uPlaneIpAddress', 'uplane'))
                                    ips_in_given_commissioning_file.update(
                                        self.get_children_info_return_dict(one, 'cPlaneIpAddress', 'cplane'))
                                    ips_in_given_commissioning_file.update(
                                        self.get_children_info_return_dict(one, 'sPlaneIpAddress', 'splane'))
                                if one.attrib[oni] == "NOKLTE:IEIF":
                                    lapset = list(one)
                                    for laps in lapset:
                                        lapsdict = dict(laps.attrib)
                                        for _, v in lapsdict.items():
                                            if str(v) == 'localIpAddr':
                                                ips_in_given_commissioning_file["trs_ipv4"] = str(laps.text)
                                            elif str(v) == 'localIpv6Addr':
                                                if str(laps.text).count(':') == 2:
                                                    ips_in_given_commissioning_file["trs_empty_ipv6"] = str(laps.text)
                                                else:
                                                    ips_in_given_commissioning_file["trs_ipv6"] = str(laps.text)
                                if one.attrib[oni] == "NOKLTE:INTP":
                                    ips_in_given_commissioning_file.update(
                                        self.get_children_info_return_dict(one, 'ntpServers', 'ntp_server'))
                info(f"IPs in commissioning file, given by tester:\n{ips_in_given_commissioning_file}")
        except (TypeError, ValueError, SystemError, OSError) as ex:
            error(f"Problems while trying to parse IP information of configuration file, given by tester. "
                  f"{ex.__class__.__name__}:{ex} was raised.\n"
                  f"{''.join(format_exception(type(ex), ex, ex.__traceback__))}")
            raise ScriptIssue(f"Problems while trying to parse IP information of configuration file "
                              f"{self.commissioning_file_path}.")
        return ips_in_given_commissioning_file

    def collect_parameters_to_be_changed(self):
        """Collect all parameters that will be changed."""
        parameter_to_be_changed = {}
        envip = ""
        name_ip_dict = self.get_ips_from_cloud_configuration()
        names_of_env = name_ip_dict.keys()
        if '.xml' in self.commissioning_file_path:
            ips_in_given_commissioning_file = self.parse_meaningful_ips_from_user_given_commissioning_file()
            for name, ip in ips_in_given_commissioning_file.items():
                if name in names_of_env:
                    envip = str(name_ip_dict[name])
                    info("{n} in commissioning file provided by user is {i} -> it needs be updated to {uip} (value from"
                         " UTE init file)".format(n=name, i=ip, uip=envip))
                elif name not in names_of_env and name in ('mplane_ip', 'cplane_ip', 'uplane_ip'):
                    if "trs_ip" in name_ip_dict:
                        envip = str(name_ip_dict["trs_ip"])
                        info("{n} in commissioning file provided by user is {i} -> it needs be updated to trs_ip {uip}"
                             " (value from UTE init file)".format(n=name, i=ip, uip=envip))
                elif name not in names_of_env and name in ('mplane_ipv6', 'cplane_ipv6', 'uplane_ipv6'):
                    if "trs_ipv6" in name_ip_dict:
                        envip = str(name_ip_dict["trs_ipv6"])
                        info("{n} in commissioning file provided by user is {i} -> it needs be updated to trs_ipv6 "
                             "{uip} (value from UTE init file)".format(n=name, i=ip, uip=envip))
                elif name not in names_of_env and 'empty' in name:
                    info("{n} in commissioning file provided by user is {i} -> NO need to updated".format(
                         n=name, i=ip, uip=envip))
                parameter_to_be_changed[name] = envip
        else:
            info("NOT XML file. Please use XML file if you want script to modify xml file")

    def get_children_info_return_dict(self, one, ec_att, save_name):
        """
        Gets information from child element abd return dictionary.

        :param one: Element of the commissioning file.
        :param str ec_att: Attribute of the element.
        :param str save_name: Short name for dictionary key.
        """
        ips = {}
        lapset = list(one)
        for laps in lapset:
            lapsdict = dict(laps.attrib)
            for _, v in lapsdict.items():
                if str(v) == ec_att:
                    l_name = laps.text
                    if str(ec_att) == "ntpServers" or str(ec_att) == "ntpServerIpAddrList":
                        lapslaps = list(laps)
                        for lapslap in lapslaps:
                            l_name = str(lapslap.text)
                    if str(ec_att) == "sgwIpAddressList":
                        lapslaps = list(laps)
                        for lapslap in lapslaps:
                            lapslapslaps = list(lapslap)
                            for lapslapslap in lapslapslaps:
                                lapslapslapdict = dict(lapslapslap.attrib)
                                for _, llv in lapslapslapdict.items():
                                    if str(llv) == "sgwIpAddress":
                                        l_name = str(lapslapslap.text)
                    if l_name:
                        if save_name == "ntp_server" and self.check_if_ipv4_or_ipv6_address(str(l_name)) == "ipv4":
                            ips["%s" % save_name] = str(l_name)
                        elif self.check_if_ipv4_or_ipv6_address(str(l_name)) == "ipv4":
                            ips["%s_ip" % save_name] = str(l_name)
                        elif self.check_if_ipv4_or_ipv6_address(str(l_name)) == "ipv6":
                            ips["%s_ipv6" % save_name] = str(l_name)
                        elif self.check_if_ipv4_or_ipv6_address(str(l_name)) == "empty_ipv4":
                            ips["%s_empty_ipv4" % save_name] = str(l_name)
                        elif self.check_if_ipv4_or_ipv6_address(str(l_name)) == "empty_ipv6":
                            ips["%s_empty_ipv6" % save_name] = str(l_name)
                        else:
                            info("Cannot get IP of %s from given commissioning file" % save_name)
                    else:
                        print("IP address of {n} is NOT found from user given commissioning file. Check the file "
                              "content. If {n} is there, please take contact to script developer and provide the file "
                              "you have used.".format(n=save_name))
        return ips

    def replace_bts_id(self):
        """
        Replace all the bts ids with value from cloud environment.
        """
        if "bts_id" in self.ips_in_cloud_environment:
            bts_id = str(self.ips_in_cloud_environment["bts_id"])
        else:
            error("Bts id is not get from admin")
            raise EnvironmentIssue("Bts id is not get")
        info("Replace all the bts ids with value {} from {}".format(bts_id, self.commissioning_file_path))
        ctr = 0
        # Read in the commissioning file
        with open(self.commissioning_file_path, 'r') as f:
            filedata = f.read()
        # Split content by \n and Replace the target string
        filedata_list = filedata.split('\n')
        new_file_content = []
        for file_line in filedata_list:
            if "MRBTS" in file_line:
                id_in_file = self.find_bts_id_in_file(file_line)
                if id_in_file != '1' and id_in_file != bts_id:
                    file_line = file_line.rstrip().replace(id_in_file, bts_id)
                    ctr += 1
            self.logger.debug(file_line.rstrip())
            new_file_content.append(file_line)
        filedata = '\n'.join(new_file_content)
        # Write the file
        with open(self.commissioning_file_path, 'w') as f:
            f.write(filedata)
        info("{} ids was replaced in {}".format(ctr, self.commissioning_file_path))
        # content = open(self.commissioning_file_path).read()
        # self.logger.debug("Content of commissioning file after replacing BTS id:\n%s" % content)
