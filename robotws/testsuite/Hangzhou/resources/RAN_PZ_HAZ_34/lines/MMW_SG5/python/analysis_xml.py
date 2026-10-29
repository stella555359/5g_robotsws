# -*- coding: utf-8 -*-
# @Time    : 2024/3/18 15:25
# @Author  : Jian.1.Chen
# @Email   : jian.1.chen@nokia-sbell.com
# @File    : analysis_xml.py
# @Software: PyCharm
import xml.etree.ElementTree as ET


def get_counter_value_from_rdbts(xml_file, dist_name, counter_name):
    tree = ET.parse(xml_file)
    root = tree.getroot()

    counter_value = 0
    for elem in root.iter():
        if elem.tag == "DN":
            dn = elem.text
        if elem.tag == "NE-WBTS_1.0" and dn == dist_name:
            for i in elem.iter():
                if i.tag == counter_name:
                    counter_value += int(i.text)
                    # counters.append(i.text)
                    print(i.text)
    return counter_value


if __name__ == "__main__":
    get_counter_value_from_rdbts("C:\\workspace\\RD.BTS-2045.20240318.072000.ANY.xml",
                                 "PLMN-PLMN/MRBTS-2045/NRBTS-11230/NRCELL-1",
                                 "NRDC_IA_MN_CU_REL_REQ")
