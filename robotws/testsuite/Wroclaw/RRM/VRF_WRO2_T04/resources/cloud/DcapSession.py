from taf.sw.dcap.rd import rd
from robot.api import logger
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.tl_config import tl as TL_CONFIG


class DcapSession:
    def __init__(self, mrbts_id, unit_type):
        self.dcap = rd()
        self.mrbts_id = mrbts_id
        self.unit_type = unit_type
        self.dcap_bts_id = None

    def __enter__(self, host=None, port='443', username='utfuser', password='utfadmin!'):
        """
        :param
        """

        self.dcap.connect_to(
            host=TL_CONFIG.gnbs[0].dcap.connection_details.addr,
            port=TL_CONFIG.gnbs[0].dcap.connection_details.port,
            username=TL_CONFIG.gnbs[0].dcap.connection_details.username,
            password=TL_CONFIG.gnbs[0].dcap.connection_details.password,
            secure=True)

        self.dcap_bts_id = self._get_dcap_by_mrbts_id(self.mrbts_id, self.unit_type)
        self.bts_info = self._get_bts_info()
        return self

    def _get_dcap_by_mrbts_id(self, bts_id, unit_type):
        """
        :param bts_id mrbts_id
        :param type vcu or vdu
        """
        all_bts = self.dcap.get_all_bts_info()
        logger.info(bts_id)
        logger.info(unit_type)
        return next(x['id'] for x in all_bts if x['type'].lower() == unit_type and x['mr_bts_id'] == float(bts_id))

    def _get_bts_info(self):
        if self.unit_type == 'vcu':
            host = TL_CONFIG.gnbs[0].cu.oam_http_connection_details.addr
            port = TL_CONFIG.gnbs[0].cu.oam_http_connection_details.port
            username = TL_CONFIG.gnbs[0].cu.oam_http_connection_details.username
            password = "Nokia@123"
        elif self.unit_type == 'vdu':
            host = TL_CONFIG.gnbs[0].dus[0].oam_http_connection_details.addr
            port = TL_CONFIG.gnbs[0].dus[0].oam_http_connection_details.port
            username = TL_CONFIG.gnbs[0].dus[0].oam_http_connection_details.username
            password = "Nokia@123"
        else:
            raise RuntimeError("Unsupported unit type!")
        return {
            "host": host,
            "port": port,
            "username": username,
            "password": password
        }

    def __exit__(self, exc_type, exc_val, exc_tb):
        return
