#!/usr/bin/python
# Note: This file is no longer in use, origin path: testsuite/Nanjing/OAM/Resources/python/smawave_operation.py

import re
import os
import logging
import random
import subprocess
import sshtunnel
from taf.sbts.oam.coam.admin import admin


def verify_atcmd_output(input_string):
    """
    This method used to verify the output of command AT+COPS?
    :param input_string: AT command output from openwrt
    :return one of 5G/4G/Idle, None otherwise
    """
    logging.info("The original output to be verified is : {0}".format(input_string))
    new_string = re.sub('\r|\n', '', input_string)
    logging.info("Updated output to be verified is : {0}".format(new_string))
    result = re.match("\\+COPS:\\s*0,\\d+,\"([^\"]*)\",(\\d*)OK", new_string)
    if result and (result.group(2) == '13' or result.group(2) == '11'):
        return '5G'
    elif result and result.group(2) == '7':
        return '4G'
    else:
        ret = re.match("\\+COPS:\\s*\\d?OK", new_string)
        return 'Idle' if ret else None


def verify_attach_status(input_value):
    """
    This method used to verify smawave UE attach status
    :param input_value: output of verify_atcmd_output method
    :return Attach, Error_status otherwise
    """
    return 'Attach' if input_value in ['4G', '5G'] else 'Error_status'


def parse_iperf_trace_to_rows(file_to_be_parsed, parallel_streams=False, get_datagram_loss=False):
    """
    Parses lines from iperf output file into specific rows
    :param file_to_be_parsed: iperf output file
    :param parallel_streams: parse it like parallel streams iperf output
    :return: valid rows list without the last summary row
    """
    if os.path.exists(file_to_be_parsed):
        valid_rows, rows = [], []
        index = 0
        with open(file_to_be_parsed, 'r') as FH:
            for item in FH:
                row = IperfServerReportRow(item, index, parallel_streams, get_datagram_loss)
                if row.correct and 'nan' not in item:
                    rows.append(row)
                index += 1
        if rows:
            logging.info("Rows parsed: \n {0}".format("\n".join([row.line for row in rows])))
            if rows[-1].interval_start == '0.0' and rows[-1].interval_end != '1.0':
                logging.debug("Summary row detected {0}.".format(rows[-1].line))
                valid_rows = rows[:-1]
            else:
                valid_rows = rows
            return valid_rows
        else:
            logging.error("The parsed list is empty, data transfer can't be reached, please check!")
            return "EMPTY"
    else:
        logging.error("The Iperf output file {0} is not exist!".format(file_to_be_parsed))
        return "EMPTY"


def count_average_throughput(iperf_row_list):
    """
    Counts average throughput based on iperf server output
    :param iperf_row_list: list of IperfServerReportRow instances
    :return: average T-put based on iperf server output
    """
    tput_list = ["{0}{1}".format(row.bandwidth_amount, row.bandwidth_unit) for row in iperf_row_list]
    print("detailed traffic list: {0}".format(tput_list))
    bandwidth_amount = []
    for row in iperf_row_list:
        if row.bandwidth_unit == "M":
            bandwidth_amount.append(float(row.bandwidth_amount))
        elif row.bandwidth_unit == "G":
            bandwidth_amount.append(float(row.bandwidth_amount) * 1024)
        elif row.bandwidth_unit == "K":
            bandwidth_amount.append(float(row.bandwidth_amount) / 1024)
    total_tput = sum([float(row_bandwidth_amount) for row_bandwidth_amount in bandwidth_amount])
    average = round((total_tput / len(bandwidth_amount)), 1)
    average_tput = "{0}{1}".format(average, "M")
    return average_tput


def check_Tput_with_deviation(expect_tput, average_tput, deviation):
    """
    Check average throughput is in desired expected range
    :param expect_tput: expected throughput
    :param average_tput: actual average throughput
    :param deviation: acceptable deviation
    :return: True or False
    """
    number_of_deviation = deviation.rstrip('%')
    expect_tput = float(expect_tput.rstrip('M'))
    average_tput = float(average_tput.rstrip('M'))
    deviation_as_float = int(number_of_deviation)
    min_acceptable_tput = expect_tput - (expect_tput * deviation_as_float / 100)
    max_acceptable_tput = expect_tput + (expect_tput * deviation_as_float / 100)
    if average_tput < min_acceptable_tput or average_tput > max_acceptable_tput:
        logging.error("Average T-Put [{0}] is NOT in desired range.expected range is {1}-{2}".format(
                                             average_tput, min_acceptable_tput, max_acceptable_tput))
        return 'Failure'
    else:
        logging.info("Average T-Put [{0}] is in desired range.".format(average_tput))
        return 'Success'


def count_average_jitter(iperf_row_list):
    """
    Counts average jitter based on iperf server output
    :param iperf_row_list: list of IperfServerReportRow instances
    :return: average jitter based on iperf server output
    """
    valid_row_list = [row for row in iperf_row_list if hasattr(row, 'udp_part')]
    if valid_row_list:
        jitter_unit = valid_row_list[1].jitter_unit
        total_jitter = sum([float(row.jitter) for row in valid_row_list])
        average_jitter = total_jitter / len(valid_row_list)
        return round(average_jitter, 4), jitter_unit


def count_datagram_loss(iperf_row_list):
    """
    Counts percentage of lost datagram during UDP data transfer
    :param iperf_row_list: list of IperfServerReportRow instances
    :return: datagram loss rate and total datagram loss
    """
    valid_udp_rows = [row for row in iperf_row_list if hasattr(row, 'udp_part')]
    if valid_udp_rows:
        total_lost_datagrams = sum([int(row.lost_datagrams) for row in valid_udp_rows])
        total_datagrams = sum([int(row.total_datagrams) for row in valid_udp_rows])
        if total_datagrams == 0:
            logging.error('Server report: None of the datagram received')
            return None
        return total_lost_datagrams, round(float(total_lost_datagrams) / total_datagrams, 4) * 100


class IperfServerReportRow(object):
    """Class representing row in Iperf report"""
    def __init__(self, line, index=-1, parallel_streams=False, get_datagram_loss=False):

        row_id_pattern = "SUM" if (parallel_streams and not get_datagram_loss) else u"\\s*(?P<id>\\d*)\\s*"
        pattern = u"\\[{}]\\s*(?P<interval_start>\\d*\\.\\d*)\\s*\\-\\s*(?P<interval_end>\\d*\\.\\d*)\\s*sec\\s*" \
                  u"(?P<transfer_amount>\\d*(\\.\\d*)?)\\s*(?P<transfer_unit>K|M|G|)Bytes\\s*" \
                  u"(?P<bandwidth_amount>\\d*\\.*\\d*)\\s*(?P<bandwidth_unit>K|M|G|)bits\\/sec" \
                  u"(?P<udp_part>\\s*(?P<jitter>\\d*\\.\\d*)\\s*(?P<jitter_unit>\\w*)\\s*" \
                  u"(?P<lost_datagrams>\\d*)\\/\\s*(?P<total_datagrams>\\d*)\\s*\\((?P<datagram_loss>\\d*. " \
                  u"\\d*|\\-nan)\\%*\\))*".format(row_id_pattern)

        self.pattern = re.compile(pattern, re.VERBOSE)
        m = re.search(self.pattern, line)
        self.line = line
        self.index = index
        if not m:
            self.correct = False
            return

        parameters = m.groupdict()
        for param, param_value in parameters.items():
            if param_value is not None:
                setattr(self, param, param_value)
        self.correct = True


def get_availabel_udp_port(lines, min_port=40000, max_port=45000):
    """
    Find one free and available udp port for iperf data traffic
    :param lines: list of occupied udp ports
    :param min_port: minimal port number
    :param max_port: max port number
    :return: free and available port number
    """
    logging.debug("starting find random free udp port.")
    i = 0
    while i < 100:
        i += 1
        logging.debug("trying find free udp port, i = {}".format(i))
        port = random.randint(min_port, max_port)
        port_str = ':{}'.format(port)
        logging.debug("testing udp port: {}".format(port))
        if any(port_str in line for line in lines):
            logging.debug("this port is occupied: {}".format(port))
            continue
        logging.info("found free udp port: {}".format(port))
        return port


def get_occupied_udp_port_list():
    """
    Search the udp port list which has been occupied.
    :return: occupied udp port list
    """
    udp_port_str = ((subprocess.check_output(["netstat", "-nulp"])).decode('utf-8')).strip()
    tmpList = udp_port_str.split("\n")
    del tmpList[0:2]
    update_port_list = []

    for i in tmpList:
        val = i.split()
        del val[0:3]
        del val[1]
        valTmp = (val[0].split(":"))[-1]
        val[0] = valTmp
        valTmp = val[1].split('/')
        val[1] = valTmp[-1]
        val = ' '.join(val)
        update_port_list.append(val)
    return update_port_list


def verify_adblog_result(item_list, checked_string):
    """
    This method used to check whether the item list appear in the checked_string.
    :param item_list : the items to be searched
    :param checked_string : ADB log string to be checked
    :return Match if find item in checked string, NotMatch otherwise
    """
    logging.info("The Item list to be verified is : {0}".format(item_list))
    for item in item_list:
        updated_string = "mPci = {0}".format(item)
        logging.info("Start to verify item : {0}".format(updated_string))
        if updated_string in checked_string:
            return "Match"
    return "NotMatch"


def check_default_route_exist(input_file):
    """
    This method used to parse 'ip route' command output file
    :param input_file:
    :return: True if found False otherwise
    """
    with open(input_file) as FH:
        for item in FH:
            if 'default' in item and '27.168' in item and 'usb0.1' in item:
                return 'True'
    return 'False'


def check_bts_mode(input_config):
    """
    This method used to check current TL  working mode based on loaded TL configuration file
    :param input_config: loaded TL config file
    :return 4GSA if gnbs is not exist in tl config file, 5G otherwise
    """
    assert input_config, "TL configuration file {0} is empty!".format(input_config)
    if input_config.gnbs is None and input_config.enbs is not None:
        return '4GSA'
    else:
        return '5G'


def check_ipaddr_type(input_config):
    """
    This method used to check anchor eNB IP addr type under NSA mode
    :param input_config: loaded TL config file
    :return ip_addr_flag
    """
    assert input_config, "TL configuration file {0} is empty!".format(input_config)
    ip_addr_flag = None
    if input_config.gnbs is not None and input_config.enbs is not None:
        if input_config.enbs[0].x2_link_addr:
            ip_addr_flag = 'X2'
        elif input_config.enbs[0].oam_ip:
            ip_addr_flag = 'OAM'
        else:
            logging.info("unsupported IP address type!")
    return ip_addr_flag


def get_detail_cell_list(ip_addr='192.168.255.129', port=443, connection=None, timeout=80):
    """
    This method used to get BTS cell info
    :param ip_addr: IP address for ssh to BTS
    :param port: port number for ssh to BTS
    :param connection: the connection alias if using an existing OAM connection
    :param timeout: timeout for the operation
    :return: BTS cell info
    """
    adm = admin()
    ret_result = None
    try:
        if not connection:
            adm.setup_admin(bts_host=ip_addr, bts_port=port)
        ret_result = adm.get_cell_list(timeout=timeout, connection=connection)

    except Exception as ex:
        logging.error("Failed to get BTS cell info with error - {0}".format(ex))
    finally:
        if not connection:
            adm.teardown_admin()

    return ret_result


def get_remote_testline_cell_info(vm_ipaddr, vm_user, vm_password, vm_ssh_port=22,
                                  lmp='192.168.255.129', https_port=443):
    """
    This method used to get remote pair testline cell info via ssh tunnel
    :param vm_ipaddr: IP address of virtual machine corresponding to target BTS
    :param vm_user: username of virtual machine
    :param vm_password: password of virtual machine
    :param vm_ssh_port: SSH port of of virtual machine
    :param lmp: target SBTS LMP ip address
    :param https_port: https service port of target BTS
    :return: remote pair testline detailed cell info
    """
    result = None
    try:
        with sshtunnel.open_tunnel(
                ssh_address_or_host=(vm_ipaddr, int(vm_ssh_port)),
                remote_bind_address=(lmp, https_port),
                ssh_username=vm_user,
                ssh_password=vm_password,
                block_on_close=False,
        ) as tunnel:
            result = get_detail_cell_list(ip_addr="127.0.0.1", port=tunnel.local_bind_port)

    except Exception as ex:
        logging.error("Failed to get remote pair testline cell info with error - {0}".format(ex))

    return result


def parse_remote_cell_info_into_list(cell_info_dict):
    """
    This method used to parse necessary cell info for further verification
    :param cell_info_dict: dictionary of specific testline detailed cell info
    :return: necessary cell info list
    """
    assert cell_info_dict, "Empty cell info dict!"
    cell_info_list = []
    cell_flag = 'nr' if cell_info_dict.get('nr') else 'lte'
    logging.info("Start to parse {0} cell info".format(cell_flag))

    for iter in cell_info_dict.get(cell_flag):
        tmp_dict = {}
        if cell_flag == 'nr':
            tmp_dict['bandwidth'] = iter.get('band')
            tmp_dict['arfcn'] = iter.get('nrarfcn')
            tmp_dict['cell_type'] = iter.get('cellDepType')

        else:
            tmp_dict['bandwidth'] = iter.get('bandNumber')
            tmp_dict['arfcn'] = iter.get('earfcnDownlink')

        tmp_dict['technology'] = iter.get('technology')
        tmp_dict['cellid'] = iter.get('globalCellId')
        tmp_dict['pci'] = iter.get('physicalCellId')

        cell_info_list.append(tmp_dict)

    return cell_info_list


def parse_atcmd_cell_info_into_dict(input_str):
    """
    This method used to parse output of check cell info at command
    :param input_str: AT command output from openwrt
    :return: cell info dictionary format as below:
    {'mode': 'ENDC',
     'cell_details': [{'pci': 311, 'cell_id': '841D01', 'arfcn': '3E8', 'is_service': '1', 'band': '102'},
                      {'pci': 313, 'cell_id': '', 'arfcn': '6979E', 'is_service': '1', 'band': '5066'}]}
    """
    parse_dict = {'mode': '', 'cell_details': []}
    logging.info("The output of AT+GTCCINFO? command : {0}".format(input_str))
    if input_str:
        resp_list = [re.sub('\r|\n', '', item.strip()) for item in input_str if item.strip() != '']
        for iter_str in resp_list:
            if iter_str.endswith('cell:') and 'neighbor' not in iter_str:
                if 'LTE-NR' and 'EN-DC' in iter_str:
                    parse_dict['mode'] = 'ENDC'
                elif 'NR' in iter_str and '-' not in iter_str:
                    parse_dict['mode'] = 'NR'
                elif 'LTE' in iter_str and '-' not in iter_str:
                    parse_dict['mode'] = 'LTE'

            if iter_str[0].isdigit() and iter_str[-1].isdigit() and ',' in iter_str:
                tmp_dict = {}
                tmp_dict['is_service'] = iter_str.split(',')[0]
                tmp_dict['cell_id'] = iter_str.split(',')[5]
                tmp_dict['arfcn'] = iter_str.split(',')[6]
                tmp_dict['pci'] = int(iter_str.split(',')[7], 16)
                tmp_dict['band'] = iter_str.split(',')[8][2:]
                parse_dict['cell_details'].append(tmp_dict)

    return parse_dict


def verify_cell_attach_result(pci_index, target_cell, attach_cell):
    """
    This method used to verify whether UE attach on target cell
    :param pci_index: pci index used to search dedicated cell item
    :param target_cell: remote peer testline cell info
    :param attach_cell: actually attached cell info
    :return: YES/NO
    """
    if not all([target_cell, attach_cell]):
        raise Exception("please provide all mandatory parameters!")

    target_dict, attached_dict = {}, {}
    for iter_item in target_cell:
        if iter_item.get('pci') == pci_index:
            target_dict = iter_item
            break
    else:
        raise Exception("unable to find pci-{0} mapped item on target cell!")

    for iter_item in attach_cell['cell_details']:
        if iter_item.get('pci') == pci_index:
            attached_dict = iter_item
            break
    else:
        return 'NO'

    return 'YES' if target_dict.get('arfcn') == attached_dict.get('arfcn') else 'NO'


def parse_anchor_lte_cell_info(cell_info_list):
    """
    Main Function:
    This method used to parse anchor lte cell info for NSA configuration

    Arguments:
        :param cell_info_list: list of anchor lte testline detailed cell info

    Return Value:
        list of anchor lte cell info

    Examples:
       ${LTE_Cell_Dict_List}  Parse Anchor Lte Cell Info  cell_info_list=${LTE_Cells_Info['cells']['lte']}

    Version:
        | Author | Version | Delivery Date | Comments |
        | Sun Jingang | 1.0.0 | 2022/2/22 | First approved version by VA |
    """
    assert cell_info_list, "Empty list of anchor lte cell info!"
    logging.info("Start to parse anchor lte cell info")

    parsed_cell_list = []
    for iter_item in cell_info_list:
        if iter_item.get('technology') not in ['FDD', 'TDD']:
            logging.info("unsupported cell technology - {0}".format(iter_item.get('technology')))
            continue

        tmp_dict = {}
        tmp_dict['cellid'] = iter_item.get('globalCellId')
        tmp_dict['pci'] = iter_item.get('physicalCellId')
        tmp_dict['earfcn'] = iter_item.get('earfcnDownlink') if iter_item.get('technology') == 'FDD' \
            else iter_item.get('earfcn')
        parsed_cell_list.append(tmp_dict)

    return parsed_cell_list


def get_epc_side_ipaddr(ip_addr_list, ue_index):
    """
    Main Function:
    This method used to retrieve epc side ip address for UL data transfer

    Arguments:
        :param ip_addr_list: ip address list
        :param ue_index: UE identifier

    Return Value:
        ip address of EPC side for UL data transfer

    Examples:
        ${app_server_addr}  Get Epc Side Ipaddr  ip_addr_list=${ute_iperf_itf_ip_list}  ue_index=${ue_index}

    Version:
        | Author | Version | Delivery Date | Comments |
        | Sun Jingang | 1.0.0 | 2022/2/24 | First approved version by VA |
    """
    ue_index = int(ue_index)
    update_ip_addr_list = list(set(ip_addr_list))
    update_ip_addr_list.sort(key=ip_addr_list.index)
    logging.info("Original ip addr list:{0};update ip addr list:{1}".format(ip_addr_list, update_ip_addr_list))
    if len(update_ip_addr_list) == 1:
        ip_address = update_ip_addr_list[0]
    else:
        if ue_index - len(update_ip_addr_list) >= 1:
            raise Exception("invalid ue index - list index out of range")
        else:
            ip_address = update_ip_addr_list[ue_index - 1]

    return ip_address


def parse_atcmd_locked_freq_info(input_string):
    """
    This method used to parse the output of command AT+GTFREQLOCK?
    :param input_string: AT command output from openwrt
    :return the locked frequency(xfcn means earfcnDL for 4G, nrarfcn for 5G), pci or scs,
            if no locked frequency return None

    e.g. Returned locked frequency: {'4G': {'xfcn': '1650', 'pci': '310'}, '5G': {'xfcn': '636200', 'scs': '1'}}
         No frequency locked: {'4G': None, '5G': None}
         Status not available: {'4G': 'ongoing', '5G': 'ongoing'}
    """
    logging.info("The original output to be parsed is : {0}".format(input_string))
    new_string = re.sub('\r|\n', '', input_string)
    logging.info("Updated output to be verified is : {0}".format(new_string))
    result = re.match("\\+GTFREQLOCK:\\s*4G:\\s*(\\S+)5G:\\s*(\\S+)OK", new_string)
    logging.info("result: {0}".format(result))
    parse_dict = {'4G': None, '5G': None}
    if result and result.group(1) != '0':
        ret = re.match("\\d+,(\\d+),(\\d+)", result.group(1))
        parse_dict['4G'] = {'xfcn': ret.group(1), 'pci': ret.group(2)}
    if result and result.group(2) != '0':
        ret = re.match("\\d+,(\\d+),(\\d+)", result.group(2))
        parse_dict['5G'] = {'xfcn': ret.group(1), 'scs': ret.group(2)}
    if not result and re.match(".*OK", new_string):
        parse_dict.update([('4G', 'ongoing'), ('5G', 'ongoing')])

    return parse_dict
