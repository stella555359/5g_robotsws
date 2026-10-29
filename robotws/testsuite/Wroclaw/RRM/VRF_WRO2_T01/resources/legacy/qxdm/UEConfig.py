import subprocess
import os
import yaml

''''
This class loads UE configuration from YMAL file. The file structure is hardcoded and you should create YAML
regarding to this example testline_configuration/7_16_UTE5GCLOUDT161/ues.yaml.
File name 'ues.yaml' is restricted.
'''


class UEConfig:
    def __init__(self):
        self.hostname = str(subprocess.check_output('hostname').strip(), 'utf-8')
        home_path = os.environ['HOME']
        self.config_path = '{}/testline_configuration/{}/ues.yaml'.format(home_path, self.hostname.replace('-', '_'))

    def get_ue_config(self, ue_yaml_alias='UE_1'):
        config = {}
        with open(self.config_path, 'r') as stream:
            try:
                config = yaml.safe_load(stream)
            except yaml.YAMLError as err:
                print(err)

        # It is splitted due to line character limitation
        ues = config['UE_POOLS']['AndroidUePool']['inline_config']
        config = ues[ue_yaml_alias]['CONSTRUCTOR_PARAMETERS']['configuration']

        if not config:
            raise IOError('Wrong YAML config or empty fields')
        return config
