from cloud5g.commissioning import CustomCommissioningBase


class CustomCommissioning(CustomCommissioningBase):

    def __init__(self, scf_path):
        super(CustomCommissioning, self).__init__(scf_path)
        self.remote_scf_path = ''

    def modify_scf(self, context):
        taf_scf = self.scf_handler
        mrbts = taf_scf.raml.cmData.MRBTS[0]
        mrbts.EQM[0].APEQM[0].RMOD[0].prodCodePlanned.value = '474473A.101'
        mrbts.EQM[0].HWTOP[0].CABLINK[1].firstEndpointLabel.value = 'QSFP'
        mrbts.EQM[0].HWTOP[0].CABLINK[1].secondEndpointLabel.value = 'QSFP'
        mrbts.EQM[0].HWTOP[0].CABLINK[2].secondEndpointLabel.value = 'QSFP'
        mrbts.EQM[0].HWTOP[0].CABLINK[2].firstEndpointLabel.value = 'QSFP'
