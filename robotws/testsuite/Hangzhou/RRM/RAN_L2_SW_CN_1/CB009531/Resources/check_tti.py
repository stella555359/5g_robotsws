import re
from set_pandas import *

pd = None
np = None


def check_tti_ulretrans(csv_file):
    init_pandas()
    df = pd.read_csv(csv_file, low_memory=False)
    df1 = df[(df["ulFdSchedData.dciFormat"] == "UL_01") & (df["ulFdSchedData.ulHarqProcessIndex"] == 5)]
    df1 = df1.reset_index(drop=True)
    if df1.loc[0, 'ulFdSchedData.numOf5qi1Prb'] == df1.loc[1, 'ulFdSchedData.numOf5qi1Prb'] \
            and df1.loc[0, 'ulFdSchedData.tbSize'] == df1.loc[1, 'ulFdSchedData.tbSize']:
        return True
    else:
        return False


def check_tti_uldata_during_retranstimer(csv_file):
    init_pandas()
    df = pd.read_csv(csv_file, low_memory=False)
    # subset = df.loc[:, ['ulFdSchedData.dciFormat', 'ulHarqRxData.crcResult', 'ulHarqRxData.ulHarqProcessIndex',
    #                     'ulPreSchedData.csListEvent']]
    df1 = df[df["ulPreSchedData.csListEvent"] == "EXITULACKRETXTIMER"]
    n = len(df1)
    for j in range(n):
        num = df1.index[j]
        for i in range(num - 20, num)[::-1]:
            if df.loc[i, 'ulFdSchedData.dciFormat'] == 'UL_01':
                print(i)
                if df.loc[num, "sfn"] == df.loc[i, "sfn"]:
                    if df.loc[num, "slot"] - df.loc[i, "slot"] <= 10:
                        return True
                elif df.loc[num, "sfn"] - df.loc[i, "sfn"] == 1:
                    if df.loc[num, "slot"] + 20 - df.loc[i, "slot"] <= 10:
                        return True
    return False


if __name__ == '__main__':
    # check_tti_uldata_During_RetransTimer("output_ul.csv")
    check_tti_ulretrans("output_ul.csv")
