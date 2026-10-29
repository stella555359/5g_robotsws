from bs4 import BeautifulSoup
import re


def get_isCsirsRateMatching_and_numCsirsMappingRes(pdml_path):
    with open(pdml_path, 'r') as pdml_file:
        xml_tree = BeautifulSoup(pdml_file, 'xml')
        dldata_pdschgrant = xml_tree.find_all('proto', attrs={'name': '_5g_l1_dl_l2_ps_dldata_pdschgrant'})
        for data in dldata_pdschgrant:
            isCsirsRateMatching = (int(data.find('field', attrs={'name': re.
                                                 compile('DlData_PdschGrant.isCsirsRateMatching')}).get('show')))
            numCsirsMappingRes = (int(data.find('field', attrs={'name': re.
                                                compile('DlData_PdschGrant.numCsirsMappingRes')}).get('show')))
        return isCsirsRateMatching, numCsirsMappingRes
