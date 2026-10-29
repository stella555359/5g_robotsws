import collections
from xml.etree.ElementTree import parse
from collections import Counter
from ctypes import *


def get_beamID(file_path):
    '''
    file_path:bip loge :/home/ute/tcpdumpL2L1_filtering_off.pdml
    Documentation:git beamID list form bip log
    return:The number of occurrences of of Beam ID ,is a dict [0:1,1:2,2:3]
    '''
    BeamID_list = []
    BeamID_dict = {}
    is_find = False
    with open(file_path, 'r') as f:
        file_path = parse(f)
    for item in file_path.iterfind('packet'):
        if is_find:
            for field in item.iterfind('proto/proto/field'):
                if field.get('name') == 'DlData_PdcchSendReq.PdcchSendReq.beamId':
                    showname = field.get('showname')
                    BeamID_list.append(showname[-2])
                    is_find = False
        else:
            for proto in item.iterfind('proto/proto'):
                if proto.get('name') == 'uldata_prachreceiveind':
                    is_find = True
                    break
    if BeamID_list != []:
        BeamID_dict = collections.Counter(BeamID_list)
    return dict(BeamID_dict)


def get_msg2(file_path):
    '''
    file_path:bip loge :/home/ute/tcpdumpL2L1_filtering_off.pdml
    Documentation:git beamID list form bip log
    return:The number of msg2 in bip log
    '''
    msg2 = 0
    is_find = False
    with open(file_path, 'r') as f:
        file_path = parse(f)
    for item in file_path.iterfind('packet'):
        if is_find:
            for proto in item.iterfind('proto/proto'):
                if proto.get('name') == 'dldata_pdschpayloadtbsendreq':
                    msg2 = msg2 + 1
                    is_find = False
        else:
            for proto in item.iterfind('proto/proto'):
                if proto.get('name') == 'uldata_prachreceiveind':
                    is_find = True
                    break
    return msg2


def get_msg2_true(file_path):
    '''
    file_path:bip loge :/home/ute/tcpdumpL2L1_filtering_off.pdml
    Documentation:git beamID list form bip log
    return:The number of msg2 in bip log
    '''
    # msg2_true = 1
    # is_find = 'locate'
    # with open(file_path, 'r') as f:
    #     file_path = parse(f)
    # for item in file_path.iterfind('packet'):
    #     if is_find == 'locate':
    #         for proto in item.iterfind('proto/proto'):
    #             if proto.get('name') == 'uldata_prachreceiveind':
    #                 is_find = 'find_showname'
    #                 break
    #     elif is_find == 'find_showname':
    #         for field in item.iterfind('proto/field'):
    #             if field.get('name') == 'mac-nr.context':
    #                 showname = field.get('showname')
    #                 is_find = 'calc'
    #                 break
    #     else:
    #         for field in item.iterfind('proto/field'):
    #             if field.get('showname') == showname:
    #                 msg2_true = msg2_true + 1
    #                 # is_find = False
    msg2_true = 0
    with open(file_path, 'r') as f:
        pdml_log_path = parse(f)
    for index, item in enumerate(pdml_log_path.iterfind('packet')):
        for field in item.iterfind('proto/field'):
            if field.get('showname') == 'Context (RNTI=99)':
                msg2_true = msg2_true + 1
    return msg2_true


def get_msg3(file_path):
    '''
    file_path:bip loge :/home/ute/tcpdumpL2L1_filtering_off.pdml
    Documentation:git msg3num form bip log
    return:the sum of msg3
    '''
    list = []
    msgnum = 1
    with open(file_path, 'r') as f:
        file_path = parse(f)
    for index, item in enumerate(file_path.iterfind('packet')):
        for proto in item.iterfind('proto/proto/'):
            if proto.get('name') == 'uldata_prachreceiveind':
                list.append(index)
    for msg1indexmin in range(len(list)):
        if msg1indexmin + 1 < len(list):
            msg1index_line_min = list[msg1indexmin]
            msg1indexmax = msg1indexmin + 1
            msg1index_line_max = list[msg1indexmax]
            msgnum = get_msg3_between_msg1(msg1index_line_min, msg1index_line_max, file_path, msgnum)
    return msgnum


def get_msg3_between_msg1(msg1index_line_min, msg1index_line_max, file_path, msgnum):
    for index, item in enumerate(file_path.iterfind('packet')):
        if index > msg1index_line_min and index < msg1index_line_max:
            for proto in item.iterfind('proto/proto'):
                if proto.get('name') == 'uldata_puschreceiveresplo':
                    msgnum = msgnum + 1
                    break
            else:
                continue
            break
        # else if :
        #     break
    # msgnum = 0
    # with open(pdml_log_path, 'r') as f:
    #     pdml_log_path = parse(f)
    # for index, item in enumerate(pdml_log_path.iterfind('packet')):
    #     for field in item.iterfind('proto/field/field'):
    #         if field.get('name') == 'mac-nr.control.crnti':
    #             msgnum = msgnum + 1
    return msgnum


def beamID_check(beamID_list, BeamID_counter):
    '''
    beamID_list:get beamID list from bip log,must be a dict
    BeamID_counter:git beamID list form counter log,must be a dict
    Documentation:to compare beamID_list and BeamID_counter whether equal
    return:equal is true,not is false
    '''
    beamID_list = dict_key(beamID_list)
    BeamID_counter = get_final_key(BeamID_counter)
    beamID_list, BeamID_counter = trans_to_str_dict(beamID_list), trans_to_str_dict(BeamID_counter)
    for key, value in BeamID_counter.items():
        if value == '0':
            del BeamID_counter[key]
    result = beamID_list == BeamID_counter
    return result


def trans_to_str_dict(file_path):
    '''
    file path:EXP:/home/ute/tcpdumpL2L1_filtering_off.pdml
    Documentation:to change key and value become string
    '''
    ret_dict = {}
    for key, value in file_path.items():
        ret_dict[str(key)] = str(value)
    return ret_dict


def dict_key(bip_dict):
    '''
    bip_dict:EXP:[0:1,1:2,2:3]
    return:[1:1,2:2,3:3]
    Documentation:change the dict key become key +1
    '''
    bip_dict_key_1 = {}
    for key, value in bip_dict.items():
        key = int(key) + 1
        bip_dict_key_1[str(key)] = str(value)
    return bip_dict_key_1


def get_beam_ID_sum(dict1, dict2):
    '''
    dict1,dict2 must be a dict
    Documentation:get the sum of dict1 add dict2
    '''
    dict_sum = dict(Counter(dict1) + Counter(dict2))
    return dict_sum


def check_ConfigurationIndex(pdml_log_path):
    ConfigurationIndex = 0
    with open(pdml_log_path, 'r') as f:
        pdml_log_path = parse(f)
    for index, item in enumerate(pdml_log_path.iterfind('packet')):
        for field in item.iterfind('proto/proto/field/field/field/field/field/field/field/field/field/field/field'):
            if field.get('name') == 'nr-rrc.prach_ConfigurationIndex':
                ConfigurationIndex = field.get('show')
                break
    return ConfigurationIndex


def check_RootSequenceIndex(pdml_log_path):
    RootSequenceIndex = 0
    with open(pdml_log_path, 'r') as f:
        pdml_log_path = parse(f)
    for index, item in enumerate(pdml_log_path.iterfind('packet')):
        for field in item.iterfind('proto/proto/field/field/field/field/field/field/field/field/field/field'):
            if field.get('name') == 'nr-rrc.prach_RootSequenceIndex':
                RootSequenceIndex = field.get('showname')
                break
    return RootSequenceIndex


def get_final_key(counter_key):
    counter_dict_key_1 = {}
    for key, value in counter_key.items():
        key = key[-1]
        counter_dict_key_1[str(key)] = str(value)
    return counter_dict_key_1
