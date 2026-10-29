#!/usr/bin/env python3

import os
import sys
import json
import time


def main(argv):
    sorted_input_json_file = argv[1]
    csv_files_folder = argv[2]
    current_time = time.time()

    if not os.path.exists(csv_files_folder):
        os.mkdir(csv_files_folder)
    with open(sorted_input_json_file, 'r') as f:
        l2lo_info_list = json.load(f)

    for l2lo_info in l2lo_info_list:
        l2lo_pool_id = l2lo_info['l2loPoolId']
        l2lo_pool_dir = os.path.join(csv_files_folder, f'{l2lo_pool_id:d}')
        if not os.path.exists(l2lo_pool_dir):
            os.mkdir(l2lo_pool_dir)

        csv_file_name = os.path.join(l2lo_pool_dir, 'memoryResources.csv')
        add_first_line = not os.path.exists(csv_file_name)
        header_line = 'time,l2loPoolId,rlcSduDescriptorUsingCount,storedHarqEventCount,usedHarqCount\n'
        mem_res = l2lo_info['memoryResources']
        record_line = '{:.6f},{:d},{:d},{:d},{:d}\n'.format(
            current_time,
            l2lo_pool_id,
            mem_res['rlcSduDescriptorUsingCount'],
            mem_res['storedHarqEventCount'],
            mem_res['usedHarqCount']
        )
        with open(csv_file_name, 'a') as f:
            if add_first_line:
                f.write(header_line)
            f.write(record_line)
        csv_file_name = os.path.join(
            csv_files_folder, 'allInOne_memoryResources.csv')
        add_first_line = not os.path.exists(csv_file_name)
        with open(csv_file_name, 'a') as f:
            if add_first_line:
                f.write(header_line)
            f.write(record_line)

        csv_file_name = os.path.join(l2lo_pool_dir, 'bufferPoolFreeCount.csv')
        add_first_line = not os.path.exists(csv_file_name)
        buffer_counts = l2lo_info['memoryResources']['bufferPoolFreeCount']
        header_line = 'time,l2loPoolId'
        for i in range(len(buffer_counts)):
            header_line += f',index{i:d}'
        header_line += '\n'
        record_line = f'{current_time:.6f},{l2lo_pool_id:d}'
        for info in buffer_counts:
            record_line += ',{:d}'.format(info['freeBufferCount'])
        record_line += '\n'
        with open(csv_file_name, 'a') as f:
            if add_first_line:
                f.write(header_line)
            f.write(record_line)
        csv_file_name = os.path.join(
            csv_files_folder, 'allInOne_bufferPoolFreeCount.csv')
        add_first_line = not os.path.exists(csv_file_name)
        with open(csv_file_name, 'a') as f:
            if add_first_line:
                f.write(header_line)
            f.write(record_line)

        for cell_group_info in l2lo_info['cellGroupResources']:
            cell_group_id = cell_group_info['nrCellGrpId']
            l2lo_cell_group_dir = os.path.join(
                l2lo_pool_dir, '{:d}'.format(cell_group_id))
            if not os.path.exists(l2lo_cell_group_dir):
                os.mkdir(l2lo_cell_group_dir)
            cell_db = dict()

            for cell_info in cell_group_info['dlCellResources']:
                cell_id = cell_info['cellIdentity']
                if cell_id not in cell_db:
                    cell_db[cell_id] = dict()
                cell_db[cell_id]['dl'] = cell_info
            for cell_info in cell_group_info['ulCellResources']:
                cell_id = cell_info['cellIdentity']
                if cell_id not in cell_db:
                    cell_db[cell_id] = dict()
                cell_db[cell_id]['ul'] = cell_info

            for cell_id in cell_db.keys():
                l2lo_cell_dir = os.path.join(l2lo_cell_group_dir, f'{cell_id:d}')
                if not os.path.exists(l2lo_cell_dir):
                    os.mkdir(l2lo_cell_dir)

                csv_file_name = os.path.join(
                    l2lo_cell_dir, 'cellResources.csv')
                add_first_line = not os.path.exists(csv_file_name)
                header_line = 'time,l2loPoolId,cellGrpId,cellIdentity,dlUeCount,dlTempUeCount,dlBearerCount,' \
                              'ulUeCount,ulTempUeCount,ulBearerCount\n'
                record_line = f'{current_time:.6f},{l2lo_pool_id:d},{cell_group_id:d},{cell_id:d}'
                if 'dl' in cell_db[cell_id]:
                    record_line += ',{:d},{:d},{:d}'.format(
                        cell_db[cell_id]['dl']['ueCount'],
                        cell_db[cell_id]['dl']['tempUeCount'],
                        cell_db[cell_id]['dl']['bearerCount']
                    )
                else:
                    record_line += ',NA,NA,NA'
                if 'ul' in cell_db[cell_id]:
                    record_line += ',{:d},{:d},{:d}'.format(
                        cell_db[cell_id]['ul']['ueCount'],
                        cell_db[cell_id]['ul']['tempUeCount'],
                        cell_db[cell_id]['ul']['bearerCount']
                    )
                else:
                    record_line += ',NA,NA,NA'
                record_line += '\n'
                with open(csv_file_name, 'a') as f:
                    if add_first_line:
                        f.write(header_line)
                    f.write(record_line)
                csv_file_name = os.path.join(
                    csv_files_folder, 'allInOne_cellResources.csv')
                add_first_line = not os.path.exists(csv_file_name)
                with open(csv_file_name, 'a') as f:
                    if add_first_line:
                        f.write(header_line)
                    f.write(record_line)


if __name__ == '__main__':
    main(sys.argv)
