import logging

from testsuite.Ulm.ET.L2.libraries.helper_functions import (
    to_bool, update_dictionary_and_log_on_missing_value)


class UE:
    """This class contains UE related properties such as:
        > id:                        ue_id
        > connection_type:           connection_type of UE (SA / NSA)
        > ue_cap:                      UE Capability of the UE
        > cell_id:                   the cell the particular UE is associated
        > attributes:                additional UE Type specific attributes such as bearer, pdu etc..
    """

    def __init__(self):
        self.id = None
        self.connection_type = None
        self.ue_cap = None
        self.optional_nr_attach_args = None
        self.cell = None
        self.qos_flows = None
        self.auto_attach = True
        self.default_ue_attributes = {'ue_cap': None,
                                      'auto_attach': True,
                                      'qos_flows': None}
        self.ue_config_params = {}

    def set_ue_attributes(self, **kwargs):
        logging.info('updating ue attributes for ue %s', self.id)
        ue_args = update_dictionary_and_log_on_missing_value(
            self.default_ue_attributes, kwargs)
        self.id = kwargs['ue_id']
        self.cell = kwargs['cell']
        for key, value in ue_args.items():
            if key == 'auto_attach':
                value = to_bool(value)
            setattr(self, key, value)

    def get_configuration_parameters(self):
        self.ue_config_params = {key: getattr(self, key) for key in self.default_ue_attributes.keys()}
        self.ue_config_params.pop('ue_cap')
        self.ue_config_params["nr_ue_cap"] = self.ue_cap
        self.ue_config_params["cell"] = self.cell
        return self.ue_config_params
