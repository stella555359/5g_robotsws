import logging
from ute_common_abstract_core.aliases_registry import aliases_registry
from ute_common_abstract_core.config import Config


class UteUeConfig(object):
    """
    Class containing additional common keywords related to UTE UE configuration
    UTE UE configuration is taken from Singleton
    ute_common_abstract_core.config.Config
    !!! Remember to use KWs after "Require UE" !!!
    """
    ROBOT_LIBRARY_SCOPE = 'TEST SUITE'

    def __init__(self):
        self.__abstract_config = None
        self.__abstract_config_dict = None
        self.__abstract_config_path = None

    @property
    def abstract_config(self):
        if not self.__abstract_config:
            self.__abstract_config = Config()
        return self.__abstract_config

    @property
    def abstract_config_dict(self):
        if not self.__abstract_config_dict:
            self.__abstract_config_dict = self.abstract_config.get_config()
        return self.__abstract_config_dict

    @property
    def abstract_config_path(self):
        if not self.__abstract_config_path:
            self.__abstract_config_path = self.abstract_config.\
                get_config_path()
        return self.__abstract_config_path

    @staticmethod
    def _get_ue_pool_name(ue_class):
        ue_pool_name = "{}Pool".format(type(ue_class).__name__)
        logging.debug("UE Pool name : {}".format(ue_pool_name))
        return ue_pool_name

    @staticmethod
    def _warn_that_yaml_is_not_used():
        msg = "UTE UE configuration path is empty, most probably YAML " \
              "file is not used for UTE UEs definition"
        logging.warn(msg)

    def get_ute_ue_configuration_dict(self):
        logging.debug("Config path: {}".format(self.abstract_config_path))
        return self.abstract_config_dict

    def get_from_ute_ue_config(self, ue_alias, top_level_key):
        ute_ue = aliases_registry()[ue_alias]
        logging.debug("UTE UE name : {}".format(ute_ue.name))
        ue_pool = self._get_ue_pool_name(ute_ue)
        if self.abstract_config_dict:
            return self.abstract_config_dict["UE_POOLS"][ue_pool]
            ["inline_config"][ute_ue.name][top_level_key]

    def get_from_ute_ue_config_yaml(self, ue_alias, top_level_key):
        if not self.abstract_config_path:
            self._warn_that_yaml_is_not_used()
        else:
            return self.get_from_ute_ue_config(ue_alias, top_level_key)

    def get_4g_starting_cell_id_for(self, ue_alias):
        return self.get_from_ute_ue_config_yaml(
            ue_alias=ue_alias,
            top_level_key="STARTING_CELL")

    def get_5g_starting_cell_id_for(self, ue_alias):
        return self.get_from_ute_ue_config_yaml(
            ue_alias=ue_alias,
            top_level_key="STARTING_CELL_5G_ID")

    def get_5g_starting_cell_pci_for(self, ue_alias):
        return self.get_from_ute_ue_config_yaml(
            ue_alias=ue_alias,
            top_level_key="STARTING_CELL_5G_PCI")
