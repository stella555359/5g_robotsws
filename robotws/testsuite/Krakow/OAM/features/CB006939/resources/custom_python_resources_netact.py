# -*- coding: utf-8 -*-
"""
author: Grzegorz Kaczor, grzegorz.kaczor@nokia.com
maintainer: Grzegorz Kaczor, grzegorz.kaczor@nokia.com
"""


def get_average_from_list(list_of_elements_to_average_from):
    if not list_of_elements_to_average_from:
        raise AttributeError("Given list is empty")
    return float(sum(list_of_elements_to_average_from)/len(list_of_elements_to_average_from))
