from taf.gnb.oam.coam.vdu import vdu
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.tl_config import tl as TL_CONFIG


class VduAdminSession:
    def __init__(self, vdu_id):
        self.admin = vdu()
        self.vdu_id = vdu_id

    def __enter__(self):
        self.admin.connect_to(
            host=TL_CONFIG.gnbs[0].dus[self.vdu_id].oam_http_connection_details.addr,
            port=TL_CONFIG.gnbs[0].dus[self.vdu_id].oam_http_connection_details.port,
            username=TL_CONFIG.gnbs[0].dus[self.vdu_id].oam_http_connection_details.username,
            password=TL_CONFIG.gnbs[0].dus[self.vdu_id].oam_http_connection_details.password, secure=True)
        return self.admin

    def __exit__(self, exc_type, exc_val, exc_tb):
        self.admin.disconnect()
