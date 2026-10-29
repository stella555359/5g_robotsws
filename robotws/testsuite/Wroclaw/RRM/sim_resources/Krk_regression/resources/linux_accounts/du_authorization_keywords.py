from testsuite.Wroclaw.RRM.sim_resources.Krk_regression.resources.linux_accounts.logging.ruemlog import RuemLog


class DuAuthorizationKeywords(RuemLog):

    def __init__(self):
        RuemLog.__init__(self)

    def serviceuser_one_step_password_authorization(self, bts_id=0, should_fail=False):
        lmp_check = self.build_authorization_cmd(bts_id, user="serviceuser", password=self.serviceuser_password,
                                                 address=self.lmp_address, ssh_key=None)
        m_plane_check = self.build_authorization_cmd(bts_id, user="serviceuser", password=self.serviceuser_password,
                                                     address=self.m_plane_address, ssh_key=None)
        self.check_authorization_result(lmp_check, should_fail, "serviceuser")
        self.check_authorization_result(m_plane_check, should_fail, "serviceuser")

    def serviceuser_one_step_password_authorization_with_uid_check(self, bts_id=0, should_fail=False):
        lmp_check = self.build_authorization_cmd(bts_id, user="serviceuser", password=self.serviceuser_password,
                                                 address=self.lmp_address, ssh_key=None)
        m_plane_check = self.build_authorization_cmd(bts_id, user="serviceuser", password=self.serviceuser_password,
                                                     address=self.m_plane_address, ssh_key=None)
        self.check_authorization_result(lmp_check, should_fail, "serviceuser", self.check_if_uid_is_not_equal_0)
        self.check_authorization_result(m_plane_check, should_fail, "serviceuser", self.check_if_uid_is_not_equal_0)

    def serviceuser_one_step_password_authorization_with_invalid_password(self, bts_id=0, should_fail=False):
        lmp_check = self.build_authorization_cmd(bts_id, user="serviceuser", password="invalid_password",
                                                 address=self.lmp_address, ssh_key=None)
        m_plane_check = self.build_authorization_cmd(bts_id, user="serviceuser", password="invalid_password",
                                                     address=self.m_plane_address, ssh_key=None)
        self.check_authorization_result(lmp_check, should_fail, "serviceuser")
        self.check_authorization_result(m_plane_check, should_fail, "serviceuser")

    def serviceuser_one_step_authorization_with_invalid_password_repeatedly(self, bts_id=0, should_fail=False):
        lmp_check = self.build_authorization_cmd(bts_id, user="serviceuser", password="invalid_password",
                                                 address=self.lmp_address, ssh_key=None, repeat_password=True)
        m_plane_check = self.build_authorization_cmd(bts_id, user="serviceuser", password="invalid_password",
                                                     address=self.m_plane_address, ssh_key=None, repeat_password=True)
        self.check_authorization_result(lmp_check, should_fail, "serviceuser")
        self.check_authorization_result(m_plane_check, should_fail, "serviceuser")

    def toor4nsn_one_step_password_authorization(self, bts_id=0, should_fail=False):
        lmp_check = self.build_authorization_cmd(bts_id, user="toor4nsn", password=self.toor4nsn_password,
                                                 address=self.lmp_address, ssh_key=None)
        m_plane_check = self.build_authorization_cmd(bts_id, user="toor4nsn", password=self.toor4nsn_password,
                                                     address=self.m_plane_address, ssh_key=None)
        self.check_authorization_result(lmp_check, should_fail, "toor4nsn")
        self.check_authorization_result(m_plane_check, should_fail, "toor4nsn")

    def toor4nsn_one_step_password_authorization_with_privileges_check(self, bts_id=0, should_fail=False):
        lmp_check = self.build_authorization_cmd(bts_id, user="toor4nsn", password=self.toor4nsn_password,
                                                 address=self.lmp_address, ssh_key=None)
        m_plane_check = self.build_authorization_cmd(bts_id, user="toor4nsn", password=self.toor4nsn_password,
                                                     address=self.m_plane_address, ssh_key=None)
        self.check_authorization_result(lmp_check, should_fail, "toor4nsn", self.check_root_privileges)
        self.check_authorization_result(m_plane_check, should_fail, "toor4nsn", self.check_root_privileges)

    def toor4nsn_two_step_authorization_with_password(self, bts_id=0, should_fail=False):
        lmp_check = self.build_authorization_cmd(bts_id, user="two_step",
                                                 password=[self.serviceuser_password, self.toor4nsn_password],
                                                 address=self.lmp_address, ssh_key=None)
        m_plane_check = self.build_authorization_cmd(bts_id, user="two_step",
                                                     password=[self.serviceuser_password, self.toor4nsn_password],
                                                     address=self.m_plane_address, ssh_key=None)
        self.check_authorization_result(lmp_check, should_fail, "two_step")
        self.check_authorization_result(m_plane_check, should_fail, "two_step")

    def serviceuser_one_step_authorization_with_ssh_key(self, bts_id=0, should_fail=False):
        lmp_check = self.build_authorization_cmd(bts_id, user="serviceuser", address=self.lmp_address,
                                                 ssh_key="{}serviceuser_key".format(self.keys_path))
        m_plane_check = self.build_authorization_cmd(bts_id, user="serviceuser", address=self.m_plane_address,
                                                     ssh_key="{}serviceuser_key".format(self.keys_path))
        self.check_authorization_result(lmp_check, should_fail, "serviceuser")
        self.check_authorization_result(m_plane_check, should_fail, "serviceuser")

    def toor4nsn_one_step_authorization_with_ssh_key(self, bts_id=0, should_fail=False):
        lmp_check = self.build_authorization_cmd(bts_id, user="toor4nsn", address=self.lmp_address,
                                                 ssh_key="{}toor4nsn_key".format(self.keys_path))
        m_plane_check = self.build_authorization_cmd(bts_id, user="toor4nsn", address=self.m_plane_address,
                                                     ssh_key="{}toor4nsn_key".format(self.keys_path))
        self.check_authorization_result(lmp_check, should_fail, "toor4nsn")
        self.check_authorization_result(m_plane_check, should_fail, "toor4nsn")

    def toor4nsn_two_step_authorization_with_different_ssh_keys(self, bts_id=0, should_fail=False):
        lmp_check = self.build_authorization_cmd(bts_id, user="two_step", address=self.lmp_address,
                                                 ssh_key=["{}serviceuser_key".format(self.keys_path),
                                                          "{}toor4nsn_key".format(self.keys_path)])
        m_plane_check = self.build_authorization_cmd(bts_id, user="two_step", address=self.m_plane_address,
                                                     ssh_key=["{}serviceuser_key".format(self.keys_path),
                                                              "{}toor4nsn_key".format(self.keys_path)])
        self.check_authorization_result(lmp_check, should_fail, "two_step")
        self.check_authorization_result(m_plane_check, should_fail, "two_step")

    def toor4nsn_two_step_authorization_with_serviceuser_ssh_key(self, bts_id=0, should_fail=False):
        lmp_check = self.build_authorization_cmd(bts_id, user="two_step", address=self.lmp_address,
                                                 ssh_key=["{}serviceuser_key".format(self.keys_path),
                                                          "{}serviceuser_key".format(self.keys_path)])
        m_plane_check = self.build_authorization_cmd(bts_id, user="two_step", address=self.m_plane_address,
                                                     ssh_key=["{}serviceuser_key".format(self.keys_path),
                                                              "{}serviceuser_key".format(self.keys_path)])
        self.check_authorization_result(lmp_check, should_fail, "two_step")
        self.check_authorization_result(m_plane_check, should_fail, "two_step")

    def toor4nsn_two_step_authorization_with_different_ssh_keys_and_privileges_check(self, bts_id=0,
                                                                                     should_fail=False):
        lmp_check = self.build_authorization_cmd(bts_id, user="two_step", address=self.lmp_address,
                                                 ssh_key=["{}serviceuser_key".format(self.keys_path),
                                                          "{}toor4nsn_key".format(self.keys_path)])
        m_plane_check = self.build_authorization_cmd(bts_id, user="two_step", address=self.m_plane_address,
                                                     ssh_key=["{}serviceuser_key".format(self.keys_path),
                                                              "{}toor4nsn_key".format(self.keys_path)])
        self.check_authorization_result(lmp_check, should_fail, "two_step", self.check_root_privileges)
        self.check_authorization_result(m_plane_check, should_fail, "two_step", self.check_root_privileges)

    def serviceuser_one_step_authorization_with_defined_ssh_key(self, bts_id=0, key_number=None, should_fail=False):
        key_name = self._build_key_name("serviceuser", key_number)
        m_plane_check = self.build_authorization_cmd(bts_id, user="serviceuser", address=self.m_plane_address,
                                                     ssh_key="{}{}".format(self.keys_path, key_name))
        self.check_authorization_result(m_plane_check, should_fail, "serviceuser")

    def toor4nsn_two_step_authorization_with_password_and_defined_ssh_key(self, bts_id=0, key_number=None,
                                                                          should_fail=False):
        key_name = self._build_key_name("toor4nsn", key_number)
        m_plane_check = self.build_authorization_cmd(bts_id, user="two_step", address=self.m_plane_address,
                                                     password=self.serviceuser_password,
                                                     ssh_key="{}{}".format(self.keys_path, key_name))
        self.check_authorization_result(m_plane_check, should_fail, "two_step")

    def toor4nsn_one_step_authorization_with_invalid_ssh_key(self, bts_id=0, should_fail=False):
        lmp_check = self.build_authorization_cmd(bts_id, user="toor4nsn", address=self.lmp_address,
                                                 ssh_key="{}serviceuser_key".format(self.keys_path))
        m_plane_check = self.build_authorization_cmd(bts_id, user="toor4nsn", address=self.m_plane_address,
                                                     ssh_key="{}serviceuser_key".format(self.keys_path))
        self.check_authorization_result(lmp_check, should_fail, "toor4nsn")
        self.check_authorization_result(m_plane_check, should_fail, "toor4nsn")

    def toor4nsn_one_step_authorization_with_invalid_password(self, bts_id=0, should_fail=False):
        lmp_check = self.build_authorization_cmd(bts_id, user="toor4nsn", password="incorrect_password",
                                                 address=self.lmp_address, ssh_key=None)
        m_plane_check = self.build_authorization_cmd(bts_id, user="toor4nsn", password="incorrect_password",
                                                     address=self.m_plane_address, ssh_key=None)
        self.check_authorization_result(lmp_check, should_fail, "toor4nsn")
        self.check_authorization_result(m_plane_check, should_fail, "toor4nsn")

    def toor4nsn_one_step_authorization_with_invalid_password_repeatedly(self, bts_id=0, should_fail=False):
        lmp_check = self.build_authorization_cmd(bts_id, user="toor4nsn", password="incorrect_password",
                                                 address=self.lmp_address, ssh_key=None, repeat_password=True)
        m_plane_check = self.build_authorization_cmd(bts_id, user="toor4nsn", password="incorrect_password",
                                                     address=self.m_plane_address, ssh_key=None, repeat_password=True)
        self.check_authorization_result(lmp_check, should_fail, "toor4nsn")
        self.check_authorization_result(m_plane_check, should_fail, "toor4nsn")

    def toor4nsn_one_step_password_authorization_with_incorrect_user(self, bts_id=0, should_fail=False):
        lmp_check = self.build_authorization_cmd(bts_id, user="bad_user", password=self.toor4nsn_password,
                                                 address=self.lmp_address, ssh_key=None)
        m_plane_check = self.build_authorization_cmd(bts_id, user="bad_user", password=self.toor4nsn_password,
                                                     address=self.m_plane_address, ssh_key=None)
        self.check_authorization_result(lmp_check, should_fail, "toor4nsn")
        self.check_authorization_result(m_plane_check, should_fail, "toor4nsn")

    def serviceuser_one_step_authorization_with_invalid_ssh_key(self, bts_id=0, should_fail=False):
        lmp_check = self.build_authorization_cmd(bts_id, user="serviceuser", address=self.lmp_address,
                                                 ssh_key="{}toor4nsn_key".format(self.keys_path))
        m_plane_check = self.build_authorization_cmd(bts_id, user="serviceuser", address=self.m_plane_address,
                                                     ssh_key="{}toor4nsn_key".format(self.keys_path))
        self.check_authorization_result(lmp_check, should_fail, "serviceuser")
        self.check_authorization_result(m_plane_check, should_fail, "serviceuser")

    def serviceuser_one_step_password_authorization_with_cat_on_auditlogserver(self, bts_id=0, should_fail=False):
        lmp_check = self.build_authorization_cmd(bts_id, user="serviceuser", password=self.serviceuser_password,
                                                 address=self.lmp_address, ssh_key=None)
        m_plane_check = self.build_authorization_cmd(bts_id, user="serviceuser", password=self.serviceuser_password,
                                                     address=self.m_plane_address, ssh_key=None)
        self.check_authorization_result(lmp_check, should_fail, "serviceuser", self.cat_auditlogserver, "serviceuser")
        self.check_authorization_result(m_plane_check, should_fail, "serviceuser", self.cat_auditlogserver,
                                        "serviceuser")

    def toor4nsn_one_step_password_authorization_with_cat_on_auditlogserver(self, bts_id=0, should_fail=False):
        lmp_check = self.build_authorization_cmd(bts_id, user="toor4nsn", password=self.toor4nsn_password,
                                                 address=self.lmp_address, ssh_key=None)
        m_plane_check = self.build_authorization_cmd(bts_id, user="toor4nsn", password=self.toor4nsn_password,
                                                     address=self.m_plane_address, ssh_key=None)
        self.check_authorization_result(lmp_check, should_fail, "toor4nsn", self.cat_auditlogserver, "toor4nsn")
        self.check_authorization_result(m_plane_check, should_fail, "toor4nsn", self.cat_auditlogserver, "toor4nsn")

    def serviceuser_one_step_password_authorization_with_ls_cmd(self, bts_id=0, should_fail=False):
        lmp_check = self.build_authorization_cmd(bts_id, user="serviceuser", password=self.serviceuser_password,
                                                 address=self.lmp_address, ssh_key=None)
        m_plane_check = self.build_authorization_cmd(bts_id, user="serviceuser", password=self.serviceuser_password,
                                                     address=self.m_plane_address, ssh_key=None)
        self.check_authorization_result(lmp_check, should_fail, "serviceuser", self.run_ls_cmd, "serviceuser")
        self.check_authorization_result(m_plane_check, should_fail, "serviceuser", self.run_ls_cmd, "serviceuser")

    def toor4nsn_one_step_password_authorization_with_ls_cmd(self, bts_id=0, should_fail=False):
        lmp_check = self.build_authorization_cmd(bts_id, user="toor4nsn", password=self.toor4nsn_password,
                                                 address=self.lmp_address, ssh_key=None)
        m_plane_check = self.build_authorization_cmd(bts_id, user="toor4nsn", password=self.toor4nsn_password,
                                                     address=self.m_plane_address, ssh_key=None)
        self.check_authorization_result(lmp_check, should_fail, "toor4nsn", self.run_ls_cmd, "root")
        self.check_authorization_result(m_plane_check, should_fail, "toor4nsn", self.run_ls_cmd, "root")
