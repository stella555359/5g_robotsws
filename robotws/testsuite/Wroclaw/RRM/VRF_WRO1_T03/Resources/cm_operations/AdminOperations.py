from taf.sbts.oam.coam.admin import admin


class AdminOperations(admin):

    def _admin_login_logout(admin_operation):
        def inner(self):
            try:
                self.connect_to_admin()
                return admin_operation(self)
            finally:
                self.teardown_admin_connection()
        return inner

    def connect_to_admin(self):
        self.connect_to()

    def teardown_admin_connection(self):
        self.teardown_admin()

    @_admin_login_logout
    def get_bts_sw_version(self):
        return self.get_sw_version()

    @_admin_login_logout
    def get_bts_sw_release_name(self):
        return self.get_sw_release_name()

    @_admin_login_logout
    def get_bts_main_info(self):
        return self.get_bts_info()
