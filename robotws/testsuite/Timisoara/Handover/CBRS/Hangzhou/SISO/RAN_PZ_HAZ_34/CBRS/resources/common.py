# -*- coding: utf-8 -*-
import re
import os
import subprocess
import time
import datetime
import math


def get_str_appeared_times_in_file(str, filepath):
    file = open(filepath, "r")
    content = file.read()
    times = content.count(str)
    file.close()
    return times


def sorted_subGrantInfo_list(subGrantInfo_list):
    sorted_list = sorted(subGrantInfo_list, key=lambda x: x['nrCbsdId'])
    return sorted_list


def generate_inquire_spectrum_info(inquiredspectrumlist):
    result = "\"inquiredSpectrum\":.*"
    for item in inquiredspectrumlist:
        result = result + "\"highFrequency\":" + str(item['highFrequency']) + ",\"lowFrequency\":" +\
                 str(item['lowFrequency']) + ".*"
    return result


def generate_power_means_report(powermeaslist):
    result = "\"rcvdPowerMeasReports\":.*"
    for item in powermeaslist:
        result = result + "\"measBandwidth\":" + str(item['measBandwidth']) + ",\"measFrequency\":" + \
                 str(item['measFrequency']) + ",\"measRcvdPower\":.*"
    return result


def check_power_means(filepath, expect=-100):
    file = open(filepath, "r")
    content = file.read()
    file.close()
    pattern = r'"measRcvdPower":(-\d+?)},'
    result = re.findall(pattern=pattern, string=content)
    flag = True
    if result:
        for value in result:
            if int(value) < int(expect):
                flag = False
                break
    return flag


def delete_icmp_policy():
    cmd = "sudo iptables -S"
    return_code, output = subprocess.getstatusoutput(cmd)
    if "--reject-with icmp-host-prohibited" in output:
        print("icmp message is prohibited, began to delete the icmp policy from iptable...")
        cmd = "sudo iptables -L INPUT --line-numbers"
        return_code, output = subprocess.getstatusoutput(cmd)
        print(output)
        pattern = r"(\d+)\s+REJECT.*reject-with icmp-host-prohibited"
        result = re.search(pattern=pattern, string=output)
        if result:
            icmp_policy_id = result.group(1)
            cmd_delete_icmp_policy = "sudo iptables -D INPUT "+icmp_policy_id
            print("**********execute '"+cmd_delete_icmp_policy+"'**********")
            os.system(cmd_delete_icmp_policy)
    else:
        print("**********icmp message is not prohibited**********")


def get_grant_value_from_saslog(filepath, responseCode=0):
    file = open(filepath, "r")
    content = file.read()
    file.close()
    maxEirp = ""
    highFrequency = ""
    lowFrequency = ""
    grantId = ""
    pattern = r'"grantRequest":.*"maxEirp":(.*?),.*highFrequency":(\d+?),"lowFrequency":(\d+?)}.*'
    result = re.search(pattern=pattern, string=content)
    if result:
        maxEirp = result.group(1)
        maxEirp = add_unit_for_pow_parameter(maxEirp)
        highFrequency = result.group(2)
        highFrequency = add_unit_for_frequent_parameter(highFrequency)
        lowFrequency = result.group(3)
        lowFrequency = add_unit_for_frequent_parameter(lowFrequency)
    pattern = r'"grantResponse":.*grantId": "(.*?)".*responseCode": '+str(responseCode)+r'.*'
    result = re.search(pattern=pattern, string=content)
    if result:
        grantId = result.group(1)
    result = dict()
    result['maxEirp'] = maxEirp
    result['highFrequency'] = highFrequency
    result['lowFrequency'] = lowFrequency
    result['grantId'] = grantId
    return result


def get_grantID_from_grantRequest(filepath, msg_index):
    msg_index = int(msg_index)
    info = get_pointed_msg_info(filepath, msgType='grantRequest')
    line_from = info[msg_index-1]['line_start']
    grantid = ""
    for i in range(line_from+1, len(lines)):
        if lines[i].startswith("{\"") and not lines[i].startswith("{\"eventType\":"):
            break
        if "grant id is" in lines[i]:
            grantid = lines[i].split("grant id is")[-1].strip(" ").strip("\n")
    return grantid


def get_grantID_value_from_saslog(filepath, responseCode=0):
    file = open(filepath, "r")
    content = file.read()
    file.close()
    grantId = ""
    pattern = r'"grantResponse":.*grantId": "(.*?)".*responseCode": '+str(responseCode)+r'.*'
    result = re.search(pattern=pattern, string=content)
    if result:
        grantId = result.group(1)
    return grantId


def get_all_grantID_value_from_saslog(filepath):
    file = open(filepath, "r")
    content = file.read()
    file.close()
    pattern = r'"grantResponse":.*grantId": "(.*?)".*responseCode": 0.*'
    results = re.findall(pattern=pattern, string=content)
    # print results
    return results


def get_recommend_value_from_grant_response(filepath):
    file = open(filepath, "r")
    content = file.read()
    file.close()
    maxEirp = ""
    lowFrequency = ""
    highFrequency = ""
    grantId = ""
    pattern = r'"grantResponse":.*maxEirp": (.*),.*lowFrequency": (\d+),.*highFrequency": (\d+)}.*responseCode": 400'
    result = re.search(pattern=pattern, string=content)
    if result:
        maxEirp = result.group(1)
        lowFrequency = result.group(2)
        highFrequency = result.group(3)
    pattern = r'"grantResponse":.*grantId": "(.*?)".*responseCode": 0.*'
    result = re.search(pattern=pattern, string=content)
    if result:
        grantId = result.group(1)
    result = dict()
    result['maxEirp'] = maxEirp
    result['highFrequency'] = highFrequency
    result['lowFrequency'] = lowFrequency
    result['grantId'] = grantId
    return result


def add_unit_for_pow_parameter(value):
    if value.endswith(".0"):
        value = value.replace(".0", "")
    # value = value + " (dBm)"
    return value


def add_unit_for_frequent_parameter(value):
    value = str(int(value)/1000000)
    # value = str(value)+" (MHz)"
    if value.endswith(".0"):
        value = value.replace(".0", "")
    return value


def get_maxeirp_in_first_grantrequest(filepath):
    file = open(filepath, "r")
    content = file.read()
    file.close()
    pattern = r'"grantRequest".*maxEirp":(.*?),'
    result = re.search(pattern=pattern, string=content)
    maxeirp_first_request = ""
    if result:
        maxeirp_first_request = result.group(1)
    return maxeirp_first_request


def get_valid_maxerip(requesvalue, recommandvalue, maxgrantpwrred):
    result = ""
    # maxgrantpwrred = float(maxgrantpwrred.replace(" (dB)", ""))
    if (float(recommandvalue) > (float(requesvalue)-maxgrantpwrred)) and (float(recommandvalue) < float(requesvalue)):
        result = recommandvalue
    else:
        result = requesvalue
    # if "." not in result:
    #     result = result+".0"
    return result


def get_pointed_msg_info(filepath, msgType):
    # msgType can be registrationRequest, registrationResponse, spectrumInquiryRequest, spectrumInquiryResponse
    # grantRequest, grantResponse, heartbeatRequest, heartbeatResponse...
    global info
    global lines
    info = []
    file = open(filepath, "r")
    lines = file.readlines()
    file.close()
    for i in range(len(lines)):
        if lines[i].startswith("{\""+msgType+"\":"):
            tmp = {}
            tmp['line_start'] = i
            tmp['content'] = lines[i]
            info.append(tmp)
    return info


def get_msg_by_type_and_index(filepath, msgType, msg_index):
    msg = ""
    msg_index = int(msg_index)
    info = get_pointed_msg_info(filepath, msgType)
    if msg_index <= len(info):
        msg = info[msg_index-1]['content']
    return msg


def get_expire_time_from_pointed_msg(filepath, msgType, msg_index, expire_type):
    # msgType can be registrationRequest, registrationResponse, spectrumInquiryRequest, spectrumInquiryResponse
    # grantRequest, grantResponse, heartbeatRequest, heartbeatResponse...
    # expire_type can be transmit or grant
    # msg_index: for example, if it is the first request, msg_index is 1, if it is the second request, msg_index is 2
    msg_index = int(msg_index)
    info = get_pointed_msg_info(filepath, msgType)
    msg = info[msg_index-1]['content']
    pattern = r''
    if expire_type.lower() == "transmit":
        pattern = r'\"transmitExpireTime\": \"(.*?)\",'
    elif expire_type.lower() == "grant":
        pattern = r'\"grantExpireTime\": \"(.*?)\",'
    result = re.search(pattern=pattern, string=msg)
    transmit_export_time = ""
    if result:
        transmit_export_time = result.group(1)
    return transmit_export_time


def get_send_time_for_pointed_msg(filepath, msgType, msg_index):
    # msgType can be registrationRequest, registrationResponse, spectrumInquiryRequest, spectrumInquiryResponse
    # grantRequest, grantResponse, heartbeatRequest, heartbeatResponse...
    # msg_index: for example, if it is the first request, msg_index is 1, if it is the second request, msg_index is 2
    msg_index = int(msg_index)
    info = get_pointed_msg_info(filepath, msgType)
    send_info = lines[info[msg_index-1]['line_start']+1]
    time_info = send_info.split("[")[0].strip(" ")
    return time_info


def get_time_interval_between_two_msg(filepath, msgType, msg_index_1, msg_index_2):
    msg_index_1 = int(msg_index_1)
    msg_index_2 = int(msg_index_2)
    # msgType can be registrationRequest, registrationResponse, spectrumInquiryRequest, spectrumInquiryResponse
    # grantRequest, grantResponse, heartbeatRequest, heartbeatResponse...
    # msg_index: for example, if it is the first request, msg_index is 1, if it is the second request, msg_index is 2
    info = get_pointed_msg_info(filepath, msgType)
    msg1 = lines[info[msg_index_1-1]['line_start']+1]
    time_send1 = msg1.split("[")[0].strip(" ")
    timeArray1 = time.strptime(time_send1, "%m/%d/%Y %H:%M:%S")
    timeStamp1 = int(time.mktime(timeArray1))
    time1 = datetime.datetime.fromtimestamp(timeStamp1)
    msg2 = lines[info[msg_index_2-1]['line_start']+1]
    time_send2 = msg2.split("[")[0].strip(" ")
    timeArray2 = time.strptime(time_send2, "%m/%d/%Y %H:%M:%S")
    timeStamp2 = int(time.mktime(timeArray2))
    time2 = datetime.datetime.fromtimestamp(timeStamp2)
    differ = time2-time1
    return int(differ.total_seconds())


def get_time_interval_between_send_and_expired(filepath, msgType, msg_index, expire_type):
    # msgType can be registrationRequest, registrationResponse, spectrumInquiryRequest, spectrumInquiryResponse
    # grantRequest, grantResponse, heartbeatRequest, heartbeatResponse...
    # expire_type can be transmit or grant
    # msg_index: for example, if it is the first request, msg_index is 1, if it is the second request, msg_index is 2
    msg_index = int(msg_index)
    expire_time = get_expire_time_from_pointed_msg(filepath, msgType, msg_index, expire_type)
    timeArray = time.strptime(expire_time, "%Y-%m-%dT%H:%M:%SZ")
    timeStamp_expire = int(time.mktime(timeArray))
    timeStamp_expire += 8*60*60
    msg = lines[info[msg_index-1]['line_start']+1]
    time_send = msg.split("[")[0].strip(" ")
    timeArray = time.strptime(time_send, "%m/%d/%Y %H:%M:%S")
    timeStamp_send = int(time.mktime(timeArray))
    time_expire = datetime.datetime.fromtimestamp(timeStamp_expire)
    time_send = datetime.datetime.fromtimestamp(timeStamp_send)
    differ = time_expire - time_send
    return int(differ.total_seconds())


def get_op_state_from_pointed_msg(filepath, msgType, msg_index):
    msg_index = int(msg_index)
    info = get_pointed_msg_info(filepath, msgType)
    line_from = info[msg_index-1]['line_start']
    status = ""
    for i in range(line_from+1, len(lines)):
        if lines[i].startswith("{\"") and not lines[i].startswith("{\"eventType\":"):
            break
        if "change op state to" in lines[i]:
            pattern = r'change op state to (.*?) from'
            result = re.search(pattern=pattern, string=lines[i])
            if result:
                status = result.group(1)
    return status


def get_msg_index_by_type_and_keywords(filepath, msgType, keywords):
    info = get_pointed_msg_info(filepath, msgType)
    flag = 0
    for i in range(len(info)-1):
        line_from = info[i]['line_start']
        if i < len(info)-1:
            line_to = info[i+1]['line_start']
        else:
            for j in range(line_from+1, len(lines)):
                if lines[j].startswith("{\"") and not lines[i].startswith("{\"eventType\":"):
                    line_to = j
                    break
        for num in range(line_from, line_to):
            if keywords in lines[num]:
                flag = 1
                break
        if flag == 1:
            break
    return i+1


def generate_correct_nrcbsdcell_distname(distname_before, cellid, cbsdcelid):
    distname = ""
    if "_R-" in distname_before:
        distname = str(distname_before.split("NRCELL_R")[0])+"NRCELL_R-"+str(cellid)+"/NRCBSDCELL_R-"+str(cbsdcelid)
    elif "_A-" in distname_before:
        distname = str(distname_before.split("NRCELL_A")[0])+"NRCELL_A-"+str(cellid)+"/NRCBSDCELL_A-"+str(cbsdcelid)
    return distname


def generate_correct_cbsdcell_distname(distname_before, cellid, cbsdcelid):
    distname = ""
    if "_R-" in distname_before:
        distname = str(distname_before.split("LNCEL_R")[0])+"LNCEL_R-"+str(cellid)+"/CBSDCEL_R-"+str(cbsdcelid)
    elif "_A-" in distname_before:
        distname = str(distname_before.split("LNCEL_A")[0])+"LNCEL_A-"+str(cellid)+"/CBSDCEL_A-"+str(cbsdcelid)
    return distname


def generate_correct_LNCEL_TDD_distname(distname_before, cellid, LNCEL_TDDid):
    distname = ""
    if "_R-" in distname_before:
        distname = str(distname_before.split("LNCEL_R")[0])+"LNCEL_R-"+str(cellid)+"/LNCEL_TDD_R-"+str(LNCEL_TDDid)
    elif "_A-" in distname_before:
        distname = str(distname_before.split("LNCEL_A")[0])+"LNCEL_A-"+str(cellid)+"/LNCEL_TDD_A-"+str(LNCEL_TDDid)
    return distname


def generate_correct_nrcell_distname(distname_before, cellid):
    distname = ""
    if "_R-" in distname_before:
        distname = str(distname_before.split("NRCELL_R")[0])+"NRCELL_R-"+str(cellid)
    elif "_A-" in distname_before:
        distname = str(distname_before.split("NRCELL_A")[0])+"NRCELL_A-"+str(cellid)
    return distname


def generate_correct_cbsd_distname(distname_before, cbsdid):
    distname = ""
    if "_R-" in distname_before:
        distname = str(distname_before.split("CBSD_R")[0])+"CBSD_R-"+str(cbsdid)
    elif "_A-" in distname_before:
        distname = str(distname_before.split("CBSD_A")[0])+"CBSD_A-"+str(cbsdid)
    return distname


def get_multi_grant_value_from_saslog(filepath, responseCode=0):
    file = open(filepath, "r")
    content = file.read()
    file.close()
    pattern = r'"grantRequest":.*"maxEirp":(.*?),.*highFrequency":(\d+?),"lowFrequency":(\d+?)}.*'
    info_req = re.findall(pattern=pattern, string=content)
    pattern = r'"grantResponse":.*grantId": "(.*?)".*responseCode": '+str(responseCode)+r'.*'
    info_resp = re.findall(pattern=pattern, string=content)
    info = []
    if len(info_req) != len(info_resp):
        return info
    for i in range(len(info_req)):
        tmp = dict()
        tmp['maxEirp'] = add_unit_for_pow_parameter(info_req[i][0])
        tmp['highFrequency'] = add_unit_for_frequent_parameter(info_req[i][1])
        tmp['lowFrequency'] = add_unit_for_frequent_parameter(info_req[i][2])
        tmp['grantId'] = info_resp[i]
        info.append(tmp)
    return info


def get_all_msg_from_log(filepath):
    msg_all = []
    if os.path.exists(filepath):
        file = open(filepath, "r")
        lines = file.readlines()
        file.close()
        for line in lines:
            if line.startswith("{\"") and not line.startswith("{\"eventType\":"):
                pattern = r'{\"(.*?)\":'
                result = re.match(pattern=pattern, string=line)
                if result:
                    msg = result.group(1)
                    msg_all.append(msg)
    return msg_all


def get_all_heartbeat_msg_from_log(filepath):
    msg_all = get_all_msg_from_log(filepath)
    msg_hearbeat = []
    for msg in msg_all:
        if msg.startswith("heartbeat"):
            msg_hearbeat.append(msg)
    return msg_hearbeat


def check_alarm_in_Active_Or_History_Alarmlist(alarmlist, faultId, supplementary, stamp_case_start):
    alarms_after_filter = []
    for alarm in alarmlist:
        if stamp_case_start is not None and 'eventTime' in alarm.keys():
            event_time = alarm['eventTime']
            if event_time > stamp_case_start:
                alarms_after_filter.append(alarm)
        else:
            alarms_after_filter.append(alarm)
    flag = False
    for alarm in alarms_after_filter:
        if supplementary is not None and 'supplAlarmInfo' in alarm.keys():
            if faultId == str(alarm['faultId']) and supplementary == alarm['supplAlarmInfo']:
                flag = True
                break
        else:
            if faultId == str(alarm['faultId']):
                flag = True
                break
    return flag


def check_alarm_in_Active_Or_History_Alarmlist_supplAlarmInfo(alarmlist, faultId, supplementary, stamp_case_start):
    alarms_after_filter = []
    for alarm in alarmlist:
        if stamp_case_start is not None and 'eventTime' in alarm.keys():
            event_time = alarm['eventTime']
            if event_time > stamp_case_start:
                alarms_after_filter.append(alarm)
        else:
            alarms_after_filter.append(alarm)
    flag = False
    for alarm in alarms_after_filter:
        if supplementary is not None and 'supplAlarmInfo' in alarm.keys():
            if faultId == str(alarm['faultId']) and supplementary == alarm['supplAlarmInfo']:
                flag = True
                break
    return flag


def check_alarm_in_Active_Or_History_Alarmlist_RU_SN(alarmlist, faultId, supplementary, stamp_case_start, ru_sn):
    alarms_after_filter = []
    for alarm in alarmlist:
        if stamp_case_start is not None and 'eventTime' in alarm.keys():
            event_time = alarm['eventTime']
            if event_time > stamp_case_start:
                alarms_after_filter.append(alarm)
        else:
            alarms_after_filter.append(alarm)
    flag = False
    for alarm in alarms_after_filter:
        if supplementary is not None and 'supplAlarmInfo' in alarm.keys():
            if faultId == str(alarm['faultId']):
                if supplementary == alarm['supplAlarmInfo'] and ru_sn == alarm['serialNo']:
                    flag = True
                    break
    return flag


def Calculate_maxEiRP(pMax, antGain, chBw, numStreams, numAnts=64):
    chBw = re.findall(r'\d+(?#\D)', chBw)[0]
    numStreams = re.findall(r'\d+(?#\D)', numStreams)[0]
    maxEiRP = \
        int(pMax) + 10 * math.log10(numAnts) + int(antGain) + \
        10 * math.log10(1/int(chBw)) - 10 * math.log10(int(numStreams))
    return maxEiRP


def get_carrier_freq(carrier_freq_str):
    carrier_freq_list = carrier_freq_str.split(' ')
    return float(carrier_freq_list[0])


def get_maxEiRP_from_SASlog(filepath):
    file = open(filepath, "r")
    content = file.read()
    file.close()
    maxEirp = ""
    pattern = r'"grantRequest":.*"maxEirp":(.*?),.*'
    result = re.search(pattern=pattern, string=content)
    if result:
        maxEirp = result.group(1)
    return maxEirp
