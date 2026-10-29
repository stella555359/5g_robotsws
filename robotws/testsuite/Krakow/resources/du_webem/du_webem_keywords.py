from taf.selenium.gnb.oam.coam.classical.interface import classical as du_selenium
from taf.sbts.oam.coam.admin import admin as du_admin
from robot.libraries.BuiltIn import BuiltIn
from functools import wraps


def selenium_connect(web_fun):
    @wraps(web_fun)
    def wrapper(self, *args, **kwargs):
        self.du_selenium_connection.login('https://{}/'.format(self.du_address), "Nemuadmin", "nemuuser")
        try:
            result = web_fun(self, *args, **kwargs)
            return result
        finally:
            pass

    return wrapper


def admin_connect(web_fun):
    @wraps(web_fun)
    def wrapper(self, *args, **kwargs):
        self.du_admin_connection.connect_to()
        try:
            result = web_fun(self, *args, **kwargs)
            return result
        finally:
            self.du_admin_connection.teardown_admin()

    return wrapper


class DuWebem(object):
    def __init__(self):
        tl = BuiltIn().get_variable_value('${{{}}}'.format("tl"), None)
        self.du_address = tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr
        self.du_selenium_connection = du_selenium()
        self.du_admin_connection = du_admin()

    @admin_connect
    def install_bts_certificate(self, path, certificate_password):
        """
        Install certificates on CU.

        :param path: path to .p12 file
        :param certificate_password: certificate file password
        :return: None
        """
        self.du_admin_connection.install_certificate(cert_file=path, cert_type="BtsTrustChain", cert_format="P12",
                                                     password=certificate_password)

    @admin_connect
    def restore_vendor_certificates(self):
        """
        Restore default certificates on DU.

        :return: None
        """
        self.du_admin_connection.restore_vendor_certificate()
