from time import sleep
from taf.selenium.gnb.oam.coam.classical import classical as du_admin
from selenium.common.exceptions import TimeoutException
from coam_api import *


class du_sel(coam_api):
    def __init__(self, host, username='Nemuadmin', password='nemuuser', browser='Chrome', timeout=60):
        self._update_from_locals(locals())
        self.admin = du_admin()

    def connect(self):
        self.admin.enable_virtual_display()
        sleep(5)
        self.admin.login(url='https://' + self.host, username=self.username,
                         password=self.password, browser=self.browser, timeout=self.timeout)
        self.admin.disable_message_box()
        if self.admin.start_up_view_window_exists():
            self.admin.close_start_up_view_window()

    def disconnect(self):
        self.admin.logout()
        self.admin.disable_virtual_display()

    def get_scf(self, coverage='Configuration Only'):
        if coverage == 'Configuration Only':
            return self.admin.save_bts_configuration(0)
        elif coverage == 'Full Runtime':
            return self.admin.save_bts_configuration(1)
