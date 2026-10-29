# -*- coding:utf-8 -*-
"""
Author: Li Yanan
Contacts: amaand.li@nokia-sbell.com
Description: provide the api for verifying unexpected resets
"""
import os.path
import os
from datetime import datetime
import datetime
import oam_file_operations
from hran_file_operations.parsers.blackbox import BlackBox
import re
import verify_crash
from taf.sbts.oam.coam.admin import admin
import logging

Not_Allowed_Reset = ['spurious',
                     'watchdog',
                     'Emergency',
                     ]


# @func_set_timeout(1200)
def check_for_reset(filefullpath, suitname, casename, qc_id, des_path):
    reset_bool = "NO"
    issue_type = "autonomous reset"
    now = datetime.datetime.now().strftime("%Y_%m_%d_%H_%M")
    now = ''.join(now.split('_'))
    suitinfo = suitname + "_" + now
    sheet_type = suitname + "_" + issue_type
    FB, curdate = Get_CurFB_Date()
    # try:
    unexp_reset_list = analysis_blackbox(get_blackbox_from_bts(destination_path=des_path))
    print("unexp_reset_list:{}".format(unexp_reset_list))
    fault_list = analysis_alarms(get_raw_alarms_history(des_path=des_path))
    history_fault_reset_list = analysis_history_alarms()
    if len(unexp_reset_list):
        if len(fault_list):
            reset_bool = "YES"
            unexp_reset_str = str(unexp_reset_list)
            fault_str = str(fault_list)
            reset_info = unexp_reset_str + "\n" + fault_str
            print("reset_info:{}".format(reset_info))
            if len(history_fault_reset_list):
                history_exception_fid = str(history_fault_reset_list)
                kw_info = reset_info + "\n" + history_exception_fid
                # dict_info = [deal_static(FB, qc_id, issue_type, casename, suitinfo, reset_info)]
                dict_info = [deal_static(casename, qc_id, issue_type, kw_info)]
                # write2localexcel(filefullpath, sheet_type, dict_info)
                verify_crash.append2xls(filefullpath, suitname, dict_info)
#          if len(history_fault_reset_list):
#              reset_bool = "YES"
#              dict_historyFID_info = [deal_static(casename, qc_id, issue_type, history_fault_reset_list)]
#              verify_crash.append2xls(filefullpath, suitname, dict_historyFID_info)

#    except func_timeout.exceptions.FunctionTimedOut:
#        print("Execution check syslog for crashes timeout")
    return reset_bool


def analysis_history_alarms():
    fault_info_list = []
    api = admin()
    connection = api.connect_to()
    result = connection.get_historic_alarms(load_history=True, timeout=600)
    api.teardown_all_aliases_for_admin()
    logging.info("Fetch historical alarms: ", result)
    print("Fetch historical alarms::{}".format(result))
    autoreset_fid = ["4352", "2087", "4383", "4592", "4341", "4019", "1806", "1900", "16"]
    for item in result:
        logging.info("fault id info: ", item['faultId'])
        print("faultId:{}".format(item['faultId']))
        print("typeof faultid: {}".format(item['faultId']))
        if str(item['faultId']) in autoreset_fid:
            fid_configDN = item['configObjectName']
            fid_impactedCells = item['impactedCellsList']
            fid_appeartime = item['btsLastUpdateTime']
            item_info = {"faultId": item['faultId'], "fid_configDN": fid_configDN,
                         "fid_impactedCells": fid_impactedCells, "fid_appeartime": fid_appeartime}
            fault_info_list.append(item_info)
    logging.info("search result:", fault_info_list)
    print("search result:{}".format(fault_info_list))
    return fault_info_list


def get_blackbox_from_bts(target_ip='192.168.255.129',
                          via_vm_ip='',
                          source_path='/ffs/run/logs/lifetimedata/blackbox',
                          destination_path=''):
    timestamp = datetime.datetime.now().strftime("%Y%m%d%H%M")
    if not os.path.exists(destination_path):
        destination_path = '/home/ute/black-box'
        os.mkdir(destination_path)
    blackbox_file = timestamp + '_' + 'blackbox'
    blackbox_path_file = os.path.join(destination_path, blackbox_file)
    oam_file_operation = oam_file_operations.oam_file_operations()
    master_bb = oam_file_operation.get_file_from_system_module(target_ip=target_ip, source_path=source_path,
                                                               destination_path=blackbox_path_file)
    print('master_bb:{}'.format(master_bb))
    if via_vm_ip:
        target_ip = '192.168.255.119'
        esm_blac = timestamp + '_' + 'ESM' + '_blackbox'
        esm_blackbox = os.path.join(destination_path, esm_blac)
        slave_bb = oam_file_operation.get_file_from_system_module(target_ip=target_ip, source_path=source_path,
                                                                  destination_path=esm_blackbox, via_ip=via_vm_ip)
        print('slave_bb:{}'.format(slave_bb))
        return master_bb, slave_bb
    return master_bb


def analysis_blackbox(bb_path):
    unexpected_reset_list = []
    reset_counter, reset_reason = BlackBox.get_reset_info_from_file(bb_path)
    print('reset_counter:{}'.format(reset_counter))
    print('reset_reason:{}'.format(reset_reason))
    print((reset_reason[0][0]))
    print(reset_reason[0][1].split('-')[-1])
    incres = datetime.timedelta(days=1)
    print('type of incres:{}, incres: {}'.format(type(incres), incres))
    now = datetime.datetime.now()
    max_date = (now + incres).strftime("%Y-%m-%d-%H-%M")
    print('type of max:{}, max:{}'.format(type(max), max))
    print('type of now:{}'.format(type(now)))
    print('now:{}'.format(now))
    for item in reset_reason:
        reset_time = item[0]
        print('reset_time:{}'.format(reset_time))
        print('reset_reason_item:{}'.format(item[1]))
        if ':' in item[1]:
            print('true')
            reset_detail_reason = item[1].split(':')[1]
        else:
            reset_detail_reason = item[1].split(' ')[-2] + ' ' + item[1].split(' ')[-1]
        print('reset_del_reas:{}'.format(reset_detail_reason))
        for nr in Not_Allowed_Reset:
            print('nr:{}'.format(nr))
            if nr in reset_detail_reason:
                dic_reset_sub = {reset_time: reset_detail_reason}
                utc_time = datetime.datetime.strptime(reset_time, "%Y-%m-%dT%H:%M:%S.%fZ")
                if utc_time.strftime("%Y-%m-%d-%H-%M") < max_date:
                    unexpected_reset_list.append(dic_reset_sub)
    print('unexpected_reset_list:{}'.format(unexpected_reset_list))
    return unexpected_reset_list


def get_raw_alarms_history(des_path):
    source_path = '/tmp/RawAlarmHistory.txt'
    if not os.path.exists(des_path):
        os.mkdir(des_path)

    raw_alarms_text = oam_file_operations.oam_file_operations().get_file_from_system_module(source_path=source_path,
                                                                                            destination_path=des_path)
    print('raw_alarms_text: {}'.format(raw_alarms_text))
    return raw_alarms_text


def analysis_alarms(alarm_file_path):
    fault_time_id = []
    with open(alarm_file_path, 'r') as f:
        alarm_in_lines = f.readlines()
    for line in alarm_in_lines:
        if '(4592)' in line:
            print('read lines:{}'.format(line))
            item_match = re.match(
                r"(\d{4}-[A-Za-z]+-\d{2}(.*)\d{2}:\d{2}:\d{2})(.+)(4592)", line)
            if item_match:
                item = {item_match.group(1): item_match.group(4)}
                fault_time_id.append(item)
    print('fault:{}'.format(fault_time_id))
    return fault_time_id


# def write2localexcel(filefullpath, sheetname, data):
#     data_reset = pd.DataFrame(["FB", "QC_ID", "Issue_Type", "Case_Name", "Sute_Info", "Reset_Info"])
#     pf_reset = pd.DataFrame(data)
#     writer = pd.ExcelWriter(filefullpath, mode='a', engine='openpyxl')
#     data_reset.to_excel(writer, sheet_name=sheetname)
#     pf_reset.to_excel(writer, sheet_name=sheetname)
#     print("Write into excel successfully!")
#     writer.save()
#     writer.close()


def deal_static(p1, p2, p3, p4, *args):
    list_item = [p1, p2, p3, p4]
    return list_item


def Get_CurFB_Date():
    FB2301_start = datetime.datetime(2023, 1, 4)
    print(FB2301_start)
    incres = datetime.timedelta(days=13, hours=24, minutes=0, seconds=0)
    FB_dic = dict()
    for i in range(1, 27):
        if i < 10:
            FB = "FB230%s" % i
        else:
            FB = "FB23%s" % i
        DateInfo = FB2301_start + (i - 1) * incres
        FB_dic[FB] = DateInfo.strftime("%Y-%m-%d")
    print(FB_dic)

    today = datetime.datetime.now().strftime("%Y-%m-%d")

    CurFBRd = None
    curFBDate = None
    for key, value in FB_dic.items():
        if today >= value:
            CurFBRd = key
            curFBDate = value
    print(CurFBRd, curFBDate)
    return CurFBRd, curFBDate


if __name__ == '__main__':
    # bb_1 = get_blackbox_from_bts(destination_path='/home/ute/black-box')
    # analysis_blackbox(bb_1)
    # raw_alarm_path = get_raw_alarms_history('/home/ute/black-box/')
    # analysis_alarms(raw_alarm_path)
    # check_for_reset(suitname, casename, qc_id, des_path)
    check_for_reset('/home/ute/bb/Dual Core-CRASH-20230319132340.xls', 'Dual Core', '4934-d-1-4', '667',
                    '/home/ute/bb/')
    # wirte_to_sharepoint()
    # analysis_history_alarms()
