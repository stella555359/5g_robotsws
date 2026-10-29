__maintainer__ = 'Damian Lyszczarczyk'
__team__ = 'MN_SRAN_Trunk_Eng_WRO_1_SG'
__email__ = 'I_UTE_CORE_5G@internal.nsn.com'

from cloud5g.commissioning import CustomCommissioningBase


class CustomCommissioning(CustomCommissioningBase):

    def __init__(self, scf_path):
        super(CustomCommissioning, self).__init__(scf_path)
        self.remote_scf_path = ''

    def modify_scf(self, context):
        taf_scf = self.scf_handler
        mrbts = taf_scf.raml.cmData.MRBTS[0]
        mrbts.NRBTS[0].NRCELL[0].gscn.value = 22402
