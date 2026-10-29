import re

from moler.device import DeviceFactory
from moler.exceptions import CommandTimeout
from moler.util.moler_test import MolerTest
from taf.sbts.oam.coam.admin import admin
from testsuite.Krakow.resources.linux_accounts.system_account_permissions import admin_connect, \
    load_moler_configuration_from_tl
from robot.libraries.BuiltIn import BuiltIn

expected_output_list = [[r"Unable to negotiate with .* port 22: no matching MAC"],
                        [r"debug2: peer server KEXINIT proposal",
                         r"debug2: KEX algorithms: ",
                         r"curve25519-sha256,curve25519-sha256@libssh.org,ecdh-sha2-nistp521,ecdh-sha2-nistp384,"
                         "ecdh-sha2-nistp256,diffie-hellman-group-exchange-sha256,diffie-hellman-group18-sha512,"
                         "diffie-hellman-group16-sha512,diffie-hellman-group14-sha256$",
                         r"debug2: host key algorithms: ",
                         r"rsa-sha2-512,rsa-sha2-256,ssh-rsa,ecdsa-sha2-nistp256,ssh-ed25519$",
                         r"debug2: ciphers ctos: ",
                         r"chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,"
                         "aes192-ctr,aes128-ctr",
                         r"debug2: ciphers ctos: ",
                         r"chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,"
                         "aes192-ctr,aes128-ctr",
                         r"debug2: MACs ctos: ",
                         r"hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,umac-128-etm@openssh.com,"
                         "hmac-sha2-512,hmac-sha2-256,umac-128@openssh.com,umac-64-etm@openssh.com",
                         r"debug2: MACs ctos: ",
                         r"hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,umac-128-etm@openssh.com,"
                         "hmac-sha2-512,hmac-sha2-256,umac-128@openssh.com,umac-64-etm@openssh.com",
                         r"debug1: Authentication succeeded"],
                        [r"Unable to negotiate with .* port 22: no matching key exchange method found."],
                        [r"Unable to negotiate with .* port 22: no matching host key type found."],
                        [r"Authentication succeeded"]]


class SSHKeywords(object):

    def __init__(self):
        tl = BuiltIn().get_variable_value('${{{}}}'.format("tl"), None)
        self.http_address = tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr
        self.du_address = tl.gnbs[0].dus[0].oam_ip.v4.split('/')[0]
        self.du_username = tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username
        self.du_password = tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password
        self.gnb_id = tl.gnbs[0].dus[0].global_bts_id
        self.admin = admin()

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def perform_ssh_connection(self, options, expected_output, fail_expected=False, timeout=20, bts_id=0):
        """
        Perform ssh connection.

        :param options: ssh cmd options
        :param expected_output: expected ssh output
        :param fail_expected: True if ssh fail expected
        :param timeout: ssh cmd timeout
        :param bts_id: ID of BTS
        :return: None
        """
        vm = DeviceFactory.get_device("GNB{}".format(bts_id), initial_state="PROXY_PC")
        ssh_cmd = vm.get_cmd(cmd_name="ssh",
                             cmd_params={"login": self.du_username, "password": self.du_password,
                                         "host": self.du_address,
                                         "expected_prompt": "root@fct.*"})
        ssh_cmd.command_string = "ssh {} {}@{}".format(options, self.du_username, self.du_address)
        try:
            ssh_cmd(timeout=int(timeout))
        except CommandTimeout:
            if fail_expected:
                self._check_ssh_output(ssh_cmd.current_ret, expected_output_list[int(expected_output)])
            else:
                MolerTest.error("SSH connection cannot be established", raise_exception=True)
            MolerTest.steps_end()
            return
        ssh_exit = vm.get_cmd(cmd_name="exit", cmd_params={"expected_prompt": "ute@.*"})
        ssh_exit()
        if fail_expected:
            MolerTest.error("SSH connection should fail but is established", raise_exception=True)
        else:
            self._check_ssh_output(ssh_cmd.current_ret, expected_output_list[int(expected_output)])
        MolerTest.steps_end()

    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def _check_ssh_output(self, output, expected_output):
        output = output["LINES"]
        MolerTest.info("ssh output:", dump=output)
        current_output = list()
        for expected_line in expected_output:
            for output_line in output:
                res = re.search(expected_line, output_line)
                if res:
                    output = output[output.index(output_line):]
                    current_output.append(expected_line)
                    break
        if expected_output != current_output:
            MolerTest.error("Missing lines in ssh output:", dump=list(set(expected_output) - set(current_output)))
        MolerTest.steps_end()

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def generate_toor4nsn_ssh_public_key(self, algorithm="ed25519", bts_id=0):
        """
        Generate ssh keys.

        :param bts_id: ID of BTS
        :param algorithm: key algorithm
        :return: None
        """
        vm = DeviceFactory.get_device("GNB{}".format(bts_id), initial_state="PROXY_PC")
        cmd_params = {"options": "-t {}".format(algorithm), "file": "/home/ute/toor4nsn_key"}
        cmd_ssh_keygen = vm.get_cmd(cmd_name="sshkeygen", cmd_params=cmd_params)
        cmd_ssh_keygen()
        MolerTest.steps_end()

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def edit_ssh_config_file(self, bts_id=0):
        """
        Edit ssh config file.

        :param bts_id: ID of BTS
        :return: None
        """
        vm = DeviceFactory.get_device("GNB{}".format(bts_id), initial_state="PROXY_PC")
        cp_cmd = vm.get_cmd(cmd_name="cp",
                            cmd_params={"src": "/home/ute/.ssh/config", "dst": "/home/ute/.ssh/config.copy"})
        cp_cmd()
        edit_config = vm.get_cmd(cmd_name="run_script", cmd_params={
            "script_command": "echo 'Host 10.83.*.*\n\tIdentityFile ~/toor4nsn_key\n\tUser toor4nsn'"
                              " >> /home/ute/.ssh/config".format(self.du_address)})
        edit_config()
        MolerTest.steps_end()

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def restore_ssh_config_file(self, bts_id=0):
        """
        Restore ssh config file.

        :param bts_id: ID of BTS
        :return: None
        """
        vm = DeviceFactory.get_device("GNB{}".format(bts_id), initial_state="PROXY_PC")
        mv_cmd = vm.get_cmd(cmd_name="mv",
                            cmd_params={"src": "/home/ute/.ssh/config.copy", "dst": "/home/ute/.ssh/config"})
        mv_cmd()
        MolerTest.steps_end()

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def delete_toor4nsn_key(self, bts_id=0):
        """
        Delete toor4nsn key.

        :param bts_id: ID of BTS
        :return: None
        """
        vm = DeviceFactory.get_device("GNB{}".format(bts_id), initial_state="PROXY_PC")
        cmd_rm = vm.get_cmd(cmd_name="rm", cmd_params={"file": "/home/ute/toor4nsn_key"})
        cmd_rm()
        cmd_rm = vm.get_cmd(cmd_name="rm", cmd_params={"file": "/home/ute/toor4nsn_key.pub"})
        cmd_rm()
        MolerTest.steps_end()
