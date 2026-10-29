from taf.rfrl.utilities.tl_config import load_moler_configuration_from_tl
from moler.device import DeviceFactory
from moler.util.moler_test import MolerTest
from robot.libraries.BuiltIn import BuiltIn


class Openssl(object):
    def __init__(self):
        tl = BuiltIn().get_variable_value('${{{}}}'.format("tl"), None)
        self.cu_address = tl.gnbs[0].cu.backhaul_site_oam_ip
        self.du_address = tl.gnbs[0].dus[0].f1_m_ip_addr

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def cu_establish_tls_1_1_connection_with_openssl(self, port, bts_id=0):
        """
        Establish TLS 1.1 connection with openssl using PC as client on CU.

        :param port: port
        :param bts_id: ID of BTS
        :return: output of openssl s_client command
        """
        vm = DeviceFactory.get_device("GNB{}_CU".format(bts_id), initial_state="UNIX_LOCAL")
        s_client_cmd = vm.get_cmd(cmd_name="openssl_s_client",
                                  cmd_params={"options": "-tls1_1 -connect {}:{}".format(self.cu_address, port)})
        ret = s_client_cmd()
        MolerTest.steps_end()
        return ret

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def du_establish_tls_1_1_connection_with_openssl(self, port, bts_id=0):
        """
        Establish TLS 1.1 connection with openssl using PC as client on DU.

        :param port: port
        :param bts_id: ID of BTS
        :return: output of openssl s_client command
        """
        vm = DeviceFactory.get_device("GNB{}".format(bts_id), initial_state="UNIX_LOCAL")
        s_client_cmd = vm.get_cmd(cmd_name="openssl_s_client",
                                  cmd_params={"options": "-tls1_1 -connect {}:{}".format(self.du_address, port)})
        ret = s_client_cmd()
        MolerTest.steps_end()
        return ret

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def cu_establish_tls_1_2_connection_with_openssl(self, port, bts_id=0):
        """
        Establish TLS 1.2 connection with openssl using PC as client.

        :param port: port
        :param bts_id: ID of BTS
        :return: output of openssl s_client command
        """
        vm = DeviceFactory.get_device("GNB{}_CU".format(bts_id), initial_state="UNIX_LOCAL")
        s_client_cmd = vm.get_cmd(cmd_name="openssl_s_client",
                                  cmd_params={"options": "-tls1_2 -connect {}:{} -cipher "
                                                         " DHE-RSA-AES256-SHA256".format(self.cu_address, port)})
        ret = s_client_cmd()
        MolerTest.steps_end()
        return ret

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def du_establish_tls_1_2_connection_with_openssl(self, port, ciphers="DHE-RSA-AES256-SHA256", bts_id=0):
        """
        Establish TLS 1.2 connection with openssl using PC as client.

        :param port: port
        :param ciphers: cipher
        :param bts_id: ID of BTS
        :return: output of openssl s_client command
        """
        vm = DeviceFactory.get_device("GNB{}".format(bts_id), initial_state="UNIX_LOCAL")
        s_client_cmd = vm.get_cmd(cmd_name="openssl_s_client",
                                  cmd_params={
                                      "options": "-tls1_2 -connect {}:{} -cipher {}".format(self.du_address, port,
                                                                                            ciphers)})
        ret = s_client_cmd()
        MolerTest.steps_end()
        return ret

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions()
    def du_establish_and_verify_tls_1_2_connection_with_openssl(self, port, ciphers, expected_cipher, bts_id=0):
        """
        Establish and verify TLS 1.2 connection with openssl using PC as client.

        :param port: port
        :param ciphers: cipher
        :param expected_cipher: expected cipher in openssl output
        :param bts_id: ID of BTS
        :return: None
        """
        ret = self.du_establish_tls_1_2_connection_with_openssl(port, ciphers, bts_id)
        if ret["Cipher"] != expected_cipher:
            MolerTest.error("Cipher is not as expected\nexpected:{}, current:{}"
                            .format(expected_cipher, ret["Cipher"]), raise_exception=True)

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def du_establish_tls_1_2_connection_with_openssl_using_not_cbc_cipher(self, port, bts_id=0):
        """
        Establish TLS 1.2 connection with openssl using PC as client.

        :param port: port
        :param bts_id: ID of BTS
        :return: output of openssl s_client command
        """
        vm = DeviceFactory.get_device("GNB{}".format(bts_id), initial_state="UNIX_LOCAL")
        s_client_cmd = vm.get_cmd(cmd_name="openssl_s_client",
                                  cmd_params={"options": "-tls1_2 -connect {}:{} -cipher "
                                                         " AES128-GCM-SHA256".format(self.du_address, port)})
        s_client_cmd.command_path = r'echo "\n" | '
        ret = s_client_cmd()
        MolerTest.steps_end()
        return ret

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def validate_certificates_used_for_https_connection_on_du(self, issuer, bts_id=0):
        """
        Validate certificates used for https connection on DU.

        :param issuer: expected issuer
        :param bts_id: ID of BTS
        :return: None
        """
        correct_issuer = False
        waiting_time = 0
        res = None
        vm = DeviceFactory.get_device("GNB{}".format(bts_id), initial_state="UNIX_LOCAL")
        while not correct_issuer and waiting_time <= 30:
            s_client_cmd = vm.get_cmd(cmd_name="openssl_s_client",
                                      cmd_params={"options": "{}:443 2>/dev/null".format(self.du_address)})
            res = s_client_cmd()
            if res["issuer"] != issuer:
                MolerTest.sleep(5)
                waiting_time += 5
            else:
                correct_issuer = True
        if res["issuer"] != issuer:
            MolerTest.error("Issuer should be {}, but it is {}".format(issuer, res["issuer"]))
        MolerTest.steps_end()

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def validate_certificates_used_for_https_connection_on_cu(self, issuer, bts_id=0):
        """
        Validate certificates used for https connection on CU.

        :param issuer: expected issuer
        :param bts_id: ID of BTS
        :return: None
        """
        correct_issuer = False
        waiting_time = 0
        res = None
        vm = DeviceFactory.get_device("GNB{}_CU".format(bts_id), initial_state="PROXY_PC")
        while not correct_issuer and waiting_time <= 30:
            s_client_cmd = vm.get_cmd(cmd_name="openssl_s_client",
                                      cmd_params={"options": "{}:443 2>/dev/null".format(self.cu_address)})
            s_client_cmd.command_path = r'echo "\n" | '
            res = s_client_cmd()
            if res["issuer"] != issuer:
                MolerTest.sleep(5)
                waiting_time += 5
            else:
                correct_issuer = True
        if not correct_issuer:
            MolerTest.error("Issuer should be {}, but it is {}".format(issuer, res["issuer"]))
        MolerTest.steps_end()

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def create_certificate_file(self, pem_file, path, bts_id=0):
        """
        Create .p12 file.

        :param pem_file: path to pem file
        :param path: path where p12 file will be created
        :param bts_id: ID of BTS
        :return: None
        """
        vm = DeviceFactory.get_device("GNB{}".format(bts_id), initial_state="PROXY_PC")
        s_client_cmd = vm.get_cmd(cmd_name="run_script", cmd_params={
            "script_command": "openssl pkcs12 -export -out {} -in {} -passout pass:emssim".format(path, pem_file)})
        s_client_cmd()
        MolerTest.steps_end()

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def delete_certificate_file(self, path, bts_id=0):
        """
        Delete .p12 file.

        :param path: path to p12 file
        :param bts_id: ID of BTS
        :return: None
        """
        vm = DeviceFactory.get_device("GNB{}".format(bts_id), initial_state="PROXY_PC")
        s_client_cmd = vm.get_cmd(cmd_name="rm", cmd_params={"file": path})
        s_client_cmd()
        MolerTest.steps_end()
