# ====================================================================================================[120 characters]
# This is a Python File, which helps to implement the Private Robot Keywords used in Sqd68 for 5GC000425 Feature
# Team: 'SqdGp68'
# Email: 'I_MN_5GSC_SW_ENG_ULM_SQD_68@internal.nsn.com'
# ----------------------------------------------------------------------------------------------------[120 characters]

import logging
import os
import json

# ET or Feature Specific Libraries:
import pandas as pd

from testsuite.Ulm.ET.L2.libraries.logger import log_begin_end_func_name


# ====================================================================================================[120 characters]
#   Global Variables
# ====================================================================================================[120 characters]

isHarqPuschInfo = False


# ====================================================================================================[120 characters]
#   Private Functions
# ====================================================================================================[120 characters]

def unique(list_ip):
    return list(set(list_ip))


def import_pandas():
    # Visualization: Force to display max columns and max width
    pd.set_option('display.max_columns', 10)
    pd.set_option('display.expand_frame_repr', False)


def filter_dataframe(df):
    required_discriminators = ['timeStamp', 'sfn', 'slot', 'rnti', 'physCellId',
                               'ulFdSchedData.tbSize', 'ulFdSchedData.rrmUlUsedMcs',
                               'ulFdSchedData.isValidWhatIsProposed',
                               'ulFdSchedData.redundancyVersion']
    df = df[required_discriminators].copy()
    df.dropna(inplace=True)
    df['timeStamp'] = pd.to_datetime(df['timeStamp'])
    return df


def get_directory(path_to_pickle):
    split_path = path_to_pickle.split('/')
    return "/".join(split_path[:-1])


@log_begin_end_func_name
def calculateHarqPuschInfo(path_to_pickle):
    # ------------------------------------------------------------------------------------------------[120 characters]
    import_pandas()
    df = pd.read_pickle(path_to_pickle)
    df = filter_dataframe(df)
    df.to_csv(str("%s/dataframe_for_manual_analysis.csv" % get_directory(path_to_pickle)))
    # ------------------------------------------------------------------------------------------------[120 characters]
    rrmUlUsedMcs = "ulFdSchedData.rrmUlUsedMcs"
    tbSize = "ulFdSchedData.tbSize"
    isValidWhatIsProposed = "ulFdSchedData.isValidWhatIsProposed"
    emptyMscRange = [0] * 29
    ulFdSchedData = {"IniReVol": emptyMscRange.copy(),
                     "IniVol": emptyMscRange.copy(),
                     "IniNum": emptyMscRange.copy(),
                     "AnyNum": emptyMscRange.copy(),
                     "AllNum": emptyMscRange.copy(),
                     "UnsucNum": emptyMscRange.copy()}
    # ------------------------------------------------------------------------------------------------[120 characters]
    df = df.astype({rrmUlUsedMcs: pd.Int32Dtype(),
                    tbSize: pd.Int32Dtype(),
                    isValidWhatIsProposed: pd.Int32Dtype()})
    df = df.loc[df[isValidWhatIsProposed] == 1]
    df_sum = df.groupby(rrmUlUsedMcs)[tbSize].sum().to_dict()
    logging.info("df_sum: \n%s" % df_sum)
    df_num = df.groupby(rrmUlUsedMcs)[tbSize].count().to_dict()
    logging.info("df_num.to_dict(): \n%s" % df_num)
    for mcs in df_sum.keys():
        ulFdSchedData["IniReVol"][mcs] = int(df_sum[mcs] / 8)
        ulFdSchedData["IniVol"][mcs] = int(df_sum[mcs] / 8)
        ulFdSchedData["IniNum"][mcs] = df_num[mcs]
        ulFdSchedData["AnyNum"][mcs] = df_num[mcs]
        ulFdSchedData["AllNum"][mcs] = df_num[mcs]
    # ------------------------------------------------------------------------------------------------[120 characters]
    logging.info("calculateHarqPuschInfo: ulFdSchedData:")
    logging.info("{" + "\n".join("{!r}: {!r},".format(k, v) for k, v in ulFdSchedData.items()) + "}")
    return ulFdSchedData


def filter_dl_dataframe(df):
    required_discriminators = ['timeStamp', 'sfn', 'slot', 'rnti', 'physCellId',
                               'dlFdSchedData.tbSize', 'dlFdSchedData.rrmDlUsedMcs',
                               'dlFdSchedData.isValidWhatIsProposed']
    df = df[required_discriminators].copy()
    df.dropna(inplace=True)
    df['timeStamp'] = pd.to_datetime(df['timeStamp'])
    return df


@log_begin_end_func_name
def calculate_pdsch_vol_info(path_to_pickle):
    # ------------------------------------------------------------------------------------------------[120 characters]
    import_pandas()
    df = pd.read_pickle(path_to_pickle)
    df = filter_dl_dataframe(df)
    df.to_csv(str("%s/dataframe_for_manual_analysis.csv" % get_directory(path_to_pickle)))

    rrmDlUsedMcs = "dlFdSchedData.rrmDlUsedMcs"
    tbSize = "dlFdSchedData.tbSize"
    isValidWhatIsProposed = "dlFdSchedData.isValidWhatIsProposed"
    dl_fdscheddata = [0] * 29
    df = df.astype({rrmDlUsedMcs: pd.Int32Dtype(),
                    tbSize: pd.Int32Dtype()})
    df_sum = df.groupby(rrmDlUsedMcs)[tbSize].sum().to_dict()
    logging.info("df_sum: \n%s" % df_sum)
    for mcs in df_sum.keys():
        dl_fdscheddata[mcs] = int(df_sum[mcs] / 8)
    # ------------------------------------------------------------------------------------------------[120 characters]
    logging.info(f"calculate_pdsch_vol_info: dlFdSchedData: {dl_fdscheddata}")
    return dl_fdscheddata
