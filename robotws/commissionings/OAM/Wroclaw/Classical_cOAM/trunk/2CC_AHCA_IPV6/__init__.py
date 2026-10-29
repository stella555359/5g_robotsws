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
        taf_scf = self.scf_handler
        mrbts = taf_scf.raml.cmData.MRBTS[0]
        mrbts.MNL[0].MNLENT[0].PMCADM[0].reportingIntervalPm.value = "15min"
        mrbts.NRBTS[0].NRPMRNL[0].miNrSfpBbmod.value = "15min"
        mrbts.NRBTS[0].NRPMRNL[0].miNrSfpRmod.value = "15min"
        mrbts.NRBTS[0].NRPMRNL[0].miNrSfpSmod.value = "15min"
