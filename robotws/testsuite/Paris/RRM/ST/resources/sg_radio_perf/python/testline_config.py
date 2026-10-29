# -*- coding: utf-8 -*
"""
Author: Annie Wong
Description: get test line info from test line config file

"""
from robot.libraries.BuiltIn import BuiltIn
from taf.config.testline.info import TestlineInfo as tl_infos


class Testline_info(object):

    def __init__(self):
        self.tl = BuiltIn().get_variable_value('${tl}')

    def get_gNBs(self):
        return self.tl.gnbs

    def get_nb_gNBs(self):
        _gnb_list = 0
        for gnb in self.tl.gnbs:
            _gnb_list += 1
        return _gnb_list

    def get_rus(self):
        """
        Get all RUs under gnb[0][du0] for classical env from test line config file
        :return: a list with RU info from test line config file
        """
        du = tl_infos.get_du_list(self.tl)
        if du[0].rus is None:
            raise Exception("No RU found in testline config file")
        else:
            return du[0].rus

    def get_ru_info_by_ru_type(self, ru_type):
        """
        Get ru info based on ru type
        :param ru_type:
        :return: a list with RU info from test line config file
        """
        rus = self.get_rus()
        list_rus_with_specific_type = []
        for ru in rus:
            if ru.radio_type.name == ru_type:
                list_rus_with_specific_type.append(ru)
        if len(list_rus_with_specific_type) == 0:
            raise Exception("No RU type {} found in testline config file".format(ru_type))
        else:
            return list_rus_with_specific_type


def test_me():
    tl_info = Testline_info()


if __name__ == "__main__":
    test_me()
