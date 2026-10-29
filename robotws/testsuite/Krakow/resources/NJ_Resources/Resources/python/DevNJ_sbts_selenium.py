import time
import zipfile
import re
import string
import taf.ul.sc.tl_config as tl_config
from robot.api import logger
from taf.selenium.sbts import sbts
from selenium.webdriver.common.by import By
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.support.ui import WebDriverWait as Wait
from taf.sbts.oam.coam.admin import *


def setup_sbts_selenium_and_login(url="https://192.168.255.129", username='Nemuadmin', password='nemuuser',
                                  virtual_enable=False, modal_action_configurations=None, log_level="info",
                                  version=None, browser='Chrome'):
    """
    keyword setup_sbts_selenium_and_login
    setup sbts selenium object and login
    :param url: url of webem address
    :param username: webem user name
    :param password: webem password
    :param virtual_enable: selenium virtual enable flag
    :param modal_action_configurations: pass the modal action configurations with dict list. You can set action
    configuration to the additional_hardware_detected modal like:
    [{
        modal_name: "Additional hardware detected",
        button: "close", #click Additional hardware detected window's close button,
                        if it is "Start sync", will click the start sync button, then click the close button.
        timeout: 20
    }]

    :param log_level: Firefox supported log level "fatal", "error", "warn", "info", "config", "debug", "trace"
                      Chrome supported log level "all", "debug", "info", "warning", "severe", "off".
                      Default value is "info"
    :type log_level: str
    :param version: software release
    :param browser: Chrome or Firefox
    :return: selenium object for webem

    Examples:
    Example 1: Setup selenium object with default parameters
    | ${selenium_coam} | setup_sbts_selenium_and_login |
    Example 2: Setup selenium object with default parameters with parameters
    | ${selenium_coam} | setup_sbts_selenium_and_login | url=https://192.168.255.129 | username=Nemuadmin |
    | ...  password=nemuuser | virtual_enable=${FALSE} |
    Example 3: Setup selenium object with default parameters with start sync
    | ${action} | Create Dictionary | modal_name=Additional hardware detected | button=start sync | timeout=${60}
    | ${action_list} | Create List | ${action}
    | ${selenium_coam} | setup_sbts_selenium_and_login | url=https://192.168.255.129 | username=Nemuadmin |
    | ...  password=nemuuser | virtual_enable=${FALSE} | modal_action_configurations=${action_list}

    Version:
    | Author | Version | Delivery Date | Comments |
    | Zhu Fuzeng | 1.0.0 | 2022/1/1 |  First approved version by VA|
    | Wu Guozhen | 1.0.1 | 2022/4/28 | added parameter modal_action_configurations and Example 3 for start sync|
    | Wu Cuicui | 1.0.2 | 2022/8/15 | add parameter log_level|
    """
    selenium_coam = sbts()
    if virtual_enable:
        selenium_coam.enable_virtual_display()

    if version:
        selenium_coam.login(url=url, browser=browser, username=username, password=password,
                            modal_action_configurations=modal_action_configurations, log_level=log_level,
                            version=version)
    else:
        selenium_coam.login(url=url, browser=browser, username=username, password=password,
                            modal_action_configurations=modal_action_configurations, log_level=log_level)
    selenium_coam.disable_message_box()
    selenium_coam.disable_screen_lock()
    if selenium_coam.start_up_view_window_exists():
        selenium_coam.close_start_up_view_window()
    return selenium_coam


def teardown_sbts_selenium(selenium_coam):
    """
    keyword teardown_sbts_selenium
    selenium logout
    :param selenium_coam: selenium object for webem
    :return: None

    Examples:
    Example: teardown an existing selenium object
    | teardown_sbts_selenium  ${selenium_coam} |
    """
    selenium_coam.logout()


def sbts_selenium_modify_parameters(selenium_coam=None, list_parameters=[],
                                    activate=True, timeout=120, virtual_enable=False, version=None, browser='Chrome'):
    """
    keyword sbts_selenium_modify_parameters
    modify parameters on webem with selenium
    :param selenium_coam: An existing selenium object, if None, will create a new one and login
    :param list_parameters: list of parameter to modify,
            in which the element should be {'dist_name':'xxx','filter_param':'xxx','node_index':'xxx',
            'abbr':'xxx', 'new_value':'xxx'}
            type of node_index is int, it is not a required parameter, the value is none by default.
    :param activate: Activate after modification if True
    :param timeout: Timeout when activation
    :param virtual_enable: selenium virtual enable flag
    :param version: SW release
    :return: None

    Examples:
    Example: Modify 1 parameter, but doesn't activate
    | ${para_mod} | Create Dictionary | dist_name=MRBTS-1/NRBTS-1 | filter_param=Activate A2 based SgNB release |
    | ...  abbr=actA2SgnbRelease | new_value=true |
    | ${list_para_mod} | Create List | ${para_mod} |
    | ${selenium_coam} | setup_sbts_selenium_and_login |
    | sbts_selenium_modify_parameters | selenium_coam=${selenium_coam} | list_parameters=${list_para_mod} |
    | ...  activate=${FALSE} |
    Example: Modify parameter with node_index
    | ${bwpdn_new} | Create Dictionary | dist_name=MRBTS-1/NRBTS-1/NRCELL-1 |
    | ...  filter_param=Bandwidth Part Profile distinguished name |
    | ...  node_index=${0} | abbr=bwpDN |
    | ...  new_value=MRBTS-1/NRBTS-1/BWP_PROFILE-2 |
    | ${list_para_mod} | Create List | ${bwpdn_new} |
    | ${selenium_coam} | setup_sbts_selenium_and_login |
    | sbts_selenium_modify_parameters | selenium_coam=${selenium_coam} | list_parameters=${list_para_mod} |
    """
    if selenium_coam is None:
        if version:
            selenium_coam_conn = setup_sbts_selenium_and_login(virtual_enable=virtual_enable, version=version,
                                                               browser=browser)
        else:
            selenium_coam_conn = setup_sbts_selenium_and_login(virtual_enable=virtual_enable, browser=browser)
    else:
        selenium_coam_conn = selenium_coam
    try:
        assert list_parameters, "list_parameters not provided"
        for para in list_parameters:
            if para.get('node_index'):
                selenium_coam_conn.set_parameter_value(dist_name=para.get('dist_name'),
                                                       node_index=para.get('node_index'),
                                                       filter_param=para.get('filter_param'), abbr=para.get('abbr'),
                                                       new_value=para.get('new_value'))
            else:
                selenium_coam_conn.set_parameter_value(dist_name=para.get('dist_name'),
                                                       filter_param=para.get('filter_param'), abbr=para.get('abbr'),
                                                       new_value=para.get('new_value'))
        if activate:
            prevalidate_and_check_errors(selenium_coam=selenium_coam_conn)
            ret = selenium_coam_conn.activate_plan(timeout=timeout)

            assert ret, "Activate Failure"
    finally:
        if selenium_coam_conn.start_up_view_window_exists():
            selenium_coam_conn.close_start_up_view_window()
        if selenium_coam is None:
            selenium_coam_conn.logout()
            if virtual_enable:
                selenium_coam_conn.disable_virtual_display()


def sbts_software_update(selenium_coam=None, file_path=None, virtual_enable=False, timeout=60,
                         start_enable_timeout=600, reset_timeout=1200):
    """
    keyword sbts_software_update
    update software via selenium on webem
    :param selenium_coam: An existing selenium object, if None, will create a new one and login
    :param file_path: package path
    :param virtual_enable: selenium virtual enable flag
    :param timeout: time to wait software update
    :param start_enable_timeout: time to wait start button enable
    :param reset_timeout: time to wait site resetting begin
    :return: None

    Examples:
    Example: software update
    | ${local_path} | download_sw_build_from_loadserver | build_version=SBTS00_ENB_9999_211006_000011 |
    | sbts_software_update | file_path=${local_path}

    """
    if selenium_coam is None:
        selenium_coam_conn = setup_sbts_selenium_and_login(virtual_enable=virtual_enable)
    else:
        selenium_coam_conn = selenium_coam
    try:
        assert file_path, "file_path is not provided"
        current_sw_version = selenium_coam_conn.check_current_software_version()
        current_active_sw = current_sw_version.get('Active')
        pattern = r'TargetBD_(\w+).xml'
        zstr = zipfile.ZipFile(file_path)
        for file_name in zstr.namelist():
            if re.search(pattern, file_name, re.I | re.M):
                target_sw_version = re.search(pattern, file_name, re.I | re.M).groups()[0]
        if target_sw_version == current_active_sw:
            check_result = True
        else:
            check_result = False
        selenium_coam_conn.load_software_package_from_local_drive(file_path=file_path, timeout=timeout)
        selenium_coam_conn.software_update(is_activate=True, timeout=timeout,
                                           start_enable_timeout=start_enable_timeout)
        dt_start = time.time()
        flag_resetting = False
        while time.time() < dt_start + reset_timeout:
            update_result = selenium_coam_conn.check_software_update_progress()
            update_status = update_result.get('status')
            if not flag_resetting:
                if update_status and 'resetting' in update_status.lower():
                    logger.info("update result changes to {}".format(update_result), also_console=True)
                    flag_resetting = True
                elif check_result and update_status.lower() == 'activation completed':
                    logger.info("update result is activation completed", also_console=True)
                    break
            else:
                if update_status == '':
                    logger.info("update result changes to {}".format(update_result), also_console=True)
                    break
            time.sleep(10)
        else:
            assert False, "Failed to trigger site reset"
        logger.info("SW activation completed, site reset triggered if needed", also_console=True)
    finally:
        if selenium_coam is None:
            selenium_coam_conn.refresh()
            selenium_coam_conn.disable_message_box()
            selenium_coam_conn.disable_screen_lock()
            selenium_coam_conn.logout()


def prevalidate_and_check_errors(selenium_coam=None, virtual_enable=False, timeout=60, version="25R3"):
    """
    keyword prevalidate_and_check_errors
    prevalidate and check errors
    :param selenium_coam: An existing selenium object, if None, will create a new one and login
    :param virtual_enable: selenium virtual enable flag
    :param timeout: timeout for collect errors
    :param version: software release
    :return: None

    Examples:
    Example:
    | ${selenium_coam} | setup_sbts_selenium_and_login |
    | prevalidate_and_check_errors | selenium_coam=${selenium_coam} |

    """
    if selenium_coam is None:
        selenium_coam_conn = setup_sbts_selenium_and_login(virtual_enable=virtual_enable)
    else:
        selenium_coam_conn = selenium_coam
    try:
        selenium_coam_conn.validate_plan(timeout=timeout)
        dict_definition_err = selenium_coam_conn.get_definition_errors(timeout=timeout)
        if version != "25R2" and version != "25R3":
            dict_hardware_err = selenium_coam_conn.get_hardware_errors(timeout=timeout)
        dict_relation_err = selenium_coam_conn.get_relation_errors(timeout=timeout)

        if dict_definition_err:
            logger.info('Definition Errors: {}'.format(dict_definition_err), also_console=True)
        if version != "25R2" and version != "25R3":
            if dict_hardware_err:
                logger.info('Hardware Errors: {}'.format(dict_hardware_err), also_console=True)
        if dict_relation_err:
            logger.info('Relation Errors: {}'.format(dict_relation_err), also_console=True)

        if version != "25R2" and version != "25R3":
            assert not dict_hardware_err, "Prevalidate Errors"
        assert not (dict_definition_err or dict_relation_err), "Prevalidate Errors"
    finally:
        if selenium_coam is None:
            selenium_coam_conn.logout()


def expand_object_and_get_children(object_name, children_name):
    """
    Main Function:
        Expand parent MO and return sub MO under parent MO

    Arguments:
        :param object_name: parent object name
        :param children_name: name of sub MO

    Return Value:
        :return a list of sub MO

    Examples:
        Example 1:
        | Expand Object And Get Children | object_name=LCELNR-${cell_id_copy_from} | children_name=CHANNEL- |

    Version:
        | Author | Version | Delivery Date | Comments |
        | Zhu fuzeng| 1.0.0 | 2022/01/16 | First approved version by VA |
    """

    selenium_coam = sbts()
    conn = sbts().store.get()
    try:
        object_name_list = selenium_coam.get_object_name_list(object_name=object_name, timeout=30)
        if not object_name_list:
            return []
        xpath_expand_icon = "//ui-expandable-panel//span[@aria-label='{}']/ancestor::div[contains(@class," \
                            "'tree-list-row-container')]//i[contains(@ng-class,'collapse-icon')]".format(object_name)

        page = conn.configuration.parameter_editor._view_panel
        wd = page.driver
        expand_icon = wd.find_element(By.XPATH, xpath_expand_icon)
        if 'expand' in expand_icon.get_attribute('class'):
            expand_icon.click()
        expand_icon = wd.find_element(By.XPATH, xpath_expand_icon)
        if 'collapse' in expand_icon.get_attribute('class'):
            xpath_children = "//ui-expandable-panel//span[contains(text(),'{}')]".format(children_name)
            children_objects = wd.find_elements(By.XPATH, xpath_children)
            return [child.get_attribute('textContent').strip() for child in children_objects]
        return []
    finally:
        pass


def get_sbts_cell_relation(dict_bts_info, cell_id, technology):
    dict_cell_cellgroup = {'cell_id': None, 'cell_group_has_other_cell': False}
    if technology.lower() == "nr":
        for cell_info in dict_bts_info['cells']['nr']:
            if str(cell_info['globalCellId']) == str(cell_id):
                dict_cell_cellgroup['cell_id'] = str(cell_id)
                break
        else:  # No cell id found in cell list
            return dict_cell_cellgroup

        dict_cell_cellgroup = {'cell_id': str(
            cell_id), 'cell_group_has_other_cell': False}
        for cell_group in dict_bts_info.get('cellsGroup'):
            cell_list = cell_group.get('nrCellList')
            for cell_in_list in cell_list:
                if cell_in_list.split('-')[-1] == str(cell_id):
                    dict_cell_cellgroup['cell_group_id'] = cell_group.get('id')[
                        'internal'].split('-')[-1]
                    dict_cell_cellgroup['cell_group_has_other_cell'] = len(
                        cell_list) > 1
                    break
            else:
                continue
            break

        if dict_cell_cellgroup.get('cell_group_id'):
            nrdu_list = dict_bts_info.get('nrDU')
            for nrdu in nrdu_list:
                refNrCellGroup_list = nrdu.get('refNrCellGroup')
                dict_cell_cellgroup['nrdu_cellgroup_list_len'] = len(
                    refNrCellGroup_list)
                for index, refNrCellGroup in enumerate(refNrCellGroup_list):
                    if refNrCellGroup == dict_cell_cellgroup.get('cell_group_id'):
                        dict_cell_cellgroup['nrdu_refNrCellGroup_index'] = index
                        break
                else:
                    continue
                break

        return dict_cell_cellgroup

    if technology.lower() == "lte":
        for cell_info in dict_bts_info['cells']['lte']:
            if str(cell_info['globalCellId']) == str(cell_id):
                dict_cell_cellgroup['cell_id'] = str(cell_id)
                break
        else:  # No cell id found in cell list
            return dict_cell_cellgroup

        dict_cell_cellgroup = {'cell_id': str(cell_id), 'cell_group_has_other_cell': False}
        return dict_cell_cellgroup


def add_sbts_cell(cell_id_copy_from, cell_id, asirmod_id, lcrId, technology="nr", chBw=None,
                  virtual_enable=True, timeout=100, oam_ip="192.168.255.129", connection=None, selenium_coam=None,
                  # For NR cell
                  cell_group_id=None, freqBandIndicatorNR=None, physCellId=None,
                  nrarfcn=None, nrarfcnDl=None, nrarfcnUl=None, chBwDl=None, chBwUl=None,
                  prachConfigurationIndex=None, type0CoresetConfigurationIndex=None,
                  gscnOrSsPbchArfcn=None, gscn=None,
                  # For LTE cell
                  phyCellId=None, earfcn=None, earfcnDL=None, earfcnUL=None, dlChBw=None, ulChBw=None,
                  prachConfIndex=None, lnRelGnbCellId=None, lteNrDualConnectAllowed=None, nrCellId=None):
    """
    Main Function:
            Add cell for SBTS site, including LTE TDD/FDD, NR TDD/FDD cells.

    Common Arguments:
            :necessary param cell_id_copy_from: the cell id to copy from
            :necessary param cell_id: the cell id of created cell
            :necessary param asirmod_id: the asirmod id to associated with created cell
            :necessary param lcrId: the lcrId of created cell
            :necessary param technology: Depends on the test line configuration, the possible values could be
                                "nr", "lte". Default is "nr".
            :optional param chBw: for NR/LTE TDD platform, the chBw of created cell
            :optional param virtual_enable: selenium virtual enable flag
            :optional param timeout: timeout for activate plan
            :optional param oam_ip: OAM IP for ssh to nodeb
            :optional param connection: the connection alias if using an existing OAM connection
            :optional param selenium_coam: An existing selenium object, if None, will create a new one and login
    NR Specific Arguments:
            :necessary param cell_group_id: the cell group id of created cell
            :necessary param freqBandIndicatorNR: the freqBandIndicatorNR of created cell
            :necessary param physCellId: the physCellId of created NR cell
            :optional param nrarfcn: for NR TDD platform, the nrarfcn of created cell
            :optional param nrarfcnDl: for NR FDD platform, the nrarfcnDl of created cell
            :optional param nrarfcnUl: for NR FDD platform, the nrarfcnUl of created cell
            :optional param chBwDl: for NR FDD platform, the chBwDl of created cell
            :optional param chBwUl: for NR FDD platform, the chBwUl of created cell
            :optional param prachConfigurationIndex: the prachConfigurationIndex of created NR cell
            :optional param type0CoresetConfigurationIndex: the type0CoresetConfigurationIndex of created cell
            :optional param gscnOrSsPbchArfcn: the gscnOrSsPbchArfcn of created cell
            :optional param gscn: the gscn of created cell
    LTE Specific Arguments:
            :necessary param phyCellId: the phyCellId of created LTE cell
            :optional param earfcn: for LTE TDD platform, the earfcn of created cell
            :optional param earfcnDL: for LTE FDD platform, the earfcnDL of created cell
            :optional param earfcnUL: for LTE FDD platform, the earfcnUL of created cell
            :optional param dlChBw: for LTE FDD platform, the dlChBw of created cell
            :optional param ulChBw: for LTE FDD platform, the ulChBw of created cell
            :optional param prachConfIndex: the prachConfIndex of created LTE cell
            :optional param lnRelGnbCellId: the lnRelGnbCellId of created LTE cell
            :optional param lteNrDualConnectAllowed: the lteNrDualConnectAllowed of created LTE cell
            :optional param nrCellId: the nrCellId of created LTE cell

    Return Value:
            none

    Examples:
            Example 1 for NR TDD:
            | add_sbts_cell | cell_id_copy_from=1  | cell_id=2 | cell_group_id=2 | asirmod_id=2 |
            | physCellId=2 | lcrId=2 | freqBandIndicatorNR=41 | type0CoresetConfigurationIndex=12 |
            | gscn=6498 | prachConfigurationIndex=96 | virtual_disable=False |
            Example 2 for NR FDD:
            | add_sbts_cell | cell_id_copy_from=1 | cell_id=2 | cell_group_id=2 | asirmod_id=2 |
            | physCellId=2 | lcrId=2 | freqBandIndicatorNR=41 | type0CoresetConfigurationIndex=12 |
            | gscn=6498 | prachConfigurationIndex=96 | virtual_disable=False |
            | nrarfcnDl=22222 | nrarfcnUl=33333 | chBwDl=20MHz | chBwUl=15MHz |
            Example 3 for LTE FDD:
            | add_sbts_cell | cell_id_copy_from=1 | cell_id=2 | asirmod_id=1 |
            | physCellId=311 | lcrId=2 |
            | lnRelGnbCellId=1 | lteNrDualConnectAllowed=allowed | nrCellId=22222 |
            | prachConfIndex=3 | earfcnDL=1650 | earfcnUL=19650 | dlChBw=20 MHz | ulChBw=20 MHz |
            | virtual_disable=False | oam_ip=172.30.1.10 | technology=lte |

    Version:
            | Author | Version | Delivery Date | Comments |
            | Dai Min| 0.0.1 | 2022/03/21 | First draft version |
            | Dai Min| 1.0.0 | 2022/03/xx | First approved version by VA |
    """

    adm = admin()
    if not connection:
        adm.setup_admin(bts_host=oam_ip)
    try:
        bts_info = adm.get_bts_info(connection=connection)
        sw_rel_name = adm.get_sw_release_name(connection=connection)
    finally:
        if not connection:
            adm.teardown_admin()
    dict_cell_cellgroup_relation = \
        get_sbts_cell_relation(dict_bts_info=bts_info, cell_id=cell_id, technology=technology)
    logger.info("dict_cell_cellgroup_relation:{}".format(dict_cell_cellgroup_relation), also_console=True)
    logger.info("Check if cell to add {} not exists".format(cell_id), also_console=True)
    if dict_cell_cellgroup_relation['cell_id']:
        raise Exception("Cell already exists!")
    else:
        dict_cell_cellgroup_relation = \
            get_sbts_cell_relation(dict_bts_info=bts_info, cell_id=cell_id_copy_from, technology=technology)
        logger.info("dict_cell_cellgroup_relation:{}".format(dict_cell_cellgroup_relation), also_console=True)
        logger.info("Check if cell to copy from {} exists".format(cell_id_copy_from), also_console=True)
        if not dict_cell_cellgroup_relation['cell_id']:
            raise Exception("Cell to copy not exists!")
        else:
            if technology.lower() == "lte":
                mrbts_id = tl_config.tl.enbs[0].instance_id
                lnbts_id = tl_config.tl.enbs[0].global_bts_id
            else:
                cellgroup_id_copy_from = dict_cell_cellgroup_relation['cell_group_id']
                mrbts_id = tl_config.tl.gnbs[0].instance_id
                nrbts_id = tl_config.tl.gnbs[0].global_bts_id

    if selenium_coam is None:
        selenium_coam_conn = \
            setup_sbts_selenium_and_login(url="https://{}".format(oam_ip), virtual_enable=virtual_enable)
    else:
        selenium_coam_conn = selenium_coam
    try:
        if technology.lower() == "nr":
            # 1. Add a NRCELL object under MRBTS-x/NRBTS-x, copy from existing object
            logger.info("Add a NRCELL object under MRBTS-{}/NRBTS-{}, copy from MRBTS-{}/NRBTS-{}/NRCELL-{}"
                        .format(mrbts_id, nrbts_id, mrbts_id, nrbts_id, cell_id_copy_from), also_console=True)
            selenium_coam_conn. \
                add_object(object_name='MRBTS-{}/NRBTS-{}'.format(mrbts_id, nrbts_id),
                           object_class_name='NRCELL',
                           plan_to_copy_from='CURRENT_BTS_CONF-1',
                           copy_from='MRBTS-{}/NRBTS-{}/NRCELL-{}'.format(mrbts_id, nrbts_id, cell_id_copy_from),
                           include_subobject=True, id_value=cell_id)
            # Set parameter physCellId
            logger.info("Set parameter physCellId {}".format(physCellId), also_console=True)
            selenium_coam_conn.set_parameter_value(
                dist_name='MRBTS-{}/NRBTS-{}/NRCELL-{}'.format(mrbts_id, nrbts_id, cell_id),
                filter_param='Physical cell identifier',
                new_value=physCellId, abbr='physCellId')
            # Set parameter lcrId
            logger.info("Set parameter lcrId {}".format(lcrId), also_console=True)
            selenium_coam_conn.set_parameter_value(
                dist_name='MRBTS-{}/NRBTS-{}/NRCELL-{}'.format(mrbts_id, nrbts_id, cell_id),
                filter_param='Local cell resource ID',
                new_value=lcrId, abbr='lcrId')
            # Set parameter freqBandIndicatorNR
            logger.info("Set parameter freqBandIndicatorNR {}".format(freqBandIndicatorNR), also_console=True)
            selenium_coam_conn.set_parameter_value(
                dist_name='MRBTS-{}/NRBTS-{}/NRCELL-{}'.format(mrbts_id, nrbts_id, cell_id),
                filter_param='Frequency band Indicator NR',
                new_value=freqBandIndicatorNR, abbr='freqBandIndicatorNR')
            # Set parameter prachConfigurationIndex
            if prachConfigurationIndex:
                logger.info("Set parameter prachConfIndex {}".format(prachConfigurationIndex), also_console=True)
                selenium_coam_conn.set_parameter_value(
                    dist_name='MRBTS-{}/NRBTS-{}/NRCELL-{}'.format(mrbts_id, nrbts_id, cell_id),
                    filter_param='PRACH configuration index',
                    new_value=prachConfigurationIndex, abbr='prachConfigurationIndex')
            # Set parameter type0CoresetConfigurationIndex
            if type0CoresetConfigurationIndex:
                logger.info("Set parameter type0CoresetConfiIndex {}".format(type0CoresetConfigurationIndex),
                            also_console=True)
                selenium_coam_conn.set_parameter_value(
                    dist_name='MRBTS-{}/NRBTS-{}/NRCELL-{}'.format(mrbts_id, nrbts_id, cell_id),
                    filter_param='Coreset configuration Index',
                    new_value=type0CoresetConfigurationIndex, abbr='type0CoresetConfigurationIndex')
            # Set parameter gscn
            if gscn:
                logger.info("Set parameter gscn {}".format(gscn), also_console=True)
                selenium_coam_conn.set_parameter_value(
                    dist_name='MRBTS-{}/NRBTS-{}/NRCELL-{}'.format(mrbts_id, nrbts_id, cell_id),
                    filter_param='Global synchronization channel number',
                    new_value=gscn, abbr='gscn')
            # Set parameter gscnOrSsPbchArfcn
            if gscnOrSsPbchArfcn:
                logger.info("Set parameter gscnOrSsPbchArfcn {}".format(gscnOrSsPbchArfcn), also_console=True)
                selenium_coam_conn.set_parameter_value(
                    dist_name='MRBTS-{}/NRBTS-{}/NRCELL-{}'.format(mrbts_id, nrbts_id, cell_id),
                    filter_param='Synchronization channel number',
                    new_value=gscnOrSsPbchArfcn, abbr='gscnOrSsPbchArfcn')
            # Set parameter rModDNList
            has_rModDNList = True
            try:
                selenium_coam_conn.get_parameter_value(dist_name='MRBTS-{}/NRBTS-{}/NRCELL-{}'
                                                       .format(mrbts_id, nrbts_id, cell_id),
                                                       filter_param='List of RMOD distinguished names',
                                                       abbr='rModDNList')
            except Exception as e:
                logger.info("{}, get_parameter_value rModDNList exception: {}".format(sw_rel_name, str(e)),
                            also_console=True)
                has_rModDNList = False

            if has_rModDNList:
                selenium_coam_conn.set_parameter_value(
                    dist_name='MRBTS-{}/NRBTS-{}/NRCELL-{}'.format(mrbts_id, nrbts_id, cell_id),
                    filter_param='List of RMOD distinguished names',
                    new_value='MRBTS-{}/EQM-1/APEQM-1/ASIRMOD-{}'.format(mrbts_id, asirmod_id),
                    node_index=0, abbr='rModDNList')
            # Set parameter narfcn
            if nrarfcn:
                selenium_coam_conn.set_parameter_value(
                    dist_name='MRBTS-{}/NRBTS-{}/NRCELL-{}'.format(mrbts_id, nrbts_id, cell_id),
                    filter_param='NR Absolute radio frequency channel number',
                    new_value=nrarfcn, abbr='nrarfcn')
            if nrarfcnDl:
                selenium_coam_conn.set_parameter_value(
                    dist_name='MRBTS-{}/NRBTS-{}/NRCELL-{}/NRCELL_FDD-1'.format(mrbts_id, nrbts_id, cell_id),
                    filter_param='NR Absolute radio frequency channel number in downlink',
                    new_value=nrarfcnDl, abbr='nrarfcnDl')
            if nrarfcnUl:
                selenium_coam_conn.set_parameter_value(
                    dist_name='MRBTS-{}/NRBTS-{}/NRCELL-{}/NRCELL_FDD-1'.format(mrbts_id, nrbts_id, cell_id),
                    filter_param='NR Absolute radio frequency channel number in uplink',
                    new_value=nrarfcnUl, abbr='nrarfcnUl')
            # Set parameter chBw
            if chBw:
                logger.info("Set parameter chBw {}".format(chBw), also_console=True)
                selenium_coam_conn.set_parameter_value(
                    dist_name='MRBTS-{}/NRBTS-{}/NRCELL-{}'.format(mrbts_id, nrbts_id, cell_id),
                    filter_param='Channel bandwidth',
                    new_value=chBw, abbr='chBw')
            # Set parameter chBwDl
            if chBwDl:
                logger.info("Set parameter chBwDl {}".format(chBwDl), also_console=True)
                selenium_coam_conn.set_parameter_value(
                    dist_name='MRBTS-{}/NRBTS-{}/NRCELL-{}/NRCELL_FDD-1'.format(mrbts_id, nrbts_id, cell_id),
                    filter_param='Channel bandwidth in downlink',
                    new_value=chBwDl, abbr='chBwDl')
            # Set parameter chBwUl
            if chBwDl:
                logger.info("Set parameter chBwUl {}".format(chBwUl), also_console=True)
                selenium_coam_conn.set_parameter_value(
                    dist_name='MRBTS-{}/NRBTS-{}/NRCELL-{}/NRCELL_FDD-1'.format(mrbts_id, nrbts_id, cell_id),
                    filter_param='Channel bandwidth in uplink',
                    new_value=chBwUl, abbr='chBwUl')

            # 2. Add a NRCELLGRP object under MRBTS-x/NRBTS-x, copy from existing object:
            logger.info("Add a NRCELLGRP object under MRBTS-{}/NRBTS-{}, copy from MRBTS-{}/NRBTS-{}/NRCELLGRP-{}"
                        .format(mrbts_id, nrbts_id, mrbts_id, nrbts_id, cellgroup_id_copy_from), also_console=True)
            selenium_coam_conn.add_object(object_name='MRBTS-{}/NRBTS-{}'.format(mrbts_id, nrbts_id),
                                          object_class_name='NRCELLGRP',
                                          plan_to_copy_from='CURRENT_BTS_CONF-1',
                                          copy_from='MRBTS-{}/NRBTS-{}/NRCELLGRP-{}'
                                          .format(mrbts_id, nrbts_id, cellgroup_id_copy_from),
                                          include_subobject=True, id_value=cell_group_id)
            # Modify value of nrCelllList #1 to lcrId of new cell:
            logger.info("Set parameter nrCellList {}".format(lcrId), also_console=True)
            selenium_coam_conn.set_parameter_value(
                dist_name='MRBTS-{}/NRBTS-{}/NRCELLGRP-{}'.format(mrbts_id, nrbts_id, cell_group_id),
                filter_param='List of NR cells assigned to cell group',
                node_index=0, new_value=lcrId, abbr='nrCellList')

            # 3. Add a LCELNR object under MRBTS-x/MNL-1/MNLENT-1/CELLMAPPING-1/, copy from existing object
            cell_map_node_list = selenium_coam_conn.get_object_name_list(object_name='CELLMAPPING')
            logger.info("Set cell_map_node_list: {}".format(cell_map_node_list), also_console=True)
            cell_map_node = cell_map_node_list[0]
            channel_list = expand_object_and_get_children(object_name='LCELNR-{}'.format(cell_id_copy_from),
                                                          children_name='CHANNEL-')
            logger.info("Channel list: {}".format(channel_list), also_console=True)
            logger.info("Add a LCELNR object under CELLMAPPING-1, copy from MRBTS-{}/MNL-1/MNLENT-1/{}/LCELNR-{}"
                        .format(mrbts_id, cell_map_node, cell_id_copy_from), also_console=True)
            selenium_coam_conn.add_object(object_name='MRBTS-{}/MNL-1/MNLENT-1/{}'.format(mrbts_id, cell_map_node),
                                          object_class_name='LCELNR',
                                          plan_to_copy_from='CURRENT_BTS_CONF-1',
                                          copy_from='MRBTS-{}/MNL-1/MNLENT-1/{}/LCELNR-{}'
                                          .format(mrbts_id, cell_map_node, cell_id_copy_from),
                                          include_subobject=True, id_value=cell_id)
            logger.info("Set parameter   LCELNR-{}/lCelnrId {}".format(cell_id, lcrId), also_console=True)
            logger.info("change antlDN in channel list: {}".format(channel_list), also_console=True)
            for channel in channel_list:
                copy_from_channel_distname = 'MRBTS-{}/MNL-1/MNLENT-1/{}/LCELNR-{}/CHANNELGROUP-1/{}' \
                    .format(mrbts_id, cell_map_node, cell_id_copy_from, channel)
                channel_distname = 'MRBTS-{}/MNL-1/MNLENT-1/{}/LCELNR-{}/CHANNELGROUP-1/{}' \
                    .format(mrbts_id, cell_map_node, cell_id, channel)
                logger.info("copy_from_channel_distname: {}".format(copy_from_channel_distname), also_console=True)
                logger.info("channel_distname: {}".format(channel_distname), also_console=True)
                cur_DN = selenium_coam_conn.get_parameter_value(dist_name=copy_from_channel_distname,
                                                                filter_param='Distinguished Name of antenna line',
                                                                abbr='antlDN')
                logger.info("current DN: {}".format(cur_DN), also_console=True)
                set_DN = re.sub(r'RMOD-\d+', 'RMOD-{}'.format(asirmod_id), cur_DN)
                logger.info("set new DN: {}".format(set_DN), also_console=True)
                selenium_coam_conn.set_parameter_value(
                    dist_name=channel_distname,
                    filter_param='Distinguished Name of antenna line',
                    new_value=set_DN, abbr='antlDN')
            logger.info("change antlDN in channel list: {}".format(channel_list), also_console=True)

            # 4. Add value of new cellgroup id in refNrCellGroup under MRBTS-x/NRBTS-x/NRDU-1
            logger.info("Add value of new cellgroup id in refNrCellGroup under MRBTS-{}/NRBTS-{}/NRDU-1"
                        .format(mrbts_id, nrbts_id), also_console=True)
            selenium_coam_conn.add_element(dist_name='MRBTS-{}/NRBTS-{}/NRDU-1'.format(mrbts_id, nrbts_id),
                                           filter_param='Reference to cell group',
                                           abbr='refNrCellGroup')
            logger.info("Set parameter refNrCellGroup {}".format(cell_group_id), also_console=True)
            selenium_coam_conn.set_parameter_value(
                dist_name='MRBTS-{}/NRBTS-{}/NRDU-1'.format(mrbts_id, nrbts_id),
                filter_param='Reference to cell group',
                node_index=dict_cell_cellgroup_relation['nrdu_cellgroup_list_len'],
                new_value=cell_group_id, abbr='refNrCellGroup')

        if technology.lower() == "lte":
            # 1. Add a LNCELL object under MRBTS-x/LNBTS-x, copy from existing object
            logger.info("Add a LNCELL object under MRBTS-{}/LNBTS-{}, copy from MRBTS-{}/LNBTS-{}/LNCEL-{}"
                        .format(mrbts_id, lnbts_id, mrbts_id, lnbts_id, cell_id_copy_from), also_console=True)
            selenium_coam_conn. \
                add_object(object_name='MRBTS-{}/LNBTS-{}'.format(mrbts_id, lnbts_id),
                           object_class_name='LNCEL',
                           plan_to_copy_from='CURRENT_BTS_CONF-1',
                           copy_from='MRBTS-{}/LNBTS-{}/LNCEL-{}'.format(mrbts_id, lnbts_id, cell_id_copy_from),
                           include_subobject=True, id_value=cell_id)
            # Set parameter phyCellId
            logger.info("Set parameter phyCellId {}".format(phyCellId), also_console=True)
            selenium_coam_conn.set_parameter_value(
                dist_name='MRBTS-{}/LNBTS-{}/LNCEL-{}'.format(mrbts_id, lnbts_id, cell_id),
                filter_param='Physical layer cell identity',
                new_value=phyCellId, abbr='phyCellId')
            # Set parameter lcrId
            logger.info("Set parameter lcrId {}".format(lcrId), also_console=True)
            selenium_coam_conn.set_parameter_value(
                dist_name='MRBTS-{}/LNBTS-{}/LNCEL-{}'.format(mrbts_id, lnbts_id, cell_id),
                filter_param='Local cell resource ID',
                new_value=lcrId, abbr='lcrId')
            # Set parameter prachConfIndex
            if prachConfIndex:
                logger.info("Set parameter prachConfIndex {}".format(prachConfIndex), also_console=True)
                try:
                    selenium_coam_conn.set_parameter_value(
                        dist_name='MRBTS-{}/LNBTS-{}/LNCEL-{}/LNCEL_FDD-0'.format(mrbts_id, lnbts_id, cell_id),
                        filter_param='PRACH configuration index',
                        new_value=prachConfIndex, abbr='prachConfIndex')
                except Exception:
                    selenium_coam_conn.set_parameter_value(
                        dist_name='MRBTS-{}/LNBTS-{}/LNCEL-{}/LNCEL_TDD-0'.format(mrbts_id, lnbts_id, cell_id),
                        filter_param='PRACH configuration index',
                        new_value=prachConfIndex, abbr='prachConfIndex')
            # Set parameter earfcn
            if earfcn:
                try:
                    selenium_coam_conn.set_parameter_value(
                        dist_name='MRBTS-{}/LNBTS-{}/LNCEL-{}'.format(mrbts_id, lnbts_id, cell_id),
                        filter_param='EARFCN for both Downlink and Uplink (TDD)',
                        new_value=earfcn, abbr='earfcn')
                except Exception:
                    selenium_coam_conn.set_parameter_value(
                        dist_name='MRBTS-{}/LNBTS-{}/LNCEL-{}/LNCEL_TDD-0'.format(mrbts_id, lnbts_id, cell_id),
                        filter_param='EARFCN for both Downlink and Uplink (TDD)',
                        new_value=earfcn, abbr='earfcn')
            if earfcnDL:
                selenium_coam_conn.set_parameter_value(
                    dist_name='MRBTS-{}/LNBTS-{}/LNCEL-{}/LNCEL_FDD-0'.format(mrbts_id, lnbts_id, cell_id),
                    filter_param='EARFCN downlink',
                    new_value=earfcnDL, abbr='earfcnDL')
            if earfcnUL:
                selenium_coam_conn.set_parameter_value(
                    dist_name='MRBTS-{}/LNBTS-{}/LNCEL-{}/LNCEL_FDD-0'.format(mrbts_id, lnbts_id, cell_id),
                    filter_param='EARFCN uplink',
                    new_value=earfcnUL, abbr='earfcnUL')
            # Set parameter chBw
            if chBw:
                logger.info("Set parameter chBw {}".format(chBw), also_console=True)
                try:
                    selenium_coam_conn.set_parameter_value(
                        dist_name='MRBTS-{}/LNBTS-{}/LNCEL-{}'.format(mrbts_id, lnbts_id, cell_id),
                        filter_param='Channel bandwidth TDD',
                        new_value=chBw, abbr='chBw')
                except Exception:
                    selenium_coam_conn.set_parameter_value(
                        dist_name='MRBTS-{}/LNBTS-{}/LNCEL-{}/LNCEL_TDD-0'.format(mrbts_id, lnbts_id, cell_id),
                        filter_param='Channel bandwidth TDD',
                        new_value=chBw, abbr='chBw')
            # Set parameter dlChBw
            if dlChBw:
                logger.info("Set parameter dlChBw {}".format(dlChBw), also_console=True)
                selenium_coam_conn.set_parameter_value(
                    dist_name='MRBTS-{}/LNBTS-{}/LNCEL-{}/LNCEL_FDD-0'.format(mrbts_id, lnbts_id, cell_id),
                    filter_param='Downlink channel bandwidth',
                    new_value=dlChBw, abbr='dlChBw')
            # Set parameter ulChBw
            if ulChBw:
                logger.info("Set parameter ulChBw {}".format(ulChBw), also_console=True)
                selenium_coam_conn.set_parameter_value(
                    dist_name='MRBTS-{}/LNBTS-{}/LNCEL-{}/LNCEL_FDD-0'.format(mrbts_id, lnbts_id, cell_id),
                    filter_param='Uplink channel bandwidth',
                    new_value=ulChBw, abbr='ulChBw')
            # Set parameter lnRelGnbCellId
            if lnRelGnbCellId:
                logger.info("Set parameter lnRelGnbCellId {}".format(lnRelGnbCellId), also_console=True)
                try:
                    selenium_coam_conn.set_parameter_value(
                        dist_name='MRBTS-{}/LNBTS-{}/LNCEL-{}/LNRELGNBCELL-0'.format(mrbts_id, lnbts_id, cell_id),
                        filter_param='New Radio neighbor relation cell identifier',
                        new_value=lnRelGnbCellId, abbr='lnRelGnbCellId')
                except Exception:
                    selenium_coam_conn.set_parameter_value(
                        dist_name='MRBTS-{}/LNBTS-{}/LNCEL-{}/LNRELGNBCELL-1'.format(mrbts_id, lnbts_id, cell_id),
                        filter_param='New Radio neighbor relation cell identifier',
                        new_value=lnRelGnbCellId, abbr='lnRelGnbCellId')
            # Set parameter lteNrDualConnectAllowed
            if lteNrDualConnectAllowed:
                logger.info("Set parameter lteNrDualConnectAllowed {}".format(lteNrDualConnectAllowed),
                            also_console=True)
                try:
                    selenium_coam_conn.set_parameter_value(
                        dist_name='MRBTS-{}/LNBTS-{}/LNCEL-{}/LNRELGNBCELL-0'.format(mrbts_id, lnbts_id, cell_id),
                        filter_param='LTE-NR Dual Connectivity (EN-DC) allowed',
                        new_value=lteNrDualConnectAllowed, abbr='lteNrDualConnectAllowed')
                except Exception:
                    selenium_coam_conn.set_parameter_value(
                        dist_name='MRBTS-{}/LNBTS-{}/LNCEL-{}/LNRELGNBCELL-1'.format(mrbts_id, lnbts_id, cell_id),
                        filter_param='LTE-NR Dual Connectivity (EN-DC) allowed',
                        new_value=lteNrDualConnectAllowed, abbr='lteNrDualConnectAllowed')
            # Set parameter nrCellId
            if nrCellId:
                logger.info("Set parameter nrCellId {}".format(nrCellId), also_console=True)
                try:
                    selenium_coam_conn.set_parameter_value(
                        dist_name='MRBTS-{}/LNBTS-{}/LNCEL-{}/LNRELGNBCELL-0'.format(mrbts_id, lnbts_id, cell_id),
                        filter_param='New Radio global cell identifier',
                        new_value=nrCellId, abbr='nrCellId')
                except Exception:
                    selenium_coam_conn.set_parameter_value(
                        dist_name='MRBTS-{}/LNBTS-{}/LNCEL-{}/LNRELGNBCELL-1'.format(mrbts_id, lnbts_id, cell_id),
                        filter_param='New Radio global cell identifier',
                        new_value=nrCellId, abbr='nrCellId')

            # 2. Add a LCELL object under MRBTS-x/MNL-1/MNLENT-1/CELLMAPPING-1/, copy from existing object
            cell_map_node_list = selenium_coam_conn.get_object_name_list(object_name='CELLMAPPING')
            logger.info("Set cell_map_node_list: {}".format(cell_map_node_list), also_console=True)
            cell_map_node = cell_map_node_list[0]
            channel_list = expand_object_and_get_children(object_name='LCELL-{}'.format(cell_id_copy_from),
                                                          children_name='CHANNEL-')
            logger.info("Channel list: {}".format(channel_list), also_console=True)
            logger.info("Add a LCELL object under CELLMAPPING-1, copy from MRBTS-{}/MNL-1/MNLENT-1/{}/LCELL-{}"
                        .format(mrbts_id, cell_map_node, cell_id_copy_from), also_console=True)
            selenium_coam_conn.add_object(object_name='MRBTS-{}/MNL-1/MNLENT-1/{}'.format(mrbts_id, cell_map_node),
                                          object_class_name='LCELL',
                                          plan_to_copy_from='CURRENT_BTS_CONF-1',
                                          copy_from='MRBTS-{}/MNL-1/MNLENT-1/{}/LCELL-{}'
                                          .format(mrbts_id, cell_map_node, cell_id_copy_from),
                                          include_subobject=True, id_value=cell_id)
            logger.info("Set parameter   LCELL-{}/lCellId {}".format(cell_id, lcrId), also_console=True)
            logger.info("change antlDN in channel list: {}".format(channel_list), also_console=True)
            for channel in channel_list:
                copy_from_channel_distname = 'MRBTS-{}/MNL-1/MNLENT-1/{}/LCELL-{}/CHANNELGROUP-1/{}' \
                    .format(mrbts_id, cell_map_node, cell_id_copy_from, channel)
                channel_distname = 'MRBTS-{}/MNL-1/MNLENT-1/{}/LCELL-{}/CHANNELGROUP-1/{}' \
                    .format(mrbts_id, cell_map_node, cell_id, channel)
                logger.info("copy_from_channel_distname: {}".format(copy_from_channel_distname), also_console=True)
                logger.info("channel_distname: {}".format(channel_distname), also_console=True)
                cur_DN = selenium_coam_conn.get_parameter_value(dist_name=copy_from_channel_distname,
                                                                filter_param='Distinguished Name of antenna line',
                                                                abbr='antlDN')
                logger.info("current DN: {}".format(cur_DN), also_console=True)
                set_DN = re.sub(r'RMOD-\d+', 'RMOD-{}'.format(asirmod_id), cur_DN)
                logger.info("set new DN: {}".format(set_DN), also_console=True)
                selenium_coam_conn.set_parameter_value(
                    dist_name=channel_distname,
                    filter_param='Distinguished Name of antenna line',
                    new_value=set_DN, abbr='antlDN')
            logger.info("change antlDN in channel list: {}".format(channel_list), also_console=True)

        logger.info("Validate And Activate parameters", also_console=True)
        error = selenium_coam_conn.validate_plan(timeout=timeout)
        logger.info("Validate error: {}".format(error), also_console=True)
        ret = selenium_coam_conn.activate_plan(download_plan_without_activation=False,
                                               activate_plan_despite_errors=True,
                                               timeout=timeout)
        assert ret, "Activate Failure"

    finally:
        if selenium_coam is None:
            selenium_coam_conn.logout()


def delete_sbts_cell(cell_id, virtual_enable=True, timeout=100, selenium_coam=None,
                     oam_ip="192.168.255.129", connection=None, technology="nr"):
    """
    Main Function:
            Delete a cell, according to a given cell id, including LTE TDD/FDD, NR TDD/FDD cells.

    Arguments:
            :param cell_id: the cell id to delete
            :param virtual_enable: selenium virtual enable flag
            :param timeout: timeout for activate plan
            :param selenium_coam: An existing selenium object, if None, will create a new one and login
            :param oam_ip: OAM IP for ssh to nodeb
            :param connection: the connection alias if using an existing OAM connection
            :param technology: Depends on the test line configuration, the possible values could be
                                "nr", "lte". Default is "nr".

    Return Value:
            none

    Examples:
            Example 1: Delete Cell 2, showing internet explorer procedure for debug:
            | delete_sbts_cell | cell_id=2 | virtual_disable=FALSE |
            Example 2: Delete Cell 2, without virtual display:
            | delete_sbts_cell | cell_id=2 |
            Example 3: Delete LTE Cell 2, without virtual display:
            | delete_sbts_cell | cell_id=2 | oam_ip=172.30.1.10 | technology=lte |

    Version:
            | Author | Version | Delivery Date | Comments |
            | Dai Min| 0.0.1 | 2022/03/21 | First draft version |
            | Dai Min| 1.0.0 | 2022/03/xx | First approved version by VA |
    """
    adm = admin()
    if not connection:
        adm.setup_admin(bts_host=oam_ip)
    try:
        bts_info = adm.get_bts_info(connection=connection)
    finally:
        if not connection:
            adm.teardown_admin()
    dict_cell_cellgroup_relation = \
        get_sbts_cell_relation(dict_bts_info=bts_info, cell_id=cell_id, technology=technology)

    logger.info("dict_cell_cellgroup_relation:{}".format(dict_cell_cellgroup_relation), also_console=True)
    logger.info("Check if cell {} exists".format(cell_id), also_console=True)
    if not dict_cell_cellgroup_relation['cell_id']:
        raise Exception("Cell not exists!")
    if technology.lower() == "lte":
        mrbts_id = tl_config.tl.enbs[0].instance_id
        lnbts_id = tl_config.tl.enbs[0].global_bts_id
    else:
        mrbts_id = tl_config.tl.gnbs[0].instance_id
        nrbts_id = tl_config.tl.gnbs[0].global_bts_id

    if selenium_coam is None:
        selenium_coam_conn = \
            setup_sbts_selenium_and_login(url="https://{}".format(oam_ip), virtual_enable=virtual_enable)
    else:
        selenium_coam_conn = selenium_coam
    try:
        if technology.lower() == "lte":
            selenium_coam_conn. \
                remove_object(object_name='MRBTS-{}/NRBTS-{}/LNCEL-{}'.format(mrbts_id, lnbts_id, cell_id))
            selenium_coam_conn.remove_object(object_name='MRBTS-{}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELL-{}'
                                             .format(mrbts_id, cell_id))
        if technology.lower() == "nr":
            selenium_coam_conn. \
                remove_object(object_name='MRBTS-{}/NRBTS-{}/NRCELL-{}'.format(mrbts_id, nrbts_id, cell_id))
            if not dict_cell_cellgroup_relation['cell_group_has_other_cell']:
                selenium_coam_conn. \
                    remove_object(object_name='MRBTS-{}/NRBTS-{}/NRCELLGRP-{}'
                                  .format(mrbts_id, nrbts_id, dict_cell_cellgroup_relation['cell_group_id']))
                selenium_coam_conn.remove_element(dist_name='MRBTS-{}/NRBTS-{}/NRDU-1'.format(mrbts_id, nrbts_id),
                                                  filter_param='Reference to cell group',
                                                  node_index=dict_cell_cellgroup_relation['nrdu_refNrCellGroup_index'],
                                                  abbr='refNrCellGroup')
            selenium_coam_conn.remove_object(object_name='MRBTS-{}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-{}'
                                             .format(mrbts_id, cell_id))

        logger.info("Validate And Activate parameters", also_console=True)
        error = selenium_coam_conn.validate_plan(timeout=timeout)
        logger.info("Validate error: {}".format(error), also_console=True)
        ret = selenium_coam_conn.activate_plan(download_plan_without_activation=False,
                                               activate_plan_despite_errors=True,
                                               timeout=timeout)
        assert ret, "Activate Failure"

    finally:
        if selenium_coam is None:
            selenium_coam_conn.logout()


def get_site_lock_or_unlock_status(selenium_coam=None, timeout=60, virtual_enable=False):
    """
    get_bts_lock_or_unlock_lte function,
    Get the Block Site/Unblock Site button's realtime text
    :param timeout: Timeout value for selenium operation
    """
    if selenium_coam is None:
        selenium_coam_conn = setup_sbts_selenium_and_login(virtual_enable=virtual_enable)
    else:
        selenium_coam_conn = selenium_coam
    try:
        _BTS_LOCK_UNLOCK_BUTTON_XPATH = "//site-block-unblock//ui-button"
        coam = selenium_coam_conn.store.get()
        coam.bts_status.site_view.navigate_to()
        dbg = coam.debug
        status = dbg.get_attribute_by_xpath(_BTS_LOCK_UNLOCK_BUTTON_XPATH, "a-title", timeout)
    finally:
        if selenium_coam is None:
            selenium_coam_conn.logout()
    return status


def block_site_from_webem(selenium_coam=None, timeout=60, virtual_enable=False):
    """
    block_bts_site function,
    Executes the block site operation on the WebEm
    :param timeout: Timeout value for selenium operation
    """
    return _change_bts_status(field='Block Site', timeout=timeout, selenium_coam=selenium_coam, virtual_enable=False)


def unblock_site_from_webem(selenium_coam=None, timeout=60, virtual_enable=False):
    """
    unblock_bts_site function,
    Executes the unblock site operation on the WebEm
    :param timeout: Timeout value for selenium operation
    """
    return _change_bts_status(field='Unblock Site', timeout=timeout, selenium_coam=selenium_coam, virtual_enable=False)


def _change_bts_status(field, timeout, selenium_coam=None, virtual_enable=False):
    """
    _change_bts_status function,
    Do block/unblock site operation, according to the field
    :param field: Timeout value for selenium operation, either _BTS_LOCK_FIELD or _BTS_UNLOCK_FIELD
    :param timeout: Timeout value for selenium operation
    :return a Block Site/Unblock Site button's realtime text after opertion
    """
    if selenium_coam is None:
        selenium_coam_conn = setup_sbts_selenium_and_login(virtual_enable=virtual_enable)
    else:
        selenium_coam_conn = selenium_coam
    try:
        _MODAL_XPATH = '//div[@class="modal-content"]'
        _LOCK_OR_UNLOCK_BUTTON_XPATH = '//div[@class="modal-content"]//ui-button[contains(*, "lock")]'

        _BTS_LOCK_UNLOCK_BUTTON_XPATH = "//site-block-unblock//ui-button"
        _BTS_LOCK_FIELD = 'Block Site'
        _BTS_UNLOCK_FIELD = 'Unblock Site'

        coam = selenium_coam_conn.store.get()
        coam.bts_status.site_view.navigate_to()
        dbg = coam.debug
        dbg.wait_for_enable((By.XPATH, _BTS_LOCK_UNLOCK_BUTTON_XPATH), timeout)
        try:
            current_status = dbg.get_attribute_by_xpath(_BTS_LOCK_UNLOCK_BUTTON_XPATH, "a-title")
        except NoSuchAttributeException:
            current_status = dbg.get_attribute_by_xpath(_BTS_LOCK_UNLOCK_BUTTON_XPATH, "a-text")
        if field != current_status:
            raise InvalidElementStateException('bts is already {}'.format(field.lower().split(' ')[0]))
        dbg.click_enabled_element((By.XPATH, _BTS_LOCK_UNLOCK_BUTTON_XPATH))
        dbg.wait_for_visibility((By.XPATH, _MODAL_XPATH), timeout)
        logger.info("modal xpath appear")
        dbg.click_enabled_element((By.XPATH, _LOCK_OR_UNLOCK_BUTTON_XPATH), timeout)
        dbg.wait_for_text_not_present_in_element((By.XPATH, _BTS_LOCK_UNLOCK_BUTTON_XPATH), current_status, timeout)
        status = dbg.get_attribute_by_xpath(_BTS_LOCK_UNLOCK_BUTTON_XPATH, "a-title")
    finally:
        if selenium_coam is None:
            selenium_coam_conn.logout()
    return status


def click_reset_site_and_cancel(selenium_coam=None, timeout=60, virtual_enable=False, browser='Chrome'):
    """
    click_reset_site_and_cancel function,
    Click "Reset Site" in WebEM and then click "Cancel"
    :param selenium_coam: selenium sbts object
    :param timeout: Timeout value for selenium operation
    :param virtual_enable: selenium virtual enable flag
    """
    if selenium_coam is None:
        selenium_coam_conn = setup_sbts_selenium_and_login(virtual_enable=virtual_enable, browser=browser)
    else:
        selenium_coam_conn = selenium_coam
    try:
        conn = selenium_coam_conn.store.get()
        page = conn.configuration.parameter_editor._view_panel
        wd = page.driver
        wait = Wait(wd, timeout)
        xpath_reset_site_button = "//reset-site-button//ui-button"
        wd.find_element(By.XPATH, xpath_reset_site_button).click()
        logger.info("Reset site button clicked")
        xpath_traffic_interruption_div = "//common-modal//div[contains(text(), 'interruption in traffic')]"
        wait.until(EC.visibility_of_element_located((By.XPATH, xpath_traffic_interruption_div)))
        xpath_cancel_button = "//ui-button[@a-text='Cancel']"
        wd.find_element(By.XPATH, xpath_cancel_button).click()
        logger.info("Cancel button clicked")
    finally:
        if selenium_coam is None and selenium_coam_conn is not None:
            selenium_coam_conn.logout()
            if virtual_enable:
                selenium_coam_conn.disable_virtual_display()
