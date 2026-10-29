import time
import re
from moler.util.moler_test import MolerTest
from taf.sbts.oam.coam.admin import admin
from taf.ul.sc.asimgr import AsiMgr
from robot.api import logger
from pprint import pprint
from json import loads, dumps
from datetime import datetime
from dateutil import tz
from xml.dom.minidom import parse
from taf.internal.sbts.admin.exceptions.exception import AdminApiConnectionClosedException
from functools import reduce


def _compare_status(dict_id_and_status, dict_expected_status):
    dict_check_result = {'check_result': True, 'check_details': {}}
    for id, status in dict_id_and_status.items():
        if status is None:
            dict_check_result['check_result'] = False
            dict_check_result['check_details'][id] = None
            continue
        if not dict_expected_status:
            continue
        for k, expected_value in dict_expected_status.items():
            real_value = status.get(k)
            if k.lower() == 'availabilityStatus'.lower() and not real_value:
                real_value = 'online'
            if real_value.strip().lower().replace(' ', '') != expected_value.strip().lower().replace(' ', ''):
                dict_check_result['check_result'] = False
                if not dict_check_result['check_details'].get(id):
                    dict_check_result['check_details'][id] = {}
                dict_check_result['check_details'][id][k] = {'real': real_value, 'expected': expected_value}

    return dict_check_result


def _moler_test_console(cause, instance_id, mode='info', result=None):
    if result is True:
        info = 'Trigger {} of {}, {}...'.format(cause, instance_id, 'Success')
        MolerTest.info(info)
    elif result is False:
        info = 'Trigger {} of {}, {}...'.format(cause, instance_id, 'Failed')
        MolerTest.error(info)
    else:
        if mode == 'info':
            info = 'Trigger {} of {}....'.format(cause, instance_id)
            MolerTest.info(info)


def _find_key_value_in_dict(dict_info, key, value):
    for keys, values in dict_info.items():
        if str(keys) == str(key) and str(values) == str(value):
            return True
        else:
            if type(values) is dict:
                ret = _find_key_value_in_dict(values, key, value)
                if ret is True:
                    return True
    return False


def _get_bb_status(adm, connection):
    bb_list = []
    try:
        bb_info = adm.get_fbb_info(connection=connection)
        if len(bb_info):
            for i in bb_info:
                tmp_dict = {'operationalState': re.sub(r'\s+', '', str(i['status']['operationalState'])).lower(),
                            'availabilityStatus': re.sub(r'\s+', '', str(i['status'].get('availabilityStatus',
                                                                                         'online'))).lower(),
                            'proceduralStatus': re.sub(r'\s+', '', str(i['status']['proceduralStatus'])).lower(),
                            'administrativeState': re.sub(r'\s+', '', str(
                                i['status']['administrativeState'])).lower(),
                            'usageState': re.sub(r'\s+', '', str(i['status']['usageState'])).lower(),
                            'internal_id': str(
                                re.search(r'.*MRBTS-.*BBMOD_R-\d+', i['id']['internal'], re.M | re.I).group())}
                try:
                    instance_id = int(
                        re.search(r'.*MRBTS-.*BBMOD-(\d+?)', i['id']['configuration'], re.M | re.I).groups()[0])
                    tmp_dict['instance_id'] = instance_id
                    configuration_id = str(
                        re.search(r'.*MRBTS-.*BBMOD-\d+', i['id']['configuration'], re.M | re.I).group())
                    tmp_dict['configuration_id'] = configuration_id
                except Exception as e:
                    MolerTest.info(str(e))
                    tmp_dict['configuration_id'] = None
                    tmp_dict['instance_id'] = None
                bb_list.append(tmp_dict)
    except Exception as e:
        MolerTest.error(str(e))
    return bb_list


def _format_cablink_extmod(list_info):
    final_list = []
    if list_info:
        for i in list_info:
            status_dict = {}
            for key, value in i.items():
                if type(value) is not dict:
                    status_dict[str(key).lower()] = str(value)
                else:
                    for keys, values in value.items():
                        status_dict[str(keys).lower()] = str(values)
            final_list.append(status_dict)
    return final_list


@MolerTest.raise_background_exceptions(check_steps_end=True)
def check_asirmod_status(asirmod_list=[], expected_status_dict={},
                         oam_ip="192.168.255.129", port=443, connection=None):
    adm = admin()
    if not connection:
        adm.setup_admin(bts_host=oam_ip, bts_port=port)

    asirmod_list = asirmod_list if type(asirmod_list) is list else str(asirmod_list).split()
    dict_asirmod_status = {}
    for id in asirmod_list:
        dict_asirmod_status[str(id)] = None
    try:
        bts_info = adm.get_bts_info(connection=connection)
    finally:
        if not connection:
            adm.teardown_admin()
    raw_asirmod_list = bts_info['radioModules']['asirmod']
    for asirmod in raw_asirmod_list:
        id = asirmod['id']['configuration'].split('-')[-1]
        if not asirmod_list or str(id) in [str(asir) for asir in asirmod_list]:
            dict_asirmod_status[id] = asirmod['status']
    logger.info("dict_status:{}".format(dict_asirmod_status), also_console=True)
    compare_res = _compare_status(dict_asirmod_status, expected_status_dict)
    if not compare_res['check_result']:
        MolerTest.error("Status check result: {}".format(compare_res))
    MolerTest.steps_end()


@MolerTest.raise_background_exceptions(check_steps_end=True)
def check_sbts_cell_status(cell_list=None, bbmod_id_list=None, expected_status_dict={}, oam_ip="192.168.255.129",
                           port=443, connection=None):
    if not cell_list:
        cell_list = []

    if type(cell_list) is str:
        cell_list = cell_list.split()

    adm = admin()
    if not connection:
        adm.setup_admin(bts_host=oam_ip, bts_port=port)

    dict_cell_status = {}
    try:
        if bbmod_id_list:
            cell_list = []
            bbmod_ids = bbmod_id_list if type(bbmod_id_list) is list else str(bbmod_id_list).split()
            for nrcell in adm.get_managed_objects(class_name="NRCELL_R", timeout=10, connection=connection):
                for bb in nrcell['parameters']['modDNList']:
                    if bb.split('-')[-1] in bbmod_ids:
                        cid = adm.get_cell_specific_info(cell_id=nrcell['distName'], connection=connection)[
                            'globalCellId']
                        if str(cid) not in cell_list:
                            cell_list.append(str(cid))

        if type(cell_list) is list:
            for cell_type in ["lte", "wcdma", "gsm", "nr"]:
                for cell_info in adm.get_cells_info(cell_type=cell_type, connection=connection):
                    if not cell_list or str(cell_info['globalCellId']) in [str(cell) for cell in cell_list]:
                        dict_cell_status[str(cell_info['id']['configuration'])] = cell_info['status']
        else:
            for k_rat, v_id in cell_list.items():
                for cell_info in adm.get_cells_info(cell_type=k_rat.lower(), connection=connection):
                    if type(v_id) is list:
                        if str(cell_info['globalCellId']) in [str(cell) for cell in v_id]:
                            dict_cell_status[str(cell_info['id']['configuration'])] = cell_info['status']
                    else:
                        if str(v_id) == str(cell_info['globalCellId']):
                            dict_cell_status[str(cell_info['id']['configuration'])] = cell_info['status']

    finally:
        if not connection:
            adm.teardown_admin()
    pprint(dict_cell_status)
    if not dict_cell_status:
        MolerTest.error("Get cell status result: {}".format(dict_cell_status))

    compare_res = _compare_status(dict_cell_status, expected_status_dict)
    if not compare_res['check_result']:
        MolerTest.error("Status check result: {}".format(compare_res))
    MolerTest.steps_end()


def _verify_faults(all_fault_id_list, forbidden_fault_id_list, allowed_fault_id_list, required_fault_id_list):
    result_dict = {'all_fault_id_list': all_fault_id_list}
    all_fault_id_set = set(all_fault_id_list)
    prefixes = ['forbidden', 'allowed', 'required']
    result_dict['check_result'] = True

    if allowed_fault_id_list:
        allowed_fault_id_list = (allowed_fault_id_list if type(allowed_fault_id_list) is list
                                 else str(allowed_fault_id_list).split()) + \
                                (required_fault_id_list if type(required_fault_id_list) is list
                                 else str(required_fault_id_list).split())

    for i, v in enumerate([forbidden_fault_id_list, allowed_fault_id_list, required_fault_id_list]):
        if v is not None:
            v = v if type(v) is list else str(v).split()
            set_v = set(v)
            if prefixes[i] == 'forbidden':
                result_dict[prefixes[i] + '_failures'] = list(all_fault_id_set.intersection(set_v))
            elif prefixes[i] == 'allowed':
                result_dict[prefixes[i] + '_failures'] = list(all_fault_id_set - set_v)
            elif prefixes[i] == 'required':
                result_dict[prefixes[i] + '_failures'] = list(set_v - all_fault_id_set)

            if result_dict[prefixes[i] + '_failures']:
                result_dict['check_result'] = False
    return result_dict


@MolerTest.raise_background_exceptions(check_steps_end=True)
def check_sbts_active_alarm(forbidden_fault_id_list=None, allowed_fault_id_list=None, required_fault_id_list=None,
                            oam_ip="192.168.255.129", connection=None):
    adm = admin()
    if not connection:
        setup_connection = False
        for i in range(5):
            try:
                adm.setup_admin(bts_host=oam_ip)
                setup_connection = True
                break
            except AdminApiConnectionClosedException:
                time.sleep(5)
        if not setup_connection:
            raise ConnectionError
    try:
        all_fault_id_list = [str(alarm['faultId']) for alarm in adm.get_active_alarms(connection=connection)]
    finally:
        if not connection:
            adm.teardown_admin()

    result_dict = _verify_faults(all_fault_id_list, forbidden_fault_id_list, allowed_fault_id_list,
                                 required_fault_id_list)
    if not result_dict['check_result']:
        MolerTest.error("Status check result: {}".format(result_dict))
    MolerTest.steps_end()


def _oper_sbts_cell(oper, cell_list=None, oam_ip="192.168.255.129", connection=None):
    if not cell_list:
        cell_list = []

    if type(cell_list) is str:
        cell_list = cell_list.split()

    adm = admin()
    if not connection:
        adm.setup_admin(bts_host=oam_ip)

    dict_cell_dist_name = {}
    try:
        if type(cell_list) is list:
            for cell_type in ["lte", "wcdma", "gsm", "nr"]:
                for cell_info in adm.get_cells_info(cell_type=cell_type, connection=connection):
                    if not cell_list or str(cell_info['globalCellId']) in [str(cell) for cell in cell_list]:
                        dict_cell_dist_name[str(cell_info['id']['configuration'])] = cell_info['id']['internal']
        else:
            for k_rat, v_id in cell_list.items():
                for cell_info in adm.get_cells_info(cell_type=k_rat.lower(), connection=connection):
                    if type(v_id) is list:
                        if str(cell_info['globalCellId']) in [str(cell) for cell in v_id]:
                            dict_cell_dist_name[str(cell_info['id']['configuration'])] = cell_info['id']['internal']
                    else:
                        if str(v_id) == str(cell_info['globalCellId']):
                            dict_cell_dist_name[str(cell_info['id']['configuration'])] = cell_info['id']['internal']

        logger.info("cell info: {}".format(dict_cell_dist_name), also_console=True)
        for cell_id, dist_name in dict_cell_dist_name.items():
            logger.info("{} cell {} dist_name: {}".format(oper, cell_id, dist_name), also_console=True)
            if 'block' == oper.lower():
                adm.block_cell(dist_name=dist_name, connection=connection)
            elif 'unblock' == oper.lower():
                adm.unblock_cell(dist_name=dist_name, connection=connection)
            else:
                raise Exception('operation not supported')
    finally:
        if not connection:
            adm.teardown_admin()


def block_sbts_cell(cell_list=[], oam_ip="192.168.255.129", connection=None):
    _oper_sbts_cell(oper='block', cell_list=cell_list, oam_ip=oam_ip, connection=connection)


def unblock_sbts_cell(cell_list=[], oam_ip="192.168.255.129", connection=None):
    _oper_sbts_cell(oper='unblock', cell_list=cell_list, oam_ip=oam_ip, connection=connection)


@MolerTest.raise_background_exceptions(check_steps_end=True)
def check_sbts_history_alarm(forbidden_fault_id_list=None, allowed_fault_id_list=None, required_fault_id_list=None,
                             oam_ip="192.168.255.129", connection=None, appeared_time_later_than=None):
    adm = admin()
    if not connection:
        adm.setup_admin(bts_host=oam_ip)
    try:
        his_alarms = []
        for alarm in adm.get_historic_alarms(connection=connection, timeout=120, load_history=True):
            if alarm['disappearTime'] / 1000 >= appeared_time_later_than:
                his_alarms.append(str(alarm['faultId']))
    finally:
        if not connection:
            adm.teardown_admin()

    MolerTest.info("History alarms retrieved are: {}".format(his_alarms))
    result_dict = _verify_faults(his_alarms, forbidden_fault_id_list, allowed_fault_id_list, required_fault_id_list)
    MolerTest.info("_verify_faults result: {}".format(result_dict))
    if not result_dict['check_result']:
        MolerTest.error("Status check result: {}".format(result_dict))
    MolerTest.steps_end()


@MolerTest.raise_background_exceptions(check_steps_end=True)
def get_asir_alarm(alarm_type="active", device_name="GNB0_ASIMGR", pw="Nemuadmin:nemuuser", ne="192.168.255.129"):
    """
    Get alarms (active or cleared) from ASiR WebEM.

    :param str alarm_type: alarm type: active or cleared (history alarm).
    :param str device_name: default is "GNB0_ASIMGR"
    :param str pw: account and password
    :param str ne: ip address
    """
    asimgr = AsiMgr(device_name=device_name, pw=pw, ne=ne, autoconnect=True)
    alarms_ordered_dict = asimgr.get_alarms_file_content()
    alarms_dict = loads(dumps(alarms_ordered_dict))
    report_items = alarms_dict.get('faultReport')
    alarms_list = []
    for ri in report_items:
        if type(ri) is dict:
            fault_object = ri.get('fault')
            if fault_object and type(fault_object) is list:
                alarms_list = list(filter(lambda dict_elem: dict_elem.get('faultState') == alarm_type, fault_object))
            if fault_object and type(fault_object) is dict and fault_object.get('faultState') == alarm_type:
                alarms_list = [fault_object]

    MolerTest.info("All {} alarms retrieved from ASiR are: {}".format(alarm_type, alarms_list))
    MolerTest.steps_end()
    return alarms_list


@MolerTest.raise_background_exceptions(check_steps_end=True)
def check_asir_history_alarm(appeared_time_later_than, device_name="GNB0_ASIMGR",
                             pw="Nemuadmin:nemuuser", ne="192.168.255.129",
                             forbidden_fault_id_list=None, allowed_fault_id_list=None, required_fault_id_list=None):
    """
    Check ASiR WebEM history alarms that have been raised since the given timestamp.
    Refer to example below about how to use this keyword:

    *** Test Cases ***
    [23] Verify ASiR History Alarm
        ${start_time}  DateTime.Get Current Date  result_format=epoch  exclude_millis=True
        Block Ants  1
        Wait Until Keyword Succeeds  2min  10s  Check Ant Status  1  operationalState=disabled
        Unblock Ants  1
        Wait Until Keyword Succeeds  2min  10s  Check Ant Status  1  operationalState=enabled
        Check ASiR History Alarm  appeared_time_later_than=${start_time}  allowed_fault_id_list=4348
        ....    required_fault_id_list=4348

    By default, alarm parameter is list, but also support str that elements are separated by a space.
    Please refer to Examples

    :param float appeared_time_later_than: Epoch time (Epoch time is the time in seconds since the UNIX epoch
                  i.e. 00:00:00.000 (UTC) 1 January 1970.) Refer to below example to get Epoch time:
    :param str device_name: Depends on the test line configuration, the possible values could be "GNB0_ASIMGR",
                  "ENB0_ASIMGR". Default is "GNB0_ASIMGR".
    :param str pw: account and password
    :param str ne: ip address
    :param list[int] forbidden_fault_id_list: list of fault IDs that should not appear
    :param list[int] allowed_fault_id_list: list of fault IDs that are allowed to appear
    :param list[int] required_fault_id_list: list of fault IDs that must appear
    :return None
    """
    history_alarm_list = get_asir_alarm(alarm_type="cleared", device_name=device_name, pw=pw, ne=ne)

    def _convert_utc_to_local_tz(utc_time):
        from_zone = tz.tzutc()
        to_zone = tz.tzlocal()
        utc = datetime.strptime(utc_time, "%Y-%m-%dT%H:%M:%S.%fZ")
        utc = utc.replace(tzinfo=from_zone)
        central = utc.astimezone(to_zone)
        return time.mktime(central.timetuple())

    delta_alarm_list = [elem for elem in history_alarm_list
                        if _convert_utc_to_local_tz(elem.get("timeStarted")) >= appeared_time_later_than]

    MolerTest.info("Total {} history alarm(s). {} alarm(s) raised after {}".format(
        len(history_alarm_list), len(delta_alarm_list),
        time.strftime("%Y-%m-%d %H:%M:%S", time.localtime(appeared_time_later_than))))
    MolerTest.info("Delta alarm(s): {}".format(delta_alarm_list))

    delta_alarm_id_list = [str(alarm['faultId']) for alarm in delta_alarm_list]

    result_dict = _verify_faults(delta_alarm_id_list, forbidden_fault_id_list, allowed_fault_id_list,
                                 required_fault_id_list)
    MolerTest.info("_verify_faults result: {}".format(result_dict))

    if not result_dict['check_result']:
        MolerTest.error("Status check result: {}".format(result_dict))

    MolerTest.steps_end()


def _operate_antmod(operation, ant_list=[], device_name="GNB0_ASIMGR",
                    pw="Nemuadmin:nemuuser", ne="192.168.255.129"):
    all_ant_list = _get_antmod_id_list(device_name=device_name, pw=pw, ne=ne)
    logger.info("All available Ant Mod ID : {0}".format(all_ant_list))

    ant_list = ant_list if type(ant_list) is list else str(ant_list).split()
    logger.info("To be {0}ed Ant ID : {1}".format(operation, ant_list))

    asir_mgr = AsiMgr(device_name=device_name, pw=pw, ne=ne)
    asir_mgr.connect_to_asimgr()

    if operation.lower() not in ['block', 'unblock', 'reset']:
        raise Exception("operation {0} is not supported.".format(operation))

    for ant_id in all_ant_list:
        if not ant_list or ant_id in ant_list:
            logger.info("{0} ANTMOD-{1}".format(operation, ant_id), also_console=True)
            if operation.lower() == 'block':
                result = asir_mgr.block_ant(number=ant_id)
            elif operation.lower() == 'unblock':
                result = asir_mgr.unblock_ant(number=ant_id)
            else:
                result = asir_mgr.reset_asirant(number_of_ant=ant_id)
            logger.info("{0} ANTMOD-{1} result: {2}".format(operation, ant_id, result), also_console=True)


def block_antmod(ant_list=[], device_name="GNB0_ASIMGR", pw="Nemuadmin:nemuuser", ne="192.168.255.129"):
    _operate_antmod(operation='block', ant_list=ant_list, device_name=device_name, pw=pw, ne=ne)


def unblock_antmod(ant_list=[], device_name="GNB0_ASIMGR", pw="Nemuadmin:nemuuser", ne="192.168.255.129"):
    _operate_antmod(operation='unblock', ant_list=ant_list, device_name=device_name, pw=pw, ne=ne)


@MolerTest.raise_background_exceptions(check_steps_end=True)
def check_antmod_status(ant_list=[], expected_status_dict={}, device_name="GNB0_ASIMGR",
                        pw="Nemuadmin:nemuuser", ne="192.168.255.129"):
    all_ant_raw_status = AsiMgr(autoconnect=True, device_name=device_name, pw=pw, ne=ne).get_all_ants_status()
    all_ant_status = _convert_orderdict_to_list_status(all_ant_raw_status)
    logger.info("All Ant Module status : {0}".format(all_ant_status))

    ant_list = ant_list if type(ant_list) is list else str(ant_list).split()
    logger.info("Check Ant ID : {0} Status".format(ant_list))

    dict_antmod_status = {}
    for index in ant_list:
        dict_antmod_status[str(index)] = None

    for ant in all_ant_status:
        if not ant_list or ant.get('status').get('configDN').split('-')[-1] in ant_list:
            dict_antmod_status[ant.get('status').get('configDN').split('-')[-1]] = ant.get('status')

    logger.info("Ant Module {0} dict status : {1}".format(ant_list, dict_antmod_status))

    compare_result = _compare_status(dict_antmod_status, expected_status_dict)
    if not compare_result['check_result']:
        MolerTest.error("Ant Module status check result: {}".format(compare_result))
    MolerTest.steps_end()


def _get_antmod_id_list(hub_id=None, device_name="GNB0_ASIMGR", pw="Nemuadmin:nemuuser", ne="192.168.255.129"):
    hw_inventory_info = AsiMgr(autoconnect=True, device_name=device_name,
                               pw=pw, ne=ne).get_asi_hw_data_based_on_commissioning()
    logger.info("ASIR Module HW inventory info : {0}".format(hw_inventory_info))
    ant_mod_id_list = []
    for hub in hw_inventory_info:
        if hub_id is None or hub['@id'] == str(hub_id):
            ant_mod_id_list = ant_mod_id_list + [ant['configDN'] for ant in hub['ANTMOD_R']]
    return ant_mod_id_list


def _convert_orderdict_to_list_status(ordered_dict):
    raw_list = loads(dumps(ordered_dict)).get('raml').get('cmData').get('managedObject')
    list_items = []
    for raw_item in raw_list:
        list_raw_item_status = raw_item.get('p')
        item_status = {}
        for raw_item_status in list_raw_item_status:
            if raw_item.get('@name') == 'availabilityStatus':
                continue
            item_status[raw_item_status.get('@name')] = raw_item_status.get('#text')

        list_items.append({'distName': raw_item.get('@distName'),
                           'class': raw_item.get('class'),
                           'status': item_status})
    return list_items


def _operate_asirmod(operation, asir_list=[], oam_ip="192.168.255.129", connection=None):
    """
    Internal method _operate_asirmod
    Do operation on given ASIR Module.
    :param operation: operation type, lock or unlock
    :param asir_list: list of ASIR Mod IDs
    :param oam_ip: OAM IP for ssh to BTS station
    :param connection: the connection alias if using an existing OAM connection
    """
    adm = admin()
    if not connection:
        adm.setup_admin(bts_host=oam_ip)

    asir_list = asir_list if type(asir_list) is list else str(asir_list).split()
    dict_asir_dist_name = {}
    for asir_id in asir_list:
        dict_asir_dist_name[str(asir_id)] = None

    if operation.lower() not in ['lock', 'unlock']:
        raise Exception("operation {0} is not supported.".format(operation))

    try:
        bts_info = adm.get_bts_info(connection=connection)
        for asir_item in bts_info['radioModules']['asirmod']:
            asir_sub_item = asir_item['id']['configuration']
            if not asir_list or asir_sub_item.split('-')[-1] in asir_list:
                dict_asir_dist_name[asir_sub_item.split('-')[-1]] = asir_sub_item
        logger.info("ASIR Module dist name dict: {0}".format(dict_asir_dist_name))

        for asir_id, dist_name in dict_asir_dist_name.items():
            logger.info("{0} ASIRMOD {1}".format(operation, asir_id), also_console=True)
            para_value = 'Locked' if operation.lower() == 'lock' else "Unlocked"

            result = adm.perform_parameter_recommissioning(dist_name=dist_name,
                                                           parameter="administrativeState",
                                                           operation='update',
                                                           value=para_value,
                                                           skip_parameter_relation_errors=True,
                                                           connection=connection)

            logger.info("{0} operation result : {1}".format(operation, result), also_console=True)
            nidd_validation_result = result.get('validationResult', {}).get(
                'niddValidationResult', {}).get('status')
            pdl_validation_result = result.get('validationResult', {}).get('pdlValidationResult', {}).get('status')
            activation_result = result.get('commissioningResult', {}).get('activationResult', {}). \
                get('resultNode', {}).get('parameters', {}).get('result')

            if nidd_validation_result.lower() != 'ok':
                raise Exception("NIDD Validation failed due to {}".format(
                    result.get('validationResult', {}).get('niddValidationResult', {}).get('logs')))
            if pdl_validation_result.lower() != 'ok':
                raise Exception("PDL Validation failed due to {}".format(
                    result.get('validationResult', {}).get('pdlValidationResult', {}).get('logs')))
            if activation_result.lower() != 'success':
                raise Exception("Activation failed due to {}".format(
                    result.get('commissioningResult', {}).get('activationResult', {}).get('resultNode', {}).get(
                        'parameters')))

    except Exception as e:
        raise Exception(str(e))

    finally:
        if not connection:
            adm.teardown_admin()


def lock_asirmod(asir_list=[], oam_ip="192.168.255.129", connection=None):
    _operate_asirmod(operation='Lock', asir_list=asir_list, oam_ip=oam_ip, connection=connection)


def unlock_asirmod(asir_list=[], oam_ip="192.168.255.129", connection=None):
    _operate_asirmod(operation='Unlock', asir_list=asir_list, oam_ip=oam_ip, connection=connection)


@MolerTest.raise_background_exceptions(check_steps_end=True)
def check_hubmod_status(hub_id_list=[], expected_status_dict={}, device_name="GNB0_ASIMGR",
                        pw="Nemuadmin:nemuuser", ne="192.168.255.129"):
    all_hub_raw_status = AsiMgr(autoconnect=True, device_name=device_name, pw=pw, ne=ne).get_all_hubs_status()
    all_hub_status = _convert_orderdict_to_list_status(all_hub_raw_status)
    logger.info("All Hub Module status : {0}".format(all_hub_status))

    hubmod_list = hub_id_list if type(hub_id_list) is list else str(hub_id_list).split()
    logger.info("Check Hub ID : {0} status".format(hubmod_list))

    dict_hubmod_status = {}
    for index in hubmod_list:
        dict_hubmod_status[str(index)] = None

    for hub in all_hub_status:
        if not hubmod_list or hub.get('status').get('configDN').split('-')[-1] in hubmod_list:
            dict_hubmod_status[hub.get('status').get('configDN').split('-')[-1]] = hub.get('status')

    logger.info("Hub Module {0} dict status : {1}".format(hubmod_list, dict_hubmod_status))

    compare_result = _compare_status(dict_hubmod_status, expected_status_dict)
    if not compare_result['check_result']:
        MolerTest.error("Hub Module status check result: {}".format(compare_result))
    MolerTest.steps_end()


@MolerTest.raise_background_exceptions(check_steps_end=True)
def check_asir_active_alarm(device_name="GNB0_ASIMGR", pw="Nemuadmin:nemuuser", ne="192.168.255.129",
                            forbidden_fault_id_list=None,
                            allowed_fault_id_list=None,
                            required_fault_id_list=None):
    """
    Keyword check_asir_active_alarm
    Get ASIR active alarms and check if the alarms match given 3 conditions, forbidden/allowed/required,
    If the condition fault ID list is not provided or None, the keyword will skip the check

    :param device_name: Supply device_name with value GNB0_ASIMGR (by default)
    for 5G ASiR, or ENB0_ASIMGR for 4G ASiR.
    :param str pw: account and password
    :param str ne: ip address
    Note that the number followed by GNB or ENB indicates the order in which the gNB/eNB is defined in the testline
    configuration file (tl.gnbs or tl.enbs of __init__.py). 0 means 1st element and 1 means 2nd element, and so on.

    By default, alarm parameter is list, but also support str that elements are separated by a space.
    Please refer to Examples

    :param forbidden_fault_id_list: list of fault IDs that should not appear
    :param allowed_fault_id_list: list of fault IDs that are allowed to appear
    :param required_fault_id_list: list of fault IDs that must appear
    :return: dictionary of check result

    Examples:
    Example 1: set allowed_fault_id_list to ${NULL}, that means all faults allowed
    | check_asir_active_alarm | allowed_fault_id_list=${Null} |
    or
    | check_asir_active_alarm  |

    Example 2: set allowed_fault_id_list to empty string or list, that means no faults allowed
    | check_sbts_alarm  allowed_fault_id_list='' |

    Example 3: check 5G active alarm '61649', '77777' forbidden, '7100', '7300', '4479' allowed, , '61524' required
    | check_asir_active_alarm | forbidden_fault_id_list=61649 77777 | allowed_fault_id_list=7100 7300 4479 |
    | ...   required_fault_id_list=61524 |

    Example 5: check 4G active alarm, faults '1234', '1235' forbidden
    | check_asir_active_alarm | device_name="ENB0_ASIMGR" | forbidden_fault_id_list=1234 1235 |
    """
    active_alarm_list = get_asir_alarm(device_name=device_name, pw=pw, ne=ne)
    logger.info("All active alarm list : {0}".format(active_alarm_list))

    active_alarm_id_list = [str(alarm['faultId']) for alarm in active_alarm_list]
    logger.info("All active alarm id list : {0}".format(active_alarm_id_list))

    verify_dict = _verify_faults(active_alarm_id_list, forbidden_fault_id_list, allowed_fault_id_list,
                                 required_fault_id_list)

    if not verify_dict['check_result']:
        MolerTest.error("ASIR active alarm check result: {0}".format(verify_dict))
    MolerTest.steps_end()


def collect_asir_commissioning(device_name="GNB0_ASIMGR", pw="Nemuadmin:nemuuser", ne="192.168.255.129",
                               outputdir="/tmp"):
    """
    Collect ASiR commissioning file and save it under output dir

    :param device_name: Supply device_name with value 'GNB0_ASIMGR' (by default)
    for 5G ASiR, or 'ENB0_ASIMGR' for 4G
    ASiR. The number followed by GNB or ENB indicates the order
    in which the gNB/eNB is defined in the testline. If
    the test line is 5G + 4G configuration and test cases
    running on the VM connected to 5G gNB, and the keyword is
    going to collect 4G ASiR commissioning (means device_name='ENB0_ASIMGR'),
    then the commission file will be saved
    under output dir of VM connected to 4G eNB (not local VM that connected to 5G gNB).
    :param str pw: account and password
    :param str ne: ip address
    :param outputdir: path to commission file.

    :return: Full path including commission file name. For example, /tmp/192.168.255.129_scf.xml
    """
    asimgr = AsiMgr(device_name=device_name, pw=pw, ne=ne, autoconnect=True)

    return asimgr.collect_commissioning_file(outputdir=outputdir)


@MolerTest.raise_background_exceptions(check_steps_end=True)
def check_sbts_cell_status_consistency(asir_commissioning_file_path, oam_ip="192.168.255.129", connection=None,
                                       pw="Nemuadmin:nemuuser", ne="192.168.255.129"):
    """
    Main Function:
            Check Cell Status Consistency between gNB/eNB and ASiR,
            if cell status is consistency in gNB/eNB and ASiR,
            the function is pass, else the function is fail and error info printed.
            Currently only cell status operationalState "enabled/disabled" is taken into account:
            If cell is locked/blocked/initializing/failed, the operationalState is disabled, otherwise is enabled.
            For ASiR cell status, as long as the operationalState of any channel in the cell is enabled, the cell
            operationalState is enabled. otherwise is disabled.
            In other words, the cell operationalState is disabled
            only if the operationalState of all channels in the cell are disabled.

    Limitation:
            Due to 4G site with RF Sharing mode does not have independent ASiR cell status, this keyword can not be
            used for check 4G cells status consistency of RF Sharing mode.

    Arguments:
            :param asir_commissioning_file_path: path to asir commissioning file
            :param oam_ip: OAM IP for ssh to nodeb
            :param connection: the connection alias if using an existing OAM connection
            :param str pw: account and password
            :param str ne: ip address

    Return Value:
            none

    """

    adm = admin()
    if not connection:
        adm.setup_admin(bts_host=oam_ip)

    cell_list = []
    sbts_cell_status = {}
    for id in cell_list:
        sbts_cell_status[str(id)] = None
    try:
        for cell_type in ["lte", "wcdma", "gsm", "nr"]:
            for cell_info in adm.get_cells_info(cell_type=cell_type, connection=connection):
                if not cell_list or str(cell_info['globalCellId']) in [str(cell) for cell in cell_list]:
                    sbts_cell_status[str(cell_info['globalCellId'])] = cell_info['status']
    finally:
        if not connection:
            adm.teardown_admin()
    logger.info("sbts_cell_status:{}".format(sbts_cell_status), also_console=True)

    def _get_cell_status_list_via_asir(path_to_scf):
        dom_tree = parse(path_to_scf)
        root_node = dom_tree.documentElement
        mo_list = root_node.getElementsByTagName("managedObject")
        cells_status_dict = {}
        for mo in mo_list:
            if mo.hasAttribute("class") and 'CELL_R' in mo.getAttribute("class").split(":")[-1]:
                elements_p = mo.getElementsByTagName("p")
                for elem in elements_p:
                    if elem.getAttribute("name") == 'configDN':
                        configDN_splits = elem.firstChild.nodeValue.split('/')
                        if 'BTS-1' in configDN_splits:
                            logger.info("configDN found BTS-1")
                            break
                else:
                    continue
                for elem in elements_p:
                    if elem.getAttribute("name") == 'lnCelId':
                        cell_id = int(elem.firstChild.nodeValue)
                        cell_r_dist_name = mo.getAttribute('distName')
                        cell_r = cell_r_dist_name.split('/')[-1]
                        cells_status_dict[cell_id] = {'globalCellId': cell_id, 'cell_r': cell_r,
                                                      'dist_name': cell_r_dist_name, 'channels': {}}
                        break

        for mo in mo_list:
            if mo.hasAttribute("class") and 'CHANNEL_R' in mo.getAttribute("class").split(":")[-1]:
                channel_r_dist_name = mo.getAttribute('distName')
                logger.info("channel_r_dist_name: {}".format(channel_r_dist_name))
                channel_r_cell_r = None
                for s in channel_r_dist_name.split('/'):
                    if s.startswith('CELL_R'):
                        channel_r_cell_r = s
                        break
                for v in cells_status_dict.values():
                    logger.info("v: {} {}".format(v.get('dist_name'), v.get('cell_r')))
                    if channel_r_dist_name.startswith(v.get('dist_name')) and channel_r_cell_r == v.get('cell_r'):
                        cell_id = v.get('globalCellId')
                        channel_name = channel_r_dist_name.split('/')[-1]
                        logger.info("cell_id: {} channel_name: {}".format(cell_id, channel_name))
                        for elem_list in mo.getElementsByTagName("list"):
                            elem_list.unlink()
                        elem_p = mo.getElementsByTagName("p")
                        for elem in elem_p:
                            if elem.getAttribute("name") == 'operationalState':
                                channel_operational_state = elem.firstChild.nodeValue
                                cells_status_dict[cell_id]['channels'][channel_name] = channel_operational_state
                                break
                        break
                else:
                    continue
        for cell_id, cell_info in cells_status_dict.items():
            for item in cell_info.get('channels').values():
                if item == 'enabled':
                    cells_status_dict[cell_id]['operationalState'] = 'enabled'
                    break
            else:
                cells_status_dict[cell_id]['operationalState'] = 'disabled'
        return cells_status_dict.values()

    asir_cell_status = _get_cell_status_list_via_asir(asir_commissioning_file_path)
    logger.info("asir_cell_status:{}".format(asir_cell_status), also_console=True)

    status_items = ['operationalState']
    result_dict = {}
    for cell in sbts_cell_status:
        cell_id = int(cell)
        if not result_dict.get(cell_id):
            result_dict[cell_id] = {'operationalState': {}}
        result_dict[cell_id]['operationalState']['sbts'] = sbts_cell_status[cell]['operationalState']

    for cell in asir_cell_status:
        cell_id = cell['globalCellId']
        if not result_dict.get(cell_id):
            result_dict[cell_id] = {'operationalState': {}}
        result_dict[cell_id]['operationalState']['asir'] = cell['operationalState']

    consistent_result = True
    consistent_info = []
    for cell_id, compare_set in result_dict.items():
        for stat_item in status_items:
            sbts_stat_val = compare_set.get(stat_item).get('sbts')
            asir_stat_val = compare_set.get(stat_item).get('asir')
            if str(sbts_stat_val).lower().replace(" ", "") != str(asir_stat_val).lower().replace(" ", ""):
                consistent_info.append('Cell [{}] Status [{}] SBTS Value [{}] ASIR [{}]'.format(
                    cell_id, stat_item, sbts_stat_val, asir_stat_val))
                consistent_result = False
    dict_ret = {'consistent_result': consistent_result,
                'result_dict': result_dict}
    if consistent_info:
        dict_ret['consistent_info'] = consistent_info
    logger.info("consistent check result is:{}".format(dict_ret), also_console=True)

    if not dict_ret['consistent_result']:
        MolerTest.error("Status check result: {}".format(dict_ret['result_dict']))
    MolerTest.steps_end()


def _verify_faults_custom(all_alarm_list, forbidden_fault_filters, allowed_fault_filters, required_fault_filters):
    result_dict = {'all_alarm_list': all_alarm_list, 'check_result': True,
                   'allowed_filters': allowed_fault_filters, 'forbidden_filters': forbidden_fault_filters,
                   'required_filters': required_fault_filters,
                   'forbidden_fail': [], 'allowed_fail': [], 'required_fail': []}

    if required_fault_filters is not None and allowed_fault_filters is not None:
        for f_required in required_fault_filters:
            k_required = set(f_required.keys())
            k_required.discard('count')
            for f_allowed in allowed_fault_filters:
                k_allowed = set(f_allowed.keys())
                k_allowed.discard('count')
                if k_required == k_allowed \
                        and reduce(lambda x, y: x and f_allowed[y] == f_required[y], k_required, True):
                    break
            else:
                f_required_copy = f_required.copy()
                f_required_copy.pop('count', None)
                allowed_fault_filters.append(f_required_copy)

    for alarm in all_alarm_list:
        if allowed_fault_filters is not None:
            for f in allowed_fault_filters:
                k_allowed = set(f.keys())
                k_allowed.discard('count')
                k_allowed.discard('accum_count')
                if reduce(lambda x, y: x and re.search(str(f.get(y)), str(alarm.get(y))), k_allowed, True):
                    if f.get('count') is not None:
                        f['accum_count'] = int(f.get('accum_count', 0)) + 1
                        if int(f['accum_count']) > int(f['count']):
                            result_dict['check_result'] = False
                            result_dict['allowed_fail'].append(alarm)
                    break
            else:
                result_dict['allowed_fail'].append(alarm)
                result_dict['check_result'] = False

        if forbidden_fault_filters is not None:
            for f in forbidden_fault_filters:
                k_forbidden = set(f.keys())
                k_forbidden.discard('count')
                if reduce(lambda x, y: x and re.search(str(f.get(y)), str(alarm.get(y))), k_forbidden, True):
                    result_dict['forbidden_fail'].append(alarm)
                    result_dict['check_result'] = False

        if required_fault_filters is not None:
            for f in required_fault_filters:
                k_required = set(f.keys())
                k_required.discard('count')
                k_required.discard('accum_count')
                if reduce(lambda x, y: x and re.search(str(f.get(y)), str(alarm.get(y))), k_required, True):
                    f["accum_count"] = f.get("accum_count", 0) + 1

    if required_fault_filters is not None:
        for f in required_fault_filters:
            if f.get('count') is None:
                if int(f.get('accum_count', 0)) < 1:
                    result_dict['check_result'] = False
                    result_dict['required_fail'].append(f)
            else:
                if int(f.get('accum_count', 0)) != int(f.get('count', 0)):
                    result_dict['check_result'] = False
                    result_dict['required_fail'].append(f)

    return result_dict


@MolerTest.raise_background_exceptions(check_steps_end=True)
def check_rmod_status(rmod_list=[], expected_status_dict={},
                      oam_ip="192.168.255.129", bts_port=443, connection=None):

    adm = admin()
    if not connection:
        adm.setup_admin(bts_host=oam_ip, bts_port=bts_port)

    rmod_list = rmod_list if type(rmod_list) is list else str(rmod_list).split()
    dict_rmod_status = {}

    try:
        bts_info = adm.get_bts_info(connection=connection)
    finally:
        if not connection:
            adm.teardown_admin()

    for rmod_item in bts_info.get("radioModules").get("rmod"):
        rmod_item_configuration = rmod_item.get("id").get("configuration")
        if not rmod_list or rmod_item_configuration.split("-")[-1] in rmod_list:
            dict_rmod_status[rmod_item_configuration.split("/")[-1]] = rmod_item["status"]

    logger.info("dict_status:{}".format(dict_rmod_status), also_console=True)
    if not dict_rmod_status:
        MolerTest.error("Get rmod result: {}".format(dict_rmod_status))

    compare_res = _compare_status(dict_rmod_status, expected_status_dict)
    if not compare_res['check_result']:
        MolerTest.error("Status check result: {}".format(compare_res))
    MolerTest.steps_end()
