# -*- coding: utf-8 -*-

# @Copyright: Nokia Networks
# @Author: cathy.mao@nokia-sbell.com
# @Contact: I_NSB_MN_RAN_RD_VRF_HAZ3_07_GMS <I_NSB_MN_RAN_RD_VRF_HAZ3_07@internal.nsn.com>


from mobility import pa_obj
from mobility import ho_obj


class sg7_lib(pa_obj, ho_obj):
    ROBOT_LIBRARY_SCOPE = 'TEST SUITE'

    def __init__(self):
        pa_obj.__init__(self)
        ho_obj.__init__(self)


if __name__ == "__main__":
    obj = sg7_lib()
