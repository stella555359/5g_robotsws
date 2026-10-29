# -*- coding: utf-8 -*-
"""
:copyright: Nokia
:author: Chen Jin Emily
:maintainer: None
:contact: None
"""

import os
import re
import time
import sys
import logging
import pkg_resources
import subprocess as sp
from enb_access import get_bbu_type
from enb_access import get_active_bts_sw_version
from download_pstool import DownloadPStools

get_tools_path1 = '{}/'.format(pkg_resources.resource_filename(__name__, "tools"))
get_tools_path2 = '/opt/TtiTracer/pstools/TtiTracer/onlineTtiStream/'
get_tools_path = get_tools_path2 if os.path.exists(get_tools_path2) else get_tools_path1
_start = False


def _get_tti_path():
    sw_build = get_active_bts_sw_version()
    if os.name == "nt":
        pstools_for_TA = 'c:\\pstools_for_TA'
        push_tool = '%s\\%s' % (pstools_for_TA, sw_build)
    else:
        pstools_for_TA = '/home/ute/pstools_for_TA'
        push_tool = '%s/%s' % (pstools_for_TA, sw_build)
    if not os.path.exists(push_tool):
        from download_pstool import DownloadPStools
        DownloadPStools(sw_build)
    if not os.path.exists(push_tool):
        import glob
        version_list = glob.glob(os.path.join(pstools_for_TA, 'TL*'))
        if not version_list:
            raise Exception("No any version's pstools exist!")
        version_list.sort()
        logging.info(version_list)
        latest_push_tool = os.path.join(version_list[-1])
        logging.warning(
            "Not find %s, will use latest %s" %
            (push_tool, latest_push_tool))
        push_tool = latest_push_tool
    if not os.path.exists(push_tool):
        raise Exception("no ttistream tool exist")
    logging.info("use tool as %s" % push_tool)
    final_path = push_tool
    os.chdir(final_path)
    if os.name != "nt":
        os.system("chmod 777 *")
    return final_path


def _kill_15003_process():
    lines = os.popen("sudo netstat -anp | grep 15003").read().splitlines()
    for line in lines:
        if "Stream" in line:
            pid = line.split()[-1].split('/')[0]
            os.system("kill -9 %s" % pid)


def start_capture_ttitrace(save_log_path, cell_id="ALL"):
    """This keyword start capture ttitrace log by ttistream
    | Input Parameters  | Man. |  Description                |
    | save_log_path     | Yes  |  downloaded ttitrace save log folder path  |
    | cell_id           | No   |  default as "ALL" |
    Example
    | ${process_obj} | start_capture_ttitrace | d:\\ttiTrace |
    | stop_capture_ttitrace | ${process_obj} |
    once no bts version's pstool exist in c:\\pstools_for_TA or /home/ute/pstools_for_TA,
    Please go http://hzjenv01.china.nsn-net.net:8080/job/Everything_get_pstools to check by manual,
    "Build with Parameters" give your testline info such as 1.1.1.1;ute;ute
    if you regist the testline in report server's testbed. the jenkins will push the tool automately.
    https://twiki.int.net.nokia.com/bin/view/LTEMACTDD/PsTools#TtiTrace
    currently we use -c xxxx,xxxx to get ttitrace log, and -c can't make sure core ul dl could be distinguish.
    so a2a pdm do not add ul dl because sometime the file could not be found
    if no throughput, no log saved.
    """
    mac_address = get_mac_tti_address(cell_id)
    if not os.path.exists(save_log_path):
        os.mkdir(save_log_path)
    obj = _start_ttitrac(mac_address,
                         save_log_path
                         )
    logging.info(os.popen("sudo netstat -anp | grep 15003").read())
    return obj, save_log_path


def stop_capture_ttitrace(process_obj):
    """This keyword stop capture ttitrace log by ttistream
    | Input Parameters  | Man. |  Description                |
    | process_obj     | Yes  |  the return value from start_capture_ttitrace  |
    Example
    | ${process_obj} | start_capture_ttitrace | d:\\ttiTrace |
    | stop_capture_ttitrace | ${process_obj} |
    """
    if process_obj != '':
        logging.info(os.popen("sudo netstat -anp | grep 15003").read())
        process_obj.stdin.write(os.linesep)
        # process_obj.communicate(os.linesep)
        logging.info(os.popen("sudo netstat -anp | grep 15003").read())
        # logging.info(process_obj.stdout.read())
    else:
        logging.info('ttitrace process is not exist !')


def _get_extra_option(tti_path):
    # this part for ttistream version >= 12941 need to add option '-x 4'
    add_option = ""
    check_version_cmd = "%s -V" % tti_path
    ret = os.popen(check_version_cmd).read()
    logging.info(ret)
    # "ret should be ttiStream.exe: SVN_REVISION: 11224 (MD1_PS_REL_2015_02_025)"
    tmp = re.search("SVN_REVISION: (\\d+)", ret)
    if tmp:
        if int(tmp.group(1)) >= 12941:
            add_option = "-x 4"
    return add_option


def _start_ttitrac(dsp_id_group, save_log_path):
    """This keyword start sicftp, generate mac TTI Trace file
    | Input Parameters  | Man. |  Description                |
    | dsp_id            | Yes  | dsp id in FCMD   |
    | save_log_path   | Yes  |  downloaded ttitrace log path  |
    | dump_method        | No   |  the ttitrace log fetch method, default is SICFTP |
    Example
    | _dump_mac_ttitrace | '1243' | 'd:\\ttiTraceUL_20111201203759.dat' |
    """
    if os.name != 'nt':
        _kill_15003_process()
    bbu_type = get_bbu_type()
    if bbu_type == 'ASIA' or bbu_type == 'ASIB':
        tti_name = "onlineTtiStream.exe" if os.name == 'nt' else "onlineTtiStream"
    else:
        tti_name = "ttiStream.exe" if os.name == 'nt' else "ttiStream"
    sicftp_path = os.path.join(get_tools_path, tti_name)
    add_option = _get_extra_option(sicftp_path)
    download_cmd = "%s -p toor4nsn@oZPS0POrRieRtu -c %s %s -o \"%s%s%s\"" % (sicftp_path,
                                                                             dsp_id_group,
                                                                             add_option,
                                                                             save_log_path,
                                                                             os.sep, os.sep)
    logging.info(download_cmd)
    process_obj = sp.Popen(download_cmd,
                           stdin=sp.PIPE,
                           shell=True,
                           stdout=sp.PIPE,
                           stderr=sp.PIPE)
    return process_obj


def dump_mac_ttitrace(save_log_path, cell_id="ALL", dump_method='SICFTP'):
    """This keyword start sicftp, generate mac TTI Trace file
    | Input Paameters  | Man. |  Description                |
    | save_log_path     | Yes  |  save log full path could be ${TEST_LOG_DIR} |
    | cell_id           | No  |  if only capture cared cell id's ttitrace, default as all cell's |
    | dump_method       | No  |  Default as 'SICFTP'          |
    Example
    | get mac ttitrace | d:\\ttitrace_20140914 | 4097 |
    Explain for realize process:\n
    once no bts version's pstool exist in c:\\pstools_for_TA or /home/ute/pstools_for_TA,
    Please go http://hzjenv01.china.nsn-net.net:8080/job/Everything_get_pstools to check by manual,
    "Build with Parameters" give your testline info such as 1.1.1.1;ute;ute
    if you regist the testline in report server's testbed. the jenkins will push the tool automately.
    https://twiki.int.net.nokia.com/bin/view/LTEMACTDD/PsTools#TtiTrace
    currently we use -c xxxx,xxxx to get ttitrace log, and -c can't make sure core ul dl could be distinguish.
    so a2a pdm do not add ul dl because sometime the file could not be found
    if no throughput, no log saved.
    """
    if os.name != 'nt':
        _kill_15003_process()
    # mac_address = get_mac_tti_address(cell_id)
    if not os.path.exists(save_log_path):
        os.mkdir(save_log_path)
    # _dump_mac_ttitrac_once(mac_address, save_log_path, dump_method)
    process_obj, save_log_path = start_capture_ttitrace(save_log_path, cell_id)
    time.sleep(5)
    stop_capture_ttitrace(process_obj)


def _dump_mac_ttitrac_once(dsp_id_group, save_log_path, dump_method='SICFTP'):
    """This keyword start sicftp, generate mac TTI Trace file
    | Input Parameters  | Man. |  Description                |
    | dsp_id            | Yes  | dsp id in FCMD   |
    | save_log_path   | Yes  |  downloaded ttitrace log path  |
    | dump_method        | No   |  the ttitrace log fetch method, default is SICFTP |
    Example
    | _dump_mac_ttitrace | '1243' | 'd:\\ttiTraceUL_20111201203759.dat' |
    """
    sic_name = "sicftp.exe" if os.name == "nt" else "sicftp"
    sicftp_path = os.path.join(get_tools_path, sic_name)
    if str(dump_method).strip().upper() == 'SICFTP':
        download_cmd = "%s -r -c %s -o \"%s%s%s\"" % (sicftp_path, dsp_id_group, save_log_path, os.sep, os.sep)
    else:
        raise Exception("TtiTrace tool %s doesn't recognize!" % dump_method)
    logging.info(download_cmd)
    ret = os.popen(download_cmd).read()
    logging.info(ret)
    import glob
    dat_list = glob.glob(os.path.join(save_log_path, '*.dat'))
    # check if download success
    if len(dat_list) > 0:
        logging.info("Download TtiTrace from %s success! -> %s" % (dsp_id_group, save_log_path))
    else:
        raise Exception("Download ttiTrace dat size = 0!")
    return save_log_path


def decode_mac_ttitrace(save_log_path):
    """This keyword run trace_parser and trace_converter, get .csv file
    | Input Parameters        | Man. | Description         |
    | save_log_path           | Yes  | path of log file    |
    Example
    | decode_mac_ttitrace | D:\\ttiTrace_20140914 |
    once no bts version's pstool exist in c:\\pstools_for_TA or /home/ute/pstools_for_TA,
    Please go http://hzjenv01.china.nsn-net.net:8080/job/Everything_get_pstools to check by manual,
    "Build with Parameters" give your testline info such as 1.1.1.1;ute;ute
    if you regist the testline in report server's testbed. the jenkins will push the tool automately.
    """
    sw_build = get_active_bts_sw_version()
    if os.name == "nt":
        tti_trace_parser = "DevC_tti_trace_parser.exe"
        pstools_for_ta = 'c:\\pstools_for_TA'
        push_parser = '%s\\%s\\%s' % (
            pstools_for_ta, sw_build, tti_trace_parser)
    else:
        tti_trace_parser = "DevC_tti_trace_parser"
        pstools_for_ta = '/home/ute/pstools_for_TA'
        push_parser = '%s/%s/%s' % (pstools_for_ta, sw_build, tti_trace_parser)
    if not os.path.exists(push_parser):
        DownloadPStools(sw_build)
        os.system('chmod 777 /home/ute/pstools_for_TA/%s/*' % sw_build)
        os.system('cp /home/ute/pstools_for_TA/%s/onlineTtiStream %s' % (sw_build, get_tools_path))
    if not os.path.exists(push_parser):
        import glob
        version_list = glob.glob(os.path.join(pstools_for_ta, 'SBTS*'))
        version_list.sort()
        logging.info(version_list)
        latest_version = os.path.join(version_list[-1], tti_trace_parser)
        logging.warning(
            "Not find %s, will use latest %s" %
            (push_parser, latest_version))
        ttitrace_parser_tool = latest_version
    else:
        ttitrace_parser_tool = push_parser
    if not os.path.exists(save_log_path):
        raise Exception("log folder is not exist in %s" % save_log_path)
    ascii_trace_log = os.path.join(save_log_path, "ascii_ttitrace.log")
    import glob
    dat_list = glob.glob(os.path.join(save_log_path, '*.dat'))
    if not dat_list:
        raise Exception("not find any .dat files, nothing can be decode")
    for dat_file in dat_list:
        decode_cmd = "%s \"%s\" \"%s\" " % (ttitrace_parser_tool,
                                            dat_file,
                                            dat_file.replace(".dat", ".csv")
                                            )
        logging.info("Execute command: '%s'" % decode_cmd)
        ret = os.popen(decode_cmd).read()
        logging.info(ret)


def _get_mac():
    cmd = "{} -p toor4nsn@oZPS0POrRieRtu -f".format(os.path.join(get_tools_path, 'onlineTtiStream'))
    os.system('sudo chmod 777 {}'.format(os.path.join(get_tools_path, 'onlineTtiStream')))
    response = os.popen(cmd)
    return response


def get_mac_tti_address(cell="ALL", node_type='ALL'):
    macultti = 'ul'
    macdltti = 'dl'
    cell_id = 'cellId'
    response = _get_mac()
    value_list = []
    useful_index = {}
    mac_address_dict = {}
    for line in response.readlines():
        tmp = line.split()
        if len(tmp) > 5:
            value_list.append(tmp)
    for value in value_list:
        if 'isTDD:1' in value:
            for item in value:
                item_s = item.split(':')
                useful_index[item_s[0]] = item_s[1]
            mac_ul = useful_index[macultti][2:]
            mac_dl = useful_index[macdltti][2:]
            mac_address_dict[useful_index[cell_id]] = [mac_dl, mac_ul]
    if cell == 'ALL':
        all_address = []
        for add in mac_address_dict.keys():
            if node_type == 'ALL':
                all_address += mac_address_dict[add]
            elif node_type == 'UL':
                all_address.append(mac_address_dict[add][1])
            elif node_type == 'DL':
                all_address.append(mac_address_dict[add][0])
        return ','.join(list(set(all_address)))
    else:
        if node_type == 'ALL':
            return ','.join(list(mac_address_dict[cell]))
        elif node_type == 'UL':
            return mac_address_dict[cell][1]
        elif node_type == 'DL':
            return mac_address_dict[cell][0]


def _get_mac_cell_mapping():
    macultti = 'MACULTTI'
    macdltti = 'MACDLTTI'
    cell_id = 'lnCel'
    response = _get_mac()
    value_list = []
    useful_index = {}
    for line in response.readlines():
        tmp = line.split()
        if len(tmp) > 8:
            value_list.append(tmp)
    for value in value_list:
        if macultti in value and \
            (macdltti in value) and \
                (cell_id in value):
            useful_index[macultti] = value.index(macultti)
            useful_index[macdltti] = value.index(macdltti)
            useful_index[cell_id] = value.index(cell_id)
            value_list.remove(value)
    cell_mapping = {}
    for value in value_list:
        cell_mapping[value[useful_index[macultti]][2:]] = 'cell'+value[useful_index[cell_id]]
        cell_mapping[value[useful_index[macdltti]][2:]] = 'cell' + value[useful_index[cell_id]]
    return cell_mapping


if __name__ == '__main__':
    # process_obj= start_capture_ttitrace(save_log_path='/home/ute/zhangwenchao/temp/')
    # time.sleep(10)
    # stop_capture_ttitrace(process_obj[0])
    # print(get_mac_tti_address())
    # print 'pid',_kill_15003_process()
    # print get_mac_tti_address()
    # print(get_mac_cell_mapping())
    # decode_mac_ttitrace('/TA/robot_log/Test_Log_20210713042429/ev_logs/LTE5657-C-b_01_03_10Mhz_Bbpool_UL_16_Layers_M \
    # U_Tra_202107130424/LTE5657-C-b_01_03_10Mhz_Bbpool_UL_16_Layers_MU_Tra/ttitrace_2')
    pass
