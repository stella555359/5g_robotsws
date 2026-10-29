import os
from cloud5g.commissioning import CustomCommissioningBase
from taf.ul.auto_commissioning import auto_commissioning

this_dir = dirname = os.path.dirname(__file__)

json_delta = os.path.join(dirname, "delta_scf_actTrsSharing.json")


class CustomCommissioning(CustomCommissioningBase):

    def __init__(self, scf_path):
        super(CustomCommissioning, self).__init__(scf_path)
        self.remote_scf_path = ''

    def modify_scf(self, context):
        auto_commissioning().inject_json_delta(self.scf_handler, json_delta)
