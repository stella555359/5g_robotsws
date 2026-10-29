from taf.selenium.gnb.oam.coam.cu import cu as cu_selenium
from moler.util.moler_test import MolerTest
from taf.gnb.oam.coam.cu import cu as cu_admin
from taf.gnb.oam.coam.cu.exception import AuthenticationFailed
from robot.libraries.BuiltIn import BuiltIn
from testsuite.Krakow.resources.routing_table.moler_keywords import MolerKeywords
from functools import wraps
import logging
import re


def admin_connect(web_fun):
    @wraps(web_fun)
    def wrapper(self, *args, **kwargs):
        host = self.cu_address if self.cu_address.count(".") == 3 else "[{}]".format(self.cu_address)
        self.cu_admin_connection.connect_to(host=host, port="443", username=self.cu_user,
                                            password=self.cu_password,
                                            cu_version='cuoam_21b', secure=True)
        try:
            result = web_fun(self, *args, **kwargs)
            return result
        finally:
            self.cu_admin_connection.disconnect()

    return wrapper


def selenium_connect(web_fun):
    @wraps(web_fun)
    def wrapper(self, *args, **kwargs):
        host = self.cu_address if self.cu_address.count(".") == 3 else "[{}]".format(self.cu_address)
        self.cu_selenium_connection.enable_virtual_display()
        self.cu_selenium_connection.login('https://{}/'.format(host), self.cu_user, self.cu_password)
        try:
            result = web_fun(self, *args, **kwargs)
            return result
        finally:
            self.cu_selenium_connection.logout()

    return wrapper


class CuWebem:
    def __init__(self):
        tl = BuiltIn().get_variable_value('${{{}}}'.format("tl"), None)
        self.cu_address = tl.gnbs[0].cu.backhaul_site_oam_ip
        self.cu_user = tl.gnbs[0].cu.oam_http_connection_details.username
        self.cu_password = tl.gnbs[0].cu.oam_http_connection_details.password
        self.cu_selenium_connection = cu_selenium()
        self.cu_admin_connection = cu_admin()
        self.cu_instance_id = tl.gnbs[0].cu.instance_id
        self.moler_keywords = MolerKeywords()

    @admin_connect
    def perform_cu_commissioning(self, path_to_scf, should_fail=False):
        """
        Load defined scf file with validation, activation and waiting for operation success.

        :return: None
        """
        plan_info = self.cu_admin_connection.upload_plan_file(path_to_plan_file=path_to_scf)
        MolerTest.sleep(15)
        plan_id = plan_info["plan_id"]
        self.cu_admin_connection.plan_validation(plan_id=plan_id)
        MolerTest.sleep(15)
        activation_id = self.cu_admin_connection.plan_activation(plan_id=plan_id)["id"]
        logging.info("Activation of scf plan ongoing ...")
        MolerTest.sleep(180)
        activation_state = self.cu_admin_connection.get_operation_state_of_activating_plan(plan_id, activation_id)
        logging.debug(activation_state)
        if activation_state["status"] == "success":
            logging.info("Activation of scf plan finished with success")
        else:
            if should_fail:
                return
            logging.error("Activation of scf plan CANNOT be performed")

    @admin_connect
    def validate_and_activate_delta_plan_with_admin(self):
        """
        Validate and activate delta plan with waiting for success.

        :return: None
        """
        delta_plan_id = self.cu_admin_connection.get_delta_plan_list()[0]["plan_id"]
        self.cu_admin_connection.validate_delta_plan(plan_id=delta_plan_id)
        MolerTest.sleep(15)
        activation_id = self.cu_admin_connection.activate_delta_plan(plan_id=delta_plan_id)["operation_id"]
        activate_ongoing = True
        while activate_ongoing:
            activate_info = self.cu_admin_connection.get_operation_state_of_activating_delta_plan(delta_plan_id,
                                                                                                  activation_id)
            logging.info("Activation of delta plan ongoing ...")
            if activate_info["status"] == "failure":
                activate_ongoing = False
                logging.info("Activation of delta plan finished with success")
            MolerTest.sleep(15)
        self.cu_admin_connection.delete_delta_plan(delta_plan_id)

    @admin_connect
    def cu_change_bts_name_via_admin(self):
        """
        Firstly change BTS name parameter via admin API, secondly change this parameter to previous value.

        :return: None
        """
        old_bts_name = self.get_object_parameters_dict(dist_name="MRBTS-392", connection=self.cu_admin_connection)[
            "btsName"]
        plan_id = self.cu_admin_connection.generate_delta_plan("plan_1")["plan_id"]
        mo_uuid = self.cu_admin_connection.search_parameters_of_current_plan("btsName")['items'][0]['mo_uuid']
        self.cu_admin_connection.update_parameters_of_delta_plan(plan_id, mo_uuid,
                                                                 [{"operation_type": "replace",
                                                                   "parameter_path": '/btsName',
                                                                   "value": "CU_custom_name"}])

        self.validate_and_activate_delta_plan_with_admin()
        plan_id = self.cu_admin_connection.generate_delta_plan("plan_1")["plan_id"]
        mo_uuid = self.cu_admin_connection.search_parameters_of_current_plan("btsName")['items'][0]['mo_uuid']
        self.cu_admin_connection.update_parameters_of_delta_plan(plan_id, mo_uuid,
                                                                 [{"operation_type": "replace",
                                                                   "parameter_path": '/btsName',
                                                                   "value": old_bts_name}])
        self.validate_and_activate_delta_plan_with_admin()
        self.cu_admin_connection.disconnect()

    @admin_connect
    def get_icmpResponseEnabled_flag_state(self):
        items = self.cu_admin_connection.search_parameters_of_current_plan("icmpResponseEnabled")["items"]
        flag = items[0]["parameter"]["simple_parameter"]["value"]
        return flag

    def get_cu_instance_id(self):
        return self.cu_instance_id

    @admin_connect
    def delete_delta_plan(self):
        """
        Delete actual delta plan with admin API.

        :return: None
        """
        delta_plan_list = self.cu_admin_connection.get_delta_plan_list()
        if delta_plan_list:
            delta_plan_id = delta_plan_list[0]["plan_id"]
            self.cu_admin_connection.delete_delta_plan(delta_plan_id)

    def cu_login_via_selenium(self):
        """
        Check possibility to login and logout with selenium.

        :return: None
        """
        self.cu_selenium_connection.login('https://{}/'.format(self.cu_address), self.cu_user, self.cu_password)
        self.cu_selenium_connection.logout()

    @selenium_connect
    def change_bts_name_via_selenium(self):
        """
        Firstly change BTS name parameter with selenium, secondly change this parameter to previous value.

        :return: None
        """
        old_name = self.cu_selenium_connection.get_parameter_value("MRBTS-{}".format(self.cu_instance_id), "BTS name",
                                                                   "btsName")
        self.cu_selenium_connection.create_delta_plan("plan_1")
        self.cu_selenium_connection.set_parameter_value("MRBTS-{}".format(self.cu_instance_id), "BTS name", "btsName",
                                                        "CU_99")
        self.cu_selenium_connection.expand_model_object_tree("MRBTS-{}".format(self.cu_instance_id))
        MolerTest.sleep(5)
        self.cu_selenium_connection.validate_plan()
        self.cu_selenium_connection.activate_plan(activate_plan_despite_reset=True,
                                                  activate_plan_despite_cell_locking=True)
        self.delete_delta_plan()
        self.cu_selenium_connection.login('https://{}/'.format(self.cu_address), 'Nemuadmin', 'nemuuser')
        self.cu_selenium_connection.create_delta_plan("plan_1")
        self.cu_selenium_connection.set_parameter_value("MRBTS-{}".format(self.cu_instance_id), "BTS name", "btsName",
                                                        old_name)
        self.cu_selenium_connection.expand_model_object_tree("MRBTS-{}".format(self.cu_instance_id))
        MolerTest.sleep(5)
        self.cu_selenium_connection.validate_plan()
        self.cu_selenium_connection.activate_plan(activate_plan_despite_reset=True,
                                                  activate_plan_despite_cell_locking=True)
        self.delete_delta_plan()

    @staticmethod
    def get_object_parameters_dict(dist_name, connection):
        """
        Create python dictionary from current scf content.

        :param dist_name: str, full class path to target object (e.g "MRBTS-1/NRBTS-1/NRCELL-1")
        :param connection: AdminConnection object or if used, string name alias
        :return: dict: parameters and values in form of dictionary
        """
        bts_configuration = connection.get_current_plan_file(path='test.txt', timeout=30)
        ret = str(bts_configuration).partition('distName="{}"'.format(dist_name))[2].partition('</managedObject>')[0]
        re_parameter_and_value = r'\s+<p\s\w+=.(?P<KEY>\w+).>(?P<VALUE>.*)</p>'
        ret_dict = dict()
        for line in ret.splitlines():
            determinate_parameter = re.search(re_parameter_and_value, line)
            if determinate_parameter:
                ret_dict[determinate_parameter.group('KEY')] = determinate_parameter.group('VALUE')
        return ret_dict

    @selenium_connect
    def get_scf_file_via_selenium(self):
        path = self.cu_selenium_connection.save_bts_configuration()
        return path

    @selenium_connect
    def add_ipv4_route_via_selenium(self, dist_name, addr, gateway):
        """
        Add ipv4 route on CU.

        :return: None
        """
        self.delete_delta_plan()
        self.cu_selenium_connection.create_delta_plan("plan_1")
        self.cu_selenium_connection.choose_plan("plan_1")
        self.cu_selenium_connection.add_element(dist_name.format(self.cu_instance_id),
                                                "List of static IPv4 routes", "staticRoutes",
                                                structure_items={"destIpAddr": addr, "destinationIpPrefixLength": "24",
                                                                 "gateway": gateway, })
        self.cu_selenium_connection.validate_plan()
        self.cu_selenium_connection.activate_plan(activate_plan_despite_reset=True,
                                                  activate_plan_despite_cell_locking=True)
        self.delete_delta_plan()

    @selenium_connect
    def add_ipv6_route_via_selenium(self, dist_name, addr, gateway):
        """
        Add ipv4 route on CU.

        :return: None
        """
        self.delete_delta_plan()
        self.cu_selenium_connection.create_delta_plan("plan_1")
        self.cu_selenium_connection.add_element(dist_name.format(self.cu_instance_id),
                                                "Static IPv6 routes", "staticIpv6Routes")
        self.cu_selenium_connection.collapse_model_object("MRBTS-{}".format(self.cu_instance_id))
        self.cu_selenium_connection.set_parameter_value(dist_name.format(self.cu_instance_id),
                                                        "Destination IPv6 address of the route", "destIpv6Addr", addr)
        self.cu_selenium_connection.collapse_model_object("MRBTS-{}".format(self.cu_instance_id))
        self.cu_selenium_connection.set_parameter_value(dist_name.format(self.cu_instance_id),
                                                        "Destination IPv6 prefix length",
                                                        "destinationIpv6PrefixLength", "64")
        self.cu_selenium_connection.collapse_model_object("MRBTS-{}".format(self.cu_instance_id))
        self.cu_selenium_connection.set_parameter_value(dist_name.format(self.cu_instance_id),
                                                        "Gateway IPv6 address", "gatewayIpv6Addr",
                                                        gateway)
        self.cu_selenium_connection.collapse_model_object("MRBTS-{}".format(self.cu_instance_id))
        self.cu_selenium_connection.validate_plan()
        self.cu_selenium_connection.activate_plan(activate_plan_despite_reset=True,
                                                  activate_plan_despite_cell_locking=True)
        self.delete_delta_plan()

    @selenium_connect
    def delete_ipv4_route(self, dist_name, structure):
        """
        Add ipv4 route on CU.

        :structure: structure to be deleted
        :return: None
        """
        self.delete_delta_plan()
        self.cu_selenium_connection.create_delta_plan("plan_1")
        self.cu_selenium_connection.remove_element(dist_name.format(self.cu_instance_id),
                                                   "List of static IPv4 routes", "staticRoutes",
                                                   "Structure {}".format(structure))
        self.cu_selenium_connection.validate_plan()
        self.cu_selenium_connection.activate_plan(activate_plan_despite_reset=True,
                                                  activate_plan_despite_cell_locking=True)
        self.delete_delta_plan()

    @selenium_connect
    def delete_ipv4_route_via_selenium(self, dist_name):
        """
        Add ipv4 route on CU.

        :return: None
        """
        self.cu_selenium_connection.create_delta_plan("plan_1")
        self.cu_selenium_connection.remove_element(dist_name.format(self.cu_instance_id),
                                                   "Static IPv6 routes", "staticIpv6Routes", "Structure 1")
        self.cu_selenium_connection.expand_model_object_tree("MRBTS-{}".format(self.cu_instance_id))
        MolerTest.sleep(5)
        self.cu_selenium_connection.validate_plan()
        self.cu_selenium_connection.activate_plan(activate_plan_despite_reset=True,
                                                  activate_plan_despite_cell_locking=True)
        self.delete_delta_plan()

    def login_to_cu_webem(self):
        """
        Login to CU webem via admin API.

        :return: None
        """
        self.cu_admin_connection.connect_to(host=self.cu_address, port="443", username=self.cu_user,
                                            password=self.cu_password, cu_version='cuoam_19b', secure=True)
        self.cu_admin_connection.disconnect()

    def login_to_cu_webem_with_incorrect_password(self):
        """
        Login to CU webem via admin API with incorrect password.

        :return: None
        """
        try:
            self.cu_admin_connection.connect_to(host=self.cu_address, port="443", username=self.cu_user,
                                                password="incorrect_passwrod", cu_version='cuoam_19b', secure=True)
            MolerTest.error("Successful authorization with incorrect password", raise_exception=True)
        except AuthenticationFailed:
            MolerTest.info("Invalid password successfully rejected")

    def login_to_cu_webem_with_incorrect_username(self):
        """
        Login to CU webem via admin API with incorrect username.

        :return: None
        """
        try:
            self.cu_admin_connection.connect_to(host=self.cu_address, port="443", username="nykaenen",
                                                password=self.cu_password, cu_version='cuoam_19b', secure=True)
            MolerTest.error("Successful authorization with incorrect username", raise_exception=True)
        except AuthenticationFailed:
            MolerTest.info("Invalid password successfully rejected")

    @selenium_connect
    def change_sctp_parameters(self, structure_items, structure_to_be_deleted=None):
        """
        Change "SCTP configuration profile" parameters.

        :param structure_items: dict, parameters with values
        :param structure_to_be_deleted: str, name of structure to be deleted, e.g. 'Structure 1'
        :return: None
        """
        dist_name = "MRBTS-{}/NRBTS-1/NRSCTP-1"
        self.delete_delta_plan()
        self.cu_selenium_connection.create_delta_plan("plan_1")
        if structure_to_be_deleted:
            self.cu_selenium_connection.remove_element(dist_name.format(self.cu_instance_id),
                                                       "SCTP configuration profile", "sctpProfile",
                                                       structure_to_be_deleted)
        self.cu_selenium_connection.add_element(dist_name.format(self.cu_instance_id),
                                                "SCTP configuration profile", "sctpProfile",
                                                list_element_value="false", structure_items=structure_items)
        self.cu_selenium_connection.fix_errors(create_all_missing_mandatory_parameters=True)
        self.cu_selenium_connection.validate_plan()
        self.cu_selenium_connection.activate_plan(activate_plan_despite_reset=True,
                                                  activate_plan_despite_cell_locking=True)
        self.delete_delta_plan()

    @selenium_connect
    def delete_sctp_structure(self, structure):
        """
        Delete "SCTP configuration profile" structure.

        :param structure: str, structure name, e.g. 'Structure 1'
        :return: None
        """
        dist_name = "MRBTS-{}/NRBTS-1/NRSCTP-1"
        self.delete_delta_plan()
        self.cu_selenium_connection.create_delta_plan("plan_1")
        self.cu_selenium_connection.remove_element(dist_name.format(self.cu_instance_id),
                                                   "SCTP configuration profile", "sctpProfile", structure)
        self.cu_selenium_connection.validate_plan()
        self.cu_selenium_connection.activate_plan(activate_plan_despite_reset=True,
                                                  activate_plan_despite_cell_locking=True)
        self.delete_delta_plan()

    @selenium_connect
    def change_sctp_parameters_via_selenium(self):
        """
        Add ipv4 route on CU.

        :return: None
        """
        dist_name = "MRBTS-{}/NRBTS-1/NRSCTP-1"
        self.delete_delta_plan()
        self.cu_selenium_connection.create_delta_plan("plan_1")
        self.cu_selenium_connection.set_parameter_value(dist_name.format(self.cu_instance_id),
                                                        "SCTP chunk bundling enabled", "sctpChunkBundlingEnabled",
                                                        "false")
        self.cu_selenium_connection.set_parameter_value(dist_name.format(self.cu_instance_id),
                                                        "SCTP heartbeat message interval", "sctpHeartbeatInterval",
                                                        "20")
        self.cu_selenium_connection.set_parameter_value(dist_name.format(self.cu_instance_id),
                                                        "Maximum number of packets can be sent", "sctpMaxBurst", "4")
        self.cu_selenium_connection.set_parameter_value(dist_name.format(self.cu_instance_id),
                                                        "SCTP maximum payload size", "sctpMaxPayloadSize", "1395")
        self.cu_selenium_connection.set_parameter_value(dist_name.format(self.cu_instance_id),
                                                        "Max Time for SCTP Setup", "sctpMaxTimeSctpSetup", "60")
        self.cu_selenium_connection.set_parameter_value(dist_name.format(self.cu_instance_id),
                                                        "SCTP path failure retransmission counter",
                                                        "sctpPathMaxRetrans", "7")
        self.cu_selenium_connection.set_parameter_value(dist_name.format(self.cu_instance_id),
                                                        "SCTP configuration identifier", "sctpProfileId", "1")
        self.cu_selenium_connection.set_parameter_value(dist_name.format(self.cu_instance_id),
                                                        "Initial retransmission timeout", "sctpRtoInit", "3000")
        self.cu_selenium_connection.set_parameter_value(dist_name.format(self.cu_instance_id),
                                                        "Maximum retransmission timeout", "sctpRtoMax", "60000")
        self.cu_selenium_connection.set_parameter_value(dist_name.format(self.cu_instance_id),
                                                        "Minimum retransmission timeout", "sctpRtoMin", "1000")
        self.cu_selenium_connection.set_parameter_value(dist_name.format(self.cu_instance_id),
                                                        "Selective acknowledge delay", "sctpSackDelay", "200")
        self.cu_selenium_connection.set_parameter_value(dist_name.format(self.cu_instance_id),
                                                        "Selective acknowledge frequency", "sctpSackFreq", "2")
        self.cu_selenium_connection.set_parameter_value(dist_name.format(self.cu_instance_id),
                                                        "Lifespan of state cookie", "sctpValidCookieLife", "60000")
        self.cu_selenium_connection.set_parameter_value(dist_name.format(self.cu_instance_id),
                                                        "Wait time before starting SCTP init after shutdown",
                                                        "sctpWaitTimeInitSeqRetry", "240")
        self.cu_selenium_connection.validate_plan()
        self.cu_selenium_connection.activate_plan(activate_plan_despite_reset=True,
                                                  activate_plan_despite_cell_locking=True)
        self.delete_delta_plan()

    @selenium_connect
    def change_sctp_rto_via_selenium(self):
        """
        Add ipv4 route on CU.

        :return: None
        """
        dist_name = "MRBTS-{}/NRBTS-1/NRSCTP-1"
        self.delete_delta_plan()
        self.cu_selenium_connection.create_delta_plan("plan_1")
        self.cu_selenium_connection.set_parameter_value(dist_name.format(self.cu_instance_id),
                                                        "Initial retransmission timeout", "sctpRtoInit", "100")
        self.cu_selenium_connection.set_parameter_value(dist_name.format(self.cu_instance_id),
                                                        "Maximum retransmission timeout", "sctpRtoMax", "300")
        self.cu_selenium_connection.set_parameter_value(dist_name.format(self.cu_instance_id),
                                                        "Minimum retransmission timeout", "sctpRtoMin", "100")
        self.cu_selenium_connection.validate_plan()
        self.cu_selenium_connection.activate_plan(activate_plan_despite_reset=True,
                                                  activate_plan_despite_cell_locking=True)
        self.delete_delta_plan()

    @MolerTest.raise_background_exceptions()
    @selenium_connect
    def perform_ip_connectivity_test(self, ip_version, scope_id, source_id, source_vm, source_vm_interface,
                                     scope_name=None, scope_abbr=None, scope_interface=None, payload=16, dscp=10):
        """
        Collect all IP Connectivity test input variable, perform test and check result.
        If result is not successful raise exception.

        :param ip_version: str, e.g. "IPv4"
        :param scope_id: str, scope identifier e.g. "DNS"
        :param source_id: str, source address identifier e.g. "OAMVM_5gbts-{}-oam-000_oam_oam {}"
        :param source_vm: str, source CU VM name e.g. "CPIF"
        :param source_vm_interface: str, source CU VM interface name e.g. "x2"
        :param scope_name: str, parameter name from CU WebEMParameter Editor e.g."IP address of the primary DNS server"
        :param scope_abbr:str, abbreviation name from CU WebEM Parameter Editor e.g. "serverIpAddressPrimary"
        :param scope_interface: str, scope interface name e.g. "fp0.505"
        :param payload: int, payload value
        :param dscp: int, DSCP value
        :return: None
        """
        # Part 1 Get Scope value as IP Connectivity input
        if scope_id == "User defined address":
            scope_value = scope_id
            ip_address_value = self.moler_keywords.get_du_interface_address(interface_name=scope_interface,
                                                                            vlan_tag_fp0=True)
            MolerTest.info(ip_address_value)
        else:
            ip_address_value = None
            scope_ip_address = self.get_address(scope_abbr, scope_name)
            scope_value = scope_id + " " + scope_ip_address  # Scope - input value
            MolerTest.info(scope_value)
        # Part 2 Get Source address as IP Connectivity input
        source_ip_address = self.moler_keywords.get_cu_interface_address(interface_name=source_vm_interface,
                                                                         device_state=source_vm)
        source_value = source_id.format(self.cu_instance_id, source_ip_address)  # Source address - input value
        MolerTest.info(source_value)
        # Part 3 Perform IP Connectivity test and verify if passed
        self.cu_selenium_connection.start_ip_connectivity_test(ip_version, scope_value, source_value, payload, dscp,
                                                               ip_address_value)
        MolerTest.sleep(20)  # Need to wait for test result output from CU
        state = self.cu_selenium_connection.get_ip_connectivity_test_result()[0]["Test result"]
        if state == "Successful":
            MolerTest.info('Passed', dump='Result from CU WebEM IP Connectivity app: {}'.format(state))
        else:
            MolerTest.error("Timeout for successful test result exceeded.\nCurrent result is '{}'".format(state),
                            raise_exception=True)

    @MolerTest.raise_background_exceptions()
    @selenium_connect
    def perform_pmtu_discovery_test(self, ip_address_type, source_id, source_vm, source_vm_interface, destination,
                                    dscp=10, fail_scenario=False, destination_tag=None):
        """
        Collect all Path MTU Discovery test input variable, perform test and check result.

        :param ip_address_type:  str, e.g "IPv4"
        :param source_id: str, source address identifier e.g. "OAMVM_5gbts-{}-oam-000_oam_oam {}"
        :param source_vm: str, source CU VM name e.g. "CPIF"
        :param source_vm_interface: str, source CU VM interface name e.g. "x2"
        :param destination: str, Destination IPv4 address e.g. "10.255.20.20"
        :param dscp: int, DSCP value
        :param fail_scenario: bool, True if "Failed" test result is expected, default False
        :param destination_tag: str, 'du' for DU interface address, default None
        :return: None
        """
        # Part 1 Get source IP address
        source_ip_address = self.moler_keywords.get_cu_interface_address(interface_name=source_vm_interface,
                                                                         device_state=source_vm)
        source = source_id.format(self.cu_instance_id, source_ip_address)
        # Part 2 Get Destination IP address
        if destination_tag == 'gateway_cu':
            destination_ip_address = self.moler_keywords.get_cu_gateway_address(destination)
        elif destination_tag == 'du':
            destination_ip_address = self.moler_keywords.get_du_interface_address(destination, vlan_tag_fp0=True)
        else:  # If no destination_tag, raw IPv4 address should be given in destination input variable
            destination_ip_address = destination
            pattern_ipv4 = '^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?).){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$'
            if not re.match(pattern_ipv4, destination_ip_address):
                MolerTest.error("'{}' is not valid IPv4 address".format(destination_ip_address), raise_exception=True)
            else:
                MolerTest.info('Validation od destination ip address {} passed'.format(destination_ip_address))
        # Part 3 Perform Path MTU Discovery test and verify if passed
        status = self.cu_selenium_connection.get_pmtu_discovery_result(ip_address_type, source,
                                                                       destination_ip_address, dscp)['Status']
        if fail_scenario is True:
            expected_result = 'Failed'
        else:
            expected_result = 'Successful'
        if status == expected_result:
            MolerTest.info('Passed', dump='Result from CU WebEM PMTU Discovery app: {} '
                                          'desired result is {}'.format(status, expected_result))
        else:
            MolerTest.error('Failed', dump='Result from CU WebEM PMTU Discovery app: {}, '
                                           'desired result is {}'.format(status, expected_result),
                            raise_exception=True)

    @admin_connect
    def get_cu_counter_admin(self, measurement_id, dimension_dist_name, counter_id):
        """
        Take counter identifiers as input variables and return dict composed of counter identifiers and
        key - value pairs. Keys are capturing start time/interval and values are counter values for that interval.

        :param measurement_id: str, counter_id composed of numerical digits only e.g "51321"
        :param dimension_dist_name: str, Full Path without last element e.g. "MRBTS-0/TNLSVC-1/TNL-4/IPNO-1/IPIF-1"
        :param counter_id: str, id of counter e.g. M51321C0
        :return: list, {'values': [{'start_time': '2021-05-11T13:45:00.000+02:00', 'value': '158772'},
                                   {'start_time': '2021-05-11T14:00:00.000+02:00', 'value': '163512'}],
                        'measurement_id': '51321',
                        'dimension_dist_name': 'MRBTS-77020/TNLSVC-1/TNL-4/IPNO-1/IPIF-1',
                        'id': 'M51321C0'}
        """
        counters = self.cu_admin_connection.get_counter(measurement_id, dimension_dist_name, counter_id)
        return counters

    @MolerTest.raise_background_exceptions()
    def get_counter_for_interval(self, measurement_id, dimension_dist_name, counter_id, interval):
        """
        Invoke get_cu_counter_admin method (see docstring) and return counter value for given interval.

        :param measurement_id: str, str, counter_id composed of numerical digits only, e.g "51321"
        :param dimension_dist_name: str, Full Path without last element, common for all counters given in counter_ids
        e.g. "MRBTS-0/TNLSVC-1/TNL-4/IPNO-1/IPIF-1"
        :param counter_id: str, e.g. M51321C0
        :param interval: int, index pointing to a counter start time/interval in index notation e.g. -1 is last element
        of a counters list corresponding to the most recent capturing start time/interval
        :return: two-element list, element with index 1 is counter start time/interval, element with index 0 is counter
        value for that interval
        """
        value = None
        start_time = None
        # Extract counter list for all intervals
        counters = self.get_cu_counter_admin(measurement_id, dimension_dist_name, counter_id)['values']
        # Extract counter for expected interval
        try:
            value = counters[interval]['value']
            start_time = counters[interval]['start_time']
        except [TypeError, ValueError]:
            MolerTest.error(msg='interval variable should be an integer, {} given instead'.format(type(interval)),
                            raise_exception=True)
        MolerTest.info(msg='{} counter values with timestamps'.format(counter_id), dump=counters)
        return [value, start_time]

    def get_many_counters(self, measurement_id, dimension_dist_name, counter_ids, interval):
        """
        Take counter_ids list (all counter identifiers from counter_ids list should come from the same
        dimension_dist_name), invoke get_counter_for_interval (see docstring) and return nested list composed of
        [counter_id, counter_value, start_time] for each counter.

        :param measurement_id: str, counter_id composed of numerical digits only, common for all counters given in
        counter_ids e.g "51321"
        :param dimension_dist_name: str,  Full Path without last element, common for all counters given in counter_ids
        e.g. "MRBTS-0/TNLSVC-1/TNL-4/IPNO-1/IPIF-1"
        :param counter_ids: list, list of counter identifiers e.g ["M51321C0", "M51321C1"]
        :param interval: int, index pointing to a counter start time/interval in index notation e.g. -1 is last element
        of a counters list corresponding to the recent capturing start time/interval
        :return: nested list with counter data e.g. [[counter_id0, counter_value0, start_time0],
                                                     [counter_id1, counter_value1, start_time1]]
        """
        counters = []
        for counter_id in counter_ids:
            data = self.get_counter_for_interval(measurement_id, dimension_dist_name, counter_id, interval)
            counters.append([counter_id, data[0], data[1]])  # data[0] it's counter value, data[1] it's start time
        return counters

    @MolerTest.raise_background_exceptions()
    def validate_counter_values(self, measurement_id, dimension_dist_name, counter_ids, interval,
                                required_values, tolerance):
        """
        Take list of counter_ids and list of required_values (first element from counter_ids list should
        correspond to first element of required_values list), invoke get_many_counters method (see docstring) and
        validate observed counter value for given interval and tolerance. Raise exception if not all counter passed.

        :param measurement_id: str, counter_id composed of numerical digits only, common for all counters given in
        counter_ids e.g "51321"
        :param dimension_dist_name: str, Full Path without last element, common for all counters given in counter_ids
        e.g. "MRBTS-0/TNLSVC-1/TNL-4/IPNO-1/IPIF-1"
        :param counter_ids: list, list of counter identifiers e.g ["M51321C0", "M51321C1"]
        :param interval: int, index pointing to a counter start time/interval in index notation e.g. -1 is last element
        of a counters list corresponding to the recent capturing start time/interval
        :param required_values: lst, list of required values e.g. [100, 200] or ["100", "200"]
        :param tolerance: int, tolerance of required value e.g. 20 for a 20% tolerance of observed value in relation to
        required value
        :return: None
        """
        lower_factor = None
        upper_factor = None
        if len(required_values) != len(counter_ids):
            MolerTest.error("Length of counter_ids list differs from length of required_values list. "
                            "They should be the same.", raise_exception=True)
        else:
            validation_result = []
            observed_values = self.get_many_counters(measurement_id, dimension_dist_name, counter_ids, interval)
            try:
                lower_factor = 1 - (float(tolerance) / 100)
                upper_factor = 1 + (float(tolerance) / 100)
            except TypeError:
                MolerTest.error("tolerance input variable should be numeric", raise_exception=True)
            for observed_value, required_value in zip(observed_values, required_values):
                # Set boundary conditions for counter value
                lower_limit = round(lower_factor * float(required_value))
                upper_limit = round(upper_factor * float(required_value))
                if lower_limit <= float(observed_value[1]) <= upper_limit:
                    verdict = 'Passed'
                else:
                    verdict = 'Failed'
                sub_result = [verdict, 'CounterID: {}'.format(observed_value[0]),
                              'Counter dist name: {}'.format(dimension_dist_name),
                              'Observed value: {}'.format(observed_value[1]),
                              'Required value: {}'.format(required_value),
                              'Lower limit: {}, Upper limit: {}'.format(lower_limit, upper_limit),
                              'Counter start time: {}'.format(observed_value[2])]
                validation_result.append(sub_result)

            MolerTest.info("Validation result: ", validation_result)
            summary = [verdict[0] for verdict in validation_result]  # verdict means 'Passed' or 'Failed'
            if not all(verdict == 'Passed' for verdict in summary):
                MolerTest.error("Validation Failed. Some observed counter values does not match to required values",
                                raise_exception=True,
                                dump=[sub_result for sub_result in validation_result if sub_result[0] == "Failed"])

    @admin_connect
    def get_object(self, parameter_name):
        """
        Get CU SCF object.

        :param parameter_name: str, name of parameter or object e.g. "discoveredMplane"
        :return: Complex Param Children Structure of object
        """
        object_value = self.cu_admin_connection.search_parameters_of_current_plan(parameter_name)
        return object_value

    @MolerTest.raise_background_exceptions()
    def get_dist_name(self, parameter_name, reduced=False):
        """
        Extract dist name from get_object output.

        :param parameter_name:  str, name of parameter or object e.g. "discoveredMplane"
        :param reduced:  bool, True if reduced dist name should be returned
        :return: str, object dist name
        """
        dist_name = None
        raw_object = str(self.get_object(parameter_name))
        if reduced is True:
            pattern = '/IPADDRESSV4-1/IPADDRESSV4_R-1'
        else:
            pattern = '/IPADDRESSV4_R-1'
        try:
            dist_name = re.search(": '(.+?){}".format(pattern), raw_object).group(1)
        except AttributeError:
            MolerTest.error('Dist name pattern not found in object', raise_exception=True,
                            dump='Dist name pattern:\n{}\nObject:\n{}'.format(dist_name, raw_object))
        return dist_name

    @MolerTest.raise_background_exceptions()
    def get_address(self, parameter_abbr, parameter_name):
        """
        Get IPv4 address of SCF object.

        :param parameter_abbr: str, SCF parameter abbreviation
        :param parameter_name: str, SCF parameter name
        :return: str, IPv4 address
        """
        address = None
        raw_object = str(self.get_object(parameter_abbr))
        found = re.search('{}'.format(parameter_name), raw_object)
        if found:
            try:
                address = re.search(r"value': '(.+?)'", raw_object).group(1)
            except AttributeError:
                MolerTest.error('IP address not found in raw_object', raise_exception=True,
                                dump='SCF object:\n{}\nAddress:\n{}'.format(raw_object, address))
            self._validate_ipv4_address(address)
        else:
            MolerTest.error('Parameter {} not found in raw_object:\n{}'.format(parameter_name, raw_object))
        return address

    @staticmethod
    @MolerTest.raise_background_exceptions()
    def _validate_ipv4_address(address):
        """
        Check if address input variable is valid IPv4 address.

        :param address: str, IPv4 address
        :return: None
        """
        pattern_ipv4 = '^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?).){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$'
        if re.match(pattern_ipv4, address):
            MolerTest.info('Validation of IPv4 address {} passed'.format(address))
        else:
            MolerTest.error("'{}' is not valid IPv4 address".format(address), raise_exception=True)

    @selenium_connect
    def cu_restore_default_certificates(self):
        self.cu_selenium_connection.restore_default_certificates()

    @selenium_connect
    def change_local_and_service_users_passwords(self):
        """
        Change default passwords of users: toor4nsn, Nemuadmin, serviceuser, wsuser using selenium

        :return: None
        """
        service_users = {"toor4nsn": "oZPS0POrRieRtu", "serviceuser": "Pl(FzaYj5~c5;q", "wsuser": "A0zY~rP#8Mx@"}
        new_password = "Nokia@123"
        for user in service_users:
            if self.cu_selenium_connection.change_service_user_password(user, service_users[user],
                                                                        new_password) != 'Successfully changed':
                MolerTest.error("Cannot change {} password".format(user))

        if self.cu_selenium_connection.change_local_users_password(current_password=self.cu_password,
                                                                   new_password=new_password) \
                != 'Successfully changed':
            MolerTest.error("Cannot change nemuadmin password")
