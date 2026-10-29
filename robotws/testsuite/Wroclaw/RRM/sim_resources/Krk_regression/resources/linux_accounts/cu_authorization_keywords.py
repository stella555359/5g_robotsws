from testsuite.Wroclaw.RRM.sim_resources.Krk_regression.resources.linux_accounts.du_authorization_keywords \
    import DuAuthorizationKeywords


class CuAuthorizationKeywords(DuAuthorizationKeywords):

    def __init__(self):
        DuAuthorizationKeywords.__init__(self)

    def cu_serviceuser_one_step_password_authorization(self, bts_id=0, should_fail=False):
        cu_check = self.build_authorization_cmd(bts_id, user="serviceuser", password=self.serviceuser_password,
                                                address=self.cu_address, ssh_key=None, device_tag="CU")
        self.check_authorization_result(cu_check, should_fail, "serviceuser")

    def cu_serviceuser_one_step_authorization_with_ssh_key_and_passphrase(self, passphrase="123456", bts_id=0,
                                                                          should_fail=False):
        cu_check = self.build_authorization_cmd(bts_id, user="serviceuser", address=self.cu_address,
                                                password=passphrase,
                                                ssh_key="{}serviceuser_key_passphrase".format(self.keys_path),
                                                device_tag="CU", repeat_password=True)
        self.check_authorization_result(cu_check, should_fail, "serviceuser")

    def cu_serviceuser_one_step_authorization_with_ssh_key(self, bts_id=0, should_fail=False):
        cu_check = self.build_authorization_cmd(bts_id, user="serviceuser", address=self.cu_address,
                                                ssh_key="{}serviceuser_key".format(self.keys_path),
                                                device_tag="CU")
        self.check_authorization_result(cu_check, should_fail, "serviceuser")

    def cu_serviceuser_one_step_authorization_with_invalid_password_repeatedly(self, bts_id=0, should_fail=False):
        cu_check = self.build_authorization_cmd(bts_id, user="serviceuser", password="invalid_password",
                                                address=self.cu_address, ssh_key=None, repeat_password=True)
        self.check_authorization_result(cu_check, should_fail, "serviceuser")

    def cu_robot_one_step_password_authorization(self, bts_id=0, should_fail=False):
        cu_check = self.build_authorization_cmd(bts_id, user="robot", password=self.robot_password,
                                                address=self.cu_address, ssh_key=None, device_tag="CU")
        self.check_authorization_result(cu_check, should_fail, "robot")

    def cu_robot_one_step_password_authorization_with_incorrect_username(self, bts_id=0, should_fail=False):
        cu_check = self.build_authorization_cmd(bts_id, user="nykaenen", password=self.robot_password,
                                                address=self.cu_address, ssh_key=None, device_tag="CU")
        self.check_authorization_result(cu_check, should_fail, "nykaenen")

    def cu_toor4nsn_two_step_password_authorization_via_robot(self, bts_id=0, should_fail=False):
        cu_check = self.build_authorization_cmd(bts_id, user="robot", password=self.robot_password,
                                                address=self.cu_address, ssh_key=None, device_tag="CU")
        self.check_authorization_result(cu_check, should_fail, "robot",
                                        attached_method=self.switch_to_toor4nsn_user)

    def cu_toor4nsn_one_step_password_authorization(self, bts_id=0, should_fail=False):
        cu_check = self.build_authorization_cmd(bts_id, user="toor4nsn", password=self.toor4nsn_password,
                                                address=self.cu_address, ssh_key=None, device_tag="CU")
        self.check_authorization_result(cu_check, should_fail, "toor4nsn")

    def cu_serviceuser_one_step_incorrect_password_authorization(self, bts_id=0, should_fail=False):
        cu_check = self.build_authorization_cmd(bts_id, user="serviceuser", password="incorrect_password",
                                                address=self.cu_address, ssh_key=None, device_tag="CU")
        self.check_authorization_result(cu_check, should_fail, "serviceuser")

    def cu_serviceuser_incorrect_password_authorization_with_limit_exceeded(self, bts_id=0, should_fail=False):
        cu_check = self.build_authorization_cmd(bts_id, user="serviceuser", password="incorrect_password",
                                                address=self.cu_address, ssh_key=None, device_tag="CU",
                                                repeat_password=True)
        self.check_authorization_result(cu_check, should_fail, "serviceuser")

    def cu_serviceuser_one_step_authorization_with_passphrase(self, bts_id=0, should_fail=False):
        cu_check = self.build_authorization_cmd(bts_id, user="serviceuser", password="123456",
                                                address=self.cu_address,
                                                ssh_key="{}serviceuser_key".format(self.keys_path),
                                                device_tag="CU")
        self.check_authorization_result(cu_check, should_fail, "serviceuser")

    def cu_toor4nsn_two_step_authorization_via_serviceuser_with_scli_cmd(self, bts_id=0, should_fail=False):
        cu_check = self.build_authorization_cmd(bts_id, user="serviceuser", password=self.serviceuser_password,
                                                address=self.cu_address, ssh_key=None, device_tag="CU")
        self.check_authorization_result(cu_check, should_fail, "serviceuser", attached_method=self.run_scli_cmd)

    def cu_toor4nsn_two_step_authorization_via_serviceuser_with_incorrect_password(self, bts_id=0, should_fail=False):
        cu_check = self.build_authorization_cmd(bts_id, user="serviceuser", password=self.serviceuser_password,
                                                address=self.cu_address, ssh_key=None, device_tag="CU")
        self.check_authorization_result(cu_check, should_fail, "serviceuser",
                                        attached_method=self.run_scli_cmd_incorrect_password)

    def cu_serviceuser_one_step_authorization_with_ssh_info_check(self, bts_id=0):
        cu_check_step_1 = self.build_authorization_cmd(bts_id, user="serviceuser", password="incorrect_password",
                                                       address=self.cu_address, ssh_key=None, device_tag="CU")
        cu_check_step_2 = self.build_authorization_cmd(bts_id, user="serviceuser", password=self.serviceuser_password,
                                                       address=self.cu_address, ssh_key=None, device_tag="CU")
        self.check_authorization_result(cu_check_step_1, True, "serviceuser")
        self.check_ssh_information(cu_check_step_2)
