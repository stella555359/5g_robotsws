import yaml
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.tl_config import tl
from taf.config.testline.connection_details import SshServiceDetails


def load_ues():
    if tl.ues[0].__class__.__name__ == 'Android':
        return tl.ues
    else:
        with open(tl.ues[0], 'r') as file:
            config = yaml.safe_load(file)
            ue_pool = config['UE_POOLS'].get('AndroidUePool', config['UE_POOLS'].get('TafUeAndroidPool'))
            ues = [UeConfig(obj, values) for obj, values in ue_pool.get('inline_config').items()]
    return ues


class UeConfig:
    def __init__(self, name, ue_obj):
        self.name = name
        self.ue_obj = ue_obj

    @property
    def serial_number(self):
        return self.ue_obj['CONSTRUCTOR_PARAMETERS']['serial_number']

    @property
    def ue_pc_address(self):
        try:
            return self.ue_obj['CONSTRUCTOR_PARAMETERS']['configuration']['ue_pc_ip']
        except KeyError:
            return self.ue_obj['CONSTRUCTOR_PARAMETERS']['configuration']['ue_pc_address']

    @property
    def ue_pc_login(self):
        return self.ue_obj['CONSTRUCTOR_PARAMETERS']['configuration']['login']

    @property
    def ue_pc_password(self):
        return self.ue_obj['CONSTRUCTOR_PARAMETERS']['configuration']['password']

    @property
    def imsi(self):
        return self.ue_obj['CONSTRUCTOR_PARAMETERS']['configuration']['imsi']

    @property
    def ssh_connection_details(self):
        return SshServiceDetails(addr=self.ue_pc_address, username=self.ue_pc_login, password=self.ue_pc_password)

    @property
    def capabilities(self):
        return self.ue_obj['CAPABILITIES']

    @property
    def bands(self):
        return self.ue_obj['CONSTRUCTOR_PARAMETERS']['bands']
