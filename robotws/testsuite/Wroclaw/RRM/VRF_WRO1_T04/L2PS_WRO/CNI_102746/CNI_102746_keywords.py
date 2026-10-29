from bs4 import BeautifulSoup
import xml.etree.ElementTree as ET
import re


def get_rimrs_slot(pdml_path):
    slot_num = []
    with open(pdml_path, 'r') as pdml_file:
        xml_tree = BeautifulSoup(pdml_file, 'xml')
        dldata_rimrssendreq = xml_tree.find_all('proto', attrs={'name': 'nr_l1dl_l2ps_dldata_rimrssendreq_t'})
        for data in dldata_rimrssendreq:
            slot_num.append(int(data.find('field', attrs={'name': re.compile('3gpp.slot')}).get('show')))
    return slot_num


def get_slot_and_symbol_index(pdml_path):
    slot = None
    symbol_index_ls = []
    with open(pdml_path, 'r') as pdml_file:
        xml_tree = BeautifulSoup(pdml_file, 'xml')
        uldata_detectionresunitsresp = xml_tree.find_all('proto', attrs={'name': 'nr_l1ul_l2ps'})
        for data in uldata_detectionresunitsresp:
            slot = (int(data.find('field', attrs={'name': re.compile('3gpp.slot')}).get('show')))

        uldata_detectionresunitsresp = xml_tree.find_all('proto', attrs={
            'name': 'nr_l1ul_l2ps_uldata_detectionresunitsresp_t'})
        for data in uldata_detectionresunitsresp:
            symbol_index_ls.append(
                int(data.find('field', attrs={'name': re.compile('UlData_detectionResUnitsResp_t.symbolIndex')}).get(
                    'show')))
        return slot, symbol_index_ls


def check_rimrssendreq_in_correct_slots(pdml_file, slots_to_check):
    try:
        tree = ET.parse(pdml_file)
        root = tree.getroot()
        found_on_slots = []

        for slot_to_check in slots_to_check:
            found = False

            for proto in root.findall(".//proto[@name='dldata_rimrssendreq']"):
                slot_field = proto.find(".//field[@name='3gpp.slot']")

                if slot_field is not None:
                    slot_value = int(slot_field.get("show").split(":")[-1].strip())

                    if slot_value == int(slot_to_check):
                        found = True
                        found_on_slots.append(slot_to_check)
                        break

            if found:
                continue

        if set(slots_to_check) == set(found_on_slots):
            print("msg 'dldata_rimrssendreq' found on all expected slots.")
            return 'Passed'
        else:
            error_message = f"msg'rimrssendreq'not found on exp. slots. Is found: {', '.join(map(str, found_on_slots))}"
            raise Exception(error_message)

    except Exception as e:
        return str(e)
