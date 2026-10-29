from testsuite.Ulm.ET.L2.libraries.ue.ue import UE
from testsuite.Ulm.ET.L2.libraries.helper_functions import to_bool, update_dictionary_and_log_on_missing_value


class NsaUe(UE):
    def __init__(self):
        super().__init__()
        self.bearer = 2
        self.optional_lte_attach_args = {}
        self.optional_dual_connectivity_args = {}
        self.ue_eutra_nr_capabilities = None
        self.connection_type = 'nsa'
        self.default_ue_attributes.update({
            'optional_lte_attach_args': {},
            'optional_dual_connectivity_args': {},
            'bearer': 2,
            "ue_eutra_nr_capabilities": None})

    def get_bearer_pdu_details(self, default_traffic_params=None):
        return {'id': self.bearer}
