#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
:copyright: NOKIA
:author: bartosz.rutkowski@nokia.com
"""

import json
import datetime
import pytz
import random
from dateutil import parser
from robot.api import logger


def extract_values_from_sas_log(log_name, parameter, cbsd_id='', data_type='',
                                start_from='', packet_amount=0, skip_packets=0):
    """ return all values of given key, does not matter on which level
        :author: bartosz.rutkowski@nokia.com
        :param log_name:        json object on which extracting should be done, should be parsed sas_log file
        :param data_type:       filter for packet name,
                                eg. data_type=heartbeatResponse will search only for heartbeatResponse
        :param parameter:       searched key, its value will be returned as a list
        :param cbsd_id:         will filter messages with given cbsdId parameter (only works on firs level)
        :param start_from:      will skip packet until given one appears, eg. start_from=heartbeatResponse
        :param packet_amount:   will skip packets that appear after packet_amount value, works if data_type is given
                                eg. packet_amount=2 will check only two packets, packet_amount=0 to check all packets
        :param skip_packets:    will skip x first messages where x = skip_packets value, works if data_type is given
        :return:                list of extracted key values
    """
    arr = []

    def extract(log_name, arr, parameter):
        if isinstance(log_name, dict):
            for k, v in list(log_name.items()):
                if isinstance(v, (dict, list)):
                    extract(v, arr, parameter)
                if k == parameter:
                    arr.append(v)
        elif isinstance(log_name, list):
            for item in log_name:
                extract(item, arr, parameter)

        return arr

    if start_from:
        new_log = []
        skip = True
        for item in log_name:
            if start_from in list(item.keys()):
                skip = False
            if skip:
                continue
            else:
                new_log.append(item)
        log_name = new_log

    if data_type:
        log_name = [i for i in log_name if data_type in list(i.keys())]

    if cbsd_id:
        new_log = []
        for i in log_name:
            for n in list(i.keys()):
                if isinstance(i[n], (dict, list)):
                    for d in i[n]:
                        if 'cbsdId' in list(d.keys()):
                            if d['cbsdId'] == cbsd_id:
                                new_log.append(i)
        log_name = new_log

    if packet_amount and data_type:
        log_name = log_name[:int(packet_amount)]

    if skip_packets and data_type:
        log_name = log_name[int(skip_packets):]

    return extract(log_name, arr, parameter)


def parse_sas_log_file(log_file_name, date_start, date_stop, time_offset=0, time_zone='Europe/Bucharest',
                       verbose=False):
    """  will parse sas log and create json instead
        :author: bartosz.rutkowski@nokia.com
        :param log_file_name:   original sas log file path
        :param date_start:      date-time from which parsing will start
        :param date_stop:       date-time on which parsing will stop
        :param time_offset:     workaround for sas time difference
        :param time_zone:       local timezone to match the datetime with sas
        :param verbose:         if true will output to console parsed json content
        :return:                parsed log in json format
    """
    with open(log_file_name, 'r') as f:
        logfile = []
        j = ''
        date = ''
        for line in f:
            line = line.replace('/n', '')
            line = line.replace('\n', '')
            line = line.replace('/r', '')
            line = line.replace('\r', '')
            if '[INFO]' in line:
                log_date = fix_date(line[0:19])
                data_type = 'info'
                info_pos = line.find('[INFO]') + 6
                data_value = line[info_pos:].strip()
                if date_start <= log_date <= date_stop:
                    logfile.append({'date': log_date, data_type: data_value})
                    date = log_date
            if '[DEBUG]' in line:
                log_date = fix_date(line[0:19])
                data_type = 'debug'
                debug_pos = line.find('[DEBUG]') + 7
                data_value = line[debug_pos:].strip()
                if date_start <= log_date <= date_stop:
                    logfile.append({'date': log_date, data_type: data_value})
                    date = log_date
            if '[WARNING]' in line:
                log_date = fix_date(line[0:19])
                data_type = 'warning'
                warning_pos = line.find('[WARNING]') + 9
                data_value = line[warning_pos:].strip()
                if date_start <= log_date <= date_stop:
                    logfile.append({'date': log_date, data_type: data_value})
                    date = log_date
            if 'Date:' in line:
                line = line.replace('Date: ', '')
                line = line.replace(',', '')
                date = parser.parse(line)
                date = date + datetime.timedelta(hours=time_offset)
                date = date.astimezone(pytz.timezone(time_zone))
                date = date.strftime('%Y-%m-%d %H:%M:%S')
                if date_start <= date <= date_stop:
                    continue
                else:
                    date = ''
            if '{"' in line and date != '':
                j = json.loads(line)  # TODO add try-exception to drop malformed packets
                k = list(j.keys())
                logfile.append({'date': date, k[0]: j[k[0]]})  # number of keys should be always 1
        t = datetime.datetime.now().strftime('%Y%m%d_%H%M%S')
        with open('sas_log_parsed_' + t + '.json', 'w') as write_file:
            json.dump(logfile, write_file, indent=4)
        if verbose:
            for item in logfile:
                if 'info' not in list(item.keys()) and \
                        'warning' not in list(item.keys()) and \
                        'debug' not in list(item.keys()):
                    for i in list(item.keys()):
                        if i != 'date':
                            if i == 'eventType':
                                logger.console('{} {} '.format(item['date'], item[i]))
                            else:
                                logger.console('{} {} '.format(item['date'], i))
        return logfile


def communication_CBSD_SAS(SAS_Sim_log_file, time_offset=0, time_zone='Europe/Bucharest'):
    """  will parse sas log and in first place will create list of json-like objects in file,
         which contain dates and CBSD-SAS communication and then will create object request_response_list which
         is a list of CBSD-SAS requests and responses with date and time and response codes from SAS responses
        :author: justyna.durak@nokia.com
        :param SAS_log_file:   SAS Simulator log file path
        :param time_offset:    workaround for sas time difference
        :param time_zone:      local timezone to match the datetime with sas
        :return:               list of CBSD-SAS requests and responses with date and time and response codes from SAS
    """
    with open(SAS_Sim_log_file, 'r') as f:
        communication_file = []
        request_response_list = []
        j = ''
        date = ''
        for line in f:
            line = line.replace('/n', '')
            line = line.replace('\n', '')
            line = line.replace('/r', '')
            line = line.replace('\r', '')
            if 'Date:' in line:
                line = line.replace('Date: ', '')
                line = line.replace(',', '')
                date = parser.parse(line)
                date = date + datetime.timedelta(hours=time_offset)
                date = date.astimezone(pytz.timezone(time_zone))
                date = date.strftime('%Y-%m-%d %H:%M:%S')
            if '{"' in line and date != '':
                j = json.loads(line)
                k = list(j.keys())
                communication_file.append({'date': date, k[0]: j[k[0]]})
        t = datetime.datetime.now().strftime('%Y%m%d_%H%M%S')
        with open('communication_CBSD_SAS_' + t + '.json', 'w') as write_file:
            json.dump(communication_file, write_file, indent=4)
        for item in communication_file:
            for i in list(item.keys()):
                if i != 'date':
                    if i == 'eventType':
                        request_response_list.append('{} {} '.format(item['date'], item[i]))
                    else:
                        if 'Response' in i:
                            response_codes = extract_values_from_sas_log(
                                log_name=[item],
                                parameter='responseCode',
                                data_type=i
                            )
                            request_response_list.append('{} {} {}'.format(item['date'], i, response_codes))
                        else:
                            request_response_list.append('{} {}'.format(item['date'], i))
        return request_response_list


def query_sas_log(log_name, data_type, parameter='', value='', parameter_count=1, start_from=''):
    """  search for specific parameter value in given data_type packet, it will iterate data_type list and
         check every item on the list only one match is needed, only one level deep after data_type,
        :author: bartosz.rutkowski@nokia.com
        :param log_name:         json parsed from sas log
        :param data_type:        filter for packet name, eg. data_type=heartbeatResponse search only for HBResponse
        :param parameter:        key for searching
        :param value:            value of key for searching, can be list, or dict etc.
        :param parameter_count:  minimum number of parameter occurrence in a data_type
        :param start_from:       will wait until start from packet is encountered
        :return:                 return True or raise exception
    """
    # todo should load json automatically if given as a value
    result = False
    # if not isinstance(value, dict) and not isinstance(value, list) and '.json' in value:
    #     if os.path.isfile(value):
    #         with open(value, 'r') as f:
    #             value = json.load(f)

    if start_from:
        new_log = []
        skip = True
        for item in log_name:
            if start_from in list(item.keys()):
                skip = False
            if skip:
                continue
            else:
                new_log.append(item)
        log_name = new_log

    for item in log_name:
        if data_type in list(item.keys()):  # if data_type requested is in sas dictionary
            if data_type == 'info' or data_type == 'warning' or data_type == 'debug':
                if item[data_type] == value:
                    logger.debug('{} = {}'.format(data_type, item[data_type]))
                    return True
            else:
                li = [True for i in item[data_type] if i[parameter] == value]
                parameter_count = int(parameter_count)
                if li.count(True) >= parameter_count:
                    result = True
                logger.debug('{} {} {} {}'.format(data_type, parameter, value, result))
    if result:
        logger.debug('{}/{} = TRUE'.format(data_type, parameter))
    else:
        raise Exception('Parameter missing or value mismatch: {}/{}={}'.format(data_type, parameter, value))


def sas_grantexpiretime_should_be_grater_than_transmitexpiretime(log_name):
    """
    :copyright: NOKIA
    :author: aleksandra.dagiel@nokia.com
    """
    ret = True
    for item in log_name:
        if 'heartbeatResponse' in list(item.keys()):
            for i in item['heartbeatResponse']:
                if 'transmitExpireTime' in list(i.keys()) and 'grantExpireTime' in list(i.keys()):
                    logger.debug('heartbeat response: {}'.format(i))
                    if i['transmitExpireTime'] < i['grantExpireTime']:
                        logger.debug('The grantExpireTime ' + i[
                            'grantExpireTime'] + ' is assigned and greater than the transmitExpireTime ' + i[
                                         'transmitExpireTime'])
                    elif i['grantExpireTime'] > i['transmitExpireTime']:
                        logger.debug('The grantExpireTime ' + i[
                            'grantExpireTime'] + ' is assigned bit is NOT greater than the transmitExpireTime ' + i[
                                         'transmitExpireTime'])
                        ret *= False
                else:
                    logger.debug('Parameter transmitExpireTime or grantExpireTime does not exist.')
                    # ret = False
    if not ret:
        raise Exception('Parameter heartbeatResponse or ExpireTime key is missing')


def fix_date(log_date):
    log_date = '{}-{}-{}{}'.format(log_date[6:10], log_date[0:2], log_date[3:5], log_date[10:])
    return log_date


def clear_sas_logs(logs):
    # todo remove if not used
    """ Michal Kosicki keyword to clear debug and info logs """
    messages_list = ["registrationRequest", "registrationResponse", "deregistrationRequest", "deregistrationResponse",
                     "spectrumInquiryRequest", "spectrumInquiryResponse", "grantRequest", "grantResponse",
                     "heartbeatRequest", "heartbeatResponse", "relinquishmentRequest", "relinquishmentResponse"]
    filtered_logs = []
    for message in logs:
        for key in list(message.keys()):
            if key in messages_list:
                filtered_logs.append(message)
                break
    return filtered_logs


def get_encrypted_packets(pcap_file_path):
    """ Michal Kosicki, duplicated """
    # todo remove if not used
    pcap_file = open(pcap_file_path)
    lines = []
    pcap_file = pcap_file.readlines()
    for line in pcap_file:
        lines.append(line.replace("\n", ""))
    packets = []
    i = 0
    while True:
        if i == len(lines):
            break
        if "Decrypted SSL" in lines[i]:
            packet = ""
            while lines[i] != "":
                packet += lines[i][56:]
                i += 1
            packets.append(packet)
        else:
            i += 1
    j = 0
    while j != len(packets):
        if "HTTP" not in packets[j]:
            del packets[j]
        else:
            j += 1
    return packets


def get_json_from_packets(packets):
    """ Michal Kosicki keyword, duplicated """
    # todo remove if not used
    packets_output = []
    for packet in packets:
        index = packet.index("{")
        packets_output.append(json.loads(packet[index:]))
    return packets_output


def generate_supported_spectrum_v2(bw_5, bw_10, bw_15, bw_20):
    """ This keyword generate random value of supportedSpectrumV2 for delta plan
        :author: marek.kot@nokia.com
        :param bw_x:         amount of cells x MHz
    """
    cells_list = int(bw_20) * [4] + int(bw_15) * [3] + int(bw_10) * [2] + int(bw_5) * [1]
    available_space = 31 - sum(cells_list)
    supported_spectrum = list(range(30))
    grants = []

    for cell in cells_list:
        space = random.randrange(available_space)
        available_space -= space
        supported_spectrum = supported_spectrum[space:]
        grants += supported_spectrum[:cell]
        supported_spectrum = supported_spectrum[cell:]

    value = sum([2 ** i for i in grants])
    return value


if __name__ == '__main__':
    # parse_sas_log_file(log_file_name='SAS_Sim.log',
    #                    date_start='2020-04-29 14:30:00',
    #                    date_stop='2020-04-29 14:37:00',
    #                    verbose=True)
    # with open('sas_log_parsed.json', 'r') as f:
    #     json_file = json.load(f)
    # a = extract_values_from_sas_log(log_name=json_file,
    #                                 parameter='cbsdId',
    #                                 cbsd_id='mrtbs-100834_2_1M185005009',
    #                                 data_type='heartbeatResponse',
    #                                 packet_amount=3,
    #                                 skip_packets=1)
    # print('\n'.join(map(str, a)))
    pass
