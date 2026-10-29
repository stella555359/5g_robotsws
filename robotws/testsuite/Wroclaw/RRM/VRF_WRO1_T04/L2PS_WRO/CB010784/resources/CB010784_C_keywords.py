from bs4 import BeautifulSoup
import re


def get_ssburstoffloadreceiveresp_data(pdml_path):
    data_item = []
    with open(pdml_path, 'r') as pdml_file:
        xml_tree = BeautifulSoup(pdml_file, 'xml')
        ssburstoffloadreceiveresp = xml_tree.find_all('field', attrs={'show': 'data (DynamicVariableSizedArray)'})
        for i in range(240, 252):
            for data in ssburstoffloadreceiveresp:
                data_item.append(int(data.find('field', attrs={'showname': re.compile('data_item_'
                                                                                      + str(i))}).get('show')))
    return data_item
