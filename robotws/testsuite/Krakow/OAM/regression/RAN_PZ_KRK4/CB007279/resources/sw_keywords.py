from taf.sbts.oam.coam.admin import admin
from robot.libraries.BuiltIn import BuiltIn
from moler.util.moler_test import MolerTest

builtin = BuiltIn()


def rollback_sw():
    admin_connection = admin()
    admin_connection.connect_to()
    try:
        active_sw = admin_connection.get_software_info()["Active SW version"]
        builtin.log_to_console("Software rollback ongoing")
        admin_connection.rollback_software(timeout=2400)
    except Exception as e:
        builtin.log_to_console("Exception occurred during SW Rollback {}".format(e), "error")
        raise
    finally:
        admin_connection.teardown()
    return active_sw


def verify_sw_changed(sw_version):
    admin_connection = admin()
    admin_connection.connect_to()
    try:
        active_sw = admin_connection.get_software_info()["Active SW version"]
        if sw_version == active_sw:
            MolerTest.error("SW version is not changed to: {}, active sw version is: {}".format(sw_version, active_sw),
                            raise_exception=True)
    finally:
        admin_connection.teardown()
