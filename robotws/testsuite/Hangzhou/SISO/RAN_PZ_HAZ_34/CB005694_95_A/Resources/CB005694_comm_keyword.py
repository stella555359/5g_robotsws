# -*- coding: utf-8 -*
import os


def Two_List_Compare(before_list, after_list):
    accept_list = [1936, 4592]
    before_list1 = [i for i in before_list if i not in accept_list]
    after_list1 = [i for i in after_list if i not in accept_list]
    result = [before_list1, after_list1]
    return result
