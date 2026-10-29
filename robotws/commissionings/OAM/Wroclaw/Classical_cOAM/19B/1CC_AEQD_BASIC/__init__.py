__maintainer__ = 'Pawel Rokicki'
__team__ = '5G_IV7_WRO_6'
__email__ = 'I_MN_5GSC_PZ_5G_IV7_WRO_6@internal.nsn.com'

from cloud5g.commissioning import CustomCommissioningBase


class CustomCommissioning(CustomCommissioningBase):

    def __init__(self, scf_path):
        super(CustomCommissioning, self).__init__(scf_path)
        self.remote_scf_path = ''

    def modify_scf(self, context):
        taf_scf = self.scf_handler
        mrbts = taf_scf.raml.cmData.MRBTS[0]

        mrbts.TNLSVC[0].TNL[0].IPNO[0].IPRT[0].staticRoutes[0].gateway.value = "10.44.64.1"
        mrbts.EQM[0].HWTOP[0].CABLINK[0].firstEndpointLabel.value = "BACKPLANE"
        mrbts.EQM[0].HWTOP[0].CABLINK[0].secondEndpointLabel.value = "BACKPLANE"
        mrbts.NRBTS[0].actMultVlan.value = "true"
        mrbts.NRBTS[0].NRCELL[0].gscn.value = "8020"
        mrbts.NRBTS[0].NRCELL[0].nrarfcn.value = "650000"
        mrbts.NRBTS[0].NRCELL[0].pMax.value = "240"
        mrbts.NRBTS[0].NRCELL[0].prachConfigurationIndex.value = "98"
