# ====================================================================================================[120 characters]
# Description
# Team: 'Sqd69'
# Email:
# ----------------------------------------------------------------------------------------------------[120 characters]

import logging
import glob
import operator
import os
import importlib

import numpy as np
import pandas as pd

# ET or Feature Specific Libraries:
from testsuite.Ulm.ET.resources.tti_analysis.helper_functions import display_df_as_html, normalize_sfn_values

# Robot Framework Libraries:
from robot.libraries.BuiltIn import BuiltIn


# ====================================================================================================[120 characters]
#   Global Variables
# ====================================================================================================[120 characters]

rbi = BuiltIn()

# ====================================================================================================[120 characters]
#   Keywords
# ====================================================================================================[120 characters]


def check_adativeSlotProcessingRatio_not_greater_than90_some_greater_than_78(df):
    """ set RAD parameter as variable: rdMaxAdaptiveSlotProcessingRatio_perCent = 90
            from ttitrace check that:
            dlLoadControlData.measurementInfo.adativeSlotProcessingRatio
            - does not exceed >90
            - there shall be some values exists >78
    """
    event = 'dlLoadControlData.measurementInfo.adaptiveSlotProcessingRatio'
    df = df[['timeStamp', 'rnti', 'sfn', 'slot', event]]
    greater_than_78_found = False
    for index, row in df.iterrows():
        rbi.log(f"{index} {row}")
        if row[event] > 90:
            rbi.fail(f"adaptiveSlotProcessingRatio > 90 : {row}")
        if row[event] > 78:
            greater_than_78_found = True
    if not greater_than_78_found:
        rbi.fail("adaptiveSlotProcessingRatio > 78 not present!")


def check_total_number_of_scheduled_ues_per_l1pool(df, inactive_cells=None, count=30):
    is_equal = False
    if inactive_cells not in [None, []]:
        for i in inactive_cells:
            df = df.drop(df[df.lcrId == i].index)
    df.dropna(
        subset=['ulTdSchedSubcellData.maxNumPuschPerSlot'], inplace=True)
    df.drop_duplicates(
        subset=['sfn', 'slot', 'lcrId'], keep='first', inplace=True)
    df_sum = df.groupby(['sfn', 'slot'])['ulTdSchedSubcellData.maxNumPuschPerSlot'] \
        .agg(['sum']).reset_index().rename(columns={'sum': 'sum_maxNumPxschPerSlot'})
    sum_max = df_sum['sum_maxNumPxschPerSlot'].max()
    print(df_sum)
    print(sum_max)
    rbi.log_to_console("\n Verification on scheduled UEs Per L1pool: \n")
    rbi.log_to_console(f"Maximum number of scheduled UEs per L1 pool:\t{sum_max}")
    rbi.log_to_console(f"Expected number of scheduled UEs per L1 pool:\t{count}")
    if sum_max == count:
        is_equal = True
        rbi.log_to_console(f" PASS: Max num of scheduled UEs ({sum_max}) == Expected num of scheduled UEs ({count})")
    if not is_equal:
        rbi.fail(f"total number of scheduled ues per l1pool is not equal to {count}!")


def check_total_number_of_scheduled_ues_per_l1pool_dl(df, inactive_cells=None, count=30):
    is_equal = False
    if inactive_cells not in [None, []]:
        for i in inactive_cells:
            df = df.drop(df[df.lcrId == i].index)
    df.dropna(
        subset=['dlTdSchedSubcellData.maxNumPdschPerSlot'], inplace=True)
    df.drop_duplicates(
        subset=['sfn', 'slot', 'lcrId'], keep='first', inplace=True)
    df_sum = df.groupby(['sfn', 'slot'])['dlTdSchedSubcellData.maxNumPdschPerSlot'] \
        .agg(['sum']).reset_index().rename(columns={'sum': 'sum_maxNumPxschPerSlot'})
    sum_max = df_sum['sum_maxNumPxschPerSlot'].max()
    print(df_sum)
    print(sum_max)
    rbi.log_to_console("\n Verification on scheduled UEs Per L1pool: \n")
    rbi.log_to_console(f"Maximum number of scheduled UEs per L1 pool:\t{sum_max}")
    rbi.log_to_console(f"Expected number of scheduled UEs per L1 pool:\t{count}")
    if sum_max == count:
        is_equal = True
        rbi.log_to_console(f" PASS: Max num of scheduled UEs ({sum_max}) == Expected num of scheduled UEs ({count})")
    if not is_equal:
        rbi.fail(f"total number of scheduled ues per l1pool is not equal to {count}!")
