# -*- coding: utf-8 -*-
"""
Keywords for GNB - FSP device.


:copyright: Nokia Networks
:author: I_SC_KRK_PROD_NITROGEN_GMS
:contact: I_SC_KRK_PROD_NITROGEN@internal.nsn.com
:maintainer: I_SC_KRK_PROD_NITROGEN_GMS
:contact: I_SC_KRK_PROD_NITROGEN@internal.nsn.com

"""
from robot.libraries.BuiltIn import BuiltIn

__author__ = 'Tomasz Krol, Agnieszka Bylica, Adam Moszczynski, Wojciech Gabrys'
__copyright__ = 'Copyright (C) 2019, Nokia'
__email__ = 'tomasz.krol@nokia.com, agnieszka.bylica@nokia.com, adam.1.moszczynski@nokia.com, ' \
            'wojciech.gabrys@nokia.com'

import re
import copy
import os
from moler.util.moler_test import MolerTest
from OAM5G_keywords import wait_until_function_succeeds
from taf.ul.sc.asimgr import AsiMgr
from taf.ul.sc.gnb.airscale import AirScale
from taf.ul.sc.exceptions import StatusException
from moler.exceptions import MolerException
from OAM5G_keywords import prepare_deltafile_for_lmpport_management


@MolerTest.raise_background_exceptions()
def check_the_number_of_connected_hubs():
    hw_inventory_info = AsiMgr(autoconnect=True).get_hw_inventory_info()
    amount_hubs_hw_inventory_info = len(hw_inventory_info['HwInventoryInfo']['HUBMOD_R'])
    MolerTest.info("The number of hubs detected in ASiR Manager: {}".format(amount_hubs_hw_inventory_info))

    return int(amount_hubs_hw_inventory_info)


@MolerTest.raise_background_exceptions()
def check_hub_visibility():
    """
    Check if Hub is visible.

    :return: Throws MolerTest.error if HUB is not visible
    """
    MolerTest.info("Checking hub visibility...")

    hw_inventory_info = AsiMgr(autoconnect=True).get_hw_inventory_info()
    tl = BuiltIn().get_variable_value("${tl}")
    amount_hubs_tl = len(tl.gnbs[0].dus[0].rus)
    amount_hubs_hw_inventory_info = len(hw_inventory_info['HwInventoryInfo']['HUBMOD_R'])
    MolerTest.info("The number of hubs found in the tl configuration: {}".format(amount_hubs_tl))
    MolerTest.info("The number of hubs detected in ASiR Manager: {}".format(amount_hubs_hw_inventory_info))

    if not hw_inventory_info['HwInventoryInfo']:
        MolerTest.error("HUBs are not visible")
    else:
        MolerTest.info("HUBs are visible")

    if amount_hubs_tl > amount_hubs_hw_inventory_info:
        MolerTest.error("Not detected all configured HUBs, check configuration and detected devices")

    elif amount_hubs_tl < amount_hubs_hw_inventory_info:
        MolerTest.error("Not configured all detected HUBs, check configuration and detected devices")

    else:
        MolerTest.info('Detected all configured HUBs')


@MolerTest.raise_background_exceptions(check_steps_end=True)
def check_hub_and_antennas_visibility(expected_antennas_nr=1, number_of_hubs=1):
    """
    Check if the Hub and the given number of antennas are visible from the Asir Manager.

    :param expected_antennas_nr: number of connected antennas
    :return: nothing
    """
    check_hub_visibility()

    visible_antennas_nr = AsiMgr(autoconnect=True).get_antennas_number(number_of_hubs)

    if visible_antennas_nr != expected_antennas_nr:
        MolerTest.error("There should be {} antenna(s) visible but number of visible antennas is: {}".format(
            expected_antennas_nr, visible_antennas_nr))
    else:
        MolerTest.info("Number of visible antennas: {}".format(visible_antennas_nr))
    MolerTest.steps_end()


@MolerTest.raise_background_exceptions()
def commission_with_deltafile(deltafile_xml_path, rerun=1):
    """
    Commissioning with provided delta file.
    :param deltafile_xml_path: string, path to deltafile xml
    :param rerun: int, number of tries
    :return: None
    """
    asimgr = AsiMgr(autoconnect=True)
    asimgr.device.goto_state(state="CLI")

    for i in range(rerun):
        commission_cmd = asimgr.device.get_cmd(cmd_name="commission", cmd_params={
            'ne': '192.168.255.129',
            'pw': 'Nemuadmin:nemuuser',
            'deltafile': deltafile_xml_path,
            'options': '-timeout 180'
        })
        try:
            commission_cmd(timeout=180)
            break
        except MolerException as ex:
            except_e = ex
            MolerTest.warning("AsiMgr: cannot finish 'commission' cmd properly, retrying {} of {}".format(i, rerun))
            MolerTest.sleep(seconds=10)

    else:
        MolerTest.error("AsiMgr: cannot finish 'commission' cmd properly! - '{}'".format(except_e))

    MolerTest.sleep(seconds=10)


@MolerTest.raise_background_exceptions(check_steps_end=True)
def check_alarms_on_asimgr(allowed_alarms=[], required_alarms=[], ne="192.168.255.129"):
    """
    Check if there are active alarms not allowed on the Asir Manager.

    :param allowed_alarms: list of alarms (numbers) that do not cause error
    :param required_alarms: list of alarms (numbers) that have to be present
    :return: None
    """

    _allowed_alarms = copy.deepcopy(allowed_alarms)
    _allowed_alarms.extend(required_alarms)
    _allowed_alarms = list(set(_allowed_alarms))

    asimgr_obj = AsiMgr(autoconnect=False, get_device=True, ne=ne)
    asimgr_obj.device.goto_state("UNIX_REMOTE")
    asimgr_obj.connect_to_asimgr()
    alarms_found = asimgr_obj.get_alarms()

    # alarms_found = AsiMgr(autoconnect=True).get_alarms()
    not_allowed_alarms_found = [alarm for alarm in alarms_found if alarm not in _allowed_alarms]
    absent_required_alarms = [alarm for alarm in required_alarms if alarm not in alarms_found]

    if absent_required_alarms:
        MolerTest.error(msg="Some required alarms are not on the AsiMgr: {}".format(
            ', '.join(map(str, absent_required_alarms))))
    else:
        MolerTest.info("All required alarms are on the AsiMgr: {}".format(", ".join(map(str, required_alarms))))

    if not_allowed_alarms_found:
        MolerTest.error(msg="There are not allowed alarms on the AsiMgr: {}".format(
            ', '.join(map(str, not_allowed_alarms_found))))
    else:
        MolerTest.info("No or only allowed alarms present on the AsiMgr")
    MolerTest.steps_end()


def block_all_ants():
    """
    Blocks all antennas.

    :return: Nothing
    """
    asimgr = AsiMgr(autoconnect=True)
    MolerTest.info("Blocking antenna...")
    number_of_ants = asimgr.get_antennas_number()
    for i in range(1, number_of_ants + 1):
        asimgr.block_ant(i)


def unblock_all_ants():
    """
    Unblocks all antennas.

    :return: Nothing
    """
    asimgr = AsiMgr(autoconnect=True)
    MolerTest.info("Unblocking antenna...")
    number_of_ants = asimgr.get_antennas_number()
    for i in range(1, number_of_ants + 1):
        asimgr.unblock_ant(i)


@MolerTest.raise_background_exceptions()
def verify_hubs_serial_number_and_product_code():
    """
    Verify if hubs' productCode and serialNumber and their values are in GetHwInventoryInfo command output

    :return: True or False
    """
    hw_inventory_info = AsiMgr(autoconnect=True).get_hw_inventory_info()
    hw = hw_inventory_info['HwInventoryInfo']['HUBMOD_R']

    fields_verifier_helper = True

    try:
        for hub in hw:
            if hub["productCode"] is None or hub["serialNumber"] is None:
                fields_verifier_helper = False
                MolerTest.error("Lack of productCode's or serialNumber's value in Hubs info")

    except KeyError:
        fields_verifier_helper = False
        MolerTest.error("No productCode or SerialNumber for Hubs")

    return fields_verifier_helper


@MolerTest.raise_background_exceptions()
def verify_antennas_serial_number_and_product_code():
    """
    Verify if antennas productCode and serialNumber and their values are in GetHwInventoryInfo command output

    :return: True or False
    """
    hw_inventory_info = AsiMgr(autoconnect=True).get_hw_inventory_info()
    hw = hw_inventory_info['HwInventoryInfo']['HUBMOD_R']

    fields_verifier_helper = True

    try:
        for hub in hw:
            for antenna in hub['ANTMOD_R']:
                if antenna["productCode"] is None or antenna["serialNumber"] is None:
                    fields_verifier_helper = False
                    MolerTest.error("Lack of productCode's or serialNumber's value in antennas info")

    except KeyError:
        fields_verifier_helper = False
        MolerTest.error("No productCode or SerialNumber field for antennas")

    return fields_verifier_helper


@MolerTest.raise_background_exceptions()
def check_asirant_down(ant_id):
    """
    Check if antenna is down.

    :param ant_id: antenna ID
    :return: True if antenna is down, False otherwise
    """
    if AsiMgr(autoconnect=True).get_ant_status(ant_id) is False:
        return True
    raise StatusException('Ant {} is not down'.format(ant_id))


def check_asirant_up(ant_id):
    """
    Check if antenna is up.

    :param ant_id: antenna ID
    :return: True if antenna is up, False otherwise
    """
    if AsiMgr(autoconnect=True).get_ant_status(ant_id):
        return True
    raise StatusException('Ant {} is not up'.format(ant_id))


def check_all_asirant_up():
    """
    Chack if all antennas are up.

    :return: None
    """
    asimgr = AsiMgr(autoconnect=True)
    number_of_ants = asimgr.get_antennas_number()
    ants = asimgr.get_all_ants_status()
    for i in range(number_of_ants, 0, -1):
        if asimgr.get_ant_status(i, ants=ants) is not True:
            raise StatusException('Ant {} is not up'.format(i))


def wait_until_all_asirants_get_up():
    """
    Wait until all antennas get up or timeout expires.

    :return: None
    """
    wait_until_function_succeeds(check_all_asirant_up, 400, 20)


@MolerTest.raise_background_exceptions()
def reset_all_ants_one_by_one_and_check_if_reset_happens(check_ant_status=True):
    """
    Reset all antennas one by one and check if every antenna has been reset.

    :return: None
    """
    asimgr = AsiMgr(autoconnect=True)
    number_of_ants = asimgr.get_antennas_number()
    for i in range(1, number_of_ants + 1):
        asimgr.reset_asirant(i)
        if check_ant_status is True:
            check_asirant_down(i)
        MolerTest.sleep(120)


@MolerTest.raise_background_exceptions()
def reset_hub_via_asimgr():
    """
    Reset hub via ASiR Manager

    :return:None
    """
    asimgr = AsiMgr(autoconnect=True)
    number_of_hubs = asimgr.get_hub_number()
    MolerTest.info(number_of_hubs)
    for i in range(1, number_of_hubs + 1):
        asimgr.reset_asirhub(i)


@MolerTest.raise_background_exceptions()
def get_asimgr_parameter_value(p_name, outputdir='/tmp', path_to_scf=None):
    """
    Get parameter value
    :param p_name: parameter name
    :param outputdir: destination directory for commissioning file
    :param path_to_scf: current commissioning file path, if None then download commissioning from device
    :return: parameter value
    """
    asimgr = AsiMgr(autoconnect=True)
    if path_to_scf is None:
        path_to_scf = asimgr.collect_commissioning_file(outputdir)
    return asimgr.get_parameter_value_from_scf_file(path_to_scf, p_name)


@MolerTest.raise_background_exceptions()
def check_asimgr_parameter_value(p_name, p_value, outputdir='/tmp', path_to_scf=None, raise_error=True):
    """
    Check if parameter value is equal to p_value.

    :param p_name: parameter name
    :param p_value: parameter value
    :param outputdir: destination directory for commissioning file
    :param path_to_scf: current commissioning file path, if None then download commissioning from device
    :param raise_error: if True raise error when parameter has a wrong value
    :return: True if equal, False otherwise
    """
    current_value = get_asimgr_parameter_value(p_name, outputdir, path_to_scf)
    if current_value == p_value:
        return True
    elif (current_value != p_value) and raise_error:
        MolerTest.error("Value of {} is not {} but {}".format(p_name, p_value, current_value))
        return False
    else:
        return False


@MolerTest.raise_background_exceptions()
def modify_parameter_on_asimgr(p_name, p_value, path_to_delta_scf):
    """
    Modify parameter value in the given delta file and send delta commissioning.

    :param p_name: parameter name
    :param p_value: new parameter value
    :param path_to_delta_scf: path to delta file
    :return: None
    """
    asimgr = AsiMgr(autoconnect=True)
    asimgr.change_parameter_in_scf_file(path_to_delta_scf, p_name, p_value)
    if not asimgr.get_parameter_value_from_scf_file(path_to_delta_scf, p_name) == p_value:
        MolerTest.error("SCF modification failed")
    else:
        asimgr.send_delta_commissioning(path_to_delta_scf)


def login_to_asimgr(user, password):
    """
    Perform Asi Manager login.

    :return: true if login passed, false if login failed
    """
    pw = "{}:{}".format(user, password)
    asimgr = AsiMgr(pw=pw, autoconnect=True)
    asimgr.connect_to_asimgr()
    try:
        asimgr.collect_alarms_file()
        MolerTest.info("Logged in successfully")
    except MolerException:
        MolerTest.info("Login failed")
        raise StatusException


def lock_lmp_port_using_asimgr():
    """
    Prepare send commissioning delta file with administrativeState changed to lock
    :return: None
    """
    asimgr = AsiMgr(autoconnect=True)
    gnb = AirScale(autoconnect=True)
    deltafile_xml_content, lock_lmtport_deltafile_path = prepare_deltafile_for_lmpport_management(
        gnb, type_of_operation="lock")
    prepare_delta_file(
        asimgr=asimgr,
        state="UNIX_REMOTE",
        deltafile_content=deltafile_xml_content,
        deltafile_xml_path=lock_lmtport_deltafile_path
    )

    commission_with_deltafile(deltafile_xml_path=lock_lmtport_deltafile_path)


def unlock_lmp_port_using_asimgr():
    """
    Prepare send commissioning delta file with administrativeState changed to unlock
    :return: None
    """
    asimgr = AsiMgr(autoconnect=True)
    gnb = AirScale(autoconnect=True)
    deltafile_xml_content, unlock_lmtport_deltafile_path = prepare_deltafile_for_lmpport_management(
        gnb, type_of_operation="unlock")
    prepare_delta_file(
        asimgr=asimgr,
        state="UNIX_REMOTE",
        deltafile_content=deltafile_xml_content,
        deltafile_xml_path=unlock_lmtport_deltafile_path
    )

    commission_with_deltafile(deltafile_xml_path=unlock_lmtport_deltafile_path)


@MolerTest.raise_background_exceptions(check_steps_end=True)
def modify_asimgr_scf_file(path_to_scf, scf_name, outputdir, to_match, new_value, count=0):
    """
    Modify part of the file e.g. class, dist_name.

    :param path_to_scf: path to file to modify
    :param scf_name: name of modified file
    :param outputdir: destination directory for modified file
    :param to_match: line to match parameter which value you want to change e.g.
        class="com.nokia.asi:ANTMOD" distName
    :param new_value: new value of parameter e.g. ASI-1/ANTMOD-1
    :param count: number of parameters to change, default 0 means all parameters found
    :return: path to new file containing modification
    """
    with open(path_to_scf, 'r') as scf_file:
        scf_content = scf_file.read()
    modified_scf_content = re.sub(pattern=r'{}=".+"'.format(to_match), repl=lambda m: m.group(1)+'="'+new_value+'"',
                                  string=scf_content, count=count)
    new_scf_path = os.path.join(outputdir, scf_name)
    with open(new_scf_path, 'w+') as modified_scf_file:
        modified_scf_file.write(modified_scf_content)
    MolerTest.steps_end()
    return new_scf_path


def adjust_version_in_asimgr_delta_scf(path_to_scf, path_to_delta, outputdir, delta_name='DeltaAsiName.xml'):
    """
    Get current version of scf file and change it in delta file.

    :param path_to_scf: path to current scf file
    :param path_to_delta: path to delta file without modification
    :param outputdir: destination directory for modified delta file
    :param delta_name: name of modified delta file
    :return: path to modified delta file
    """
    with open(path_to_scf, 'r') as scf_file_content:
        scf_file_content = scf_file_content.read()
    version_match = re.search(r'managedObject\s+.+\sversion="(\S+)"', scf_file_content)
    version = version_match.group(1)
    MolerTest.info(version)
    return modify_asimgr_scf_file(path_to_scf=path_to_delta, scf_name=delta_name, outputdir=outputdir,
                                  to_match='(<managedObject class="com.nokia.asi:\\S+" distName="\\S+" .* version)',
                                  new_value=version)


@MolerTest.raise_background_exceptions()
def prepare_delta_file(asimgr, state, deltafile_content, deltafile_xml_path):
    """
    Prepare deltafile
    :param asimgr: object, asimgr
    :param state: string, state to go
    :param deltafile_content: string, full deltafile
    :param deltafile_xml_path: string, path to delta
    :return: None
    """
    asimgr.device.goto_state(state=state, rerun=5)

    tee_deltafile_xml = asimgr.device.get_cmd(cmd_name="tee", cmd_params={
        'content': deltafile_content,
        'path': os.path.join(deltafile_xml_path)
    })

    tee_deltafile_xml(timeout=30)
