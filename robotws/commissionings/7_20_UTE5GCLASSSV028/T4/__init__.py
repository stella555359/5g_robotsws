# https://confluence.ext.net.nokia.com/display/CSG5GSCCGG/Custom+Commissioning
# Managed objects and distanmes are not duplicated
# List can have multiple Items
# Params declared directly in Lists are always nameless
# Params can have empty values
# Nameless params are only possible directly in a List
# Each distname of Managed Object in SCF has positive digit correlating to name of each object.:
# e.g. MRBTS-100/MNL-2/WHATEVER-1/SMTH-2


import os
from cloud5g.commissioning import CustomCommissioningBase
from taf.ul.auto_commissioning import auto_commissioning

this_dir = dirname = os.path.dirname(__file__)

json_delta = os.path.join(dirname, "pydelta.json")


class CustomCommissioning(CustomCommissioningBase):

    def __init__(self, scf_path):
        super(CustomCommissioning, self).__init__(scf_path)
        self.remote_scf_path = ''

    def modify_scf(self, context):
        auto_commissioning().inject_json_delta(self.scf_handler, json_delta)
