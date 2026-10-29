from time import sleep
from taf.selenium.gnb.oam.coam.cu import cu as cu_admin
from taf.selenium.gnb.oam.coam.cu.common.exceptions import ParamValueError
from coam_api import *
import xml.dom.minidom


class cu_sel(coam_api):
    def __init__(self, host, username='Nemuadmin', password='nemuuser', browser='Firefox'):
        self._update_from_locals(locals())
        self.admin = cu_admin()

    def connect(self):
        self.admin.enable_virtual_display()
        sleep(5)
        self.admin.login(url='https://'+self.host, username=self.username,
                         password=self.password, browser=self.browser)

    def disconnect(self):
        self.admin.logout()
        self.admin.disable_virtual_display()

    def get_scf(self, coverage):
        self.admin.choose_plan('CURRENT_PLAN')
        if coverage == 'Configuration Only':
            return self.admin.save_bts_configuration(0)
        if coverage == 'Full Runtime':
            return self.admin.save_bts_configuration(2)

    def get_parameter_value(self, mo, name, abbr):
        return self.admin.get_parameter_value(object_name=mo, filter_param=name, abbreviation=abbr)

    def _commission_param(self, mo, name, abbr, value):
        delta_name = 'pdl-check'
        timeout = 120
        self.admin.create_delta_plan(delta_name)
        try:
            self.admin.set_parameter_value(
                object_name=mo, filter_param=name, abbr=abbr, new_value=value, timeout=timeout)
            pdl_infos = self.admin.validate_plan(timeout)
        except ParamValueError as e:
            return abbr + ': ' + str(e)
        else:
            return pdl_infos
        finally:
            self.admin.choose_plan(delta_name)
            self.admin.delete_plan(timeout)

    @staticmethod
    def _verify_pdl_result(pdl_infos, abbr, should_pass):
        return (abbr not in str(pdl_infos)) is should_pass

    def check_pdl(self, mo, name, abbr, value, should_pass=True):
        pdl_infos = self._commission_param(mo, name, abbr, value)
        return self._verify_pdl_result(pdl_infos, abbr, should_pass)

    def paramsFile(self, filePath, dist_name, parameter, new_value, save_path):
        doc = xml.dom.minidom.parse(filePath)
        root = doc.documentElement
        cmdDataNode = root.getElementsByTagName('cmData')[0]
        manObjs = root.getElementsByTagName('managedObject')
        for manObj in manObjs:
            if manObj.getAttribute('distName') == dist_name:
                listNode = manObj.getElementsByTagName('p')
                for node in listNode:
                    if node.getAttribute('name') == parameter:
                        n = node.childNodes[0]
                        n.data = new_value
        with open(save_path, 'w') as file:
            doc.writexml(file, encoding='UTF-8')
        return save_path
