from taf.rfrl.utilities.tl_config import load_moler_configuration_from_tl
from taf.rfrl.bts.connections import device_aliases
from moler.util.moler_test import MolerTest
from moler.device import DeviceFactory


@load_moler_configuration_from_tl()
@MolerTest.raise_background_exceptions()
def change_hub_password(new_password="", user=None, reset_to_default=False, bts_id=0, du_id=0, ru_id=0):
    """
    Main Function:
        This keyword is used to change/reset user hubadmin/hubapp password with password CLI.
    Arguments:
        :new_password: new password
        :user: hubadmin or hubapp, default is hubadmin user
        :reset_to_default: True means to reset password
    Return Value:
        :return: Dictionary of PASSWORD_CHANGED status
    Examples:
        change_password(new_password=new_password, user=user, reset_to_default=True)
    """
    ru_device = DeviceFactory.get_device(device_aliases.ssh_bts_du_ru.format('GNB', bts_id, du_id, ru_id))
    ru_device.goto_state("RFSW_CLI")
    cmd = ru_device.get_cmd(cmd_name="password", cmd_params={"user": user, "reset_to_default": reset_to_default,
                                                             "new_password": new_password})
    result = cmd(timeout=30)
    return result


@load_moler_configuration_from_tl()
@MolerTest.raise_background_exceptions()
def connect_to_hub_with_default_password(bts_id=0, du_id=0, ru_id=0):
    ru_device = DeviceFactory.get_device(device_aliases.ssh_bts_du_ru.format('GNB', bts_id, du_id, ru_id),
                                         initial_state="RU")
