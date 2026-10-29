# -*- coding: utf-8 -*-
# @Time    : 2021/12/16 23:54
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
                    values_list.append((entry.packet.xpath('.//' + attribute_name)[0].show))
                except IndexError:
                    print(attribute_name + ": value not found")
    return values_list
