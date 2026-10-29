import os
from cloud5g.commissioning import CustomCommissioningBase
from taf.ul.auto_commissioning import auto_commissioning

this_dir = os.path.dirname(__file__)

json_delta = os.path.join(this_dir, "pydelta.json")


class CustomCommissioning(CustomCommissioningBase):

    def __init__(self, scf_path):
        super(CustomCommissioning, self).__init__(scf_path)
        self.remote_scf_path = ''

    def modify_scf(self, context):
        auto_commissioning().inject_json_delta(self.scf_handler, json_delta)
        scf = self.scf_handler
        mrbts = scf.raml.cmData.MRBTS[0]
        CABLINK_2 = mrbts.EQM[0].HWTOP[0].CABLINK[1]
        CABLINK_2.firstEndpointLabel.value = context.tl_config.gnbs[0].dus[0].cablinks[0].source.label
        CABLINK_2.secondEndpointLabel.value = context.tl_config.gnbs[0].dus[0].cablinks[0].target.label
        CABLINK_2.firstEndpointPortId.value = context.tl_config.gnbs[0].dus[0].cablinks[0].source.port_id
        CABLINK_2.secondEndpointPortId.value = context.tl_config.gnbs[0].dus[0].cablinks[0].target.port_id
