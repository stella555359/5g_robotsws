
from testsuite.Ulm.ET.L2.libraries.logger import logger, logging
from testsuite.Ulm.ET.L2.libraries.ue.nsa_ue import NsaUe
from testsuite.Ulm.ET.L2.libraries.ue.sa_ue import SaUe

SA_UE_START = 1
SA_UE_END = 101
NSA_UE_START = 101
NSA_UE_END = 201


class UeCollection:
    """This class contains the defined group name and it's respective UE information
    The class also provides the following external methods:
    > get_required_configuration_parameters_for_nsa_ues
    > get_required_configuration_parameters_for_sa_ues
    > get_list_of_configured_ue_ids
    """
    nsa_id_generator = (ue_id for ue_id in range(NSA_UE_START, NSA_UE_END))
    sa_id_generator = (ue_id for ue_id in range(SA_UE_START, SA_UE_END))
    ue_list = []
    ue_collection = []

    def __str__(self):
        return self.group_name

    @classmethod
    def _store_ues(cls, ue_obj):
        """Stores the given ue object in a list. This list stores UE's for all classes"""
        cls.ue_list.append(ue_obj)

    @classmethod
    def get_ue_groups(cls):
        return cls.ue_collection

    @classmethod
    def add_to_ue_group_collection(cls, collection_obj):
        if collection_obj not in cls.ue_collection:
            cls.ue_collection.append(collection_obj)

    @logger
    def __init__(self, group_name):
        self.group_name = group_name
        self.all_ues = []
        self.nsa_ues = []
        self.sa_ues = []
        self._auto_attach = None
        self.bearer = None
        self.pdu = None
        self.nsa_ue_ids = []
        self.sa_ue_ids = []
        self.connection_type = None
        self.ue_config_params = {'auto_attach': {}, 'not_auto_attach': {}}

    def __repr__(self):
        return f"UE Collection: {self.group_name}"

    def add_ue_to_group(self, connection_type: str, **kwargs):
        """Method creates a new UE object of class UE and updates it with the corresponding attributes """
        self.add_to_ue_group_collection(self)
        if connection_type == 'NSA':
            ue_id = next(self.nsa_id_generator)
        elif connection_type == 'SA':
            ue_id = next(self.sa_id_generator)
        else:
            logging.error('Unknown or invalid ue_type.')
            return
        logging.info(
            "Adding UE with connection_type %s with UE ID: %s", connection_type, ue_id)
        ue = self._create_new_ue(connection_type=connection_type)
        ue.set_ue_attributes(ue_id=ue_id, **kwargs)
        if not self.bearer and connection_type == "NSA":
            self.bearer = ue.bearer
        if not self.pdu and connection_type == "SA":
            self.pdu = ue.pdu
        self._store_ues(ue)

    @property
    def configured_nsa_ues(self):
        """Returns a list of NSA UEs configured"""
        if not self.nsa_ue_ids:
            self.nsa_ue_ids = [ue.id for ue in self.nsa_ues]
        return self.nsa_ue_ids

    @property
    def configured_sa_ues(self):
        """Returns a list of SA UEs configured"""
        if not self.sa_ue_ids:
            self.sa_ue_ids = [ue.id for ue in self.sa_ues]
            return self.sa_ue_ids
        else:
            return self.sa_ue_ids

    @property
    def cell(self):
        return list(set([ue.cell for ue in self.all_ues]))[0]

    @logger
    def get_configuration_parameters(self, all_ues=False):
        if len(self.ue_config_params) < 3:
            for ue in self.all_ues:
                ue_params = ue.get_configuration_parameters()
                if ue_params['auto_attach']:
                    self.ue_config_params['auto_attach'][ue.id] = ue_params
                else:
                    self.ue_config_params['not_auto_attach'][ue.id] = ue_params
        if all_ues:
            return {**self.ue_config_params['auto_attach'], **self.ue_config_params['not_auto_attach']}
        return self.ue_config_params['auto_attach'], self.ue_config_params['not_auto_attach']

    @logger
    def get_list_of_configured_ue_ids(self):
        """Returns a list of UE Ids configured
        Ex. [1, 2, 3, 4]"""
        return [ue_id.id for ue_id in self.all_ues]

    def get_comma_separated_ue_ids(self):
        comma_separated_ue_ids = ','.join([str(ue_ids)
                                           for ue_ids in self.get_list_of_configured_ue_ids()])
        return comma_separated_ue_ids

    @logger
    def _create_new_ue(self, connection_type):
        "Creates a new UE and associates it with either SA / NSA attributes based on the type of UE required"
        if connection_type == 'NSA':
            new_ue = NsaUe()
            self.nsa_ues.append(new_ue)
            self.connection_type = 'nsa'
        elif connection_type == 'SA':
            new_ue = SaUe()
            self.sa_ues.append(new_ue)
            self.connection_type = 'sa'
        else:
            logging.info("Error! Incorrect UE Type")
            raise KeyError
        self.all_ues.append(new_ue)
        return new_ue
