import logging
from taf.rfrl.utilities import tl_config
from taf.rfrl.bts.devices.asir.generic_asir import GenericAsirHub


class WlanGenericAsir(GenericAsirHub):

    def __init__(self, bts_type='GNB'):
        self._connection_alias = None
        self.host = None
        super(WlanGenericAsir, self).__init__(bts_type=bts_type)

    def set_connection_alias(self, alias: str):
        self._connection_alias = alias

    def connect(self, host: str, alias: str):
        self.host = host
        self.set_connection_alias(alias)
        super().connect()

    def _connect(self, bts_id=0, du_id=0):
        credentials = tl_config.get_web_credentials_for_du(bts_id=bts_id, du_id=du_id, bts_type=self.bts_type)
        logging.debug("[ASIR] Connecting to {}  {}".format(self._connection_alias, self.host))
        self.asir.connect_to(host=self.host,
                             port=3601,
                             username=credentials['username'],
                             password=credentials['password'],
                             asir_version="ASIR_22R3",
                             secure=False,
                             alias=self._connection_alias)

    def disconnect(self):
        super().disconnect()
