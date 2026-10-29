# Created by shuihe
# Maintianed by shuihe
import csv
import math
import ast
import decimal
from decimal import Decimal


def blertaget_value_nidd(pdcchBlerTarget_nidd, pdcchBlerTargetHR_nidd, cqicorr_up, cqicorrHr_up):
    pdcchBlerTarget = float(pdcchBlerTarget_nidd) / 1000
    pdcchBlerTargetHR = float(pdcchBlerTargetHR_nidd) / 1000
    cqicorr_down = float(cqicorr_up) * (1 - pdcchBlerTarget) / pdcchBlerTarget
    cqicorrHr_down = float(cqicorrHr_up) * (1 - pdcchBlerTargetHR) / pdcchBlerTargetHR
    print(f'Match found: cqicorr_down = {cqicorr_down}, cqicorrHr_down = {cqicorrHr_down}')
    return cqicorr_down, cqicorrHr_down


def compare_blerTargetHr(csv_file_path, bwp1_2_target, cellid):
    with open(csv_file_path) as csvfile:
        list_reader = list(csv.DictReader(csvfile))
        st_check_index = 0
        pass_index = 0
        for i_row in list_reader[st_check_index:]:
            nrCellGrpId = i_row['itf_l2_ps_cell_CellReconfigurationReq_t.nrCellGrpId']
            if nrCellGrpId and nrCellGrpId == str(cellid):
                blerTargetHr = i_row[
                    'itf_l2_ps_pdcch_DynamicAggregationLevelHRSetReconfig.blerTargetHr'
                ]
                blerTargetHr_values = blerTargetHr.split(',')
                if len(blerTargetHr_values) == 2:
                    blerTargetHr_X = blerTargetHr_values[0]
                    blerTargetHr_Y = blerTargetHr_values[1]
                    if (blerTargetHr_X == str(bwp1_2_target) and blerTargetHr_Y == str(bwp1_2_target)):
                        print(
                            f'Match found: blerTargetHr_X = {blerTargetHr_X}, '
                            f'blerTargetHr_Y = {blerTargetHr_Y}, nrCellGrpId = {nrCellGrpId}'
                        )
                        pass_index += 1
                    else:
                        print(
                            f'No match: blerTargetHr_X = {blerTargetHr_X}, '
                            f'blerTargetHr_Y = {blerTargetHr_Y}, nrCellGrpId = {nrCellGrpId}'
                        )
                        pass_index += 2
    if pass_index == 2:
        raise Exception('Fail')
    if pass_index == 1:
        print('case pass')


def compare_blerTargetBr(csv_file_path, bwp1_2_target, cellid):
    with open(csv_file_path) as csvfile:
        list_reader = list(csv.DictReader(csvfile))
        st_check_index = 0
        pass_index = 0
        for i_row in list_reader[st_check_index:]:
            nrCellGrpId = i_row['itf_l2_ps_cell_CellReconfigurationReq_t.nrCellGrpId']
            if nrCellGrpId and nrCellGrpId == str(cellid):
                blerTargetBr = i_row[
                    'itf_l2_ps_pdcch_DynamicAggregationLevelSetReconfig.blerTarget']
                blerTargetBr_values = blerTargetBr.split(',')
                if len(blerTargetBr_values) == 2:
                    blerTargetBr_X = blerTargetBr_values[0]
                    blerTargetBr_Y = blerTargetBr_values[1]
                if blerTargetBr_X == str(bwp1_2_target) and blerTargetBr_Y == str(bwp1_2_target):
                    print(f'Match found: blerTargetBr_X = {blerTargetBr_X},'
                          f' blerTargetBr_Y = {blerTargetBr_Y}, nrCellGrpId = {nrCellGrpId}')
                    pass_index += 1
                else:
                    print(f'No match: blerTargetBr_X = {blerTargetBr_X}, '
                          f'blerTargetBr_Y = {blerTargetBr_Y}, nrCellGrpId = {nrCellGrpId}')
                    pass_index += 2
    if pass_index == 2:
        raise Exception('Fail')
    if pass_index == 1:
        print(f'case pass')


def cqiPdcchOffset_value_check(file_path, rnti_filter):
    with open(file_path, newline='') as csvfile:
        reader = csv.DictReader(csvfile)
        filtered_rows = [row for row in reader if row['rnti'] == str(rnti_filter)]
        if not filtered_rows:
            print(f"No rows found with rnti == {rnti_filter}")
            return
        previous_value = None
        drop_count = 0
        total_drop = 0
        drop_rows = []
        for i, row in enumerate(filtered_rows):
            if row['dlFdSchedData.cqiPdcchOffset'] == '':
                continue
            current_value = float(row['dlFdSchedData.cqiPdcchOffset'])
            if previous_value is not None and current_value < previous_value:
                drop_count += 1
                total_drop += (previous_value - current_value)
                drop_rows.append(i)
            previous_value = current_value
        average_drop = round(total_drop / drop_count, 4) if drop_count > 0 else 0
        print("Filtered Table (rnti == {rnti_filter}):")
        # for row in filtered_rows:
        #     print(row)
        print(f"Number of drops: {drop_count}")
        print(f"Average drop value: {average_drop}")
        print(f"Rows where drops occurred: {drop_rows}")


def cqiPdcchOffset_value_check_multiUE(file_path):
    with open(file_path, newline='') as csvfile:
        reader = csv.DictReader(csvfile)
        rnti_values = set(row['rnti'] for row in reader)
        csvfile.seek(0)
        reader = csv.DictReader(csvfile)  #
        for rnti_filter in rnti_values:
            filtered_rows = [row for row in reader if row['rnti'] == rnti_filter]
            if not filtered_rows:
                print(f"No rows found with rnti == {rnti_filter}")
                continue
            previous_value = None
            drop_count = 0
            total_drop = 0
            drop_rows = []
            for i, row in enumerate(filtered_rows):
                if row['dlFdSchedData.cqiPdcchOffset'] == '':
                    continue
                current_value = float(row['dlFdSchedData.cqiPdcchOffset'])
                if previous_value is not None and current_value < previous_value:
                    drop_count += 1
                    total_drop += (previous_value - current_value)
                    drop_rows.append(i)
                previous_value = current_value
            average_drop = round(total_drop / drop_count, 4) if drop_count > 0 else 0
            print(f"Filtered Table (rnti == {rnti_filter}):")
            # for row in filtered_rows:
            #     print(row)
            print(f"Number of drops: {drop_count}")
            print(f"Average drop value: {average_drop}")
            print(f"Rows where drops occurred: {drop_rows}")
            csvfile.seek(0)
            reader = csv.DictReader(csvfile)


def cqiPdcchOffset_value_check_multiUE_Manual_tti(file_path):
    with open(file_path, newline='') as csvfile:
        reader = csv.DictReader(csvfile)
        rnti_values = set(row['rnti'] for row in reader)
        csvfile.seek(0)
        reader = csv.DictReader(csvfile)
        for rnti_filter in rnti_values:
            filtered_rows = [row for row in reader if row['rnti'] == rnti_filter]
            if not filtered_rows:
                print(f"No rows found with rnti == {rnti_filter}")
                continue
            previous_value = None
            drop_count = 0
            total_drop = 0
            drop_rows = []
            drop_values = []
            drop_sfn = []
            for i, row in enumerate(filtered_rows):
                if row['cqiPdcchOffset'] == '':
                    continue
                current_value = float(row['cqiPdcchOffset'])
                current_sfn = float(row['sfn'])
                if previous_value is not None and current_value < previous_value:
                    drop_count += 1
                    drop_value = previous_value - current_value
                    total_drop += (previous_value - current_value)
                    drop_rows.append(i)
                    drop_values.append(drop_value)
                    drop_sfn.append(current_sfn)
                previous_value = current_value
            average_drop = round(total_drop / drop_count, 4) if drop_count > 0 else 0
            print(f"Filtered Table (rnti == {rnti_filter}):")
            # for row in filtered_rows:
            #     print(row)
            print(f"Number of drops: {drop_count}")
            print(f"Average drop value: {average_drop}")
            print(f"Rows where drops occurred: {drop_rows}")
            print(f"sfn where drops occurred: {drop_sfn}")
            print(f"Drop values: {drop_values}")
            csvfile.seek(0)
            reader = csv.DictReader(csvfile)

# list01 = ['111111100011111000', '100000000000000000', '011111100011111111', '111111100011111111']
# print(list(list01[0]))
# a = cal_power_offset_2(list01)
# print(a)
# check_power_boosting_2('target_dl.csv')
# #
# if __name__ == "__main__":
#     file_name = "C:/Users/l3gao/0_python/6_issue.csv"
#     file_name2 = "C:/Users/l3gao/0_python/7_issue.csv"
#     # compare_blerTargetHr(file_name,9935)
#     # cqiPdcchOffset_value_check(file_name, 9935)
#     # cqiPdcchOffset_value_check_multiUE(file_name)
#     # blertaget_value_nidd(80,10,0.001,0.009)
#     cqiPdcchOffset_value_check_multiUE_Manual_tti(file_name)
#     print('file done ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~')
#     cqiPdcchOffset_value_check_multiUE_Manual_tti(file_name2)
