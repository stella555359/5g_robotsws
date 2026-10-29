# Created by shuihe
# Maintianed by shuihe
import csv
import ast
# import pandas as pd


def spill_value_of_srsswitchmeas_bk(csv_filename):
    with open(csv_filename) as csvfile:
        # csv.DictReader(csvfile): read csv as a list of dict
        list_reader = list(csv.DictReader(csvfile))
        for column in list_reader:
            i = column['srsSwitchMeasData.srsSwitchMeas']
            # get srs_monitor_para
            if i:
                j = ast.literal_eval(i)
                k = j[0]
                srs_monitor_para = k.keys()
                print(srs_monitor_para)
                break
        for column in list_reader:
            i = column['srsSwitchMeasData.srsSwitchMeas']
            if i:
                print(i)
                current_index = list_reader.index(column)
                print(current_index)
                j = ast.literal_eval(i)
                print(type(j[0]))
                k = j[0]
                print(k.keys())
                for a in k.keys():
                    srs_monitor_value = k.get(a)
                    print(srs_monitor_value)


def add_column(csv_filename):
    with open(csv_filename, 'r') as csvfile:
        list_reader = list(csv.reader(csvfile))
        a = list_reader[0]
        a.append('rnti1')
        print(a)


def spill_value_of_srsswitchmeas(csv_filename, target_file):
    with open(csv_filename) as csvfile:
        # csv.DictReader(csvfile): read csv as a list of dict
        list_reader = list(csv.DictReader(csvfile))
        # get srs_monitor_para
        '''
        after run the below codes, will get:
        ['rnti001', 'isSPIDUe', 'srsState', 'schedPrbRatioM100', 'spectrumEfficiencyM100', 'correlationAvgM100',
        'averageCoMaPowerLinear', 'powerDiff', 'numOfSrsBufCheck', 'numOfSrsRlqCheck', 'sampleDlBufHi',
        'sampleDlBufLo', 'sampleRlqGood', 'sampleRlqBad']
        '''
        srs_monitor_para = []
        for column in list_reader:
            i = column['srsSwitchMeasData.srsSwitchMeas']
            if i:
                j = ast.literal_eval(i)
                k = j[0]
                for m in k.keys():
                    if m == 'rnti':
                        srs_monitor_para.append('rnti001')
                    else:
                        srs_monitor_para.append(m)
                # srs_monitor_para = k.keys()
                # srs_monitor_para[0] = 'rnti001'
                # print(srs_monitor_para)
                break
        # print(srs_monitor_para)
        # add srs_monitor_para into header
        '''
        after run the below codes, will copy the srsSwitchMeasData.srsSwitchMeas column into the each i column, i is
        the element of the srs_monitor_para
        '''
        # with open(csv_filename, 'r') as csvfile:
        #     row_reader = list(csv.reader(csvfile))
        #     for i in srs_monitor_para:
        #         row_reader[0].append(i)
        #     print(row_reader[0])
        # get value list
        '''
        after run the below codes, will get:
        [[5947, 0, 'WBSRS', 48, 2222, 100, 135856, 1, 1, 1, 0, 0, 0, 0],
        [37795, 0, 'WBSRS', 51, 2222, 100, 134387, 1, 1, 1, 0, 0, 0, 0]]
        '''
        srs_value = []
        srs_index = -1
        srs_index_list = []
        for column in list_reader:
            # i = column['srsSwitchMeasData.srsSwitchMeas']
            a = (column['srsSwitchMeasData.srsSwitchMeas'])
            rnti002 = []
            srs_index += 1
            if a:
                srs_index_list.append(srs_index)
                a = ast.literal_eval(a)
                # print(a[0])
                for i in a[0]:
                    b = a[0].get(i)
                    rnti002.append(b)
                # print(rnti002)
                srs_value.append(rnti002)
        # print(srs_value)
        # print(srs_index_list)
        # add srs header and value  into rowreader
        with open(csv_filename, 'r') as csvfile001:
            row_reader = list(csv.reader(csvfile001))
            for i in srs_monitor_para:
                row_reader[0].append(i)
            for j in range(len(srs_monitor_para)):
                for row in row_reader:
                    row.append('')
            c = -1
            for k in srs_index_list:
                a = k+1
                b = -(len(srs_monitor_para)+1)
                c += 1
                # delete element[-1]~element[-14]
                del row_reader[a][-1:b:-1]
                row_reader[a] = row_reader[a] + srs_value[c]
                # print(row_reader[a])
        # write the new list into csv
        with open(target_file, 'w') as newfile:
            writer = csv.writer(newfile)
            for row in row_reader:
                writer.writerow(row)


def delete_ho_interim(csv_filename, tti_without_ho_interim_file):
    with open(csv_filename) as csvfile:
        list_reader = list(csv.DictReader(csvfile))
        start_index = 0
        end_index = 0
        init_lcrid = 0
        for column in list_reader:
            init_lcrid = column['lcrId']
            print(init_lcrid)
            break
        for column in list_reader:
            i = column['lcrId']
            j = column['ulFdSchedData.numOfLayers']
            if i != init_lcrid and j == 'RANK1':
                start_index = list_reader.index(column)
                break
        for column in list_reader:
            i = column['lcrId']
            j = column['ulFdSchedData.numOfLayers']
            if i != init_lcrid and j == 'RANK2':
                end_index = list_reader.index(column)
                break
        # print(start_index, end_index)
        del list_reader[start_index: end_index+1]
        with open(tti_without_ho_interim_file, 'w') as newfile:
            writer = csv.DictWriter(newfile, list_reader[0].keys())
            writer.writeheader()
            writer.writerows(list_reader)


def split_value_of_bwv_response(csv_filename, target_file):
    with open(csv_filename) as csvfile:
        # csv.DictReader(csvfile): read csv as a list of dict
        list_reader = list(csv.DictReader(csvfile))
        # get srs_monitor_para
        '''
        after run the below codes, will get:
        ['rnti001', 'isSPIDUe', 'srsState', 'schedPrbRatioM100', 'spectrumEfficiencyM100', 'correlationAvgM100',
        'averageCoMaPowerLinear', 'powerDiff', 'numOfSrsBufCheck', 'numOfSrsRlqCheck', 'sampleDlBufHi',
        'sampleDlBufLo', 'sampleRlqGood', 'sampleRlqBad']
        '''
        srs_monitor_para = []
        for column in list_reader:
            i = column['bwvRespData.bwvRespUeInfo']
            if i:
                j = ast.literal_eval(i)
                k = j[0]
                for m in k.keys():
                    srs_monitor_para.append(m)
                # srs_monitor_para = k.keys()
                srs_monitor_para[0] = 'rnti001'
                # print(srs_monitor_para)
                break
        # print(srs_monitor_para)
        # add srs_monitor_para into header
        '''
        after run the below codes, will copy the srsSwitchMeasData.srsSwitchMeas column into the each i column, i is
        the element of the srs_monitor_para
        '''
        # with open(csv_filename, 'r') as csvfile:
        #     row_reader = list(csv.reader(csvfile))
        #     for i in srs_monitor_para:
        #         row_reader[0].append(i)
        #     print(row_reader[0])
        # get value list
        '''
        after run the below codes, will get:
        [[5947, 0, 'WBSRS', 48, 2222, 100, 135856, 1, 1, 1, 0, 0, 0, 0],
        [37795, 0, 'WBSRS', 51, 2222, 100, 134387, 1, 1, 1, 0, 0, 0, 0]]
        '''
        srs_value = []
        srs_index = -1
        srs_index_list = []
        for column in list_reader:
            # i = column['srsSwitchMeasData.srsSwitchMeas']
            a = (column['bwvRespData.bwvRespUeInfo'])
            rnti002 = []
            srs_index += 1
            if a:
                srs_index_list.append(srs_index)
                a = ast.literal_eval(a)
                # print(a[0])
                for i in a[0]:
                    b = a[0].get(i)
                    rnti002.append(b)
                # print(rnti002)
                srs_value.append(rnti002)
        # print(srs_value)
        # print(srs_index_list)
        # add srs header and value  into rowreader
        with open(csv_filename, 'r') as csvfile001:
            row_reader = list(csv.reader(csvfile001))
            for i in srs_monitor_para:
                row_reader[0].append(i)
            for j in range(len(srs_monitor_para)):
                for row in row_reader:
                    row.append('')
            c = -1
            for k in srs_index_list:
                a = k+1
                b = -(len(srs_monitor_para)+1)
                c += 1
                # delete element[-1]~element[-14]
                del row_reader[a][-1:b:-1]
                row_reader[a] = row_reader[a] + srs_value[c]
                # print(row_reader[a])
        # write the new list into csv
        with open(target_file, 'w') as newfile:
            writer = csv.writer(newfile)
            for row in row_reader:
                writer.writerow(row)


# get_average('tti_ul.csv')
# get_average('tti_ul.csv', 'ulLaDeltaSinr.ulUsedMcs')
# get_average('tti_ul.csv', 'ulFdSchedData.numOfPrb')
# get_average('tti_ul.csv', 'ulFdSchedData.tbSize')
# get_average('tti_ul.csv', 'ulFdSchedData.reScaledCorrAvgSinrAllocPrb')
# spill_value_of_srsswitchmeas('tti_dl_001.csv', '/home/ute/shuihe/001/target.csv')
# add_column('tti_dl_simple.csv')
# split_value_of_bwv_response('30.csv', '30_target.csv')
