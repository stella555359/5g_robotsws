import os
from cloud5g.commissioning import CustomCommissioningBase
from resources.pydelta.injector import Injector

this_dir = dirname = os.path.dirname(__file__)

json_delta = os.path.join(dirname, "pydelta.json")


class CustomCommissioning(CustomCommissioningBase):

    def __init__(self, scf_path):
        super(CustomCommissioning, self).__init__(scf_path)
        self.remote_scf_path = ''

    def modify_scf(self, context):
        injector = Injector(self.scf_handler)
        injector.inject_json_delta(json_delta)
