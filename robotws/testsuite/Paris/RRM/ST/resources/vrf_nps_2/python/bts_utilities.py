from functools import wraps
from moler.device import DeviceFactory
from taf.rfrl.utilities.tl_config import load_moler_configuration_from_tl
from moler.util.moler_test import MolerTest
from moler.exceptions import MolerException


@load_moler_configuration_from_tl()
@MolerTest.raise_background_exceptions()
def get_bts_utc_current_time(bts_id=0):
    moler_device = DeviceFactory.get_device("GNB{}".format(bts_id), initial_state="FCT")
    try:
        res = moler_device.get_cmd(cmd_name="echo",
                                   cmd_params={"options": r'$(date --utc +"%Y-%m-%dT%H:%M:%S.%6N%:z")'})()
        return res['RESULT'][0]
    except MolerException:
        MolerTest.error("Error on command date", raise_exception=True)
