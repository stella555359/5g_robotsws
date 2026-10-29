from moler.device import DeviceFactory
from moler.util.moler_test import MolerTest
from taf.gnb.oam.coam.admin import admin
from ute_common_admin.exception import AdminApiProcedureFailureException

from taf.rfrl.bts.devices.exceptions import WrongApiException
from testsuite.Wroclaw.RRM.sim_resources.Krk_regression.resources.linux_accounts.system_account_permissions \
    import admin_connect, load_moler_configuration_from_tl
from taf.rfrl.bts.devices.cu.commissioning import CuCommissioning
from robot.libraries.BuiltIn import BuiltIn
import os

expected_ciphers_port_443 = ['TLS_DHE_RSA_WITH_AES_128_GCM_SHA256',
                             'TLS_DHE_RSA_WITH_AES_256_GCM_SHA384',
                             'TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384',
                             'TLS_RSA_WITH_AES_128_GCM_SHA256',
                             'TLS_RSA_WITH_AES_256_GCM_SHA384']
expected_ciphers_port_8443 = ["TLS_DHE_RSA_WITH_AES_128_GCM_SHA256",
                              "TLS_DHE_RSA_WITH_AES_256_GCM_SHA384",
                              "TLS_RSA_WITH_AES_128_GCM_SHA256",
                              "TLS_RSA_WITH_AES_256_GCM_SHA384"]
expected_du_ciphers_port_443 = ["TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384",
                                "TLS_DHE_RSA_WITH_AES_256_GCM_SHA384",
                                "TLS_RSA_WITH_AES_256_GCM_SHA384",
                                "TLS_DHE_RSA_WITH_AES_128_GCM_SHA256",
                                "TLS_RSA_WITH_AES_128_GCM_SHA256"]
expected_du_ciphers_port_8443 = ["TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384",
                                 "TLS_DHE_RSA_WITH_AES_256_GCM_SHA384",
                                 "TLS_RSA_WITH_AES_256_GCM_SHA384",
                                 "TLS_DHE_RSA_WITH_AES_128_GCM_SHA256",
                                 "TLS_RSA_WITH_AES_128_GCM_SHA256"]
expected_du_ciphers_port_8443_script = ["Testing AES256-GCM-SHA384...YES",
                                        "Testing DHE-RSA-AES256-GCM-SHA384...YES",
                                        "Testing ECDHE-RSA-AES256-GCM-SHA384...YES",
                                        "Testing DHE-RSA-AES128-GCM-SHA256...YES",
                                        "Testing AES128-GCM-SHA256...YES"]


class SyVeSecurity(object):

    def __init__(self):
        tl = BuiltIn().get_variable_value('${{{}}}'.format("tl"), None)
        self.http_address = tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr
        self.cu_address = tl.gnbs[0].cu.backhaul_site_oam_ip
        self.du_address = tl.gnbs[0].dus[0].f1_m_ip_addr
        self.gnb_id = tl.gnbs[0].dus[0].global_bts_id
        self.admin = admin()
        self.gnb_cu = CuCommissioning()

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def check_maxauthtries(self, value, bts_id=0):
        """
        Check value of maxauthtries parameter on DU.

        :param value: expected value of maxauthtries parameter
        :param bts_id: ID of BTS
        :return: None
        """
        moler_device = DeviceFactory.get_device("GNB{}".format(bts_id), initial_state="FCT")
        cmd_cat = moler_device.get_cmd(cmd_name="cat", cmd_params={"path": "/etc/ssh/sshd_config"})
        res = cmd_cat()
        if "MaxAuthTries {}".format(value) not in res["LINES"]:
            MolerTest.error("MaxAuthTries != {}".format(value))
        MolerTest.steps_end()

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def cu_check_maxauthtries(self, value, bts_id=0):
        """
        Check value of maxauthtries parameter on CU.

        :param value: expected value of maxauthtries parameter
        :param bts_id: ID of BTS
        :return: None
        """
        moler_device = DeviceFactory.get_device("GNB{}_CU".format(bts_id), initial_state="OAM")
        cmd_cat = moler_device.get_cmd(cmd_name="cat", cmd_params={"path": "/etc/ssh/external_sshd_config; echo"})
        res = cmd_cat()
        if "MaxAuthTries {}".format(value) not in res["LINES"]:
            MolerTest.error("MaxAuthTries != {}".format(value))
        MolerTest.steps_end()

    @admin_connect
    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def cu_change_ssh_max_auth_attempts_parameter(self, value="2", should_fail=False):
        """
        Change value of sshmaxauthattempts parameter on CU.

        :param value: new value of maxauthtries parameter
        :param should_fail: True if delta plan activation should fail
        :return: None
        """
        self.gnb_cu.delete_delta_plan_from_cu()
        self.gnb_cu.update_parameter_of_delta_plan("sshMaxAuthAttempts", value)
        try:
            self.gnb_cu.validate_and_activate_delta_plan()
        except WrongApiException:
            if not should_fail:
                MolerTest.error("Cannot change parameter 'sshMaxAuthAttempts' to {}".format(value))
            MolerTest.steps_end()
            self.gnb_cu.delete_delta_plan_from_cu()
            return
        if should_fail:
            MolerTest.error("Parameter 'sshMaxAuthAttempts' has been changed to {}".format(value))
        MolerTest.steps_end()

    @staticmethod
    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def verify_tls_connection_is_not_established(s_client_output):
        """
        Verify TLS connection is not established.

        :param s_client_output: output from openssl s_client moler command
        :return: None
        """
        if s_client_output["Session-ID"] or s_client_output["Master-Key"]:
            MolerTest.error("TLS connection is established")
        MolerTest.steps_end()

    @staticmethod
    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def verify_tls_connection_is_established(s_client_output):
        """
        Verify TLS connection is established.

        :param s_client_output: output from openssl s_client moler command
        :return: None
        """
        if not s_client_output["Session-ID"] or not s_client_output["Master-Key"]:
            MolerTest.error("TLS connection is not established")
        MolerTest.steps_end()

    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def check_supported_by_cu_tls_server_cipher_suites(self, port, bts_id=0):
        """
        Check supported by CU TLS server cipher suites.

        :param port: port
        :param bts_id: ID of BTS
        :return: None
        """
        moler_device = DeviceFactory.get_device("GNB{}_CU".format(bts_id), initial_state="OAM")
        cmd_nmap = moler_device.get_cmd(cmd_name="nmap",
                                        cmd_params={"options": "--script ssl-enum-ciphers -p {}".format(port),
                                                    "ip": self.cu_address})
        res = cmd_nmap()["CIPHERS"]
        expected = expected_ciphers_port_443 if port == "443" else expected_ciphers_port_8443
        if res.sort() != expected.sort():
            MolerTest.error("Expected ciphers:\n{},\ncurrent ciphers:\n{}".format(expected.sort(), res.sort()))
        MolerTest.steps_end()

    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def check_supported_by_du_tls_server_cipher_suites(self, port, bts_id=0):
        """
        Check supported by DU TLS server cipher suites.

        :param port: port
        :param bts_id: ID of BTS
        :return: None
        """
        moler_device = DeviceFactory.get_device("GNB{}".format(bts_id), initial_state="PROXY_PC")
        cmd_nmap = moler_device.get_cmd(cmd_name="nmap",
                                        cmd_params={"options": "--script ssl-enum-ciphers -p {}".format(port),
                                                    "ip": self.du_address})
        res = cmd_nmap()["CIPHERS"]
        expected = expected_du_ciphers_port_443 if port == "443" else expected_du_ciphers_port_8443
        if res.sort() != expected.sort():
            MolerTest.error("Expected ciphers:\n{},\ncurrent ciphers:\n{}".format(expected.sort(), res.sort()))
        MolerTest.steps_end()

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def run_tls_cipher_check_script(self, port, script_path, bts_id=0):
        """
        Run tls cipher check script.

        :param port: port
        :param script_path: path to tls cipher check script
        :param bts_id: ID of BTS
        :return: None
        """
        vm = DeviceFactory.get_device("GNB{}".format(bts_id), initial_state="PROXY_PC")
        cmd_chmod = vm.get_cmd(cmd_name="chmod", cmd_params={"permission": "+x", "filename": script_path})
        cmd_chmod()
        twamp_cmd = vm.get_cmd(cmd_name="run_script", cmd_params={
            "script_command": "{} {}:{} | grep YES > tmp".format(script_path, self.du_address, port)})
        twamp_cmd(timeout=1500)
        cat_cmd = vm.get_cmd(cmd_name="cat", cmd_params={"path": "tmp"})
        output = cat_cmd()
        expected = expected_du_ciphers_port_443 if port == "443" else expected_du_ciphers_port_8443_script
        error_list = list(expected)
        for cipher in expected:
            for line in output["LINES"]:
                if cipher == line:
                    error_list.remove(cipher)
        if error_list:
            MolerTest.error("Missing ciphers in output: '{}', expected: '{}'".format(output, expected),
                            dump=error_list)
        MolerTest.steps_end()

    @admin_connect
    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def du_change_mplanenw_parameter(self, parameter, value, fail_expected=False):
        """
        change parameter in mplanenw.

        :param parameter: parameter abbreviation
        :param value: planned value of parameter
        :param fail_expected: True if fail expected
        :return: None
        """
        try:
            self.admin.perform_parameter_recommissioning("MRBTS-{}/MNL-1/MNLENT-1/MPLANENW-1".format(self.gnb_id),
                                                         parameter,
                                                         "update", value=value,
                                                         skip_parameter_relation_errors=True)
        except AdminApiProcedureFailureException:
            if not fail_expected:
                MolerTest.error("Cannot change parameter '{}' to {}".format(parameter, value))
            else:
                MolerTest.steps_end()
                return
        if fail_expected:
            MolerTest.error("Parameter {} has been changed to {}".format(parameter, value))
        MolerTest.steps_end()

    @admin_connect
    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def disable_ipsec(self):
        """
        Disable IPsec.

        :return: None
        """
        try:
            self.admin.perform_parameter_recommissioning("MRBTS-{}/TNLSVC-1/TNL-1/IPAPP-1/IPSECC-1"
                                                         .format(self.gnb_id), "ipSecEnabled",
                                                         "update", value="false", skip_parameter_relation_errors=True)
        except AdminApiProcedureFailureException:
            MolerTest.error("Cannot change parameter 'ipSecEnabled' to false")
        MolerTest.steps_end()

    @admin_connect
    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def set_local_ip_addr(self, addr):
        """
        Change value of localIpAddr parameter.

        :param addr: local ip address
        :return: None
        """
        try:
            self.admin.perform_parameter_recommissioning("MRBTS-{}/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1"
                                                         .format(self.gnb_id), "localIpAddr",
                                                         "update", value=addr, skip_parameter_relation_errors=True)
        except AdminApiProcedureFailureException:
            MolerTest.error("Cannot change parameter 'ipSecEnabled' to false")
        MolerTest.steps_end()

    @admin_connect
    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def remove_ssh_keys(self, skip_parameter_relation_errors=False):
        """
        Remove all ssh keys.

        :param skip_parameter_relation_errors: Skip parameter relation errors.
        :return: None
        """
        dist_name = "MRBTS-{}/MNL-1/MNLENT-1/SECADM-1".format(self.gnb_id)
        try:
            self.admin.create_delta()
            self.admin.append_parameter_delete_to_delta(dist_name=dist_name, parameter="rootUserPublicKeys")
            self.admin.save_delta()
            self.admin.perform_delta_recommissioning("delta.json",
                                                     skip_parameter_relation_errors=skip_parameter_relation_errors)
            self.admin.remove_delta()
            self.delete_delta_file("{}/delta.json".format(os.getcwd()))
        except AdminApiProcedureFailureException as e:
            MolerTest.error("Cannot remove ssh keys:\n {}".format(e))
        MolerTest.steps_end()

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def delete_delta_file(self, file_path, bts_id=0):
        """
        Delete delta file.

        :param file_path: path to file
        :param bts_id: ID of BTS
        :return: None
        """
        moler_device = DeviceFactory.get_device("GNB{}".format(bts_id), initial_state="PROXY_PC")
        cmd_rm = moler_device.get_cmd(cmd_name="rm", cmd_params={"file": file_path})
        cmd_rm()
        MolerTest.steps_end()
