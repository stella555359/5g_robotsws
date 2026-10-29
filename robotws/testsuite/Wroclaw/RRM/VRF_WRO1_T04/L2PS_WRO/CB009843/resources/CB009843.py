from bs4 import BeautifulSoup
from robot.libraries.BuiltIn import BuiltIn
import re

ute_wtssim_instance = BuiltIn().get_library_instance('ute_wtssim')


def verify_if_sub_band_SRS_is_enabled(pdml_path):
    with open(pdml_path, 'r') as pdml_file:
        xml_tree = BeautifulSoup(pdml_file, 'xml')
    srs_enable_list = xml_tree.find_all('proto', attrs={'name': 'uldata_srsreceivereq'})
    if not srs_enable_list:
        raise Exception("Check failed - srs_enable_list is empty")
    for record in srs_enable_list:
        srs_info = record.find('field', attrs={'name': re.compile('srsBmSubbandIdLtCoMa')}).get('show')
        if not srs_info:
            raise Exception("Check failed")
