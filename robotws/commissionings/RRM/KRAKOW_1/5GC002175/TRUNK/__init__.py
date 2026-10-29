# -*- coding: utf-8 -*-

__maintainer__ = 'Mateusz Plinta'
__team__ = 'MN 5G&SC'
__email__ = 'mateusz.plinta@nokia.com'


import os
from cloud5g.commissioning import CustomCommissioningBase
from taf.ul.auto_commissioning import auto_commissioning

this_dir = os.path.dirname(__file__)

json_delta = os.path.join(this_dir, "2175_delta.json")


class CustomCommissioning(CustomCommissioningBase):

    def __init__(self, scf_path):
        super(CustomCommissioning, self).__init__(scf_path)
        self.remote_scf_path = ''

    def modify_scf(self, context):
        auto_commissioning().inject_json_delta(self.scf_handler, json_delta)
