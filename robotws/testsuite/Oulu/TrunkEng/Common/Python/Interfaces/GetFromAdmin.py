"""
:author:  Terhi Talvitie
:contact: I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com
"""

import re
from traceback import format_exception
from robot.libraries.BuiltIn import BuiltIn
from taf.internal.sbts.admin.exceptions import (
    AdminApiConnectionClosedException, AdminApiProcedureFailureException, AdminApiProcedureTimeoutException,
    AdminApiNoResponseException, AdminApiTerminatedException)
from taf.internal.aliasing.exceptions import AliasLookupError
from taf.sbts.oam.coam.admin.exceptions import AliasInUse
from testsuite.Oulu.TrunkEng.Common.Python.Interfaces.Logger import info, error, warning
from testsuite.Oulu.TrunkEng.Common.Python.Resources.exceptions import EnvironmentIssue, ScriptIssue


class GetFromAdmin:
    """
    Class for getting information from admin interface.

    GetFromAdmin is called in common_resources.robot. If the class is already initiated once, import robot BuiltIn
        >> from robot.libraries.BuiltIn import BuiltIn
    and call with
        >> BuiltIn().get_library_instance("GET_FROM_ADMIN")
    """
    bbpools_cells = {}

    def __init__(self):
        self.admin = BuiltIn().get_library_instance("ADMIN")
        self.logger = BuiltIn().get_library_instance("LOG")

    def _get_parameters_from_mos(self, mos, class_name, parameter_name, short_name, inlist=""):
        """
        Collects dictionary from managed objects of the given value.

        :param list mos: List of managed objects
        :param str class_name: Class name for example NOKLTE:GTPU
        :param str parameter_name: Parameter name to be fetched. For example sgwIpAddressList
        :param str short_name: Short name for the IP address. Used for key name in return library. For example S-GW.
        :param str inlist: (Optional) If IP address/parameter is in list, give name in list. For example sgwIpAddress
        """
        ips = []
        self.logger.debug(f"Getting {parameter_name} from {class_name} (short name is {short_name})")
        for mo in mos:
            parameter_dict = mo["parameters"]
            if parameter_name in parameter_dict:
                if inlist:
                    if inlist in parameter_dict[parameter_name]:
                        ips.append(str(parameter_dict[parameter_name][inlist]))
                    else:
                        error(f"No {inlist} under {parameter_name} of {class_name}. Cannot get IP of {short_name}.")
                elif short_name == 'NTP':
                    for i in parameter_dict[parameter_name]:
                        ips.append(str(i))
                else:
                    ips.append(str(parameter_dict[parameter_name]))
        self.logger.debug(f"Found {short_name} IPs: {ips}")
        return ips

    def get_information_return_dict(self, class_name, ip_add, short_name, inlist="", fail_test_if_not=True):
        """
        Get information from admin.

        :param str class_name: Class name of the managed object. For example "NOKLTE:LNMME"
        :param str ip_add: IP address to be fetched. For example "sgwIpAddress"
        :param str short_name: Short name for the IP address. For example "SGW".
        :param str inlist: (Optional) If IP address is in list, give list name. For example "sgwIpAddressList"
        :param bool fail_test_if_not: (Optional) If True, test fails if class is not found. Default is True.
        :return dict: Returns dictionary with short name as key and IP address as value. For example
                      {"SGW": 10.34.180.182"}
        """
        parameter_dict = {}
        try:
            mos = self.admin.get_managed_objects(class_name)
            if mos:
                ips = self._get_parameters_from_mos(mos, class_name, ip_add, short_name, inlist)
                if not ips:
                    if fail_test_if_not:
                        error(f"There is no {ip_add} under object {class_name}. Something is wrong/changed in BTS SW")
                        raise EnvironmentIssue
                    else:
                        info(f"There is no {ip_add} under object {class_name}. Cannot get IP of {short_name} from "
                             f"admin.")
                elif len(ips) > 1:
                    if fail_test_if_not:
                        error(f"There are more than one {ip_add} under object {class_name}: {ips}. Cannot be sure if"
                              f" correct address is selected.")
                        raise EnvironmentIssue
                    else:
                        info(f"There are more than one {ip_add} under object {class_name}: {ips} when searched from "
                             f"admin. Cannot be sure if correct address is selected.")
                else:
                    parameter_dict[short_name] = str(ips[0])
            else:
                if fail_test_if_not:
                    error(f"No managed objects found from admin by class name {class_name}. Cannot get IP of {ip_add}.")
                    raise EnvironmentIssue
                else:
                    info(f"No managed objects found from admin by class name {class_name}. Cannot get IP of {ip_add}.")
        except (AdminApiProcedureFailureException, AdminApiProcedureTimeoutException, AdminApiNoResponseException,
                AliasLookupError, AdminApiTerminatedException, AliasInUse,
                AdminApiConnectionClosedException) as admin_error:
            error(f"Unable to get information from admin. {admin_error.__class__.__name__}:{admin_error} was raised.\n"
                  f"{''.join(format_exception(type(admin_error), admin_error, admin_error.__traceback__))}")
            raise EnvironmentIssue
        return parameter_dict

    def get_ips_from_admin(self, mme=True, oms=False, sgw=False, top=True, ntp=True):
        """
        Get IPs of LNMME, oamIpAddr, sgwIpAddress, masterIpAddr and NTP from admin. NOTE all environments do not have
        all IPs. If some IP is not needed and test should not fail from that it is not found, set it to False.

        :param bool mme: True if MME IP is needed. Default is True.
        :param bool oms: True if OMS IP is needed. Default is False.
        :param bool sgw: True if SGW IP is needed. Default is False.
        :param bool top: True if TOP IP is needed. Default is True.
        :param bool ntp: True if NTP IP is needed. Default is True.
        :return dict: Returns dictionary with short name as key and IP address as value. For example
                      {"MME": "10.35.108.4", "OMS": "10.35.110.4", "SGW": "10.34.210.1", "TOP": "10.34.142.79",
                      "NTP": "10.34.142.90"}
        """
        ip_dict = {}
        if mme:
            ip_dict.update(self.get_information_return_dict("NOKLTE:LNMME", "ipAddrPrim", 'MME'))
        if oms:
            ip_dict.update(self.get_information_return_dict("NOKLTE:IPNO", "oamIpAddr", 'OMS'))
        if sgw:
            ip_dict.update(self.get_information_return_dict("NOKLTE:GTPU", "sgwIpAddressList", 'SGW', "sgwIpAddress"))
        if top:
            ip_dict.update(self.get_information_return_dict("TOPF", "topMasterList", 'TOP', "masterIpAddr"))
        if ntp:
            ip_dict.update(self.get_information_return_dict("NTP", "ntpServerIpAddrList", 'NTP'))
        info(f"IPs parsed from admin: {ip_dict}")
        return ip_dict
