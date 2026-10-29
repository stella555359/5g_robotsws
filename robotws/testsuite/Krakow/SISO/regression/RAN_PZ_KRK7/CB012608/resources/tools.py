from moler.util.moler_test import MolerTest
from robot.libraries.BuiltIn import BuiltIn
from taf.sbts.oam.coam.admin import admin
from taf.rfrl.utilities.tl_config import load_moler_configuration_from_tl
from moler.device import DeviceFactory
from taf.rfrl.bts.connections import device_aliases
from taf.rfrl.bts.devices.du.du_operations import GnbDuOperations


admin_connection = admin()
tl = BuiltIn().get_variable_value('${tl}')
if tl.gnbs[0].dus[0].airscale.common_units:
    lmp_address = tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr
else:
    lmp_address = tl.gnbs[0].dus[0].airscale.core_units[0].lmp_connection.addr
gnb_id = tl.gnbs[0].dus[0].global_bts_id
du_operations = GnbDuOperations()
trigger_dist_names = ["MRBTS-{}/TNLSVC-1/TNL-2/TRIGGER-1/TRIGGER_R-1".format(gnb_id),
                      "MRBTS-{}/TNLSVC-1/TNL-2/TRIGGER-2/TRIGGER_R-1".format(gnb_id)]


def lock_sfp_lane(lane):
    """
    Lock SFP Lane

    :param lane: SFP Lane dist name
    :return: None
    """
    admin_connection.connect_to(bts_host=lmp_address)
    try:
        admin_connection.lock(dist_name=lane, timeout=60)
    finally:
        admin_connection.teardown()


def unlock_sfp_lane(lane):
    """
    Unlock SFP Lane

    :param lane: SFP Lane dist name
    :return: None
    """
    admin_connection.connect_to(bts_host=lmp_address)
    try:
        admin_connection.unlock(dist_name=lane, timeout=60)
    finally:
        admin_connection.teardown()
