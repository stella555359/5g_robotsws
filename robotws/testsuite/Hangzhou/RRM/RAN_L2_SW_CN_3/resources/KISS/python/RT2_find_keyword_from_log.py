# -*- coding: UTF-8 -*-
# author : zhangwenchao
# CreateDate : 2016-12-7

import re
import sys
import os
import pandas as pd
import logging
from robot.api import logger


def find_err_and_wrn_print_from_syslog(filepath, casename):
    data_all = []
    data_err = []
    data_wrn = []
    err_list = []
    wrn_list = []
    print_err = ''
    print_wrn = ''
    print_all = ''
    log_str = ''
    err_white_list = ['TDDPS', 'MACPS', 'PHY', 'UEC/', 'RROM/', 'CPLANE', 'EAaErrorFatality_Fatal']
    str_tmp = '|grep '.join(err_white_list)
    command1 = 'grep -e "ERR/" {}/btslog/btslog_*|grep {}'.format(filepath, str_tmp)
    err = os.popen(command1)
    for line in err.readlines():
        data_err.append('{}:'.format(str)+line.split('/')[-1])
        data_all.append(line)
        if 'btslog' in line:
            line = line.split(':', 1)[1]
        str_err = re.findall('>\\s(\\w+.*$)', line)
        err_list.append(str_err[0])
    wrn_white_list = ['TDDPS', 'MACPS']
    wrn_black_list = ['LTE1491', 'Drop unexpected Harq']
    str_tmp2 = '|grep '.join(wrn_white_list)
    str_tmp3 = '\\|'.join(wrn_black_list)
    command2 = 'grep -e "WRN/" {}/btslog/btslog_*|grep {}|grep -v "{}"'.format(filepath, str_tmp2, str_tmp3)
    wrn = os.popen(command2)
    for line in wrn.readlines():
        data_wrn.append('{}:'.format(str)+line.split('/')[-1])
        data_all.append(line)
        if 'btslog' in line:
            line = line.split(':', 1)[1]
        str_wrn = re.findall('>\\s(\\w+.*$)', line)
        wrn_list.append(str_wrn[0])
    for key, value in remove_duplicates(err_list).items():
        print_err += '<tr><td>error</td>' + '<td>{}</td>'.format(key.strip()) + '<td>{}</td>'.format(value)\
                   + '<td>{}</td>'.format(list_in_file(data_all, key.strip())) + '</tr>'
        if 'TDDPS' in key or 'MACPS' in key:
            log_str += "MAC error printer message:'{}', total count is {}\n".format(key.strip(), value)
            # logging.error("MAC error printer message:'{}', total count is {}".format(key.strip(), value))
    for key, value in remove_duplicates(wrn_list).items():
        print_wrn += '<tr><td>warning</td>' + '<td>{}</td>'.format(key.strip()) + '<td>{}</td>'.format(value) \
                     + '<td>{}</td>'.format(list_in_file(data_all, key.strip())) + '</tr>'
        if value >= 20:
            log_str += "waring printer message:'{}', total count is {}\n".format(key.strip(), value)
            # logging.warning("waring printer message:'{}', total count is {}".format(key.strip(), value))
    if print_err:
        print_all += print_err
    if print_wrn:
        print_all += print_wrn
    if print_all:
        html_str = '''<table border=1>
                        <tr><td>fault_type</td><td>detail_keyword_print</td><td>total_num</td><td>exist_file</td></tr>
                        {}
                        </table>
                        '''.format(print_all)
        logger.write(html_str, level='HTML', html=True)
    if log_str:
        str11 = '='*int((178-len(casename))/2)+casename+'='*int((178-len(casename))/2)
        str12 = '='*178
        logging.warning("{}\n{}\n{}".format(str11, log_str.strip(), str12))


def list_counter(listed, keyword):
    count = 0
    for element in listed:
        if keyword in element:
            count = count + 1
    return count


def list_in_file(listed, keyword):
    files = []
    for element in listed:
        if keyword.split('/')[-1] in element:
            files.append(element.split(':')[0].split('/')[-1])
    return " ".join(sorted(list(set(files))))


def remove_duplicates(data):
    import difflib
    new_data = {}
    temp_data = data
    while temp_data:
        num = len(temp_data)
        element = temp_data[0]
        same_data = difflib.get_close_matches(element, data, num, cutoff=0.6)
        temp_data = list(set(temp_data).difference(set(same_data)))
        new_data[element] = len(same_data)
    return new_data


def RT2_find_keyword_from_syslog(filename, regexp):
    """the keyword optimize grep file find large file issue
    :param filename:path
    :param regexp:
    :return:
    """
    datas = []
    with open(filename, 'rb') as f:
        lines = f.readlines()
        for line in lines:
            keyword = re.findall(regexp, line)
            if keyword:
                datas.append(line)
                logging.info(line)
        return datas


def RT2_find_keyword_num_from_syslog(filename, regexp):
    """the keyword optimize grep file find large file issue
    :param filename:path
    :param regexp:
    :return:
    """
    datas = []
    with open(filename, 'rb') as f:
        lines = f.readlines()
        for line in lines:
            keyword = re.findall(regexp, line)
            if keyword:
                datas.append(line)
                logging.info(line)
        return len(datas)


def RT2_get_frame_number_list_from_keyword_syslog(filename, regexp):
    lines = RT2_find_keyword_from_syslog(filename, regexp)
    frame_list = []
    for line in lines:
        frame_temp = re.findall('/\\d+/', line)
        frame = re.findall('\\d+', frame_temp[0])
        frame_list.append(frame[0])
    return frame_list


def RT2_get_time_list_from_keyword_syslog(filename, regexp):
    lines = RT2_find_keyword_from_syslog(filename, regexp)
    time_list = []
    for line in lines:
        time_temp = re.findall('T.*Z', line)
        time = re.findall('\\d+:\\d+:\\d+.\\d', time_temp[0])
        time = time[0].replace('.', ':')
        time_list.append(time)
    return time_list


def RT2_convert_time_to_ms(text):
    """the keyword is convert time to millsecond
    Example:
          RT2_convert_time_to_ms  |02:38:51:677  |
    """
    ms = 0
    regexp = '(\\d+):(\\d+):(\\d+):(\\d+)'
    time = re.match(regexp, text)
    if time is not None:
        ms = (int(time.group(1))*360+int(time.group(2))*60+int(time.group(3)))*1000+int(time.group(4))
    print(ms)


def RT2_get_filename_from_keyword(filepath, keyword):
    filenames = os.listdir(filepath)
    for filename in filenames:
        if filename[-3:] == 'csv':
            filename = filename.strip()
            pattern = re.compile(keyword, re.I)
            if re.findall(pattern, filename):
                return filename
            else:
                print("csv file not been found")


def RT2_replace_file_keyword(filename, regexp, targetkeyword):
    targetkeyword = targetkeyword.strip()
    sourcekeyword = RT2_find_keyword_from_syslog(filename, regexp)
    print("sourcefile is:%s" % (sourcekeyword))
    with open(filename, 'r') as r:
        lines = r.readlines()
    with open(filename, 'w+') as w:
        for line in lines:
            if re.search(sourcekeyword[0], line):
                w.write(line.replace(sourcekeyword[0], targetkeyword))
                w.write('\n')
            else:
                w.write(line)
        w.close()
    targetkeyword = RT2_find_keyword_from_syslog(filename, regexp)
    print("targetfile is:%s" % (targetkeyword))


def parse_ue_beam_ratio(file_path):
    datas = []
    with open(file_path, 'rb') as f:
        lines = f.readlines()
        for line in lines:
            pattern = 'T(\\d+\\:\\d+\\:\\d+\\.\\d+)Z.+crnti\\=(\\d+)\\,' \
                    'ueIndex\\=(\\d*)\\,beamIdx\\=(\\d*)\\,sectorGain\\=(\\-*\\d*(?:\\.\\d+)?)' \
                    '\\,signalGainDl\\=(\\-*\\d+(?:\\.\\d+)?)\\,signalGainUl\\=(\\-*\\d+(?:\\.\\d+)?)' \
                    '\\,eigValS\\=(\\-*\\d+(?:\\.\\d+)?)\\, \
                    doaH\\_M10\\=(\\-*\\d+(?:\\.\\d+)?)\\,doaV\\_M10\\=(\\-*\\d+(?:\\.\\d+)?)\\, \
                    UeBeamUlDlV\\=(\\-*\\d+(?:\\.\\d+)?)\\,SRSRcvs\\=(\\-*\\d+(?:\\.\\d+)?)'
            data = re.findall(pattern, line)
            if data:
                datas.append(data[0])
    return pd.DataFrame(list(datas), columns=['time', 'crnti', 'ueIndex', 'beamIdx', 'sectorGain', 'signalGainDl',
                                              'signalGainUl', 'eigValS', 'doaH_M10', 'doaV_M10', 'UeBeamUlDlV',
                                              'UeBeamUlDlV'])


if __name__ == '__main__':
    find_err_and_wrn_print_from_syslog(sys.argv[1], sys.argv[2])
    # RT2_find_keyword_from_syslog(sys.argv[1],sys.argv[2])
    # RT2_keyword_exist_current_syslog(sys.argv[1],sys.argv[2])
    # RT2_get_frame_number_list_from_keyword_syslog(sys.argv[1],sys.argv[2])
    # RT2_get_time_list_from_keyword_syslog(sys.argv[1],sys.argv[2])
    # RT2_convert_time_to_ms(sys.argv[1])
    # RT2_get_filename_from_keyword(sys.argv[1],sys.argv[2])
    # print(parse_ue_beam_ratio(sys.argv[1]))
    pass
