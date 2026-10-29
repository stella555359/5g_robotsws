__maintainer__ = 'Jakub Kupiec'
__team__ = '5G_PZ_MMW_KRK_4_SG'
__email__ = 'jakub.kupiec@nokia.com'

import os
from cloud5g.commissioning import CustomCommissioningBase
from taf.ul.auto_commissioning import auto_commissioning

this_dir = dirname = os.path.dirname(__file__)

json_delta = os.path.join(dirname, "delta_scf_7_7_CLOUDSKA004_20B.json")


class CustomCommissioning(CustomCommissioningBase):

    def __init__(self, scf_path):
        super(CustomCommissioning, self).__init__(scf_path)
        self.remote_scf_path = ''

    def modify_scf(self, context):
        auto_commissioning().inject_json_delta(self.scf_handler, json_delta)
