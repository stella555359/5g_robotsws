from testsuite.Ulm.ET.L2.libraries.ue.ue import UE
from testsuite.Ulm.ET.L2.libraries.helper_functions import to_bool, update_dictionary_and_log_on_missing_value


class SaUe(UE):
    def __init__(self):
        super().__init__()
        self.bearers = [2]
        self.pdu = 1
        self.optional_dual_connectivity_args = {None}
        self.connection_type = 'sa'
        self.default_ue_attributes.update(
            {
                'ue_eutra_nr_capabilities': {},
                'optional_nr_attach_args': {},
                'pdu': 1})

    def get_configuration_parameters(self):
        super().get_configuration_parameters()
        self.ue_config_params.pop('ue_eutra_nr_capabilities')
        return self.ue_config_params

    def get_bearer_pdu_details(self, default_traffic_params: dict):
        qfi = default_traffic_params.pop('qfi')
        return {'pdu': self.pdu, 'qfi': qfi}
