# coding = utf-8

"""
:copyright: Nokia Networks
:author: Shi Ming
:contact: ming.shi@nokia-sbell.com
:maintainer: Ming Shi
:contact: Ming Shi
"""


import re
import os
import openpyxl
from openpyxl.workbook.workbook import Workbook


def get_iperf_value(byte_size, direction, file_path, copy_value_file_name):
    '''
    get values of iperf, and copy output value to another txt file
    :param byte_size: : size of packet  e.g. 64, 255
    :param direction: The traffic direction. e.g.  UL or DL.
    :param file_path: the path which store output of iperf
            e.g. /opt/workspace/CIT/Master/Case_Logs/
    :param copy_value_file_name: copy time and corresponding packet to this txt file
            e.g. 255UL_iperf13.txt
    '''
    txt_file_name = str(byte_size) + '_' + str(direction) + '.txt'
    filepath = file_path + txt_file_name
    copy_filepath = file_path + copy_value_file_name

    pattarn1 = r'\d{5}\)\='
    pattarn2 = ' ('
    with open(filepath, 'r') as file:
        read_string = file.read()
        result = re.split(pattarn1, read_string)[1].split(pattarn2)[0]

    with open(copy_filepath, 'w') as file:
        file.write(result)


def create_xlsx_excel_and_write_value(file_path, txt_file, excel_file, excel_sheet):
    '''
    create excel and write value of time and packet to excel file
    :param file_path: the path of excel   e.g. /opt/workspace/CIT/Master/Case_Logs
    :param txt_file: : the txt file which store value of time and packet
            e.g. 255UL_iperf13.txt
    :param excel_file: the excel file which store value of time and packet
            e.g. '255UL_iperf13.xlsx'
    :param excel_sheet: the sheet name of excel file which store value of time and packet
            e.g. '255UL_iperf13'
    '''
    filepath = file_path + txt_file
    with open(filepath, 'r') as file:
        result = file.read().split(',')
    iperf_time = []
    iperf_value = []
    for i in result:
        iperf_time.append(i.split(':')[0])
        iperf_value.append(i.split(':')[1])

    excel_filepath = file_path + excel_file
    wb = Workbook()
    ws = wb.create_sheet(title=excel_sheet)
    for i in range(len(iperf_time)):
        ws.cell(row=i+1, column=1, value=iperf_time[i])
        ws.cell(row=i+1, column=2, value=iperf_value[i])
    wb.save(filename=excel_filepath)


def sum_value(file_path, excel_file, excel_sheet, satisfied_time='all'):
    '''
    create excel and write value of time and packet to excel file
    :param file_path: the path of excel   e.g. /opt/workspace/CIT/Master/Case_Logs
    :param excel_file: the excel file which store value of time and packet
            e.g. '255UL_iperf13.xlsx'
    :param excel_sheet: the sheet name of excel file which store value of time and packet
            e.g. '255UL_iperf13'
    :param satisfied_time: : satisified required time
            e.g. '60'
    '''
    excel_filepath = file_path + excel_file
    data = openpyxl.load_workbook(excel_filepath)
    table = data[excel_sheet]
    nrows_num = table.max_row
    ncols_num = table.max_column
    sum_all_packet = ' '
    packet_value = []
    if satisfied_time == 'all':
        for i in range(1, nrows_num+1):
            packet_value.append(int(table.cell(row=i, column=2).value))
        sum_all_packet = sum(packet_value)
    else:
        for i in range(1, nrows_num+1):
            if int(table.cell(row=i, column=1).value) <= int(satisfied_time):
                packet_value.append(int(table.cell(row=i, column=2).value))
        sum_all_packet = sum(packet_value)
    print(sum_all_packet)
    return sum_all_packet
