'''
    author: Fuzengz
    contact: fuzeng.zhu@nokia-sbell.com
    Feature: CB005858
'''

from taf.selenium.sbts import *
from collections import OrderedDict
import pprint
from json import loads, dumps
from xml.dom.minidom import parse
from selenium import webdriver
import time
import datetime
from pyvirtualdisplay import Display
from taf.ul.sc.asimgr import *
import threading
from taf.gnb.oam.coam.admin import *
from robot.api import logger
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.support.ui import WebDriverWait as Wait
from selenium.common.exceptions import TimeoutException
import tempfile
import os
import sys
from moler.util.moler_test import MolerTest
from taf.selenium.sbts import sbts
from testsuite.Krakow.resources.NJ_Resources.Resources.python.DevNJ_ASIR_Selenium import *

'''
Function OrderedDict_To_Dict:
tranfer ordered dictionary into plain dictionary, which is easy for read
'''


def OrderedDict_To_Dict(ordered_dict):
    return loads(dumps(ordered_dict))


'''
Function Asir_OrderedDict_Info_To_List_Status:
tranfer hub status from ordered dictionary into plain dictionary, which is easy for processing
'''


def Asir_OrderedDict_Info_To_List_Status(ordered_dict_Hubs):
    raw_list_hubs = OrderedDict_To_Dict(ordered_dict_Hubs).get(
        'raml').get('cmData').get('managedObject')
    print(raw_list_hubs)
    list_hubs = []
    for raw_hub in raw_list_hubs:
        list_raw_hub_status = raw_hub.get('p')
        hub_status = {}
        for raw_hub_status in list_raw_hub_status:
            if raw_hub.get('@name') == 'availabilityStatus':
                continue
            hub_status[raw_hub_status.get(
                '@name')] = raw_hub_status.get('#text')

        list_hubs.append({'distName': raw_hub.get('@distName'),
                          'class': raw_hub.get('class'), 'status': hub_status})
    return list_hubs


'''
Function Get_Check_Hub_Status_Consistency:
Compare the list of HUB status between Gnb and Asir, and return a result dictionary that contains the details
will called by upper robot keyword 'Check Hub Status Consistency'

Parameters example:

    list_gnb_hub_status = [
        {
            u"status": {
                u"administrativeState": u"Unlocked",
                u"operationalState": u"Enabled",
                u"availabilityStatus": u"Online",
                u"proceduralStatus": u"configured",
            },
            u"id": {
                u"internal": u"/MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/EQM_R-4/APEQM_R-1/ASIRMOD_R-2",
                u"configuration": u"MRBTS-3693/EQM-1/APEQM-1/ASIRMOD-2",
                u"runtime": u"MRBTS-3693/EQM_R-4/APEQM_R-1/ASIRMOD_R-2",
            },
        },
        {
            u"status": {
                u"administrativeState": u"Unlocked",
                u"operationalState": u"Enabled",
                u"availabilityStatus": u"Online",
                u"proceduralStatus": u"configured",
            },
            u"id": {
                u"internal": u"/MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/EQM_R-4/APEQM_R-1/ASIRMOD_R-1",
                u"configuration": u"MRBTS-3693/EQM-1/APEQM-1/ASIRMOD-1",
                u"runtime": u"MRBTS-3693/EQM_R-4/APEQM_R-1/ASIRMOD_R-1",
            },
        },
        {
            u"status": {
                u"administrativeState": u"Unlocked",
                u"operationalState": u"Enabled",
                u"availabilityStatus": u"Online",
                u"proceduralStatus": u"configured",
            },
            u"id": {
                u"internal": u"/MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/EQM_R-4/APEQM_R-1/ASIRMOD_R-3",
                u"configuration": u"MRBTS-3693/EQM-1/APEQM-1/ASIRMOD-3",
                u"runtime": u"MRBTS-3693/EQM_R-4/APEQM_R-1/ASIRMOD_R-3",
            },
        },
    ]
    list_asir_hub_status = [
        {
            "status": {
                u"configDN": u"ASI-1/HUBMOD-1",
                u"swState": u"configured",
                u"operationalState": u"enabled",
                u"hwState": u"working",
                u"localState": u"unblocked",
            },
            "distName": u"ASI-1/ASI_R-1/HUBMOD_R-1",
            "class": None,
        },
        {
            "status": {
                u"configDN": u"ASI-1/HUBMOD-2",
                u"swState": u"configured",
                u"operationalState": u"enabled",
                u"hwState": u"working",
                u"localState": u"unblocked",
            },
            "distName": u"ASI-1/ASI_R-1/HUBMOD_R-2",
            "class": None,
        },
        {
            "status": {
                u"configDN": u"ASI-1/HUBMOD-3",
                u"swState": u"configured",
                u"operationalState": u"enabled",
                u"hwState": u"working",
                u"localState": u"unblocked",
            },
            "distName": u"ASI-1/ASI_R-1/HUBMOD_R-3",
            "class": None,
        },
    ]

Return example:

{
    "result_dict": {
        u"1": {
            "administrativeState": {"gnb": u"Unlocked", "asir": u"unblocked"},
            "operationalState": {"gnb": u"Enabled", "asir": u"enabled"},
        },
        u"3": {
            "administrativeState": {"gnb": u"Unlocked", "asir": u"unblocked"},
            "operationalState": {"gnb": u"Enabled", "asir": u"enabled"},
        },
        u"2": {
            "administrativeState": {"gnb": u"Unlocked", "asir": u"unblocked"},
            "operationalState": {"gnb": u"Enabled", "asir": u"enabled"},
        },
    },
    "consistent_result": True,
}
'''


def Get_Check_Hub_Status_Consistency(list_gnb_hub_status, list_asir_hub_status):
    # status_items = ['operationalState',
    #                 'availabilityStatus', 'administrativeState']
    # status_items_asir = ['operationalState',
    #                      'availabilityStatus', 'localState']
    status_items = ['operationalState', 'administrativeState']
    status_items_asir = ['operationalState', 'localState']
    # Because some ASIR status text not same with that of GNB, here give a match rules
    asir_match_rules = {
        # 'availabilityStatus': {'online': None, 'offline': 'not installed'},
        'administrativeState': {'locked': 'blocked', 'unlocked': 'unblocked'}
    }

    def compare_status(status_name, gnb_status, asir_status):
        if str(gnb_status).lower().replace(" ", "") == str(asir_status).lower().replace(" ", ""):
            return True
        if gnb_status:
            # if asir_status and gnb_status.lower() == asir_status.lower():
            #     return True
            if asir_status is None and asir_match_rules.get(status_name) \
                    and asir_match_rules.get(status_name).get(gnb_status.lower()).replace(" ", "") is None:
                return True
            if asir_status is not None and asir_match_rules.get(status_name) \
                    and asir_match_rules.get(status_name).get(gnb_status.lower()).replace(" ", "") == \
                    asir_status.lower().replace(" ", ""):
                return True
            return False
        return False

    result_dict = {}
    for hub in list_gnb_hub_status:
        hub_id = hub['id']['configuration'].split('-')[-1]
        if not result_dict.get(hub_id):
            result_dict[hub_id] = {}
        hub_status = hub['status']
        for stat_item in status_items:
            if not result_dict[hub_id].get(stat_item):
                result_dict[hub_id][stat_item] = {}
            result_dict[hub_id][stat_item]['gnb'] = hub_status[stat_item]

    for hub in list_asir_hub_status:
        hub_id = hub['status']['configDN'].split('-')[-1]
        # Here hub_id represents the meaning of "HUBMOD ID". It needs to be converted to "ASIRMOD ID"
        hub_id = get_asirmod_id_from_hubmod_id(hub_id)
        if not result_dict.get(hub_id):
            result_dict[hub_id] = {}
        hub_status = hub['status']
        for i, stat_item in enumerate(status_items):
            if not result_dict[hub_id].get(stat_item):
                result_dict[hub_id][stat_item] = {}
            result_dict[hub_id][stat_item]['asir'] = hub_status[status_items_asir[i]]

    consistent_result = True
    consistent_info = []
    for hub_id, compare_set in result_dict.items():
        for stat_item in status_items:
            gnb_stat_val = compare_set.get(stat_item).get('gnb')
            asir_stat_val = compare_set.get(stat_item).get('asir')
            res = compare_status(stat_item, gnb_stat_val, asir_stat_val)
            if not res:
                consistent_info.append('Hub [{}] Status [{}] Gnb Value [{}] ASIR [{}]'.format(
                    hub_id, stat_item, gnb_stat_val, asir_stat_val))
                consistent_result = False
    dict_ret = {'consistent_result': consistent_result,
                'result_dict': result_dict}
    if consistent_info:
        dict_ret['consistent_info'] = consistent_info

    return dict_ret


'''
Function Get_Check_Cell_Status:
Compare the list of Cell status between Gnb and Asir, and return a result dictionary that contains the details.
will called by upper robot keyword 'Check Cell Status'
'''


def Get_Check_Cell_Status(list_cell_status, cell_id, dict_check_status):
    check_result = True
    dict_result = {}
    id_found = False
    for cell in list_cell_status:
        if str(cell.get('globalCellId')) == str(cell_id):
            id_found = True
            dict_cell_status = cell.get('status')
            if 'availabilityStatus' not in dict_cell_status or dict_cell_status['availabilityStatus'] == '':
                dict_cell_status['availabilityStatus'] = 'online'
            for k, v in dict_check_status.items():
                if str(dict_cell_status.get(k)).lower().replace(" ", "") != str(v).lower().replace(" ", ""):
                    check_result = False
                    dict_result[k] = {'real_value': str(
                        dict_cell_status.get(k)), 'expected_val': str(v)}
            break
    if id_found:
        return {'check_result': check_result, 'check_info': 'Check successfully' if check_result else 'Check Failed',
                'dict_result': dict_result}

    return {'check_result': False, 'check_info': 'cell not found with id {}'.format(cell_id)}


'''
Function Get_Check_Ant_Status:
Compare the list of Cell status between Gnb and Asir, and return a result dictionary that contains the details.
will called by upper robot keyword 'Check Ant Status'
'''


def Get_Check_Ant_Status(list_ant_status, ant_id, dict_check_status):
    check_result = True
    dict_result = {}
    id_found = False
    for ant in list_ant_status:
        if ant.get('status')['configDN'].split('-')[-1] == str(ant_id):
            id_found = True
            dict_ant_status = ant.get('status')
            for k, v in dict_check_status.items():
                if str(dict_ant_status.get(k)).lower().replace(" ", "") != str(v).lower().replace(" ", ""):
                    check_result = False
                    dict_result[k] = {'real_value': str(
                        dict_ant_status.get(k)), 'expected_val': str(v)}
            break
    if id_found:
        return {'check_result': check_result, 'check_info': 'Check successfully' if check_result else 'Check Failed',
                'dict_result': dict_result}

    return {'check_result': False, 'check_info': 'ant not found with id {}'.format(ant_id)}


'''
Function Get_Check_Hub_Status_Via_Gnb:
Compare the list of HUB status between Gnb and user expected hub,
and return a result dictionary that contains the details.
will called by upper robot keyword 'Check Hub Status Via Gnb'
'''


def Get_Check_Hub_Status_Via_Gnb(list_hub_status, hub_id, dict_check_status):
    check_result = True
    dict_result = {}
    id_found = False
    for hub in list_hub_status:
        if hub.get('id').get('configuration').split('-')[-1] == str(hub_id):
            id_found = True
            dict_hub_status = hub.get('status')
            if 'availabilityStatus' not in dict_hub_status or dict_hub_status['availabilityStatus'] == '':
                dict_hub_status['availabilityStatus'] = 'online'
            for k, v in dict_check_status.items():
                if str(dict_hub_status.get(k)).lower().replace(" ", "") != str(v).lower().replace(" ", ""):
                    check_result = False
                    dict_result[k] = {'real_value': str(
                        dict_hub_status.get(k)), 'expected_val': str(v)}
            break
    if id_found:
        return {'check_result': check_result, 'check_info': 'Check successfully' if check_result else 'Check Failed',
                'dict_result': dict_result}

    return {'check_result': False, 'check_info': 'hub not found with id {}'.format(hub_id)}


'''
Function Get_Check_Hub_Status_Via_ASIR:
Compare the list of HUB status between Asir and user expected hub,
and return a result dictionary that contains the details.
will called by upper robot keyword 'Check Hub Status Via ASIR'
'''


def Get_Check_Hub_Status_Via_ASIR(list_hub_status, hub_id, dict_check_status):
    check_result = True
    dict_result = {}
    id_found = False
    for hub in list_hub_status:
        if hub.get('status')['configDN'].split('-')[-1] == str(hub_id):
            id_found = True
            dict_hub_status = hub.get('status')
            for k, v in dict_check_status.items():
                if str(dict_hub_status.get(k)).lower() != str(v).lower():
                    check_result = False
                    dict_result[k] = {'real_value': str(
                        dict_hub_status.get(k)), 'expected_val': str(v)}
            break
    if id_found:
        return {'check_result': check_result, 'check_info': 'Check successfully' if check_result else 'Check Failed',
                'dict_result': dict_result}

    return {'check_result': False, 'check_info': 'hub not found with id {}'.format(hub_id)}


'''
Function Get_Cell_Status_List_Via_ASIR:
Export and then parse the Runtime SCF file, and pick runtime info about channels in cells
Return a List of cell status, only contains id, administrateState and channel status
'''


def Get_Cell_Status_List_Via_ASIR(path_to_scf):
    domTree = parse(path_to_scf)
    rootNode = domTree.documentElement
    mo_list = rootNode.getElementsByTagName("managedObject")
    cells_status_dict = {}
    # Find the cell ids can mapped to gnb cell ids
    for mo in mo_list:
        if mo.hasAttribute("class") and 'CELL_R' in mo.getAttribute("class").split(":")[-1]:
            elements_p = mo.getElementsByTagName("p")
            for elem in elements_p:
                if elem.getAttribute("name") == 'configDN':
                    logger.info("configDN: {}".format(elem.firstChild.nodeValue))
                    configDN_splits = elem.firstChild.nodeValue.split('/')
                    if 'BTS-1' in configDN_splits:
                        logger.info("configDN found BTS-1")
                        break
            else:
                continue
            # maybe targetLcrId can also be used
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
            channel_r_cell_r = None
            for s in channel_r_dist_name.split('/'):
                if s.startswith('CELL_R'):
                    channel_r_cell_r = s
                    break
            print('channel_r_dist_name {}  channel_r_cell_r {}'.format(channel_r_dist_name, channel_r_cell_r))
            # looking for the lnCelID related Channel
            for v in cells_status_dict.values():
                print('v: {} {}'.format(v.get('dist_name'), v.get('cell_r')))
                # the CHANNEL_R's CELL_R in the dict
                if channel_r_dist_name.startswith(v.get('dist_name')) and channel_r_cell_r == v.get('cell_r'):

                    cell_id = v.get('globalCellId')
                    channel_name = channel_r_dist_name.split('/')[-1]
                    print('cell_id: {} channel_name: {}'.format(cell_id, channel_name))
                    for elem_list in mo.getElementsByTagName("list"):
                        elem_list.unlink()
                    elements_p = mo.getElementsByTagName("p")
                    for elem in elements_p:
                        if elem.getAttribute("name") == 'operationalState':
                            channel_operationalState = elem.firstChild.nodeValue
                            cells_status_dict[cell_id]['channels'][channel_name] = channel_operationalState
                            break
                    break
            else:
                continue
    for cell_id, cell_info in cells_status_dict.items():
        # any channel is enabled, then the cell operational state is enabled, otherwise is disabled
        for item in cell_info.get('channels').values():
            if item == 'enabled':
                cells_status_dict[cell_id]['operationalState'] = 'enabled'
                break
        else:
            cells_status_dict[cell_id]['operationalState'] = 'disabled'
    return cells_status_dict.values()
    # All Same can set locked/unlocked, otherwise keep None
    #     if len(set(cell_info.get('channels').values())) == 1:
    #         cells_status_dict[cell_id]['operationalState'] = 'enabled' if list(cell_info.get(
    #             'channels').values())[0] == 'enabled' else 'disabled'
    # print(cells_status_dict.values())
    # return cells_status_dict.values()


'''
Function Get_Check_Cell_Status_Consistency:
Compare the list of Cell status between Gnb and Asir, and return a result dictionary that contains the details
will called by upper robot keyword 'Check Cell Status Consistency'

    Parameters example:

    list_gnb_cell_status = [
        {
            u'status': {
            u'usageState': u'Active',
            u'proceduralStatus': u'configured',
            u'availabilityStatus': u'Online',
            u'administrativeState': u'Unlocked',
            u'operationalState': u'Enabled',
            u'blockingState': u'Unblocked'
            },
            u'globalCellId': 2,
        },
        {
            u'status': {
            u'usageState': u'Active',
            u'proceduralStatus': u'configured',
            u'availabilityStatus': u'Online',
            u'administrativeState': u'Unlocked',
            u'operationalState': u'Enabled',
            u'blockingState': u'Unblocked'
            },
            u'globalCellId': 1,
        }
    ]
    list_asir_cell_status = [
        {
            "globalCellId": 1,
            "channels": {
            "u'CHANNEL_R-6'": "u'disabled'",
            "u'CHANNEL_R-4'": "u'disabled'",
            "u'CHANNEL_R-5'": "u'disabled'",
            "u'CHANNEL_R-2'": "u'disabled'",
            "u'CHANNEL_R-3'": "u'disabled'",
            "u'CHANNEL_R-1'": "u'disabled'"
            },
            "operationalState": "disabled"
        },
        {
            "globalCellId": 2,
            "channels": {
            "u'CHANNEL_R-6'": "u'enabled'",
            "u'CHANNEL_R-4'": "u'enabled'",
            "u'CHANNEL_R-5'": "u'enabled'",
            "u'CHANNEL_R-2'": "u'enabled'",
            "u'CHANNEL_R-3'": "u'enabled'",
            "u'CHANNEL_R-1'": "u'enabled'"
            },
            "operationalState": "enabled"
        }
    ]


Return example:

    {
        "result_dict": {
            1: {
            "operationalState": {
                "gnb": "u'Enabled'",
                "asir": "enabled"
            }
            },
            2: {
            "operationalState": {
                "gnb": "u'Enabled'",
                "asir": "enabled"
            }
            }
        },
        "consistent_result": "True"
    }
'''


def Get_Check_Cell_Status_Consistency(list_gnb_cell_status, list_asir_cell_status):
    status_items = ['operationalState']
    result_dict = {}
    for cell in list_gnb_cell_status:
        cell_id = cell['globalCellId']
        if not result_dict.get(cell_id):
            result_dict[cell_id] = {'operationalState': {}}
        result_dict[cell_id]['operationalState']['gnb'] = cell['status']['operationalState']

    for cell in list_asir_cell_status:
        cell_id = cell['globalCellId']
        if not result_dict.get(cell_id):
            result_dict[cell_id] = {'operationalState': {}}
        result_dict[cell_id]['operationalState']['asir'] = cell['operationalState']

    consistent_result = True
    consistent_info = []
    for cell_id, compare_set in result_dict.items():
        for stat_item in status_items:
            gnb_stat_val = compare_set.get(stat_item).get('gnb')
            asir_stat_val = compare_set.get(stat_item).get('asir')
            if str(gnb_stat_val).lower().replace(" ", "") != str(asir_stat_val).lower().replace(" ", ""):
                consistent_info.append('Cell [{}] Status [{}] Gnb Value [{}] ASIR [{}]'.format(
                    cell_id, stat_item, gnb_stat_val, asir_stat_val))
                consistent_result = False
    dict_ret = {'consistent_result': consistent_result,
                'result_dict': result_dict}
    if consistent_info:
        dict_ret['consistent_info'] = consistent_info

    return dict_ret


'''
Function Get_Check_Allowed_Or_Required_Alarm_List:
Check a given alarm list, check if all fault ids is in allowed fault id list, and all required fault id appeared
will called by upper robot keyword 'Check Allowed Or Required Alarm List'

Input parameters:
 all_fault_id_list: returned fault Ids list by keywords Get All Active Alarms Via Gnb or Get All Active Alarms Via Asir
 str_allowed_fault_id_list: allowed fault id string, e.g. '61649 61648 6450 61524'
 str_required_fault_id_list: required fault id string, e.g. '6450 61524 12345'

Return:
  Dictionary of check result, user can judege allowed or required result by key 'check_allowed' 'check_required'
  And then check details about not allowed fault id list by key 'unexpected_fault_id_list'
  And then check details about required but not appeared fault id list by key 'missed_fault_id_list'

  key 'all_fault_id_list', 'allowed_alarm_fault_id_list' and 'required_alarm_fault_id_list'
     is the list transferred from input parameter


  Example Return:

  {
    "required_alarm_fault_id_list": [ "6450", "61524", "12345" ],
    "unexpected_fault_id_list": [],
    "missed_fault_id_list": [ "12345" ],
    "all_fault_id_list": [ "6450", "61524", "61648", "61649" ],
    "allowed_alarm_fault_id_list": [ "6450", "61524", "61648", "61649" ],
    "check_required": "False",
    "check_allowed": "True"
  }


'''


def Get_Check_Allowed_Or_Required_Alarm_List(all_fault_id_list, str_allowed_fault_id_list, str_required_fault_id_list):
    result_dict = {}
    all_fault_id_list = [str(x) for x in all_fault_id_list]
    all_fault_id_set = set(all_fault_id_list)
    allowed_alarm_fault_id_set = set(
        [] if str_allowed_fault_id_list == 'null' else str_allowed_fault_id_list.split())
    required_alarm_fault_id_set = set(
        [] if str_required_fault_id_list == 'null' else str_required_fault_id_list.split())

    if not allowed_alarm_fault_id_set:
        allowed_alarm_fault_id_set = all_fault_id_set
    if not required_alarm_fault_id_set:
        required_alarm_fault_id_set = all_fault_id_set

    result_dict['all_fault_id_list'] = list(all_fault_id_set)
    result_dict['allowed_alarm_fault_id_list'] = list(
        allowed_alarm_fault_id_set)
    result_dict['required_alarm_fault_id_list'] = list(
        required_alarm_fault_id_set)

    result_dict['unexpected_fault_id_list'] = list(
        all_fault_id_set - allowed_alarm_fault_id_set)
    result_dict['missed_fault_id_list'] = list(
        required_alarm_fault_id_set - all_fault_id_set)

    result_dict['check_allowed'] = False if result_dict['unexpected_fault_id_list'] else True
    result_dict['check_required'] = False if result_dict['missed_fault_id_list'] else True
    return result_dict


'''
Function Transfer_Activate_Alarms_ASIR:
Transfer the alarms ordered dictionary into plain dictionary
'''


def Transfer_Activate_Alarms_ASIR(alarms_ordered_dict):
    alarms_dict = OrderedDict_To_Dict(alarms_ordered_dict)
    report_items = alarms_dict.get('faultReport')
    active_alarms_list = []
    for ri in report_items:
        if isinstance(ri, dict):
            fault_object = ri.get('fault')
            if fault_object and isinstance(fault_object, list) == list:
                return filter(lambda dict_elem: dict_elem.get('faultState') == 'active', fault_object)
            if fault_object and isinstance(fault_object, dict) and fault_object.get('faultState') == 'active':
                return [fault_object]

    return active_alarms_list


'''
Function Get_BBMOD_Hub_Relation:
Get the dictionary relationship between BBMOD & HUBs
Input parameters:
 dict_bts_info: usually get by taf.gnb.oam.coam.admin Get BTS info method
Return:
 Dictionary of relationship
Return Example:
{
  "BBMOD-1": [ "ASIRMOD-1", "ASIRMOD-2"],
  "BBMOD-2": [ "ASIRMOD-3", "ASIRMOD-4"]
}

'''


def Get_BBMOD_Hub_Relation(dict_bts_info):
    dict_bbmod_asirmod_relation = {}
    list_cables = dict_bts_info.get(u'cables')
    for cable in list_cables:

        bbmod_id = None
        for segment in cable.get('firstEndPointId').get('runtime').split('/'):
            if 'BBMOD' in segment.upper():  # find bbmod and extract its id
                bbmod_id = 'BBMOD-' + segment.split('-')[-1]
                break

        if not bbmod_id:
            continue

        asirmod_id = None
        for segment in cable.get('secondEndPointId').get('runtime').split('/'):
            if 'ASIRMOD' in segment.upper():  # find bbmod and extract its id
                asirmod_id = 'ASIRMOD-' + segment.split('-')[-1]
                break
        if not asirmod_id:
            continue

        if not dict_bbmod_asirmod_relation.get(bbmod_id):
            dict_bbmod_asirmod_relation[bbmod_id] = []
        if asirmod_id not in dict_bbmod_asirmod_relation[bbmod_id]:
            dict_bbmod_asirmod_relation[bbmod_id].append(asirmod_id)

    return dict_bbmod_asirmod_relation


'''
Function Get_Hub_Ids_Of_BBMOD:
Get the string of HUB ids belong to specific BBMOD id
Input parameters:
 dict_bts_info: usually get by taf.gnb.oam.coam.admin Get BTS info method
 bbmod_id: BBmod id, int or string, e.g.  2 or '2'
Return:
 string of Hub ids, ids are seprated by single space , e.g. '3 4', if no HUBs connected, return 'None'

'''


def Get_Hub_Ids_Of_BBMOD(dict_bts_info, bbmod_id):
    dict_bbmod_asirmod_relation = Get_BBMOD_Hub_Relation(dict_bts_info)
    bbmod_long_id = 'BBMOD-' + str(bbmod_id)
    list_hub_long_ids = dict_bbmod_asirmod_relation.get(bbmod_long_id)
    if list_hub_long_ids:
        list_hub_short_ids = [long_id.split('-')[-1] for long_id in list_hub_long_ids]
        return ' '.join(list_hub_short_ids)
    return 'None'


'''
Function Asir_reset_hub:
Reset a HUB via ASIR Manager, by give a ASIRMOD ID
Input parameters:
 asirmod_id:  ASIRMOD ID in Asir Mananger, e.g. 2
 timeout: The timeout seconds, default value is 180 seconds
Return:
 A dictionary of result of the reseting.
 e.g. {'asirmod_id':2, 'res':True, 'state_records':['Enabled','Disabled','Enabled']}

'''


def Asir_reset_hub(asirmod_id, timeout=180):
    timeout = int(timeout)
    hubmod_id = get_hubmod_id_from_asirmod_id(asirmod_id)
    print("asirmod_id: {}, hubmod_id {}".format(asirmod_id, hubmod_id))
    asir_mgr = AsiMgr()
    asir_mgr.connect_to_asimgr()
    oper_state_record = {}
    # Start a thread of function gnb_check_hub_reseting, that polling the operational state of the hub from Gnb Webem
    t = threading.Thread(target=gnb_check_hub_reseting,
                         args=(asirmod_id, oper_state_record, timeout))
    t.start()
    time.sleep(5)
    print("Do reset hub")
    asir_mgr.reset_asirhub(hubmod_id)
    t.join(timeout)
    print('finally oper_state_record:', oper_state_record)
    return oper_state_record


'''
Function gnb_check_hub_reseting:
This function assist function Asir_reset_hub, to check the change of the operational state during the hub reseting
Input parameters:
 hub_id:  HUB ID in Asir Mananger, e.g. 2
 oper_state_record:  A list keep the operation state change during the reset procedure
 timeout: The timeout seconds, default value is 180 seconds

'''


def gnb_check_hub_reseting(asirmod_id, oper_state_record, timeout=180):
    coam = admin()
    coam.connect_to()

    try:
        start_time = time.time()
        i = 0
        oper_state_record['asirmod_id'] = asirmod_id
        oper_state_record['res'] = False
        oper_state_record['state_records'] = []

        while time.time() < start_time + timeout:

            hubs_info_list = coam.get_bts_info().get('radioModules').get('asirmod')

            for hub_info in hubs_info_list:
                # hub found
                if hub_info.get('id').get('configuration').split('-')[-1] == str(asirmod_id):
                    stat = hub_info.get('status').get('operationalState')
                    print(i, 'stat:', stat)
                    if not oper_state_record['state_records'] \
                            or oper_state_record['state_records'][-1] != stat.lower():
                        oper_state_record['state_records'].append(stat.lower())
                        print(i, 'hw_stat:', oper_state_record)
                        if oper_state_record['state_records'][-1] == 'enabled' \
                                and 'disabled' in oper_state_record['state_records']:
                            oper_state_record['res'] = True
                            return
            i = i + 1
            time.sleep(1)
    except Exception:
        pass
    finally:
        coam.teardown()


'''
Function Get_Check_BBMOD_Status:
Compare the list of BBMOD status between Gnb and user expected hub,
and return a result dictionary that contains the details.
will called by upper robot keyword 'Check BBMOD Status'
'''


def Get_Check_BBMOD_Status(list_bbmod_status, bbmod_id, dict_check_status):
    check_result = True
    dict_result = {}
    id_found = False
    for bbmod in list_bbmod_status:
        if bbmod.get('id').get('configuration').split('-')[-1] == str(bbmod_id):
            id_found = True
            dict_bbmod_status = bbmod.get('status')
            if 'availabilityStatus' not in dict_bbmod_status or dict_bbmod_status['availabilityStatus'] == '':
                dict_bbmod_status['availabilityStatus'] = 'online'
            for k, v in dict_check_status.items():
                if str(dict_bbmod_status.get(k)).lower().replace(" ", "") != str(v).lower().replace(" ", ""):
                    check_result = False
                    dict_result[k] = {'real_value': str(
                        dict_bbmod_status.get(k)), 'expected_val': str(v)}
            break
    if id_found:
        return {'check_result': check_result, 'check_info': 'Check successfully' if check_result else 'Check Failed',
                'dict_result': dict_result}

    return {'check_result': False, 'check_info': 'bbmod not found with id {}'.format(bbmod_id)}


'''
Function Get_Check_All_BBMODs_Status:
Compare the list of BBMOD status with dictionary of check status,
and return a result dictionary that contains the details.
will called by upper robot keyword 'Check All BBMODs Status'

Return:
Dictionary of check result.
'''


def Get_Check_All_BBMODs_Status(list_bbmod_status, dict_check_status):
    check_result = True
    dict_result = {}
    if list_bbmod_status:
        for bbmod in list_bbmod_status:
            dict_bbmod_status = bbmod.get('status')
            if 'availabilityStatus' not in dict_bbmod_status or dict_bbmod_status['availabilityStatus'] == '':
                dict_bbmod_status['availabilityStatus'] = 'online'
            for k, v in dict_check_status.items():
                if str(dict_bbmod_status.get(k)).lower().replace(" ", "") != str(v).lower().replace(" ", ""):
                    check_result = False
                    bbmod_runtime_id = bbmod.get('id').get('runtime').split('-')[-1]
                    if not dict_result.get(bbmod_runtime_id):
                        dict_result[bbmod_runtime_id] = {'runtime_id': bbmod_runtime_id}
                    dict_result[bbmod_runtime_id][k] = \
                        {'real_value': str(dict_bbmod_status.get(k)), 'expected_val': str(v)}
    else:
        check_result = False

    return {'check_result': check_result, 'check_info': 'Check successfully' if check_result else 'Check Failed',
            'dict_result': dict_result}


'''
Function Get_Ant_Mod_Id_List:
This function to get all ants mod id of a specified hub id,
 or all ants mod id of all hubs if no hub id given
Input parameters:
 hub_id:  HUB ID in Asir Mananger, e.g. 2
Return:
 List of Ant Mod IDs
 e.g. [1,2]
'''


def Get_Ant_Mod_Id_List(hub_id=None):
    hw_inventory_info = AsiMgr(
        autoconnect=True).get_asi_hw_data_based_on_commissioning()
    logger.info("Hw Inventory Info is: {}".format(hw_inventory_info))
    ant_mod_id_list = []
    for hub in hw_inventory_info:
        if hub_id is None or hub['@id'] == str(hub_id):
            ant_mod_id_list = ant_mod_id_list + \
                              [ant['configDN'] for ant in hub['ANTMOD_R']]
    logger.info("ant_mod_id_list is: {}".format(ant_mod_id_list))
    return ant_mod_id_list


def Get_Ant_Port_Id_List_Of_Specific_Hub(hub_id=1):
    """
    Get ant port ID list

    :param hub_id: hub ID. Default is 1
    :return        list of ant port ID
    :rtype         list
    """
    hw_inventory_info = AsiMgr(autoconnect=True).get_asi_hw_data_based_on_commissioning()
    logger.info("Hw Inventory Info is: {}".format(hw_inventory_info))

    for hub in hw_inventory_info:
        if hub['@id'] == str(hub_id):
            return [int(ant['antPortRDN']) - 1 for ant in hub['ANTMOD_R']]


'''
Function Get_Cell_CellGroup_Relation:
Get the dictionary of relationship between cell and cellgroup.
Input parameters:
 dict_bts_info: usually get by taf.gnb.oam.coam.admin Get BTS info method
 cell_id: Cell id, int or string, e.g.  2 or '2'
Return:
Dictionary of relationship. e.g.
{
    'nrdu_refNrCellGroup_index': 1,
    'cell_id': '2',
    'cell_group_has_other_cell': False,
    'cell_group_id': u'1',
    'nrdu_cellgroup_list_len': 2
}
'''


def Get_Cell_CellGroup_Relation(dict_bts_info, cell_id):
    dict_cell_cellgroup = {'cell_id': None, 'cell_group_has_other_cell': False}
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


def _switch_to_dedicated_tab(wd, tab, timeout=8):
    """
    _switch_to_dedicated_tab function, enter specified tab after keyword _enter_config_man
    :param wd: web driver instance
    :param tab: tab name
    :param timeout: Maximum waiting seconds before clicking the tab's button
    Note: Due to ASIR WebEM GUI is changed, the method of _switch_to_dedicated_tab will be also changed.
          Please DO NOT call _switch_to_dedicated_tab function in this file again, you can refer to
          switch_to_dedicated_tab function in DevNJ_ASIR_Selenium.py file.
    """
    time.sleep(timeout)
    _xpath_tab = "//button[contains(text(), '{}')]".format(tab)
    tab_btn = wd.find_element(By.XPATH, _xpath_tab)
    if 'active' in tab_btn.get_attribute('class'):
        logger.info("tab '{}' is already active".format(tab))

    else:
        tab_btn.click()
        time.sleep(3)
        assert ('active' in tab_btn.get_attribute('class')
                ), "Failed to switch to tab '{}'".format(tab)
        logger.info("tab '{}' is switched to be active".format(tab))


def _import_detected_configuration(wd, mode):
    """
    _import_detected_configuration funciton, click button 'Import Detected Configuration',
    and choose the import mode
    :param wd: web driver instance
    :param mode: complete or incremental
    Note: Please DO NOT call _import_detected_configuration function in this file again, you can refer to
          import_detected_configuration function in DevNJ_ASIR_Selenium.py file.
    """
    assert (mode.lower() in ['complete', 'incremental']
            ), "parameter {} is not valid, should be in ['complete', 'incremental']".format(mode)
    xpath_import_detected_btn = "//button[@id='import-detected-configuration-button']"
    xpath_modal = "//div[@id='configuration-scope-modal']"
    xpath_complete_import_radio = "{}//b[contains(text(),'Complete')]".format(
        xpath_modal)
    xpath_incremental_import_radio = "{}//b[contains(text(),'Incremental')]".format(
        xpath_modal)
    xpath_continue_btn = "{}//button[contains(text(),'Continue')]".format(
        xpath_modal)
    xpath_select_mode = ''
    if mode.lower() == 'complete':
        xpath_select_mode = xpath_complete_import_radio
    elif mode.lower() == 'incremental':
        xpath_select_mode = xpath_incremental_import_radio
    wd.find_element(By.XPATH, xpath_import_detected_btn).click()
    wd.find_element(By.XPATH, xpath_select_mode).click()
    wd.find_element(By.XPATH, xpath_continue_btn).click()


def _enter_config_man(wd, overwrite=True, timeout=5):
    """
    _enter_config_man function, enter configuration manager page after login, usually used in Suite Setup
    :param wd: web driver instance
    :param overwrite: True for overwrite last modification, False for continue with last modification
    :param timeout: Maximum seconds for waiting for the configuration manangement page available
    Note: Please DO NOT call _enter_config_man function in this file again, you can refer to enter_config_man function
          in DevNJ_ASIR_Selenium.py file.
    """
    logger.info("DevNJ_ASIR_Selenium _enter_config_man")
    _xpath_config_man_button = "//*[@href='#/commissioning/cards']"
    _xpath_config_man_start_button = "//*[@id='editCurrentStartButton']"
    _xpath_config_man_overwrite_button = "//div[@id='overwrite-modal']//button[text()='Overwrite']"
    _xpath_config_man_continue_button = "//*[@id='continueCurrentContinueButton']"
    _xpath_config_man_header = "//div[@id='commissioning-header']"
    wd.find_element(By.XPATH, _xpath_config_man_button).click()
    if overwrite:
        wd.find_element(
            By.XPATH, _xpath_config_man_start_button).click()
        time.sleep(2)
        overwrite_btn = wd.find_elements(
            By.XPATH, _xpath_config_man_overwrite_button)
        if overwrite_btn:
            overwrite_btn[0].click()
    else:
        wd.find_element(
            By.XPATH, _xpath_config_man_continue_button).click()

    Wait(wd, timeout).until(EC.visibility_of_element_located(
        (By.XPATH, _xpath_config_man_header)))


def _activate(wd, as_full_configuration=None, timeout=60):
    """
    _activate function, switch to tab 'Activation',
        toggle/untoggle the checkbox 'as_full_configuration', click button 'Activate'
    :param wd: web driver instance
    :param as_full_configuration: None for neglect the Full Configuration checkbox
                                    True for activate as full configuration
                                    False for activate not as full configuration
    :param timeout: waiting timeout seconds for button or dialog apprearance
    Note: Please DO NOT call _activate function in this file again, you can refer to activate function in
          DevNJ_ASIR_Selenium.py file.
    """

    dict_ret = {}
    xpath_activate_btn = "//button[@id='run-activation-btn']"
    xpath_full_checkbox = "//input[@id='activate-as-full-checkbox-input']"
    xpath_full_checkbox_outer = "//mat-checkbox[@id='activate-as-full-checkbox']"
    xpath_validation_modal = "//div[@id='validation-config-error-modal']"
    xpath_validation_modal_close_btn = "{}//button[contains(text(),'Close')]".format(
        xpath_validation_modal)
    xpath_next_btn = "//button[@id='stepper-next-button']"
    xpath_finish_btn = "//button[@id='stepper-finish-button']"

    logger.info('Activate with Full Configuration {}'.format(
        as_full_configuration))
    # User activate regardless the mode
    if as_full_configuration is not None:
        # see if the mode checkbox is disabled or not
        checkbox_mode = wd.find_element(By.XPATH, xpath_full_checkbox)
        checkbox_mode_disabled = 'mat-checkbox-disabled' in checkbox_mode.get_attribute(
            'class').split()

        # if the checkbox is disabled, omit the specified mode
        if not checkbox_mode_disabled:
            logger.info('Activate Mode Checkbox is enabled')
            is_full_checked = checkbox_mode.get_attribute('aria-checked')
            if is_full_checked != str(as_full_configuration).lower():
                logger.info('Change Activate Mode to {}'.format(
                    as_full_configuration))
                wd.find_element(
                    By.XPATH, xpath_full_checkbox_outer).click()
                is_full_checked = checkbox_mode.get_attribute(
                    'aria-checked')
                assert (is_full_checked == str(as_full_configuration).lower()), \
                    'Failed to set full configuration to be {}'.format(
                        as_full_configuration)
            else:
                logger.info('Activation Full configuration is already {}, need not change'.format(
                    is_full_checked))
        else:
            logger.info('Activate Mode Checkbox is disabled')
    else:
        logger.info('Activate without Mode Change')
    is_full_checked = wd.find_element(
        By.XPATH, xpath_full_checkbox).get_attribute('aria-checked')
    logger.info('Activate Mode on Checkbox is {}'.format(is_full_checked))
    wd.find_element(By.XPATH, xpath_activate_btn).click()
    # noinspection PyBroadException
    try:
        modal_validation = wd.find_element(
            By.XPATH, xpath_validation_modal)
    except Exception as e:
        modal_validation = None

    if modal_validation is None:
        dict_ret['ret'] = True
        wait = Wait(wd, timeout)
        if is_full_checked == 'true':  # full need next and finish
            next_btn = wait.until(
                EC.element_to_be_clickable((By.XPATH, xpath_next_btn)))
            next_btn.click()

        finish_btn = None
        try:
            finish_btn = wait.until(
                EC.element_to_be_clickable((By.XPATH, xpath_finish_btn)))
        except Exception as e:
            screenshot_name = 'activate_finish_button_not_clickable.png'
            logger.warn('Finish button not clickable in {} seconds, screenshot:{}'.format(
                timeout, screenshot_name))

        if finish_btn:
            tm_start = time.time()
            while time.time() < tm_start + timeout:
                try:
                    finish_btn.click()
                    logger.info('Finish Button clicked')
                    break
                except Exception as e:
                    logger.error(str(e))
                    time.sleep(1)
            else:
                screenshot_name = 'activate_finish_button_not_clicked.png'
                logger.warn('Finish button not clicked in {} seconds, screenshot:{}'.format(
                    timeout, screenshot_name))

    else:
        dict_ret['ret'] = False
        dict_ret['info'] = wd.find_element(
            By.XPATH, "{}//div[@class='content']".format(xpath_validation_modal)).text
        wd.find_element(
            By.XPATH, xpath_validation_modal_close_btn).click()

    return dict_ret


def selenium_asir_webem_sync(url, user_name, user_password, virtual_enable=True, debug=False):
    """
    selenium_asir_webem_sync function, After Gnb Web EM delta commissioned,
        Open ASIR Web EM to sync the change by selenium operation
    :param url: Gnb Web EM url e.g. https://192.168.255.129
    :param user_name: user name of Gnb Web Em, usually 'Nemuadmin'
    :param user_password: user password of Gnb Web Em, usually 'nemuuser'
    :return a Dictionary of selenium operation result
    Note: Due to ASIR WebEM GUI is changed, the method of _switch_to_dedicated_tab will be also changed. So call
          sync_config_with_gnb function in DevNJ_ASIR_Selenium.py file instead of _switch_to_dedicated_tab &
          _import_detected_configuration & _activate and other functions.
    """
    steps = []
    func_name = sys._getframe().f_code.co_name
    timeout_wait = 30
    ui_delay = 1

    screenshot_dir = tempfile.mkdtemp(prefix='{}_screenshots_'.format(func_name))
    logger.info("selenium_asir_webem_sync, virtual_enable is {}, screenshot dir {}"
                .format(virtual_enable, screenshot_dir), also_console=True)

    wd = None
    if debug:
        options = webdriver.ChromeOptions()
        options.add_argument('--ignore-certificate-errors')
        options.add_argument('--start-maximized')
        logger.info("debug Selenium adopted", also_console=True)
        chrome_driver = r"/opt/ute/chromedriver/chromedriver"
        wd = webdriver.Chrome(chrome_driver, chrome_options=options)
    else:
        logger.info("taf Selenium adopted", also_console=True)
        selenium_coam = sbts()
        if virtual_enable:
            logger.info("enable_virtual_display", also_console=True)
            selenium_coam.enable_virtual_display()

        wd = selenium_coam._configure_before_login("Chrome", None, "/home/ute/Downloads", None)._driver
    wd.implicitly_wait(15)
    try:
        steps.append("Login to WebEM")
        logger.info("Login to WebEM")
        wd.get(url)
        INPUT_USERNAME_XPATH = '//input[@name="username" or @placeholder="Username"]'
        INPUT_PASSWORD_XPATH = '//input[@name="password" or @placeholder="Password"]'
        wd.find_element(By.XPATH, INPUT_USERNAME_XPATH).send_keys(user_name)
        wd.find_element(By.XPATH, INPUT_PASSWORD_XPATH).send_keys(user_password + '\n')
        wait = Wait(wd, timeout_wait)
        try:
            wait.until(EC.element_to_be_clickable((By.CSS_SELECTOR, '[a-text="Confirm"]'))).click()
        except TimeoutException as e:
            logger.info("No Confirm button need to click")
        try:
            wait.until(EC.element_to_be_clickable((By.XPATH, "//div[@class='ui-modal']//ui-button["
                                                             "@a-text='Close']//button"))).click()
        except TimeoutException as e:
            logger.info("No Bts Info's Close button need to click")
        steps.append("Click Button 'Launch ASiR Web EM'")
        logger.info("Click Button 'Launch ASiR Web EM'")
        LAUNCH_ASIR_XPATH = '//ui-button[contains(@a-text,"Launch ASiR")]'
        retry_times = 0
        while retry_times < 3:
            try:
                retry_times += 1
                btnAsir = wait.until(EC.element_to_be_clickable((By.XPATH, LAUNCH_ASIR_XPATH)))
                btnAsir.click()
                break
            except Exception as e:
                logger.error('Click "Launch ASIR" button at {} time, exception: {}'.format(retry_times, str(e)))
                time.sleep(1)
        else:
            raise Exception('Failed to click "Launch ASIR" button after {} times'.format(retry_times))

        time.sleep(ui_delay * 10)
        logger.info("Webdriver switch to 'ASIR Web EM'")
        steps.append("Webdriver switch to 'ASIR Web EM'")
        for handle in wd.window_handles:
            wd.switch_to.window(handle)
            if 'asir webem' in wd.title.lower():
                break
        # Call sync_config_with_gnb function in DevNJ_ASIR_Selenium.py instead of the following steps.
        call_sync = DevNJ_ASIR_Selenium(wd=wd)
        call_sync.sync_config_with_gnb()
        # steps.append("_enter_config_man")
        # _enter_config_man(wd)
        # steps.append("_switch_to_dedicated_tab(wd, 'Profiles')")
        # _switch_to_dedicated_tab(wd, 'Profiles')
        # steps.append("_import_detected_configuration(wd, 'complete')")
        # _import_detected_configuration(wd, 'complete')
        # steps.append("_switch_to_dedicated_tab(wd, 'Cells')")
        # _switch_to_dedicated_tab(wd, 'Cells')
        # steps.append("_import_detected_configuration(wd, 'complete')")
        # _import_detected_configuration(wd, 'complete')
        # # find the cell list table
        # time.sleep(ui_delay * 5)
        # steps.append("wd.find_element_by_id('cell-list-table')")
        # cell_list_table = wd.find_element_by_id('cell-list-table')
        # cell_list_items = cell_list_table.find_elements_by_tag_name('tr')
        # for cell_item in cell_list_items:
        #     cell_item.click()
        #     time.sleep(ui_delay * 3)
        # steps.append("_switch_to_dedicated_tab(wd, 'Parameter editor')")
        # _switch_to_dedicated_tab(wd, 'Parameter editor')
        # steps.append("_import_detected_configuration(wd, 'complete')")
        # _import_detected_configuration(wd, 'complete')
        # steps.append("_switch_to_dedicated_tab(wd, 'Activation')")
        # _switch_to_dedicated_tab(wd, 'Activation')
        # steps.append("activate")
        # _activate(wd)
        return {'res': True}
    except Exception as e:
        screenshot_name = '{}.png'.format(func_name)
        if not os.path.exists(screenshot_dir):
            os.makedirs(screenshot_dir)
        screenshot_path = os.path.join(screenshot_dir, screenshot_name)
        wd.save_screenshot(screenshot_path)
        logger.error('{} Exception {}, screenshot saved to {}'.format(func_name, str(e), screenshot_path))
        return {'res': False, 'exception': e, 'steps': steps}
    finally:
        wd.quit()
        if virtual_enable and selenium_coam:
            selenium_coam.disable_virtual_display()


def get_hubmod_id_from_asirmod_id(asirmod_id=None):
    """
    Convert ASIRMOD ID (used in gNB WebEM for Hub) to HUBMOD ID (used in ASiR WebEM for Hub)
    :param asirmod_id: HUB ID (ASIRMOD-x)
    :return: HUB ID (HUBMOD-x)
    """
    api = admin()
    connection = None
    try:
        connection = api.connect_to()
        bts_info = connection.get_bts_info(timeout=120)
        for hub in bts_info.get('radioModules').get('asirmod'):
            if hub.get('id').get('configuration').split('-')[-1] == str(asirmod_id):
                serial_number = hub.get('serialNumber')
                break
        else:
            raise Exception("Didn't find specified HUB information with ASiRMOD ID {}".format(asirmod_id))
    finally:
        if connection:
            api.teardown(connection=connection)

    hw_inventory_info = AsiMgr(autoconnect=True).get_asi_hw_data_based_on_commissioning()
    for single_hub_info in hw_inventory_info:
        if single_hub_info.get("serialNumber") == serial_number:
            return single_hub_info.get("@id")
    else:
        raise Exception("Didn't find HUB information with serial number {}".format(serial_number))


def get_asirmod_id_from_hubmod_id(hubmod_id=None):
    """
    Convert HUBMOD ID (used in ASiR WebEM for Hub) to ASIRMOD ID (used in gNB WebEM for Hub)
    :param hubmod_id: HUB ID (HUBMOD-x)
    :return: HUB ID (ASIRMOD-x)
    """
    hw_inventory_info = AsiMgr(autoconnect=True).get_asi_hw_data_based_on_commissioning()
    for single_hub_info in hw_inventory_info:
        if single_hub_info.get("@id") == str(hubmod_id):
            serial_number = single_hub_info.get("serialNumber")
            break
    else:
        raise Exception("Didn't find specified HUB information with HUBMOD ID {}".format(hubmod_id))

    api = admin()
    connection = None
    try:
        connection = api.connect_to()
        bts_info = connection.get_bts_info(timeout=120)
        for hub in bts_info.get('radioModules').get('asirmod'):
            if hub.get('serialNumber') == serial_number:
                asirmod_id = hub.get('id').get('configuration').split('-')[-1]
                break
        else:
            raise Exception("Didn't find HUB information with serial number {}".format(serial_number))
    finally:
        if connection:
            api.teardown(connection=connection)

    return asirmod_id


def Get_Check_DASRFM_Status(list_dasrfm_status, dasrfm_id, dict_check_status):
    """
    Compare the list of DASRFM status between Gnb and user expected dasrfm,
    and return a result dictionary that contains the details.
    will called by upper robot keyword 'Check DASRFM Status'
    :param list_dasrfm_status: list of all DAS RFMs' status
    :param dasrfm_id: DAS RFM's ID
    :param dict_check_status: dictionary of status key/value pair
    :return: dictinary of check result
    """
    check_result = True
    dict_result = {}
    for dasrfm in list_dasrfm_status:
        if dasrfm.get('id').get('configuration').split('-')[-1] == str(dasrfm_id):
            dict_dasrfm_status = dasrfm.get('status')
            if 'availabilityStatus' not in dict_dasrfm_status or dict_dasrfm_status['availabilityStatus'] == '':
                dict_dasrfm_status['availabilityStatus'] = 'online'
            for k, v in dict_check_status.items():
                if str(dict_dasrfm_status.get(k)).lower().replace(" ", "") != str(v).lower().replace(" ", ""):
                    check_result = False
                    dict_result[k] = {'real_value': str(
                        dict_dasrfm_status.get(k)), 'expected_val': str(v)}
            break
    else:
        return {'check_result': False, 'check_info': 'dasrfm not found with id {}'.format(dasrfm_id)}

    return {'check_result': check_result, 'check_info': 'Check successfully' if check_result else 'Check Failed',
            'dict_result': dict_result}


def _get_prrh_hw_inventory_info_via_asir():
    """
    Retrieve pRRH information from ASI commission file.
    :return: a list of dictionaries. Each dictionary contains the related information of one pRRH. For example:
             [{u'serialNumber': u'NH192400134', u'productName': u'AWHHC'},
              {u'serialNumber': u'NH191503055', u'productName': u'AWHHC'}]
    """
    asimgr = AsiMgr(autoconnect=True)
    path_to_scf = asimgr.collect_commissioning_file("/tmp")
    domTree = parse(path_to_scf)
    rootNode = domTree.documentElement
    mo_list = rootNode.getElementsByTagName("managedObject")

    hw_inventory_info = []
    for mo in mo_list:
        if mo.hasAttribute("class") and mo.getAttribute("class") == "com.nokia.asi:ANTMOD_R":
            tmp_dict = {}
            elememts_p = mo.getElementsByTagName("p")
            name_list = ["productName", "serialNumber"]
            for element in elememts_p:
                if element.hasAttribute("name") and element.getAttribute("name") in name_list:
                    tmp_dict[element.getAttribute("name")] = element.childNodes[0].data
            hw_inventory_info.append(tmp_dict)

    MolerTest.info("ANTMOD_R info: {}".format(hw_inventory_info))
    return hw_inventory_info


def _get_prrh_hw_inventory_info_via_gnb():
    """
    Retrieve pRRH hardware inventory information by invoking ADMIN API.
    :return: a list of dictionaries. Each dictionary contains the related information of one pRRH. For example:
            [{'serialNumber': u'NH192400134', 'vendorName': u'Nokia', 'inventoryUnitType': u'AWHHC'},
             {'serialNumber': u'NH191503055', 'vendorName': u'Nokia', 'inventoryUnitType': u'AWHHC'}]
    """
    api = admin()
    connection = None
    try:
        name_list = ["serialNumber", "inventoryUnitType", "vendorName"]
        invunits_list = []
        connection = api.connect_to()
        invunits = connection.get_managed_objects(class_name="INVUNIT_R", timeout=120)
        for unit in invunits:
            tmp_dict = {}
            if unit.get("parameters").get("vendorUnitFamilyType") == "ASiR-pRRH":
                for name in name_list:
                    tmp_dict[name] = unit.get("parameters").get(name)
                invunits_list.append(tmp_dict)
    finally:
        if connection:
            api.teardown(connection=connection)
    MolerTest.info("INVUNIT info: {}".format(invunits_list))
    return invunits_list


@MolerTest.raise_background_exceptions(check_steps_end=True)
def verify_prrh_hw_inventory_info():
    """
    Verify if BTS fills INVUNIT::inventoryUnitType with the unit Type of the pRRH(i.e.,AHGEA ) and fills
    INVUNIT:vendorName with 'Nokia' so customer application can recognize the pRRH.
    :return: None
    """
    prrh_info_asir = _get_prrh_hw_inventory_info_via_asir()
    prrh_info_gnb = _get_prrh_hw_inventory_info_via_gnb()

    if len(prrh_info_asir) != len(prrh_info_gnb):
        MolerTest.error("Number of pRRH retrieved from ASiR {} is not equal to number got from gNB {}".format(
            len(prrh_info_asir), len(prrh_info_gnb)
        ))

    result = [y for x in prrh_info_asir for y in prrh_info_gnb if y['serialNumber'] == x['serialNumber']
              if y['inventoryUnitType'] != x['productName'] or y['vendorName'] != 'Nokia']
    if result:
        MolerTest.error(
            "Error found on pRRH: {}. Either 'inventoryUnitType' is incorrect or 'vendorName' is not 'Nokia'".format(
                result))

    MolerTest.steps_end()
