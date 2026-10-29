import time
import logging
from selenium.common.exceptions import TimeoutException
from taf.selenium.sbts import sbts as selenium_coam
from taf.rfrl.utilities import tl_config
from taf.rfrl.bts.devices.generic_bts import GenericBts


def manually_trigger_the_service_account_synchronization(web_user="Nemuadmin", web_password="nemuuser"):
    if web_user != "BTSRead":
        selenium = selenium_coam()
        selenium.enable_virtual_display()
        selenium.login(url="https://192.168.255.129/", username=web_user, password=web_password)
        if selenium.start_up_view_window_exists():
            selenium.close_start_up_view_window()
        selenium.sync_to_radio_modules()
        selenium.logout()
    else:
        logging.warning("BTSRead user can not trigger service account synchronization")


def try_change_flag(username="Nemuadmin", password="nemuuser"):
    selenium = selenium_coam()
    selenium.enable_virtual_display()
    selenium.login(url="https://192.168.255.129/", username=username, password=password)
    if selenium.start_up_view_window_exists():
        selenium.close_start_up_view_window()
    try:
        selenium.set_parameter_value(
            dist_name="MRBTS-{}/MNL-1/MNLENT-1/SECADM-1".format(tl_config.get_bts_instance_id()),
            filter_param="Activate service account synchronization to RU/RF devices",
            new_value="true")
    except TimeoutException:
        if username == "BTSRead" or username == "BTSApplication":
            logging.warning("User {} was not able to change parameter value".format(username))
        else:
            pass
    selenium.logout()


def get_parameter_value(param):
    bts = GenericBts()
    bts.login_gui()
    value = bts.gui_coam.get_planned_parameter_value(
        dist_name="MRBTS-{}/MNL-1/MNLENT-1/SECADM-1".format(tl_config.get_bts_instance_id()),
        filter_param=param)
    bts.logout_gui()
    return value


def change_password_for_user(user, new_password, old_password=None):
    bts = GenericBts()
    bts.login_gui()
    logging.info("Wait for WebEm notifications to disappear")
    time.sleep(20)
    if user == "serviceuser":
        status = bts.gui_coam.change_password_for_service_account(username=user,
                                                                  old_password=old_password,
                                                                  new_password=new_password,
                                                                  confirm_password=new_password)
    else:
        status = bts.gui_coam.configure_local_user_account(account_type=user,
                                                           new_password=new_password,
                                                           confirm_password=new_password)
    logging.info("Wait for WebEm notifications to disappear")
    time.sleep(20)
    bts.logout_gui()
    return status


def set_up_passwords():
    change_password_for_user(user="BTS Security Administrator", new_password="Nemu@123")
    change_password_for_user(user="BTS Application Administrator", new_password="Nemu@123")
    change_password_for_user(user="BTS Read-Only User", new_password="Nemu@123")
