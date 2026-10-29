from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.tl_config import tl
from taf.sbts.oam.coam.admin import admin as taf_admin
from robot.api import logger


mrbts_id = str(tl.gnbs[0].instance_id)
nrbts_id = str(tl.gnbs[0].global_bts_id)
bts_prefix = "MRBTS-" + mrbts_id + "/NRBTS-" + nrbts_id
LOCALHOST = '127.0.0.1'


class AdminSession:
    def __init__(self, remote_host=LOCALHOST, remote_user='ute', remote_pass='ute', bts_ip='192.168.255.129'):
        self.admin = taf_admin()
        self.remote_host = remote_host
        self.user = remote_user
        self.password = remote_pass
        self.bts_ip = bts_ip

    def __enter__(self):
        self.admin.setup_admin(
            bts_host=self.bts_ip,
            remote_host=self.remote_host,
            remote_host_username=self.user,
            remote_host_password=self.password)
        return self.admin

    def __exit__(self, exc_type, exc_val, exc_tb):
        self.admin.teardown_admin()


def remove_relation_object(cell_id, instance_number, rel_to_cell='5G'):
    object_name = 'NRREL' if rel_to_cell == '5G' else 'NRRELE'
    with AdminSession() as admin:
        admin.perform_object_recommissioning(
            dist_name='{}/NRCELL-{}/{}-{}'.format(bts_prefix, cell_id, object_name, instance_number),
            parameter=[],
            operation='delete',
        )


def verify_State(cell_id, cell_status, *Cells_info: dict) -> None:
    for cell_information in Cells_info:
        if cell_information["cellName"] == cell_id:
            logger.info("EXPECTED cell id: {}".format(cell_information["cellName"]), also_console=False)
            cell_information_Dict = cell_information["status"]
            logger.info("currently still visible administrativeState for cell id {} : {}"
                        .format(cell_id, cell_information_Dict["administrativeState"]), also_console=False)
            logger.info("expected administrativeState: {}".format(cell_status))
            if cell_information_Dict["administrativeState"] != cell_status:
                raise Exception(f"Expected administrativeState state for cell {cell_information['cellName']} is "
                                + cell_status + f" state, but was "
                                f"in {cell_information_Dict['administrativeState']} status")
