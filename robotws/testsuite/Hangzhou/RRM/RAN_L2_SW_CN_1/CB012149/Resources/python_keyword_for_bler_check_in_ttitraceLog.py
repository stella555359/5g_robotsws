import sys
import csv
import re
import os
from python_keyword_for_ttitrace_filter import *

STR_UL_crcResult = "ulHarqRxData.crcResult"
# STR_DL_ackNack = "dlFdSchedData.ackNack"
STR_DL_ackNack = "dlHarqRxDataArray.ackNack"
strultrace, strdltrace = '_ul.csv', '_dl.csv'


def common_get_ttitrace_file_list(filepath):
    filelist = []
    strTrace = '.csv'
    files = os.listdir(filepath)
    for f in files:
        if (f.endswith(strTrace) and (re.search(strultrace, f) or re.search(strdltrace, f))):
            filelist.append("%s%s" % (filepath, f))
    return filelist


def common_check_harq_info_bler_rate_in_file(filename, rate):
    """ This keyword is used to check the NACK/DTX result in ttitrace.

        | Input Parameters      | Man. | Description |
        | filename              | Yes  | the ttitrace log path+name.|
        | rate                  | Yes  | the max bler rate |

        | Output                | Man. | Description |
        | printing              | Null | checking result and NACK/DTX error percent|
        Example:
        | common_check_harq_info_bler_rate | c:\\Temp\\test_UL_1233_ul_0000.csv    0.1 |
    """
    Row_Number = 0  # RowNumber is the begin row to check
    harqtotal, harqnack, harqdtx = 0, 0, 0
    result = True
    retString = ''
    if (re.search(strultrace, filename)):
        crcName, ackValue, nackValue = STR_UL_crcResult, "OK", "NOK"
    elif (re.search(strdltrace, filename)):
        crcName, ackValue, nackValue = STR_DL_ackNack, "ACK", "NACK"
    filterHarqACK, filterHarqNACK, filterHarqDTX = [crcName + "==" + ackValue], [crcName + "==" + nackValue], [
        crcName + "==DTX"]
    countsHarqACK = common_filter_in_ttitraceLog(filename, filterHarqACK)
    countsHarqNACK = common_filter_in_ttitraceLog(filename, filterHarqNACK)
    countsHarqDTX = common_filter_in_ttitraceLog(filename, filterHarqDTX)
    countsHarqTotal = sum([countsHarqNACK, countsHarqDTX, countsHarqACK])
    '''if bler larger than input rate, log check fail'''
    result = False if ((float(countsHarqNACK + countsHarqDTX) / countsHarqTotal) > float(rate)) else True
    # retString += "=== %s ===" % os.path.basename(filename) + '\r\n'
    retString += "=== %s ===" % filename + '\r\n'
    retString += "  HARQ check result: %s | Totol : %d | NACK : %d | DTX : %d" % \
                 (result, countsHarqTotal, countsHarqNACK, countsHarqDTX) + '\r\n'
    retString += "  NACK/DTX error percent: %.3f" % (float(countsHarqNACK + countsHarqDTX) / countsHarqTotal) + '\r\n'
    print(retString)
    return result


def common_check_harq_info_bler_rate_in_path(path, rate):
    filelist = common_get_ttitrace_file_list(path)
    print("**********Expect bler is not higher than: %.3f **********" % (float(rate)) + '\r\n')
    ret = True
    for filename in filelist:
        ret = ret and common_check_harq_info_bler_rate_in_file(filename, rate)
    return ret


if __name__ == '__main__':
    pass
    # path = "C:\\jiangliyun\\5G\\2024_E2E_Testing\\Features\\CB012149\\log\\preTest\\9169-2ue\\"
    # retString = common_check_harq_info_bler_rate_in_path(path, 0.1)
    # print(retString)
