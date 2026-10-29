# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: I_ASL3_HZH_TA_FRAMEWORK_GMS@internal.nsn.com
:contact: I_ASL3_HZH_TA_FRAMEWORK_GMS@internal.nsn.com
"""
import time
from robot.libraries.BuiltIn import BuiltIn
from taf.hw.rf_attenuator import attenuator
from ..common_lib_aic import common_lib_aic
from ..base_lib.ta_xml import ta_xml
from ..base_lib.ta_xml.common_xml import CommonXML
from taf.gnb.oam.coam.vdu import Vdu
import traceback
import re

builtin_obj = BuiltIn()
comm_obj = common_lib_aic()
xml_obj = ta_xml()


class pa_base(object):
    def __init__(self):
        self._setup_pa_flag = False
        self.remote_host = None
        self.du_host = ""  # will get from class instance
        self.alias = ""  # will get from class instance

    def _setup_pa(self):
        if not self._setup_pa_flag:
            self._setup_pa_flag = True
            self.pa_obj = attenuator()
            self.tl = builtin_obj.get_variable_value("${tl}")
            self.du_obj = Vdu()
            self.cell_rru_ant_mapping, self.rru_ids = self._get_cell_rru_ant_mapping()

    def _get_cell_rru_ant_mapping(self):
        builtin_obj.log("step: get cell, rru and ant mapping")
        bts_port, use_ssl = comm_obj.define_admin_port()
        try:
            self.du_obj.connect_to(
                host=self.du_host,
                port=bts_port,
                username="Nemuadmin",
                password="Nokia@123",
                secure=use_ssl,
                connection_name=self.alias)
            self.du_obj.get_current_plan_file(
                local_dir_path=("/home/ute"),
                filename="scf.xml",
                timeout=100,
                include_runtime_data=True,
                vdu_connection=self.alias)
        except Exception:
            detail = traceback.format_exc()
            builtin_obj.log(detail)
            raise Exception("fail to download scf from du")
        finally:
            self.du_obj.disconnect(vdu_connection=self.alias)
        nr_cell_rru_ant_mapping, rru_ids_1 = self._get_cell_mapping("/home/ute/scf.xml", "NRCELL", "LCELNR")
        builtin_obj.log("debug: nr_cell_rru_ant_mapping={}, rru_ids={}".format(nr_cell_rru_ant_mapping, rru_ids_1))
        lte_cell_rru_ant_mapping, rru_ids_2 = self._get_cell_mapping("/home/ute/scf.xml", "LNCEL", "LCELL")
        builtin_obj.log("debug: lte_cell_rru_ant_mapping={}, rru_ids={}".format(lte_cell_rru_ant_mapping, rru_ids_2))
        cell_rru_ant_mapping = nr_cell_rru_ant_mapping | lte_cell_rru_ant_mapping
        rru_ids = list(set(rru_ids_1 + rru_ids_2))
        rru_ids.sort()
        builtin_obj.log("debug: cell_rru_ant_mapping={}, rru_ids={}".format(cell_rru_ant_mapping, rru_ids))
        return cell_rru_ant_mapping, rru_ids

    def _get_cell_mapping(self, scf, cell_class, lcell_class):
        cell_rru_ant_mapping = {}
        rru_ids = []
        commxml_obj = CommonXML(scf)
        cell_elements = commxml_obj.get_elements("//managedObject[matches(@class, '.*:{}$')]".format(cell_class))
        for cell_e in cell_elements:
            rru_ant_sub_dict = {}
            dn = commxml_obj.get_element_attribute(cell_e, "distName")
            instance_id = dn.rpartition("-")[-1]
            lcr_id = xml_obj.read_xml(scf,
                                      "text|//*[matches(@distName, '.*/{}-{}$')]/*[matches(@name, 'lcrId')]".format(
                                          cell_class, instance_id))
            # print("lcrid_id={}".format(lcr_id))
            antlDN_xpath = r"//managedObject[matches(@distName, '.*/{}-{}/CHANNELGROUP-\d+/CHANNEL-\d+$')]" \
                           "/*[@name='antlDN']".format(lcell_class, lcr_id)
            # print(antlDN_xpath)
            antlDN_elements = commxml_obj.get_elements(antlDN_xpath)
            if len(antlDN_elements):
                for antlDN_e in antlDN_elements:
                    antlDN = commxml_obj.get_element_text(antlDN_e)
                    # print("antldn={}".format(antlDN))
                    rru_id = antlDN.split("/")[-2].split("-")[-1]
                    ant_id = antlDN.split("/")[-1].split("-")[-1]
                    if rru_id not in rru_ant_sub_dict:
                        rru_ant_sub_dict[rru_id] = [ant_id]
                    else:
                        ant_ids = rru_ant_sub_dict[rru_id]
                        ant_ids.append(ant_id)
                        ant_ids = list(set(ant_ids))
                        rru_ant_sub_dict[rru_id] = ant_ids
                        ant_ids.sort()
                    rru_ids.append(rru_id)
            else:
                phyant_xpath = r"//managedObject[matches(@distName, '.*/{}-{}/CHANNELGROUP-\d+/CHANNEL-\d+$')]" \
                                "/*[@name='resourceDN']".format(lcell_class, lcr_id)
                phyant_elements = commxml_obj.get_elements(phyant_xpath)
                if len(phyant_elements):
                    phyant_0 = commxml_obj.get_element_text(phyant_elements[0])
                    rru_id = phyant_0.split("/")[-2].split("-")[-1]
                    rru_ant_sub_dict[rru_id] = []
                    rru_ids.append(rru_id)
            cell_rru_ant_mapping[dn.split("-")[-1]] = rru_ant_sub_dict
        rru_ids = list(set(rru_ids))
        return cell_rru_ant_mapping, rru_ids

    def _adjust_one_pa_max_value(self, attenuator):
        self._setup_pa()
        max_value = 140
        self.pa_obj.setup_attenuator(attenuator)
        ports = [int(port) for port in attenuator.attenuation_port_numbers]
        try:
            values = [max_value] * len(ports)
            builtin_obj.log("step: set {} {} with {}".format(attenuator.ip_addr, ports, values))
            self.pa_obj.set_ports_attenuation(ports, values, confirm=True)
        except Exception:
            detail = traceback.format_exc()
            builtin_obj.log("debug:{}".format(detail))
            match = re.search(r" Given value .* dB is out of range \[\d+ dB, (\d+)\s*dB\]", detail, re.I)
            if match:
                max_value = match.group(1)
                values = [int(max_value)] * len(ports)
                builtin_obj.log("step: set {} {} with {}".format(attenuator.ip_addr, ports, values))
                self.pa_obj.set_ports_attenuation(ports, values, confirm=True)
            else:
                raise Exception(detail)
        values = self.pa_obj.read_ports_attenuation(ports)
        builtin_obj.log("step: read ports:{} {}, values:{}".format(attenuator.ip_addr, ports, values))

    def _adjust_pa_all_ports_max_value(self):
        self._setup_pa()
        try:
            # multiple attenuators
            attenuators = self.tl.attenuators
            for attenuator in attenuators:
                self._adjust_one_pa_max_value(attenuator)
        except NameError:
            self._adjust_one_pa_max_value(self.tl.attenuator)

    def _classify_pa(self, attenuation_ports, ant_ids):
        """
        :param attenuation_ports: all attenuation_ports of one RRU, refer to TL init file
        :param ant_ids: RRU ant ids, which setup one cell
        :return: dictionary of pa and ports, key is pa, value is ports
        """
        pa_ports_mapping = {}
        if len(ant_ids) == 0 or len(ant_ids) > len(attenuation_ports):
            # for massiveMIMO RRU or not all ant ports are connected to PA, treat all ports serving the cell
            atten_indexes = range(len(attenuation_ports))
        else:
            atten_indexes = [int(ant_id)-1 for ant_id in ant_ids]
        for index in atten_indexes:
            attenuator = attenuation_ports[index].attenuator
            port = attenuation_ports[index].port_no
            if attenuator not in pa_ports_mapping:
                pa_ports_mapping[attenuator] = [port]
            else:
                ports = pa_ports_mapping[attenuator]
                ports.append(port)
                pa_ports_mapping[attenuator] = ports
        return pa_ports_mapping

    def _adjust_pa_for_cell(self, cell_id, value, confirm):
        self._setup_pa()
        for rru_id, ant_ids in self.cell_rru_ant_mapping[cell_id].items():
            builtin_obj.log("debug: cell: {}, rru and ant ports: {}".format(cell_id,
                                                                            self.cell_rru_ant_mapping[cell_id]))
            ru_index = self.rru_ids.index(rru_id)
            if self.alias == "du1_pa":
                ru = self.tl.gnbs[0].dus[0].rannics[0].rus[ru_index]
            elif self.alias == "du2_pa":
                ru = self.tl.gnbs[0].dus[1].rannics[0].rus[ru_index]
            elif self.alias == "du3_pa":
                ru = self.tl.gnbs[0].dus[2].rannics[0].rus[ru_index]
            elif self.alias == "du4_pa":
                ru = self.tl.gnbs[0].dus[3].rannics[0].rus[ru_index]
            else:
                raise Exception("not support alias:{}".format(self.alias))
            builtin_obj.log("debug: ru_index={}".format(ru_index))
            attenuator_ports_dict = self._classify_pa(ru.attenuation_ports, ant_ids)
            for attenuator, ports in attenuator_ports_dict.items():
                builtin_obj.log("debug: att={}".format(attenuator))
                self.pa_obj.setup_attenuator(attenuator)
                values = [value] * len(ports)
                builtin_obj.log("step: set {} {} with {}".format(attenuator.ip_addr, ports, values))
                self.pa_obj.set_ports_attenuation(ports, values, confirm=confirm)
                values = self.pa_obj.read_ports_attenuation(ports)
                builtin_obj.log("step: read ports:{} {}, values:{}".format(attenuator.ip_addr, ports, values))

    def _adjust_pa_stepwise_for_cell(self, cell_id, start_value, end_value, step, interval):
        current_value = int(start_value)
        while current_value <= int(end_value):
            self._adjust_pa_for_cell(cell_id=cell_id, value=current_value, confirm=False)
            time.sleep(int(interval))
            current_value = current_value + float(step)


class pa_du1(object):
    def __init__(self):
        self.pa_base_instance_1 = pa_base()

    def _setup_du1_pa(self):
        self.pa_base_instance_1.alias = "du1_pa"
        self.pa_base_instance_1.du_host = builtin_obj.get_variable_value("${VDU_IP}")

    def adjust_pa_all_ports_max_value(self):
        self._setup_du1_pa()
        self.pa_base_instance_1._adjust_pa_all_ports_max_value()

    def adjust_pa_for_cell_du1(self, cell_id, value=0):
        self._setup_du1_pa()
        self.pa_base_instance_1._adjust_pa_for_cell(cell_id, value, confirm=True)

    def adjust_pa_stepwise_for_cell_du1(self, cell_id, start_value, end_value, step=2, interval=0):
        self._setup_du1_pa()
        self.pa_base_instance_1._adjust_pa_stepwise_for_cell(
            cell_id, start_value, end_value, step, interval)


class pa_du2(object):
    def __init__(self):
        self.pa_base_instance_2 = pa_base()

    def _setup_du2_pa(self):
        self.pa_base_instance_2.alias = "du2_pa"
        self.pa_base_instance_2.du_host = builtin_obj.get_variable_value("${VDU2_IP}")

    def adjust_pa_for_cell_du2(self, cell_id, value=0):
        self._setup_du2_pa()
        self.pa_base_instance_2._adjust_pa_for_cell(cell_id, value, confirm=True)

    def adjust_pa_stepwise_for_cell_du2(self, cell_id, start_value, end_value, step=2, interval=0):
        self._setup_du2_pa()
        self.pa_base_instance_2._adjust_pa_stepwise_for_cell(
            cell_id, start_value, end_value, step, interval)


class pa_du3(object):
    def __init__(self):
        self.pa_base_instance_3 = pa_base()

    def _setup_du3_pa(self):
        self.pa_base_instance_3.alias = "du3_pa"
        self.pa_base_instance_3.du_host = builtin_obj.get_variable_value("${VDU3_IP}")

    def adjust_pa_for_cell_du3(self, cell_id, value=0):
        self._setup_du3_pa()
        self.pa_base_instance_3._adjust_pa_for_cell(cell_id, value, confirm=True)

    def adjust_pa_stepwise_for_cell_du3(self, cell_id, start_value, end_value, step=2, interval=0):
        self._setup_du3_pa()
        self.pa_base_instance_3._adjust_pa_stepwise_for_cell(
            cell_id, start_value, end_value, step, interval)


class pa_du4(object):
    def __init__(self):
        self.pa_base_instance_4 = pa_base()

    def _setup_du4_pa(self):
        self.pa_base_instance_4.alias = "du4_pa"
        self.pa_base_instance_4.du_host = builtin_obj.get_variable_value("${VDU4_IP}")

    def adjust_pa_for_cell_du4(self, cell_id, value=0):
        self._setup_du4_pa()
        self.pa_base_instance_4._adjust_pa_for_cell(cell_id, value, confirm=True)

    def adjust_pa_stepwise_for_cell_du4(self, cell_id, start_value, end_value, step=2, interval=0):
        self._setup_du4_pa()
        self.pa_base_instance_4._adjust_pa_stepwise_for_cell(
            cell_id, start_value, end_value, step, interval)


class pa_aic(pa_du1, pa_du2, pa_du3, pa_du4):
    def __init__(self):
        pa_du1.__init__(self)
        pa_du2.__init__(self)
        pa_du3.__init__(self)
        pa_du4.__init__(self)


if __name__ == "__main__":
    pa_obj = pa_aic()
    help(pa_obj)
