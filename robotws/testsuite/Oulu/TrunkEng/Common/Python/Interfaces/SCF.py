"""
:author: Essi Passoja
:contact: I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com
"""

import os
from datetime import datetime
from traceback import format_exception
import xml.etree.ElementTree as etree
from xml.etree.ElementTree import parse
from robot.libraries.BuiltIn import BuiltIn
from taf.config.scf import scf
from taf.internal.sbts.admin.exceptions import (
    AdminApiConnectionClosedException, AdminApiProcedureFailureException, AdminApiProcedureTimeoutException,
    AdminApiNoResponseException, AdminApiTerminatedException)
from taf.internal.aliasing.exceptions import AliasLookupError
from taf.sbts.oam.coam.admin.exceptions import AliasInUse
from testsuite.Oulu.TrunkEng.Common.Python.Interfaces.Logger import info, warning, error
from testsuite.Oulu.TrunkEng.Common.Python.Resources.exceptions import (EnvironmentIssue, CommissioningFailure,
                                                                        ScriptIssue, InvalidUserInput)


class SCF:
    """
    SCF is used for getting values from SCF files and performing commissioning.

    SCF is called in common_resources.robot. If the class is already initiated once, import robot
    BuiltIn
        >> from robot.libraries.BuiltIn import BuiltIn
    and call with
        >> BuiltIn().get_library_instance("SCF")
    """

    scf_file_path = ""
    remote_loaded = False

    def __init__(self):
        self.admin = BuiltIn().get_library_instance("ADMIN")
        self.logger = BuiltIn().get_library_instance("LOG")

        self.scf = scf()

    def get_scf(self, extra_name="", admin_connection="default", update_scf_path=True, add_timestamp_to_extra=False):
        """
        Get SCF and print its file path.
        """
        try:
            if extra_name:
                if add_timestamp_to_extra:
                    scf_file_name = f"scf_{datetime.now().strftime('%Y%m%d_%H%M%S')}_{extra_name}.xml"
                else:
                    scf_file_name = f"scf_{extra_name}.xml"
            else:
                scf_file_name = f"scf_{datetime.now().strftime('%Y%m%d_%H%M%S')}.xml"
            if os.path.exists(self.logger.log_dir):
                scf_file_path = os.path.join(self.logger.log_dir, scf_file_name)
                self.admin.get_current_scf_file(self.logger.log_dir, scf_file_path, timeout=60,
                                                connection=admin_connection, with_auto_configured_parameters=True)
            else:
                tc_path = self._safe_split(self.logger.log_dir, "/loop_")[0]
                if os.path.exists(tc_path):
                    scf_file_path = os.path.join(tc_path, scf_file_name)
                    self.admin.get_current_scf_file(tc_path, scf_file_path, timeout=60, connection=admin_connection,
                                                    with_auto_configured_parameters=True)
                else:
                    scf_file_path = os.path.join(self.logger.suite_folder, scf_file_name)
                    self.admin.get_current_scf_file(self.logger.suite_folder, scf_file_path, timeout=60,
                                                    connection=admin_connection, with_auto_configured_parameters=True)
            if update_scf_path:
                SCF.scf_file_path = scf_file_path
                info(f"Current SCF saved to {SCF.scf_file_path}")
                self.scf.load_scf(file_path=SCF.scf_file_path)
                if admin_connection == "remote":
                    SCF.remote_loaded = True
            else:
                info(f"SCF saved to {scf_file_path}")
                print("Load of file is not done and SCF.scf_file_path is not updated.")
            return scf_file_path
        except (AdminApiProcedureFailureException, AdminApiProcedureTimeoutException,
                AdminApiNoResponseException, AliasLookupError, AdminApiTerminatedException, AliasInUse,
                AdminApiConnectionClosedException) as e:
            error(f"Unable to get current SCF file. {e.__class__.__name__}:{e}")
            info(f"{''.join(format_exception(type(e), e, e.__traceback__))}")
            BuiltIn().set_suite_variable("${KW_SUCCESS}", "${False}")

    @staticmethod
    def get_path_of_current_scf_file():
        """
        Get path of current SCF file.
        """
        info(f"Path to current SCF file: {SCF.scf_file_path}")
        return SCF.scf_file_path

    def get_value_from_scf(self, dist_name, p_name, list_name=None, depth=0, retry=0, admin_connection="default",
                           allow_missing=False):
        """
        Get values from SCF.

        :param str dist_name: DistName from SCF.
        :param str p_name: Path name from SCF.
        :param str list_name: (Optional) name-attribute for list
        :param int depth: (Optional) Depth of the function. Default is 0.
        :param int retry: Retry after AttributeError, default is 0.
        :param str admin_connection: Default is default
        :param bool allow_missing: If True, method returns empty string if element is not found. If False, KeyError is
                                   raised if element is not found. Default is False (needed for optional parameters).
        :return str: Returns the value in SCF under distName and path name as string.
        """
        self.logger.debug(f"{dist_name}, {p_name}, {list_name}, {depth}, {retry}, {admin_connection}, {allow_missing}")
        used_scf = SCF.scf_file_path
        if admin_connection == "remote":
            used_scf = BuiltIn().get_variable_value("${REMOTE_SCF}", default="")
        self.logger.debug(f"SCF used_scf: {used_scf}")
        try:
            if not os.path.exists(used_scf) and not os.path.isfile(used_scf):
                print(f"Get SCF file from admin_connection '{admin_connection}' for get_value_from_scf method")
                if admin_connection != "remote":
                    self.get_scf(admin_connection=admin_connection)
                    used_scf = SCF.scf_file_path
                else:
                    used_scf = self.get_scf(extra_name="remote", admin_connection=admin_connection,
                                            update_scf_path=False)
                    self.scf.load_scf(file_path=used_scf)
            if admin_connection == "remote":
                # if not SCF.remote_loaded:
                self.scf.load_scf(file_path=used_scf)
                SCF.remote_loaded = True
            value_of_attribute = self.scf.get_value_from_scf(dist_name=dist_name, p_name=p_name, list_name=list_name)
            return value_of_attribute
        except KeyError:
            if allow_missing:
                info(f"Element {p_name} was not found from {dist_name}")
            else:
                warning("Element {} was not found from {}".format(p_name, dist_name))
            return ""
        except AttributeError as e:
            if depth >= 1:
                return ""
            if retry < 1:
                print(f"AttributeError: {e}. Try to load scf again and try again\n"
                      f"{''.join(format_exception(type(e), e, e.__traceback__))}")
            elif retry > 3:
                info(f"{''.join(format_exception(type(e), e, e.__traceback__))}")
                error(f"Method get_value_from_scf results to {e.__class__.__name__}:{e}")
                # raise EnvironmentIssue(f"{e.__class__.__name__}:{e}")
                return ""
            else:
                error(f"AttributeError: {e}. Try to load scf again and try again\n"
                      f"{''.join(format_exception(type(e), e, e.__traceback__))}")
            retry += 1
            self.scf.load_scf(file_path=used_scf)
            return self.get_value_from_scf(dist_name=dist_name, p_name=p_name, list_name=list_name, depth=depth + 1,
                                           retry=retry, allow_missing=allow_missing)

    def get_all_p_values(self, dist_name, p_name=None, list_name=None, retry=0):
        """
        Get all p values from SCF.

        :param str dist_name: distname for class.
        :param str p_name: (Optional) p-name for element.
        :param str list_name: (Optional) name-attribute for list
        :param int retry: If AttributeError try to load scf again
        :return list: Returns all p values for given parameters.
        """
        try:
            if not os.path.exists(SCF.scf_file_path):
                print("No SCF file, get SCF file for method get_all_p_values")
                self.get_scf()
            all_p_values = self.scf.get_all_values_from_scf(dist_name=dist_name, p_name=p_name, list_name=list_name)
            self.logger.debug(f"All p values for {dist_name}: {all_p_values}")
            return all_p_values
        except KeyError as e:
            warning(f"Element {p_name} or list {list_name} was not found from {dist_name}\n"
                    f"{''.join(format_exception(type(e), e, e.__traceback__))}")
            return []
        except AttributeError as e:
            if retry < 1:
                info(f"AttributeError: {e}. Try to load scf again and try again\n"
                     f"{''.join(format_exception(type(e), e, e.__traceback__))}")
            else:
                error(f"AttributeError: {e}. Try to load scf again and try again\n"
                      f"{''.join(format_exception(type(e), e, e.__traceback__))}")
            self.scf.load_scf(file_path=SCF.scf_file_path)
            self.get_all_p_values(dist_name, p_name=p_name, list_name=list_name, retry=1)

    def get_distname_based_on_class(self, class_name, admin_connection="default"):
        """
        Get distName based on class.

        :param str class_name: The class in question.
        :param str admin_connection: Default is default
        :return list(str) distname_list: Returns the distName based on class.
        """
        print(f"Get_distname_based_on_class from admin_connection: {admin_connection}")
        distname_list = []
        used_scf = SCF.scf_file_path
        if admin_connection == "remote":
            used_scf = BuiltIn().get_variable_value("${REMOTE_SCF}")
            if not os.path.exists(used_scf) or not os.path.isfile(used_scf):
                print("SCF from remote was not yet saved, get it")
                used_scf = self.get_scf(extra_name="remote", admin_connection=admin_connection, update_scf_path=False)
                print("Load remote scf in get_distname_based_on_class")
                self.scf.load_scf(file_path=used_scf)
                SCF.remote_loaded = True
            if not SCF.remote_loaded:
                self.scf.load_scf(file_path=used_scf)
                SCF.remote_loaded = True
        else:
            if not os.path.exists(used_scf) or not os.path.isfile(used_scf):
                print("SCF was not yet saved, get it")
                self.get_scf(admin_connection=admin_connection)
                used_scf = SCF.scf_file_path
        print(f"Parse class '{class_name}' from file {used_scf}")
        scf = parse(used_scf)
        root = scf.getroot()
        for managed_object in root[0]:
            mo_attributes = managed_object.attrib
            try:
                if self._check_class_name(class_name, mo_attributes["class"]):
                    distname_list.append(mo_attributes["distName"])
            except KeyError:
                pass
        return distname_list

    def get_class_dict(self, class_name):
        """
        Get all elements in a class.

        Example snippet of scf.xml:
        <managedObject class="com.nokia.srbts.eqm:BBMOD" distName="MRBTS-29250/EQM-1/APEQM-1/CABINET-1/BBMOD-1"
                       version="EQM23R1_2221_110" operation="create">
          <p name="administrativeState">Unlocked</p>
          <p name="fddNrCellConfigTradeoff">not used</p>
          <p name="prodCodePlanned">474020B.101</p>
          <p name="useFullCapacity">true</p>
        </managedObject>

        This would return a dictionary:
            {'MRBTS-29250/EQM-1/APEQM-1/CABINET-1/BBMOD-1':
                {'administrativeState': 'Unlocked',
                 'fddNrCellConfigTradeoff': 'not used',
                 'prodCodePlanned': '474020B.101',
                 'useFullCapacity': 'true'
                 }
            }

        :param str class_name: The class in scf. Does not require the full 'com.nokia.srbts.eqm:BBMOD' string, 'BBMOD'
                               is enough.
        :return str: Returns the element's value in class.
        """
        class_dict = {}
        if not os.path.exists(SCF.scf_file_path):
            self.get_scf()
        scf = parse(SCF.scf_file_path)
        root = scf.getroot()
        for managed_object in root[0].findall("{raml21.xsd}managedObject"):
            mo_attributes = managed_object.attrib
            try:
                if self._check_class_name(class_name, mo_attributes["class"]):
                    class_dict[mo_attributes["distName"]] = {}
                    for param in managed_object.findall("{raml21.xsd}p"):
                        class_dict[mo_attributes["distName"]][param.attrib["name"]] = param.text
                    for list_param in managed_object.findall("{raml21.xsd}list"):
                        list_name = list_param.attrib["name"]
                        class_dict[mo_attributes["distName"]][list_name] = []
                        for item in list_param.findall("{raml21.xsd}item"):
                            for param in item.findall("{raml21.xsd}p"):
                                class_dict[mo_attributes["distName"]][list_name].append(
                                    (param.attrib["name"], param.text))
                        for param in list_param.findall("{raml21.xsd}p"):
                            class_dict[mo_attributes["distName"]][list_name].append(param.text)
            except KeyError:
                pass
        return class_dict

    def get_element_based_on_class(self, class_name, element_name, child_element_name=""):
        """
        Get element value in a class.

        Example snippet of scf.xml:
        <raml xmlns="raml21.xsd" version="2.1">
            <cmData type="plan" scope="all" id="3833634170">
                <header>
                    <log action="create" dateTime="2022-12-21T11:05:38.372Z"/>
                </header>
                <managedObject class="com.nokia.srbts:MRBTS" distName="MRBTS-29250" version="SBTS23R1_2216_100"
                               operation="create">
                    <p name="btsName">2_11_UTESRAN042</p>
                </managedObject>

        :param str class_name: The class in scf.
        :param str element_name: The element in class.
        :param str child_element_name: (Optional) The child element in element.
        :return str: Returns the element's value in class.
        """
        if not os.path.exists(SCF.scf_file_path):
            self.get_scf()
        scf = parse(SCF.scf_file_path)
        root = scf.getroot()
        for managed_object in root[0].findall("{raml21.xsd}managedObject"):
            if self._check_class_name(class_name, managed_object.attrib["class"]):
                for element in managed_object:
                    if element.attrib["name"] == element_name:
                        print(f"element attribute: {element.attrib}, element tag: {element.tag},"
                              f"element text: {element.text}")
                        if child_element_name:
                            if "list" in element.tag:
                                for child in list(element):
                                    print(f"child element attribute: {child.attrib}, child element tag: {child.tag},"
                                          f"child element text: {child.text}")
                                    if "no_name_value_in_list" in child_element_name:
                                        return child.text
                                    if "item" in child.tag:
                                        for list_child in list(child):
                                            print(
                                                f"list child element attribute: {child.attrib}, list child element tag:"
                                                f" {list_child.tag}, list child element text: {list_child.text}")
                                            if "name" in list_child.attrib:
                                                if list_child.attrib["name"] == child_element_name:
                                                    return list_child.text
                        return element.text
        return ""

    def check_admin_response(self, admin_response, raise_error=True):
        """
        Check response from admin to commissioning request.

        :param dict admin_response: Response from admin to commissioning request.
        :param bool raise_error: (OPTIONAL) True if error should be raised. Default value is True.
        """
        if not admin_response:
            error("Problems in commissioning with file. No response from admin was received.")
            BuiltIn().set_suite_variable("${KW_SUCCESS}", "${False}")
            raise EnvironmentIssue("No response from admin was received for commissioning request.")
        self._check_if_validation_ok(admin_response, raise_error)
        self._check_if_commissioning_result_ok(admin_response, raise_error)

    def perform_commissioning_with_scf_file(self, commissioning_file=None, create_own_connection=True,
                                            commissioning_connection="log_admin"):
        """
        Performs a commissioning using the SCF.

        :param str commissioning_file: (Optional) Set to None if not given. Path to the commissioning file.
                                        NOTE: If set to None, uses an earlier fetched SCF.
        :param bool create_own_connection: (Optional) Set to True if own connection is needed. Default is True.
        :param str commissioning_connection: (Optional) Connection name to be used for commissioning. Default is
                                             log_admin.
        """
        if not os.path.exists(SCF.scf_file_path):
            self.get_scf()
        try:
            if create_own_connection:
                commissioning_connection = "scf"
                self.logger.debug(
                    "Make extra bts connection to ip 192.168.255.129.\nNOTE there is need for this because bts may be "
                    "in not commissioned state and because of that M-Plane ip is not replying, if it is used.")
                bts = BuiltIn().get_library_instance("BTS")
                release = bts.get_sw_release_via_targetbd()
                self.admin.connect_to(
                    bts_host='192.168.255.129', admin_api_log_dir=self.logger.create_admin_folder(), name='scf',
                    release=release)
            if not commissioning_file:
                commissioning_file = SCF.scf_file_path
                info("Use earlier fetched SCF as a commissioning file {}".format(commissioning_file))
            else:
                info("Use {} as a commissioning file".format(commissioning_file))
            info("Performing commissioning with file {} ...".format(commissioning_file))
            admin_response = self.admin.perform_commissioning(
                scf_file=commissioning_file, skip_parameter_relation_errors=False, should_activate=True, timeout=900,
                connection=commissioning_connection)
            self.check_admin_response(admin_response)
        except (AdminApiProcedureFailureException, AdminApiProcedureTimeoutException, AdminApiNoResponseException,
                AliasLookupError, AdminApiTerminatedException, AliasInUse,
                AdminApiConnectionClosedException) as admin_error:
            BuiltIn().set_suite_variable("${COMMISSIONING_TRIGGERED_RESET}", "${False}")
            error(f"Problems when performing commissioning with file {commissioning_file}. "
                  f"{admin_error.__class__.__name__} was raised.\n"
                  f"{''.join(format_exception(type(admin_error), admin_error, admin_error.__traceback__))}")
            BuiltIn().set_suite_variable("${KW_SUCCESS}", "${False}")
            info(f"Admin responses with error:{admin_error}")
            raise CommissioningFailure(f"Problems when performing commissioning, {admin_error.__class__.__name__} was"
                                       f" raised.")
        finally:
            if create_own_connection:
                self._teardown_scf_admin()
        info("Commissioning done.")

    def get_ips_from_scf(self, mme=True, oms=False, sgw=False, top=True, ntp=True):
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
            ip_dict["MME"] = self.get_element_based_on_class("NOKLTE:LNMME", "ipAddrPrim")
        if oms:
            ip_dict["OMS"] = self.get_element_based_on_class("NOKLTE:IPNO", "oamIpAddr")
        if sgw:
            ip_dict["SGW"] = self.get_element_based_on_class("NOKLTE:GTPU", "sgwIpAddressList", "sgwIpAddress")
        if top:
            ip_dict["TOPF"] = self.get_element_based_on_class("com.nokia.srbts.mnl:TOPF", "topMasterList",
                                                              "masterIpAddr")
        if ntp:
            ip_dict["NTP"] = self.get_element_based_on_class("com.nokia.srbts.mnl:NTP", "ntpServerIpAddrOrFqdnList",
                                                             "no_name_value_in_list")
        info(f"IPs parsed from SCF file: {ip_dict}")
        return ip_dict

    def _teardown_scf_admin(self):
        """Teardown scf admin connection. """
        try:
            self.logger.debug("Disconnect scf admin connection")
            self.admin.teardown(connection="scf")
        except (AttributeError, TypeError, ValueError, IndexError, AliasLookupError,
                AdminApiProcedureFailureException, AdminApiProcedureTimeoutException, AdminApiNoResponseException,
                AdminApiTerminatedException, AdminApiConnectionClosedException, AliasInUse) as e:
            self.logger.debug(f"While tearing down scf admin connection, ERROR {e.__class__.__name__}:{e}\n"
                              f"{''.join(format_exception(type(e), e, e.__traceback__))}")
            print(f"While tearing down scf admin connection, ERROR {e.__class__.__name__}:{e}")

    @staticmethod
    def _check_class_name(user_class_name, scf_class_name):
        if ":" not in user_class_name and ":" in scf_class_name:
            return user_class_name == scf_class_name.split(":")[-1]
        else:
            return user_class_name == scf_class_name

    def _raise_error_if_needed(self, raise_error, error_text):
        """
        Raise error if needed. Raise error or only print info.

        :param bool raise_error: True if error should be raised.
        :param str error_text: Error text to print.
        """
        self.logger.debug("Problem noticed. Check if error should be raised or if only info should be printed.")
        if raise_error:
            error(f"Problems in commissioning with file. {error_text}")
            BuiltIn().set_suite_variable("${KW_SUCCESS}", "${False}")
            raise EnvironmentIssue(f"{error_text}")
        else:
            info(f"Problems in commissioning with file. {error_text}")

    def _check_status(self, admin_response, status_key, raise_error, upper_key=""):
        """
        Check status of given key in admin response. If status is FAIL, raise error if needed.
        :param dict admin_response: Response from admin to commissioning request.
        :param str status_key: Key in admin response to check. For example niddValidationResult.
        """
        if upper_key:
            self.logger.debug(f"Check status of {status_key} of {upper_key}.")
            if upper_key in admin_response:
                if status_key in admin_response[upper_key] and "status" in admin_response[upper_key][status_key]:
                    if admin_response[upper_key][status_key]["status"] == "FAIL":
                        self._raise_error_if_needed(raise_error, f"{status_key} was FAIL.")
                    else:
                        info(f"{status_key} was OK.")
        else:
            self.logger.debug(f"Check status of {status_key}.")
            if status_key in admin_response and "status" in admin_response[status_key]:
                if admin_response[status_key]["status"] == "FAIL":
                    self._raise_error_if_needed(raise_error, f"{status_key} was FAIL.")
                else:
                    info(f"{status_key} was OK.")

    def _check_if_validation_ok(self, admin_response, raise_error):
        """
        Check if validation ok. If not, raise error if raise_error is True, otherwise just print info.

        :param dict admin_response: Response from admin to commissioning request.
        :param bool raise_error: True if error should be raised.
        """
        info("Checking if commissioning file validation was ok...")
        if "validationResult" not in admin_response:
            self.logger.debug("No validationResult in response from admin. Most likely validation was fail.")
            self._check_status(admin_response, "niddValidationResult", raise_error)
            self._check_status(admin_response, "pdlValidationResult", raise_error)
            if "niddValidationResult" not in admin_response and "pdlValidationResult" not in admin_response:
                self._raise_error_if_needed(raise_error, "No validationResult, niddValidationResult nor "
                                                         "pdlValidationResult in response from admin.")
        else:
            self.logger.debug("validationResult in response from admin.")
            if ("niddValidationResult" not in admin_response["validationResult"] or "pdlValidationResult" not in
                    admin_response["validationResult"]):
                self._raise_error_if_needed(raise_error, "No niddValidationResult and no pdlValidationResult in "
                                                         "validationResult in response from admin.")
            self._check_status(admin_response, "niddValidationResult", raise_error, "validationResult")
            self._check_status(admin_response, "pdlValidationResult", raise_error, "validationResult")

    def _check_if_commissioning_result_ok(self, admin_response, raise_error):
        """
        Check if commissioning result is ok. If not, raise error if raise_error is True, otherwise just print info.

        :param dict admin_response: Response from admin to commissioning request.
        :param bool raise_error: True if error should be raised.
        """
        self.logger.debug("Check if commissioning result is ok")
        if "commissioningResult" not in admin_response:
            self._raise_error_if_needed(raise_error, "No commissioningResult in response from admin.")
        elif "isGoingToTriggerReset" not in admin_response["commissioningResult"]:
            self._raise_error_if_needed(raise_error, "No isGoingToTriggerReset in commissioningResult in response from"
                                                     " admin.")
        elif admin_response['commissioningResult']['isGoingToTriggerReset']:
            info("Admin responses that commissioning is going to trigger reset.")
            BuiltIn().set_suite_variable("${COMMISSIONING_TRIGGERED_RESET}", "${True}")
        elif not admin_response['commissioningResult']['isGoingToTriggerReset']:
            info("Admin responses that commissioning is not going to trigger any reset.")
        else:
            self._raise_error_if_needed(raise_error,
                                        f"The value of isGoingToTriggerReset in response from admin has value "
                                        f"{admin_response['commissioningResult']['isGoingToTriggerReset']}, it should "
                                        f"have true or false.")

    def _disable_enforcedrecovtimewindow(self, object_distname):
        timestamp = datetime.now().strftime("%Y%m%d%H%M%S")
        path_to_delta_file = os.path.join(self.logger.log_dir, f"enforced_recovery_{timestamp}.json")
        try:
            self.admin.create_delta("enforced_recovery")
            self.admin.append_parameter_update_to_delta(object_distname, "enforcedRecovTimeWindow",
                                                        "Enforced recovery disabled",
                                                        delta_id="enforced_recovery")
            self.admin.save_delta(path_to_delta_file, delta_id="enforced_recovery")
            info(f"Delta commissioning file is saved to {path_to_delta_file}")
            commissioning_result = self.admin.perform_delta_recommissioning(path_to_delta_file,
                                                                            skip_parameter_relation_errors=True)
            info("Delta commissioning finished.")
            self.logger.debug(f"Result: {commissioning_result}")
            return True
        except (AdminApiProcedureFailureException, AdminApiProcedureTimeoutException,
                AdminApiNoResponseException, AliasLookupError, AdminApiTerminatedException, AliasInUse,
                AdminApiConnectionClosedException) as admin_error:
            error(f"Problems when performing delta commissioning with file {path_to_delta_file}."
                  f"{admin_error.__class__.__name__}:{admin_error}.")
            info(f"{''.join(format_exception(type(admin_error), admin_error, admin_error.__traceback__))}")
        return False

    def check_if_enforcedrecovtimewindow_enabled_and_disable_it(self):
        """
        Checks if enforcedRecovTimeWindow of class com.nokia.srbts.mnl:FEATCADM is enabled and disable it.
        Change:
            <p name=enforcedRecovTimeWindow>Enforced recovery enabled within 0 - 60 minutes</p>.
        To:
            <p name=enforcedRecovTimeWindow>Enforced recovery disabled</p>.
        :raise IndexError: If the com.nokia.srbts.mnl:FEATCADM is not found from commissioning.
        """
        try:
            object_distname = self.get_distname_based_on_class("com.nokia.srbts.mnl:FEATCADM")[0]
            enforced = self.get_value_from_scf(dist_name=object_distname, p_name="enforcedRecovTimeWindow")
            self.logger.debug(f"Value of enforcedRecovTimeWindow: {enforced}")
            if "enforced recovery disabled" in enforced.lower():
                info(f"enforcedRecovTimeWindow already has value '{enforced}' no need to for recommissioning.")
                return True
            else:
                if self._disable_enforcedrecovtimewindow(object_distname):
                    info("Value of enforcedRecovTimeWindow is successfully set to 'Enforced recovery disabled'")
                else:
                    error("There were problems with delta commissioning. The value of enforcedRecovTimeWindow is not "
                          f"changed to 'Enforced recovery disabled', it still is {enforced}. Set KW_SUCCESS to False.")
                    BuiltIn().set_suite_variable("${KW_SUCCESS}", "${False}")
        except IndexError as e:
            info(f"{''.join(format_exception(type(e), e, e.__traceback__))}")
            error("Could not find com.nokia.srbts.mnl:FEATCADM value, cannot check if fault signature is enabled.")

    def load_scf_file(self, used_scf):
        """
        Load scf file.
        :param str used_scf: path to scf file to be load
        """
        self.scf.load_scf(file_path=used_scf)

    @staticmethod
    def change_list_items_to_scf(scf_file, class_name, list_name, parameters_to_change):
        """
        Change values of list items to scf file.

        :param str scf_file: Path to scf file.
        :param str class_name: Class name of the object.
        :param str list_name: Name of the list in the object.
        :param dict parameters_to_change: Dictionary of parameters to change with parameter name as key and
        """
        if not os.path.exists(scf_file):
            raise FileNotFoundError(f"SCF file {scf_file} does not exist.")
        if not class_name:
            raise ScriptIssue("Class name cannot be empty.")
        if not list_name:
            raise ScriptIssue("List name cannot be empty.")
        if not parameters_to_change or not isinstance(parameters_to_change, dict):
            raise ScriptIssue("Parameters to change must be a non-empty dictionary.")
        try:
            etree.register_namespace("", 'raml21.xsd')
            tree = etree.parse(scf_file)
            root = tree.getroot()
            for managed_object in root.findall('.//*[@class="{}"]'.format(class_name)):
                param_list = managed_object.find('.*[@name="{}"]'.format(list_name))
                for parameter, value in parameters_to_change.items():
                    for parameter_name in param_list[0].findall('.*[@name="{}"]'.format(parameter)):
                        parameter_name.text = value
            tree.write(scf_file, xml_declaration=True, method='xml', encoding="utf8", default_namespace=None)
            info(f"Save modified scf file to {scf_file}")
        except Exception as e:
            info(f"{''.join(format_exception(type(e), e, e.__traceback__))}")
            raise ScriptIssue(f"An error occurred while modifying the SCF file: {e.__class__.__name__}:{e}")

    @staticmethod
    def _get_version_from_class(class_name, root):
        """
        Get version from class.

        :param str class_name: The class in question.
        :return str: Returns the version based on class.
        """
        version = ""
        distname = ""
        for mo in root.iter('{raml21.xsd}managedObject'):
            if mo.attrib.get('class') == class_name:
                version = mo.attrib.get('version')
                distname = mo.attrib.get('distName')
                break
        if not version or not distname:
            error(f"Class {class_name} not found from SCF file. Check that you have given correct RAT for this test and"
                  f" environment (value for parameter SELECTED_RAT).")
            raise InvalidUserInput(f"Class {class_name} not found from SCF.xml.")
        return version, distname

    @staticmethod
    def add_power_save_window_managed_object_to_scf(scf_file, managedobject_class, lbps_period_dict,
                                                    cells_for_lbpscelllist):
        """
        Add power save window managed object to scf file.

        :param str scf_file: Path to scf file.
        :param str managedobject_class: Class of the managed object.
        :param dict lbps_period_dict: Dictionary with lbps period start and end times.
        :param list cells_for_lbpscelllist: List of cells for lbpsCellList
        """
        if not os.path.exists(scf_file):
            raise FileNotFoundError(f"SCF file {scf_file} does not exist.")
        try:
            etree.register_namespace("", 'raml21.xsd')
            tree = etree.parse(scf_file)
            root = tree.getroot()
            cm_data = root.find('{raml21.xsd}cmData')
            header = cm_data.find('{raml21.xsd}header')
            # log = header.find('{raml21.xsd}log')
            # timestamp = log.attrib.get('dateTime', datetime.now().strftime("%Y-%m-%dT%H:%M:%S.%fZ"))
            if "NOKLTE" in managedobject_class:
                version, distname_of_class = SCF._get_version_from_class("NOKLTE:LNBTS", root)
                distname_of_class = f"{distname_of_class}/PSGRP-1"
            else:
                version, distname_of_class = SCF._get_version_from_class("com.nokia.srbts.nrbts:NRBTS", root)
                distname_of_class = f"{distname_of_class}/NRPGRP-0"
            new_managed_object = etree.Element('managedObject', attrib={
                'class': managedobject_class,
                'distName': distname_of_class,
                'version': version,
                'operation': 'create'
            })
    # lbpsCellList
            lbpsCellList = etree.SubElement(new_managed_object, '{raml21.xsd}list', {'name': 'lbpsCellList'})
            for cell_id in cells_for_lbpscelllist:
                item = etree.SubElement(lbpsCellList, '{raml21.xsd}item')
                etree.SubElement(item, '{raml21.xsd}p', {'name': 'lbpsCellSOOrder'}).text = '100'
                etree.SubElement(item, '{raml21.xsd}p', {'name': 'lbpsUseExtConfig'}).text = 'false'
                if "NOKLTE" in managedobject_class:
                    etree.SubElement(item, '{raml21.xsd}p', {'name': 'lnCelId'}).text = cell_id
                elif "nrbts:NRPGRP":
                    etree.SubElement(item, '{raml21.xsd}p', {'name': 'nrCellId'}).text = cell_id
    # lbpsPeriod
            lbps_period_list = etree.SubElement(new_managed_object, '{raml21.xsd}list', {'name': 'lbpsPeriodList'})
            item = etree.SubElement(lbps_period_list, '{raml21.xsd}item')
            for lbts_key, lbts_value in lbps_period_dict.items():
                etree.SubElement(item, '{raml21.xsd}p', {'name': str(lbts_key)}).text = str(lbts_value)
            p_values = [
                ('lbpsLastCellMinLoad', '100'),
                ('lbpsLastCellSOEnabled', 'true')
            ]
            # ('lbpsLastCellRTXMinLoad', '0'),
            # ('lbpsLoadCalcMethod', 'Max(G, W, P)'),
            # ('lbpsMaxLoad', '100'),
            # ('lbpsMonWinForCellSOff', '300'),
            # ('lbpsMonWinForCellSOn', '120'),
            # ('lbpsMonWinForRtxSOff', '300'),
            # ('lbpsMonWinForRtxSOn', '120'),
            # ('lbpsRTXCellCapOffset', '80'),
            # ('lbpsRTXMaxLoad', '60'),
            # ('lbpsRTXMinLoad', '20'),
            # ('lbpsSOMethod', 'Cell Switch Off'),
            # ('lbpsSOffTrRule', 'MaxValueMethod'),
            # ('lbpsSOnTrRule', 'MinValueMethod'),
            for name, value in p_values:
                etree.SubElement(new_managed_object, '{raml21.xsd}p', {'name': name}).text = value
            # Append to cmData
            cm_data.append(new_managed_object)
            # Write back
            tree.write(scf_file, encoding='utf-8', xml_declaration=True)
            info(f"Added power saving managed object {managedobject_class} to {scf_file}")
        except Exception as e:
            info(f"{''.join(format_exception(type(e), e, e.__traceback__))}")
            raise ScriptIssue(f"An error occurred while adding the {managedobject_class} managed object: "
                              f"{e.__class__.__name__}:{e}")

    @staticmethod
    def modify_power_save_window_to_scf(scf_file, managedobject_class, lbps_period_dict, cells_for_lbpscelllist):
        """
        Modify power save window to scf file.

        :param str scf_file: Path to scf file.
        :param str managedobject_class: Class of the managed object.
        :param dict lbps_period_dict: Dictionary with lbps period start and end times.
        :param list cells_for_lbpscelllist: List of cells for lbpsCellList
        """
        if not os.path.exists(scf_file):
            raise FileNotFoundError(f"SCF file {scf_file} does not exist.")
        try:
            etree.register_namespace("", 'raml21.xsd')
            tree = etree.parse(scf_file)
            root = tree.getroot()
            cm_data = root.find('{raml21.xsd}cmData')
            header = cm_data.find('{raml21.xsd}header')
            if "NOKLTE" in managedobject_class:
                class_name = "NOKLTE:PSGRP"
                cell_id = 'lnCelId'
            else:
                class_name = "com.nokia.srbts.nrbts:NRPGRP"
                cell_id = 'nrCellId'
            found_cells = []
            for mo in root.iter('{raml21.xsd}managedObject'):
                if mo.attrib.get('class') == class_name:
                    for lbps_list in mo.findall('{raml21.xsd}list'):
                        if lbps_list.attrib.get('name') == 'lbpsCellList':
                            items_to_remove = []
                            for item in lbps_list.findall('{raml21.xsd}item'):
                                for p in item.findall('{raml21.xsd}p'):
                                    if p.attrib.get('name') == "lbpsCellSOOrder":
                                        if p.text != '100':
                                            info(f"Modify lbpsCellSOOrder value to 100 from {p.text}")
                                            p.text = '100'
                                        else:
                                            info(f"lbpsCellSOOrder value already 100, no need to modify.")
                                    elif p.attrib.get('name') == "lbpsUseExtConfig":
                                        if p.text != 'false':
                                            info(f"Modify lbpsUseExtConfig value to false from {p.text}")
                                            p.text = 'false'
                                        else:
                                            info(f"lbpsUseExtConfig value already false, no need to modify.")
                                    if p.attrib.get('name') == cell_id:
                                        found_cells.append(p.text)
                                        if p.text not in cells_for_lbpscelllist:
                                            info(f"Remove cell {p.text} item from lbpsCellList in scf file.")
                                            items_to_remove.append(item)
                                        else:
                                            info(f"Cell {p.text} already is in lbpsCellList in scf file.")
                            for item in items_to_remove:
                                lbps_list.remove(item)
                            missing_cells = [cell for cell in cells_for_lbpscelllist if cell not in found_cells]
                            if missing_cells:
                                info(f"Cells {missing_cells} are missing from lbpsCellList, add them now.")
                                for cell_id_value in missing_cells:
                                    item = etree.SubElement(lbps_list, '{raml21.xsd}item')
                                    etree.SubElement(item, '{raml21.xsd}p', {'name': 'lbpsCellSOOrder'}).text = '100'
                                    etree.SubElement(item, '{raml21.xsd}p', {'name': 'lbpsUseExtConfig'}).text = 'false'
                                    etree.SubElement(item, '{raml21.xsd}p', {'name': cell_id}).text = cell_id_value
                            else:
                                info("No missing cells to add to lbpsCellList.")
                        elif lbps_list.attrib.get('name') == 'lbpsPeriodList':
                            for item in lbps_list.findall('{raml21.xsd}item'):
                                for lbts_key, lbts_value in lbps_period_dict.items():
                                    for p in item.findall('{raml21.xsd}p'):
                                        if p.attrib.get('name') == lbts_key:
                                            if p.text != str(lbts_value):
                                                info(f"Modify {lbts_key} value to {lbts_value} from {p.text}")
                                                p.text = str(lbts_value)
                                            else:
                                                info(f"{lbts_key} value already {lbts_value}, no need to modify.")
            # Write back
            tree.write(scf_file, encoding='utf-8', xml_declaration=True)
            info(f"Modified power saving managed object {managedobject_class} to {scf_file}")
        except Exception as e:
            info(f"{''.join(format_exception(type(e), e, e.__traceback__))}")
            raise ScriptIssue(f"An error occurred while adding the {managedobject_class} managed object: "
                              f"{e.__class__.__name__}:{e}")

    @staticmethod
    def _safe_split(value, sep):
        """Safely split values that may be None; returns list from splitting str(value)."""
        if value is None:
            return [""]
        return str(value).split(sep)
