import time

from taf.sbts.oam.coam.admin import admin

admin_connection = admin()


def verify_x2_link_is_available():
    """Check if X2 connection to all eNBs is available; if not - return eNB ID for unavailable ones."""
    admin_connection.connect_to()
    lteenb_objects = admin_connection.get_managed_objects(class_name="LTEENB_R")
    admin_connection.teardown()
    for _ in range(20):
        for lteenb in lteenb_objects:
            if str(lteenb["parameters"]["eNodeBId"]) != "None":
                break
            time.sleep(5)
    if not lteenb_objects:
        raise AssertionError("Waiting for LTEENB_R object to be available")
    for lteenb in lteenb_objects:
        link_status = lteenb["parameters"]["x2LinkStatus"]
        if "unavailable" in link_status:
            raise AssertionError("X2 link unavailable to {}".format(lteenb["parameters"]["eNodeBId"]))
        return True
