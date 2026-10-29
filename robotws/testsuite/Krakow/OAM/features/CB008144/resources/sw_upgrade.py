from taf.internal.sbts.admin.exceptions import AdminApiConnectionClosedException, AdminApiProcedureFailureException
from taf.rfrl.bts.devices.exceptions import SwUpgradeException
from taf.rfrl.bts.devices.du.sw_update import GnbSwUpdate


def upgrade_sw(sw_version, gnb_id=0, du_id=0, target_path="/tmp", update_timeout=600):
    gnb_sw_update = GnbSwUpdate()
    try:
        sw_path = gnb_sw_update.download_sw_package(sw_version, target_path)
        gnb_sw_update.update_software(sw_package_dir=sw_path, timeout=update_timeout, bts_id=gnb_id, du_id=du_id)
    except (AdminApiConnectionClosedException, AdminApiProcedureFailureException):
        raise SwUpgradeException
