from bs4 import BeautifulSoup
from robot.libraries.XML import XML
import re


def get_rimrs_slot_and_nsc_id(pdml_path):
    with open(pdml_path, 'r') as pdml_file:
        xml_tree = BeautifulSoup(pdml_file, 'xml')
        dldata_rimrssendreq = xml_tree.find('proto', {'name': 'nr_l1dl_l2ps_dldata_rimrssendreq_t'})
        if dldata_rimrssendreq:
            slot_num = int(dldata_rimrssendreq.find('field', {'name': re.compile('3gpp.slot')}).get('show'))
            nsc_id_num = int(dldata_rimrssendreq.find('field', {'name': re.compile('DlData_RimRsSendReq_t.nscID')}).get(
                'show'))
            return [slot_num], [nsc_id_num]


def get_slot_and_nsc_id_for_rs1_and_rs2(pdml_path):
    slot_num = []
    nsc_id_num = []
    with open(pdml_path, 'r') as pdml_file:
        xml_tree = BeautifulSoup(pdml_file, 'xml')
        dldata_rimrssendreq = xml_tree.find_all('proto', attrs={'name': 'nr_l1dl_l2ps_dldata_rimrssendreq_t'})
        for data in dldata_rimrssendreq:
            slot_num.append(int(data.find('field', attrs={'name': re.compile('3gpp.slot')}).get('show')))
            nsc_id_num.append(int(data.find('field', attrs={'name': re.compile('DlData_RimRsSendReq_t.nscID')}).get(
                'show')))
    return slot_num, nsc_id_num


def verify_if_rimrssendreq_does_not_occur(pdml_file):
    xpath_container = ".//proto[@name='dldata_rimrssendreq']"
    XML().element_should_not_exist(source=pdml_file, xpath=xpath_container)
