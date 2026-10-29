# -*- coding: utf-8 -*-
"""
Author: Wang Yixiang
Contacts: yixiang.x.wang@nokia-sbell.com
Description: After code of testline_configuration migrate from gitlab to gerrit, only tl is open to outside,
             PARAMS_TO_MODIFY_SCF not open now, but some legacy cases need to use the "PARAMS_TO_MODIFY_SCF",
             so define the default value of PARAMS_TO_MODIFY_SCF

__all__ = ["tl"]

"""
PARAMS_TO_MODIFY_SCF = []
