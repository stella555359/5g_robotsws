import sys
import csv
import re
import os
from python_keyword_for_ttitrace_filter import *

STR_UL_UlCaAllowList = "ulCaAllowList.allowList"


def common_check_UlCaAllowList_in_file_as_expected(filename, UlCaAllowList_expect):
    """ This keyword is used return the crnti of UlCaAllowList in ttitrace.

        | Input Parameters      | Man. | Description |
        | filename              | Yes  | the ttitrace log path+name.|
        | UlCaAllowList_expect  | Yes  | expected crnti list.|

        | Output                | Man. | Description |
        | return               | Null | True or False whether check pass in ttitrace log the rnti list in allow-list
        match to input rnti list|
        Example:
        | common_check_UlCaAllowList_in_file | c:\\Temp\\test_UL_1233_ul_0000.csv | [2255, 6655] |
    """
    UlCaAllowList = []
    retString = ""
    data = common_get_ttitrace_reader(filename)
    column_index = common_get_column_index_from_ttitrace(data, STR_UL_UlCaAllowList)
    for i, Row_of_date in enumerate(data):
        if i > 0:
            allowList = re.findall(r"\d+", Row_of_date[column_index])
            for rnti in allowList:
                if rnti.strip() not in UlCaAllowList and rnti != '':
                    UlCaAllowList.append(rnti.strip())
    '''if UlCaAllowList in ttitrace log not same with input crnti list, log check fail'''
    result = False if (sorted(UlCaAllowList) != sorted(UlCaAllowList_expect)) else True
    retString += "=== %s ===" % filename + '\r\n'
    retString += "  UlCaAllowList check result: {}; rnti in ttitrace: {}, expect input rnti list: {} " \
        .format(result, UlCaAllowList, UlCaAllowList_expect)
    print(retString)
    return result


def common_get_column_value_summarize_in_file(filename, columnName):
    """ This keyword is used return the value and counts in ttitrace on the given .columnName

        | Input Parameters      | Man. | Description |
        | filename              | Yes  | the ttitrace log path+name.|
        | columnName            | Yes  | such as: ulPreTdBlockUeData.cs2BlockUeList |

        | Output                | Man. | Description |
        | return               | Null | return the value and counts |
        Example:
        | common_get_column_value_summarize_in_file | c:\\Temp\\***.csv | ulPreTdBlockUeData.cs2BlockUeList |
    """
    reg = r"CS2\w+"
    blockListDict = {}
    data = common_get_ttitrace_reader(filename)
    column_index = common_get_column_index_from_ttitrace(data, columnName)
    print("column_index: ", column_index)
    if column_index is not None:
        for i, Row_of_date in enumerate(data):
            if i > 0:
                blockList = re.findall(reg, Row_of_date[column_index])
                for blockReason in blockList:
                    if blockReason not in blockListDict:
                        blockListDict[blockReason] = 1
                    else:
                        blockListDict[blockReason] += 1
        print("blockListDict: ", blockListDict)
    return blockListDict


def count_non_empty_and_non_zero_rows_in_column(filename, column_name):
    """ This keyword is used to return the count of rows not empty and not equal to zero.

        | Input Parameters      | Man. | Description |
        | filename              | Yes  | the ttitrace log path+name.|
        | column_name           | Yes  | the name of the column such as 'ulCaAllowList.allowList' |

        | Output                | Man. | Description |
        | return               | Number | return the count of rows with non-empty and non-zero column |

    """
    row_count = 0
    data = common_get_ttitrace_reader(filename)
    column_index = common_get_column_index_from_ttitrace(data, column_name)

    if column_index is not None:
        for i, Row_of_data in enumerate(data):
            # Assuming header row has no data and should be skipped
            if i > 0 and Row_of_data[column_index] is not None and Row_of_data[column_index] != "":
                try:
                    if float(Row_of_data[column_index]) != 0:
                        row_count += 1
                except ValueError:  # Handle cases where the cell value is not a number
                    continue

    print(f"Row count with non-empty and non-zero values in '{column_name}': {row_count}")
    return row_count


def count_non_empty_rows_in_column(filename, column_name):
    """ This keyword is used to return the count of rows where a specified column value is not empty.

        | Input Parameters      | Man. | Description |
        | filename              | Yes  | the ttitrace log path+name.|
        | column_name           | Yes  | the name of the column such as 'ulCaAllowList.allowList' |

        | Output                | Man. | Description |
        | return               | Number | return the count of rows with non-empty values in column |

    """
    row_count = 0
    data = common_get_ttitrace_reader(filename)
    column_index = common_get_column_index_from_ttitrace(data, column_name)

    if column_index is not None:
        for i, Row_of_data in enumerate(data):
            # Assuming header row has no data and should be skipped
            if i > 0 and Row_of_data[column_index]:
                row_count += 1

    print(f"Row count with non-empty values in '{column_name}': {row_count}")
    return row_count


if __name__ == '__main__':
    pass
