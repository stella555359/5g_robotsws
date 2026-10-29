__maintainer__ = 'Chen Xiaqing'
__team__ = 'I_CLOUD_AGENT_AIC'
__email__ = 'I_CLOUD_AGENT_AIC@internal.nsn.com'

from cloud5g.commissioning import CustomCommissioningBase
from taf.internal.scf.managed_object import ManagedObject
from taf.internal.scf.list import List
from taf.internal.scf.list import Item
from taf.internal.scf.list import P


class CustomCommissioning(CustomCommissioningBase):
    def __init__(self, scf_path):
        super(CustomCommissioning, self).__init__(scf_path)
        self.remote_scf_path = ''

    # main function of scf modification
    # first argument include following parameters:
    #    mrbts
    #    nrbts
    #    tl_config (you can refer to testline configuration __init__.py)
    #    tl_name (test line name)
    #    number_of_cells
    #    builds (as dict format like {"active": "", "passive": ""})
    def modify_scf(self, context):
        taf_scf = self.scf_handler
        mrbts_id = context.mrbts
        nrbts_id = context.nrbts

        # here index 0 means first MRBTS object, index is start from 0
        mrbts = taf_scf.raml.cmData.MRBTS[0]

        mrbts.NRBTS[0].NRSYSINFO_PROFILE[0].NRIRFIM[0].ssbScs.value = '100 KHz'
