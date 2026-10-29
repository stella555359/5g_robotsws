from taf.sbts.oam.coam.admin import admin
from time import sleep
from testsuite.Wroclaw.SyVe.RRM.resources.Logger import Logger
from testsuite.Wroclaw.SyVe.RRM.resources.TestEnvData import TestEnvData as Env


class BtsAdminApi(object):

    def __init__(self, bts_host=Env.GNB_HTTPS_CONNECTION_HOST, alias='default'):
        self._api = admin()
        self.bts_host = bts_host
        self.alias = alias

    def __enter__(self):
        return self._api.connect_to(bts_host=self.bts_host, release=Env.ADMIN_CONNECT_STREAM, name=self.alias)

    def __exit__(self, exc_type, exc_val, exc_tb):
        self._api.teardown()

    def wait_for_admin_connection_possibility(self, timeout=300, interval=15):
        fail_msg = "There was problem with Admin connection to BTS within {}s".format(timeout)
        Logger.info("Trying admin connection possibility")
        while timeout > 0:
            sleep(interval)
            try:
                self._api.connect_to(bts_host=self.bts_host, release=Env.ADMIN_CONNECT_STREAM)
                self._api.teardown()
                Logger.debug("BTS Admin Connected!")
                return
            except Exception as e:
                Logger.debug("BTS Admin not connected yet! Reason: '{}'".format(e))
                timeout -= interval
        assert False, fail_msg

    def admin_api_connect_to(self):
        return self._api.connect_to(bts_host=self.bts_host, release=Env.ADMIN_CONNECT_STREAM, name=self.alias)

    def admin_api_teardown(self, connection=None):
        self._api.teardown(connection)
