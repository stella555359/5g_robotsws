# -*- coding: utf-8 -*-
"""
:author: Xu Huamin.1
:contact: huamin.1.xu@nokia-sbell.com
"""
import logging
import os
import time


def dtx_crc_analysis(crc_list, dtx_list, id_list, sfn_idx):
    """
    :param crc_list     UlData_PuschReceiveRespHarqU.grants_item_0.crc
    :param dtx_list     UlData_PuschReceiveRespHarqU.grants_item_0.dtx
    :param id_list      UlData_PuschReceiveRespHarqU.grants_item_0.harqProcessIndex
    :param sfn_idx      the fisrt UlData_PuschReceiveRespHarqU sfn after 5GC000545 enabled
    """
    result_all = []
    bad_msg_cnt = 0
    for i in range(sfn_idx, len(crc_list)):
        result_all, tag = _check_msg_status(result_all=result_all, dtx=dtx_list[i], crc=crc_list[i], id=id_list[i])
        if tag == 'FAIL':
            bad_msg_cnt = bad_msg_cnt + 1
            logging.info("sfn no {} fail\r".format(i))
    for result in result_all:
        if result['STATUS'] == 'NOK':
            bad_msg_cnt = bad_msg_cnt + 1
            logging.info("ID {} failed in final status\r".format(result['ID']))
    logging.info("final ID status {}\r".format(result_all))
    return bad_msg_cnt


def _check_msg_status(result_all, dtx, crc, id):
    tag = 'SUCC'
    if dtx == '0' and crc == '0':
        status = 'OK'
    else:
        status = 'NOK'
    result = {'COUNTER': 0, 'STATUS': status, 'ID': id}
    if len(result_all) == 0:
        result_all.append(result)
    else:
        flag = _check_new_id_or_not(result_all=result_all, id=id)
        if flag == 'OLD':
            result_all, tag = _update_status_result(result_all=result_all, id=id, status=status)
        else:
            result_all.append(result)
    return result_all, tag


def _check_new_id_or_not(result_all, id):
    flag = 'NEW'
    for result in result_all:
        if result['ID'] == id:
            flag = 'OLD'
            break
    return flag


def _update_status_result(result_all, id, status):
    tag = 'SUCC'
    for result in result_all:
        if result['ID'] == id:
            if result['STATUS'] == status:
                result['COUNTER'] = result['COUNTER'] + 1
            else:
                result['COUNTER'] = 0
                result['STATUS'] = status
            if result['COUNTER'] >= 4 and result['STATUS'] == 'NOK':
                result['COUNTER'] = 0
                result['STATUS'] = 'OK'
                tag = 'FAIL'
                logging.info("ID {} failed to retransmit 5 times\r".format(id))
            break
    return result_all, tag
