from robot.libraries.XML import XML
from bs4 import BeautifulSoup
import re


def get_rimrs_slot_and_sfn(pdml_path):
    slot_num = []
    sfn_num = []
    with open(pdml_path, 'r') as pdml_file:
        xml_tree = BeautifulSoup(pdml_file, 'xml')
        dldata_rimrssendreq = xml_tree.find_all('proto', attrs={'name': 'nr_l1dl_l2ps_dldata_rimrssendreq_t'})
        for data in dldata_rimrssendreq:
            slot_num.append(int(data.find('field', attrs={'name': re.compile('3gpp.slot')}).get('show')))
            sfn_num.append(int(data.find('field', attrs={'name': re.compile('3gpp.sfn')}).get('show')))
    return slot_num, sfn_num


def verify_rimrssendreq_is_visible(pdml_file):
    xpath_container = ".//proto[@name='dldata_rimrssendreq']"
    XML().element_should_exist(source=pdml_file, xpath=xpath_container)


def verify_if_starting_rb_for_rimrs_is_correct(pdml_file):
    xpath_startRbforRS = ".//field[@name='DlData_RimRsSendReq_t.startPrb']"
    xpath_numOfPrb = ".//field[@name='DlData_RimRsSendReq_t.numOfPrb']"
    assert XML().get_element_count(source=pdml_file, xpath=xpath_startRbforRS) == 2
    XML().element_attribute_should_be(source=pdml_file, xpath=xpath_startRbforRS,
                                      expected="startPrb (Uint16): 0", name="showname")
    XML().element_attribute_should_be(source=pdml_file, xpath=xpath_numOfPrb,
                                      expected="numOfPrb (Uint16): 48", name="showname")


def verify_that_rimrssendreq_does_not_occur(pdml_file):
    xpath_container = ".//proto[@name='dldata_rimrssendreq']"
    XML().element_should_not_exist(source=pdml_file, xpath=xpath_container)


def get_rimrs_num_and_start_prbs(pdml_path):
    start_prb = []
    num_prb = []
    with open(pdml_path, 'r') as pdml_file:
        xml_tree = BeautifulSoup(pdml_file, 'xml')
        rimrs_resources = xml_tree.find_all('proto', attrs={'name': 'nr_l1dl_l2ps_dldata_rimrssendreq_t'})
        for rimrs in rimrs_resources:
            start_prb.append(int(rimrs.find('field', attrs={'name': re.compile('startPrb')}).get('show')))
            num_prb.append(int(rimrs.find('field', attrs={'name': re.compile('numOfPrb')}).get('show')))
    return list(zip(start_prb, num_prb))


def verify_rimrs_num_and_start_prbs(pdml_path):
    expected_values = [(0, 48)]
    actual_values = list(get_rimrs_num_and_start_prbs(pdml_path))
    if all(actual == expected for actual, expected in zip(actual_values, expected_values)):
        print("Check passed, StartRBforRS: \n1.startPrb: 0, numOfPrb: 48")
    else:
        raise Exception("Check failed, incorrect StartRBforRS")


def get_rimrs_slot(pdml_path):
    slot_num = []
    with open(pdml_path, 'r') as pdml_file:
        xml_tree = BeautifulSoup(pdml_file, 'xml')
        rimrs_resources = xml_tree.find_all('proto', attrs={'name': 'nr_l1dl_l2ps_dldata_rimrssendreq_t'})
        for rimrs in rimrs_resources:
            slot_num.append(int(rimrs.find('field', attrs={'name': re.compile('slot')}).get('show')))
    return list(zip(slot_num))


def verify_slot(pdml_path):
    rimrs_slot = set(get_rimrs_slot(pdml_path)) == {3}
    if rimrs_slot:
        print("Check passed, slot for rimrssenreq: slot: 3")
    else:
        raise Exception("Check failed, incorrect slot")


def verify_if_rimrs_are_not_on_the_same_slot_and_sfn_than_csirs(pdml_path):
    rimrs_slot_sfn_pairs = set()
    csirs_slot_sfn_pairs = set()
    with open(pdml_path, 'r') as pdml_file:
        xml_tree = BeautifulSoup(pdml_file, 'xml')
        rimrs_tags = xml_tree.find_all('proto', attrs={'name': 'dldata_rimrssendreq'})
        for rimrs_tag in rimrs_tags:
            slot_num = int(rimrs_tag.find('field', attrs={'name': re.compile('slot')}).get('show'))
            sfn_num = int(rimrs_tag.find('field', attrs={'name': re.compile('sfn')}).get('show'))
            rimrs_slot_sfn_pairs.add((slot_num, sfn_num))
        csirs_tags = xml_tree.find_all('proto', attrs={'name': 'dldata_csirssendreq'})
        for csirs_tag in csirs_tags:
            slot_num = int(csirs_tag.find('field', attrs={'name': re.compile('slot')}).get('show'))
            sfn_num = int(csirs_tag.find('field', attrs={'name': re.compile('sfn')}).get('show'))
            csirs_slot_sfn_pairs.add((slot_num, sfn_num))
        common_pairs = rimrs_slot_sfn_pairs & csirs_slot_sfn_pairs
        if common_pairs:
            raise Exception('Check failed, RIMRS and CSIRS should not occur in the same slot and SFN: '
                            'slot/sfn pairs {}'.format(common_pairs))
        else:
            print('Check passed, RIMRS and CSIRS do not occur in the same slot and SFN.')
