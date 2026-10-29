import os
import json
from functools import wraps
from moler.device import DeviceFactory
from ute_common_admin.exception import AdminApiProcedureFailureException
from robot.libraries.BuiltIn import BuiltIn
from moler.util.moler_test import MolerTest
from moler.exceptions import MolerException, CommandFailure
from taf.sbts.oam.coam.admin import admin
from taf.rfrl.utilities.tl_config import load_moler_configuration_from_tl


def admin_connect(web_fun):
    @wraps(web_fun)
    def wrapper(self, *args, **kwargs):
        self.admin.connect_to(bts_host=self.http_address)
        try:
            result = web_fun(self, *args, **kwargs)
            return result
        finally:
            try:
                self.admin.teardown()
            except Exception as ex:
                MolerTest.warning("Exception in admin_connect teardown: '{}' '{}'.".format(ex, repr(ex)))

    return wrapper


class SystemAccountPermissions:

    def __init__(self):
        tl = BuiltIn().get_variable_value('${{{}}}'.format("tl"), None)
        self.http_address = tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr
        self.m_plane_address = tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr
        self.cu_address = tl.gnbs[0].cu.backhaul_site_oam_ip
        self.lmp_address = tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr
        self.ssh_username = tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username
        self.toor4nsn_password = "oZPS0POrRieRtu"
        self.robot_password = "rastre1"
        self.serviceuser_password = "Pl(FzaYj5~c5;q"
        self.keys_path = "/home/ute/"
        self.delta_path = None
        self.moler_device = None
        self.gnb_id = tl.gnbs[0].dus[0].global_bts_id
        self._state_before_fct = dict()
        self._cloned_gnb = None
        self.admin = admin()

    @admin_connect
    def get_param(self, param="systemAcctPermEnable", dist_name=None):
        """
        Get value of provided WebEM parameter.

        :param param:
        :return: value if provided parameter
        """
        bts_configuration = self.admin.get_scf(export_type="configurationAndRuntimeObjects")
        if not dist_name:
            value = str(bts_configuration).partition('<p name="{}">'.format(param))[2].partition('</p>')[0]
            MolerTest.info(value)
            return value
        value = str(bts_configuration).partition('distName="{}"'.format(dist_name))[2]
        value = value.partition('<p name="{}">'.format(param))[2].partition('</p>')[0]
        return value

    @admin_connect
    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def verify_param(self, param="systemAcctPermEnable", expected="true"):
        """
        Verify value of provided WebEM parameter.

        :param expected: expected value
        :param param: param to be verified
        :return: None
        """
        bts_configuration = self.admin.get_scf(export_type="configurationAndRuntimeObjects")
        value = str(bts_configuration).partition('<p name="{}">'.format(param))[2].partition('</p>')[0]
        if value != expected:
            MolerTest.error("{} should be {}, but is{}".format(param, expected, value))
        MolerTest.steps_end()

    @admin_connect
    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def verify_number_of_ssh_keys_via_webem(self, expected, key_type="serviceUserPublicKeys"):
        """
        Verify number of keys in WebEM

        :param expected: expected number of keys
        :param key_type: serviceUserPublicKeys or rootUserPublicKeys
        :return: value if provided parameter
        """
        expected = int(expected)
        bts_configuration = self.admin.get_scf(export_type="configurationAndRuntimeObjects")
        lines = str(bts_configuration).partition('<list name="{}">'.format(key_type))[2].partition('</list>')[0]
        lines = lines.splitlines()
        number_of_keys = 0
        for line in lines:
            if '<p name="keyValue"' in line:
                number_of_keys += 1
        if number_of_keys != expected:
            MolerTest.error(
                "Expected number of '{}' is '{}', but there are '{}' keys".format(key_type, expected, number_of_keys))
        MolerTest.steps_end()

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def verify_number_of_ssh_keys_via_linux_files(self, expected, user="serviceuser", bts_id=0):
        """
        Verify number of keys in file system

        :param expected: expected number of keys
        :param user: serviceuser or toor4nsn
        :param bts_id: ID of BTS
        :return: None
        """
        expected = int(expected)
        self._prepare_moler_device(bts_id, "DU")
        self.moler_device.goto_state("FCT")
        cmd_cat = self.moler_device.get_cmd(cmd_name="cat",
                                            cmd_params={"path": "/user/{}/.ssh/authorized_keys".format(user)})
        keys = cmd_cat()
        number_of_keys = 0
        for _ in keys["LINES"]:
            number_of_keys += 1
        number_of_keys = int(number_of_keys / 2)
        if number_of_keys != expected:
            MolerTest.error(
                "Expected number of '{}' keys is '{}', but there are '{}' keys".format(user, expected, number_of_keys))
        MolerTest.steps_end()

    @admin_connect
    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def change_ssh_max_auth_attempts_parameter(self, value="2", should_fail=False):
        """
        Change 'sshMaxAuthAttempts' WebEM parameter to provided value.

        :param value: planned value of parameter
        :return: None
        """
        try:
            self.admin.perform_parameter_recommissioning("MRBTS-{}/MNL-1/MNLENT-1/SECADM-1".format(self.gnb_id),
                                                         "sshMaxAuthAttempts",
                                                         "update", value=value, skip_parameter_relation_errors=True)
        except AdminApiProcedureFailureException:
            if not should_fail:
                MolerTest.error("Cannot change parameter 'sshMaxAuthAttempts' to {}".format(value))
        if value == self.get_param(param="sshMaxAuthAttempts"):
            if should_fail:
                MolerTest.error("Parameter 'sshMaxAuthAttempts' successfully changed to {}".format(value))
            else:
                MolerTest.info("Parameter 'sshMaxAuthAttempts' successfully changed to {}".format(value))
        else:
            MolerTest.info("Cannot change parameter 'sshMaxAuthAttempts' to {}".format(value))
        MolerTest.steps_end()

    @admin_connect
    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def change_system_account_permission_parameter(self, value="false"):
        """
        Change 'systemAcctPermEnable' WebEM parameter to provided value.

        :param value: planned value of parameter
        :return: None
        """
        self.admin.perform_parameter_recommissioning("MRBTS-{}/MNL-1/MNLENT-1/FEATCADM-1".format(self.gnb_id),
                                                     "systemAcctPermEnable",
                                                     "update", value=value, skip_parameter_relation_errors=True)
        if value != self.get_param(param="systemAcctPermEnable"):
            MolerTest.error("Cannot change parameter 'systemAcctPermEnable' to {}".format(value))
        else:
            MolerTest.info("Parameter 'systemAcctPermEnable' successfully changed to {}".format(value))
            MolerTest.steps_end()

    @admin_connect
    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def change_key_continuation_parameter(self, value="false", should_fail=False):
        """
        Change 'keyContinuation' WebEM parameter to provided value.

        :param should_fail: True or False
        :param value: planned value of parameter
        :return: None
        """
        try:
            self.admin.perform_parameter_recommissioning("MRBTS-{}/MNL-1/MNLENT-1/SECADM-1".format(self.gnb_id),
                                                         "keyContinuation",
                                                         "update", value=value, skip_parameter_relation_errors=True)
        except AdminApiProcedureFailureException as e:
            if should_fail:
                MolerTest.info(e)
                MolerTest.steps_end()
                return
            else:
                MolerTest.error(e)
        if value != self.get_param(param="keyContinuation"):
            MolerTest.error("Cannot change parameter 'keyContinuation' to {}".format(value))
        else:
            MolerTest.info("Parameter 'keyContinuation' successfully changed to {}".format(value))
            MolerTest.steps_end()

    @admin_connect
    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def update_webem_ssh_keys(self, should_fail=False):
        """
        Update keys in WebEM

        :return: None
        """
        if not self.delta_path:
            MolerTest.error("Prepare delta file")
        else:
            try:
                self.admin.perform_delta_recommissioning("{}/delta.json".format(self.delta_path),
                                                         skip_parameter_relation_errors=True)
            except AdminApiProcedureFailureException as e:
                if should_fail:
                    MolerTest.info(e)
                else:
                    MolerTest.error(e)
        MolerTest.steps_end()

    @admin_connect
    def delete_root_user_ssh_keys(self):
        self.admin.perform_parameter_recommissioning("MRBTS-{}/MNL-1/MNLENT-1/SECADM-1".format(self.gnb_id),
                                                     "rootUserPublicKeys",
                                                     "delete", "", skip_parameter_relation_errors=True)

    @admin_connect
    def delete_service_user_ssh_keys(self):
        self.admin.perform_parameter_recommissioning("MRBTS-{}/MNL-1/MNLENT-1/SECADM-1".format(self.gnb_id),
                                                     "serviceUserPublicKeys",
                                                     "delete", "", skip_parameter_relation_errors=True)

    @load_moler_configuration_from_tl()
    def build_authorization_cmd_one_step(self, user=None, password=None, address=None, ssh_key=None,
                                         repeat_password=False):
        """
        Builds proper one step authorization moler cmd based on entered parameters.

        :param user: defined user to authorize
        :param password: string which contains serviceuser or toor4nsn password
        :param address: address of remote device
        :param ssh_key: string which contains path to serviceuser or toor4nsn ssh key
        :param repeat_password: True if password is to be repeated
        :return: proper moler authorization cmd
        """
        if user == "toor4nsn":
            prompt_user = "root"
        else:
            prompt_user = user
        if password and not ssh_key:
            return self.moler_device.get_cmd(cmd_name="ssh",
                                             cmd_params={"login": user, "host": address,
                                                         "repeat_password": repeat_password,
                                                         "password": password, "allowed_newline_after_prompt": True,
                                                         "set_prompt": r'export PS1="${PS1::-5} $ "',
                                                         "expected_prompt": r'{}@.*'.format(prompt_user),
                                                         "prompt_after_login": r'{}@.*'.format(prompt_user),
                                                         "set_timeout": None,
                                                         })
        elif password and ssh_key:
            proxy_cmd = "-i {} {}@{}".format(ssh_key, user, address)
            return self.moler_device.get_cmd(cmd_name="ssh",
                                             cmd_params={"options": proxy_cmd, "login": None, "host": "",
                                                         "password": password, "allowed_newline_after_prompt": True,
                                                         "term_mono": None,
                                                         "set_prompt": r'export PS1="${PS1::-5} $ "',
                                                         "expected_prompt": r'{}@.*'.format(prompt_user),
                                                         "repeat_password": repeat_password,
                                                         "prompt_after_login": r'{}@.*'.format(prompt_user),
                                                         "encrypt_password": False, "set_timeout": None})
        else:
            proxy_cmd = "-i {} {}@{}".format(ssh_key, user, address)
            return self.moler_device.get_cmd(cmd_name="ssh",
                                             cmd_params={"options": proxy_cmd, "login": None, "host": "",
                                                         "password": None, "allowed_newline_after_prompt": True,
                                                         "term_mono": None,
                                                         "set_prompt": r'export PS1="${PS1::-5} $ "',
                                                         "expected_prompt": r'{}@.*'.format(prompt_user),
                                                         "prompt_after_login": r'{}@.*'.format(prompt_user),
                                                         "repeat_password": False, "set_timeout": None})

    @load_moler_configuration_from_tl()
    def build_authorization_cmd_two_step(self, password=None, address=None, ssh_key=None):
        """
        Builds proper two step authorization moler cmd based on entered parameters.

        :param password: list -> [serviceuser password, toor4nsn password]
        :param address: address of remote device
        :param ssh_key: list -> [serviceuser ssh key path, toor4nsn ssh key path]
        :return: proper moler authorization cmd
        """
        if password and not ssh_key:
            proxy_service_user = "ssh -W %h:%p -p 22 serviceuser@{}".format(address)
            proxy_cmd = """-Ao ProxyCommand="{}" -p 22 toor4nsn@127.0.0.1""".format(proxy_service_user)
            return self.moler_device.get_cmd(cmd_name="ssh",
                                             cmd_params={"options": proxy_cmd, "login": None, "host": "",
                                                         "password": password, "repeat_password": False,
                                                         "term_mono": None, "set_timeout": None})
        elif ssh_key and not password:
            proxy_service_user = "ssh -i {}  -W %h:%p -p 22 serviceuser@{}".format(ssh_key[0], address)
            proxy_cmd = """-Ao ProxyCommand="{}" -p 22 toor4nsn@127.0.0.1 -i {}""".format(proxy_service_user,
                                                                                          ssh_key[1])
            return self.moler_device.get_cmd(cmd_name="ssh",
                                             cmd_params={"options": proxy_cmd, "login": None, "host": "",
                                                         "password": None, "repeat_password": False,
                                                         "term_mono": None, "set_timeout": None})
        else:
            proxy_service_user = "ssh -W %h:%p -p 22 serviceuser@{}".format(address)
            proxy_cmd = """-Ao ProxyCommand="{}" -p 22 toor4nsn@127.0.0.1 -i {}""".format(proxy_service_user, ssh_key)
            return self.moler_device.get_cmd(cmd_name="ssh",
                                             cmd_params={"options": proxy_cmd, "login": None, "host": "",
                                                         "password": password, "repeat_password": False,
                                                         "term_mono": None, "set_timeout": None})

    def build_authorization_cmd(self, bts_id=0, user=None, password=None, address=None, ssh_key=None, device_tag="DU",
                                repeat_password=False):
        """
        Builds proper moler authorization cmd.

        :param bts_id: ID of BTS
        :param user: defined user to authorize or string -> "two_step"
        :param password: list or string (more information in proper method)
        :param address: address of remote device
        :param ssh_key: list or string (more information in proper method)
        :param device_tag:
        :param repeat_password: True if password is to be repeated
        :return: proper moler authorization cmd
        """
        self._prepare_moler_device(bts_id, device_tag)
        if user == "two_step":
            return self.build_authorization_cmd_two_step(password, address, ssh_key)
        elif user == "ssh_passwd":
            return self.build_authorization_cmd_one_step
        else:
            return self.build_authorization_cmd_one_step(user, password, address, ssh_key, repeat_password)

    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def check_authorization_result(self, moler_cmd, should_fail, user, attached_method=None, *args):
        """
        Method used to check if authorization moler cmd ends with success or fails with option to run additional
        moler function in case when authentication is successful.

        :param moler_cmd: authorization moler cmd
        :param should_fail: flag which determinate if authorization should be possible
        :param user: defined user to authorize
        :param attached_method: moler method which be executed
        :param args: args for attached_method
        :return: None
        """
        raise_exception = False
        try:
            moler_cmd()
            if should_fail:
                MolerTest.error("Authentication to {} account finished with success".format(user))
                raise_exception = True
            else:
                MolerTest.info("Authentication to {} account finished with success".format(user))
        except MolerException:
            MolerTest.steps_end()
            if should_fail:
                MolerTest.info("Authentication to {} account failed".format(user))
            else:
                MolerTest.error("Authentication to {} account failed".format(user))
                raise_exception = True
        if not raise_exception and attached_method:
            MolerTest.sleep(seconds=0.5, quiet=True)
            try:
                if args:
                    attached_method(args)
                else:
                    attached_method()
            except MolerException:
                raise_exception = True
                pass
        if not should_fail:
            try:
                cmd_exit = self.moler_device.get_cmd(cmd_name='exit')
                cmd_exit()
                MolerTest.sleep(seconds=1, quiet=True)
            except MolerException:
                pass
        try:
            self.moler_device.goto_state("UNIX_LOCAL", rerun=3)
        except MolerException:
            pass
        self.moler_device.goto_state("UNIX_LOCAL")
        self.moler_device.goto_state("PROXY_PC")
        if raise_exception:
            MolerTest.error("Cannot properly authenticate and/or execute attached method.", raise_exception=True)
        MolerTest.steps_end()

    def check_if_uid_is_not_equal_0(self):
        """
        Run id cmd and check if output is NOT equal 0.

        :return: None
        """
        cmd_id = self.moler_device.get_cmd(cmd_name="id",
                                           cmd_params={"user": "serviceuser",
                                                       "prompt": r"serviceuser@fct-\da.*(>|$)\s*"})

        result = cmd_id()
        MolerTest.info("Output of id serviceuser cmd: {}".format(result["UID"][0]["ID"]))
        if not result["UID"][0]["ID"] == 0:
            MolerTest.info("Good")
        else:
            MolerTest.error("Bad", raise_exception=True)

    def check_root_privileges(self):
        """
        Create test file and try to change it permissions in order to check if user have root privileges.

        :return: None
        """
        cmd_touch = self.moler_device.get_cmd(cmd_name="bash", cmd_params={"bash": "touch test_file",
                                                                           "prompt": r"root@fct-\da.*"})
        cmd_chmod = self.moler_device.get_cmd(cmd_name="chmod",
                                              cmd_params={"permission": "777", "filename": "test_file",
                                                          "prompt": r"root@fct-\da.*"})
        cmd_rm_test_file = self.moler_device.get_cmd(cmd_name="rm", cmd_params={"file": "test_file",
                                                                                "prompt": r"root@fct-\da.*"})
        try:
            cmd_touch()
            cmd_chmod()
            cmd_rm_test_file()
            MolerTest.info("User has root privileges")
        except MolerException:
            MolerTest.error("User does NOT have root privileges", raise_exception=True)

    def run_ls_cmd(self, args):
        cmd_ls = self.moler_device.get_cmd(cmd_name="ls",
                                           cmd_params={"options": "-l",
                                                       "prompt": r"{}@(asc|fct)-\da.*(>|$|#)\s*".format(args[0])})
        try:
            cmd_ls()
            MolerTest.info("Successfully executed 'ls -l' cmd")
        except MolerException:
            MolerTest.error("Can NOT execute 'ls -l' cmd", raise_exception=True)

    def switch_to_toor4nsn_user(self):
        cmd_su = self.moler_device.get_cmd(cmd_name="su",
                                           cmd_params={"login": "toor4nsn", "password": "oZPS0POrRieRtu",
                                                       "allowed_newline_after_prompt": True,
                                                       "set_prompt": r'export PS1="${PS1::-5} $ "',
                                                       "expected_prompt": r'root@.*',
                                                       "prompt_after_login": r'root@.*'})
        try:
            cmd_su()
            MolerTest.info("Successfully switch to toor4nsn account")
        except MolerException:
            MolerTest.error("Can NOT switch to toor4nsn account", raise_exception=True)

    def run_scli_cmd(self):
        self.moler_device.goto_state("SERVICE_USER")
        scli_cmd = self.moler_device.get_cmd(cmd_name="set_user_username",
                                             cmd_params={"login": "toor4nsn", "password": "oZPS0POrRieRtu",
                                                         "expected_prompt": r'[root@.*]',
                                                         "allowed_newline_after_prompt": True,
                                                         'set_timeout': None})
        try:
            scli_cmd()
            MolerTest.info("Successfully log to toor4nsn account via SCLI cmd")
        except MolerException:
            MolerTest.error("Can NOT log to toor4nsn account via SCLI cmd", raise_exception=True)

    def run_scli_cmd_incorrect_password(self):
        self.moler_device.goto_state("SERVICE_USER")
        scli_cmd = self.moler_device.get_cmd(cmd_name="set_user_username",
                                             cmd_params={"login": "toor4nsn", "password": "incorrect_password",
                                                         "expected_prompt": r"\[root@.*]",
                                                         "prompt": r".*",
                                                         "allowed_newline_after_prompt": True,
                                                         'set_timeout': None})
        try:
            scli_cmd()
            MolerTest.error("Successfully log to toor4nsn account via SCLI cmd with incorrect password",
                            raise_exception=True)
        except MolerException:
            MolerTest.info("Can NOT log to toor4nsn account via SCLI cmd with incorrect password")

    @load_moler_configuration_from_tl()
    def _prepare_moler_device(self, bts_id, device_tag):
        if device_tag == "CU":
            self.moler_device = DeviceFactory.get_device("GNB{}_CU".format(bts_id), initial_state="PROXY_PC")
        else:
            self.moler_device = DeviceFactory.get_device("GNB{}".format(bts_id), initial_state="PROXY_PC")

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def change_webem_keys(self, operation, user, number=1, path="/home/ute", should_fail=False, bts_id=0):
        """
        Prepare delta with keys.

        :param should_fail: True or False
        :param operation: update or delete
        :param number: number of keys
        :param user: serviceuser or toor4nsn
        :param path: path where delta is saved
        :param bts_id: ID of BTS
        :return: True, False
        """
        self.delta_path = path
        parameter = self._set_parameter(user)
        self._prepare_moler_device(bts_id, "DU")
        key_files = self._prepare_key_files_list(user)
        self._prepare_delta(key_files, number, parameter, operation)
        self.update_webem_ssh_keys(should_fail=should_fail)
        MolerTest.steps_end()

    def delete_delta_file(self):
        if self.delta_path:
            os.remove("{}/delta.json".format(self.delta_path))

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def compare_keys(self, should_be_different=False, bts_id=0):
        """
        Check if toor4nsn and serviceuser keys are equal.

        :param should_be_different: True or False
        :param bts_id: ID of BTS
        :return: None
        """
        self._prepare_moler_device(bts_id, "DU")
        self.moler_device.goto_state("FCT")
        serviceuser_keys, toor4nsn_keys = self._run_cat_cmd_on_keys_files()
        self._compare_keys_dicts(serviceuser_keys, toor4nsn_keys, should_be_different)
        MolerTest.steps_end()

    @staticmethod
    def _set_parameter(user):
        parameter = "rootUserPublicKeys"
        if user == "serviceuser":
            parameter = "serviceUserPublicKeys"
        return parameter

    def _prepare_delta(self, key_files, number, parameter, operation):
        delta = self._create_delta(parameter, operation)
        for i, key_file in enumerate(key_files):
            if i == int(number):
                break
            cmd_cat = self.moler_device.get_cmd(cmd_name="cat",
                                                cmd_params={"path": "/home/ute/{}".format(key_file)})
            res = cmd_cat()
            line = res["LINES"][0]
            key = {
                "keyDescription": "#{}".format(i + 1),
                "keyValue": line
            }
            delta[0]["parameters"][0]["value"].append(key)
        self._save_delta(delta)

    def _create_delta(self, parameter, operation):
        delta = [
            {
                "distName": "MRBTS-{}/MNL-1/MNLENT-1/SECADM-1".format(self.gnb_id),
                "operation": "update",
                "parameters": [{
                    "parameterName": parameter,
                    "operation": operation,
                    "value": []}]
            }
        ]
        return delta

    def _save_delta(self, delta):
        with open('{}/delta.json'.format(self.delta_path), 'w') as outfile:
            json.dump(delta, outfile)

    def _prepare_key_files_list(self, user):
        cmd_ls = self.moler_device.get_cmd(cmd_name="ls", cmd_params={"path": "/home/ute/"})
        ls_res = cmd_ls()
        key_files = []
        for _file in ls_res["files"]:
            if ".pub" in _file and user in _file:
                key_files.append(_file)
        key_files.sort()
        return key_files

    def _run_cat_cmd_on_keys_files(self):
        cmd_cat = self.moler_device.get_cmd(cmd_name="cat",
                                            cmd_params={"path": "/user/serviceuser/.ssh/authorized_keys"})
        serviceuser_keys = cmd_cat()

        cmd_cat = self.moler_device.get_cmd(cmd_name="cat", cmd_params={"path": "/user/toor4nsn/.ssh/authorized_keys"})
        toor4nsn_keys = cmd_cat()
        return serviceuser_keys, toor4nsn_keys

    @staticmethod
    def _compare_keys_dicts(serviceuser_keys, toor4nsn_keys, should_be_different):
        if serviceuser_keys != toor4nsn_keys:
            if should_be_different:
                MolerTest.info("Keys for serviceuser and toor4nsn are different")
            else:
                MolerTest.error("Keys for serviceuser and toor4nsn are different")
        else:
            if should_be_different:
                MolerTest.error("Keys for serviceuser and toor4nsn are the same")
            else:
                MolerTest.info("Keys for serviceuser and toor4nsn are the same")

    @staticmethod
    def _build_key_name(user, key_number):
        if key_number:
            return "{}_key_{}".format(user, key_number)
        else:
            return "{}_key".format(user)

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def generate_ssh_keys(self, user, passphrase=False, bts_id=0):
        """
        Generate ssh keys.

        :param passphrase: key password
        :param user: serviceuser or toor4nsn
        :param bts_id: ID of BTS
        :return: None
        """
        self._prepare_moler_device(bts_id, "DU")
        cmd_params = dict()
        if passphrase:
            cmd_params = {"passphrase": "123456"}
        for i in range(11):
            if i == 0:
                cmd_params["file"] = "/home/ute/{}_key".format(user)
                cmd_ssh_keygen = self.moler_device.get_cmd(cmd_name="sshkeygen", cmd_params=cmd_params)
                cmd_ssh_keygen()
            else:
                if i < 10:
                    i = "0{}".format(i)
                cmd_params["file"] = "/home/ute/{}_key_{}".format(user, i)
                cmd_ssh_keygen = self.moler_device.get_cmd(cmd_name="sshkeygen", cmd_params=cmd_params)
                cmd_ssh_keygen()

        MolerTest.steps_end()

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def generate_ssh_key_with_passphrase(self, user, passphrase="123456", bts_id=0):
        """
        Generate ssh keys.

        :param passphrase: key password
        :param user: serviceuser or toor4nsn
        :param bts_id: ID of BTS
        :return: None
        """
        self._prepare_moler_device(bts_id, "DU")
        cmd_params = {"passphrase": passphrase, "file": "/home/ute/{}_key_passphrase".format(user)}
        cmd_ssh_keygen = self.moler_device.get_cmd(cmd_name="sshkeygen", cmd_params=cmd_params)
        cmd_ssh_keygen()

        MolerTest.steps_end()

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def delete_ssh_keys(self, user, bts_id=0):
        """
        Delete ssh keys.

        :param user: serviceuser or toor4nsn
        :param bts_id: ID of BTS
        :return: None
        """
        self._prepare_moler_device(bts_id, "DU")
        paths = ["/home/ute/{}_key".format(user), "/home/ute/{}_key.pub".format(user)]
        for i in range(1, 11):
            i_str = "{:02d}".format(i)
            paths.append("/home/ute/{}_key_{}".format(user, i_str))
            paths.append("/home/ute/{}_key_{}.pub".format(user, i_str))
        for path in paths:
            cmd_rm = self.moler_device.get_cmd(cmd_name="rm", cmd_params={"file": path})
            try:
                cmd_rm()
            except CommandFailure as cf:
                exc_msg = str(cf)
                if "No such file or directory" in exc_msg:
                    MolerTest.warning("Cannot remove file '{}' because it does not exist: '{}'.".format(path, exc_msg))
                else:
                    raise

        MolerTest.steps_end()

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def delete_ssh_key_with_passphrase(self, user, bts_id=0):
        """
        Delete ssh keys.

        :param user: serviceuser or toor4nsn
        :param bts_id: ID of BTS
        :return: None
        """
        self._prepare_moler_device(bts_id, "DU")
        cmd_rm = self.moler_device.get_cmd(cmd_name="rm",
                                           cmd_params={"file": "/home/ute/{}_key_passphrase".format(user)})
        cmd_rm()
        cmd_rm = self.moler_device.get_cmd(cmd_name="rm",
                                           cmd_params={"file": "/home/ute/{}_key_passphrase.pub".format(user)})
        cmd_rm()
        MolerTest.steps_end()

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions()
    def get_state_before_fct(self, bts_id=0):
        """
        Get and remember state before FCT (UNIX_LOCAL or PROXY_PC).

        :param bts_id: ID of BTS
        :return: State before FCT.
        """
        device_name = "GNB{}".format(bts_id)
        if device_name in self._state_before_fct:
            return self._state_before_fct[device_name]
        device = DeviceFactory.get_device(device_name)
        state = "PROXY_PC"
        try:
            device.get_configurations(source_state="PROXY_PC", dest_state="FCT")
        except KeyError:
            state = "UNIX_LOCAL"
        self._state_before_fct[device_name] = state
        return state

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions()
    def _check_if_file_exists(self, path, state):
        """
        Check if file exists.

        :param path: path to file to check
        :param state: if not None then try to change state of gnb to this state.
        :return: True if file exists or False if not.
        """
        device = self._cloned_gnb
        if state is not None:
            device.goto_state(state)
        cmd = device.get_cmd(cmd_name="ls", cmd_params={"options": "-l", "path": path})
        try:
            cmd()
        except MolerException:
            return False
        return True

    def check_if_authorized_keys_file_exist(self, path="/user/toor4nsn/.ssh/authorized_keys", state="FCT"):
        if self._check_if_file_exists(path=path, state=state):
            MolerTest.info("Authorized keys file exist")
        else:
            MolerTest.error("Authorized keys file does NOT exist", raise_exception=True)

    def check_if_authorized_keys_file_does_not_exist(self, path="/user/toor4nsn/.ssh/authorized_keys", state="FCT"):
        if not self._check_if_file_exists(path=path, state=state):
            MolerTest.info("Authorized keys file does NOT exist")
        else:
            MolerTest.error("Authorized keys file does NOT exist", raise_exception=True)

    def prepare_ssh_and_clone_in_unix_local(self, bts_id=0):
        """
        Prepare connections for SSH.

        :param bts_id: ID of BTS
        :return: None
        """
        device_name = "GNB{}".format(bts_id)
        cloned_name = "{}_nofr".format(device_name)
        self.moler_device = DeviceFactory.get_device(name=device_name, initial_state="UNIX_LOCAL")
        if self._cloned_gnb is None or self._cloned_gnb.name != cloned_name:
            self._cloned_gnb = DeviceFactory.get_cloned_device(new_name=cloned_name,
                                                               source_device=self.moler_device,
                                                               initial_state="UNIX_LOCAL")
        self._cloned_gnb.goto_state(state="FCT", keep_state=False)
        state = self.get_state_before_fct(bts_id=bts_id)
        self._state_before_fct[cloned_name] = state

    def cu_run_fdisk_cmd_as_toor4nsn(self, bts_id=0):
        self._prepare_moler_device(bts_id, "CU")
        self.moler_device.goto_state("FCT")
        fdisk_cmd = self.moler_device.get_cmd(cmd_name="bash",
                                              cmd_params={"bash": "fdisk -l"})
        try:
            fdisk_cmd()
            MolerTest.info("Cmd 'fdisk -l' executed with success")
        except MolerException:
            MolerTest.error("Cmd 'fdisk -l' CANNOT be executed", raise_exception=True)

    def cu_run_cmd_id_with_output_check(self, bts_id=0):
        self._prepare_moler_device(bts_id, "CU")
        self.moler_device.goto_state("FCT")
        id_a = self.moler_device.get_cmd(cmd_name="id", cmd_params={"user": "toor4nsn"})
        output = id_a()
        if output["UID"][0]["ID"] == 0 and output["GID"][0]["ID"] == 0:
            MolerTest.info("UID of user 'toor4nsn' is equal 0")
        else:
            MolerTest.error("UID of user 'toor4nsn' is NOT equal 0", raise_exception=True)

    def run_cat_cmd_on_ruemlog_has(self, bts_id=0):
        self._prepare_moler_device(bts_id, "DU")
        cmd_cat = self.moler_device.get_cmd(cmd_name="cat", cmd_params={"path": "/rom/config/ruemlog_has.json "})
        cmd_cat()
        MolerTest.info("Run 'cat' cmd on reumlog_has.json possible")

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions()
    def check_internalsshkeys(self, number_of_keys, bts_id=0):
        self._prepare_moler_device(bts_id, "CU")
        self.moler_device.goto_state("FCT")
        cmd_cat = self.moler_device.get_cmd(cmd_name="cat",
                                            cmd_params={
                                                "path": "/var/opt/nokia/lib/externalsshkeys/"
                                                        "serviceuser/authorized_keys"})
        res = str(len(cmd_cat()["LINES"]))
        if res != number_of_keys:
            MolerTest.error("Wrong number of keys in /var/opt/nokia/lib/externalsshkeys/serviceuser/")
        MolerTest.steps_end()

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions()
    def verify_internal_ssh_key_exists(self, key, bts_id=0):
        self._prepare_moler_device(bts_id, "CU")
        self.moler_device.goto_state("FCT")
        cmd_cat = self.moler_device.get_cmd(cmd_name="cat",
                                            cmd_params={
                                                "path": "/var/opt/nokia/lib/externalsshkeys/"
                                                        "serviceuser/authorized_keys"})
        keys = cmd_cat()["LINES"]
        for item in keys:
            if key in item:
                return
        MolerTest.error("key: {} is not in /var/opt/nokia/lib/externalsshkeys/serviceuser/".format(key))
        MolerTest.steps_end()

    @classmethod
    def check_ssh_information(cls, authorization_cmd):
        last_login_flag = False
        failed_login_flag = False
        serviceuser_login_flag = False
        try:
            ssh_info = authorization_cmd()
            MolerTest.info("Authentication to serviceuser account finished with success")
            for line in ssh_info["LINES"]:
                if "Last login:" in line:
                    last_login_flag = True
                elif "There was 1 failed login attempt since the last successful login." in line:
                    failed_login_flag = True
                elif "serviceuser" in line:
                    serviceuser_login_flag = True
            if last_login_flag and failed_login_flag and serviceuser_login_flag:
                MolerTest.info("All ssh information provided")
            else:
                MolerTest.error("Missing expected ssh information", raise_exception=True)
        except MolerException:
            MolerTest.error("Authentication to serviceuser account failed", raise_exception=True)

    @admin_connect
    @MolerTest.raise_background_exceptions()
    def upgrade_software(self, path):
        operation_status = self.admin.update_software(path)
        if operation_status == "Accepted":
            MolerTest.info("Software upgrade end with success")
        else:
            MolerTest.error("Software upgrade failed", raise_exception=True)
        MolerTest.steps_end()

    @admin_connect
    @MolerTest.raise_background_exceptions()
    def software_rollback(self):
        operation_status = self.admin.rollback_software()
        if operation_status == "Accepted":
            MolerTest.info("Software rollback end with success")
        else:
            MolerTest.error("Software rollback upgrade failed", raise_exception=True)
        MolerTest.steps_end()
