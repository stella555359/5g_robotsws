"""
:copyright: Nokia Networks
:authors:
    Patryk Wojcik, patryk.wojcik@nokia.com
:maintainers:
    Patryk Wojcik, patryk.wojcik@nokia.com
"""

from taf.internal.sbts.admin.exceptions.exception import AdminApiProcedureFailureException
from taf.sbts.oam.coam.admin import admin
from taf.rfrl.bts.devices.ru.ru_operations import GnbRuOperations as RuOp
from taf.rfrl.bts.devices.du.du_operations import GnbDuOperations as GnbBBu
from taf.rfrl.bts.devices.du.cell_operations import GenericCellOperations
from taf.rfrl.bts.devices.du.alarm_verification import GnbAlarmVerification
from taf.rfrl.bts.devices.generic_bts import GenericBts, login_logout_GUI
from taf.rfrl.utilities import tl_config
from taf.rfrl.utilities.tl_config import load_moler_configuration_from_tl
from moler.device import DeviceFactory
import logging

bts = GnbBBu()
ru_op = RuOp()
gnb_cell = GenericCellOperations()
gnb_alarm = GnbAlarmVerification()
admin_cli = admin()
dist_name = "MRBTS-{}/MNL-1/MNLENT-1/SECADM-1".format(tl_config.get_bts_instance_id())
serviceuser_bts_pswd = "Pl(FzaYj5~c5;q"
serviceuser_ru_pswd = "tC0p5lpI9l/jX3RLphVLv+nxJ4P32DnqZlLyU9wkmeQ="


class CoamBts(GenericBts):
    def __init__(self):
        super(CoamBts, self).__init__()

    @login_logout_GUI
    def set_value_of_actsynctoru(self, value='true', bts_id=0, du_id=0):
        """
        Function to set value of  actsynctoru
        +------------------+---------+------------+------------+------------+
        |     Example                                                       |
        +==================+=========+============+============+============+
        | CoamBts.Set_value_of_actsynctoru    value=true                    |
        +------------------+---------+------------+------------+------------+
        :param value:   value which should be set for actsynctoru
        :param bts_id:  id of bts
        :param du_id:   id of du
        """
        self.gui_coam.set_parameter_value(
            dist_name=dist_name,
            filter_param="Activate service account synchronization to RU/RF devices",
            abbr="actSyncToRU",
            new_value=value,
            sbts=self.gui_alias.format(bts_id, du_id)
        )
        self.gui_coam.validate_plan(sbts=self.gui_alias.format(bts_id, du_id))
        self.gui_coam.activate_plan(sbts=self.gui_alias.format(bts_id, du_id))

    @login_logout_GUI
    def sync_to_radio_modules(self, bts_id=0, du_id=0):
        """
        Function to synchronize radio modules. It is possible to click manually by going to security and service
        account ssh and then clicking Synchronize to Radio Modules
        +------------------+---------+------------+------------+------------+
        |     Example                                                       |
        +==================+=========+============+============+============+
        | CoamBts.Sync_to_radio_modules                                     |
        +------------------+---------+------------+------------+------------+
        :param bts_id:  id of bts
        :param du_id:   id of du
        """
        self.gui_coam.sync_to_radio_modules(sbts=self.gui_alias.format(bts_id, du_id))

    @login_logout_GUI
    def verify_password_for_service_account(self, username, new_password, old_password=serviceuser_bts_pswd, bts_id=0,
                                            du_id=0):
        """
        Verifies password for service account. New password should:
        -get minimum length of password is 8 characters
        -get 3maximum length of password is 128 characters
        -get at least two numbers
        -get lower and upper case letters
        -The following characters are disallowed from 7-bit US ASCII: control = <US-ASCII coded characters
         00-1F and 7F hexadecimal> space = <US-ASCII coded character 20 hexadecimal> delims
          = "<" | ">" unwise = "{" | "}" | "|" | "\" | "^" | "`" colon = ":"
         All other characters are allowed from 7-bit US ASCII
        -password must contain at least 1 non-alphanumeric character.
        +------------------+---------+------------+------------+------------+------------+------------+------------+
        |     Example                                                                                              |
        +==================+=========+============+============+============+============+============+============+
        | CoamBts.Verify_password_for_service_account     username=serviceuser    new_password=${password_too_long}|
        +------------------+---------+------------+------------+------------+------------+------------+------------+
        :param username:        name of user
        :param new_password:    password which should meet all requirements
        :param old_password:    previous password of BTS
        :param bts_id:          id of BTS
        :param du_id:           id of DU
        """
        logging.info(f"Trying to change password to {username}/{new_password}")
        status = self.gui_coam.change_password_for_service_account(username=username, old_password=old_password,
                                                                   new_password=new_password,
                                                                   confirm_password=new_password,
                                                                   sbts=self.gui_alias.format(bts_id, du_id))
        assert not status, f'status={status} with {username}/{new_password}'

    @login_logout_GUI
    def set_password_and_enable_local_user_account(self, account_type, password, activate_state='Active', bts_id=0,
                                                   du_id=0):
        """
        A function is provided for setting passwords and activating local user accounts.
        +------------------+---------+------------+------------+
        |     Example                                          |
        +==================+=========+============+============+
        | CoamBts.Set_password_and_enable_local_user_account   |
        | ...     account_type=BTS Read-Only User              |
        | ...     password=${tl.creds[3].password}             |
        +------------------+---------+------------+------------+
        :account_type:   account type, "BTS System Administrator", "BTS Security Administrator",
                         "BTS Application Administrator" and "BTS Read-Only User" can be choosen
        :password:       new password for local user account
        :activate_state: state of account. May be Active/Inactive
        :param bts_id:   id of bts
        :param du_id:    id of du
        """
        self.gui_coam.configure_local_user_account(account_type=account_type, new_password=password,
                                                   confirm_password=password, activate_state=activate_state,
                                                   sbts=self.gui_alias.format(bts_id, du_id))


def try_to_change_flag_for_service_account_synchronization(username, password):
    """
    Try to change flag actsynctoru for different service account. For BTSApplication and BTSRead should be not
    possible to change flag and exception should appear.
    +------------------+---------+------------+------------+------------+------------+------------+------------+
    |     Example                                                                                              |
    +==================+=========+============+============+============+============+============+============+
    | Try to change flag for service account synchronization                                                   |
    | ...     username=${creds[0].username}                                                                    |
    | ...     password=${creds[0].password}                                                                    |
    +------------------+---------+------------+------------+------------+------------+------------+------------+
    :param username:    name of user
    :param password:    password to log in to Webem
    """
    admin_cli.connect_to(username=username, password=password)
    actsynctoru = admin_cli.get_parameter_by_distname(dist_name=dist_name,
                                                      parameter_list=["actSyncToRU"])
    actsynctoru = actsynctoru[0]["parameters"]["actSyncToRU"]
    if (username == "Nemuadmin" or username == "BTSSecurity") and actsynctoru is True:
        set_actsynctoru_flag(new_value='false')
        ru_op.reset_all_radio_unit(timeout=240)
        bts.wait_for_site_to_be_onair()
        ssh_to_ru_serviceuser(ru_id=0, password=serviceuser_ru_pswd)
        ssh_to_ru_serviceuser(ru_id=1, password=serviceuser_ru_pswd)
    try:
        set_actsynctoru_flag(new_value='true')
        ssh_to_ru_serviceuser(ru_id=0, password=serviceuser_bts_pswd)
        ssh_to_ru_serviceuser(ru_id=1, password=serviceuser_bts_pswd)

    except AdminApiProcedureFailureException:
        assert username in ["BTSApplication", "BTSRead"], 'This exception was expected only for BTSApplication ' \
                                                          'and BTSRead'
        if username == "BTSApplication" or username == "BTSRead":
            logging.info(f"actsynctoru flag cannot be changed from {username} account")
    admin_cli.teardown()


def set_actsynctoru_flag(new_value='true'):
    """
    Function to set value of actsynctoru
    +------------------+---------+------------+------------+------------+
    |     Example                                                       |
    +==================+=========+============+============+============+
    | set_actsynctoru_flag(new_value='false')                           |
    +------------------+---------+------------+------------+------------+
    :param new_value:       value which should be set for actsynctoru
    """
    admin_cli.perform_parameter_recommissioning(dist_name=dist_name,
                                                parameter="actSyncToRU",
                                                operation="update",
                                                value=new_value)


@load_moler_configuration_from_tl()
def get_ru_ip(ru_id, gnb_id=0, du_id=0):
    """
    Gets ip of ru by executing command cat /ffs/run/config/FRIps.txt in proper container na gNB
    +------------------+---------+
    |     Example                |
    +==================+=========+
    | ru_ip = get_ru_ip(ru_id)   |
    +------------------+---------+
    :param ru_id:   id of RU
    :param gnb_id:  id of gNB
    :param du_id:   id of DU
    """
    bts_device = DeviceFactory.get_device(name=bts.ssh_alias.format(gnb_id, du_id))
    bts_device.goto_state("FHNET")
    frips = bts_device.get_cmd(cmd_name='cat',
                               cmd_params={"path": "/ffs/run/config/FRIps.txt"})()['LINES']
    ru_ip = frips[int(ru_id)].split(';')[2]
    return ru_ip


@load_moler_configuration_from_tl()
def ssh_to_ru_serviceuser(ru_id=0, gnb_id=0, du_id=0, user="serviceuser", password=serviceuser_bts_pswd):
    """
    Try to connect to RU with proper password and username=serviceuser.
    +------------------+---------+------------+------------+------------+------------+------------+------------+
    |     Example                                                                                              |
    +==================+=========+============+============+============+============+============+============+
    | Ssh to ru serviceuser    ru_id=1  password=${serviceuser_bts_pswd}                                       |
    +------------------+---------+------------+------------+------------+------------+------------+------------+
    :param ru_id:       id of RU
    :param gnb_id:      id of gNB
    :param du_id:       id of DU
    :param user:        name of user
    :param password:    password to log in to BTS
    """
    ru_ip = get_ru_ip(ru_id)
    ru_name = ru_op.ssh_ru_alias.format(gnb_id, du_id, ru_id)
    ru = DeviceFactory.get_device(name=ru_name, establish_connection=False)
    ru.ru_ip_address = ru_ip
    ru._configurations['CONNECTION_HOPS']['FHNET']['RU']["command_params"]['login'] = user
    ru._configurations['CONNECTION_HOPS']['FHNET']['RU']["command_params"]['password'] = password
    ru = DeviceFactory.get_device(ru_op.ssh_ru_alias.format(gnb_id, du_id, ru_id))
    ru.goto_state("RU")
    return ru


def block_cells_and_check_alarm_activation(cell_list):
    """
    Function to block cells from the list and verify corresponding alarm activation
    +------------------+---------+---------+---------+---------+---------+
    |     Example                                                        |
    +==================+=========+=========+=========+=========+=========+
    | Block cells and check alarm activation    cell_list=${all_cells}   |
    +------------------+---------+---------+---------+---------+---------+
    :param cell_list:   list of cell IDs
    """
    for cell in cell_list:
        gnb_cell.block_cell(cell_id=cell)
        gnb_cell.verify_cell_is_blocked(cell_id=cell)
        gnb_alarm.wait_for_alarm_activation(fault_id=49, awaiting_time=60)


def unblock_cells(cell_list):
    """
    Function to unblock cells from the list
    +------------------+---------+---------+---------+---------+-----------+
    |     Example                                                          |
    +==================+=========+=========+=========+=========+===========+
    | Unblock cells and check alarm activation    cell_list=${all_cells}   |
    +------------------+---------+---------+---------+---------+-----------+
    :param cell_list:   list of cell IDs
    """
    for cell in cell_list:
        gnb_cell.unblock_cell(cell_id=cell)
    gnb_cell.verify_all_cells_are_unblocked()


def check_x2_alarm_activation():
    """
    Function to verify X2 alarm activation
    +------------------+----------+
    |     Example                 |
    +==================+==========+
    | Check X2 alarm activation   |
    +------------------+----------+
    """
    gnb_alarm.wait_for_alarm_activation(fault_id=7300, awaiting_time=300)


def check_x2_alarm_deactivation():
    """
    Function to verify X2 alarm deactivation
    +------------------+-----------+
    |     Example                  |
    +==================+===========+
    | Check X2 alarm deactivation  |
    +------------------+-----------+
    """
    gnb_alarm.wait_for_alarm_deactivation(fault_id=7300, awaiting_time=360)


def check_cell_blocked_alarm_deactivation():
    """
    Function to verify blocked cell alarm deactivation
    +------------------+----------+----------+
    |     Example                            |
    +==================+==========+==========+
    | Check cell blocked alarm deactivation  |
    +------------------+----------+----------+
    """
    gnb_alarm.wait_for_alarm_deactivation(fault_id=49, awaiting_time=60)


def check_all_cells_are_onair():
    """
    Function to verify that all cells are onair
    +------------------+----------+
    |     Example                 |
    +==================+==========+
    | Check all cells are onair   |
    +------------------+----------+
    """
    gnb_cell.wait_for_all_cells_to_be_onair(timeout=600)


def lock_selected_cells(cell_list):
    """
    Function to lock cells from the list
    +------------------+---------+---------+----------+
    |     Example                                     |
    +==================+=========+=========+==========+
    | Lock selected cells    cell_list=${all_cells}   |
    +------------------+---------+---------+----------+
    :param cell_list:   list of cell IDs
    """
    for cell in cell_list:
        gnb_cell.lock_cell(cell_id=cell)
        gnb_cell.wait_for_cell_to_be_locked(cell_id=cell)


def unlock_selected_cells(cell_list):
    """
    Function to unlock cells from the list
    +------------------+---------+---------+------------+
    |     Example                                       |
    +==================+=========+=========+============+
    | Unlock selected cells    cell_list=${all_cells}   |
    +------------------+---------+---------+------------+
    :param cell_list:   list of cell IDs
    """
    for cell in cell_list:
        gnb_cell.unlock_cell(cell_id=cell)
        gnb_cell.verify_cell_is_unlocked(cell_id=cell)


def check_unit_power_reset_alarm_activation():
    """
    Function to verify unit power reset alarm activation
    +------------------+-----------+------------+
    |     Example                               |
    +==================+===========+============+
    | Check unit power reset alarm activation   |
    +------------------+-----------+------------+
    """
    gnb_alarm.wait_for_alarm_activation(fault_id=4589, awaiting_time=300)
