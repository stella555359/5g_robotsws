# -*- coding: utf-8 -*-
# @Time    : 2022/1/24 15:55
# @Author  : Jian.1.Chen
# @Email   : jian.1.chen@nokia-sbell.com
# @File    : pdmlanalyzer.py
# @Software: PyCharm
from taf.analyzer.pdml import PdmlReader


def get_list_of_values(pdml_path, attribute_name):
    values_list = []
    with open(pdml_path, "rb") as file_obj:
        for entry in PdmlReader(file_obj=file_obj):
            if attribute_name in entry.packet:
                try:
                    value = entry.packet.xpath('.//' + attribute_name)[0].showname.split(" ")[1]
                    values_list.append(value)
                except IndexError:
                    print(attribute_name + ": value not found")
    return values_list
