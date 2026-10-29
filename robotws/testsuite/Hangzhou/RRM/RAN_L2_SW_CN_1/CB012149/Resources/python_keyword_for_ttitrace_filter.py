import csv
import re
import os


def common_get_ttitrace_reader(filename):
    list_ttitrace = []
    with open(filename, 'r') as file1:
        data = csv.reader(file1)
        for Row_of_date in data:
            list_ttitrace.append(Row_of_date)
        return list_ttitrace


def common_get_column_index_from_ttitrace(data, sLeft):
    for Row_of_date in data:
        for i in range(len(Row_of_date)):
            if Row_of_date[i] == sLeft:
                return i


def common_filter_ttitrace_data_with_reg(data, sLeft, operator, sRight):
    legalOperators = [">", "<", "==", "!=", ">=", "<="]
    count = 0
    column_index = common_get_column_index_from_ttitrace(data, sLeft)
    if operator in legalOperators:
        for Row_of_date in data:
            string = "'" + Row_of_date[column_index] + "'" + operator + "'" + sRight + "'"
            if eval(string):
                count += 1
        return count
    else:
        print('ERR: operators check Fail, please enter valid operators in : ', legalOperators)


def common_filter_in_ttitraceData(data, filterList):
    regSplit = r"([a-zA-Z1-9.]+)([><=]+)(.*)"
    count = 0
    for filter in filterList:
        # print("filter: ", filter)
        sLeft, operator, sRight = re.search(regSplit, filter).group(1), re.search(regSplit, filter).group(2), \
                                  re.search(regSplit, filter).group(3)
        # print("sLeft, operator, sRight: ", sLeft, operator, sRight)
        count = common_filter_ttitrace_data_with_reg(data, sLeft, operator, sRight)
        # print("-->counts after filter: ", count)
    return count


def common_filter_in_ttitraceLog(filename, filterList):
    data = common_get_ttitrace_reader(filename)
    count = common_filter_in_ttitraceData(data, filterList)
    return count


if __name__ == '__main__':
    pass
    # filename = "C:\\jiangliyun\\5G\\2024_E2E_Testing\\Features\\CB012149\\log\\preTest\\9169-2ue\\output_ul
    # -ttitraceBothUeHighData.csv"
    # filterList = ["ulFdSchedData.mcsTable==QAM256", "ulFdSchedData.ueType==SCELL", "slot==5"]
    # counts = common_filter_in_ttitraceLog(filename, filterList)
