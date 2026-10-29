# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Lin Stella
:contact: stella.lin@nokia-sbell.com

"""

from robot.libraries.BuiltIn import BuiltIn

tl = BuiltIn().get_variable_value("${tl}")

# ------------ swconfig CB008940 flags ------------------
# enable cb008940-A new CSM
# 0x420062=1
SWCONFIG_newCSMflag = ["0x420062=1"]
