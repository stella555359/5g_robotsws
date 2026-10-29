from robot.libraries.BuiltIn import BuiltIn
from moler.util.moler_test import MolerTest
from functools import wraps
from taf.sbts.oam.coam.admin import admin

tl = BuiltIn().get_variable_value("${tl}")


def enb_login_logout(web_fun):
    @wraps(web_fun)
    def wrapper(self, *args, **kwargs):
        self.admin.connect_to(bts_host=tl.enbs[kwargs.get("enb_id")].oam_ip.v4)
        result = web_fun(self, *args, **kwargs)
        return result

    return wrapper


class EnbKeywords:

    def __init__(self):
        self.admin = admin()

    @enb_login_logout
    def change_enb_parameter(self, dist_name, parameter, value, enb_id=0):
        """
        Change eNB parameter
        :param dist_name: object dist name
        :param parameter: name of parameter
        :param value: new value of parameter
        :param enb_id: eNB ID
        :return: None
        """
        self.admin.perform_parameter_recommissioning(dist_name=dist_name, parameter=parameter, operation="update",
                                                     value=value)

    @enb_login_logout
    def delete_enb_parameter(self, dist_name, parameter, enb_id=0):
        """
        Delete eNB parameter
        :param dist_name: object dist name
        :param parameter: name of parameter
        :param enb_id: eNB ID
        :return: None
        """
        self.admin.perform_parameter_recommissioning(dist_name=dist_name, parameter=parameter, operation="delete",
                                                     value="")

    @enb_login_logout
    def get_enb_parameter(self, dist_name, parameter, enb_id=0):
        """
        Get eNB parameter
        :param dist_name: object dist name
        :param parameter: name of parameter
        :param enb_id: eNB ID
        :return: None
        """
        bts_configuration = self.admin.get_scf(export_type="configurationAndRuntimeObjects")
        if not dist_name:
            value = str(bts_configuration).partition('<p name="{}">'.format(parameter))[2].partition('</p>')[0]
            return value
        value = str(bts_configuration).partition('distName="{}"'.format(dist_name))[2]
        value = value.partition('<p name="{}">'.format(parameter))[2].partition('</p>')[0]
        return value
