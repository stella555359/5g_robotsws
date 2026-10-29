from taf.gnb.oam.coam.cu import cu
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.tl_config import tl as TL_CONFIG


class VcuAdminSession:
    def __init__(self):
        self.admin = cu()

    def __enter__(self):
        self.admin.connect_to(
            host=TL_CONFIG.gnbs[0].cu.oam_http_connection_details.addr,
            port=TL_CONFIG.gnbs[0].cu.oam_http_connection_details.port,
            username=TL_CONFIG.gnbs[0].cu.oam_http_connection_details.username,
            password=TL_CONFIG.gnbs[0].cu.oam_http_connection_details.password,
            secure=True)
        return self.admin

    def __exit__(self, exc_type, exc_val, exc_tb):
        self.admin.disconnect()
