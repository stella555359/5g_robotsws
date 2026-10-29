# -*- coding: utf-8 -*
import re
import os
import csv


class Viavi_Log_analysis(object):
    def __init__(self):
        self.ul_csv_list = []
        self.dl_csv_list = []

    def Get_CSV_Path(self, dir_path):
        file_dict = {}
        for file in os.listdir(dir_path):
            if 'L1DLSTATS' in file:
                file_dict['DL'] = os.path.join(dir_path, file)
            elif 'L1ULSTATS' in file:
                file_dict['UL'] = os.path.join(dir_path, file)
        return file_dict

    def Preprocessing_CSV_files(self, csv_file):
        reader = csv.reader(open(csv_file, 'r'))
        new_list = [line for line in reader if (len(line) > 0) and (line[0] == '#State' or line[0] == '0')]
        return new_list

    def Get_UL_DL_Csv_List(self, dir_path, direction):
        file_dict = self.Get_CSV_Path(dir_path=dir_path)
        if direction.lower() == 'ul':
            UL_csv_file = file_dict['UL']
            self.ul_csv_list = self.Preprocessing_CSV_files(csv_file=UL_csv_file)
        elif direction.lower() == 'dl':
            DL_csv_file = file_dict['DL']
            self.dl_csv_list = self.Preprocessing_CSV_files(csv_file=DL_csv_file)

    def First_filter_result(self, column_name, csv_list):
        column_name_dict = {}
        column = csv_list[0].index(column_name)
        column_name_list = [row[column] for row in csv_list[1:]]
        row_name = set(column_name_list)
        for id in row_name:
            column_name_dict[id] = [i for i in range(0, len(column_name_list)) if column_name_list[i] == id]
        # print column_name_dict.keys()
        return column_name_dict

    def Second_filter_result(self, column_name1, column_name2, para1, para2, csv_list):
        column_name1_dict = self.First_filter_result(column_name=column_name1, csv_list=csv_list)
        column_name2_dict = self.First_filter_result(column_name=column_name2, csv_list=csv_list)
        para1_index = column_name1_dict[para1]
        para2_index = column_name2_dict[para2]
        result_list_index = [i for i in para1_index if i in para2_index]
        return result_list_index

    def Get_One_Filter_Parameter_Value_List(self, filter_column_name, filter_para, para, csv_list):
        column_name_dict = self.First_filter_result(column_name=filter_column_name, csv_list=csv_list)
        row_index = column_name_dict[filter_para]
        column_index = csv_list[0].index(para)
        para_value_list = [csv_list[i + 1][column_index] for i in row_index]
        return para_value_list

    def Get_One_Filter_Parameter_Value_Dict(self, filter_column_name1, filter_column_name2,
                                            filter_para1, csv_list):
        # self.Get_UL_DL_Csv_List(dir_path=dir_path, direction='dl')
        # csv_list = self.dl_csv_list
        para_value_dict = {}
        column_name_dict = self.First_filter_result(column_name=filter_column_name1, csv_list=csv_list)
        row_index = column_name_dict[filter_para1]
        column_index = csv_list[0].index(filter_column_name2)
        para_value_list_tmp = [csv_list[i + 1][column_index] for i in row_index]
        para_key_list = set(para_value_list_tmp)
        for key in para_key_list:
            para_value_dict[key] = []
            for i in range(0, len(para_value_list_tmp)):
                if para_value_list_tmp[i] == key:
                    para_value_dict[key].append(row_index[i])
        return para_value_dict

    def According_Index_Get_dict_Value(self, index_dict, column_name, csv_list):
        result_dict = {}
        column_index = csv_list[0].index(column_name)
        for key in index_dict.keys():
            result_dict[key] = []
            for i in index_dict[key]:
                result_dict[key].append(csv_list[i + 1][column_index])
        return result_dict

    def Get_True_Tp(self, input_list, expect_value):
        index = -1
        print (expect_value)
        for i in range(0, len(input_list)):
            if input_list[i] >= expect_value:
                index = i
                break
        if index == -1:
            raise Exception("all tp value are less than expect_value")
            result_list = False
        else:
            result_list = input_list[index:]
        return result_list

    def Check_Unexpect_value_count(self, input_list, check_value, expect_num, check_str):
        count = 0
        if check_str.lower() == 'tp':
            for value in input_list:
                if value < float(check_value):
                    count = count + 1
        elif check_str.lower() == 'bler':
            for value in input_list:
                if value > float(check_value):
                    count = count + 1
        if count <= expect_num:
            return True
        else:
            print (count)
            raise Exception("unexcept vlaue in value list are more than expect_num")
            return False

    def Check_Start_Tp_Time(self, input_list, row=10, min=10, max=120):
        count = 0
        count1 = 0
        for index in range(0, len(input_list)):
            if input_list[index] >= max:
                tmp_row = index - row
                if tmp_row < 0:
                    print (tmp_row)
                    raise Exception("input row is out of list")
                    return False
                else:
                    last_row = index
                    break
            else:
                count = count + 1
        if count == len(input_list):
            raise Exception("all vlaue are less than max")
            return False
        for i in range(last_row - row, last_row):
            if input_list[i] >= min and input_list[i] < max:
                count1 = count1 + 1
        print (input_list[last_row - row: last_row + 1])
        if count1 == row:
            raise Exception("TP is rising too slowly and has exceeded the expected number of rows")
            return False
        else:
            return True

    def Get_One_UE_UL_TP_list(self, dir_path, UE_ID):
        self.Get_UL_DL_Csv_List(dir_path=dir_path, direction='ul')
        para_value_dict = self.Get_One_Filter_Parameter_Value_Dict(filter_column_name1='Cell Group',
                                                                   filter_column_name2='UE ID',
                                                                   filter_para1='SCG', csv_list=self.ul_csv_list)
        result_dict = self.According_Index_Get_dict_Value(index_dict=para_value_dict,
                                                          column_name='UL-SCH throughput(kbps)',
                                                          csv_list=self.ul_csv_list)
        one_ue_tp_list_tmp = result_dict[UE_ID]
        one_ue_tp_list = [float(i)/1024 for i in one_ue_tp_list_tmp]
        return one_ue_tp_list

    def Get_One_UE_DL_TP_list(self, dir_path, UE_ID):
        self.Get_UL_DL_Csv_List(dir_path=dir_path, direction='dl')
        para_value_dict = self.Get_One_Filter_Parameter_Value_Dict(filter_column_name1='Cell Group',
                                                                   filter_column_name2='UE ID',
                                                                   filter_para1='SCG', csv_list=self.dl_csv_list)
        result_dict = self.According_Index_Get_dict_Value(index_dict=para_value_dict,
                                                          column_name='DL-SCH throughput(kbps)',
                                                          csv_list=self.dl_csv_list)
        one_ue_tp_list_tmp = result_dict[UE_ID]
        one_ue_tp_list = [float(i)/1024 for i in one_ue_tp_list_tmp]
        return one_ue_tp_list

    def Get_One_UE_UL_Bler_list(self, dir_path, UE_ID):
        self.Get_UL_DL_Csv_List(dir_path=dir_path, direction='ul')
        para_value_dict = self.Get_One_Filter_Parameter_Value_Dict(filter_column_name1='Cell Group',
                                                                   filter_column_name2='UE ID',
                                                                   filter_para1='SCG', csv_list=self.ul_csv_list)
        result_dict = self.According_Index_Get_dict_Value(index_dict=para_value_dict,
                                                          column_name='UL-SCH BLER',
                                                          csv_list=self.ul_csv_list)
        one_ue_bler_list_tmp = result_dict[UE_ID]
        one_ue_bler_list = [float(i) for i in one_ue_bler_list_tmp]
        return one_ue_bler_list

    def Get_One_UE_DL_Bler_list(self, dir_path, UE_ID):
        self.Get_UL_DL_Csv_List(dir_path=dir_path, direction='dl')
        para_value_dict = self.Get_One_Filter_Parameter_Value_Dict(filter_column_name1='Cell Group',
                                                                   filter_column_name2='UE ID',
                                                                   filter_para1='SCG', csv_list=self.dl_csv_list)
        result_dict = self.According_Index_Get_dict_Value(index_dict=para_value_dict,
                                                          column_name='DL-SCH BLER',
                                                          csv_list=self.dl_csv_list)
        one_ue_bler_list_tmp = result_dict[UE_ID]
        one_ue_bler_list = [float(i) for i in one_ue_bler_list_tmp]
        return one_ue_bler_list

    def Check_One_UE_TP_Stable(self, dir_path, direction, check_value=50, expect_num=5, UE_ID='0'):
        if direction.lower() == 'ul':
            one_ue_tp_list_tmp = self.Get_One_UE_UL_TP_list(dir_path=dir_path, UE_ID=UE_ID)
        else:
            one_ue_tp_list_tmp = self.Get_One_UE_DL_TP_list(dir_path=dir_path, UE_ID=UE_ID)
        print (one_ue_tp_list_tmp)
        one_ue_tp_list = self.Get_True_Tp(input_list=one_ue_tp_list_tmp, expect_value=check_value)
        if one_ue_tp_list is False:
            result = False
        else:
            print (one_ue_tp_list)
            result = self.Check_Unexpect_value_count(input_list=one_ue_tp_list, check_value=check_value,
                                                     expect_num=expect_num, check_str='tp')
        return result

    def Check_One_UE_Bler_Stable(self, dir_path, direction, check_value=0.01, expect_num=5, UE_ID='0'):
        if direction.lower() == 'ul':
            one_ue_bler_list = self.Get_One_UE_UL_Bler_list(dir_path=dir_path, UE_ID=UE_ID)
        else:
            one_ue_bler_list = self.Get_One_UE_DL_Bler_list(dir_path=dir_path, UE_ID=UE_ID)
        print (one_ue_bler_list)
        result = self.Check_Unexpect_value_count(input_list=one_ue_bler_list, check_value=check_value,
                                                 expect_num=expect_num, check_str='bler')
        return result

    def Check_One_UE_Start_TP_Time(self, dir_path, direction, row=10, min=10, max=90, UE_ID='0'):
        if direction.lower() == 'ul':
            one_ue_tp_list = self.Get_One_UE_UL_TP_list(dir_path=dir_path, UE_ID=UE_ID)
        else:
            one_ue_tp_list = self.Get_One_UE_DL_TP_list(dir_path=dir_path, UE_ID=UE_ID)
        result = self.Check_Start_Tp_Time(input_list=one_ue_tp_list, row=row, min=min, max=max)
        return result
