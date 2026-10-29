# -*- coding: UTF-8 -*-

import csv
import logging as log

__version__ = '0.1'


class CsvOperateLibrary(object):
    ROBOT_LIBRARY_SCOPE = 'TEST SUITE'

    def __init__(self):
        pass

    def _convert_to_num(self, value):
        if value.isdigit():
            return int(value)
        elif ('.' in value) and (value.count('.') == 1):
            pre, aft = value.split('.')
            if pre.isdigit() and aft.isdigit():
                return float(value)
            else:
                return value
        else:
            return value

    def csv_read_as_dict_list(self, fpath, cared_title='ALL'):
        self.value_dict_list = []
        csv_list = []
        with open(fpath, 'r') as csvfile:
            csvreader = csv.reader(csvfile)
            for c in csvreader:
                csv_list.append(c)
        pos_list = []
        if cared_title == 'ALL':
            for r in range(len(csv_list)):
                if len(csv_list[r]) == len(csv_list[r + 1]):
                    self.cared_title = csv_list[r]
                    break
        else:
            self.cared_title = cared_title
        # find title line and title index
        for r in range(len(csv_list)):
            row = csv_list[r]
            if self.cared_title[0] in row:
                next = r + 1
                for ca in self.cared_title:
                    pos_list.append(row.index(ca))
                break
        if not pos_list:
            raise Exception('not find title line')
        # get all title's value
        for r in range(next, len(csv_list)):
            dline = {}
            row = csv_list[r]
            for pos in range(len(pos_list)):
                dline[self.cared_title[pos]] = self._convert_to_num(
                    row[pos_list[pos]])
            dline['Num'] = r
            self.value_dict_list.append(dline)
        return self.value_dict_list

    def csv_read_as_list_dict(self, fpath, cared_title):
        value_list_dict = {}
        csv_list = []
        with open(fpath, 'r') as csvfile:
            csvreader = csv.reader(csvfile)
            for c in csvreader:
                csv_list.append(c)
        pos_list = []
        # find title line and title index
        for r in range(len(csv_list)):
            row = csv_list[r]
            if cared_title[0] in row:
                next = r + 1
                for ca in cared_title:
                    pos_list.append(row.index(ca))
                    value_list_dict[ca] = []
                value_list_dict['Num'] = []
                break
        if not pos_list:
            raise Exception('not find title line')
        # get all title's value
        for r in range(next, len(csv_list)):
            row = csv_list[r]
            for pos in range(len(pos_list)):
                try:
                    value_list_dict[cared_title[pos]].append(
                        self._convert_to_num(row[pos_list[pos]]))
                except Exception as err:
                    pass
            value_list_dict['Num'].append(r)
        return value_list_dict

    def csv_write_dict_list(self, fpath, content_list, title):
        with open(fpath, "w", newline='') as csv_file:
            writer = csv.writer(csv_file, delimiter=',')
            keys = title
            writer.writerow(keys)
            for i in content_list:
                values = []
                for key in title:
                    values.append(i[key])
                writer.writerow(values)

    def csiRs_filter_config_and_check_item(self, fpath, min_value, max_value,
                                           csiRsConfig='DlData_CsiRsResource_t.csiRsConfig',
                                           patternId='DlData_CsiRsResource_t.patternId_item'):
        """this keyword will check 2 column value in expection
        :param fPath: such as '/home/ute/test.csv'
        :param min_value: such as '1054'
        :param min_value: such as '2100'
        :param csiRsConfig: default as 'DlData_CsiRsResource_t.csiRsConfig'
        :param patternId: default as 'DlData_CsiRsResource_t.patternId_item'
        """
        title = [csiRsConfig, patternId]
        raw_list = self.csv_read_as_dict_list(fpath, title)
        valid_list = []
        for line in raw_list:
            if '4' in line[csiRsConfig]:
                valid_list += line[patternId].split(',')[:4]
        final = list(set(valid_list))
        log.info('all exist values are %s' % final)
        fail_list = []
        for value in final:
            value = int(value)
            if (value >= int(min_value)) and (value <= int(max_value)):
                continue
            else:
                fail_list.append(value)
        if fail_list:
            raise Exception("Value %s is out of range(%s, %s)" % (fail_list, min_value, max_value))

    def csv_startPrb_before_sib1_should_be_unique(self,
                                                  f_path,
                                                  startprb_title='startPrb (Uint16)',
                                                  info_title='Info'):
        """check all VirtualUePrb less than AllocCellPrb
        :param fPath: such as '/home/ute/test.csv'
        :param startprb_title: such as 'startPrb (Uint16)'
        :param info_title: such as 'Info'
        """
        title = [startprb_title, info_title]
        raw_dict = self.csv_read_as_list_dict(f_path, title)
        prb_value_list = []
        for i in range(len(raw_dict[info_title])):
            if i - 1 < 0:
                continue
            info = raw_dict['Info'][i].strip()
            last_info = raw_dict['Info'][i - 1].strip()
            if (info == 'DlData_PdschPayloadTbSendReq , SIB1') and (
                    last_info == 'DlData_PdschSendReq'):
                prb_value_list.append(raw_dict[startprb_title][i - 1])
        log.info(prb_value_list)
        uni_value = list(set(prb_value_list))
        log.info(uni_value)
        if (len(uni_value)) > 1:
            raise Exception('failed for multi value exist %s' % uni_value)

    def csv_VirtualUePrb_should_less_than_AllocCellPrb(self, fPath):
        """check all VirtualUePrb less than AllocCellPrb
        :param fPath: such as '/home/ute/test.csv'
        """
        title = ['timeStamp',
                 'sfn',
                 'slot',
                 'rnti',
                 'lcrId',
                 'physCellId',
                 'emCoreId',
                 'ulAllocatedPooledResourcesData.numAllocCellPrbUl',
                 'ulFdSchedData.numOfLayers',
                 'ulFdSchedData.prbOfVirtualUe',
                 'ulFdSchedData.subcellId',
                 'ulFdSchedData.ulMuStatus',
                 'ulFdSchedData.ulProGrantType',
                 'ulFdSchedData.underProbing',
                 'ulFdSchedData.virtualUeIndex']
        raw_dict = self.csv_read_as_dict_list(fPath)  # , title)
        filter_list = []
        line_num = 0
        for line in raw_dict:
            allocprb = line['ulAllocatedPooledResourcesData.numAllocCellPrbUl']
            if (allocprb or
                    line['ulFdSchedData.prbOfVirtualUe']) and (
                    line['physCellId'] == 50):
                line['Num'] = line_num
                filter_list.append(line)
                line_num += 1
        filter_file = fPath.replace('.csv', 'flt.csv')
        self.csv_write_dict_list(filter_file, filter_list, ['Num'] + title)

        alloc_pos_list = []
        for i in filter_list:
            allocprb = i['ulAllocatedPooledResourcesData.numAllocCellPrbUl']
            if allocprb:
                alloc_pos_list.append(i['Num'])

        all_dict_list = []
        alloc_pos_list.append(len(filter_list))

        for i in range(len(alloc_pos_list) - 1):
            block_dict = {}
            allocprb = filter_list[alloc_pos_list[i]
                                   ]['ulAllocatedPooledResourcesData.numAllocCellPrbUl']
            key = '%s_%s' % (
                filter_list[alloc_pos_list[i]]['Num'], int(float(allocprb)))
            start = alloc_pos_list[i] + 1
            stop = alloc_pos_list[i + 1]
            value_dict = self._handle_block(filter_list[start:stop])
            block_dict[key] = value_dict
            all_dict_list.append(block_dict)
        output_str = ''
        for item in all_dict_list:
            for p in item:
                output_str += '%s\r\n' % p
                alloc = int(float(p.split('_')[-1]))
                keys = sorted(item[p])

                for q in keys:

                    if 0 not in item[p][q] or 1 not in item[p][q]:
                        continue
                    result = (max(item[p][q][0]) + max(item[p][q][1])) <= alloc
                    output_str += '\t%s\t%s\t%s\r\n' % (q, item[p][q], result)
        log.info(output_str)
        if 'False' in output_str:
            raise Exception(
                'not all VirtualUePrb less than AllocCellPrb, please check %s' %
                filter_file)

    def _handle_block(self, block_list):
        value_dict = {}
        for line in block_list:

            key = "{}_{}".format(line['sfn'], str(line['slot']).zfill(2))
            if key not in value_dict.keys():
                value_dict[key] = {}
            SubCellId = int(float(line['ulFdSchedData.subcellId']))
            if SubCellId not in value_dict[key].keys():
                value_dict[key][SubCellId] = []
            value_dict[key][SubCellId].append(
                int(float(line['ulFdSchedData.prbOfVirtualUe'])))
        return value_dict

    def csv_split_with_rnti_and_retransmission(self, file_path):
        raw_dict = self.csv_read_as_dict_list(file_path)
        all = self.csv_read_as_list_dict(file_path, ['rnti'])
        uni_rnti = list(set(all['rnti']))
        no_use_rnti = [0, 65535]
        for rnti in no_use_rnti:
            if rnti in uni_rnti:
                uni_rnti.remove(rnti)
        new_files = []
        for rnti in uni_rnti:
            valid_line = []
            for line in raw_dict:
                if (line['rnti'] == rnti) and (
                        line['ulFdSchedData.txNumber']) and not ((
                        line['ulFdSchedData.txNumber'] == 1) and (
                        line['ulHarqRxData.crcResult'] == 'OK')):
                    valid_line.append(line)
            if valid_line:
                new = file_path.replace('.csv', '_%s.csv' % rnti)
                new_files.append(new)
                self.csv_write_dict_list(new,
                                         valid_line,
                                         self.cared_title)
        return new_files


if __name__ == '__main__':
    pass
